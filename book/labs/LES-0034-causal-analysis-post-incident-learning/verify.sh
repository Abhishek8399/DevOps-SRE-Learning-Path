#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
MODEL="${SCRIPT_DIR}/fixtures/incident_model.py"
SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0034-${CURRENT_UID}"
PASSED=0

pass() {
  PASSED=$((PASSED + 1))
  printf 'assertion=pass name=%s\n' "$1"
}

fail() {
  printf 'assertion=fail name=%s detail=%s\n' "$1" "$2" >&2
  exit 1
}

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

if [[ "${CURRENT_UID}" == "0" ]]; then
  printf 'refused=true reason=root-not-required\n' >&2
  exit 77
fi

python3 "${MODEL}" validate-scenario "${SCENARIO}" >/dev/null
pass scenario-contract
python3 -c 'import pathlib; compile(pathlib.Path(__import__("sys").argv[1]).read_text(encoding="utf-8"), __import__("sys").argv[1], "exec")' "${MODEL}"
pass python-compiles-in-memory

bash "${LAB}" cleanup >/dev/null
doctor_output="$(bash "${LAB}" doctor)"
contains doctor-absent "${doctor_output}" "state=absent"

if bash "${LAB}" run timeline >/dev/null 2>&1; then
  fail run-refuses-absent "run unexpectedly succeeded"
fi
pass run-refuses-absent

setup_output="$(bash "${LAB}" setup)"
contains setup-new "${setup_output}" "existing=false"
setup_again="$(bash "${LAB}" setup)"
contains setup-idempotent "${setup_again}" "existing=true"
status_output="$(bash "${LAB}" status)"
contains status-ready "${status_output}" "state=ready"

timeline="$(bash "${LAB}" run timeline)"
contains timeline-conflict "${timeline}" "rawOrderConflict=true"
contains timeline-uncertainty "${timeline}" "uncertainEvents=1"

claims="$(bash "${LAB}" run claims)"
contains claims-unsupported "${claims}" "unsupported=2"
contains claims-ids "${claims}" "unsupportedIds=C4,C5"

graph="$(bash "${LAB}" run graph)"
contains graph-acyclic "${graph}" "acyclic=true"
contains graph-supported "${graph}" "supportedLinks=6"
contains graph-tentative "${graph}" "unsupportedLinks=1"

counterfactual="$(bash "${LAB}" run counterfactual)"
contains counterfactual-testable "${counterfactual}" "testable=3"
contains counterfactual-confounded "${counterfactual}" "confounded=1"

methods="$(bash "${LAB}" run methods)"
contains methods-linear "${methods}" "linearCoverage=4"
contains methods-graph "${methods}" "graphCoverage=8"

actions="$(bash "${LAB}" run actions)"
contains actions-accepted "${actions}" "accepted=5"
contains actions-rejected "${actions}" "rejected=3"

verification="$(bash "${LAB}" run verification)"
contains verification-effective "${verification}" "verifiedEffective=4"
contains verification-ineffective "${verification}" "ineffective=1"
contains verification-overdue "${verification}" "overdue=1"

[[ -f "${STATE_DIR}/result.json" && ! -L "${STATE_DIR}/result.json" ]] || fail result-regular "result missing or not regular"
pass result-regular

printf 'unexpected\n' >"${STATE_DIR}/UNEXPECTED"
if bash "${LAB}" status >/dev/null 2>&1; then
  fail unexpected-entry-refused "status accepted unexpected state"
fi
pass unexpected-entry-refused
rm -f -- "${STATE_DIR}/UNEXPECTED"

cleanup_output="$(bash "${LAB}" cleanup)"
contains cleanup-removed "${cleanup_output}" "removed=true"
final_status="$(bash "${LAB}" status)"
contains cleanup-absent "${final_status}" "state=absent"

trap - EXIT
printf 'verification=pass assertions=%s cases=7 state_absent=true network_used=false production_touched=false\n' "${PASSED}"
