#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"; STATE="/tmp/reliability-atlas-les0070-supply-chain-$(id -u)"
declare -A EXPECTED=(
  [baseline]=admissible [change-unreviewed]=change-review
  [source-revision-floating]=source-identity [workflow-action-tagged]=workflow-integrity
  [runner-shared-persistent]=runner-isolation [secret-scope-broad]=secret-scope
  [network-egress-open]=network-egress [dependency-graph-unlocked]=dependency-lock
  [dependency-source-untrusted]=dependency-source [dependency-integrity-missing]=dependency-integrity
  [license-policy-absent]=license-policy [secret-scan-skipped]=secret-scan
  [source-scan-skipped]=source-scan [iac-scan-skipped]=iac-scan
  [image-scan-skipped]=image-scan [scanner-version-unknown]=scanner-identity
  [vulnerability-data-stale-unknown]=vulnerability-data [findings-not-gated]=finding-policy
  [exception-owner-expiry-missing]=exception-governance [build-host-contaminated]=build-isolation
  [build-not-reproducible]=build-reproducibility [artifact-tag-only]=artifact-identity
  [sbom-missing]=sbom-presence [sbom-for-other-digest]=sbom-binding
  [provenance-missing]=provenance-presence [provenance-subject-mismatch]=provenance-binding
  [signature-unverified]=signature-verification [signer-not-authorized]=signer-policy
  [admission-check-bypassed]=admission-policy [runtime-uses-tag]=runtime-identity
  [deployment-inventory-stale]=runtime-inventory [revocation-path-untested]=revocation-readiness
  [recovery-unproven]=recovery-proof [residual-risk-owner-missing]=risk-ownership
)
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor; "$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=34'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown; "$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=34 refusal=true cleanup=true\n'
