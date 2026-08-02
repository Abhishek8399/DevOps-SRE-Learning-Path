#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="${SCRIPT_DIRECTORY}/lab.sh"
readonly MODEL_SCRIPT="${SCRIPT_DIRECTORY}/fixtures/automation_model.sh"
VERIFY_UID=$(id -u)
readonly VERIFY_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0017-${VERIFY_UID}.state"

CHECKS=0
PASSES=0

fail() {
  local message=$1
  printf 'verification=failed check=%s\n' "$message" >&2
  exit 1
}

pass() {
  local label=$1
  CHECKS=$((CHECKS + 1))
  PASSES=$((PASSES + 1))
  printf 'verification=pass check=%s\n' "$label"
}

assert_contains() {
  local label=$1
  local haystack=$2
  local needle=$3
  CHECKS=$((CHECKS + 1))
  if [[ $haystack == *"$needle"* ]]; then
    PASSES=$((PASSES + 1))
    printf 'verification=pass check=%s\n' "$label"
  else
    printf 'verification=failed check=%s expected=%q\n' "$label" "$needle" >&2
    exit 1
  fi
}

expect_failure() {
  local label=$1
  shift
  local output
  local status

  CHECKS=$((CHECKS + 1))
  set +e
  output=$("$@" 2>&1)
  status=$?
  set -e
  if ((status == 0)); then
    printf 'verification=failed check=%s reason=unexpected-success output=%q\n' "$label" "$output" >&2
    exit 1
  fi
  PASSES=$((PASSES + 1))
  printf 'verification=pass check=%s refusal_status=%d\n' "$label" "$status"
}

registered_root() {
  local key
  local value
  local found=''

  [[ -f $STATE_FILE && ! -L $STATE_FILE ]] || fail 'registered-root-state-file-missing'
  while IFS='=' read -r key value; do
    if [[ $key == root ]]; then
      [[ -z $found ]] || fail 'registered-root-duplicated'
      found=$value
    fi
  done <"$STATE_FILE"
  [[ -n $found ]] || fail 'registered-root-field-missing'
  printf '%s\n' "$found"
}

cleanup_on_exit() {
  local original_status=$?
  if [[ -e $STATE_FILE || -L $STATE_FILE ]]; then
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1 || true
  fi
  return "$original_status"
}
trap cleanup_on_exit EXIT

