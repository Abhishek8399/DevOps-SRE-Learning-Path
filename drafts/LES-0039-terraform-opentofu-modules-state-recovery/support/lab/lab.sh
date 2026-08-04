#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
FIXTURES="${SCRIPT_DIR}/fixtures"
GUARD="${FIXTURES}/guard.py"
CURRENT_UID="$(id -u)"
STATE_PARENT="/tmp"
STATE_DIR="/tmp/reliability-atlas-les0039-${CURRENT_UID}"

refuse_root() {
  [[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
}

require_tools() {
  local tool
  for tool in bash python3 id mktemp mv cp rm readlink stat sha256sum awk sed grep mkdir basename; do
    command -v "${tool}" >/dev/null 2>&1 || { printf 'refused=true reason=missing-tool tool=%s\n' "${tool}" >&2; exit 69; }
  done
  [[ -f "${GUARD}" && ! -L "${GUARD}" ]] || { printf 'refused=true reason=guard-invalid\n' >&2; exit 78; }
  python3 "${GUARD}" validate-fixtures "${FIXTURES}" >/dev/null
}

resolve_cli() {
  local requested="${1:-}" located resolved digest version
  [[ "${requested}" == "terraform" || "${requested}" == "tofu" ]] || {
    printf 'refused=true reason=cli-name-invalid expected=terraform-or-tofu\n' >&2; exit 64;
  }
  located="$(command -v -- "${requested}")" || { printf 'refused=true reason=cli-missing cli=%s\n' "${requested}" >&2; exit 69; }
  resolved="$(readlink -f -- "${located}")"
  [[ -f "${resolved}" && ! -L "${resolved}" ]] || { printf 'refused=true reason=cli-file-invalid\n' >&2; exit 78; }
  [[ "$(basename -- "${resolved}")" == "${requested}" || "$(basename -- "${resolved}")" == "${requested}.exe" ]] || {
    printf 'refused=true reason=cli-basename-invalid\n' >&2; exit 78;
  }
  digest="$(sha256sum -- "${resolved}" | awk '{print $1}')"
  version="$("${resolved}" version | sed -n '1p')"
  case "${requested}" in
    terraform) [[ "${version}" == "Terraform v"* ]] || { printf 'refused=true reason=cli-product-mismatch\n' >&2; exit 78; } ;;
    tofu) [[ "${version}" == "OpenTofu v"* ]] || { printf 'refused=true reason=cli-product-mismatch\n' >&2; exit 78; } ;;
  esac
  printf '%s\n%s\n%s\n%s\n' "${requested}" "${resolved}" "${version}" "${digest}"
}

validate_root() {
  [[ "${STATE_DIR}" == "/tmp/reliability-atlas-les0039-${CURRENT_UID}" ]] || { printf 'refused=true reason=state-path-invalid\n' >&2; exit 78; }
  [[ "$(readlink -f -- "${STATE_PARENT}")" == "/tmp" ]] || { printf 'refused=true reason=parent-invalid\n' >&2; exit 78; }
  python3 "${GUARD}" validate-state-root "${STATE_DIR}" --uid "${CURRENT_UID}" >/dev/null
}

load_cli() {
  validate_root
  mapfile -t CLI_INFO < <(python3 "${GUARD}" cli-info "${STATE_DIR}" --uid "${CURRENT_UID}")
  [[ "${#CLI_INFO[@]}" == "4" ]] || { printf 'refused=true reason=cli-record-invalid\n' >&2; exit 78; }
  CLI_NAME="${CLI_INFO[0]}"
  CLI_PATH="${CLI_INFO[1]}"
  CLI_VERSION="${CLI_INFO[2]}"
  export CHECKPOINT_DISABLE=1 TF_IN_AUTOMATION=1 TF_CLI_CONFIG_FILE="${STATE_DIR}/cli.tfrc"
}

doctor() {
  require_tools
  resolve_cli "${1:-}" >/dev/null
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_root
    printf 'ready=true state=owned-existing path=%s\n' "${STATE_DIR}"
  else
    printf 'ready=true state=absent path=%s\n' "${STATE_DIR}"
  fi
}

