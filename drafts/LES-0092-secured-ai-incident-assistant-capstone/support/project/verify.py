#!/usr/bin/env python3
"""Run the complete CAP-005 harness from absent state back to absence."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

import assistantctl


EXPECTED_RESULTS = {
    "prompt-injection": "blocked",
    "sensitive-value": "blocked",
    "cross-tenant": "blocked",
    "unsupported-claim": "blocked",
    "citation-mismatch": "blocked",
    "corpus-drift": "blocked",
    "unknown-tool": "blocked",
    "unauthorized-scope": "blocked",
    "approval-invalid": "blocked",
    "ambiguous-outcome": "ambiguous",
    "answer-leakage": "blocked",
    "clock-skew": "fallback",
    "release-drift": "blocked",
    "audit-tamper": "blocked",
    "budget-exceeded": "fallback",
    "kill-switch": "fallback",
}


def run_tests() -> int:
    suite = unittest.defaultTestLoader.discover(
        str(Path(__file__).resolve().parent / "tests")
    )
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if not result.wasSuccessful():
        raise assistantctl.GuardError("unit test suite failed")
    return result.testsRun


def main() -> int:
    assistantctl.ensure_normal_user()
    if assistantctl.RUNTIME.exists() or assistantctl.RUNTIME.is_symlink():
        raise assistantctl.GuardError(
            "verification requires an absent .runtime; use guarded cleanup first"
        )
    initialized = False
    try:
        tests = run_tests()
        check_result = assistantctl.check()
        if (
            check_result["authority"] != "local-fixture-only"
            or check_result["network"] != "none"
            or check_result["model"] != "none"
        ):
            raise assistantctl.GuardError("authority boundary changed")
        assistantctl.initialize()
        initialized = True
        baseline = assistantctl.run_baseline()
        if len(baseline["verifiedClaims"]) != 4 or len(baseline["abstentions"]) != 2:
            raise assistantctl.GuardError("baseline evidence contract changed")
        actual: dict[str, str] = {}
        for name in assistantctl.SCENARIOS:
            receipt = assistantctl.run_scenario(name)
            actual[name] = receipt["result"]
        if actual != EXPECTED_RESULTS:
            raise assistantctl.GuardError("scenario result matrix changed")
        dossier = assistantctl.build_dossier()
        if dossier["counts"] != {"blocked": 12, "fallback": 3, "ambiguous": 1}:
            raise assistantctl.GuardError("dossier outcome counts changed")
        dossier_text = assistantctl.DOSSIER.read_text(encoding="utf-8")
        for required in (
            "## System boundary",
            "## State and authority",
            "## Evidence and retrieval",
            "## Failure and evaluation decisions",
            "## Approval, reconciliation and audit",
            "## Kill and fallback",
            "## Privacy, capacity and cost",
            "## Proof limits",
        ):
            if required not in dossier_text:
                raise assistantctl.GuardError(f"dossier section missing: {required}")
        if len(assistantctl.verify_audit()) != 19:
            raise assistantctl.GuardError("audit record count changed")
        cleanup_result = assistantctl.cleanup()
        initialized = False
        if assistantctl.RUNTIME.exists() or assistantctl.RUNTIME.is_symlink():
            raise assistantctl.GuardError("runtime remained after cleanup")
        print(assistantctl.canonical_json({
            "verify": "pass",
            "tests": tests,
            "scenarios": len(actual),
            "scenarioResults": actual,
            "counts": dossier["counts"],
            "claims": len(baseline["verifiedClaims"]),
            "audit": "verified",
            "dossier": "pass",
            "cleanup": cleanup_result["runtime"],
            "authority": "local-fixture-only",
            "model": "none",
            "network": "none",
            "externalEffects": "none",
            "proofLimit": "deterministic fixture; no real model or production integration",
        }))
        return 0
    except Exception:
        if initialized:
            try:
                assistantctl.cleanup()
            except Exception as cleanup_error:
                print(json.dumps(
                    {"cleanupAfterFailure": "refused", "error": str(cleanup_error)},
                    sort_keys=True,
                ), file=sys.stderr)
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except assistantctl.GuardError as exc:
        print(assistantctl.canonical_json(
            {"verify": "refused", "error": str(exc)}
        ), file=sys.stderr)
        raise SystemExit(2)
