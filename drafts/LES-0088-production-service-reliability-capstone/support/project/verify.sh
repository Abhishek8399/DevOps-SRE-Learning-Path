#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ "$(id -u)" -ne 0 ]] || {
  printf 'verify: refusal: run as a normal user, not root\n' >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  printf 'verify: refusal: python3 is required\n' >&2
  exit 1
}
cd -- "$PROJECT_ROOT"
exec python3 ops/verify.py
