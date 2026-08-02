#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0009"
readonly LAB_VERSION="1"
LAB_UID="$(id -u)"
readonly LAB_UID
readonly LAB_PREFIX="devops-sre-LES-0009-safe-local-workbench."
readonly STATE_FILE="/tmp/devops-sre-LES-0009-safe-local-workbench-$LAB_UID.state"
readonly SENTINEL_NAME=".les-0009-sentinel"
readonly WORKBENCH_NAME="workbench"
readonly BASELINE_NAME="baseline.record"
readonly CASE_NAME="case.record"
readonly RECOVERY_NAME="recovery.record"
readonly VERIFICATION_NAME="verification.record"
readonly MAX_ENTRIES=300
readonly MAX_FILE_BYTES=1048576
readonly MAX_TOTAL_BYTES=5242880

LAB_ROOT=""
WORKBENCH_PATH=""
BASELINE_OID=""
ACTIVE_CASE=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

expected_sentinel() {
  printf 'lesson_id=%s\nlab_version=%s\nowner_uid=%s' \
    "$LESSON_ID" "$LAB_VERSION" "$LAB_UID"
}

expected_gitignore() {
  printf '%s\n' '.env.local' '*.log' '*.cache' 'build/'
}

expected_readme() {
  printf '%s\n' \
    '# Local workbench fixture' \
    '' \
    'This synthetic repository exists only inside the bounded LES-0009 lab.'
}

expected_service_baseline() {
  printf '%s\n' \
    'mode=baseline' \
    'timeout_seconds=30' \
    'retries=2'
}

expected_service_guided_index() {
  printf '%s\n' \
    'mode=guided-index' \
    'timeout_seconds=10' \
    'retries=2'
}

expected_service_guided_worktree() {
  printf '%s\n' \
    'mode=guided-worktree' \
    'timeout_seconds=5' \
    'retries=0'
}

expected_service_transfer_index() {
  printf '%s\n' \
    'mode=transfer-index' \
    'timeout_seconds=45' \
    'retries=4'
}

expected_service_transfer_worktree() {
  printf '%s\n' \
    'mode=transfer-worktree' \
    'timeout_seconds=45' \
    'retries=1'
}

expected_example() {
  printf '%s\n' \
    'API_ENDPOINT=https://example.invalid' \
    'CREDENTIAL_SOURCE=runtime-injection-required'
}

expected_baseline_record() {
  printf 'record_version=1\nlesson_id=%s\nhead_oid=%s\nbranch=main\nworktree_clean=true\nremote_count=0' \
    "$LESSON_ID" "$BASELINE_OID"
}

expected_case_record() {
  printf 'record_version=1\nlesson_id=%s\ncase=%s\nhead_oid=%s' \
    "$LESSON_ID" "$ACTIVE_CASE" "$BASELINE_OID"
}

expected_recovery_record() {
  printf 'record_version=1\nlesson_id=%s\ncase=%s\nhead_oid=%s\nrecovery=selective' \
    "$LESSON_ID" "$ACTIVE_CASE" "$BASELINE_OID"
}

expected_verification_record() {
  printf 'record_version=1\nlesson_id=%s\ncase=%s\nhead_oid=%s\noperation=local_snapshot_integrity\nverified=true' \
    "$LESSON_ID" "$ACTIVE_CASE" "$BASELINE_OID"
}

state_file_present() {
  [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]
}

require_environment() {
  local tool tmp_owner tmp_mode tmp_real

  if [[ "$LAB_UID" -eq 0 ]]; then
    fail "run this lab from a normal non-root Ubuntu shell"
    return 1
  fi
  if [[ ! -f /etc/os-release ]] \
    || ! grep -Fxq 'ID=ubuntu' /etc/os-release \
    || ! grep -Eq '^VERSION_ID="?24[.]04"?$' /etc/os-release; then
    fail "Ubuntu 24.04 LTS is required"
    return 1
  fi
  for tool in bash basename cat chmod cmp dirname find git grep id \
    mkdir mktemp readlink realpath rm rmdir stat wc; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      fail "required command is missing: $tool"
      return 1
    fi
  done
  if [[ ! -d /tmp || -L /tmp ]]; then
    fail "/tmp must be a real directory, not a symbolic link"
    return 1
  fi
  tmp_real="$(realpath -e -- /tmp)"
  tmp_owner="$(stat -c '%u' -- /tmp)"
  tmp_mode="$(stat -c '%a' -- /tmp)"
  if [[ "$tmp_real" != "/tmp" || "$tmp_owner" != "0" || "$tmp_mode" != "1777" ]]; then
    fail "/tmp must resolve to /tmp and be root-owned mode 1777"
    return 1
  fi
}

