#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0061-distributed-workflows-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [single-store-overcomplicated]=transaction-boundary
  [volatile-coordinator]=workflow-authority
  [unstable-step-id]=step-identity
  [state-outbox-split]=state-publish-gap
  [relay-not-fenced]=stale-relay
  [effect-not-idempotent]=duplicate-effect
  [checkpoint-before-effect]=effect-loss
  [compensation-not-idempotent]=duplicate-compensation
  [pivot-before-validation]=irreversible-order
  [unbounded-retry]=retry-storm
  [deadline-missing]=missing-deadline
  [history-unversioned]=history-version
  [replay-nondeterministic]=nondeterministic-replay
  [concurrency-unchecked]=concurrent-workflow
  [retention-too-short]=recovery-horizon
  [manual-state-unowned]=manual-orphan
  [authorization-stale]=stale-authorization
  [reconciliation-missing]=silent-drift
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=19'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=19 refusal=true cleanup=true\n'
