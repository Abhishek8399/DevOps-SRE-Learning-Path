#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0083-strategy-$(id -u)"
[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
if env AWS_PROFILE=production "$LAB" doctor >/dev/null 2>&1; then exit 1; fi
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=71 strategy_id=payments-modernization-strategy-v1'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 71 ]]
for expected in \
  'baseline boundary=defensible-within-model' \
  'current-state-asserted-without-evidence boundary=current-state' \
  'evidence-confidence-hidden boundary=confidence' \
  'dependencies-unclassified boundary=dependencies' \
  'strategy-options-incomplete boundary=options' \
  'vendor-exit-plan-unbound boundary=vendor-exit' \
  'cost-model-semantics-unbound boundary=cost' \
  'estimate-range-or-confidence-unbound boundary=uncertainty' \
  'wave-size-exceeds-delivery-capacity boundary=wave-capacity' \
  'writer-authority-or-fencing-unbound boundary=writer' \
  'cutover-window-does-not-close boundary=cutover' \
  'rollback-feasibility-unproved boundary=rollback' \
  'go-no-go-authority-unbound boundary=go-no-go' \
  'strategy-validation-plan-missing boundary=validation'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done
"$LAB" roadmap | grep -q 'stages=discover->rationalize->foundation->pilot->waves->reconcile->decommission'
"$LAB" inventory | grep -q 'total=120 observed=72 declared=30 unknown=18 observed_pct=60.00 unknown_pct=15.00'
"$LAB" capacity | grep -q 'future_peak_rps=15625.00 target_rps=20312.50 healthy_instances=34 per_domain=17 provisioned_instances=51 surviving_rps=20400.00'
"$LAB" transfer | grep -q 'bulk_hours=59.26 source_delta_gb=1185.19 final_sync_hours=1.46 validation_hours=1.50 cutover_hours=2.96 window_hours=4.00 closes=true'
"$LAB" economics | grep -q 'current_total=7200000.00 proposed_total=7350000.00 net_saving=-150000.00 break_even_months=39.27 breaks_even_within_horizon=false'
"$LAB" vendor | grep -q 'managed_suite=3.95 portable_platform=3.95 managed_suite_veto=exit-plan feasible_selected=portable-platform'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=71 calculations=5 refusal=true cleanup=true runtime_calls=none\n'
