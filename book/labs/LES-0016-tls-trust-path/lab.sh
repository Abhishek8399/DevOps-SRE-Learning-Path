#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0016"
readonly LAB_VERSION="1"
SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/tls_trust_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly LAB_ROOT_PREFIX="reliability-atlas-LES-0016."
readonly STATE_FILE="/tmp/reliability-atlas-LES-0016-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0016-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="tls_trust_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active-case.state"
readonly INPUT_MARKER_NAME="inputs-observed.state"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly EXPECTED_MANIFEST=$'artifact\ttype\tcreated_by\trequired\n.les-0016-sentinel\tregular-file\tsetup\tyes\nartifact-manifest.tsv\tregular-file\tsetup\tyes\ntls_trust_model.py\tregular-file\tsetup\tyes\nbaseline.summary\tregular-file\trun-baseline\tno\nactive-case.state\tregular-file\tinject\tno\ninputs-observed.state\tregular-file\tobserve-inputs\tno\nrecovery.summary\tregular-file\trecover\tno\nverification.summary\tregular-file\tverify-operation\tno'

LAB_ROOT=""
ROLLBACK_ROOT=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

require_normal_user() {
  if [[ "$LAB_UID" -eq 0 ]]; then
    fail "run this lab from a normal non-root Ubuntu shell"
    return 1
  fi
}

require_environment() {
  local tool tmp_owner tmp_mode sticky_character

  require_normal_user
  if [[ ! -d /tmp || -L /tmp ]]; then
    fail "/tmp must be a real directory"
    return 1
  fi
  tmp_owner="$(stat -c '%u' -- /tmp)"
  tmp_mode="$(stat -c '%A' -- /tmp)"
  sticky_character="${tmp_mode:9:1}"
  if [[ "$tmp_owner" != "0" \
    || ( "$sticky_character" != "t" && "$sticky_character" != "T" ) ]]; then
    fail "/tmp must be root-owned and sticky"
    return 1
  fi

  for tool in bash chmod cmp dirname find grep id install mktemp \
    python3 realpath rm rmdir stat
  do
    if ! command -v "$tool" >/dev/null 2>&1; then
      fail "required command is missing: $tool"
      return 1
    fi
  done
  if ! python3 -c \
    'import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)'
  then
    fail "python3 3.8 or newer is required"
    return 1
  fi
  if [[ ! -f "$FIXTURE_SOURCE" || -L "$FIXTURE_SOURCE" ]]; then
    fail "fixture source must be a regular non-symlink file"
    return 1
  fi
}

expected_sentinel() {
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s\n' \
    "$LESSON_ID" "$LAB_VERSION" "$LAB_UID"
}

expected_state_descriptor() {
  local root="$1"
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$root"
}

require_regular_owned_file() {
  local path="$1" expected_mode="$2" label="$3"
  local owner links mode

  if [[ ! -f "$path" || -L "$path" ]]; then
    fail "$label must be a regular non-symlink file"
    return 1
  fi
  owner="$(stat -c '%u' -- "$path")"
  links="$(stat -c '%h' -- "$path")"
  mode="$(stat -c '%a' -- "$path")"
  if [[ "$owner" != "$LAB_UID" || "$links" != "1" || "$mode" != "$expected_mode" ]]; then
    fail "$label owner, link count, or mode is outside the lab contract"
    return 1
  fi
}

check_orphan_roots() {
  local candidate

  candidate="$(find /tmp -mindepth 1 -maxdepth 1 -type d \
    -name "${LAB_ROOT_PREFIX}*" -print -quit 2>/dev/null || true)"
  if [[ -n "$candidate" ]]; then
    fail "an unregistered LES-0016 root exists; inspect ownership and history manually"
    return 1
  fi
}

