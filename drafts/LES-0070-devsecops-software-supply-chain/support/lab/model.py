#!/usr/bin/env python3
"""Deterministic LES-0070 evidence-gate model; it scans or signs nothing."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


ORDERED_GATES = (
    ("change_reviewed", "change-review"),
    ("source_revision_bound", "source-identity"),
    ("workflow_dependencies_pinned", "workflow-integrity"),
    ("runner_isolated", "runner-isolation"),
    ("secret_scope_bounded", "secret-scope"),
    ("network_egress_bounded", "network-egress"),
    ("dependency_graph_locked", "dependency-lock"),
    ("dependency_source_allowed", "dependency-source"),
    ("dependency_integrity_verified", "dependency-integrity"),
    ("license_policy_evaluated", "license-policy"),
    ("secret_scan_complete", "secret-scan"),
    ("source_scan_complete", "source-scan"),
    ("iac_scan_complete", "iac-scan"),
    ("image_scan_complete", "image-scan"),
    ("scanner_identity_bound", "scanner-identity"),
    ("vulnerability_data_time_bound", "vulnerability-data"),
    ("finding_policy_enforced", "finding-policy"),
    ("exception_bound", "exception-governance"),
    ("build_isolated", "build-isolation"),
    ("build_reproducible", "build-reproducibility"),
    ("artifact_digest_bound", "artifact-identity"),
    ("sbom_generated", "sbom-presence"),
    ("sbom_artifact_bound", "sbom-binding"),
    ("provenance_generated", "provenance-presence"),
    ("provenance_artifact_bound", "provenance-binding"),
    ("signature_verified", "signature-verification"),
    ("signer_policy_bound", "signer-policy"),
    ("admission_verifies", "admission-policy"),
    ("runtime_digest_pinned", "runtime-identity"),
    ("deployment_inventory_current", "runtime-inventory"),
    ("revocation_path_ready", "revocation-readiness"),
    ("recovery_proven", "recovery-proof"),
    ("residual_risk_owned", "risk-ownership"),
)
REQUIRED_DEFAULTS = {key for key, _ in ORDERED_GATES}


def load(path: str) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if data.get("schemaVersion") != 1 or data.get("lessonId") != "LES-0070":
        raise ValueError("fixture identity")
    defaults = data.get("defaults")
    cases = data.get("cases")
    if not isinstance(defaults, dict) or set(defaults) != REQUIRED_DEFAULTS:
        raise ValueError("fixture defaults")
    if not all(isinstance(defaults[key], bool) for key in REQUIRED_DEFAULTS):
        raise ValueError("fixture default types")
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
        if not all(isinstance(value, bool) for value in case["override"].values()):
            raise ValueError("case override types")
        ids.add(case["id"])
    if "baseline" not in ids:
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
    return "admissible"


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
