#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
readonly VERIFY_UID="$(id -u)"
readonly STATE_FILE="/tmp/devops-sre-LES-0007-systems-thinking-$VERIFY_UID.state"
readonly UNEXPECTED_NAME=".verify-unexpected"
readonly UNEXPECTED_CONTENT="owned-by-les-0007-verifier-$VERIFY_UID"
readonly OUTPUT_KEYS="profile jobs completed workers arrival_ms service_ms elapsed_ms throughput_per_s max_queue mean_wait_ms p95_wait_ms queue_capacity offered_rate_per_s nominal_capacity_per_s backpressure_jobs producer_blocked_ms max_admission_delay_ms mean_completion_latency_ms p95_completion_latency_ms"

VERIFIER_OWNS_STATE=0
VERIFIER_ROOT=""

verify_fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

assert_contains() {
  local output="$1" expected="$2" label="$3"

  if [[ "$output" != *"$expected"* ]]; then
    verify_fail "$label did not contain: $expected"
    return 1
  fi
}

assert_exact_line() {
  local output="$1" expected="$2" label="$3"

  if ! grep -Fxq -- "$expected" <<< "$output"; then
    verify_fail "$label did not contain exact line: $expected"
    return 1
  fi
}

expect_failure() {
  local expected_fragment="$1"
  shift
  local output

  if output="$("$@" 2>&1)"; then
    verify_fail "command unexpectedly succeeded: $*"
    return 1
  fi
  assert_contains "$output" "$expected_fragment" "expected refusal"
}

capture_root() {
  local output="$1"
  local -a matches=()

  mapfile -t matches < <(grep '^lab_root=' <<< "$output")
  if [[ "${#matches[@]}" -ne 1 ]]; then
    verify_fail "setup did not return exactly one lab_root"
    return 1
  fi
  VERIFIER_ROOT="${matches[0]#lab_root=}"
  if [[ ! "$VERIFIER_ROOT" =~ ^/tmp/devops-sre-LES-0007-systems-thinking\.[[:alnum:]]{8}$ \
    || ! -d "$VERIFIER_ROOT" \
    || -L "$VERIFIER_ROOT" \
    || "$(stat -c '%u' -- "$VERIFIER_ROOT")" != "$VERIFY_UID" \
    || "$(stat -c '%a' -- "$VERIFIER_ROOT")" != "700" \
    || "$(realpath -e -- "$VERIFIER_ROOT")" != "$VERIFIER_ROOT" ]]; then
    verify_fail "setup returned an unsafe or invalid lab_root"
    return 1
  fi
  VERIFIER_OWNS_STATE=1
}

expected_profile_output() {
  case "$1" in
    stable)
      cat <<'EOF_STABLE'
profile=stable
jobs=12
completed=12
workers=1
arrival_ms=400
service_ms=300
elapsed_ms=4700
throughput_per_s=2.553
max_queue=0
mean_wait_ms=0.000
p95_wait_ms=0
queue_capacity=3
offered_rate_per_s=2.500
nominal_capacity_per_s=3.333
backpressure_jobs=0
producer_blocked_ms=0
max_admission_delay_ms=0
mean_completion_latency_ms=300.000
p95_completion_latency_ms=300
EOF_STABLE
      ;;
    saturated)
      cat <<'EOF_SATURATED'
profile=saturated
jobs=12
completed=12
workers=1
arrival_ms=100
service_ms=300
elapsed_ms=3600
throughput_per_s=3.333
max_queue=3
mean_wait_ms=691.667
p95_wait_ms=900
queue_capacity=3
offered_rate_per_s=10.000
nominal_capacity_per_s=3.333
backpressure_jobs=7
producer_blocked_ms=1900
max_admission_delay_ms=1300
mean_completion_latency_ms=1400.000
p95_completion_latency_ms=2500
EOF_SATURATED
      ;;
    recovered)
      cat <<'EOF_RECOVERED'
profile=recovered
jobs=12
completed=12
workers=3
arrival_ms=100
service_ms=300
elapsed_ms=1400
throughput_per_s=8.571
max_queue=0
mean_wait_ms=0.000
p95_wait_ms=0
queue_capacity=3
offered_rate_per_s=10.000
nominal_capacity_per_s=10.000
backpressure_jobs=0
producer_blocked_ms=0
max_admission_delay_ms=0
mean_completion_latency_ms=300.000
p95_completion_latency_ms=300
EOF_RECOVERED
      ;;
    *)
      verify_fail "unknown expected profile: $1"
      return 1
      ;;
  esac
}

