#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0014"
readonly LAB_PREFIX="reliability-atlas-LES-0014."
SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/dns_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0014-$LAB_UID.state"
readonly SENTINEL_NAME=".lesson-owner"
readonly MANIFEST_NAME="manifest.sha256"
readonly MODEL_NAME="dns_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active.case"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly ALLOWED_NAMES="$SENTINEL_NAME $MANIFEST_NAME $MODEL_NAME $BASELINE_NAME $CASE_NAME $RECOVERY_NAME $VERIFICATION_NAME"

EXPECTED_MANIFEST="$(sha256sum -- "$FIXTURE_SOURCE" | awk '{print $1}')"
readonly EXPECTED_MANIFEST
LAB_ROOT=""
ACTIVE_CASE=""
ROLLBACK_ROOT=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

require_tools() {
  local tool
  for tool in awk bash chmod cmp find grep id install mktemp python3 readlink realpath rm rmdir sha256sum stat; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      fail "required command is missing: $tool"
      return 1
    fi
  done
}

require_environment() {
  local tmp_owner tmp_mode tmp_resolved python_version
  if [[ "$LAB_UID" -eq 0 ]]; then
    fail "run this lab as a normal non-root Ubuntu user"
    return 1
  fi
  require_tools
  if [[ ! -d /tmp || -L /tmp ]]; then
    fail "/tmp must be a real directory"
    return 1
  fi
  tmp_owner="$(stat -c '%u' -- /tmp)"
  tmp_mode="$(stat -c '%a' -- /tmp)"
  tmp_resolved="$(realpath -e -- /tmp)"
  if [[ "$tmp_owner" != "0" || "$tmp_mode" != "1777" || "$tmp_resolved" != "/tmp" ]]; then
    fail "/tmp must be root-owned, mode 1777, and resolve to /tmp"
    return 1
  fi
  if [[ ! -f "$FIXTURE_SOURCE" || -L "$FIXTURE_SOURCE" ]]; then
    fail "fixture must be a regular non-symlink file"
    return 1
  fi
  python_version="$(python3 -c 'import sys; print(sys.version_info >= (3, 8))')"
  if [[ "$python_version" != "True" ]]; then
    fail "Python 3.8 or newer is required"
    return 1
  fi
  python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"), p.name, "exec")' "$FIXTURE_SOURCE"
}

expected_sentinel() {
  printf 'lesson_id=%s\nowner_uid=%s\n' "$LESSON_ID" "$LAB_UID"
}

expected_state() {
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$1"
}

validate_root_path() {
  local root="$1" owner mode resolved
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0014\.[[:alnum:]]{8}$ ]]; then
    fail "lab root is outside the exact lesson pattern"
    return 1
  fi
  if [[ ! -d "$root" || -L "$root" ]]; then
    fail "lab root must be a real directory"
    return 1
  fi
  owner="$(stat -c '%u' -- "$root")"
  mode="$(stat -c '%a' -- "$root")"
  resolved="$(realpath -e -- "$root")"
  if [[ "$owner" != "$LAB_UID" || "$mode" != "700" || "$resolved" != "$root" ]]; then
    fail "lab root ownership, mode, or resolution failed"
    return 1
  fi
}

require_regular_owned_file() {
  local path="$1" expected_mode="$2" label="$3" owner links mode
  if [[ ! -f "$path" || -L "$path" ]]; then
    fail "$label must be a regular non-symlink file"
    return 1
  fi
  owner="$(stat -c '%u' -- "$path")"
  links="$(stat -c '%h' -- "$path")"
  mode="$(stat -c '%a' -- "$path")"
  if [[ "$owner" != "$LAB_UID" || "$links" != "1" || "$mode" != "$expected_mode" ]]; then
    fail "$label ownership, link count, or mode failed"
    return 1
  fi
}

state_file_present() {
  path_present "$STATE_FILE"
}

require_no_orphans() {
  local candidate
  while IFS= read -r candidate; do
    [[ -z "$candidate" ]] && continue
    fail "unregistered lesson candidate exists: $candidate"
    return 1
  done < <(find /tmp -mindepth 1 -maxdepth 1 -name 'reliability-atlas-LES-0014.*' -print)
}

