#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0064-workflow-ml-platform-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [unstable-run-identity]=run-identity
  [data-interval-unbound]=data-interval
  [task-not-idempotent]=task-idempotency
  [retry-unbounded]=retry-budget
  [timeout-missing]=deadline
  [trigger-rule-false-green]=false-green
  [backfill-live-contention]=backfill-isolation
  [pool-not-enforced]=resource-pool
  [scheduler-health-dependent]=component-health
  [dag-parse-nondeterministic]=dag-parse
  [training-data-unversioned]=training-data-version
  [experiment-lineage-incomplete]=experiment-lineage
  [evaluation-population-mismatch]=evaluation-population
  [threshold-missing]=promotion-gate
  [model-artifact-unpinned]=model-artifact
  [alias-uncontrolled]=alias-promotion
  [feature-skew]=training-serving-skew
  [drift-unowned]=drift-response
  [serving-no-rollback]=serving-rollback
  [notebook-shared-unsafe]=notebook-isolation
  [privacy-retention-unbounded]=privacy-retention
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=22'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=22 refusal=true cleanup=true\n'
