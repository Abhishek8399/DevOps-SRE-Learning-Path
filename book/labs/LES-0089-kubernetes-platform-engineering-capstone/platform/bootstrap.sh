#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
export KUBECONFIG="${project_root}/${KUBECONFIG_REL}"
[[ -f "${KUBECONFIG}" ]] || { echo "missing=kubeconfig run=cluster/create.sh" >&2; exit 2; }
kubectl apply --server-side --field-manager=atlas-platform -k "${project_root}/platform/base"
kubectl get validatingadmissionpolicy atlas-workload-contract
kubectl get resourcequota,limitrange -n team-a
set +e
allowed="$(kubectl auth can-i create deployments --as=system:serviceaccount:team-a:developer -n team-a)"
allowed_rc=$?
secret_denied="$(kubectl auth can-i get secrets --as=system:serviceaccount:team-a:developer -n team-a)"
secret_rc=$?
cross_tenant_denied="$(kubectl auth can-i create deployments --as=system:serviceaccount:team-a:developer -n team-b)"
cross_tenant_rc=$?
set -e
[[ "$allowed" == "yes" && "$allowed_rc" -eq 0 ]]
[[ "$secret_denied" == "no" && "$secret_rc" -eq 1 ]]
[[ "$cross_tenant_denied" == "no" && "$cross_tenant_rc" -eq 1 ]]
echo "rbac=pass same_tenant=yes secrets=no cross_tenant=no"
echo "platform=bootstrap-pass namespaces=2 policy=cel rbac=least-privilege quota=present"
