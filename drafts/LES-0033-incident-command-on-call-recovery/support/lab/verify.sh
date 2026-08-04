#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_NUMBER="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0033-${UID_NUMBER}"
CASES=(triage roles mitigation recovery communication handoff review)
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
python3 -c 'import pathlib,sys; source=pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"); compile(source,sys.argv[1],"exec")' "${SCRIPT_DIR}/fixtures/incident_model.py"
python3 "${SCRIPT_DIR}/fixtures/incident_model.py" validate-scenario "${SCRIPT_DIR}/fixtures/scenario.json" | grep -F 'scenario_valid=true' >/dev/null

bash "${LAB}" cleanup >/dev/null
bash "${LAB}" doctor | grep -F 'ready=true' >/dev/null
bash "${LAB}" setup | grep -F 'state=ready' >/dev/null
bash "${LAB}" status | grep -F 'runtime=deterministic-model-only' >/dev/null

for case_name in "${CASES[@]}"; do
  output="$(bash "${LAB}" run "${case_name}")"
  grep -F '"case"' <<<"${output}" >/dev/null
  grep -F '"proofLimit"' <<<"${output}" >/dev/null
done

triage_output="$(bash "${LAB}" run triage)"
grep -F '"declare":true' <<<"${triage_output}" >/dev/null
grep -F '"severity":"SEV-1"' <<<"${triage_output}" >/dev/null
grep -F '"critical-user-journey"' <<<"${triage_output}" >/dev/null
grep -F '"multiple-regions"' <<<"${triage_output}" >/dev/null

roles_output="$(bash "${LAB}" run roles)"
grep -F '"coverage":"complete"' <<<"${roles_output}" >/dev/null
grep -F '"acknowledged":4' <<<"${roles_output}" >/dev/null
grep -F '"conflicts":0' <<<"${roles_output}" >/dev/null

mitigation_output="$(bash "${LAB}" run mitigation)"
grep -F '"selected":"disable-promotion-enrichment"' <<<"${mitigation_output}" >/dev/null
grep -F '"restart-shared-database"' <<<"${mitigation_output}" >/dev/null
grep -F '"rollback-release"' <<<"${mitigation_output}" >/dev/null

recovery_output="$(bash "${LAB}" run recovery)"
grep -F '"userRecovered":true' <<<"${recovery_output}" >/dev/null
grep -F '"queuesDraining":true' <<<"${recovery_output}" >/dev/null
grep -F '"dataIntegrity":"verified"' <<<"${recovery_output}" >/dev/null
grep -F '"observeMinutes":30' <<<"${recovery_output}" >/dev/null

communication_output="$(bash "${LAB}" run communication)"
grep -F '"requiredFields":"complete"' <<<"${communication_output}" >/dev/null
grep -F '"speculativeClaims":0' <<<"${communication_output}" >/dev/null
grep -F '"nextUpdateAt":"2026-08-04T02:35:00Z"' <<<"${communication_output}" >/dev/null

handoff_output="$(bash "${LAB}" run handoff)"
grep -F '"accepted":true' <<<"${handoff_output}" >/dev/null
grep -F '"gaps":0' <<<"${handoff_output}" >/dev/null
grep -F '"broadcast":true' <<<"${handoff_output}" >/dev/null

review_output="$(bash "${LAB}" run review)"
grep -F '"blameTerms":0' <<<"${review_output}" >/dev/null
grep -F '"causalLinks":5' <<<"${review_output}" >/dev/null
grep -F '"actionableItems":4' <<<"${review_output}" >/dev/null

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

printf 'verification=passed lesson=LES-0033 cases=%s assertions=23 refusals=unexpected-child,symlink-child cleanup=passed final_state=absent runtime=deterministic-model-only\n' "${#CASES[@]}"
