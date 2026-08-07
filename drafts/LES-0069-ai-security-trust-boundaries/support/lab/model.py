#!/usr/bin/env python3
"""Deterministic LES-0069 teaching model; it performs no AI inference or external action."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


REQUIRED_DEFAULTS = {
    "operation_defined",
    "threat_model_complete",
    "content_origin_labeled",
    "retrieved_content_authoritative",
    "output_schema_strict",
    "output_sink_validated",
    "tool_minimal",
    "tool_typed",
    "tool_authorized",
    "downstream_authorized",
    "identity_user_bound",
    "secret_scope_bounded",
    "sandbox_bounded",
    "egress_allowlisted",
    "approval_required",
    "approval_preview_bound",
    "approval_fresh",
    "data_provenance",
    "data_integrity",
    "model_provenance",
    "signer_policy_bound",
    "artifact_format_safe",
    "dependency_provenance",
    "audit_complete",
    "audit_content_safe",
    "red_team_invariants",
    "kill_path_independent",
    "kill_queue_accounted",
    "recovery_proven",
    "residual_risk_owned",
}


def load(path: str) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0069":
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
    if not s["threat_model_complete"]:
        return "threat-model"
    if not s["content_origin_labeled"]:
        return "content-origin"
    if s["retrieved_content_authoritative"]:
        return "content-authority"
    if not s["output_schema_strict"]:
        return "output-schema"
    if not s["output_sink_validated"]:
        return "output-validation"
    if not s["tool_minimal"]:
        return "tool-functionality"
    if not s["tool_typed"]:
        return "tool-schema"
    if not s["tool_authorized"]:
        return "tool-authorization"
    if not s["downstream_authorized"]:
        return "downstream-authorization"
    if not s["identity_user_bound"]:
        return "identity-propagation"
    if not s["secret_scope_bounded"]:
        return "secret-scope"
    if not s["sandbox_bounded"]:
        return "sandbox-isolation"
    if not s["egress_allowlisted"]:
        return "egress-control"
    if not s["approval_required"]:
        return "approval-required"
    if not s["approval_preview_bound"]:
        return "approval-binding"
    if not s["approval_fresh"]:
        return "approval-freshness"
    if not s["data_provenance"]:
        return "data-provenance"
    if not s["data_integrity"]:
        return "data-integrity"
    if not s["model_provenance"]:
        return "model-provenance"
    if not s["signer_policy_bound"]:
        return "signer-policy"
    if not s["artifact_format_safe"]:
        return "artifact-format"
    if not s["dependency_provenance"]:
        return "dependency-provenance"
    if not s["audit_complete"]:
        return "audit-completeness"
    if not s["audit_content_safe"]:
        return "audit-privacy"
    if not s["red_team_invariants"]:
        return "adversarial-evaluation"
    if not s["kill_path_independent"]:
        return "kill-path"
    if not s["kill_queue_accounted"]:
        return "kill-accounting"
    if not s["recovery_proven"]:
        return "recovery-proof"
    if not s["residual_risk_owned"]:
        return "risk-ownership"
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
