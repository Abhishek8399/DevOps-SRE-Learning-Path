#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0015"
readonly LAB_VERSION="1"
SCRIPT_DIRECTORY="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/http_path_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly LAB_PREFIX="reliability-atlas-LES-0015."
readonly STATE_FILE="/tmp/reliability-atlas-LES-0015-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0015-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="http_path_model.py"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active-case.state"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly EXPECTED_MANIFEST=$'artifact\ttype\tcreated_by\trequired\n.les-0015-sentinel\tregular-file\tsetup\tyes\nartifact-manifest.tsv\tregular-file\tsetup\tyes\nhttp_path_model.py\tregular-file\tsetup\tyes\nbaseline.summary\tregular-file\trun-baseline\tno\nactive-case.state\tregular-file\tinject\tno\nrecovery.summary\tregular-file\trecover\tno\nverification.summary\tregular-file\tverify-operation\tno'
readonly BASELINE_KEYS="record case operation result_status application_correct original_requests_per_second upstream_attempts_per_second success_percent p95_latency_ms cache_hit_percent cache_key_dimensions pool_connections_in_use pool_connections_limit pool_pending_current pool_pending_limit connection_reuse_percent healthy_backends total_backends origin_capacity_per_second"
readonly SCENARIO_KEYS="record case view operation method request_target context_a context_b overall_deadline_ms configured_max_attempts cache_mode expected_contract"
readonly OPERATION_KEYS="record case view operation method result_status status_issuer application_correct response_context observed_context total_latency_ms request_id_consistent"
readonly PROXY_KEYS="record case view original_requests_per_second upstream_attempts_per_second retries_per_second overall_deadline_ms per_try_timeout_ms forwarded_identity_source request_id_consistent"
readonly CACHE_KEYS="record case view lookup_result cache_entries cache_hit_percent cache_key_dimensions vary_fields cache_control age_seconds etag_present authorization_present"
readonly POOL_KEYS="record case view pool_connections_in_use pool_connections_limit pool_pending_current pool_pending_limit pool_acquire_p95_ms connection_reuse_percent"
readonly HEALTH_KEYS="record case view healthy_backends total_backends health_path origin_requests_per_second origin_capacity_per_second origin_p95_latency_ms"
readonly RECOVERY_KEYS="record case action change_scope result_status application_correct upstream_attempts_per_second pool_pending_current"
readonly VERIFICATION_KEYS="record case operation result_status application_correct context_a_correct context_b_correct unsafe_shared_hit attempt_ratio_within_budget pool_headroom_present queue_headroom_present verification_scope"

LAB_ROOT=""
ROLLBACK_ROOT=""
ACTIVE_CASE=""

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
  for tool in bash basename chmod cmp dirname find grep id install mktemp \
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
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s' \
    "$LESSON_ID" "$LAB_VERSION" "$LAB_UID"
}

expected_descriptor() {
  local root="$1"
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$root"
}

require_owned_file() {
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

list_orphan_roots() {
  local -a candidates=()
  local candidate owner resolved

  mapfile -d '' candidates < <(
    find -P /tmp -mindepth 1 -maxdepth 1 -type d \
      -uid "$LAB_UID" -name "${LAB_PREFIX}????????" -print0
  )
  for candidate in "${candidates[@]}"; do
    if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0015\.[[:alnum:]]{8}$ \
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

require_no_orphans() {
  local -a candidates=()
  mapfile -d '' candidates < <(list_orphan_roots)
  if [[ "${#candidates[@]}" -ne 0 ]]; then
    fail "unregistered lesson root candidate exists: ${candidates[0]}"
    return 1
  fi
}

validate_root() {
  local candidate="$1" resolved owner mode

  if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0015\.[[:alnum:]]{8}$ \
    || "$(dirname -- "$candidate")" != "/tmp" \
    || ! -d "$candidate" || -L "$candidate" ]]; then
    fail "registered root is outside the exact lesson-specific /tmp boundary"
    return 1
  fi
  resolved="$(realpath -e -- "$candidate")"
  owner="$(stat -c '%u' -- "$candidate")"
  mode="$(stat -c '%a' -- "$candidate")"
  if [[ "$resolved" != "$candidate" || "$owner" != "$LAB_UID" \
    || "$mode" != "700" ]]; then
    fail "registered root resolution, owner, or mode changed"
    return 1
  fi
}

