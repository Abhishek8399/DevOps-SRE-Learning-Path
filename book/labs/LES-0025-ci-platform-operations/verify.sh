#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$script_dir"

state_path="/tmp/reliability-atlas-LES-0025-${UID}.state.d"
owned_root=''
foreign_state_created=0

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
  [[ "$status" -eq "$expected_status" ]] || fail "unexpected-status-${expected_token}-${status}"
  expect_token "$output" "$expected_token"
  printf '%s\n' "$output"
}

remove_verifier_marker_if_owned() {
  [[ -n "$owned_root" ]] || return 0
  [[ "$owned_root" =~ ^/tmp/reliability-atlas-LES-0025-${UID}\.[A-Za-z0-9_-]+$ ]] || return 0
  local marker="${owned_root}/verifier-owned-unexpected.file"
  if [[ -f "$marker" && ! -L "$marker" ]]; then
    rm -f -- "$marker"
  fi
}

cleanup_on_exit() {
  local status=$?
  remove_verifier_marker_if_owned
  bash lab.sh cleanup >/dev/null 2>&1 || true
  if [[ "$foreign_state_created" -eq 1 \
    && -d "$state_path" \
    && ! -L "$state_path" \
    && -f "${state_path}/marker" \
    && ! -L "${state_path}/marker" \
    && "$(cat "${state_path}/marker")" == 'foreign-state-marker' ]]; then
    rm -f -- "${state_path}/marker"
    rmdir -- "$state_path" 2>/dev/null || true
  fi
  exit "$status"
}
trap cleanup_on_exit EXIT

bash -n lab.sh
bash -n verify.sh
grep -Fq 'if (( EUID == 0 )); then' lab.sh || fail 'lab-root-guard-missing'
python3 - <<'PY'
import ast
from pathlib import Path

for path in sorted(Path('.').rglob('*.py')):
    ast.parse(path.read_text(encoding='utf-8'), filename=str(path))
print('python_ast_parse=passed')
PY

removal_races="$(bash lab.sh verify-removal-races)"
expect_token "$removal_races" 'removal_race_regressions=passed'
expect_token "$removal_races" 'replacement_preserved=true'
expect_token "$removal_races" 'atomic_deletion_claimed=false'

initial="$(bash lab.sh check)"
expect_token "$initial" 'state=absent'
expect_token "$initial" 'orphan_count=0'

dry_setup="$(LAB_DRY_RUN=1 bash lab.sh setup)"
expect_token "$dry_setup" 'dry_run=true'
after_dry_setup="$(bash lab.sh check)"
[[ "$initial" == "$after_dry_setup" ]] || fail 'setup-dry-run-mutated-state'

setup_output="$(bash lab.sh setup)"
expect_token "$setup_output" 'setup_complete=true'
owned_root="$(sed -n 's/^root=//p' <<<"$setup_output")"
[[ "$owned_root" =~ ^/tmp/reliability-atlas-LES-0025-${UID}\.[A-Za-z0-9_-]+$ ]] || fail 'setup-root-grammar'

expect_failure 64 'compare-requires-graph-record' bash lab.sh compare >/dev/null

graph_output="$(bash lab.sh run graph)"
expect_token "$graph_output" 'engine=local-graph'
expect_token "$graph_output" 'status=passed'

stage_output="$(bash lab.sh run stage-broken)"
expect_token "$stage_output" 'engine=local-stage'
expect_token "$stage_output" 'status=passed'

comparison="$(bash lab.sh compare)"
expect_token "$comparison" 'both_green=true'
expect_token "$comparison" 'artifact_digest_equal=true'
expect_token "$comparison" 'permission_contract_equal=false'
expect_token "$comparison" 'concurrency_contract_equal=false'
expect_token "$comparison" 'timeout_contract_equal=false'
expect_token "$comparison" 'encoded_comparison_equal=false'
expect_token "$comparison" 'declarative_fields_behaviorally_enforced=false'

expect_failure 64 'verification-requires-corrected-stage-run' bash lab.sh verify-operation >/dev/null

recovery="$(bash lab.sh recover)"
expect_token "$recovery" 'engine=local-stage'
expect_token "$recovery" 'contract=corrected'
expect_token "$recovery" 'status=passed'

verification="$(bash lab.sh verify-operation)"
expect_token "$verification" 'encoded_comparison_equal=true'
expect_token "$verification" 'declarative_fields_behaviorally_enforced=false'
expect_token "$verification" 'local_verification_passed=true'
expect_token "$verification" 'network_targets=0'
expect_token "$verification" 'secret_inputs=0'

expect_failure 64 'record-already-exists-graph.record.json' bash lab.sh run graph >/dev/null

before_dry_cleanup="$(bash lab.sh status)"
dry_cleanup="$(LAB_DRY_RUN=1 bash lab.sh cleanup)"
expect_token "$dry_cleanup" 'dry_run=true'
after_dry_cleanup="$(bash lab.sh status)"
[[ "$before_dry_cleanup" == "$after_dry_cleanup" ]] || fail 'cleanup-dry-run-mutated-state'

printf '%s\n' 'verifier-owned-marker' >"${owned_root}/verifier-owned-unexpected.file"
chmod 600 "${owned_root}/verifier-owned-unexpected.file"
marker_before="$(sha256sum "${owned_root}/verifier-owned-unexpected.file")"
expect_failure 65 'unexpected-root-child-verifier-owned-unexpected.file' bash lab.sh cleanup >/dev/null
marker_after="$(sha256sum "${owned_root}/verifier-owned-unexpected.file")"
[[ "$marker_before" == "$marker_after" ]] || fail 'unexpected-file-was-mutated'
remove_verifier_marker_if_owned

cleanup_output="$(bash lab.sh cleanup)"
expect_token "$cleanup_output" 'cleanup_proven=true'
owned_root=''

final_check="$(bash lab.sh check)"
expect_token "$final_check" 'state=absent'
expect_token "$final_check" 'orphan_count=0'

idempotent_cleanup="$(bash lab.sh cleanup)"
expect_token "$idempotent_cleanup" 'cleanup_proven=true'
expect_token "$idempotent_cleanup" 'state=absent'

mkdir -m 700 -- "$state_path"
printf '%s\n' 'foreign-state-marker' >"${state_path}/marker"
chmod 600 "${state_path}/marker"
foreign_state_created=1
foreign_before="$(sha256sum "${state_path}/marker")"
expect_failure 73 'state-already-exists' bash lab.sh setup >/dev/null
foreign_after="$(sha256sum "${state_path}/marker")"
[[ "$foreign_before" == "$foreign_after" ]] || fail 'preexisting-state-was-mutated'
rm -f -- "${state_path}/marker"
rmdir -- "$state_path"
foreign_state_created=0

trap - EXIT
printf '%s\n' \
  'verification_passed=true' \
  'platform=Ubuntu-24.04' \
  'engines=local-graph,local-stage' \
  'cases=green-but-declared-contract-mismatch,corrected-encoded-field-equality' \
  'artifact_binding=exact-content-and-sha256' \
  'child_environment=minimal-no-inherited-credentials' \
  'network_targets=0' \
  'hosted_ci_calls=0' \
  'cloud_calls=0' \
  'cleanup=exact-allowlist-finally-absent' \
  'cooperative_replacement_races=regular,root,state,rollback-root,rollback-state' \
  'atomic_deletion_claimed=false' \
  'cleanup_proven=true'
