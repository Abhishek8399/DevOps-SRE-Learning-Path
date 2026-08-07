#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kind_bin="${project_root}/.tools/bin/kind"
state_dir="${project_root}/.state"

[[ "${EUID}" -ne 0 ]] || { echo "refusal=run-as-normal-user" >&2; exit 2; }
[[ "${state_dir}" == "${project_root}/.state" ]] || { echo "refusal=unsafe-state-path" >&2; exit 2; }
if [[ -x "${kind_bin}" ]] && "${kind_bin}" get clusters | grep -Fxq "${CLUSTER_NAME}"; then
  "${kind_bin}" delete cluster --name "${CLUSTER_NAME}"
fi
if [[ -e "${state_dir}" && -L "${state_dir}" ]]; then
  echo "refusal=symlink-state" >&2
  exit 2
fi
rm -rf -- "${state_dir}"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CLUSTER_NAME}(-|$)"; then
  echo "cleanup=failed reason=cluster-container-remains" >&2
  exit 1
fi
if docker image inspect atlas-platform-demo:1.0.0 >/dev/null 2>&1; then
  docker image rm atlas-platform-demo:1.0.0 >/dev/null
fi
echo "cleanup=pass cluster=absent state=absent workload_image=absent tool_and_node_cache=retained"
