#!/usr/bin/env python3
"""Deterministic virtual incident model for LES-0008.

The fixture emits fixed key-value evidence. It does not sleep, open sockets,
write files, create workers, or consume real host resources to simulate a fault.
"""

from __future__ import annotations

import argparse
from typing import Dict, Iterable, Mapping, Tuple


CASES = ("guided", "changed", "transfer")
VIEWS = ("symptoms", "timeline", "path", "changes")
PROBES = ("app-only", "dependency-only", "queue")
EXPERIMENTS = ("retry-off", "known-good-workers")


BASELINE: Dict[str, str] = {
    "record": "baseline",
    "case": "baseline",
    "requests": "20",
    "successes": "20",
    "timeouts": "0",
    "p95_latency_ms": "120",
    "app_p95_ms": "30",
    "dependency_p95_ms": "50",
    "max_queue": "0",
    "dependency_calls": "20",
    "retries": "0",
    "worker_limit": "4",
    "app_revision": "app-2026.08.1",
    "config_revision": "cfg-001",
}


OBSERVATIONS: Dict[str, Dict[str, Dict[str, str]]] = {
    "guided": {
        "symptoms": {
            "record": "observation",
            "case": "guided",
            "view": "symptoms",
            "requests": "20",
            "successes": "8",
            "timeouts": "12",
            "p95_latency_ms": "980",
            "error": "upstream_timeout",
        },
        "timeline": {
            "record": "observation",
            "case": "guided",
            "view": "timeline",
            "baseline_at": "T-10m",
            "event_at": "T-5m_app_deploy",
            "symptom_at": "T0",
            "followup_at": "T+1m_retry_rise",
            "observation": "correlation_is_not_causation",
        },
        "path": {
            "record": "observation",
            "case": "guided",
            "view": "path",
            "gateway_p95_ms": "10",
            "app_only_p95_ms": "30",
            "dependency_p95_ms": "700",
            "max_queue": "3",
            "dependency_calls": "44",
        },
        "changes": {
            "record": "observation",
            "case": "guided",
            "view": "changes",
            "app_revision_before": "app-2026.08.1",
            "app_revision_after": "app-2026.08.2",
            "worker_limit_before": "4",
            "worker_limit_after": "4",
            "retry_limit_before": "0",
            "retry_limit_after": "2",
            "config_revision_before": "cfg-001",
            "config_revision_after": "cfg-002",
        },
    },
    "changed": {
        "symptoms": {
            "record": "observation",
            "case": "changed",
            "view": "symptoms",
            "requests": "20",
            "successes": "14",
            "timeouts": "6",
            "p95_latency_ms": "840",
            "error": "upstream_timeout",
        },
        "timeline": {
            "record": "observation",
            "case": "changed",
            "view": "timeline",
            "baseline_at": "T-10m",
            "event_at": "T-2m_config_change",
            "symptom_at": "T0",
            "followup_at": "T+1m_queue_rise",
            "observation": "change_is_a_lead_not_a_verdict",
        },
        "path": {
            "record": "observation",
            "case": "changed",
            "view": "path",
            "gateway_p95_ms": "10",
            "app_only_p95_ms": "780",
            "dependency_p95_ms": "50",
            "max_queue": "12",
            "dependency_calls": "20",
        },
        "changes": {
            "record": "observation",
            "case": "changed",
            "view": "changes",
            "app_revision_before": "app-2026.08.1",
            "app_revision_after": "app-2026.08.1",
            "worker_limit_before": "4",
            "worker_limit_after": "1",
            "retry_limit_before": "0",
            "retry_limit_after": "0",
            "config_revision_before": "cfg-001",
            "config_revision_after": "cfg-worker-1",
        },
    },
    "transfer": {
        "symptoms": {
            "record": "observation",
            "case": "transfer",
            "view": "symptoms",
            "requests": "20",
            "successes": "10",
            "timeouts": "10",
            "p95_latency_ms": "910",
            "error": "upstream_timeout",
        },
        "timeline": {
            "record": "observation",
            "case": "transfer",
            "view": "timeline",
            "baseline_at": "T-10m",
            "event_at": "none_observed",
            "symptom_at": "T0",
            "followup_at": "T+1m_telemetry_gap",
            "observation": "missing_evidence_is_not_healthy_evidence",
        },
        "path": {
            "record": "observation",
            "case": "transfer",
            "view": "path",
            "gateway_p95_ms": "10",
            "app_only_p95_ms": "30",
            "dependency_p95_ms": "not_collected",
            "max_queue": "2",
            "dependency_calls": "20",
        },
        "changes": {
            "record": "observation",
            "case": "transfer",
            "view": "changes",
            "app_revision_before": "app-2026.08.1",
            "app_revision_after": "app-2026.08.1",
            "worker_limit_before": "4",
            "worker_limit_after": "4",
            "retry_limit_before": "0",
            "retry_limit_after": "0",
            "config_revision_before": "cfg-001",
            "config_revision_after": "cfg-001",
        },
    },
}


