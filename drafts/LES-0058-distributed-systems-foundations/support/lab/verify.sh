#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0058-distributed-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [even-membership]=membership-shape
  [unsafe-reconfiguration]=membership-change
  [quorum-loss]=quorum-loss
  [unsafe-quorums]=quorum-intersection
  [dual-writer]=split-brain
  [isolated-old-leader]=stale-leader
  [wall-clock-lease]=clock-safety
  [expired-worker-no-fence]=stale-writer
  [missing-causal-token]=causal-order
  [stale-linearizable-read]=stale-read
  [lag-without-repair]=replication-lag
  [divergence-no-repair]=convergence
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=13'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=13 refusal=true cleanup=true\n'
