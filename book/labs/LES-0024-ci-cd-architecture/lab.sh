#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly LESSON_ID='LES-0024'
readonly STATE_VERSION='2'
readonly STATE_PARENT='/tmp'
readonly NETWORK_POLICY='none'

SCRIPT_SOURCE=${BASH_SOURCE[0]}
if [[ $SCRIPT_SOURCE == *'/'* ]]; then
  SCRIPT_PARENT=${SCRIPT_SOURCE%/*}
else
  SCRIPT_PARENT='.'
fi
SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)
readonly SCRIPT_SOURCE SCRIPT_PARENT SCRIPT_DIRECTORY
readonly MODEL_SOURCE="${SCRIPT_DIRECTORY}/fixtures/pipeline_model.py"
LAB_UID=$EUID
readonly LAB_UID
readonly ROOT_PREFIX="reliability-atlas-LES-0024-u${LAB_UID}."
readonly STATE_FILE="${STATE_PARENT}/reliability-atlas-LES-0024-${LAB_UID}.state"

LAB_ROOT=''
STATE_PHASE=''
PENDING_ROOT=''
PENDING_DESCRIPTOR=''
PENDING_DESCRIPTOR_IDENTITY=''
LOCK_HELD=0
LAB_CLEANUP_STOP_STEP='none'
EXPECTED_DESCRIPTOR_IDENTITY=''
EXPECTED_LAB_ROOT=''
POST_LINK_GATE=''
POST_LINK_GATE_IDENTITY=''

die() {
  local message=${1:-unknown-error}
  local status=${2:-1}
  printf 'error=%s\n' "$message" >&2
  exit "$status"
}

path_present() {
  [[ -e $1 || -L $1 ]]
}

usage() {
  cat >&2 <<'USAGE'
usage:
  bash lab.sh check
  bash lab.sh setup
  bash lab.sh status
  bash lab.sh run baseline
  bash lab.sh inject guided|independent
  bash lab.sh scenario
  bash lab.sh acknowledge-predictions SHA256
  bash lab.sh observe graph|runner|cache|artifact|identity|approval|deployment
  bash lab.sh experiment cache-key
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup

optional safe preview:
  LAB_DRY_RUN=1 bash lab.sh setup
  LAB_DRY_RUN=1 bash lab.sh cleanup
USAGE
  return 64
}

require_normal_user() {
  ((LAB_UID != 0)) || die 'root-is-refused-run-as-a-normal-user' 77
}

require_command() {
  command -v -- "$1" >/dev/null 2>&1 || die "missing-required-command-$1" 69
}

validate_boolean_control() {
  local name=$1 value=$2
  case $value in
    0|1) ;;
    *) die "${name}-must-be-0-or-1" 64 ;;
  esac
}

validate_control_environment() {
  local hook=${LAB_TEST_STOP_AFTER_CLEANUP_STEP:-none}
  validate_boolean_control LAB_DRY_RUN "${LAB_DRY_RUN:-0}"
  validate_boolean_control LES0024_VERIFIER_MODE "${LES0024_VERIFIER_MODE:-0}"
  validate_boolean_control LAB_TEST_DELAY_AFTER_CLEANUP_LOCK "${LAB_TEST_DELAY_AFTER_CLEANUP_LOCK:-0}"
  validate_boolean_control LAB_TEST_DELAY_BEFORE_DESCRIPTOR_OPEN "${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_OPEN:-0}"
  validate_boolean_control LAB_TEST_DELAY_BEFORE_DESCRIPTOR_LINK "${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_LINK:-0}"
  validate_boolean_control LAB_TEST_STOP_AFTER_CLEANUP_MARKER "${LAB_TEST_STOP_AFTER_CLEANUP_MARKER:-0}"
  case $hook in
    none|marker|verification|recovery|case|baseline|experiment|prediction|runner-a|runner-b|model|sentinel|root) ;;
    *) die 'LAB_TEST_STOP_AFTER_CLEANUP_STEP-invalid' 64 ;;
  esac
  if [[ ${LAB_TEST_STOP_AFTER_CLEANUP_MARKER:-0} == 1 ]]; then
    [[ $hook == none ]] || die 'cleanup-interruption-hooks-conflict' 64
    hook=marker
  fi
  if [[ $hook != none || ${LAB_TEST_DELAY_AFTER_CLEANUP_LOCK:-0} == 1 || ${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_OPEN:-0} == 1 || ${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_LINK:-0} == 1 || -n ${LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE:-} ]]; then
    [[ ${LES0024_VERIFIER_MODE:-0} == 1 ]] || die 'test-hooks-are-verifier-only' 64
  fi
  if [[ -n ${LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE:-} ]]; then
    [[ ${LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE:-} =~ ^/tmp/reliability-atlas-LES-0024-verifier-postlinkgate\.[A-Za-z0-9]{8}$ ]] \
      || die 'post-link-gate-path-invalid' 64
    validate_regular_file "$LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE" 600
    POST_LINK_GATE=$LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE
    POST_LINK_GATE_IDENTITY=$(stat -c '%d:%i' -- "$POST_LINK_GATE") \
      || die 'cannot-read-post-link-gate-identity' 73
  fi
  if [[ -n ${LES0024_EXPECTED_DESCRIPTOR_IDENTITY:-} || -n ${LES0024_EXPECTED_LAB_ROOT:-} ]]; then
    [[ ${LES0024_VERIFIER_MODE:-0} == 1 ]] || die 'expected-lifecycle-is-verifier-only' 64
    [[ ${LES0024_EXPECTED_DESCRIPTOR_IDENTITY:-} =~ ^[0-9]+:[0-9]+$ ]] \
      || die 'expected-descriptor-identity-invalid' 64
    [[ ${LES0024_EXPECTED_LAB_ROOT:-} =~ ^/tmp/reliability-atlas-LES-0024-u${LAB_UID}\.[A-Za-z0-9]{8}$ ]] \
      || die 'expected-lab-root-invalid' 64
    EXPECTED_DESCRIPTOR_IDENTITY=$LES0024_EXPECTED_DESCRIPTOR_IDENTITY
    EXPECTED_LAB_ROOT=$LES0024_EXPECTED_LAB_ROOT
  fi
  LAB_CLEANUP_STOP_STEP=$hook
}

validate_environment() {
  local command_name tmp_mode tmp_owner
  require_normal_user
  validate_control_environment
  [[ ${BASH_VERSINFO[0]} -ge 5 ]] || die 'bash-5-or-newer-required' 69
  for command_name in bash chmod cmp find flock grep install ln mkdir mktemp mv python3 readlink rm rmdir sha256sum sleep stat; do
    require_command "$command_name"
  done
  [[ -d $STATE_PARENT && ! -L $STATE_PARENT ]] || die 'tmp-must-be-real-directory' 73
  tmp_owner=$(stat -c '%u' -- "$STATE_PARENT") || die 'cannot-read-tmp-owner' 73
  tmp_mode=$(stat -c '%a' -- "$STATE_PARENT") || die 'cannot-read-tmp-mode' 73
  [[ $tmp_owner == 0 ]] || die 'tmp-must-be-owned-by-root' 73
  [[ $tmp_mode == 1777 ]] || die "tmp-mode-must-be-1777-found-${tmp_mode}" 73
  [[ -f $MODEL_SOURCE && ! -L $MODEL_SOURCE ]] || die 'model-source-missing-or-not-regular' 66
  PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$MODEL_SOURCE" \
    || die 'model-source-does-not-parse' 65
}

orphan_candidate() {
  find -P "$STATE_PARENT" -mindepth 1 -maxdepth 1 -name "${ROOT_PREFIX}*" -print -quit 2>/dev/null
}

require_absent_state() {
  local orphan
  ! path_present "$STATE_FILE" || die 'state-descriptor-already-exists' 73
  orphan=$(orphan_candidate)
  [[ -z $orphan ]] || die 'unregistered-lesson-root-found-refusing-to-guess' 73
}

validate_regular_file() {
  local path=$1 expected_mode=$2 owner mode links
  [[ -f $path && ! -L $path ]] || die "expected-regular-file-${path##*\/}" 73
  owner=$(stat -c '%u' -- "$path") || die "cannot-read-owner-${path##*\/}" 73
  mode=$(stat -c '%a' -- "$path") || die "cannot-read-mode-${path##*\/}" 73
  links=$(stat -c '%h' -- "$path") || die "cannot-read-links-${path##*\/}" 73
  [[ $owner == "$LAB_UID" ]] || die "unexpected-owner-${path##*\/}" 73
  [[ $mode == "$expected_mode" ]] || die "unexpected-mode-${path##*\/}-${mode}" 73
  [[ $links == 1 ]] || die "unexpected-link-count-${path##*\/}-${links}" 73
}

expected_mode_for_child() {
  case $1 in
    .sentinel) printf '%s\n' 400 ;;
    pipeline_model.py) printf '%s\n' 500 ;;
    record.tmp|cleanup.marker|baseline.record|case.record|prediction.record|experiment.record|recovery.record|verification.record) printf '%s\n' 600 ;;
    *) return 1 ;;
  esac
}

expected_descriptor_for() {
  local root=$1 phase=$2
  case $phase in
    active) phase=A ;;
    cleanup) phase=C ;;
    *) die 'descriptor-phase-render-invalid' 70 ;;
  esac
  printf 'lesson=%s\nversion=%s\nuid=%s\nphase=%s\nroot=%s\n' \
    "$LESSON_ID" "$STATE_VERSION" "$LAB_UID" "$phase" "$root"
}

load_state_descriptor() {
  local -a lines=()
  validate_regular_file "$STATE_FILE" 600
  mapfile -t lines <"$STATE_FILE"
  ((${#lines[@]} == 5)) || die 'state-descriptor-field-count-invalid' 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die 'state-descriptor-lesson-invalid' 73
  [[ ${lines[1]} == "version=${STATE_VERSION}" ]] || die 'state-descriptor-version-invalid' 73
  [[ ${lines[2]} == "uid=${LAB_UID}" ]] || die 'state-descriptor-uid-invalid' 73
  [[ ${lines[3]} == phase=A || ${lines[3]} == phase=C ]] || die 'state-descriptor-phase-invalid' 73
  [[ ${lines[4]} == root=* ]] || die 'state-descriptor-root-field-invalid' 73
  if [[ ${lines[3]} == phase=A ]]; then
    STATE_PHASE=active
  else
    STATE_PHASE=cleanup
  fi
  LAB_ROOT=${lines[4]#root=}
  [[ $LAB_ROOT =~ ^/tmp/reliability-atlas-LES-0024-u${LAB_UID}\.[A-Za-z0-9]{8}$ ]] \
    || die 'registered-root-pattern-invalid' 73
}

validate_root_identity() {
  local canonical owner mode
  [[ -d $LAB_ROOT && ! -L $LAB_ROOT ]] || die 'registered-root-missing-or-not-real-directory' 73
  canonical=$(readlink -e -- "$LAB_ROOT") || die 'registered-root-cannot-be-resolved' 73
  [[ $canonical == "$LAB_ROOT" ]] || die 'registered-root-canonical-path-invalid' 73
  owner=$(stat -c '%u' -- "$LAB_ROOT") || die 'cannot-read-root-owner' 73
  mode=$(stat -c '%a' -- "$LAB_ROOT") || die 'cannot-read-root-mode' 73
  [[ $owner == "$LAB_UID" ]] || die 'registered-root-owner-invalid' 73
  [[ $mode == 700 ]] || die "registered-root-mode-invalid-${mode}" 73
}

validate_sentinel() {
  local -a lines=()
  local sentinel="${LAB_ROOT}/.sentinel"
  validate_regular_file "$sentinel" 400
  mapfile -t lines <"$sentinel"
  ((${#lines[@]} == 3)) || die 'sentinel-field-count-invalid' 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die 'sentinel-lesson-invalid' 73
  [[ ${lines[1]} == "version=${STATE_VERSION}" ]] || die 'sentinel-version-invalid' 73
  [[ ${lines[2]} == "uid=${LAB_UID}" ]] || die 'sentinel-uid-invalid' 73
}

validate_workspace() {
  local runner=$1 cleanup_mode=${2:-0} path canonical owner mode listing
  local -a lines=()
  path="${LAB_ROOT}/${runner}"
  [[ $runner == runner-a || $runner == runner-b ]] || die 'workspace-name-not-allowlisted' 73
  if ! path_present "$path"; then
    [[ $cleanup_mode == 1 ]] && return 0
    die "workspace-${runner}-missing" 73
  fi
  [[ -d $path && ! -L $path ]] || die "workspace-${runner}-not-real-directory" 73
  canonical=$(readlink -e -- "$path") || die "workspace-${runner}-cannot-be-resolved" 73
  [[ $canonical == "$path" ]] || die "workspace-${runner}-canonical-path-invalid" 73
  owner=$(stat -c '%u' -- "$path") || die "workspace-${runner}-owner-unreadable" 73
  mode=$(stat -c '%a' -- "$path") || die "workspace-${runner}-mode-unreadable" 73
  [[ $owner == "$LAB_UID" ]] || die "workspace-${runner}-owner-invalid" 73
  [[ $mode == 700 ]] || die "workspace-${runner}-mode-invalid-${mode}" 73
  listing=$(find -P "$path" -mindepth 1 -maxdepth 1 -printf '%f\n')
  if [[ -z $listing && $cleanup_mode == 1 ]]; then
    return 0
  fi
  [[ $listing == '.workspace' ]] || die "workspace-${runner}-children-invalid" 73
  validate_regular_file "${path}/.workspace" 400
  mapfile -t lines <"${path}/.workspace"
  ((${#lines[@]} == 5)) || die "workspace-${runner}-sentinel-field-count-invalid" 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die "workspace-${runner}-lesson-invalid" 73
  [[ ${lines[1]} == "version=${STATE_VERSION}" ]] || die "workspace-${runner}-version-invalid" 73
  [[ ${lines[2]} == "uid=${LAB_UID}" ]] || die "workspace-${runner}-uid-invalid" 73
  [[ ${lines[3]} == "runner=${runner}" ]] || die "workspace-${runner}-identity-invalid" 73
  [[ ${lines[4]} == "root=${LAB_ROOT}" ]] || die "workspace-${runner}-root-invalid" 73
}

validate_cleanup_marker() {
  local -a lines=()
  local marker="${LAB_ROOT}/cleanup.marker"
  validate_regular_file "$marker" 600
  mapfile -t lines <"$marker"
  ((${#lines[@]} == 3)) || die 'cleanup-marker-field-count-invalid' 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die 'cleanup-marker-lesson-invalid' 73
  [[ ${lines[1]} == "uid=${LAB_UID}" ]] || die 'cleanup-marker-uid-invalid' 73
  [[ ${lines[2]} == "root=${LAB_ROOT}" ]] || die 'cleanup-marker-root-invalid' 73
}

validate_existing_children() {
  local cleanup_mode=$1 child_path child_name expected_mode
  while IFS= read -r -d '' child_path; do
    child_name=${child_path##*\/}
    case $child_name in
      runner-a|runner-b) validate_workspace "$child_name" "$cleanup_mode" ;;
      *)
        expected_mode=$(expected_mode_for_child "$child_name") || die "unexpected-child-${child_name}" 73
        validate_regular_file "$child_path" "$expected_mode"
        case $child_name in
          .sentinel) validate_sentinel ;;
          pipeline_model.py)
            cmp -s -- "$MODEL_SOURCE" "$child_path" || die 'installed-model-differs-from-reviewed-source' 73
            ;;
          cleanup.marker) validate_cleanup_marker ;;
        esac
        ;;
    esac
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
}

validate_normal_state_locked() {
  [[ $STATE_PHASE == active ]] || die 'cleanup-is-in-progress-use-cleanup-to-resume' 73
  validate_root_identity
  validate_existing_children 0
  ! path_present "${LAB_ROOT}/cleanup.marker" || die 'cleanup-marker-invalid-during-active-phase' 73
  validate_sentinel
  validate_regular_file "${LAB_ROOT}/pipeline_model.py" 500
  cmp -s -- "$MODEL_SOURCE" "${LAB_ROOT}/pipeline_model.py" || die 'installed-model-differs-from-reviewed-source' 73
  validate_workspace runner-a 0
  validate_workspace runner-b 0
}

validate_cleanup_state_locked() {
  [[ $STATE_PHASE == cleanup ]] || die 'cleanup-phase-required' 73
  if ! path_present "$LAB_ROOT"; then
    return 0
  fi
  validate_root_identity
  validate_existing_children 1
}

acquire_descriptor_lock() {
  local path_identity fd_identity
  ((LOCK_HELD == 0)) || return 0
  if [[ ${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_OPEN:-0} == 1 ]]; then
    printf 'test_hook=before-descriptor-open\n' >&2
    sleep 2
  fi
  exec 9<"$STATE_FILE" || die 'cannot-open-state-descriptor' 73
  path_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE") || die 'cannot-read-descriptor-path-identity' 73
  fd_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) || die 'cannot-read-descriptor-fd-identity' 73
  [[ $path_identity == "$fd_identity" ]] || die 'descriptor-path-changed-while-opening' 73
  flock -n 9 || die 'state-lock-contended' 75
  LOCK_HELD=1
  load_state_descriptor
  path_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE") || die 'descriptor-unlinked-during-lock' 73
  [[ $path_identity == "$fd_identity" ]] || die 'descriptor-path-changed-after-lock' 73
}

acquire_normal_lock() {
  acquire_descriptor_lock
  validate_normal_state_locked
}

release_lock() {
  if ((LOCK_HELD == 1)); then
    flock -u 9 || true
    exec 9<&-
    LOCK_HELD=0
  fi
}

transition_to_cleanup() {
  local fd_identity path_identity
  ((LOCK_HELD == 1)) || die 'descriptor-lock-required-for-transition' 70
  [[ $STATE_PHASE == active ]] || return 0
  fd_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) || die 'cannot-read-transition-fd-identity' 73
  path_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE") || die 'cannot-read-transition-path-identity' 73
  [[ $fd_identity == "$path_identity" ]] || die 'descriptor-identity-changed-before-transition' 73
  PYTHONDONTWRITEBYTECODE=1 python3 - /proc/self/fd/9 <<'PY' \
    || die 'cannot-persist-locked-cleanup-transition' 73
import os
import sys

descriptor_path = sys.argv[1]
descriptor_fd = os.open(descriptor_path, os.O_RDWR)
try:
    content = os.pread(descriptor_fd, 65_536, 0)
    marker = b"\nphase=A\n"
    if content.count(marker) != 1:
        raise SystemExit("active phase marker missing or duplicated")
    offset = content.index(marker) + len(b"\nphase=")
    if os.pwrite(descriptor_fd, b"C", offset) != 1:
        raise SystemExit("phase write was not exactly one byte")
    os.fsync(descriptor_fd)
finally:
    os.close(descriptor_fd)
PY
  load_state_descriptor
  [[ $STATE_PHASE == cleanup ]] || die 'cleanup-transition-not-persisted' 73
}

maybe_stop_cleanup() {
  local step=$1
  if [[ $LAB_CLEANUP_STOP_STEP == "$step" ]]; then
    die "simulated-interruption-after-${step}" 85
  fi
}

remove_pending_workspace() {
  local root=$1 runner=$2 path
  path="${root}/${runner}"
  if [[ -d $path && ! -L $path ]]; then
    if [[ -f ${path}/.workspace && ! -L ${path}/.workspace ]]; then
      rm -- "${path}/.workspace" 2>/dev/null || true
    fi
    rmdir -- "$path" 2>/dev/null || true
  fi
}

pending_setup_cleanup() {
  local original_status=$? registered=0 child candidate_identity
  release_lock
  if [[ -n $PENDING_ROOT ]]; then
    if [[ -f $STATE_FILE && ! -L $STATE_FILE ]] && \
      cmp -s -- "$STATE_FILE" <(expected_descriptor_for "$PENDING_ROOT" active) 2>/dev/null; then
      registered=1
    fi
    if ((registered == 0)) && \
      [[ $PENDING_ROOT =~ ^/tmp/reliability-atlas-LES-0024-u${LAB_UID}\.[A-Za-z0-9]{8}$ && -d $PENDING_ROOT && ! -L $PENDING_ROOT ]]; then
      if [[ $(stat -c '%u' -- "$PENDING_ROOT" 2>/dev/null || printf invalid) == "$LAB_UID" ]]; then
        for child in record.tmp verification.record recovery.record experiment.record prediction.record case.record baseline.record cleanup.marker pipeline_model.py .sentinel; do
          if [[ -f ${PENDING_ROOT}/${child} && ! -L ${PENDING_ROOT}/${child} ]]; then
            rm -- "${PENDING_ROOT}/${child}" 2>/dev/null || true
          fi
        done
        remove_pending_workspace "$PENDING_ROOT" runner-a
        remove_pending_workspace "$PENDING_ROOT" runner-b
        rmdir -- "$PENDING_ROOT" 2>/dev/null || true
      fi
    fi
  fi
  if [[ -n $PENDING_DESCRIPTOR ]] && path_present "$PENDING_DESCRIPTOR"; then
    if [[ -f $PENDING_DESCRIPTOR && ! -L $PENDING_DESCRIPTOR ]]; then
      candidate_identity=$(stat -c '%d:%i' -- "$PENDING_DESCRIPTOR" 2>/dev/null || true)
      if [[ -n $PENDING_DESCRIPTOR_IDENTITY && $candidate_identity == "$PENDING_DESCRIPTOR_IDENTITY" ]]; then
        rm -- "$PENDING_DESCRIPTOR" 2>/dev/null || true
      else
        printf 'error=pending-descriptor-identity-changed-preserving\n' >&2
      fi
    else
      printf 'error=pending-descriptor-type-changed-preserving\n' >&2
    fi
  fi
  return "$original_status"
}

trap pending_setup_cleanup EXIT
trap 'exit 130' INT TERM

write_record() {
  local target=$1 content=$2 temporary="${LAB_ROOT}/record.tmp"
  ! path_present "$target" || die "record-already-exists-${target##*\/}" 73
  ! path_present "$temporary" || die 'stale-record-candidate-found' 73
  (set -o noclobber; : >"$temporary") 2>/dev/null || die 'cannot-create-record-candidate' 73
  chmod 600 -- "$temporary"
  validate_regular_file "$temporary" 600
  printf '%s\n' "$content" >"$temporary"
  validate_regular_file "$temporary" 600
  mv -T -- "$temporary" "$target"
  validate_regular_file "$target" 600
}

require_field() {
  local output=$1 field=$2
  grep -Fqx -- "$field" <<<"$output" || die "model-output-missing-${field%%=*}" 70
}

record_digest() {
  local path=$1 digest
  validate_regular_file "$path" 600
  digest=$(sha256sum -- "$path") || die "cannot-hash-record-${path##*\/}" 70
  printf '%s' "${digest%% *}"
}

load_case() {
  local line
  validate_regular_file "${LAB_ROOT}/case.record" 600
  line=$(grep -E '^case=(guided|independent)$' "${LAB_ROOT}/case.record" || true)
  [[ $line == 'case=guided' || $line == 'case=independent' ]] || die 'case-record-invalid' 73
  printf '%s' "${line#case=}"
}

write_workspace_sentinel() {
  local runner=$1 path
  path="${LAB_ROOT}/${runner}"
  mkdir -- "$path"
  chmod 700 -- "$path"
  printf 'lesson=%s\nversion=%s\nuid=%s\nrunner=%s\nroot=%s\n' \
    "$LESSON_ID" "$STATE_VERSION" "$LAB_UID" "$runner" "$LAB_ROOT" >"${path}/.workspace"
  chmod 400 -- "${path}/.workspace"
}

run_model_or_die() {
  local error_label=$1
  shift
  local output status
  set +e
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/pipeline_model.py" "$@" 2>&1)
  status=$?
  set -e
  ((status == 0)) || die "$error_label" 70
  printf '%s' "$output"
}

command_check() {
  validate_environment
  if ! path_present "$STATE_FILE"; then
    require_absent_state
    printf 'lesson=%s\nstate=absent\nnetwork=%s\nprivilege=non-root\n' "$LESSON_ID" "$NETWORK_POLICY"
    return 0
  fi
  acquire_descriptor_lock
  if [[ $STATE_PHASE == active ]]; then
    validate_normal_state_locked
    printf 'lesson=%s\nstate=registered\nlab_root=%s\nnetwork=%s\nprivilege=non-root\n' \
      "$LESSON_ID" "$LAB_ROOT" "$NETWORK_POLICY"
  else
    validate_cleanup_state_locked
    printf 'lesson=%s\nstate=cleanup-in-progress\nlab_root=%s\nnetwork=%s\n' \
      "$LESSON_ID" "$LAB_ROOT" "$NETWORK_POLICY"
  fi
}

command_setup() {
  local root descriptor_candidate descriptor_candidate_identity descriptor_identity current_candidate_identity
  local current_gate_identity gate_released=0
  validate_environment
  if [[ ${LAB_DRY_RUN:-0} == 1 ]]; then
    require_absent_state
    printf 'dry_run=true\naction=setup\nwould_create=one-private-root-two-separated-runner-workspaces-one-locking-descriptor\nnetwork=%s\nstate=absent\n' \
      "$NETWORK_POLICY"
    return 0
  fi
  if path_present "$STATE_FILE"; then
    acquire_normal_lock
    printf 'setup=already-present\nlab_root=%s\nnetwork=%s\n' "$LAB_ROOT" "$NETWORK_POLICY"
    return 0
  fi
  require_absent_state
  root=$(mktemp -d --tmpdir="$STATE_PARENT" "${ROOT_PREFIX}XXXXXXXX") || die 'cannot-create-private-root' 73
  PENDING_ROOT=$root
  chmod 700 -- "$root"
  LAB_ROOT=$root
  printf 'lesson=%s\nversion=%s\nuid=%s\n' "$LESSON_ID" "$STATE_VERSION" "$LAB_UID" >"${root}/.sentinel"
  chmod 400 -- "${root}/.sentinel"
  install -m 0500 -- "$MODEL_SOURCE" "${root}/pipeline_model.py"
  write_workspace_sentinel runner-a
  write_workspace_sentinel runner-b

  descriptor_candidate=$(mktemp --tmpdir="$STATE_PARENT" "reliability-atlas-LES-0024-${LAB_UID}.candidate.XXXXXXXX") \
    || die 'cannot-create-descriptor-candidate' 73
  PENDING_DESCRIPTOR=$descriptor_candidate
  descriptor_candidate_identity=$(stat -c '%d:%i' -- "$descriptor_candidate") \
    || die 'cannot-read-created-descriptor-candidate-identity' 73
  PENDING_DESCRIPTOR_IDENTITY=$descriptor_candidate_identity
  expected_descriptor_for "$root" active >"$descriptor_candidate"
  chmod 600 -- "$descriptor_candidate"
  validate_regular_file "$descriptor_candidate" 600
  if [[ ${LAB_TEST_DELAY_BEFORE_DESCRIPTOR_LINK:-0} == 1 ]]; then
    printf 'test_hook=before-descriptor-link\n' >&2
    sleep 2
  fi
  ln -T -- "$descriptor_candidate" "$STATE_FILE" || die 'cannot-register-state-atomically' 73
  current_candidate_identity=$(stat -c '%d:%i' -- "$descriptor_candidate") \
    || die 'cannot-read-descriptor-candidate-before-removal' 73
  [[ $current_candidate_identity == "$descriptor_candidate_identity" ]] \
    || die 'descriptor-candidate-identity-changed-refusing-removal' 73
  rm -- "$descriptor_candidate"
  ! path_present "$descriptor_candidate" || die 'descriptor-candidate-still-present-after-removal' 73
  PENDING_DESCRIPTOR=''
  PENDING_DESCRIPTOR_IDENTITY=''
  if [[ -n $POST_LINK_GATE ]]; then
    printf 'test_hook=after-descriptor-link\n' >&2
    for _ in {1..1000}; do
      validate_regular_file "$POST_LINK_GATE" 600
      current_gate_identity=$(stat -c '%d:%i' -- "$POST_LINK_GATE") \
        || die 'cannot-read-post-link-gate-identity-during-wait' 73
      [[ $current_gate_identity == "$POST_LINK_GATE_IDENTITY" ]] \
        || die 'post-link-gate-identity-changed' 86
      if grep -Fqx -- 'release' "$POST_LINK_GATE"; then
        gate_released=1
        break
      fi
      sleep 0.02
    done
    ((gate_released == 1)) || die 'post-link-gate-timeout' 86
  fi
  acquire_descriptor_lock
  descriptor_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) \
    || die 'cannot-read-setup-descriptor-identity' 73
  [[ $descriptor_identity == "$descriptor_candidate_identity" && $LAB_ROOT == "$root" ]] \
    || die 'setup-lifecycle-replaced-before-ownership-receipt' 79
  validate_normal_state_locked
  PENDING_ROOT=''
  printf 'setup=complete\nlab_root=%s\nownership_descriptor_identity=%s\nrunner_workspaces=runner-a,runner-b\nworkspace_claim=distinct-private-paths-same-uid-not-isolation\nnetwork=%s\nnext_command=bash lab.sh run baseline\n' \
    "$LAB_ROOT" "$descriptor_identity" "$NETWORK_POLICY"
}

command_status() {
  local baseline='pending' active='none' prediction='pending' experiment='pending' recovery='pending' verification='pending'
  validate_environment
  acquire_descriptor_lock
  if [[ $STATE_PHASE == cleanup ]]; then
    validate_cleanup_state_locked
    printf 'state=cleanup-in-progress\nlab_root=%s\nnetwork=%s\nnext_command=bash lab.sh cleanup\n' "$LAB_ROOT" "$NETWORK_POLICY"
    return 0
  fi
  validate_normal_state_locked
  path_present "${LAB_ROOT}/baseline.record" && baseline='complete'
  if path_present "${LAB_ROOT}/case.record"; then active=$(load_case); fi
  path_present "${LAB_ROOT}/prediction.record" && prediction='acknowledged'
  path_present "${LAB_ROOT}/experiment.record" && experiment='complete'
  path_present "${LAB_ROOT}/recovery.record" && recovery='complete'
  path_present "${LAB_ROOT}/verification.record" && verification='complete'
  printf 'state=ready\nlab_root=%s\nbaseline=%s\nactive_case=%s\nprediction=%s\nexperiment=%s\nrecovery=%s\nverification=%s\nrunner_workspaces=2\nworkspace_isolation_proven=false\nnetwork=%s\n' \
    "$LAB_ROOT" "$baseline" "$active" "$prediction" "$experiment" "$recovery" "$verification" "$NETWORK_POLICY"
}

command_run() {
  local target=$1 output
  [[ $target == baseline ]] || die 'run-target-must-be-baseline' 64
  validate_environment
  acquire_normal_lock
  ! path_present "${LAB_ROOT}/baseline.record" || die 'baseline-already-recorded' 73
  ! path_present "${LAB_ROOT}/case.record" || die 'cannot-run-baseline-after-case' 73
  output=$(CDPATH='' cd -- "${LAB_ROOT}/runner-a" && run_model_or_die 'baseline-model-failed' baseline)
  require_field "$output" 'record=baseline'
  require_field "$output" 'runner_workspaces_distinct=true'
  require_field "$output" 'workspace_isolation_proven=false'
  require_field "$output" 'build_attempt_ids_distinct=true'
  require_field "$output" 'artifact_byte_identical=true'
  require_field "$output" 'attempt_id_embedded_in_artifact=false'
  require_field "$output" 'cache_key_complete=true'
  require_field "$output" 'approval_separated_from_executor=true'
  require_field "$output" 'duplicate_promotions=0'
  require_field "$output" 'network_calls=0'
  require_field "$output" 'hosted_ci_calls=0'
  require_field "$output" 'registry_calls=0'
  require_field "$output" 'cloud_calls=0'
  write_record "${LAB_ROOT}/baseline.record" "$output"
  printf '%s\nnext_command=bash lab.sh inject guided\n' "$output"
}

command_inject() {
  local case_name=$1 output baseline_digest
  [[ $case_name == guided || $case_name == independent ]] || die 'case-must-be-guided-or-independent' 64
  validate_environment
  acquire_normal_lock
  validate_regular_file "${LAB_ROOT}/baseline.record" 600
  ! path_present "${LAB_ROOT}/case.record" || die 'case-already-active' 73
  baseline_digest=$(record_digest "${LAB_ROOT}/baseline.record")
  output=$(run_model_or_die 'case-registration-model-failed' case --name "$case_name" --baseline-record-sha256 "$baseline_digest")
  require_field "$output" 'record=case_registration'
  require_field "$output" "case=${case_name}"
  require_field "$output" "baseline_record_sha256=${baseline_digest}"
  require_field "$output" 'answer_key=not-provided'
  write_record "${LAB_ROOT}/case.record" "$output"
  printf '%s\n' "$output"
  if [[ $case_name == independent ]]; then
    printf 'next_command=bash lab.sh scenario\n'
  else
    printf 'next_command=bash lab.sh observe graph\n'
  fi
}

command_scenario() {
  local case_name output forbidden
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  [[ $case_name == independent ]] || die 'scenario-only-available-for-independent-case' 73
  ! path_present "${LAB_ROOT}/recovery.record" || die 'scenario-unavailable-after-recovery' 73
  output=$(run_model_or_die 'scenario-model-failed' scenario)
  require_field "$output" 'record=scenario_input'
  for forbidden in decision diagnosis root_cause recovery approval_valid cache_valid identity_valid promotion_allowed deployment_outcome duplicate_effects answer_key; do
    if grep -Fiq -- "$forbidden" <<<"$output"; then
      die "scenario-exposed-derived-field-${forbidden}" 70
    fi
  done
  printf '%s\nprediction_gate=bash lab.sh acknowledge-predictions SHA256\n' "$output"
}

command_acknowledge_predictions() {
  local external_digest=$1 case_name output
  [[ $external_digest =~ ^[a-f0-9]{64}$ ]] || die 'prediction-digest-must-be-lowercase-sha256' 64
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  [[ $case_name == independent ]] || die 'prediction-acknowledgment-only-for-independent-case' 73
  ! path_present "${LAB_ROOT}/prediction.record" || die 'predictions-already-acknowledged' 73
  ! path_present "${LAB_ROOT}/recovery.record" || die 'predictions-unavailable-after-recovery' 73
  output=$(run_model_or_die 'prediction-model-failed' acknowledge-predictions --external-sha256 "$external_digest")
  require_field "$output" 'record=prediction_acknowledgment'
  require_field "$output" "external_prediction_sha256=${external_digest}"
  require_field "$output" 'content_stored=false'
  require_field "$output" 'review_required=true'
  write_record "${LAB_ROOT}/prediction.record" "$output"
  printf '%s\nnext_command=bash lab.sh observe graph\n' "$output"
}

command_observe() {
  local view=$1 case_name output
  case $view in
    graph|runner|cache|artifact|identity|approval|deployment) ;;
    *) die 'view-not-allowlisted' 64 ;;
  esac
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  if [[ $case_name == independent ]]; then
    validate_regular_file "${LAB_ROOT}/prediction.record" 600
  fi
  ! path_present "${LAB_ROOT}/recovery.record" || die 'observation-unavailable-after-recovery' 73
  output=$(run_model_or_die 'observation-model-failed' observe --case "$case_name" --view "$view")
  require_field "$output" 'record=observation'
  require_field "$output" "case=${case_name}"
  require_field "$output" "view=${view}"
  printf '%s\n' "$output"
}

command_experiment() {
  local experiment_name=$1 case_name prediction_digest output
  [[ $experiment_name == cache-key ]] || die 'experiment-must-be-cache-key' 64
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  [[ $case_name == independent ]] || die 'experiment-only-available-for-independent-case' 73
  validate_regular_file "${LAB_ROOT}/prediction.record" 600
  ! path_present "${LAB_ROOT}/experiment.record" || die 'experiment-already-recorded' 73
  ! path_present "${LAB_ROOT}/recovery.record" || die 'experiment-unavailable-after-recovery' 73
  prediction_digest=$(record_digest "${LAB_ROOT}/prediction.record")
  output=$(run_model_or_die 'experiment-model-failed' experiment --name cache-key --prediction-record-sha256 "$prediction_digest")
  require_field "$output" 'record=experiment'
  require_field "$output" 'case=independent'
  require_field "$output" 'experiment=cache-key'
  require_field "$output" 'declared_variable=pipeline-definition-digest-in-key'
  require_field "$output" 'single_variable_changed=true'
  require_field "$output" 'proof_limit=deterministic-local-model-only'
  require_field "$output" 'network_calls=0'
  require_field "$output" 'hosted_ci_calls=0'
  require_field "$output" 'registry_calls=0'
  require_field "$output" 'cloud_calls=0'
  write_record "${LAB_ROOT}/experiment.record" "$output"
  printf '%s\nnext_command=bash lab.sh recover\n' "$output"
}

command_recover() {
  local case_name output baseline_digest case_digest prediction_digest='' experiment_digest=''
  local -a model_args
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  validate_regular_file "${LAB_ROOT}/baseline.record" 600
  validate_regular_file "${LAB_ROOT}/case.record" 600
  ! path_present "${LAB_ROOT}/recovery.record" || die 'recovery-already-recorded' 73
  baseline_digest=$(record_digest "${LAB_ROOT}/baseline.record")
  case_digest=$(record_digest "${LAB_ROOT}/case.record")
  model_args=(recover --case "$case_name" --baseline-record-sha256 "$baseline_digest" --case-record-sha256 "$case_digest")
  if [[ $case_name == independent ]]; then
    validate_regular_file "${LAB_ROOT}/prediction.record" 600
    validate_regular_file "${LAB_ROOT}/experiment.record" 600
    prediction_digest=$(record_digest "${LAB_ROOT}/prediction.record")
    experiment_digest=$(record_digest "${LAB_ROOT}/experiment.record")
    model_args+=(--prediction-record-sha256 "$prediction_digest" --experiment-record-sha256 "$experiment_digest")
  fi
  output=$(run_model_or_die 'recovery-model-failed' "${model_args[@]}")
  require_field "$output" 'record=recovery'
  require_field "$output" "case=${case_name}"
  require_field "$output" "baseline_record_sha256=${baseline_digest}"
  require_field "$output" "case_record_sha256=${case_digest}"
  require_field "$output" 'operation_success=true'
  require_field "$output" 'promotion_count=1'
  require_field "$output" 'duplicate_promotions=0'
  require_field "$output" 'user_verification=passed'
  write_record "${LAB_ROOT}/recovery.record" "$output"
  printf '%s\nnext_command=bash lab.sh verify-operation\n' "$output"
}

command_verify_operation() {
  local case_name output
  local -a model_args
  validate_environment
  acquire_normal_lock
  case_name=$(load_case)
  validate_regular_file "${LAB_ROOT}/baseline.record" 600
  validate_regular_file "${LAB_ROOT}/case.record" 600
  validate_regular_file "${LAB_ROOT}/recovery.record" 600
  ! path_present "${LAB_ROOT}/verification.record" || die 'verification-already-recorded' 73
  model_args=(verify \
    --baseline-record "${LAB_ROOT}/baseline.record" \
    --case-record "${LAB_ROOT}/case.record" \
    --recovery-record "${LAB_ROOT}/recovery.record")
  if [[ $case_name == independent ]]; then
    validate_regular_file "${LAB_ROOT}/prediction.record" 600
    validate_regular_file "${LAB_ROOT}/experiment.record" 600
    model_args+=(--prediction-record "${LAB_ROOT}/prediction.record" --experiment-record "${LAB_ROOT}/experiment.record")
  fi
  output=$(run_model_or_die 'record-semantic-verification-failed' "${model_args[@]}")
  require_field "$output" 'record=verification'
  require_field "$output" 'controller_state=converged'
  require_field "$output" 'operation_success=true'
  require_field "$output" 'runner_workspaces=distinct-private-current-uid'
  require_field "$output" 'workspace_isolation_proven=false'
  require_field "$output" 'cache_key_complete=true'
  require_field "$output" 'artifact_identity=verified'
  require_field "$output" 'identity_scope=valid'
  require_field "$output" 'approval_binding=valid'
  require_field "$output" 'promotion_count=1'
  require_field "$output" 'duplicate_promotions=0'
  require_field "$output" 'user_verification=passed'
  require_field "$output" 'network_calls=0'
  require_field "$output" 'hosted_ci_calls=0'
  require_field "$output" 'registry_calls=0'
  require_field "$output" 'cloud_calls=0'
  write_record "${LAB_ROOT}/verification.record" "$output"
  printf '%s\n' "$output"
}

remove_if_present() {
  local name=$1 expected_mode=$2 step=$3 path
  path="${LAB_ROOT}/${name}"
  if path_present "$path"; then
    validate_regular_file "$path" "$expected_mode"
    rm -- "$path"
  fi
  maybe_stop_cleanup "$step"
}

remove_workspace() {
  local runner=$1 path
  path="${LAB_ROOT}/${runner}"
  if ! path_present "$path"; then
    maybe_stop_cleanup "$runner"
    return 0
  fi
  validate_workspace "$runner" 1
  if path_present "${path}/.workspace"; then
    validate_regular_file "${path}/.workspace" 400
    rm -- "${path}/.workspace"
  fi
  [[ $(find -P "$path" -mindepth 1 -maxdepth 1 -print -quit) == '' ]] \
    || die "workspace-${runner}-not-empty-refusing-broader-cleanup" 73
  rmdir -- "$path" || die "cannot-remove-empty-workspace-${runner}" 73
  maybe_stop_cleanup "$runner"
}

ensure_cleanup_marker() {
  local marker="${LAB_ROOT}/cleanup.marker"
  if path_present "$marker"; then
    validate_cleanup_marker
    return 0
  fi
  printf 'lesson=%s\nuid=%s\nroot=%s\n' "$LESSON_ID" "$LAB_UID" "$LAB_ROOT" >"$marker"
  chmod 600 -- "$marker"
  validate_cleanup_marker
}

command_cleanup() {
  local root_before descriptor_identity fd_identity resumed=0
  validate_environment
  if ! path_present "$STATE_FILE"; then
    [[ -z $EXPECTED_DESCRIPTOR_IDENTITY && -z $EXPECTED_LAB_ROOT ]] \
      || die 'verifier-owned-lifecycle-mismatch-refusing-cleanup' 79
    require_absent_state
    printf 'cleanup=already-clean\nstate=absent\ncleanup_proven=true\n'
    return 0
  fi

  acquire_descriptor_lock
  if [[ -n $EXPECTED_DESCRIPTOR_IDENTITY || -n $EXPECTED_LAB_ROOT ]]; then
    fd_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) \
      || die 'cannot-read-guarded-cleanup-descriptor-identity' 73
    [[ $fd_identity == "$EXPECTED_DESCRIPTOR_IDENTITY" && $LAB_ROOT == "$EXPECTED_LAB_ROOT" ]] \
      || die 'verifier-owned-lifecycle-mismatch-refusing-cleanup' 79
  fi
  root_before=$LAB_ROOT
  if [[ $STATE_PHASE == active ]]; then
    validate_normal_state_locked
  else
    resumed=1
    validate_cleanup_state_locked
  fi

  if [[ ${LAB_DRY_RUN:-0} == 1 ]]; then
    if path_present "$LAB_ROOT"; then
      printf 'dry_run=true\naction=cleanup\nwould_remove=validated-allowlisted-state-only\nlab_root=%s\nnetwork=%s\n' \
        "$LAB_ROOT" "$NETWORK_POLICY"
    else
      printf 'dry_run=true\naction=cleanup-descriptor-only\nstate=cleanup\nnetwork=%s\n' "$NETWORK_POLICY"
    fi
    return 0
  fi

  if [[ ${LAB_TEST_DELAY_AFTER_CLEANUP_LOCK:-0} == 1 ]]; then
    printf 'test_hook=cleanup-lock-held\n' >&2
    sleep 2
  fi

  if [[ $STATE_PHASE == active ]]; then
    transition_to_cleanup
  fi

  if path_present "$LAB_ROOT"; then
    validate_cleanup_state_locked
    ensure_cleanup_marker
    maybe_stop_cleanup marker
    remove_if_present verification.record 600 verification
    remove_if_present recovery.record 600 recovery
    remove_if_present experiment.record 600 experiment
    remove_if_present prediction.record 600 prediction
    remove_if_present case.record 600 case
    remove_if_present baseline.record 600 baseline
    remove_if_present record.tmp 600 baseline
    remove_workspace runner-a
    remove_workspace runner-b
    remove_if_present pipeline_model.py 500 model
    remove_if_present .sentinel 400 sentinel
    remove_if_present cleanup.marker 600 marker-final
    [[ $(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print -quit) == '' ]] \
      || die 'lab-root-not-empty-refusing-broader-cleanup' 73
    rmdir -- "$LAB_ROOT" || die 'cannot-remove-empty-lab-root' 73
    maybe_stop_cleanup root
  fi

  validate_regular_file "$STATE_FILE" 600
  cmp -s -- "$STATE_FILE" <(expected_descriptor_for "$root_before" cleanup) \
    || die 'state-descriptor-changed-before-removal' 73
  descriptor_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE") || die 'cannot-read-final-descriptor-identity' 73
  fd_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) || die 'cannot-read-final-lock-identity' 73
  [[ $descriptor_identity == "$fd_identity" ]] || die 'descriptor-identity-changed-before-removal' 73
  rm -- "$STATE_FILE"
  ! path_present "$root_before" || die 'lab-root-still-present-after-cleanup' 73
  ! path_present "$STATE_FILE" || die 'state-descriptor-still-present-after-cleanup' 73
  [[ -z $(orphan_candidate) ]] || die 'orphan-remains-after-cleanup' 73
  printf 'cleanup=complete\nstate=absent\ncleanup_proven=true\n'
  if ((resumed == 1)); then
    printf 'resume=descriptor-phase\n'
  fi
}

main() {
  local command=${1:-}
  case $command in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      (($# == 1)) || { usage; exit 64; }
      "command_${command//-/_}"
      ;;
    run|inject|observe|experiment|acknowledge-predictions)
      (($# == 2)) || { usage; exit 64; }
      "command_${command//-/_}" "$2"
      ;;
    *) usage; exit 64 ;;
  esac
}

main "$@"
