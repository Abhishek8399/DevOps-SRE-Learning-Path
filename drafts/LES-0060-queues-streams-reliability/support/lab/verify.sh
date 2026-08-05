#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0060-queues-streams-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [ambiguous-publisher-ack]=publisher-ack
  [unstable-event-id]=event-identity
  [missing-ordering-contract]=ordering-contract
  [producer-retry-new-id]=producer-duplicate
  [non-idempotent-effect]=consumer-duplicate
  [checkpoint-before-effect]=effect-loss
  [poison-unbounded]=poison-loop
  [quarantine-no-owner]=quarantine
  [backlog-no-drain]=backlog-drain
  [hot-partition]=hot-partition
  [retention-too-short]=replay-horizon
  [rebalance-no-fence]=stale-consumer
  [unguarded-replay]=replay-effect
  [insufficient-replicas]=durability-availability
  [authorization-unscoped]=security-boundary
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=16'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=16 refusal=true cleanup=true\n'
