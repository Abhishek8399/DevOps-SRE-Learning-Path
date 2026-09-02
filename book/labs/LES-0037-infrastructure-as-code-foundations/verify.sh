#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
MODEL="${SCRIPT_DIR}/fixtures/iac_model.py"
SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0037-${CURRENT_UID}"
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
if bash "${LAB}" run graph >/dev/null 2>&1; then fail run-refuses-absent "run unexpectedly succeeded"; fi
pass run-refuses-absent
contains setup-new "$(bash "${LAB}" setup)" "existing=false"
contains setup-idempotent "$(bash "${LAB}" setup)" "existing=true"
contains status-ready "$(bash "${LAB}" status)" "state=ready"

graph="$(bash "${LAB}" run graph)"
contains graph-order "${graph}" "order=network,database,service"
contains graph-cycle "${graph}" "cycle=false"
plan="$(bash "${LAB}" run plan)"
contains plan-create "${plan}" "create=1"
contains plan-update "${plan}" "update=1"
contains plan-delete "${plan}" "delete=1"
contains plan-noop "${plan}" "noOp=1"
contains plan-changes "${plan}" "changes=3"
drift="$(bash "${LAB}" run drift)"
contains drift-count "${drift}" "drifted=1"
contains drift-source "${drift}" "source=out-of-band"
contains drift-decision "${drift}" "decisionRequired=true"
policy="$(bash "${LAB}" run policy)"
contains policy-denied "${policy}" "denied=1"
contains policy-reason "${policy}" "reason=public-database"
partial="$(bash "${LAB}" run partial)"
contains partial-succeeded "${partial}" "succeeded=1"
contains partial-failed "${partial}" "failed=1"
contains partial-blocked "${partial}" "blocked=1"
contains partial-transaction "${partial}" "transactionalRollback=false"
converge="$(bash "${LAB}" run converge)"
contains converge-first "${converge}" "firstChanges=3"
contains converge-second "${converge}" "secondChanges=0"
contains converge-result "${converge}" "converged=true"
sensitive="$(bash "${LAB}" run sensitive)"
contains sensitive-display "${sensitive}" "displayRedacted=true"
contains sensitive-state "${sensitive}" "stateContainsSensitive=true"
contains sensitive-encryption "${sensitive}" "encryptedClaimed=false"

[[ -f "${STATE_DIR}/result.json" && ! -L "${STATE_DIR}/result.json" ]] || fail result-regular "result missing or not regular"
pass result-regular
printf 'unexpected\n' >"${STATE_DIR}/UNEXPECTED"
if bash "${LAB}" status >/dev/null 2>&1; then fail unexpected-entry-refused "status accepted unexpected state"; fi
pass unexpected-entry-refused
rm -f -- "${STATE_DIR}/UNEXPECTED"
contains cleanup-removed "$(bash "${LAB}" cleanup)" "removed=true"
contains cleanup-absent "$(bash "${LAB}" status)" "state=absent"

trap - EXIT
printf 'verification=pass assertions=%s cases=7 state_absent=true network_used=false provider_used=false infrastructure_touched=false\n' "${PASSED}"
