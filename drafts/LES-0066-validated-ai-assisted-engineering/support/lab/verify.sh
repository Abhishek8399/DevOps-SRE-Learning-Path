#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"; STATE="/tmp/reliability-atlas-les0066-validated-ai-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable [task-not-defined]=task-contract [non-ai-baseline-missing]=baseline
  [dataset-leak]=data-leakage [population-unrepresentative]=population
  [metric-cost-mismatch]=metric [token-budget-exceeded]=token-budget
  [context-evidence-lost]=context-use [embedding-contract-mismatch]=embedding-contract
  [retrieval-baseline-missing]=retrieval-baseline [retrieval-provenance-missing]=retrieval-provenance
  [generation-ungrounded]=grounding [citation-unverified]=citation
  [prompt-injection-trusted]=instruction-trust [tool-schema-loose]=tool-schema
  [tool-authority-excessive]=tool-authority [tool-output-untrusted]=tool-output
  [side-effect-not-idempotent]=side-effect [human-review-ceremonial]=human-review
  [eval-contaminated]=eval-integrity [judge-not-calibrated]=judge-calibration
  [version-lineage-missing]=version-lineage [privacy-retention-unsafe]=privacy-lifecycle
  [rollback-untested]=rollback
)
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor; "$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=24'
for case_id in "${!EXPECTED[@]}"; do "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"; done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=24 refusal=true cleanup=true\n'
