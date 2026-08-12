#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

# Fault injection is verifier-controlled. Do not let an inherited developer
# setting affect baseline, preservation, or private-regression checks.
unset LAB_FAULT_POINT

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$script_dir"

state_path="/tmp/reliability-atlas-LES-0026-${UID}.state.d"
owns_lifecycle=0
owned_token=''
owned_state_identity=''
owned_root=''
owned_root_identity=''
owned_state_cleanup=''
owned_state_final=''
foreign_probe_armed=0
foreign_state_identity=''
foreign_marker_expected_digest=''

fail() {
  printf 'verification-failed=%s\n' "$1" >&2
  exit 1
}

expect_token() {
  local output="$1"
  local token="$2"
  grep -Fq -- "$token" <<<"$output" || fail "missing-token-${token}"
}

reject_token() {
  local output="$1"
  local token="$2"
  if grep -Fq -- "$token" <<<"$output"; then
    fail "unexpected-token-${token}"
  fi
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

identity_at() {
  local path="$1"
  stat -c '%d:%i' -- "$path"
}

owned_state_present() {
  local candidate
  for candidate in "$state_path" "$owned_state_cleanup" "$owned_state_final"; do
    [[ -n "$candidate" ]] || continue
    if [[ -d "$candidate" && ! -L "$candidate" \
      && "$(identity_at "$candidate")" == "$owned_state_identity" ]]; then
      return 0
    fi
  done
  return 1
}

cleanup_on_exit() {
  local status=$?
  if [[ "$owns_lifecycle" -eq 1 ]] && owned_state_present; then
    bash lab.sh cleanup --expect-token "$owned_token" >/dev/null 2>&1 || true
  fi
  exit "$status"
}

cleanup_foreign_probe_on_exit() {
  local status=$?
  local marker="${state_path}/marker"
  trap - EXIT
  if [[ "$foreign_probe_armed" -eq 1 \
    && -d "$state_path" \
    && ! -L "$state_path" \
    && "$(identity_at "$state_path")" == "$foreign_state_identity" \
    && "$(stat -c '%u:%a' -- "$state_path")" == "${UID}:700" ]]; then
    if [[ -f "$marker" \
      && ! -L "$marker" \
      && "$(stat -c '%u:%a:%h' -- "$marker")" == "${UID}:600:1" ]]; then
      local marker_digest_line marker_digest
      marker_digest_line="$(sha256sum -- "$marker" 2>/dev/null || true)"
      marker_digest="${marker_digest_line%% *}"
      if [[ "$marker_digest" == "$foreign_marker_expected_digest" ]]; then
        rm -f -- "$marker"
      fi
    fi
    rmdir -- "$state_path" 2>/dev/null || true
  fi
  exit "$status"
}

capture_setup() {
  local output key value
  output="$(bash lab.sh setup)"
  expect_token "$output" 'setup_complete=true'
  owned_token=''
  owned_state_identity=''
  owned_root=''
  owned_root_identity=''
  owned_state_cleanup=''
  owned_state_final=''
  while IFS='=' read -r key value; do
    case "$key" in
      lifecycle_token) owned_token="$value" ;;
      root) owned_root="$value" ;;
      root_identity) owned_root_identity="$value" ;;
      state_identity) owned_state_identity="$value" ;;
      state_cleanup) owned_state_cleanup="$value" ;;
      state_final) owned_state_final="$value" ;;
    esac
  done <<<"$output"
  [[ "$owned_token" =~ ^[0-9a-f]{32}$ ]] || fail 'setup-token-grammar'
  [[ "$owned_root" =~ ^/tmp/reliability-atlas-LES-0026-${UID}\.[A-Za-z0-9_-]+$ ]] \
    || fail 'setup-root-grammar'
  [[ -d "$state_path" && ! -L "$state_path" ]] || fail 'setup-state-type'
  [[ -d "$owned_root" && ! -L "$owned_root" ]] || fail 'setup-root-type'
  [[ "$(identity_at "$state_path")" == "$owned_state_identity" ]] \
    || fail 'setup-state-identity'
  [[ "$(identity_at "$owned_root")" == "$owned_root_identity" ]] \
    || fail 'setup-root-identity'
  [[ "$owned_state_cleanup" == "${state_path}.cleanup.${owned_token}."* ]] \
    || fail 'setup-state-cleanup-grammar'
  [[ "$owned_state_final" == "${state_path}.final.${owned_token}."* ]] \
    || fail 'setup-state-final-grammar'
  owns_lifecycle=1
}

