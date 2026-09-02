#!/usr/bin/env bash

set -Eeuo pipefail
umask 077
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly LAB="$SCRIPT_DIR/lab.sh"
readonly STATE_FILE="/tmp/devops-sre-LES-0002-process-lifecycle-$(id -u).state"
cleanup_on_exit() { bash "$LAB" cleanup >/dev/null 2>&1 || true; }
trap cleanup_on_exit EXIT
[[ "$(id -u)" -ne 0 ]] || { printf 'verification_error=run as non-root\n' >&2; exit 1; }
[[ ! -e "$STATE_FILE" ]] || { printf 'verification_error=active learner state exists\n' >&2; exit 1; }
bash "$LAB" check | grep -Fxq 'state=absent'
bash "$LAB" setup | grep -Fxq 'setup=complete'
bash "$LAB" inject | grep -Fxq 'state=running'
bash "$LAB" observe | grep -Fxq 'identity=matched'
bash "$LAB" status | grep -Fxq 'identity=matched'
bash "$LAB" terminate | grep -Fxq 'termination=graceful'
bash "$LAB" status | grep -Fxq 'state=terminated'
bash "$LAB" cleanup | grep -Fxq 'cleanup_proven=true'
bash "$LAB" check | grep -Fxq 'process_candidates=0'
trap - EXIT
printf 'verification_passed=true\nidentity_guard=uid,start_ticks,token\n'
printf 'termination=graceful\ncleanup_proven=true\n'
