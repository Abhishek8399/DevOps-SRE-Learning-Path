#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$DIR"
STATE="/tmp/reliability-atlas-les0084-docs-$(id -u)"
fail(){ printf 'verify=fail reason=%s\n' "$1" >&2; exit 1; }
[[ "$(id -u)" -ne 0 ]] || fail root-refused

if [[ -d "$STATE" && ! -L "$STATE" ]]; then bash lab.sh cleanup >/dev/null; fi
[[ ! -e "$STATE" && ! -L "$STATE" ]] || fail initial-state
bash lab.sh doctor
bash lab.sh setup
status="$(bash lab.sh status)"
[[ "$status" == *"cases=73"* && "$status" == *"packet_id=fictional-checkout-incident-docs"* ]] || fail status

roadmap="$(bash lab.sh roadmap)"
claims="$(bash lab.sh claims)"
timeline="$(bash lab.sh timeline)"
runbook="$(bash lab.sh runbook)"
freshness="$(bash lab.sh freshness)"
audiences="$(bash lab.sh audiences)"
[[ "$roadmap" == *"publish_calls=none"* ]] || fail roadmap
[[ "$claims" == *"attributable_pct=87.50"* && "$claims" == *"unknown_pct=4.17"* ]] || fail claims
[[ "$timeline" == *"impact_minutes=33"* && "$timeline" == *"response_minutes=35"* ]] || fail timeline
[[ "$runbook" == *"validation_pct=100.00"* && "$runbook" == *"safe_mutations=true"* ]] || fail runbook
[[ "$freshness" == *"active_current_pct=100.00"* && "$freshness" == *"critical_expired=0"* ]] || fail freshness
[[ "$audiences" == *"coverage_pct=100.00"* && "$audiences" == *"conflicts=0"* ]] || fail audiences

count="$(bash lab.sh evaluate-all | wc -l | tr -d ' ')"
[[ "$count" == "73" ]] || fail cases
[[ "$(bash lab.sh evaluate material-claim-unsourced)" == "case=material-claim-unsourced boundary=evidence" ]] || fail evidence-boundary
[[ "$(bash lab.sh evaluate destructive-command-unbounded)" == "case=destructive-command-unbounded boundary=safety" ]] || fail safety-boundary
[[ "$(bash lab.sh evaluate supersession-rewrites-history)" == "case=supersession-rewrites-history boundary=decision-record" ]] || fail decision-boundary

if DOCS_PUBLISH_TOKEN=fictional bash lab.sh status >/tmp/les0084-authority.out 2>&1; then fail authority-accepted; fi
grep -q 'credential-or-runtime-authority' /tmp/les0084-authority.out || fail authority-reason
rm -- /tmp/les0084-authority.out

bash lab.sh inject-unknown
if bash lab.sh status >/tmp/les0084-unknown.out 2>&1; then fail unknown-accepted; fi
grep -q 'unknown-artifact:unknown' /tmp/les0084-unknown.out || fail unknown-reason
rm -- /tmp/les0084-unknown.out
bash lab.sh clear-unknown
bash lab.sh cleanup
[[ ! -e "$STATE" && ! -L "$STATE" ]] || fail cleanup
printf 'verify=pass cases=73 calculations=5 refusal=true cleanup=true publish_calls=none runtime_calls=none\n'