cleanup_current() {
  local output check
  output="$(bash lab.sh cleanup --expect-token "$owned_token")"
  expect_token "$output" 'cleanup_proven=true'
  check="$(bash lab.sh check)"
  expect_token "$check" 'state=absent'
  expect_token "$check" 'state_recovery_count=0'
  expect_token "$check" 'orphan_count=0'
  owns_lifecycle=0
}

for required in python3 shellcheck sha256sum grep find stat; do
  command -v "$required" >/dev/null 2>&1 \
    || fail "missing-required-command-${required}"
done

bash -n lab.sh
bash -n verify.sh
shellcheck --shell=bash lab.sh verify.sh
grep -Fq 'if (( EUID == 0 )); then' lab.sh || fail 'lab-root-guard-missing'
grep -Fq 'if CURRENT_UID == 0:' lab_controller.py \
  || fail 'controller-root-guard-missing'
grep -Fq 'cProfile.Profile()' model/telemetry_model.py \
  || fail 'stdlib-profile-model-missing'
grep -Fq 'synthetic keys are not W3C traceparent identifiers' \
  model/telemetry_model.py || fail 'synthetic-trace-boundary-missing'
for label in '[READ-ONLY]' '[MUTATING]' '[DESTRUCTIVE]'; do
  grep -Fq -- "$label" README.md || fail "missing-safety-label-${label}"
done
grep -Fq 'book/labs/LES-0026-observability-foundations' README.md \
  || fail 'canonical-learner-path-missing'
if grep -Eq '^cd .*drafts/' README.md; then
  fail 'draft-path-exposed-as-learner-command'
fi
if grep -Eiq 'future canonical|after promotion|before promotion|intended for promotion|reviewing the draft' README.md; then
  fail 'stale-draft-promotion-language'
fi
grep -Fq 'guided walkthrough' README.md || fail 'walkthrough-classification-missing'
grep -Fq 'record-hypothesis delayed' README.md || fail 'hypothesis-command-missing'
grep -Fq 'pipeline_trace_produced=8' README.md || fail 'pipeline-key-doc-mismatch'

platform_detected="$(PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import platform

values = platform.freedesktop_os_release()
identifier = values.get('ID', 'unknown')
version = values.get('VERSION_ID', 'unknown')
if identifier == 'ubuntu' and version == '24.04':
    print('Ubuntu-24.04')
else:
    print(f'{identifier}-{version}')
PY
)"
if [[ "$platform_detected" != 'Ubuntu-24.04' ]]; then
  printf 'platform=%s\n' "$platform_detected" >&2
  fail 'canonical-platform-requires-Ubuntu-24.04'
fi

PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import ast
import json
from pathlib import Path

for path in sorted(Path('.').rglob('*.py')):
    ast.parse(path.read_text(encoding='utf-8'), filename=str(path))

config = json.loads(Path('config/scenario.json').read_text(encoding='utf-8'))
assert config['lesson'] == 'LES-0026'
assert len(config['requests']) == 8
assert config['missingSignalCase']['traceDropSequences'] == [3, 7]
assert all('syntheticTraceKey' in request for request in config['requests'])
assert all('traceId' not in request for request in config['requests'])
print('python_ast_and_config=passed')
PY

# Baseline absence is proven before any EXIT cleanup trap exists. A verifier
# that encounters somebody else's lifecycle exits without cleanup authority.
initial="$(bash lab.sh check)"
if ! grep -Fq 'state=absent' <<<"$initial" \
  || ! grep -Fq 'state_recovery_count=0' <<<"$initial" \
  || ! grep -Fq 'orphan_count=0' <<<"$initial"; then
  fail 'pre-existing-or-concurrent-state-present'
fi

