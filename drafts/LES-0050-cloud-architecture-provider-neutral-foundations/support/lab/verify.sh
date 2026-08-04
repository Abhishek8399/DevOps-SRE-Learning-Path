#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
D="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
L="$D/lab.sh"
R="/tmp/reliability-atlas-les0050-model-$(id -u)"
[[ ! -e "$R" ]] || { printf 'verify=fail reason=preexisting-state\n' >&2; exit 1; }
"$L" doctor
"$L" setup
trap 'if [[ -d "$R" ]]; then "$L" cleanup >/dev/null; fi' EXIT
"$L" evaluate | grep -q '"decision": "pass"'
for scenario in zone-loss quota-exhaustion api-throttle managed-region-outage policy-denial capacity-shortage cost-anomaly shared-dependency; do
  "$L" scenario "$scenario" | grep -q "\"scenario\": \"$scenario\""
done
"$L" inject-unknown
if "$L" status >/dev/null 2>&1; then
  printf 'verify=fail reason=unknown-state-accepted\n' >&2
  exit 1
fi
"$L" clear-unknown
"$L" cleanup
trap - EXIT
[[ ! -e "$R" ]] || { printf 'verify=fail reason=cleanup\n' >&2; exit 1; }
printf 'verify=pass scenarios=8 cleanup=true runtime=model-only\n'
