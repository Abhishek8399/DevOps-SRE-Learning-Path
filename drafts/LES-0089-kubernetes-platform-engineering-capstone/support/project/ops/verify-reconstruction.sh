#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kubeconfig="${project_root}/${KUBECONFIG_REL}"
source_path="drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml"

wait_user_probe() {
  local attempt
  for attempt in $(seq 1 30); do
    if curl -fsS --max-time 2 http://127.0.0.1:18080/version 2>/dev/null | grep -Fq '"1.0.0"'; then
      echo "user_probe=pass attempt=${attempt}"
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_user_probe ||
  { echo "reconstruction=refused reason=baseline-user-probe" >&2; exit 2; }

recover() {
  bash "${project_root}/platform/bootstrap.sh" >/dev/null 2>&1 || true
  python3 "${project_root}/ops/reconcile.py" \
    --source "${source_path}" --revision HEAD --kubeconfig "${kubeconfig}" >/dev/null 2>&1 || true
  kubectl --kubeconfig "${kubeconfig}" rollout status deployment/payments-api -n team-a --timeout=60s >/dev/null 2>&1 || true
}
trap recover EXIT

kubectl --kubeconfig "${kubeconfig}" delete namespace team-a --wait=true --timeout=120s >/dev/null
if kubectl --kubeconfig "${kubeconfig}" get namespace team-a >/dev/null 2>&1; then
  echo "reconstruction=failed reason=namespace-remains" >&2
  exit 1
fi

bash "${project_root}/platform/bootstrap.sh" >/dev/null
python3 "${project_root}/ops/reconcile.py" \
  --source "${source_path}" --revision HEAD --kubeconfig "${kubeconfig}"
kubectl --kubeconfig "${kubeconfig}" rollout status deployment/payments-api -n team-a --timeout=120s >/dev/null
wait_user_probe
[[ "$(kubectl --kubeconfig "${kubeconfig}" get resourcequota tenant-budget -n team-a -o name)" == "resourcequota/tenant-budget" ]]
trap - EXIT
echo "reconstruction=pass deleted=team-a restored=platform-controls,workload user_probe=pass data_restore=not-exercised"