# Prove a nested verifier preserves a pre-existing exact state object. The
# temporary trap is authorized only for this verifier-created directory and
# constant marker. It never invokes lab cleanup.
if ! mkdir -m 700 -- "$state_path"; then
  fail 'pre-existing-state-race-lost-preserved-competitor'
fi
foreign_state_identity="$(identity_at "$state_path")"
foreign_marker_expected_line="$(printf '%s\n' 'foreign-state-marker' | sha256sum)"
foreign_marker_expected_digest="${foreign_marker_expected_line%% *}"
foreign_probe_armed=1
trap cleanup_foreign_probe_on_exit EXIT
printf '%s\n' 'foreign-state-marker' >"${state_path}/marker"
chmod 600 "${state_path}/marker"
foreign_marker_identity="$(identity_at "${state_path}/marker")"
foreign_marker_digest="$(sha256sum "${state_path}/marker")"
expect_failure 1 'verification-failed=pre-existing-or-concurrent-state-present' \
  bash verify.sh
[[ "$(identity_at "$state_path")" == "$foreign_state_identity" ]] \
  || fail 'pre-existing-state-identity-changed'
[[ "$(identity_at "${state_path}/marker")" == "$foreign_marker_identity" ]] \
  || fail 'pre-existing-marker-identity-changed'
[[ "$(sha256sum "${state_path}/marker")" == "$foreign_marker_digest" ]] \
  || fail 'pre-existing-marker-content-changed'
expect_failure 73 'state-already-exists' bash lab.sh setup
[[ "$(sha256sum "${state_path}/marker")" == "$foreign_marker_digest" ]] \
  || fail 'setup-mutated-pre-existing-state'
[[ "$(stat -c '%u:%a:%h' -- "${state_path}/marker")" == "${UID}:600:1" ]] \
  || fail 'pre-existing-marker-metadata-changed'
rm -f -- "${state_path}/marker"
rmdir -- "$state_path"
foreign_probe_armed=0
trap - EXIT

post_foreign="$(bash lab.sh check)"
expect_token "$post_foreign" 'state=absent'
expect_token "$post_foreign" 'state_recovery_count=0'
expect_token "$post_foreign" 'orphan_count=0'

# Induce a private-regression failure before normal lifecycle work. Its bounded
# finalizer must remove all known entries; otherwise the scanner-visible root
# makes this check fail closed instead of leaving invisible /tmp residue.
expect_failure 75 'fault-injected-after-file-quarantine' \
  env LAB_FAULT_POINT=after-file-quarantine \
  bash lab.sh verify-removal-races
after_private_failure="$(bash lab.sh check)"
expect_token "$after_private_failure" 'state=absent'
expect_token "$after_private_failure" 'state_recovery_count=0'
expect_token "$after_private_failure" 'orphan_count=0'

trap cleanup_on_exit EXIT

removal_races="$(bash lab.sh verify-removal-races)"
expect_token "$removal_races" 'removal_race_regressions=passed'
expect_token "$removal_races" 'replacement_preserved=true'
expect_token "$removal_races" 'atomic_deletion_claimed=false'

unexpected="$(bash lab.sh verify-unexpected-preservation)"
expect_token "$unexpected" 'unexpected_child_refused=true'
expect_token "$unexpected" 'unexpected_child_preserved_before_explicit_removal=true'

dry_setup="$(LAB_DRY_RUN=1 bash lab.sh setup)"
expect_token "$dry_setup" 'dry_run=true'
expect_token "$dry_setup" 'mutation_performed=false'
after_dry_setup="$(bash lab.sh check)"
[[ "$post_foreign" == "$after_dry_setup" ]] || fail 'setup-dry-run-mutated-state'

capture_setup

# A second verifier sees this valid lifecycle before installing a cleanup trap.
descriptor_before="$(sha256sum "${state_path}/descriptor.json")"
sentinel_before="$(sha256sum "${owned_root}/.sentinel")"
state_before="$(identity_at "$state_path")"
root_before="$(identity_at "$owned_root")"
expect_failure 1 'verification-failed=pre-existing-or-concurrent-state-present' \
  bash verify.sh
[[ "$(sha256sum "${state_path}/descriptor.json")" == "$descriptor_before" ]] \
  || fail 'concurrent-verifier-mutated-descriptor'
