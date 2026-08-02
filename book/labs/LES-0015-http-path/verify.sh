#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
VERIFY_UID="$(id -u)"
readonly VERIFY_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0015-$VERIFY_UID.state"
EXTERNAL_ROOT=""
ORPHAN_ROOT=""

fail() { printf 'verify_error=%s\n' "$1" >&2; }

cleanup_owned_test_paths() {
  if [[ -n "$ORPHAN_ROOT" && "$ORPHAN_ROOT" =~ ^/tmp/reliability-atlas-LES-0015\.[[:alnum:]]{8}$ \
    && -d "$ORPHAN_ROOT" && ! -L "$ORPHAN_ROOT" \
    && "$(stat -c '%u' -- "$ORPHAN_ROOT" 2>/dev/null || true)" == "$VERIFY_UID" ]]; then
    rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true
  fi
  if [[ -n "$EXTERNAL_ROOT" && "$EXTERNAL_ROOT" =~ ^/tmp/reliability-atlas-LES-0015-verifier\.[[:alnum:]]{8}$ \
    && -d "$EXTERNAL_ROOT" && ! -L "$EXTERNAL_ROOT" \
    && "$(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true)" == "$VERIFY_UID" ]]; then
    rm -- "$EXTERNAL_ROOT/target" 2>/dev/null || true
    rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
  fi
}

trap cleanup_owned_test_paths EXIT INT TERM

if [[ "$VERIFY_UID" -eq 0 ]]; then
  fail "run the verifier as a normal non-root user"
  exit 1
fi
if [[ ! -x "$LAB_SCRIPT" && ! -f "$LAB_SCRIPT" ]]; then
  fail "lab.sh is missing"
  exit 1
fi

must_contain() {
  local output="$1" expected="$2" label="$3"
  if ! grep -Fq -- "$expected" <<< "$output"; then
    fail "$label did not contain: $expected"
    exit 1
  fi
}

must_fail() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label unexpectedly succeeded"
    exit 1
  fi
}

state_root() {
  local -a lines=()
  mapfile -t lines < "$STATE_FILE"
  if [[ "${#lines[@]}" -ne 4 || "${lines[3]}" != lab_root=* ]]; then
    fail "cannot read verifier state root"
    exit 1
  fi
  printf '%s\n' "${lines[3]#lab_root=}"
}

initial="$(bash "$LAB_SCRIPT" check)"
must_contain "$initial" "state=absent" "initial check"
must_fail "unknown command" bash "$LAB_SCRIPT" unknown
must_fail "extra argument" bash "$LAB_SCRIPT" check extra
must_fail "observe before setup" bash "$LAB_SCRIPT" observe proxy

setup="$(bash "$LAB_SCRIPT" setup)"
must_contain "$setup" "setup=complete" "setup"
must_contain "$(bash "$LAB_SCRIPT" setup)" "setup=already-present" "idempotent setup"
must_fail "observe before baseline" bash "$LAB_SCRIPT" observe proxy
must_fail "inject before baseline" bash "$LAB_SCRIPT" inject guided

baseline="$(bash "$LAB_SCRIPT" run baseline)"
must_contain "$baseline" "record=baseline" "baseline"
must_contain "$baseline" "application_correct=true" "baseline"
must_fail "second baseline" bash "$LAB_SCRIPT" run baseline
must_fail "invalid case" bash "$LAB_SCRIPT" inject answer

must_contain "$(bash "$LAB_SCRIPT" inject guided)" "case=guided" "guided inject"
scenario="$(bash "$LAB_SCRIPT" scenario)"
must_contain "$scenario" "record=scenario" "guided scenario"
must_contain "$scenario" "observation_revealed=false" "guided scenario"
must_contain "$scenario" "predict_before_observe=true" "guided scenario"
if grep -Eq 'root_cause|diagnosis|recommended_fix|answer=' <<< "$scenario"; then
  fail "scenario leaked a diagnosis before observation"
  exit 1
fi
must_fail "second active case" bash "$LAB_SCRIPT" inject independent
for view in operation proxy cache pools health; do
  output="$(bash "$LAB_SCRIPT" observe "$view")"
  must_contain "$output" "record=observation" "$view observation"
  must_contain "$output" "view=$view" "$view observation"
done
must_contain "$(bash "$LAB_SCRIPT" recover)" "record=recovery" "guided recovery"
must_fail "observe after recovery" bash "$LAB_SCRIPT" observe proxy
verification="$(bash "$LAB_SCRIPT" verify-operation)"
must_contain "$verification" "application_correct=true" "guided verification"
must_contain "$verification" "verification_scope=deterministic_model_only" "guided verification"
must_contain "$(bash "$LAB_SCRIPT" cleanup)" "cleanup_proven=true" "guided cleanup"
must_contain "$(bash "$LAB_SCRIPT" check)" "state=absent" "guided final check"