assert_profile_contract() {
  local output="$1" profile="$2" expected
  local -a expected_keys=() output_lines=()
  local index key value line jobs="" completed="" max_queue="" queue_capacity=""

  expected="$(expected_profile_output "$profile")"
  if [[ "$output" != "$expected" ]]; then
    verify_fail "$profile output changed from the deterministic contract"
    return 1
  fi

  read -r -a expected_keys <<< "$OUTPUT_KEYS"
  mapfile -t output_lines <<< "$output"
  if [[ "${#output_lines[@]}" -ne "${#expected_keys[@]}" ]]; then
    verify_fail "$profile output field count changed"
    return 1
  fi

  for index in "${!expected_keys[@]}"; do
    line="${output_lines[$index]}"
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "$key" != "${expected_keys[$index]}" ]]; then
      verify_fail "$profile output key order changed at $key"
      return 1
    fi
    case "$key" in
      jobs)
        jobs="$value"
        ;;
      completed)
        completed="$value"
        ;;
      max_queue)
        max_queue="$value"
        ;;
      queue_capacity)
        queue_capacity="$value"
        ;;
    esac
  done

  if [[ "$completed" != "$jobs" ]]; then
    verify_fail "$profile lost work: completed does not equal jobs"
    return 1
  fi
  if (( max_queue > queue_capacity )); then
    verify_fail "$profile exceeded its bounded queue capacity"
    return 1
  fi
}

remove_verifier_artifact() {
  local path="$VERIFIER_ROOT/$UNEXPECTED_NAME"
  local actual owner links

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return 0
  fi
  if [[ ! "$VERIFIER_ROOT" =~ ^/tmp/devops-sre-LES-0007-systems-thinking\.[[:alnum:]]{8}$ \
    || ! -d "$VERIFIER_ROOT" \
    || -L "$VERIFIER_ROOT" \
    || "$(stat -c '%u' -- "$VERIFIER_ROOT")" != "$VERIFY_UID" \
    || "$(stat -c '%a' -- "$VERIFIER_ROOT")" != "700" \
    || "$(realpath -e -- "$VERIFIER_ROOT")" != "$VERIFIER_ROOT" ]]; then
    verify_fail "refusing to remove verifier artifact from an unsafe root"
    return 1
  fi
  if [[ ! -f "$path" || -L "$path" ]]; then
    verify_fail "verifier artifact changed type"
    return 1
  fi
  owner="$(stat -c '%u' -- "$path")"
  links="$(stat -c '%h' -- "$path")"
  actual="$(cat -- "$path")"
  if [[ "$owner" != "$VERIFY_UID" \
    || "$links" != "1" \
    || "$actual" != "$UNEXPECTED_CONTENT" ]]; then
    verify_fail "verifier artifact identity or content changed"
    return 1
  fi
  rm -- "$path"
}

best_effort_cleanup() {
  local exit_code="$?"

  trap - EXIT
  set +e
  if [[ "$VERIFIER_OWNS_STATE" -eq 1 ]]; then
    remove_verifier_artifact >/dev/null 2>&1
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1
  fi
  exit "$exit_code"
}

trap best_effort_cleanup EXIT

begin_setup() {
  local output

  output="$(bash "$LAB_SCRIPT" setup)"
  assert_exact_line "$output" "setup=complete" "setup"
  assert_exact_line "$output" "state=ready" "setup"
  capture_root "$output"
}

