#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly LESSON_ID='LES-0017'
readonly STATE_VERSION='1'
readonly STATE_PARENT='/tmp'
readonly ROOT_BASENAME_PREFIX='reliability-atlas-LES-0017.'
readonly NETWORK_POLICY='none'

SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
readonly SCRIPT_DIRECTORY
FIXTURE_SOURCE="${SCRIPT_DIRECTORY}/fixtures/automation_model.sh"
readonly FIXTURE_SOURCE
LAB_UID=$(id -u)
readonly LAB_UID
STATE_FILE="${STATE_PARENT}/reliability-atlas-LES-0017-${LAB_UID}.state"
readonly STATE_FILE

LAB_ROOT=''
PENDING_SETUP_ROOT=''
LOCK_HELD=0

die() {
  local message=${1:-unknown-error}
  local status=${2:-1}
  printf 'error=%s\n' "$message" >&2
  exit "$status"
}

usage() {
  cat >&2 <<'USAGE'
usage:
  bash lab.sh check
  bash lab.sh setup
  bash lab.sh status
  bash lab.sh run baseline
  bash lab.sh inject guided|independent
  bash lab.sh observe input|expansion|pipeline|state|retry
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup
  bash lab.sh reset
USAGE
  return 64
}

require_no_extra_arguments() {
  local expected=$1
  local actual=$2
  ((actual == expected)) || { usage; exit 64; }
}

require_normal_user() {
  ((LAB_UID != 0)) || die 'root-is-refused-run-as-a-normal-user' 77
}

require_command() {
  local command_name=$1
  command -v -- "$command_name" >/dev/null 2>&1 || die "missing-required-command-${command_name}" 69
}

validate_environment() {
  local command_name
  local tmp_mode
  local tmp_owner

  require_normal_user
  [[ ${BASH_VERSINFO[0]} -ge 5 ]] || die 'bash-5-or-newer-required' 69

  for command_name in bash id stat readlink mktemp find cmp chmod cp mv rm rmdir flock grep wc; do
    require_command "$command_name"
  done

  [[ -d $STATE_PARENT && ! -L $STATE_PARENT ]] || die 'tmp-must-be-a-real-directory' 73
  tmp_owner=$(stat -c '%u' -- "$STATE_PARENT") || die 'cannot-read-tmp-owner' 73
  tmp_mode=$(stat -c '%a' -- "$STATE_PARENT") || die 'cannot-read-tmp-mode' 73
  [[ $tmp_owner == 0 ]] || die 'tmp-must-be-owned-by-root' 73
  [[ $tmp_mode == 1777 ]] || die "tmp-mode-must-be-1777-found-${tmp_mode}" 73
  [[ -f $FIXTURE_SOURCE && ! -L $FIXTURE_SOURCE ]] || die 'fixture-source-missing-or-not-regular' 66
  bash -n -- "$FIXTURE_SOURCE" || die 'fixture-source-does-not-parse' 65
}

orphan_candidate() {
  find -P "$STATE_PARENT" -mindepth 1 -maxdepth 1 -name "${ROOT_BASENAME_PREFIX}*" -print -quit 2>/dev/null
}

require_absent_state() {
  local orphan
  [[ ! -e $STATE_FILE && ! -L $STATE_FILE ]] || die 'state-descriptor-already-exists' 73
  orphan=$(orphan_candidate)
  [[ -z $orphan ]] || die 'unregistered-lesson-root-found-refusing-to-guess' 73
}

validate_regular_file() {
  local path=$1
  local expected_mode=$2
  local owner
  local mode
  local links

  [[ -f $path && ! -L $path ]] || die "expected-regular-file-${path##*/}" 73
  owner=$(stat -c '%u' -- "$path") || die "cannot-read-owner-${path##*/}" 73
  mode=$(stat -c '%a' -- "$path") || die "cannot-read-mode-${path##*/}" 73
  links=$(stat -c '%h' -- "$path") || die "cannot-read-links-${path##*/}" 73
  [[ $owner == "$LAB_UID" ]] || die "unexpected-owner-${path##*/}" 73
  [[ $mode == "$expected_mode" ]] || die "unexpected-mode-${path##*/}-${mode}" 73
  [[ $links == 1 ]] || die "unexpected-link-count-${path##*/}-${links}" 73
}