PROBE_RESULTS: Dict[str, Dict[str, Dict[str, str]]] = {
    "guided": {
        "app-only": {
            "requests": "5",
            "successes": "5",
            "p95_latency_ms": "30",
            "max_queue": "0",
            "conclusion_hint": "app_path_is_healthy_without_dependency",
        },
        "dependency-only": {
            "requests": "5",
            "successes": "2",
            "p95_latency_ms": "700",
            "max_queue": "0",
            "conclusion_hint": "dependency_path_is_slow",
        },
        "queue": {
            "requests": "20",
            "successes": "8",
            "p95_latency_ms": "250",
            "max_queue": "3",
            "conclusion_hint": "queueing_is_present_but_not_first_divergence",
        },
    },
    "changed": {
        "app-only": {
            "requests": "5",
            "successes": "3",
            "p95_latency_ms": "780",
            "max_queue": "12",
            "conclusion_hint": "app_worker_path_is_slow",
        },
        "dependency-only": {
            "requests": "5",
            "successes": "5",
            "p95_latency_ms": "50",
            "max_queue": "0",
            "conclusion_hint": "dependency_path_is_healthy",
        },
        "queue": {
            "requests": "20",
            "successes": "14",
            "p95_latency_ms": "620",
            "max_queue": "12",
            "conclusion_hint": "worker_queue_is_first_divergence",
        },
    },
    "transfer": {
        "app-only": {
            "requests": "5",
            "successes": "5",
            "p95_latency_ms": "30",
            "max_queue": "0",
            "conclusion_hint": "app_path_is_healthy_without_dependency",
        },
        "dependency-only": {
            "requests": "5",
            "successes": "2",
            "p95_latency_ms": "650",
            "max_queue": "0",
            "conclusion_hint": "missing_dependency_signal_is_now_collected",
        },
        "queue": {
            "requests": "20",
            "successes": "10",
            "p95_latency_ms": "80",
            "max_queue": "2",
            "conclusion_hint": "small_queue_does_not_explain_tail_latency",
        },
    },
}


