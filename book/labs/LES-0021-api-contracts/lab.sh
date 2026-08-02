#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

readonly LESSON_ID='LES-0021'
readonly STATE_VERSION='1'
readonly STATE_PARENT='/tmp'
readonly ROOT_PREFIX='reliability-atlas-LES-0021.'
readonly NETWORK_POLICY='none'

SCRIPT_SOURCE=${BASH_SOURCE[0]}
if [[ $SCRIPT_SOURCE == */* ]]; then
  SCRIPT_PARENT=${SCRIPT_SOURCE%/*}
else
  SCRIPT_PARENT='.'
fi
SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)
readonly SCRIPT_SOURCE SCRIPT_PARENT SCRIPT_DIRECTORY
readonly MODEL_SOURCE="${SCRIPT_DIRECTORY}/fixtures/api_contract_model.py"
LAB_UID=$EUID
readonly LAB_UID
readonly STATE_FILE="${STATE_PARENT}/reliability-atlas-LES-0021-${LAB_UID}.state"

LAB_ROOT=''
PENDING_ROOT=''
PENDING_DESCRIPTOR=''
LOCK_HELD=0

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
  bash lab.sh observe request|contract|operation|page|limit|webhook
  bash lab.sh recover
  bash lab.sh verify-operation
  bash lab.sh cleanup
USAGE
  return 64
}

require_normal_user() {
  ((LAB_UID != 0)) || die 'root-is-refused-run-as-a-normal-user' 77
}

require_command() {
  command -v -- "$1" >/dev/null 2>&1 || die "missing-required-command-$1" 69
}

validate_environment() {
  local command_name tmp_mode tmp_owner
  require_normal_user
  [[ ${BASH_VERSINFO[0]} -ge 5 ]] || die 'bash-5-or-newer-required' 69
  for command_name in bash chmod cmp find flock grep install ln mktemp mv python3 readlink rm rmdir sha256sum stat; do
    require_command "$command_name"
  done
  [[ -d $STATE_PARENT && ! -L $STATE_PARENT ]] || die 'tmp-must-be-real-directory' 73
  tmp_owner=$(stat -c '%u' -- "$STATE_PARENT") || die 'cannot-read-tmp-owner' 73
  tmp_mode=$(stat -c '%a' -- "$STATE_PARENT") || die 'cannot-read-tmp-mode' 73
  [[ $tmp_owner == 0 ]] || die 'tmp-must-be-owned-by-root' 73
  [[ $tmp_mode == 1777 ]] || die "tmp-mode-must-be-1777-found-${tmp_mode}" 73
  [[ -f $MODEL_SOURCE && ! -L $MODEL_SOURCE ]] || die 'model-source-missing-or-not-regular' 66
  PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$MODEL_SOURCE" || die 'model-source-does-not-parse' 65
}

orphan_candidate() {
  find -P "$STATE_PARENT" -mindepth 1 -maxdepth 1 -uid "$LAB_UID" -name "${ROOT_PREFIX}*" -print -quit 2>/dev/null
}

require_absent_state() {
  local orphan
  ! path_present "$STATE_FILE" || die 'state-descriptor-already-exists' 73
  orphan=$(orphan_candidate)
  [[ -z $orphan ]] || die 'unregistered-lesson-root-found-refusing-to-guess' 73
}

validate_regular_file() {
  local path=$1 expected_mode=$2 owner mode links
  [[ -f $path && ! -L $path ]] || die "expected-regular-file-${path##*/}" 73
  owner=$(stat -c '%u' -- "$path") || die "cannot-read-owner-${path##*/}" 73
  mode=$(stat -c '%a' -- "$path") || die "cannot-read-mode-${path##*/}" 73
  links=$(stat -c '%h' -- "$path") || die "cannot-read-links-${path##*/}" 73
  [[ $owner == "$LAB_UID" ]] || die "unexpected-owner-${path##*/}" 73
  [[ $mode == "$expected_mode" ]] || die "unexpected-mode-${path##*/}-${mode}" 73
  [[ $links == 1 ]] || die "unexpected-link-count-${path##*/}-${links}" 73
}

expected_mode_for_child() {
  case $1 in
    .sentinel) printf '%s\n' 400 ;;
    api_contract_model.py) printf '%s\n' 500 ;;
    .lock|record.tmp|cleanup.marker|baseline.record|case.record|recovery.record|verification.record) printf '%s\n' 600 ;;
    *) return 1 ;;
  esac
}