setup() {
  require_tools
  local requested="${1:-}" candidate
  mapfile -t resolved < <(resolve_cli "${requested}")
  [[ "${#resolved[@]}" == "4" ]] || { printf 'refused=true reason=cli-resolution-invalid\n' >&2; exit 78; }
  if [[ -e "${STATE_DIR}" || -L "${STATE_DIR}" ]]; then
    validate_root
    mapfile -t existing < <(python3 "${GUARD}" cli-info "${STATE_DIR}" --uid "${CURRENT_UID}")
    [[ "${existing[0]}" == "${resolved[0]}" && "${existing[3]}" == "${resolved[3]}" ]] || { printf 'refused=true reason=existing-cli-mismatch\n' >&2; exit 78; }
    printf 'state=ready existing=true cli=%s version=%s path=%s\n' "${existing[0]}" "${existing[2]}" "${STATE_DIR}"
    return 0
  fi
  candidate="$(mktemp -d "${STATE_PARENT}/reliability-atlas-les0039-${CURRENT_UID}.candidate.XXXXXX")"
  cleanup_candidate() {
    if [[ -n "${candidate:-}" && -d "${candidate}" && ! -L "${candidate}" ]]; then
      local real
      real="$(readlink -f -- "${candidate}")"
      if [[ "${real}" == "/tmp/reliability-atlas-les0039-${CURRENT_UID}.candidate."* && "$(stat -c '%u' -- "${real}")" == "${CURRENT_UID}" ]]; then rm -rf -- "${real}"; fi
    fi
  }
  trap cleanup_candidate EXIT
  mkdir -- "${candidate}/mirror"
  cp -- "${FIXTURES}/v1/main.tf" "${candidate}/main.tf"
  printf 'v1\n' >"${candidate}/stage.txt"
  printf 'LES-0039:%s\n' "${CURRENT_UID}" >"${candidate}/SENTINEL"
  python3 -c 'import json,sys; json.dump({"schemaVersion":1,"lessonId":"LES-0039","uid":int(sys.argv[1]),"statePath":sys.argv[2]},open(sys.argv[3],"x",encoding="utf-8"),indent=2)' "${CURRENT_UID}" "${STATE_DIR}" "${candidate}/manifest.json"
  python3 -c 'import json,sys; json.dump({"name":sys.argv[1],"path":sys.argv[2],"version":sys.argv[3],"sha256":sys.argv[4]},open(sys.argv[5],"x",encoding="utf-8"),indent=2)' "${resolved[0]}" "${resolved[1]}" "${resolved[2]}" "${resolved[3]}" "${candidate}/cli.json"
  printf 'provider_installation {\n  filesystem_mirror { path = "%s/mirror" }\n}\n' "${STATE_DIR}" >"${candidate}/cli.tfrc"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'refused=true reason=state-created-concurrently\n' >&2; exit 75; }
  mv -- "${candidate}" "${STATE_DIR}"
  candidate=""
  trap - EXIT
  validate_root
  printf 'state=ready existing=false cli=%s version=%s path=%s\n' "${resolved[0]}" "${resolved[2]}" "${STATE_DIR}"
}

status() {
  require_tools
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then printf 'state=absent path=%s\n' "${STATE_DIR}"; return 0; fi
  load_cli
  printf 'state=ready stage=%s cli=%s version=%s path=%s\n' "$(sed -n '1p' "${STATE_DIR}/stage.txt")" "${CLI_NAME}" "${CLI_VERSION}" "${STATE_DIR}"
}

require_stage() {
  local expected="${1}"
  [[ "$(sed -n '1p' "${STATE_DIR}/stage.txt")" == "${expected}" ]] || { printf 'refused=true reason=stage-mismatch expected=%s\n' "${expected}" >&2; exit 66; }
}

capture_state() {
  local stage="${1}" temporary="${STATE_DIR}/.state-view.json.tmp"
  "${CLI_PATH}" -chdir="${STATE_DIR}" state pull >"${temporary}"
  python3 "${GUARD}" inspect-state "${temporary}" --stage "${stage}" >/dev/null
  mv -- "${temporary}" "${STATE_DIR}/state-view.json"
  python3 "${GUARD}" inspect-state "${STATE_DIR}/state-view.json" --stage "${stage}"
}

