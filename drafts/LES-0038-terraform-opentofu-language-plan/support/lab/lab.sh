#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
FIXTURES="${SCRIPT_DIR}/fixtures"
GUARD="${FIXTURES}/guard.py"
CURRENT_UID="$(id -u)"
STATE_PARENT="/tmp"
STATE_DIR="/tmp/reliability-atlas-les0038-${CURRENT_UID}"

refuse_root() {
  [[ "${CURRENT_UID}" != "0" ]] || { printf 'refused=true reason=root-not-required\n' >&2; exit 77; }
}

require_tools() {
  local tool
  for tool in bash python3 id mktemp mv cp rm readlink stat find sha256sum awk sed grep mkdir basename; do
    command -v "${tool}" >/dev/null 2>&1 || { printf 'refused=true reason=missing-tool tool=%s\n' "${tool}" >&2; exit 69; }
  done
  [[ -f "${GUARD}" && ! -L "${GUARD}" ]] || { printf 'refused=true reason=guard-invalid\n' >&2; exit 78; }
  python3 "${GUARD}" validate-fixtures "${FIXTURES}" >/dev/null
}

resolve_cli() {
  local requested="${1:-}"
  [[ "${requested}" == "terraform" || "${requested}" == "tofu" ]] || {
    printf 'refused=true reason=cli-name-invalid expected=terraform-or-tofu\n' >&2
    exit 64
  }
  local located resolved digest version
  located="$(command -v -- "${requested}")" || { printf 'refused=true reason=cli-missing cli=%s\n' "${requested}" >&2; exit 69; }
  resolved="$(readlink -f -- "${located}")"
  [[ -f "${resolved}" && ! -L "${resolved}" ]] || { printf 'refused=true reason=cli-file-invalid\n' >&2; exit 78; }
  [[ "$(basename -- "${resolved}")" == "${requested}" || "$(basename -- "${resolved}")" == "${requested}.exe" ]] || {
    printf 'refused=true reason=cli-basename-invalid\n' >&2; exit 78;
  }
  digest="$(sha256sum -- "${resolved}" | awk '{print $1}')"
  version="$("${resolved}" version | sed -n '1p')"
  [[ "${version}" == "Terraform v"* || "${version}" == "OpenTofu v"* ]] || { printf 'refused=true reason=cli-version-invalid\n' >&2; exit 78; }
  printf '%s\n%s\n%s\n%s\n' "${requested}" "${resolved}" "${version}" "${digest}"
}

validate_state() {
  [[ "${STATE_DIR}" == "/tmp/reliability-atlas-les0038-${CURRENT_UID}" ]] || { printf 'refused=true reason=state-path-invalid\n' >&2; exit 78; }
  [[ "$(readlink -f -- "${STATE_PARENT}")" == "/tmp" ]] || { printf 'refused=true reason=parent-invalid\n' >&2; exit 78; }
  python3 "${GUARD}" validate-state "${STATE_DIR}" --uid "${CURRENT_UID}" >/dev/null
}

load_cli() {
  validate_state
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
    validate_state
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
    validate_state
    mapfile -t existing < <(python3 "${GUARD}" cli-info "${STATE_DIR}" --uid "${CURRENT_UID}")
    [[ "${existing[0]}" == "${resolved[0]}" && "${existing[3]}" == "${resolved[3]}" ]] || {
      printf 'refused=true reason=existing-cli-mismatch\n' >&2; exit 78;
    }
    printf 'state=ready existing=true cli=%s version=%s path=%s\n' "${existing[0]}" "${existing[2]}" "${STATE_DIR}"
    return 0
  fi
  candidate="$(mktemp -d "${STATE_PARENT}/reliability-atlas-les0038-${CURRENT_UID}.candidate.XXXXXX")"
  cleanup_candidate() {
    if [[ -n "${candidate:-}" && -d "${candidate}" && ! -L "${candidate}" ]]; then
      local real
      real="$(readlink -f -- "${candidate}")"
      if [[ "${real}" == "/tmp/reliability-atlas-les0038-${CURRENT_UID}.candidate."* && "$(stat -c '%u' -- "${real}")" == "${CURRENT_UID}" ]]; then
        rm -rf -- "${real}"
      fi
    fi
  }
  trap cleanup_candidate EXIT
  mkdir -- "${candidate}/tests" "${candidate}/mirror"
  cp -- "${FIXTURES}/main.tf" "${FIXTURES}/valid.tfvars" "${FIXTURES}/invalid.tfvars" "${candidate}/"
  cp -- "${FIXTURES}/tests/language.tftest.hcl" "${candidate}/tests/"
  printf 'LES-0038:%s\n' "${CURRENT_UID}" >"${candidate}/SENTINEL"
  python3 -c 'import json,sys; json.dump({"schemaVersion":1,"lessonId":"LES-0038","uid":int(sys.argv[1]),"statePath":sys.argv[2]},open(sys.argv[3],"x",encoding="utf-8"),indent=2)' "${CURRENT_UID}" "${STATE_DIR}" "${candidate}/manifest.json"
  python3 -c 'import json,sys; json.dump({"name":sys.argv[1],"path":sys.argv[2],"version":sys.argv[3],"sha256":sys.argv[4]},open(sys.argv[5],"x",encoding="utf-8"),indent=2)' "${resolved[0]}" "${resolved[1]}" "${resolved[2]}" "${resolved[3]}" "${candidate}/cli.json"
  printf 'provider_installation {\n  filesystem_mirror { path = "%s/mirror" }\n}\n' "${STATE_DIR}" >"${candidate}/cli.tfrc"
  [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]] || { printf 'refused=true reason=state-created-concurrently\n' >&2; exit 75; }
  mv -- "${candidate}" "${STATE_DIR}"
  candidate=""
  trap - EXIT
  validate_state
  printf 'state=ready existing=false cli=%s version=%s path=%s\n' "${resolved[0]}" "${resolved[2]}" "${STATE_DIR}"
}