load_state() {
  local lines version lesson owner root resolved
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  lines="$(wc -l < "$STATE_FILE" | tr -d '[:space:]')"
  if [[ "$lines" != "4" ]]; then
    fail "state descriptor shape changed"
    return 1
  fi
  version="$(grep -E '^state_version=' "$STATE_FILE" || true)"
  lesson="$(grep -E '^lesson_id=' "$STATE_FILE" || true)"
  owner="$(grep -E '^owner_uid=' "$STATE_FILE" || true)"
  root="$(grep -E '^lab_root=' "$STATE_FILE" || true)"
  if [[ "$version" != "state_version=1" || "$lesson" != "lesson_id=$LESSON_ID" \
    || "$owner" != "owner_uid=$LAB_UID" || -z "$root" ]]; then
    fail "state descriptor identity changed"
    return 1
  fi
  LAB_ROOT="${root#lab_root=}"
  validate_root_path "$LAB_ROOT"
  resolved="$(realpath -e -- "$LAB_ROOT")"
  if ! cmp -s -- "$STATE_FILE" <(expected_state "$resolved"); then
    fail "state descriptor content changed"
    return 1
  fi
}

artifact_is_allowed() {
  local name="$1" allowed
  for allowed in $ALLOWED_NAMES; do
    [[ "$name" == "$allowed" ]] && return 0
  done
  return 1
}

validate_model_output() {
  local command="$1" expected="$2" path="$3"
  local generated
  generated="$(python3 "$LAB_ROOT/$MODEL_NAME" $command)"
  if ! cmp -s -- "$path" <(printf '%s\n' "$generated"); then
    fail "$expected content changed"
    return 1
  fi
}

validate_artifacts() {
  local name path digest line
  validate_root_path "$LAB_ROOT"
  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then
    fail "lesson sentinel changed"
    return 1
  fi
  require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "manifest"
  if ! cmp -s -- "$LAB_ROOT/$MANIFEST_NAME" <(printf '%s\n' "$EXPECTED_MANIFEST"); then
    fail "manifest changed"
    return 1
  fi
  require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "model"
  digest="$(sha256sum -- "$LAB_ROOT/$MODEL_NAME" | awk '{print $1}')"
  if [[ "$digest" != "$EXPECTED_MANIFEST" ]]; then
    fail "model digest changed"
    return 1
  fi
  while IFS= read -r path; do
    name="${path##*/}"
    if ! artifact_is_allowed "$name"; then
      fail "unexpected artifact exists: $name"
      return 1
    fi
  done < <(find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print)

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
    line="$(cat "$LAB_ROOT/$CASE_NAME")"
    case "$line" in
      case=guided) ACTIVE_CASE="guided" ;;
      case=independent) ACTIVE_CASE="independent" ;;
      *) fail "active case content changed"; return 1 ;;
    esac
  fi
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$BASELINE_NAME" "600" "baseline"
    validate_model_output "baseline" "baseline" "$LAB_ROOT/$BASELINE_NAME"
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$RECOVERY_NAME" "600" "recovery"
    if [[ -z "$ACTIVE_CASE" ]]; then
      fail "recovery exists without an active case"
      return 1
    fi
    validate_model_output "recover --case $ACTIVE_CASE" "recovery" "$LAB_ROOT/$RECOVERY_NAME"
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$VERIFICATION_NAME" "600" "verification"
    if [[ -z "$ACTIVE_CASE" || ! -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
      fail "verification exists without recovery"
      return 1
    fi
    validate_model_output "verify --case $ACTIVE_CASE" "verification" "$LAB_ROOT/$VERIFICATION_NAME"
  fi
}

write_record() {
  local path="$1" value="$2"
  if path_present "$path"; then
    fail "refusing to overwrite record: ${path##*/}"
    return 1
  fi
  set -o noclobber
  printf '%s\n' "$value" > "$path"
  set +o noclobber
  chmod 600 -- "$path"
}

rollback_setup() {
  local path owner mode resolved
  if [[ -n "$ROLLBACK_ROOT" && -d "$ROLLBACK_ROOT" && ! -L "$ROLLBACK_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$mode" == "700" && "$resolved" == "$ROLLBACK_ROOT" ]]; then
      for path in "$ROLLBACK_ROOT/$MODEL_NAME" "$ROLLBACK_ROOT/$MANIFEST_NAME" "$ROLLBACK_ROOT/$SENTINEL_NAME"; do
        if [[ -f "$path" && ! -L "$path" && "$(stat -c '%u:%h' -- "$path" 2>/dev/null || true)" == "$LAB_UID:1" ]]; then
          rm -- "$path" 2>/dev/null || true
        fi
      done
      rmdir -- "$ROLLBACK_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" \
    && "$(stat -c '%u:%h:%a' -- "$STATE_FILE" 2>/dev/null || true)" == "$LAB_UID:1:600" ]]; then
    rm -- "$STATE_FILE" 2>/dev/null || true
  fi
}

