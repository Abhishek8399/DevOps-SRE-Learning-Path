#!/usr/bin/env bash
set -euo pipefail

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$script_dir"

state_path="/tmp/reliability-atlas-LES-0027-${UID}.state.d"

fail() {
  printf 'verification-failed=%s\n' "$1" >&2
  exit 1
}

expect_token() {
  local output="$1"
  local token="$2"
  grep -Fq -- "$token" <<<"$output" || fail "missing-token-${token}"
}

expect_failure() {
  local expected_status="$1"
  local expected_token="$2"
  shift 2
  local output status
  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e
  [[ "$status" -eq "$expected_status" ]] \
    || fail "unexpected-status-${expected_token}-${status}"
  expect_token "$output" "$expected_token"
}

for required in python3 grep find stat sha256sum shellcheck docker; do
  command -v "$required" >/dev/null 2>&1 \
    || fail "missing-required-command-${required}"
done
docker compose version >/dev/null 2>&1 \
  || fail 'missing-required-command-docker-compose'

platform_detected="$(PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import platform

values = platform.freedesktop_os_release()
print(f"{values.get('ID', 'unknown')}-{values.get('VERSION_ID', 'unknown')}")
PY
)"
[[ "$platform_detected" == 'ubuntu-24.04' ]] \
  || fail "canonical-platform-requires-Ubuntu-24.04-found-${platform_detected}"

bash -n lab.sh
bash -n verify.sh
shellcheck --shell=bash lab.sh verify.sh

PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import ast
from pathlib import Path

for path in sorted(Path(".").rglob("*.py")):
    ast.parse(path.read_text(encoding="utf-8"), filename=str(path))

module = ast.parse(Path("lab_controller.py").read_text(encoding="utf-8"))
mapping = None
for node in module.body:
    if isinstance(node, ast.Assign) and any(
        isinstance(target, ast.Name) and target.id == "ACTION_RISKS"
        for target in node.targets
    ):
        mapping = ast.literal_eval(node.value)
        break
expected = {
    "doctor": "read-only",
    "model": "read-only",
    "prepare": "networked-install",
    "validate-configs": "mutating-bounded",
    "setup": "mutating-bounded",
    "status": "read-only",
    "check": "read-only",
    "run": "mutating-bounded",
    "recover-context": "mutating-bounded",
    "interrupt-gateway": "mutating-bounded",
    "compare-sampling": "mutating-bounded",
    "verify-operation": "sampled-read-only",
    "cleanup": "destructive-disposable",
}
if mapping != expected:
    raise SystemExit(f"public action risk map mismatch: {mapping!r}")
print("python_ast=passed")
print("public_action_risk_map=passed")
PY

PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py' -v

for label in '[READ-ONLY]' '[SAMPLED READ-ONLY]' '[MUTATING]' '[DESTRUCTIVE]' '[NETWORK ACCESS]'; do
  grep -Fq -- "$label" README.md || fail "missing-safety-label-${label}"
done
grep -Fq 'if (( EUID == 0 )); then' lab.sh || fail 'shell-root-guard-missing'
grep -Fq 'if CURRENT_UID == 0:' lab_controller.py || fail 'controller-root-guard-missing'
grep -Fq 'runtime-evidence-incomplete-per-hop-counter-contract-not-implemented' \
  lab_controller.py || fail 'runtime-evidence-refusal-missing'
grep -Fq 'bounded-in-process-queue' services/service_a.py \
  || fail 'async-carrier-boundary-missing'
grep -Fq 'RECORD_REAL_' artifacts.lock.json || fail 'image-lock-placeholder-missing'
grep -Fq 'RECORD_REAL_' requirements.lock || fail 'wheel-lock-placeholder-missing'
grep -Fq 'pull_policy: never' compose.yaml || fail 'compose-pull-policy-missing'
grep -Fq -- '--no-index --no-deps' compose.yaml || fail 'offline-pip-policy-missing'
grep -Fq 'internal: true' compose.yaml || fail 'internal-network-missing'
if grep -Eq 'docker\.sock|network_mode:[[:space:]]*host|privileged:[[:space:]]*true' compose.yaml; then
  fail 'unsafe-compose-capability-present'
fi

initial="$(bash lab.sh status)"
expect_token "$initial" 'state=absent'
expect_token "$initial" 'state_recovery_count=0'
expect_token "$initial" 'project_resource_count=0'
[[ ! -e "$state_path" && ! -L "$state_path" ]] || fail 'unexpected-initial-state-path'
if compgen -G "/tmp/reliability-atlas-LES-0027-${UID}.state.d.cleanup.*" >/dev/null; then
  fail 'unexpected-initial-cleanup-recovery-state'
