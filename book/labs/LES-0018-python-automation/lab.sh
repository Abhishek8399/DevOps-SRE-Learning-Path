#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0018"
readonly LAB_PREFIX="reliability-atlas-LES-0018."
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
if [[ "$SCRIPT_SOURCE" == */* ]]; then
  SCRIPT_PARENT="${SCRIPT_SOURCE%/*}"
else
  SCRIPT_PARENT="."
fi
SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)"
readonly SCRIPT_SOURCE SCRIPT_PARENT SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/operation_model.py"
LAB_UID="$EUID"
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0018-$LAB_UID.state"
readonly SENTINEL_NAME=".lesson-owner"
readonly CLEANUP_NAME=".cleanup-in-progress"
readonly MANIFEST_NAME="manifest.sha256"
readonly MODEL_NAME="operation_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active.case"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly ALLOWED_NAMES="$SENTINEL_NAME $CLEANUP_NAME $MANIFEST_NAME $MODEL_NAME $BASELINE_NAME $CASE_NAME $RECOVERY_NAME $VERIFICATION_NAME"

LAB_ROOT=""
ACTIVE_CASE=""
ROLLBACK_ROOT=""
EXPECTED_MANIFEST=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

require_tools() {
  local tool
  for tool in awk bash cat chmod cmp find grep install mktemp python3 realpath rm rmdir sha256sum stat tr wc; do
    command -v "$tool" >/dev/null 2>&1 || {
      fail "required command is missing: $tool"
      return 1
    }
  done
}

require_environment() {
  local tmp_owner tmp_mode tmp_resolved python_supported
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
  python_supported="$(python3 -c 'import sys; print(sys.version_info >= (3, 8))')"
  if [[ "$python_supported" != "True" ]]; then
    fail "Python 3.8 or newer is required"
    return 1
  fi
  PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$FIXTURE_SOURCE"
  EXPECTED_MANIFEST="$(sha256sum -- "$FIXTURE_SOURCE" | awk '{print $1}')"
}

expected_sentinel() {
  printf 'lesson_id=%s\nowner_uid=%s\n' "$LESSON_ID" "$LAB_UID"
}

expected_state() {
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' "$LESSON_ID" "$LAB_UID" "$1"
}

expected_cleanup_marker() {
  printf 'cleanup_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' "$LESSON_ID" "$LAB_UID" "$1"
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
    fail "$label ownership, hard-link count, or mode failed"
    return 1
  fi
}

validate_root_path() {
  local root="$1" owner mode resolved
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0018\.[[:alnum:]]{8}$ ]]; then
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

require_no_orphans() {
  local candidate
  while IFS= read -r candidate; do
    [[ -z "$candidate" ]] && continue
    fail "unregistered lesson candidate exists: $candidate"
    return 1
  done < <(find /tmp -mindepth 1 -maxdepth 1 -name 'reliability-atlas-LES-0018.*' -print)
}

load_state_descriptor() {
  local lines version lesson owner root
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  lines="$(wc -l < "$STATE_FILE" | tr -d '[:space:]')"
  [[ "$lines" == "4" ]] || { fail "state descriptor shape changed"; return 1; }
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
  if [[ ! "$LAB_ROOT" =~ ^/tmp/reliability-atlas-LES-0018\.[[:alnum:]]{8}$ ]]; then
    fail "state descriptor root is outside the exact lesson pattern"
    return 1
  fi
  if ! cmp -s -- "$STATE_FILE" <(expected_state "$LAB_ROOT"); then
    fail "state descriptor content changed"
    return 1
  fi
}

load_state() {
  load_state_descriptor
  validate_root_path "$LAB_ROOT"
}

artifact_allowed() {
  local name="$1" allowed
  for allowed in $ALLOWED_NAMES; do
    [[ "$name" == "$allowed" ]] && return 0
  done
  return 1
}

compare_model_output() {
  local path="$1"
  shift
  if ! cmp -s -- "$path" <(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" "$@"); then
    fail "${path##*/} content changed"
    return 1
  fi
}

validate_cleanup_marker() {
  require_regular_owned_file "$LAB_ROOT/$CLEANUP_NAME" "600" "cleanup marker"
  if ! cmp -s -- "$LAB_ROOT/$CLEANUP_NAME" <(expected_cleanup_marker "$LAB_ROOT"); then
    fail "cleanup marker content changed"
    return 1
  fi
}

