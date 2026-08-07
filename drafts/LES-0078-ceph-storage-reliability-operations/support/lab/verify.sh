#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0078-ceph-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" inventory-tools | grep -q '^inventory=observed .* cluster_calls=none$'
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=56'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 56 ]]
for expected in \
  'baseline boundary=operable-within-model' \
  'stale-client-map boundary=client-map' \
  'crush-correlated-domain boundary=crush-failure-domain' \
  'active-degraded boundary=pg-cleanliness' \
  'pg-inconsistent boundary=data-consistency' \
  'recovery-user-slo-contention boundary=recovery-contention' \
  'fullest-osd-at-full-ratio boundary=fullness-admission' \
  'rbd-writer-authority-ambiguous boundary=writer-authority' \
  'mixed-release-incompatible boundary=upgrade-compatibility' \
  'clean-user-slo-failed boundary=user-io'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=56 refusal=true cleanup=true cluster_calls=none\n'
