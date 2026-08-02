#!/usr/bin/env python3
"""Deterministic, offline API-contract model for LES-0021.

This program opens no socket, reads no environment variable, uses no clock or
random source, and changes no file. The guarded Bash wrapper owns all state.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import dataclass
from typing import Final, Mapping, Sequence


MODEL_VERSION: Final[str] = "1"
SUPPORTED_MEDIA_TYPE: Final[str] = "application/json"
PROBLEM_MEDIA_TYPE: Final[str] = "application/problem+json"
SUPPORTED_API_VERSION: Final[int] = 1


class ContractViolation(ValueError):
    """The caller supplied a request that does not satisfy the contract."""


@dataclass(frozen=True)
class ReleaseRequest:
    service: str
    target: str
    replicas: int


def emit(fields: Sequence[tuple[str, object]]) -> None:
    """Print a stable newline-delimited evidence record."""
    for key, value in fields:
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        else:
            rendered = str(value)
        if "\n" in rendered or "\r" in rendered:
            raise RuntimeError(f"multiline model field rejected: {key}")
        print(f"{key}={rendered}")


def parse_release(raw: str) -> ReleaseRequest:
    """Parse JSON and reject unknown fields, wrong types, and bad ranges."""
    try:
        value = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise ContractViolation(f"malformed-json-at-character-{exc.pos}") from exc
    if not isinstance(value, dict):
        raise ContractViolation("top-level-value-must-be-object")
    expected = {"service", "target", "replicas"}
    actual = set(value)
    if actual != expected:
        raise ContractViolation("object-fields-do-not-match-contract")
    service = value["service"]
    target = value["target"]
    replicas = value["replicas"]
    if not isinstance(service, str) or not service or len(service) > 40:
        raise ContractViolation("service-must-be-nonempty-string-at-most-40-characters")
    if not isinstance(target, str) or not target or len(target) > 80:
        raise ContractViolation("target-must-be-nonempty-string-at-most-80-characters")
    if type(replicas) is not int or not 1 <= replicas <= 20:
        raise ContractViolation("replicas-must-be-integer-between-1-and-20")
    return ReleaseRequest(service=service, target=target, replicas=replicas)


def canonical_request(request: ReleaseRequest) -> bytes:
    value = {
        "replicas": request.replicas,
        "service": request.service,
        "target": request.target,
    }
    return json.dumps(
        value,
        ensure_ascii=False,
        allow_nan=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def command_baseline() -> None:
    raw = '{"service":"caf\\u00e9-api","target":"2026.08.02","replicas":3}'
    request = parse_release(raw)
    body = canonical_request(request)
    emit(
        (
            ("record", "baseline"),
            ("model_version", MODEL_VERSION),
            ("method", "POST"),
            ("request_content_type", SUPPORTED_MEDIA_TYPE),
            ("request_accept", SUPPORTED_MEDIA_TYPE),
            ("request_schema_version", SUPPORTED_API_VERSION),
            ("parsed_replicas_type", type(request.replicas).__name__),
            ("parsed_replicas", request.replicas),
            ("unicode_service", request.service),
            ("utf8_byte_count", len(body)),
            ("canonical_sha256", hashlib.sha256(body).hexdigest()),
            ("response_status", 201),
            ("response_content_type", SUPPORTED_MEDIA_TYPE),
            ("response_schema_version", SUPPORTED_API_VERSION),
            ("consumer_readback", "valid"),
        )
    )


def command_case(case_name: str) -> None:
    if case_name not in {"guided", "independent"}:
        raise ContractViolation("case-not-allowlisted")
    emit(
        (
            ("record", "case_registration"),
            ("case", case_name),
            ("answer_key", "not-provided"),
            ("external_network", "unused"),
        )
    )


def command_scenario() -> None:
    # Raw independent inputs only. Do not add derived outcome or solution fields.
    raw_payload = {
        "replicas": 3,
        "service": "payments-api",
        "target": "2026.08.02",
    }
    emit(
        (
            ("record", "scenario_input"),
            ("case", "independent"),
            ("method", "POST"),
            ("target", "/v1/releases"),
            ("content_type", SUPPORTED_MEDIA_TYPE),
            ("accept", SUPPORTED_MEDIA_TYPE),
            ("api_version", SUPPORTED_API_VERSION),
            ("idempotency_key", "deploy-417"),
            ("client_deadline_ms", 250),
            ("payload_json", json.dumps(raw_payload, sort_keys=True, separators=(",", ":"))),
            ("page_limit", 2),
        )
    )


def guided_view(view: str) -> Sequence[tuple[str, object]]:
    views: Mapping[str, Sequence[tuple[str, object]]] = {
        "request": (
            ("payload_json", '{"service":"billing-api","target":"2026.08.02","replicas":"3"}'),
            ("observed_replicas_json_type", "string"),
            ("required_replicas_json_type", "integer"),
        ),
        "contract": (
            ("response_status", 422),
            ("response_content_type", PROBLEM_MEDIA_TYPE),
            ("problem_type", "https://errors.example.invalid/invalid-field"),
            ("problem_title", "Request field failed validation"),
            ("problem_field", "/replicas"),
            ("problem_code", "integer-required"),
        ),
        "operation": (
            ("mutation_attempts", 0),
            ("state_owner", "modeled-release-service"),
            ("authoritative_state", "absent"),
        ),
        "page": (
            ("page_strategy", "snapshot-cursor"),
            ("page_one_ids", "rel-101,rel-102"),
            ("page_two_ids", "rel-103,rel-104"),
            ("snapshot_version", "inventory-9"),
            ("duplicates", 0),
        ),
        "limit": (
            ("response_status", 429),
            ("retry_after_seconds", 2),
            ("client_attempt_budget_remaining", 1),
            ("fleet_retry_budget_percent", 8),
        ),
        "webhook": (
            ("signature_algorithm", "hmac-sha256-model"),
            ("signed_components", "event-id,timestamp,raw-body"),
            ("timestamp_age_seconds", 12),
            ("replay_cache_result", "first-delivery"),
        ),
    }
    return views[view]


def independent_view(view: str) -> Sequence[tuple[str, object]]:
    views: Mapping[str, Sequence[tuple[str, object]]] = {
        "request": (
            ("decoded_top_level_type", "object"),
            ("decoded_replicas_type", "integer"),
            ("unknown_fields", 0),
            ("schema_validation", "accepted"),
        ),
        "contract": (
            ("selected_api_version", 1),
            ("request_media_type", SUPPORTED_MEDIA_TYPE),
            ("response_media_type", SUPPORTED_MEDIA_TYPE),
            ("response_schema_compatible", True),
        ),
        "operation": (
            ("client_result", "deadline-exceeded-before-response"),
            ("logical_operation_id", "deploy-417"),
            ("authoritative_state", "committed"),
            ("service_attempt_count", 1),
            ("local_receipt", "missing"),
        ),
        "page": (
            ("page_strategy", "snapshot-cursor"),
            ("snapshot_version", "inventory-12"),
            ("page_one_ids", "rel-201,rel-202"),
            ("page_two_ids", "rel-203,rel-204"),
            ("duplicates", 0),
            ("omissions", 0),
        ),
        "limit": (
            ("response_status", 429),
            ("retry_after_seconds", 2),
            ("remaining_deadline_ms", 900),
            ("retry_eligible", False),
            ("reason", "mutation-outcome-must-be-reconciled-first"),
        ),
        "webhook": (
            ("event_id", "evt-417"),
            ("signature_valid", True),
            ("timestamp_age_seconds", 11),
            ("replay_cache_result", "already-processed"),
            ("second_effect", False),
        ),
    }
    return views[view]


def command_observe(case_name: str, view: str) -> None:
    if case_name not in {"guided", "independent"}:
        raise ContractViolation("case-not-allowlisted")
    if view not in {"request", "contract", "operation", "page", "limit", "webhook"}:
        raise ContractViolation("view-not-allowlisted")
    details = guided_view(view) if case_name == "guided" else independent_view(view)
    emit((("record", "observation"), ("case", case_name), ("view", view), *details))


def command_recover(case_name: str) -> None:
    if case_name == "guided":
        fields = (
            ("action", "reject-invalid-request-before-mutation"),
            ("problem_status", 422),
            ("corrected_replicas_type", "integer"),
            ("new_request_requires-new-review", True),
            ("operation_success", True),
        )
    elif case_name == "independent":
        fields = (
            ("action", "reconcile-by-stable-idempotency-key"),
            ("logical_operation_id", "deploy-417"),
            ("reconciled_state", "committed"),
            ("additional_mutation_attempts", 0),
            ("local_receipt", "published-after-readback"),
            ("operation_success", True),
        )
    else:
        raise ContractViolation("case-not-allowlisted")
    emit((("record", "recovery"), ("case", case_name), *fields))


def command_verify(case_name: str) -> None:
    if case_name not in {"guided", "independent"}:
        raise ContractViolation("case-not-allowlisted")
    expected_attempts = 0 if case_name == "guided" else 1
    emit(
        (
            ("record", "verification"),
            ("case", case_name),
            ("operation_success", True),
            ("service_mutation_attempts", expected_attempts),
            ("duplicate_effects", 0),
            ("schema_contract", "valid"),
            ("content_negotiation", "valid"),
            ("pagination_consistency", "valid"),
            ("rate_limit_policy", "bounded"),
            ("problem_details", "typed-and-sanitized"),
            ("version_contract", "compatible"),
            ("webhook_replay_effects", 0),
            ("consumer_readback", "valid"),
            ("verification_scope", "deterministic-offline-model-only"),
        )
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(prog="api_contract_model.py")
    subparsers = result.add_subparsers(dest="command", required=True)
    subparsers.add_parser("baseline")
    case_parser = subparsers.add_parser("case")
    case_parser.add_argument("--name", required=True, choices=("guided", "independent"))
    subparsers.add_parser("scenario")
    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    observe_parser.add_argument(
        "--view", required=True, choices=("request", "contract", "operation", "page", "limit", "webhook")
    )
    recover_parser = subparsers.add_parser("recover")
    recover_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--case", required=True, choices=("guided", "independent"))
    return result


def main() -> int:
    args = parser().parse_args()
    try:
        if args.command == "baseline":
            command_baseline()
        elif args.command == "case":
            command_case(args.name)
        elif args.command == "scenario":
            command_scenario()
        elif args.command == "observe":
            command_observe(args.case, args.view)
        elif args.command == "recover":
            command_recover(args.case)
        elif args.command == "verify":
            command_verify(args.case)
        else:
            raise AssertionError("unreachable command")
    except ContractViolation as exc:
        print(f"model_error={exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
