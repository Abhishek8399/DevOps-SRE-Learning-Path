#!/usr/bin/env python3
"""Deterministic chaos-experiment evidence model; it injects no fault."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("purpose-defined", "purpose_defined"),
    ("owner-defined", "owner_defined"),
    ("critical-flow", "critical_flow_defined"),
    ("steady-state", "steady_state_measurable"),
    ("control-group", "control_group_defined"),
    ("falsifiable-hypothesis", "hypothesis_falsifiable"),
    ("realistic-fault", "fault_realistic"),
    ("target-inventory", "target_inventory_exact"),
    ("target-identity", "target_identity_bound"),
    ("nonproduction-first", "nonproduction_first"),
    ("blast-radius", "blast_radius_bounded"),
    ("least-privilege", "least_privilege_identity"),
    ("authorization", "execution_authorized"),
    ("change-freeze", "conflicting_changes_frozen"),
    ("observability", "observability_ready"),
    ("independent-probe", "probe_independent_of_fault_path"),
    ("abort-threshold", "abort_threshold_defined"),
    ("abort-tested", "abort_tested"),
    ("independent-stop", "stop_path_independent"),
    ("rollback-defined", "rollback_defined"),
    ("rollback-tested", "rollback_tested"),
    ("recovery-check", "recovery_check_defined"),
    ("time-bound", "duration_bounded"),
    ("concurrency-bound", "concurrency_bounded"),
    ("capacity-headroom", "capacity_headroom_ready"),
    ("dependency-contract", "dependency_contract_ready"),
    ("data-safety", "data_safety_reviewed"),
    ("security-review", "security_reviewed"),
    ("communication", "communication_ready"),
    ("incident-command", "incident_command_ready"),
    ("customer-support", "customer_support_ready"),
    ("versioned-experiment", "experiment_versioned"),
    ("peer-review", "experiment_peer_reviewed"),
    ("dry-run", "dry_run_passed"),
    ("healthy-baseline", "baseline_healthy"),
    ("control-stable", "control_stable"),
    ("injection-authorized", "injection_authority_reconfirmed"),
    ("continuous-guard", "guardrails_continuous"),
    ("fault-applied", "fault_application_observed"),
    ("hypothesis-verified", "hypothesis_evaluated"),
    ("abort-honored", "abort_honored"),
    ("rollback-attempted", "rollback_attempted"),
    ("correct-state-restored", "correct_state_restored"),
    ("findings-recorded", "findings_recorded"),
    ("action-owner", "action_owner_assigned"),
    ("cleanup-exact", "cleanup_inventory_exact"),
)

ALLOWED_TOP = {"schema_version", "base", "cases"}
ALLOWED_CASE = {"name", "overrides", "expected_boundary"}
KNOWN_FIELDS = {field for _, field in GATES}


def fail(reason: str) -> NoReturn:
    raise ValueError(reason)


def boundary(candidate: dict) -> str:
    for name, field in GATES:
        if candidate[field] is not True:
            return name
    return "defensible-within-model"


def load(path: str) -> dict:
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(document, dict) or set(document) != ALLOWED_TOP:
        fail("top-level-shape")
    if document["schema_version"] != 1:
        fail("schema-version")
    if not isinstance(document["base"], dict) or set(document["base"]) != KNOWN_FIELDS:
        fail("base-fields")
    if any(type(value) is not bool for value in document["base"].values()):
        fail("base-types")
    cases = document["cases"]
    if not isinstance(cases, list) or len(cases) != 47:
        fail("case-count")
    names = set()
    for case in cases:
        if not isinstance(case, dict) or set(case) != ALLOWED_CASE:
            fail("case-shape")
        if not isinstance(case["name"], str) or not case["name"] or case["name"] in names:
            fail("case-name")
        names.add(case["name"])
        overrides = case["overrides"]
        if not isinstance(overrides, dict) or not set(overrides).issubset(KNOWN_FIELDS):
            fail("case-overrides")
        if any(type(value) is not bool for value in overrides.values()):
            fail("override-types")
        allowed = {"defensible-within-model", *(name for name, _ in GATES)}
        if case["expected_boundary"] not in allowed:
            fail("expected-boundary")
        observed = boundary({**document["base"], **overrides})
        if observed != case["expected_boundary"]:
            fail(f"expectation:{case['name']}:{observed}")
    return document


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
            print(f"model=valid cases={len(document['cases'])} gates={len(GATES)}")
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
