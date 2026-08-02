#!/usr/bin/env python3
"""Deterministic, offline HTTP-path evidence for LES-0015.

The model creates no listener, socket, HTTP request, load, subprocess, or host
configuration change. It prints allowlisted key=value evidence only.
"""

from __future__ import annotations

import argparse
import sys
from types import MappingProxyType
from typing import Mapping, Sequence

sys.dont_write_bytecode = True


BASELINE = MappingProxyType(
    {
        "record": "baseline",
        "case": "known-good",
        "operation": "http_request",
        "result_status": "200",
        "application_correct": "true",
        "original_requests_per_second": "900",
        "upstream_attempts_per_second": "720",
        "success_percent": "99.98",
        "p95_latency_ms": "95",
        "cache_hit_percent": "20",
        "cache_key_dimensions": "scheme,authority,target,tenant_context",
        "pool_connections_in_use": "96",
        "pool_connections_limit": "256",
        "pool_pending_current": "12",
        "pool_pending_limit": "512",
        "connection_reuse_percent": "91",
        "healthy_backends": "8",
        "total_backends": "8",
        "origin_capacity_per_second": "1600",
    }
)

SCENARIOS: Mapping[str, Mapping[str, str]] = MappingProxyType(
    {
        "guided": MappingProxyType(
            {
                "operation": "read_catalog_item",
                "method": "GET",
                "request_target": "/v1/catalog/items/42",
                "context_a": "public_catalog",
                "context_b": "not_applicable",
                "overall_deadline_ms": "800",
                "configured_max_attempts": "3",
                "cache_mode": "shared",
                "expected_contract": "correct_item_or_bounded_error",
                "result_status": "503",
                "status_issuer": "reverse_proxy",
                "application_correct": "false",
                "response_context": "none",
                "observed_context": "none",
                "total_latency_ms": "790",
                "request_id_consistent": "true",
                "original_requests_per_second": "900",
                "upstream_attempts_per_second": "2250",
                "retries_per_second": "1350",
                "per_try_timeout_ms": "250",
                "forwarded_identity_source": "trusted_edge",
                "lookup_result": "bypass",
                "cache_entries": "18000",
                "cache_hit_percent": "10",
                "cache_key_dimensions": "scheme,authority,target",
                "vary_fields": "accept-encoding",
                "cache_control": "no-store",
                "age_seconds": "0",
                "etag_present": "false",
                "authorization_present": "false",
                "pool_connections_in_use": "256",
                "pool_connections_limit": "256",
                "pool_pending_current": "512",
                "pool_pending_limit": "512",
                "pool_acquire_p95_ms": "505",
                "connection_reuse_percent": "28",
                "healthy_backends": "8",
                "total_backends": "8",
                "health_path": "/live",
                "origin_requests_per_second": "2250",
                "origin_capacity_per_second": "1600",
                "origin_p95_latency_ms": "450",
            }
        ),
        "independent": MappingProxyType(
            {
                "operation": "read_account_summary",
                "method": "GET",
                "request_target": "/v1/account/summary",
                "context_a": "tenant_alpha",
                "context_b": "tenant_beta",
                "overall_deadline_ms": "800",
                "configured_max_attempts": "2",
                "cache_mode": "shared",
                "expected_contract": "context_scoped_representation",
                "result_status": "200",
                "status_issuer": "shared_cache",
                "application_correct": "false",
                "response_context": "tenant_alpha",
                "observed_context": "tenant_beta",
                "total_latency_ms": "7",
                "request_id_consistent": "true",
                "original_requests_per_second": "600",
                "upstream_attempts_per_second": "120",
                "retries_per_second": "0",
                "per_try_timeout_ms": "250",
                "forwarded_identity_source": "untrusted_client_field",
                "lookup_result": "hit",
                "cache_entries": "24000",
                "cache_hit_percent": "80",
                "cache_key_dimensions": "scheme,authority,target",
                "vary_fields": "accept-encoding",
                "cache_control": "public_max_age_300",
                "age_seconds": "42",
                "etag_present": "true",
                "authorization_present": "true",
                "pool_connections_in_use": "54",
                "pool_connections_limit": "256",
                "pool_pending_current": "0",
                "pool_pending_limit": "512",
                "pool_acquire_p95_ms": "2",
                "connection_reuse_percent": "93",
                "healthy_backends": "8",
                "total_backends": "8",
                "health_path": "/ready",
                "origin_requests_per_second": "120",
                "origin_capacity_per_second": "1600",
                "origin_p95_latency_ms": "45",
            }
        ),
    }
)

