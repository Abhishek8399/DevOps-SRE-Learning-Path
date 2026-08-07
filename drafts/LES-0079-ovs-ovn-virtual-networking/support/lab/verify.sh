#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0079-ovs-ovn-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" inventory-tools | grep -q '^inventory=observed .* runtime_calls=none$'
if env OVS_RUNDIR=/tmp/forbidden "$LAB" doctor >/dev/null 2>&1; then exit 1; fi
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=58'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 58 ]]
for expected in \
  'baseline boundary=operable-within-model' \
  'northd-stalled boundary=northd-compilation' \
  'logical-port-bound-wrong-chassis boundary=binding-placement' \
  'controller-stale boundary=controller-convergence' \
  'table-priority-shadowed boundary=pipeline-selection' \
  'stale-address-set boundary=policy-membership' \
  'underlay-mtu-failed boundary=underlay-mtu' \
  'encapsulation-or-decapsulation-failed boundary=tunnel-transport' \
  'destination-vif-not-delivered boundary=destination-delivery' \
  'reverse-path-failed boundary=reverse-transport' \
  'packet-path-user-operation-failed boundary=user-transaction'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=58 refusal=true cleanup=true runtime_calls=none\n'
