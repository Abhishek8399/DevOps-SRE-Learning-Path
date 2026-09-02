#!/usr/bin/env bash
set -euo pipefail

if (( EUID == 0 )); then
  printf '%s\n' 'root-is-refused-run-as-a-normal-user' >&2
  exit 77
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd -- "$script_dir"

fail() {
  printf 'verification-failed=%s\n' "$1" >&2
  exit 1
}

if (( $# != 1 )) || [[ "$1" != 'static' && "$1" != 'runtime' ]]; then
  printf '%s\n' 'usage: bash verify.sh {static|runtime}' >&2
  exit 64
fi
mode="$1"

for required in bash python3 shellcheck docker grep sed; do
  command -v "$required" >/dev/null 2>&1 || fail "missing-command-${required}"
done
docker compose version >/dev/null 2>&1 || fail 'missing-docker-compose'

platform="$({ python3 - <<'PY'
import platform
value = platform.freedesktop_os_release()
print(f"{value.get('ID')}-{value.get('VERSION_ID')}")
PY
} 2>/dev/null)"
[[ "$platform" == 'ubuntu-24.04' ]] || fail "canonical-platform-${platform}"

bash -n runtime.sh verify.sh
shellcheck runtime.sh verify.sh
PYTHONDONTWRITEBYTECODE=1 python3 - <<'PY'
import ast
import json
from pathlib import Path

for path in sorted(Path('.').rglob('*.py')):
    ast.parse(path.read_text(encoding='utf-8'), filename=str(path))
for path in sorted(Path('.').rglob('*.json')):
    json.loads(path.read_text(encoding='utf-8'))
print('python_json_static=passed')
PY
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py' -v
docker compose -f compose.yaml -p "reliability-atlas-les0028-${UID}" config --quiet
grep -Fq 'host port' README.md
grep -Fq 'not yet an executable learner command path' README.md

if [[ "$mode" == 'static' ]]; then
  printf '%s\n' 'verification=passed mode=static mutation=none product_runtime=not-run'
  exit 0
fi

lifecycle_token=''
cleanup_on_exit() {
  local original_status=$?
  trap - EXIT
  if [[ -n "$lifecycle_token" ]]; then
    set +e
    cleanup_output="$(bash runtime.sh cleanup --expect-token "$lifecycle_token" 2>&1)"
    cleanup_status=$?
    set -e
    if (( cleanup_status != 0 )); then
      printf '%s\n' "$cleanup_output" >&2
      printf '%s\n' 'verification-failed=trap-cleanup-failed' >&2
      exit 1
    fi
  fi
  exit "$original_status"
}
trap cleanup_on_exit EXIT

bash runtime.sh doctor | grep -Fq 'ready=true'
bash runtime.sh validate-configs | grep -Fq 'config_validation=passed'
setup_output="$(bash runtime.sh setup)"
lifecycle_token="$(sed -n 's/.*lifecycle_token=\([0-9a-f]\{32\}\).*/\1/p' <<<"$setup_output")"
[[ "$lifecycle_token" =~ ^[0-9a-f]{32}$ ]] || fail 'setup-token-invalid'
grep -Fq 'containers=4' <<<"$setup_output"
bash runtime.sh status | grep -Fq 'host_ports=0'
bash runtime.sh exercise | grep -Fq 'runtime_exercise=passed'
bash runtime.sh cleanup --expect-token "$lifecycle_token" | grep -Fq 'cleanup_proven=true'
lifecycle_token=''
bash runtime.sh status | grep -Fq 'state=absent project_resources=absent'
trap - EXIT
printf '%s\n' 'verification=passed mode=runtime products=prometheus,alertmanager,grafana cleanup=passed final_state=absent'
