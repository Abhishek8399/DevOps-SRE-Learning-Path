#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_SOURCE=${BASH_SOURCE[0]}
if [[ $SCRIPT_SOURCE == */* ]]; then SCRIPT_PARENT=${SCRIPT_SOURCE%/*}; else SCRIPT_PARENT='.'; fi
SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)
readonly SCRIPT_DIRECTORY
readonly LAB_SCRIPT="${SCRIPT_DIRECTORY}/lab.sh"
readonly BASE_IMAGE='busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662'
readonly LAB_UID="$EUID"
readonly CONTAINER_NAME="reliability-atlas-les0023-u${LAB_UID}"
readonly STATE_FILE="/tmp/reliability-atlas-LES-0023-${LAB_UID}.state"
readonly CASE_FILE="/tmp/reliability-atlas-LES-0023-${LAB_UID}.case"
readonly RECOVERY_FILE="/tmp/reliability-atlas-LES-0023-${LAB_UID}.recovery"
readonly VERIFICATION_FILE="/tmp/reliability-atlas-LES-0023-${LAB_UID}.verification"

MAIN_ID=''
FOREIGN_ID=''
EXTERNAL_ROOT=''
SAVED_DESCRIPTOR=''
RESTORE_DESCRIPTOR=0
RESTORE_CASE_SYMLINK=0

fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e $1 || -L $1 ]]
}

container_id_if_present() {
  timeout 10 docker container inspect --format '{{.Id}}' "$CONTAINER_NAME" 2>/dev/null || true
}

restore_and_cleanup() {
  local actual
  if [[ -f ${STATE_FILE}.rewrite && ! -L ${STATE_FILE}.rewrite && $(stat -c '%u:%h' -- "${STATE_FILE}.rewrite" 2>/dev/null || true) == "$LAB_UID:1" ]]; then
    rm -- "${STATE_FILE}.rewrite" 2>/dev/null || true
  fi
  if ((RESTORE_DESCRIPTOR == 1)) && [[ -n $SAVED_DESCRIPTOR && -f $STATE_FILE && ! -L $STATE_FILE ]]; then
    if [[ $(stat -c '%u:%h' -- "$STATE_FILE" 2>/dev/null || true) == "$LAB_UID:1" ]]; then
      printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE" 2>/dev/null || true
      chmod 600 -- "$STATE_FILE" 2>/dev/null || true
    fi
  fi
  if ((RESTORE_CASE_SYMLINK == 1)) && [[ -L $CASE_FILE ]]; then rm -- "$CASE_FILE" 2>/dev/null || true; fi
  if [[ -f $STATE_FILE && ! -L $STATE_FILE ]]; then bash "$LAB_SCRIPT" cleanup >/dev/null 2>&1 || true; fi
  actual=$(container_id_if_present)
  if [[ -n $FOREIGN_ID && $actual == "$FOREIGN_ID" ]]; then timeout 20 docker container rm --force "$CONTAINER_NAME" >/dev/null 2>&1 || true; fi
  if [[ -n $MAIN_ID && $actual == "$MAIN_ID" ]]; then timeout 20 docker container rm --force "$CONTAINER_NAME" >/dev/null 2>&1 || true; fi
  if [[ -n $EXTERNAL_ROOT && $EXTERNAL_ROOT =~ ^/tmp/reliability-atlas-LES-0023-verifier\.[A-Za-z0-9]{8}$ && -d $EXTERNAL_ROOT && ! -L $EXTERNAL_ROOT ]]; then
    if [[ $(stat -c '%u' -- "$EXTERNAL_ROOT" 2>/dev/null || true) == "$LAB_UID" ]]; then
      if [[ -f ${EXTERNAL_ROOT}/target && ! -L ${EXTERNAL_ROOT}/target ]]; then rm -- "${EXTERNAL_ROOT}/target" 2>/dev/null || true; fi
      rmdir -- "$EXTERNAL_ROOT" 2>/dev/null || true
    fi
  fi
}

trap restore_and_cleanup EXIT
trap 'exit 130' INT TERM

if ((LAB_UID == 0)); then
  fail 'run-verifier-as-a-normal-non-root-WSL-user' || true
  exit 77
fi
for tool in bash chmod cmp docker grep ln mktemp mv readlink rm rmdir sed stat timeout; do
  if ! command -v -- "$tool" >/dev/null 2>&1; then
    fail "required-verifier-command-missing-${tool}" || true
    exit 69
  fi
done
bash -n "$LAB_SCRIPT"
bash -n "$SCRIPT_DIRECTORY/verify.sh"

if ! timeout 20 docker version >/dev/null 2>&1; then
  printf 'static_verification=passed\n'
  printf 'runtime_verification=blocked\n'
  printf 'reason=docker-daemon-unavailable\n'
  printf 'network_pull_attempted=false\n'
  printf 'cleanup_proven=not-exercised\n'
  trap - EXIT INT TERM
  exit 0
fi
if ! timeout 20 docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
  printf 'static_verification=passed\n'
  printf 'runtime_verification=blocked\n'
  printf 'reason=pinned-busybox-image-not-cached\n'
  printf 'network_pull_attempted=false\n'
  printf 'cleanup_proven=not-exercised\n'
  trap - EXIT INT TERM
  exit 0
fi

must_fail() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then fail "$label-unexpectedly-succeeded"; return 1; fi
}

assert_contains() {
  local value=$1 expected=$2 label=$3
  grep -Fq -- "$expected" <<<"$value" || { fail "$label-missing-${expected}"; return 1; }
}

assert_absent() {
  local value=$1 forbidden=$2 label=$3
  if grep -Fiq -- "$forbidden" <<<"$value"; then fail "$label-exposed-${forbidden}"; return 1; fi
}

assert_clean() {
  local value
  value=$(bash "$LAB_SCRIPT" check)
  assert_contains "$value" 'state=absent' 'clean-check'
  assert_contains "$value" 'image_cached=true' 'cached-image-check'
  assert_contains "$value" 'network=none' 'network-check'
  [[ -z $(container_id_if_present) ]] || { fail 'container-remains-after-cleanup'; return 1; }
  for path in "$STATE_FILE" "$CASE_FILE" "$RECOVERY_FILE" "$VERIFICATION_FILE"; do
    ! path_present "$path" || { fail "local-artifact-remains-${path##*/}"; return 1; }
  done
}

