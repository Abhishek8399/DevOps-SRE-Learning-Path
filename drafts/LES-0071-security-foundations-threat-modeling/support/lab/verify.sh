#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0071-security-$(id -u)"
declare -A EXPECTED=(
  [baseline]=defensible
  [scope-unknown]=scope
  [asset-owner-missing]=asset-ownership
  [classification-unknown]=data-classification
  [diagram-stale]=architecture
  [boundary-unmapped]=trust-boundaries
  [actor-capability-ignored]=actors
  [entry-point-missing]=entry-points
  [threat-list-empty]=threat-identification
  [risk-unanalysed]=risk-analysis
  [risk-owner-missing]=risk-ownership
  [requirement-not-testable]=security-requirements
  [proofing-too-weak]=identity-proofing
  [authentication-replayable]=authentication
  [shared-workload-identity]=workload-identity
  [object-check-missing]=authorization
  [permission-wildcard]=least-privilege
  [approver-can-deploy]=separation-of-duties
  [secret-never-rotated]=secret-lifecycle
  [plaintext-hop]=transport-encryption
  [sensitive-backup-plaintext]=stored-data-encryption
  [key-owner-unknown]=key-management
  [flat-network]=segmentation
  [egress-anywhere]=egress
  [default-admin]=secure-defaults
  [inventory-stale]=vulnerability-management
  [decision-not-logged]=logging-coverage
  [logs-mutable-by-service]=log-integrity
  [no-detection-question]=detection
  [alert-has-no-owner]=alert-routing
  [response-role-unknown]=response-readiness
  [containment-uses-compromised-plane]=containment
  [forensics-overwritten]=evidence-preservation
  [restore-never-tested]=recovery-proof
  [exception-permanent]=residual-risk
  [model-never-revisited]=continuous-review
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=36'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=36 refusal=true cleanup=true\n'
