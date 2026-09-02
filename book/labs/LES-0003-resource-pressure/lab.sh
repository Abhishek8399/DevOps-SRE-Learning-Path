#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

fail() { printf 'lab_error=%s\n' "$1" >&2; exit 1; }

check_environment() {
  [[ "$(id -u)" -ne 0 ]] || fail "run as a normal non-root user"
  [[ -r /etc/os-release ]] || fail "/etc/os-release is unavailable"
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu is required for the supported walkthrough"
  for tool in awk cat free id nproc ps uname uptime vmstat; do
    command -v "$tool" >/dev/null 2>&1 || fail "required command is missing: $tool"
  done
  printf 'environment=ready\nos=%s\nkernel=%s\nprivilege=non-root\nmutation=none\n' \
    "${PRETTY_NAME:-Ubuntu}" "$(uname -r)"
}

observe() {
  check_environment >/dev/null
  printf '%s\n' '--- cpu-and-load ---'
  nproc
  uptime
  printf '%s\n' '--- interval-sample ---'
  vmstat -y 1 3
  printf '%s\n' '--- memory ---'
  free -h
  printf '%s\n' '--- pressure ---'
  for resource in cpu memory io; do
    if [[ -r "/proc/pressure/$resource" ]]; then
      printf '[%s]\n' "$resource"
      cat "/proc/pressure/$resource"
    else
      printf '[%s] unavailable\n' "$resource"
    fi
  done
  printf '%s\n' '--- process-snapshot ---'
  ps -eo pid,ppid,stat,ni,psr,pcpu,pmem,rss,comm --sort=-rss | awk 'NR <= 11'
  printf 'observation=complete\nmutation=none\n'
}

case "${1:-}" in
  check) check_environment ;;
  observe) observe ;;
  cleanup) printf 'cleanup=not-required\nmutation=none\ncleanup_proven=true\n' ;;
  *) fail "usage: bash lab.sh check|observe|cleanup" ;;
esac
