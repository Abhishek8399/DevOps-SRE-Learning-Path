#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; LAB="$DIR/lab.sh"
ROOT="/tmp/reliability-atlas-les0055-model-$(id -u)"
[[ ! -e "$ROOT"&&! -L "$ROOT" ]]||exit 1
"$LAB" doctor; "$LAB" setup
trap '[[ ! -d "$ROOT" ]]||"$LAB" cleanup>/dev/null' EXIT
"$LAB" evaluate baseline|grep -q '"decision": "operable"'
declare -A EXPECTED=([project-sprawl]=governance [service-account-key]=identity [mutable-image]=artifact [public-data]=network-exposure [single-zone]=failure-domain [quota-no-headroom]=capacity-quota [restore-untested]=recovery [resource-only-monitoring]=observability)
for case_name in "${!EXPECTED[@]}";do output="$("$LAB" evaluate "$case_name")";grep -q '"decision": "not-operable"'<<<"$output";grep -q "boundary.*${EXPECTED[$case_name]}"<<<"$output";done
"$LAB" inject-unknown
if "$LAB" status>/dev/null 2>&1;then exit 1;fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$ROOT"&&! -L "$ROOT" ]]||exit 1
printf 'verify=pass cases=9 cleanup=true runtime=model-only\n'
