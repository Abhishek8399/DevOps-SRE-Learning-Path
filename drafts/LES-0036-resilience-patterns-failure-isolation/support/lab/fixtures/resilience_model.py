#!/usr/bin/env python3
"""Deterministic offline resilience reasoning model for LES-0036."""

from __future__ import annotations

import argparse
import json
import math
import os
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0036"
CASE_ID = "resilience-containment-v1"
CASES = ("deadline", "retries", "jitter", "idempotency", "circuit", "bulkhead")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    require(isinstance(value, dict), "top-level JSON must be an object")
    return value


def validate_scenario(data: dict[str, Any]) -> None:
    require(data.get("schemaVersion") == 1, "schemaVersion must be 1")
    require(data.get("lessonId") == LESSON_ID, "lessonId mismatch")
    require(data.get("caseId") == CASE_ID, "caseId mismatch")
    require(data.get("fictional") is True, "fixture must be fictional")

    deadline = data.get("deadline")
    require(isinstance(deadline, dict), "deadline must be an object")
    require(isinstance(deadline.get("totalMs"), int) and deadline["totalMs"] > 0, "deadline total must be positive integer")
    allocations = deadline.get("allocationsMs")
    require(isinstance(allocations, dict) and len(allocations) == 7, "deadline requires seven allocations")
    require(all(isinstance(value, int) and value >= 0 for value in allocations.values()), "allocations must be nonnegative integers")

    retries = data.get("retries")
    require(isinstance(retries, dict), "retries must be an object")
    layer_attempts = retries.get("layerTotalAttempts")
    require(isinstance(layer_attempts, list) and len(layer_attempts) == 3, "three retry layers required")
    require(all(isinstance(value, int) and value >= 1 for value in layer_attempts), "layer attempts must be positive integers")
    require(isinstance(retries.get("globalTotalAttempts"), int) and retries["globalTotalAttempts"] >= 1, "global attempts invalid")

    jitter = data.get("jitter")
    require(isinstance(jitter, dict), "jitter must be an object")
    require(isinstance(jitter.get("slots"), list) and len(jitter["slots"]) == 8, "eight jitter slots required")
    require(all(isinstance(value, int) and value >= 0 for value in jitter["slots"]), "jitter slots invalid")

    idempotency = data.get("idempotency")
    require(isinstance(idempotency, dict), "idempotency must be an object")
    requests = idempotency.get("requests")
    require(isinstance(requests, list) and len(requests) == 4, "four idempotency requests required")
    for request in requests:
        require(isinstance(request, dict), "idempotency request must be an object")
        require(all(isinstance(request.get(key), str) and request[key] for key in ("key", "principal", "fingerprint", "outcome")), "idempotency fields invalid")
        require(request["outcome"] in {"committed", "replay", "conflict"}, "unknown idempotency outcome")

    circuit = data.get("circuit")
    require(isinstance(circuit, dict), "circuit must be an object")
    window = circuit.get("closedWindow")
    probes = circuit.get("halfOpenProbes")
    require(isinstance(window, list) and len(window) >= circuit.get("minimumSamples", 0), "circuit window too small")
    require(isinstance(probes, list) and len(probes) == 2, "two half-open probes required")
    require(set(window + probes) <= {"success", "failure"}, "circuit outcome invalid")
    require(isinstance(circuit.get("openFailureRatio"), (int, float)) and 0 < circuit["openFailureRatio"] <= 1, "circuit ratio invalid")

    bulkhead = data.get("bulkhead")
    require(isinstance(bulkhead, dict), "bulkhead must be an object")
    for key in ("sharedCapacity", "criticalDemand", "optionalDemand", "criticalReserve", "optionalReserve"):
        require(isinstance(bulkhead.get(key), int) and bulkhead[key] >= 0, f"bulkhead {key} invalid")
    require(bulkhead["criticalReserve"] + bulkhead["optionalReserve"] <= bulkhead["sharedCapacity"], "reserves exceed capacity")


def validate_state(path: Path, uid: int) -> None:
    expected = Path(f"/tmp/reliability-atlas-les0036-{uid}")
    require(path.is_absolute() and path == expected, "state path mismatch")
    require(path.exists() and path.is_dir() and not path.is_symlink(), "state must be a regular directory")
    require(path.stat().st_uid == uid, "state owner mismatch")
    sentinel, manifest, scenario = path / "SENTINEL", path / "manifest.json", path / "scenario.json"
    for item in (sentinel, manifest, scenario):
        require(item.is_file() and not item.is_symlink(), f"invalid state file: {item.name}")
        require(item.stat().st_uid == uid, f"owner mismatch: {item.name}")
    require(sentinel.read_text(encoding="utf-8") == f"{LESSON_ID}:{uid}\n", "sentinel mismatch")
    require(
        load_json(manifest)
        == {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(path), "caseId": CASE_ID},
        "manifest mismatch",
    )
    validate_scenario(load_json(scenario))
    require({item.name for item in path.iterdir()} <= {"SENTINEL", "manifest.json", "scenario.json", "result.json"}, "unexpected state entry")
    result = path / "result.json"
    if result.exists():
        require(result.is_file() and not result.is_symlink() and result.stat().st_uid == uid, "result invalid")


