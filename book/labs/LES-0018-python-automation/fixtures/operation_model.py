#!/usr/bin/env python3
"""Deterministic offline evidence model for LES-0018.

The program opens no file or socket and imports only the Python standard
library. It prints fixed key-value evidence for a guarded Bash controller.
"""

from __future__ import annotations

import argparse
from collections.abc import Iterable


CASES = ("guided", "independent")
VIEWS = ("operation", "input", "runtime", "state", "outcome")


def emit(rows: Iterable[tuple[str, object]]) -> None:
    for key, value in rows:
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        else:
            rendered = str(value)
        print(f"{key}={rendered}")


def baseline() -> None:
    emit(
        (
            ("record", "baseline"),
            ("operation", "publish_reconciliation_checkpoint"),
            ("input_validation", "passed"),
            ("expected_operations", 3),
            ("receipt_count", 3),
            ("duplicate_receipts", 0),
            ("publication", "complete"),
            ("consumer_readback", "valid"),
            ("operation_success", True),
            ("scope", "deterministic_model_only"),
        )
    )


def scenario() -> None:
    emit(
        (
            ("record", "scenario_input"),
            ("operation", "set_release_catalog_version"),
            ("operation_id", "op-release-417"),
            ("target", "release-catalog"),
            ("intended_version", 42),
            ("client_deadline_ms", 30000),
            ("response_lost_after_ms", 30000),
            ("configured_max_attempts", 3),
            ("local_phase", "attempting"),
            ("request_sent", True),
            ("network", "virtual_model_only"),
        )
    )


def observe(case: str, view: str) -> None:
    common = (("record", "observation"), ("case", case), ("view", view))
    rows: dict[tuple[str, str], tuple[tuple[str, object], ...]] = {
        ("guided", "operation"): (
            ("promised_operation", "publish_three_terminal_receipts"),
            ("expected_operations", 3),
            ("reported_process_exit", 0),
            ("consumer_readback", "invalid"),
        ),
        ("guided", "input"): (
            ("field", "max_attempts"),
            ("observed_type", "string"),
            ("required_type", "integer"),
            ("observed_value", "3"),
            ("runtime_validation", "missing"),
        ),
        ("guided", "runtime"): (
            ("helper_operation", "op-2"),
            ("helper_returncode", 23),
            ("caught_handler", "broad_exception_continue"),
            ("top_level_exit", 0),
        ),
        ("guided", "state"): (
            ("publication_method", "direct_final_write"),
            ("published_records", 2),
            ("expected_records", 3),
            ("prior_artifact_retained", False),
        ),
        ("guided", "outcome"): (
            ("op_1", "committed"),
            ("op_2", "definite_no_effect_validation_rejection"),
            ("op_3", "committed"),
            ("duplicate_receipts", 0),
            ("first_failed_boundary", "runtime_input_validation"),
        ),
        ("independent", "operation"): (
            ("promised_operation", "set_release_catalog_version"),
            ("operation_id", "op-release-417"),
            ("intended_version", 42),
            ("local_completion_recorded", False),
        ),
        ("independent", "input"): (
            ("schema_validation", "passed"),
            ("operation_id_stable", True),
            ("deadline_ms", 30000),
            ("attempt_number", 1),
        ),
        ("independent", "runtime"): (
            ("request_sent", True),
            ("response_received", False),
            ("client_observation", "deadline_expired"),
            ("elapsed_ms", 30000),
        ),
        ("independent", "state"): (
            ("local_phase", "attempting"),
            ("local_receipt_present", False),
            ("automatic_retry_started", False),
            ("authoritative_owner", "modeled_release_service"),
        ),
        ("independent", "outcome"): (
            ("lookup_operation_id", "op-release-417"),
            ("authoritative_lookup", "found"),
            ("authoritative_state", "committed"),
            ("target_version", 42),
            ("service_attempt_count", 1),
            ("duplicate_effects", 0),
        ),
    }
    emit((*common, *rows[(case, view)]))


def recover(case: str) -> None:
    rows = {
        "guided": (
            ("action", "validate_rebuild_candidate_publish"),
            ("input_schema", "enforced"),
            ("expected_records", 3),
            ("published_records", 3),
            ("receipt_count", 3),
            ("duplicate_receipts", 0),
            ("consumer_readback", "valid"),
            ("operation_success", True),
        ),
        "independent": (
            ("action", "reconcile_record_existing_receipt"),
            ("operation_id", "op-release-417"),
            ("additional_mutation_attempts", 0),
            ("target_version", 42),
            ("receipt_count", 1),
            ("duplicate_receipts", 0),
            ("consumer_readback", "valid"),
            ("operation_success", True),
        ),
    }
    emit((("record", "recovery"), ("case", case), *rows[case], ("scope", "deterministic_model_only")))


def verify(case: str) -> None:
    receipt_count = 3 if case == "guided" else 1
    emit(
        (
            ("record", "verification"),
            ("case", case),
            ("operation_success", True),
            ("receipt_count", receipt_count),
            ("duplicate_receipts", 0),
            ("consumer_readback", "valid"),
            ("verification_scope", "deterministic_model_only"),
        )
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="LES-0018 deterministic evidence model")
    subcommands = result.add_subparsers(dest="command", required=True)
    subcommands.add_parser("baseline")
    subcommands.add_parser("scenario")
    observe_parser = subcommands.add_parser("observe")
    observe_parser.add_argument("--case", choices=CASES, required=True)
    observe_parser.add_argument("--view", choices=VIEWS, required=True)
    recover_parser = subcommands.add_parser("recover")
    recover_parser.add_argument("--case", choices=CASES, required=True)
    verify_parser = subcommands.add_parser("verify")
    verify_parser.add_argument("--case", choices=CASES, required=True)
    return result


def main() -> int:
    args = parser().parse_args()
    if args.command == "baseline":
        baseline()
    elif args.command == "scenario":
        scenario()
    elif args.command == "observe":
        observe(args.case, args.view)
    elif args.command == "recover":
        recover(args.case)
    elif args.command == "verify":
        verify(args.case)
    else:
        raise AssertionError(f"unhandled command: {args.command}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
