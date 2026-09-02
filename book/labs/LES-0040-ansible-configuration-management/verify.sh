#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
UID_VALUE="$(id -u)"
CONTROLLER_ROOT="/tmp/reliability-atlas-les0040-controller-${UID_VALUE}"
MANAGED_ROOT="/tmp/reliability-atlas-les0040-managed-${UID_VALUE}"

fail() {
  printf 'verification=fail reason=%s\n' "$*" >&2
  exit 1
}

if [[ -e "${CONTROLLER_ROOT}" || -L "${CONTROLLER_ROOT}" ||
      -e "${MANAGED_ROOT}" || -L "${MANAGED_ROOT}" ]]; then
  bash "${LAB}" cleanup
fi

bash "${LAB}" doctor
bash "${LAB}" setup
bash "${LAB}" setup
bash "${LAB}" status
bash "${LAB}" inventory
bash "${LAB}" preflight
bash "${LAB}" check-initial
bash "${LAB}" apply-initial
bash "${LAB}" verify-state
bash "${LAB}" apply-steady
bash "${LAB}" inject-drift
bash "${LAB}" check-drift
bash "${LAB}" repair
bash "${LAB}" verify-state
bash "${LAB}" apply-steady
bash "${LAB}" inject-unknown

if bash "${LAB}" cleanup; then
  fail "cleanup accepted an unexpected entry"
else
  printf 'cleanup_refusal=pass\n'
fi

bash "${LAB}" clear-unknown
bash "${LAB}" cleanup

[[ ! -e "${CONTROLLER_ROOT}" && ! -L "${CONTROLLER_ROOT}" ]] ||
  fail "controller root remains"
[[ ! -e "${MANAGED_ROOT}" && ! -L "${MANAGED_ROOT}" ]] ||
  fail "managed root remains"

printf 'verification=pass state_absent=true\n'