main() {
  local output
  local root
  local state_after

  ((VERIFY_UID != 0)) || fail 'root-is-refused-run-as-a-normal-user'
  [[ -f $LAB_SCRIPT && ! -L $LAB_SCRIPT ]] || fail 'lab-script-missing'
  [[ -f $MODEL_SCRIPT && ! -L $MODEL_SCRIPT ]] || fail 'model-script-missing'

  bash -n -- "$LAB_SCRIPT"
  bash -n -- "$MODEL_SCRIPT"
  bash -n -- "${SCRIPT_DIRECTORY}/verify.sh"
  pass 'bash-parser-gate'

  output=$(bash "$LAB_SCRIPT" check)
  assert_contains 'clean-preflight' "$output" 'state=absent'
  assert_contains 'network-is-none' "$output" 'network=none'

  expect_failure 'unknown-action-refused' bash "$LAB_SCRIPT" unknown
  expect_failure 'extra-argument-refused' bash "$LAB_SCRIPT" check extra
  expect_failure 'invalid-case-refused' bash "$LAB_SCRIPT" inject arbitrary

  output=$(bash "$LAB_SCRIPT" setup)
  assert_contains 'setup-ready' "$output" 'setup=ready'
  output=$(bash "$LAB_SCRIPT" setup)
  assert_contains 'setup-idempotent' "$output" 'setup=already-ready'
  output=$(bash "$LAB_SCRIPT" status)
  assert_contains 'initial-state-valid' "$output" 'state=valid'
  assert_contains 'initial-baseline-absent' "$output" 'baseline=absent'

  expect_failure 'case-before-baseline-refused' bash "$LAB_SCRIPT" inject guided

  root=$(registered_root)
  exec 8<>"${root}/.lock"
  flock -n 8 || fail 'verifier-cannot-acquire-contention-lock'
  expect_failure 'concurrent-mutation-refused' bash "$LAB_SCRIPT" run baseline
  flock -u 8
  exec 8>&-

  output=$(bash "$LAB_SCRIPT" run baseline)
  assert_contains 'baseline-recorded' "$output" 'baseline=recorded'
  expect_failure 'second-baseline-refused' bash "$LAB_SCRIPT" run baseline

  output=$(bash "$LAB_SCRIPT" inject guided)
  assert_contains 'guided-selected' "$output" 'case=guided'
  expect_failure 'second-case-refused' bash "$LAB_SCRIPT" inject independent
  expect_failure 'derived-before-raw-refused' bash "$LAB_SCRIPT" observe expansion
  expect_failure 'recovery-before-raw-refused' bash "$LAB_SCRIPT" recover

  output=$(bash "$LAB_SCRIPT" observe input)
  assert_contains 'guided-raw-operation' "$output" 'operation=publish-release-inventory'
  assert_contains 'guided-raw-gate-instruction' "$output" 'next=write-prediction-before-derived-views'
  output=$(bash "$LAB_SCRIPT" observe expansion)
  assert_contains 'guided-expansion-detected' "$output" 'arguments_received=8'
  output=$(bash "$LAB_SCRIPT" observe pipeline)
  assert_contains 'guided-producer-status' "$output" 'producer_status=23'
  assert_contains 'guided-selected-status' "$output" 'selected_pipeline_status=0'
  output=$(bash "$LAB_SCRIPT" observe state)
  assert_contains 'guided-partial-final' "$output" 'current_final_records=4'
  output=$(bash "$LAB_SCRIPT" observe retry)
  assert_contains 'guided-duplicate-risk' "$output" 'duplicate_effect_risk=true'

  output=$(bash "$LAB_SCRIPT" recover)
  assert_contains 'guided-recovery-recorded' "$output" 'recovery=recorded'
  assert_contains 'guided-candidate-gate' "$output" 'publication=validated-candidate-then-rename'
  expect_failure 'second-recovery-refused' bash "$LAB_SCRIPT" recover
  output=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains 'guided-operation-verified' "$output" 'operation_verified=true'
  assert_contains 'guided-no-duplicates' "$output" 'duplicate_effects=0'
  expect_failure 'second-verification-refused' bash "$LAB_SCRIPT" verify-operation

  output=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains 'guided-cleanup-complete' "$output" 'cleanup=complete'
  assert_contains 'guided-no-recursive-delete' "$output" 'recursive_delete=false'
  output=$(bash "$LAB_SCRIPT" check)
  assert_contains 'guided-cleanup-proof' "$output" 'state=absent'

  bash "$LAB_SCRIPT" setup >/dev/null
  bash "$LAB_SCRIPT" run baseline >/dev/null
  bash "$LAB_SCRIPT" inject independent >/dev/null
  expect_failure 'independent-derived-before-raw-refused' bash "$LAB_SCRIPT" observe state
  output=$(bash "$LAB_SCRIPT" observe input)
  assert_contains 'independent-raw-timeout' "$output" 'run_a_observation=request-deadline-expired-after-ten-seconds'
  output=$(bash "$LAB_SCRIPT" observe expansion)
  assert_contains 'independent-framing-not-cause' "$output" 'arguments_received=5'
  output=$(bash "$LAB_SCRIPT" observe pipeline)
  assert_contains 'independent-pipeline-not-cause' "$output" 'selected_pipeline_status=0'
  output=$(bash "$LAB_SCRIPT" observe state)
  assert_contains 'independent-authoritative-owner' "$output" 'authoritative_owner=remote-release-service'
  output=$(bash "$LAB_SCRIPT" observe retry)
  assert_contains 'independent-two-operation-ids' "$output" 'run_b_operation_id=attempt-west-228'
  assert_contains 'independent-no-reconcile-before-retry' "$output" 'authoritative_query_before_retry=false'
  output=$(bash "$LAB_SCRIPT" recover)
  assert_contains 'independent-reconciled-commit' "$output" 'run_a_outcome=reconciled-committed'
  assert_contains 'independent-duplicate-suppressed' "$output" 'run_b_outcome=reconciled-duplicate-and-suppressed'
  output=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains 'independent-operation-verified' "$output" 'operation_verified=true'
  assert_contains 'independent-one-effect' "$output" 'unique_committed_logical_effects=1'
  assert_contains 'independent-repeat-idempotent' "$output" 'second_identical_run_additional_effects=0'

  output=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains 'independent-cleanup-complete' "$output" 'state=absent'
  output=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains 'cleanup-idempotent' "$output" 'cleanup=already-absent'
  state_after=$(bash "$LAB_SCRIPT" check)
  assert_contains 'final-absence-proof' "$state_after" 'state=absent'
  [[ ! -e $STATE_FILE && ! -L $STATE_FILE ]] || fail 'state-descriptor-remained-after-cleanup'
  pass 'state-descriptor-absence'

  trap - EXIT
  printf 'verification=complete checks=%d passed=%d failed=0 state=absent network=none\n' "$CHECKS" "$PASSES"
}

main "$@"
