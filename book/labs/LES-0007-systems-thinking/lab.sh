#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0007"
readonly LAB_VERSION="1"
readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/queue_model.py"
readonly LAB_UID="$(id -u)"
readonly LAB_GID="$(id -g)"
readonly LAB_PREFIX="devops-sre-LES-0007-systems-thinking."
readonly STATE_FILE="/tmp/devops-sre-LES-0007-systems-thinking-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0007-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="queue_model.py"
readonly EXPECTED_MANIFEST=$'artifact\ttype\tcreated_by\trequired\n.les-0007-sentinel\tregular-file\tsetup\tyes\nartifact-manifest.tsv\tregular-file\tsetup\tyes\nqueue_model.py\tregular-file\tsetup\tyes\nstable.summary\tregular-file\trun stable\tno\nsaturated.summary\tregular-file\trun saturated\tno\nrecovered.summary\tregular-file\trun recovered\tno'
readonly SUMMARY_KEYS="profile jobs completed workers arrival_ms service_ms elapsed_ms throughput_per_s max_queue mean_wait_ms p95_wait_ms queue_capacity offered_rate_per_s nominal_capacity_per_s backpressure_jobs producer_blocked_ms max_admission_delay_ms mean_completion_latency_ms p95_completion_latency_ms"

LAB_ROOT=""
ROLLBACK_ROOT=""

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

require_environment() {
  local tool tmp_owner tmp_mode last_mode_character

  require_normal_user
  if [[ ! -d /tmp || -L /tmp ]]; then
    fail "/tmp must be a real directory"
    return 1
  fi
  tmp_owner="$(stat -c '%u' -- /tmp)"
  tmp_mode="$(stat -c '%A' -- /tmp)"
  last_mode_character="${tmp_mode:9:1}"
  if [[ "$tmp_owner" != "0" \
    || ( "$last_mode_character" != "t" \
      && "$last_mode_character" != "T" ) ]]; then
    fail "/tmp must be root-owned and sticky"
    return 1
  fi

  for tool in bash basename cat chmod cmp dirname find grep id install \
    mktemp python3 realpath rmdir rm stat
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
    fail "queue model source must be a regular non-symlink file"
    return 1
  fi
}

