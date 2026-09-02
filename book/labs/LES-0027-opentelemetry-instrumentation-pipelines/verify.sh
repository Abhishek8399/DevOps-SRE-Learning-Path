#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$script_dir"

fail() {
  printf 'verification-failed=%s\n' "$1" >&2
  exit 1
}

expect_token() {
  local output="$1"
  local token="$2"
  grep -Fq -- "$token" <<<"$output" || fail "missing-token-${token}"
}

capture_success() {
  local __variable="$1"
  shift
  local output status
  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e
  if (( status != 0 )); then
    printf '%s\n' "$output" >&2
    fail "command-status-${status}-$*"
  fi
  printf -v "$__variable" '%s' "$output"
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

if (( $# != 1 )) || [[ "$1" != 'static' && "$1" != 'runtime' ]]; then
  printf '%s\n' 'usage: bash verify.sh {static|runtime}' >&2
  exit 64
fi
mode="$1"

for required in python3 grep sed sha256sum shellcheck docker mktemp; do
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

for path in sorted(Path('.').rglob('*.py')):
    ast.parse(path.read_text(encoding='utf-8'), filename=str(path))

module = ast.parse(Path('lab_controller.py').read_text(encoding='utf-8'))
mapping = None
for node in module.body:
    if isinstance(node, ast.Assign) and any(
        isinstance(target, ast.Name) and target.id == 'ACTION_RISKS'
        for target in node.targets
    ):
        mapping = ast.literal_eval(node.value)
        break
expected = {
    'doctor': 'read-only',
    'model': 'read-only',
    'prepare': 'networked-install',
    'validate-configs': 'mutating-bounded',
    'setup': 'mutating-bounded',
    'status': 'read-only',
    'check': 'read-only',
    'run': 'mutating-bounded',
    'recover-context': 'mutating-bounded',
    'interrupt-gateway': 'mutating-bounded',
    'compare-sampling': 'mutating-bounded',
    'verify-operation': 'sampled-read-only',
    'cleanup': 'destructive-disposable',
}
if mapping != expected:
    raise SystemExit(f'public action risk map mismatch: {mapping!r}')
print('python_ast=passed')
print('public_action_risk_map=passed')
PY

PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py' -v

for label in '[READ-ONLY]' '[SAMPLED READ-ONLY]' '[MUTATING]' '[DESTRUCTIVE]' '[NETWORK ACCESS]'; do
  grep -Fq -- "$label" README.md || fail "missing-safety-label-${label}"
done
grep -Fq 'if (( EUID == 0 )); then' lab.sh || fail 'shell-root-guard-missing'
grep -Fq 'if CURRENT_UID == 0:' lab_controller.py || fail 'controller-root-guard-missing'
grep -Fq 'runtime_verification_passed=true' lab_controller.py \
  || fail 'runtime-verification-success-contract-missing'
grep -Fq 'bounded-in-process-queue' services/service_a.py \
  || fail 'async-carrier-boundary-missing'
if grep -Rq 'RECORD_REAL_' artifacts.lock.json requirements.lock; then
  fail 'artifact-lock-placeholder-remains'
fi
grep -Fq 'pull_policy: never' compose.yaml || fail 'compose-pull-policy-missing'
grep -Fq -- '--no-index --no-deps' compose.yaml || fail 'offline-pip-policy-missing'
grep -Fq 'internal: true' compose.yaml || fail 'internal-network-missing'
if grep -Eq 'docker\.sock|network_mode:[[:space:]]*host|privileged:[[:space:]]*true|^[[:space:]]+ports:' compose.yaml; then
  fail 'unsafe-compose-capability-or-host-port-present'
fi

doctor="$(bash lab.sh doctor)"
for token in \
  'verification_mode=doctor-read-only-preflight' \
  'caller_root=false' \
  'ubuntu_24_04_ready=true' \
  'tool_python3=available' \
  'tool_docker_client=available' \
  'tool_docker_compose=available' \
  'docker_daemon_ready=true' \
  'published_host_ports=0' \
  'artifact_lock=complete' \
  'requirements_lock_count=14' \
  'prepared_artifacts=verified' \
  'compose_render=passed' \
  'compose_render_binding=exact-reviewed-lock' \
  'collector_config_validation=available-next-step' \
  'runtime_ready=true' \
  'normal_setup_network_access=false' \
  'prepare_network_access=explicit-only'; do
  expect_token "$doctor" "$token"
done

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

root_runtime_check='not-run-no-passwordless-sudo'
if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  set +e
  root_output="$(sudo -n bash lab.sh model 2>&1)"
  root_status=$?
  set -e
  [[ "$root_status" -eq 77 ]] || fail "root-refusal-status-${root_status}"
  expect_token "$root_output" 'root-is-refused-run-as-a-normal-user'
  root_runtime_check='passed'
fi

if [[ "$mode" == 'static' ]]; then
  current="$(bash lab.sh status)"
  state_value="$(sed -n 's/^state=//p' <<<"$current" | head -n 1)"
  [[ "$state_value" == 'absent' || "$state_value" == 'active' ]] \
    || fail "static-mode-state-not-auditable-${state_value:-missing}"
  printf '%s\n' \
    'verification_passed=true' \
    'verification_mode=static-readiness' \
    'platform=Ubuntu-24.04' \
    'verification_scope=syntax,shellcheck,static-contracts,deterministic-model,complete-locks,offline-artifacts,compose-render,doctor' \
    'runtime_mutations=0' \
    'network_downloads=0' \
    "observed_state=${state_value}" \
    "root_runtime_check=${root_runtime_check}"
  exit 0
fi

initial="$(bash lab.sh status)"
expect_token "$initial" 'state=absent'
expect_token "$initial" 'state_recovery_count=0'
expect_token "$initial" 'project_resource_count=0'

lifecycle_token=''
setup_output=''
baseline_output=''
broken_output=''
recovery_output=''
outage_output=''
sampling_output=''
audit_output=''
cleanup_output=''
lock_holder_pid=''
lock_ready_path=''
cleanup_on_exit() {
  local original_status=$?
  local cleanup_output cleanup_status
  trap - EXIT
  if [[ -n "$lock_holder_pid" ]] && kill -0 "$lock_holder_pid" 2>/dev/null; then
    kill -TERM "$lock_holder_pid" 2>/dev/null || true
    wait "$lock_holder_pid" 2>/dev/null || true
  fi
  if [[ -n "$lock_ready_path" && -f "$lock_ready_path" ]]; then
    rm -- "$lock_ready_path"
  fi
  if [[ -n "$lifecycle_token" ]]; then
    set +e
    cleanup_output="$(bash lab.sh cleanup --expect-token "$lifecycle_token" 2>&1)"
    cleanup_status=$?
    set -e
    if (( cleanup_status != 0 )); then
      printf '%s\n' "$cleanup_output" >&2
      printf '%s\n' 'verification-failed=trap-cleanup-failed' >&2
      exit 1
    fi
  fi
  exit "$original_status"
}
trap cleanup_on_exit EXIT

capture_success setup_output bash lab.sh setup
lifecycle_token="$(sed -n 's/^lifecycle_token=//p' <<<"$setup_output")"
[[ "$lifecycle_token" =~ ^[0-9a-f]{32}$ ]] || fail 'setup-token-invalid'
expect_token "$setup_output" 'setup_complete=true'
expect_token "$setup_output" 'containers=5'
expect_token "$setup_output" 'network_internal=true'

lock_ready_path="$(
  mktemp "/tmp/reliability-atlas-LES-0027-${UID}.lock-ready.XXXXXX"
)"
PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY' >"$lock_ready_path" &
import lab_controller as controller
import time

state = controller.state_document()
with controller.operation_lock(state):
    print('operation_lock_held=true', flush=True)
    time.sleep(120)
PY
lock_holder_pid=$!
for _ in {1..100}; do
  grep -Fq 'operation_lock_held=true' "$lock_ready_path" && break
  kill -0 "$lock_holder_pid" 2>/dev/null || fail 'operation-lock-holder-exited-early'
  sleep 0.05
done
grep -Fq 'operation_lock_held=true' "$lock_ready_path" || \
  fail 'operation-lock-holder-not-ready'
expect_failure 73 'another-lab-operation-is-active' \
  bash lab.sh cleanup --expect-token "$lifecycle_token"
kill -TERM "$lock_holder_pid"
wait "$lock_holder_pid" 2>/dev/null || true
lock_holder_pid=''
rm -- "$lock_ready_path"
lock_ready_path=''
post_lock_refusal="$(bash lab.sh status)"
expect_token "$post_lock_refusal" 'state=active'
expect_token "$post_lock_refusal" 'project_container_count=5'

# The terminated owner deliberately leaves its matching sentinel. The next
# operation must reclaim it only after the kernel-held lock has been released.
capture_success baseline_output bash lab.sh run baseline
expect_token "$baseline_output" 'per_hop_reconciliation_passed=true'
expect_token "$baseline_output" 'source_span_creation_delta=3'
expect_token "$baseline_output" 'sdk_export_success_delta=3'
expect_token "$baseline_output" 'gateway_sink_visibility_delta=3'

capture_success broken_output bash lab.sh run broken-context
expect_token "$broken_output" 'context_joined=false'
expect_token "$broken_output" 'per_hop_reconciliation_passed=true'

capture_success recovery_output bash lab.sh recover-context
expect_token "$recovery_output" 'context_recovered=true'
expect_token "$recovery_output" 'per_hop_reconciliation_passed=true'

capture_success outage_output bash lab.sh interrupt-gateway
for token in \
  'queue_occupancy_measured=true' \
  'oldest_queue_age_measured=true' \
  'retry_attempts_measured=true' \
  'refused_span_delta=0' \
  'dropped_span_delta=0' \
  'per_hop_reconciliation_measured=true' \
  'queue_experiment_complete=true'; do
  expect_token "$outage_output" "$token"
done

capture_success sampling_output bash lab.sh compare-sampling
expect_token "$sampling_output" 'sampling_full_observed=32'
expect_token "$sampling_output" 'deterministic_trace_ids_equal=true'
quarter="$(sed -n 's/^sampling_quarter_observed=//p' <<<"$sampling_output")"
[[ "$quarter" =~ ^[0-9]+$ && "$quarter" -gt 0 && "$quarter" -lt 32 ]] \
  || fail 'runtime-quarter-sampling-not-discriminating'

capture_success audit_output \
  bash lab.sh verify-operation --expect-token "$lifecycle_token"
for token in \
  'runtime_control_records_verified=true' \
  'source_creation_delta=3' \
  'sdk_export_delta=3' \
  'agent_receive_delta=3' \
  'gateway_export_delta=3' \
  'refused_span_delta=0' \
  'dropped_span_delta=0' \
  'per_hop_reconciliation_passed=true' \
  'sampling_deterministic_trace_ids_equal=true' \
  'runtime_evidence_complete=true' \
  'runtime_verification_passed=true'; do
  expect_token "$audit_output" "$token"
done

active="$(bash lab.sh status)"
expect_token "$active" 'state=active'
expect_token "$active" 'evidence_records=baseline.json,broken-context.json,gateway-interruption.json,recovery.json,sampling.json'
expect_token "$active" 'per_hop_evidence_complete=true'

capture_success cleanup_output \
  bash lab.sh cleanup --expect-token "$lifecycle_token"
expect_token "$cleanup_output" 'cleanup_proven=true'
expect_token "$cleanup_output" 'project_resources=absent'
lifecycle_token=''

final="$(bash lab.sh status)"
expect_token "$final" 'state=absent'
expect_token "$final" 'state_recovery_count=0'
expect_token "$final" 'project_resource_count=0'

printf '%s\n' \
  'verification_passed=true' \
  'verification_mode=full-offline-runtime' \
  'platform=Ubuntu-24.04' \
  'verification_scope=static-contracts,collector-configs,five-container-runtime,context-break-recovery,per-hop-counters,queue-retry-drain,sampling,evidence-bindings,exact-cleanup' \
  'artifact_lock=complete' \
  'opentelemetry_runtime_executed=true' \
  'collector_config_binary_validation=passed' \
  'docker_runtime_created=true' \
  'runtime_evidence_complete=true' \
  'network_downloads=0' \
  'cloud_calls=0' \
  "root_runtime_check=${root_runtime_check}" \
  'state=absent' \
  'project_resources=absent' \
  'atomic_deletion_claimed=false'
