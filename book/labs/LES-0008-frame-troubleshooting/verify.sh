#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
readonly README_PATH="$SCRIPT_DIRECTORY/README.md"
readonly VERIFY_UID="$(id -u)"
readonly LESSON_ID="LES-0008"
readonly LAB_VERSION="1"
readonly LAB_PREFIX="devops-sre-LES-0008-frame-troubleshooting."
readonly STATE_FILE="/tmp/devops-sre-LES-0008-frame-troubleshooting-$VERIFY_UID.state"
readonly UNEXPECTED_NAME=".verify-unexpected"
readonly UNEXPECTED_CONTENT="owned-by-les-0008-verifier-$VERIFY_UID"

VERIFIER_OWNS_STATE=0
VERIFIER_ROOT=""
EXTERNAL_TARGET=""
ORPHAN_ROOT=""

verify_fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

expected_sentinel() {
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s' \
    "$LESSON_ID" "$LAB_VERSION" "$VERIFY_UID"
}

expected_external_target() {
  printf 'les-0008-external-target-%s\n' "$VERIFY_UID"
}

assert_readme_answer_isolation() {
  local pattern

  for pattern in '| `transfer` |' '650 ms' '910 ms' '10/20' \
    'not_collected' 'more dependency evidence' \
    'missing_dependency_signal' 'small_queue'
  do
    if grep -Fqi -- "$pattern" "$README_PATH"; then
      verify_fail \
        "learner README exposes a known transfer-case spoiler: $pattern"
      return 1
    fi
  done
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
  if [[ "$output" != *"$expected_fragment"* ]]; then
    verify_fail "refusal did not contain: $expected_fragment"
    return 1
  fi
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
  if [[ ! "$VERIFIER_ROOT" =~ ^/tmp/devops-sre-LES-0008-frame-troubleshooting\.[[:alnum:]]{8}$ \
    || ! -d "$VERIFIER_ROOT" || -L "$VERIFIER_ROOT" \
    || "$(stat -c '%u' -- "$VERIFIER_ROOT")" != "$VERIFY_UID" \
    || "$(stat -c '%a' -- "$VERIFIER_ROOT")" != "700" \
    || "$(realpath -e -- "$VERIFIER_ROOT")" != "$VERIFIER_ROOT" ]]; then
    verify_fail "setup returned an unsafe or invalid lab_root"
    return 1
  fi
  VERIFIER_OWNS_STATE=1
}