EXPERIMENT_RESULTS: Dict[str, Dict[str, Dict[str, str]]] = {
    "guided": {
        "retry-off": {
            "requests": "20",
            "successes": "8",
            "timeouts": "12",
            "p95_latency_ms": "760",
            "dependency_calls": "20",
            "max_queue": "2",
            "worker_limit": "4",
            "result": "amplification_reduced_dependency_latency_remains",
        },
        "known-good-workers": {
            "requests": "20",
            "successes": "8",
            "timeouts": "12",
            "p95_latency_ms": "980",
            "dependency_calls": "44",
            "max_queue": "1",
            "worker_limit": "4",
            "result": "no_material_change_dependency_latency_remains",
        },
    },
    "changed": {
        "retry-off": {
            "requests": "20",
            "successes": "14",
            "timeouts": "6",
            "p95_latency_ms": "840",
            "dependency_calls": "20",
            "max_queue": "12",
            "worker_limit": "1",
            "result": "no_material_change_worker_queue_remains",
        },
        "known-good-workers": {
            "requests": "20",
            "successes": "20",
            "timeouts": "0",
            "p95_latency_ms": "120",
            "dependency_calls": "20",
            "max_queue": "0",
            "worker_limit": "4",
            "result": "latency_recovered_with_known_good_worker_limit",
        },
    },
    "transfer": {
        "retry-off": {
            "requests": "20",
            "successes": "10",
            "timeouts": "10",
            "p95_latency_ms": "910",
            "dependency_calls": "20",
            "max_queue": "2",
            "worker_limit": "4",
            "result": "no_material_change_more_dependency_evidence_needed",
        },
        "known-good-workers": {
            "requests": "20",
            "successes": "10",
            "timeouts": "10",
            "p95_latency_ms": "910",
            "dependency_calls": "20",
            "max_queue": "1",
            "worker_limit": "4",
            "result": "no_material_change_more_dependency_evidence_needed",
        },
    },
}


def emit(items: Mapping[str, str]) -> None:
    """Print a stable key-value record and reject multiline values."""

    for key, value in items.items():
        if not key or "\n" in key or "=" in key:
            raise ValueError("invalid output key")
        if not value or "\n" in value or "\r" in value:
            raise ValueError(f"invalid output value for {key}")
        print(f"{key}={value}")


def combined(
    prefix: Iterable[Tuple[str, str]], values: Mapping[str, str]
) -> Dict[str, str]:
    result = dict(prefix)
    result.update(values)
    return result


def recovery(case_name: str) -> Dict[str, str]:
    return {
        "record": "recovery",
        "case": case_name,
        "action": "restore_fixture_known_good",
        "requests": "20",
        "successes": "20",
        "timeouts": "0",
        "p95_latency_ms": "120",
        "dependency_calls": "20",
        "max_queue": "0",
        "worker_limit": "4",
        "lost_work": "0",
    }


def verification(case_name: str) -> Dict[str, str]:
    return {
        "record": "verification",
        "case": case_name,
        "operation": "synthetic_checkout",
        "requests": "20",
        "successes": "20",
        "timeouts": "0",
        "p95_latency_ms": "120",
        "lost_work": "0",
        "recovery_verified": "true",
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Emit deterministic evidence for one virtual FRAME incident."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("baseline")

    observe_parser = subparsers.add_parser("observe")
    observe_parser.add_argument("--case", required=True, choices=CASES)
    observe_parser.add_argument("--view", required=True, choices=VIEWS)

    probe_parser = subparsers.add_parser("probe")
    probe_parser.add_argument("--case", required=True, choices=CASES)
    probe_parser.add_argument("--probe", required=True, choices=PROBES)

    experiment_parser = subparsers.add_parser("experiment")
    experiment_parser.add_argument("--case", required=True, choices=CASES)
    experiment_parser.add_argument(
        "--experiment", required=True, choices=EXPERIMENTS
    )

    for name in ("recover", "verify"):
        command_parser = subparsers.add_parser(name)
        command_parser.add_argument("--case", required=True, choices=CASES)

    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.command == "baseline":
        emit(BASELINE)
    elif args.command == "observe":
        emit(OBSERVATIONS[args.case][args.view])
    elif args.command == "probe":
        emit(
            combined(
                (
                    ("record", "probe"),
                    ("case", args.case),
                    ("probe", args.probe),
                ),
                PROBE_RESULTS[args.case][args.probe],
            )
        )
    elif args.command == "experiment":
        emit(
            combined(
                (
                    ("record", "experiment"),
                    ("case", args.case),
                    ("experiment", args.experiment),
                ),
                EXPERIMENT_RESULTS[args.case][args.experiment],
            )
        )
    elif args.command == "recover":
        emit(recovery(args.case))
    elif args.command == "verify":
        emit(verification(args.case))
    else:
        raise AssertionError(f"unhandled command: {args.command}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