require_regular_owned_file() {
  local path="$1" expected_mode="$2" label="$3"

  if [[ ! -f "$path" || -L "$path" ]]; then
    fail "$label must be a regular non-symlink file"
    return 1
  fi
  if [[ "$(stat -c '%u' -- "$path")" != "$LAB_UID" \
    || "$(stat -c '%a' -- "$path")" != "$expected_mode" \
    || "$(stat -c '%h' -- "$path")" != "1" ]]; then
    fail "$label owner, mode, or link count changed"
    return 1
  fi
}

validate_root_path() {
  local candidate="$1" resolved owner mode

  if [[ ! "$candidate" =~ ^/tmp/devops-sre-LES-0009-safe-local-workbench[.][[:alnum:]]{8}$ ]]; then
    fail "recorded lab root is outside the exact lesson prefix"
    return 1
  fi
  if [[ ! -d "$candidate" || -L "$candidate" ]]; then
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
  validate_root_path "$LAB_ROOT"
  require_regular_owned_file \
    "$LAB_ROOT/$SENTINEL_NAME" "600" "lesson sentinel"
  if ! cmp -s -- "$LAB_ROOT/$SENTINEL_NAME" <(expected_sentinel); then
    fail "lesson sentinel content changed"
    return 1
  fi
  WORKBENCH_PATH="$LAB_ROOT/$WORKBENCH_NAME"
  if [[ ! -d "$WORKBENCH_PATH" || -L "$WORKBENCH_PATH" \
    || "$(realpath -e -- "$WORKBENCH_PATH")" != "$WORKBENCH_PATH" \
    || "$(stat -c '%u' -- "$WORKBENCH_PATH")" != "$LAB_UID" \
    || "$(stat -c '%a' -- "$WORKBENCH_PATH")" != "700" ]]; then
    fail "workbench directory identity changed"
    return 1
  fi
}

load_state() {
  local -a lines=()

  if ! state_file_present; then
    fail "lab state is absent; run: bash lab.sh setup"
    return 1
  fi
  require_regular_owned_file "$STATE_FILE" "600" "state descriptor"
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
  validate_root_identity
}

direct_name_allowed() {
  case "$1" in
    "$SENTINEL_NAME"|"$WORKBENCH_NAME"|"$BASELINE_NAME"|"$CASE_NAME"|\
    "$RECOVERY_NAME"|"$VERIFICATION_NAME")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_tree_safety() {
  local root_device entry_count=0 total_bytes=0 item name owner device links size

  validate_root_identity
  root_device="$(stat -c '%d' -- "$LAB_ROOT")"

  while IFS= read -r -d '' item; do
    name="$(basename -- "$item")"
    if ! direct_name_allowed "$name"; then
      fail "unexpected top-level artifact blocks safe operation: $name"
      return 1
    fi
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)

  while IFS= read -r -d '' item; do
    entry_count=$((entry_count + 1))
    if (( entry_count > MAX_ENTRIES )); then
      fail "lab tree exceeds the bounded entry count"
      return 1
    fi
    if [[ -L "$item" ]]; then
      fail "symbolic links are forbidden inside the lab root"
      return 1
    fi
    owner="$(stat -c '%u' -- "$item")"
    device="$(stat -c '%d' -- "$item")"
    if [[ "$owner" != "$LAB_UID" ]]; then
      fail "foreign-owned item blocks safe operation"
      return 1
    fi
    if [[ "$device" != "$root_device" ]]; then
      fail "cross-device item blocks safe operation"
      return 1
    fi
    if [[ -f "$item" ]]; then
      links="$(stat -c '%h' -- "$item")"
      size="$(stat -c '%s' -- "$item")"
      if [[ "$links" != "1" ]]; then
        fail "hard-linked regular file blocks safe operation"
        return 1
      fi
      if (( size > MAX_FILE_BYTES )); then
        fail "oversized file blocks safe operation"
        return 1
      fi
      total_bytes=$((total_bytes + size))
      if (( total_bytes > MAX_TOTAL_BYTES )); then
        fail "lab tree exceeds the bounded total byte count"
        return 1
      fi
    elif [[ ! -d "$item" ]]; then
      fail "special file blocks safe operation"
      return 1
    fi
  done < <(find -P "$LAB_ROOT" -xdev -mindepth 1 -print0)
}

