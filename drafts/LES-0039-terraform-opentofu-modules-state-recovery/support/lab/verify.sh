#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
CLI_NAME="${1:-}"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0039-${CURRENT_UID}"

[[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
[[ "${CLI_NAME}" == "terraform" || "${CLI_NAME}" == "tofu" ]] || { printf 'usage: bash verify.sh <terraform|tofu>\n' >&2; exit 64; }

if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
  bash "${LAB}" cleanup
fi

bash "${LAB}" doctor "${CLI_NAME}" | grep -q 'state=absent'
bash "${LAB}" setup "${CLI_NAME}" | grep -q 'existing=false'
bash "${LAB}" setup "${CLI_NAME}" | grep -q 'existing=true'
bash "${LAB}" status | grep -q 'stage=v1'

bash "${LAB}" run init
bash "${LAB}" run plan-v1 | grep -q 'creates=2'
bash "${LAB}" run apply-v1 | grep -q 'stage=v1'
bash "${LAB}" run inspect-v1 | grep -q 'terraform_data.api'
bash "${LAB}" run stage-v2
bash "${LAB}" status | grep -q 'stage=v2'
bash "${LAB}" run plan-refactor | grep -q 'moves=2 creates=0 updates=0 deletes=0'
bash "${LAB}" run apply-refactor | grep -q 'stage=v2'
bash "${LAB}" run inspect-v2 | grep -q 'module.service.terraform_data.component'
bash "${LAB}" run backup | grep -q 'backup=protected'
bash "${LAB}" run corrupt | grep -q 'state=corrupted'
bash "${LAB}" run prove-refusal | grep -q 'corrupt_state=refused'
bash "${LAB}" run restore | grep -q 'stage=v2'
bash "${LAB}" run converge | grep -q 'converged=true changes=0'

printf 'unexpected\n' >"${STATE_DIR}/unexpected.txt"
if bash "${LAB}" status >/dev/null 2>&1; then
  printf 'failed=true reason=unexpected-entry-accepted\n' >&2
  exit 1
fi
rm -- "${STATE_DIR}/unexpected.txt"

bash "${LAB}" cleanup | grep -q 'state=absent removed=true'
bash "${LAB}" status | grep -q 'state=absent'
[[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'failed=true reason=state-remains\n' >&2; exit 1; }

printf 'verification=pass lesson=LES-0039 cli=%s state_absent=true\n' "${CLI_NAME}"
