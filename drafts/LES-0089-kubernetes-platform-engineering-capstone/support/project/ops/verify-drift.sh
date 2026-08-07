#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kubeconfig="${project_root}/${KUBECONFIG_REL}"
source_path="drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml"
original="$(kubectl --kubeconfig "${kubeconfig}" get deployment payments-api -n team-a -o jsonpath='{.spec.replicas}')"
[[ "${original}" == "2" ]] || { echo "drift_test=refused expected_replicas=2 actual=${original}" >&2; exit 2; }

restore() {
  kubectl --kubeconfig "${kubeconfig}" scale deployment/payments-api -n team-a --replicas="${original}" >/dev/null 2>&1 || true
}
trap restore EXIT

kubectl --kubeconfig "${kubeconfig}" scale deployment/payments-api -n team-a --replicas=1 >/dev/null
[[ "$(kubectl --kubeconfig "${kubeconfig}" get deployment payments-api -n team-a -o jsonpath='{.spec.replicas}')" == "1" ]]
python3 "${project_root}/ops/reconcile.py" \
  --source "${source_path}" \
  --revision HEAD \
  --kubeconfig "${kubeconfig}"
actual="$(kubectl --kubeconfig "${kubeconfig}" get deployment payments-api -n team-a -o jsonpath='{.spec.replicas}')"
[[ "${actual}" == "2" ]]
kubectl --kubeconfig "${kubeconfig}" rollout status deployment/payments-api -n team-a --timeout=120s >/dev/null
trap - EXIT
echo "drift_test=pass injected_replicas=1 reconciled_replicas=2 source=git-head"
