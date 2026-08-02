#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly LAB="${SCRIPT_DIR}/lab.sh"
CURRENT_UID="$(id -u)"
readonly CURRENT_UID
readonly STATE_FILE="/tmp/reliability-atlas-les0010-${CURRENT_UID}.state"
VERIFY_ROOT=""
OUT=""
ERR=""

fail() {
  printf 'verification_failed=true reason=%s\n' "$1" >&2
  exit 1
}

expect_success() {
  local label="$1"
  shift
  "$@" >"$OUT" 2>"$ERR" || fail "${label}-unexpected-failure"
}

expect_failure() {
  local label="$1"
  shift
  if "$@" >"$OUT" 2>"$ERR"; then
    fail "${label}-unexpected-success"
  fi
  grep -q 'refused=true' "$ERR" || fail "${label}-missing-refusal"
}

registered_root() {
  sed -n 's/^root=//p' -- "$STATE_FILE"
}

safe_exact_remove() {
  local path="$1"
  [[ "$path" == /tmp/reliability-atlas-les0010-verify-* ]] || fail "unsafe-verifier-temp-path"
  [[ -f "$path" && ! -L "$path" ]] || fail "verifier-temp-not-file"
  rm -- "$path"
}

safe_remove_verifier_root() {
  [[ -n "$VERIFY_ROOT" ]] || return 0
  [[ "$VERIFY_ROOT" == "/tmp/reliability-atlas-les0010-verify-${CURRENT_UID}-"* ]] || return 1
  [[ -d "$VERIFY_ROOT" && ! -L "$VERIFY_ROOT" ]] || return 1
  [[ "$(stat -c '%u' -- "$VERIFY_ROOT")" == "$CURRENT_UID" ]] || return 1
  [[ "$(stat -c '%a' -- "$VERIFY_ROOT")" == "700" ]] || return 1
  local file
  for file in "$OUT" "$ERR"; do
    if [[ -e "$file" || -L "$file" ]]; then
      [[ -f "$file" && ! -L "$file" ]] || return 1
      [[ "$(stat -c '%u' -- "$file")" == "$CURRENT_UID" ]] || return 1
      [[ "$(stat -c '%h' -- "$file")" == "1" ]] || return 1
      rm -- "$file"
    fi
  done
  rmdir -- "$VERIFY_ROOT"
}

finish() {
  if [[ -e "$STATE_FILE" && -f "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    bash "$LAB" cleanup >/dev/null 2>&1 || true
  fi
  safe_remove_verifier_root
}

[[ "$CURRENT_UID" != "0" ]] || fail "run-as-normal-user"
VERIFY_ROOT="$(mktemp -d "/tmp/reliability-atlas-les0010-verify-${CURRENT_UID}-XXXXXX")"
chmod 700 -- "$VERIFY_ROOT"
OUT="${VERIFY_ROOT}/out"
ERR="${VERIFY_ROOT}/err"
readonly VERIFY_ROOT OUT ERR
trap finish EXIT
bash -n "$LAB" || fail "lab-syntax"
python3 "$SCRIPT_DIR/fixtures/io_model.py" --help >/dev/null || fail "model-syntax"
expect_success clean-check bash "$LAB" check
grep -q 'state=absent' "$OUT" || fail "clean-check-output"
expect_failure status-before-setup bash "$LAB" status
expect_success setup bash "$LAB" setup
expect_success idempotent-setup bash "$LAB" setup
expect_success status bash "$LAB" status
grep -q 'recovered=false operation_verified=false' "$OUT" || fail "initial-status"

expect_success baseline bash "$LAB" observe baseline
grep -q 'app_p95_ms=42 commit_p95_ms=7' "$OUT" || fail "baseline-values"
expect_success incident bash "$LAB" observe incident
grep -q 'app_p95_ms=918 commit_p95_ms=844' "$OUT" || fail "incident-values"
expect_success path bash "$LAB" observe path
grep -q 'device block-layer' "$OUT" || fail "path-view"
expect_success device bash "$LAB" probe device
grep -q 'vda 41.0 1312.0' "$OUT" || fail "device-view"
expect_success system bash "$LAB" probe system
grep -q 'Dirty_kib=262144 Writeback_kib=65536' "$OUT" || fail "system-view"
expect_success process bash "$LAB" probe process
grep -q 'ledger-api' "$OUT" || fail "process-view"
expect_success mount bash "$LAB" probe mount
grep -q '/srv/ledger' "$OUT" || fail "mount-view"
expect_failure verify-before-recovery bash "$LAB" verify-operation

root="$(registered_root)"
[[ "$root" == "/tmp/reliability-atlas-les0010-${CURRENT_UID}-"* ]] || fail "root-prefix"
printf 'unexpected\n' > "$root/unexpected.file"
chmod 600 -- "$root/unexpected.file"
expect_failure unknown-entry-cleanup bash "$LAB" cleanup
[[ -f "$root/unexpected.file" ]] || fail "unknown-entry-removed"
rm -- "$root/unexpected.file"

external="$(mktemp /tmp/reliability-atlas-les0010-verify-external-XXXXXX)"
printf 'outside\n' > "$external"
ln -s -- "$external" "$root/unexpected-link"
expect_failure symlink-cleanup bash "$LAB" cleanup
[[ -f "$external" ]] || fail "external-target-removed"
rm -- "$root/unexpected-link"
safe_exact_remove "$external"

cp -- "$STATE_FILE" "$root/descriptor.backup"
chmod 600 -- "$root/descriptor.backup"
{
  printf 'lesson_id=LES-0010\n'
  printf 'uid=%s\n' "$CURRENT_UID"
  printf 'root=/tmp\n'
  printf 'schema=1\n'
} > "$STATE_FILE"
chmod 600 -- "$STATE_FILE"
expect_failure out-of-scope-root bash "$LAB" cleanup
[[ -d /tmp ]] || fail "tmp-damaged"
mv -T -- "$root/descriptor.backup" "$STATE_FILE"

expect_success recover bash "$LAB" recover
expect_failure repeat-recovery bash "$LAB" recover
expect_success recovered-view bash "$LAB" observe recovered
grep -q 'app_p95_ms=51 commit_p95_ms=9' "$OUT" || fail "recovered-values"
expect_success verify-operation bash "$LAB" verify-operation
expect_failure repeat-verification bash "$LAB" verify-operation
expect_success final-status bash "$LAB" status
grep -q 'recovered=true operation_verified=true' "$OUT" || fail "final-status"
expect_success cleanup bash "$LAB" cleanup
grep -q 'cleanup_proven=true' "$OUT" || fail "cleanup-proof"
expect_success final-check bash "$LAB" check
grep -q 'state=absent' "$OUT" || fail "final-absence"

trap - EXIT
finish
[[ ! -e "$VERIFY_ROOT" && ! -L "$VERIFY_ROOT" ]] || fail "verifier-root-remains"
printf 'verification_passed=true\n'
printf 'profiles=baseline,incident,recovered\n'
printf 'refusals=status-before-setup,verify-before-recovery,unknown-entry,symlink,out-of-scope-root,repeat-recovery,repeat-verification\n'
printf 'external_target_preserved=true\n'
printf 'cleanup_proven=true\n'
