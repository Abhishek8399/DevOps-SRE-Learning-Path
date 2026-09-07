#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
IFS=$'\n\t'

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$DIR"

case "${1:-doctor}" in
  doctor)
    command -v python3 >/dev/null
    [[ -f README.md && -f verify.sh && -f pyproject.toml ]]
    printf 'doctor=pass lesson=LES-0088 runtime=not-run\n'
    ;;
  status)
    printf 'lesson=LES-0088 project=present runtime=not-assessed readme=%s\n' "$DIR/README.md"
    ;;
  verify)
    exec bash ./verify.sh
    ;;
  *)
    printf 'usage: %s {doctor|status|verify}\n' "$0" >&2
    exit 64
    ;;
esac