validate_identity() {
  validate_root "$LAB_ROOT"
  require_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then
    fail "lesson sentinel content changed"
    return 1
  fi
}

load_state() {
  local -a lines=()

  if ! path_present "$STATE_FILE"; then
    fail "lab state is absent; run: bash lab.sh setup"
    return 1
  fi
  require_owned_file "$STATE_FILE" "600" "state descriptor"
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
  validate_identity
  if ! cmp -s -- "$STATE_FILE" <(expected_descriptor "$LAB_ROOT"); then
    fail "state descriptor content changed"
    return 1
  fi
}

is_allowed_artifact() {
  case "$1" in
    "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|"$BASELINE_NAME"|\
    "$CASE_NAME"|"$RECOVERY_NAME"|"$VERIFICATION_NAME") return 0 ;;
    *) return 1 ;;
  esac
}

validate_output() {
  local output="$1" expected_key_string="$2" label="$3"
  local -a keys=() lines=()
  local index line key value

  read -r -a keys <<< "$expected_key_string"
  mapfile -t lines <<< "$output"
  if [[ "${#lines[@]}" -ne "${#keys[@]}" ]]; then
    fail "$label returned an unexpected number of fields"
    return 1
  fi
  for index in "${!keys[@]}"; do
    line="${lines[$index]}"
    if [[ "$line" != *=* ]]; then
      fail "$label returned a malformed field"
      return 1
    fi
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "$key" != "${keys[$index]}" ]]; then
      fail "$label field order changed at $key"
      return 1
    fi
    if [[ ! "$value" =~ ^[A-Za-z0-9/][A-Za-z0-9._:+,/-]*$ ]]; then
      fail "$label returned an unsafe value for $key"
      return 1
    fi
  done
}

load_case() {
  local -a lines=()

  require_owned_file "$LAB_ROOT/$CASE_NAME" "600" "active case"
  mapfile -t lines < "$LAB_ROOT/$CASE_NAME"
  if [[ "${#lines[@]}" -ne 1 || "${lines[0]}" != case=* ]]; then
    fail "active case content is invalid"
    return 1
  fi
  ACTIVE_CASE="${lines[0]#case=}"
  case "$ACTIVE_CASE" in
    guided|independent) ;;
    *) fail "active case name is invalid"; return 1 ;;
  esac
}

compare_record() {
  local path="$1" expected_keys_string="$2" label="$3"
  shift 3
  local expected

  require_owned_file "$path" "600" "$label"
  expected="$(python3 "$LAB_ROOT/$MODEL_NAME" "$@")"
  validate_output "$expected" "$expected_keys_string" "$label"
  if ! cmp -s -- "$path" <(printf '%s\n' "$expected"); then
    fail "$label content changed"
    return 1
  fi
}

