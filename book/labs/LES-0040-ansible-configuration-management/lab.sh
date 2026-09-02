#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FIXTURE_SOURCE="${SCRIPT_DIR}/fixtures"
GUARD="${SCRIPT_DIR}/guard.py"
LESSON_UID="$(id -u)"
CONTROLLER_ROOT="/tmp/reliability-atlas-les0040-controller-${LESSON_UID}"
MANAGED_ROOT="/tmp/reliability-atlas-les0040-managed-${LESSON_UID}"
SENTINEL=".les0040-sentinel"

die() {
  printf 'lab=fail reason=%s\n' "$*" >&2
  exit 1
}

require_normal_user() {
  [[ "${LESSON_UID}" =~ ^[0-9]+$ ]] || die "numeric UID required"
  (( LESSON_UID > 0 )) || die "run as a normal user; root is refused"
}

doctor() {
  require_normal_user
  [[ -r /etc/os-release ]] || die "/etc/os-release is unavailable"
  grep -Eq '^ID="?ubuntu"?$' /etc/os-release || die "Ubuntu is required"
  grep -Eq '^VERSION_ID="?24\.04([^0-9].*)?"?$' /etc/os-release ||
    die "Ubuntu 24.04 is required"
  local command_name
  for command_name in bash python3 ansible-playbook ansible-inventory ansible-config cp mkdir chmod rm grep id date sed stat cat; do
    command -v "${command_name}" >/dev/null 2>&1 ||
      die "missing required command: ${command_name}"
  done
  python3 -c 'import pathlib,sys; p=pathlib.Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"), str(p), "exec")' "${GUARD}"
  python3 "${GUARD}" static "${FIXTURE_SOURCE}"
  printf 'doctor=pass uid=%s os=ubuntu-24.04\n' "${LESSON_UID}"
  ansible-playbook --version | sed -n '1,5p'
}

require_ready() {
  doctor >/dev/null
  python3 "${GUARD}" controller "${CONTROLLER_ROOT}" >/dev/null
  python3 "${GUARD}" managed-known "${MANAGED_ROOT}" >/dev/null
}

setup() {
  doctor
  if [[ -e "${CONTROLLER_ROOT}" || -L "${CONTROLLER_ROOT}" ||
        -e "${MANAGED_ROOT}" || -L "${MANAGED_ROOT}" ]]; then
    [[ -d "${CONTROLLER_ROOT}" && ! -L "${CONTROLLER_ROOT}" ]] ||
      die "controller root is incomplete or unsafe"
    [[ -d "${MANAGED_ROOT}" && ! -L "${MANAGED_ROOT}" ]] ||
      die "managed root is incomplete or unsafe"
    python3 "${GUARD}" controller "${CONTROLLER_ROOT}"
    python3 "${GUARD}" managed-known "${MANAGED_ROOT}"
    printf 'setup=pass state=existing\n'
    return
  fi

  mkdir -m 0700 -- "${CONTROLLER_ROOT}" "${MANAGED_ROOT}"
  mkdir -m 0700 -- "${CONTROLLER_ROOT}/fixtures"
  cp -a -- "${FIXTURE_SOURCE}/." "${CONTROLLER_ROOT}/fixtures/"
  printf 'les0040:%s\n' "${LESSON_UID}" >"${CONTROLLER_ROOT}/${SENTINEL}"
  printf 'les0040:%s\n' "${LESSON_UID}" >"${MANAGED_ROOT}/${SENTINEL}"
  chmod 0600 -- "${CONTROLLER_ROOT}/${SENTINEL}" "${MANAGED_ROOT}/${SENTINEL}"
  python3 "${GUARD}" controller "${CONTROLLER_ROOT}"
  python3 "${GUARD}" empty "${MANAGED_ROOT}"
  printf 'setup=pass state=created\n'
}

status() {
  require_ready
  printf 'controller=%s managed=%s uid=%s\n' "${CONTROLLER_ROOT}" "${MANAGED_ROOT}" "${LESSON_UID}"
  python3 "${GUARD}" managed-known "${MANAGED_ROOT}"
}

ansible_env() {
  export ANSIBLE_CONFIG="${CONTROLLER_ROOT}/fixtures/ansible.cfg"
  export ANSIBLE_NOCOLOR=1
  export PYTHONUNBUFFERED=1
}

run_play() {
  local output_name="$1"
  shift
  require_ready
  ansible_env
  local output_path="${CONTROLLER_ROOT}/${output_name}"
  local rc
  set +e
  (
    cd -- "${CONTROLLER_ROOT}/fixtures"
    ansible-playbook -i inventory.ini playbook.yml -e "lab_root=${MANAGED_ROOT}" -e "lesson_uid=${LESSON_UID}" "$@"
  ) >"${output_path}" 2>&1
  rc=$?
  set -e
  cat -- "${output_path}"
  (( rc == 0 )) || die "ansible-playbook failed rc=${rc} output=${output_path}"
}

inventory() {
  require_ready
  ansible_env
  local output="${CONTROLLER_ROOT}/inventory.out"
  (
    cd -- "${CONTROLLER_ROOT}/fixtures"
    ansible-inventory -i inventory.ini --list
  ) >"${output}"
  python3 "${GUARD}" inventory "${output}"
  (
    cd -- "${CONTROLLER_ROOT}/fixtures"
    ansible-inventory -i inventory.ini --graph
    ansible-inventory -i inventory.ini --host les0040-local
  )
}

