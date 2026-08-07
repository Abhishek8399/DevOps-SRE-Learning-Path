#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$ROOT/lab.sh"
MODEL="$ROOT/model.py"
CASES="$ROOT/fixtures/cases.json"
PACKET="$ROOT/fixtures/packet.json"
STATE="/tmp/reliability-atlas-les0087-career-$(id -u)"
OUT="/tmp/les0087-verify-$(id -u)"

fail(){ printf 'verify=fail reason=%s\n' "$1" >&2; exit 1; }
expect(){ local output="$1" pattern="$2"; grep -Eq -- "$pattern" <<<"$output" || fail "expected:$pattern output:$output"; }
tidy(){ rm -f -- "$OUT"; }
trap tidy EXIT

[[ "$(id -u)" -ne 0 ]] || fail root-unsupported
[[ ! -e "$STATE" ]] || fail preexisting-state
python3 "$MODEL" validate "$CASES" "$PACKET"
doctor="$(bash "$LAB" doctor)"; expect "$doctor" 'doctor=pass'
bash "$LAB" setup
status="$(bash "$LAB" status)"; expect "$status" 'cases=73'; expect "$status" 'fictional-career-roadmap-evidence'

all="$(bash "$LAB" evaluate-all)"; expect "$all" 'refused=72'; expect "$all" 'baseline_pass=1'
title="$(bash "$LAB" evaluate title-proves-level)"; expect "$title" 'boundary=title-level'
course="$(bash "$LAB" evaluate course-completion-equals-skill)"; expect "$course" 'boundary=course-credential'
cloud="$(bash "$LAB" evaluate provider-apply-requested)"; expect "$cloud" 'boundary=cloud-authority'
hire="$(bash "$LAB" evaluate roadmap-guarantees-job)"; expect "$hire" 'boundary=hiring-prediction'

roles="$(bash "$LAB" roles)"; expect "$roles" 'coverage_pct=100.00'; expect "$roles" 'versioned=9'
evidence="$(bash "$LAB" evidence)"; expect "$evidence" 'total=60'; expect "$evidence" 'attributable_pct=80.00'
deps="$(bash "$LAB" dependencies)"; expect "$deps" 'coverage_pct=100.00'; expect "$deps" 'cycles=0'
capacity="$(bash "$LAB" capacity)"; expect "$capacity" 'committed_pct=80.00'; expect "$capacity" 'reserve_pct=20.00'
milestones="$(bash "$LAB" milestones)"; expect "$milestones" 'structure_pct=100.00'; expect "$milestones" 'production_claims=0'
reviews="$(bash "$LAB" reviews)"; expect "$reviews" 'independent_pct=100.00'; expect "$reviews" 'hiring_predictions=0'

if AWS_PROFILE=synthetic bash "$LAB" doctor >"$OUT" 2>&1; then fail authority-accepted; fi
grep -q credential-private-data-or-external-authority "$OUT" || fail authority-reason
bash "$LAB" inject-unknown
if bash "$LAB" cleanup >"$OUT" 2>&1; then fail unknown-cleanup-accepted; fi
grep -q unknown-artifact "$OUT" || fail unknown-cleanup-reason
bash "$LAB" clear-unknown
bash "$LAB" cleanup
[[ ! -e "$STATE" ]] || fail final-state
printf 'verify=pass cases=73 calculations=6 refusal=true cleanup=true learner_evaluation=none level_inference=none hiring_prediction=none external_calls=none\n'
