#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

VERIFY_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly VERIFY_DIRECTORY
readonly LAB_SCRIPT="$VERIFY_DIRECTORY/lab.sh"
readonly FIXTURE_SOURCE="$VERIFY_DIRECTORY/fixtures/packet_path_model.py"
readonly README_PATH="$VERIFY_DIRECTORY/README.md"
readonly LESSON_PATH="$VERIFY_DIRECTORY/../../volumes/02-connectivity/LES-0012-ethernet-ip-cidr-routing-nat/lesson.md"
readonly RESPONSE_TEMPLATE="$VERIFY_DIRECTORY/independent-response-template.md"
VERIFY_UID="$(id -u)"
readonly VERIFY_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0012-$VERIFY_UID.state"
readonly LAB_PREFIX="reliability-atlas-LES-0012."
readonly UNEXPECTED_NAME="verifier-unexpected.txt"

VERIFIER_ROOT=""
ORPHAN_ROOT=""
EXTERNAL_TARGET=""

verify_fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e "$1" || -L "$1" ]]
}

numeric_field() {
  local output="$1" key="$2" label="$3" line
  line="$(grep -E "^${key}=-?[0-9]+$" <<< "$output" || true)"
  if [[ -z "$line" || "$line" == *$'\n'* ]]; then
    verify_fail "$label requires exactly one numeric $key field"
    return 1
  fi
  printf '%s' "${line#*=}"
}

assert_packet_mtu_math() {
  local output="$1" label="$2"
  local application segments payload ip_header tcp_header packet
  local link_mtu overhead effective encapsulated headroom

  application="$(numeric_field "$output" application_response_bytes "$label")"
  segments="$(numeric_field "$output" tcp_segment_count "$label")"
  payload="$(numeric_field "$output" largest_tcp_segment_payload_bytes "$label")"
  ip_header="$(numeric_field "$output" ip_header_bytes "$label")"
  tcp_header="$(numeric_field "$output" tcp_header_bytes "$label")"
  packet="$(numeric_field "$output" largest_emitted_ip_packet_bytes "$label")"
  link_mtu="$(numeric_field "$output" underlay_link_mtu "$label")"
  overhead="$(numeric_field "$output" encapsulation_overhead_bytes "$label")"
  effective="$(numeric_field "$output" effective_inner_ip_mtu "$label")"
  encapsulated="$(numeric_field "$output" largest_encapsulated_packet_bytes "$label")"
  headroom="$(numeric_field "$output" mtu_headroom_bytes "$label")"

  if (( segments < 1 || application < payload )); then
    verify_fail "$label has an impossible application/segmentation relationship"
    return 1
  fi
  if (( packet != payload + ip_header + tcp_header )); then
    verify_fail "$label packet size does not equal TCP payload plus IP and TCP headers"
    return 1
  fi
  if (( effective != link_mtu - overhead )); then
    verify_fail "$label effective inner MTU does not equal link MTU minus overhead"
    return 1
  fi
  if (( encapsulated != packet + overhead )); then
    verify_fail "$label encapsulated size does not equal IP packet plus overhead"
    return 1
  fi
  if (( headroom != link_mtu - encapsulated )); then
    verify_fail "$label MTU headroom does not equal link MTU minus encapsulated size"
    return 1
  fi
}

assert_probe_mtu_math() {
  local output="$1" label="$2"
  local small_packet small_encapsulated large_packet large_encapsulated
  local link_mtu overhead effective headroom

  small_packet="$(numeric_field "$output" small_ip_packet_bytes "$label")"
  small_encapsulated="$(numeric_field "$output" small_encapsulated_packet_bytes "$label")"
  large_packet="$(numeric_field "$output" large_ip_packet_bytes "$label")"
  large_encapsulated="$(numeric_field "$output" large_encapsulated_packet_bytes "$label")"
  link_mtu="$(numeric_field "$output" underlay_link_mtu "$label")"
  overhead="$(numeric_field "$output" encapsulation_overhead_bytes "$label")"
  effective="$(numeric_field "$output" effective_inner_ip_mtu "$label")"
  headroom="$(numeric_field "$output" large_mtu_headroom_bytes "$label")"

  if (( small_encapsulated != small_packet + overhead \
    || large_encapsulated != large_packet + overhead \
    || effective != link_mtu - overhead \
    || headroom != link_mtu - large_encapsulated )); then
    verify_fail "$label contains inconsistent MTU probe arithmetic"
    return 1
  fi
}

