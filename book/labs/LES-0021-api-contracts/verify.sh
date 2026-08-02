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
readonly MODEL_SOURCE="${SCRIPT_DIRECTORY}/fixtures/api_contract_model.py"
LAB_UID=$EUID
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0021-${LAB_UID}.state"

LAB_ROOT=''
EXTERNAL_ROOT=''
ORPHAN_ROOT=''
SAVED_DESCRIPTOR=''
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

valid_lab_root_for_restore() {
  local owner mode resolved
  [[ -n $LAB_ROOT && $LAB_ROOT =~ ^/tmp/reliability-atlas-LES-0021\.[A-Za-z0-9]{8}$ && -d $LAB_ROOT && ! -L $LAB_ROOT ]] || return 1
  owner=$(stat -c '%u' -- "$LAB_ROOT" 2>/dev/null || true)
  mode=$(stat -c '%a' -- "$LAB_ROOT" 2>/dev/null || true)
  resolved=$(readlink -e -- "$LAB_ROOT" 2>/dev/null || true)
  [[ $owner == "$LAB_UID" && $mode == 700 && $resolved == "$LAB_ROOT" ]]
}

restore_verifier_mutations() {
  local target identity
  if ((RESTORE_DESCRIPTOR == 1)) && [[ -n $SAVED_DESCRIPTOR && -f $STATE_FILE && ! -L $STATE_FILE ]]; then
    identity=$(stat -c '%u:%h:%a' -- "$STATE_FILE" 2>/dev/null || true)
    if [[ $identity == "$LAB_UID:1:600" ]]; then
      printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE" 2>/dev/null || true
      chmod 600 -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
  valid_lab_root_for_restore || return 0
  if ((RESTORE_MODEL == 1)); then
    target="${LAB_ROOT}/api_contract_model.py"
    if [[ -f $target && ! -L $target ]]; then
      install -m 0500 -- "$MODEL_SOURCE" "$target" 2>/dev/null || true
    fi
  fi
  if ((RESTORE_BASELINE == 1)); then
    target="${LAB_ROOT}/baseline.record"
    if [[ -L $target ]]; then
      rm -- "$target" 2>/dev/null || true
    elif [[ -f $target ]]; then
      rm -- "$target" 2>/dev/null || true
    fi
    if ! path_present "$target"; then
      PYTHONDONTWRITEBYTECODE=1 python3 "$MODEL_SOURCE" baseline >"$target" 2>/dev/null || true
      chmod 600 -- "$target" 2>/dev/null || true
    fi
  fi
}

cleanup_verifier_paths() {
  local owner resolved
  restore_verifier_mutations
  if [[ -n $EXTERNAL_ROOT && $EXTERNAL_ROOT =~ ^/tmp/reliability-atlas-LES-0021-verifier\.[A-Za-z0-9]{8}$ && -d $EXTERNAL_ROOT && ! -L $EXTERNAL_ROOT ]]; then
    owner=$(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true)
    resolved=$(readlink -e -- "$EXTERNAL_ROOT" 2>/dev/null || true)
    if [[ $owner == "$LAB_UID" && $resolved == "$EXTERNAL_ROOT" ]]; then
      if [[ -f ${EXTERNAL_ROOT}/target && ! -L ${EXTERNAL_ROOT}/target ]]; then rm -- "${EXTERNAL_ROOT}/target" 2>/dev/null || true; fi
      rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -n $ORPHAN_ROOT && $ORPHAN_ROOT =~ ^/tmp/reliability-atlas-LES-0021\.[A-Za-z0-9]{8}$ && -d $ORPHAN_ROOT && ! -L $ORPHAN_ROOT ]]; then
    owner=$(stat -c '%u' -- "$ORPHAN_ROOT" 2>/dev/null || true)
    resolved=$(readlink -e -- "$ORPHAN_ROOT" 2>/dev/null || true)
    if [[ $owner == "$LAB_UID" && $resolved == "$ORPHAN_ROOT" ]]; then rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true; fi
  fi
}

trap cleanup_verifier_paths EXIT
trap 'exit 130' INT TERM

if ((LAB_UID == 0)); then fail 'run-verifier-as-a-normal-non-root-Ubuntu-user'; exit 77; fi
for tool in bash chmod cmp find grep install ln mktemp python3 readlink rm rmdir stat; do
  command -v -- "$tool" >/dev/null 2>&1 || { fail "required-verifier-command-missing-${tool}"; exit 69; }
done
PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$MODEL_SOURCE"

must_fail() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label-unexpectedly-succeeded"
    return 1
  fi
}

assert_contains() {
  local value=$1 expected=$2 label=$3
  grep -Fq -- "$expected" <<<"$value" || { fail "$label-missing-${expected}"; return 1; }
}

assert_absent() {
  local value=$1 forbidden=$2 label=$3
  if grep -Fiq -- "$forbidden" <<<"$value"; then
    fail "$label-exposed-${forbidden}"
    return 1
  fi
}

