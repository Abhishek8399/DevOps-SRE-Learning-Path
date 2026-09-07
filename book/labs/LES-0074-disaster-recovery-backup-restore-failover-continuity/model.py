#!/usr/bin/env python3
"""Deterministic DR evidence-gate model. It performs no backup or recovery."""

from __future__ import annotations

import json
import sys
from pathlib import Path

GATES = (
    ("flow-defined", lambda x: x["flow_defined"] is True),
    ("business-impact-approval", lambda x: x["business_impact_approved"] is True),
    ("rto-defined", lambda x: isinstance(x["rto_minutes"], int) and x["rto_minutes"] > 0),
    ("rpo-defined", lambda x: isinstance(x["rpo_minutes"], int) and x["rpo_minutes"] >= 0),
    ("strategy-rto", lambda x: x["strategy_rto_minutes"] <= x["rto_minutes"]),
    ("strategy-rpo", lambda x: x["strategy_rpo_minutes"] <= x["rpo_minutes"]),
    ("state-inventory", lambda x: x["state_inventory_complete"] is True),
    ("dependency-map", lambda x: x["dependency_map_complete"] is True),
    ("replication-is-not-backup", lambda x: x["replication_is_backup"] is False),
    ("backup-job", lambda x: x["backup_job_succeeded"] is True),
    ("backup-freshness", lambda x: x["backup_age_minutes"] <= x["rpo_minutes"]),
    ("backup-identity", lambda x: x["backup_identity_bound"] is True),
    ("failure-domain-independence", lambda x: x["backup_independent_failure_domain"] is True),
    ("cyber-recovery-copy", lambda x: x["backup_offline_or_immutable"] is True),
    ("backup-encryption", lambda x: x["backup_encrypted"] is True),
    ("recovery-key", lambda x: x["recovery_key_available"] is True),
    ("retention-window", lambda x: x["retention_covers_target"] is True),
    ("backup-chain", lambda x: x["backup_chain_complete"] is True),
    ("backup-checksum", lambda x: x["checksum_verified"] is True),
    ("restore-tested", lambda x: x["restore_tested"] is True),
    ("restore-isolation", lambda x: x["restore_target_isolated"] is True),
    ("restore-version", lambda x: x["restore_version_compatible"] is True),
    ("restore-authorization", lambda x: x["restore_authorized"] is True),
    ("restored-integrity", lambda x: x["restored_integrity_valid"] is True),
    ("application-correctness", lambda x: x["application_correctness_valid"] is True),
    ("security-validation", lambda x: x["security_validation_passed"] is True),
    ("measured-rpo", lambda x: x["measured_data_loss_minutes"] <= x["rpo_minutes"]),
    ("measured-rto", lambda x: x["measured_recovery_minutes"] <= x["rto_minutes"]),
    ("recovery-capacity", lambda x: x["recovery_capacity_ready"] is True),
    ("failover-quota", lambda x: x["failover_quota_ready"] is True),
    ("recovery-config-drift", lambda x: x["recovery_config_current"] is True),
    ("dependency-order", lambda x: x["dependency_order_valid"] is True),
    ("control-plane-independence", lambda x: x["control_plane_dependency_required"] is False),
    ("recovery-routing", lambda x: x["routing_ready"] is True),
    ("single-writer-safety", lambda x: x["single_writer_enforced"] is True),
    ("failover-authority", lambda x: x["failover_authorized"] is True),
    ("recovery-communication", lambda x: x["communication_plan_ready"] is True),
    ("runbook-currency", lambda x: x["runbook_current"] is True),
    ("break-glass-access", lambda x: x["break_glass_credentials_tested"] is True),
    ("recovery-observability", lambda x: x["recovery_observability_ready"] is True),
    ("third-party-continuity", lambda x: x["third_party_dependencies_ready"] is True),
    ("failback-plan", lambda x: x["failback_plan_ready"] is True),
    ("recovery-soak", lambda x: x["soak_completed"] is True),
    ("cleanup-inventory", lambda x: x["cleanup_inventory_exact"] is True),
)

