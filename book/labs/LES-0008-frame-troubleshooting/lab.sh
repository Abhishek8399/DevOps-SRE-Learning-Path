#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0008"
readonly LAB_VERSION="1"
readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/incident_model.py"
readonly LAB_UID="$(id -u)"
readonly LAB_PREFIX="devops-sre-LES-0008-frame-troubleshooting."
readonly STATE_FILE="/tmp/devops-sre-LES-0008-frame-troubleshooting-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0008-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="incident_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active-case.state"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly EXPECTED_MANIFEST=$'artifact\ttype\tcreated_by\trequired\n.les-0008-sentinel\tregular-file\tsetup\tyes\nartifact-manifest.tsv\tregular-file\tsetup\tyes\nincident_model.py\tregular-file\tsetup\tyes\nbaseline.summary\tregular-file\trun baseline\tno\nactive-case.state\tregular-file\tinject\tno\nretry-off.experiment\tregular-file\texperiment retry-off\tno\nknown-good-workers.experiment\tregular-file\texperiment known-good-workers\tno\nrecovery.summary\tregular-file\trecover\tno\nverification.summary\tregular-file\tverify-operation\tno'
readonly BASELINE_KEYS="record case requests successes timeouts p95_latency_ms app_p95_ms dependency_p95_ms max_queue dependency_calls retries worker_limit app_revision config_revision"
readonly SYMPTOM_KEYS="record case view requests successes timeouts p95_latency_ms error"
readonly TIMELINE_KEYS="record case view baseline_at event_at symptom_at followup_at observation"
readonly PATH_KEYS="record case view gateway_p95_ms app_only_p95_ms dependency_p95_ms max_queue dependency_calls"
readonly CHANGE_KEYS="record case view app_revision_before app_revision_after worker_limit_before worker_limit_after retry_limit_before retry_limit_after config_revision_before config_revision_after"
readonly PROBE_KEYS="record case probe requests successes p95_latency_ms max_queue conclusion_hint"
readonly EXPERIMENT_KEYS="record case experiment requests successes timeouts p95_latency_ms dependency_calls max_queue worker_limit result"
readonly RECOVERY_KEYS="record case action requests successes timeouts p95_latency_ms dependency_calls max_queue worker_limit lost_work"
readonly VERIFICATION_KEYS="record case operation requests successes timeouts p95_latency_ms lost_work recovery_verified"

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
    fail "incident model source must be a regular non-symlink file"
    return 1
  fi
}

