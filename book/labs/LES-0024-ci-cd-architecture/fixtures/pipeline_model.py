#!/usr/bin/env python3
"""Deterministic, offline CI/CD control-plane model for LES-0024.

The model uses only in-memory standard-library values. It never opens a socket,
starts another process, installs software, reads credentials, contacts hosted CI,
pushes an artifact, or changes a deployment. The Bash controller owns all local
state and treats this program as a small evidence generator.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from collections.abc import Iterable
from pathlib import Path


SOURCE_BYTES = b"service: atlas-demo\nrevision: 8f43c92\n"
LOCK_BYTES = b"runtime=python-stdlib-model@1\n"
PIPELINE_V1 = b"checkout>test>package>approve>canary>promote\n"
PIPELINE_V2 = b"checkout>lint>test>package>policy>approve>canary>promote\n"
RUNNER_IMAGE = b"ubuntu-24.04-local-runner-model@sha256:pinned\n"
SOURCE_REVISION = "8f43c92"
LOGICAL_RELEASE_ID = "release-882"
CURRENT_RUN_ID = "run-024-current"
REPEAT_RUN_ID = "run-024-repeat"
PREVIOUS_RUN_ID = "run-023-previous"
EXPECTED_SUBJECT = "repo:atlas:ref:main"
FAULT_SUBJECT = "repo:atlas:ref:feature/cache-test"
DEPLOY_AUDIENCE = "local-deployment-controller"
FAULT_AUDIENCE = "local-artifact-cache"


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def canonical_json(value: object) -> bytes:
    return (
        json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
        + "\n"
    ).encode("utf-8")


def artifact(definition: bytes) -> bytes:
    return canonical_json(
        {
            "application": "atlas-demo",
            "lockSha256": sha256(LOCK_BYTES),
            "pipelineDefinitionSha256": sha256(definition),
            "runnerImageSha256": sha256(RUNNER_IMAGE),
            "schemaVersion": 1,
            "sourceRevision": SOURCE_REVISION,
            "sourceSha256": sha256(SOURCE_BYTES),
            "testResult": "passed",
        }
    )


CURRENT_ARTIFACT = artifact(PIPELINE_V2)
PREVIOUS_ARTIFACT = artifact(PIPELINE_V1)


def render(value: object) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (dict, list)):
        return canonical_json(value).decode("utf-8").strip()
    return str(value)


def emit(pairs: Iterable[tuple[str, object]]) -> None:
    for key, value in pairs:
        rendered = render(value)
        if "\n" in rendered or "\r" in rendered:
            raise ValueError(f"multiline value refused for {key}")
        print(f"{key}={rendered}")


def record_mapping(pairs: Iterable[tuple[str, object]]) -> dict[str, str]:
    result: dict[str, str] = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate expected field: {key}")
        result[key] = render(value)
    return result


def read_record(path_value: str) -> tuple[bytes, dict[str, str]]:
    path = Path(path_value)
    data = path.read_bytes()
    if not data or len(data) > 65_536 or not data.endswith(b"\n"):
        raise ValueError(f"record size or terminator invalid: {path.name}")
    text = data.decode("utf-8")
    result: dict[str, str] = {}
    for line in text.splitlines():
        if not line or "=" not in line:
            raise ValueError(f"record line invalid: {path.name}")
        key, value = line.split("=", 1)
        if not key or key in result or "\x00" in value:
            raise ValueError(f"record field invalid: {path.name}")
        result[key] = value
    return data, result


def require_exact_record(
    actual: dict[str, str],
    expected_pairs: Iterable[tuple[str, object]],
    label: str,
) -> None:
    expected = record_mapping(expected_pairs)
    if actual != expected:
        missing = sorted(set(expected) - set(actual))
        extra = sorted(set(actual) - set(expected))
        changed = sorted(
            key for key in set(actual) & set(expected) if actual[key] != expected[key]
        )
        raise ValueError(
            f"{label} mismatch missing={missing} extra={extra} changed={changed}"
        )


def require_digest(value: str, label: str) -> str:
    if len(value) != 64 or any(character not in "0123456789abcdef" for character in value):
        raise ValueError(f"{label} must be a lowercase SHA-256 digest")
    return value


def baseline_pairs() -> list[tuple[str, object]]:
    second_attempt = artifact(PIPELINE_V2)
    return [
        ("record", "baseline"),
        ("logical_release_id", LOGICAL_RELEASE_ID),
        ("source_revision", SOURCE_REVISION),
        ("source_sha256", sha256(SOURCE_BYTES)),
        ("pipeline_definition_sha256", sha256(PIPELINE_V2)),
        ("lock_sha256", sha256(LOCK_BYTES)),
        ("runner_image_sha256", sha256(RUNNER_IMAGE)),
        ("job_graph", "checkout,lint,test,package,policy,approve,canary,promote"),
        ("runner_workspace_count", 2),
        ("runner_workspaces_distinct", True),
        ("runner_workspace_separation", "private-paths-same-uid"),
        ("workspace_isolation_proven", False),
        ("runner_workspace_reuse", False),
        ("cache_key_fields", "source,definition,lock,runner-image,job-policy"),
        ("cache_key_complete", True),
        ("build_attempt_a", CURRENT_RUN_ID),
        ("build_attempt_b", REPEAT_RUN_ID),
        ("build_attempt_ids_distinct", CURRENT_RUN_ID != REPEAT_RUN_ID),
        ("artifact_sha256", sha256(CURRENT_ARTIFACT)),
        ("repeat_artifact_sha256", sha256(second_attempt)),
        ("artifact_byte_identical", CURRENT_ARTIFACT == second_attempt),
        ("attempt_id_embedded_in_artifact", False),
        ("quality_gates", "lint=passed,test=passed,policy=passed"),
        ("execution_subject", EXPECTED_SUBJECT),
        ("execution_audience", DEPLOY_AUDIENCE),
        ("approval_actor", "local-reviewer-model"),
        ("approval_separated_from_executor", True),
        ("approval_artifact_sha256", sha256(CURRENT_ARTIFACT)),
        ("approval_environment", "local-production-model"),
        ("promotion_concurrency", 1),
        ("promotion_count", 1),
        ("duplicate_promotions", 0),
        ("production_artifact_sha256", sha256(CURRENT_ARTIFACT)),
        ("user_verification", "passed"),
        ("network_calls", 0),
        ("hosted_ci_calls", 0),
        ("registry_calls", 0),
        ("cloud_calls", 0),
    ]


def baseline() -> None:
    emit(baseline_pairs())


def case_pairs(name: str, baseline_record_sha256: str) -> list[tuple[str, object]]:
    family = "failed-canary" if name == "guided" else "answer-isolated"
    return [
        ("record", "case_registration"),
        ("case", name),
        ("case_family", family),
        ("logical_release_id", LOGICAL_RELEASE_ID),
        ("baseline_record_sha256", baseline_record_sha256),
        ("answer_key", "not-provided"),
    ]


def register_case(name: str, baseline_record_sha256: str) -> None:
    emit(case_pairs(name, baseline_record_sha256))


def independent_scenario() -> None:
    """Emit only configured/raw inputs, never a model answer or decision."""

    emit(
        [
            ("record", "scenario_input"),
            ("case", "independent"),
            ("logical_release_id", LOGICAL_RELEASE_ID),
            ("source_revision", SOURCE_REVISION),
            ("source_sha256", sha256(SOURCE_BYTES)),
            ("pipeline_definition_sha256", sha256(PIPELINE_V2)),
            ("reported_cache_key_fields", "source,lock,runner-image,job-policy"),
            ("reported_cache_entry", "present"),
            ("candidate_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("runner_attempt_count", 2),
            ("runner_a_workspace", "runner-a"),
            ("runner_b_workspace", "runner-b"),
            ("expected_identity_subject", EXPECTED_SUBJECT),
            ("presented_identity_subject", FAULT_SUBJECT),
            ("required_identity_audience", DEPLOY_AUDIENCE),
            ("presented_identity_audience", FAULT_AUDIENCE),
            ("review_record_count", 1),
            ("review_record_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("requested_environment", "local-production-model"),
            ("network_policy", "none"),
        ]
    )


def guided_observation(view: str) -> None:
    common = [("record", "observation"), ("case", "guided"), ("view", view)]
    views: dict[str, list[tuple[str, object]]] = {
        "graph": [
            ("trigger", "reviewed-main-revision"),
            ("jobs", "checkout,lint,test,package,policy,approve,canary,promote"),
            ("failed_job", "canary"),
            ("downstream_promote_started", False),
        ],
        "runner": [
            ("workspace_a", "runner-a"),
            ("workspace_b", "runner-b"),
            ("workspaces_distinct", True),
            ("workspace_permissions", "0700-current-uid"),
            ("workspace_isolation_proven", False),
            ("workspace_reused", False),
        ],
        "cache": [
            ("cache_key_fields", "source,definition,lock,runner-image,job-policy"),
            ("cache_key_complete", True),
            ("cache_entry_definition_match", True),
            ("cache_hit_is_correctness_proof", False),
        ],
        "artifact": [
            ("candidate_artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("test_artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("approved_artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("artifact_identity_preserved", True),
        ],
        "identity": [
            ("subject", EXPECTED_SUBJECT),
            ("audience", DEPLOY_AUDIENCE),
            ("environment_scope", "local-production-model"),
            ("identity_contract_match", True),
            ("credential_material", "none-local-model"),
        ],
        "approval": [
            ("review_actor", "local-reviewer-model"),
            ("execution_actor", "local-runner-model"),
            ("separation_of_duties", True),
            ("artifact_binding_match", True),
            ("environment_binding_match", True),
            ("review_fresh_for_run", True),
        ],
        "deployment": [
            ("canary_started", True),
            ("canary_ready", False),
            ("canary_user_check", "failed"),
            ("promote_job_started", False),
            ("production_changed", False),
            ("production_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("containment", "stop-canary-retain-known-production"),
        ],
    }
    emit(common + views[view])


def independent_observation(view: str) -> None:
    common = [("record", "observation"), ("case", "independent"), ("view", view)]
    views: dict[str, list[tuple[str, object]]] = {
        "graph": [
            ("logical_release_id", LOGICAL_RELEASE_ID),
            ("active_attempts", 2),
            ("attempt_a_stage", "promotion-gate"),
            ("attempt_b_stage", "promotion-gate"),
            ("shared_release_lock_owner", "none"),
            ("duplicate_effect_risk", True),
        ],
        "runner": [
            ("workspace_a", "runner-a"),
            ("workspace_b", "runner-b"),
            ("workspaces_distinct", True),
            ("workspace_isolation_proven", False),
            ("build_state_shared", False),
            ("promotion_state_shared_without_lock", True),
        ],
        "cache": [
            ("cache_result", "hit"),
            ("cache_key_fields", "source,lock,runner-image,job-policy"),
            ("definition_digest_in_key", False),
            ("lock_digest_in_key", True),
            ("runner_image_digest_in_key", True),
            ("job_policy_in_key", True),
            ("served_pipeline_definition_sha256", sha256(PIPELINE_V1)),
            ("current_pipeline_definition_sha256", sha256(PIPELINE_V2)),
            ("cache_entry_matches_current_contract", False),
        ],
        "artifact": [
            ("candidate_source", "cache-entry"),
            ("candidate_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("current_contract_artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("source_revision_equal", True),
            ("pipeline_definition_equal", False),
            ("candidate_matches_current_contract", False),
        ],
        "identity": [
            ("expected_subject", EXPECTED_SUBJECT),
            ("presented_subject", FAULT_SUBJECT),
            ("subject_match", False),
            ("required_audience", DEPLOY_AUDIENCE),
            ("presented_audience", FAULT_AUDIENCE),
            ("audience_match", False),
            ("environment_scope_match", False),
        ],
        "approval": [
            ("review_record_count", 1),
            ("review_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("review_pipeline_definition_sha256", sha256(PIPELINE_V1)),
            ("review_matches_candidate_bytes", True),
            ("review_matches_current_contract", False),
            ("review_reusable_for_current_run", False),
        ],
        "deployment": [
            ("promotion_allowed", False),
            ("production_changed", False),
            ("production_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
            ("duplicate_promotions", 0),
            ("user_verification", "known-production-still-serving"),
            ("required_next_state", "reconcile-cache-identity-approval-and-lock"),
        ],
    }
    emit(common + views[view])


def prediction_pairs(external_digest: str) -> list[tuple[str, object]]:
    return [
        ("record", "prediction_acknowledgment"),
        ("case", "independent"),
        ("external_prediction_sha256", external_digest),
        ("content_stored", False),
        ("review_required", True),
    ]


def acknowledge_prediction(external_digest: str) -> None:
    emit(prediction_pairs(require_digest(external_digest, "external prediction digest")))


def experiment_pairs(prediction_record_sha256: str) -> list[tuple[str, object]]:
    return [
        ("record", "experiment"),
        ("case", "independent"),
        ("experiment", "cache-key"),
        ("prediction_record_sha256", prediction_record_sha256),
        ("declared_variable", "pipeline-definition-digest-in-key"),
        ("control_key_fields", "source,lock,runner-image,job-policy"),
        ("control_definition_digest_in_key", False),
        ("control_cache_result", "stale-hit"),
        ("control_artifact_sha256", sha256(PREVIOUS_ARTIFACT)),
        ("treatment_key_fields", "source,definition,lock,runner-image,job-policy"),
        ("treatment_definition_digest_in_key", True),
        ("treatment_cache_result", "miss-build-current"),
        ("treatment_artifact_sha256", sha256(CURRENT_ARTIFACT)),
        ("unchanged_source_sha256", sha256(SOURCE_BYTES)),
        ("unchanged_lock_sha256", sha256(LOCK_BYTES)),
        ("unchanged_runner_image_sha256", sha256(RUNNER_IMAGE)),
        ("unchanged_job_policy", "lint,test,policy"),
        ("single_variable_changed", True),
        ("proof_limit", "deterministic-local-model-only"),
        ("network_calls", 0),
        ("hosted_ci_calls", 0),
        ("registry_calls", 0),
        ("cloud_calls", 0),
    ]


def experiment_cache_key(prediction_record_sha256: str) -> None:
    emit(
        experiment_pairs(
            require_digest(prediction_record_sha256, "prediction record digest")
        )
    )


def recovery_pairs(
    case: str,
    baseline_record_sha256: str,
    case_record_sha256: str,
    prediction_record_sha256: str | None = None,
    experiment_record_sha256: str | None = None,
) -> list[tuple[str, object]]:
    common: list[tuple[str, object]] = [
        ("record", "recovery"),
        ("case", case),
        ("baseline_record_sha256", baseline_record_sha256),
        ("case_record_sha256", case_record_sha256),
    ]
    if case == "guided":
        details = [
            ("evidence_preserved", True),
            ("failed_canary_removed", True),
            ("known_production_retained", True),
            ("probe_contract_corrected", True),
            ("artifact_rebuilt", False),
            ("artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("fresh_canary_ready", True),
            ("promotion_count", 1),
            ("duplicate_promotions", 0),
            ("user_verification", "passed"),
            ("operation_success", True),
        ]
    else:
        if prediction_record_sha256 is None or experiment_record_sha256 is None:
            raise ValueError("independent recovery requires prediction and experiment")
        details = [
            ("prediction_record_sha256", prediction_record_sha256),
            ("experiment_record_sha256", experiment_record_sha256),
            ("evidence_preserved", True),
            ("quarantined_cache_entries", 1),
            ("cache_key_fields", "source,definition,lock,runner-image,job-policy"),
            ("cache_key_complete", True),
            ("release_lock_scope", LOGICAL_RELEASE_ID),
            ("serialized_attempts", True),
            ("execution_subject", EXPECTED_SUBJECT),
            ("execution_audience", DEPLOY_AUDIENCE),
            ("fresh_review_bound_to_artifact", True),
            ("artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("fresh_canary_ready", True),
            ("promotion_count", 1),
            ("duplicate_promotions", 0),
            ("user_verification", "passed"),
            ("operation_success", True),
        ]
    return common + details


def recover(
    case: str,
    baseline_record_sha256: str,
    case_record_sha256: str,
    prediction_record_sha256: str | None,
    experiment_record_sha256: str | None,
) -> None:
    if prediction_record_sha256 is not None:
        prediction_record_sha256 = require_digest(
            prediction_record_sha256, "prediction record digest"
        )
    if experiment_record_sha256 is not None:
        experiment_record_sha256 = require_digest(
            experiment_record_sha256, "experiment record digest"
        )
    emit(
        recovery_pairs(
            case,
            require_digest(baseline_record_sha256, "baseline record digest"),
            require_digest(case_record_sha256, "case record digest"),
            prediction_record_sha256,
            experiment_record_sha256,
        )
    )


def verify_records(
    baseline_path: str,
    case_path: str,
    recovery_path: str,
    prediction_path: str | None,
    experiment_path: str | None,
) -> None:
    baseline_bytes, baseline_record = read_record(baseline_path)
    require_exact_record(baseline_record, baseline_pairs(), "baseline")
    baseline_digest = sha256(baseline_bytes)

    case_bytes, case_record = read_record(case_path)
    case_name = case_record.get("case", "")
    if case_name not in {"guided", "independent"}:
        raise ValueError("case identity invalid")
    require_exact_record(case_record, case_pairs(case_name, baseline_digest), "case")
    case_digest = sha256(case_bytes)

    prediction_digest: str | None = None
    experiment_digest: str | None = None
    if case_name == "independent":
        if prediction_path is None or experiment_path is None:
            raise ValueError("independent verification requires experiment records")
        prediction_bytes, prediction_record = read_record(prediction_path)
        external_digest = prediction_record.get("external_prediction_sha256", "")
        require_digest(external_digest, "stored external prediction digest")
        require_exact_record(
            prediction_record,
            prediction_pairs(external_digest),
            "prediction acknowledgment",
        )
        prediction_digest = sha256(prediction_bytes)
        experiment_bytes, experiment_record = read_record(experiment_path)
        require_exact_record(
            experiment_record,
            experiment_pairs(prediction_digest),
            "experiment",
        )
        experiment_digest = sha256(experiment_bytes)
    elif prediction_path is not None or experiment_path is not None:
        raise ValueError("guided verification refuses independent records")

    recovery_bytes, recovery_record = read_record(recovery_path)
    require_exact_record(
        recovery_record,
        recovery_pairs(
            case_name,
            baseline_digest,
            case_digest,
            prediction_digest,
            experiment_digest,
        ),
        "recovery",
    )
    recovery_digest = sha256(recovery_bytes)

    artifact_identity_valid = (
        baseline_record["artifact_sha256"] == sha256(CURRENT_ARTIFACT)
        and recovery_record["artifact_sha256"] == baseline_record["artifact_sha256"]
    )
    identity_scope_valid = (
        baseline_record["execution_subject"] == EXPECTED_SUBJECT
        and baseline_record["execution_audience"] == DEPLOY_AUDIENCE
        and (
            case_name == "guided"
            or (
                recovery_record["execution_subject"] == EXPECTED_SUBJECT
                and recovery_record["execution_audience"] == DEPLOY_AUDIENCE
            )
        )
    )
    approval_valid = (
        baseline_record["approval_artifact_sha256"] == baseline_record["artifact_sha256"]
        and (
            case_name == "guided"
            or recovery_record["fresh_review_bound_to_artifact"] == "true"
        )
    )
    operation_success = (
        recovery_record["operation_success"] == "true"
        and recovery_record["fresh_canary_ready"] == "true"
        and recovery_record["user_verification"] == "passed"
        and artifact_identity_valid
        and identity_scope_valid
        and approval_valid
    )
    emit(
        [
            ("record", "verification"),
            ("case", case_name),
            ("baseline_record_sha256", baseline_digest),
            ("case_record_sha256", case_digest),
            ("recovery_record_sha256", recovery_digest),
            ("controller_state", "converged" if operation_success else "invalid"),
            ("operation_success", operation_success),
            ("source_revision", SOURCE_REVISION),
            ("pipeline_definition_sha256", sha256(PIPELINE_V2)),
            ("runner_workspaces", "distinct-private-current-uid"),
            ("workspace_isolation_proven", False),
            ("workspace_reuse", False),
            ("cache_key_complete", baseline_record["cache_key_complete"] == "true"),
            ("artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("artifact_identity", "verified" if artifact_identity_valid else "invalid"),
            ("identity_subject", EXPECTED_SUBJECT),
            ("identity_audience", DEPLOY_AUDIENCE),
            ("identity_scope", "valid" if identity_scope_valid else "invalid"),
            ("approval_binding", "valid" if approval_valid else "invalid"),
            ("promotion_lock_scope", LOGICAL_RELEASE_ID),
            ("promotion_count", int(recovery_record["promotion_count"])),
            ("duplicate_promotions", int(recovery_record["duplicate_promotions"])),
            ("production_artifact_sha256", sha256(CURRENT_ARTIFACT)),
            ("rollback_target_preserved", True),
            ("user_verification", recovery_record["user_verification"]),
            ("network_calls", 0),
            ("hosted_ci_calls", 0),
            ("registry_calls", 0),
            ("cloud_calls", 0),
        ]
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="offline LES-0024 CI/CD model")
    subparsers = result.add_subparsers(dest="command", required=True)
    subparsers.add_parser("baseline")
    case_parser = subparsers.add_parser("case")
    case_parser.add_argument("--name", required=True, choices=("guided", "independent"))
    case_parser.add_argument("--baseline-record-sha256", required=True)
    subparsers.add_parser("scenario")
    prediction_parser = subparsers.add_parser("acknowledge-predictions")
    prediction_parser.add_argument("--external-sha256", required=True)
    experiment_parser = subparsers.add_parser("experiment")
    experiment_parser.add_argument("--name", required=True, choices=("cache-key",))
    experiment_parser.add_argument("--prediction-record-sha256", required=True)
    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    observe_parser.add_argument(
        "--view",
        required=True,
        choices=("graph", "runner", "cache", "artifact", "identity", "approval", "deployment"),
    )
    recover_parser = subparsers.add_parser("recover")
    recover_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    recover_parser.add_argument("--baseline-record-sha256", required=True)
    recover_parser.add_argument("--case-record-sha256", required=True)
    recover_parser.add_argument("--prediction-record-sha256")
    recover_parser.add_argument("--experiment-record-sha256")
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--baseline-record", required=True)
    verify_parser.add_argument("--case-record", required=True)
    verify_parser.add_argument("--recovery-record", required=True)
    verify_parser.add_argument("--prediction-record")
    verify_parser.add_argument("--experiment-record")
    return result


def main() -> None:
    args = parser().parse_args()
    if args.command == "baseline":
        baseline()
    elif args.command == "case":
        register_case(
            args.name,
            require_digest(args.baseline_record_sha256, "baseline record digest"),
        )
    elif args.command == "scenario":
        independent_scenario()
    elif args.command == "acknowledge-predictions":
        acknowledge_prediction(args.external_sha256)
    elif args.command == "experiment":
        experiment_cache_key(args.prediction_record_sha256)
    elif args.command == "observe":
        if args.case == "guided":
            guided_observation(args.view)
        else:
            independent_observation(args.view)
    elif args.command == "recover":
        recover(
            args.case,
            args.baseline_record_sha256,
            args.case_record_sha256,
            args.prediction_record_sha256,
            args.experiment_record_sha256,
        )
    elif args.command == "verify":
        verify_records(
            args.baseline_record,
            args.case_record,
            args.recovery_record,
            args.prediction_record,
            args.experiment_record,
        )


if __name__ == "__main__":
    main()
