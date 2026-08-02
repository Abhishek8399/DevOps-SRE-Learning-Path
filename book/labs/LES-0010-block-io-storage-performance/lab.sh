#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

readonly LESSON_ID="LES-0010"
readonly PREFIX="reliability-atlas-les0010"
SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly FIXTURE_SOURCE="${SCRIPT_DIR}/fixtures/io_model.py"
CURRENT_UID="$(id -u)"
readonly CURRENT_UID
readonly STATE_FILE="/tmp/${PREFIX}-${CURRENT_UID}.state"

die() {
  printf 'refused=true reason=%s\n' "$1" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing-command-${1}"
}

mode_of() {
  stat -c '%a' -- "$1"
}

owner_of() {
  stat -c '%u' -- "$1"
}

links_of() {
  stat -c '%h' -- "$1"
}

require_non_root() {
  [[ "$CURRENT_UID" != "0" ]] || die "root-not-supported"
}

require_tmp_boundary() {
  [[ -d /tmp && ! -L /tmp ]] || die "tmp-not-real-directory"
  [[ "$(realpath -- /tmp)" == "/tmp" ]] || die "tmp-realpath-mismatch"
  [[ "$(owner_of /tmp)" == "0" ]] || die "tmp-owner-not-root"
  [[ "$(mode_of /tmp)" == "1777" ]] || die "tmp-mode-not-1777"
}

require_source() {
  [[ -f "$FIXTURE_SOURCE" && ! -L "$FIXTURE_SOURCE" ]] || die "fixture-not-regular"
  [[ "$(links_of "$FIXTURE_SOURCE")" == "1" ]] || die "fixture-link-count"
  python3 "$FIXTURE_SOURCE" --help >/dev/null 2>&1 || die "fixture-python-invalid"
}

preflight() {
  for name in awk bash basename chmod cmp cp dirname find grep id mktemp mv python3 realpath rm rmdir sed sha256sum stat; do
    need_command "$name"
  done
  require_non_root
  require_tmp_boundary
  require_source
}

descriptor_is_safe() {
  [[ -e "$STATE_FILE" ]] || return 1
  [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]] || die "descriptor-not-regular"
  [[ "$(owner_of "$STATE_FILE")" == "$CURRENT_UID" ]] || die "descriptor-owner-mismatch"
  [[ "$(mode_of "$STATE_FILE")" == "600" ]] || die "descriptor-mode-not-600"
  [[ "$(links_of "$STATE_FILE")" == "1" ]] || die "descriptor-link-count"
}

read_descriptor() {
  descriptor_is_safe || die "state-absent"
  local line1 line2 line3 line4 extra
  IFS= read -r line1 < "$STATE_FILE" || die "descriptor-read-failed"
  IFS= read -r line2 < <(sed -n '2p' -- "$STATE_FILE") || die "descriptor-read-failed"
  IFS= read -r line3 < <(sed -n '3p' -- "$STATE_FILE") || die "descriptor-read-failed"
  IFS= read -r line4 < <(sed -n '4p' -- "$STATE_FILE") || die "descriptor-read-failed"
  extra="$(sed -n '5p' -- "$STATE_FILE")"
  [[ -z "$extra" ]] || die "descriptor-extra-field"
  [[ "$line1" == "lesson_id=${LESSON_ID}" ]] || die "descriptor-lesson-mismatch"
  [[ "$line2" == "uid=${CURRENT_UID}" ]] || die "descriptor-uid-mismatch"
  [[ "$line3" == root=* ]] || die "descriptor-root-missing"
  [[ "$line4" == "schema=1" ]] || die "descriptor-schema-mismatch"
  LAB_ROOT="${line3#root=}"
  [[ "$LAB_ROOT" == "/tmp/${PREFIX}-${CURRENT_UID}-"* ]] || die "root-prefix-mismatch"
  [[ "$LAB_ROOT" != *$'\n'* && "$LAB_ROOT" != *$'\r'* ]] || die "root-control-character"
}

require_regular_owned_file() {
  local path="$1"
  local expected_mode="$2"
  [[ -f "$path" && ! -L "$path" ]] || die "unsafe-file-$(basename -- "$path")"
  [[ "$(owner_of "$path")" == "$CURRENT_UID" ]] || die "file-owner-$(basename -- "$path")"
  [[ "$(mode_of "$path")" == "$expected_mode" ]] || die "file-mode-$(basename -- "$path")"
  [[ "$(links_of "$path")" == "1" ]] || die "file-link-count-$(basename -- "$path")"
}

require_root() {
  [[ -d "$LAB_ROOT" && ! -L "$LAB_ROOT" ]] || die "root-not-real-directory"
  [[ "$(realpath -- "$LAB_ROOT")" == "$LAB_ROOT" ]] || die "root-realpath-mismatch"
  [[ "$(owner_of "$LAB_ROOT")" == "$CURRENT_UID" ]] || die "root-owner-mismatch"
  [[ "$(mode_of "$LAB_ROOT")" == "700" ]] || die "root-mode-not-700"
}

