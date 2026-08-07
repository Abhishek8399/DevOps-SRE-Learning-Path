#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0075-chaos-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=47'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 47 ]]
printf '%s\n' "$results" | grep -q '^case=baseline boundary=defensible-within-model'
printf '%s\n' "$results" | grep -q '^case=selector-not-resolved boundary=target-inventory'
printf '%s\n' "$results" | grep -q '^case=abort-never-rehearsed boundary=abort-tested'
printf '%s\n' "$results" | grep -q '^case=stop-uses-failed-control-plane boundary=independent-stop'
printf '%s\n' "$results" | grep -q '^case=baseline-already-broken boundary=healthy-baseline'
printf '%s\n' "$results" | grep -q '^case=tool-green-fault-not-applied boundary=fault-applied'
printf '%s\n' "$results" | grep -q '^case=rollback-ran-state-still-wrong boundary=correct-state-restored'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=47 refusal=true cleanup=true\n'