remove_unexpected_artifact() {
  local path="$VERIFIER_ROOT/$UNEXPECTED_NAME" actual

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return 0
  fi
  if [[ ! -f "$path" || -L "$path" \
    || "$(stat -c '%u' -- "$path")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$path")" != "1" ]]; then
    verify_fail "unexpected verifier artifact changed identity"
    return 1
  fi
  actual="$(cat -- "$path")"
  if [[ "$actual" != "$UNEXPECTED_CONTENT" ]]; then
    verify_fail "unexpected verifier artifact changed content"
    return 1
  fi
  rm -- "$path"
}

remove_external_target() {
  if [[ -z "$EXTERNAL_TARGET" \
    || ( ! -e "$EXTERNAL_TARGET" && ! -L "$EXTERNAL_TARGET" ) ]]; then
    EXTERNAL_TARGET=""
    return 0
  fi
  if [[ ! "$EXTERNAL_TARGET" =~ ^/tmp/devops-sre-LES-0008-verifier-target\.[[:alnum:]]{8}$ \
    || ! -f "$EXTERNAL_TARGET" || -L "$EXTERNAL_TARGET" \
    || "$(stat -c '%u' -- "$EXTERNAL_TARGET")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$EXTERNAL_TARGET")" != "1" ]]; then
    verify_fail "external verifier target changed identity"
    return 1
  fi
  if ! cmp -s -- "$EXTERNAL_TARGET" <(expected_external_target); then
    verify_fail "external verifier target changed content"
    return 1
  fi
  rm -- "$EXTERNAL_TARGET"
  EXTERNAL_TARGET=""
}

restore_sentinel_if_known_blank_tamper() {
  local path="$VERIFIER_ROOT/.les-0008-sentinel"

  if [[ -z "$VERIFIER_ROOT" || ( ! -e "$path" && ! -L "$path" ) ]]; then
    return 0
  fi
  if [[ ! -f "$path" || -L "$path" \
    || "$(stat -c '%u' -- "$path")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$path")" != "1" \
    || "$(stat -c '%a' -- "$path")" != "600" ]]; then
    verify_fail "sentinel blank-tamper recovery identity changed"
    return 1
  fi
  if cmp -s -- "$path" <(expected_sentinel); then
    return 0
  fi
  if ! cmp -s -- "$path" <(expected_sentinel; printf '\n'); then
    verify_fail "sentinel changed beyond the verifier blank-tamper case"
    return 1
  fi
  expected_sentinel > "$path"
  chmod 600 -- "$path"
}

restore_external_target_if_known_blank_tamper() {
  if [[ -z "$EXTERNAL_TARGET" \
    || ( ! -e "$EXTERNAL_TARGET" && ! -L "$EXTERNAL_TARGET" ) ]]; then
    return 0
  fi
  if [[ ! -f "$EXTERNAL_TARGET" || -L "$EXTERNAL_TARGET" \
    || "$(stat -c '%u' -- "$EXTERNAL_TARGET")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$EXTERNAL_TARGET")" != "1" ]]; then
    return 0
  fi
  if cmp -s -- "$EXTERNAL_TARGET" <(expected_external_target); then
    return 0
  fi
  if cmp -s -- "$EXTERNAL_TARGET" \
    <(expected_external_target; printf '\n'); then
    expected_external_target > "$EXTERNAL_TARGET"
    chmod 600 -- "$EXTERNAL_TARGET"
  fi
}

remove_orphan_candidate() {
  local owner mode resolved

  if [[ -z "$ORPHAN_ROOT" ]]; then
    return 0
  fi
  if [[ ! "$ORPHAN_ROOT" =~ ^/tmp/devops-sre-LES-0008-frame-troubleshooting\.[[:alnum:]]{8}$ \
    || ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" ]]; then
    verify_fail "orphan verifier root changed type or path"
    return 1
  fi
  owner="$(stat -c '%u' -- "$ORPHAN_ROOT")"
  mode="$(stat -c '%a' -- "$ORPHAN_ROOT")"
  resolved="$(realpath -e -- "$ORPHAN_ROOT")"
  if [[ "$owner" != "$VERIFY_UID" || "$mode" != "700" \
    || "$resolved" != "$ORPHAN_ROOT" ]]; then
    verify_fail "orphan verifier root changed identity"
    return 1
  fi
  if ! rmdir -- "$ORPHAN_ROOT"; then
    verify_fail "orphan verifier root was not empty; it was preserved"
    return 1
  fi
  ORPHAN_ROOT=""
}

best_effort_cleanup() {
  local exit_code="$?"

  trap - EXIT
  set +e
  if [[ "$VERIFIER_OWNS_STATE" -eq 1 ]]; then
    restore_sentinel_if_known_blank_tamper >/dev/null 2>&1
    remove_unexpected_artifact >/dev/null 2>&1
    if [[ -n "$VERIFIER_ROOT" \
      && -L "$VERIFIER_ROOT/baseline.summary" ]]; then
      rm -- "$VERIFIER_ROOT/baseline.summary" >/dev/null 2>&1
    fi
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1
  fi
  remove_orphan_candidate >/dev/null 2>&1
  restore_external_target_if_known_blank_tamper >/dev/null 2>&1
  remove_external_target >/dev/null 2>&1
  exit "$exit_code"
}

trap best_effort_cleanup EXIT

begin_setup() {
  local output

  output="$(TMPDIR=/path/that/must/not/be-used bash "$LAB_SCRIPT" setup)"
  if grep -Fxq -- "setup=complete" <<< "$output"; then
    VERIFIER_OWNS_STATE=1
  fi
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

assert_case_evidence() {
  local case_name="$1" output

  output="$(bash "$LAB_SCRIPT" observe symptoms)"
  assert_exact_line "$output" "record=observation" "$case_name symptoms"
  assert_exact_line "$output" "case=$case_name" "$case_name symptoms"
  assert_exact_line "$output" "view=symptoms" "$case_name symptoms"

  output="$(bash "$LAB_SCRIPT" observe timeline)"
  assert_exact_line "$output" "view=timeline" "$case_name timeline"
  output="$(bash "$LAB_SCRIPT" observe path)"
  assert_exact_line "$output" "view=path" "$case_name path"
  output="$(bash "$LAB_SCRIPT" observe changes)"
  assert_exact_line "$output" "view=changes" "$case_name changes"

  output="$(bash "$LAB_SCRIPT" probe app-only)"
  assert_exact_line "$output" "probe=app-only" "$case_name app probe"
  output="$(bash "$LAB_SCRIPT" probe dependency-only)"
  assert_exact_line "$output" "probe=dependency-only" "$case_name dependency probe"
  output="$(bash "$LAB_SCRIPT" probe queue)"
  assert_exact_line "$output" "probe=queue" "$case_name queue probe"

  case "$case_name" in
    guided)
      output="$(bash "$LAB_SCRIPT" observe path)"
      assert_exact_line "$output" "dependency_p95_ms=700" "guided path"
      assert_exact_line "$output" "dependency_calls=44" "guided path"
      ;;
    changed)
      output="$(bash "$LAB_SCRIPT" observe path)"
      assert_exact_line "$output" "dependency_p95_ms=50" "changed path"
      assert_exact_line "$output" "max_queue=12" "changed path"
      ;;
    transfer)
      output="$(bash "$LAB_SCRIPT" observe path)"
      assert_exact_line "$output" "dependency_p95_ms=not_collected" "transfer path"
      output="$(bash "$LAB_SCRIPT" probe dependency-only)"
      assert_exact_line "$output" "p95_latency_ms=650" "transfer dependency probe"
      ;;
  esac
}

run_case() {
  local case_name="$1" output baseline_output

  begin_setup
  baseline_output="$(bash "$LAB_SCRIPT" run baseline)"
  assert_exact_line "$baseline_output" "record=baseline" "$case_name baseline"
  assert_exact_line "$baseline_output" "successes=20" "$case_name baseline"
  assert_exact_line "$baseline_output" "p95_latency_ms=120" "$case_name baseline"

  output="$(bash "$LAB_SCRIPT" inject "$case_name")"
  assert_exact_line "$output" "injection=complete" "$case_name injection"
  assert_exact_line "$output" "case=$case_name" "$case_name injection"
  assert_exact_line "$output" "failure_scope=virtual-model-only" "$case_name injection"
  assert_case_evidence "$case_name"

  output="$(bash "$LAB_SCRIPT" experiment retry-off)"
  assert_exact_line "$output" "experiment=retry-off" "$case_name retry experiment"
  output="$(bash "$LAB_SCRIPT" experiment known-good-workers)"
  assert_exact_line \
    "$output" "experiment=known-good-workers" "$case_name worker experiment"
  expect_failure "retry-off experiment was already recorded" \
    bash "$LAB_SCRIPT" experiment retry-off

  output="$(bash "$LAB_SCRIPT" recover)"
  assert_exact_line "$output" "record=recovery" "$case_name recovery"
  assert_exact_line "$output" "successes=20" "$case_name recovery"
  assert_exact_line "$output" "lost_work=0" "$case_name recovery"
  output="$(bash "$LAB_SCRIPT" verify-operation)"
  assert_exact_line "$output" "record=verification" "$case_name verification"
  assert_exact_line "$output" "operation=synthetic_checkout" "$case_name verification"
  assert_exact_line "$output" "recovery_verified=true" "$case_name verification"

  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "baseline=recorded" "$case_name status"
  assert_exact_line "$output" "active_case=$case_name" "$case_name status"
  assert_exact_line \
    "$output" "experiments_completed=retry-off,known-good-workers" \
    "$case_name status"
  assert_exact_line "$output" "recovery=complete" "$case_name status"
  assert_exact_line "$output" "operation_verification=complete" "$case_name status"
  finish_cleanup
}

main() {
  local output old_root manifest_path unexpected_path baseline_path link_target
  local sentinel_path

  if [[ "$VERIFY_UID" -eq 0 ]]; then
    verify_fail "run verification as a normal non-root user"
    return 1
  fi
  for tool in bash cat chmod cmp grep id ln mktemp readlink realpath rm rmdir stat; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      verify_fail "required verifier command is missing: $tool"
      return 1
    fi
  done
  if [[ ! -f "$LAB_SCRIPT" || -L "$LAB_SCRIPT" ]]; then
    verify_fail "lab.sh is missing, not regular, or a symlink"
    return 1
  fi
  if [[ ! -f "$README_PATH" || -L "$README_PATH" ]]; then
    verify_fail "README.md is missing, not regular, or a symlink"
    return 1
  fi
  assert_readme_answer_isolation
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "active learner state exists; finish or preserve the learner attempt, then use supported bash lab.sh cleanup; if guarded cleanup refuses, stop and retain the diagnostic"
    return 1
  fi

  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "environment=ready" "initial check"
  assert_exact_line "$output" "state=absent" "initial check"

  run_case guided
  run_case changed
  run_case transfer

  begin_setup
  bash "$LAB_SCRIPT" run baseline >/dev/null
  expect_failure "baseline was already recorded" \
    bash "$LAB_SCRIPT" run baseline
  bash "$LAB_SCRIPT" inject guided >/dev/null
  expect_failure "an incident case is already active" \
    bash "$LAB_SCRIPT" inject changed
  expect_failure "view must be" bash "$LAB_SCRIPT" observe ../../etc
  finish_cleanup

  begin_setup
  sentinel_path="$VERIFIER_ROOT/.les-0008-sentinel"
  printf '\n' >> "$sentinel_path"
  expect_failure "lesson sentinel content changed" bash "$LAB_SCRIPT" status
  restore_sentinel_if_known_blank_tamper
  finish_cleanup

  begin_setup
  manifest_path="$VERIFIER_ROOT/artifact-manifest.tsv"
  printf '\n' >> "$manifest_path"
  expect_failure "artifact manifest content changed" bash "$LAB_SCRIPT" status
  old_root="$VERIFIER_ROOT"
  output="$(bash "$LAB_SCRIPT" reset)"
  capture_root "$output"
  assert_exact_line \
    "$output" "reset=complete" "manifest blank-tamper recovery reset"
  if [[ -e "$old_root" || -L "$old_root" ]]; then
    verify_fail "manifest blank-tamper recovery left its old root behind"
    return 1
  fi
  finish_cleanup

  begin_setup
  bash "$LAB_SCRIPT" run baseline >/dev/null
  baseline_path="$VERIFIER_ROOT/baseline.summary"
  printf '\n' >> "$baseline_path"
  expect_failure "baseline summary content changed" bash "$LAB_SCRIPT" status
  old_root="$VERIFIER_ROOT"
  output="$(bash "$LAB_SCRIPT" reset)"
  capture_root "$output"
  assert_exact_line \
    "$output" "reset=complete" "summary blank-tamper recovery reset"
  if [[ -e "$old_root" || -L "$old_root" ]]; then
    verify_fail "summary blank-tamper recovery left its old root behind"
    return 1
  fi
  finish_cleanup

  begin_setup
  unexpected_path="$VERIFIER_ROOT/$UNEXPECTED_NAME"
  set -o noclobber
  printf '%s\n' "$UNEXPECTED_CONTENT" > "$unexpected_path"
  set +o noclobber
  chmod 600 -- "$unexpected_path"
  expect_failure "unexpected artifact blocks safe operation" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -e "$STATE_FILE" || ! -d "$VERIFIER_ROOT" \
    || ! -f "$unexpected_path" ]]; then
    verify_fail "refused cleanup mutated unexpected-artifact state"
    return 1
  fi
  remove_unexpected_artifact
  finish_cleanup

  begin_setup
  bash "$LAB_SCRIPT" run baseline >/dev/null
  EXTERNAL_TARGET="$(
    mktemp --tmpdir=/tmp devops-sre-LES-0008-verifier-target.XXXXXXXX
  )"
  printf 'les-0008-external-target-%s\n' "$VERIFY_UID" > "$EXTERNAL_TARGET"
  chmod 600 -- "$EXTERNAL_TARGET"
  baseline_path="$VERIFIER_ROOT/baseline.summary"
  rm -- "$baseline_path"
  ln -s -- "$EXTERNAL_TARGET" "$baseline_path"
  expect_failure "baseline.summary must be a regular non-symlink file" \
    bash "$LAB_SCRIPT" cleanup
  link_target="$(readlink -- "$baseline_path")"
  if [[ "$link_target" != "$EXTERNAL_TARGET" \
    ]] || ! cmp -s -- "$EXTERNAL_TARGET" <(expected_external_target); then
    verify_fail "symlink refusal did not preserve the external target"
    return 1
  fi
  rm -- "$baseline_path"
  finish_cleanup
  printf '\n' >> "$EXTERNAL_TARGET"
  expect_failure \
    "external verifier target changed content" remove_external_target
  if [[ ! -f "$EXTERNAL_TARGET" || -L "$EXTERNAL_TARGET" ]]; then
    verify_fail "external-target blank-tamper refusal removed the target"
    return 1
  fi
  expected_external_target > "$EXTERNAL_TARGET"
  chmod 600 -- "$EXTERNAL_TARGET"
  remove_external_target

  ORPHAN_ROOT="$(
    mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX"
  )"
  chmod 700 -- "$ORPHAN_ROOT"
  expect_failure \
    "unregistered lesson root candidate exists" bash "$LAB_SCRIPT" check
  expect_failure \
    "unregistered lesson root candidate exists" bash "$LAB_SCRIPT" setup
  expect_failure \
    "unregistered lesson root candidate exists" bash "$LAB_SCRIPT" cleanup
  if [[ ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" \
    || -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "orphan-candidate refusal did not preserve clean boundaries"
    return 1
  fi
  remove_orphan_candidate

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=already-clean" "idempotent cleanup"
  assert_exact_line \
    "$output" \
    "cleanup_proof_scope=descriptor-and-owned-candidates-at-check" \
    "idempotent cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "idempotent cleanup"

  printf 'verification_passed=true\n'
  printf 'cases=guided,changed,transfer\n'
  printf '%s\n' 'refusals=repeat-baseline,second-case,repeat-experiment,invalid-input,sentinel-trailing-blank,manifest-trailing-blank,summary-trailing-blank,unexpected-artifact,symlink,external-target-trailing-blank,orphan-candidate'
  printf 'answer_isolation=passed\n'
  printf 'cleanup_proven=true\n'
}

main "$@"
