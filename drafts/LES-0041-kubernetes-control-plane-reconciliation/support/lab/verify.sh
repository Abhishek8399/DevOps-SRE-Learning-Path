#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
MODEL="${SCRIPT_DIR}/model.py"
UID_VALUE="$(id -u)"
ROOT="/tmp/reliability-atlas-les0041-model-${UID_VALUE}"

fail() {
  printf 'verification=fail reason=%s\n' "$*" >&2
  exit 1
}

if [[ -e "${ROOT}" || -L "${ROOT}" ]]; then
  bash "${LAB}" cleanup
fi

bash "${LAB}" doctor
bash "${LAB}" setup
bash "${LAB}" setup

if python3 "${MODEL}" schedule "${ROOT}" >/dev/null 2>&1; then
  fail "out-of-order scheduling was accepted"
else
  printf 'invalid_transition_refusal=pass\n'
fi

bash "${LAB}" submit
bash "${LAB}" reconcile
bash "${LAB}" schedule
bash "${LAB}" kubelet
bash "${LAB}" update
bash "${LAB}" inject-controller-stall
bash "${LAB}" diagnose
bash "${LAB}" recover
bash "${LAB}" verify-state
bash "${LAB}" inject-unknown

if bash "${LAB}" cleanup; then
  fail "cleanup accepted an unexpected entry"
else
  printf 'cleanup_refusal=pass\n'
fi

bash "${LAB}" clear-unknown
bash "${LAB}" cleanup
[[ ! -e "${ROOT}" && ! -L "${ROOT}" ]] || fail "model root remains"
printf 'verification=pass state_absent=true runtime=kubernetes-model-only cluster_evidence=false\n'