read_root() {
  local line root owner mode resolved
  line=$(grep -E '^root=' "$STATE_FILE")
  root=${line#root=}
  [[ $root =~ ^/tmp/reliability-atlas-LES-0021\.[A-Za-z0-9]{8}$ && -d $root && ! -L $root ]] || { fail 'registered-root-failed-verifier-boundary'; return 1; }
  owner=$(stat -c '%u' -- "$root")
  mode=$(stat -c '%a' -- "$root")
  resolved=$(readlink -e -- "$root")
  [[ $owner == "$LAB_UID" && $mode == 700 && $resolved == "$root" ]] || { fail 'registered-root-identity-invalid'; return 1; }
  printf '%s' "$root"
}

initial=$(bash "$LAB_SCRIPT" check)
assert_contains "$initial" 'state=absent' 'initial-check'
must_fail 'status-before-setup' bash "$LAB_SCRIPT" status
must_fail 'unknown-command' bash "$LAB_SCRIPT" unknown
must_fail 'extra-check-argument' bash "$LAB_SCRIPT" check extra
must_fail 'invalid-run-target' bash "$LAB_SCRIPT" run incident
must_fail 'invalid-case' bash "$LAB_SCRIPT" inject transfer
must_fail 'scenario-before-case' bash "$LAB_SCRIPT" scenario
must_fail 'observe-before-case' bash "$LAB_SCRIPT" observe request
must_fail 'verify-before-setup' bash "$LAB_SCRIPT" verify-operation

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
  assert_contains "$value" 'parsed_replicas_type=int' "$case_name-baseline-type"
  assert_contains "$value" 'unicode_service=café-api' "$case_name-unicode"
  assert_contains "$value" 'response_status=201' "$case_name-baseline-status"
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
    assert_contains "$scenario" 'idempotency_key=deploy-417' 'independent-idempotency-key'
    assert_contains "$scenario" 'client_deadline_ms=250' 'independent-deadline'
    for forbidden in authoritative committed receipt diagnosis recovery answer_key duplicate_effects retry_eligible; do
      assert_absent "$scenario" "$forbidden" 'independent-scenario'
    done
  fi

  for view in request contract operation page limit webhook; do
    value=$(bash "$LAB_SCRIPT" observe "$view")
    assert_contains "$value" 'record=observation' "$case_name-$view-record"
    assert_contains "$value" "case=${case_name}" "$case_name-$view-case"
    assert_contains "$value" "view=${view}" "$case_name-$view-view"
  done

  if [[ $case_name == guided ]]; then
    value=$(bash "$LAB_SCRIPT" observe request)
    assert_contains "$value" 'observed_replicas_json_type=string' 'guided-json-type'
    value=$(bash "$LAB_SCRIPT" observe contract)
    assert_contains "$value" 'response_status=422' 'guided-problem-status'
    assert_contains "$value" 'response_content_type=application/problem+json' 'guided-problem-media-type'
  else
    value=$(bash "$LAB_SCRIPT" observe operation)
    assert_contains "$value" 'client_result=deadline-exceeded-before-response' 'independent-client-result'
    assert_contains "$value" 'authoritative_state=committed' 'independent-owner-state'
    assert_contains "$value" 'service_attempt_count=1' 'independent-attempt-count'
    value=$(bash "$LAB_SCRIPT" observe page)
    assert_contains "$value" 'duplicates=0' 'independent-pagination'
    value=$(bash "$LAB_SCRIPT" observe webhook)
    assert_contains "$value" 'replay_cache_result=already-processed' 'independent-webhook-replay'
  fi

  value=$(bash "$LAB_SCRIPT" recover)
  assert_contains "$value" 'record=recovery' "$case_name-recovery"
  assert_contains "$value" 'operation_success=true' "$case_name-recovery-outcome"
  must_fail "$case_name-repeated-recovery" bash "$LAB_SCRIPT" recover
  must_fail "$case_name-observe-after-recovery" bash "$LAB_SCRIPT" observe operation
  if [[ $case_name == independent ]]; then
    assert_contains "$value" 'additional_mutation_attempts=0' 'independent-no-replay'
  fi

  value=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains "$value" 'record=verification' "$case_name-verification"
  assert_contains "$value" 'operation_success=true' "$case_name-success"
  assert_contains "$value" 'duplicate_effects=0' "$case_name-duplicates"
  assert_contains "$value" 'pagination_consistency=valid' "$case_name-pagination-contract"
  assert_contains "$value" 'rate_limit_policy=bounded' "$case_name-rate-limit-contract"
  assert_contains "$value" 'webhook_replay_effects=0' "$case_name-webhook-contract"
  assert_contains "$value" 'consumer_readback=valid' "$case_name-readback"
  must_fail "$case_name-repeated-verification" bash "$LAB_SCRIPT" verify-operation

  value=$(bash "$LAB_SCRIPT" status)
  assert_contains "$value" "active_case=${case_name}" "$case_name-final-status"
  assert_contains "$value" 'verification=complete' "$case_name-final-verification-status"
  value=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'cleanup_proven=true' "$case_name-cleanup"
  value=$(bash "$LAB_SCRIPT" check)
  assert_contains "$value" 'state=absent' "$case_name-final-check"
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
[[ -f ${LAB_ROOT}/unexpected.file ]] || { fail 'unexpected-artifact-was-changed'; exit 1; }
rm -- "${LAB_ROOT}/unexpected.file"

RESTORE_MODEL=1
chmod 700 -- "${LAB_ROOT}/api_contract_model.py"
printf '\n# verifier tamper\n' >>"${LAB_ROOT}/api_contract_model.py"
chmod 500 -- "${LAB_ROOT}/api_contract_model.py"
must_fail 'changed-model-status' bash "$LAB_SCRIPT" status
must_fail 'changed-model-cleanup' bash "$LAB_SCRIPT" cleanup
install -m 0500 -- "$MODEL_SOURCE" "${LAB_ROOT}/api_contract_model.py"
RESTORE_MODEL=0
assert_contains "$(bash "$LAB_SCRIPT" status)" 'state=ready' 'restored-model'

EXTERNAL_ROOT=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0021-verifier.XXXXXXXX')
printf 'must-survive\n' >"${EXTERNAL_ROOT}/target"
chmod 600 -- "${EXTERNAL_ROOT}/target"
RESTORE_BASELINE=1
rm -- "${LAB_ROOT}/baseline.record"
ln -s -- "${EXTERNAL_ROOT}/target" "${LAB_ROOT}/baseline.record"
must_fail 'symlink-status' bash "$LAB_SCRIPT" status
must_fail 'symlink-cleanup' bash "$LAB_SCRIPT" cleanup
cmp -s -- "${EXTERNAL_ROOT}/target" <(printf 'must-survive\n') || { fail 'external-symlink-target-changed'; exit 1; }
rm -- "${LAB_ROOT}/baseline.record"
PYTHONDONTWRITEBYTECODE=1 python3 "$MODEL_SOURCE" baseline >"${LAB_ROOT}/baseline.record"
chmod 600 -- "${LAB_ROOT}/baseline.record"
RESTORE_BASELINE=0

SAVED_DESCRIPTOR=$(<"$STATE_FILE")
RESTORE_DESCRIPTOR=1
printf 'lesson=LES-0021\nversion=1\nuid=%s\nroot=%s\n' "$LAB_UID" "$EXTERNAL_ROOT" >"$STATE_FILE"
chmod 600 -- "$STATE_FILE"
must_fail 'out-of-scope-descriptor-status' bash "$LAB_SCRIPT" status
must_fail 'out-of-scope-descriptor-cleanup' bash "$LAB_SCRIPT" cleanup
cmp -s -- "${EXTERNAL_ROOT}/target" <(printf 'must-survive\n') || { fail 'out-of-scope-target-changed'; exit 1; }
printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE"
chmod 600 -- "$STATE_FILE"
RESTORE_DESCRIPTOR=0
bash "$LAB_SCRIPT" cleanup >/dev/null

ORPHAN_ROOT=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0021.XXXXXXXX')
must_fail 'orphan-check' bash "$LAB_SCRIPT" check
must_fail 'orphan-setup' bash "$LAB_SCRIPT" setup
must_fail 'orphan-cleanup' bash "$LAB_SCRIPT" cleanup
[[ -d $ORPHAN_ROOT && ! -L $ORPHAN_ROOT ]] || { fail 'orphan-candidate-was-changed'; exit 1; }
rmdir -- "$ORPHAN_ROOT"
ORPHAN_ROOT=''

value=$(bash "$LAB_SCRIPT" cleanup)
assert_contains "$value" 'cleanup=already-clean' 'idempotent-cleanup'
assert_contains "$value" 'cleanup_proven=true' 'idempotent-cleanup-proof'
if find "$SCRIPT_DIRECTORY" -type d -name __pycache__ -print -quit | grep -q .; then
  fail 'python-bytecode-cache-residue-found'
  exit 1
fi
if find "$SCRIPT_DIRECTORY" -type f \( -name '*.pyc' -o -name '.coverage' \) -print -quit | grep -q .; then
  fail 'generated-python-residue-found'
  exit 1
fi

rm -- "${EXTERNAL_ROOT}/target"
rmdir -- "$EXTERNAL_ROOT"
EXTERNAL_ROOT=''
trap - EXIT INT TERM

printf 'verification_passed=true\n'
printf 'cases=guided,independent\n'
printf 'scenarios=json-types,unicode,content-negotiation,idempotency,pagination,rate-limit,problem-details,versioning,webhook-replay\n'
printf 'refusals=invalid-input,invalid-transition,unexpected-artifact,changed-model,symlink,out-of-scope-descriptor,orphan-candidate\n'
printf 'answer_isolation=raw-independent-inputs-no-derived-outcome-diagnosis-recovery-or-retry-answer\n'
printf 'network_mutation=none\n'
printf 'host_mutation=guarded-tmp-state-only\n'
printf 'cleanup_proven=true\n'
