#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

SCRIPT_DIRECTORY="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="$SCRIPT_DIRECTORY/lab.sh"
readonly README_PATH="$SCRIPT_DIRECTORY/README.md"
VERIFY_UID="$(id -u)"
readonly VERIFY_UID
readonly STATE_FILE="/tmp/devops-sre-LES-0009-safe-local-workbench-$VERIFY_UID.state"
readonly LAB_PREFIX="devops-sre-LES-0009-safe-local-workbench."

VERIFIER_ROOT=""
EXTERNAL_TARGET=""
ORPHAN_ROOT=""
DESCRIPTOR_TAMPERED=0

verify_fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

expected_external() {
  printf 'les-0009-external-target-%s\n' "$VERIFY_UID"
}

expected_descriptor() {
  printf 'state_version=1\nlesson_id=LES-0009\nowner_uid=%s\nlab_root=%s\n' \
    "$VERIFY_UID" "$VERIFIER_ROOT"
}

assert_exact_line() {
  local output="$1" expected="$2" label="$3"

  if ! grep -Fxq -- "$expected" <<< "$output"; then
    verify_fail "$label did not contain exact line: $expected"
    return 1
  fi
}

expect_failure() {
  local expected="$1"
  shift
  local output

  if output="$("$@" 2>&1)"; then
    verify_fail "command unexpectedly succeeded: $*"
    return 1
  fi
  if [[ "$output" != *"$expected"* ]]; then
    verify_fail "refusal did not contain: $expected"
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
  if [[ ! "$VERIFIER_ROOT" =~ ^/tmp/devops-sre-LES-0009-safe-local-workbench[.][[:alnum:]]{8}$ \
    || ! -d "$VERIFIER_ROOT" || -L "$VERIFIER_ROOT" \
    || "$(stat -c '%u' -- "$VERIFIER_ROOT")" != "$VERIFY_UID" \
    || "$(stat -c '%a' -- "$VERIFIER_ROOT")" != "700" \
    || "$(realpath -e -- "$VERIFIER_ROOT")" != "$VERIFIER_ROOT" ]]; then
    verify_fail "setup returned an unsafe lab_root"
    return 1
  fi
}

assert_readme_answer_isolation() {
  local pattern

  for pattern in 'handoff.md' 'transfer.cache' 'transfer-index' \
    'timeout_seconds=45' 'retries=4' 'retries=1'
  do
    if grep -Fqi -- "$pattern" "$README_PATH"; then
      verify_fail "learner README exposes a transfer-case spoiler: $pattern"
      return 1
    fi
  done
}

begin_setup() {
  local output

  output="$(TMPDIR=/path/that/must/not-be-used bash "$LAB_SCRIPT" setup)"
  assert_exact_line "$output" "setup=complete" "setup"
  assert_exact_line "$output" "state=ready" "setup"
  capture_root "$output"
}

