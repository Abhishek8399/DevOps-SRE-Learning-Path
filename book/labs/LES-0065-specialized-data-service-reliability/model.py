#!/usr/bin/env python3
"""Deterministic LES-0065 specialized data-service boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "partitionKeyBound", "maximumPartitionMiB", "partitionLimitMiB",
    "replicaPlacementSafe", "consistencyClaimBounded",
    "clockSkewMillis", "clockSkewBudgetMillis",
    "repairIntervalHours", "tombstoneGraceHours", "tombstonePurgeRepaired",
    "maintenanceHeadroom", "restoreTested", "securePlanes",
    "embeddingVersionPinned", "vectorShapeCompatible", "stablePointIdentity",
    "recallMeasuredAgainstExact", "payloadFilterIndexed",
    "indexMemoryGiB", "indexMemoryBudgetGiB", "shardReplicaPlacementSafe",
    "vectorSnapshotRestoreTested", "sourceRemainsAuthority",
    "ingestionFreshnessSeconds", "ingestionSloSeconds",
    "lineageVerified", "leastPrivilegeMetadata", "expected",
}

BOOLEAN_FIELDS = {
    "partitionKeyBound", "replicaPlacementSafe", "consistencyClaimBounded",
    "tombstonePurgeRepaired", "maintenanceHeadroom", "restoreTested",
    "securePlanes", "embeddingVersionPinned", "vectorShapeCompatible",
    "stablePointIdentity", "recallMeasuredAgainstExact",
    "payloadFilterIndexed", "shardReplicaPlacementSafe",
    "vectorSnapshotRestoreTested", "sourceRemainsAuthority",
    "lineageVerified", "leastPrivilegeMetadata",
}

INTEGER_FIELDS = {
    "maximumPartitionMiB", "partitionLimitMiB", "clockSkewMillis",
    "clockSkewBudgetMillis", "repairIntervalHours", "tombstoneGraceHours",
    "indexMemoryGiB", "indexMemoryBudgetGiB", "ingestionFreshnessSeconds",
    "ingestionSloSeconds",
}
DEFAULT_FIELDS = REQUIRED - {"id", "expected"}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0065":
        raise ValueError("fixture identity")
    cases = data.get("cases")
    if not isinstance(cases, list) or not cases:
        raise ValueError("cases")
    defaults = data.get("defaults")
    if not isinstance(defaults, dict) or set(defaults) != DEFAULT_FIELDS:
        raise ValueError("defaults")
    for field in BOOLEAN_FIELDS:
        if not isinstance(defaults[field], bool):
            raise ValueError(f"default boolean field: {field}")
    for field in INTEGER_FIELDS:
        if not isinstance(defaults[field], int) or defaults[field] < 0:
            raise ValueError(f"default integer field: {field}")
    seen = set()
    normalized = []
    for override in cases:
        if not isinstance(override, dict):
            raise ValueError("case")
        unknown = set(override) - REQUIRED
        if unknown or not {"id", "expected"} <= set(override):
            raise ValueError(f"case fields: {override.get('id', 'unknown')}")
        case = defaults | override
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
        normalized.append(case)
    data["cases"] = normalized
    return data


def evaluate(case: dict) -> str:
    if not case["partitionKeyBound"]:
        return "partition-query"
    if case["maximumPartitionMiB"] > case["partitionLimitMiB"]:
        return "hot-partition"
    if not case["replicaPlacementSafe"]:
        return "replica-placement"
    if not case["consistencyClaimBounded"]:
        return "consistency-contract"
    if case["clockSkewMillis"] > case["clockSkewBudgetMillis"]:
        return "clock-skew"
    if case["repairIntervalHours"] >= case["tombstoneGraceHours"]:
        return "repair-horizon"
    if not case["tombstonePurgeRepaired"]:
        return "tombstone-purge"
    if not case["maintenanceHeadroom"]:
        return "maintenance-headroom"
    if not case["restoreTested"]:
        return "cassandra-restore"
    if not case["securePlanes"]:
        return "security-plane"
    if not case["embeddingVersionPinned"]:
        return "embedding-version"
    if not case["vectorShapeCompatible"]:
        return "vector-contract"
    if not case["stablePointIdentity"]:
        return "point-identity"
    if not case["recallMeasuredAgainstExact"]:
        return "recall-baseline"
    if not case["payloadFilterIndexed"]:
        return "filter-index"
    if case["indexMemoryGiB"] > case["indexMemoryBudgetGiB"]:
        return "index-memory"
    if not case["shardReplicaPlacementSafe"]:
        return "vector-placement"
    if not case["vectorSnapshotRestoreTested"]:
        return "vector-restore"
    if not case["sourceRemainsAuthority"]:
        return "catalog-authority"
    if case["ingestionFreshnessSeconds"] > case["ingestionSloSeconds"]:
        return "catalog-freshness"
    if not case["lineageVerified"]:
        return "lineage-evidence"
    if not case["leastPrivilegeMetadata"]:
        return "metadata-authorization"
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
