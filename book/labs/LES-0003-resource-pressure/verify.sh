#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly LAB="$SCRIPT_DIR/lab.sh"

"$LAB" check | grep -Fxq 'environment=ready'
output="$($LAB observe)"
grep -Fq -- '--- cpu-and-load ---' <<< "$output"
grep -Fq -- '--- interval-sample ---' <<< "$output"
grep -Fq -- '--- memory ---' <<< "$output"
grep -Fq -- '--- pressure ---' <<< "$output"
grep -Fq -- 'observation=complete' <<< "$output"
"$LAB" cleanup | grep -Fxq 'cleanup_proven=true'
printf 'verification_passed=true\nmutation=none\ncleanup_proven=true\n'
