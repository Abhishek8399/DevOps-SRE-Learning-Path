#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
app_dir="${repo_dir}/learning-cockpit"
port="${RELIABILITY_ATLAS_PORT:-3000}"

[[ "${port}" =~ ^[0-9]{1,5}$ ]] && (( port >= 1 && port <= 65535 )) || {
  printf '%s\n' '[ERROR] RELIABILITY_ATLAS_PORT must be a numeric TCP port from 1 to 65535.' >&2
  exit 1
}

command -v node >/dev/null 2>&1 || { printf '%s\n' '[ERROR] Node.js is required.' >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { printf '%s\n' '[ERROR] npm is required.' >&2; exit 1; }
[[ -d "${app_dir}/node_modules" ]] || {
  printf '%s\n' '[ERROR] Dependencies are not installed in learning-cockpit/node_modules.' >&2
  printf '%s\n' '        From the repository root, run: (cd learning-cockpit && npm ci)' >&2
  exit 1
}

printf 'Starting Reliability Atlas on http://127.0.0.1:%s\n' "${port}"
printf '%s\n' 'Stop it with Ctrl+C in this terminal.'
cd -- "${app_dir}"
exec npm run dev -- --hostname 127.0.0.1 --port "${port}"