scan_candidates() {
  local allowed="$1" item resolved

  while IFS= read -r -d '' item; do
    if [[ -n "$allowed" && "$item" == "$allowed" ]]; then
      continue
    fi
    if [[ -L "$item" ]]; then
      fail "unregistered lesson root candidate is a symlink"
      return 1
    fi
    resolved="$(realpath -e -- "$item")"
    if [[ "$resolved" != "$item" ]]; then
      fail "unregistered lesson root candidate is noncanonical"
      return 1
    fi
    fail "unregistered lesson root candidate exists: $item"
    return 1
  done < <(find -P /tmp -mindepth 1 -maxdepth 1 \
    -name "$LAB_PREFIX*" -print0)
}

git_local() {
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    command git -c core.hooksPath=/dev/null -c commit.gpgSign=false \
    -C "$WORKBENCH_PATH" "$@"
}

load_baseline_record() {
  local path="$LAB_ROOT/$BASELINE_NAME" actual

  require_regular_owned_file "$path" "600" "baseline record"
  BASELINE_OID="$(git_local rev-parse HEAD)"
  actual="$(cat -- "$path")"
  if [[ "$actual" != "$(expected_baseline_record)" ]]; then
    fail "baseline record content changed"
    return 1
  fi
}

load_case_record() {
  local path="$LAB_ROOT/$CASE_NAME"
  local -a lines=()

  require_regular_owned_file "$path" "600" "case record"
  mapfile -t lines < "$path"
  if [[ "${#lines[@]}" -ne 4 \
    || "${lines[0]}" != "record_version=1" \
    || "${lines[1]}" != "lesson_id=$LESSON_ID" \
    || "${lines[2]}" != case=* \
    || "${lines[3]}" != "head_oid=$BASELINE_OID" ]]; then
    fail "case record content is invalid"
    return 1
  fi
  ACTIVE_CASE="${lines[2]#case=}"
  case "$ACTIVE_CASE" in
    guided|transfer) ;;
    *)
      fail "case record selects an unsupported case"
      return 1
      ;;
  esac
  if [[ "$(cat -- "$path")" != "$(expected_case_record)" ]]; then
    fail "case record content changed"
    return 1
  fi
}

validate_head_snapshot() {
  local branch head_count remote_output top

  if [[ "$(git_local rev-parse --is-inside-work-tree)" != "true" ]]; then
    fail "workbench is not a Git working tree"
    return 1
  fi
  top="$(git_local rev-parse --show-toplevel)"
  if [[ "$top" != "$WORKBENCH_PATH" ]]; then
    fail "Git top-level path escaped the workbench"
    return 1
  fi
  branch="$(git_local branch --show-current)"
  if [[ "$branch" != "main" ]]; then
    fail "workbench branch changed"
    return 1
  fi
  head_count="$(git_local rev-list --count HEAD)"
  if [[ "$head_count" != "1" ]]; then
    fail "workbench history changed"
    return 1
  fi
  remote_output="$(git_local remote)"
  if [[ -n "$remote_output" ]]; then
    fail "workbench remote boundary changed"
    return 1
  fi
  if ! git_local show HEAD:.gitignore | cmp -s - <(expected_gitignore) \
    || ! git_local show HEAD:README.md | cmp -s - <(expected_readme) \
    || ! git_local show HEAD:service.conf | cmp -s - <(expected_service_baseline) \
    || ! git_local show HEAD:app.env.example | cmp -s - <(expected_example); then
    fail "HEAD snapshot content changed"
    return 1
  fi
  BASELINE_OID="$(git_local rev-parse HEAD)"
}

