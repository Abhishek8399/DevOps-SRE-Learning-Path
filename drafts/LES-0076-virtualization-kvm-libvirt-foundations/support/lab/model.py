#!/usr/bin/env python3
"""Deterministic virtualization-readiness evidence model; it creates no VM."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("workload-contract", "workload_contract_defined"),
    ("host-identity", "host_identity_bound"),
    ("firmware-virtualization", "firmware_virtualization_enabled"),
    ("kernel-kvm", "kernel_kvm_available"),
    ("kvm-device-access", "kvm_device_accessible"),
    ("architecture-match", "architecture_compatible"),
    ("emulator-identity", "emulator_identity_bound"),
    ("machine-type", "machine_type_bound"),
    ("domain-schema", "domain_xml_valid"),
    ("domain-identity", "domain_identity_unique"),
    ("cpu-model", "cpu_model_compatible"),
    ("vcpu-topology", "vcpu_topology_valid"),
    ("numa-policy", "numa_placement_defined"),
    ("memory-headroom", "memory_capacity_headroom"),
    ("memory-backing", "memory_backing_safe"),
    ("storage-source", "storage_source_identity"),
    ("image-format", "image_format_declared"),
    ("backing-chain", "backing_chain_complete"),
    ("storage-headroom", "storage_free_space_ready"),
    ("storage-confinement", "storage_permissions_confined"),
    ("network-mode", "network_mode_defined"),
    ("bridge-identity", "bridge_identity_bound"),
    ("network-identity", "mac_ip_identity_unique"),
    ("packet-policy", "packet_policy_reviewed"),
    ("least-privilege", "management_least_privilege"),
    ("secure-transport", "management_transport_secure"),
    ("domain-isolation", "domain_security_isolation"),
    ("firmware-state", "firmware_nvram_identity"),
    ("datasource-identity", "cloud_init_datasource_bound"),
    ("image-sanitization", "image_sanitized"),
    ("boot-observability", "boot_readiness_observable"),
    ("guest-agent-boundary", "guest_agent_dependency_bounded"),
    ("failure-reserve", "host_failure_reserve"),
    ("oversubscription-policy", "oversubscription_policy_defined"),
    ("noisy-neighbor-guards", "noisy_neighbor_guardrails"),
    ("failure-domain-inventory", "failure_domain_inventory"),
    ("placement-policy", "placement_anti_affinity"),
    ("migration-compatibility", "migration_compatibility"),
    ("migration-security", "migration_network_secure"),
    ("migration-storage", "migration_storage_available"),
    ("migration-abort", "migration_abort_defined"),
    ("restore-proof", "backup_restore_tested"),
    ("ha-fencing", "ha_fencing_defined"),
    ("ha-recovery", "ha_recovery_validated"),
    ("rollback", "change_rollback_defined"),
    ("monitoring-owner", "monitoring_owner_defined"),
    ("audit-evidence", "audit_evidence_ready"),
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
    return "admissible-within-model"


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
    if not isinstance(cases, list) or len(cases) != 49:
        fail("case-count")
    names = set()
    allowed = {"admissible-within-model", *(name for name, _ in GATES)}
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