assert_scenario_input_only() {
  local output="$1" label="$2"
  local forbidden_keys
  forbidden_keys='network_address|broadcast_address|gateway_on_link|destination_on_link|selected_table|candidate_routes|winning_prefix|route_type|route_metric|next_hop|egress_interface|route_result|neighbor_target|neighbor_state|original_tuple|translated_tuple|translation_state|forward_result|return_route|reverse_state|tcp_segment_count|largest_tcp_segment_payload_bytes|largest_emitted_ip_packet_bytes|effective_inner_ip_mtu|largest_encapsulated_packet_bytes|mtu_headroom_bytes|mtu_result|control_feedback|operation_success|result'
  if grep -Eq "^(${forbidden_keys})=" <<< "$output"; then
    verify_fail "$label leaked a derived answer or result field"
    return 1
  fi
  if grep -Eq '=(selected|rejected|reachable|unreachable|present|missing|fits|exceeds|delivered|dropped|true|false)$' <<< "$output"; then
    verify_fail "$label leaked a derived answer or result value"
    return 1
  fi
  assert_exact_line "$output" "scenario_scope=input-only" "$label"
  assert_exact_line "$output" "pmtud_feedback_status=unobserved" "$label"
  assert_exact_line "$output" "prediction_record=external-required" "$label"
}

assert_exact_line() {
  local output="$1" expected="$2" label="$3"
  if ! grep -Fqx -- "$expected" <<< "$output"; then
    verify_fail "$label did not contain: $expected"
    return 1
  fi
}

expect_failure() {
  local expected="$1"
  shift
  local output status

  set +e
  output="$("$@" 2>&1)"
  status="$?"
  set -e
  if [[ "$status" -eq 0 ]]; then
    verify_fail "expected refusal but command succeeded: $*"
    return 1
  fi
  if ! grep -Fq -- "$expected" <<< "$output"; then
    verify_fail "refusal did not contain '$expected': $output"
    return 1
  fi
}

capture_root() {
  local output="$1" line owner mode resolved
  line="$(grep -E '^lab_root=' <<< "$output" | tail -n 1 || true)"
  if [[ -z "$line" ]]; then
    verify_fail "setup did not report lab_root"
    return 1
  fi
  VERIFIER_ROOT="${line#lab_root=}"
  if [[ ! "$VERIFIER_ROOT" =~ ^/tmp/reliability-atlas-LES-0012\.[[:alnum:]]{8}$ \
    || ! -d "$VERIFIER_ROOT" || -L "$VERIFIER_ROOT" ]]; then
    verify_fail "setup returned an invalid root"
    return 1
  fi
  owner="$(stat -c '%u' -- "$VERIFIER_ROOT")"
  mode="$(stat -c '%a' -- "$VERIFIER_ROOT")"
  resolved="$(realpath -e -- "$VERIFIER_ROOT")"
  if [[ "$owner" != "$VERIFY_UID" || "$mode" != "700" \
    || "$resolved" != "$VERIFIER_ROOT" ]]; then
    verify_fail "setup root identity is invalid"
    return 1
  fi
}

cleanup_verifier_owned() {
  if [[ -n "$EXTERNAL_TARGET" && -f "$EXTERNAL_TARGET" \
    && ! -L "$EXTERNAL_TARGET" ]]; then
    rm -- "$EXTERNAL_TARGET" 2>/dev/null || true
  fi
  if [[ -n "$ORPHAN_ROOT" && -d "$ORPHAN_ROOT" \
    && ! -L "$ORPHAN_ROOT" ]]; then
    rmdir -- "$ORPHAN_ROOT" 2>/dev/null || true
  fi
  if path_present "$STATE_FILE"; then
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1 || true
  fi
}

begin_setup() {
  local output
  output="$(bash "$LAB_SCRIPT" setup)"
  assert_exact_line "$output" "setup=complete" "setup"
  capture_root "$output"
}

finish_cleanup() {
  local output
  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "state=absent" "cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "cleanup"
  if path_present "$STATE_FILE" || path_present "$VERIFIER_ROOT"; then
    verify_fail "cleanup left registered state"
    return 1
  fi
  VERIFIER_ROOT=""
}

