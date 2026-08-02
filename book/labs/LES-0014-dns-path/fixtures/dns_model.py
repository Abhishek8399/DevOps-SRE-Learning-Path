#!/usr/bin/env python3
"""Deterministic offline DNS evidence model for LES-0014.

The model opens no socket, reads no host resolver configuration, and writes no
file. The Bash controller owns the guarded lifecycle and persistence boundary.
"""

from __future__ import annotations

import argparse
from collections.abc import Iterable


def emit(items: Iterable[tuple[str, object]]) -> None:
    for key, value in items:
        print(f"{key}={value}")


def baseline() -> None:
    emit(
        [
            ("record", "baseline"),
            ("operation", "resolve_and_select"),
            ("query_name", "payments.service.test."),
            ("query_type", "A"),
            ("resolver", "resolver-r1"),
            ("rcode", "NOERROR"),
            ("selected_address", "10.20.4.18"),
            ("expected_address", "10.20.4.18"),
            ("ttl_remaining_s", 300),
            ("operation_success", "true"),
        ]
    )


SCENARIO_ROWS = [
    ("record", "scenario_input"),
    ("case", "independent"),
    ("client_scope", "pod-checkout-17"),
    ("input_name", "inventory.prod"),
    ("search_domains", "shop.svc.cluster.local.,svc.cluster.local.,cluster.local."),
    ("ndots", 5),
    ("query_types", "A,AAAA"),
    ("attempts", 2),
    ("operation_deadline_ms", 1200),
    ("advertised_udp_payload_bytes", 4096),
    ("modeled_response_bytes", 1780),
    ("modeled_path_safe_udp_bytes", 1232),
    ("default_udp_outcome", "timeout"),
    ("explicit_tcp_outcome", "NOERROR"),
]


OBSERVATIONS = {
    "guided": {
        "operation": [
            ("operation", "resolve_and_select"),
            ("input_name", "payments.service.test."),
            ("lookup_result", "NOERROR"),
            ("selected_address", "10.20.4.18"),
            ("expected_address", "10.20.7.31"),
            ("elapsed_ms", 7),
            ("operation_success", "false"),
        ],
        "resolver": [
            ("resolver", "resolver-r1"),
            ("view", "private-payments"),
            ("query_name", "payments.service.test."),
            ("query_type", "A"),
            ("rcode", "NOERROR"),
            ("answer_source", "positive_cache"),
        ],
        "cache": [
            ("cache_result", "hit"),
            ("cached_address", "10.20.4.18"),
            ("cached_at", "10:02:00Z"),
            ("authority_changed_at", "10:03:00Z"),
            ("original_ttl_s", 300),
            ("ttl_remaining_s", 180),
        ],
        "authority": [
            ("authority", "ns1.service.test."),
            ("aa", "true"),
            ("soa_serial", 2026080202),
            ("authoritative_address", "10.20.7.31"),
            ("authoritative_ttl_s", 300),
            ("replicas_aligned", "true"),
        ],
        "transport": [
            ("udp_result", "NOERROR"),
            ("udp_response_bytes", 96),
            ("tc", "false"),
            ("tcp_result", "NOERROR"),
            ("network_mutation", "none"),
            ("packet_sent", "false"),
        ],
    },
    "independent": {
        "operation": [
            ("operation", "resolve_and_select"),
            ("input_name", "inventory.prod"),
            ("lookup_result", "timeout"),
            ("selected_address", "none"),
            ("expected_address", "192.0.2.44"),
            ("elapsed_ms", 1200),
            ("operation_success", "false"),
        ],
        "resolver": [
            ("resolver", "cluster-dns-a"),
            ("candidate_names", "inventory.prod.shop.svc.cluster.local.,inventory.prod.svc.cluster.local.,inventory.prod.cluster.local.,inventory.prod."),
            ("query_types", "A,AAAA"),
            ("attempts", 2),
            ("candidate_queries_observed", 14),
            ("final_candidate", "inventory.prod."),
        ],
        "cache": [
            ("cache_hits", 0),
            ("cache_misses", 8),
            ("negative_answers", 6),
            ("positive_answers", 1),
            ("retry_queries", 6),
            ("evictions", 0),
        ],
        "authority": [
            ("authority", "ns1.prod."),
            ("aa", "true"),
            ("rcode", "NOERROR"),
            ("answer_address", "192.0.2.44"),
            ("answer_count", 12),
            ("response_bytes", 1780),
        ],
        "transport": [
            ("advertised_udp_payload_bytes", 4096),
            ("modeled_path_safe_udp_bytes", 1232),
            ("udp_result", "timeout"),
            ("tc_observed", "false"),
            ("explicit_tcp_result", "NOERROR"),
            ("packet_sent", "false"),
        ],
    },
}


def observe(case: str, view: str) -> None:
    emit([("record", "observation"), ("case", case), ("view", view)])
    emit(OBSERVATIONS[case][view])


def recover(case: str) -> None:
    if case == "guided":
        rows = [
            ("action", "preserve_old_endpoint_and_advance_to_cache_expiry"),
            ("owner", "resolver-r1-cache-window"),
            ("blast_radius", "modeled_client_only"),
            ("rollback", "restore_preincident_virtual_clock"),
            ("selected_address", "10.20.7.31"),
        ]
    else:
        rows = [
            ("action", "use_absolute_name_and_supported_tcp_fallback"),
            ("owner", "modeled_client_resolver_policy"),
            ("blast_radius", "modeled_client_only"),
            ("rollback", "restore_original_modeled_policy"),
            ("selected_address", "192.0.2.44"),
        ]
    emit([("record", "recovery"), ("case", case), *rows, ("operation_success", "true")])


def verify(case: str) -> None:
    selected = "10.20.7.31" if case == "guided" else "192.0.2.44"
    emit(
        [
            ("record", "verification"),
            ("case", case),
            ("query_result", "NOERROR"),
            ("selected_address", selected),
            ("operation_success", "true"),
            ("verification_scope", "deterministic_model_only"),
            ("network_mutation", "none"),
        ]
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("baseline")
    sub.add_parser("scenario")
    observed = sub.add_parser("observe")
    observed.add_argument("--case", choices=("guided", "independent"), required=True)
    observed.add_argument("--view", choices=tuple(OBSERVATIONS["guided"]), required=True)
    recovered = sub.add_parser("recover")
    recovered.add_argument("--case", choices=("guided", "independent"), required=True)
    verified = sub.add_parser("verify")
    verified.add_argument("--case", choices=("guided", "independent"), required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.command == "baseline":
        baseline()
    elif args.command == "scenario":
        emit(SCENARIO_ROWS)
    elif args.command == "observe":
        observe(args.case, args.view)
    elif args.command == "recover":
        recover(args.case)
    else:
        verify(args.case)


if __name__ == "__main__":
    main()