expected_case_status() {
  case "$ACTIVE_CASE" in
    guided)
      printf '%s\n' \
        'MM service.conf' \
        '?? notes.txt' \
        '!! .env.local' \
        '!! scratch.log'
      ;;
    transfer)
      printf '%s\n' \
        'MM service.conf' \
        '?? handoff.md' \
        '!! .env.local' \
        '!! transfer.cache'
      ;;
  esac
}

validate_case_files() {
  local status_output

  status_output="$(git_local status --porcelain=v1 \
    --untracked-files=all --ignored=matching)"
  if [[ -e "$LAB_ROOT/$RECOVERY_NAME" || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    if [[ -n "$status_output" ]]; then
      fail "recovered workbench is not clean"
      return 1
    fi
    if ! cmp -s -- "$WORKBENCH_PATH/service.conf" \
      <(expected_service_baseline); then
      fail "recovered service.conf differs from baseline"
      return 1
    fi
    case "$ACTIVE_CASE" in
      guided)
        for item in notes.txt .env.local scratch.log; do
          if [[ -e "$WORKBENCH_PATH/$item" || -L "$WORKBENCH_PATH/$item" ]]; then
            fail "guided temporary path remains after recovery: $item"
            return 1
          fi
        done
        ;;
      transfer)
        for item in handoff.md .env.local transfer.cache; do
          if [[ -e "$WORKBENCH_PATH/$item" || -L "$WORKBENCH_PATH/$item" ]]; then
            fail "transfer temporary path remains after recovery: $item"
            return 1
          fi
        done
        ;;
    esac
  else
    if [[ "$status_output" != "$(expected_case_status)" ]]; then
      fail "active case Git status differs from its deterministic contract"
      return 1
    fi
    case "$ACTIVE_CASE" in
      guided)
        if ! git_local show :service.conf | cmp -s - \
          <(expected_service_guided_index) \
          || ! cmp -s -- "$WORKBENCH_PATH/service.conf" \
          <(expected_service_guided_worktree); then
          fail "guided case content changed"
          return 1
        fi
        ;;
      transfer)
        if ! git_local show :service.conf | cmp -s - \
          <(expected_service_transfer_index) \
          || ! cmp -s -- "$WORKBENCH_PATH/service.conf" \
          <(expected_service_transfer_worktree); then
          fail "transfer case content changed"
          return 1
        fi
        ;;
    esac
  fi
}

validate_lifecycle_records() {
  local path

  validate_head_snapshot
  path="$LAB_ROOT/$BASELINE_NAME"
  if [[ -e "$path" || -L "$path" ]]; then
    load_baseline_record
  else
    if [[ -e "$LAB_ROOT/$CASE_NAME" || -L "$LAB_ROOT/$CASE_NAME" \
      || -e "$LAB_ROOT/$RECOVERY_NAME" || -L "$LAB_ROOT/$RECOVERY_NAME" \
      || -e "$LAB_ROOT/$VERIFICATION_NAME" \
      || -L "$LAB_ROOT/$VERIFICATION_NAME" ]]; then
      fail "later lifecycle record exists without a baseline"
      return 1
    fi
    if [[ -n "$(git_local status --porcelain=v1 \
      --untracked-files=all --ignored=matching)" ]]; then
      fail "pre-baseline workbench is not clean"
      return 1
    fi
    return 0
  fi

  path="$LAB_ROOT/$CASE_NAME"
  if [[ -e "$path" || -L "$path" ]]; then
    load_case_record
    validate_case_files
  else
    if [[ -e "$LAB_ROOT/$RECOVERY_NAME" || -L "$LAB_ROOT/$RECOVERY_NAME" \
      || -e "$LAB_ROOT/$VERIFICATION_NAME" \
      || -L "$LAB_ROOT/$VERIFICATION_NAME" ]]; then
      fail "later lifecycle record exists without an active case"
      return 1
    fi
    if [[ -n "$(git_local status --porcelain=v1 \
      --untracked-files=all --ignored=matching)" ]]; then
      fail "baseline workbench is not clean"
      return 1
    fi
    return 0
  fi

  path="$LAB_ROOT/$RECOVERY_NAME"
  if [[ -e "$path" || -L "$path" ]]; then
    require_regular_owned_file "$path" "600" "recovery record"
    if [[ "$(cat -- "$path")" != "$(expected_recovery_record)" ]]; then
      fail "recovery record content changed"
      return 1
    fi
  elif [[ -e "$LAB_ROOT/$VERIFICATION_NAME" \
    || -L "$LAB_ROOT/$VERIFICATION_NAME" ]]; then
    fail "verification exists without recovery"
    return 1
  fi

  path="$LAB_ROOT/$VERIFICATION_NAME"
  if [[ -e "$path" || -L "$path" ]]; then
    require_regular_owned_file "$path" "600" "verification record"
    if [[ "$(cat -- "$path")" != "$(expected_verification_record)" ]]; then
      fail "verification record content changed"
      return 1
    fi
  fi
}

