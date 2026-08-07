#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0073-performance-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=43'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 43 ]]
printf '%s\n' "$results" | grep -q '^case=baseline boundary=defensible'
printf '%s\n' "$results" | grep -q '^case=before-and-after-load-differs boundary=baseline-comparability'
printf '%s\n' "$results" | grep -q '^case=host-metric-used-for-throttled-container boundary=cgroup-scope'
printf '%s\n' "$results" | grep -q '^case=sysctl-copied-from-blog boundary=tunable-semantics'
printf '%s\n' "$results" | grep -q '^case=immediate-win-no-soak boundary=sustained-verification'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=43 refusal=true cleanup=true\n'
