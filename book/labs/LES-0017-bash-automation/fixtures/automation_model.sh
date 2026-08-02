#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

usage() {
  printf '%s\n' 'usage: automation_model.sh baseline | automation_model.sh <guided|independent> <input|expansion|pipeline|state|retry|recovery|verification>' >&2
  return 64
}

emit_baseline() {
  printf '%s\n' \
    'model=deterministic-bash-automation' \
    'scenario=baseline' \
    'input_records=6' \
    'arguments_received=6' \
    'producer_status=0' \
    'consumer_status=0' \
    'pipeline_status=0' \
    'effects_committed=6' \
    'candidate_records=6' \
    'publication=complete' \
    'operation_verified=true'
}

emit_guided_input() {
  printf '%s\n' \
    'model=deterministic-bash-automation' \
    'scenario=guided' \
    'view=raw-input' \
    'operation=publish-release-inventory' \
    'expected_records=6' \
    'record_1=alpha.log' \
    'record_2=quarter close.log' \
    'record_3=literal-asterisk-*.log' \
    'record_4=--looks-like-option.log' \
    'record_5=empty-field-record' \
    'record_6=omega.log' \
    'producer_observation=emitted-four-records-then-returned-status-23' \
    'caller_observation=reported-status-0' \
    'consumer_observation=final-report-has-four-records'
}

emit_guided_expansion() {
  printf '%s\n' \
    'scenario=guided' \
    'view=expansion' \
    'logical_records=6' \
    'arguments_received=8' \
    'space_record_preserved=false' \
    'wildcard_record_preserved=false' \
    'leading_dash_preserved_as_operand=false' \
    'empty_value_preserved=false' \
    'record_protocol=unquoted-command-substitution'
}

emit_guided_pipeline() {
  printf '%s\n' \
    'scenario=guided' \
    'view=pipeline' \
    'producer_status=23' \
    'consumer_status=0' \
    'pipefail_enabled=false' \
    'selected_pipeline_status=0' \
    'partial_output_exists=true' \
    'candidate_is_final_path=true'
}

emit_guided_state() {
  printf '%s\n' \
    'scenario=guided' \
    'view=state' \
    'previous_final_records=6' \
    'current_final_records=4' \
    'expected_effects=6' \
    'committed_effects=4' \
    'terminal_receipts=4' \
    'unknown_receipts=0' \
    'publication_gate=exit-status-only'
}

emit_guided_retry() {
  printf '%s\n' \
    'scenario=guided' \
    'view=retry' \
    'retry_scope=entire-batch' \
    'operation_id_policy=per-attempt' \
    'committed_before_retry=4' \
    'already_committed_replay_candidates=4' \
    'retry_attempt_limit=unbounded' \
    'duplicate_effect_risk=true'
}

emit_guided_recovery() {
  printf '%s\n' \
    'scenario=guided' \
    'recovery=recorded' \
    'framing=nul-delimited-records' \
    'argument_transport=quoted-array' \
    'option_boundary=double-dash' \
    'producer_status_policy=explicit' \
    'publication=validated-candidate-then-rename' \
    'retry=missing-idempotent-operations-only' \
    'prior_complete_report=restored-before-regeneration'
}

emit_guided_verification() {
  printf '%s\n' \
    'scenario=guided' \
    'verification=complete' \
    'input_records=6' \
    'unique_terminal_receipts=6' \
    'published_records=6' \
    'duplicate_effects=0' \
    'producer_failure_returns_nonzero=true' \
    'prior_final_preserved_on_failure=true' \
    'operation_verified=true'
}

emit_independent_input() {
  printf '%s\n' \
    'model=deterministic-bash-automation' \
    'scenario=independent' \
    'view=raw-input' \
    'operation=reconcile-release-generation-2041' \
    'expected_records=5' \
    'run_a_runner=ci-runner-east' \
    'run_a_local_marker=pending' \
    'run_a_observation=request-deadline-expired-after-ten-seconds' \
    'run_b_runner=ci-runner-west' \
    'run_b_trigger=automatic-whole-job-retry' \
    'remote_observation=one-delayed-receipt-and-two-accepted-attempt-records' \
    'final_observation=release-generation-visible'
}

