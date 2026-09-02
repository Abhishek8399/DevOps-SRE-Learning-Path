#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
MODEL="${SCRIPT_DIR}/fixtures/capacity_model.py"
SOURCE_SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_PARENT="/tmp"
STATE_DIR="/tmp/reliability-atlas-les0035-${CURRENT_UID}"

refuse_root() {
  [[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
}

require_tools() {
  local tool
  for tool in bash python3 id mktemp mv cp rm readlink stat find wc; do
    command -v "${tool}" >/dev/null 2>&1 || { printf 'refused=true reason=missing-tool tool=%s\n' "${tool}" >&2; exit 69; }
  done
}

validate_inputs() {
  [[ -f "${MODEL}" && ! -L "${MODEL}" ]] || { printf 'refused=true reason=model-invalid\n' >&2; exit 78; }
  [[ -f "${SOURCE_SCENARIO}" && ! -L "${SOURCE_SCENARIO}" ]] || { printf 'refused=true reason=scenario-invalid\n' >&2; exit 78; }
  python3 "${MODEL}" validate-scenario "${SOURCE_SCENARIO}" >/dev/null
}

validate_state() {
  [[ "${STATE_DIR}" == "/tmp/reliability-atlas-les0035-${CURRENT_UID}" ]] || { printf 'refused=true reason=state-path-invalid\n' >&2; exit 78; }
  [[ "$(readlink -f -- "${STATE_PARENT}")" == "/tmp" ]] || { printf 'refused=true reason=parent-invalid\n' >&2; exit 78; }
  python3 "${MODEL}" validate-state "${STATE_DIR}" --uid "${CURRENT_UID}" >/dev/null
}

doctor() {
  require_tools
  validate_inputs
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_state
    printf 'ready=true state=owned-existing path=%s\n' "${STATE_DIR}"
  else
    printf 'ready=true state=absent path=%s\n' "${STATE_DIR}"
  fi
}

setup() {
  require_tools
  validate_inputs
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_state
    printf 'state=ready existing=true path=%s\n' "${STATE_DIR}"
    return 0
  fi
  local candidate
  candidate="$(mktemp -d "${STATE_PARENT}/reliability-atlas-les0035-${CURRENT_UID}.candidate.XXXXXX")"
  cleanup_candidate() {
    if [[ -n "${candidate:-}" && -d "${candidate}" && ! -L "${candidate}" ]]; then
      local resolved
      resolved="$(readlink -f -- "${candidate}")"
      if [[ "${resolved}" == "/tmp/reliability-atlas-les0035-${CURRENT_UID}.candidate."* && "$(stat -c '%u' -- "${resolved}")" == "${CURRENT_UID}" ]]; then
        rm -rf -- "${resolved}"
      fi
    fi
  }
  trap cleanup_candidate EXIT
  printf 'LES-0035:%s\n' "${CURRENT_UID}" >"${candidate}/SENTINEL"
  cp -- "${SOURCE_SCENARIO}" "${candidate}/scenario.json"
  python3 -c 'import json,sys; value={"schemaVersion":1,"lessonId":"LES-0035","uid":int(sys.argv[1]),"statePath":sys.argv[2],"caseId":"capacity-knee-v1"}; handle=open(sys.argv[3],"w",encoding="utf-8"); json.dump(value,handle,indent=2); handle.write("\n"); handle.close()' "${CURRENT_UID}" "${STATE_DIR}" "${candidate}/manifest.json"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'refused=true reason=state-created-concurrently\n' >&2; exit 75; }
  mv -- "${candidate}" "${STATE_DIR}"
  candidate=""
  trap - EXIT
  validate_state
  printf 'state=ready existing=false path=%s\n' "${STATE_DIR}"
}

status() {
  require_tools
  validate_inputs
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'state=absent path=%s\n' "${STATE_DIR}"
    return 0
  fi
  validate_state
  local files
  files="$(find "${STATE_DIR}" -mindepth 1 -maxdepth 1 -type f -printf '.' | wc -c)"
  printf 'state=ready path=%s files=%s owner_uid=%s\n' "${STATE_DIR}" "${files}" "${CURRENT_UID}"
}

run_case() {
  local case_name="${1:-}"
  [[ -n "${case_name}" ]] || { printf 'usage: bash lab.sh run <baseline|curve|queue|forecast|autoscale|workload|overload>\n' >&2; exit 64; }
  require_tools
  validate_inputs
  [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]] || { printf 'refused=true reason=state-absent hint=run-setup\n' >&2; exit 66; }
  validate_state
  rm -f -- "${STATE_DIR}/result.json"
  python3 "${MODEL}" run "${case_name}" "${STATE_DIR}/scenario.json" --result "${STATE_DIR}/result.json"
  validate_state
}

cleanup() {
  require_tools
  validate_inputs
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'state=absent removed=false path=%s\n' "${STATE_DIR}"
    return 0
  fi
  validate_state
  local resolved
  resolved="$(readlink -f -- "${STATE_DIR}")"
  [[ "${resolved}" == "/tmp/reliability-atlas-les0035-${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-path-invalid\n' >&2; exit 78; }
  [[ "$(stat -c '%u' -- "${resolved}")" == "${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-owner-invalid\n' >&2; exit 78; }
  rm -rf -- "${resolved}"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'failed=true reason=cleanup-incomplete\n' >&2; exit 74; }
  printf 'state=absent removed=true path=%s\n' "${STATE_DIR}"
}

usage() {
  printf 'usage: bash lab.sh <doctor|setup|status|run CASE|verify|cleanup>\n' >&2
}

main() {
  refuse_root
  case "${1:-}" in
    doctor) doctor ;;
    setup) setup ;;
    status) status ;;
    run) run_case "${2:-}" ;;
    verify) exec bash "${SCRIPT_DIR}/verify.sh" ;;
    cleanup) cleanup ;;
    *) usage; exit 64 ;;
  esac
}

main "$@"
