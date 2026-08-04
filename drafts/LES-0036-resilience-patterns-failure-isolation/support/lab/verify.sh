#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
MODEL="${SCRIPT_DIR}/fixtures/resilience_model.py"
SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0036-${CURRENT_UID}"
PASSED=0

pass() { PASSED=$((PASSED + 1)); printf 'assertion=pass name=%s\n' "$1"; }
fail() { printf 'assertion=fail name=%s detail=%s\n' "$1" "$2" >&2; exit 1; }
contains() {
  local name="$1" value="$2" expected="$3"
  [[ "${value}" == *"${expected}"* ]] || fail "${name}" "expected=${expected} actual=${value}"
  pass "${name}"
}
cleanup_on_exit() {
  local code=$?
  if [[ "${CURRENT_UID}" != "0" && ( -e "${STATE_DIR}" || -L "${STATE_DIR}" ) ]]; then
    bash "${LAB}" cleanup >/dev/null || true
  fi
  exit "${code}"
}
trap cleanup_on_exit EXIT

[[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
python3 "${MODEL}" validate-scenario "${SCENARIO}" >/dev/null
pass scenario-contract
python3 -c 'import pathlib,sys; compile(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"), sys.argv[1], "exec")' "${MODEL}"
pass python-compiles-in-memory

bash "${LAB}" cleanup >/dev/null
contains doctor-absent "$(bash "${LAB}" doctor)" "state=absent"
if bash "${LAB}" run deadline >/dev/null 2>&1; then fail run-refuses-absent "run unexpectedly succeeded"; fi
pass run-refuses-absent
contains setup-new "$(bash "${LAB}" setup)" "existing=false"
contains setup-idempotent "$(bash "${LAB}" setup)" "existing=true"
contains status-ready "$(bash "${LAB}" status)" "state=ready"

deadline="$(bash "${LAB}" run deadline)"
contains deadline-remaining "${deadline}" "remainingMs=120"
contains deadline-valid "${deadline}" "valid=true"
retries="$(bash "${LAB}" run retries)"
contains retries-unbounded "${retries}" "unboundedAttempts=27"
contains retries-budgeted "${retries}" "budgetedAttempts=4"
contains retries-contained "${retries}" "amplificationContained=true"
jitter="$(bash "${LAB}" run jitter)"
contains jitter-slots "${jitter}" "uniqueSlots=8"
contains jitter-spread "${jitter}" "synchronized=false"
idempotency="$(bash "${LAB}" run idempotency)"
contains idempotency-requests "${idempotency}" "requests=4"
contains idempotency-effects "${idempotency}" "sideEffects=1"
contains idempotency-conflict "${idempotency}" "conflicts=1"
contains idempotency-safe "${idempotency}" "safe=true"
circuit="$(bash "${LAB}" run circuit)"
contains circuit-opened "${circuit}" "opened=true"
contains circuit-probes "${circuit}" "probes=2"
contains circuit-recovered "${circuit}" "finalState=closed"
bulkhead="$(bash "${LAB}" run bulkhead)"
contains bulkhead-shared "${bulkhead}" "sharedProtected=false"
contains bulkhead-isolated "${bulkhead}" "bulkheadProtected=true"

[[ -f "${STATE_DIR}/result.json" && ! -L "${STATE_DIR}/result.json" ]] || fail result-regular "result missing or not regular"
pass result-regular
printf 'unexpected\n' >"${STATE_DIR}/UNEXPECTED"
if bash "${LAB}" status >/dev/null 2>&1; then fail unexpected-entry-refused "status accepted unexpected state"; fi
pass unexpected-entry-refused
rm -f -- "${STATE_DIR}/UNEXPECTED"
contains cleanup-removed "$(bash "${LAB}" cleanup)" "removed=true"
contains cleanup-absent "$(bash "${LAB}" status)" "state=absent"

trap - EXIT
printf 'verification=pass assertions=%s cases=6 state_absent=true network_used=false production_touched=false\n' "${PASSED}"
