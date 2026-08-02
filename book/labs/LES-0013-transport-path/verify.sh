#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
readonly MODEL_SOURCE="$SCRIPT_DIRECTORY/fixtures/transport_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0013-$LAB_UID.state"

EXTERNAL_ROOT=""
ORPHAN_ROOT=""

fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

cleanup_verifier_paths() {
  local owner resolved

  if [[ -n "$EXTERNAL_ROOT" \
    && "$EXTERNAL_ROOT" =~ ^/tmp/reliability-atlas-LES-0013-verifier\.[[:alnum:]]{8}$ \
    && -d "$EXTERNAL_ROOT" && ! -L "$EXTERNAL_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$EXTERNAL_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$resolved" == "$EXTERNAL_ROOT" ]]; then
      if [[ -f "$EXTERNAL_ROOT/target" && ! -L "$EXTERNAL_ROOT/target" ]]; then
        rm -- "$EXTERNAL_ROOT/target" 2>/dev/null || true
      fi
      rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -n "$ORPHAN_ROOT" \
    && "$ORPHAN_ROOT" =~ ^/tmp/reliability-atlas-LES-0013\.[[:alnum:]]{8}$ \
    && -d "$ORPHAN_ROOT" && ! -L "$ORPHAN_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ORPHAN_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ORPHAN_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$resolved" == "$ORPHAN_ROOT" ]]; then
      rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true
    fi
  fi
}

trap cleanup_verifier_paths EXIT
trap 'exit 130' INT TERM

if [[ "$LAB_UID" -eq 0 ]]; then
  fail "run the verifier as a normal non-root Ubuntu user"
  exit 1
fi

for tool in bash chmod cmp grep install ln mktemp python3 realpath rm rmdir stat; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    fail "required verifier command is missing: $tool"
    exit 1
  fi
done

if ! python3 -c \
  'from pathlib import Path; compile(Path("fixtures/transport_model.py").read_text(encoding="utf-8"), "transport_model.py", "exec")' \
  2>/dev/null
then
  if ! python3 -c \
    'from pathlib import Path; p=Path(__import__("sys").argv[1]); compile(p.read_text(encoding="utf-8"), p.name, "exec")' \
    "$MODEL_SOURCE"
  then
    fail "fixture model did not compile"
    exit 1
  fi
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