status() {
  require_tools
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then
    printf 'state=absent path=%s\n' "${STATE_DIR}"
    return 0
  fi
  load_cli
  printf 'state=ready cli=%s version=%s path=%s\n' "${CLI_NAME}" "${CLI_VERSION}" "${STATE_DIR}"
}

run_case() {
  local case_name="${1:-}"
  require_tools
  load_cli
  case "${case_name}" in
    fmt) "${CLI_PATH}" -chdir="${STATE_DIR}" fmt -check -diff ;;
    init) "${CLI_PATH}" -chdir="${STATE_DIR}" init -backend=false -input=false ;;
    validate) "${CLI_PATH}" -chdir="${STATE_DIR}" validate ;;
    test) "${CLI_PATH}" -chdir="${STATE_DIR}" test -no-color ;;
    plan) "${CLI_PATH}" -chdir="${STATE_DIR}" plan -input=false -lock=false -refresh=false -var-file=valid.tfvars -out=review.tfplan -no-color ;;
    inspect)
      [[ -f "${STATE_DIR}/review.tfplan" && ! -L "${STATE_DIR}/review.tfplan" ]] || { printf 'refused=true reason=plan-missing\n' >&2; exit 66; }
      "${CLI_PATH}" -chdir="${STATE_DIR}" show -json review.tfplan >"${STATE_DIR}/.review.json.tmp"
      mv -- "${STATE_DIR}/.review.json.tmp" "${STATE_DIR}/review.json"
      python3 "${GUARD}" validate-plan "${STATE_DIR}/review.json"
      ;;
    graph)
      [[ -f "${STATE_DIR}/review.tfplan" && ! -L "${STATE_DIR}/review.tfplan" ]] || { printf 'refused=true reason=plan-missing\n' >&2; exit 66; }
      "${CLI_PATH}" -chdir="${STATE_DIR}" graph -type=plan -plan=review.tfplan >"${STATE_DIR}/.graph.dot.tmp"
      mv -- "${STATE_DIR}/.graph.dot.tmp" "${STATE_DIR}/graph.dot"
      grep -q 'terraform_data.catalog' "${STATE_DIR}/graph.dot"
      printf 'graph=valid catalog=true\n'
      ;;
    negative)
      if "${CLI_PATH}" -chdir="${STATE_DIR}" plan -input=false -lock=false -refresh=false -var-file=invalid.tfvars -no-color >"${STATE_DIR}/.invalid-output.tmp" 2>&1; then
        printf 'failed=true reason=invalid-input-accepted\n' >&2; exit 1
      fi
      mv -- "${STATE_DIR}/.invalid-output.tmp" "${STATE_DIR}/invalid-output.txt"
      grep -q 'environment must be' "${STATE_DIR}/invalid-output.txt"
      grep -q 'every service needs an unprivileged port' "${STATE_DIR}/invalid-output.txt"
      printf 'negative=refused validations=2\n'
      ;;
    *) printf 'usage: bash lab.sh run <fmt|init|validate|test|plan|inspect|graph|negative>\n' >&2; exit 64 ;;
  esac
  validate_state
}

cleanup() {
  require_tools
  if [[ ! -e "${STATE_DIR}" && ! -L "${STATE_DIR}" ]]; then printf 'state=absent removed=false path=%s\n' "${STATE_DIR}"; return 0; fi
  validate_state
  local real
  real="$(readlink -f -- "${STATE_DIR}")"
  [[ "${real}" == "/tmp/reliability-atlas-les0038-${CURRENT_UID}" && "$(stat -c '%u' -- "${real}")" == "${CURRENT_UID}" ]] || {
    printf 'refused=true reason=cleanup-boundary-invalid\n' >&2; exit 78;
  }
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