command_check() {
  require_environment
  if ! state_file_present; then
    require_no_orphans
  fi
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'environment=ready\nprivilege=normal-user\nnetwork=none\nexecution=deterministic_dns_model\n'
  if state_file_present; then
    load_state
    validate_artifacts
    printf 'state=ready\nlab_root=%s\n' "$LAB_ROOT"
  else
    printf 'state=absent\nnext_command=bash lab.sh setup\n'
  fi
}

command_setup() {
  require_environment
  if state_file_present; then
    load_state
    validate_artifacts
    printf 'setup=already-present\nstate=ready\nlab_root=%s\n' "$LAB_ROOT"
    return 0
  fi
  require_no_orphans
  trap rollback_setup EXIT
  trap 'exit 130' INT TERM
  ROLLBACK_ROOT="$(mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX")"
  LAB_ROOT="$ROLLBACK_ROOT"
  validate_root_path "$LAB_ROOT"
  expected_sentinel > "$LAB_ROOT/$SENTINEL_NAME"
  chmod 600 -- "$LAB_ROOT/$SENTINEL_NAME"
  printf '%s\n' "$EXPECTED_MANIFEST" > "$LAB_ROOT/$MANIFEST_NAME"
  chmod 600 -- "$LAB_ROOT/$MANIFEST_NAME"
  install -m 0500 -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"
  set -o noclobber
  expected_state "$LAB_ROOT" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"
  load_state
  validate_artifacts
  ROLLBACK_ROOT=""
  trap - EXIT INT TERM
  printf 'setup=complete\nstate=ready\nlab_root=%s\nnext_command=bash lab.sh run baseline\n' "$LAB_ROOT"
}

artifact_state() {
  if path_present "$1"; then printf 'complete'; else printf 'pending'; fi
}

command_status() {
  require_environment
  load_state
  validate_artifacts
  printf 'lesson_id=%s\nstate=ready\nlab_root=%s\n' "$LESSON_ID" "$LAB_ROOT"
  printf 'baseline=%s\n' "$(artifact_state "$LAB_ROOT/$BASELINE_NAME")"
  printf 'active_case=%s\n' "${ACTIVE_CASE:-none}"
  printf 'recovery=%s\n' "$(artifact_state "$LAB_ROOT/$RECOVERY_NAME")"
  printf 'verification=%s\n' "$(artifact_state "$LAB_ROOT/$VERIFICATION_NAME")"
  printf 'execution=deterministic_dns_model\nhost_resolver_mutation=none\nnetwork_mutation=none\n'
}

command_run() {
  local target="$1" output
  if [[ "$target" != "baseline" ]]; then fail "run target must be baseline"; return 1; fi
  require_environment
  load_state
  validate_artifacts
  if path_present "$LAB_ROOT/$BASELINE_NAME" || [[ -n "$ACTIVE_CASE" ]]; then
    fail "baseline must be recorded once before incident injection"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
  write_record "$LAB_ROOT/$BASELINE_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

command_inject() {
  local case_name="$1"
  case "$case_name" in guided|independent) ;; *) fail "case must be guided or independent"; return 1 ;; esac
  require_environment
  load_state
  validate_artifacts
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -n "$ACTIVE_CASE" ]]; then
    fail "inject requires one baseline and no active case"
    return 1
  fi
  write_record "$LAB_ROOT/$CASE_NAME" "case=$case_name"
  validate_artifacts
  printf 'injection=complete\ncase=%s\nfailure_scope=deterministic_model_only\nanswer_key=not_provided\n' "$case_name"
  if [[ "$case_name" == "independent" ]]; then
    printf 'next_command=bash lab.sh scenario\n'
  else
    printf 'next_command=bash lab.sh observe operation\n'
  fi
}

