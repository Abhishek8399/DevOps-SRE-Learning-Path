#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"; STATE="/tmp/reliability-atlas-les0068-mlops-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable [operation-not-defined]=operation-contract
  [release-manifest-incomplete]=release-identity [data-alias-only]=data-identity
  [data-digest-mismatch]=data-integrity [mutable-model-alias]=model-identity
  [prompt-unversioned]=prompt-identity [tokenizer-mismatch]=tokenizer-compatibility
  [evaluation-dataset-unversioned]=evaluation-identity [scorer-unversioned]=scorer-identity
  [aggregate-eval-only]=evaluation-slices [future-leakage]=evaluation-time
  [serving-mode-mismatch]=serving-mode [gateway-auth-missing]=gateway-auth
  [tenant-budget-unbound]=gateway-budget [retry-deadline-reset]=request-deadline
  [gpu-device-unhealthy]=device-health [gpu-memory-overcommitted]=gpu-memory
  [gpu-profile-mismatch]=gpu-profile [queue-deadline-missed]=queue-deadline
  [batch-head-of-line]=batch-admission [cache-tenant-unbound]=cache-isolation
  [canary-version-unlabeled]=canary-attribution [canary-sample-too-small]=canary-evidence
  [rollback-cold-too-slow]=rollback-readiness [drift-auto-retrain]=drift-response
  [label-delay-ignored]=label-maturity [telemetry-content-unsafe]=telemetry-privacy
  [unit-cost-unmeasured]=unit-economics [telemetry-cardinality-unbounded]=telemetry-capacity
)
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor; "$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=30'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=30 refusal=true cleanup=true\n'