load_state_descriptor() {
  local -a lines=()
  validate_regular_file "$STATE_FILE" 600
  mapfile -t lines <"$STATE_FILE"
  ((${#lines[@]} == 4)) || die 'state-descriptor-field-count-invalid' 73
  [[ ${lines[0]} == "lesson=${LESSON_ID}" ]] || die 'state-descriptor-lesson-invalid' 73
  [[ ${lines[1]} == "version=${STATE_VERSION}" ]] || die 'state-descriptor-version-invalid' 73
  [[ ${lines[2]} == "uid=${LAB_UID}" ]] || die 'state-descriptor-uid-invalid' 73
  [[ ${lines[3]} == root=* ]] || die 'state-descriptor-root-field-invalid' 73
  LAB_ROOT=${lines[3]#root=}
  [[ -n $LAB_ROOT ]] || die 'state-descriptor-root-empty' 73
}

validate_root_identity() {
  local canonical owner mode
  [[ $LAB_ROOT =~ ^/tmp/reliability-atlas-LES-0021\.[A-Za-z0-9]{8}$ ]] || die 'registered-root-pattern-invalid' 73
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

validate_children() {
  local child_path child_name expected_mode
  while IFS= read -r -d '' child_path; do
    child_name=${child_path##*/}
    expected_mode=$(expected_mode_for_child "$child_name") || die "unexpected-child-${child_name}" 73
    validate_regular_file "$child_path" "$expected_mode"
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
  validate_sentinel
  validate_regular_file "${LAB_ROOT}/api_contract_model.py" 500
  validate_regular_file "${LAB_ROOT}/.lock" 600
  cmp -s -- "$MODEL_SOURCE" "${LAB_ROOT}/api_contract_model.py" || die 'installed-model-differs-from-reviewed-source' 73
}

validate_registered_state() {
  load_state_descriptor
  validate_root_identity
  validate_children
}

acquire_lock() {
  local path_identity fd_identity
  ((LOCK_HELD == 0)) || return 0
  exec 9<>"${LAB_ROOT}/.lock" || die 'cannot-open-state-lock' 73
  path_identity=$(stat -Lc '%d:%i' -- "${LAB_ROOT}/.lock") || die 'cannot-read-lock-path-identity' 73
  fd_identity=$(stat -Lc '%d:%i' -- /proc/self/fd/9) || die 'cannot-read-lock-fd-identity' 73
  [[ $path_identity == "$fd_identity" ]] || die 'lock-path-changed-while-opening' 73
  flock -n 9 || die 'state-lock-contended' 75
  LOCK_HELD=1
  validate_registered_state
}

release_lock() {
  if ((LOCK_HELD == 1)); then
    flock -u 9 || true
    exec 9>&-
    LOCK_HELD=0
  fi
}

expected_descriptor_for() {
  local root=$1
  printf 'lesson=%s\nversion=%s\nuid=%s\nroot=%s\n' "$LESSON_ID" "$STATE_VERSION" "$LAB_UID" "$root"
}

pending_setup_cleanup() {
  local original_status=$? registered=0 child
  if [[ -n $PENDING_ROOT ]]; then
    if [[ -f $STATE_FILE && ! -L $STATE_FILE ]]; then
      if cmp -s -- "$STATE_FILE" <(expected_descriptor_for "$PENDING_ROOT") 2>/dev/null; then
        registered=1
      fi
    fi
    if ((registered == 0)) && [[ $PENDING_ROOT =~ ^/tmp/reliability-atlas-LES-0021\.[A-Za-z0-9]{8}$ && -d $PENDING_ROOT && ! -L $PENDING_ROOT ]]; then
      if [[ $(stat -c '%u' -- "$PENDING_ROOT" 2>/dev/null || printf invalid) == "$LAB_UID" ]]; then
        for child in record.tmp verification.record recovery.record case.record baseline.record cleanup.marker .lock api_contract_model.py .sentinel; do
          if [[ -f ${PENDING_ROOT}/${child} && ! -L ${PENDING_ROOT}/${child} ]]; then
            rm -- "${PENDING_ROOT}/${child}" 2>/dev/null || true
          fi
        done
        rmdir -- "$PENDING_ROOT" 2>/dev/null || true
      fi
    fi
  fi
  if [[ -n $PENDING_DESCRIPTOR && -f $PENDING_DESCRIPTOR && ! -L $PENDING_DESCRIPTOR ]]; then
    rm -- "$PENDING_DESCRIPTOR" 2>/dev/null || true
  fi
  return "$original_status"
}

trap pending_setup_cleanup EXIT
trap 'exit 130' INT TERM

write_record() {
  local target=$1 content=$2 temporary="${LAB_ROOT}/record.tmp"
  ! path_present "$target" || die "record-already-exists-${target##*/}" 73
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

load_case() {
  local line
  validate_regular_file "${LAB_ROOT}/case.record" 600
  line=$(grep -E '^case=(guided|independent)$' "${LAB_ROOT}/case.record" || true)
  [[ $line == 'case=guided' || $line == 'case=independent' ]] || die 'case-record-invalid' 73
  printf '%s' "${line#case=}"
}

command_check() {
  validate_environment
  if ! path_present "$STATE_FILE"; then
    require_absent_state
    printf 'lesson=%s\nstate=absent\nnetwork=%s\n' "$LESSON_ID" "$NETWORK_POLICY"
    return 0
  fi
  validate_registered_state
  acquire_lock
  printf 'lesson=%s\nstate=registered\nlab_root=%s\nnetwork=%s\n' "$LESSON_ID" "$LAB_ROOT" "$NETWORK_POLICY"
}

command_setup() {
  local root descriptor_candidate
  validate_environment
  if path_present "$STATE_FILE"; then
    validate_registered_state
    acquire_lock
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
  install -m 0500 -- "$MODEL_SOURCE" "${root}/api_contract_model.py"
  : >"${root}/.lock"
  chmod 600 -- "${root}/.lock"
  validate_root_identity
  validate_children

  descriptor_candidate=$(mktemp --tmpdir="$STATE_PARENT" "reliability-atlas-LES-0021-${LAB_UID}.candidate.XXXXXXXX") || die 'cannot-create-descriptor-candidate' 73
  PENDING_DESCRIPTOR=$descriptor_candidate
  expected_descriptor_for "$root" >"$descriptor_candidate"
  chmod 600 -- "$descriptor_candidate"
  validate_regular_file "$descriptor_candidate" 600
  ln -- "$descriptor_candidate" "$STATE_FILE" || die 'cannot-register-state-atomically' 73
  rm -- "$descriptor_candidate"
  PENDING_DESCRIPTOR=''
  PENDING_ROOT=''
  validate_registered_state
  acquire_lock
  printf 'setup=complete\nlab_root=%s\nnetwork=%s\nnext_command=bash lab.sh run baseline\n' "$LAB_ROOT" "$NETWORK_POLICY"
}

command_status() {
  local baseline='pending' active='none' recovery='pending' verification='pending'
  validate_environment
  validate_registered_state
  acquire_lock
  path_present "${LAB_ROOT}/baseline.record" && baseline='complete'
  if path_present "${LAB_ROOT}/case.record"; then active=$(load_case); fi
  path_present "${LAB_ROOT}/recovery.record" && recovery='complete'
  path_present "${LAB_ROOT}/verification.record" && verification='complete'
  printf 'state=ready\nlab_root=%s\nbaseline=%s\nactive_case=%s\nrecovery=%s\nverification=%s\nnetwork=%s\n' \
    "$LAB_ROOT" "$baseline" "$active" "$recovery" "$verification" "$NETWORK_POLICY"
}

command_run() {
  local target=$1 output
  [[ $target == baseline ]] || die 'run-target-must-be-baseline' 64
  validate_environment
  validate_registered_state
  acquire_lock
  ! path_present "${LAB_ROOT}/baseline.record" || die 'baseline-already-recorded' 73
  ! path_present "${LAB_ROOT}/case.record" || die 'cannot-run-baseline-after-case' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" baseline)
  require_field "$output" 'record=baseline'
  require_field "$output" 'parsed_replicas_type=int'
  require_field "$output" 'unicode_service=café-api'
  require_field "$output" 'consumer_readback=valid'
  write_record "${LAB_ROOT}/baseline.record" "$output"
  printf '%s\nnext_command=bash lab.sh inject guided\n' "$output"
}

command_inject() {
  local case_name=$1 output
  [[ $case_name == guided || $case_name == independent ]] || die 'case-must-be-guided-or-independent' 64
  validate_environment
  validate_registered_state
  acquire_lock
  validate_regular_file "${LAB_ROOT}/baseline.record" 600
  ! path_present "${LAB_ROOT}/case.record" || die 'case-already-active' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" case --name "$case_name")
  require_field "$output" 'record=case_registration'
  require_field "$output" "case=${case_name}"
  require_field "$output" 'answer_key=not-provided'
  write_record "${LAB_ROOT}/case.record" "$output"
  printf '%s\n' "$output"
  if [[ $case_name == independent ]]; then
    printf 'next_command=bash lab.sh scenario\n'
  else
    printf 'next_command=bash lab.sh observe request\n'
  fi
}

command_scenario() {
  local case_name output forbidden
  validate_environment
  validate_registered_state
  acquire_lock
  case_name=$(load_case)
  [[ $case_name == independent ]] || die 'scenario-only-available-for-independent-case' 73
  ! path_present "${LAB_ROOT}/recovery.record" || die 'scenario-unavailable-after-recovery' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" scenario)
  require_field "$output" 'record=scenario_input'
  for forbidden in authoritative committed receipt diagnosis recovery answer_key duplicate_effects retry_eligible; do
    if grep -Fiq -- "$forbidden" <<<"$output"; then
      die "scenario-exposed-derived-field-${forbidden}" 70
    fi
  done
  printf '%s\n' "$output"
}

command_observe() {
  local view=$1 case_name output
  case $view in request|contract|operation|page|limit|webhook) ;; *) die 'view-not-allowlisted' 64 ;; esac
  validate_environment
  validate_registered_state
  acquire_lock
  case_name=$(load_case)
  ! path_present "${LAB_ROOT}/recovery.record" || die 'observation-unavailable-after-recovery' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" observe --case "$case_name" --view "$view")
  require_field "$output" 'record=observation'
  require_field "$output" "case=${case_name}"
  require_field "$output" "view=${view}"
  printf '%s\n' "$output"
}

command_recover() {
  local case_name output
  validate_environment
  validate_registered_state
  acquire_lock
  case_name=$(load_case)
  ! path_present "${LAB_ROOT}/recovery.record" || die 'recovery-already-recorded' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" recover --case "$case_name")
  require_field "$output" 'record=recovery'
  require_field "$output" "case=${case_name}"
  require_field "$output" 'operation_success=true'
  write_record "${LAB_ROOT}/recovery.record" "$output"
  printf '%s\nnext_command=bash lab.sh verify-operation\n' "$output"
}

command_verify_operation() {
  local case_name output
  validate_environment
  validate_registered_state
  acquire_lock
  case_name=$(load_case)
  validate_regular_file "${LAB_ROOT}/recovery.record" 600
  ! path_present "${LAB_ROOT}/verification.record" || die 'verification-already-recorded' 73
  output=$(PYTHONDONTWRITEBYTECODE=1 python3 "${LAB_ROOT}/api_contract_model.py" verify --case "$case_name")
  require_field "$output" 'record=verification'
  require_field "$output" 'operation_success=true'
  require_field "$output" 'duplicate_effects=0'
  require_field "$output" 'consumer_readback=valid'
  write_record "${LAB_ROOT}/verification.record" "$output"
  printf '%s\n' "$output"
}

command_cleanup() {
  local root_before name
  validate_environment
  if ! path_present "$STATE_FILE"; then
    require_absent_state
    printf 'cleanup=already-clean\nstate=absent\ncleanup_proven=true\n'
    return 0
  fi
  validate_registered_state
  acquire_lock
  root_before=$LAB_ROOT
  ! path_present "${LAB_ROOT}/cleanup.marker" || die 'cleanup-marker-already-exists' 73
  printf 'lesson=%s\nuid=%s\nroot=%s\n' "$LESSON_ID" "$LAB_UID" "$LAB_ROOT" >"${LAB_ROOT}/cleanup.marker"
  chmod 600 -- "${LAB_ROOT}/cleanup.marker"
  validate_children
  for name in verification.record recovery.record case.record baseline.record record.tmp; do
    if path_present "${LAB_ROOT}/${name}"; then
      validate_regular_file "${LAB_ROOT}/${name}" 600
      rm -- "${LAB_ROOT}/${name}"
    fi
  done
  validate_regular_file "${LAB_ROOT}/api_contract_model.py" 500
  rm -- "${LAB_ROOT}/api_contract_model.py"
  validate_regular_file "${LAB_ROOT}/.sentinel" 400
  rm -- "${LAB_ROOT}/.sentinel"
  validate_regular_file "${LAB_ROOT}/cleanup.marker" 600
  rm -- "${LAB_ROOT}/cleanup.marker"
  release_lock
  validate_regular_file "${LAB_ROOT}/.lock" 600
  rm -- "${LAB_ROOT}/.lock"
  rmdir -- "$LAB_ROOT" || die 'lab-root-not-empty-refusing-broader-cleanup' 73
  validate_regular_file "$STATE_FILE" 600
  cmp -s -- "$STATE_FILE" <(expected_descriptor_for "$root_before") || die 'state-descriptor-changed-before-removal' 73
  rm -- "$STATE_FILE"
  ! path_present "$root_before" || die 'lab-root-still-present-after-cleanup' 73
  ! path_present "$STATE_FILE" || die 'state-descriptor-still-present-after-cleanup' 73
  [[ -z $(orphan_candidate) ]] || die 'orphan-remains-after-cleanup' 73
  printf 'cleanup=complete\nstate=absent\ncleanup_proven=true\n'
}

main() {
  local command=${1:-}
  case $command in
    check|setup|status|scenario|recover|verify-operation|cleanup)
      (($# == 1)) || { usage; exit 64; }
      "command_${command//-/_}"
      ;;
    run|inject|observe)
      (($# == 2)) || { usage; exit 64; }
      "command_${command}" "$2"
      ;;
    *) usage; exit 64 ;;
  esac
}

main "$@"
