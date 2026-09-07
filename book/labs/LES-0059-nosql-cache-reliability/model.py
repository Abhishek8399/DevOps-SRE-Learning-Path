#!/usr/bin/env python3
"""Deterministic LES-0059 NoSQL and cache architecture boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "sourceOfTruthExplicit", "accessPatternBound",
    "partitionKeyCardinality", "hottestKeyRps", "perKeyCapacity",
    "valueBytes", "maximumValueBytes", "invariantKeys", "atomicKeyLimit",
    "requiredRevision", "servedRevision", "cacheCorrectnessCritical",
    "ttlSeconds", "duplicateWindowSeconds", "versionedInvalidation",
    "requestCoalescing", "ttlJitter", "negativeCachingBounded",
    "securityDecisionCached", "failOpenAllowed", "writeBehind",
    "writeBehindDurable", "repairEnabled", "expected",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0059":
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
        seen.add(case["id"])
        for field in (
            "partitionKeyCardinality", "hottestKeyRps", "perKeyCapacity",
            "valueBytes", "maximumValueBytes", "invariantKeys",
            "atomicKeyLimit", "requiredRevision", "servedRevision",
            "ttlSeconds", "duplicateWindowSeconds",
        ):
            if not isinstance(case[field], int) or case[field] < 0:
                raise ValueError(f"integer field: {case['id']}:{field}")
    return data


def evaluate(case: dict) -> str:
    if not case["sourceOfTruthExplicit"]:
        return "authority"
    if not case["accessPatternBound"] or case["partitionKeyCardinality"] < 1:
        return "access-pattern"
    if case["invariantKeys"] > case["atomicKeyLimit"]:
        return "atomic-scope"
    if case["hottestKeyRps"] > case["perKeyCapacity"]:
        return "hot-key"
    if case["valueBytes"] > case["maximumValueBytes"]:
        return "value-size"
    if case["requiredRevision"] > case["servedRevision"]:
        return "consistency-contract"
    if (
        case["cacheCorrectnessCritical"]
        and case["ttlSeconds"] < case["duplicateWindowSeconds"]
    ):
        return "ttl-correctness"
    if not case["versionedInvalidation"]:
        return "invalidation"
    if not case["requestCoalescing"] and not case["ttlJitter"]:
        return "stampede"
    if not case["negativeCachingBounded"]:
        return "negative-cache"
    if case["securityDecisionCached"] and case["failOpenAllowed"]:
        return "security-fail-open"
    if case["writeBehind"] and not case["writeBehindDurable"]:
        return "write-behind-loss"
    if not case["repairEnabled"]:
        return "repair"
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
