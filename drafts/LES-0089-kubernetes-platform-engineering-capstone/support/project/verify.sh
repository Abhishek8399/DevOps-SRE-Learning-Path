#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${project_root}/toolchain.env"
kind_bin="${project_root}/.tools/bin/kind"
source_path="drafts/LES-0089-kubernetes-platform-engineering-capstone/support/project/desired/team-a/payments-api.yaml"

[[ "${EUID}" -ne 0 ]] || { echo "verify=refused reason=root" >&2; exit 2; }
command -v git >/dev/null && command -v python3 >/dev/null &&
  command -v docker >/dev/null && command -v kubectl >/dev/null ||
  { echo "verify=refused reason=missing-prerequisite" >&2; exit 2; }

bash "${project_root}/tools/install-kind.sh"
if "${kind_bin}" get clusters | grep -Fxq "${CLUSTER_NAME}"; then
  echo "verify=refused reason=cluster-already-exists cleanup=bash-cluster/cleanup.sh" >&2
  exit 2
fi

cleanup_best_effort() {
  bash "${project_root}/cluster/cleanup.sh" >/dev/null 2>&1 || true
}
trap cleanup_best_effort EXIT

mapfile -t shell_files < <(find "${project_root}" -type f -name '*.sh' -print | sort)
bash -n "${shell_files[@]}"
python3 -m py_compile \
  "${project_root}/platformctl.py" \
  "${project_root}/ops/reconcile.py" \
  "${project_root}/ops/measure_slo.py" \
  "${project_root}/workload/server.py"
(cd "${project_root}" && python3 -m unittest discover -s tests -v)

temp_dir="$(mktemp -d)"
cleanup_temp() {
  [[ "${temp_dir}" == /tmp/tmp.* && -d "${temp_dir}" && ! -L "${temp_dir}" ]] || return 1
  rm -f -- "${temp_dir}/payments-api.yaml" "${temp_dir}/payments-api.json"
  rmdir -- "${temp_dir}"
}
cleanup_failure() {
  cleanup_temp >/dev/null 2>&1 || true
  cleanup_best_effort
}
trap cleanup_failure EXIT
python3 "${project_root}/platformctl.py" generate \
  --request "${project_root}/requests/payments-api.json" \
  --output "${temp_dir}/payments-api.yaml" \
  --catalog-output "${temp_dir}/payments-api.json"
cmp "${temp_dir}/payments-api.yaml" "${project_root}/desired/team-a/payments-api.yaml"
cmp "${temp_dir}/payments-api.json" "${project_root}/catalog/payments-api.json"
kubectl kustomize "${project_root}/platform/base" >/dev/null

bash "${project_root}/cluster/create.sh"
bash "${project_root}/platform/bootstrap.sh"
bash "${project_root}/workload/build-load.sh"
python3 "${project_root}/ops/reconcile.py" \
  --source "${source_path}" --revision HEAD \
  --kubeconfig "${project_root}/${KUBECONFIG_REL}"
kubectl --kubeconfig "${project_root}/${KUBECONFIG_REL}" \
  rollout status deployment/payments-api -n team-a --timeout=120s >/dev/null
curl -fsS http://127.0.0.1:18080/version | grep -Fq '"1.0.0"'
bash "${project_root}/ops/verify-denials.sh"
bash "${project_root}/ops/verify-drift.sh"
bash "${project_root}/ops/verify-rollback.sh"
python3 "${project_root}/ops/measure_slo.py" probe \
  --requests 100 --concurrency 5 --output "${project_root}/.state/probes.jsonl"
python3 "${project_root}/ops/measure_slo.py" evaluate \
  --input "${project_root}/.state/probes.jsonl" --availability 0.99 --latency-ms 200 \
  --output "${project_root}/.state/slo-receipt.jsonl"
bash "${project_root}/ops/verify-reconstruction.sh"

cleanup_temp
trap cleanup_best_effort EXIT
bash "${project_root}/cluster/cleanup.sh"
trap - EXIT
echo "verify=pass tests=12 nodes=3 policies=3 rbac=3 git_reconcile=true drift=true rollback=true probes=100 reconstruction=true external_calls=tool-download-and-image-pull-only production_actions=none"
echo "cleanup=pass cluster=absent state=absent workload_image=absent"
