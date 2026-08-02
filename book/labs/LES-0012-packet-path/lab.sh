#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0012"
readonly LAB_VERSION="1"
SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly FIXTURE_SOURCE="$SCRIPT_DIRECTORY/fixtures/packet_path_model.py"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly LAB_PREFIX="reliability-atlas-LES-0012."
readonly STATE_FILE="/tmp/reliability-atlas-LES-0012-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0012-sentinel"
readonly MANIFEST_NAME="artifact-manifest.tsv"
readonly MODEL_NAME="packet_path_model.py"
readonly SCENARIO_NAME="scenario.input"
readonly BASELINE_NAME="baseline.summary"
readonly CASE_NAME="active-case.state"
readonly RECOVERY_NAME="recovery.summary"
readonly VERIFICATION_NAME="verification.summary"
readonly SCENARIO_KEYS="record case scenario_scope operation reported_symptom namespace source_cidr destination_address protocol destination_port policy_rules route_entries translation_config return_route_entries application_response_bytes planned_largest_tcp_segment_payload_bytes ip_header_bytes tcp_header_bytes underlay_link_mtu encapsulation_overhead_bytes pmtud_feedback_status"
readonly BASELINE_KEYS="record case operation source_address source_prefix destination_address winning_prefix route_type next_hop neighbor_state translation_state forward_result return_route reverse_state application_response_bytes tcp_segment_count largest_tcp_segment_payload_bytes ip_header_bytes tcp_header_bytes largest_emitted_ip_packet_bytes underlay_link_mtu encapsulation_overhead_bytes effective_inner_ip_mtu largest_encapsulated_packet_bytes mtu_headroom_bytes mtu_result control_feedback ttl_out operation_success"
readonly ADDRESS_KEYS="record case view namespace source_address prefix_length subnet_mask network_address broadcast_address destination_address gateway_on_link destination_on_link egress_interface interface_mtu"
readonly ROUTE_KEYS="record case view policy_rule selected_table candidate_routes winning_prefix route_type route_metric source_address next_hop egress_interface route_result"
readonly PATH_KEYS="record case view neighbor_target neighbor_state original_tuple translated_tuple translation_state forward_result return_route reverse_state application_response_bytes tcp_segment_count largest_tcp_segment_payload_bytes ip_header_bytes tcp_header_bytes largest_emitted_ip_packet_bytes underlay_link_mtu encapsulation_overhead_bytes effective_inner_ip_mtu largest_encapsulated_packet_bytes mtu_headroom_bytes mtu_result control_feedback ttl_out operation_success"
readonly NEIGHBOR_PROBE_KEYS="record case probe target interface state samples scope"
readonly RETURN_PROBE_KEYS="record case probe reply_destination selected_route state_owner reverse_state result scope"
readonly MTU_PROBE_KEYS="record case probe small_ip_packet_bytes small_encapsulated_packet_bytes small_result large_ip_packet_bytes large_encapsulated_packet_bytes large_result underlay_link_mtu encapsulation_overhead_bytes effective_inner_ip_mtu large_mtu_headroom_bytes control_feedback scope"
readonly RECOVERY_KEYS="record case action winning_prefix route_type neighbor_state translation_state return_route reverse_state segmentation_strategy application_response_bytes tcp_segment_count largest_tcp_segment_payload_bytes ip_header_bytes tcp_header_bytes largest_emitted_ip_packet_bytes underlay_link_mtu encapsulation_overhead_bytes effective_inner_ip_mtu largest_encapsulated_packet_bytes mtu_headroom_bytes mtu_result operation_success"
readonly VERIFICATION_KEYS="record case operation forward_result return_result translation_state reverse_state segmentation_strategy application_response_bytes tcp_segment_count largest_tcp_segment_payload_bytes ip_header_bytes tcp_header_bytes largest_emitted_ip_packet_bytes underlay_link_mtu encapsulation_overhead_bytes effective_inner_ip_mtu largest_encapsulated_packet_bytes mtu_headroom_bytes mtu_result operation_success verification_scope"

LAB_ROOT=""
ROLLBACK_ROOT=""
SCENARIO_CASE=""
ACTIVE_CASE=""
RECORDED_MODEL_SHA256=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

state_file_present() {
  path_present "$STATE_FILE"
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
    python3 readlink realpath rm rmdir sha256sum stat
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
  if [[ "$(stat -c '%h' -- "$FIXTURE_SOURCE")" != "1" ]]; then
    fail "fixture source link count changed"
    return 1
  fi
}