emit_independent_expansion() {
  printf '%s\n' \
    'scenario=independent' \
    'view=expansion' \
    'logical_records=5' \
    'arguments_received=5' \
    'space_record_preserved=true' \
    'wildcard_record_preserved=true' \
    'leading_dash_preserved_as_operand=true' \
    'empty_value_preserved=true' \
    'record_protocol=nul-delimited-and-quoted-array'
}

emit_independent_pipeline() {
  printf '%s\n' \
    'scenario=independent' \
    'view=pipeline' \
    'producer_status=0' \
    'consumer_status=0' \
    'pipefail_enabled=true' \
    'selected_pipeline_status=0' \
    'partial_output_exists=false' \
    'candidate_validated=true'
}

emit_independent_state() {
  printf '%s\n' \
    'scenario=independent' \
    'view=state' \
    'run_a_local_state=pending' \
    'run_a_remote_state=committed' \
    'run_b_local_state=pending' \
    'run_b_remote_state=accepted-duplicate-intent' \
    'local_lock_domain=runner-filesystem' \
    'shared_lock_domain=none' \
    'authoritative_owner=remote-release-service'
}

emit_independent_retry() {
  printf '%s\n' \
    'scenario=independent' \
    'view=retry' \
    'run_a_operation_id=attempt-east-771' \
    'run_b_operation_id=attempt-west-228' \
    'logical_intent=release-generation-2041' \
    'idempotency_scope=attempt-not-intent' \
    'timeout_classification=definite-failure' \
    'authoritative_query_before_retry=false' \
    'retry_attempt_limit=3'
}

emit_independent_recovery() {
  printf '%s\n' \
    'scenario=independent' \
    'recovery=recorded' \
    'admission=paused-for-generation-2041' \
    'authoritative_query=by-logical-intent' \
    'run_a_outcome=reconciled-committed' \
    'run_b_outcome=reconciled-duplicate-and-suppressed' \
    'future_operation_id=stable-per-logical-intent' \
    'local_coordination=runner-defense-in-depth' \
    'remote_coordination=server-idempotency-and-status-query'
}

emit_independent_verification() {
  printf '%s\n' \
    'scenario=independent' \
    'verification=complete' \
    'release_generation=2041' \
    'visible_release_generations=1' \
    'unique_committed_logical_effects=1' \
    'unknown_outcomes=0' \
    'resume_state=complete' \
    'second_identical_run_additional_effects=0' \
    'operation_verified=true'
}

emit_case_view() {
  local scenario=$1
  local view=$2

  case "$scenario:$view" in
    guided:input) emit_guided_input ;;
    guided:expansion) emit_guided_expansion ;;
    guided:pipeline) emit_guided_pipeline ;;
    guided:state) emit_guided_state ;;
    guided:retry) emit_guided_retry ;;
    guided:recovery) emit_guided_recovery ;;
    guided:verification) emit_guided_verification ;;
    independent:input) emit_independent_input ;;
    independent:expansion) emit_independent_expansion ;;
    independent:pipeline) emit_independent_pipeline ;;
    independent:state) emit_independent_state ;;
    independent:retry) emit_independent_retry ;;
    independent:recovery) emit_independent_recovery ;;
    independent:verification) emit_independent_verification ;;
    *) usage ;;
  esac
}

main() {
  (($# >= 1 && $# <= 2)) || { usage; return 64; }

  if [[ $1 == baseline ]]; then
    (($# == 1)) || { usage; return 64; }
    emit_baseline
    return 0
  fi

  (($# == 2)) || { usage; return 64; }
  case $1 in guided|independent) ;; *) usage; return 64 ;; esac
  case $2 in input|expansion|pipeline|state|retry|recovery|verification) ;; *) usage; return 64 ;; esac
  emit_case_view "$1" "$2"
}

main "$@"
