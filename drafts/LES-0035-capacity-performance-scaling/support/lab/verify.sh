#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
MODEL="${SCRIPT_DIR}/fixtures/capacity_model.py"
SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0035-${CURRENT_UID}"
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
if bash "${LAB}" run baseline >/dev/null 2>&1; then fail run-refuses-absent "run unexpectedly succeeded"; fi
pass run-refuses-absent
contains setup-new "$(bash "${LAB}" setup)" "existing=false"
contains setup-idempotent "$(bash "${LAB}" setup)" "existing=true"
contains status-ready "$(bash "${LAB}" status)" "state=ready"

baseline="$(bash "${LAB}" run baseline)"
contains baseline-offered "${baseline}" "offered=1200"
contains baseline-accepted "${baseline}" "accepted=1100"
contains baseline-goodput "${baseline}" "goodput=1040"
curve="$(bash "${LAB}" run curve)"
contains curve-knee "${curve}" "kneeRps=900"
contains curve-collapse "${curve}" "collapseRps=1200"
contains curve-peak "${curve}" "peakGoodputRps=900"
queue="$(bash "${LAB}" run queue)"
contains queue-estimated "${queue}" "estimatedConcurrency=180"
contains queue-observed "${queue}" "observedConcurrency=184"
contains queue-tolerance "${queue}" "withinTolerance=true"
forecast="$(bash "${LAB}" run forecast)"
contains forecast-required "${forecast}" "requiredRps=1800"
contains forecast-replicas "${forecast}" "requiredReplicas=12"
autoscale="$(bash "${LAB}" run autoscale)"
contains autoscale-reaction "${autoscale}" "reactionSeconds=105"
contains autoscale-unsafe "${autoscale}" "safe=false"
workload="$(bash "${LAB}" run workload)"
contains workload-classes "${workload}" "classes=3"
contains workload-share "${workload}" "shareTotal=1.0"
contains workload-headroom "${workload}" "generatorHeadroomPct=40"
contains workload-valid "${workload}" "valid=true"
overload="$(bash "${LAB}" run overload)"
contains overload-admitted "${overload}" "admitted=3"
contains overload-shed "${overload}" "shed=2"
contains overload-priority "${overload}" "priorityInversion=false"

[[ -f "${STATE_DIR}/result.json" && ! -L "${STATE_DIR}/result.json" ]] || fail result-regular "result missing or not regular"
pass result-regular
printf 'unexpected\n' >"${STATE_DIR}/UNEXPECTED"
if bash "${LAB}" status >/dev/null 2>&1; then fail unexpected-entry-refused "status accepted unexpected state"; fi
pass unexpected-entry-refused
rm -f -- "${STATE_DIR}/UNEXPECTED"
contains cleanup-removed "$(bash "${LAB}" cleanup)" "removed=true"
contains cleanup-absent "$(bash "${LAB}" status)" "state=absent"

trap - EXIT
printf 'verification=pass assertions=%s cases=7 state_absent=true network_used=false production_touched=false\n' "${PASSED}"
