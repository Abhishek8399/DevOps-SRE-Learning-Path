#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

fail() { printf 'lab_error=%s\n' "$1" >&2; exit 1; }

check_environment() {
  [[ "$(id -u)" -ne 0 ]] || fail "run as a normal non-root user"
  [[ -r /etc/os-release ]] || fail "/etc/os-release is unavailable"
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu is required for the supported walkthrough"
  for tool in df findmnt id stat; do
    command -v "$tool" >/dev/null 2>&1 || fail "required command is missing: $tool"
  done
  printf 'environment=ready\nos=%s\nprivilege=non-root\nmutation=none\n' "${PRETTY_NAME:-Ubuntu}"
}

observe() {
  local target="${1:-$PWD}"
  check_environment >/dev/null
  [[ -e "$target" || -L "$target" ]] || fail "target does not exist"
  printf '%s\n' '--- environment ---'
  . /etc/os-release
  printf 'os=%s\nkernel=%s\nuid=%s\n' "${PRETTY_NAME:-Ubuntu}" "$(uname -r)" "$(id -u)"
  printf '%s\n' '--- exact mount ---'
  findmnt -T "$target" -o TARGET,SOURCE,FSTYPE,OPTIONS,MAJ:MIN
  printf '%s\n' '--- block capacity ---'
  df -hT -- "$target"
  printf '%s\n' '--- inode capacity ---'
  df -i -- "$target"
  printf '%s\n' '--- target record ---'
  stat -c 'dev=%D inode=%i links=%h type=%F bytes=%s blocks512=%b owner=%u:%g mode=%a name=%n' -- "$target"
  printf 'observation=complete\nmutation=none\n'
}

case "${1:-}" in
  check) check_environment ;;
  observe) observe "${2:-$PWD}" ;;
  cleanup) printf 'cleanup=not-required\nmutation=none\ncleanup_proven=true\n' ;;
  *) fail "usage: bash lab.sh check|observe [existing-path]|cleanup" ;;
esac
