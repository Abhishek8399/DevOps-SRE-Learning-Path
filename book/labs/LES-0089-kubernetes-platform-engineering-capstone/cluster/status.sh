#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
export KUBECONFIG="${project_root}/${KUBECONFIG_REL}"
kubectl cluster-info
kubectl get nodes -o custom-columns=NAME:.metadata.name,ROLE:.metadata.labels.node-role\\.kubernetes\\.io/control-plane,READY:.status.conditions[-1].status,VERSION:.status.nodeInfo.kubeletVersion
kubectl get --raw=/readyz
echo
echo "cluster=status-pass name=${CLUSTER_NAME}"
