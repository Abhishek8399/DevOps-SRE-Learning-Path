#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
readonly MODEL_SOURCE="$SCRIPT_DIRECTORY/fixtures/tls_trust_model.py"
VERIFY_UID="$(id -u)"
readonly VERIFY_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0016-$VERIFY_UID.state"

VERIFIER_LAB_ROOT=""
EXTERNAL_ROOT=""
ORPHAN_ROOT=""

fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

safe_remove_file() {
  local path="$1" owner
  if [[ -f "$path" && ! -L "$path" ]]; then
    owner="$(stat -c '%u' -- "$path" 2>/dev/null || true)"
    if [[ "$owner" == "$VERIFY_UID" ]]; then
      rm -- "$path" 2>/dev/null || true
    fi
  fi
}

cleanup_verifier_paths() {
  local owner resolved name

  if [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1 || true
  fi
  if [[ -n "$VERIFIER_LAB_ROOT" \
    && "$VERIFIER_LAB_ROOT" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ \
    && -d "$VERIFIER_LAB_ROOT" && ! -L "$VERIFIER_LAB_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$VERIFIER_LAB_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$VERIFIER_LAB_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$VERIFY_UID" && "$resolved" == "$VERIFIER_LAB_ROOT" ]]; then
      for name in verification.summary recovery.summary inputs-observed.state \
        active-case.state baseline.summary tls_trust_model.py artifact-manifest.tsv \
        .les-0016-sentinel unexpected.file
      do
        safe_remove_file "$VERIFIER_LAB_ROOT/$name"
      done
      if [[ -L "$VERIFIER_LAB_ROOT/baseline.summary" ]]; then
        rm -- "$VERIFIER_LAB_ROOT/baseline.summary" 2>/dev/null || true
      fi
      rmdir -- "$VERIFIER_LAB_ROOT" 2>/dev/null || true
    fi
  fi
  safe_remove_file "$STATE_FILE"

  if [[ -n "$EXTERNAL_ROOT" \
    && "$EXTERNAL_ROOT" =~ ^/tmp/reliability-atlas-LES-0016-verifier\.[[:alnum:]]{8}$ \
    && -d "$EXTERNAL_ROOT" && ! -L "$EXTERNAL_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$EXTERNAL_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$VERIFY_UID" && "$resolved" == "$EXTERNAL_ROOT" ]]; then
      safe_remove_file "$EXTERNAL_ROOT/target"
      rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -n "$ORPHAN_ROOT" \
    && "$ORPHAN_ROOT" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ \
    && -d "$ORPHAN_ROOT" && ! -L "$ORPHAN_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ORPHAN_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ORPHAN_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$VERIFY_UID" && "$resolved" == "$ORPHAN_ROOT" ]]; then
      rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true
    fi
  fi
}

trap cleanup_verifier_paths EXIT
trap 'exit 130' INT TERM

if [[ "$VERIFY_UID" -eq 0 ]]; then
  fail "run the verifier as a normal non-root Ubuntu user"
  exit 1
fi

for tool in bash cat chmod cmp find grep install ln mktemp python3 realpath rm rmdir stat; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    fail "required verifier command is missing: $tool"
    exit 1
  fi
done

if ! python3 -c \
  'from pathlib import Path; p=Path(__import__("sys").argv[1]); compile(p.read_text(encoding="utf-8"), p.name, "exec")' \
  "$MODEL_SOURCE"
then
  fail "fixture model did not compile"
  exit 1
fi

must_fail() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label unexpectedly succeeded"
    return 1
  fi
}

assert_contains() {
  local text="$1" expected="$2" label="$3"
  if ! grep -Fq -- "$expected" <<< "$text"; then
    fail "$label did not contain: $expected"
    return 1
  fi
}

assert_no_answer_labels() {
  local text="$1" label="$2"
  if grep -Eiq '^(diagnosis|root_cause|solution|solution_key|recommended_action)=' <<< "$text"; then
    fail "$label exposed a diagnosis or solution label"
    return 1
  fi
}

read_registered_root() {
  local line root owner resolved
  if [[ ! -f "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    fail "state descriptor unavailable to verifier"
    return 1
  fi
  line="$(grep -E '^lab_root=' "$STATE_FILE" || true)"
  root="${line#lab_root=}"
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ \
    || ! -d "$root" || -L "$root" ]]; then
    fail "registered root failed verifier boundary"
    return 1
  fi
  owner="$(stat -c '%u' -- "$root")"
  resolved="$(realpath -e -- "$root")"
  if [[ "$owner" != "$VERIFY_UID" || "$resolved" != "$root" ]]; then
    fail "registered root ownership or resolution failed verifier boundary"
    return 1
  fi
  printf '%s' "$root"
}