load_state_descriptor() {
  local -a state_lines=()
  local root_value

  validate_regular_file "$STATE_FILE" 600
  mapfile -t state_lines <"$STATE_FILE"
  ((${#state_lines[@]} == 4)) || die 'state-descriptor-field-count-invalid' 73
  [[ ${state_lines[0]} == "lesson=${LESSON_ID}" ]] || die 'state-descriptor-lesson-invalid' 73
  [[ ${state_lines[1]} == "version=${STATE_VERSION}" ]] || die 'state-descriptor-version-invalid' 73
  [[ ${state_lines[2]} == "uid=${LAB_UID}" ]] || die 'state-descriptor-uid-invalid' 73
  [[ ${state_lines[3]} == root=* ]] || die 'state-descriptor-root-field-invalid' 73

  root_value=${state_lines[3]#root=}
  [[ -n $root_value ]] || die 'state-descriptor-root-empty' 73
  LAB_ROOT=$root_value
}

validate_root_identity() {
  local canonical_root
  local owner
  local mode
  local basename_value

  [[ $LAB_ROOT =~ ^/tmp/reliability-atlas-LES-0017\.[A-Za-z0-9]{8}$ ]] || die 'registered-root-pattern-invalid' 73
  [[ -d $LAB_ROOT && ! -L $LAB_ROOT ]] || die 'registered-root-missing-or-not-real-directory' 73
  canonical_root=$(readlink -e -- "$LAB_ROOT") || die 'registered-root-cannot-be-resolved' 73
  [[ $canonical_root == "$LAB_ROOT" ]] || die 'registered-root-canonical-path-invalid' 73
  [[ $(dirname -- "$LAB_ROOT") == "$STATE_PARENT" ]] || die 'registered-root-parent-invalid' 73
  basename_value=$(basename -- "$LAB_ROOT")
  [[ $basename_value =~ ^reliability-atlas-LES-0017\.[A-Za-z0-9]{8}$ ]] || die 'registered-root-basename-invalid' 73
  owner=$(stat -c '%u' -- "$LAB_ROOT") || die 'cannot-read-root-owner' 73
  mode=$(stat -c '%a' -- "$LAB_ROOT") || die 'cannot-read-root-mode' 73
  [[ $owner == "$LAB_UID" ]] || die 'registered-root-owner-invalid' 73
  [[ $mode == 700 ]] || die "registered-root-mode-invalid-${mode}" 73
}

validate_sentinel() {
  local -a sentinel_lines=()
  local sentinel="${LAB_ROOT}/.sentinel"

  validate_regular_file "$sentinel" 400
  mapfile -t sentinel_lines <"$sentinel"
  ((${#sentinel_lines[@]} == 3)) || die 'sentinel-field-count-invalid' 73
  [[ ${sentinel_lines[0]} == "lesson=${LESSON_ID}" ]] || die 'sentinel-lesson-invalid' 73
  [[ ${sentinel_lines[1]} == "version=${STATE_VERSION}" ]] || die 'sentinel-version-invalid' 73
  [[ ${sentinel_lines[2]} == "uid=${LAB_UID}" ]] || die 'sentinel-uid-invalid' 73
}

expected_mode_for_child() {
  local child_name=$1
  case $child_name in
    .sentinel) printf '%s\n' 400 ;;
    model.sh) printf '%s\n' 500 ;;
    .lock|baseline.txt|case.txt|raw-observed.txt|recovery.txt|verification.txt|candidate.txt) printf '%s\n' 600 ;;
    *) return 1 ;;
  esac
}

validate_children() {
  local child_path
  local child_name
  local expected_mode

  while IFS= read -r -d '' child_path; do
    child_name=${child_path##*/}
    expected_mode=$(expected_mode_for_child "$child_name") || die "unexpected-child-${child_name}" 73
    validate_regular_file "$child_path" "$expected_mode"
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)

  validate_sentinel
  validate_regular_file "${LAB_ROOT}/model.sh" 500
  validate_regular_file "${LAB_ROOT}/.lock" 600
  cmp -s -- "$FIXTURE_SOURCE" "${LAB_ROOT}/model.sh" || die 'registered-model-differs-from-reviewed-source' 73
}

validate_registered_state() {
  load_state_descriptor
  validate_root_identity
  validate_children
}

acquire_state_lock() {
  ((LOCK_HELD == 0)) || return 0
  exec 9<>"${LAB_ROOT}/.lock" || die 'cannot-open-state-lock' 73
  flock -n 9 || die 'state-lock-contended' 75
  LOCK_HELD=1
  validate_registered_state
}

release_state_lock() {
  if ((LOCK_HELD == 1)); then
    flock -u 9 || true
    exec 9>&-
    LOCK_HELD=0
  fi
}

pending_setup_cleanup() {
  local original_status=$?
  local pending=$PENDING_SETUP_ROOT

  if [[ -n $pending && $pending =~ ^/tmp/reliability-atlas-LES-0017\.[A-Za-z0-9]{8}$ && -d $pending && ! -L $pending ]]; then
    if [[ $(stat -c '%u' -- "$pending" 2>/dev/null || printf '%s' invalid) == "$LAB_UID" ]]; then
      rm -f -- \
        "${pending}/candidate.txt" \
        "${pending}/verification.txt" \
        "${pending}/recovery.txt" \
        "${pending}/raw-observed.txt" \
        "${pending}/case.txt" \
        "${pending}/baseline.txt" \
        "${pending}/model.sh" \
        "${pending}/.sentinel" \
        "${pending}/.lock" 2>/dev/null || true
      rmdir -- "$pending" 2>/dev/null || true
    fi
  fi

  return "$original_status"
}
trap pending_setup_cleanup EXIT

print_environment() {
  printf '%s\n' \
    "lesson_id=${LESSON_ID}" \
    'environment=ready' \
    'privilege=normal-user' \
    "bash_major=${BASH_VERSINFO[0]}" \
    "network=${NETWORK_POLICY}" \
    'execution=deterministic_bash_model'
}

action_check() {
  local orphan
  validate_environment
  print_environment

  if [[ -e $STATE_FILE || -L $STATE_FILE ]]; then
    validate_registered_state
    printf '%s\n' \
      'state=present' \
      "root=${LAB_ROOT}" \
      'next_command=bash lab.sh status'
    return 0
  fi

  orphan=$(orphan_candidate)
  [[ -z $orphan ]] || die 'unregistered-lesson-root-found-refusing-to-guess' 73
  printf '%s\n' \
    'state=absent' \
    'next_command=bash lab.sh setup'
}

write_state_descriptor() {
  local root=$1
  (
    set -o noclobber
    printf '%s\n' \
      "lesson=${LESSON_ID}" \
      "version=${STATE_VERSION}" \
      "uid=${LAB_UID}" \
      "root=${root}" >"$STATE_FILE"
  ) || die 'state-descriptor-creation-raced-or-failed' 73
  chmod 600 -- "$STATE_FILE" || die 'cannot-protect-state-descriptor' 73
}

action_setup() {
  local new_root
  validate_environment

  if [[ -e $STATE_FILE || -L $STATE_FILE ]]; then
    validate_registered_state
    printf '%s\n' \
      'setup=already-ready' \
      "root=${LAB_ROOT}" \
      'next_command=bash lab.sh run baseline'
    return 0
  fi

  require_absent_state
  new_root=$(mktemp -d "${STATE_PARENT}/${ROOT_BASENAME_PREFIX}XXXXXXXX") || die 'cannot-create-private-root' 73
  PENDING_SETUP_ROOT=$new_root
  LAB_ROOT=$new_root
  chmod 700 -- "$LAB_ROOT" || die 'cannot-protect-private-root' 73
  validate_root_identity

  printf '%s\n' \
    "lesson=${LESSON_ID}" \
    "version=${STATE_VERSION}" \
    "uid=${LAB_UID}" >"${LAB_ROOT}/.sentinel"
  chmod 400 -- "${LAB_ROOT}/.sentinel"
  cp -- "$FIXTURE_SOURCE" "${LAB_ROOT}/model.sh"
  chmod 500 -- "${LAB_ROOT}/model.sh"
  : >"${LAB_ROOT}/.lock"
  chmod 600 -- "${LAB_ROOT}/.lock"
  write_state_descriptor "$LAB_ROOT"

  PENDING_SETUP_ROOT=''
  validate_registered_state
  printf '%s\n' \
    'setup=ready' \
    "root=${LAB_ROOT}" \
    'network=none' \
    'next_command=bash lab.sh run baseline'
}

file_state() {
  local path=$1
  if [[ -f $path && ! -L $path ]]; then
    printf '%s' present
  else
    printf '%s' absent
  fi
}

selected_case() {
  local case_file="${LAB_ROOT}/case.txt"
  local case_value

  validate_regular_file "$case_file" 600
  IFS= read -r case_value <"$case_file" || die 'cannot-read-selected-case' 73
  case $case_value in guided|independent) ;; *) die 'selected-case-invalid' 73 ;; esac
  [[ $(wc -l <"$case_file") == 1 ]] || die 'selected-case-file-invalid' 73
  printf '%s\n' "$case_value"
}

action_status() {
  local case_value='none'
  validate_environment
  validate_registered_state

  if [[ -f ${LAB_ROOT}/case.txt ]]; then
    case_value=$(selected_case)
  fi

  printf '%s\n' \
    "lesson_id=${LESSON_ID}" \
    'state=valid' \
    "root=${LAB_ROOT}" \
    "baseline=$(file_state "${LAB_ROOT}/baseline.txt")" \
    "case=${case_value}" \
    "raw_observed=$(file_state "${LAB_ROOT}/raw-observed.txt")" \
    "recovery=$(file_state "${LAB_ROOT}/recovery.txt")" \
    "verification=$(file_state "${LAB_ROOT}/verification.txt")" \
    'network=none'
}

write_model_candidate() {
  local destination=$1
  shift
  local candidate="${LAB_ROOT}/candidate.txt"

  [[ ! -e $candidate && ! -L $candidate ]] || die 'stale-candidate-present' 73
  : >"$candidate"
  chmod 600 -- "$candidate"
  if ! "${LAB_ROOT}/model.sh" "$@" >"$candidate"; then
    rm -- "$candidate"
    die 'deterministic-model-failed' 70
  fi
  [[ -s $candidate ]] || { rm -- "$candidate"; die 'deterministic-model-produced-empty-output' 70; }
  mv -- "$candidate" "$destination" || die 'candidate-publication-failed' 74
}

action_run_baseline() {
  validate_environment
  validate_registered_state
  acquire_state_lock
  [[ ! -e ${LAB_ROOT}/baseline.txt && ! -L ${LAB_ROOT}/baseline.txt ]] || die 'baseline-already-recorded' 65
  [[ ! -e ${LAB_ROOT}/case.txt && ! -L ${LAB_ROOT}/case.txt ]] || die 'cannot-record-baseline-after-case-selection' 65
  write_model_candidate "${LAB_ROOT}/baseline.txt" baseline
  validate_registered_state
  printf '%s\n' \
    'baseline=recorded' \
    'next_command=bash lab.sh inject guided'
}

action_inject() {
  local requested_case=$1
  validate_environment
  validate_registered_state
  acquire_state_lock
  [[ -f ${LAB_ROOT}/baseline.txt ]] || die 'baseline-required-before-case-selection' 65
  [[ ! -e ${LAB_ROOT}/case.txt && ! -L ${LAB_ROOT}/case.txt ]] || die 'case-already-selected-cleanup-before-another-case' 65
  [[ ! -e ${LAB_ROOT}/candidate.txt && ! -L ${LAB_ROOT}/candidate.txt ]] || die 'stale-candidate-present' 73

  : >"${LAB_ROOT}/candidate.txt"
  chmod 600 -- "${LAB_ROOT}/candidate.txt"
  printf '%s\n' "$requested_case" >"${LAB_ROOT}/candidate.txt"
  mv -- "${LAB_ROOT}/candidate.txt" "${LAB_ROOT}/case.txt"
  validate_registered_state
  printf '%s\n' \
    "case=${requested_case}" \
    'incident=selected' \
    'next_command=bash lab.sh observe input'
}

validate_raw_marker() {
  local case_value=$1
  local expected="${LAB_ROOT}/candidate.txt"
  local actual="${LAB_ROOT}/raw-observed.txt"

  validate_regular_file "$actual" 600
  [[ ! -e $expected && ! -L $expected ]] || die 'stale-candidate-present' 73
  : >"$expected"
  chmod 600 -- "$expected"
  "${LAB_ROOT}/model.sh" "$case_value" input >"$expected" || { rm -- "$expected"; die 'cannot-regenerate-raw-model' 70; }
  if ! cmp -s -- "$expected" "$actual"; then
    rm -- "$expected"
    die 'raw-observation-marker-invalid' 73
  fi
  rm -- "$expected"
}

action_observe() {
  local view=$1
  local case_value
  validate_environment
  validate_registered_state
  [[ -f ${LAB_ROOT}/baseline.txt ]] || die 'baseline-required-before-observation' 65
  case_value=$(selected_case)

  if [[ $view == input ]]; then
    acquire_state_lock
    if [[ -f ${LAB_ROOT}/raw-observed.txt ]]; then
      validate_raw_marker "$case_value"
    else
      write_model_candidate "${LAB_ROOT}/raw-observed.txt" "$case_value" input
    fi
    cat -- "${LAB_ROOT}/raw-observed.txt"
    printf '%s\n' 'next=write-prediction-before-derived-views'
    return 0
  fi

  [[ -f ${LAB_ROOT}/raw-observed.txt ]] || die 'raw-input-must-be-observed-before-derived-views' 65
  validate_raw_marker "$case_value"
  "${LAB_ROOT}/model.sh" "$case_value" "$view"
}

action_recover() {
  local case_value
  validate_environment
  validate_registered_state
  acquire_state_lock
  case_value=$(selected_case)
  [[ -f ${LAB_ROOT}/raw-observed.txt ]] || die 'raw-input-and-prediction-required-before-recovery' 65
  validate_raw_marker "$case_value"
  [[ ! -e ${LAB_ROOT}/recovery.txt && ! -L ${LAB_ROOT}/recovery.txt ]] || die 'recovery-already-recorded' 65
  write_model_candidate "${LAB_ROOT}/recovery.txt" "$case_value" recovery
  validate_registered_state
  cat -- "${LAB_ROOT}/recovery.txt"
  printf '%s\n' 'next_command=bash lab.sh verify-operation'
}

validate_recovery() {
  local case_value=$1
  local expected="${LAB_ROOT}/candidate.txt"
  local actual="${LAB_ROOT}/recovery.txt"

  validate_regular_file "$actual" 600
  [[ ! -e $expected && ! -L $expected ]] || die 'stale-candidate-present' 73
  : >"$expected"
  chmod 600 -- "$expected"
  "${LAB_ROOT}/model.sh" "$case_value" recovery >"$expected" || { rm -- "$expected"; die 'cannot-regenerate-recovery-model' 70; }
  if ! cmp -s -- "$expected" "$actual"; then
    rm -- "$expected"
    die 'recovery-record-invalid' 73
  fi
  rm -- "$expected"
}

action_verify_operation() {
  local case_value
  validate_environment
  validate_registered_state
  acquire_state_lock
  case_value=$(selected_case)
  [[ -f ${LAB_ROOT}/recovery.txt ]] || die 'recovery-required-before-operation-verification' 65
  validate_recovery "$case_value"
  [[ ! -e ${LAB_ROOT}/verification.txt && ! -L ${LAB_ROOT}/verification.txt ]] || die 'operation-already-verified' 65
  write_model_candidate "${LAB_ROOT}/verification.txt" "$case_value" verification
  grep -Fxq -- 'operation_verified=true' "${LAB_ROOT}/verification.txt" || die 'modeled-operation-verification-failed' 70
  validate_registered_state
  cat -- "${LAB_ROOT}/verification.txt"
  printf '%s\n' 'next_command=bash lab.sh cleanup'
}

remove_if_present() {
  local path=$1
  if [[ -e $path || -L $path ]]; then
    rm -- "$path" || die "cannot-remove-${path##*/}" 74
  fi
}

action_cleanup() {
  local removed_root
  validate_environment

  if [[ ! -e $STATE_FILE && ! -L $STATE_FILE ]]; then
    require_absent_state
    printf '%s\n' 'cleanup=already-absent' 'state=absent'
    return 0
  fi

  validate_registered_state
  acquire_state_lock
  removed_root=$LAB_ROOT

  remove_if_present "${LAB_ROOT}/candidate.txt"
  remove_if_present "${LAB_ROOT}/verification.txt"
  remove_if_present "${LAB_ROOT}/recovery.txt"
  remove_if_present "${LAB_ROOT}/raw-observed.txt"
  remove_if_present "${LAB_ROOT}/case.txt"
  remove_if_present "${LAB_ROOT}/baseline.txt"
  remove_if_present "${LAB_ROOT}/model.sh"
  remove_if_present "${LAB_ROOT}/.sentinel"
  remove_if_present "${LAB_ROOT}/.lock"
  rmdir -- "$LAB_ROOT" || die 'registered-root-not-empty-refusing-recursive-delete' 74
  rm -- "$STATE_FILE" || die 'cannot-remove-state-descriptor' 74
  release_state_lock
  LAB_ROOT=''
  require_absent_state
  printf '%s\n' \
    'cleanup=complete' \
    "removed_root=${removed_root}" \
    'recursive_delete=false' \
    'state=absent'
}

action_reset() {
  action_cleanup
  action_setup
}

main() {
  local action=${1:-}
  local subject=${2:-}

  case $action in
    check)
      require_no_extra_arguments 1 "$#"
      action_check
      ;;
    setup)
      require_no_extra_arguments 1 "$#"
      action_setup
      ;;
    status)
      require_no_extra_arguments 1 "$#"
      action_status
      ;;
    run)
      require_no_extra_arguments 2 "$#"
      [[ $subject == baseline ]] || { usage; return 64; }
      action_run_baseline
      ;;
    inject)
      require_no_extra_arguments 2 "$#"
      case $subject in guided|independent) ;; *) usage; return 64 ;; esac
      action_inject "$subject"
      ;;
    observe)
      require_no_extra_arguments 2 "$#"
      case $subject in input|expansion|pipeline|state|retry) ;; *) usage; return 64 ;; esac
      action_observe "$subject"
      ;;
    recover)
      require_no_extra_arguments 1 "$#"
      action_recover
      ;;
    verify-operation)
      require_no_extra_arguments 1 "$#"
      action_verify_operation
      ;;
    cleanup)
      require_no_extra_arguments 1 "$#"
      action_cleanup
      ;;
    reset)
      require_no_extra_arguments 1 "$#"
      action_reset
      ;;
    *)
      usage
      return 64
      ;;
  esac
}

main "$@"