[[ "$(sha256sum "${owned_root}/.sentinel")" == "$sentinel_before" ]] \
  || fail 'concurrent-verifier-mutated-sentinel'
[[ "$(identity_at "$state_path")" == "$state_before" ]] \
  || fail 'concurrent-verifier-replaced-state'
[[ "$(identity_at "$owned_root")" == "$root_before" ]] \
  || fail 'concurrent-verifier-replaced-root'

expect_failure 65 'missing-file-guided.record.json' \
  bash lab.sh inspect-signals guided

guided_run="$(bash lab.sh run guided)"
expect_token "$guided_run" 'request_rows=8'
expect_token "$guided_run" 'trace_rows=8'
expect_token "$guided_run" 'profile_kind=python-cprofile-call-count-summary'

guided_signals="$(bash lab.sh inspect-signals guided)"
expect_token "$guided_signals" 'latency_breach_sequence=6'
expect_token "$guided_signals" 'error_sequence=4'
expect_token "$guided_signals" 'queue_breach_sequences=3,5'
expect_token "$guided_signals" 'trace_context_standard=none-synthetic-keys-only'
expect_token "$guided_signals" 'correlation_is_causality=false'

ordering="$(bash lab.sh inspect-ordering)"
expect_token "$ordering" 'sequence_order=1,2,3,4,5,6,7,8'
expect_token "$ordering" 'event_time_order=1,2,3,4,5,6,7,8'
expect_token "$ordering" 'ingest_time_order=1,3,4,5,6,2,7,8'
expect_token "$ordering" 'missing_sequences=none'
expect_token "$ordering" 'ingest_reordered=true'
expect_token "$ordering" 'fixture_explanation=sequence-2-modeled-ingest-delay'
expect_token "$ordering" 'production_cause_proven=false'

guided_verification="$(bash lab.sh verify-guided)"
expect_token "$guided_verification" 'guided_verified=true'
expect_token "$guided_verification" \
  'signal_families=metrics,logs,traces,events,profiles'
expect_token "$guided_verification" 'production_causality_proven=false'

missing_run="$(bash lab.sh run missing-signal)"
expect_token "$missing_run" 'request_rows=8'
expect_token "$missing_run" 'trace_rows=6'

missing_signals="$(bash lab.sh inspect-signals missing-signal)"
expect_token "$missing_signals" 'missing_trace_rows=2'
expect_token "$missing_signals" 'cause_determined=false'
expect_token "$missing_signals" \
  'candidate_causes=not-produced,sampled,dropped,delayed,query-scope,correlation-defect'
expect_token "$missing_signals" \
  'next_evidence=record-hypothesis-then-inspect-pipeline'
reject_token "$missing_signals" 'export_queue_full'
reject_token "$missing_signals" 'modeled_drop_sequences=3,7'

expect_failure 64 'pipeline-reveal-requires-hypothesis-attempt' \
  bash lab.sh inspect-pipeline missing-signal
expect_failure 64 'operation-requires-missing-signal-inspection' \
  bash lab.sh verify-operation

hypothesis="$(bash lab.sh record-hypothesis delayed)"
expect_token "$hypothesis" 'hypothesis_recorded=delayed'
expect_token "$hypothesis" 'attempted_before_reveal=true'
expect_token "$hypothesis" 'scored_assessment=false'

pipeline="$(bash lab.sh inspect-pipeline missing-signal)"
expect_token "$pipeline" 'walkthrough=true'
expect_token "$pipeline" 'attempt_recorded_before_reveal=true'
expect_token "$pipeline" 'pipeline_trace_produced=8'
expect_token "$pipeline" 'pipeline_trace_exported=6'
expect_token "$pipeline" 'pipeline_trace_dropped=2'
expect_token "$pipeline" 'modeled_drop_sequences=3,7'
expect_token "$pipeline" 'modeled_drop_reason=export_queue_full'
expect_token "$pipeline" 'production_absence_explained=false'

operation="$(bash lab.sh verify-operation)"
expect_token "$operation" \
  'guided_signal_families=metrics,logs,traces,events,profiles'
