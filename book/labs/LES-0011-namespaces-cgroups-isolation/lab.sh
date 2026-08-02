#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0011"
readonly LAB_VERSION="1"
SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/isolation_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly LAB_PREFIX="reliability-atlas-LES-0011."
readonly STATE_FILE="/tmp/reliability-atlas-LES-0011-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0011-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="isolation_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active-case.state"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly EXPECTED_MANIFEST=$'artifact\ttype\tcreated_by\trequired\n.les-0011-sentinel\tregular-file\tsetup\tyes\nartifact-manifest.tsv\tregular-file\tsetup\tyes\nisolation_model.py\tregular-file\tsetup\tyes\nbaseline.summary\tregular-file\tbaseline\tno\nactive-case.state\tregular-file\tinject\tno\nrecovery.summary\tregular-file\trecover\tno\nverification.summary\tregular-file\tverify\tno'
readonly BASELINE_KEYS="record case operation_success workload_id instance_id namespace_view cgroup_id memory_current_bytes memory_max_bytes memory_oom memory_oom_kill cpu_nr_throttled pids_current pids_max pids_max_events"
readonly IDENTITY_KEYS="record case view workload_id instance_id namespace_view cgroup_id"
readonly RESOURCE_KEYS="record case view memory_current_bytes memory_max_bytes cpu_nr_throttled pids_current pids_max"
readonly EVENT_KEYS="record case view memory_oom memory_oom_kill cpu_nr_throttled pids_max_events"
readonly OPERATION_KEYS="record case view operation operation_success error"
readonly RECOVERY_KEYS="record case action operation_success memory_current_bytes memory_oom_kill_delta_after cpu_nr_throttled_delta_after pids_current pids_max_events_delta_after"
readonly VERIFICATION_KEYS="record case operation operation_success durable_outputs duplicate_outputs lost_outputs verification_scope"

LAB_ROOT=""
ROLLBACK_ROOT=""
ACTIVE_CASE=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

require_normal_user() {
  if [[ "$LAB_UID" -eq 0 ]]; then
    fail "run this lab from a normal non-root Ubuntu shell"
    return 1
  fi
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

state_file_present() {
  path_present "$STATE_FILE"
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

  for tool in awk bash basename cat chmod cmp dirname find findmnt grep id \
    install mktemp python3 readlink realpath rm rmdir stat
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
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s' \
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
  if [[ "$owner" != "$LAB_UID" || "$links" != "1" \
    || "$mode" != "$expected_mode" ]]; then
    fail "$label owner, link count, or mode changed"
    return 1
  fi
}

require_cleanup_file() {
  local path="$1" label="$2"
  local owner links

  if [[ ! -f "$path" || -L "$path" ]]; then
    fail "$label must be a regular non-symlink file"
    return 1
  fi
  owner="$(stat -c '%u' -- "$path")"
  links="$(stat -c '%h' -- "$path")"
  if [[ "$owner" != "$LAB_UID" || "$links" != "1" ]]; then
    fail "$label owner or link count changed"
    return 1
  fi
}

list_owned_orphan_candidates() {
  local -a entries=()
  local candidate owner resolved

  mapfile -d '' entries < <(
    find -P /tmp -mindepth 1 -maxdepth 1 -type d \
      -uid "$LAB_UID" -name "${LAB_PREFIX}????????" -print0
  )
  for candidate in "${entries[@]}"; do
    if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0011\.[[:alnum:]]{8}$ \
      || ! -d "$candidate" || -L "$candidate" ]]; then
      continue
    fi
    owner="$(stat -c '%u' -- "$candidate" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$candidate" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$resolved" == "$candidate" ]]; then
      printf '%s\0' "$candidate"
    fi
  done
}

require_no_orphan_candidates() {
  local -a candidates=()
  mapfile -d '' candidates < <(list_owned_orphan_candidates)
  if [[ "${#candidates[@]}" -ne 0 ]]; then
    fail "unregistered lesson root candidate exists: ${candidates[0]}"
    return 1
  fi
}

