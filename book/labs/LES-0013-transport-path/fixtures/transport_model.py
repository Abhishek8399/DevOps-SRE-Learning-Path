#!/usr/bin/env python3
"""Deterministic, offline evidence model for LES-0013.

This program creates no socket, network request, load, or host mutation. It
prints fixed key=value records selected by an allowlisted CLI.
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
        "operation": "tcp_connect_and_request",
        "operation_success": "true",
        "error": "none",
        "connect_latency_ms": "12",
        "new_connections_per_second": "900",
        "established_reuse_percent": "82",
        "active_connections": "4200",
        "syn_sent_connections": "8",
        "syn_recv_connections": "12",
        "time_wait_connections": "1800",
        "close_wait_connections": "6",
        "listen_queue_current": "18",
        "listen_queue_limit": "2048",
        "listen_overflows_total": "2",
        "ephemeral_ports_used": "2600",
        "ephemeral_ports_eligible": "28232",
        "process_fds_used": "9100",
        "process_fds_limit": "65536",
        "socket_memory_bytes": "73400320",
        "conntrack_entries": "48000",
        "conntrack_limit": "262144",
        "conntrack_insert_failures_total": "0",
    }
)


CASES: Mapping[str, Mapping[str, str]] = MappingProxyType(
    {
        "guided": MappingProxyType(
            {
                "operation": "tcp_connect_and_request",
                "operation_success": "false",
                "error": "connect_timeout",
                "phase": "tcp_establishment",
                "connect_latency_ms": "1000",
                "established_reuse_success": "true",
                "protocol": "tcp",
                "address_family": "ipv4",
                "client_state": "syn_sent_rising",
                "server_listener": "present",
                "active_connections": "4600",
                "syn_sent_connections": "1850",
                "syn_recv_connections": "2310",
                "time_wait_connections": "2100",
                "close_wait_connections": "8",
                "listen_queue_current": "2048",
                "listen_queue_limit": "2048",
                "listen_overflows_total": "986",
                "accept_rate_per_second": "1450",
                "new_connections_per_second": "2600",
                "ephemeral_ports_used": "5100",
                "ephemeral_ports_eligible": "28232",
                "process_fds_used": "14200",
                "process_fds_limit": "65536",
                "socket_memory_bytes": "125829120",
                "state_scope": "node_conntrack",
                "conntrack_entries": "61000",
                "conntrack_limit": "262144",
                "conntrack_insert_failures_total": "0",
                "nat_mappings_active": "55000",
                "recovery_action": "rollback_accept_loop_regression",
            }
        ),
        "independent": MappingProxyType(
            {
                "operation": "tcp_connect_and_request",
                "operation_success": "false",
                "error": "connect_timeout",
                "phase": "tcp_establishment",
                "connect_latency_ms": "1000",
                "established_reuse_success": "true",
                "protocol": "tcp",
                "address_family": "ipv4",
                "client_state": "syn_sent_rising",
                "server_listener": "present",
                "active_connections": "4300",
                "syn_sent_connections": "1720",
                "syn_recv_connections": "18",
                "time_wait_connections": "1950",
                "close_wait_connections": "7",
                "listen_queue_current": "27",
                "listen_queue_limit": "2048",
                "listen_overflows_total": "2",
                "accept_rate_per_second": "2550",
                "new_connections_per_second": "2500",
                "ephemeral_ports_used": "4900",
                "ephemeral_ports_eligible": "28232",
                "process_fds_used": "11600",
                "process_fds_limit": "65536",
                "socket_memory_bytes": "94371840",
                "state_scope": "node_conntrack",
                "conntrack_entries": "262144",
                "conntrack_limit": "262144",
                "conntrack_insert_failures_total": "1478",
                "nat_mappings_active": "248300",
                "recovery_action": "approved_owner_specific_remediation",
            }
        ),
    }
)


BASELINE_FIELDS: Sequence[str] = (
    "record",
    "case",
    "operation",
    "operation_success",
    "error",
    "connect_latency_ms",
    "new_connections_per_second",
    "established_reuse_percent",
    "active_connections",
    "syn_sent_connections",
    "syn_recv_connections",
    "time_wait_connections",
    "close_wait_connections",
    "listen_queue_current",
    "listen_queue_limit",
    "listen_overflows_total",
    "ephemeral_ports_used",
    "ephemeral_ports_eligible",
    "process_fds_used",
    "process_fds_limit",
    "socket_memory_bytes",
    "conntrack_entries",
    "conntrack_limit",
    "conntrack_insert_failures_total",
)

VIEW_FIELDS: Mapping[str, Sequence[str]] = MappingProxyType(
    {
        "operation": (
            "operation",
            "operation_success",
            "error",
            "phase",
            "connect_latency_ms",
            "established_reuse_success",
        ),
        "endpoints": (
            "protocol",
            "address_family",
            "client_state",
            "server_listener",
            "active_connections",
            "syn_sent_connections",
            "syn_recv_connections",
            "time_wait_connections",
            "close_wait_connections",
        ),
        "queues": (
            "listen_queue_current",
            "listen_queue_limit",
            "listen_overflows_total",
            "accept_rate_per_second",
            "new_connections_per_second",
        ),
        "resources": (
            "ephemeral_ports_used",
            "ephemeral_ports_eligible",
            "process_fds_used",
            "process_fds_limit",
            "socket_memory_bytes",
        ),
        "stateful-path": (
            "state_scope",
            "conntrack_entries",
            "conntrack_limit",
            "conntrack_insert_failures_total",
            "nat_mappings_active",
        ),
    }
)


def emit(fields: Sequence[str], values: Mapping[str, str]) -> None:
    for field in fields:
        print(f"{field}={values[field]}")


def emit_observation(case_name: str, view: str) -> None:
    case = CASES[case_name]
    print("record=observation")
    print(f"case={case_name}")
    print(f"view={view}")
    emit(VIEW_FIELDS[view], case)


def emit_recovery(case_name: str) -> None:
    case = CASES[case_name]
    values = {
        "record": "recovery",
        "case": case_name,
        "action": case["recovery_action"],
        "operation_success": "true",
        "error": "none",
        "listen_queue_current": BASELINE["listen_queue_current"],
        "conntrack_entries": BASELINE["conntrack_entries"],
    }
    emit(tuple(values.keys()), values)


def emit_verification(case_name: str) -> None:
    values = {
        "record": "verification",
        "case": case_name,
        "operation": "tcp_connect_and_request",
        "operation_success": "true",
        "fresh_connect_success": "true",
        "established_reuse_success": "true",
        "correctness_check": "passed",
        "verification_scope": "deterministic_model_only",
    }
    emit(tuple(values.keys()), values)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description="Print deterministic transport evidence without network access."
    )
    subcommands = result.add_subparsers(dest="command", required=True)
    subcommands.add_parser("baseline")

    observe = subcommands.add_parser("observe")
    observe.add_argument("--case", choices=tuple(CASES), required=True)
    observe.add_argument("--view", choices=tuple(VIEW_FIELDS), required=True)

    for name in ("recover", "verify"):
        operation = subcommands.add_parser(name)
        operation.add_argument("--case", choices=tuple(CASES), required=True)
    return result


def main() -> int:
    arguments = parser().parse_args()
    if arguments.command == "baseline":
        emit(BASELINE_FIELDS, BASELINE)
    elif arguments.command == "observe":
        emit_observation(arguments.case, arguments.view)
    elif arguments.command == "recover":
        emit_recovery(arguments.case)
    elif arguments.command == "verify":
        emit_verification(arguments.case)
    else:  # argparse makes this unreachable; keep an explicit failure boundary.
        raise RuntimeError("unsupported command")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