source_model_sha256() {
  local digest
  digest="$(sha256sum -- "$FIXTURE_SOURCE")"
  digest="${digest%% *}"
  if [[ ! "$digest" =~ ^[0-9a-f]{64}$ ]]; then
    fail "fixture source hash is invalid"
    return 1
  fi
  printf '%s' "$digest"
}

expected_sentinel() {
  local model_hash="$1"
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s\nnetwork=none\nhost_mutation=none\nmodel_sha256=%s' \
    "$LESSON_ID" "$LAB_VERSION" "$LAB_UID" "$model_hash"
}

expected_manifest() {
  local model_hash="$1"
  printf '%s\n' \
    $'artifact\ttype\tmode\tintegrity' \
    $'.les-0012-sentinel\tregular-file\t600\texact-content' \
    $'artifact-manifest.tsv\tregular-file\t600\texact-content' \
    "packet_path_model.py"$'\tregular-file\t500\tsha256:'"$model_hash" \
    $'scenario.input\tregular-file\t600\trecomputed-if-present' \
    $'baseline.summary\tregular-file\t600\trecomputed-if-present' \
    $'active-case.state\tregular-file\t600\texact-case-if-present' \
    $'recovery.summary\tregular-file\t600\trecomputed-if-present' \
    $'verification.summary\tregular-file\t600\trecomputed-if-present'
}

expected_state_descriptor() {
  local root="$1" model_hash="$2"
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\nmodel_sha256=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$root" "$model_hash"
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

list_owned_orphan_candidates() {
  local -a entries=()
  local candidate owner resolved

  mapfile -d '' entries < <(
    find -P /tmp -mindepth 1 -maxdepth 1 -type d \
      -uid "$LAB_UID" -name "${LAB_PREFIX}????????" -print0
  )
  for candidate in "${entries[@]}"; do
    if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0012\.[[:alnum:]]{8}$ \
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

  if [[ ! "$candidate" =~ ^/tmp/reliability-atlas-LES-0012\.[[:alnum:]]{8}$ ]]; then
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
  local model_hash="$1"
  validate_root_path "$LAB_ROOT"
  require_regular_owned_file \
    "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel "$model_hash"); then
    fail "lesson sentinel content changed"
    return 1
  fi
}

load_state() {
  local -a lines=()
  local current_hash

  if ! state_file_present; then
    fail "lab state is absent; run: bash lab.sh setup"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  mapfile -t lines < "$STATE_FILE"
  if [[ "${#lines[@]}" -ne 5 \
    || "${lines[0]}" != "state_version=1" \
    || "${lines[1]}" != "lesson_id=$LESSON_ID" \
    || "${lines[2]}" != "owner_uid=$LAB_UID" \
    || "${lines[3]}" != lab_root=* \
    || "${lines[4]}" != model_sha256=* ]]; then
    fail "state descriptor content is invalid"
    return 1
  fi

  LAB_ROOT="${lines[3]#lab_root=}"
  RECORDED_MODEL_SHA256="${lines[4]#model_sha256=}"
  if [[ ! "$RECORDED_MODEL_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
    fail "state descriptor model hash is invalid"
    return 1
  fi
  validate_root_path "$LAB_ROOT"
  current_hash="$(source_model_sha256)"
  if [[ "$RECORDED_MODEL_SHA256" != "$current_hash" ]]; then
    fail "fixture source hash changed since setup"
    return 1
  fi
  if ! cmp -s -- "$STATE_FILE" \
    <(expected_state_descriptor "$LAB_ROOT" "$current_hash"); then
    fail "state descriptor content changed"
    return 1
  fi
  validate_root_identity "$current_hash"
}

is_allowed_artifact() {
  case "$1" in
    "$SENTINEL_NAME"|"$MANIFEST_NAME"|"$MODEL_NAME"|"$SCENARIO_NAME"|\
    "$BASELINE_NAME"|"$CASE_NAME"|"$RECOVERY_NAME"|"$VERIFICATION_NAME")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

artifact_expected_mode() {
  case "$1" in
    "$MODEL_NAME") printf '500' ;;
    *) printf '600' ;;
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
    if [[ ! "$value" =~ ^-?[A-Za-z0-9][A-Za-z0-9._:+,/@%-]*$ ]]; then
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
    guided|independent) ;;
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
    fail "$label content changed"
    return 1
  fi
}
load_scenario_case() {
  local -a lines=()

  require_regular_owned_file "$LAB_ROOT/$SCENARIO_NAME" "600" "scenario input"
  mapfile -t lines < "$LAB_ROOT/$SCENARIO_NAME"
  if [[ "${#lines[@]}" -lt 2 \
    || "${lines[0]}" != "record=scenario" \
    || "${lines[1]}" != case=* ]]; then
    fail "scenario input content is invalid"
    return 1
  fi
  SCENARIO_CASE="${lines[1]#case=}"
  case "$SCENARIO_CASE" in
    guided|independent) ;;
    *)
      fail "scenario case name is invalid"
      return 1
      ;;
  esac
  compare_recorded_output \
    "$LAB_ROOT/$SCENARIO_NAME" "$SCENARIO_KEYS" "scenario input" \
    scenario --case "$SCENARIO_CASE"
}



