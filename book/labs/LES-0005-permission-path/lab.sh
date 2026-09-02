#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

fail() { printf 'lab_error=%s\n' "$1" >&2; exit 1; }

check_environment() {
  [[ "$(id -u)" -ne 0 ]] || fail "run as a normal non-root user"
  [[ -r /etc/os-release ]] || fail "/etc/os-release is unavailable"
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu is required for the supported walkthrough"
  for tool in findmnt id namei readlink stat; do
    command -v "$tool" >/dev/null 2>&1 || fail "required command is missing: $tool"
  done
  printf 'environment=ready\nos=%s\nprivilege=non-root\nmutation=none\n' "${PRETTY_NAME:-Ubuntu}"
}

observe() {
  local target="${1:-$PWD}"
  check_environment >/dev/null
  [[ -e "$target" || -L "$target" ]] || fail "target does not exist"
  printf '%s\n' '--- identity ---'
  id
  grep -E '^(Uid|Gid|Groups|CapInh|CapPrm|CapEff|CapBnd|NoNewPrivs):' /proc/self/status
  printf '%s\n' '--- lexical-and-resolved-target ---'
  printf 'lexical=%s\n' "$target"
  readlink -f -- "$target"
  printf '%s\n' '--- path-components ---'
  namei -l -- "$target"
  printf '%s\n' '--- target-metadata ---'
  stat -c 'type=%F mode=%A octal=%a owner=%U:%G uid=%u gid=%g inode=%i links=%h name=%n' -- "$target"
  printf '%s\n' '--- mount-boundary ---'
  findmnt -T "$target" -o TARGET,SOURCE,FSTYPE,OPTIONS
  if command -v getfacl >/dev/null 2>&1; then
    printf '%s\n' '--- access-acl ---'
    getfacl -cp -- "$target"
  else
    printf '%s\n' '--- access-acl ---'
    printf 'getfacl=unavailable package=acl\n'
  fi
  printf 'observation=complete\nmutation=none\n'
}

case "${1:-}" in
  check) check_environment ;;
  observe) observe "${2:-$PWD}" ;;
  cleanup) printf 'cleanup=not-required\nmutation=none\ncleanup_proven=true\n' ;;
  *) fail "usage: bash lab.sh check|observe [existing-path]|cleanup" ;;
esac