assert_answer_isolation() {
  local path
  for path in "$README_PATH" "$RESPONSE_TEMPLATE" "$LESSON_PATH"; do
    if [[ ! -f "$path" || -L "$path" ]]; then
      verify_fail "learner-facing file is missing, non-regular, or a symlink: $path"
      return 1
    fi
  done
  if ! grep -Fq -- "contains no diagnosis or model answer" "$RESPONSE_TEMPLATE"; then
    verify_fail "response template does not declare answer isolation"
    return 1
  fi
  if grep -Eq \
    '10\.88\.4\.12|172\.31\.40\.80|203\.0\.113\.22|edge-b|control_feedback=missing|tcp-mss-clamp-1380|clamps the largest TCP payload from 1460' \
    "$README_PATH" "$RESPONSE_TEMPLATE" "$LESSON_PATH"; then
    verify_fail "learner-facing material exposes independent-case evidence"
    return 1
  fi
}

assert_static_offline_boundary() {
  if grep -Eq \
    '(^|[[:space:]])(sudo|curl|wget|ping|nc|ncat|ip|iptables|nft|unshare|nsenter|sysctl|apt|dnf|yum)[[:space:]]' \
    "$LAB_SCRIPT" "$FIXTURE_SOURCE"; then
    verify_fail "runtime files contain a forbidden network or privilege command"
    return 1
  fi
  if grep -Eq \
    '(^|[[:space:]])(import|from)[[:space:]]+(socket|subprocess|requests|urllib|http)' \
    "$FIXTURE_SOURCE"; then
    verify_fail "fixture imports a socket, process, or network client module"
    return 1
  fi
}

