#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0082-architecture-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor

if env AWS_PROFILE=production "$LAB" doctor >/dev/null 2>&1; then
  exit 1
fi

"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=67 design_id=checkout-architecture-v1'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 67 ]]

for expected in \
  'baseline boundary=defensible-within-model' \
  'requirements-ambiguous-or-unmeasurable boundary=requirements' \
  'diagram-mixes-abstraction-levels boundary=abstraction' \
  'state-owner-or-writer-authority-unbound boundary=state-owner' \
  'availability-composition-invalid boundary=availability' \
  'capacity-model-or-failure-reserve-invalid boundary=capacity' \
  'queue-backlog-age-or-drain-model-invalid boundary=queue' \
  'trust-boundary-or-authority-crossing-unmapped boundary=trust-boundary' \
  'credible-alternatives-not-compared boundary=options' \
  'sensitivity-or-tradeoff-points-unidentified boundary=sensitivity' \
  'decision-record-lacks-context-options-or-consequences boundary=adr' \
  'complexity-not-justified-by-requirement boundary=simplicity' \
  'architecture-validation-plan-missing boundary=validation'; do
  printf '%s\n' "$results" | grep -q "^case=$expected"
done

map_output="$("$LAB" map)"
[[ "$map_output" == *'map=pass design_id=checkout-architecture-v1'* ]]
[[ "$map_output" == *'state_owner=database trust_crossings=2 failure_domains=3'* ]]

capacity_output="$("$LAB" capacity)"
[[ "$capacity_output" == *'target_rps=15600.00 healthy_instances=21 per_domain=11 provisioned_instances=33'* ]]
[[ "$capacity_output" == *'after_one_domain_loss_rps=16500 reserve=true'* ]]

availability_output="$("$LAB" availability)"
[[ "$availability_output" == *'composite_pct=99.8001 implied_unavailable_minutes_30d=86.35 independence_assumed=true'* ]]

backlog_output="$("$LAB" backlog)"
[[ "$backlog_output" == *'items=24000.00 peak_age_seconds=48.00 drain_seconds=96.00'* ]]
[[ "$backlog_output" == *'rpo_exposed_writes=75000.00 exposed_not_proven_lost=true'* ]]

latency_output="$("$LAB" latency)"
[[ "$latency_output" == *'budget_ms=300.00 slo_ms=300.00 unallocated_ms=0.00 closes=true'* ]]

tradeoff_output="$("$LAB" tradeoff)"
[[ "$tradeoff_output" == *'synchronous=3.20 durable_queue=3.60 model_selected=durable-queue'* ]]
[[ "$tradeoff_output" == *'decision_authority=human-review-required'* ]]

"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=67 calculations=5 refusal=true cleanup=true runtime_calls=none\n'