finish_cleanup() {
  local root_before="$VERIFIER_ROOT" output

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=complete" "cleanup"
  assert_exact_line "$output" "state=absent" "cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "cleanup"
  if [[ -e "$root_before" || -L "$root_before" \
    || -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "cleanup left the lab root or state descriptor behind"
    return 1
  fi
  VERIFIER_OWNS_STATE=0
  VERIFIER_ROOT=""
}

require_owned_regular_file() {
  local path="$1" label="$2"

  if [[ ! -f "$path" || -L "$path" \
    || "$(stat -c '%u' -- "$path")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$path")" != "1" ]]; then
    verify_fail "$label is not a verifier-owned regular single-link file"
    return 1
  fi
}

main() {
  local output stable_output saturated_output recovered_output
  local old_root manifest_path unexpected_path

  if [[ "$VERIFY_UID" -eq 0 ]]; then
    verify_fail "run verification as a normal non-root user"
    return 1
  fi
  if [[ ! -f "$LAB_SCRIPT" || -L "$LAB_SCRIPT" ]]; then
    verify_fail "lab.sh is missing, not regular, or a symlink"
    return 1
  fi
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "active learner state exists; clean it manually before verification"
    return 1
  fi

  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "environment=ready" "initial check"
  assert_exact_line "$output" "state=absent" "initial check"

  begin_setup
  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "lesson_id=LES-0007" "initial status"
  assert_exact_line "$output" "state=ready" "initial status"
  assert_exact_line "$output" "lab_root=$VERIFIER_ROOT" "initial status"
  assert_exact_line "$output" "profiles_completed=none" "initial status"
  assert_exact_line "$output" "execution=virtual-time-bounded" "initial status"
  assert_exact_line "$output" "queue_capacity=3" "initial status"
  assert_exact_line \
    "$output" "profiles_available=stable,saturated,recovered" "initial status"

  stable_output="$(bash "$LAB_SCRIPT" run stable)"
  saturated_output="$(bash "$LAB_SCRIPT" run saturated)"
  recovered_output="$(bash "$LAB_SCRIPT" run recovered)"
  assert_profile_contract "$stable_output" stable
  assert_profile_contract "$saturated_output" saturated
  assert_profile_contract "$recovered_output" recovered

  expect_failure "stable was already recorded" \
    bash "$LAB_SCRIPT" run stable
  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line \
    "$output" "profiles_completed=stable,saturated,recovered" "completed status"
  finish_cleanup

  begin_setup
  old_root="$VERIFIER_ROOT"
  stable_output="$(bash "$LAB_SCRIPT" run stable)"
  assert_profile_contract "$stable_output" stable
  output="$(bash "$LAB_SCRIPT" reset)"
  capture_root "$output"
  assert_exact_line "$output" "cleanup_proven=true" "reset cleanup"
  assert_exact_line "$output" "setup=complete" "reset setup"
  assert_exact_line "$output" "reset=complete" "reset"
  if [[ -e "$old_root" || -L "$old_root" ]]; then
    verify_fail "reset left its old lab root behind"
    return 1
  fi
  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "profiles_completed=none" "reset status"
  finish_cleanup

  begin_setup
  manifest_path="$VERIFIER_ROOT/artifact-manifest.tsv"
  require_owned_regular_file "$manifest_path" "artifact manifest"
  printf 'verifier-tamper\n' > "$manifest_path"
  expect_failure "artifact manifest content changed" \
    bash "$LAB_SCRIPT" run stable
  old_root="$VERIFIER_ROOT"
  output="$(bash "$LAB_SCRIPT" reset)"
  capture_root "$output"
  assert_exact_line "$output" "reset=complete" "tamper recovery reset"
  if [[ -e "$old_root" || -L "$old_root" ]]; then
    verify_fail "tamper recovery left its old lab root behind"
    return 1
  fi
  stable_output="$(bash "$LAB_SCRIPT" run stable)"
  assert_profile_contract "$stable_output" stable
  finish_cleanup

  begin_setup
  unexpected_path="$VERIFIER_ROOT/$UNEXPECTED_NAME"
  set -o noclobber
  printf '%s\n' "$UNEXPECTED_CONTENT" > "$unexpected_path"
  set +o noclobber
  chmod 600 -- "$unexpected_path"
  expect_failure "unexpected artifact blocks safe operation" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -e "$STATE_FILE" \
    || ! -d "$VERIFIER_ROOT" \
    || ! -f "$unexpected_path" ]]; then
    verify_fail "refused cleanup mutated protected state"
    return 1
  fi
  remove_verifier_artifact
  finish_cleanup

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=already-clean" "idempotent cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "idempotent cleanup"

  printf 'verification_passed=true\n'
  printf 'profiles=stable,saturated,recovered\n'
  printf 'refusals=repeat-run,manifest-tamper,unexpected-artifact\n'
  printf 'cleanup_proven=true\n'
}

main "$@"
