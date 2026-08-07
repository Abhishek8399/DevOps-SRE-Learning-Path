#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0074-recovery-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'cases=45'
results="$("$LAB" evaluate-all)"
[[ "$(printf '%s\n' "$results" | grep -c '^case=')" -eq 45 ]]
printf '%s\n' "$results" | grep -q '^case=baseline boundary=defensible'
printf '%s\n' "$results" | grep -q '^case=replica-called-backup boundary=replication-is-not-backup'
printf '%s\n' "$results" | grep -q '^case=wal-or-incremental-chain-gap boundary=backup-chain'
printf '%s\n' "$results" | grep -q '^case=application-correctness-unchecked boundary=application-correctness'
printf '%s\n' "$results" | grep -q '^case=measured-data-loss-exceeds-rpo boundary=measured-rpo'
printf '%s\n' "$results" | grep -q '^case=measured-recovery-exceeds-rto boundary=measured-rto'
printf '%s\n' "$results" | grep -q '^case=old-primary-can-still-write boundary=single-writer-safety'
printf '%s\n' "$results" | grep -q '^case=failback-unplanned boundary=failback-plan'
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then
  exit 1
fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]
printf 'verify=pass cases=45 refusal=true cleanup=true\n'