expect_token "$operation" 'deterministic_failures=latency,error,queue'
expect_token "$operation" 'missing_signal_diagnosed=export_queue_full'
expect_token "$operation" 'correlation_is_causality=false'
expect_token "$operation" 'vendor_behavior_proven=false'
expect_token "$operation" 'local_verification_passed=true'

expect_failure 64 'record-already-exists-guided.record.json' \
  bash lab.sh run guided

before_dry_cleanup="$(bash lab.sh status)"
dry_cleanup="$(LAB_DRY_RUN=1 bash lab.sh cleanup --expect-token "$owned_token")"
expect_token "$dry_cleanup" 'dry_run=true'
expect_token "$dry_cleanup" 'mutation_performed=false'
after_dry_cleanup="$(bash lab.sh status)"
[[ "$before_dry_cleanup" == "$after_dry_cleanup" ]] \
  || fail 'cleanup-dry-run-mutated-state'

cleanup_current
idempotent_cleanup="$(bash lab.sh cleanup --expect-token "$owned_token")"
expect_token "$idempotent_cleanup" 'cleanup_proven=true'

run_fault_case() {
  local point="$1"
  local fixture="$2"
  local output status check
  capture_setup
  if [[ "$fixture" == 'guided' ]]; then
    bash lab.sh run guided >/dev/null
  fi
  set +e
  output="$(
    LAB_FAULT_POINT="$point" \
      bash lab.sh cleanup --expect-token "$owned_token" 2>&1
  )"
  status=$?
  set -e
  [[ "$status" -eq 75 ]] || fail "fault-status-${point}-${status}"
  expect_token "$output" "fault-injected-${point}"
  owned_state_present || fail "fault-lost-owned-state-${point}"
  if [[ "$point" == 'after-cleanup-intent' ]]; then
    expect_failure 64 'cleanup-in-progress' bash lab.sh status
  fi
  cleanup_current
  check="$(bash lab.sh check)"
  expect_token "$check" 'state=absent'
  expect_token "$check" 'state_recovery_count=0'
  expect_token "$check" 'orphan_count=0'
}

# Each point is immediately after a durable rename, unlink, rmdir, or lifecycle
# transition. A plain cleanup must recognize the exact tombstone and resume.
run_fault_case after-cleanup-intent none
run_fault_case after-file-quarantine none
run_fault_case after-file-unlink none
run_fault_case after-directory-quarantine none
run_fault_case after-directory-rmdir none
run_fault_case after-root-record-removal guided
run_fault_case after-first-artifact-removal guided
run_fault_case after-root-quarantine none
run_fault_case before-root-final-rmdir none
run_fault_case after-state-quarantine none
run_fault_case after-state-descriptor-removal none
run_fault_case after-state-lock-removal none
run_fault_case before-state-final-rmdir none

final_check="$(bash lab.sh check)"
expect_token "$final_check" 'state=absent'
expect_token "$final_check" 'state_recovery_count=0'
expect_token "$final_check" 'orphan_count=0'

if find . -type d -name '__pycache__' -print -quit | grep -q .; then
  fail 'python-bytecode-directory-created'
fi

trap - EXIT
printf '%s\n' \
  'verification_passed=true' \
  "platform=${platform_detected}" \
  'signal_families=metrics,logs,traces,events,profiles' \
  'trace_topology=request-root-with-sequential-sibling-phases' \
  'ordering_exercise=event-order-versus-ingest-order' \
  'cases=guided,missing-signal-guided-walkthrough' \
  'hypothesis_required_before_reveal=true' \
  'preexisting_state_preserved=true' \
  'concurrent_verifier_preserved=true' \
  'timestamps=event,observed,ingest,sequence' \
  'profile=python-cprofile-deterministic-call-counts' \
  'trace_context=synthetic-not-W3C' \
  'correlation_is_causality=false' \
  'network_targets=0' \
  'cloud_calls=0' \
  'package_installs=0' \
  'cleanup=exact-allowlist-restartable-finally-absent' \
  'fault_boundaries=13' \
  'replacement_races=regular-file,owned-directory' \
  'atomic_deletion_claimed=false' \
  'cleanup_proven=true'
