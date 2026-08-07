#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${project_root}/toolchain.env"
kubeconfig="${project_root}/${KUBECONFIG_REL}"
[[ -f "${kubeconfig}" ]] || { echo "missing=kubeconfig" >&2; exit 2; }

expect_denial() {
  local label="${1}" pattern="${2}" manifest="${3}"
  local output rc
  set +e
  output="$(kubectl --kubeconfig "${kubeconfig}" apply --dry-run=server -f "${manifest}" 2>&1)"
  rc=$?
  set -e
  [[ "${rc}" -ne 0 ]] || { echo "denial=failed label=${label} reason=unexpected-accept" >&2; exit 1; }
  grep -Eqi "${pattern}" <<<"${output}" ||
    { echo "denial=failed label=${label} reason=wrong-mechanism output=${output}" >&2; exit 1; }
  echo "denial=pass label=${label} rc=${rc}"
}

expect_denial cel-owner "owner label is required" "${project_root}/failures/unsafe-deployment.yaml"
expect_denial pod-security "violates PodSecurity" "${project_root}/failures/privileged-pod.yaml"
expect_denial resource-quota "exceeded quota" "${project_root}/failures/over-quota-pod.yaml"
echo "denials=pass mechanisms=3 resources_created=none"
