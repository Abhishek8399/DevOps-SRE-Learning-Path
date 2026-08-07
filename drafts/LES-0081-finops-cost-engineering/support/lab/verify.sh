#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0081-finops-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor

if env AWS_PROFILE=production "$LAB" doctor >/dev/null 2>&1; then
  exit 1
fi

"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=64 rows=12'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 64 ]]

for expected in \
  'baseline boundary=defensible-within-model' \
  'billed-effective-list-or-contracted-cost-confused boundary=cost-semantics' \
  'dataset-does-not-reconcile-to-invoice boundary=invoice-reconciliation' \
  'shared-cost-driver-unjustified boundary=allocation-driver' \
  'allocation-does-not-conserve-cost boundary=allocation-conservation' \
  'unit-denominator-unstable-or-gameable boundary=unit-denominator' \
  'forecast-has-no-uncertainty-range boundary=uncertainty' \
  'budget-alert-treated-as-real-time-control boundary=budget-latency' \
  'cost-spike-security-abuse-unchecked boundary=security-abuse' \
  'optimization-ignores-slo-or-performance boundary=slo-performance' \
  'rightsizing-removes-failure-reserve boundary=failure-reserve' \
  'commitment-utilization-or-vacancy-unacceptable boundary=commitment-utilization' \
  'estimated-savings-not-reconciled-to-actual boundary=realized-savings' \
  'executive-narrative-hides-assumptions-or-risk boundary=communication'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done

analysis="$("$LAB" analyze)"
for token in \
  'analysis=pass rows=12 currency=USD' \
  'effective=6220.00' \
  'direct_allocation_pct=76.27' \
  'shared=1500.00' \
  'cost_per_successful_transaction=0.000778' \
  'cost_per_business_unit=0.001681'; do
  [[ "$analysis" == *"$token"* ]]
done

allocation="$("$LAB" allocate)"
[[ "$allocation" == *'allocation=pass shared_source=1500.00 payments_shared=900.00 search_shared=600.00'* ]]
[[ "$allocation" == *'conservation=true'* ]]

forecast="$("$LAB" forecast)"
[[ "$forecast" == *'forecast=pass point=6800.00 low=6400.00 high=7300.00 budget=6500.00'* ]]
[[ "$forecast" == *'uncertainty=explicit'* ]]

commitment="$("$LAB" commitment)"
[[ "$commitment" == *'commitment=pass coverage_pct=65.00 utilization_pct=83.33 vacancy=250.00'* ]]

"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=64 calculations=4 refusal=true cleanup=true cloud_runtime_calls=none\n'