state_file_present() {
  [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]
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

expected_sentinel() {
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s' \
    "$LESSON_ID" "$LAB_VERSION" "$LAB_UID"
}

validate_root_path() {
  local candidate="$1" resolved owner mode

  if [[ ! "$candidate" =~ ^/tmp/devops-sre-LES-0007-systems-thinking\.[[:alnum:]]{8}$ ]]; then
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
  local actual_sentinel expected

  validate_root_path "$LAB_ROOT"
  require_regular_owned_file \
    "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  actual_sentinel="$(cat -- "$LAB_ROOT/$SENTINEL_NAME")"
  expected="$(expected_sentinel)"
  if [[ "$actual_sentinel" != "$expected" ]]; then
    fail "lesson sentinel content changed"
    return 1
  fi
}

load_state() {
  local -a state_lines=()

  if ! state_file_present; then
    fail "lab state is absent; run: bash lab.sh setup"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  mapfile -t state_lines < "$STATE_FILE"
  if [[ "${#state_lines[@]}" -ne 4 \
    || "${state_lines[0]}" != "state_version=1" \
    || "${state_lines[1]}" != "lesson_id=$LESSON_ID" \
    || "${state_lines[2]}" != "owner_uid=$LAB_UID" \
    || "${state_lines[3]}" != lab_root=* ]]; then
    fail "state descriptor content is invalid"
    return 1
  fi
  LAB_ROOT="${state_lines[3]#lab_root=}"
  validate_root_identity
}

is_allowed_artifact() {
  case "$1" in
    "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|\
    stable.summary|saturated.summary|recovered.summary)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_summary_output() {
  local output="$1" expected_profile="$2"
  local -a expected_keys=() output_lines=()
  local index line key value

  read -r -a expected_keys <<< "$SUMMARY_KEYS"
  mapfile -t output_lines <<< "$output"
  if [[ "${#output_lines[@]}" -ne "${#expected_keys[@]}" ]]; then
    fail "queue model returned an unexpected number of fields"
    return 1
  fi

  for index in "${!expected_keys[@]}"; do
    line="${output_lines[$index]}"
    if [[ "$line" != *=* ]]; then
      fail "queue model returned a malformed field"
      return 1
    fi
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "$key" != "${expected_keys[$index]}" ]]; then
      fail "queue model field order changed at $key"
      return 1
    fi
    if [[ "$key" == "profile" ]]; then
      if [[ "$value" != "$expected_profile" ]]; then
        fail "queue model returned the wrong profile"
        return 1
      fi
    elif [[ ! "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      fail "queue model returned a non-numeric value for $key"
      return 1
    fi
  done
}

validate_artifacts() {
  local mode="$1"
  local -a entries=()
  local entry name profile path actual expected

  mapfile -d '' entries < <(
    find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0
  )
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

  require_regular_owned_file \
    "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  require_regular_owned_file \
    "$LAB_ROOT/$MANIFEST_NAME" "600" "artifact manifest"
  require_regular_owned_file \
    "$LAB_ROOT/$MODEL_NAME" "500" "queue model"

  actual="$(cat -- "$LAB_ROOT/$MANIFEST_NAME")"
  if [[ "$actual" != "$EXPECTED_MANIFEST" ]]; then
    fail "artifact manifest content changed; use reset for recovery"
    return 1
  fi
  if ! cmp -s -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"; then
    fail "queue model copy changed; use reset for recovery"
    return 1
  fi

  for profile in stable saturated recovered; do
    path="$LAB_ROOT/$profile.summary"
    if [[ -e "$path" || -L "$path" ]]; then
      require_regular_owned_file "$path" "600" "$profile summary"
      actual="$(cat -- "$path")"
      expected="$(python3 "$LAB_ROOT/$MODEL_NAME" --profile "$profile")"
      validate_summary_output "$expected" "$profile"
      if [[ "$actual" != "$expected" ]]; then
        fail "$profile summary content changed; use reset for recovery"
        return 1
      fi
    fi
  done
}

completed_profiles_csv() {
  local profile completed=""

  for profile in stable saturated recovered; do
    if [[ -f "$LAB_ROOT/$profile.summary" \
      && ! -L "$LAB_ROOT/$profile.summary" ]]; then
      if [[ -n "$completed" ]]; then
        completed+=","
      fi
      completed+="$profile"
    fi
  done
  if [[ -z "$completed" ]]; then
    completed="none"
  fi
  printf '%s' "$completed"
}

rollback_setup() {
  local name path owner links mode resolved

  if [[ -n "$ROLLBACK_ROOT" \
    && "$ROLLBACK_ROOT" =~ ^/tmp/devops-sre-LES-0007-systems-thinking\.[[:alnum:]]{8}$ \
    && -d "$ROLLBACK_ROOT" \
    && ! -L "$ROLLBACK_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" \
      && "$mode" == "700" \
      && "$resolved" == "$ROLLBACK_ROOT" ]]; then
      for name in stable.summary saturated.summary recovered.summary \
        "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"
      do
        path="$ROLLBACK_ROOT/$name"
        if [[ -e "$path" || -L "$path" ]]; then
          if [[ -f "$path" && ! -L "$path" ]]; then
            owner="$(stat -c '%u' -- "$path" 2>/dev/null || true)"
            links="$(stat -c '%h' -- "$path" 2>/dev/null || true)"
            if [[ "$owner" == "$LAB_UID" && "$links" == "1" ]]; then
              rm -- "$path" 2>/dev/null || true
            fi
          fi
        fi
      done
      rmdir -- "$ROLLBACK_ROOT" 2>/dev/null || true
    fi
  fi

  if state_file_present \
    && [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    owner="$(stat -c '%u' -- "$STATE_FILE" 2>/dev/null || true)"
    links="$(stat -c '%h' -- "$STATE_FILE" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$STATE_FILE" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" \
      && "$links" == "1" \
      && "$mode" == "600" ]] \
      && grep -Fxq -- "lab_root=$ROLLBACK_ROOT" "$STATE_FILE" 2>/dev/null
    then
      rm -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
}

command_check() {
  require_environment

  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'environment=ready\n'
  printf 'execution=virtual-time-bounded\n'
  printf 'privilege=normal-user\n'
  if state_file_present; then
    load_state
    validate_artifacts strict
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    printf 'profiles_completed=%s\n' "$(completed_profiles_csv)"
  else
    printf 'state=absent\n'
    printf 'next_command=bash lab.sh setup\n'
  fi
}

command_setup() {
  local state_content

  require_environment
  if state_file_present; then
    load_state
    validate_artifacts strict
    printf 'setup=already-present\n'
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    return 0
  fi

  ROLLBACK_ROOT="$(
    mktemp -d --tmpdir=/tmp \
      "${LAB_PREFIX}XXXXXXXX"
  )"
  LAB_ROOT="$ROLLBACK_ROOT"
  trap rollback_setup EXIT
  trap 'exit 130' INT TERM

  validate_root_path "$LAB_ROOT"
  expected_sentinel > "$LAB_ROOT/$SENTINEL_NAME"
  chmod 600 -- "$LAB_ROOT/$SENTINEL_NAME"
  printf '%s\n' "$EXPECTED_MANIFEST" > "$LAB_ROOT/$MANIFEST_NAME"
  chmod 600 -- "$LAB_ROOT/$MANIFEST_NAME"
  install -m 0500 -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"

  state_content="$(
    printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
      "$LESSON_ID" "$LAB_UID" "$LAB_ROOT"
  )"
  set -o noclobber
  printf '%s\n' "$state_content" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"

  load_state
  validate_artifacts strict
  ROLLBACK_ROOT=""
  trap - EXIT INT TERM

  printf 'setup=complete\n'
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'next_command=bash lab.sh run stable\n'
}

