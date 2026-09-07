#!/usr/bin/env python3
"""Deterministic LES-0058 distributed-systems boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "nodes", "writeQuorum", "readQuorum", "reachableVoters",
    "leaderReachable", "leaderHasQuorum", "linearizableRead",
    "readFromLeader", "requiredIndex", "servedIndex", "dualWriterPossible",
    "leaseUsesMonotonicTime", "fencingTokenChecked",
    "causalDependencyRequired", "causalTokenPresent", "repairEnabled",
    "configTransitionOverlaps", "expected",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0058":
        raise ValueError("fixture identity")
    cases = data.get("cases")
    if not isinstance(cases, list) or not cases:
        raise ValueError("cases")
    seen = set()
    for case in cases:
        if set(case) != REQUIRED:
            raise ValueError(f"case fields: {case.get('id', 'unknown')}")
        case_id = case["id"]
        if not isinstance(case_id, str) or not case_id or case_id in seen:
            raise ValueError("case identity")
        seen.add(case_id)
        for field in ("nodes", "writeQuorum", "readQuorum", "reachableVoters",
                      "requiredIndex", "servedIndex"):
            if not isinstance(case[field], int) or case[field] < 0:
                raise ValueError(f"integer field: {case_id}:{field}")
    return data


def evaluate(case: dict) -> str:
    nodes = case["nodes"]
    write_quorum = case["writeQuorum"]
    read_quorum = case["readQuorum"]
    if (
        nodes < 3
        or nodes % 2 == 0
        or not 1 <= write_quorum <= nodes
        or not 1 <= read_quorum <= nodes
    ):
        return "membership-shape"
    if not case["configTransitionOverlaps"]:
        return "membership-change"
    if case["reachableVoters"] < write_quorum:
        return "quorum-loss"
    if case["linearizableRead"] and read_quorum + write_quorum <= nodes:
        return "quorum-intersection"
    if case["dualWriterPossible"]:
        return "split-brain"
    if case["leaderReachable"] and not case["leaderHasQuorum"]:
        return "stale-leader"
    if not case["leaseUsesMonotonicTime"]:
        return "clock-safety"
    if not case["fencingTokenChecked"]:
        return "stale-writer"
    if case["causalDependencyRequired"] and not case["causalTokenPresent"]:
        return "causal-order"
    if case["requiredIndex"] > case["servedIndex"]:
        if case["linearizableRead"] or case["readFromLeader"]:
            return "stale-read"
        return "replication-lag"
    if not case["repairEnabled"]:
        return "convergence"
    return "operable"


def case_by_id(data: dict, case_id: str) -> dict:
    for case in data["cases"]:
        if case["id"] == case_id:
            return case
    raise ValueError("unknown case")


def main() -> int:
    if len(sys.argv) < 3:
        return 2
    command, path = sys.argv[1:3]
    data = load(path)
    if command == "validate":
        print(f"fixture=valid cases={len(data['cases'])}")
        return 0
    if command == "list":
        print("\n".join(case["id"] for case in data["cases"]))
        return 0
    if len(sys.argv) != 4:
        return 2
    case = case_by_id(data, sys.argv[3])
    if command == "show":
        print(json.dumps(case, sort_keys=True, indent=2))
        return 0
    if command == "evaluate":
        boundary = evaluate(case)
        decision = "operable" if boundary == "operable" else "not-operable"
        print(f"case={case['id']} decision={decision} boundary={boundary}")
        return 0 if boundary == case["expected"] else 1
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
