#!/usr/bin/env bash
set -euo pipefail

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' 'missing-required-command-python3' >&2
  exit 69
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "${script_dir}/lab_controller.py" "$@"