expected_sentinel() {
  printf 'lesson_id=%s\nuid=%s\nroot=%s\n' "$LESSON_ID" "$CURRENT_UID" "$LAB_ROOT"
}

validate_state() {
  read_descriptor
  require_root
  require_regular_owned_file "$LAB_ROOT/.sentinel" 600
  cmp -s -- <(expected_sentinel) "$LAB_ROOT/.sentinel" || die "sentinel-content-mismatch"
  require_regular_owned_file "$LAB_ROOT/io_model.py" 600
  require_regular_owned_file "$LAB_ROOT/model.sha256" 600
  local recorded actual
  recorded="$(sed -n '1p' -- "$LAB_ROOT/model.sha256")"
  [[ "$recorded" =~ ^[0-9a-f]{64}$ ]] || die "manifest-format"
  [[ -z "$(sed -n '2p' -- "$LAB_ROOT/model.sha256")" ]] || die "manifest-extra-field"
  actual="$(sha256sum -- "$LAB_ROOT/io_model.py")"
  actual="${actual%% *}"
  [[ "$actual" == "$recorded" ]] || die "model-integrity-mismatch"
  require_regular_owned_file "$LAB_ROOT/scenario.state" 600
  cmp -s -- <(printf 'profile=incident\n') "$LAB_ROOT/scenario.state" || die "scenario-content-mismatch"
  if [[ -e "$LAB_ROOT/recovery.state" || -L "$LAB_ROOT/recovery.state" ]]; then
    require_regular_owned_file "$LAB_ROOT/recovery.state" 600
    cmp -s -- <(printf 'profile=recovered\n') "$LAB_ROOT/recovery.state" || die "recovery-content-mismatch"
  fi
  if [[ -e "$LAB_ROOT/verification.state" || -L "$LAB_ROOT/verification.state" ]]; then
    require_regular_owned_file "$LAB_ROOT/verification.state" 600
    cmp -s -- <(printf 'operation_verified=true\n') "$LAB_ROOT/verification.state" || die "verification-content-mismatch"
    [[ -f "$LAB_ROOT/recovery.state" ]] || die "verification-before-recovery"
  fi
}

scan_candidates() {
  find -P /tmp -maxdepth 1 -mindepth 1 -user "$CURRENT_UID" -type d -name "${PREFIX}-${CURRENT_UID}-*" -print
}

check_absent() {
  [[ ! -e "$STATE_FILE" && ! -L "$STATE_FILE" ]] || die "descriptor-already-exists"
  local candidates
  candidates="$(scan_candidates)"
  [[ -z "$candidates" ]] || die "orphan-candidate-present"
}

cmd_check() {
  preflight
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    validate_state
    printf 'environment=ready state=present root_validated=true\n'
  else
    check_absent
    printf 'environment=ready state=absent candidates=none\n'
  fi
}

write_descriptor() {
  local temporary="${STATE_FILE}.new"
  [[ ! -e "$temporary" && ! -L "$temporary" ]] || die "temporary-descriptor-exists"
  {
    printf 'lesson_id=%s\n' "$LESSON_ID"
    printf 'uid=%s\n' "$CURRENT_UID"
    printf 'root=%s\n' "$LAB_ROOT"
    printf 'schema=1\n'
  } > "$temporary"
  chmod 600 -- "$temporary"
  mv -T -- "$temporary" "$STATE_FILE"
}

cmd_setup() {
  preflight
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    validate_state
    printf 'setup=already-present state=ready\n'
    return 0
  fi
  check_absent
  LAB_ROOT="$(mktemp -d "/tmp/${PREFIX}-${CURRENT_UID}-XXXXXX")"
  chmod 700 -- "$LAB_ROOT"
  expected_sentinel > "$LAB_ROOT/.sentinel"
  chmod 600 -- "$LAB_ROOT/.sentinel"
  cp -- "$FIXTURE_SOURCE" "$LAB_ROOT/io_model.py"
  chmod 600 -- "$LAB_ROOT/io_model.py"
  sha256sum -- "$LAB_ROOT/io_model.py" | awk '{print $1}' > "$LAB_ROOT/model.sha256"
  chmod 600 -- "$LAB_ROOT/model.sha256"
  printf 'profile=incident\n' > "$LAB_ROOT/scenario.state"
  chmod 600 -- "$LAB_ROOT/scenario.state"
  write_descriptor
  validate_state
  printf 'setup=complete state=ready scenario=slow-commit synthetic=true\n'
}

active_profile() {
  if [[ -f "$LAB_ROOT/recovery.state" ]]; then
    printf 'recovered'
  else
    printf 'incident'
  fi
}

