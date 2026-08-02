#!/usr/bin/env python3

"""Emit deterministic namespace/cgroup evidence without creating pressure."""

from __future__ import annotations

import argparse
from collections.abc import Iterable


CASES = ("guided", "transfer")
VIEWS = ("identity", "resources", "events", "operation")

BASELINE = (
    ("record", "baseline"),
    ("case", "baseline"),
    ("operation_success", "true"),
    ("workload_id", "report-worker"),
    ("instance_id", "ctr-a1"),
    ("namespace_view", "workload-a"),
    ("cgroup_id", "cg-91"),
    ("memory_current_bytes", "268435456"),
    ("memory_max_bytes", "536870912"),
    ("memory_oom", "0"),
    ("memory_oom_kill", "0"),
    ("cpu_nr_throttled", "2"),
    ("pids_current", "18"),
    ("pids_max", "128"),
    ("pids_max_events", "0"),
)

OBSERVATIONS = {
    "guided": {
        "identity": (
            ("workload_id", "report-worker"),
            ("instance_id", "ctr-a1"),
            ("namespace_view", "workload-a"),
            ("cgroup_id", "cg-91"),
        ),
        "resources": (
            ("memory_current_bytes", "532676608"),
            ("memory_max_bytes", "536870912"),
            ("cpu_nr_throttled", "2"),
            ("pids_current", "21"),
            ("pids_max", "128"),
        ),
        "events": (
            ("memory_oom", "2"),
            ("memory_oom_kill", "1"),
            ("cpu_nr_throttled", "2"),
            ("pids_max_events", "0"),
        ),
        "operation": (
            ("operation", "generate-report"),
            ("operation_success", "false"),
            ("error", "worker-terminated"),
        ),
    },
    "transfer": {
        "identity": (
            ("workload_id", "report-worker"),
            ("instance_id", "ctr-a1"),
            ("namespace_view", "workload-a"),
            ("cgroup_id", "cg-91"),
        ),
        "resources": (
            ("memory_current_bytes", "301989888"),
            ("memory_max_bytes", "536870912"),
            ("cpu_nr_throttled", "2"),
            ("pids_current", "128"),
            ("pids_max", "128"),
        ),
        "events": (
            ("memory_oom", "0"),
            ("memory_oom_kill", "0"),
            ("cpu_nr_throttled", "2"),
            ("pids_max_events", "9"),
        ),
        "operation": (
            ("operation", "generate-report"),
            ("operation_success", "false"),
            ("error", "worker-create-unavailable"),
        ),
    },
}


def emit(items: Iterable[tuple[str, str]]) -> None:
    for key, value in items:
        print(f"{key}={value}")


def observation(case: str, view: str) -> tuple[tuple[str, str], ...]:
    return (
        ("record", "observation"),
        ("case", case),
        ("view", view),
        *OBSERVATIONS[case][view],
    )


def recovery(case: str) -> tuple[tuple[str, str], ...]:
    return (
        ("record", "recovery"),
        ("case", case),
        ("action", "restore-virtual-known-good"),
        ("operation_success", "true"),
        ("memory_current_bytes", "268435456"),
        ("memory_oom_kill_delta_after", "0"),
        ("cpu_nr_throttled_delta_after", "0"),
        ("pids_current", "18"),
        ("pids_max_events_delta_after", "0"),
    )


def verification(case: str) -> tuple[tuple[str, str], ...]:
    return (
        ("record", "verification"),
        ("case", case),
        ("operation", "generate-report"),
        ("operation_success", "true"),
        ("durable_outputs", "1"),
        ("duplicate_outputs", "0"),
        ("lost_outputs", "0"),
        ("verification_scope", "deterministic-model-only"),
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emit deterministic evidence for the LES-0011 virtual model."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("baseline")

    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=CASES)
    observe_parser.add_argument("--view", required=True, choices=VIEWS)

    for command in ("recover", "verify"):
        command_parser = subparsers.add_parser(command)
        command_parser.add_argument("--case", required=True, choices=CASES)

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.command == "baseline":
        emit(BASELINE)
    elif args.command == "observe":
        emit(observation(args.case, args.view))
    elif args.command == "recover":
        emit(recovery(args.case))
    elif args.command == "verify":
        emit(verification(args.case))
    else:
        raise AssertionError(f"unhandled command: {args.command}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
