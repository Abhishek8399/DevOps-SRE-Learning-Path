#!/usr/bin/env python3
"""Deterministic offline IaC reasoning model for LES-0037."""

from __future__ import annotations

import argparse
import json
import os
from collections import Counter
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0037"
CASE_ID = "iac-change-system-v1"
CASES = ("graph", "plan", "drift", "policy", "partial", "converge", "sensitive")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        value = json.load(handle)
    require(isinstance(value, dict), "top-level JSON must be an object")
    return value


def resource_map(items: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {item["name"]: item for item in items}


def graph_order(desired: list[dict[str, Any]]) -> tuple[list[str], bool]:
    names = {item["name"] for item in desired}
    incoming = {item["name"]: set(item["dependsOn"]) for item in desired}
    require(all(dependency in names for values in incoming.values() for dependency in values), "graph has unknown dependency")
    order: list[str] = []
    ready = sorted(name for name, dependencies in incoming.items() if not dependencies)
    while ready:
        name = ready.pop(0)
        order.append(name)
        for candidate in sorted(names - set(order)):
            if name in incoming[candidate]:
                incoming[candidate].remove(name)
                if not incoming[candidate] and candidate not in ready:
                    ready.append(candidate)
                    ready.sort()
    return order, len(order) != len(names)


def plan_actions(desired: list[dict[str, Any]], current: list[dict[str, Any]]) -> list[dict[str, str]]:
    wanted = resource_map(desired)
    observed = resource_map(current)
    actions: list[dict[str, str]] = []
    for name in sorted(wanted):
        if name not in observed:
            action = "create"
        elif wanted[name]["kind"] != observed[name]["kind"]:
            action = "replace"
        elif wanted[name]["attributes"] != observed[name]["attributes"]:
            action = "update"
        else:
            action = "no-op"
        actions.append({"resource": name, "action": action})
    for name in sorted(set(observed) - set(wanted)):
        actions.append({"resource": name, "action": "delete"})
    return actions


def validate_scenario(data: dict[str, Any]) -> None:
    require(data.get("schemaVersion") == 1, "schemaVersion must be 1")
    require(data.get("lessonId") == LESSON_ID, "lessonId mismatch")
    require(data.get("caseId") == CASE_ID, "caseId mismatch")
    require(data.get("fictional") is True, "fixture must be fictional")
    desired = data.get("desired")
    current = data.get("current")
    require(isinstance(desired, list) and len(desired) == 3, "desired must contain three resources")
    require(isinstance(current, list) and len(current) == 3, "current must contain three resources")
    for item in desired:
        require(isinstance(item, dict), "desired resource must be an object")
        require(isinstance(item.get("name"), str) and item["name"], "desired name invalid")
        require(isinstance(item.get("kind"), str) and item["kind"], "desired kind invalid")
        require(isinstance(item.get("dependsOn"), list), "dependsOn must be an array")
        require(isinstance(item.get("attributes"), dict), "desired attributes must be an object")
    for item in current:
        require(isinstance(item, dict), "current resource must be an object")
        require(all(isinstance(item.get(key), str) and item[key] for key in ("name", "remoteId", "kind")), "current identity invalid")
        require(isinstance(item.get("attributes"), dict), "current attributes must be an object")
    require(len(resource_map(desired)) == len(desired), "duplicate desired name")
    require(len(resource_map(current)) == len(current), "duplicate current name")
    order, cycle = graph_order(desired)
    require(not cycle and order == ["network", "database", "service"], "unexpected desired graph")
    drift = data.get("drift")
    require(isinstance(drift, dict) and drift.get("resource") == "service", "drift contract invalid")
    require(drift.get("source") == "out-of-band", "drift source invalid")
    policy = data.get("policyCandidate")
    require(isinstance(policy, dict) and policy.get("kind") == "database", "policy candidate invalid")
    require(policy.get("public") is True, "policy fixture must exercise denial")
    partial = data.get("partialExecution")
    require(isinstance(partial, list) and len(partial) == 3, "partial execution must have three outcomes")
    require([item.get("result") for item in partial] == ["succeeded", "failed", "blocked"], "partial outcome order invalid")
    sensitive = data.get("sensitive")
    require(isinstance(sensitive, dict), "sensitive must be an object")
    require(sensitive.get("display") == "<redacted>" and bool(sensitive.get("stored")), "sensitive fixture invalid")


def validate_state(path: Path, uid: int) -> None:
    expected = Path(f"/tmp/reliability-atlas-les0037-{uid}")
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
    if case == "graph":
        order, cycle = graph_order(data["desired"])
        return {"case": case, "nodes": len(order), "order": ",".join(order), "cycle": cycle}
    if case == "plan":
        actions = plan_actions(data["desired"], data["current"])
        counts = Counter(item["action"] for item in actions)
        return {"case": case, "create": counts["create"], "update": counts["update"], "replace": counts["replace"], "delete": counts["delete"], "noOp": counts["no-op"], "changes": sum(value for key, value in counts.items() if key != "no-op")}
    if case == "drift":
        value = data["drift"]
        return {"case": case, "drifted": 1 if value["observed"] != value["desired"] else 0, "resource": value["resource"], "attribute": value["attribute"], "source": value["source"], "decisionRequired": True}
    if case == "policy":
        value = data["policyCandidate"]
        denied = value["kind"] == "database" and value["public"] is True
        return {"case": case, "evaluated": 1, "denied": int(denied), "reason": "public-database" if denied else "none"}
    if case == "partial":
        counts = Counter(item["result"] for item in data["partialExecution"])
        return {"case": case, "succeeded": counts["succeeded"], "failed": counts["failed"], "blocked": counts["blocked"], "transactionalRollback": False, "newPlanRequired": True}
    if case == "converge":
        first = plan_actions(data["desired"], data["current"])
        reconciled = [{"name": item["name"], "remoteId": f"fixture-{item['name']}", "kind": item["kind"], "attributes": item["attributes"]} for item in data["desired"]]
        second = plan_actions(data["desired"], reconciled)
        first_changes = sum(item["action"] != "no-op" for item in first)
        second_changes = sum(item["action"] != "no-op" for item in second)
        return {"case": case, "firstChanges": first_changes, "secondChanges": second_changes, "converged": second_changes == 0}
    value = data["sensitive"]
    return {"case": case, "displayRedacted": value["display"] == "<redacted>", "stateContainsSensitive": bool(value["stored"]), "encryptedClaimed": False}


def compact(result: dict[str, Any]) -> str:
    return " ".join(f"{key}={str(value).lower() if isinstance(value, bool) else value}" for key, value in result.items())


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
