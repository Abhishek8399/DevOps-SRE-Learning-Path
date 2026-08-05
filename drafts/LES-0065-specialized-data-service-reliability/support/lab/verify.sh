#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0065-specialized-data-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [query-without-partition-key]=partition-query
  [hot-partition]=hot-partition
  [replica-placement-unsafe]=replica-placement
  [consistency-overclaimed]=consistency-contract
  [client-clock-skew]=clock-skew
  [repair-window-missed]=repair-horizon
  [tombstone-purge-unsafe]=tombstone-purge
  [compaction-no-headroom]=maintenance-headroom
  [backup-not-restored]=cassandra-restore
  [management-plane-open]=security-plane
  [embedding-model-unversioned]=embedding-version
  [dimension-metric-mismatch]=vector-contract
  [point-id-unstable]=point-identity
  [recall-baseline-missing]=recall-baseline
  [filter-index-missing]=filter-index
  [index-memory-exceeded]=index-memory
  [shard-replica-unsafe]=vector-placement
  [vector-snapshot-untested]=vector-restore
  [catalog-treated-as-data-authority]=catalog-authority
  [catalog-ingestion-stale]=catalog-freshness
  [lineage-unverified]=lineage-evidence
  [metadata-access-overbroad]=metadata-authorization
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=23'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=23 refusal=true cleanup=true\n'