validate_root_path() {
  local candidate="$1" resolved owner mode

  if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0011\.[[:alnum:]]{8}$ ]]; then
    fail "recorded lab path is outside the lesson-specific /tmp prefix"
    return 1
  fi
  if [[ "$(dirname -- "$candidate")" != "/tmp" \
    || ! -d "$candidate" || -L "$candidate" ]]; then
    fail "recorded lab root is missing, not a directory, or a symlink"
    return 1
  fi
  resolved="$(realpath -e -- "$candidate")"
  owner="$(stat -c '%u' -- "$candidate")"
  mode="$(stat -c '%a' -- "$candidate")"
  if [[ "$resolved" != "$candidate" || "$owner" != "$LAB_UID" \
    || "$mode" != "700" ]]; then
    fail "recorded lab root resolution, owner, or mode changed"
    return 1
  fi
}

validate_root_identity() {
  validate_root_path "$LAB_ROOT"
  require_regular_owned_file \
    "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then
    fail "lesson sentinel content changed"
    return 1
  fi
}

load_state() {
  local -a lines=()

  if ! state_file_present; then
    fail "lab state is absent; run: bash lab.sh setup"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  mapfile -t lines < "$STATE_FILE"
  if [[ "${#lines[@]}" -ne 4 \
    || "${lines[0]}" != "state_version=1" \
    || "${lines[1]}" != "lesson_id=$LESSON_ID" \
    || "${lines[2]}" != "owner_uid=$LAB_UID" \
    || "${lines[3]}" != lab_root=* ]]; then
    fail "state descriptor content is invalid"
    return 1
  fi
  LAB_ROOT="${lines[3]#lab_root=}"
  validate_root_identity
  if ! cmp -s -- "$STATE_FILE" <(expected_state_descriptor "$LAB_ROOT"); then
    fail "state descriptor content changed"
    return 1
  fi
}

is_allowed_artifact() {
  case "$1" in
    "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|"$BASELINE_NAME"|\
    "$CASE_NAME"|"$RECOVERY_NAME"|"$VERIFICATION_NAME")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_output_shape() {
  local output="$1" expected_key_string="$2" label="$3"
  local -a expected_keys=() lines=()
  local index line key value

  read -r -a expected_keys <<< "$expected_key_string"
  mapfile -t lines <<< "$output"
  if [[ "${#lines[@]}" -ne "${#expected_keys[@]}" ]]; then
    fail "$label returned an unexpected number of fields"
    return 1
  fi
  for index in "${!expected_keys[@]}"; do
    line="${lines[$index]}"
    if [[ "$line" != *=* ]]; then
      fail "$label returned a malformed field"
      return 1
    fi
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "$key" != "${expected_keys[$index]}" ]]; then
      fail "$label field order changed at $key"
      return 1
    fi
    if [[ ! "$value" =~ ^[A-Za-z0-9][A-Za-z0-9._:+,/-]*$ ]]; then
      fail "$label returned an unsafe value for $key"
      return 1
    fi
  done
}

load_active_case() {
  local -a lines=()

  require_regular_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
  mapfile -t lines < "$LAB_ROOT/$CASE_NAME"
  if [[ "${#lines[@]}" -ne 1 || "${lines[0]}" != case=* ]]; then
    fail "active case content is invalid"
    return 1
  fi
  ACTIVE_CASE="${lines[0]#case=}"
  case "$ACTIVE_CASE" in
    guided|transfer) ;;
    *)
      fail "active case name is invalid"
      return 1
      ;;
  esac
}

compare_recorded_output() {
  local path="$1" keys="$2" label="$3"
  shift 3
  local expected

  require_regular_owned_file "$path" "600" "$label"
  expected="$(python3 "$LAB_ROOT/$MODEL_NAME" "$@")"
  validate_output_shape "$expected" "$keys" "$label"
  if ! cmp -s -- "$path" <(printf '%s\n' "$expected"); then
    fail "$label content changed; use guarded reset if cleanup identity remains valid"
    return 1
  fi
}

