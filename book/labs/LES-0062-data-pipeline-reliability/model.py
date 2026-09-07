#!/usr/bin/env python3
"""Deterministic LES-0062 data-pipeline architecture boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "sourceReplayable", "stableSourcePosition",
    "deterministicTransform", "idempotentSink", "durableCheckpoint",
    "compatibleCheckpoint", "idleInputHandled", "allowedLatenessSeconds",
    "observedLatenessSeconds", "stateRetentionSeconds",
    "recoveryHorizonSeconds", "compatibleSchema", "qualityContract",
    "quarantineOwner", "completeLineage", "hottestPartitionPerSecond",
    "partitionCapacityPerSecond", "ingressPerSecond",
    "servicePerSecond", "outageSeconds", "recoveryWindowSeconds",
    "boundedPrivacyRetention", "isolatedReplaySink", "expected",
}

BOOLEAN_FIELDS = {
    "sourceReplayable", "stableSourcePosition", "deterministicTransform",
    "idempotentSink", "durableCheckpoint", "compatibleCheckpoint",
    "idleInputHandled", "compatibleSchema", "qualityContract",
    "quarantineOwner", "completeLineage", "boundedPrivacyRetention",
    "isolatedReplaySink",
}

INTEGER_FIELDS = {
    "allowedLatenessSeconds", "observedLatenessSeconds",
    "stateRetentionSeconds", "recoveryHorizonSeconds",
    "hottestPartitionPerSecond", "partitionCapacityPerSecond",
    "ingressPerSecond", "servicePerSecond", "outageSeconds",
    "recoveryWindowSeconds",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0062":
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
    return data


def evaluate(case: dict) -> str:
    if not case["sourceReplayable"]:
        return "source-replay"
    if not case["stableSourcePosition"]:
        return "source-position"
    if not case["deterministicTransform"]:
        return "transform-replay"
    if not case["idempotentSink"]:
        return "sink-duplicate"
    if not case["durableCheckpoint"]:
        return "checkpoint-durability"
    if not case["compatibleCheckpoint"]:
        return "checkpoint-compatibility"
    if not case["idleInputHandled"]:
        return "watermark-idleness"
    if case["allowedLatenessSeconds"] < case["observedLatenessSeconds"]:
        return "late-data-policy"
    if case["stateRetentionSeconds"] < case["recoveryHorizonSeconds"]:
        return "state-horizon"
    if not case["compatibleSchema"]:
        return "schema-contract"
    if not case["qualityContract"]:
        return "quality-contract"
    if not case["quarantineOwner"]:
        return "quality-quarantine"
    if not case["completeLineage"]:
        return "lineage-gap"
    if case["hottestPartitionPerSecond"] > case["partitionCapacityPerSecond"]:
        return "data-skew"
    spare = case["servicePerSecond"] - case["ingressPerSecond"]
    backlog = case["ingressPerSecond"] * case["outageSeconds"]
    if spare <= 0 or spare * case["recoveryWindowSeconds"] < backlog:
        return "recovery-drain"
    if not case["boundedPrivacyRetention"]:
        return "privacy-retention"
    if not case["isolatedReplaySink"]:
        return "replay-side-effect"
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