validate_artifacts() {
  local -a entries=()
  local entry name actual_hash

  mapfile -d '' entries < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
  for entry in "${entries[@]}"; do
    name="$(basename -- "$entry")"
    if ! is_allowed_artifact "$name"; then
      fail "unexpected artifact blocks safe operation: $name"
      return 1
    fi
    require_regular_owned_file \
      "$entry" "$(artifact_expected_mode "$name")" "artifact $name"
  done

  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  require_regular_owned_file "$LAB_ROOT/$MANIFEST_NAME" "600" "artifact manifest"
  require_regular_owned_file "$LAB_ROOT/$MODEL_NAME" "500" "fixture model"
  if ! cmp -s -- "$LAB_ROOT/$MANIFEST_NAME" \
    <(expected_manifest "$RECORDED_MODEL_SHA256"); then
    fail "artifact manifest content changed"
    return 1
  fi
  actual_hash="$(sha256sum -- "$LAB_ROOT/$MODEL_NAME")"
  actual_hash="${actual_hash%% *}"
  if [[ "$actual_hash" != "$RECORDED_MODEL_SHA256" ]] \
    || ! cmp -s -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"; then
    fail "fixture model hash or content changed"
    return 1
  fi

  SCENARIO_CASE=""
  ACTIVE_CASE=""
  if path_present "$LAB_ROOT/$SCENARIO_NAME"; then
    load_scenario_case
  fi
  if path_present "$LAB_ROOT/$BASELINE_NAME"; then
    if [[ -z "$SCENARIO_CASE" ]]; then
      fail "baseline summary requires a validated scenario input"
      return 1
    fi
    compare_recorded_output \
      "$LAB_ROOT/$BASELINE_NAME" "$BASELINE_KEYS" "baseline summary" baseline
  fi
  if path_present "$LAB_ROOT/$CASE_NAME"; then
    if [[ -z "$SCENARIO_CASE" \
      || ! -f "$LAB_ROOT/$BASELINE_NAME" \
      || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
      fail "active case requires validated scenario input and baseline"
      return 1
    fi
    load_active_case
    if [[ "$ACTIVE_CASE" != "$SCENARIO_CASE" ]]; then
      fail "active case does not match the recorded scenario"
      return 1
    fi
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
    && "$ROLLBACK_ROOT" =~ ^/tmp/reliability-atlas-LES-0012\.[[:alnum:]]{8}$ \
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
      && cmp -s -- "$STATE_FILE" \
        <(expected_state_descriptor "$ROLLBACK_ROOT" "$(source_model_sha256)")
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
  printf 'host_mutation=none\n'
  if state_file_present; then
    load_state
    validate_artifacts
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
  else
    printf 'state=absent\n'
    printf 'next_command=bash lab.sh setup\n'
  fi
}

command_setup() {
  local model_hash
  require_environment
  if state_file_present; then
    load_state
    validate_artifacts
    printf 'setup=already-present\n'
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    return 0
  fi
  require_no_orphan_candidates
  model_hash="$(source_model_sha256)"

  trap rollback_setup EXIT
  trap 'exit 130' INT TERM
  ROLLBACK_ROOT="$(mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX")"
  LAB_ROOT="$ROLLBACK_ROOT"
  validate_root_path "$LAB_ROOT"

  expected_sentinel "$model_hash" > "$LAB_ROOT/$SENTINEL_NAME"
  chmod 600 -- "$LAB_ROOT/$SENTINEL_NAME"
  expected_manifest "$model_hash" > "$LAB_ROOT/$MANIFEST_NAME"
  chmod 600 -- "$LAB_ROOT/$MANIFEST_NAME"
  install -m 0500 -- "$FIXTURE_SOURCE" "$LAB_ROOT/$MODEL_NAME"

  set -o noclobber
  expected_state_descriptor "$LAB_ROOT" "$model_hash" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"

  load_state
  validate_artifacts
  ROLLBACK_ROOT=""
  trap - EXIT INT TERM
  printf 'setup=complete\n'
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'next_command=bash lab.sh scenario guided|independent\n'
}

command_status() {
  require_environment
  load_state
  validate_artifacts
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'state=ready\n'
  printf 'scenario=%s\n' "$(artifact_state "$LAB_ROOT/$SCENARIO_NAME")"
  if [[ -n "$SCENARIO_CASE" ]]; then
    printf 'scenario_case=%s\n' "$SCENARIO_CASE"
  else
    printf 'scenario_case=none\n'
  fi
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'baseline=%s\n' "$(artifact_state "$LAB_ROOT/$BASELINE_NAME")"
  if [[ -n "$ACTIVE_CASE" ]]; then
    printf 'active_case=%s\n' "$ACTIVE_CASE"
  else
    printf 'active_case=none\n'
  fi
  printf 'recovery=%s\n' "$(artifact_state "$LAB_ROOT/$RECOVERY_NAME")"
  printf 'verification=%s\n' "$(artifact_state "$LAB_ROOT/$VERIFICATION_NAME")"
  printf 'network=none\n'
  printf 'host_mutation=none\n'
}

command_scenario() {
  local case_name="$1" output
  case "$case_name" in
    guided|independent) ;;
    *)
      fail "scenario must be guided or independent"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts
  if path_present "$LAB_ROOT/$SCENARIO_NAME"; then
    fail "scenario input was already recorded; use guarded reset for another case"
    return 1
  fi
  if path_present "$LAB_ROOT/$BASELINE_NAME" || [[ -n "$ACTIVE_CASE" ]]; then
    fail "scenario input must be recorded before baseline or incident observation"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" scenario --case "$case_name")"
  validate_output_shape "$output" "$SCENARIO_KEYS" "scenario input"
  write_immutable_record "$LAB_ROOT/$SCENARIO_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
  printf 'prediction_record=external-required\n'
  printf 'next_command=bash lab.sh run baseline\n'
}