run_case() {
  local case_name=$1 value view scenario forbidden
  value=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$value" 'setup=complete' "$case_name-setup"
  MAIN_ID=$(container_id_if_present)
  [[ $MAIN_ID =~ ^[0-9a-f]{64}$ ]] || { fail "$case_name-invalid-container-id"; return 1; }
  value=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$value" 'setup=already-present' "$case_name-repeated-setup"
  value=$(bash "$LAB_SCRIPT" status)
  assert_contains "$value" 'state=running' "$case_name-running"
  assert_contains "$value" 'health=healthy' "$case_name-healthy"
  assert_contains "$value" 'oom_killed=false' "$case_name-not-oom"
  must_fail "$case_name-recover-before-case" bash "$LAB_SCRIPT" recover
  must_fail "$case_name-verify-before-recovery" bash "$LAB_SCRIPT" verify-operation
  must_fail "$case_name-invalid-view" bash "$LAB_SCRIPT" observe invalid

  for view in image runtime filesystem limits process network health logs; do
    value=$(bash "$LAB_SCRIPT" observe "$view")
    assert_contains "$value" 'record=observation' "$case_name-$view-record"
    assert_contains "$value" "view=${view}" "$case_name-$view-view"
  done
  value=$(bash "$LAB_SCRIPT" observe image)
  assert_contains "$value" 'rootfs_type=layers' "$case_name-image-layers"
  value=$(bash "$LAB_SCRIPT" observe filesystem)
  assert_contains "$value" 'readonly_rootfs=true' "$case_name-readonly-rootfs"
  assert_contains "$value" 'bind_count=0' "$case_name-no-binds"
  value=$(bash "$LAB_SCRIPT" observe limits)
  assert_contains "$value" 'memory_bytes=67108864' "$case_name-memory-limit"
  assert_contains "$value" 'pids_limit=64' "$case_name-pids-limit"
  value=$(bash "$LAB_SCRIPT" observe network)
  assert_contains "$value" 'network_mode=none' "$case_name-network-none"
  assert_contains "$value" 'published_port_count=0' "$case_name-no-ports"

  value=$(bash "$LAB_SCRIPT" inject "$case_name")
  assert_contains "$value" "case=${case_name}" "$case_name-injection"
  assert_contains "$value" 'answer_key=not-provided' "$case_name-answer-boundary"
  must_fail "$case_name-second-injection" bash "$LAB_SCRIPT" inject guided
  if [[ $case_name == guided ]]; then
    assert_contains "$value" 'visible_signal=health-unhealthy' 'guided-visible-signal'
    must_fail 'guided-scenario-refusal' bash "$LAB_SCRIPT" scenario
    value=$(bash "$LAB_SCRIPT" observe health)
    assert_contains "$value" 'health=unhealthy' 'guided-health-evidence'
    value=$(bash "$LAB_SCRIPT" observe process)
    assert_contains "$value" 'container_state=running' 'guided-running-while-unhealthy'
  else
    scenario=$(bash "$LAB_SCRIPT" scenario)
    assert_contains "$scenario" 'record=scenario_input' 'independent-scenario'
    assert_contains "$scenario" 'requested_action=maintenance-stop' 'independent-action'
    assert_contains "$scenario" 'stop_timeout_seconds=3' 'independent-timeout-input'
    for forbidden in exit_code stopped signal_received outcome diagnosis recovery answer_key process_state health_state; do
      assert_absent "$scenario" "$forbidden" 'independent-scenario'
    done
    value=$(bash "$LAB_SCRIPT" observe runtime)
    assert_contains "$value" 'status=exited' 'independent-runtime-state'
    value=$(bash "$LAB_SCRIPT" observe process)
    assert_contains "$value" 'process_table=unavailable-container-not-running' 'independent-process-boundary'
    value=$(bash "$LAB_SCRIPT" observe logs)
    assert_contains "$value" 'event=signal signal=TERM pid=1' 'independent-pid1-signal'
  fi

  value=$(bash "$LAB_SCRIPT" recover)
  assert_contains "$value" 'record=recovery' "$case_name-recovery"
  assert_contains "$value" 'state=running' "$case_name-recovered-running"
  assert_contains "$value" 'health=healthy' "$case_name-recovered-health"
  must_fail "$case_name-repeated-recovery" bash "$LAB_SCRIPT" recover
  must_fail "$case_name-scenario-after-recovery" bash "$LAB_SCRIPT" scenario

  value=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains "$value" 'record=verification' "$case_name-verification"
  assert_contains "$value" 'container_uid=65534' "$case_name-nonroot"
  assert_contains "$value" 'read_only_rootfs=verified' "$case_name-rootfs"
  assert_contains "$value" 'writable_tmpfs=verified' "$case_name-tmpfs"
  assert_contains "$value" 'network=none' "$case_name-network"
  if [[ $case_name == independent ]]; then assert_contains "$value" 'pid1_signal_contract=verified' 'independent-signal-contract'; fi
  must_fail "$case_name-repeated-verification" bash "$LAB_SCRIPT" verify-operation

  value=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'cleanup_proven=true' "$case_name-cleanup"
  MAIN_ID=''
  assert_clean
}

