#!/usr/bin/env python3
"""Deterministic LES-0061 distributed-workflow architecture boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "crossServiceRequired", "workflowAuthorityDurable", "stableStepId",
    "stateOutboxAtomic", "relayFenced", "effectIdempotent",
    "checkpointAfterEffect", "compensationIdempotent",
    "validationsBeforePivot", "boundedRetries", "deadlineSeconds",
    "workflowHistoryVersioned", "deterministicReplay",
    "concurrencyVersionChecked", "outboxRetentionSeconds",
    "recoveryHorizonSeconds", "manualOwner", "authorizationAtEffect",
    "reconciliation", "expected",
}

BOOLEAN_FIELDS = {
    "crossServiceRequired", "workflowAuthorityDurable", "stableStepId",
    "stateOutboxAtomic", "relayFenced", "effectIdempotent",
    "checkpointAfterEffect", "compensationIdempotent",
    "validationsBeforePivot", "boundedRetries", "workflowHistoryVersioned",
    "deterministicReplay", "concurrencyVersionChecked", "manualOwner",
    "authorizationAtEffect", "reconciliation",
}

INTEGER_FIELDS = {
    "deadlineSeconds", "outboxRetentionSeconds", "recoveryHorizonSeconds",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0061":
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
    if not case["crossServiceRequired"]:
        return "transaction-boundary"
    if not case["workflowAuthorityDurable"]:
        return "workflow-authority"
    if not case["stableStepId"]:
        return "step-identity"
    if not case["stateOutboxAtomic"]:
        return "state-publish-gap"
    if not case["relayFenced"]:
        return "stale-relay"
    if not case["effectIdempotent"]:
        return "duplicate-effect"
    if not case["checkpointAfterEffect"]:
        return "effect-loss"
    if not case["compensationIdempotent"]:
        return "duplicate-compensation"
    if not case["validationsBeforePivot"]:
        return "irreversible-order"
    if not case["boundedRetries"]:
        return "retry-storm"
    if case["deadlineSeconds"] == 0:
        return "missing-deadline"
    if not case["workflowHistoryVersioned"]:
        return "history-version"
    if not case["deterministicReplay"]:
        return "nondeterministic-replay"
    if not case["concurrencyVersionChecked"]:
        return "concurrent-workflow"
    if case["outboxRetentionSeconds"] < case["recoveryHorizonSeconds"]:
        return "recovery-horizon"
    if not case["manualOwner"]:
        return "manual-orphan"
    if not case["authorizationAtEffect"]:
        return "stale-authorization"
    if not case["reconciliation"]:
        return "silent-drift"
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