validate_strict_state() {
  validate_tree_safety
  validate_lifecycle_records
}

write_private_file() {
  local path="$1"
  shift
  set -o noclobber
  if ! "$@" > "$path"; then
    set +o noclobber
    fail "could not create expected artifact: $(basename -- "$path")"
    return 1
  fi
  set +o noclobber
  chmod 600 -- "$path"
}

command_check() {
  require_environment
  if state_file_present; then
    load_state
    scan_candidates "$LAB_ROOT"
    validate_strict_state
    printf 'environment=ready\n'
    printf 'state=present\n'
    printf 'lesson_id=%s\n' "$LESSON_ID"
    printf 'network=disabled\n'
    printf 'privilege=normal-user\n'
  else
    scan_candidates ""
    printf 'environment=ready\n'
    printf 'state=absent\n'
    printf 'lesson_id=%s\n' "$LESSON_ID"
    printf 'network=disabled\n'
    printf 'privilege=normal-user\n'
  fi
}

command_setup() {
  local created_root

  require_environment
  if state_file_present; then
    load_state
    scan_candidates "$LAB_ROOT"
    validate_strict_state
    printf 'setup=already-present\n'
    printf 'state=ready\n'
    printf 'lab_root=%s\n' "$LAB_ROOT"
    return 0
  fi
  scan_candidates ""
  created_root="$(mktemp -d --tmpdir=/tmp "${LAB_PREFIX}XXXXXXXX")"
  chmod 700 -- "$created_root"
  LAB_ROOT="$created_root"
  WORKBENCH_PATH="$LAB_ROOT/$WORKBENCH_NAME"
  mkdir -- "$WORKBENCH_PATH"
  chmod 700 -- "$WORKBENCH_PATH"
  expected_sentinel > "$LAB_ROOT/$SENTINEL_NAME"
  chmod 600 -- "$LAB_ROOT/$SENTINEL_NAME"
  set -o noclobber
  printf 'state_version=1\nlesson_id=%s\nowner_uid=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_UID" "$LAB_ROOT" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"

  git_local init -q -b main
  git_local config user.name "Training Operator"
  git_local config user.email "training@example.invalid"
  git_local config core.autocrlf false
  git_local config core.safecrlf true
  expected_gitignore > "$WORKBENCH_PATH/.gitignore"
  expected_readme > "$WORKBENCH_PATH/README.md"
  expected_service_baseline > "$WORKBENCH_PATH/service.conf"
  expected_example > "$WORKBENCH_PATH/app.env.example"
  git_local add -- .gitignore README.md service.conf app.env.example
  GIT_AUTHOR_DATE='2000-01-01T00:00:00+0000' \
    GIT_COMMITTER_DATE='2000-01-01T00:00:00+0000' \
    git_local commit -q -m "baseline: safe local workbench"

  validate_strict_state
  printf 'setup=complete\n'
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'network=disabled\n'
  printf 'next_command=bash lab.sh run baseline\n'
}

