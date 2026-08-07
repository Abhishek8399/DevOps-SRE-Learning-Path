#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$DIR"
STATE="/tmp/reliability-atlas-les0085-leadership-$(id -u)"
fail(){ printf 'verify=fail reason=%s\n' "$1" >&2; exit 1; }
[[ "$(id -u)" -ne 0 ]] || fail root-refused

if [[ -d "$STATE" && ! -L "$STATE" ]]; then bash lab.sh cleanup >/dev/null; fi
[[ ! -e "$STATE" && ! -L "$STATE" ]] || fail initial-state
bash lab.sh doctor
bash lab.sh setup
status="$(bash lab.sh status)"
[[ "$status" == *"cases=73"* && "$status" == *"packet_id=fictional-checkout-platform-leadership"* ]] || fail status

roadmap="$(bash lab.sh roadmap)"
priorities="$(bash lab.sh priorities)"
delegation="$(bash lab.sh delegation)"
decisions="$(bash lab.sh decisions)"
stakeholders="$(bash lab.sh stakeholders)"
load="$(bash lab.sh load)"
[[ "$roadmap" == *"people_system_calls=none"* ]] || fail roadmap
[[ "$priorities" == *"utilization_pct=90.00"* && "$priorities" == *"reserve_pct=10.00"* && "$priorities" == *"stopped=18"* ]] || fail priorities
[[ "$delegation" == *"complete_pct=100.00"* ]] || fail delegation
[[ "$decisions" == *"closure_pct=100.00"* && "$decisions" == *"unresolved=0"* ]] || fail decisions
[[ "$stakeholders" == *"coverage_pct=100.00"* && "$stakeholders" == *"conflicts=0"* ]] || fail stakeholders
[[ "$load" == *"spread=2"* && "$load" == *"maximum_share_pct=22.50"* && "$load" == *"handoff_pct=100.00"* ]] || fail load

count="$(bash lab.sh evaluate-all | wc -l | tr -d ' ')"
[[ "$count" == "73" ]] || fail cases
[[ "$(bash lab.sh evaluate everything-priority-one)" == "case=everything-priority-one boundary=priority" ]] || fail priority-boundary
[[ "$(bash lab.sh evaluate responsibility-without-authority)" == "case=responsibility-without-authority boundary=delegation" ]] || fail delegation-boundary
[[ "$(bash lab.sh evaluate fabricated-career-metric)" == "case=fabricated-career-metric boundary=ethics" ]] || fail ethics-boundary

if HR_SYSTEM_TOKEN=fictional bash lab.sh status >/tmp/les0085-authority.out 2>&1; then fail authority-accepted; fi
grep -q 'credential-or-external-authority' /tmp/les0085-authority.out || fail authority-reason
rm -- /tmp/les0085-authority.out

bash lab.sh inject-unknown
if bash lab.sh status >/tmp/les0085-unknown.out 2>&1; then fail unknown-accepted; fi
grep -q 'unknown-artifact:unknown' /tmp/les0085-unknown.out || fail unknown-reason
rm -- /tmp/les0085-unknown.out
bash lab.sh clear-unknown
bash lab.sh cleanup
[[ ! -e "$STATE" && ! -L "$STATE" ]] || fail cleanup
printf 'verify=pass cases=73 calculations=5 refusal=true cleanup=true people_system_calls=none messaging_calls=none runtime_calls=none\n'
