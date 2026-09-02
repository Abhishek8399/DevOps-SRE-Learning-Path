#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_NUMBER="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0031-${UID_NUMBER}"
CASES=(risk toil automation workload ownership readiness operating-review incident)
INJECTED_UNEXPECTED=false
INJECTED_SYMLINK=false

if [[ "${UID_NUMBER}" == "0" ]]; then
  printf 'refused=true reason=root-not-required\n' >&2
  exit 77
fi

final_cleanup() {
  local original_status=$?
  local cleanup_status=0
  trap - EXIT
  if [[ "${INJECTED_UNEXPECTED}" == "true" && -f "${STATE_DIR}/unexpected" && ! -L "${STATE_DIR}/unexpected" ]]; then
    rm -- "${STATE_DIR}/unexpected"
  fi
  if [[ "${INJECTED_SYMLINK}" == "true" && -L "${STATE_DIR}/unsafe-link" && "$(readlink -- "${STATE_DIR}/unsafe-link")" == "/tmp" ]]; then
    rm -- "${STATE_DIR}/unsafe-link"
  fi
  if [[ -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    if ! bash "${LAB}" cleanup >/dev/null; then
      printf 'verification=cleanup-failed state=%s action=preserve-and-inspect\n' "${STATE_DIR}" >&2
      cleanup_status=1
    fi
  elif [[ -L "${STATE_DIR}" ]]; then
    printf 'verification=cleanup-refused reason=state-root-is-symlink state=%s\n' "${STATE_DIR}" >&2
    cleanup_status=1
  fi
  if [[ "${original_status}" -ne 0 ]]; then
    exit "${original_status}"
  fi
  exit "${cleanup_status}"
}
trap final_cleanup EXIT

bash -n "${LAB}"
bash -n "${BASH_SOURCE[0]}"
python3 -c 'import pathlib,sys; source=pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"); compile(source,sys.argv[1],"exec")' "${SCRIPT_DIR}/fixtures/sre_operating_model.py"

bash "${LAB}" cleanup >/dev/null
bash "${LAB}" doctor | grep -F 'ready=true' >/dev/null
bash "${LAB}" setup | grep -F 'state=ready' >/dev/null
bash "${LAB}" status | grep -F 'runtime=deterministic-model-only' >/dev/null

for case_name in "${CASES[@]}"; do
  output="$(bash "${LAB}" run "${case_name}")"
  grep -F '"case"' <<<"${output}" >/dev/null
  grep -F '"proofLimit"' <<<"${output}" >/dev/null
done

risk_output="$(bash "${LAB}" run risk)"
grep -F '"exhausted":["public-checkout"]' <<<"${risk_output}" >/dev/null
grep -F '"remainingBudgetEvents":-1000.0' <<<"${risk_output}" >/dev/null

toil_output="$(bash "${LAB}" run toil)"
grep -F '"toilMinutes":600' <<<"${toil_output}" >/dev/null
grep -F '"toilFraction":0.645161' <<<"${toil_output}" >/dev/null

automation_output="$(bash "${LAB}" run automation)"
grep -F '"bestFirstQuarter":"worker-self-recovery"' <<<"${automation_output}" >/dev/null
grep -F '"firstQuarterNetAfterBuildHours":18.0' <<<"${automation_output}" >/dev/null

workload_output="$(bash "${LAB}" run workload)"
grep -F '"engineeringHours":64' <<<"${workload_output}" >/dev/null
grep -F '"engineeringGapHours":56.0' <<<"${workload_output}" >/dev/null
grep -F '"sustainableByFixture":false' <<<"${workload_output}" >/dev/null

ownership_output="$(bash "${LAB}" run ownership)"
grep -F '"missing":["capacity-owner","on-call-secondary"]' <<<"${ownership_output}" >/dev/null

readiness_output="$(bash "${LAB}" run readiness)"
grep -F '"decision":"no-go"' <<<"${readiness_output}" >/dev/null
grep -F '"blockers":["user-journey-slo","dependency-failure-test","on-call-secondary"]' <<<"${readiness_output}" >/dev/null

review_output="$(bash "${LAB}" run operating-review)"
grep -F '"interventionPeriods":["week-1","week-2"]' <<<"${review_output}" >/dev/null

incident_output="$(bash "${LAB}" run incident)"
grep -F '"earliestSupportedBoundary":"operating model, incentives, and service ownership"' <<<"${incident_output}" >/dev/null

touch "${STATE_DIR}/unexpected"
INJECTED_UNEXPECTED=true
if bash "${LAB}" cleanup >/dev/null 2>&1; then
  printf 'verification=failed reason=unexpected-child-not-refused\n' >&2
  exit 1
fi
rm -- "${STATE_DIR}/unexpected"
INJECTED_UNEXPECTED=false

ln -s -- /tmp "${STATE_DIR}/unsafe-link"
INJECTED_SYMLINK=true
if bash "${LAB}" cleanup >/dev/null 2>&1; then
  printf 'verification=failed reason=symlink-child-not-refused\n' >&2
  exit 1
fi
rm -- "${STATE_DIR}/unsafe-link"
INJECTED_SYMLINK=false

bash "${LAB}" cleanup | grep -F 'cleanup=passed state=absent' >/dev/null
[[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]
trap - EXIT

printf 'verification=passed lesson=LES-0031 cases=%s refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only\n' "${#CASES[@]}"