read_registered_root() {
  local line root owner mode resolved

  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  line="$(grep -E '^lab_root=' "$STATE_FILE" || true)"
  root="${line#lab_root=}"
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ ]]; then
    fail "registered root does not match the exact lesson boundary"
    return 1
  fi
  if ! cmp -s -- "$STATE_FILE" <(expected_state_descriptor "$root"); then
    fail "state descriptor content or field order changed"
    return 1
  fi
  if [[ ! -d "$root" || -L "$root" ]]; then
    fail "registered root must be a real directory"
    return 1
  fi
  owner="$(stat -c '%u' -- "$root")"
  mode="$(stat -c '%a' -- "$root")"
  resolved="$(realpath -e -- "$root")"
  if [[ "$owner" != "$LAB_UID" || "$mode" != "700" || "$resolved" != "$root" ]]; then
    fail "registered root ownership, mode, or resolution changed"
    return 1
  fi
  printf '%s' "$root"
}

active_case_from_root() {
  local root="$1" line case_name

  line="$(grep -E '^case=' "$root/$CASE_NAME" || true)"
  case_name="${line#case=}"
  if [[ "$case_name" != "guided" && "$case_name" != "independent" ]]; then
    fail "active case is invalid"
    return 1
  fi
  if ! cmp -s -- "$root/$CASE_NAME" <(printf 'case=%s\n' "$case_name"); then
    fail "active case content changed"
    return 1
  fi
  printf '%s' "$case_name"
}

validate_known_artifacts() {
  local root="$1" child name active_case
  local baseline_path case_path marker_path recovery_path verification_path

  while IFS= read -r child; do
    name="$(basename -- "$child")"
    case "$name" in
      "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|"$BASELINE_NAME"|\
      "$CASE_NAME"|"$INPUT_MARKER_NAME"|"$RECOVERY_NAME"|"$VERIFICATION_NAME") ;;
      *)
        fail "unexpected artifact in registered root: $name"
        return 1
        ;;
    esac
  done < <(find "$root" -mindepth 1 -maxdepth 1 -print)

  require_regular_owned_file "$root/$SENTINEL_NAME" "400" "sentinel"
  require_regular_owned_file "$root/$MANIFEST_NAME" "400" "artifact manifest"
  require_regular_owned_file "$root/$MODEL_NAME" "500" "model copy"
  if ! cmp -s -- "$root/$SENTINEL_NAME" <(expected_sentinel); then
    fail "sentinel content changed"
    return 1
  fi
  if ! cmp -s -- "$root/$MANIFEST_NAME" <(printf '%s\n' "$EXPECTED_MANIFEST"); then
    fail "artifact manifest changed"
    return 1
  fi
  if ! cmp -s -- "$root/$MODEL_NAME" "$FIXTURE_SOURCE"; then
    fail "model copy differs from reviewed repository source"
    return 1
  fi

  baseline_path="$root/$BASELINE_NAME"
  case_path="$root/$CASE_NAME"
  marker_path="$root/$INPUT_MARKER_NAME"
  recovery_path="$root/$RECOVERY_NAME"
  verification_path="$root/$VERIFICATION_NAME"

  if path_present "$baseline_path"; then
    require_regular_owned_file "$baseline_path" "600" "baseline record"
    if ! cmp -s -- "$baseline_path" <(python3 "$root/$MODEL_NAME" baseline); then
      fail "baseline record changed"
      return 1
    fi
  fi

  if path_present "$case_path"; then
    if ! path_present "$baseline_path"; then
      fail "active case exists without a baseline"
      return 1
    fi
    require_regular_owned_file "$case_path" "600" "active case"
    active_case="$(active_case_from_root "$root")"
  else
    active_case=""
  fi

  if path_present "$marker_path"; then
    if [[ -z "$active_case" ]]; then
      fail "input marker exists without an active case"
      return 1
    fi
    require_regular_owned_file "$marker_path" "600" "input marker"
    if ! cmp -s -- "$marker_path" \
      <(printf 'inputs_observed=true\ncase=%s\n' "$active_case"); then
      fail "input marker changed"
      return 1
    fi
  fi

  if path_present "$recovery_path"; then
    if [[ -z "$active_case" || ! -f "$marker_path" ]]; then
      fail "recovery exists before raw-input observation"
      return 1
    fi
    require_regular_owned_file "$recovery_path" "600" "recovery record"
    if ! cmp -s -- "$recovery_path" \
      <(python3 "$root/$MODEL_NAME" recover "$active_case"); then
      fail "recovery record changed"
      return 1
    fi
  fi

  if path_present "$verification_path"; then
    if [[ -z "$active_case" || ! -f "$recovery_path" ]]; then
      fail "verification exists before recovery"
      return 1
    fi
    require_regular_owned_file "$verification_path" "600" "verification record"
    if ! cmp -s -- "$verification_path" \
      <(python3 "$root/$MODEL_NAME" verify "$active_case"); then
      fail "verification record changed"
      return 1
    fi
  fi
}