BASELINE_FIELDS: Sequence[str] = tuple(BASELINE.keys())
SCENARIO_FIELDS: Sequence[str] = (
    "operation",
    "method",
    "request_target",
    "context_a",
    "context_b",
    "overall_deadline_ms",
    "configured_max_attempts",
    "cache_mode",
    "expected_contract",
)
VIEW_FIELDS: Mapping[str, Sequence[str]] = MappingProxyType(
    {
        "operation": (
            "operation",
            "method",
            "result_status",
            "status_issuer",
            "application_correct",
            "response_context",
            "observed_context",
            "total_latency_ms",
            "request_id_consistent",
        ),
        "proxy": (
            "original_requests_per_second",
            "upstream_attempts_per_second",
            "retries_per_second",
            "overall_deadline_ms",
            "per_try_timeout_ms",
            "forwarded_identity_source",
            "request_id_consistent",
        ),
        "cache": (
            "lookup_result",
            "cache_entries",
            "cache_hit_percent",
            "cache_key_dimensions",
            "vary_fields",
            "cache_control",
            "age_seconds",
            "etag_present",
            "authorization_present",
        ),
        "pools": (
            "pool_connections_in_use",
            "pool_connections_limit",
            "pool_pending_current",
            "pool_pending_limit",
            "pool_acquire_p95_ms",
            "connection_reuse_percent",
        ),
        "health": (
            "healthy_backends",
            "total_backends",
            "health_path",
            "origin_requests_per_second",
            "origin_capacity_per_second",
            "origin_p95_latency_ms",
        ),
    }
)


def emit(fields: Sequence[str], values: Mapping[str, str]) -> None:
    for field in fields:
        print(f"{field}={values[field]}")


def emit_scenario(case_name: str) -> None:
    print("record=scenario")
    print(f"case={case_name}")
    print("view=inputs")
    emit(SCENARIO_FIELDS, SCENARIOS[case_name])


def emit_observation(case_name: str, view: str) -> None:
    print("record=observation")
    print(f"case={case_name}")
    print(f"view={view}")
    emit(VIEW_FIELDS[view], SCENARIOS[case_name])


def emit_recovery(case_name: str) -> None:
    values = {
        "record": "recovery",
        "case": case_name,
        "action": "apply_approved_case_recovery",
        "change_scope": "deterministic_model_only",
        "result_status": "200",
        "application_correct": "true",
        "upstream_attempts_per_second": "720" if case_name == "guided" else "600",
        "pool_pending_current": "12" if case_name == "guided" else "0",
    }
    emit(tuple(values.keys()), values)


def emit_verification(case_name: str) -> None:
    values = {
        "record": "verification",
        "case": case_name,
        "operation": SCENARIOS[case_name]["operation"],
        "result_status": "200",
        "application_correct": "true",
        "context_a_correct": "true",
        "context_b_correct": "true",
        "unsafe_shared_hit": "false",
        "attempt_ratio_within_budget": "true",
        "pool_headroom_present": "true",
        "queue_headroom_present": "true",
        "verification_scope": "deterministic_model_only",
    }
    emit(tuple(values.keys()), values)


def build_parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description="Print deterministic HTTP-path evidence without network access."
    )
    commands = result.add_subparsers(dest="command", required=True)
    commands.add_parser("baseline")

    scenario = commands.add_parser("scenario")
    scenario.add_argument("--case", choices=tuple(SCENARIOS), required=True)

    observe = commands.add_parser("observe")
    observe.add_argument("--case", choices=tuple(SCENARIOS), required=True)
    observe.add_argument("--view", choices=tuple(VIEW_FIELDS), required=True)

    for name in ("recover", "verify"):
        operation = commands.add_parser(name)
        operation.add_argument("--case", choices=tuple(SCENARIOS), required=True)
    return result


def main() -> int:
    arguments = build_parser().parse_args()
    if arguments.command == "baseline":
        emit(BASELINE_FIELDS, BASELINE)
    elif arguments.command == "scenario":
        emit_scenario(arguments.case)
    elif arguments.command == "observe":
        emit_observation(arguments.case, arguments.view)
    elif arguments.command == "recover":
        emit_recovery(arguments.case)
    elif arguments.command == "verify":
        emit_verification(arguments.case)
    else:
        raise RuntimeError("unsupported command")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
