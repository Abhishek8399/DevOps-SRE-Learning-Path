#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"; STATE="/tmp/reliability-atlas-les0067-aiops-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable [operation-not-defined]=operation-contract
  [user-impact-unbound]=user-impact [telemetry-identity-missing]=telemetry-identity
  [event-observed-time-conflated]=event-time [data-quality-unchecked]=data-quality
  [seasonality-ignored]=seasonality [population-unrepresentative]=population
  [labels-unreviewed]=labels [future-leakage]=time-split
  [simple-baseline-missing]=simple-baseline [threshold-cost-mismatch]=threshold-cost
  [single-point-page]=persistence [review-capacity-exceeded]=review-capacity
  [unstable-dedup-key]=deduplication [unbounded-group-window]=grouping
  [stale-topology]=topology [change-evidence-missing]=change-evidence
  [correlation-claimed-cause]=causal-claim [cause-not-tested]=cause-evidence
  [forecast-no-interval]=forecast-interval [forecast-too-late]=forecast-lead
  [explanation-unvalidated]=explanation [feedback-identity-missing]=feedback
  [automation-overprivileged]=automation-authority
  [action-not-idempotent]=automation-idempotency [rollback-untested]=rollback
  [drift-unmonitored]=drift [privacy-retention-unsafe]=privacy-lifecycle
)
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor; "$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=29'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=29 refusal=true cleanup=true\n'
