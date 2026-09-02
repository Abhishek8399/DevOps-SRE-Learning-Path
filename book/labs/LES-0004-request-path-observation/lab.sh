#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

fail() { printf 'lab_error=%s\n' "$1" >&2; exit 1; }

check_environment() {
  [[ "$(id -u)" -ne 0 ]] || fail "run as a normal non-root user"
  [[ -r /etc/os-release ]] || fail "/etc/os-release is unavailable"
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Ubuntu is required for the supported walkthrough"
  for tool in getent ip ss; do
    command -v "$tool" >/dev/null 2>&1 || fail "required command is missing: $tool"
  done
  printf 'environment=ready\nos=%s\nprivilege=non-root\nnetwork_request=none\nmutation=none\n' "${PRETTY_NAME:-Ubuntu}"
}

observe() {
  check_environment >/dev/null
  printf '%s\n' '--- namespace identity ---'
  printf 'network_namespace=%s\n' "$(readlink /proc/self/ns/net)"
  ip -br address
  printf '%s\n' '--- localhost resolution ---'
  getent ahosts localhost
  printf '%s\n' '--- loopback route decision ---'
  ip route get 127.0.0.1
  printf '%s\n' '--- main route view ---'
  ip route
  printf '%s\n' '--- resolver configuration ---'
  sed -n '1,40p' /etc/resolv.conf
  printf '%s\n' '--- listening TCP sockets ---'
  ss -lnt
  printf 'observation=complete\nnetwork_request=none\nmutation=none\n'
}

case "${1:-}" in
  check) check_environment ;;
  observe) observe ;;
  cleanup) printf 'cleanup=not-required\nmutation=none\ncleanup_proven=true\n' ;;
  *) fail "usage: bash lab.sh check|observe|cleanup" ;;
esac