read_registered_root() {
  local line root owner resolved
  if [[ ! -f "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    fail "state descriptor unavailable to verifier"
    return 1
  fi
  line="$(grep -E '^lab_root=' "$STATE_FILE")"
  root="${line#lab_root=}"
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0013\.[[:alnum:]]{8}$ \
    || ! -d "$root" || -L "$root" ]]; then
    fail "registered root failed verifier boundary"
    return 1
  fi
  owner="$(stat -c '%u' -- "$root")"
  resolved="$(realpath -e -- "$root")"
  if [[ "$owner" != "$LAB_UID" || "$resolved" != "$root" ]]; then
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

run_case() {
  local case_name="$1"
  local setup status baseline injected observed recovered verified cleaned final view

  setup="$(bash "$LAB_SCRIPT" setup)"
  assert_contains "$setup" "setup=complete" "$case_name setup"
  setup="$(bash "$LAB_SCRIPT" setup)"
  assert_contains "$setup" "setup=already-present" "$case_name repeated setup"
  status="$(bash "$LAB_SCRIPT" status)"
  assert_contains "$status" "baseline=pending" "$case_name initial status"
  must_fail "$case_name verify before recovery" bash "$LAB_SCRIPT" verify-operation
  must_fail "$case_name recover before injection" bash "$LAB_SCRIPT" recover

  baseline="$(bash "$LAB_SCRIPT" run baseline)"
  assert_contains "$baseline" "record=baseline" "$case_name baseline"
  assert_contains "$baseline" "operation_success=true" "$case_name baseline"
  must_fail "$case_name repeated baseline" bash "$LAB_SCRIPT" run baseline

  injected="$(bash "$LAB_SCRIPT" inject "$case_name")"
  assert_contains "$injected" "case=$case_name" "$case_name injection"
  assert_contains "$injected" "answer_key=not_provided" "$case_name injection"
  must_fail "$case_name second injection" bash "$LAB_SCRIPT" inject guided
  must_fail "$case_name invalid view" bash "$LAB_SCRIPT" observe invalid-view
  must_fail "$case_name extra observe argument" \
    bash "$LAB_SCRIPT" observe operation unexpected

  for view in operation endpoints queues resources stateful-path; do
    observed="$(bash "$LAB_SCRIPT" observe "$view")"
    assert_contains "$observed" "record=observation" "$case_name $view"
    assert_contains "$observed" "case=$case_name" "$case_name $view"
    assert_contains "$observed" "view=$view" "$case_name $view"
  done

  recovered="$(bash "$LAB_SCRIPT" recover)"
  assert_contains "$recovered" "record=recovery" "$case_name recovery"
  assert_contains "$recovered" "operation_success=true" "$case_name recovery"
  must_fail "$case_name repeated recovery" bash "$LAB_SCRIPT" recover
  must_fail "$case_name observe after recovery" \
    bash "$LAB_SCRIPT" observe operation

  verified="$(bash "$LAB_SCRIPT" verify-operation)"
  assert_contains "$verified" "record=verification" "$case_name verification"
  assert_contains "$verified" "operation_success=true" "$case_name verification"
  assert_contains "$verified" \
    "verification_scope=deterministic_model_only" "$case_name verification"
  must_fail "$case_name repeated verification" bash "$LAB_SCRIPT" verify-operation

  status="$(bash "$LAB_SCRIPT" status)"
  assert_contains "$status" "active_case=$case_name" "$case_name final status"
  assert_contains "$status" "recovery=complete" "$case_name final status"
  assert_contains "$status" "verification=complete" "$case_name final status"

  cleaned="$(bash "$LAB_SCRIPT" cleanup)"
  assert_contains "$cleaned" "cleanup_proven=true" "$case_name cleanup"
  final="$(bash "$LAB_SCRIPT" check)"
  assert_contains "$final" "state=absent" "$case_name final check"
}

run_case guided
run_case independent

bash "$LAB_SCRIPT" setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
lab_root="$(read_registered_root)"

printf 'unknown\n' > "$lab_root/unexpected.file"
chmod 600 -- "$lab_root/unexpected.file"
must_fail "unexpected artifact status" bash "$LAB_SCRIPT" status
must_fail "unexpected artifact cleanup" bash "$LAB_SCRIPT" cleanup
if [[ ! -f "$lab_root/unexpected.file" ]]; then
  fail "unexpected artifact changed after refusal"
  exit 1
fi
rm -- "$lab_root/unexpected.file"

chmod 700 -- "$lab_root/transport_model.py"
printf '\n# verifier-tamper\n' >> "$lab_root/transport_model.py"
chmod 500 -- "$lab_root/transport_model.py"
must_fail "changed model status" bash "$LAB_SCRIPT" status
install -m 0500 -- "$MODEL_SOURCE" "$lab_root/transport_model.py"
status="$(bash "$LAB_SCRIPT" status)"
assert_contains "$status" "state=ready" "restored model status"

EXTERNAL_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0013-verifier.XXXXXXXX')"
printf 'must-survive\n' > "$EXTERNAL_ROOT/target"
chmod 600 -- "$EXTERNAL_ROOT/target"
rm -- "$lab_root/baseline.summary"
ln -s -- "$EXTERNAL_ROOT/target" "$lab_root/baseline.summary"
must_fail "symlink status" bash "$LAB_SCRIPT" status
must_fail "symlink cleanup" bash "$LAB_SCRIPT" cleanup
if ! cmp -s -- "$EXTERNAL_ROOT/target" <(printf 'must-survive\n'); then
  fail "external symlink target changed"
  exit 1
fi
rm -- "$lab_root/baseline.summary"
python3 "$MODEL_SOURCE" baseline > "$lab_root/baseline.summary"
chmod 600 -- "$lab_root/baseline.summary"

descriptor="$(cat "$STATE_FILE")"
printf 'state_version=1\nlesson_id=LES-0013\nowner_uid=%s\nlab_root=%s\n' \
  "$LAB_UID" "$EXTERNAL_ROOT" > "$STATE_FILE"
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

ORPHAN_ROOT="$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0013.XXXXXXXX')"
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
printf 'refusals=invalid-input,invalid-transition,unexpected-artifact,changed-model,symlink,out-of-scope-descriptor,orphan-candidate\n'
printf 'answer_isolation=independent-values-and-diagnosis-not-printed\n'
printf 'network_mutation=none\n'
printf 'cleanup_proven=true\n'