command_run() {
  local profile="$1" summary_path output

  case "$profile" in
    stable|saturated|recovered)
      ;;
    *)
      fail "profile must be stable, saturated, or recovered"
      return 1
      ;;
  esac

  require_environment
  load_state
  validate_artifacts strict

  summary_path="$LAB_ROOT/$profile.summary"
  if [[ -e "$summary_path" || -L "$summary_path" ]]; then
    fail "$profile was already recorded; use reset to start a new run"
    return 1
  fi

  output="$(python3 "$LAB_ROOT/$MODEL_NAME" --profile "$profile")"
  validate_summary_output "$output" "$profile"

  set -o noclobber
  printf '%s\n' "$output" > "$summary_path"
  set +o noclobber
  chmod 600 -- "$summary_path"

  validate_artifacts strict
  printf '%s\n' "$output"
}

command_status() {
  require_environment
  load_state
  validate_artifacts strict

  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'profiles_completed=%s\n' "$(completed_profiles_csv)"
  printf 'execution=virtual-time-bounded\n'
  printf 'queue_capacity=3\n'
  printf 'profiles_available=stable,saturated,recovered\n'
}

remove_known_if_present() {
  local path="$1" label="$2"

  if [[ -e "$path" || -L "$path" ]]; then
    require_cleanup_file "$path" "$label"
    rm -- "$path"
  fi
}

restore_sentinel_after_race() {
  local sentinel_path="$LAB_ROOT/$SENTINEL_NAME"

  if [[ ! -e "$sentinel_path" && ! -L "$sentinel_path" \
    && -d "$LAB_ROOT" && ! -L "$LAB_ROOT" ]]; then
    set -o noclobber
    if expected_sentinel > "$sentinel_path"; then
      chmod 600 -- "$sentinel_path"
    fi
    set +o noclobber
  fi
}

command_cleanup() {
  local root_to_remove profile

  require_environment
  if ! state_file_present; then
    printf 'cleanup=already-clean\n'
    printf 'state=absent\n'
    printf 'cleanup_proven=true\n'
    return 0
  fi

  load_state
  validate_artifacts cleanup
  root_to_remove="$LAB_ROOT"

  for profile in stable saturated recovered; do
    remove_known_if_present \
      "$root_to_remove/$profile.summary" "$profile summary"
  done
  remove_known_if_present \
    "$root_to_remove/$MODEL_NAME" "queue model"
  remove_known_if_present \
    "$root_to_remove/$MANIFEST_NAME" "artifact manifest"

  require_cleanup_file \
    "$root_to_remove/$SENTINEL_NAME" "lesson sentinel"
  rm -- "$root_to_remove/$SENTINEL_NAME"
  if ! rmdir -- "$root_to_remove"; then
    restore_sentinel_after_race
    fail "lab root changed during cleanup; sentinel was restored when safe"
    return 1
  fi

  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  rm -- "$STATE_FILE"

  if [[ -e "$root_to_remove" || -L "$root_to_remove" \
    || -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    fail "cleanup absence proof failed"
    return 1
  fi

  LAB_ROOT=""
  printf 'cleanup=complete\n'
  printf 'state=absent\n'
  printf 'cleanup_proven=true\n'
}

command_reset() {
  require_environment
  if state_file_present; then
    command_cleanup
  fi
  command_setup
  printf 'reset=complete\n'
}

usage() {
  cat <<'USAGE'
Usage:
  bash lab.sh check
  bash lab.sh setup
  bash lab.sh status
  bash lab.sh run stable
  bash lab.sh run saturated
  bash lab.sh run recovered
  bash lab.sh cleanup
  bash lab.sh reset
USAGE
}

main() {
  local command_name="${1:-}"

  case "$command_name" in
    check|setup|status|cleanup|reset)
      if [[ "$#" -ne 1 ]]; then
        usage >&2
        return 2
      fi
      "command_$command_name"
      ;;
    run)
      if [[ "$#" -ne 2 ]]; then
        usage >&2
        return 2
      fi
      command_run "$2"
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac
}

main "$@"
