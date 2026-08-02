#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_SOURCE=${BASH_SOURCE[0]}
if [[ $SCRIPT_SOURCE == */* ]]; then
  SCRIPT_PARENT=${SCRIPT_SOURCE%/*}
else
  SCRIPT_PARENT='.'
fi
SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)
readonly SCRIPT_SOURCE SCRIPT_PARENT SCRIPT_DIRECTORY
readonly LAB_SCRIPT="${SCRIPT_DIRECTORY}/lab.sh"
readonly MODEL_SOURCE="${SCRIPT_DIRECTORY}/fixtures/build_model.py"
LAB_UID=$EUID
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0022-${LAB_UID}.state"

LAB_ROOT=''
EXTERNAL_ROOT=''
ORPHAN_ROOT=''
SAVED_DESCRIPTOR=''
SAVED_BASELINE=''
RESTORE_MODEL=0
RESTORE_BASELINE=0
RESTORE_DESCRIPTOR=0

fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e $1 || -L $1 ]]
}

assert_contains() {
  local value=$1 expected=$2 label=$3
  grep -Fq -- "$expected" <<<"$value" || {
    fail "$label-missing-${expected}"
    return 1
  }
}

assert_absent() {
  local value=$1 forbidden=$2 label=$3
  if grep -Fiq -- "$forbidden" <<<"$value"; then
    fail "$label-exposed-${forbidden}"
    return 1
  fi
}

must_fail() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label-unexpectedly-succeeded"
    return 1
  fi
}

valid_lab_root_for_restore() {
  local owner mode resolved
  [[ -n $LAB_ROOT && $LAB_ROOT =~ ^/tmp/reliability-atlas-LES-0022\.[A-Za-z0-9]{8}$ && -d $LAB_ROOT && ! -L $LAB_ROOT ]] || return 1
  owner=$(stat -c '%u' -- "$LAB_ROOT" 2>/dev/null || true)
  mode=$(stat -c '%a' -- "$LAB_ROOT" 2>/dev/null || true)
  resolved=$(readlink -e -- "$LAB_ROOT" 2>/dev/null || true)
  [[ $owner == "$LAB_UID" && $mode == 700 && $resolved == "$LAB_ROOT" ]]
}

read_root() {
  local line root owner mode resolved
  line=$(grep -E '^root=' "$STATE_FILE")
  root=${line#root=}
  [[ $root =~ ^/tmp/reliability-atlas-LES-0022\.[A-Za-z0-9]{8}$ && -d $root && ! -L $root ]] || {
    fail 'registered-root-failed-verifier-boundary'
    return 1
  }
  owner=$(stat -c '%u' -- "$root")
  mode=$(stat -c '%a' -- "$root")
  resolved=$(readlink -e -- "$root")
  [[ $owner == "$LAB_UID" && $mode == 700 && $resolved == "$root" ]] || {
    fail 'registered-root-identity-invalid'
    return 1
  }
  printf '%s' "$root"
}

restore_verifier_mutations() {
  local identity target
  if ((RESTORE_DESCRIPTOR == 1)) && [[ -n $SAVED_DESCRIPTOR && -f $STATE_FILE && ! -L $STATE_FILE ]]; then
    identity=$(stat -c '%u:%h:%a' -- "$STATE_FILE" 2>/dev/null || true)
    if [[ $identity == "$LAB_UID:1:600" ]]; then
      printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE" 2>/dev/null || true
      chmod 600 -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
  valid_lab_root_for_restore || return 0
  if ((RESTORE_MODEL == 1)); then
    target="${LAB_ROOT}/build_model.py"
    if [[ -f $target && ! -L $target ]]; then
      install -m 0500 -- "$MODEL_SOURCE" "$target" 2>/dev/null || true
    fi
  fi
  if ((RESTORE_BASELINE == 1)); then
    target="${LAB_ROOT}/baseline.record"
    if [[ -L $target || -f $target ]]; then
      rm -- "$target" 2>/dev/null || true
    fi
    if ! path_present "$target" && [[ -n $SAVED_BASELINE ]]; then
      printf '%s\n' "$SAVED_BASELINE" >"$target" 2>/dev/null || true
      chmod 600 -- "$target" 2>/dev/null || true
    fi
  fi
}

cleanup_verifier_paths() {
  local owner resolved
  restore_verifier_mutations
  if path_present "$STATE_FILE"; then
    LAB_TEST_STOP_AFTER_CLEANUP_MARKER=0 LES0022_VERIFIER_MODE=1 bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1 || true
  fi
  if [[ -n $EXTERNAL_ROOT && $EXTERNAL_ROOT =~ ^/tmp/reliability-atlas-LES-0022-verifier\.[A-Za-z0-9]{8}$ && -d $EXTERNAL_ROOT && ! -L $EXTERNAL_ROOT ]]; then
    owner=$(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true)
    resolved=$(readlink -e -- "$EXTERNAL_ROOT" 2>/dev/null || true)
    if [[ $owner == "$LAB_UID" && $resolved == "$EXTERNAL_ROOT" ]]; then
      if [[ -f ${EXTERNAL_ROOT}/target && ! -L ${EXTERNAL_ROOT}/target ]]; then
        rm -- "${EXTERNAL_ROOT}/target" 2>/dev/null || true
      fi
      rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -n $ORPHAN_ROOT && $ORPHAN_ROOT =~ ^/tmp/reliability-atlas-LES-0022\.[A-Za-z0-9]{8}$ && -d $ORPHAN_ROOT && ! -L $ORPHAN_ROOT ]]; then
    owner=$(stat -c '%u' -- "$ORPHAN_ROOT" 2>/dev/null || true)
    resolved=$(readlink -e -- "$ORPHAN_ROOT" 2>/dev/null || true)
    if [[ $owner == "$LAB_UID" && $resolved == "$ORPHAN_ROOT" ]]; then
      rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true
    fi
  fi
}

trap cleanup_verifier_paths EXIT
trap 'exit 130' INT TERM

if ((LAB_UID == 0)); then
  fail 'run-verifier-as-a-normal-non-root-Ubuntu-user'
  exit 77
fi
for tool in bash chmod cmp find grep install ln mktemp python3 readlink rm rmdir sha256sum stat; do
  command -v -- "$tool" >/dev/null 2>&1 || {
    fail "required-verifier-command-missing-${tool}"
    exit 69
  }
done
bash -n "$LAB_SCRIPT"
PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$MODEL_SOURCE"

initial=$(bash "$LAB_SCRIPT" check)
assert_contains "$initial" 'state=absent' 'initial-check'

preview=$(LAB_DRY_RUN=1 bash "$LAB_SCRIPT" setup)
assert_contains "$preview" 'dry_run=true' 'setup-preview'
assert_contains "$preview" 'state=absent' 'setup-preview'
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'setup-preview-postcondition'

must_fail 'status-before-setup' bash "$LAB_SCRIPT" status
must_fail 'unknown-command' bash "$LAB_SCRIPT" unknown
must_fail 'extra-check-argument' bash "$LAB_SCRIPT" check extra
must_fail 'invalid-run-target' bash "$LAB_SCRIPT" run incident
must_fail 'invalid-case' bash "$LAB_SCRIPT" inject transfer
must_fail 'scenario-before-case' bash "$LAB_SCRIPT" scenario
must_fail 'observe-before-case' bash "$LAB_SCRIPT" observe inputs
must_fail 'verify-before-setup' bash "$LAB_SCRIPT" verify-operation
must_fail 'invalid-dry-run-value' env LAB_DRY_RUN=yes bash "$LAB_SCRIPT" check
must_fail 'learner-interruption-hook' env LAB_TEST_STOP_AFTER_CLEANUP_MARKER=1 bash "$LAB_SCRIPT" cleanup

run_case() {
  local case_name=$1 value scenario view forbidden
  value=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$value" 'setup=complete' "$case_name-setup"
  value=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$value" 'setup=already-present' "$case_name-repeated-setup"
  value=$(bash "$LAB_SCRIPT" status)
  assert_contains "$value" 'baseline=pending' "$case_name-initial-status"
  must_fail "$case_name-recover-before-case" bash "$LAB_SCRIPT" recover
  must_fail "$case_name-verify-before-recovery" bash "$LAB_SCRIPT" verify-operation

  value=$(bash "$LAB_SCRIPT" run baseline)
  assert_contains "$value" 'record=baseline' "$case_name-baseline"
  assert_contains "$value" 'byte_identical=true' "$case_name-baseline-bytes"
  assert_contains "$value" 'consumer_readback=valid' "$case_name-baseline-readback"
  assert_contains "$value" 'network_calls=0' "$case_name-baseline-network"
  must_fail "$case_name-repeated-baseline" bash "$LAB_SCRIPT" run baseline

  value=$(bash "$LAB_SCRIPT" inject "$case_name")
  assert_contains "$value" "case=${case_name}" "$case_name-injection"
  assert_contains "$value" 'answer_key=not-provided' "$case_name-answer-boundary"
  must_fail "$case_name-second-injection" bash "$LAB_SCRIPT" inject guided
  must_fail "$case_name-invalid-view" bash "$LAB_SCRIPT" observe invalid

  if [[ $case_name == guided ]]; then
    must_fail 'guided-scenario-refusal' bash "$LAB_SCRIPT" scenario
  else
    scenario=$(bash "$LAB_SCRIPT" scenario)
    assert_contains "$scenario" 'record=scenario_input' 'independent-scenario'
    assert_contains "$scenario" 'logical_operation_id=build-417' 'independent-operation-id'
    assert_contains "$scenario" 'cache_key_fields=source_sha256' 'independent-cache-input'
    for forbidden in authoritative committed receipt diagnosis recovery answer_key duplicate_effects retry_eligible root_cause; do
      assert_absent "$scenario" "$forbidden" 'independent-scenario'
    done
  fi

  for view in inputs dependencies context cache artifact supplychain; do
    value=$(bash "$LAB_SCRIPT" observe "$view")
    assert_contains "$value" 'record=observation' "$case_name-$view-record"
    assert_contains "$value" "case=${case_name}" "$case_name-$view-case"
    assert_contains "$value" "view=${view}" "$case_name-$view-view"
  done

  if [[ $case_name == guided ]]; then
    value=$(bash "$LAB_SCRIPT" observe artifact)
    assert_contains "$value" 'naive_byte_identical=false' 'guided-naive-mismatch'
    assert_contains "$value" 'normalized_byte_identical=true' 'guided-normalized-match'
    value=$(bash "$LAB_SCRIPT" observe dependencies)
    assert_contains "$value" 'lock_integrity_match=true' 'guided-lock-integrity'
  else
    value=$(bash "$LAB_SCRIPT" observe dependencies)
    assert_contains "$value" 'integrity_match=false' 'independent-dependency-drift'
    value=$(bash "$LAB_SCRIPT" observe context)
    assert_contains "$value" 'context_policy_match=false' 'independent-context-drift'
    value=$(bash "$LAB_SCRIPT" observe cache)
    assert_contains "$value" 'cache_result=hit' 'independent-cache-hit'
    assert_contains "$value" 'cache_hit_validates_current_inputs=false' 'independent-cache-proof-limit'
    value=$(bash "$LAB_SCRIPT" observe artifact)
    assert_contains "$value" 'candidate_hash_matches_expected=true' 'independent-stale-hash'
    assert_contains "$value" 'promotion_allowed=false' 'independent-promotion-refusal'
    value=$(bash "$LAB_SCRIPT" observe supplychain)
    assert_contains "$value" 'workspace_dependency_matches_provenance=false' 'independent-material-mismatch'
  fi

  value=$(LAB_DRY_RUN=1 bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'dry_run=true' "$case_name-cleanup-preview"
  assert_contains "$(bash "$LAB_SCRIPT" status)" "active_case=${case_name}" "$case_name-preview-no-mutation"

  value=$(bash "$LAB_SCRIPT" recover)
  assert_contains "$value" 'record=recovery' "$case_name-recovery"
  assert_contains "$value" 'operation_success=true' "$case_name-recovery-outcome"
  assert_contains "$value" 'byte_identical=true' "$case_name-recovery-rebuild"
  must_fail "$case_name-repeated-recovery" bash "$LAB_SCRIPT" recover
  must_fail "$case_name-observe-after-recovery" bash "$LAB_SCRIPT" observe artifact

  value=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains "$value" 'record=verification' "$case_name-verification"
  assert_contains "$value" 'operation_success=true' "$case_name-success"
  assert_contains "$value" 'lock_integrity=valid' "$case_name-lock"
  assert_contains "$value" 'cache_key_complete=true' "$case_name-cache-key"
  assert_contains "$value" 'duplicate_promotions=0' "$case_name-duplicates"
  assert_contains "$value" 'consumer_readback=valid' "$case_name-readback"
  must_fail "$case_name-repeated-verification" bash "$LAB_SCRIPT" verify-operation

  value=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'cleanup_proven=true' "$case_name-cleanup"
  value=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'cleanup=already-clean' "$case_name-idempotent-cleanup"
  assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' "$case_name-final-check"
}

run_case guided
run_case independent

bash "$LAB_SCRIPT" setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
LAB_ROOT=$(read_root)

printf 'unexpected\n' >"${LAB_ROOT}/unexpected.file"
chmod 600 -- "${LAB_ROOT}/unexpected.file"
must_fail 'unexpected-artifact-status' bash "$LAB_SCRIPT" status
must_fail 'unexpected-artifact-cleanup' bash "$LAB_SCRIPT" cleanup
[[ -f ${LAB_ROOT}/unexpected.file ]] || {
  fail 'unexpected-artifact-was-changed'
  exit 1
}
rm -- "${LAB_ROOT}/unexpected.file"

RESTORE_MODEL=1
chmod 700 -- "${LAB_ROOT}/build_model.py"
printf '\n# verifier tamper\n' >>"${LAB_ROOT}/build_model.py"
chmod 500 -- "${LAB_ROOT}/build_model.py"
must_fail 'changed-model-status' bash "$LAB_SCRIPT" status
must_fail 'changed-model-cleanup' bash "$LAB_SCRIPT" cleanup
install -m 0500 -- "$MODEL_SOURCE" "${LAB_ROOT}/build_model.py"
RESTORE_MODEL=0
assert_contains "$(bash "$LAB_SCRIPT" status)" 'state=ready' 'restored-model'

EXTERNAL_ROOT=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0022-verifier.XXXXXXXX')
printf 'must-survive\n' >"${EXTERNAL_ROOT}/target"
chmod 600 -- "${EXTERNAL_ROOT}/target"
SAVED_BASELINE=$(<"${LAB_ROOT}/baseline.record")
RESTORE_BASELINE=1
rm -- "${LAB_ROOT}/baseline.record"
ln -s -- "${EXTERNAL_ROOT}/target" "${LAB_ROOT}/baseline.record"
must_fail 'symlink-record-status' bash "$LAB_SCRIPT" status
must_fail 'symlink-record-cleanup' bash "$LAB_SCRIPT" cleanup
assert_contains "$(<"${EXTERNAL_ROOT}/target")" 'must-survive' 'external-canary'
rm -- "${LAB_ROOT}/baseline.record"
printf '%s\n' "$SAVED_BASELINE" >"${LAB_ROOT}/baseline.record"
chmod 600 -- "${LAB_ROOT}/baseline.record"
RESTORE_BASELINE=0

SAVED_DESCRIPTOR=$(<"$STATE_FILE")
RESTORE_DESCRIPTOR=1
printf 'lesson=LES-0022\nversion=1\nuid=%s\nroot=%s\n' "$LAB_UID" "$EXTERNAL_ROOT" >"$STATE_FILE"
chmod 600 -- "$STATE_FILE"
must_fail 'redirected-descriptor-status' bash "$LAB_SCRIPT" status
must_fail 'redirected-descriptor-cleanup' bash "$LAB_SCRIPT" cleanup
assert_contains "$(<"${EXTERNAL_ROOT}/target")" 'must-survive' 'redirected-canary'
printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE"
chmod 600 -- "$STATE_FILE"
RESTORE_DESCRIPTOR=0

assert_contains "$(bash "$LAB_SCRIPT" cleanup)" 'cleanup_proven=true' 'pre-orphan-cleanup'
ORPHAN_ROOT=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0022.XXXXXXXX')
chmod 700 -- "$ORPHAN_ROOT"
must_fail 'orphan-check' bash "$LAB_SCRIPT" check
must_fail 'orphan-setup' bash "$LAB_SCRIPT" setup
rmdir -- "$ORPHAN_ROOT"
ORPHAN_ROOT=''
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'post-orphan-check'

bash "$LAB_SCRIPT" setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
must_fail 'simulated-cleanup-interruption' env LAB_TEST_STOP_AFTER_CLEANUP_MARKER=1 LES0022_VERIFIER_MODE=1 bash "$LAB_SCRIPT" cleanup
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=cleanup-in-progress' 'interrupted-cleanup-state'
must_fail 'mutation-during-cleanup' bash "$LAB_SCRIPT" run baseline
assert_contains "$(bash "$LAB_SCRIPT" cleanup)" 'resume=cleanup-marker' 'cleanup-resume'
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'final-state'

printf 'verification_passed=true\n'
printf 'platform=Ubuntu-24.04-WSL2\n'
printf 'cases=guided,independent\n'
printf 'refusals=dry-run,root-guard,unexpected-artifact,model-tamper,symlink,descriptor-redirection,orphan\n'
printf 'root_refusal=implemented-reviewer-test-only\n'
printf 'interruption=cleanup-marker-resume-tested\n'
printf 'answer_isolation=raw-independent-input-without-derived-outcome-or-recovery\n'
printf 'network_mutation=none\n'
printf 'host_mutation=guarded-current-user-tmp-state-only\n'
printf 'cleanup_proven=true\n'
