#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"; STATE="/tmp/reliability-atlas-les0069-ai-security-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable [operation-undefined]=operation-contract
  [threat-model-incomplete]=threat-model [content-origin-missing]=content-origin
  [retrieved-content-authoritative]=content-authority [output-schema-open]=output-schema
  [output-sink-unvalidated]=output-validation [tool-catalog-excessive]=tool-functionality
  [tool-arguments-untyped]=tool-schema [tool-authorization-missing]=tool-authorization
  [downstream-mediation-missing]=downstream-authorization [shared-service-identity]=identity-propagation
  [secret-scope-broad]=secret-scope [sandbox-unbounded]=sandbox-isolation
  [egress-open]=egress-control [approval-omitted]=approval-required
  [approval-preview-changed]=approval-binding [approval-expired]=approval-freshness
  [dataset-lineage-missing]=data-provenance [dataset-digest-mismatch]=data-integrity
  [model-provenance-missing]=model-provenance [signature-policy-unbound]=signer-policy
  [executable-model-format]=artifact-format [dependency-provenance-missing]=dependency-provenance
  [audit-effect-gap]=audit-completeness [audit-content-unredacted]=audit-privacy
  [red-team-invariants-missing]=adversarial-evaluation [containment-path-dependent]=kill-path
  [kill-queue-unaccounted]=kill-accounting [recovery-unproven]=recovery-proof
  [residual-risk-owner-missing]=risk-ownership
)
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor; "$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=31'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=31 refusal=true cleanup=true\n'