assert_clean
must_fail 'unknown-command' bash "$LAB_SCRIPT" unknown
must_fail 'extra-check-argument' bash "$LAB_SCRIPT" check extra
must_fail 'observe-before-setup' bash "$LAB_SCRIPT" observe image
must_fail 'inject-before-setup' bash "$LAB_SCRIPT" inject guided
must_fail 'scenario-before-setup' bash "$LAB_SCRIPT" scenario

run_case guided
run_case independent

value=$(bash "$LAB_SCRIPT" setup)
assert_contains "$value" 'setup=complete' 'tamper-setup'
MAIN_ID=$(container_id_if_present)
SAVED_DESCRIPTOR=$(<"$STATE_FILE")
RESTORE_DESCRIPTOR=1
printf '%s\n' "$SAVED_DESCRIPTOR" | sed 's/^container_id=.*/container_id=0000000000000000000000000000000000000000000000000000000000000000/' >"${STATE_FILE}.rewrite"
chmod 600 -- "${STATE_FILE}.rewrite"
mv -f -- "${STATE_FILE}.rewrite" "$STATE_FILE"
must_fail 'tampered-descriptor-status' bash "$LAB_SCRIPT" status
must_fail 'tampered-descriptor-cleanup' bash "$LAB_SCRIPT" cleanup
[[ $(container_id_if_present) == "$MAIN_ID" ]] || { fail 'tamper-test-changed-container'; exit 1; }
printf '%s\n' "$SAVED_DESCRIPTOR" >"$STATE_FILE"
chmod 600 -- "$STATE_FILE"
RESTORE_DESCRIPTOR=0
bash "$LAB_SCRIPT" cleanup >/dev/null
MAIN_ID=''
assert_clean

