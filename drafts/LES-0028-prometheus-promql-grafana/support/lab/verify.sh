#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_NUMBER="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0028-${UID_NUMBER}"
CASES=(counter-rate vector-match histogram cardinality alert-state dashboard-contract incident)
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
python3 -c 'import pathlib,sys; source=pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"); compile(source,sys.argv[1],"exec")' "${SCRIPT_DIR}/fixtures/prometheus_model.py"

bash "${LAB}" cleanup >/dev/null
bash "${LAB}" doctor | grep -F 'ready=true' >/dev/null
bash "${LAB}" setup | grep -F 'state=ready' >/dev/null
bash "${LAB}" status | grep -F 'runtime=deterministic-model-only' >/dev/null

for case_name in "${CASES[@]}"; do
  output="$(bash "${LAB}" run "${case_name}")"
  grep -F '"case"' <<<"${output}" >/dev/null
  grep -F '"proofLimit"' <<<"${output}" >/dev/null
done

counter_output="$(bash "${LAB}" run counter-rate)"
grep -F '"attemptDelta":232' <<<"${counter_output}" >/dev/null
grep -F '"failureDelta":10' <<<"${counter_output}" >/dev/null
grep -F '"resetCount":2' <<<"${counter_output}" >/dev/null

cardinality_output="$(bash "${LAB}" run cardinality)"
grep -F '"boundedSeriesMaximum":1920' <<<"${cardinality_output}" >/dev/null
grep -F '"unboundedLabels":["request_id"]' <<<"${cardinality_output}" >/dev/null

alert_output="$(bash "${LAB}" run alert-state)"
grep -F '"states":["inactive","pending","firing","firing","resolved"]' <<<"${alert_output}" >/dev/null

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

printf 'verification=passed lesson=LES-0028 cases=%s refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only\n' "${#CASES[@]}"
