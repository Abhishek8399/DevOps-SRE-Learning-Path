#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_NUMBER="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0032-${UID_NUMBER}"
CASES=(event-sli time-budget latency coverage aggregation burn alerting low-traffic policy)
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
python3 -c 'import pathlib,sys; source=pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"); compile(source,sys.argv[1],"exec")' "${SCRIPT_DIR}/fixtures/slo_model.py"

bash "${LAB}" cleanup >/dev/null
bash "${LAB}" doctor | grep -F 'ready=true' >/dev/null
bash "${LAB}" setup | grep -F 'state=ready' >/dev/null
bash "${LAB}" status | grep -F 'runtime=deterministic-model-only' >/dev/null

for case_name in "${CASES[@]}"; do
  output="$(bash "${LAB}" run "${case_name}")"
  grep -F '"case"' <<<"${output}" >/dev/null
  grep -F '"proofLimit"' <<<"${output}" >/dev/null
done

event_output="$(bash "${LAB}" run event-sli)"
grep -F '"name":"checkout-completion"' <<<"${event_output}" >/dev/null
grep -F '"remainingBudgetEvents":-1200.0' <<<"${event_output}" >/dev/null
grep -F '"budgetConsumedFraction":1.6' <<<"${event_output}" >/dev/null
grep -F '"name":"catalog-read"' <<<"${event_output}" >/dev/null
grep -F '"remainingBudgetEvents":1000.0' <<<"${event_output}" >/dev/null

time_output="$(bash "${LAB}" run time-budget)"
grep -F '"allowedBadMinutes":40.32' <<<"${time_output}" >/dev/null
grep -F '"remainingBudgetMinutes":-7.18' <<<"${time_output}" >/dev/null
grep -F '"compliant":false' <<<"${time_output}" >/dev/null

latency_output="$(bash "${LAB}" run latency)"
grep -F '"budgetConsumedFraction":1.25' <<<"${latency_output}" >/dev/null
grep -F '"thresholdMilliseconds":400' <<<"${latency_output}" >/dev/null

coverage_output="$(bash "${LAB}" run coverage)"
grep -F '"coverageRatio":0.9' <<<"${coverage_output}" >/dev/null
grep -F '"observedOnlySli":0.999' <<<"${coverage_output}" >/dev/null
grep -F '"conservativeSli":0.8991' <<<"${coverage_output}" >/dev/null
grep -F '"measurementValid":false' <<<"${coverage_output}" >/dev/null

aggregation_output="$(bash "${LAB}" run aggregation)"
grep -F '"weightedGoodOverTotal":0.991' <<<"${aggregation_output}" >/dev/null
grep -F '"unweightedMeanOfRatios":0.995' <<<"${aggregation_output}" >/dev/null

burn_output="$(bash "${LAB}" run burn)"
grep -F '"actualErrorRate":0.0016' <<<"${burn_output}" >/dev/null
grep -F '"burnRate":1.6' <<<"${burn_output}" >/dev/null
grep -F '"budgetExhaustionDaysIfSustained":17.5' <<<"${burn_output}" >/dev/null

alert_output="$(bash "${LAB}" run alerting)"
grep -F '"active":["page-fast","page-medium","ticket-slow"]' <<<"${alert_output}" >/dev/null
grep -F '"name":"recovered-spike"' <<<"${alert_output}" >/dev/null
grep -F '"active":false' <<<"${alert_output}" >/dev/null

low_output="$(bash "${LAB}" run low-traffic)"
grep -F '"burnRate":100.0' <<<"${low_output}" >/dev/null
grep -F '"decision":"human-impact-and-measurement-review-required"' <<<"${low_output}" >/dev/null

policy_output="$(bash "${LAB}" run policy)"
grep -F '"budgetExhausted":true' <<<"${policy_output}" >/dev/null
grep -F '"decision":"pause-user-risk-increasing-change-and-prioritize-reliability"' <<<"${policy_output}" >/dev/null

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

printf 'verification=passed lesson=LES-0032 cases=%s assertions=24 refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only\n' "${#CASES[@]}"