validate_cleanup_artifacts() {
  local path name manifest case_line lifecycle
  validate_cleanup_marker

  shopt -s nullglob dotglob
  for path in "$LAB_ROOT"/*; do
    name="${path##*/}"
    artifact_allowed "$name" || { fail "unexpected artifact during cleanup: $name"; return 1; }
  done
  shopt -u nullglob dotglob

  if path_present "$LAB_ROOT/$SENTINEL_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
    cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel) || { fail "lesson sentinel changed"; return 1; }
  fi
  if path_present "$LAB_ROOT/$MANIFEST_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "manifest"
    manifest="$(tr -d '[:space:]' < "$LAB_ROOT/$MANIFEST_NAME")"
    [[ "$manifest" == "$EXPECTED_MANIFEST" ]] || { fail "manifest changed"; return 1; }
    path_present "$LAB_ROOT/$SENTINEL_NAME" || { fail "manifest remains after sentinel removal"; return 1; }
  fi
  if path_present "$LAB_ROOT/$MODEL_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "installed model"
    [[ "$(sha256sum -- "$LAB_ROOT/$MODEL_NAME" | awk '{print $1}')" == "$EXPECTED_MANIFEST" ]] || {
      fail "installed model digest changed"
      return 1
    }
    path_present "$LAB_ROOT/$MANIFEST_NAME" || { fail "installed model remains after manifest removal"; return 1; }
    path_present "$LAB_ROOT/$SENTINEL_NAME" || { fail "installed model remains after sentinel removal"; return 1; }
  fi

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
    [[ "$(wc -l < "$LAB_ROOT/$CASE_NAME" | tr -d '[:space:]')" == "1" ]] || { fail "active case shape changed"; return 1; }
    case_line="$(cat -- "$LAB_ROOT/$CASE_NAME")"
    case "$case_line" in
      case=guided) ACTIVE_CASE="guided" ;;
      case=independent) ACTIVE_CASE="independent" ;;
      *) fail "active case value changed"; return 1 ;;
    esac
  fi

  for lifecycle in "$BASELINE_NAME" "$CASE_NAME" "$RECOVERY_NAME" "$VERIFICATION_NAME"; do
    if path_present "$LAB_ROOT/$lifecycle" && ! path_present "$LAB_ROOT/$MODEL_NAME"; then
      fail "lifecycle record remains after installed model removal"
      return 1
    fi
  done
  if path_present "$LAB_ROOT/$CASE_NAME" && ! path_present "$LAB_ROOT/$BASELINE_NAME"; then
    fail "active case remains after baseline removal"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME" && ! path_present "$LAB_ROOT/$CASE_NAME"; then
    fail "recovery remains after active case removal"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME" && ! path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "verification remains after recovery removal"
    return 1
  fi

  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$BASELINE_NAME" "600" "baseline"
    compare_model_output "$LAB_ROOT/$BASELINE_NAME" baseline
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$RECOVERY_NAME" "600" "recovery"
    [[ -n "$ACTIVE_CASE" ]] || { fail "recovery exists without active case"; return 1; }
    compare_model_output "$LAB_ROOT/$RECOVERY_NAME" recover --case "$ACTIVE_CASE"
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$VERIFICATION_NAME" "600" "verification"
    [[ -n "$ACTIVE_CASE" && -f "$LAB_ROOT/$RECOVERY_NAME" ]] || { fail "verification exists without recovery"; return 1; }
    compare_model_output "$LAB_ROOT/$VERIFICATION_NAME" verify --case "$ACTIVE_CASE"
  fi
}

