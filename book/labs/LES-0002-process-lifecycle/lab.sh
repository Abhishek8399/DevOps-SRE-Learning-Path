#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

readonly LESSON_ID="LES-0002"
readonly LAB_UID="$(id -u)"
readonly PREFIX="devops-sre-LES-0002-process-lifecycle."
readonly STATE_FILE="/tmp/devops-sre-LES-0002-process-lifecycle-$LAB_UID.state"
readonly SENTINEL=".les-0002-sentinel"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly TARGET_SCRIPT="$SCRIPT_DIR/fixtures/signal-target.sh"
LAB_ROOT=""
LAB_TOKEN=""
LAB_PID=""
LAB_START=""

fail() {
  printf 'lab_error=%s\n' "$1" >&2
  return 1
}

require_environment() {
  local tool
  [[ "$LAB_UID" -ne 0 ]] || { fail "run as a normal non-root Ubuntu user"; return 1; }
  [[ -f /etc/os-release ]] \
    && grep -Fxq 'ID=ubuntu' /etc/os-release \
    && grep -Eq '^VERSION_ID="?24[.]04"?$' /etc/os-release \
    || { fail "Ubuntu 24.04 LTS is required"; return 1; }
  for tool in bash chmod cmp find grep id kill mkdir mktemp ps readlink realpath \
    rm rmdir sed sleep stat tr wc; do
    command -v "$tool" >/dev/null 2>&1 \
      || { fail "required command is missing: $tool"; return 1; }
  done
  [[ -f "$TARGET_SCRIPT" && ! -L "$TARGET_SCRIPT" ]] \
    || { fail "fixture script is missing or is a symbolic link"; return 1; }
}

candidate_count() {
  find -P /tmp -mindepth 1 -maxdepth 1 -name "$PREFIX*" -printf . | wc -c
}

validate_root() {
  local resolved owner mode item name
  [[ "$LAB_ROOT" =~ ^/tmp/devops-sre-LES-0002-process-lifecycle[.][[:alnum:]]{8}$ ]] \
    || { fail "recorded lab root is outside the lesson prefix"; return 1; }
  [[ -d "$LAB_ROOT" && ! -L "$LAB_ROOT" ]] \
    || { fail "lab root is missing, not a directory, or a symbolic link"; return 1; }
  resolved="$(realpath -e -- "$LAB_ROOT")"
  owner="$(stat -c '%u' -- "$LAB_ROOT")"
  mode="$(stat -c '%a' -- "$LAB_ROOT")"
  [[ "$resolved" == "$LAB_ROOT" && "$owner" == "$LAB_UID" && "$mode" == "700" ]] \
    || { fail "lab root path, owner, or mode changed"; return 1; }
  [[ -f "$LAB_ROOT/$SENTINEL" && ! -L "$LAB_ROOT/$SENTINEL" ]] \
    || { fail "lesson sentinel is missing or unsafe"; return 1; }
  cmp -s -- "$LAB_ROOT/$SENTINEL" <(
    printf 'lesson_id=%s\nowner_uid=%s\n' "$LESSON_ID" "$LAB_UID"
  ) || { fail "lesson sentinel content changed"; return 1; }
  while IFS= read -r -d '' item; do
    name="$(basename -- "$item")"
    case "$name" in
      "$SENTINEL"|events.log|process.record|termination.record) ;;
      *) fail "unexpected lesson artifact blocks cleanup: $name"; return 1 ;;
    esac
    [[ ! -L "$item" && -f "$item" && "$(stat -c '%u' -- "$item")" == "$LAB_UID" \
      && "$(stat -c '%h' -- "$item")" == "1" ]] \
      || { fail "lesson artifact type, owner, or link count changed: $name"; return 1; }
  done < <(find -P "$LAB_ROOT" -mindepth 1 -maxdepth 1 -print0)
}

load_state() {
  local -a lines
  [[ -f "$STATE_FILE" && ! -L "$STATE_FILE" ]] \
    || { fail "lab state is absent; run: bash lab.sh setup"; return 1; }
  [[ "$(stat -c '%u' -- "$STATE_FILE")" == "$LAB_UID" \
    && "$(stat -c '%a' -- "$STATE_FILE")" == "600" \
    && "$(stat -c '%h' -- "$STATE_FILE")" == "1" ]] \
    || { fail "state descriptor owner, mode, or link count changed"; return 1; }
  mapfile -t lines < "$STATE_FILE"
  [[ "${#lines[@]}" -eq 3 \
    && "${lines[0]}" == "state_version=1" \
    && "${lines[1]}" == "lesson_id=$LESSON_ID" \
    && "${lines[2]}" == lab_root=* ]] \
    || { fail "state descriptor content is invalid"; return 1; }
  LAB_ROOT="${lines[2]#lab_root=}"
  validate_root
  [[ "$(candidate_count)" == "1" ]] \
    || { fail "registered state does not own the only lesson candidate"; return 1; }
}