def evaluate(case: str, data: dict[str, Any]) -> dict[str, Any]:
    validate_scenario(data)
    require(case in CASES, f"unknown case: {case}")
    if case == "deadline":
        value = data["deadline"]
        allocated = sum(value["allocationsMs"].values())
        remaining = value["totalMs"] - allocated
        return {"case": case, "totalMs": value["totalMs"], "allocatedMs": allocated, "remainingMs": remaining, "valid": remaining >= 0}
    if case == "retries":
        value = data["retries"]
        unbounded = math.prod(value["layerTotalAttempts"])
        budgeted = value["globalTotalAttempts"]
        return {"case": case, "layers": len(value["layerTotalAttempts"]), "unboundedAttempts": unbounded, "budgetedAttempts": budgeted, "amplificationContained": budgeted < unbounded}
    if case == "jitter":
        slots = data["jitter"]["slots"]
        unique = len(set(slots))
        return {"case": case, "clients": len(slots), "uniqueSlots": unique, "synchronized": unique == 1}
    if case == "idempotency":
        requests = data["idempotency"]["requests"]
        first = requests[0]
        require(first["outcome"] == "committed", "first request must commit")
        side_effects = sum(1 for request in requests if request["outcome"] == "committed")
        conflicts = sum(1 for request in requests if request["outcome"] == "conflict")
        replays = sum(1 for request in requests if request["outcome"] == "replay")
        require(all(request["key"] == first["key"] and request["principal"] == first["principal"] for request in requests), "key scope changed")
        require(all(request["fingerprint"] == first["fingerprint"] for request in requests if request["outcome"] != "conflict"), "matching replay fingerprint changed")
        return {"case": case, "requests": len(requests), "sideEffects": side_effects, "replays": replays, "conflicts": conflicts, "safe": side_effects == 1 and conflicts == 1}
    if case == "circuit":
        value = data["circuit"]
        window = value["closedWindow"]
        failure_ratio = sum(1 for item in window if item == "failure") / len(window)
        opened = len(window) >= value["minimumSamples"] and failure_ratio >= value["openFailureRatio"]
        probes = value["halfOpenProbes"] if opened else []
        final_state = "closed" if probes and all(item == "success" for item in probes) else ("open" if opened else "closed")
        return {"case": case, "samples": len(window), "failureRatio": round(failure_ratio, 3), "opened": opened, "probes": len(probes), "finalState": final_state}
    value = data["bulkhead"]
    shared_critical_accepted = max(0, min(value["criticalDemand"], value["sharedCapacity"] - value["optionalDemand"]))
    partitioned_critical_accepted = min(value["criticalDemand"], value["criticalReserve"])
    return {
        "case": case,
        "criticalDemand": value["criticalDemand"],
        "sharedCriticalAccepted": shared_critical_accepted,
        "partitionedCriticalAccepted": partitioned_critical_accepted,
        "sharedProtected": shared_critical_accepted == value["criticalDemand"],
        "bulkheadProtected": partitioned_critical_accepted == value["criticalDemand"],
    }


def compact(result: dict[str, Any]) -> str:
    parts = []
    for key, value in result.items():
        rendered = str(value).lower() if isinstance(value, bool) else str(value)
        parts.append(f"{key}={rendered}")
    return " ".join(parts)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    validate = commands.add_parser("validate-scenario")
    validate.add_argument("scenario", type=Path)
    state = commands.add_parser("validate-state")
    state.add_argument("state", type=Path)
    state.add_argument("--uid", required=True, type=int)
    run = commands.add_parser("run")
    run.add_argument("case", choices=CASES)
    run.add_argument("scenario", type=Path)
    run.add_argument("--result", type=Path)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    if args.command == "validate-scenario":
        validate_scenario(load_json(args.scenario))
        print(f"valid=true lesson={LESSON_ID} case={CASE_ID}")
        return 0
    if args.command == "validate-state":
        validate_state(args.state, args.uid)
        print(f"valid=true state={args.state} uid={args.uid}")
        return 0
    value = evaluate(args.case, load_json(args.scenario))
    if args.result is not None:
        require(args.result.parent.is_dir(), "result parent missing")
        require(not args.result.is_symlink(), "result cannot be a symlink")
        temporary = args.result.with_suffix(".tmp")
        require(not temporary.exists(), "temporary result exists")
        with temporary.open("x", encoding="utf-8") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
        os.replace(temporary, args.result)
    print(compact(value))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f"model_error={type(exc).__name__} detail={exc}", file=__import__("sys").stderr)
        raise SystemExit(65)
