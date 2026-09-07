#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$DIR"
[[ "$(id -u)" -ne 0 ]] || { printf 'verify=refused reason=root\n' >&2; exit 2; }
exec python3 ./verify.py