load_process() {
  local -a lines
  local record="$LAB_ROOT/process.record"
  [[ -f "$record" && ! -L "$record" ]] || return 1
  mapfile -t lines < "$record"
  [[ "${#lines[@]}" -eq 4 \
    && "${lines[0]}" == "record_version=1" \
    && "${lines[1]}" == token=* \
    && "${lines[2]}" == pid=* \
    && "${lines[3]}" == start_ticks=* ]] \
    || { fail "process record is invalid"; return 1; }
  LAB_TOKEN="${lines[1]#token=}"
  LAB_PID="${lines[2]#pid=}"
  LAB_START="${lines[3]#start_ticks=}"
  [[ "$LAB_TOKEN" =~ ^les-0002-[0-9]+-[0-9]+$ && "$LAB_PID" =~ ^[0-9]+$ \
    && "$LAB_START" =~ ^[0-9]+$ ]] \
    || { fail "process record values are invalid"; return 1; }
}

process_matches() {
  local start owner command_line
  [[ -d "/proc/$LAB_PID" ]] || return 1
  owner="$(stat -c '%u' -- "/proc/$LAB_PID")"
  start="$(sed -E 's/^.*\) [^ ]+ ([^ ]+ ){18}([^ ]+).*$/\2/' "/proc/$LAB_PID/stat")"
  command_line="$(tr '\0' ' ' < "/proc/$LAB_PID/cmdline")"
  [[ "$owner" == "$LAB_UID" && "$start" == "$LAB_START" \
    && "$command_line" == *"$TARGET_SCRIPT"* && "$command_line" == *"$LAB_TOKEN"* ]]
}

command_check() {
  require_environment
  if [[ -e "$STATE_FILE" || -L "$STATE_FILE" ]]; then
    load_state
    printf 'environment=ready\nstate=present\nlesson_id=%s\nprocess_candidates=%s\n' \
      "$LESSON_ID" "$(candidate_count)"
  else
    [[ "$(candidate_count)" == "0" ]] \
      || { fail "unregistered lesson root candidate exists"; return 1; }
    printf 'environment=ready\nstate=absent\nlesson_id=%s\nprocess_candidates=0\n' "$LESSON_ID"
  fi
}

command_setup() {
  require_environment
  [[ ! -e "$STATE_FILE" && ! -L "$STATE_FILE" ]] \
    || { load_state; printf 'setup=already-present\nlab_root=%s\n' "$LAB_ROOT"; return; }
  [[ "$(candidate_count)" == "0" ]] \
    || { fail "unregistered lesson root candidate exists"; return 1; }
  LAB_ROOT="$(mktemp -d --tmpdir=/tmp "${PREFIX}XXXXXXXX")"
  chmod 700 -- "$LAB_ROOT"
  printf 'lesson_id=%s\nowner_uid=%s\n' "$LESSON_ID" "$LAB_UID" > "$LAB_ROOT/$SENTINEL"
  chmod 600 -- "$LAB_ROOT/$SENTINEL"
  set -o noclobber
  printf 'state_version=1\nlesson_id=%s\nlab_root=%s\n' \
    "$LESSON_ID" "$LAB_ROOT" > "$STATE_FILE"
  set +o noclobber
  chmod 600 -- "$STATE_FILE"
  validate_root
  printf 'setup=complete\nlab_root=%s\nnetwork=disabled\n' "$LAB_ROOT"
}