ALLOWED_TOP = {"schema_version", "base", "cases"}
ALLOWED_CASE = {"name", "overrides", "expected_boundary"}
KNOWN_FIELDS = {field for field in (
    "flow_defined business_impact_approved rto_minutes rpo_minutes "
    "strategy_rto_minutes strategy_rpo_minutes state_inventory_complete "
    "dependency_map_complete replication_is_backup backup_job_succeeded "
    "backup_age_minutes backup_identity_bound backup_independent_failure_domain "
    "backup_offline_or_immutable backup_encrypted recovery_key_available "
    "retention_covers_target backup_chain_complete checksum_verified restore_tested "
    "restore_target_isolated restore_version_compatible restore_authorized "
    "restored_integrity_valid application_correctness_valid security_validation_passed "
    "measured_data_loss_minutes measured_recovery_minutes recovery_capacity_ready "
    "failover_quota_ready recovery_config_current dependency_order_valid "
    "control_plane_dependency_required routing_ready single_writer_enforced "
    "failover_authorized communication_plan_ready runbook_current "
    "break_glass_credentials_tested recovery_observability_ready "
    "third_party_dependencies_ready failback_plan_ready soak_completed "
    "cleanup_inventory_exact"
).split()}


def fail(reason: str) -> "NoReturn":
    raise ValueError(reason)


def load(path: str) -> dict:
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(document, dict) or set(document) != ALLOWED_TOP:
        fail("top-level-shape")
    if document["schema_version"] != 1:
        fail("schema-version")
    base = document["base"]
    cases = document["cases"]
    if not isinstance(base, dict) or set(base) != KNOWN_FIELDS:
        fail("base-fields")
    if not isinstance(cases, list) or len(cases) != 45:
        fail("case-count")
    names = set()
    for case in cases:
        if not isinstance(case, dict) or set(case) != ALLOWED_CASE:
            fail("case-shape")
        if not isinstance(case["name"], str) or not case["name"] or case["name"] in names:
            fail("case-name")
        names.add(case["name"])
        if not isinstance(case["overrides"], dict):
            fail("case-overrides")
        if not set(case["overrides"]).issubset(KNOWN_FIELDS):
            fail("unknown-override")
        if case["expected_boundary"] not in {"defensible", *(name for name, _ in GATES)}:
            fail("expected-boundary")
        if boundary({**base, **case["overrides"]}) != case["expected_boundary"]:
            fail(f"expectation:{case['name']}")
    return document


def boundary(candidate: dict) -> str:
    for name, predicate in GATES:
        if not predicate(candidate):
            return name
    return "defensible"


def find_case(document: dict, name: str) -> dict:
    for case in document["cases"]:
        if case["name"] == name:
            return case
    fail(f"unknown-case:{name}")


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: model.py validate|list|show|evaluate|evaluate-all FIXTURE [CASE]", file=sys.stderr)
        return 2
    action, path = sys.argv[1:3]
    try:
        document = load(path)
        if action == "validate":
            print(f"model=valid cases={len(document['cases'])}")
        elif action == "list":
            print("\n".join(case["name"] for case in document["cases"]))
        elif action == "show":
            if len(sys.argv) != 4:
                fail("case-required")
            case = find_case(document, sys.argv[3])
            print(json.dumps({**document["base"], **case["overrides"]}, sort_keys=True, indent=2))
        elif action == "evaluate":
            if len(sys.argv) != 4:
                fail("case-required")
            case = find_case(document, sys.argv[3])
            observed = boundary({**document["base"], **case["overrides"]})
            print(f"case={case['name']} boundary={observed} expected={case['expected_boundary']}")
        elif action == "evaluate-all":
            for case in document["cases"]:
                observed = boundary({**document["base"], **case["overrides"]})
                print(f"case={case['name']} boundary={observed} expected={case['expected_boundary']}")
        else:
            fail("unknown-action")
    except (OSError, json.JSONDecodeError, ValueError, KeyError, TypeError) as exc:
        print(f"model=fail reason={exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
