#!/usr/bin/env python3
"""Deterministic LES-0063 lakehouse/table architecture boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "catalogAuthoritative", "atomicPointerCommit", "snapshotReachable",
    "manifestClosure", "stableFileIdentity", "fieldIdsPreserved",
    "formatCompatible", "partitionEvolutionCompatible", "conflictValidation",
    "snapshotRetentionSeconds", "rollbackHorizonSeconds",
    "orphanRetentionSeconds", "maxWriterSeconds", "rollbackAnchor",
    "averageFileMiB", "minimumFileMiB", "deleteRatioPermille",
    "maximumDeleteRatioPermille", "statisticsFresh", "plannedScanGiB",
    "scanBudgetGiB", "workloadIsolated", "leastPrivilege", "completeAudit",
    "expected",
}

BOOLEAN_FIELDS = {
    "catalogAuthoritative", "atomicPointerCommit", "snapshotReachable",
    "manifestClosure", "stableFileIdentity", "fieldIdsPreserved",
    "formatCompatible", "partitionEvolutionCompatible", "conflictValidation",
    "rollbackAnchor", "statisticsFresh", "workloadIsolated",
    "leastPrivilege", "completeAudit",
}

INTEGER_FIELDS = {
    "snapshotRetentionSeconds", "rollbackHorizonSeconds",
    "orphanRetentionSeconds", "maxWriterSeconds", "averageFileMiB",
    "minimumFileMiB", "deleteRatioPermille", "maximumDeleteRatioPermille",
    "plannedScanGiB", "scanBudgetGiB",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0063":
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
    if not case["catalogAuthoritative"]:
        return "catalog-authority"
    if not case["atomicPointerCommit"]:
        return "commit-atomicity"
    if not case["snapshotReachable"]:
        return "snapshot-reference"
    if not case["manifestClosure"]:
        return "manifest-closure"
    if not case["stableFileIdentity"]:
        return "file-identity"
    if not case["fieldIdsPreserved"]:
        return "schema-field-id"
    if not case["formatCompatible"]:
        return "format-compatibility"
    if not case["partitionEvolutionCompatible"]:
        return "partition-evolution"
    if not case["conflictValidation"]:
        return "write-conflict"
    if case["snapshotRetentionSeconds"] < case["rollbackHorizonSeconds"]:
        return "snapshot-retention"
    if case["orphanRetentionSeconds"] <= case["maxWriterSeconds"]:
        return "orphan-retention"
    if not case["rollbackAnchor"]:
        return "rollback-anchor"
    if case["averageFileMiB"] < case["minimumFileMiB"]:
        return "small-files"
    if case["deleteRatioPermille"] > case["maximumDeleteRatioPermille"]:
        return "delete-amplification"
    if not case["statisticsFresh"]:
        return "statistics"
    if case["plannedScanGiB"] > case["scanBudgetGiB"]:
        return "scan-budget"
    if not case["workloadIsolated"]:
        return "workload-isolation"
    if not case["leastPrivilege"]:
        return "authorization"
    if not case["completeAudit"]:
        return "audit-lineage"
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