fi
if compgen -G '.artifacts*' >/dev/null; then
  fail 'unexpected-prepared-or-staging-artifacts-present'
fi

doctor="$(bash lab.sh doctor)"
for token in \
  'verification_mode=doctor-read-only-preflight' \
  'caller_root=false' \
  'ubuntu_24_04_ready=true' \
  'tool_python3=available' \
  'tool_curl=available' \
  'tool_docker_client=available' \
  'tool_docker_compose=available' \
  'loopback_port_18027=available' \
  'loopback_port_18888=available' \
  'loopback_port_18889=available' \
  'loopback_port_18890=available' \
  'artifact_lock=incomplete' \
  'prepared_artifacts=absent' \
  'compose_render=passed' \
  'compose_render_binding=synthetic-substitution-for-static-render-only' \
  'collector_config_validation=blocked-lock-incomplete' \
  'runtime_ready=false' \
  'normal_setup_network_access=false' \
  'prepare_network_access=explicit-only'; do
  expect_token "$doctor" "$token"
done
daemon_state="$(sed -n 's/^docker_daemon_ready=//p' <<<"$doctor")"
[[ "$daemon_state" == 'true' || "$daemon_state" == 'false' ]] \
  || fail "invalid-docker-daemon-readiness-${daemon_state:-missing}"
expect_token "$doctor" 'docker_daemon_detail='

model="$(bash lab.sh model)"
for token in \
  'engine=deterministic-contract-model' \
  'opentelemetry_executed=false' \
  'collector_executed=false' \
  'network_targets=0' \
  'filesystem_mutations=0' \
  'baseline_context_joined=true' \
  'broken_context_joined=false' \
  'recovery_context_joined=true' \
  'modeled_gateway_queue_depth=4' \
  'modeled_gateway_recovered_exports=4' \
  'modeled_sampling_full=32' \
  'model_is_not-runtime-evidence=true'; do
  expect_token "$model" "$token"
done
quarter="$(sed -n 's/^modeled_sampling_quarter=//p' <<<"$model")"
[[ "$quarter" =~ ^[0-9]+$ && "$quarter" -gt 0 && "$quarter" -lt 32 ]] \
  || fail 'modeled-quarter-sampling-not-discriminating'

expect_failure 64 'prepare-requires-explicit---allow-network-downloads' \
  bash lab.sh prepare
expect_failure 78 'artifact-lock-incomplete-record-reviewed-digests-first' \
  bash lab.sh prepare --allow-network-downloads
expect_failure 78 'collector-config-validation-blocked-artifact-lock-incomplete' \
  bash lab.sh validate-configs
expect_failure 78 'artifact-lock-incomplete-record-reviewed-digests-first' \
  bash lab.sh setup
expect_failure 66 "required-directory-missing-reliability-atlas-LES-0027-${UID}.state.d" \
  bash lab.sh verify-operation

[[ ! -e "$state_path" && ! -L "$state_path" ]] || fail 'fail-closed-action-created-state'
if compgen -G '.artifacts*' >/dev/null; then
  fail 'fail-closed-action-created-artifacts'
fi

root_runtime_check='not-run-no-passwordless-sudo'
if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  expect_failure 77 'root-is-refused-run-as-a-normal-user' sudo -n bash lab.sh model
  expect_failure 77 'root-is-refused-run-as-a-normal-user' sudo -n bash verify.sh
  root_runtime_check='passed'
fi

final="$(bash lab.sh status)"
expect_token "$final" 'state=absent'
expect_token "$final" 'state_recovery_count=0'
expect_token "$final" 'project_resource_count=0'
[[ ! -e "$state_path" && ! -L "$state_path" ]] || fail 'final-state-path-present'
if compgen -G "/tmp/reliability-atlas-LES-0027-${UID}.state.d.cleanup.*" >/dev/null; then
  fail 'final-cleanup-recovery-state-present'
fi
if compgen -G '.artifacts*' >/dev/null; then
  fail 'final-artifact-path-present'
fi

printf '%s\n' \
  'verification_passed=true' \
  'platform=Ubuntu-24.04' \
  'verification_scope=static-contracts,deterministic-model,fail-closed-locks,async-carrier-source,action-risk-map,final-absence' \
  'artifact_lock=incomplete-by-design' \
  'opentelemetry_runtime_executed=false' \
  'collector_config_binary_validation=not-run-lock-incomplete' \
  'docker_runtime_created=false' \
  'runtime_evidence_complete=false' \
  'network_downloads=0' \
  'cloud_calls=0' \
  "root_runtime_check=${root_runtime_check}" \
  'state=absent' \
  'atomic_deletion_claimed=false'
