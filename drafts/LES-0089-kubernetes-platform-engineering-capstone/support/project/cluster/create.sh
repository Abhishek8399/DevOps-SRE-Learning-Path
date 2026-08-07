#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kind_bin="${project_root}/.tools/bin/kind"
kubeconfig="${project_root}/${KUBECONFIG_REL}"

[[ "${EUID}" -ne 0 ]] || { echo "refusal=run-as-normal-user" >&2; exit 2; }
command -v docker >/dev/null || { echo "missing=docker" >&2; exit 2; }
command -v kubectl >/dev/null || { echo "missing=kubectl" >&2; exit 2; }
docker info >/dev/null || { echo "docker_daemon=unavailable" >&2; exit 2; }
[[ -x "${kind_bin}" ]] || { echo "missing=project-kind run=tools/install-kind.sh" >&2; exit 2; }
[[ "$(sha256sum "${kind_bin}" | awk '{print $1}')" == "${KIND_LINUX_AMD64_SHA256}" ]] ||
  { echo "kind=rejected reason=checksum" >&2; exit 2; }

mkdir -p "${project_root}/.state"
if "${kind_bin}" get clusters | grep -Fxq "${CLUSTER_NAME}"; then
  echo "cluster=present name=${CLUSTER_NAME}"
else
  "${kind_bin}" create cluster \
    --name "${CLUSTER_NAME}" \
    --config "${project_root}/cluster/kind.yaml" \
    --image "${KIND_NODE_IMAGE}" \
    --kubeconfig "${kubeconfig}" \
    --wait 180s
fi

chmod 0600 "${kubeconfig}"
KUBECONFIG="${kubeconfig}" kubectl wait --for=condition=Ready nodes --all --timeout=180s
KUBECONFIG="${kubeconfig}" kubectl get nodes -o wide
echo "cluster=create-pass name=${CLUSTER_NAME} api=loopback kubeconfig=project-local"