validate_artifacts() {
  local mode="$1"
  local -a entries=()
  local entry name

  mapfile -d '' entries < <(find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
  for entry in "${entries[@]}"; do
    name="$(basename -- "$entry")"
    if ! is_allowed_artifact "$name"; then
      fail "unexpected artifact blocks safe operation: $name"
      return 1
    fi
    if [[ "$mode" == "cleanup" ]]; then
      require_cleanup_file "$entry" "artifact $name"
    fi
  done

  if [[ "$mode" == "cleanup" ]]; then
    return 0
  fi

  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "artifact manifest"
  require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "fixture model"
  if ! cmp -s -- "$LAB_ROOT/$MANIFEST_NAME" <(printf '%s\n' "$EXPECTED_MANIFEST"); then
    fail "artifact manifest content changed; use guarded reset if cleanup identity remains valid"
    return 1
  fi
  if ! cmp -s -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"; then
    fail "fixture model copy changed; use guarded reset if cleanup identity remains valid"
    return 1
  fi

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    compare_recorded_output \
      "$LAB_ROOT/$BASELINE_NAME" "$BASELINE_KEYS" "baseline summary" baseline
  fi
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
      fail "active case requires a validated baseline"
      return 1
    fi
    load_active_case
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    if [[ -z "$ACTIVE_CASE" ]]; then
      fail "recovery summary exists without an active case"
      return 1
    fi
    compare_recorded_output \
      "$LAB_ROOT/$RECOVERY_NAME" "$RECOVERY_KEYS" "recovery summary" \
      recover --case "$ACTIVE_CASE"
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    if [[ -z "$ACTIVE_CASE" \
      || ! -f "$LAB_ROOT/$RECOVERY_NAME" \
      || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
      fail "verification requires a validated recovery"
      return 1
    fi
    compare_recorded_output \
      "$LAB_ROOT/$VERIFICATION_NAME" "$VERIFICATION_KEYS" \
      "verification summary" verify --case "$ACTIVE_CASE"
  fi
}

artifact_state() {
  if [[ -f "$1" && ! -L "$1" ]]; then
    printf 'complete'
  else
    printf 'pending'
  fi
}

write_immutable_record() {
  local path="$1" content="$2"
  set -o noclobber
  printf '%s\n' "$content" > "$path"
  set +o noclobber
  chmod 600 -- "$path"
}

rollback_setup() {
  local path owner links mode resolved name

  if [[ -n "$ROLLBACK_ROOT" \
    && "$ROLLBACK_ROOT" =~ ^/tmp/reliability-atlas-LES-0011\.[[:alnum:]]{8}$ \
    && -d "$ROLLBACK_ROOT" && ! -L "$ROLLBACK_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$mode" == "700" \
      && "$resolved" == "$ROLLBACK_ROOT" ]]; then
      for name in "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"; do
        path="$ROLLBACK_ROOT/$name"
        if [[ -f "$path" && ! -L "$path" ]]; then
          owner="$(stat -c '%u' -- "$path" 2>/dev/null || true)"
          links="$(stat -c '%h' -- "$path" 2>/dev/null || true)"
          if [[ "$owner" == "$LAB_UID" && "$links" == "1" ]]; then
            rm -- "$path" 2>/dev/null || true
          fi
        fi
      done
      rmdir -- "$ROLLBACK_ROOT" 2>/dev/null || true
    fi
  fi
  if [[ -n "$ROLLBACK_ROOT" && -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    owner="$(stat -c '%u' -- "$STATE_FILE" 2>/dev/null || true)"
    links="$(stat -c '%h' -- "$STATE_FILE" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$STATE_FILE" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$links" == "1" && "$mode" == "600" ]] \
      && cmp -s -- "$STATE_FILE" <(expected_state_descriptor "$ROLLBACK_ROOT")
    then
      rm -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
}

command_check() {
  require_environment
  if ! state_file_present; then
    require_no_orphan_candidates
  fi
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'environment=ready\n'
  printf 'privilege=normal-user\n'
  printf 'network=none\n'
  printf 'execution=deterministic-virtual-model\n'
  if state_file_present; then
    load_state
    validate_artifacts strict
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
  else
    printf 'state=absent\n'
    printf 'next_command=bash lab.sh setup\n'
  fi
}

command_host_observe() {
  local type value cgroup_fs cgroup_membership

  require_environment
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'host_observation=read-only\n'
  printf 'pid=%s\n' "$$"
  printf 'uid=%s\n' "$LAB_UID"
  for type in mnt pid net user uts ipc cgroup time; do
    value="$(readlink "/proc/self/ns/$type" 2>/dev/null || true)"
    if [[ -z "$value" ]]; then
      value="unavailable"
    fi
    printf 'namespace_%s=%s\n' "$type" "$value"
  done
  cgroup_fs="$(findmnt -no FSTYPE /sys/fs/cgroup 2>/dev/null || true)"
  if [[ -z "$cgroup_fs" ]]; then
    cgroup_fs="unavailable"
  fi
  cgroup_membership="$(awk -F: '$1 == "0" { print $3 }' /proc/self/cgroup 2>/dev/null || true)"
  if [[ -z "$cgroup_membership" ]]; then
    cgroup_membership="unavailable"
  fi
  printf 'cgroup_filesystem=%s\n' "$cgroup_fs"
  printf 'cgroup_membership=%s\n' "$cgroup_membership"
  printf 'mutation=none\n'
}

command_setup() {
  require_environment
  if state_file_present; then
    load_state
    validate_artifacts strict
    printf 'setup=already-present\n'
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    return 0
  fi
  require_no_orphan_candidates

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
  expected_state_descriptor "$LAB_ROOT" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"

  load_state
  validate_artifacts strict
  ROLLBACK_ROOT=""
  trap - EXIT INT TERM
  printf 'setup=complete\n'
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'next_command=bash lab.sh baseline\n'
}

command_status() {
  require_environment
  load_state
  validate_artifacts strict
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'baseline=%s\n' "$(artifact_state "$LAB_ROOT/$BASELINE_NAME")"
  if [[ -n "$ACTIVE_CASE" ]]; then
    printf 'active_case=%s\n' "$ACTIVE_CASE"
  else
    printf 'active_case=none\n'
  fi
  printf 'recovery=%s\n' "$(artifact_state "$LAB_ROOT/$RECOVERY_NAME")"
  printf 'verification=%s\n' "$(artifact_state "$LAB_ROOT/$VERIFICATION_NAME")"
  printf 'execution=deterministic-virtual-model\n'
  printf 'host_mutation=none\n'
}

command_baseline() {
  local output path
  require_environment
  load_state
  validate_artifacts strict
  path="$LAB_ROOT/$BASELINE_NAME"
  if path_present "$path"; then
    fail "baseline was already recorded; use guarded reset for a fresh attempt"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "baseline must be recorded before incident injection"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
  validate_output_shape "$output" "$BASELINE_KEYS" "baseline"
  write_immutable_record "$path" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
}

command_inject() {
  local case_name="$1"
  case "$case_name" in
    guided|transfer) ;;
    *)
      fail "case must be guided or transfer"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts strict
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before incident injection"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "an incident case is already active; use guarded reset for another case"
    return 1
  fi
  write_immutable_record "$LAB_ROOT/$CASE_NAME" "case=$case_name"
  validate_artifacts strict
  printf 'injection=complete\n'
  printf 'case=%s\n' "$case_name"
  printf 'failure_scope=deterministic-model-only\n'
  printf 'next_command=bash lab.sh observe identity\n'
}

command_observe() {
  local view="$1" keys output
  case "$view" in
    identity) keys="$IDENTITY_KEYS" ;;
    resources) keys="$RESOURCE_KEYS" ;;
    events) keys="$EVENT_KEYS" ;;
    operation) keys="$OPERATION_KEYS" ;;
    *)
      fail "view must be identity, resources, events, or operation"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts strict
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no incident case is active; inject a case after the baseline"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "the virtual case is already recovered; verify or reset"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" observe --case "$ACTIVE_CASE" --view "$view")"
  validate_output_shape "$output" "$keys" "$view observation"
  printf '%s\n' "$output"
}