validate_state() {
  LAB_ROOT="$(read_registered_root)"
  validate_known_artifacts "$LAB_ROOT"
}

write_new_artifact() {
  local path="$1" content="$2"

  if path_present "$path"; then
    fail "refusing to replace existing artifact: $(basename -- "$path")"
    return 1
  fi
  if ! (set -o noclobber; printf '%s\n' "$content" > "$path") 2>/dev/null; then
    fail "could not create artifact without replacement"
    return 1
  fi
  chmod 600 -- "$path"
}

rollback_setup() {
  local owner resolved name

  if [[ -n "$ROLLBACK_ROOT" \
    && "$ROLLBACK_ROOT" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ \
    && -d "$ROLLBACK_ROOT" && ! -L "$ROLLBACK_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$resolved" == "$ROLLBACK_ROOT" ]]; then
      for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$INPUT_MARKER_NAME" \
        "$CASE_NAME" "$BASELINE_NAME" "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"
      do
        if [[ -f "$ROLLBACK_ROOT/$name" && ! -L "$ROLLBACK_ROOT/$name" ]]; then
          rm -- "$ROLLBACK_ROOT/$name" 2>/dev/null || true
        fi
      done
      rmdir -- "$ROLLBACK_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    owner="$(stat -c '%u' -- "$STATE_FILE" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" ]]; then
      rm -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
}

command_check() {
  require_environment
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'environment=ready\n'
  printf 'privilege=normal-user\n'
  printf 'network=none\n'
  printf 'execution=deterministic_public_metadata_model\n'
  if path_present "$STATE_FILE"; then
    validate_state
    printf 'state=registered\n'
    printf 'next_command=bash lab.sh status\n'
  else
    check_orphan_roots
    printf 'state=absent\n'
    printf 'next_command=bash lab.sh setup\n'
  fi
}

command_setup() {
  local root

  require_environment
  if path_present "$STATE_FILE"; then
    validate_state
    printf 'setup=already-present\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    return 0
  fi
  check_orphan_roots

  root="$(mktemp -d --tmpdir=/tmp "${LAB_ROOT_PREFIX}XXXXXXXX")"
  if [[ ! "$root" =~ ^/tmp/reliability-atlas-LES-0016\.[[:alnum:]]{8}$ ]]; then
    fail "mktemp returned a root outside the exact lesson boundary"
    return 1
  fi
  chmod 700 -- "$root"
  ROLLBACK_ROOT="$root"
  trap rollback_setup EXIT

  install -m 0500 -- "$FIXTURE_SOURCE" "$root/$MODEL_NAME"
  expected_sentinel > "$root/$SENTINEL_NAME"
  chmod 400 -- "$root/$SENTINEL_NAME"
  printf '%s\n' "$EXPECTED_MANIFEST" > "$root/$MANIFEST_NAME"
  chmod 400 -- "$root/$MANIFEST_NAME"

  if ! (set -o noclobber; expected_state_descriptor "$root" > "$STATE_FILE") 2>/dev/null; then
    fail "state descriptor appeared during setup; no existing entry was replaced"
    return 1
  fi
  chmod 600 -- "$STATE_FILE"
  validate_state

  ROLLBACK_ROOT=""
  trap - EXIT
  printf 'setup=complete\n'
  printf 'lab_root=%s\n' "$root"
  printf 'network=none\n'
  printf 'private_keys=none\n'
  printf 'next_command=bash lab.sh run baseline\n'
}

command_status() {
  local baseline_state case_state input_state recovery_state verification_state active_case

  require_environment
  if ! path_present "$STATE_FILE"; then
    fail "lab state is absent; run bash lab.sh setup"
    return 1
  fi
  validate_state
  baseline_state="pending"
  case_state="none"
  input_state="pending"
  recovery_state="pending"
  verification_state="pending"
  [[ -f "$LAB_ROOT/$BASELINE_NAME" ]] && baseline_state="complete"
  if [[ -f "$LAB_ROOT/$CASE_NAME" ]]; then
    active_case="$(active_case_from_root "$LAB_ROOT")"
    case_state="$active_case"
  fi
  [[ -f "$LAB_ROOT/$INPUT_MARKER_NAME" ]] && input_state="complete"
  [[ -f "$LAB_ROOT/$RECOVERY_NAME" ]] && recovery_state="complete"
  [[ -f "$LAB_ROOT/$VERIFICATION_NAME" ]] && verification_state="complete"
  printf 'state=ready\n'
  printf 'baseline=%s\n' "$baseline_state"
  printf 'active_case=%s\n' "$case_state"
  printf 'inputs_observed=%s\n' "$input_state"
  printf 'recovery=%s\n' "$recovery_state"
  printf 'verification=%s\n' "$verification_state"
}

command_run_baseline() {
  local output

  validate_state
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    fail "baseline already exists and is immutable for this lifecycle"
    return 1
  fi
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    fail "cannot create a baseline after incident selection"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
  write_new_artifact "$LAB_ROOT/$BASELINE_NAME" "$output"
  printf '%s\n' "$output"
}

command_inject() {
  local requested_case="$1"

  validate_state
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before selecting an incident"
    return 1
  fi
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    fail "an active case already exists"
    return 1
  fi
  write_new_artifact "$LAB_ROOT/$CASE_NAME" "case=$requested_case"
  printf 'incident_ready=true\n'
  printf 'case=%s\n' "$requested_case"
  printf 'answer_key=not_provided\n'
  printf 'next_command=bash lab.sh observe inputs\n'
}

command_observe_inputs() {
  local active_case output

  validate_state
  if [[ ! -f "$LAB_ROOT/$CASE_NAME" ]]; then
    fail "select guided or independent before observation"
    return 1
  fi
  active_case="$(active_case_from_root "$LAB_ROOT")"
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" inputs "$active_case")"
  if ! path_present "$LAB_ROOT/$INPUT_MARKER_NAME"; then
    write_new_artifact "$LAB_ROOT/$INPUT_MARKER_NAME" \
      "$(printf 'inputs_observed=true\ncase=%s' "$active_case")"
  fi
  printf '%s\n' "$output"
  printf 'hypothesis_checkpoint=write_three_mechanisms_before_derived_views\n'
}

command_observe_view() {
  local view="$1" active_case

  validate_state
  if [[ ! -f "$LAB_ROOT/$CASE_NAME" ]]; then
    fail "select guided or independent before observation"
    return 1
  fi
  if [[ ! -f "$LAB_ROOT/$INPUT_MARKER_NAME" ]]; then
    fail "observe raw inputs and write hypotheses before derived views"
    return 1
  fi
  if [[ -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "derived incident views close after modeled recovery"
    return 1
  fi
  active_case="$(active_case_from_root "$LAB_ROOT")"
  python3 "$LAB_ROOT/$MODEL_NAME" view "$active_case" "$view"
}

command_recover() {
  local active_case output

  validate_state
  if [[ ! -f "$LAB_ROOT/$CASE_NAME" || ! -f "$LAB_ROOT/$INPUT_MARKER_NAME" ]]; then
    fail "select a case and observe raw inputs before recovery"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "recovery already recorded"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    fail "verification cannot precede recovery"
    return 1
  fi
  active_case="$(active_case_from_root "$LAB_ROOT")"
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" recover "$active_case")"
  write_new_artifact "$LAB_ROOT/$RECOVERY_NAME" "$output"
  printf '%s\n' "$output"
  printf 'next_command=bash lab.sh verify-operation\n'
}

command_verify_operation() {
  local active_case output

  validate_state
  if [[ ! -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "record modeled recovery before operation verification"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    fail "operation verification already recorded"
    return 1
  fi
  active_case="$(active_case_from_root "$LAB_ROOT")"
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" verify "$active_case")"
  write_new_artifact "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  printf '%s\n' "$output"
}

command_cleanup() {
  local name

  require_environment
  if ! path_present "$STATE_FILE"; then
    check_orphan_roots
    printf 'cleanup=already-clean\n'
    printf 'cleanup_proven=true\n'
    return 0
  fi
  validate_state
  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$INPUT_MARKER_NAME" \
    "$CASE_NAME" "$BASELINE_NAME" "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"
  do
    if path_present "$LAB_ROOT/$name"; then
      require_regular_owned_file "$LAB_ROOT/$name" \
        "$([[ "$name" == "$MODEL_NAME" ]] && printf '500' || \
          { [[ "$name" == "$MANIFEST_NAME" || "$name" == "$SENTINEL_NAME" ]] \
            && printf '400' || printf '600'; })" "$name"
      rm -- "$LAB_ROOT/$name"
    fi
  done
  rmdir -- "$LAB_ROOT"
  rm -- "$STATE_FILE"
  check_orphan_roots
  if path_present "$STATE_FILE"; then
    fail "state descriptor remains after cleanup"
    return 1
  fi
  printf 'cleanup=complete\n'
  printf 'cleanup_proven=true\n'
}

dispatch() {
  local command="${1:-}"

  case "$command" in
    check)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh check"; return 2; }
      command_check
      ;;
    setup)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh setup"; return 2; }
      command_setup
      ;;
    status)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh status"; return 2; }
      command_status
      ;;
    run)
      [[ "$#" -eq 2 && "${2:-}" == "baseline" ]] \
        || { fail "usage: bash lab.sh run baseline"; return 2; }
      command_run_baseline
      ;;
    inject)
      [[ "$#" -eq 2 && ( "${2:-}" == "guided" || "${2:-}" == "independent" ) ]] \
        || { fail "usage: bash lab.sh inject guided|independent"; return 2; }
      command_inject "$2"
      ;;
    observe)
      if [[ "$#" -ne 2 ]]; then
        fail "usage: bash lab.sh observe inputs|handshake|certificate|trust|rotation|ownership"
        return 2
      fi
      if [[ "$2" == "inputs" ]]; then
        command_observe_inputs
      elif [[ "$2" == "handshake" || "$2" == "certificate" || "$2" == "trust" \
        || "$2" == "rotation" || "$2" == "ownership" ]]; then
        command_observe_view "$2"
      else
        fail "usage: bash lab.sh observe inputs|handshake|certificate|trust|rotation|ownership"
        return 2
      fi
      ;;
    recover)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh recover"; return 2; }
      command_recover
      ;;
    verify-operation)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh verify-operation"; return 2; }
      command_verify_operation
      ;;
    cleanup)
      [[ "$#" -eq 1 ]] || { fail "usage: bash lab.sh cleanup"; return 2; }
      command_cleanup
      ;;
    *)
      fail "usage: bash lab.sh check|setup|status|run baseline|inject guided|independent|observe VIEW|recover|verify-operation|cleanup"
      return 2
      ;;
  esac
}

trap 'exit 130' INT TERM
require_environment
dispatch "$@"
