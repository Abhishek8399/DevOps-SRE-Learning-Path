#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly LAB="$SCRIPT_DIR/lab.sh"

"$LAB" check | grep -Fxq 'environment=ready'
output="$($LAB observe "$SCRIPT_DIR/README.md")"
grep -Fq -- '--- identity ---' <<< "$output"
grep -Fq -- '--- path-components ---' <<< "$output"
grep -Fq -- '--- mount-boundary ---' <<< "$output"
grep -Fq -- 'observation=complete' <<< "$output"
"$LAB" cleanup | grep -Fxq 'cleanup_proven=true'
printf 'verification_passed=true\nmutation=none\ncleanup_proven=true\n'
