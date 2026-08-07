#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kubeconfig="${project_root}/${KUBECONFIG_REL}"
deployment="deployment/payments-api"
namespace="team-a"
original="$(kubectl --kubeconfig "${kubeconfig}" get "${deployment}" -n "${namespace}" -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "${original}" == "atlas-platform-demo:1.0.0" ]] ||
  { echo "rollback_test=refused expected_image=atlas-platform-demo:1.0.0 actual=${original}" >&2; exit 2; }

restore() {
  kubectl --kubeconfig "${kubeconfig}" set image "${deployment}" service="${original}" -n "${namespace}" >/dev/null 2>&1 || true
  kubectl --kubeconfig "${kubeconfig}" rollout status "${deployment}" -n "${namespace}" --timeout=60s >/dev/null 2>&1 || true
}
trap restore EXIT

kubectl --kubeconfig "${kubeconfig}" set image "${deployment}" service=atlas-platform-demo:2.0.0-broken -n "${namespace}" >/dev/null
set +e
failure_output="$(kubectl --kubeconfig "${kubeconfig}" rollout status "${deployment}" -n "${namespace}" --timeout=12s 2>&1)"
failure_rc=$?
set -e
[[ "${failure_rc}" -ne 0 ]] || { echo "rollback_test=failed reason=bad-image-became-ready" >&2; exit 1; }
grep -Eqi "deadline exceeded|timed out" <<<"${failure_output}"

kubectl --kubeconfig "${kubeconfig}" rollout undo "${deployment}" -n "${namespace}" >/dev/null
kubectl --kubeconfig "${kubeconfig}" rollout status "${deployment}" -n "${namespace}" --timeout=120s >/dev/null
actual="$(kubectl --kubeconfig "${kubeconfig}" get "${deployment}" -n "${namespace}" -o jsonpath='{.spec.template.spec.containers[0].image}')"
[[ "${actual}" == "${original}" ]]
curl -fsS http://127.0.0.1:18080/version | grep -Fq '"1.0.0"'
trap - EXIT
echo "rollback_test=pass failed_image=observed restored_image=${actual} user_probe=pass"