command_inject() {
  local start
  require_environment
  load_state
  [[ ! -e "$LAB_ROOT/process.record" && ! -e "$LAB_ROOT/events.log" ]] \
    || { fail "process case already exists; use cleanup or reset"; return 1; }
  LAB_TOKEN="les-0002-$LAB_UID-$(date +%s)"
  : > "$LAB_ROOT/events.log"
  chmod 600 -- "$LAB_ROOT/events.log"
  bash "$TARGET_SCRIPT" "$LAB_TOKEN" "$LAB_ROOT/events.log" >/dev/null 2>&1 &
  LAB_PID="$!"
  for _ in 1 2 3 4 5; do
    [[ -r "/proc/$LAB_PID/stat" ]] && grep -Fq 'event=ready ' "$LAB_ROOT/events.log" && break
    sleep 0.1
  done
  [[ -r "/proc/$LAB_PID/stat" ]] || { fail "fixture process did not start"; return 1; }
  start="$(sed -E 's/^.*\) [^ ]+ ([^ ]+ ){18}([^ ]+).*$/\2/' "/proc/$LAB_PID/stat")"
  printf 'record_version=1\ntoken=%s\npid=%s\nstart_ticks=%s\n' \
    "$LAB_TOKEN" "$LAB_PID" "$start" > "$LAB_ROOT/process.record"
  chmod 600 -- "$LAB_ROOT/process.record"
  load_process
  process_matches || { fail "fixture identity check failed after start"; return 1; }
  printf 'inject=complete\npid=%s\nstate=running\n' "$LAB_PID"
}

command_observe() {
  require_environment
  load_state
  load_process || { fail "no process case exists"; return 1; }
  process_matches || { fail "recorded process is absent or identity changed"; return 1; }
  ps -o pid,ppid,user,stat,nlwp,etime,cmd -p "$LAB_PID"
  printf 'identity=matched\nstart_ticks=%s\n' "$LAB_START"
}

command_status() {
  require_environment
  load_state
  if load_process; then
    if process_matches; then
      printf 'state=running\npid=%s\nidentity=matched\n' "$LAB_PID"
    elif [[ -f "$LAB_ROOT/termination.record" ]] \
      && grep -Fxq 'termination=graceful' "$LAB_ROOT/termination.record"; then
      printf 'state=terminated\nidentity=not-running\n'
    else
      fail "recorded process is absent or identity changed without termination proof"
      return 1
    fi
  else
    printf 'state=ready\nidentity=no-process-record\n'
  fi
}

command_terminate() {
  local _
  require_environment
  load_state
  load_process || { fail "no process case exists"; return 1; }
  [[ ! -e "$LAB_ROOT/termination.record" ]] \
    || { fail "termination was already recorded"; return 1; }
  process_matches || { fail "refusing to signal an absent or changed process"; return 1; }
  kill -TERM "$LAB_PID"
  for _ in {1..50}; do process_matches || break; sleep 0.1; done
  process_matches && { fail "process did not terminate within five seconds"; return 1; }
  grep -Fq "event=term_received token=$LAB_TOKEN pid=$LAB_PID" "$LAB_ROOT/events.log" \
    || { fail "graceful termination event is missing"; return 1; }
  printf 'termination=graceful\npid=%s\n' "$LAB_PID" > "$LAB_ROOT/termination.record"
  chmod 600 -- "$LAB_ROOT/termination.record"
  printf 'termination=graceful\nstate=terminated\npid=%s\n' "$LAB_PID"
}

command_cleanup() {
  local _
  require_environment
  if [[ ! -e "$STATE_FILE" && ! -L "$STATE_FILE" ]]; then
    [[ "$(candidate_count)" == "0" ]] \
      || { fail "unregistered lesson root candidate exists"; return 1; }
    printf 'cleanup=already-clean\nstate=absent\ncleanup_proven=true\n'
    return
  fi
  load_state
  if load_process && process_matches; then
    kill -TERM "$LAB_PID"
    for _ in {1..50}; do process_matches || break; sleep 0.1; done
    process_matches && { fail "fixture remains running; cleanup stopped"; return 1; }
  fi
  validate_root
  rm -f -- "$LAB_ROOT/events.log" "$LAB_ROOT/process.record" \
    "$LAB_ROOT/termination.record" "$LAB_ROOT/$SENTINEL"
  rmdir -- "$LAB_ROOT"
  rm -- "$STATE_FILE"
  [[ ! -e "$STATE_FILE" && "$(candidate_count)" == "0" ]] \
    || { fail "cleanup absence proof failed"; return 1; }
  printf 'cleanup=complete\nstate=absent\nprocess_candidates=0\ncleanup_proven=true\n'
}

command_reset() {
  command_cleanup >/dev/null
  command_setup
}

case "${1:-}" in
  check) command_check ;;
  setup) command_setup ;;
  inject) command_inject ;;
  observe) command_observe ;;
  status) command_status ;;
  terminate) command_terminate ;;
  cleanup) command_cleanup ;;
  reset) command_reset ;;
  *) fail "usage: bash lab.sh check|setup|inject|observe|status|terminate|cleanup|reset"; exit 2 ;;
esac