bash "$LAB_SCRIPT" setup >/dev/null
MAIN_ID=$(container_id_if_present)
EXTERNAL_ROOT=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0023-verifier.XXXXXXXX')
printf 'must-survive\n' >"${EXTERNAL_ROOT}/target"
chmod 600 -- "${EXTERNAL_ROOT}/target"
ln -s -- "${EXTERNAL_ROOT}/target" "$CASE_FILE"
RESTORE_CASE_SYMLINK=1
must_fail 'case-symlink-status' bash "$LAB_SCRIPT" status
must_fail 'case-symlink-cleanup' bash "$LAB_SCRIPT" cleanup
cmp -s -- "${EXTERNAL_ROOT}/target" <(printf 'must-survive\n') || { fail 'case-symlink-target-changed'; exit 1; }
rm -- "$CASE_FILE"
RESTORE_CASE_SYMLINK=0
bash "$LAB_SCRIPT" cleanup >/dev/null
MAIN_ID=''
rm -- "${EXTERNAL_ROOT}/target"
rmdir -- "$EXTERNAL_ROOT"
EXTERNAL_ROOT=''
assert_clean

FOREIGN_ID=$(timeout 30 docker run --detach --pull=never --name "$CONTAINER_NAME" \
  --label 'reliability-atlas.verifier=foreign-refusal' --user 65534:65534 --network none --read-only \
  --cap-drop ALL --security-opt no-new-privileges=true --pids-limit 16 --memory 32m --memory-swap 32m \
  "$BASE_IMAGE" sleep 300)
[[ $FOREIGN_ID =~ ^[0-9a-f]{64}$ ]] || { fail 'foreign-container-id-invalid'; exit 1; }
must_fail 'foreign-container-check' bash "$LAB_SCRIPT" check
must_fail 'foreign-container-setup' bash "$LAB_SCRIPT" setup
must_fail 'foreign-container-cleanup' bash "$LAB_SCRIPT" cleanup
[[ $(container_id_if_present) == "$FOREIGN_ID" ]] || { fail 'foreign-container-was-changed'; exit 1; }
timeout 20 docker container rm --force "$CONTAINER_NAME" >/dev/null
FOREIGN_ID=''
assert_clean

value=$(bash "$LAB_SCRIPT" cleanup)
assert_contains "$value" 'cleanup=already-clean' 'idempotent-cleanup'
assert_contains "$value" 'cleanup_proven=true' 'idempotent-cleanup-proof'

trap - EXIT INT TERM
printf 'static_verification=passed\n'
printf 'runtime_verification=passed\n'
printf 'cases=guided-health,independent-pid1-signal\n'
printf 'observations=image,runtime,filesystem,limits,process,network,health,logs\n'
printf 'refusals=invalid-input,invalid-transition,descriptor-tamper,artifact-symlink,foreign-container\n'
printf 'answer_isolation=raw-independent-inputs-no-derived-state-outcome-diagnosis-or-recovery\n'
printf 'base_image=pinned-cached-only\n'
printf 'network_pull_attempted=false\n'
printf 'cleanup_proven=true\n'