cmd_status() {
  preflight
  validate_state
  local recovered=false verified=false
  [[ -f "$LAB_ROOT/recovery.state" ]] && recovered=true
  [[ -f "$LAB_ROOT/verification.state" ]] && verified=true
  printf 'state=ready scenario=slow-commit recovered=%s operation_verified=%s synthetic=true\n' "$recovered" "$verified"
}

run_model() {
  local view="$1"
  local profile="$2"
  validate_state
  python3 "$LAB_ROOT/io_model.py" "$view" "$profile"
}

cmd_observe() {
  local profile="${1:-}"
  case "$profile" in
    baseline) run_model summary baseline ;;
    incident) run_model summary incident ;;
    recovered)
      validate_state
      [[ -f "$LAB_ROOT/recovery.state" ]] || die "recovery-not-complete"
      run_model summary recovered
      ;;
    path) validate_state; run_model path "$(active_profile)" ;;
    *) die "usage-observe-baseline-incident-recovered-path" ;;
  esac
}

cmd_probe() {
  local boundary="${1:-}"
  local profile
  validate_state
  profile="$(active_profile)"
  case "$boundary" in
    system|device|process|mount) run_model "$boundary" "$profile" ;;
    *) die "usage-probe-system-device-process-mount" ;;
  esac
}

cmd_recover() {
  preflight
  validate_state
  [[ ! -e "$LAB_ROOT/recovery.state" && ! -L "$LAB_ROOT/recovery.state" ]] || die "recovery-already-recorded"
  printf 'profile=recovered\n' > "$LAB_ROOT/recovery.state"
  chmod 600 -- "$LAB_ROOT/recovery.state"
  validate_state
  printf 'recovery=complete mechanism=virtual-storage-service-restored synthetic=true\n'
}

cmd_verify_operation() {
  preflight
  validate_state
  [[ -f "$LAB_ROOT/recovery.state" ]] || die "recovery-not-complete"
  [[ ! -e "$LAB_ROOT/verification.state" && ! -L "$LAB_ROOT/verification.state" ]] || die "verification-already-recorded"
  python3 "$LAB_ROOT/io_model.py" verify recovered
  printf 'operation_verified=true\n' > "$LAB_ROOT/verification.state"
  chmod 600 -- "$LAB_ROOT/verification.state"
  validate_state
  printf 'verification=complete user_operation=ledger-commit synthetic=true\n'
}

allowed_name() {
  case "$1" in
    .sentinel|io_model.py|model.sha256|scenario.state|recovery.state|verification.state) return 0 ;;
    *) return 1 ;;
  esac
}

validate_cleanup_entries() {
  local entry name
  while IFS= read -r -d '' entry; do
    name="$(basename -- "$entry")"
    allowed_name "$name" || die "unknown-entry-${name}"
    require_regular_owned_file "$entry" 600
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
}

remove_if_present() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    require_regular_owned_file "$path" 600
    rm -- "$path"
  fi
}

cmd_cleanup() {
  preflight
  validate_state
  validate_cleanup_entries
  remove_if_present "$LAB_ROOT/verification.state"
  remove_if_present "$LAB_ROOT/recovery.state"
  remove_if_present "$LAB_ROOT/scenario.state"
  remove_if_present "$LAB_ROOT/model.sha256"
  remove_if_present "$LAB_ROOT/io_model.py"
  remove_if_present "$LAB_ROOT/.sentinel"
  rmdir -- "$LAB_ROOT"
  rm -- "$STATE_FILE"
  [[ ! -e "$STATE_FILE" && ! -L "$STATE_FILE" ]] || die "descriptor-remains"
  [[ ! -e "$LAB_ROOT" && ! -L "$LAB_ROOT" ]] || die "root-remains"
  local candidates
  candidates="$(scan_candidates)"
  [[ -z "$candidates" ]] || die "candidate-remains"
  printf 'cleanup=complete state=absent cleanup_scope=registered-root-and-owned-candidates-at-check cleanup_proven=true\n'
}

usage() {
  cat <<'USAGE'
Usage:
  bash lab.sh check
  bash lab.sh setup
  bash lab.sh status
  bash lab.sh observe baseline|incident|recovered|path
  bash lab.sh probe system|device|process|mount
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup
USAGE
}

main() {
  local command_name="${1:-}"
  shift || true
  case "$command_name" in
    check) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_check ;;
    setup) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_setup ;;
    status) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_status ;;
    observe) [[ "$#" -eq 1 ]] || die "observe-requires-one-view"; cmd_observe "$1" ;;
    probe) [[ "$#" -eq 1 ]] || die "probe-requires-one-boundary"; cmd_probe "$1" ;;
    recover) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_recover ;;
    verify-operation) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_verify_operation ;;
    cleanup) [[ "$#" -eq 0 ]] || die "unexpected-arguments"; cmd_cleanup ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
  esac
}

main "$@"