state_file_present() {
  [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
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

expected_state_descriptor() {
  local root="$1"

  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$root"
}

list_owned_orphan_candidates() {
  local -a entries=()
  local candidate owner resolved

  mapfile -d '' entries < <(
    find -P /tmp -mindepth 1 -maxdepth 1 -type d \
      -uid "$LAB_UID" -name "${LAB_PREFIX}????????" -print0
  )
  for candidate in "${entries[@]}"; do
    if [[ ! "$candidate" =~ ^/tmp/devops-sre-LES-0008-frame-troubleshooting\.[[:alnum:]]{8}$ \
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

  if [[ ! "$candidate" =~ ^/tmp/devops-sre-LES-0008-frame-troubleshooting\.[[:alnum:]]{8}$ ]]; then
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
    "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|"$BASELINE_NAME"|\
    "$CASE_NAME"|retry-off.experiment|known-good-workers.experiment|\
    "$RECOVERY_NAME"|"$VERIFICATION_NAME")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_output_shape() {
  local output="$1" expected_key_string="$2" label="$3"
  local -a expected_keys=() output_lines=()
  local index line key value

  read -r -a expected_keys <<< "$expected_key_string"
  mapfile -t output_lines <<< "$output"
  if [[ "${#output_lines[@]}" -ne "${#expected_keys[@]}" ]]; then
    fail "$label returned an unexpected number of fields"
    return 1
  fi
  for index in "${!expected_keys[@]}"; do
    line="${output_lines[$index]}"
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
  local -a case_lines=()

  require_regular_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
  mapfile -t case_lines < "$LAB_ROOT/$CASE_NAME"
  if [[ "${#case_lines[@]}" -ne 1 \
    || "${case_lines[0]}" != case=* ]]; then
    fail "active case content is invalid"
    return 1
  fi
  ACTIVE_CASE="${case_lines[0]#case=}"
  case "$ACTIVE_CASE" in
    guided|changed|transfer)
      ;;
    *)
      fail "active case name is invalid"
      return 1
      ;;
  esac
}

compare_recorded_output() {
  local path="$1" expected_keys="$2" label="$3"
  shift 3
  local expected

  require_regular_owned_file "$path" "600" "$label"
  expected="$(python3 "$LAB_ROOT/$MODEL_NAME" "$@")"
  validate_output_shape "$expected" "$expected_keys" "$label"
  if ! cmp -s -- "$path" <(printf '%s\n' "$expected"); then
    fail "$label content changed; use reset for recovery"
    return 1
  fi
}

validate_artifacts() {
  local mode="$1"
  local -a entries=()
  local entry name experiment path

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
    "$LAB_ROOT/$MODEL_NAME" "500" "incident model"

  if ! cmp -s -- "$LAB_ROOT/$MANIFEST_NAME" \
    <(printf '%s\n' "$EXPECTED_MANIFEST"); then
    fail "artifact manifest content changed; use reset for recovery"
    return 1
  fi
  if ! cmp -s -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"; then
    fail "incident model copy changed; use reset for recovery"
    return 1
  fi

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    compare_recorded_output \
      "$LAB_ROOT/$BASELINE_NAME" "$BASELINE_KEYS" "baseline summary" \
      baseline
  fi

  if path_present "$LAB_ROOT/$CASE_NAME"; then
    if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" \
      || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
      fail "active case requires a validated baseline"
      return 1
    fi
    load_active_case
  fi

  for experiment in retry-off known-good-workers; do
    path="$LAB_ROOT/$experiment.experiment"
    if path_present "$path"; then
      if [[ -z "$ACTIVE_CASE" ]]; then
        fail "$experiment experiment exists without an active case"
        return 1
      fi
      compare_recorded_output \
        "$path" "$EXPERIMENT_KEYS" "$experiment experiment" \
        experiment --case "$ACTIVE_CASE" --experiment "$experiment"
    fi
  done

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
      fail "operation verification requires a validated recovery"
      return 1
    fi
    compare_recorded_output \
      "$LAB_ROOT/$VERIFICATION_NAME" "$VERIFICATION_KEYS" \
      "operation verification" verify --case "$ACTIVE_CASE"
  fi
}

experiments_completed_csv() {
  local experiment completed=""

  for experiment in retry-off known-good-workers; do
    if [[ -f "$LAB_ROOT/$experiment.experiment" \
      && ! -L "$LAB_ROOT/$experiment.experiment" ]]; then
      if [[ -n "$completed" ]]; then
        completed+=","
      fi
      completed+="$experiment"
    fi
  done
  if [[ -z "$completed" ]]; then
    completed="none"
  fi
  printf '%s' "$completed"
}

artifact_state() {
  if [[ -f "$1" && ! -L "$1" ]]; then
    printf 'complete'
  else
    printf 'pending'
  fi
}

rollback_setup() {
  local name path owner links mode resolved

  if [[ -n "$ROLLBACK_ROOT" \
    && "$ROLLBACK_ROOT" =~ ^/tmp/devops-sre-LES-0008-frame-troubleshooting\.[[:alnum:]]{8}$ \
    && -d "$ROLLBACK_ROOT" && ! -L "$ROLLBACK_ROOT" ]]; then
    owner="$(stat -c '%u' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    resolved="$(realpath -e -- "$ROLLBACK_ROOT" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$mode" == "700" \
      && "$resolved" == "$ROLLBACK_ROOT" ]]; then
      for name in "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"; do
        path="$ROLLBACK_ROOT/$name"
        if path_present "$path" && [[ -f "$path" && ! -L "$path" ]]; then
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

  if [[ -n "$ROLLBACK_ROOT" ]] \
    && state_file_present \
    && [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    owner="$(stat -c '%u' -- "$STATE_FILE" 2>/dev/null || true)"
    links="$(stat -c '%h' -- "$STATE_FILE" 2>/dev/null || true)"
    mode="$(stat -c '%a' -- "$STATE_FILE" 2>/dev/null || true)"
    if [[ "$owner" == "$LAB_UID" && "$links" == "1" \
      && "$mode" == "600" ]] \
      && cmp -s -- "$STATE_FILE" \
        <(expected_state_descriptor "$ROLLBACK_ROOT")
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
  printf 'execution=virtual-time-bounded\n'
  printf 'privilege=normal-user\n'
  printf 'network=none\n'
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
  ROLLBACK_ROOT="$(
    mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX"
  )"
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
  printf 'next_command=bash lab.sh run baseline\n'
}

write_immutable_record() {
  local path="$1" content="$2"

  set -o noclobber
  printf '%s\n' "$content" > "$path"
  set +o noclobber
  chmod 600 -- "$path"
}

command_run_baseline() {
  local path output

  require_environment
  load_state
  validate_artifacts strict
  path="$LAB_ROOT/$BASELINE_NAME"
  if path_present "$path"; then
    fail "baseline was already recorded; use reset for a fresh attempt"
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
  local case_name="$1" path

  case "$case_name" in
    guided|changed|transfer)
      ;;
    *)
      fail "case must be guided, changed, or transfer"
      return 1
      ;;
  esac

  require_environment
  load_state
  validate_artifacts strict
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" \
    || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before incident injection"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "an incident case is already active; use reset for another case"
    return 1
  fi

  path="$LAB_ROOT/$CASE_NAME"
  write_immutable_record "$path" "case=$case_name"
  validate_artifacts strict
  printf 'injection=complete\n'
  printf 'case=%s\n' "$case_name"
  printf 'failure_scope=virtual-model-only\n'
  printf 'next_command=bash lab.sh observe symptoms\n'
}

require_active_incident() {
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no incident case is active; run inject after the baseline"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "the active case is already recovered; verify the operation or reset"
    return 1
  fi
}

command_observe() {
  local view="$1" expected_keys output

  case "$view" in
    symptoms)
      expected_keys="$SYMPTOM_KEYS"
      ;;
    timeline)
      expected_keys="$TIMELINE_KEYS"
      ;;
    path)
      expected_keys="$PATH_KEYS"
      ;;
    changes)
      expected_keys="$CHANGE_KEYS"
      ;;
    *)
      fail "view must be symptoms, timeline, path, or changes"
      return 1
      ;;
  esac

  require_environment
  load_state
  validate_artifacts strict
  require_active_incident
  output="$(
    python3 "$LAB_ROOT/$MODEL_NAME" observe \
      --case "$ACTIVE_CASE" --view "$view"
  )"
  validate_output_shape "$output" "$expected_keys" "$view observation"
  printf '%s\n' "$output"
}

