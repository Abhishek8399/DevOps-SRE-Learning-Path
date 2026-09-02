#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
LAB="${SCRIPT_DIR}/lab.sh"
GUARD="${SCRIPT_DIR}/fixtures/guard.py"
CLI_NAME="${1:-}"
CURRENT_UID="$(id -u)"
STATE_DIR="/tmp/reliability-atlas-les0038-${CURRENT_UID}"
PASSED=0

pass() { PASSED=$((PASSED + 1)); printf 'assertion=pass name=%s\n' "$1"; }
fail() { printf 'assertion=fail name=%s detail=%s\n' "$1" "$2" >&2; exit 1; }
contains() {
  local name="$1" value="$2" expected="$3"
  [[ "${value}" == *"${expected}"* ]] || fail "${name}" "expected=${expected}"
  pass "${name}"
}
cleanup_on_exit() {
  local code=$?
  if [[ "${CURRENT_UID}" != "0" && ( -e "${STATE_DIR}" || -L "${STATE_DIR}" ) ]]; then
    rm -f -- "${STATE_DIR}/UNEXPECTED" 2>/dev/null || true
    bash "${LAB}" cleanup >/dev/null 2>&1 || true
  fi
  exit "${code}"
}
trap cleanup_on_exit EXIT

[[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
[[ "${CLI_NAME}" == "terraform" || "${CLI_NAME}" == "tofu" ]] || { printf 'usage: bash verify.sh <terraform|tofu>\n' >&2; exit 64; }
python3 "${GUARD}" validate-fixtures "${SCRIPT_DIR}/fixtures" >/dev/null
pass fixture-contract
python3 -c 'import pathlib,sys; compile(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"), sys.argv[1], "exec")' "${GUARD}"
pass guard-compiles-in-memory

bash "${LAB}" cleanup >/dev/null
contains doctor-absent "$(bash "${LAB}" doctor "${CLI_NAME}")" 'state=absent'
if bash "${LAB}" run fmt >/dev/null 2>&1; then fail run-refuses-absent 'run unexpectedly succeeded'; fi
pass run-refuses-absent
contains setup-new "$(bash "${LAB}" setup "${CLI_NAME}")" 'existing=false'
contains setup-idempotent "$(bash "${LAB}" setup "${CLI_NAME}")" 'existing=true'
contains status-ready "$(bash "${LAB}" status)" "cli=${CLI_NAME}"

bash "${LAB}" run fmt >/dev/null
pass fmt-check
init_output="$(bash "${LAB}" run init)"
contains init-built-in "${init_output}" 'builtin/terraform is built in'
validate_output="$(bash "${LAB}" run validate)"
contains validate-success "${validate_output}" 'configuration is valid'
test_output="$(bash "${LAB}" run test)"
contains tests-two-pass "${test_output}" '2 passed, 0 failed'
plan_output="$(bash "${LAB}" run plan)"
contains plan-three-create "${plan_output}" 'Plan: 3 to add, 0 to change, 0 to destroy.'
inspect_output="$(bash "${LAB}" run inspect)"
contains inspect-three "${inspect_output}" 'changes=3'
contains inspect-address "${inspect_output}" 'terraform_data.service["api"]'
contains graph-catalog "$(bash "${LAB}" run graph)" 'catalog=true'
contains negative-two "$(bash "${LAB}" run negative)" 'validations=2'

[[ -f "${STATE_DIR}/review.tfplan" && -f "${STATE_DIR}/review.json" && -f "${STATE_DIR}/graph.dot" ]] || fail evidence-files 'expected evidence missing'
pass evidence-files
[[ ! -e "${STATE_DIR}/terraform.tfstate" && ! -e "${STATE_DIR}/.terraform.lock.hcl" ]] || fail no-state-lock 'unexpected state or lock'
pass no-state-lock
python3 "${GUARD}" validate-plan "${STATE_DIR}/review.json" >/dev/null
pass plan-contract

printf 'unexpected\n' >"${STATE_DIR}/UNEXPECTED"
if bash "${LAB}" status >/dev/null 2>&1; then fail unexpected-entry-refused 'status accepted unexpected entry'; fi
pass unexpected-entry-refused
rm -f -- "${STATE_DIR}/UNEXPECTED"
contains status-recovers "$(bash "${LAB}" status)" 'state=ready'
contains cleanup-removed "$(bash "${LAB}" cleanup)" 'removed=true'
contains cleanup-absent "$(bash "${LAB}" status)" 'state=absent'
trap - EXIT
printf 'verification=pass assertions=%s cli=%s state_absent=true network=none provider=none backend=none apply=never\n' "${PASSED}" "${CLI_NAME}"
