#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0076-virtualization-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" capability | grep -q '^capability=observed '
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=49'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 49 ]]
printf '%s\n' "$results" | grep -q '^case=baseline boundary=admissible-within-model'
printf '%s\n' "$results" | grep -q '^case=dev-kvm-denied boundary=kvm-device-access'
printf '%s\n' "$results" | grep -q '^case=qcow2-backing-file-missing boundary=backing-chain'
printf '%s\n' "$results" | grep -q '^case=cloud-init-instance-id-reused boundary=datasource-identity'
printf '%s\n' "$results" | grep -q '^case=running-means-ready boundary=boot-observability'
printf '%s\n' "$results" | grep -q '^case=destination-cpu-machine-incompatible boundary=migration-compatibility'
printf '%s\n' "$results" | grep -q '^case=failed-host-can-still-write boundary=ha-fencing'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=49 refusal=true cleanup=true vm_actions=none\n'
