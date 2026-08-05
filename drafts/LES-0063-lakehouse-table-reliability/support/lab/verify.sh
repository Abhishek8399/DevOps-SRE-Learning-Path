#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0063-lakehouse-table-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [catalog-not-authoritative]=catalog-authority
  [pointer-commit-not-atomic]=commit-atomicity
  [snapshot-unreachable]=snapshot-reference
  [manifest-incomplete]=manifest-closure
  [file-identity-unstable]=file-identity
  [field-ids-not-preserved]=schema-field-id
  [reader-format-incompatible]=format-compatibility
  [partition-evolution-unsafe]=partition-evolution
  [conflict-validation-missing]=write-conflict
  [snapshots-expire-too-soon]=snapshot-retention
  [orphan-cleanup-races-writer]=orphan-retention
  [rollback-anchor-missing]=rollback-anchor
  [small-files]=small-files
  [delete-files-dominate]=delete-amplification
  [statistics-stale]=statistics
  [scan-budget-exceeded]=scan-budget
  [maintenance-not-isolated]=workload-isolation
  [catalog-overprivileged]=authorization
  [audit-incomplete]=audit-lineage
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=20'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=20 refusal=true cleanup=true\n'