command_probe() {
  local probe_name="$1" output

  case "$probe_name" in
    app-only|dependency-only|queue)
      ;;
    *)
      fail "probe must be app-only, dependency-only, or queue"
      return 1
      ;;
  esac

  require_environment
  load_state
  validate_artifacts strict
  require_active_incident
  output="$(
    python3 "$LAB_ROOT/$MODEL_NAME" probe \
      --case "$ACTIVE_CASE" --probe "$probe_name"
  )"
  validate_output_shape "$output" "$PROBE_KEYS" "$probe_name probe"
  printf '%s\n' "$output"
}

command_experiment() {
  local experiment="$1" path output

  case "$experiment" in
    retry-off|known-good-workers)
      ;;
    *)
      fail "experiment must be retry-off or known-good-workers"
      return 1
      ;;
  esac

  require_environment
  load_state
  validate_artifacts strict
  require_active_incident
  path="$LAB_ROOT/$experiment.experiment"
  if path_present "$path"; then
    fail "$experiment experiment was already recorded; use reset for a fresh attempt"
    return 1
  fi
  output="$(
    python3 "$LAB_ROOT/$MODEL_NAME" experiment \
      --case "$ACTIVE_CASE" --experiment "$experiment"
  )"
  validate_output_shape "$output" "$EXPERIMENT_KEYS" "$experiment experiment"
  write_immutable_record "$path" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
}

command_recover() {
  local path output

  require_environment
  load_state
  validate_artifacts strict
  require_active_incident
  path="$LAB_ROOT/$RECOVERY_NAME"
  if path_present "$path"; then
    fail "recovery was already recorded"
    return 1
  fi
  output="$(
    python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE"
  )"
  validate_output_shape "$output" "$RECOVERY_KEYS" "recovery"
  write_immutable_record "$path" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
}