validate_artifacts() {
  local -a entries=()
  local entry name

  mapfile -d '' entries < <(find "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
  for entry in "${entries[@]}"; do
    name="$(basename -- "$entry")"
    if ! is_allowed_artifact "$name"; then
      fail "unexpected artifact blocks safe operation: $name"
      return 1
    fi
    if [[ "$name" == "$MODEL_NAME" ]]; then
      require_owned_file "$entry" "500" "fixture model"
    else
      require_owned_file "$entry" "600" "artifact $name"
    fi
  done

  require_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "artifact manifest"
  require_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "fixture model"
  if ! cmp -s -- "$LAB_ROOT/$MANIFEST_NAME" <(printf '%s\n' "$EXPECTED_MANIFEST"); then
    fail "artifact manifest content changed"
    return 1
  fi
  if ! cmp -s -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"; then
    fail "fixture model copy changed"
    return 1
  fi

  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    compare_record "$LAB_ROOT/$BASELINE_NAME" "$BASELINE_KEYS" \
      "baseline summary" baseline
  fi
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
      fail "active case requires a validated baseline"
      return 1
    fi
    load_case
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    if [[ -z "$ACTIVE_CASE" ]]; then
      fail "recovery exists without an active case"
      return 1
    fi
    compare_record "$LAB_ROOT/$RECOVERY_NAME" "$RECOVERY_KEYS" \
      "recovery summary" recover --case "$ACTIVE_CASE"
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    if [[ -z "$ACTIVE_CASE" || ! -f "$LAB_ROOT/$RECOVERY_NAME" \
      || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
      fail "verification requires a validated recovery"
      return 1
    fi
    compare_record "$LAB_ROOT/$VERIFICATION_NAME" "$VERIFICATION_KEYS" \
      "verification summary" verify --case "$ACTIVE_CASE"
  fi
}

write_record() {
  local path="$1" content="$2"
  set -o noclobber
  printf '%s\n' "$content" > "$path"
  set +o noclobber
  chmod 600 -- "$path"
}

rollback_setup() {
  local path name owner mode resolved links

  if [[ -n "$ROLLBACK_ROOT" \
    && "$ROLLBACK_ROOT" =~ ^/tmp/reliability-atlas-LES-0015\.[[:alnum:]]{8}$ \
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
      && cmp -s -- "$STATE_FILE" <(expected_descriptor "$ROLLBACK_ROOT")
    then
      rm -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
}

command_check() {
  require_environment
  if path_present "$STATE_FILE"; then
    load_state
    validate_artifacts
  else
    require_no_orphans
  fi
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'environment=ready\nprivilege=normal-user\nnetwork=none\n'
  printf 'execution=deterministic_http_model\n'
  if [[ -n "$LAB_ROOT" ]]; then
    printf 'state=ready\nlab_root=%s\n' "$LAB_ROOT"
  else
    printf 'state=absent\nnext_command=bash lab.sh setup\n'
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
  validate_root "$LAB_ROOT"
  expected_sentinel > "$LAB_ROOT/$SENTINEL_NAME"
  chmod 600 -- "$LAB_ROOT/$SENTINEL_NAME"
  printf '%s\n' "$EXPECTED_MANIFEST" > "$LAB_ROOT/$MANIFEST_NAME"
  chmod 600 -- "$LAB_ROOT/$MANIFEST_NAME"
  install -m 0500 -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"
  set -o noclobber
  expected_descriptor "$LAB_ROOT" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"
  load_state
  validate_artifacts
  ROLLBACK_ROOT=""
  trap - EXIT INT TERM
  printf 'setup=complete\nstate=ready\nlab_root=%s\n' "$LAB_ROOT"
  printf 'next_command=bash lab.sh run baseline\n'
}

command_status() {
  require_environment
  load_state
  validate_artifacts
  printf 'lesson_id=%s\nstate=ready\nlab_root=%s\n' "$LESSON_ID" "$LAB_ROOT"
  [[ -f "$LAB_ROOT/$BASELINE_NAME" ]] && printf 'baseline=complete\n' || printf 'baseline=pending\n'
  [[ -n "$ACTIVE_CASE" ]] && printf 'active_case=%s\n' "$ACTIVE_CASE" || printf 'active_case=none\n'
  [[ -f "$LAB_ROOT/$RECOVERY_NAME" ]] && printf 'recovery=complete\n' || printf 'recovery=pending\n'
  [[ -f "$LAB_ROOT/$VERIFICATION_NAME" ]] && printf 'verification=complete\n' || printf 'verification=pending\n'
  printf 'network_mutation=none\n'
}

command_run() {
  local target="$1" output
  if [[ "$target" != "baseline" ]]; then
    fail "run target must be baseline"
    return 1
  fi
  require_environment
  load_state
  validate_artifacts
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    fail "baseline already exists; clean and set up for a fresh attempt"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
  validate_output "$output" "$BASELINE_KEYS" "baseline"
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
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before selecting a case"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "a case is already active; clean and set up for another attempt"
    return 1
  fi
  write_record "$LAB_ROOT/$CASE_NAME" "case=$case_name"
  validate_artifacts
  printf 'injection=complete\ncase=%s\nfailure_scope=deterministic_model_only\n' "$case_name"
  printf 'answer_key=not_provided\nnext_command=bash lab.sh scenario\n'
}

command_scenario() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no active case; select one after recording the baseline"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" scenario --case "$ACTIVE_CASE")"
  validate_output "$output" "$SCENARIO_KEYS" "scenario inputs"
  printf '%s\n' "$output"
  printf 'observation_revealed=false\npredict_before_observe=true\n'
}

command_observe() {
  local view="$1" keys output
  case "$view" in
    operation) keys="$OPERATION_KEYS" ;;
    proxy) keys="$PROXY_KEYS" ;;
    cache) keys="$CACHE_KEYS" ;;
    pools) keys="$POOL_KEYS" ;;
    health) keys="$HEALTH_KEYS" ;;
    *) fail "view must be operation, proxy, cache, pools, or health"; return 1 ;;
  esac
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no active case"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "case is recovered; verify-operation or clean"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" observe --case "$ACTIVE_CASE" --view "$view")"
  validate_output "$output" "$keys" "$view observation"
  printf '%s\n' "$output"
}

