#!/usr/bin/env python3
"""Deterministic LES-0068 teaching model; it performs no inference or external action."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


REQUIRED_DEFAULTS = {
    "operation_defined",
    "release_manifest_complete",
    "data_immutable",
    "data_digest_match",
    "model_immutable",
    "prompt_versioned",
    "tokenizer_compatible",
    "evaluation_dataset_versioned",
    "scorer_versioned",
    "evaluation_slices",
    "chronological_split",
    "serving_mode_fits",
    "gateway_auth",
    "tenant_budget",
    "single_deadline",
    "device_healthy",
    "gpu_memory_gib",
    "gpu_memory_budget_gib",
    "gpu_profile_match",
    "queue_age_ms",
    "service_p99_ms",
    "deadline_ms",
    "batch_wait_bounded",
    "cache_tenant_bound",
    "canary_release_labeled",
    "canary_sample",
    "minimum_canary_sample",
    "rollback_minutes",
    "rollback_objective_minutes",
    "drift_classified",
    "automatic_retraining",
    "labels_mature",
    "content_capture_safe",
    "unit_cost_measured",
    "telemetry_cardinality_bounded",
}


def load(path: str) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0068":
        raise ValueError("fixture identity")
    defaults = data.get("defaults")
    cases = data.get("cases")
    if not isinstance(defaults, dict) or set(defaults) != REQUIRED_DEFAULTS:
        raise ValueError("fixture defaults")
    if not isinstance(cases, list) or not cases:
        raise ValueError("fixture cases")
    ids: set[str] = set()
    for case in cases:
        if not isinstance(case, dict) or set(case) != {"id", "expect", "override"}:
            raise ValueError("case shape")
        if not isinstance(case["id"], str) or not case["id"] or case["id"] in ids:
            raise ValueError("case identity")
        if not isinstance(case["expect"], str) or not case["expect"]:
            raise ValueError("case expectation")
        if not isinstance(case["override"], dict) or not set(case["override"]).issubset(REQUIRED_DEFAULTS):
            raise ValueError("case override")
        ids.add(case["id"])
    if "baseline" not in ids:
        raise ValueError("baseline missing")
    return data


def resolve(data: dict[str, Any], case_id: str) -> tuple[dict[str, Any], str]:
    for case in data["cases"]:
        if case["id"] == case_id:
            state = dict(data["defaults"])
            state.update(case["override"])
            return state, case["expect"]
    raise ValueError(f"unknown case: {case_id}")


def boundary(s: dict[str, Any]) -> str:
    if not s["operation_defined"]:
        return "operation-contract"
    if not s["release_manifest_complete"]:
        return "release-identity"
    if not s["data_immutable"]:
        return "data-identity"
    if not s["data_digest_match"]:
        return "data-integrity"
    if not s["model_immutable"]:
        return "model-identity"
    if not s["prompt_versioned"]:
        return "prompt-identity"
    if not s["tokenizer_compatible"]:
        return "tokenizer-compatibility"
    if not s["evaluation_dataset_versioned"]:
        return "evaluation-identity"
    if not s["scorer_versioned"]:
        return "scorer-identity"
    if not s["evaluation_slices"]:
        return "evaluation-slices"
    if not s["chronological_split"]:
        return "evaluation-time"
    if not s["serving_mode_fits"]:
        return "serving-mode"
    if not s["gateway_auth"]:
        return "gateway-auth"
    if not s["tenant_budget"]:
        return "gateway-budget"
    if not s["single_deadline"]:
        return "request-deadline"
    if not s["device_healthy"]:
        return "device-health"
    if s["gpu_memory_gib"] > s["gpu_memory_budget_gib"]:
        return "gpu-memory"
    if not s["gpu_profile_match"]:
        return "gpu-profile"
    if s["queue_age_ms"] + s["service_p99_ms"] > s["deadline_ms"]:
        return "queue-deadline"
    if not s["batch_wait_bounded"]:
        return "batch-admission"
    if not s["cache_tenant_bound"]:
        return "cache-isolation"
    if not s["canary_release_labeled"]:
        return "canary-attribution"
    if s["canary_sample"] < s["minimum_canary_sample"]:
        return "canary-evidence"
    if s["rollback_minutes"] > s["rollback_objective_minutes"]:
        return "rollback-readiness"
    if not s["drift_classified"] or s["automatic_retraining"]:
        return "drift-response"
    if not s["labels_mature"]:
        return "label-maturity"
    if not s["content_capture_safe"]:
        return "telemetry-privacy"
    if not s["unit_cost_measured"]:
        return "unit-economics"
    if not s["telemetry_cardinality_bounded"]:
        return "telemetry-capacity"
    return "operable"


def validate(data: dict[str, Any]) -> None:
    for case in data["cases"]:
        state, expected = resolve(data, case["id"])
        actual = boundary(state)
        if actual != expected:
            raise ValueError(f"{case['id']}: expected {expected}, got {actual}")


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        raise ValueError("usage")
    action, path = argv[1], argv[2]
    data = load(path)
    validate(data)
    if action == "validate" and len(argv) == 3:
        print(f"model=valid cases={len(data['cases'])}")
    elif action == "list" and len(argv) == 3:
        for case in data["cases"]:
            print(case["id"])
    elif action in {"show", "evaluate"} and len(argv) == 4:
        state, expected = resolve(data, argv[3])
        if action == "show":
            print(json.dumps({"id": argv[3], "expected": expected, "state": state}, sort_keys=True))
        else:
            print(f"case={argv[3]} boundary={boundary(state)}")
    else:
        raise ValueError("usage")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"model=fail reason={exc}", file=sys.stderr)
        raise SystemExit(1)