command_recover() {
  local output
  require_environment
  load_state
  validate_artifacts strict
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no incident case is active"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "recovery was already recorded; verify or reset"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE")"
  validate_output_shape "$output" "$RECOVERY_KEYS" "recovery"
  write_immutable_record "$LAB_ROOT/$RECOVERY_NAME" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
  printf 'next_command=bash lab.sh verify\n'
}

command_verify() {
  local output
  require_environment
  load_state
  validate_artifacts strict
  if [[ -z "$ACTIVE_CASE" \
    || ! -f "$LAB_ROOT/$RECOVERY_NAME" \
    || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "verify requires a validated recovery"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    fail "verification was already recorded; inspect status or reset"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE")"
  validate_output_shape "$output" "$VERIFICATION_KEYS" "verification"
  write_immutable_record "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
}

command_cleanup() {
  local name root_before
  require_environment
  if ! state_file_present; then
    require_no_orphan_candidates
    printf 'cleanup=already-clean\n'
    printf 'state=absent\n'
    printf 'cleanup_proven=true\n'
    return 0
  fi
  load_state
  root_before="$LAB_ROOT"
  validate_artifacts cleanup
  validate_root_identity

  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$CASE_NAME" \
    "$BASELINE_NAME" "$MODEL_NAME" "$MANIFEST_NAME"; do
    if path_present "$LAB_ROOT/$name"; then
      require_cleanup_file "$LAB_ROOT/$name" "artifact $name"
      rm -- "$LAB_ROOT/$name"
    fi
  done
  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then
    fail "lesson sentinel changed during cleanup"
    return 1
  fi
  rm -- "$LAB_ROOT/$SENTINEL_NAME"
  if ! rmdir -- "$LAB_ROOT"; then
    fail "lab root changed during cleanup; inspect without recursive deletion"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  if ! cmp -s -- "$STATE_FILE" <(expected_state_descriptor "$root_before"); then
    fail "state descriptor changed during cleanup"
    return 1
  fi
  rm -- "$STATE_FILE"
  if path_present "$STATE_FILE" || path_present "$root_before"; then
    fail "cleanup absence proof failed"
    return 1
  fi
  require_no_orphan_candidates
  printf 'cleanup=complete\n'
  printf 'state=absent\n'
  printf 'cleanup_proven=true\n'
}

command_reset() {
  command_cleanup
  command_setup
}

usage() {
  printf '%s\n' \
    "Usage: bash lab.sh check" \
    "       bash lab.sh host-observe" \
    "       bash lab.sh setup" \
    "       bash lab.sh status" \
    "       bash lab.sh baseline" \
    "       bash lab.sh inject guided|transfer" \
    "       bash lab.sh observe identity|resources|events|operation" \
    "       bash lab.sh recover" \
    "       bash lab.sh verify" \
    "       bash lab.sh cleanup" \
    "       bash lab.sh reset"
}

main() {
  local command="${1:-}"
  case "$command" in
    check|host-observe|setup|status|baseline|recover|verify|cleanup|reset)
      if [[ "$#" -ne 1 ]]; then
        fail "unexpected argument count"
        usage >&2
        return 2
      fi
      "command_${command//-/_}"
      ;;
    inject|observe)
      if [[ "$#" -ne 2 ]]; then
        fail "$command requires exactly one allowlisted value"
        usage >&2
        return 2
      fi
      "command_$command" "$2"
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac
}

main "$@"
