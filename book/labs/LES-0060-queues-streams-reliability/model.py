#!/usr/bin/env python3
"""Deterministic LES-0060 queue and stream architecture boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "publisherAckExplicit", "stableEventId", "partitionKeyBound",
    "orderingScopeBound", "retryReusesId", "idempotentEffect",
    "checkpointAfterEffect", "boundedRetries", "quarantineOwner",
    "ingressPerSecond", "servicePerSecond", "outageSeconds",
    "recoveryWindowSeconds", "hottestPartitionPerSecond",
    "perPartitionCapacity", "retentionSeconds", "recoveryHorizonSeconds",
    "fencedAssignment", "guardedReplay", "availableReplicas",
    "requiredReplicas", "scopedAuthorization", "expected",
}

BOOLEAN_FIELDS = {
    "publisherAckExplicit", "stableEventId", "partitionKeyBound",
    "orderingScopeBound", "retryReusesId", "idempotentEffect",
    "checkpointAfterEffect", "boundedRetries", "quarantineOwner",
    "fencedAssignment", "guardedReplay", "scopedAuthorization",
}

INTEGER_FIELDS = {
    "ingressPerSecond", "servicePerSecond", "outageSeconds",
    "recoveryWindowSeconds", "hottestPartitionPerSecond",
    "perPartitionCapacity", "retentionSeconds", "recoveryHorizonSeconds",
    "availableReplicas", "requiredReplicas",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0060":
        raise ValueError("fixture identity")
    cases = data.get("cases")
    if not isinstance(cases, list) or not cases:
        raise ValueError("cases")
    seen = set()
    for case in cases:
        if set(case) != REQUIRED:
            raise ValueError(f"case fields: {case.get('id', 'unknown')}")
        if not isinstance(case["id"], str) or not case["id"] or case["id"] in seen:
            raise ValueError("case identity")
        if not isinstance(case["expected"], str) or not case["expected"]:
            raise ValueError(f"expected: {case['id']}")
        seen.add(case["id"])
        for field in BOOLEAN_FIELDS:
            if not isinstance(case[field], bool):
                raise ValueError(f"boolean field: {case['id']}:{field}")
        for field in INTEGER_FIELDS:
            if not isinstance(case[field], int) or case[field] < 0:
                raise ValueError(f"integer field: {case['id']}:{field}")
        if case["requiredReplicas"] < 1:
            raise ValueError(f"required replicas: {case['id']}")
    return data


def evaluate(case: dict) -> str:
    if not case["publisherAckExplicit"]:
        return "publisher-ack"
    if not case["stableEventId"]:
        return "event-identity"
    if not case["partitionKeyBound"] or not case["orderingScopeBound"]:
        return "ordering-contract"
    if not case["retryReusesId"]:
        return "producer-duplicate"
    if not case["idempotentEffect"]:
        return "consumer-duplicate"
    if not case["checkpointAfterEffect"]:
        return "effect-loss"
    if not case["boundedRetries"]:
        return "poison-loop"
    if not case["quarantineOwner"]:
        return "quarantine"
    spare = case["servicePerSecond"] - case["ingressPerSecond"]
    backlog = case["ingressPerSecond"] * case["outageSeconds"]
    recoverable = spare > 0 and (
        spare * case["recoveryWindowSeconds"] >= backlog
    )
    if not recoverable:
        return "backlog-drain"
    if case["hottestPartitionPerSecond"] > case["perPartitionCapacity"]:
        return "hot-partition"
    if case["retentionSeconds"] < case["recoveryHorizonSeconds"]:
        return "replay-horizon"
    if not case["fencedAssignment"]:
        return "stale-consumer"
    if not case["guardedReplay"]:
        return "replay-effect"
    if case["availableReplicas"] < case["requiredReplicas"]:
        return "durability-availability"
    if not case["scopedAuthorization"]:
        return "security-boundary"
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
