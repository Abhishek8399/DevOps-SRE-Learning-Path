#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$ROOT/lab.sh"
MODEL="$ROOT/model.py"
CASES="$ROOT/fixtures/cases.json"
PACKET="$ROOT/fixtures/packet.json"
STATE="/tmp/reliability-atlas-les0086-interviews-$(id -u)"

fail(){ printf 'verify=fail reason=%s\n' "$1" >&2; exit 1; }
expect(){ local output="$1" pattern="$2"; grep -Eq -- "$pattern" <<<"$output" || fail "expected:$pattern output:$output"; }

[[ "$(id -u)" -ne 0 ]] || fail root-unsupported
[[ ! -e "$STATE" ]] || fail preexisting-state

python3 "$MODEL" validate "$CASES" "$PACKET"
doctor="$(bash "$LAB" doctor)"; expect "$doctor" 'doctor=pass'
bash "$LAB" setup
status="$(bash "$LAB" status)"; expect "$status" 'cases=73'; expect "$status" 'fictional-platform-interview-evidence'

all="$(bash "$LAB" evaluate-all)"; expect "$all" 'refused=72'; expect "$all" 'baseline_pass=1'
role="$(bash "$LAB" evaluate role-level-assumed)"; expect "$role" 'boundary=role-fit'
truth="$(bash "$LAB" evaluate fabricated-career-metric)"; expect "$truth" 'boundary=ethics-confidentiality'
ai="$(bash "$LAB" evaluate unauthorized-live-assistance)"; expect "$ai" 'boundary=ai-boundary'

stories="$(bash "$LAB" stories)"; expect "$stories" 'complete_pct=100.00'; expect "$stories" 'fabricated=0'
claims="$(bash "$LAB" claims)"; expect "$claims" 'total=50'; expect "$claims" 'attributable_pct=92.00'
variants="$(bash "$LAB" variants)"; expect "$variants" '30s:62/65'; expect "$variants" '900s:1810/1950'
coverage="$(bash "$LAB" coverage)"; expect "$coverage" 'coverage_pct=100.00'; expect "$coverage" 'conflicts=0'
followups="$(bash "$LAB" followups)"; expect "$followups" 'consistent_pct=100.00'; expect "$followups" 'invented=0'

if ATS_TOKEN=synthetic bash "$LAB" doctor >/tmp/les0086-authority.out 2>&1; then
  fail authority-accepted
fi
grep -q credential-private-data-or-external-authority /tmp/les0086-authority.out || fail authority-reason
rm -- /tmp/les0086-authority.out

bash "$LAB" inject-unknown
if bash "$LAB" cleanup >/tmp/les0086-cleanup.out 2>&1; then
  fail unknown-cleanup-accepted
fi
grep -q unknown-artifact /tmp/les0086-cleanup.out || fail unknown-cleanup-reason
rm -- /tmp/les0086-cleanup.out
bash "$LAB" clear-unknown
bash "$LAB" cleanup
[[ ! -e "$STATE" ]] || fail final-state

printf 'verify=pass cases=73 calculations=5 refusal=true cleanup=true candidate_evaluation=none hiring_prediction=none external_calls=none\n'