bash "$LAB_SCRIPT" setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
bash "$LAB_SCRIPT" inject independent >/dev/null
independent_scenario="$(bash "$LAB_SCRIPT" scenario)"
must_contain "$independent_scenario" "case=independent" "independent scenario"
must_contain "$independent_scenario" "observation_revealed=false" "independent scenario"
for view in operation proxy cache pools health; do
  output="$(bash "$LAB_SCRIPT" observe "$view")"
  must_contain "$output" "case=independent" "$view independent observation"
  must_contain "$output" "view=$view" "$view independent observation"
done
must_contain "$(bash "$LAB_SCRIPT" recover)" "action=apply_approved_case_recovery" "independent recovery"
verification="$(bash "$LAB_SCRIPT" verify-operation)"
must_contain "$verification" "context_a_correct=true" "independent verification"
must_contain "$verification" "context_b_correct=true" "independent verification"
must_contain "$verification" "unsafe_shared_hit=false" "independent verification"
must_contain "$(bash "$LAB_SCRIPT" status)" "verification=complete" "independent status"
bash "$LAB_SCRIPT" cleanup >/dev/null

bash "$LAB_SCRIPT" setup >/dev/null
LAB_ROOT="$(state_root)"
printf 'unexpected\n' > "$LAB_ROOT/unexpected.txt"
must_fail "unexpected artifact refusal" bash "$LAB_SCRIPT" status
if [[ ! -f "$LAB_ROOT/unexpected.txt" ]]; then
  fail "unexpected artifact changed after refusal"
  exit 1
fi
rm -- "$LAB_ROOT/unexpected.txt"
bash "$LAB_SCRIPT" cleanup >/dev/null

bash "$LAB_SCRIPT" setup >/dev/null
LAB_ROOT="$(state_root)"
chmod 700 -- "$LAB_ROOT/http_path_model.py"
must_fail "changed model mode refusal" bash "$LAB_SCRIPT" status
chmod 500 -- "$LAB_ROOT/http_path_model.py"
bash "$LAB_SCRIPT" cleanup >/dev/null

EXTERNAL_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0015-verifier.XXXXXXXX')"
printf 'do-not-touch\n' > "$EXTERNAL_ROOT/target"
ln -s -- "$EXTERNAL_ROOT/target" "$STATE_FILE"
must_fail "symlink descriptor refusal" bash "$LAB_SCRIPT" check
if [[ "$(< "$EXTERNAL_ROOT/target")" != "do-not-touch" ]]; then
  fail "external symlink target changed"
  exit 1
fi
rm -- "$STATE_FILE"

bash "$LAB_SCRIPT" setup >/dev/null
descriptor="$(< "$STATE_FILE")"
printf 'state_version=1\nlesson_id=LES-0015\nowner_uid=%s\nlab_root=%s\n' \
  "$VERIFY_UID" "$EXTERNAL_ROOT" > "$STATE_FILE"
chmod 600 -- "$STATE_FILE"
must_fail "out-of-scope descriptor refusal" bash "$LAB_SCRIPT" status
if [[ "$(< "$EXTERNAL_ROOT/target")" != "do-not-touch" ]]; then
  fail "out-of-scope target changed"
  exit 1
fi
printf '%s\n' "$descriptor" > "$STATE_FILE"
chmod 600 -- "$STATE_FILE"
bash "$LAB_SCRIPT" cleanup >/dev/null

ORPHAN_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0015.XXXXXXXX')"
must_fail "orphan check refusal" bash "$LAB_SCRIPT" check
must_fail "orphan setup refusal" bash "$LAB_SCRIPT" setup
must_fail "orphan cleanup refusal" bash "$LAB_SCRIPT" cleanup
if [[ ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" ]]; then
  fail "orphan candidate changed after refusal"
  exit 1
fi
rmdir -- "$ORPHAN_ROOT"
ORPHAN_ROOT=""

must_contain "$(bash "$LAB_SCRIPT" cleanup)" "cleanup=already-clean" "idempotent cleanup"
if find "$SCRIPT_DIRECTORY" -type d -name __pycache__ -print -quit | grep -q .; then
  fail "python bytecode cache residue found"
  exit 1
fi
rm -- "$EXTERNAL_ROOT/target"
rmdir -- "$EXTERNAL_ROOT"
EXTERNAL_ROOT=""
trap - EXIT INT TERM

printf 'verification_passed=true\n'
printf 'cases=guided,independent\n'
printf 'prediction_gate=scenario-before-observation\n'
printf 'refusals=invalid-input,invalid-transition,unexpected-artifact,changed-model,symlink,out-of-scope-descriptor,orphan-candidate\n'
printf 'answer_isolation=independent-diagnosis-not-printed\n'
printf 'network_mutation=none\ncleanup_proven=true\n'
