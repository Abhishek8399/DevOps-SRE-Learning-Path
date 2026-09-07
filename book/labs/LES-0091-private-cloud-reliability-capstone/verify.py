#!/usr/bin/env python3
"""Run the complete CAP-004 simulator from absent state back to absence."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

import cloudctl


EXPECTED_RESULTS = {
    "compute-host-loss": "degraded",
    "rack-loss": "degraded",
    "placement-generation-conflict": "blocked",
    "gateway-failure": "degraded",
    "mtu-mismatch": "unavailable",
    "ceph-osd-down": "degraded",
    "ceph-near-full": "blocked",
    "migration-incompatible": "blocked",
    "upgrade-boundary": "blocked",
    "restore-divergence": "blocked",
    "bmc-ambiguous": "blocked",
    "policy-violation": "blocked",
}


def run_tests() -> None:
    suite = unittest.defaultTestLoader.discover(
        str(Path(__file__).resolve().parent / "tests")
    )
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if not result.wasSuccessful():
        raise cloudctl.GuardError("unit test suite failed")


def main() -> int:
    cloudctl.ensure_normal_user()
    if cloudctl.RUNTIME.exists() or cloudctl.RUNTIME.is_symlink():
        raise cloudctl.GuardError(
            "verification requires an absent .runtime; use guarded cleanup first"
        )
    completed: list[str] = []
    initialized = False
    try:
        run_tests()
        check_result = cloudctl.check()
        if check_result["authority"] != "local-simulation-only":
            raise cloudctl.GuardError("authority boundary changed")
        cloudctl.initialize()
        initialized = True
        baseline = cloudctl.run_baseline()
        if baseline["userOperations"] != {
            "run-build": "pass",
            "submit-checkout": "pass",
        }:
            raise cloudctl.GuardError("baseline user-operation evidence changed")
        for name in cloudctl.SCENARIOS:
            receipt = cloudctl.run_scenario(name)
            if receipt["result"] != EXPECTED_RESULTS[name]:
                raise cloudctl.GuardError(
                    f"{name} result changed: {receipt['result']}"
                )
            completed.append(name)
        dossier = cloudctl.build_dossier()
        if dossier["scenarios"] != len(cloudctl.SCENARIOS):
            raise cloudctl.GuardError("dossier omitted scenario evidence")
        dossier_text = cloudctl.DOSSIER_PATH.read_text(encoding="utf-8")
        for required in (
            "## System boundary",
            "## Failure domains",
            "## Workload contracts",
            "## Baseline capacity and operation",
            "## Failure decisions",
            "## State recovery order",
            "## Proof limits",
        ):
            if required not in dossier_text:
                raise cloudctl.GuardError(f"dossier section missing: {required}")
        cleanup_result = cloudctl.cleanup()
        initialized = False
        if cloudctl.RUNTIME.exists() or cloudctl.RUNTIME.is_symlink():
            raise cloudctl.GuardError("runtime remained after cleanup")
        print(cloudctl.canonical_json({
            "verify": "pass",
            "tests": 17,
            "scenarios": len(completed),
            "scenarioResults": EXPECTED_RESULTS,
            "dossier": "pass",
            "cleanup": cleanup_result["runtime"],
            "authority": "local-simulation-only",
            "proofLimit": "no infrastructure API or runtime was invoked",
        }))
        return 0
    except Exception:
        if initialized:
            try:
                cloudctl.cleanup()
            except Exception as cleanup_error:
                print(json.dumps(
                    {"cleanupAfterFailure": "refused", "error": str(cleanup_error)},
                    sort_keys=True,
                ), file=sys.stderr)
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except cloudctl.GuardError as exc:
        print(cloudctl.canonical_json(
            {"verify": "refused", "error": str(exc)}
        ), file=sys.stderr)
        raise SystemExit(2)
