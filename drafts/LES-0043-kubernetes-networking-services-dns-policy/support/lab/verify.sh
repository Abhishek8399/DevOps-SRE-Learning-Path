#!/usr/bin/env bash
set -Eeuo pipefail
D="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; L="$D/lab.sh"; R="/tmp/reliability-atlas-les0043-model-$(id -u)"
[[ "$(id -u)" -gt 0 && ! -e "$R" && ! -L "$R" ]]||exit 1; bash "$L" setup>/dev/null; bash "$L" verify-cases
if bash "$L" diagnose-as dns-nxdomain service-dataplane>/dev/null 2>&1; then exit 1; fi
bash "$L" inject-unknown; if bash "$L" cleanup>/dev/null 2>&1; then exit 1; fi
bash "$L" clear-unknown; bash "$L" cleanup; [[ ! -e "$R" ]]||exit 1
printf 'verification=pass cases=7 wrong_answer=rejected cleanup_refusal=pass state_absent=true\n'