command_verify_operation() {
  local path output

  require_environment
  load_state
  validate_artifacts strict
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no incident case is active"
    return 1
  fi
  if [[ ! -f "$LAB_ROOT/$RECOVERY_NAME" \
    || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "recover the virtual case before verifying the user operation"
    return 1
  fi
  path="$LAB_ROOT/$VERIFICATION_NAME"
  if path_present "$path"; then
    fail "operation verification was already recorded"
    return 1
  fi
  output="$(
    python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE"
  )"
  validate_output_shape "$output" "$VERIFICATION_KEYS" \
    "operation verification"
  if ! grep -Fxq -- "recovery_verified=true" <<< "$output"; then
    fail "operation verification did not prove recovery"
    return 1
  fi
  write_immutable_record "$path" "$output"
  validate_artifacts strict
  printf '%s\n' "$output"
}

command_status() {
  local baseline_state active_case_state="none"

  require_environment
  load_state
  validate_artifacts strict
  if [[ -f "$LAB_ROOT/$BASELINE_NAME" \
    && ! -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    baseline_state="recorded"
  else
    baseline_state="pending"
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    active_case_state="$ACTIVE_CASE"
  fi

  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'baseline=%s\n' "$baseline_state"
  printf 'active_case=%s\n' "$active_case_state"
  printf 'experiments_completed=%s\n' "$(experiments_completed_csv)"
  printf 'recovery=%s\n' "$(artifact_state "$LAB_ROOT/$RECOVERY_NAME")"
  printf 'operation_verification=%s\n' \
    "$(artifact_state "$LAB_ROOT/$VERIFICATION_NAME")"
  printf 'execution=virtual-time-bounded\n'
  printf 'cases_available=guided,changed,transfer\n'
}

remove_known_if_present() {
  local path="$1" label="$2"

  if path_present "$path"; then
    require_cleanup_file "$path" "$label"
    rm -- "$path"
  fi
}

restore_sentinel_after_race() {
  local sentinel_path="$LAB_ROOT/$SENTINEL_NAME"
  local owner mode resolved

  if [[ -e "$sentinel_path" || -L "$sentinel_path" \
    || ! -d "$LAB_ROOT" || -L "$LAB_ROOT" ]]; then
    return 0
  fi
  owner="$(stat -c '%u' -- "$LAB_ROOT" 2>/dev/null || true)"
  mode="$(stat -c '%a' -- "$LAB_ROOT" 2>/dev/null || true)"
  resolved="$(realpath -e -- "$LAB_ROOT" 2>/dev/null || true)"
  if [[ "$owner" != "$LAB_UID" || "$mode" != "700" \
    || "$resolved" != "$LAB_ROOT" ]]; then
    return 0
  fi

  set -o noclobber
  if expected_sentinel > "$sentinel_path"; then
    chmod 600 -- "$sentinel_path"
  fi
  set +o noclobber
}

command_cleanup() {
  local root_to_remove

  require_environment
  if ! state_file_present; then
    require_no_orphan_candidates
    printf 'cleanup=already-clean\n'
    printf 'state=absent\n'
    printf 'cleanup_proof_scope=descriptor-and-owned-candidates-at-check\n'
    printf 'cleanup_proven=true\n'
    return 0
  fi

  load_state
  validate_artifacts cleanup
  root_to_remove="$LAB_ROOT"

  remove_known_if_present \
    "$root_to_remove/$VERIFICATION_NAME" "operation verification"
  remove_known_if_present \
    "$root_to_remove/$RECOVERY_NAME" "recovery summary"
  remove_known_if_present \
    "$root_to_remove/known-good-workers.experiment" \
    "known-good-workers experiment"
  remove_known_if_present \
    "$root_to_remove/retry-off.experiment" "retry-off experiment"
  remove_known_if_present "$root_to_remove/$CASE_NAME" "active case"
  remove_known_if_present "$root_to_remove/$BASELINE_NAME" "baseline summary"
  remove_known_if_present "$root_to_remove/$MODEL_NAME" "incident model"
  remove_known_if_present "$root_to_remove/$MANIFEST_NAME" "artifact manifest"

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
  require_no_orphan_candidates

  LAB_ROOT=""
  ACTIVE_CASE=""
  printf 'cleanup=complete\n'
  printf 'state=absent\n'
  printf 'cleanup_proof_scope=descriptor-and-owned-candidates-at-check\n'
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
  bash lab.sh run baseline
  bash lab.sh inject guided|changed|transfer
  bash lab.sh observe symptoms|timeline|path|changes
  bash lab.sh probe app-only|dependency-only|queue
  bash lab.sh experiment retry-off|known-good-workers
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup
  bash lab.sh reset
USAGE
}

main() {
  local command_name="${1:-}"

  case "$command_name" in
    check|setup|status|recover|verify-operation|cleanup|reset)
      if [[ "$#" -ne 1 ]]; then
        usage >&2
        return 2
      fi
      if [[ "$command_name" == "verify-operation" ]]; then
        command_verify_operation
      else
        "command_$command_name"
      fi
      ;;
    run)
      if [[ "$#" -ne 2 || "$2" != "baseline" ]]; then
        usage >&2
        return 2
      fi
      command_run_baseline
      ;;
    inject|observe|probe|experiment)
      if [[ "$#" -ne 2 ]]; then
        usage >&2
        return 2
      fi
      "command_$command_name" "$2"
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac
}

main "$@"
