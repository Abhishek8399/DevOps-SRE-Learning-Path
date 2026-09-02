#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
"$LAB" doctor
"$LAB" setup
"$LAB" verify-cases
if "$LAB" diagnose-as values-type-drift rollout >/dev/null 2>&1; then printf 'verify=fail reason=wrong-boundary-accepted\n' >&2; exit 1; fi
"$LAB" inject-unknown
if "$LAB" list >/dev/null 2>&1; then printf 'verify=fail reason=unknown-artifact-accepted\n' >&2; exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
printf 'verification=pass boundary=model-only state_absent=true\n'
