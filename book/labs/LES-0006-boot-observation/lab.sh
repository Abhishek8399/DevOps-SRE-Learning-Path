#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

fail() { printf 'lab_error=%s\n' "$1" >&2; exit 1; }

check_environment() {
  [[ "$(id -u)" -ne 0 ]] || fail "run as a normal non-root user"
  [[ -r /etc/os-release ]] || fail "/etc/os-release is unavailable"
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu is required for the supported walkthrough"
  for tool in cat id ps uname uptime; do
    command -v "$tool" >/dev/null 2>&1 || fail "required command is missing: $tool"
  done
  printf 'environment=ready\nos=%s\nprivilege=non-root\nmutation=none\n' "${PRETTY_NAME:-Ubuntu}"
}

observe() {
  check_environment >/dev/null
  printf '%s\n' '--- system identity ---'
  . /etc/os-release
  printf 'os=%s\nkernel=%s\nuid=%s\n' "${PRETTY_NAME:-Ubuntu}" "$(uname -r)" "$(id -u)"
  printf '%s\n' '--- pid 1 boundary ---'
  ps -p 1 -o pid=,ppid=,comm=,args=
  printf 'pid1_comm=%s\n' "$(cat /proc/1/comm)"
  printf '%s\n' '--- boot identity and elapsed time ---'
  if [[ -r /proc/sys/kernel/random/boot_id ]]; then
    printf 'boot_id=%s\n' "$(cat /proc/sys/kernel/random/boot_id)"
  else
    printf 'boot_id=unavailable\n'
  fi
  uptime
  if [[ "$(cat /proc/1/comm)" == "systemd" ]] && command -v systemd-analyze >/dev/null 2>&1; then
    printf '%s\n' '--- systemd phase timing ---'
    if ! systemd-analyze time; then
      printf 'systemd_analysis=unavailable\n'
    fi
  else
    printf 'systemd_analysis=not-applicable pid1-is-not-systemd\n'
  fi
  printf 'observation=complete\nmutation=none\n'
}

case "${1:-}" in
  check) check_environment ;;
  observe) observe ;;
  cleanup) printf 'cleanup=not-required\nmutation=none\ncleanup_proven=true\n' ;;
  *) fail "usage: bash lab.sh check|observe|cleanup" ;;
esac
