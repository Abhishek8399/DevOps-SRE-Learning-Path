#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
MODEL="${SCRIPT_DIR}/fixtures/sre_operating_model.py"
SOURCE_SCENARIO="${SCRIPT_DIR}/fixtures/scenario.json"
CURRENT_UID="$(id -u)"
STATE_PARENT="/tmp"
STATE_NAME="reliability-atlas-les0031-${CURRENT_UID}"
STATE_DIR="${STATE_PARENT}/${STATE_NAME}"

refuse_root() {
  if [[ "${CURRENT_UID}" == "0" ]]; then
    printf 'refused=true reason=root-not-required\n' >&2
    exit 77
  fi
}

require_tools() {
  local tool
  for tool in bash python3 id mktemp mv cp rm readlink stat find wc; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
      printf 'refused=true reason=missing-tool tool=%s\n' "${tool}" >&2
      exit 69
    fi
  done
}

validate_static_inputs() {
  [[ -f "${MODEL}" && ! -L "${MODEL}" ]] || { printf 'refused=true reason=model-invalid\n' >&2; exit 78; }
  [[ -f "${SOURCE_SCENARIO}" && ! -L "${SOURCE_SCENARIO}" ]] || { printf 'refused=true reason=scenario-invalid\n' >&2; exit 78; }
  python3 "${MODEL}" validate-scenario "${SOURCE_SCENARIO}" >/dev/null
}

validate_state() {
  [[ "${STATE_DIR}" == "/tmp/reliability-atlas-les0031-${CURRENT_UID}" ]] || { printf 'refused=true reason=state-name-invalid\n' >&2; exit 78; }
  [[ "$(readlink -f -- "${STATE_PARENT}")" == "/tmp" ]] || { printf 'refused=true reason=parent-realpath-invalid\n' >&2; exit 78; }
  python3 "${MODEL}" validate-state "${STATE_DIR}" --uid "${CURRENT_UID}" >/dev/null
}

doctor() {
  require_tools
  validate_static_inputs
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_state
    printf 'ready=true uid=%s state=owned-existing state_path=%s runtime=deterministic-model-only\n' "${CURRENT_UID}" "${STATE_DIR}"
  else
    printf 'ready=true uid=%s state=absent state_path=%s runtime=deterministic-model-only\n' "${CURRENT_UID}" "${STATE_DIR}"
  fi
}

setup() {
  require_tools
  validate_static_inputs
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_state
    printf 'state=ready existing=true path=%s\n' "${STATE_DIR}"
    return 0
  fi
  local candidate
  candidate="$(mktemp -d "${STATE_PARENT}/${STATE_NAME}.candidate.XXXXXX")"
  cleanup_candidate() {
    if [[ -n "${candidate:-}" && -d "${candidate}" && ! -L "${candidate}" ]]; then
      local resolved
      resolved="$(readlink -f -- "${candidate}")"
      if [[ "${resolved}" == "${STATE_PARENT}/${STATE_NAME}.candidate."* && "$(stat -c '%u' -- "${resolved}")" == "${CURRENT_UID}" ]]; then
        rm -rf -- "${resolved}"
      fi
    fi
  }
  trap cleanup_candidate EXIT
  printf 'LES-0031:%s\n' "${CURRENT_UID}" >"${candidate}/SENTINEL"
  cp -- "${SOURCE_SCENARIO}" "${candidate}/scenario.json"
  python3 -c 'import json,sys; path=sys.argv[3]; value={"schemaVersion":1,"lessonId":"LES-0031","uid":int(sys.argv[1]),"statePath":sys.argv[2],"caseId":"sre-operating-model-v1"}; handle=open(path,"w",encoding="utf-8"); json.dump(value,handle,indent=2); handle.write("\n"); handle.close()' "${CURRENT_UID}" "${STATE_DIR}" "${candidate}/manifest.json"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'refused=true reason=state-created-concurrently\n' >&2; exit 75; }
  mv -- "${candidate}" "${STATE_DIR}"
  candidate=""
  trap - EXIT
  validate_state
  printf 'state=ready existing=false path=%s\n' "${STATE_DIR}"
}

status() {
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'state=absent path=%s\n' "${STATE_DIR}"
    return 0
  fi
  validate_state
  local result_count
  result_count="$(find "${STATE_DIR}" -maxdepth 1 -type f -name 'result-*.json' -printf '.' | wc -c)"
  printf 'state=ready path=%s case=sre-operating-model-v1 results=%s runtime=deterministic-model-only\n' "${STATE_DIR}" "${result_count}"
}

run_case() {
  local case_name="${1:-}"
  [[ -n "${case_name}" ]] || { printf 'usage: bash lab.sh run <case>\n' >&2; exit 64; }
  validate_state
  python3 "${MODEL}" run "${case_name}" "${STATE_DIR}" --uid "${CURRENT_UID}"
}

cleanup() {
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'cleanup=passed state=absent path=%s\n' "${STATE_DIR}"
    return 0
  fi
  validate_state
  local resolved
  resolved="$(readlink -f -- "${STATE_DIR}")"
  [[ "${resolved}" == "/tmp/reliability-atlas-les0031-${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-realpath-invalid\n' >&2; exit 78; }
  [[ "$(stat -c '%u' -- "${resolved}")" == "${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-owner-invalid\n' >&2; exit 78; }
  rm -rf -- "${resolved}"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'cleanup=failed state=present\n' >&2; exit 1; }
  printf 'cleanup=passed state=absent path=%s\n' "${STATE_DIR}"
}

main() {
  refuse_root
  local action="${1:-}"
  case "${action}" in
    doctor) doctor ;;
    setup) setup ;;
    status) status ;;
    run) shift; run_case "${1:-}" ;;
    cleanup) cleanup ;;
    reset) cleanup; setup ;;
    *) printf 'usage: bash lab.sh doctor|setup|status|run <case>|cleanup|reset\n' >&2; exit 64 ;;
  esac
}

main "$@"
