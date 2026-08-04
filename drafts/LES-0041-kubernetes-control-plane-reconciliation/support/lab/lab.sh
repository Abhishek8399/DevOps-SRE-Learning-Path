#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MODEL="${SCRIPT_DIR}/model.py"
FIXTURE="${SCRIPT_DIR}/fixtures/desired.json"
UID_VALUE="$(id -u)"
ROOT="/tmp/reliability-atlas-les0041-model-${UID_VALUE}"
SENTINEL=".les0041-sentinel"

die() {
  printf 'lab=fail reason=%s\n' "$*" >&2
  exit 1
}

doctor() {
  (( UID_VALUE > 0 )) || die "run as a normal user; root is refused"
  [[ -r /etc/os-release ]] || die "/etc/os-release unavailable"
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release || die "Ubuntu is required"
  grep -Eq '^VERSION_ID="?24\.04([^0-9].*)?"?$' /etc/os-release ||
    die "Ubuntu 24.04 is required"
  local name
  for name in bash python3 cp mkdir chmod rm grep id stat cat sed; do
    command -v "${name}" >/dev/null 2>&1 || die "missing command: ${name}"
  done
  python3 -c 'import pathlib,sys; p=pathlib.Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"), str(p), "exec")' "${MODEL}"
  python3 -c 'import json,pathlib,sys; json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))' "${FIXTURE}"
  printf 'doctor=pass uid=%s runtime=kubernetes-model-only cluster_evidence=false\n' "${UID_VALUE}"
}

require_state() {
  doctor >/dev/null
  [[ -d "${ROOT}" && ! -L "${ROOT}" ]] || die "model root absent or unsafe"
  python3 "${MODEL}" verify "${ROOT}" >/dev/null
}

setup() {
  doctor
  if [[ -e "${ROOT}" || -L "${ROOT}" ]]; then
    require_state
    printf 'setup=pass state=existing runtime=kubernetes-model-only\n'
    return
  fi
  mkdir -m 0700 -- "${ROOT}"
  cp -- "${FIXTURE}" "${ROOT}/desired.json"
  chmod 0600 -- "${ROOT}/desired.json"
  printf 'les0041:%s\n' "${UID_VALUE}" >"${ROOT}/${SENTINEL}"
  chmod 0600 -- "${ROOT}/${SENTINEL}"
  python3 "${MODEL}" initialize "${ROOT}" --phase EMPTY
  printf 'setup=pass state=created runtime=kubernetes-model-only\n'
}

run_transition() {
  local command="$1"
  local phase="$2"
  require_state
  python3 "${MODEL}" "${command}" "${ROOT}" --phase "${phase}"
}

status() {
  require_state
  python3 "${MODEL}" inspect "${ROOT}"
}

submit() { run_transition submit SUBMITTED; }
reconcile() { run_transition reconcile RECONCILED; }
schedule() { run_transition schedule SCHEDULED; }
kubelet() { run_transition kubelet READY; }
update_model() { run_transition update UPDATED; }
inject_controller_stall() { run_transition inject-stall STALLED; }

diagnose() {
  require_state
  python3 "${MODEL}" diagnose "${ROOT}" --phase STALLED
}

recover() { run_transition recover RECOVERED; }

verify_state() {
  require_state
  python3 "${MODEL}" verify "${ROOT}" --phase RECOVERED
}

inject_unknown() {
  require_state
  printf 'cleanup-refusal-test\n' >"${ROOT}/unexpected.entry"
  chmod 0600 -- "${ROOT}/unexpected.entry"
  printf 'unexpected_entry=true\n'
}

clear_unknown() {
  local path="${ROOT}/unexpected.entry"
  [[ -f "${path}" && ! -L "${path}" ]] || die "known test entry absent or unsafe"
  [[ "$(stat -c '%u' -- "${path}")" == "${UID_VALUE}" ]] || die "test owner differs"
  [[ "$(cat -- "${path}")" == "cleanup-refusal-test" ]] || die "test content differs"
  rm -f -- "${path}"
  require_state
  printf 'unexpected_entry=false\n'
}

cleanup() {
  (( UID_VALUE > 0 )) || die "root is refused"
  require_state
  python3 "${MODEL}" verify "${ROOT}" >/dev/null
  rm -rf -- "${ROOT}"
  [[ ! -e "${ROOT}" && ! -L "${ROOT}" ]] || die "model root remains"
  printf 'cleanup=pass state_absent=true\n'
}

usage() {
  printf '%s\n' 'usage: bash lab.sh {doctor|setup|status|submit|reconcile|schedule|kubelet|update|inject-controller-stall|diagnose|recover|verify-state|inject-unknown|clear-unknown|cleanup}'
}

case "${1:-}" in
  doctor) doctor ;;
  setup) setup ;;
  status) status ;;
  submit) submit ;;
  reconcile) reconcile ;;
  schedule) schedule ;;
  kubelet) kubelet ;;
  update) update_model ;;
  inject-controller-stall) inject_controller_stall ;;
  diagnose) diagnose ;;
  recover) recover ;;
  verify-state) verify_state ;;
  inject-unknown) inject_unknown ;;
  clear-unknown) clear_unknown ;;
  cleanup) cleanup ;;
  *) usage; exit 2 ;;
esac
