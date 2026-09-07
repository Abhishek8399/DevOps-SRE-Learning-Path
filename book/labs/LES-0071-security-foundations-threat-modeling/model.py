#!/usr/bin/env python3
"""Deterministic LES-0071 security-decision model; it attacks nothing."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


ORDERED_GATES = (
    ("scope_defined", "scope"),
    ("assets_owned", "asset-ownership"),
    ("data_classified", "data-classification"),
    ("architecture_current", "architecture"),
    ("trust_boundaries_mapped", "trust-boundaries"),
    ("actors_capabilities", "actors"),
    ("entry_points_mapped", "entry-points"),
    ("threats_identified", "threat-identification"),
    ("likelihood_impact_assessed", "risk-analysis"),
    ("risk_owner_assigned", "risk-ownership"),
    ("requirements_defined", "security-requirements"),
    ("identity_proofing_appropriate", "identity-proofing"),
    ("authentication_strength", "authentication"),
    ("workload_identity_bound", "workload-identity"),
    ("authorization_complete", "authorization"),
    ("least_privilege", "least-privilege"),
    ("separation_of_duties", "separation-of-duties"),
    ("secret_lifecycle", "secret-lifecycle"),
    ("encryption_in_transit", "transport-encryption"),
    ("encryption_at_rest", "stored-data-encryption"),
    ("key_lifecycle", "key-management"),
    ("segmentation_enforced", "segmentation"),
    ("egress_bounded", "egress"),
    ("secure_defaults", "secure-defaults"),
    ("asset_patch_inventory", "vulnerability-management"),
    ("logging_complete", "logging-coverage"),
    ("log_integrity", "log-integrity"),
    ("detection_use_case", "detection"),
    ("alert_routed", "alert-routing"),
    ("response_roles", "response-readiness"),
    ("containment_independent", "containment"),
    ("evidence_preserved", "evidence-preservation"),
    ("recovery_proven", "recovery-proof"),
    ("residual_risk_owned", "residual-risk"),
    ("review_triggered", "continuous-review"),
)
REQUIRED_DEFAULTS = {key for key, _ in ORDERED_GATES}


def load(path: str) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0071":
        raise ValueError("fixture identity")
    defaults = data.get("defaults")
    cases = data.get("cases")
    if not isinstance(defaults, dict) or set(defaults) != REQUIRED_DEFAULTS:
        raise ValueError("fixture defaults")
    if not all(isinstance(defaults[key], bool) for key in REQUIRED_DEFAULTS):
        raise ValueError("fixture default types")
    if not isinstance(cases, list) or not cases:
        raise ValueError("fixture cases")
    identifiers: set[str] = set()
    for case in cases:
        if not isinstance(case, dict) or set(case) != {"id", "expect", "override"}:
            raise ValueError("case shape")
        if not isinstance(case["id"], str) or not case["id"] or case["id"] in identifiers:
            raise ValueError("case identity")
        if not isinstance(case["expect"], str) or not case["expect"]:
            raise ValueError("case expectation")
        if not isinstance(case["override"], dict) or not set(case["override"]).issubset(REQUIRED_DEFAULTS):
            raise ValueError("case override")
        if not all(isinstance(value, bool) for value in case["override"].values()):
            raise ValueError("case override types")
        identifiers.add(case["id"])
    if "baseline" not in identifiers:
        raise ValueError("baseline missing")
    return data


def resolve(data: dict[str, Any], case_id: str) -> tuple[dict[str, bool], str]:
    for case in data["cases"]:
        if case["id"] == case_id:
            state = dict(data["defaults"])
            state.update(case["override"])
            return state, case["expect"]
    raise ValueError(f"unknown case: {case_id}")


def boundary(state: dict[str, bool]) -> str:
    for key, result in ORDERED_GATES:
        if not state[key]:
            return result
    return "defensible"


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
