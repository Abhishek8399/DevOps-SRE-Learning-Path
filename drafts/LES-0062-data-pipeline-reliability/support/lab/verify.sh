#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0062-data-pipeline-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [source-not-replayable]=source-replay
  [source-position-unstable]=source-position
  [transform-nondeterministic]=transform-replay
  [sink-not-idempotent]=sink-duplicate
  [checkpoint-not-durable]=checkpoint-durability
  [checkpoint-incompatible]=checkpoint-compatibility
  [idle-input-unhandled]=watermark-idleness
  [lateness-too-short]=late-data-policy
  [state-retention-too-short]=state-horizon
  [schema-incompatible]=schema-contract
  [quality-contract-missing]=quality-contract
  [quarantine-unowned]=quality-quarantine
  [lineage-incomplete]=lineage-gap
  [hot-partition]=data-skew
  [backlog-no-drain]=recovery-drain
  [privacy-retention-unbounded]=privacy-retention
  [replay-live-sink]=replay-side-effect
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=18'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=18 refusal=true cleanup=true\n'