command_run() {
  local mode="$1" path

  if [[ "$mode" != "baseline" ]]; then
    fail "run mode must be baseline"
    return 1
  fi
  require_environment
  load_state
  validate_strict_state
  path="$LAB_ROOT/$BASELINE_NAME"
  if [[ -e "$path" || -L "$path" ]]; then
    fail "baseline was already recorded; use guarded reset for a new attempt"
    return 1
  fi
  BASELINE_OID="$(git_local rev-parse HEAD)"
  set -o noclobber
  expected_baseline_record > "$path"
  set +o noclobber
  chmod 600 -- "$path"
  validate_strict_state
  printf 'record=baseline\n'
  printf 'head_oid=%s\n' "$BASELINE_OID"
  printf 'branch=main\n'
  printf 'worktree_clean=true\n'
  printf 'remote_count=0\n'
}

create_case_files() {
  case "$ACTIVE_CASE" in
    guided)
      expected_service_guided_index > "$WORKBENCH_PATH/service.conf"
      git_local add -- service.conf
      expected_service_guided_worktree > "$WORKBENCH_PATH/service.conf"
      printf '%s\n' 'training-note=classify-before-removal' \
        > "$WORKBENCH_PATH/notes.txt"
      printf '%s\n' 'TRAINING_VALUE=nonsecret-placeholder' \
        > "$WORKBENCH_PATH/.env.local"
      printf '%s\n' 'synthetic_log=local-only' \
        > "$WORKBENCH_PATH/scratch.log"
      ;;
    transfer)
      expected_service_transfer_index > "$WORKBENCH_PATH/service.conf"
      git_local add -- service.conf
      expected_service_transfer_worktree > "$WORKBENCH_PATH/service.conf"
      printf '%s\n' 'handoff=classify-ownership-before-action' \
        > "$WORKBENCH_PATH/handoff.md"
      printf '%s\n' 'TRAINING_VALUE=nonsecret-placeholder' \
        > "$WORKBENCH_PATH/.env.local"
      printf '%s\n' 'cache=synthetic-local-only' \
        > "$WORKBENCH_PATH/transfer.cache"
      ;;
  esac
  chmod 600 -- "$WORKBENCH_PATH/service.conf"
  case "$ACTIVE_CASE" in
    guided)
      chmod 600 -- "$WORKBENCH_PATH/notes.txt" \
        "$WORKBENCH_PATH/.env.local" "$WORKBENCH_PATH/scratch.log"
      ;;
    transfer)
      chmod 600 -- "$WORKBENCH_PATH/handoff.md" \
        "$WORKBENCH_PATH/.env.local" "$WORKBENCH_PATH/transfer.cache"
      ;;
  esac
}

command_inject() {
  local selected="$1" path

  case "$selected" in
    guided|transfer) ;;
    *)
      fail "case must be guided or transfer"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_strict_state
  if [[ ! -e "$LAB_ROOT/$BASELINE_NAME" \
    || -L "$LAB_ROOT/$BASELINE_NAME" ]]; then
    fail "record the baseline before injecting a case"
    return 1
  fi
  if [[ -e "$LAB_ROOT/$CASE_NAME" || -L "$LAB_ROOT/$CASE_NAME" ]]; then
    fail "a case is already active; use guarded reset for a new attempt"
    return 1
  fi
  load_baseline_record
  ACTIVE_CASE="$selected"
  create_case_files
  path="$LAB_ROOT/$CASE_NAME"
  set -o noclobber
  expected_case_record > "$path"
  set +o noclobber
  chmod 600 -- "$path"
  validate_strict_state
  printf 'injection=complete\n'
  printf 'case=%s\n' "$ACTIVE_CASE"
  printf 'scope=local-disposable-repository-only\n'
  printf 'network=disabled\n'
}