run_case() {
  local case_name="${1:-}" result
  require_tools
  load_cli
  case "${case_name}" in
    init)
      require_stage v1
      "${CLI_PATH}" -chdir="${STATE_DIR}" fmt -check -diff
      "${CLI_PATH}" -chdir="${STATE_DIR}" init -input=false
      "${CLI_PATH}" -chdir="${STATE_DIR}" validate
      ;;
    plan-v1)
      require_stage v1
      [[ ! -e "${STATE_DIR}/terraform.tfstate" ]] || { printf 'refused=true reason=v1-state-already-exists\n' >&2; exit 66; }
      "${CLI_PATH}" -chdir="${STATE_DIR}" plan -input=false -out=v1.tfplan -no-color
      "${CLI_PATH}" -chdir="${STATE_DIR}" show -json v1.tfplan >"${STATE_DIR}/.v1-plan.json.tmp"
      python3 "${GUARD}" inspect-v1-plan "${STATE_DIR}/.v1-plan.json.tmp" >/dev/null
      mv -- "${STATE_DIR}/.v1-plan.json.tmp" "${STATE_DIR}/v1-plan.json"
      python3 "${GUARD}" inspect-v1-plan "${STATE_DIR}/v1-plan.json"
      ;;
    apply-v1)
      require_stage v1
      [[ -f "${STATE_DIR}/v1.tfplan" && ! -L "${STATE_DIR}/v1.tfplan" ]] || { printf 'refused=true reason=v1-plan-missing\n' >&2; exit 66; }
      python3 "${GUARD}" inspect-v1-plan "${STATE_DIR}/v1-plan.json" >/dev/null
      "${CLI_PATH}" -chdir="${STATE_DIR}" apply -input=false -auto-approve -no-color v1.tfplan
      capture_state v1
      ;;
    inspect-v1)
      require_stage v1
      capture_state v1
      ;;
    stage-v2)
      require_stage v1
      capture_state v1 >/dev/null
      cp -- "${STATE_DIR}/state-view.json" "${STATE_DIR}/.v1-state.json.tmp"
      python3 "${GUARD}" inspect-state "${STATE_DIR}/.v1-state.json.tmp" --stage v1 >/dev/null
      mv -- "${STATE_DIR}/.v1-state.json.tmp" "${STATE_DIR}/v1-state.json"
      [[ ! -e "${STATE_DIR}/modules" && ! -L "${STATE_DIR}/modules" ]] || { printf 'refused=true reason=module-directory-exists\n' >&2; exit 66; }
      mkdir -p -- "${STATE_DIR}/modules/service"
      cp -- "${FIXTURES}/v2/modules/service/main.tf" "${STATE_DIR}/modules/service/main.tf"
      cp -- "${FIXTURES}/v2/main.tf" "${STATE_DIR}/main.tf"
      printf 'v2\n' >"${STATE_DIR}/stage.txt"
      ;;
    plan-refactor)
      require_stage v2
      "${CLI_PATH}" -chdir="${STATE_DIR}" init -input=false
      "${CLI_PATH}" -chdir="${STATE_DIR}" fmt -check -diff
      "${CLI_PATH}" -chdir="${STATE_DIR}" validate
      "${CLI_PATH}" -chdir="${STATE_DIR}" plan -input=false -out=refactor.tfplan -no-color
      "${CLI_PATH}" -chdir="${STATE_DIR}" show -json refactor.tfplan >"${STATE_DIR}/.refactor-plan.json.tmp"
      python3 "${GUARD}" inspect-refactor-plan "${STATE_DIR}/.refactor-plan.json.tmp" >/dev/null
      mv -- "${STATE_DIR}/.refactor-plan.json.tmp" "${STATE_DIR}/refactor-plan.json"
      python3 "${GUARD}" inspect-refactor-plan "${STATE_DIR}/refactor-plan.json"
      ;;
    apply-refactor)
      require_stage v2
      [[ -f "${STATE_DIR}/refactor.tfplan" && ! -L "${STATE_DIR}/refactor.tfplan" ]] || { printf 'refused=true reason=refactor-plan-missing\n' >&2; exit 66; }
      python3 "${GUARD}" inspect-refactor-plan "${STATE_DIR}/refactor-plan.json" >/dev/null
      "${CLI_PATH}" -chdir="${STATE_DIR}" apply -input=false -auto-approve -no-color refactor.tfplan
      capture_state v2
      python3 "${GUARD}" compare-states "${STATE_DIR}/v1-state.json" "${STATE_DIR}/state-view.json"
      ;;
    inspect-v2)
      require_stage v2
      capture_state v2
      ;;
    backup)
      require_stage v2
      capture_state v2 >/dev/null
      cp -- "${STATE_DIR}/state-view.json" "${STATE_DIR}/.protected.tfstate.tmp"
      python3 "${GUARD}" inspect-state "${STATE_DIR}/.protected.tfstate.tmp" --stage v2 >/dev/null
      mv -- "${STATE_DIR}/.protected.tfstate.tmp" "${STATE_DIR}/protected.tfstate"
      (cd -- "${STATE_DIR}" && sha256sum protected.tfstate >protected.sha256)
      printf 'backup=protected file=protected.tfstate\n'
      ;;
    corrupt)
      require_stage v2
      (cd -- "${STATE_DIR}" && sha256sum -c protected.sha256 >/dev/null)
      python3 "${GUARD}" inspect-state "${STATE_DIR}/protected.tfstate" --stage v2 >/dev/null
      python3 "${GUARD}" inspect-state "${STATE_DIR}/terraform.tfstate" --stage v2 >/dev/null
      printf '{broken' >"${STATE_DIR}/terraform.tfstate"
      printf 'state=corrupted bounded=true\n'
      ;;
    prove-refusal)
      require_stage v2
      if "${CLI_PATH}" -chdir="${STATE_DIR}" state list >"${STATE_DIR}/.corrupt-output.tmp" 2>&1; then
        printf 'failed=true reason=corrupt-state-accepted\n' >&2; exit 1
      fi
      mv -- "${STATE_DIR}/.corrupt-output.tmp" "${STATE_DIR}/corrupt-output.txt"
      printf 'corrupt_state=refused\n'
      ;;
    restore)
      require_stage v2
      (cd -- "${STATE_DIR}" && sha256sum -c protected.sha256 >/dev/null)
      python3 "${GUARD}" inspect-state "${STATE_DIR}/protected.tfstate" --stage v2 >/dev/null
      cp -- "${STATE_DIR}/protected.tfstate" "${STATE_DIR}/.terraform.tfstate.restore"
      mv -- "${STATE_DIR}/.terraform.tfstate.restore" "${STATE_DIR}/terraform.tfstate"
      capture_state v2
      ;;
    converge)
      require_stage v2
      capture_state v2 >/dev/null
      if "${CLI_PATH}" -chdir="${STATE_DIR}" plan -input=false -detailed-exitcode -no-color; then result=0; else result=$?; fi
      [[ "${result}" == "0" ]] || { printf 'failed=true reason=not-converged exit=%s\n' "${result}" >&2; exit 1; }
      printf 'converged=true changes=0\n'
      ;;
    *)
      printf 'usage: bash lab.sh run <init|plan-v1|apply-v1|inspect-v1|stage-v2|plan-refactor|apply-refactor|inspect-v2|backup|corrupt|prove-refusal|restore|converge>\n' >&2
      exit 64
      ;;
  esac
  validate_root
}

cleanup() {
  require_tools
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'state=absent removed=false path=%s\n' "${STATE_DIR}"
    return 0
  fi
  validate_root
  local real
  real="$(readlink -f -- "${STATE_DIR}")"
  [[ "${real}" == "/tmp/reliability-atlas-les0039-${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-path-invalid\n' >&2; exit 78; }
  [[ "$(stat -c '%u' -- "${real}")" == "${CURRENT_UID}" ]] || { printf 'refused=true reason=cleanup-owner-invalid\n' >&2; exit 78; }
  rm -rf -- "${real}"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'failed=true reason=cleanup-incomplete\n' >&2; exit 74; }
  printf 'state=absent removed=true path=%s\n' "${STATE_DIR}"
}

refuse_root
case "${1:-}" in
  doctor) doctor "${2:-}" ;;
  setup) setup "${2:-}" ;;
  status) status ;;
  run) run_case "${2:-}" ;;
  verify) exec bash "${SCRIPT_DIR}/verify.sh" "${2:-}" ;;
  cleanup) cleanup ;;
  *) printf 'usage: bash lab.sh <doctor CLI|setup CLI|status|run CASE|verify CLI|cleanup>\n' >&2; exit 64 ;;
esac
