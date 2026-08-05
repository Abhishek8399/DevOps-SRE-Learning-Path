#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="$DIR/lab.sh"
STATE="/tmp/reliability-atlas-les0056-postgres-$(id -u)"

[[ ! -e "$STATE" && ! -L "$STATE" ]]||exit 1
"$LAB" doctor
"$LAB" setup
trap '[ ! -d "$STATE" ] || "$LAB" cleanup >/dev/null' EXIT
"$LAB" status | grep -q 'orders=100000'
before="$("$LAB" plan-before)"
grep -q '"Node Type": "Seq Scan"' <<<"$before"
"$LAB" add-index
after="$("$LAB" plan-after)"
grep -Eq '"Node Type": "(Index Scan|Index Only Scan|Bitmap Heap Scan)"' <<<"$after"
"$LAB" lock-wait
"$LAB" deadlock
"$LAB" connections
"$LAB" backup-restore
"$LAB" inject-unknown
if "$LAB" status >/dev/null 2>&1; then exit 1; fi
"$LAB" clear-unknown
"$LAB" cleanup
trap - EXIT
[[ ! -e "$STATE" && ! -L "$STATE" ]]||exit 1
printf 'verify=pass plan=true lock=true deadlock=true connections=true restore=true cleanup=true\n'