initial="$(bash "$LAB_SCRIPT" check)"
assert_contains "$initial" "state=absent" "initial check"
must_fail "status before setup" bash "$LAB_SCRIPT" status
must_fail "unknown command" bash "$LAB_SCRIPT" unknown
must_fail "extra check argument" bash "$LAB_SCRIPT" check unexpected
must_fail "invalid run target" bash "$LAB_SCRIPT" run incident
must_fail "invalid case" bash "$LAB_SCRIPT" inject transfer
must_fail "invalid view" bash "$LAB_SCRIPT" observe answer

run_case() {
  local case_name="$1"
  local setup status baseline injected inputs observed evidence recovered verified cleaned final view

  setup="$(bash "$LAB_SCRIPT" setup)"
  assert_contains "$setup" "setup=complete" "$case_name setup"
  VERIFIER_LAB_ROOT="$(read_registered_root)"
  setup="$(bash "$LAB_SCRIPT" setup)"
  assert_contains "$setup" "setup=already-present" "$case_name repeated setup"
  status="$(bash "$LAB_SCRIPT" status)"
  assert_contains "$status" "baseline=pending" "$case_name initial status"
  must_fail "$case_name verify before recovery" bash "$LAB_SCRIPT" verify-operation
  must_fail "$case_name recover before input" bash "$LAB_SCRIPT" recover

  baseline="$(bash "$LAB_SCRIPT" run baseline)"
  assert_contains "$baseline" "record=baseline" "$case_name baseline"
  assert_contains "$baseline" "operation_success=true" "$case_name baseline"
  must_fail "$case_name repeated baseline" bash "$LAB_SCRIPT" run baseline

  injected="$(bash "$LAB_SCRIPT" inject "$case_name")"
  assert_contains "$injected" "case=$case_name" "$case_name injection"
  assert_contains "$injected" "answer_key=not_provided" "$case_name injection"
  must_fail "$case_name second injection" bash "$LAB_SCRIPT" inject guided
  must_fail "$case_name derived view before inputs" bash "$LAB_SCRIPT" observe handshake
  must_fail "$case_name extra observe argument" \
    bash "$LAB_SCRIPT" observe inputs unexpected

  inputs="$(bash "$LAB_SCRIPT" observe inputs)"
  assert_contains "$inputs" "record=inputs" "$case_name inputs"
  assert_contains "$inputs" "case=$case_name" "$case_name inputs"
  assert_contains "$inputs" "hypothesis_checkpoint=" "$case_name input checkpoint"
  evidence="$injected"$'\n'"$inputs"

  for view in handshake certificate trust rotation ownership; do
    observed="$(bash "$LAB_SCRIPT" observe "$view")"
    assert_contains "$observed" "record=observation" "$case_name $view"
    assert_contains "$observed" "case=$case_name" "$case_name $view"
    assert_contains "$observed" "view=$view" "$case_name $view"
    evidence+=$'\n'"$observed"
  done
  assert_no_answer_labels "$evidence" "$case_name evidence"

  recovered="$(bash "$LAB_SCRIPT" recover)"
  assert_contains "$recovered" "record=recovery" "$case_name recovery"
  assert_contains "$recovered" "rollback_preserved=true" "$case_name recovery"
  must_fail "$case_name repeated recovery" bash "$LAB_SCRIPT" recover
  must_fail "$case_name observe after recovery" bash "$LAB_SCRIPT" observe trust

  verified="$(bash "$LAB_SCRIPT" verify-operation)"
  assert_contains "$verified" "record=verification" "$case_name verification"
  assert_contains "$verified" "fresh_handshake_success=true" "$case_name verification"
  assert_contains "$verified" "application_correctness=verified" "$case_name verification"
  assert_contains "$verified" \
    "verification_scope=deterministic_model_only" "$case_name verification"
  must_fail "$case_name repeated verification" bash "$LAB_SCRIPT" verify-operation

  status="$(bash "$LAB_SCRIPT" status)"
  assert_contains "$status" "active_case=$case_name" "$case_name final status"
  assert_contains "$status" "inputs_observed=complete" "$case_name final status"
  assert_contains "$status" "recovery=complete" "$case_name final status"
  assert_contains "$status" "verification=complete" "$case_name final status"

  cleaned="$(bash "$LAB_SCRIPT" cleanup)"
  assert_contains "$cleaned" "cleanup_proven=true" "$case_name cleanup"
  VERIFIER_LAB_ROOT=""
  final="$(bash "$LAB_SCRIPT" check)"
  assert_contains "$final" "state=absent" "$case_name final check"
}

