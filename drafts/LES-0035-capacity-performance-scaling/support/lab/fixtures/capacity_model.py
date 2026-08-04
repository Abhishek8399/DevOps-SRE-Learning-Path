#!/usr/bin/env python3
"""Deterministic offline capacity reasoning model for LES-0035."""

from __future__ import annotations

import argparse
import json
import math
import os
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0035"
CASE_ID = "capacity-knee-v1"
CASES = ("baseline", "curve", "queue", "forecast", "autoscale", "workload", "overload")


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
    require(isinstance(data.get("baseline"), dict), "baseline must be an object")
    curve = data.get("curve")
    require(isinstance(curve, list) and len(curve) == 5, "curve must have five points")
    require([point["offeredRps"] for point in curve] == sorted(point["offeredRps"] for point in curve), "curve offered load must increase")
    for key in ("queue", "forecast", "autoscale", "workload"):
        require(isinstance(data.get(key), dict), f"{key} must be an object")
    require(isinstance(data.get("overload"), list) and len(data["overload"]) == 5, "overload must have five classes")


def validate_state(path: Path, uid: int) -> None:
    expected = Path(f"/tmp/reliability-atlas-les0035-{uid}")
    require(path.is_absolute() and path == expected, "state path mismatch")
    require(path.exists() and path.is_dir() and not path.is_symlink(), "state must be a regular directory")
    require(path.stat().st_uid == uid, "state owner mismatch")
    sentinel, manifest, scenario = path / "SENTINEL", path / "manifest.json", path / "scenario.json"
    for item in (sentinel, manifest, scenario):
        require(item.is_file() and not item.is_symlink(), f"invalid state file: {item.name}")
        require(item.stat().st_uid == uid, f"owner mismatch: {item.name}")
    require(sentinel.read_text(encoding="utf-8") == f"{LESSON_ID}:{uid}\n", "sentinel mismatch")
    require(load_json(manifest) == {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(path), "caseId": CASE_ID}, "manifest mismatch")
    validate_scenario(load_json(scenario))
    require({item.name for item in path.iterdir()} <= {"SENTINEL", "manifest.json", "scenario.json", "result.json"}, "unexpected state entry")
    result = path / "result.json"
    if result.exists():
        require(result.is_file() and not result.is_symlink() and result.stat().st_uid == uid, "result invalid")


def evaluate(case: str, data: dict[str, Any]) -> dict[str, Any]:
    validate_scenario(data)
    require(case in CASES, f"unknown case: {case}")
    if case == "baseline":
        value = data["baseline"]
        require(value["offered"] >= value["accepted"] >= value["completed"] >= value["goodput"], "work states must be monotonic")
        return {"case": case, **value, "attemptRatio": round((value["accepted"] + value["retriedAttempts"]) / value["accepted"], 3)}
    if case == "curve":
        curve = data["curve"]
        base_p99 = curve[0]["p99Ms"]
        knee = next(point for point in curve if point["p99Ms"] >= base_p99 * 2 and point["goodputRps"] < point["offeredRps"] * 0.98)
        collapse = next(curve[index] for index in range(1, len(curve)) if curve[index]["goodputRps"] < curve[index - 1]["goodputRps"])
        peak = max(curve, key=lambda point: point["goodputRps"])
        return {"case": case, "kneeRps": knee["offeredRps"], "collapseRps": collapse["offeredRps"], "peakGoodputRps": peak["goodputRps"], "kneeP99Ms": knee["p99Ms"]}
    if case == "queue":
        value = data["queue"]
        estimated = round(value["throughputPerSecond"] * value["averageTimeSeconds"])
        error_pct = abs(value["observedConcurrency"] - estimated) / estimated * 100
        return {"case": case, "estimatedConcurrency": estimated, "observedConcurrency": value["observedConcurrency"], "differencePct": round(error_pct, 3), "withinTolerance": error_pct <= value["tolerancePct"]}
    if case == "forecast":
        value = data["forecast"]
        raw = value["baselineRps"] * value["growthFactor"] * value["eventFactor"] * value["uncertaintyFactor"] * value["failureReserveFactor"]
        required = math.ceil(raw / 50) * 50
        replicas = math.ceil(required / value["safeRpsPerReplica"])
        return {"case": case, "rawRequiredRps": round(raw, 3), "requiredRps": required, "requiredReplicas": replicas, "safeRpsPerReplica": value["safeRpsPerReplica"]}
    if case == "autoscale":
        value = data["autoscale"]
        reaction = sum(value[key] for key in ("metricDelaySeconds", "controllerDelaySeconds", "supplyDelaySeconds", "warmupSeconds"))
        return {"case": case, "reactionSeconds": reaction, "queueBufferSeconds": value["queueBufferSeconds"], "safe": reaction <= value["queueBufferSeconds"]}
    if case == "workload":
        value = data["workload"]
        share = sum(item["share"] for item in value["classes"])
        return {"case": case, "classes": len(value["classes"]), "shareTotal": round(share, 3), "generatorHeadroomPct": 100 - value["generatorCpuPct"], "valid": abs(share - 1.0) < 1e-9 and value["generatorCpuPct"] <= 70}
    items = data["overload"]
    admitted = [item for item in items if item["admit"]]
    shed = [item for item in items if not item["admit"]]
    inversion = bool(admitted and shed and max(item["priority"] for item in admitted) > min(item["priority"] for item in shed))
    return {"case": case, "admitted": len(admitted), "shed": len(shed), "priorityInversion": inversion}


def compact(result: dict[str, Any]) -> str:
    parts = []
    for key, value in result.items():
        if isinstance(value, bool):
            rendered = str(value).lower()
        else:
            rendered = str(value)
        parts.append(f"{key}={rendered}")
    return " ".join(parts)


def build_parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    commands = result.add_subparsers(dest="command", required=True)
    validate = commands.add_parser("validate-scenario")
    validate.add_argument("scenario", type=Path)
    state = commands.add_parser("validate-state")
    state.add_argument("state", type=Path)
    state.add_argument("--uid", required=True, type=int)
    run = commands.add_parser("run")
    run.add_argument("case", choices=CASES)
    run.add_argument("scenario", type=Path)
    run.add_argument("--result", type=Path)
    return result


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
    except (OSError, ValueError, KeyError, TypeError, StopIteration) as exc:
        print(f"model_error={type(exc).__name__} detail={exc}", file=__import__("sys").stderr)
        raise SystemExit(65)