finish_cleanup() {
  local prior="$VERIFIER_ROOT" output

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=complete" "cleanup"
  assert_exact_line "$output" "state=absent" "cleanup"
  assert_exact_line "$output" \
    "cleanup_proof_scope=descriptor-and-owned-candidates-at-check" "cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "cleanup"
  if [[ -e "$prior" || -L "$prior" \
    || -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "cleanup left its root or descriptor behind"
    return 1
  fi
  VERIFIER_ROOT=""
}

remove_known_unexpected() {
  local path="$VERIFIER_ROOT/unexpected.verify" content

  if [[ -z "$VERIFIER_ROOT" || ( ! -e "$path" && ! -L "$path" ) ]]; then
    return 0
  fi
  if [[ ! -f "$path" || -L "$path" \
    || "$(stat -c '%u' -- "$path")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$path")" != "1" ]]; then
    verify_fail "unexpected verifier artifact changed identity"
    return 1
  fi
  content="$(cat -- "$path")"
  if [[ "$content" != "owned-by-les-0009-verifier-$VERIFY_UID" ]]; then
    verify_fail "unexpected verifier artifact changed content"
    return 1
  fi
  rm -- "$path"
}

remove_known_symlink() {
  local path="$VERIFIER_ROOT/workbench/external-link" target

  if [[ -z "$VERIFIER_ROOT" || ! -L "$path" ]]; then
    return 0
  fi
  target="$(readlink -- "$path")"
  if [[ "$target" != "$EXTERNAL_TARGET" ]]; then
    verify_fail "verifier symlink target changed"
    return 1
  fi
  rm -- "$path"
}

remove_external() {
  if [[ -z "$EXTERNAL_TARGET" \
    || ( ! -e "$EXTERNAL_TARGET" && ! -L "$EXTERNAL_TARGET" ) ]]; then
    EXTERNAL_TARGET=""
    return 0
  fi
  if [[ ! "$EXTERNAL_TARGET" =~ ^/tmp/devops-sre-LES-0009-verifier-target[.][[:alnum:]]{8}$ \
    || ! -f "$EXTERNAL_TARGET" || -L "$EXTERNAL_TARGET" \
    || "$(stat -c '%u' -- "$EXTERNAL_TARGET")" != "$VERIFY_UID" \
    || "$(stat -c '%h' -- "$EXTERNAL_TARGET")" != "1" ]]; then
    verify_fail "external verifier target changed identity or content"
    return 1
  fi
  if ! cmp -s -- "$EXTERNAL_TARGET" <(expected_external); then
    verify_fail "external verifier target changed identity or content"
    return 1
  fi
  rm -- "$EXTERNAL_TARGET"
  EXTERNAL_TARGET=""
}

remove_orphan() {
  if [[ -z "$ORPHAN_ROOT" ]]; then
    return 0
  fi
  if [[ ! "$ORPHAN_ROOT" =~ ^/tmp/devops-sre-LES-0009-safe-local-workbench[.][[:alnum:]]{8}$ \
    || ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" \
    || "$(stat -c '%u' -- "$ORPHAN_ROOT")" != "$VERIFY_UID" \
    || "$(stat -c '%a' -- "$ORPHAN_ROOT")" != "700" \
    || "$(realpath -e -- "$ORPHAN_ROOT")" != "$ORPHAN_ROOT" ]]; then
    verify_fail "orphan verifier root changed identity"
    return 1
  fi
  if ! rmdir -- "$ORPHAN_ROOT"; then
    verify_fail "orphan verifier root was not empty; preserved"
    return 1
  fi
  ORPHAN_ROOT=""
}

best_effort_cleanup() {
  local exit_code="$?"

  trap - EXIT
  set +e
  if [[ "$DESCRIPTOR_TAMPERED" -eq 1 && -n "$VERIFIER_ROOT" \
    && -d "$VERIFIER_ROOT" && ! -L "$VERIFIER_ROOT" ]]; then
    expected_descriptor > "$STATE_FILE"
    chmod 600 -- "$STATE_FILE"
    DESCRIPTOR_TAMPERED=0
  fi
  remove_known_unexpected >/dev/null 2>&1
  remove_known_symlink >/dev/null 2>&1
  if [[ -e "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1
  fi
  remove_external >/dev/null 2>&1
  remove_orphan >/dev/null 2>&1
  exit "$exit_code"
}

trap best_effort_cleanup EXIT

run_case() {
  local selected="$1" output

  begin_setup
  output="$(bash "$LAB_SCRIPT" run baseline)"
  assert_exact_line "$output" "record=baseline" "$selected baseline"
  assert_exact_line "$output" "branch=main" "$selected baseline"
  assert_exact_line "$output" "worktree_clean=true" "$selected baseline"
  assert_exact_line "$output" "remote_count=0" "$selected baseline"

  output="$(bash "$LAB_SCRIPT" inject "$selected")"
  assert_exact_line "$output" "injection=complete" "$selected injection"
  assert_exact_line "$output" "case=$selected" "$selected injection"
  assert_exact_line "$output" \
    "scope=local-disposable-repository-only" "$selected injection"

  for view in status worktree staged ignored history; do
    output="$(bash "$LAB_SCRIPT" observe "$view")"
    assert_exact_line "$output" "record=observation" "$selected $view"
    assert_exact_line "$output" "case=$selected" "$selected $view"
    assert_exact_line "$output" "view=$view" "$selected $view"
  done
  if [[ "$selected" == "guided" ]]; then
    output="$(bash "$LAB_SCRIPT" observe status)"
    assert_exact_line "$output" "MM service.conf" "guided mixed status"
    assert_exact_line "$output" "?? notes.txt" "guided untracked status"
    assert_exact_line "$output" "!! .env.local" "guided ignored status"
  fi

  output="$(bash "$LAB_SCRIPT" recover)"
  assert_exact_line "$output" "record=recovery" "$selected recovery"
  assert_exact_line "$output" "method=selective-restore" "$selected recovery"
  assert_exact_line "$output" "head_unchanged=true" "$selected recovery"
  assert_exact_line "$output" "worktree_clean=true" "$selected recovery"

  output="$(bash "$LAB_SCRIPT" verify-operation)"
  assert_exact_line "$output" "record=verification" "$selected verification"
  assert_exact_line "$output" \
    "operation=local_snapshot_integrity" "$selected verification"
  assert_exact_line "$output" "tracked_baseline_match=true" "$selected verification"
  assert_exact_line "$output" "worktree_clean=true" "$selected verification"
  assert_exact_line "$output" "remote_count=0" "$selected verification"
  assert_exact_line "$output" \
    "temporary_fixture_state_absent=true" "$selected verification"
  assert_exact_line "$output" "recovery_verified=true" "$selected verification"

  output="$(bash "$LAB_SCRIPT" status)"
  assert_exact_line "$output" "baseline=recorded" "$selected final status"
  assert_exact_line "$output" "active_case=$selected" "$selected final status"
  assert_exact_line "$output" "recovery=complete" "$selected final status"
  assert_exact_line "$output" \
    "operation_verification=complete" "$selected final status"
  finish_cleanup
}

main() {
  local output unexpected link_path original_root

  if [[ "$VERIFY_UID" -eq 0 ]]; then
    verify_fail "run verification as a normal non-root user"
    return 1
  fi
  for tool in bash cat chmod cmp grep id ln mktemp readlink realpath rm \
    rmdir stat; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      verify_fail "required verifier command is missing: $tool"
      return 1
    fi
  done
  if [[ ! -f "$LAB_SCRIPT" || -L "$LAB_SCRIPT" \
    || ! -f "$README_PATH" || -L "$README_PATH" ]]; then
    verify_fail "lab.sh and README.md must be regular non-symlink files"
    return 1
  fi
  assert_readme_answer_isolation
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "active learner state exists; preserve or finish it first"
    return 1
  fi

  output="$(bash "$LAB_SCRIPT" check)"
  assert_exact_line "$output" "environment=ready" "initial check"
  assert_exact_line "$output" "state=absent" "initial check"

  run_case guided
  run_case transfer

  begin_setup
  bash "$LAB_SCRIPT" run baseline >/dev/null
  expect_failure "baseline was already recorded" \
    bash "$LAB_SCRIPT" run baseline
  bash "$LAB_SCRIPT" inject guided >/dev/null
  expect_failure "a case is already active" \
    bash "$LAB_SCRIPT" inject transfer
  expect_failure "view must be" \
    bash "$LAB_SCRIPT" observe ../../etc
  bash "$LAB_SCRIPT" recover >/dev/null
  expect_failure "recovery was already recorded" \
    bash "$LAB_SCRIPT" recover
  bash "$LAB_SCRIPT" verify-operation >/dev/null
  expect_failure "operation verification was already recorded" \
    bash "$LAB_SCRIPT" verify-operation
  finish_cleanup

  begin_setup
  unexpected="$VERIFIER_ROOT/unexpected.verify"
  printf 'owned-by-les-0009-verifier-%s\n' "$VERIFY_UID" > "$unexpected"
  chmod 600 -- "$unexpected"
  expect_failure "unexpected top-level artifact blocks safe operation" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -f "$unexpected" || ! -d "$VERIFIER_ROOT" \
    || ! -f "$STATE_FILE" ]]; then
    verify_fail "unexpected-artifact refusal did not preserve state"
    return 1
  fi
  remove_known_unexpected
  finish_cleanup

  begin_setup
  EXTERNAL_TARGET="$(mktemp --tmpdir=/tmp \
    devops-sre-LES-0009-verifier-target.XXXXXXXX)"
  expected_external > "$EXTERNAL_TARGET"
  chmod 600 -- "$EXTERNAL_TARGET"
  link_path="$VERIFIER_ROOT/workbench/external-link"
  ln -s -- "$EXTERNAL_TARGET" "$link_path"
  expect_failure "symbolic links are forbidden inside the lab root" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -L "$link_path" \
    || "$(readlink -- "$link_path")" != "$EXTERNAL_TARGET" ]]; then
    verify_fail "symlink refusal failed to preserve external target"
    return 1
  fi
  if ! cmp -s -- "$EXTERNAL_TARGET" <(expected_external); then
    verify_fail "symlink refusal changed the external target"
    return 1
  fi
  remove_known_symlink
  finish_cleanup
  remove_external

  begin_setup
  original_root="$VERIFIER_ROOT"
  printf 'state_version=1\nlesson_id=LES-0009\nowner_uid=%s\nlab_root=/tmp\n' \
    "$VERIFY_UID" > "$STATE_FILE"
  chmod 600 -- "$STATE_FILE"
  DESCRIPTOR_TAMPERED=1
  expect_failure "recorded lab root is outside the exact lesson prefix" \
    bash "$LAB_SCRIPT" status
  if [[ ! -d "$original_root" || -L "$original_root" ]]; then
    verify_fail "out-of-scope refusal changed the original root"
    return 1
  fi
  expected_descriptor > "$STATE_FILE"
  chmod 600 -- "$STATE_FILE"
  DESCRIPTOR_TAMPERED=0
  finish_cleanup

  ORPHAN_ROOT="$(mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX")"
  chmod 700 -- "$ORPHAN_ROOT"
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" check
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" setup
  expect_failure "unregistered lesson root candidate exists" \
    bash "$LAB_SCRIPT" cleanup
  if [[ ! -d "$ORPHAN_ROOT" || -L "$ORPHAN_ROOT" \
    || -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    verify_fail "orphan refusal crossed its boundary"
    return 1
  fi
  remove_orphan

  output="$(bash "$LAB_SCRIPT" cleanup)"
  assert_exact_line "$output" "cleanup=already-clean" "idempotent cleanup"
  assert_exact_line "$output" \
    "cleanup_proof_scope=descriptor-and-owned-candidates-at-check" \
    "idempotent cleanup"
  assert_exact_line "$output" "cleanup_proven=true" "idempotent cleanup"

  printf 'verification_passed=true\n'
  printf 'cases=guided,transfer\n'
  printf '%s\n' \
    'refusals=repeat-baseline,second-case,invalid-view,repeat-recovery,repeat-verification,unexpected-top-level,symlink,out-of-scope-descriptor,orphan-candidate'
  printf 'answer_isolation=passed\n'
  printf 'external_target_preserved=true\n'
  printf 'cleanup_proven=true\n'
}

main "$@"
