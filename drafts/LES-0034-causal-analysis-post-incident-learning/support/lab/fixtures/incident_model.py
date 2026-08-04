#!/usr/bin/env python3
"""Deterministic, offline causal-analysis teaching model for LES-0034."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0034"
CASE_ID = "queue-collapse-v1"
SENTINEL_PREFIX = f"{LESSON_ID}:"
CASES = ("timeline", "claims", "graph", "counterfactual", "methods", "actions", "verification")


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError("top-level JSON must be an object")
    return value


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def validate_scenario(data: dict[str, Any]) -> None:
    require(data.get("schemaVersion") == 1, "schemaVersion must be 1")
    require(data.get("lessonId") == LESSON_ID, "lessonId mismatch")
    require(data.get("caseId") == CASE_ID, "caseId mismatch")
    require(data.get("fictional") is True, "fixture must be fictional")
    expected = {
        "timeline": 3,
        "claims": 6,
        "counterfactuals": 4,
        "actions": 8,
        "verification": 6,
    }
    for key, count in expected.items():
        require(isinstance(data.get(key), list), f"{key} must be a list")
        require(len(data[key]) == count, f"{key} count must be {count}")
    graph = data.get("graph")
    require(isinstance(graph, dict), "graph must be an object")
    require(len(graph.get("nodes", [])) == 8, "graph must have eight nodes")
    require(len(graph.get("edges", [])) == 7, "graph must have seven edges")
    require(isinstance(data.get("methods"), dict), "methods must be an object")


def validate_state(path: Path, uid: int) -> None:
    require(path.is_absolute(), "state path must be absolute")
    require(path == Path(f"/tmp/reliability-atlas-les0034-{uid}"), "state path mismatch")
    require(path.exists(), "state does not exist")
    require(not path.is_symlink(), "state cannot be a symlink")
    require(path.is_dir(), "state must be a directory")
    require(path.stat().st_uid == uid, "state owner mismatch")
    sentinel = path / "SENTINEL"
    manifest = path / "manifest.json"
    scenario = path / "scenario.json"
    for item in (sentinel, manifest, scenario):
        require(item.is_file() and not item.is_symlink(), f"invalid state file: {item.name}")
        require(item.stat().st_uid == uid, f"owner mismatch: {item.name}")
    require(sentinel.read_text(encoding="utf-8") == f"{SENTINEL_PREFIX}{uid}\n", "sentinel mismatch")
    manifest_data = load_json(manifest)
    require(manifest_data == {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(path), "caseId": CASE_ID}, "manifest mismatch")
    validate_scenario(load_json(scenario))
    allowed = {"SENTINEL", "manifest.json", "scenario.json", "result.json"}
    require({item.name for item in path.iterdir()} <= allowed, "unexpected state entry")
    result = path / "result.json"
    if result.exists():
        require(result.is_file() and not result.is_symlink(), "result must be a regular file")
        require(result.stat().st_uid == uid, "result owner mismatch")


def graph_is_acyclic(nodes: list[str], edges: list[dict[str, Any]]) -> bool:
    outgoing = {node: [] for node in nodes}
    indegree = {node: 0 for node in nodes}
    for edge in edges:
        source, target = edge["from"], edge["to"]
        require(source in outgoing and target in outgoing, "edge names unknown node")
        outgoing[source].append(target)
        indegree[target] += 1
    ready = [node for node in nodes if indegree[node] == 0]
    visited = 0
    while ready:
        node = ready.pop()
        visited += 1
        for target in outgoing[node]:
            indegree[target] -= 1
            if indegree[target] == 0:
                ready.append(target)
    return visited == len(nodes)


def evaluate(case: str, data: dict[str, Any]) -> dict[str, Any]:
    validate_scenario(data)
    require(case in CASES, f"unknown case: {case}")
    if case == "timeline":
        events = data["timeline"]
        raw_order = [event["id"] for event in sorted(events, key=lambda item: item["raw"])]
        normalized = [event["id"] for event in sorted(events, key=lambda item: item["normalizedEpochMs"])]
        return {"case": case, "rawOrder": raw_order, "normalizedOrder": normalized, "rawOrderConflict": raw_order != normalized, "uncertainEvents": sum(event["uncertaintyMs"] >= 1000 for event in events)}
    if case == "claims":
        claims = data["claims"]
        unsupported = [claim["id"] for claim in claims if not claim["evidenceIds"]]
        return {"case": case, "total": len(claims), "supported": len(claims) - len(unsupported), "unsupported": len(unsupported), "unsupportedIds": unsupported}
    if case == "graph":
        graph = data["graph"]
        supported = sum(bool(edge["mechanism"] and edge["evidenceIds"]) for edge in graph["edges"])
        return {"case": case, "nodes": len(graph["nodes"]), "links": len(graph["edges"]), "supportedLinks": supported, "unsupportedLinks": len(graph["edges"]) - supported, "acyclic": graph_is_acyclic(graph["nodes"], graph["edges"])}
    if case == "counterfactual":
        items = data["counterfactuals"]
        testable = sum(bool(item["intervention"] and item["prediction"] and item["falsifier"] and item["heldConstant"] and not item["confounded"]) for item in items)
        return {"case": case, "total": len(items), "testable": testable, "confounded": sum(bool(item["confounded"]) for item in items)}
    if case == "methods":
        methods = data["methods"]
        return {"case": case, "linearCoverage": methods["fiveWhysCoveredConditions"], "graphCoverage": methods["causalGraphCoveredConditions"], "barriersReviewed": methods["barriersReviewed"]}
    if case == "actions":
        actions = data["actions"]
        accepted = sum(bool(item["accepted"]) for item in actions)
        return {"case": case, "total": len(actions), "accepted": accepted, "rejected": len(actions) - accepted}
    states: dict[str, int] = {}
    for item in data["verification"]:
        states[item["state"]] = states.get(item["state"], 0) + 1
    return {"case": case, "total": len(data["verification"]), "verifiedEffective": states.get("verified-effective", 0), "ineffective": states.get("ineffective", 0), "overdue": states.get("overdue", 0)}


def compact(result: dict[str, Any]) -> str:
    ordered = ["case", "total", "rawOrder", "normalizedOrder", "rawOrderConflict", "uncertainEvents", "supported", "unsupported", "unsupportedIds", "nodes", "links", "supportedLinks", "unsupportedLinks", "acyclic", "testable", "confounded", "linearCoverage", "graphCoverage", "barriersReviewed", "accepted", "rejected", "verifiedEffective", "ineffective", "overdue"]
    parts: list[str] = []
    for key in ordered:
        if key not in result:
            continue
        value = result[key]
        if isinstance(value, bool):
            rendered = str(value).lower()
        elif isinstance(value, list):
            rendered = ",".join(str(item) for item in value)
        else:
            rendered = str(value)
        parts.append(f"{key}={rendered}")
    return " ".join(parts)


def parser() -> argparse.ArgumentParser:
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
    args = parser().parse_args()
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
        require(args.result.parent.is_dir(), "result parent must exist")
        require(not args.result.is_symlink(), "result cannot be a symlink")
        temporary = args.result.with_suffix(".tmp")
        require(not temporary.exists(), "temporary result already exists")
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
