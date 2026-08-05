#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
ROOT="/tmp/reliability-atlas-les0053-model-$(id -u)"

[[ ! -e "$ROOT" && ! -L "$ROOT" ]] || {
  printf 'verify=fail reason=preexisting-state\n' >&2
  exit 1
}

"$LAB" doctor
"$LAB" setup
trap '[[ ! -d "$ROOT" ]] || "$LAB" cleanup >/dev/null' EXIT

"$LAB" evaluate baseline | grep -q '"boundary": "user-outcome".*"decision": "operable"'

declare -A EXPECTED=(
  [long-lived-admin]=identity
  [mutable-artifact]=artifact
  [public-database]=network-exposure
  [single-az]=failure-domain
  [quota-no-headroom]=capacity-quota
  [restore-untested]=recovery
  [no-user-sli]=observability
  [unbounded-retries]=resilience
)

for case_name in "${!EXPECTED[@]}"; do
  output="$("$LAB" evaluate "$case_name")"
  grep -q '"decision": "not-operable"' <<<"$output"
  grep -q "boundary.*${EXPECTED[$case_name]}" <<<"$output"
done

"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  printf 'verify=fail reason=unknown-not-refused\n' >&2
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$ROOT" && ! -L "$ROOT" ]] || exit 1
printf 'verify=pass cases=9 cleanup=true runtime=model-only\n'
