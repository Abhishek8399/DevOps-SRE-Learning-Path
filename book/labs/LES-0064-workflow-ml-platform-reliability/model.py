#!/usr/bin/env python3
"""Deterministic LES-0064 workflow and ML-platform boundary model."""
from __future__ import annotations

import json
import pathlib
import sys

REQUIRED = {
    "id", "stableRunIdentity", "boundedDataInterval", "idempotentTask",
    "boundedRetries", "taskTimeoutSeconds", "operationDeadlineSeconds",
    "dagStatusRepresentsRequiredTasks", "backfillIsolated", "poolEnforced",
    "componentHealthIndependent", "deterministicDagParse",
    "versionedTrainingData", "completeExperimentLineage",
    "representativeEvaluation", "promotionThresholds",
    "immutableModelArtifact", "controlledAliasPromotion", "featureParity",
    "driftOwner", "reversibleServing", "isolatedNotebook",
    "privacyRetentionDays", "privacyRetentionLimitDays", "expected",
}

BOOLEAN_FIELDS = {
    "stableRunIdentity", "boundedDataInterval", "idempotentTask",
    "boundedRetries", "dagStatusRepresentsRequiredTasks", "backfillIsolated",
    "poolEnforced", "componentHealthIndependent", "deterministicDagParse",
    "versionedTrainingData", "completeExperimentLineage",
    "representativeEvaluation", "promotionThresholds",
    "immutableModelArtifact", "controlledAliasPromotion", "featureParity",
    "driftOwner", "reversibleServing", "isolatedNotebook",
}

INTEGER_FIELDS = {
    "taskTimeoutSeconds", "operationDeadlineSeconds",
    "privacyRetentionDays", "privacyRetentionLimitDays",
}


def load(path: str) -> dict:
    data = json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0064":
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
    if not case["stableRunIdentity"]:
        return "run-identity"
    if not case["boundedDataInterval"]:
        return "data-interval"
    if not case["idempotentTask"]:
        return "task-idempotency"
    if not case["boundedRetries"]:
        return "retry-budget"
    if (
        case["taskTimeoutSeconds"] == 0
        or case["operationDeadlineSeconds"] == 0
        or case["taskTimeoutSeconds"] > case["operationDeadlineSeconds"]
    ):
        return "deadline"
    if not case["dagStatusRepresentsRequiredTasks"]:
        return "false-green"
    if not case["backfillIsolated"]:
        return "backfill-isolation"
    if not case["poolEnforced"]:
        return "resource-pool"
    if not case["componentHealthIndependent"]:
        return "component-health"
    if not case["deterministicDagParse"]:
        return "dag-parse"
    if not case["versionedTrainingData"]:
        return "training-data-version"
    if not case["completeExperimentLineage"]:
        return "experiment-lineage"
    if not case["representativeEvaluation"]:
        return "evaluation-population"
    if not case["promotionThresholds"]:
        return "promotion-gate"
    if not case["immutableModelArtifact"]:
        return "model-artifact"
    if not case["controlledAliasPromotion"]:
        return "alias-promotion"
    if not case["featureParity"]:
        return "training-serving-skew"
    if not case["driftOwner"]:
        return "drift-response"
    if not case["reversibleServing"]:
        return "serving-rollback"
    if not case["isolatedNotebook"]:
        return "notebook-isolation"
    if case["privacyRetentionDays"] > case["privacyRetentionLimitDays"]:
        return "privacy-retention"
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
