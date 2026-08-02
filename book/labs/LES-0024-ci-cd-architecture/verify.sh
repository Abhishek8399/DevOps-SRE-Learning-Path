#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SCRIPT_SOURCE=${BASH_SOURCE[0]}
if [[ $SCRIPT_SOURCE == *'/'* ]]; then
  SCRIPT_PARENT=${SCRIPT_SOURCE%/*}
else
  SCRIPT_PARENT='.'
fi
SCRIPT_DIRECTORY=$(CDPATH='' cd -- "$SCRIPT_PARENT" && pwd -P)
readonly SCRIPT_SOURCE SCRIPT_PARENT SCRIPT_DIRECTORY
readonly LAB_SCRIPT="${SCRIPT_DIRECTORY}/lab.sh"
readonly MODEL_SOURCE="${SCRIPT_DIRECTORY}/fixtures/pipeline_model.py"
LAB_UID=$EUID
readonly LAB_UID
readonly STATE_FILE="/tmp/reliability-atlas-LES-0024-${LAB_UID}.state"

LAB_ROOT=''
VERIFIER_OWNS_STATE=0
OWNED_DESCRIPTOR_IDENTITY=''
OWNED_ROOT=''
PARSED_RECEIPT_IDENTITY=''
PARSED_RECEIPT_ROOT=''
RACE_FIXTURE_KIND=''
RACE_FIXTURE_IDENTITY=''
RACE_TARGET=''
RACE_TARGET_IDENTITY=''
RACE_PID=''
RACE_GATE=''
RACE_GATE_IDENTITY=''
TEMP_FILES=()

fail() {
  printf 'verification_error=%s\n' "$1" >&2
  return 1
}

path_present() {
  [[ -e $1 || -L $1 ]]
}

assert_contains() {
  local value=$1 expected=$2 label=$3
  grep -Fq -- "$expected" <<<"$value" || {
    fail "${label}-missing-${expected}"
    return 1
  }
}

assert_absent() {
  local value=$1 forbidden=$2 label=$3
  if grep -Fiq -- "$forbidden" <<<"$value"; then
    fail "${label}-exposed-${forbidden}"
    return 1
  fi
}

must_fail_with() {
  local label=$1 expected_status=$2 expected_token=$3 output status
  shift 3
  set +e
  output=$("$@" 2>&1)
  status=$?
  set -e
  [[ $status == "$expected_status" ]] || {
    fail "${label}-wrong-exit-${status}-expected-${expected_status}"
    printf '%s\n' "$output" >&2
    return 1
  }
  assert_contains "$output" "$expected_token" "$label"
}

parse_setup_receipt() {
  local output=$1 label=$2
  local -a root_lines=() identity_lines=()
  mapfile -t root_lines < <(grep -E '^lab_root=' <<<"$output")
  mapfile -t identity_lines < <(grep -E '^ownership_descriptor_identity=' <<<"$output")
  ((${#root_lines[@]} == 1)) || {
    fail "${label}-setup-root-receipt-count"
    return 1
  }
  ((${#identity_lines[@]} == 1)) || {
    fail "${label}-setup-identity-receipt-count"
    return 1
  }
  PARSED_RECEIPT_ROOT=${root_lines[0]#lab_root=}
  PARSED_RECEIPT_IDENTITY=${identity_lines[0]#ownership_descriptor_identity=}
  [[ $PARSED_RECEIPT_ROOT =~ ^/tmp/reliability-atlas-LES-0024-u${LAB_UID}\.[A-Za-z0-9]{8}$ ]] || {
    fail "${label}-setup-root-receipt-invalid"
    return 1
  }
  [[ $PARSED_RECEIPT_IDENTITY =~ ^[0-9]+:[0-9]+$ ]] || {
    fail "${label}-setup-identity-receipt-invalid"
    return 1
  }
}

state_snapshot() {
  PYTHONDONTWRITEBYTECODE=1 python3 - "$STATE_FILE" <<'PY'
import hashlib
import os
import stat
import sys
from pathlib import Path

descriptor = Path(sys.argv[1])
digest = hashlib.sha256()
descriptor_bytes = descriptor.read_bytes()
digest.update(b"descriptor\0" + descriptor_bytes)
root_lines = [
    line.removeprefix("root=")
    for line in descriptor_bytes.decode("utf-8").splitlines()
    if line.startswith("root=")
]
if len(root_lines) != 1:
    raise SystemExit("descriptor root invalid")
root = Path(root_lines[0])
for path in sorted([root, *root.rglob("*")], key=lambda item: str(item)):
    metadata = path.lstat()
    relative = "." if path == root else str(path.relative_to(root))
    digest.update(relative.encode("utf-8") + b"\0")
    digest.update(
        f"{stat.S_IMODE(metadata.st_mode)}:{metadata.st_uid}:{metadata.st_gid}:"
        f"{metadata.st_nlink}:{metadata.st_size}".encode("ascii")
    )
    digest.update(b"\0")
    if path.is_symlink():
        digest.update(os.readlink(path).encode("utf-8"))
    elif path.is_file():
        digest.update(path.read_bytes())
print(digest.hexdigest())
PY
}

owned_setup() {
  local output
  output=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$output" 'setup=complete' 'owned-setup'
  parse_setup_receipt "$output" 'owned-setup'
  OWNED_ROOT=$PARSED_RECEIPT_ROOT
  OWNED_DESCRIPTOR_IDENTITY=$PARSED_RECEIPT_IDENTITY
  LAB_ROOT=$OWNED_ROOT
  VERIFIER_OWNS_STATE=1
  printf '%s' "$output"
}

run_guarded_owned_cleanup() {
  ((VERIFIER_OWNS_STATE == 1)) || {
    fail 'guarded-cleanup-called-without-ownership'
    return 1
  }
  [[ -n $OWNED_DESCRIPTOR_IDENTITY && -n $OWNED_ROOT ]] || {
    fail 'guarded-cleanup-missing-ownership-receipt'
    return 1
  }
  LES0024_VERIFIER_MODE=1 \
    LES0024_EXPECTED_DESCRIPTOR_IDENTITY=$OWNED_DESCRIPTOR_IDENTITY \
    LES0024_EXPECTED_LAB_ROOT=$OWNED_ROOT \
    bash "$LAB_SCRIPT" cleanup
}

owned_cleanup() {
  local output check_output
  ((VERIFIER_OWNS_STATE == 1)) || {
    fail 'owned-cleanup-called-without-ownership'
    return 1
  }
  output=$(run_guarded_owned_cleanup)
  assert_contains "$output" 'cleanup_proven=true' 'owned-cleanup'
  check_output=$(bash "$LAB_SCRIPT" check)
  assert_contains "$check_output" 'state=absent' 'owned-cleanup-postcondition'
  VERIFIER_OWNS_STATE=0
  LAB_ROOT=''
  OWNED_ROOT=''
  OWNED_DESCRIPTOR_IDENTITY=''
  printf '%s' "$output"
}

cleanup_race_fixture() {
  local current_identity
  if [[ -n $RACE_GATE && -f $RACE_GATE && ! -L $RACE_GATE ]]; then
    current_identity=$(stat -c '%d:%i' -- "$RACE_GATE" 2>/dev/null || true)
    if [[ $current_identity == "$RACE_GATE_IDENTITY" ]]; then
      printf 'release\n' >"$RACE_GATE" 2>/dev/null || true
    fi
  fi
  if [[ -n $RACE_PID ]]; then
    wait "$RACE_PID" 2>/dev/null || true
    RACE_PID=''
  fi
  case $RACE_FIXTURE_KIND in
    directory)
      if [[ -d $STATE_FILE && ! -L $STATE_FILE ]]; then
        current_identity=$(stat -c '%d:%i' -- "$STATE_FILE" 2>/dev/null || true)
        if [[ $current_identity == "$RACE_FIXTURE_IDENTITY" && -z $(find -P "$STATE_FILE" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null) ]]; then
          rmdir -- "$STATE_FILE" 2>/dev/null || true
        fi
      fi
      ;;
    symlink)
      if [[ -L $STATE_FILE ]]; then
        current_identity=$(stat -c '%d:%i' -- "$STATE_FILE" 2>/dev/null || true)
        if [[ $current_identity == "$RACE_FIXTURE_IDENTITY" && $(readlink -- "$STATE_FILE" 2>/dev/null || true) == "$RACE_TARGET" ]]; then
          rm -- "$STATE_FILE" 2>/dev/null || true
        fi
      fi
      ;;
  esac
  if [[ -n $RACE_TARGET && -d $RACE_TARGET && ! -L $RACE_TARGET ]]; then
    current_identity=$(stat -c '%d:%i' -- "$RACE_TARGET" 2>/dev/null || true)
    if [[ $current_identity == "$RACE_TARGET_IDENTITY" && -z $(find -P "$RACE_TARGET" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null) ]]; then
      rmdir -- "$RACE_TARGET" 2>/dev/null || true
    fi
  fi
  RACE_FIXTURE_KIND=''
  RACE_FIXTURE_IDENTITY=''
  RACE_TARGET=''
  RACE_TARGET_IDENTITY=''
  RACE_GATE=''
  RACE_GATE_IDENTITY=''
}

cleanup_verifier_paths() {
  local original_status=$? path owner
  cleanup_race_fixture
  if ((VERIFIER_OWNS_STATE == 1)); then
    run_guarded_owned_cleanup >/dev/null 2>&1 || true
  fi
  for path in "${TEMP_FILES[@]}"; do
    if [[ $path =~ ^/tmp/reliability-atlas-LES-0024-verifier-[A-Za-z0-9.]+$ && -f $path && ! -L $path ]]; then
      owner=$(stat -c '%u' -- "$path" 2>/dev/null || true)
      [[ $owner == "$LAB_UID" ]] && rm -- "$path" 2>/dev/null || true
    fi
  done
  return "$original_status"
}

run_descriptor_destination_race() {
  local kind=$1 output_file status hook_seen=0 current_identity
  local fixture_snapshot_before fixture_snapshot_after target_snapshot_before target_snapshot_after
  [[ $kind == directory || $kind == symlink ]] || {
    fail 'descriptor-race-kind-invalid'
    return 1
  }
  ! path_present "$STATE_FILE" || {
    fail "${kind}-race-state-not-absent"
    return 1
  }
  output_file=$(mktemp --tmpdir=/tmp "reliability-atlas-LES-0024-verifier-race${kind}.XXXXXXXX")
  TEMP_FILES+=("$output_file")
  LES0024_VERIFIER_MODE=1 LAB_TEST_DELAY_BEFORE_DESCRIPTOR_LINK=1 \
    bash "$LAB_SCRIPT" setup >"$output_file" 2>&1 &
  RACE_PID=$!
  for _ in {1..150}; do
    if grep -Fq 'test_hook=before-descriptor-link' "$output_file"; then
      hook_seen=1
      break
    fi
    sleep 0.02
  done
  ((hook_seen == 1)) || {
    wait "$RACE_PID" || true
    RACE_PID=''
    fail "${kind}-descriptor-link-hook-not-observed"
    return 1
  }

  if [[ $kind == directory ]]; then
    RACE_FIXTURE_KIND=directory
    mkdir -- "$STATE_FILE"
    chmod 700 -- "$STATE_FILE"
    RACE_FIXTURE_IDENTITY=$(stat -c '%d:%i' -- "$STATE_FILE")
    fixture_snapshot_before=$(stat -c '%d:%i:%f:%u:%g:%a:%h:%s' -- "$STATE_FILE")
  else
    RACE_TARGET=$(mktemp -d --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-racetarget.XXXXXXXX')
    chmod 700 -- "$RACE_TARGET"
    RACE_TARGET_IDENTITY=$(stat -c '%d:%i' -- "$RACE_TARGET")
    target_snapshot_before=$(stat -c '%d:%i:%f:%u:%g:%a:%h:%s' -- "$RACE_TARGET")
    RACE_FIXTURE_KIND=symlink
    ln -s -- "$RACE_TARGET" "$STATE_FILE"
    RACE_FIXTURE_IDENTITY=$(stat -c '%d:%i' -- "$STATE_FILE")
    fixture_snapshot_before=$(stat -c '%d:%i:%f:%u:%g:%a:%h:%s' -- "$STATE_FILE")
  fi

  set +e
  wait "$RACE_PID"
  status=$?
  set -e
  RACE_PID=''
  [[ $status == 73 ]] || {
    fail "${kind}-descriptor-race-wrong-exit-${status}-expected-73"
    return 1
  }
  assert_contains "$(<"$output_file")" 'cannot-register-state-atomically' "${kind}-descriptor-race"
  current_identity=$(stat -c '%d:%i' -- "$STATE_FILE")
  [[ $current_identity == "$RACE_FIXTURE_IDENTITY" ]] || {
    fail "${kind}-descriptor-race-replaced-foreign-path"
    return 1
  }
  fixture_snapshot_after=$(stat -c '%d:%i:%f:%u:%g:%a:%h:%s' -- "$STATE_FILE")
  [[ $fixture_snapshot_before == "$fixture_snapshot_after" ]] || {
    fail "${kind}-descriptor-race-mutated-foreign-path-metadata"
    return 1
  }
  if [[ $kind == directory ]]; then
    [[ -d $STATE_FILE && ! -L $STATE_FILE && -z $(find -P "$STATE_FILE" -mindepth 1 -maxdepth 1 -print -quit) ]] || {
      fail 'directory-descriptor-race-mutated-foreign-directory'
      return 1
    }
  else
    [[ -L $STATE_FILE && $(readlink -- "$STATE_FILE") == "$RACE_TARGET" ]] || {
      fail 'symlink-descriptor-race-mutated-foreign-symlink'
      return 1
    }
    target_snapshot_after=$(stat -c '%d:%i:%f:%u:%g:%a:%h:%s' -- "$RACE_TARGET")
    [[ $target_snapshot_before == "$target_snapshot_after" && -z $(find -P "$RACE_TARGET" -mindepth 1 -maxdepth 1 -print -quit) ]] || {
      fail 'symlink-descriptor-race-mutated-foreign-target'
      return 1
    }
  fi
  cleanup_race_fixture
  assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' "${kind}-descriptor-race-postcondition"
}

run_setup_receipt_replacement_race() {
  local output_file hook_seen=0 status output value replacement_identity replacement_root
  local snapshot_before snapshot_after current_identity
  ! path_present "$STATE_FILE" || {
    fail 'setup-receipt-race-state-not-absent'
    return 1
  }
  output_file=$(mktemp --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-receiptreplacement.XXXXXXXX')
  TEMP_FILES+=("$output_file")
  RACE_GATE=$(mktemp --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-postlinkgate.XXXXXXXX')
  TEMP_FILES+=("$RACE_GATE")
  printf 'wait\n' >"$RACE_GATE"
  chmod 600 -- "$RACE_GATE"
  RACE_GATE_IDENTITY=$(stat -c '%d:%i' -- "$RACE_GATE")
  LES0024_VERIFIER_MODE=1 LAB_TEST_AFTER_DESCRIPTOR_LINK_GATE=$RACE_GATE \
    bash "$LAB_SCRIPT" setup >"$output_file" 2>&1 &
  RACE_PID=$!
  for _ in {1..150}; do
    if grep -Fq 'test_hook=after-descriptor-link' "$output_file"; then
      hook_seen=1
      break
    fi
    sleep 0.02
  done
  ((hook_seen == 1)) || {
    wait "$RACE_PID" || true
    RACE_PID=''
    fail 'setup-receipt-post-link-hook-not-observed'
    return 1
  }

  value=$(bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'cleanup=complete' 'setup-receipt-original-cleanup'
  owned_setup >/dev/null
  replacement_identity=$OWNED_DESCRIPTOR_IDENTITY
  replacement_root=$OWNED_ROOT
  snapshot_before=$(state_snapshot)
  current_identity=$(stat -c '%d:%i' -- "$RACE_GATE")
  [[ $current_identity == "$RACE_GATE_IDENTITY" ]] || {
    fail 'setup-receipt-gate-identity-changed-before-release'
    return 1
  }
  printf 'release\n' >"$RACE_GATE"

  set +e
  wait "$RACE_PID"
  status=$?
  set -e
  RACE_PID=''
  RACE_GATE=''
  RACE_GATE_IDENTITY=''
  output=$(<"$output_file")
  [[ $status == 79 ]] || {
    fail "setup-receipt-race-wrong-exit-${status}-expected-79"
    return 1
  }
  assert_contains "$output" 'setup-lifecycle-replaced-before-ownership-receipt' 'setup-receipt-race'
  assert_absent "$output" 'setup=complete' 'setup-receipt-race'
  assert_absent "$output" "lab_root=${replacement_root}" 'setup-receipt-race'
  assert_absent "$output" "ownership_descriptor_identity=${replacement_identity}" 'setup-receipt-race'
  snapshot_after=$(state_snapshot)
  [[ $snapshot_before == "$snapshot_after" ]] || {
    fail 'setup-receipt-race-mutated-replacement-state'
    return 1
  }
  current_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE")
  [[ $current_identity == "$replacement_identity" ]] || {
    fail 'setup-receipt-race-changed-replacement-descriptor'
    return 1
  }
  owned_cleanup >/dev/null
  assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'setup-receipt-race-postcondition'
}

trap cleanup_verifier_paths EXIT
trap 'exit 130' INT TERM

if ((LAB_UID == 0)); then
  printf 'verification_error=run-verifier-as-a-normal-non-root-Ubuntu-user\n' >&2
  exit 77
fi
for tool in bash chmod cmp find flock grep install ln mkdir mktemp python3 readlink rm rmdir sha256sum sleep stat; do
  command -v -- "$tool" >/dev/null 2>&1 || {
    printf 'verification_error=required-verifier-command-missing-%s\n' "$tool" >&2
    exit 69
  }
done
bash -n "$LAB_SCRIPT"
bash -n "$SCRIPT_DIRECTORY/verify.sh"
PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; import sys; p=Path(sys.argv[1]); compile(p.read_text(encoding="utf-8"),str(p),"exec")' "$MODEL_SOURCE"

set +e
initial=$(bash "$LAB_SCRIPT" check 2>&1)
initial_status=$?
set -e
if ((initial_status != 0)) || ! grep -Fq 'state=absent' <<<"$initial"; then
  printf 'verification_error=pre-existing-state-refused\n' >&2
  exit 78
fi
assert_contains "$initial" 'network=none' 'initial-network'

preview=$(LAB_DRY_RUN=1 bash "$LAB_SCRIPT" setup)
assert_contains "$preview" 'dry_run=true' 'setup-preview'
assert_contains "$preview" 'state=absent' 'setup-preview'
assert_contains "$preview" 'two-separated-runner-workspaces' 'setup-preview-workspaces'
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'setup-preview-postcondition'

must_fail_with 'status-before-setup' 73 'cannot-open-state-descriptor' bash "$LAB_SCRIPT" status
must_fail_with 'unknown-command' 64 'usage:' bash "$LAB_SCRIPT" unknown
must_fail_with 'extra-check-argument' 64 'usage:' bash "$LAB_SCRIPT" check extra
must_fail_with 'invalid-run-target' 64 'run-target-must-be-baseline' bash "$LAB_SCRIPT" run incident
must_fail_with 'invalid-case' 64 'case-must-be-guided-or-independent' bash "$LAB_SCRIPT" inject transfer
must_fail_with 'invalid-dry-run-value' 64 'LAB_DRY_RUN-must-be-0-or-1' env LAB_DRY_RUN=yes bash "$LAB_SCRIPT" check
must_fail_with 'learner-test-hook' 64 'test-hooks-are-verifier-only' env LAB_TEST_STOP_AFTER_CLEANUP_STEP=runner-a bash "$LAB_SCRIPT" cleanup
run_descriptor_destination_race directory
run_descriptor_destination_race symlink
run_setup_receipt_replacement_race

# A nested verifier must refuse valid pre-existing state without changing one byte.
owned_setup >/dev/null
snapshot_before=$(state_snapshot)
set +e
nested_output=$(bash "$SCRIPT_DIRECTORY/verify.sh" 2>&1)
nested_status=$?
set -e
[[ $nested_status == 78 ]] || {
  fail "nested-verifier-wrong-exit-${nested_status}"
  exit 1
}
assert_contains "$nested_output" 'pre-existing-state-refused' 'nested-verifier'
snapshot_after=$(state_snapshot)
[[ $snapshot_before == "$snapshot_after" ]] || {
  fail 'nested-verifier-changed-pre-existing-state'
  exit 1
}
owned_cleanup >/dev/null

# Verifier cleanup authority is bound to the exact setup receipt, not the path name.
owned_setup >/dev/null
original_owned_identity=$OWNED_DESCRIPTOR_IDENTITY
original_owned_root=$OWNED_ROOT
value=$(bash "$LAB_SCRIPT" cleanup)
assert_contains "$value" 'cleanup=complete' 'replacement-original-cleanup'
replacement_setup=$(bash "$LAB_SCRIPT" setup)
assert_contains "$replacement_setup" 'setup=complete' 'replacement-setup'
parse_setup_receipt "$replacement_setup" 'replacement-setup'
replacement_identity=$PARSED_RECEIPT_IDENTITY
replacement_root=$PARSED_RECEIPT_ROOT
snapshot_before=$(state_snapshot)
must_fail_with 'replacement-normal-guard' 79 'verifier-owned-lifecycle-mismatch-refusing-cleanup' \
  env LES0024_VERIFIER_MODE=1 \
  LES0024_EXPECTED_DESCRIPTOR_IDENTITY="$original_owned_identity" \
  LES0024_EXPECTED_LAB_ROOT="$original_owned_root" \
  bash "$LAB_SCRIPT" cleanup
snapshot_after=$(state_snapshot)
[[ $snapshot_before == "$snapshot_after" ]] || {
  fail 'replacement-normal-guard-mutated-replacement-state'
  exit 1
}
(
  RACE_FIXTURE_KIND=''
  RACE_FIXTURE_IDENTITY=''
  RACE_TARGET=''
  RACE_TARGET_IDENTITY=''
  RACE_PID=''
  trap cleanup_verifier_paths EXIT
  exit 0
)
snapshot_after=$(state_snapshot)
[[ $snapshot_before == "$snapshot_after" ]] || {
  fail 'replacement-exit-guard-mutated-replacement-state'
  exit 1
}
current_identity=$(stat -Lc '%d:%i' -- "$STATE_FILE")
[[ $current_identity == "$replacement_identity" ]] || {
  fail 'replacement-descriptor-identity-changed'
  exit 1
}
OWNED_DESCRIPTOR_IDENTITY=$replacement_identity
OWNED_ROOT=$replacement_root
LAB_ROOT=$replacement_root
VERIFIER_OWNS_STATE=1
owned_cleanup >/dev/null

run_case() {
  local case_name=$1 value scenario view forbidden prediction_digest
  owned_setup >/dev/null
  value=$(bash "$LAB_SCRIPT" setup)
  assert_contains "$value" 'setup=already-present' "${case_name}-repeated-setup"
  value=$(bash "$LAB_SCRIPT" status)
  assert_contains "$value" 'baseline=pending' "${case_name}-initial-status"
  assert_contains "$value" 'workspace_isolation_proven=false' "${case_name}-workspace-claim"
  must_fail_with "${case_name}-recover-before-case" 73 'expected-regular-file-case.record' bash "$LAB_SCRIPT" recover
  must_fail_with "${case_name}-verify-before-recovery" 73 'expected-regular-file-case.record' bash "$LAB_SCRIPT" verify-operation

  value=$(bash "$LAB_SCRIPT" run baseline)
  assert_contains "$value" 'record=baseline' "${case_name}-baseline"
  assert_contains "$value" 'runner_workspaces_distinct=true' "${case_name}-baseline-workspaces"
  assert_contains "$value" 'workspace_isolation_proven=false' "${case_name}-baseline-boundary"
  assert_contains "$value" 'build_attempt_ids_distinct=true' "${case_name}-attempts"
  assert_contains "$value" 'artifact_byte_identical=true' "${case_name}-artifact"
  assert_contains "$value" 'attempt_id_embedded_in_artifact=false' "${case_name}-receipt-boundary"
  assert_contains "$value" 'cache_key_complete=true' "${case_name}-cache"
  assert_contains "$value" 'network_calls=0' "${case_name}-network"
  must_fail_with "${case_name}-repeated-baseline" 73 'baseline-already-recorded' bash "$LAB_SCRIPT" run baseline

  value=$(bash "$LAB_SCRIPT" inject "$case_name")
  assert_contains "$value" "case=${case_name}" "${case_name}-injection"
  assert_contains "$value" 'baseline_record_sha256=' "${case_name}-baseline-binding"
  assert_contains "$value" 'answer_key=not-provided' "${case_name}-answer-boundary"
  must_fail_with "${case_name}-second-injection" 73 'case-already-active' bash "$LAB_SCRIPT" inject guided
  must_fail_with "${case_name}-invalid-view" 64 'view-not-allowlisted' bash "$LAB_SCRIPT" observe invalid

  if [[ $case_name == guided ]]; then
    must_fail_with 'guided-scenario-refusal' 73 'scenario-only-available-for-independent-case' bash "$LAB_SCRIPT" scenario
  else
    scenario=$(bash "$LAB_SCRIPT" scenario)
    assert_contains "$scenario" 'record=scenario_input' 'independent-scenario'
    assert_contains "$scenario" 'reported_cache_key_fields=source,lock,runner-image,job-policy' 'independent-cache-input'
    for forbidden in decision diagnosis root_cause recovery approval_valid cache_valid identity_valid promotion_allowed deployment_outcome duplicate_effects answer_key; do
      assert_absent "$scenario" "$forbidden" 'independent-scenario'
    done
    must_fail_with 'independent-observe-before-prediction' 73 'expected-regular-file-prediction.record' bash "$LAB_SCRIPT" observe graph
    must_fail_with 'independent-experiment-before-prediction' 73 'expected-regular-file-prediction.record' bash "$LAB_SCRIPT" experiment cache-key
    must_fail_with 'independent-recover-before-prediction' 73 'expected-regular-file-prediction.record' bash "$LAB_SCRIPT" recover
    prediction_digest=$(printf 'cache stale; identity and release serialization suspect\n' | sha256sum)
    prediction_digest=${prediction_digest%% *}
    value=$(bash "$LAB_SCRIPT" acknowledge-predictions "$prediction_digest")
    assert_contains "$value" "external_prediction_sha256=${prediction_digest}" 'prediction-digest'
    assert_contains "$value" 'content_stored=false' 'prediction-content-boundary'
    must_fail_with 'repeated-prediction-ack' 73 'predictions-already-acknowledged' bash "$LAB_SCRIPT" acknowledge-predictions "$prediction_digest"
  fi

  for view in graph runner cache artifact identity approval deployment; do
    value=$(bash "$LAB_SCRIPT" observe "$view")
    assert_contains "$value" 'record=observation' "${case_name}-${view}-record"
    assert_contains "$value" "case=${case_name}" "${case_name}-${view}-case"
    assert_contains "$value" "view=${view}" "${case_name}-${view}-view"
  done

  if [[ $case_name == guided ]]; then
    value=$(bash "$LAB_SCRIPT" observe deployment)
    assert_contains "$value" 'canary_ready=false' 'guided-canary-failure'
    assert_contains "$value" 'promote_job_started=false' 'guided-promotion-stop'
    assert_contains "$value" 'production_changed=false' 'guided-production-preserved'
  else
    value=$(bash "$LAB_SCRIPT" observe runner)
    assert_contains "$value" 'workspace_isolation_proven=false' 'independent-workspace-boundary'
    value=$(bash "$LAB_SCRIPT" observe cache)
    assert_contains "$value" 'cache_key_fields=source,lock,runner-image,job-policy' 'independent-cache-omission'
    assert_contains "$value" 'definition_digest_in_key=false' 'independent-definition-gap'
    assert_contains "$value" 'lock_digest_in_key=true' 'independent-lock-present'
    assert_contains "$value" 'runner_image_digest_in_key=true' 'independent-image-present'
    assert_contains "$value" 'cache_entry_matches_current_contract=false' 'independent-stale-cache'
    value=$(bash "$LAB_SCRIPT" experiment cache-key)
    assert_contains "$value" 'declared_variable=pipeline-definition-digest-in-key' 'independent-experiment-variable'
    assert_contains "$value" 'control_key_fields=source,lock,runner-image,job-policy' 'independent-control'
    assert_contains "$value" 'control_cache_result=stale-hit' 'independent-control-result'
    assert_contains "$value" 'treatment_key_fields=source,definition,lock,runner-image,job-policy' 'independent-treatment'
    assert_contains "$value" 'treatment_cache_result=miss-build-current' 'independent-treatment-result'
    assert_contains "$value" 'single_variable_changed=true' 'independent-controlled-experiment'
    assert_contains "$value" 'proof_limit=deterministic-local-model-only' 'independent-proof-limit'
    must_fail_with 'repeated-experiment' 73 'experiment-already-recorded' bash "$LAB_SCRIPT" experiment cache-key
  fi

  value=$(LAB_DRY_RUN=1 bash "$LAB_SCRIPT" cleanup)
  assert_contains "$value" 'dry_run=true' "${case_name}-cleanup-preview"
  assert_contains "$(bash "$LAB_SCRIPT" status)" "active_case=${case_name}" "${case_name}-preview-no-mutation"

  value=$(bash "$LAB_SCRIPT" recover)
  assert_contains "$value" 'record=recovery' "${case_name}-recovery"
  assert_contains "$value" 'operation_success=true' "${case_name}-recovery-outcome"
  assert_contains "$value" 'promotion_count=1' "${case_name}-recovery-promotion"
  assert_contains "$value" 'duplicate_promotions=0' "${case_name}-recovery-duplicates"
  assert_contains "$value" 'user_verification=passed' "${case_name}-recovery-user-check"
  if [[ $case_name == independent ]]; then
    assert_contains "$value" 'prediction_record_sha256=' 'independent-prediction-binding'
    assert_contains "$value" 'experiment_record_sha256=' 'independent-experiment-binding'
    assert_contains "$value" 'serialized_attempts=true' 'independent-serialization'
  fi
  must_fail_with "${case_name}-repeated-recovery" 73 'recovery-already-recorded' bash "$LAB_SCRIPT" recover
  must_fail_with "${case_name}-observe-after-recovery" 73 'observation-unavailable-after-recovery' bash "$LAB_SCRIPT" observe deployment

  saved_baseline=$(<"${LAB_ROOT}/baseline.record")
  baseline_digest_before=$(sha256sum "${LAB_ROOT}/baseline.record")
  printf 'record=baseline\n' >"${LAB_ROOT}/baseline.record"
  chmod 600 -- "${LAB_ROOT}/baseline.record"
  must_fail_with "${case_name}-truncated-baseline" 70 'record-semantic-verification-failed' bash "$LAB_SCRIPT" verify-operation
  printf '%s\n' "$saved_baseline" >"${LAB_ROOT}/baseline.record"
  chmod 600 -- "${LAB_ROOT}/baseline.record"
  baseline_digest_after=$(sha256sum "${LAB_ROOT}/baseline.record")
  [[ $baseline_digest_before == "$baseline_digest_after" ]] || {
    fail "${case_name}-baseline-restore-byte-mismatch"
    return 1
  }

  saved_recovery=$(<"${LAB_ROOT}/recovery.record")
  recovery_digest_before=$(sha256sum "${LAB_ROOT}/recovery.record")
  altered_recovery=${saved_recovery/operation_success=true/operation_success=false}
  [[ $altered_recovery != "$saved_recovery" ]] || {
    fail "${case_name}-recovery-alteration-not-applied"
    return 1
  }
  printf '%s\n' "$altered_recovery" >"${LAB_ROOT}/recovery.record"
  chmod 600 -- "${LAB_ROOT}/recovery.record"
  must_fail_with "${case_name}-altered-recovery" 70 'record-semantic-verification-failed' bash "$LAB_SCRIPT" verify-operation
  printf '%s\n' "$saved_recovery" >"${LAB_ROOT}/recovery.record"
  chmod 600 -- "${LAB_ROOT}/recovery.record"
  recovery_digest_after=$(sha256sum "${LAB_ROOT}/recovery.record")
  [[ $recovery_digest_before == "$recovery_digest_after" ]] || {
    fail "${case_name}-recovery-restore-byte-mismatch"
    return 1
  }

  value=$(bash "$LAB_SCRIPT" verify-operation)
  assert_contains "$value" 'record=verification' "${case_name}-verification"
  assert_contains "$value" 'controller_state=converged' "${case_name}-controller"
  assert_contains "$value" 'runner_workspaces=distinct-private-current-uid' "${case_name}-workspace-separation"
  assert_contains "$value" 'workspace_isolation_proven=false' "${case_name}-isolation-boundary"
  assert_contains "$value" 'artifact_identity=verified' "${case_name}-artifact"
  assert_contains "$value" 'identity_scope=valid' "${case_name}-identity"
  assert_contains "$value" 'approval_binding=valid' "${case_name}-approval"
  assert_contains "$value" 'promotion_count=1' "${case_name}-promotion-count"
  assert_contains "$value" 'duplicate_promotions=0' "${case_name}-duplicates"
  assert_contains "$value" 'user_verification=passed' "${case_name}-user-verification"
  must_fail_with "${case_name}-repeated-verification" 73 'verification-already-recorded' bash "$LAB_SCRIPT" verify-operation

  owned_cleanup >/dev/null
  assert_contains "$(bash "$LAB_SCRIPT" cleanup)" 'cleanup=already-clean' "${case_name}-idempotent-cleanup"
}

run_case guided
run_case independent

# Unknown and symlinked children must be refused without touching foreign bytes.
owned_setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
printf 'unexpected\n' >"${LAB_ROOT}/unexpected.file"
chmod 600 -- "${LAB_ROOT}/unexpected.file"
must_fail_with 'unexpected-child-status' 73 'unexpected-child-unexpected.file' bash "$LAB_SCRIPT" status
must_fail_with 'unexpected-child-cleanup' 73 'unexpected-child-unexpected.file' bash "$LAB_SCRIPT" cleanup
[[ $(<"${LAB_ROOT}/unexpected.file") == unexpected ]] || {
  fail 'unexpected-child-was-modified'
  exit 1
}
rm -- "${LAB_ROOT}/unexpected.file"

external_target=$(mktemp --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-target.XXXXXXXX')
TEMP_FILES+=("$external_target")
printf 'must-survive\n' >"$external_target"
chmod 600 -- "$external_target"
saved_baseline=$(<"${LAB_ROOT}/baseline.record")
rm -- "${LAB_ROOT}/baseline.record"
ln -s -- "$external_target" "${LAB_ROOT}/baseline.record"
must_fail_with 'symlink-record-status' 73 'expected-regular-file-baseline.record' bash "$LAB_SCRIPT" status
must_fail_with 'symlink-record-cleanup' 73 'expected-regular-file-baseline.record' bash "$LAB_SCRIPT" cleanup
[[ $(<"$external_target") == must-survive ]] || {
  fail 'external-symlink-target-was-modified'
  exit 1
}
rm -- "${LAB_ROOT}/baseline.record"
printf '%s\n' "$saved_baseline" >"${LAB_ROOT}/baseline.record"
chmod 600 -- "${LAB_ROOT}/baseline.record"
owned_cleanup >/dev/null

# Cleanup resumes after an allowlisted child has already disappeared.
owned_setup >/dev/null
bash "$LAB_SCRIPT" run baseline >/dev/null
must_fail_with 'interruption-after-runner-a' 85 'simulated-interruption-after-runner-a' \
  env LES0024_VERIFIER_MODE=1 LAB_TEST_STOP_AFTER_CLEANUP_STEP=runner-a bash "$LAB_SCRIPT" cleanup
assert_contains "$(<"$STATE_FILE")" 'phase=C' 'runner-a-interrupted-phase'
[[ ! -e ${LAB_ROOT}/runner-a && -d ${LAB_ROOT}/runner-b ]] || {
  fail 'runner-a-interruption-boundary-invalid'
  exit 1
}
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=cleanup-in-progress' 'runner-a-interrupted-check'
owned_cleanup >/dev/null

# Cleanup also resumes from the empty-root window after the root was removed.
owned_setup >/dev/null
must_fail_with 'interruption-after-root' 85 'simulated-interruption-after-root' \
  env LES0024_VERIFIER_MODE=1 LAB_TEST_STOP_AFTER_CLEANUP_STEP=root bash "$LAB_SCRIPT" cleanup
[[ ! -e $LAB_ROOT && -f $STATE_FILE ]] || {
  fail 'root-window-interruption-boundary-invalid'
  exit 1
}
assert_contains "$(<"$STATE_FILE")" 'phase=C' 'root-window-phase'
owned_cleanup >/dev/null

# A second cleanup cannot cross the stable descriptor lock.
owned_setup >/dev/null
concurrent_output=$(mktemp --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-concurrent.XXXXXXXX')
TEMP_FILES+=("$concurrent_output")
LES0024_VERIFIER_MODE=1 LAB_TEST_DELAY_AFTER_CLEANUP_LOCK=1 \
  bash "$LAB_SCRIPT" cleanup >"$concurrent_output" 2>&1 &
concurrent_pid=$!
hook_seen=0
for _ in {1..100}; do
  if grep -Fq 'test_hook=cleanup-lock-held' "$concurrent_output"; then
    hook_seen=1
    break
  fi
  sleep 0.02
done
((hook_seen == 1)) || {
  fail 'concurrent-cleanup-hook-not-observed'
  wait "$concurrent_pid" || true
  exit 1
}
must_fail_with 'concurrent-cleanup-refusal' 75 'state-lock-contended' bash "$LAB_SCRIPT" cleanup
wait "$concurrent_pid"
assert_contains "$(<"$concurrent_output")" 'cleanup=complete' 'concurrent-cleanup-owner'
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'concurrent-cleanup-postcondition'
VERIFIER_OWNS_STATE=0
LAB_ROOT=''

# An invocation that started before cleanup cannot recreate the descriptor.
owned_setup >/dev/null
stale_output=$(mktemp --tmpdir=/tmp 'reliability-atlas-LES-0024-verifier-stale.XXXXXXXX')
TEMP_FILES+=("$stale_output")
set +e
LES0024_VERIFIER_MODE=1 LAB_TEST_DELAY_BEFORE_DESCRIPTOR_OPEN=1 \
  bash "$LAB_SCRIPT" status >"$stale_output" 2>&1 &
stale_pid=$!
set -e
hook_seen=0
for _ in {1..100}; do
  if grep -Fq 'test_hook=before-descriptor-open' "$stale_output"; then
    hook_seen=1
    break
  fi
  sleep 0.02
done
((hook_seen == 1)) || {
  fail 'stale-invocation-hook-not-observed'
  wait "$stale_pid" || true
  exit 1
}
owned_cleanup >/dev/null
set +e
wait "$stale_pid"
stale_status=$?
set -e
[[ $stale_status == 73 ]] || {
  fail "stale-invocation-wrong-exit-${stale_status}"
  exit 1
}
assert_contains "$(<"$stale_output")" 'cannot-open-state-descriptor' 'stale-invocation-refusal'
assert_contains "$(bash "$LAB_SCRIPT" check)" 'state=absent' 'stale-invocation-no-recreation'

printf 'verification_passed=true\n'
printf 'platform=Ubuntu-24.04\n'
printf 'cases=guided-failed-canary,independent-stale-cache-concurrency-identity\n'
printf 'runner_workspaces=two-distinct-private-current-uid-directories\n'
printf 'workspace_isolation_proven=false\n'
printf 'record_binding=exact-content-and-digest-verified\n'
printf 'experiment=prediction-gated-single-variable-cache-key\n'
printf 'cleanup=serialized-resumable-and-finally-absent\n'
printf 'preexisting_state=refused-and-byte-preserved\n'
printf 'network_mutation=none\n'
printf 'hosted_ci_calls=0\n'
printf 'registry_calls=0\n'
printf 'cloud_calls=0\n'
printf 'cleanup_proven=true\n'