validate_artifacts() {
  local path name manifest case_line
  if path_present "$LAB_ROOT/$CLEANUP_NAME"; then
    validate_cleanup_artifacts
    fail "cleanup is in progress; run: bash lab.sh cleanup"
    return 1
  fi
  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel) || { fail "lesson sentinel changed"; return 1; }
  require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "manifest"
  manifest="$(tr -d '[:space:]' < "$LAB_ROOT/$MANIFEST_NAME")"
  [[ "$manifest" == "$EXPECTED_MANIFEST" ]] || { fail "manifest changed"; return 1; }
  require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "installed model"
  [[ "$(sha256sum -- "$LAB_ROOT/$MODEL_NAME" | awk '{print $1}')" == "$EXPECTED_MANIFEST" ]] || {
    fail "installed model digest changed"
    return 1
  }

  shopt -s nullglob dotglob
  for path in "$LAB_ROOT"/*; do
    name="${path##*/}"
    artifact_allowed "$name" || { fail "unexpected artifact: $name"; return 1; }
  done
  shopt -u nullglob dotglob

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
    [[ "$(wc -l < "$LAB_ROOT/$CASE_NAME" | tr -d '[:space:]')" == "1" ]] || { fail "active case shape changed"; return 1; }
    case_line="$(cat -- "$LAB_ROOT/$CASE_NAME")"
    case "$case_line" in
      case=guided) ACTIVE_CASE="guided" ;;
      case=independent) ACTIVE_CASE="independent" ;;
      *) fail "active case value changed"; return 1 ;;
    esac
  fi

  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$BASELINE_NAME" "600" "baseline"
    compare_model_output "$LAB_ROOT/$BASELINE_NAME" baseline
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$RECOVERY_NAME" "600" "recovery"
    [[ -n "$ACTIVE_CASE" ]] || { fail "recovery exists without active case"; return 1; }
    compare_model_output "$LAB_ROOT/$RECOVERY_NAME" recover --case "$ACTIVE_CASE"
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$VERIFICATION_NAME" "600" "verification"
    [[ -n "$ACTIVE_CASE" && -f "$LAB_ROOT/$RECOVERY_NAME" ]] || { fail "verification exists without recovery"; return 1; }
    compare_model_output "$LAB_ROOT/$VERIFICATION_NAME" verify --case "$ACTIVE_CASE"
  fi
}

write_record() {
  local path="$1" value="$2"
  path_present "$path" && { fail "refusing to overwrite record: ${path##*/}"; return 1; }
  if ! (set -o noclobber; printf '%s\n' "$value" > "$path"); then
    fail "could not create record: ${path##*/}"
    return 1
  fi
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
  if path_present "$STATE_FILE"; then
    load_state
    validate_artifacts
    printf 'lesson_id=%s\nenvironment=ready\nprivilege=normal-user\nnetwork=none\nexecution=deterministic_python_model\nstate=ready\nlab_root=%s\n' "$LESSON_ID" "$LAB_ROOT"
  else
    require_no_orphans
    printf 'lesson_id=%s\nenvironment=ready\nprivilege=normal-user\nnetwork=none\nexecution=deterministic_python_model\nstate=absent\nnext_command=bash lab.sh setup\n' "$LESSON_ID"
  fi
}

command_setup() {
  require_environment
  if path_present "$STATE_FILE"; then
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
  if ! (set -o noclobber; expected_state "$LAB_ROOT" > "$STATE_FILE"); then
    fail "state descriptor already exists"
    return 1
  fi
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
  printf 'baseline=%s\nactive_case=%s\nrecovery=%s\nverification=%s\n' \
    "$(artifact_state "$LAB_ROOT/$BASELINE_NAME")" "${ACTIVE_CASE:-none}" \
    "$(artifact_state "$LAB_ROOT/$RECOVERY_NAME")" "$(artifact_state "$LAB_ROOT/$VERIFICATION_NAME")"
  printf 'execution=deterministic_python_model\nnetwork_mutation=none\nhost_mutation=guarded-tmp-state-only\n'
}

command_run() {
  local target="$1" output
  [[ "$target" == "baseline" ]] || { fail "run target must be baseline"; return 1; }
  require_environment
  load_state
  validate_artifacts
  if path_present "$LAB_ROOT/$BASELINE_NAME" || [[ -n "$ACTIVE_CASE" ]]; then
    fail "baseline must be recorded once before incident injection"
    return 1
  fi
  output="$(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
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
  if [[ "$case_name" == "independent" ]]; then printf 'next_command=bash lab.sh scenario\n'; else printf 'next_command=bash lab.sh observe operation\n'; fi
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
  output="$(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" scenario)"
  for forbidden in authoritative committed receipt diagnosis recovery answer_key duplicate_effects; do
    if grep -Fiq -- "$forbidden" <<< "$output"; then
      fail "scenario exposed forbidden derived field: $forbidden"
      return 1
    fi
  done
  printf '%s\n' "$output"
}