command_run() {
  local operation="$1" output path
  if [[ "$operation" != "baseline" ]]; then
    fail "run accepts only: baseline"
    return 1
  fi
  require_environment
  load_state
  validate_artifacts
  path="$LAB_ROOT/$BASELINE_NAME"
  if path_present "$path"; then
    fail "baseline was already recorded; use guarded reset for a fresh attempt"
    return 1
  fi
  if [[ -z "$SCENARIO_CASE" ]]; then
    fail "record a guided or independent scenario before baseline"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "baseline must be recorded before incident injection"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" baseline)"
  validate_output_shape "$output" "$BASELINE_KEYS" "baseline"
  write_immutable_record "$path" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

command_inject() {
  local case_name="$1"
  case "$case_name" in
    guided|independent) ;;
    *)
      fail "case must be guided or independent"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before incident injection"
    return 1
  fi
  if [[ -n "$ACTIVE_CASE" ]]; then
    fail "an incident case is already active; use guarded reset for another case"
    return 1
  fi
  if [[ "$case_name" != "$SCENARIO_CASE" ]]; then
    fail "injected case must match the recorded scenario"
    return 1
  fi
  write_immutable_record "$LAB_ROOT/$CASE_NAME" "case=$case_name"
  validate_artifacts
  printf 'injection=complete\n'
  printf 'case=%s\n' "$case_name"
  printf 'failure_scope=deterministic-model-only\n'
  printf 'next_command=bash lab.sh observe addresses\n'
}

current_observation_case() {
  if [[ -n "$ACTIVE_CASE" ]]; then
    printf '%s' "$ACTIVE_CASE"
  else
    printf 'baseline'
  fi
}

command_observe() {
  local view="$1" keys output case_name
  case "$view" in
    addresses) keys="$ADDRESS_KEYS" ;;
    routes) keys="$ROUTE_KEYS" ;;
    path) keys="$PATH_KEYS" ;;
    *)
      fail "view must be addresses, routes, or path"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before observation"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "the virtual case is already recovered; verify-operation or reset"
    return 1
  fi
  case_name="$(current_observation_case)"
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" observe --case "$case_name" --view "$view")"
  validate_output_shape "$output" "$keys" "$view observation"
  printf '%s\n' "$output"
}

