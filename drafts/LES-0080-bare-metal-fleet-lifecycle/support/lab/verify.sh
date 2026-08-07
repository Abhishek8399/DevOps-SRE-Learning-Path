#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0080-bare-metal-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" inventory-tools | grep -q '^inventory=observed .* hardware_runtime_calls=none$'

if env REDFISH_ENDPOINT=https://192.0.2.10 "$LAB" doctor >/dev/null 2>&1; then
  exit 1
fi

"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=63'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 63 ]]

for expected in \
  'baseline boundary=operable-within-model' \
  'bmc-certificate-or-trust-invalid boundary=bmc-trust' \
  'requested-and-observed-power-diverged boundary=power-reconciliation' \
  'architecture-or-bootfile-mismatch boundary=network-bootstrap' \
  'ipxe-chainload-loop-or-script-failed boundary=ipxe-chain' \
  'image-digest-or-signature-invalid boundary=image-integrity' \
  'hardware-inspection-stale boundary=inspection-freshness' \
  'desired-and-current-raid-diverged boundary=raid-realization' \
  'switch-port-vlan-bond-or-mtu-wrong boundary=switch-edge' \
  'image-write-incomplete-or-wrong-device boundary=disk-write' \
  'cloud-init-or-first-boot-failed boundary=first-boot' \
  'original-user-operation-failed boundary=user-transaction' \
  'uncorrected-or-fatal-hardware-error boundary=fatal-errors' \
  'firmware-or-controller-canary-failed boundary=upgrade-canary' \
  'sanitization-verification-or-validation-failed boundary=sanitization-evidence'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done

"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=63 refusal=true cleanup=true hardware_runtime_calls=none\n'
