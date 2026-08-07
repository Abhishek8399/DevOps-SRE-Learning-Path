#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0077-openstack-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" inventory-tools | grep -q '^inventory=observed .* service_calls=none$'
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=51'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 51 ]]
printf '%s\n' "$results" | grep -q '^case=baseline boundary=operable-within-model'
printf '%s\n' "$results" | grep -q '^case=token-wrong-project boundary=token-scope'
printf '%s\n' "$results" | grep -q '^case=instance-cell-mapping-missing boundary=cell-mapping'
printf '%s\n' "$results" | grep -q '^case=placement-inventory-stale boundary=placement-inventory'
printf '%s\n' "$results" | grep -q '^case=active-image-bytes-missing boundary=image-bytes'
printf '%s\n' "$results" | grep -q '^case=port-binding-failed boundary=port-binding'
printf '%s\n' "$results" | grep -q '^case=bound-port-no-dataplane boundary=dataplane-realization'
printf '%s\n' "$results" | grep -q '^case=cinder-backend-down boundary=volume-backend'
printf '%s\n' "$results" | grep -q '^case=active-state-power-state-conflict boundary=server-state'
printf '%s\n' "$results" | grep -q '^case=guest-up-application-down boundary=application-readiness'
printf '%s\n' "$results" | grep -q '^case=database-or-rabbitmq-single-point boundary=database-messaging-ha'
printf '%s\n' "$results" | grep -q '^case=failed-compute-not-fenced boundary=fencing'
printf '%s\n' "$results" | grep -q '^case=mixed-version-rpc-incompatible boundary=upgrade-compatibility'
printf '%s\n' "$results" | grep -q '^case=online-data-migrations-incomplete boundary=data-migrations'
printf '%s\n' "$results" | grep -q '^case=request-id-not-correlated boundary=observability-correlation'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=51 refusal=true cleanup=true service_calls=none\n'