run_case() {
  local case_name="$1" output

  begin_setup
  output="$(bash "$LAB_SCRIPT" scenario "$case_name")"
  assert_exact_line "$output" "record=scenario" "$case_name scenario"
  assert_exact_line "$output" "case=$case_name" "$case_name scenario"
  assert_scenario_input_only "$output" "$case_name scenario"
  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "scenario=complete" "$case_name scenario status"
  assert_exact_line "$output" "scenario_case=$case_name" "$case_name scenario status"
  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "baseline=pending" "$case_name initial status"
  assert_exact_line "$output" "active_case=none" "$case_name initial status"

  output="$(bash "$LAB_SCRIPT" run baseline)"
  assert_exact_line "$output" "record=baseline" "$case_name baseline"
  assert_exact_line "$output" "operation_success=true" "$case_name baseline"

  for view in addresses routes path; do
    output="$(bash "$LAB_SCRIPT" observe "$view")"
    assert_exact_line "$output" "case=baseline" "$case_name baseline $view"
    assert_exact_line "$output" "view=$view" "$case_name baseline $view"
    if [[ "$view" == "path" ]]; then
      assert_packet_mtu_math "$output" "$case_name baseline path"
    fi
  done
  for probe_name in neighbor return mtu; do
    output="$(bash "$LAB_SCRIPT" probe "$probe_name")"
    assert_exact_line "$output" "case=baseline" "$case_name baseline $probe_name probe"
    assert_exact_line "$output" "packets_sent=0" "$case_name baseline $probe_name probe"
  done

  output="$(bash "$LAB_SCRIPT" inject "$case_name")"
  assert_exact_line "$output" "injection=complete" "$case_name injection"
  assert_exact_line "$output" "case=$case_name" "$case_name injection"

  output="$(bash "$LAB_SCRIPT" observe addresses)"
  assert_exact_line "$output" "case=$case_name" "$case_name addresses"
  output="$(bash "$LAB_SCRIPT" observe routes)"
  assert_exact_line "$output" "case=$case_name" "$case_name routes"
  output="$(bash "$LAB_SCRIPT" observe path)"
  assert_exact_line "$output" "case=$case_name" "$case_name path"
  assert_exact_line "$output" "operation_success=false" "$case_name incident operation"

  if [[ "$case_name" == "guided" ]]; then
    assert_exact_line "$output" "forward_result=route-rejected" "guided path"
    output="$(bash "$LAB_SCRIPT" observe routes)"
    assert_exact_line "$output" "route_type=blackhole" "guided route"
    assert_exact_line "$output" "route_result=rejected" "guided route"
  else
    assert_exact_line "$output" "forward_result=delivered" "independent path"
    assert_exact_line "$output" "effective_inner_ip_mtu=1420" "independent path"
    assert_exact_line "$output" "largest_emitted_ip_packet_bytes=1500" "independent path"
    assert_exact_line "$output" "largest_encapsulated_packet_bytes=1580" "independent path"
    assert_exact_line "$output" "mtu_headroom_bytes=-80" "independent path"
    assert_exact_line "$output" "mtu_result=exceeds" "independent path"
    assert_packet_mtu_math "$output" "independent incident path"
    output="$(bash "$LAB_SCRIPT" observe routes)"
    assert_exact_line "$output" "route_result=selected" "independent route"
  fi

  for probe_name in neighbor return mtu; do
    output="$(bash "$LAB_SCRIPT" probe "$probe_name")"
    assert_exact_line "$output" "case=$case_name" "$case_name $probe_name probe"
    assert_exact_line "$output" "packets_sent=0" "$case_name $probe_name probe"
    if [[ "$probe_name" == "mtu" ]]; then
      assert_probe_mtu_math "$output" "$case_name mtu probe"
    fi
  done

  output="$(bash "$LAB_SCRIPT" recover)"
  assert_exact_line "$output" "record=recovery" "$case_name recovery"
  assert_exact_line "$output" "operation_success=true" "$case_name recovery"
  assert_packet_mtu_math "$output" "$case_name recovery"
  if [[ "$case_name" == "independent" ]]; then
    assert_exact_line "$output" "segmentation_strategy=tcp-mss-clamp-1380" "independent recovery"
    assert_exact_line "$output" "application_response_bytes=3000" "independent recovery"
    assert_exact_line "$output" "largest_emitted_ip_packet_bytes=1420" "independent recovery"
    assert_exact_line "$output" "largest_encapsulated_packet_bytes=1500" "independent recovery"
    assert_exact_line "$output" "mtu_headroom_bytes=0" "independent recovery"
  fi
  output="$(bash "$LAB_SCRIPT" verify-operation)"
  assert_exact_line "$output" "record=verification" "$case_name verification"
  assert_exact_line "$output" "forward_result=delivered" "$case_name verification"
  assert_exact_line "$output" "return_result=delivered" "$case_name verification"
  assert_exact_line "$output" "operation_success=true" "$case_name verification"
  assert_exact_line \
    "$output" "verification_scope=deterministic-model-only" "$case_name verification"
  assert_packet_mtu_math "$output" "$case_name verification"

  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "recovery=complete" "$case_name final status"
  assert_exact_line "$output" "verification=complete" "$case_name final status"
  finish_cleanup

  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "state=absent" "$case_name post-cleanup check"
}

