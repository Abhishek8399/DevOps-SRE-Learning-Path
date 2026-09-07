#!/usr/bin/env python3
"""Deterministic LES-0057 compatibility and delivery-boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "contractVersioned", "removedFields", "newRequiredFields",
    "changedTypes", "narrowedEnums", "meaningChanged", "consumerRejectsUnknown",
    "addedFields", "stableEventId", "duplicateSafe", "orderingRequired",
    "partitionKeyStable", "sequencePresent", "freshnessRequired",
    "freshnessChecked", "retryOwners", "attemptBudget", "deadlineBudgeted",
    "stateLookupAvailable", "expected",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0057":
        raise ValueError("fixture identity")
    cases = data.get("cases")
    if not isinstance(cases, list) or not cases:
        raise ValueError("cases")
    seen = set()
    for case in cases:
        if set(case) != REQUIRED:
            raise ValueError(f"case fields: {case.get('id', 'unknown')}")
        if case["id"] in seen:
            raise ValueError("duplicate case")
        seen.add(case["id"])
    return data


def evaluate(case: dict) -> str:
    if not case["contractVersioned"]:
        return "contract-identity"
    if case["removedFields"]:
        return "compatibility-remove"
    if case["newRequiredFields"]:
        return "compatibility-required"
    if case["changedTypes"]:
        return "compatibility-type"
    if case["narrowedEnums"]:
        return "compatibility-enum"
    if case["meaningChanged"]:
        return "compatibility-meaning"
    if case["consumerRejectsUnknown"] and case["addedFields"]:
        return "forward-compatibility"
    if not case["stableEventId"] or not case["duplicateSafe"]:
        return "duplicate-safety"
    if case["orderingRequired"] and (
        not case["partitionKeyStable"] or not case["sequencePresent"]
    ):
        return "ordering"
    if case["freshnessRequired"] and not case["freshnessChecked"]:
        return "replay"
    if (
        case["retryOwners"] != 1
        or case["attemptBudget"] < 1
        or not case["deadlineBudgeted"]
    ):
        return "retry-amplification"
    if not case["stateLookupAvailable"]:
        return "state-ownership"
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