command_observe() {
  local view="$1" output
  case "$view" in operation|input|runtime|state|outcome) ;; *) fail "view must be operation, input, runtime, state, or outcome"; return 1 ;; esac
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" || -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "observation requires an active unrecovered case"
    return 1
  fi
  output="$(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" observe --case "$ACTIVE_CASE" --view "$view")"
  grep -Fqx 'record=observation' <<< "$output" || { fail "observation record shape changed"; return 1; }
  grep -Fqx "case=$ACTIVE_CASE" <<< "$output" || { fail "observation case changed"; return 1; }
  grep -Fqx "view=$view" <<< "$output" || { fail "observation view changed"; return 1; }
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
  output="$(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE")"
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
  output="$(PYTHONDONTWRITEBYTECODE=1 python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE")"
  write_record "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

command_cleanup() {
  local name root_before first_entry
  require_environment
  if ! path_present "$STATE_FILE"; then
    require_no_orphans
    printf 'cleanup=already-clean\nstate=absent\ncleanup_proven=true\n'
    return 0
  fi
  load_state_descriptor
  root_before="$LAB_ROOT"
  if ! path_present "$LAB_ROOT"; then
    require_no_orphans
    require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
    cmp -s -- "$STATE_FILE" <(expected_state "$root_before") || { fail "state descriptor changed"; return 1; }
    rm -- "$STATE_FILE"
    path_present "$STATE_FILE" && { fail "cleanup descriptor absence proof failed"; return 1; }
    printf 'cleanup=complete\nstate=absent\ncleanup_resumed=descriptor-finalization\ncleanup_proven=true\n'
    return 0
  fi
  validate_root_path "$LAB_ROOT"

  if ! path_present "$LAB_ROOT/$CLEANUP_NAME"; then
    first_entry="$(find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print -quit)"
    if [[ -n "$first_entry" ]]; then
      validate_artifacts
      write_record "$LAB_ROOT/$CLEANUP_NAME" "$(expected_cleanup_marker "$LAB_ROOT")"
    fi
  fi
  if path_present "$LAB_ROOT/$CLEANUP_NAME"; then
    validate_cleanup_artifacts
  else
    first_entry="$(find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print -quit)"
    [[ -z "$first_entry" ]] || { fail "cleanup marker is missing from a nonempty root"; return 1; }
  fi
  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$CASE_NAME" "$BASELINE_NAME"; do
    if path_present "$LAB_ROOT/$name"; then
      require_regular_owned_file "$LAB_ROOT/$name" "600" "artifact $name"
      rm -- "$LAB_ROOT/$name"
    fi
  done
  if path_present "$LAB_ROOT/$MODEL_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "installed model"
    rm -- "$LAB_ROOT/$MODEL_NAME"
  fi
  if path_present "$LAB_ROOT/$MANIFEST_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "manifest"
    rm -- "$LAB_ROOT/$MANIFEST_NAME"
  fi
  if path_present "$LAB_ROOT/$SENTINEL_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
    cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel) || { fail "lesson sentinel changed"; return 1; }
    rm -- "$LAB_ROOT/$SENTINEL_NAME"
  fi
  if path_present "$LAB_ROOT/$CLEANUP_NAME"; then
    require_regular_owned_file "$LAB_ROOT/$CLEANUP_NAME" "600" "cleanup marker"
    cmp -s -- "$LAB_ROOT/$CLEANUP_NAME" <(expected_cleanup_marker "$LAB_ROOT") || { fail "cleanup marker changed"; return 1; }
    rm -- "$LAB_ROOT/$CLEANUP_NAME"
  fi
  rmdir -- "$LAB_ROOT" || { fail "lab root changed during cleanup"; return 1; }
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  cmp -s -- "$STATE_FILE" <(expected_state "$root_before") || { fail "state descriptor changed"; return 1; }
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
    '       bash lab.sh observe operation|input|runtime|state|outcome' \
    '       bash lab.sh recover' \
    '       bash lab.sh verify-operation' \
    '       bash lab.sh cleanup'
}

main() {
  local command="${1:-}"
  case "$command" in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      [[ "$#" -eq 1 ]] || { fail "unexpected argument count"; usage >&2; return 2; }
      "command_${command//-/_}"
      ;;
    run|inject|observe)
      [[ "$#" -eq 2 ]] || { fail "$command requires exactly one allowlisted value"; usage >&2; return 2; }
      "command_$command" "$2"
      ;;
    *) usage >&2; return 2 ;;
  esac
}

main "$@"
