#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
IFS=$'\n\t'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"; LAB="${SCRIPT_DIR}/lab.sh"; ROOT="/tmp/reliability-atlas-les0042-model-$(id -u)"
[[ "$(id -u)" -gt 0 ]] || { printf 'verification=fail reason=root-refused\n' >&2; exit 1; }
[[ ! -e "$ROOT" && ! -L "$ROOT" ]] || { printf 'verification=fail reason=preexisting-root\n' >&2; exit 1; }
bash "$LAB" setup >/dev/null; bash "$LAB" verify-cases
if bash "$LAB" diagnose-as pending-resources kubelet-image >/dev/null 2>&1; then printf 'verification=fail reason=wrong-answer-accepted\n' >&2; exit 1; fi
bash "$LAB" inject-unknown >/dev/null
if bash "$LAB" cleanup >/dev/null 2>&1; then printf 'verification=fail reason=unknown-entry-cleaned\n' >&2; exit 1; fi
bash "$LAB" clear-unknown >/dev/null; bash "$LAB" cleanup
[[ ! -e "$ROOT" && ! -L "$ROOT" ]] || { printf 'verification=fail reason=residue\n' >&2; exit 1; }
printf 'verification=pass cases=8 wrong_answer=rejected cleanup_refusal=pass state_absent=true\n'