command_scenario() {
  local output forbidden
  require_environment
  load_state
  validate_artifacts
  if [[ "$ACTIVE_CASE" != "independent" || -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "scenario is available only for an active unrecovered independent case"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" scenario)"
  for forbidden in diagnosis recovery transaction_count candidate_count computed answer_key; do
    if grep -Fiq -- "$forbidden" <<< "$output"; then
      fail "scenario exposed forbidden derived field: $forbidden"
      return 1
    fi
  done
  printf '%s\n' "$output"
}

command_observe() {
  local view="$1" output
  case "$view" in operation|resolver|cache|authority|transport) ;; *) fail "view must be operation, resolver, cache, authority, or transport"; return 1 ;; esac
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" || -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "observation requires an active unrecovered case"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" observe --case "$ACTIVE_CASE" --view "$view")"
  if ! grep -Fqx 'record=observation' <<< "$output" \
    || ! grep -Fqx "case=$ACTIVE_CASE" <<< "$output" \
    || ! grep -Fqx "view=$view" <<< "$output"; then
    fail "observation output shape changed"
    return 1
  fi
  printf '%s\n' "$output"
}

command_recover() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" || -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "recovery requires one active unrecovered case"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE")"
  write_record "$LAB_ROOT/$RECOVERY_NAME" "$output"
  validate_artifacts
  printf '%s\nnext_command=bash lab.sh verify-operation\n' "$output"
}

command_verify_operation() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" || ! -f "$LAB_ROOT/$RECOVERY_NAME" || -f "$LAB_ROOT/$VERIFICATION_NAME" ]]; then
    fail "verify-operation requires one active recovered unverified case"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE")"
  write_record "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

require_cleanup_file() {
  require_regular_owned_file "$1" "600" "$2"
}

command_cleanup() {
  local name root_before
  require_environment
  if ! state_file_present; then
    require_no_orphans
    printf 'cleanup=already-clean\nstate=absent\ncleanup_proven=true\n'
    return 0
  fi
  load_state
  root_before="$LAB_ROOT"
  validate_artifacts
  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$CASE_NAME" "$BASELINE_NAME"; do
    if path_present "$LAB_ROOT/$name"; then
      require_cleanup_file "$LAB_ROOT/$name" "artifact $name"
      rm -- "$LAB_ROOT/$name"
    fi
  done
  require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "model"
  rm -- "$LAB_ROOT/$MODEL_NAME"
  require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "manifest"
  rm -- "$LAB_ROOT/$MANIFEST_NAME"
  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then fail "lesson sentinel changed"; return 1; fi
  rm -- "$LAB_ROOT/$SENTINEL_NAME"
  if ! rmdir -- "$LAB_ROOT"; then fail "lab root changed during cleanup"; return 1; fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  if ! cmp -s -- "$STATE_FILE" <(expected_state "$root_before"); then fail "state descriptor changed"; return 1; fi
  rm -- "$STATE_FILE"
  if path_present "$root_before" || path_present "$STATE_FILE"; then fail "cleanup absence proof failed"; return 1; fi
  require_no_orphans
  printf 'cleanup=complete\nstate=absent\ncleanup_proven=true\n'
}

usage() {
  printf '%s\n' \
    'Usage: bash lab.sh check' \
    '       bash lab.sh setup' \
    '       bash lab.sh status' \
    '       bash lab.sh run baseline' \
    '       bash lab.sh inject guided|independent' \
    '       bash lab.sh scenario' \
    '       bash lab.sh observe operation|resolver|cache|authority|transport' \
    '       bash lab.sh recover' \
    '       bash lab.sh verify-operation' \
    '       bash lab.sh cleanup'
}

main() {
  local command="${1:-}"
  case "$command" in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      if [[ "$#" -ne 1 ]]; then fail "unexpected argument count"; usage >&2; return 2; fi
      "command_${command//-/_}"
      ;;
    run|inject|observe)
      if [[ "$#" -ne 2 ]]; then fail "$command requires exactly one allowlisted value"; usage >&2; return 2; fi
      "command_$command" "$2"
      ;;
    *) usage >&2; return 2 ;;
  esac
}

main "$@"