preflight() {
  require_ready
  ansible_env
  local output="${CONTROLLER_ROOT}/preflight.out"
  (
    cd -- "${CONTROLLER_ROOT}/fixtures"
    ansible-playbook -i inventory.ini playbook.yml --syntax-check
    ansible-playbook -i inventory.ini playbook.yml --list-hosts
    ansible-playbook -i inventory.ini playbook.yml --list-tasks
  ) >"${output}" 2>&1
  cat -- "${output}"
  grep -q 'les0040-local' "${output}" || die "preflight host is absent"
  grep -q 'managed_service' "${output}" || die "role tasks are absent"
  printf 'preflight=pass\n'
}

check_initial() {
  require_ready
  python3 "${GUARD}" empty "${MANAGED_ROOT}"
  run_play check-initial.out --check --diff
  python3 "${GUARD}" recap "${CONTROLLER_ROOT}/check-initial.out" 3 3
  python3 "${GUARD}" empty "${MANAGED_ROOT}"
  printf 'check_initial=pass mutation=false\n'
}

apply_initial() {
  require_ready
  python3 "${GUARD}" empty "${MANAGED_ROOT}"
  run_play apply-initial.out
  python3 "${GUARD}" recap "${CONTROLLER_ROOT}/apply-initial.out" 3 3
  grep -q 'Write deterministic activation evidence' "${CONTROLLER_ROOT}/apply-initial.out" ||
    die "initial handler evidence is absent"
  python3 "${GUARD}" state "${MANAGED_ROOT}"
  printf 'apply_initial=pass\n'
}

verify_state() {
  require_ready
  python3 "${GUARD}" state "${MANAGED_ROOT}"
}

apply_steady() {
  require_ready
  python3 "${GUARD}" state "${MANAGED_ROOT}"
  run_play apply-steady.out
  python3 "${GUARD}" recap "${CONTROLLER_ROOT}/apply-steady.out" 0 0
  python3 "${GUARD}" state "${MANAGED_ROOT}"
  printf 'steady=pass changed=0\n'
}

inject_drift() {
  require_ready
  python3 "${GUARD}" state "${MANAGED_ROOT}"
  printf 'name=drifted-by-les0040\nport=1\n' >"${MANAGED_ROOT}/service.conf"
  chmod 0600 -- "${MANAGED_ROOT}/service.conf"
  python3 "${GUARD}" drift "${MANAGED_ROOT}"
  printf 'drift_injected=true\n'
}

check_drift() {
  require_ready
  python3 "${GUARD}" drift "${MANAGED_ROOT}"
  run_play check-drift.out --check --diff
  python3 "${GUARD}" recap "${CONTROLLER_ROOT}/check-drift.out" 1 1
  grep -q 'Write deterministic activation evidence' "${CONTROLLER_ROOT}/check-drift.out" ||
    die "predicted handler evidence is absent"
  python3 "${GUARD}" drift "${MANAGED_ROOT}"
  printf 'check_drift=pass mutation=false\n'
}

repair() {
  require_ready
  python3 "${GUARD}" drift "${MANAGED_ROOT}"
  run_play repair.out
  python3 "${GUARD}" recap "${CONTROLLER_ROOT}/repair.out" 1 1
  grep -q 'Write deterministic activation evidence' "${CONTROLLER_ROOT}/repair.out" ||
    die "repair handler evidence is absent"
  python3 "${GUARD}" state "${MANAGED_ROOT}"
  printf 'repair=pass\n'
}

inject_unknown() {
  require_ready
  printf 'cleanup-refusal-test\n' >"${CONTROLLER_ROOT}/unexpected.entry"
  chmod 0600 -- "${CONTROLLER_ROOT}/unexpected.entry"
  printf 'unexpected_entry=true\n'
}

clear_unknown() {
  local path="${CONTROLLER_ROOT}/unexpected.entry"
  [[ -f "${path}" && ! -L "${path}" ]] || die "known test entry is absent or unsafe"
  [[ "$(stat -c '%u' -- "${path}")" == "${LESSON_UID}" ]] || die "test entry owner differs"
  [[ "$(cat -- "${path}")" == "cleanup-refusal-test" ]] || die "test entry content differs"
  rm -f -- "${path}"
  python3 "${GUARD}" controller "${CONTROLLER_ROOT}" >/dev/null
  printf 'unexpected_entry=false\n'
}

cleanup() {
  require_normal_user
  python3 "${GUARD}" cleanup "${CONTROLLER_ROOT}" "${MANAGED_ROOT}"
  rm -rf -- "${CONTROLLER_ROOT}" "${MANAGED_ROOT}"
  python3 "${GUARD}" absent "${CONTROLLER_ROOT}" "${MANAGED_ROOT}"
  printf 'cleanup=pass\n'
}

usage() {
  printf '%s\n' 'usage: bash lab.sh {doctor|setup|status|inventory|preflight|check-initial|apply-initial|verify-state|apply-steady|inject-drift|check-drift|repair|inject-unknown|clear-unknown|cleanup}'
}

case "${1:-}" in
  doctor) doctor ;;
  setup) setup ;;
  status) status ;;
  inventory) inventory ;;
  preflight) preflight ;;
  check-initial) check_initial ;;
  apply-initial) apply_initial ;;
  verify-state) verify_state ;;
  apply-steady) apply_steady ;;
  inject-drift) inject_drift ;;
  check-drift) check_drift ;;
  repair) repair ;;
  inject-unknown) inject_unknown ;;
  clear-unknown) clear_unknown ;;
  cleanup) cleanup ;;
  *) usage; exit 2 ;;
esac