command_recover() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" ]]; then fail "no active case"; return 1; fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then fail "recovery already recorded"; return 1; fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE")"
  validate_output "$output" "$RECOVERY_KEYS" "recovery"
  write_record "$LAB_ROOT/$RECOVERY_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
  printf 'next_command=bash lab.sh verify-operation\n'
}

command_verify_operation() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" || ! -f "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "record a validated recovery before verification"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then fail "verification already recorded"; return 1; fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE")"
  validate_output "$output" "$VERIFICATION_KEYS" "operation verification"
  write_record "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

command_cleanup() {
  local name path
  require_environment
  if ! path_present "$STATE_FILE"; then
    require_no_orphans
    printf 'cleanup=already-clean\ncleanup_proven=true\n'
    return 0
  fi
  load_state
  validate_artifacts
  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$CASE_NAME" \
    "$BASELINE_NAME" "$MODEL_NAME" "$MANIFEST_NAME" "$SENTINEL_NAME"
  do
    path="$LAB_ROOT/$name"
    if path_present "$path"; then
      if [[ "$name" == "$MODEL_NAME" ]]; then
        require_owned_file "$path" "500" "fixture model"
      else
        require_owned_file "$path" "600" "artifact $name"
      fi
      rm -- "$path"
    fi
  done
  rmdir -- "$LAB_ROOT"
  require_owned_file "$STATE_FILE" "600" "state descriptor"
  rm -- "$STATE_FILE"
  LAB_ROOT=""
  require_no_orphans
  printf 'cleanup=complete\ncleanup_proven=true\nstate=absent\n'
}

usage() {
  printf 'usage: bash lab.sh {check|setup|status|run baseline|inject guided|inject independent|scenario|observe operation|observe proxy|observe cache|observe pools|observe health|recover|verify-operation|cleanup}\n' >&2
}

main() {
  if [[ "$#" -lt 1 ]]; then usage; return 2; fi
  case "$1" in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      [[ "$#" -eq 1 ]] || { fail "unexpected arguments"; return 2; }
      "command_${1//-/_}"
      ;;
    run|inject|observe)
      [[ "$#" -eq 2 ]] || { fail "exactly one argument is required"; return 2; }
      "command_$1" "$2"
      ;;
    *) usage; return 2 ;;
  esac
}

main "$@"