command_observe() {
  local view="$1"

  case "$view" in
    status|worktree|staged|ignored|history) ;;
    *)
      fail "view must be status, worktree, staged, ignored, or history"
      return 1
      ;;
  esac
  require_environment
  load_state
  validate_strict_state
  if [[ ! -e "$LAB_ROOT/$CASE_NAME" \
    || -L "$LAB_ROOT/$CASE_NAME" ]]; then
    fail "an active case is required"
    return 1
  fi
  load_baseline_record
  load_case_record
  printf 'record=observation\n'
  printf 'case=%s\n' "$ACTIVE_CASE"
  printf 'view=%s\n' "$view"
  case "$view" in
    status)
      git_local status --porcelain=v1 --branch \
        --untracked-files=all --ignored=matching
      ;;
    worktree)
      git_local diff --no-ext-diff -- service.conf
      ;;
    staged)
      git_local diff --cached --no-ext-diff -- service.conf
      ;;
    ignored)
      git_local status --porcelain=v1 --untracked-files=all \
        --ignored=matching | grep '^!! '
      git_local check-ignore -v -- .env.local
      case "$ACTIVE_CASE" in
        guided) git_local check-ignore -v -- scratch.log ;;
        transfer) git_local check-ignore -v -- transfer.cache ;;
      esac
      ;;
    history)
      printf 'head_oid=%s\n' "$(git_local rev-parse HEAD)"
      printf 'head_type=%s\n' "$(git_local cat-file -t HEAD)"
      printf 'tree_type=%s\n' "$(git_local cat-file -t 'HEAD^{tree}')"
      printf 'branch=%s\n' "$(git_local branch --show-current)"
      printf 'remote_count=%s\n' "$(git_local remote | wc -l)"
      printf 'subject=%s\n' "$(git_local log -1 --format='%s')"
      ;;
  esac
}

remove_exact_fixture_file() {
  local name="$1" path="$WORKBENCH_PATH/$1"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    fail "expected fixture file is absent: $name"
    return 1
  fi
  if [[ ! -f "$path" || -L "$path" \
    || "$(stat -c '%u' -- "$path")" != "$LAB_UID" \
    || "$(stat -c '%h' -- "$path")" != "1" \
    || "$(stat -c '%s' -- "$path")" -gt "$MAX_FILE_BYTES" ]]; then
    fail "expected fixture file changed identity: $name"
    return 1
  fi
  rm -- "$path"
}

command_recover() {
  local path

  require_environment
  load_state
  validate_strict_state
  if [[ ! -e "$LAB_ROOT/$CASE_NAME" \
    || -L "$LAB_ROOT/$CASE_NAME" ]]; then
    fail "an active case is required"
    return 1
  fi
  if [[ -e "$LAB_ROOT/$RECOVERY_NAME" \
    || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "recovery was already recorded"
    return 1
  fi
  load_baseline_record
  load_case_record
  git_local restore --staged -- service.conf
  git_local restore --worktree -- service.conf
  case "$ACTIVE_CASE" in
    guided)
      remove_exact_fixture_file notes.txt
      remove_exact_fixture_file .env.local
      remove_exact_fixture_file scratch.log
      ;;
    transfer)
      remove_exact_fixture_file handoff.md
      remove_exact_fixture_file .env.local
      remove_exact_fixture_file transfer.cache
      ;;
  esac
  path="$LAB_ROOT/$RECOVERY_NAME"
  set -o noclobber
  expected_recovery_record > "$path"
  set +o noclobber
  chmod 600 -- "$path"
  validate_strict_state
  printf 'record=recovery\n'
  printf 'case=%s\n' "$ACTIVE_CASE"
  printf 'method=selective-restore\n'
  printf 'head_unchanged=true\n'
  printf 'worktree_clean=true\n'
}

command_verify_operation() {
  local path

  require_environment
  load_state
  validate_strict_state
  if [[ ! -e "$LAB_ROOT/$RECOVERY_NAME" \
    || -L "$LAB_ROOT/$RECOVERY_NAME" ]]; then
    fail "successful supported recovery is required before verification"
    return 1
  fi
  if [[ -e "$LAB_ROOT/$VERIFICATION_NAME" \
    || -L "$LAB_ROOT/$VERIFICATION_NAME" ]]; then
    fail "operation verification was already recorded"
    return 1
  fi
  load_baseline_record
  load_case_record
  validate_case_files
  path="$LAB_ROOT/$VERIFICATION_NAME"
  set -o noclobber
  expected_verification_record > "$path"
  set +o noclobber
  chmod 600 -- "$path"
  validate_strict_state
  printf 'record=verification\n'
  printf 'operation=local_snapshot_integrity\n'
  printf 'branch=main\n'
  printf 'head_oid=%s\n' "$BASELINE_OID"
  printf 'tracked_baseline_match=true\n'
  printf 'worktree_clean=true\n'
  printf 'remote_count=0\n'
  printf 'temporary_fixture_state_absent=true\n'
  printf 'recovery_verified=true\n'
}

