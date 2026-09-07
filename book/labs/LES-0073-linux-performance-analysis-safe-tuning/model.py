#!/usr/bin/env python3
"""Deterministic LES-0073 performance experiment model; it changes nothing."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


ORDERED_GATES = (
    ("outcome_defined", "outcome"),
    ("workload_identity_bound", "workload-identity"),
    ("experiment_window_owned", "experiment-window"),
    ("baseline_comparable", "baseline-comparability"),
    ("samples_repeated", "sample-quality"),
    ("environment_recorded", "environment"),
    ("latency_distribution_measured", "latency"),
    ("throughput_measured", "throughput"),
    ("errors_measured", "service-errors"),
    ("resource_inventory_current", "resource-inventory"),
    ("cpu_utilization_checked", "cpu-utilization"),
    ("cpu_saturation_checked", "cpu-saturation"),
    ("cpu_errors_checked", "cpu-errors"),
    ("memory_utilization_checked", "memory-utilization"),
    ("memory_pressure_checked", "memory-pressure"),
    ("memory_errors_checked", "memory-errors"),
    ("io_utilization_checked", "io-utilization"),
    ("io_saturation_checked", "io-saturation"),
    ("io_errors_checked", "io-errors"),
    ("network_utilization_checked", "network-utilization"),
    ("network_saturation_checked", "network-saturation"),
    ("network_errors_checked", "network-errors"),
    ("process_scope_bound", "process-scope"),
    ("cgroup_scope_bound", "cgroup-scope"),
    ("counter_units_known", "counter-units"),
    ("counter_delta_valid", "counter-delta"),
    ("counter_limitations_stated", "counter-limitations"),
    ("hypothesis_written", "hypothesis"),
    ("profile_scope_bound", "profile-scope"),
    ("profile_symbols_valid", "profile-symbols"),
    ("profile_overhead_bounded", "profile-overhead"),
    ("offcpu_evidence_checked", "offcpu"),
    ("correlation_challenged", "causality"),
    ("one_variable_changed", "change-isolation"),
    ("tunable_semantics_verified", "tunable-semantics"),
    ("security_impact_reviewed", "security-impact"),
    ("resource_policy_reviewed", "resource-policy"),
    ("canary_representative", "canary"),
    ("stop_criteria_predeclared", "stop-criteria"),
    ("rollback_proven", "rollback"),
    ("before_after_compared", "comparison"),
    ("regressions_and_drift_monitored", "sustained-verification"),
)
REQUIRED_DEFAULTS = {key for key, _ in ORDERED_GATES}


def load(path: str) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0073":
        raise ValueError("fixture identity")
    defaults, cases = data.get("defaults"), data.get("cases")
    if not isinstance(defaults, dict) or set(defaults) != REQUIRED_DEFAULTS:
        raise ValueError("fixture defaults")
    if not all(isinstance(defaults[key], bool) for key in REQUIRED_DEFAULTS):
        raise ValueError("fixture default types")
    if not isinstance(cases, list) or not cases:
        raise ValueError("fixture cases")
    identifiers: set[str] = set()
    for case in cases:
        if not isinstance(case, dict) or set(case) != {"id", "expect", "override"}:
            raise ValueError("case shape")
        if not isinstance(case["id"], str) or not case["id"] or case["id"] in identifiers:
            raise ValueError("case identity")
        if not isinstance(case["expect"], str) or not case["expect"]:
            raise ValueError("case expectation")
        if not isinstance(case["override"], dict) or not set(case["override"]).issubset(REQUIRED_DEFAULTS):
            raise ValueError("case override")
        if not all(isinstance(value, bool) for value in case["override"].values()):
            raise ValueError("case override types")
        identifiers.add(case["id"])
    if "baseline" not in identifiers:
        raise ValueError("baseline missing")
    return data


def resolve(data: dict[str, Any], case_id: str) -> tuple[dict[str, bool], str]:
    for case in data["cases"]:
        if case["id"] == case_id:
            state = dict(data["defaults"])
            state.update(case["override"])
            return state, case["expect"]
    raise ValueError(f"unknown case: {case_id}")


def boundary(state: dict[str, bool]) -> str:
    for key, result in ORDERED_GATES:
        if not state[key]:
            return result
    return "defensible"


def validate(data: dict[str, Any]) -> None:
    for case in data["cases"]:
        state, expected = resolve(data, case["id"])
        actual = boundary(state)
        if actual != expected:
            raise ValueError(f"{case['id']}: expected {expected}, got {actual}")


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        raise ValueError("usage")
    action, path = argv[1], argv[2]
    data = load(path)
    validate(data)
    if action == "validate" and len(argv) == 3:
        print(f"model=valid cases={len(data['cases'])}")
    elif action == "list" and len(argv) == 3:
        for case in data["cases"]:
            print(case["id"])
    elif action == "evaluate-all" and len(argv) == 3:
        for case in data["cases"]:
            state, _ = resolve(data, case["id"])
            print(f"case={case['id']} boundary={boundary(state)}")
    elif action in {"show", "evaluate"} and len(argv) == 4:
        state, expected = resolve(data, argv[3])
        if action == "show":
            print(json.dumps({"id": argv[3], "expected": expected, "state": state}, sort_keys=True))
        else:
            print(f"case={argv[3]} boundary={boundary(state)}")
    else:
        raise ValueError("usage")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"model=fail reason={exc}", file=sys.stderr)
        raise SystemExit(1)
