#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0059-nosql-cache-$(id -u)"
declare -A EXPECTED=(
  [baseline]=operable
  [cache-no-authority]=authority
  [unknown-access-pattern]=access-pattern
  [cross-key-invariant]=atomic-scope
  [hot-key]=hot-key
  [oversized-value]=value-size
  [stale-session-read]=consistency-contract
  [idempotency-ttl-short]=ttl-correctness
  [unversioned-invalidation]=invalidation
  [stampede]=stampede
  [unbounded-negative-cache]=negative-cache
  [authorization-fail-open]=security-fail-open
  [volatile-write-behind]=write-behind-loss
  [repair-disabled]=repair
)

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=14'
for case_id in "${!EXPECTED[@]}"; do
  "$LAB" evaluate "$case_id" | grep -q "boundary=${EXPECTED[$case_id]}"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=14 refusal=true cleanup=true\n'