command_status() {
  local baseline="pending" active="none" recovery="pending" verification="pending"

  require_environment
  load_state
  scan_candidates "$LAB_ROOT"
  validate_strict_state
  if [[ -e "$LAB_ROOT/$BASELINE_NAME" ]]; then baseline="recorded"; fi
  if [[ -e "$LAB_ROOT/$CASE_NAME" ]]; then
    load_baseline_record
    load_case_record
    active="$ACTIVE_CASE"
  fi
  if [[ -e "$LAB_ROOT/$RECOVERY_NAME" ]]; then recovery="complete"; fi
  if [[ -e "$LAB_ROOT/$VERIFICATION_NAME" ]]; then verification="complete"; fi
  printf 'lesson_id=%s\n' "$LESSON_ID"
  printf 'state=ready\n'
  printf 'lab_root=%s\n' "$LAB_ROOT"
  printf 'baseline=%s\n' "$baseline"
  printf 'active_case=%s\n' "$active"
  printf 'recovery=%s\n' "$recovery"
  printf 'operation_verification=%s\n' "$verification"
  printf 'network=disabled\n'
  printf 'remote_count=%s\n' "$(git_local remote | wc -l)"
}

command_cleanup() {
  local root_to_remove

  require_environment
  if ! state_file_present; then
    scan_candidates ""
    printf 'cleanup=already-clean\n'
    printf 'state=absent\n'
    printf 'cleanup_proof_scope=descriptor-and-owned-candidates-at-check\n'
    printf 'cleanup_proven=true\n'
    return 0
  fi
  load_state
  scan_candidates "$LAB_ROOT"
  validate_tree_safety
  root_to_remove="$LAB_ROOT"

  find -P "$root_to_remove" -xdev -depth -mindepth 1 \
    '(' -type f -o -type d ')' -delete
  if [[ -e "$root_to_remove" || -L "$root_to_remove" ]]; then
    if [[ -d "$root_to_remove" && ! -L "$root_to_remove" ]]; then
      rmdir -- "$root_to_remove"
    else
      fail "lab root changed during cleanup; descriptor retained"
      return 1
    fi
  fi
  if [[ -e "$root_to_remove" || -L "$root_to_remove" ]]; then
    fail "lab root remains after exact cleanup; descriptor retained"
    return 1
  fi
  rm -- "$STATE_FILE"
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    fail "state descriptor remains after cleanup"
    return 1
  fi
  scan_candidates ""
  printf 'cleanup=complete\n'
  printf 'state=absent\n'
  printf 'cleanup_proof_scope=descriptor-and-owned-candidates-at-check\n'
  printf 'cleanup_proven=true\n'
}

command_reset() {
  command_cleanup >/dev/null
  command_setup
  printf 'reset=complete\n'
}

usage() {
  printf '%s\n' \
    'usage: bash lab.sh check' \
    '       bash lab.sh setup' \
    '       bash lab.sh run baseline' \
    '       bash lab.sh inject guided|transfer' \
    '       bash lab.sh observe status|worktree|staged|ignored|history' \
    '       bash lab.sh recover' \
    '       bash lab.sh verify-operation' \
    '       bash lab.sh status' \
    '       bash lab.sh reset' \
    '       bash lab.sh cleanup'
}

main() {
  local command="${1:-}"

  case "$command" in
    check)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_check
      ;;
    setup)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_setup
      ;;
    run)
      [[ "$#" -eq 2 ]] || { usage >&2; return 2; }
      command_run "$2"
      ;;
    inject)
      [[ "$#" -eq 2 ]] || { usage >&2; return 2; }
      command_inject "$2"
      ;;
    observe)
      [[ "$#" -eq 2 ]] || { usage >&2; return 2; }
      command_observe "$2"
      ;;
    recover)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_recover
      ;;
    verify-operation)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_verify_operation
      ;;
    status)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_status
      ;;
    reset)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_reset
      ;;
    cleanup)
      [[ "$#" -eq 1 ]] || { usage >&2; return 2; }
      command_cleanup
      ;;
    *)
      usage >&2
      return 2
      ;;
  esac
}

main "$@"
