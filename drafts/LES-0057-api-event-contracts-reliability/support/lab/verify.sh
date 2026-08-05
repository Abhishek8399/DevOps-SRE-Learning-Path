#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0057-api-events-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [removed-field]=compatibility-remove
  [new-required]=compatibility-required
  [changed-type]=compatibility-type
  [narrowed-enum]=compatibility-enum
  [changed-meaning]=compatibility-meaning
  [strict-consumer]=forward-compatibility
  [duplicate-no-claim]=duplicate-safety
  [ordering-no-sequence]=ordering
  [replay-no-freshness]=replay
  [multi-retry-owners]=retry-amplification
  [notification-no-owner]=state-ownership
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=12'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=12 refusal=true cleanup=true\n'
