#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_NUMBER="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0030-${UID_NUMBER}"
CASES=(alert-quality state-machine burn-rate no-data routing flapping dashboard incident)
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
python3 -c 'import pathlib,sys; source=pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"); compile(source,sys.argv[1],"exec")' "${SCRIPT_DIR}/fixtures/alert_lifecycle_model.py"

bash "${LAB}" cleanup >/dev/null
bash "${LAB}" doctor | grep -F 'ready=true' >/dev/null
bash "${LAB}" setup | grep -F 'state=ready' >/dev/null
bash "${LAB}" status | grep -F 'runtime=deterministic-model-only' >/dev/null

for case_name in "${CASES[@]}"; do
  output="$(bash "${LAB}" run "${case_name}")"
  grep -F '"case"' <<<"${output}" >/dev/null
  grep -F '"proofLimit"' <<<"${output}" >/dev/null
done

quality_output="$(bash "${LAB}" run alert-quality)"
grep -F '"falsePositives":4' <<<"${quality_output}" >/dev/null
grep -F '"missedSignificantEvents":2' <<<"${quality_output}" >/dev/null
grep -F '"precision":0.666667' <<<"${quality_output}" >/dev/null
grep -F '"recall":0.8' <<<"${quality_output}" >/dev/null

state_output="$(bash "${LAB}" run state-machine)"
grep -F '"finalState":"normal"' <<<"${state_output}" >/dev/null
grep -F '"stateTransitions":3' <<<"${state_output}" >/dev/null

burn_output="$(bash "${LAB}" run burn-rate)"
grep -F '"firingPolicies":["fast-page","slow-page","ticket"]' <<<"${burn_output}" >/dev/null

no_data_output="$(bash "${LAB}" run no-data)"
grep -F '"healthy-zero":"value-zero"' <<<"${no_data_output}" >/dev/null
grep -F '"partial-population":"missing-series"' <<<"${no_data_output}" >/dev/null
grep -F '"no-data":"no-data"' <<<"${no_data_output}" >/dev/null
grep -F '"query-error":"query-error"' <<<"${no_data_output}" >/dev/null

routing_output="$(bash "${LAB}" run routing)"
grep -F '"receivedAlerts":6' <<<"${routing_output}" >/dev/null
grep -F '"uniqueAlerts":5' <<<"${routing_output}" >/dev/null
grep -F '"deliverableAlerts":3' <<<"${routing_output}" >/dev/null
grep -F '"notificationGroups":2' <<<"${routing_output}" >/dev/null

flapping_output="$(bash "${LAB}" run flapping)"
grep -F '"naiveTransitions":4' <<<"${flapping_output}" >/dev/null
grep -F '"hysteresisTransitions":2' <<<"${flapping_output}" >/dev/null

dashboard_output="$(bash "${LAB}" run dashboard)"
grep -F '"real-zero-errors":"value-zero"' <<<"${dashboard_output}" >/dev/null
grep -F '"no-traffic-evidence":"no-data"' <<<"${dashboard_output}" >/dev/null
grep -F '"stale-success-rate":"stale"' <<<"${dashboard_output}" >/dev/null
grep -F '"partial-coverage":"partial"' <<<"${dashboard_output}" >/dev/null

incident_output="$(bash "${LAB}" run incident)"
grep -F '"earliestSupportedBoundary":"notification policy grouping, inhibition, and deduplication"' <<<"${incident_output}" >/dev/null

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

printf 'verification=passed lesson=LES-0030 cases=%s refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only\n' "${#CASES[@]}"