run_case guided
run_case independent

bash "$LAB_SCRIPT" setup >/dev/null
VERIFIER_LAB_ROOT="$(read_registered_root)"
bash "$LAB_SCRIPT" run baseline >/dev/null

printf 'unknown\n' > "$VERIFIER_LAB_ROOT/unexpected.file"
chmod 600 -- "$VERIFIER_LAB_ROOT/unexpected.file"
must_fail "unexpected artifact status" bash "$LAB_SCRIPT" status
must_fail "unexpected artifact cleanup" bash "$LAB_SCRIPT" cleanup
if [[ ! -f "$VERIFIER_LAB_ROOT/unexpected.file" ]]; then
  fail "unexpected artifact changed after refusal"
  exit 1
fi
rm -- "$VERIFIER_LAB_ROOT/unexpected.file"

chmod 700 -- "$VERIFIER_LAB_ROOT/tls_trust_model.py"
printf '\n# verifier-tamper\n' >> "$VERIFIER_LAB_ROOT/tls_trust_model.py"
chmod 500 -- "$VERIFIER_LAB_ROOT/tls_trust_model.py"
must_fail "changed model status" bash "$LAB_SCRIPT" status
install -m 0500 -- "$MODEL_SOURCE" "$VERIFIER_LAB_ROOT/tls_trust_model.py"
status="$(bash "$LAB_SCRIPT" status)"
assert_contains "$status" "state=ready" "restored model status"

EXTERNAL_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0016-verifier.XXXXXXXX')"
printf 'must-survive\n' > "$EXTERNAL_ROOT/target"
chmod 600 -- "$EXTERNAL_ROOT/target"
rm -- "$VERIFIER_LAB_ROOT/baseline.summary"
ln -s -- "$EXTERNAL_ROOT/target" "$VERIFIER_LAB_ROOT/baseline.summary"
must_fail "symlink status" bash "$LAB_SCRIPT" status
must_fail "symlink cleanup" bash "$LAB_SCRIPT" cleanup
if ! cmp -s -- "$EXTERNAL_ROOT/target" <(printf 'must-survive\n'); then
  fail "external symlink target changed"
  exit 1
fi
rm -- "$VERIFIER_LAB_ROOT/baseline.summary"
python3 "$MODEL_SOURCE" baseline > "$VERIFIER_LAB_ROOT/baseline.summary"
chmod 600 -- "$VERIFIER_LAB_ROOT/baseline.summary"

descriptor="$(cat "$STATE_FILE")"
printf 'state_version=1\nlesson_id=LES-0016\nowner_uid=%s\nlab_root=%s\n' \
  "$VERIFY_UID" "$EXTERNAL_ROOT" > "$STATE_FILE"
chmod 600 -- "$STATE_FILE"
must_fail "out-of-scope descriptor status" bash "$LAB_SCRIPT" status
must_fail "out-of-scope descriptor cleanup" bash "$LAB_SCRIPT" cleanup
if ! cmp -s -- "$EXTERNAL_ROOT/target" <(printf 'must-survive\n'); then
  fail "out-of-scope target changed"
  exit 1
fi
printf '%s\n' "$descriptor" > "$STATE_FILE"
chmod 600 -- "$STATE_FILE"
bash "$LAB_SCRIPT" cleanup >/dev/null
VERIFIER_LAB_ROOT=""

ORPHAN_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0016.XXXXXXXX')"
must_fail "orphan check" bash "$LAB_SCRIPT" check
must_fail "orphan setup" bash "$LAB_SCRIPT" setup
must_fail "orphan cleanup" bash "$LAB_SCRIPT" cleanup
if [[ ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" ]]; then
  fail "orphan candidate changed after refusal"
  exit 1
fi
rmdir -- "$ORPHAN_ROOT"
ORPHAN_ROOT=""

idempotent="$(bash "$LAB_SCRIPT" cleanup)"
assert_contains "$idempotent" "cleanup=already-clean" "idempotent cleanup"
assert_contains "$idempotent" "cleanup_proven=true" "idempotent cleanup"

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
printf 'refusals=invalid-input,invalid-transition,derived-before-inputs,unexpected-artifact,changed-model,symlink,out-of-scope-descriptor,orphan-candidate\n'
printf 'answer_isolation=independent-values-captured-but-no-diagnosis-or-solution-label-printed\n'
printf 'network_mutation=none\n'
printf 'private_keys=none\n'
printf 'cleanup_proven=true\n'