command_probe() {
  local probe_name="$1" keys output case_name
  case "$probe_name" in
    neighbor) keys="$NEIGHBOR_PROBE_KEYS" ;;
    return) keys="$RETURN_PROBE_KEYS" ;;
    mtu) keys="$MTU_PROBE_KEYS" ;;
    *)
      fail "probe must be neighbor, return, or mtu"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_artifacts
  if [[ ! -f "$LAB_ROOT/$BASELINE_NAME" || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before a bounded probe"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "the virtual case is already recovered; verify-operation or reset"
    return 1
  fi
  case_name="$(current_observation_case)"
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" probe --case "$case_name" --probe "$probe_name")"
  validate_output_shape "$output" "$keys" "$probe_name probe"
  printf '%s\n' "$output"
  printf 'probe_scope=deterministic-model-only\n'
  printf 'packets_sent=0\n'
}

command_recover() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" ]]; then
    fail "no incident case is active"
    return 1
  fi
  if path_present "$LAB_ROOT/$RECOVERY_NAME"; then
    fail "recovery was already recorded; verify-operation or reset"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" recover --case "$ACTIVE_CASE")"
  validate_output_shape "$output" "$RECOVERY_KEYS" "recovery"
  write_immutable_record "$LAB_ROOT/$RECOVERY_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
  printf 'next_command=bash lab.sh verify-operation\n'
}

command_verify_operation() {
  local output
  require_environment
  load_state
  validate_artifacts
  if [[ -z "$ACTIVE_CASE" \
    || ! -f "$LAB_ROOT/$RECOVERY_NAME" \
    || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "verify-operation requires a validated recovery"
    return 1
  fi
  if path_present "$LAB_ROOT/$VERIFICATION_NAME"; then
    fail "operation verification was already recorded; inspect status or reset"
    return 1
  fi
  output="$(python3 "$LAB_ROOT/$MODEL_NAME" verify --case "$ACTIVE_CASE")"
  validate_output_shape "$output" "$VERIFICATION_KEYS" "operation verification"
  write_immutable_record "$LAB_ROOT/$VERIFICATION_NAME" "$output"
  validate_artifacts
  printf '%s\n' "$output"
}

command_cleanup() {
  local name root_before model_hash
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
  validate_artifacts
  root_before="$LAB_ROOT"
  model_hash="$RECORDED_MODEL_SHA256"

  for name in "$VERIFICATION_NAME" "$RECOVERY_NAME" "$CASE_NAME" \
    "$BASELINE_NAME" "$SCENARIO_NAME" "$MODEL_NAME" "$MANIFEST_NAME"; do
    if path_present "$LAB_ROOT/$name"; then
      require_regular_owned_file \
        "$LAB_ROOT/$name" "$(artifact_expected_mode "$name")" "artifact $name"
      rm -- "$LAB_ROOT/$name"
    fi
  done
  require_regular_owned_file "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel "$model_hash"); then
    fail "lesson sentinel changed during cleanup"
    return 1
  fi
  rm -- "$LAB_ROOT/$SENTINEL_NAME"
  if ! rmdir -- "$LAB_ROOT"; then
    fail "lab root changed during cleanup; inspect without recursive deletion"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
  if ! cmp -s -- "$STATE_FILE" \
    <(expected_state_descriptor "$root_before" "$model_hash"); then
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
  printf 'cleanup_proof_scope=validated-descriptor-root-manifest-hash-and-allowlist\n'
  printf 'cleanup_proven=true\n'
}

command_reset() {
  command_cleanup
  command_setup
}

usage() {
  printf '%s\n' \
    "Usage: bash lab.sh check" \
    "       bash lab.sh setup" \
    "       bash lab.sh status" \
    "       bash lab.sh run baseline" \
    "       bash lab.sh inject guided|independent" \
    "       bash lab.sh observe addresses|routes|path" \
    "       bash lab.sh probe neighbor|return|mtu" \
    "       bash lab.sh recover" \
    "       bash lab.sh verify-operation" \
    "       bash lab.sh scenario guided|independent" \
    "       bash lab.sh cleanup" \
    "       bash lab.sh reset"
}

main() {
  local command="${1:-}"
  case "$command" in
    check|setup|status|recover|verify-operation|cleanup|reset)
      if [[ "$#" -ne 1 ]]; then
        fail "unexpected argument count"
        usage >&2
        return 2
      fi
      "command_${command//-/_}"
      ;;
    scenario|run|inject|observe|probe)
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