main() {
  local output sentinel_path manifest_path model_path baseline_path
  local sentinel_content manifest_content baseline_content descriptor_content
  local unexpected_path link_path hardlink_path
  local -a descriptor_lines=()

  if [[ "$VERIFY_UID" -eq 0 ]]; then
    verify_fail "run verification as a normal non-root user"
    return 1
  fi
  for tool in bash cat chmod cmp grep id install ln mktemp readlink \
    realpath rm rmdir sha256sum stat tail
  do
    if ! command -v "$tool" >/dev/null 2>&1; then
      verify_fail "required verifier command is missing: $tool"
      return 1
    fi
  done
  if [[ ! -f "$LAB_SCRIPT" || -L "$LAB_SCRIPT" ]]; then
    verify_fail "lab.sh is missing, non-regular, or a symlink"
    return 1
  fi
  if [[ ! -f "$FIXTURE_SOURCE" || -L "$FIXTURE_SOURCE" ]]; then
    verify_fail "fixture is missing, non-regular, or a symlink"
    return 1
  fi

  assert_answer_isolation
  assert_static_offline_boundary
  if path_present "$STATE_FILE"; then
    verify_fail "active learner state exists; preserve it and use supported cleanup"
    return 1
  fi
  trap cleanup_verifier_owned EXIT INT TERM

  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "environment=ready" "initial check"
  assert_exact_line "$output" "state=absent" "initial check"
  assert_exact_line "$output" "network=none" "initial check"
  assert_exact_line "$output" "host_mutation=none" "initial check"

  run_case guided
  run_case independent

  begin_setup
  expect_failure "record the baseline before observation" \
    bash "$LAB_SCRIPT" observe addresses
  expect_failure "record the baseline before a bounded probe" \
    bash "$LAB_SCRIPT" probe neighbor
  expect_failure "record a guided or independent scenario before baseline" \
    bash "$LAB_SCRIPT" run baseline
  expect_failure "scenario must be guided or independent" \
    bash "$LAB_SCRIPT" scenario ../../etc
  bash "$LAB_SCRIPT" scenario guided >/dev/null
  expect_failure "scenario input was already recorded" \
    bash "$LAB_SCRIPT" scenario independent
  expect_failure "run accepts only: baseline" bash "$LAB_SCRIPT" run ../../etc
  bash "$LAB_SCRIPT" run baseline >/dev/null
  expect_failure "baseline was already recorded" bash "$LAB_SCRIPT" run baseline
  expect_failure "case must be guided or independent" \
    bash "$LAB_SCRIPT" inject ../../etc
  expect_failure "injected case must match the recorded scenario" \
    bash "$LAB_SCRIPT" inject independent
  bash "$LAB_SCRIPT" inject guided >/dev/null
  expect_failure "an incident case is already active" \
    bash "$LAB_SCRIPT" inject independent
  expect_failure "view must be addresses, routes, or path" \
    bash "$LAB_SCRIPT" observe ../../etc
  expect_failure "probe must be neighbor, return, or mtu" \
    bash "$LAB_SCRIPT" probe ../../etc
  bash "$LAB_SCRIPT" recover >/dev/null
  expect_failure "recovery was already recorded" bash "$LAB_SCRIPT" recover
  bash "$LAB_SCRIPT" verify-operation >/dev/null
  expect_failure "operation verification was already recorded" \
    bash "$LAB_SCRIPT" verify-operation
  finish_cleanup

  begin_setup
  sentinel_path="$VERIFIER_ROOT/.les-0012-sentinel"
  sentinel_content="$(cat -- "$sentinel_path")"
  printf '\n' >> "$sentinel_path"
  expect_failure "lesson sentinel content changed" bash "$LAB_SCRIPT" status
  printf '%s' "$sentinel_content" > "$sentinel_path"
  chmod 600 -- "$sentinel_path"
  finish_cleanup

  begin_setup
  manifest_path="$VERIFIER_ROOT/artifact-manifest.tsv"
  manifest_content="$(cat -- "$manifest_path")"
  printf '\n' >> "$manifest_path"
  expect_failure "artifact manifest content changed" bash "$LAB_SCRIPT" status
  printf '%s\n' "$manifest_content" > "$manifest_path"
  chmod 600 -- "$manifest_path"
  finish_cleanup

  begin_setup
  model_path="$VERIFIER_ROOT/packet_path_model.py"
  chmod 700 -- "$model_path"
  printf '\n' >> "$model_path"
  chmod 500 -- "$model_path"
  expect_failure "fixture model hash or content changed" bash "$LAB_SCRIPT" status
  install -m 0500 -- "$FIXTURE_SOURCE" "$model_path"
  finish_cleanup

  begin_setup
  manifest_path="$VERIFIER_ROOT/artifact-manifest.tsv"
  chmod 644 -- "$manifest_path"
  expect_failure "owner, link count, or mode changed" \
    bash "$LAB_SCRIPT" status
  chmod 600 -- "$manifest_path"
  finish_cleanup

  begin_setup
  bash "$LAB_SCRIPT" scenario guided >/dev/null
  bash "$LAB_SCRIPT" run baseline >/dev/null
  baseline_path="$VERIFIER_ROOT/baseline.summary"
  baseline_content="$(cat -- "$baseline_path")"
  printf '\n' >> "$baseline_path"
  expect_failure "baseline summary content changed" bash "$LAB_SCRIPT" status
  printf '%s\n' "$baseline_content" > "$baseline_path"
  chmod 600 -- "$baseline_path"
  finish_cleanup

  begin_setup
  descriptor_content="$(cat -- "$STATE_FILE")"
  mapfile -t descriptor_lines < "$STATE_FILE"
  printf '%s\n' \
    "${descriptor_lines[0]}" "${descriptor_lines[1]}" \
    "${descriptor_lines[2]}" "lab_root=/tmp" "${descriptor_lines[4]}" \
    > "$STATE_FILE"
  chmod 600 -- "$STATE_FILE"
  expect_failure "recorded lab path is outside" bash "$LAB_SCRIPT" status
  if [[ ! -d "$VERIFIER_ROOT" || -L "$VERIFIER_ROOT" ]]; then
    verify_fail "out-of-scope descriptor refusal changed the registered root"
    return 1
  fi
  printf '%s\n' "$descriptor_content" > "$STATE_FILE"
  chmod 600 -- "$STATE_FILE"
  finish_cleanup

  begin_setup
  unexpected_path="$VERIFIER_ROOT/$UNEXPECTED_NAME"
  printf 'verifier-owned\n' > "$unexpected_path"
  chmod 600 -- "$unexpected_path"
  expect_failure "unexpected artifact blocks safe operation" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -f "$unexpected_path" || ! -d "$VERIFIER_ROOT" \
    || ! -f "$STATE_FILE" ]]; then
    verify_fail "unexpected-artifact refusal mutated guarded state"
    return 1
  fi
  rm -- "$unexpected_path"
  finish_cleanup

  begin_setup
  bash "$LAB_SCRIPT" scenario guided >/dev/null
  bash "$LAB_SCRIPT" run baseline >/dev/null
  baseline_path="$VERIFIER_ROOT/baseline.summary"
  baseline_content="$(cat -- "$baseline_path")"
  EXTERNAL_TARGET="$(mktemp --tmpdir=/tmp reliability-atlas-LES-0012-verifier-target.XXXXXXXX)"
  printf 'external-target-%s\n' "$VERIFY_UID" > "$EXTERNAL_TARGET"
  chmod 600 -- "$EXTERNAL_TARGET"
  rm -- "$baseline_path"
  ln -s -- "$EXTERNAL_TARGET" "$baseline_path"
  expect_failure "artifact baseline.summary must be a regular non-symlink file" \
    bash "$LAB_SCRIPT" cleanup
  link_path="$(readlink -- "$baseline_path")"
  if [[ "$link_path" != "$EXTERNAL_TARGET" ]] \
    || ! grep -Fqx -- "external-target-$VERIFY_UID" "$EXTERNAL_TARGET"; then
    verify_fail "symlink refusal did not preserve the external target"
    return 1
  fi
  rm -- "$baseline_path"
  printf '%s\n' "$baseline_content" > "$baseline_path"
  chmod 600 -- "$baseline_path"
  finish_cleanup
  rm -- "$EXTERNAL_TARGET"
  EXTERNAL_TARGET=""

  begin_setup
  model_path="$VERIFIER_ROOT/packet_path_model.py"
  hardlink_path="$(mktemp --tmpdir=/tmp reliability-atlas-LES-0012-verifier-hardlink.XXXXXXXX)"
  rm -- "$hardlink_path"
  ln -- "$model_path" "$hardlink_path"
  expect_failure "owner, link count, or mode changed" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -f "$hardlink_path" || -L "$hardlink_path" ]]; then
    verify_fail "hard-link refusal did not preserve the external link"
    return 1
  fi
  rm -- "$hardlink_path"
  finish_cleanup

  ORPHAN_ROOT="$(mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX")"
  chmod 700 -- "$ORPHAN_ROOT"
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" check
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" setup
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" ]] \
    || path_present "$STATE_FILE"; then
    verify_fail "orphan-candidate refusal changed guarded boundaries"
    return 1
  fi
  rmdir -- "$ORPHAN_ROOT"
  ORPHAN_ROOT=""

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=already-clean" "idempotent cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "idempotent cleanup"
  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "state=absent" "final check"

  trap - EXIT INT TERM
  printf 'verification_passed=true\n'
  printf 'cases=guided,independent\n'
  printf '%s\n' 'refusals=prebaseline-observe,prebaseline-probe,prescenario-baseline,invalid-scenario,repeat-scenario,invalid-run,repeat-baseline,invalid-case,scenario-case-mismatch,second-case,invalid-view,invalid-probe,repeat-recovery,repeat-verification,sentinel-tamper,manifest-tamper,model-hash,mode,out-of-scope-descriptor,unexpected-artifact,symlink,hard-link,orphan-candidate'
  printf 'answer_isolation=passed\n'
  printf 'network_mutation=none\n'
  printf 'cleanup_proven=true\n'
}

main "$@"
