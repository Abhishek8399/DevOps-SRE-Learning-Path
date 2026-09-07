#!/usr/bin/env python3
"""Deterministic bare-metal lifecycle evidence model; it calls no hardware runtime."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("user-operation", "user-operation-undefined", "user_operation_defined"),
    ("asset-identity", "physical-asset-identity-unbound", "asset_identity_bound"),
    ("location-identity", "rack-slot-or-cabling-unbound", "location_identity_bound"),
    ("owner-authority", "owner-or-tenant-authority-unbound", "owner_authority_bound"),
    ("change-identity", "change-or-request-identity-unbound", "change_identity_bound"),
    ("release-contract", "controller-release-or-api-unbound", "release_contract_bound"),
    ("bmc-endpoint", "bmc-endpoint-identity-unbound", "bmc_endpoint_bound"),
    ("bmc-trust", "bmc-certificate-or-trust-invalid", "bmc_trust_valid"),
    ("bmc-authorization", "bmc-authorization-excessive-or-denied", "bmc_authorization_valid"),
    ("manager-health", "bmc-manager-unhealthy", "manager_health_valid"),
    ("task-state", "redfish-task-unknown-or-failed", "task_state_terminal_success"),
    ("power-observation", "power-state-stale-or-unknown", "power_observation_fresh"),
    ("power-reconciliation", "requested-and-observed-power-diverged", "power_reconciled"),
    ("firmware-inventory", "firmware-inventory-unbound", "firmware_inventory_bound"),
    ("firmware-compatibility", "firmware-bundle-incompatible", "firmware_compatible"),
    ("boot-mode", "uefi-or-legacy-mode-wrong", "boot_mode_valid"),
    ("secure-boot", "secure-boot-policy-or-keys-invalid", "secure_boot_valid"),
    ("boot-order", "boot-order-or-one-shot-target-wrong", "boot_order_valid"),
    ("management-network", "management-network-unreachable", "management_network_valid"),
    ("provisioning-network", "provisioning-network-unreachable", "provisioning_network_valid"),
    ("dhcp-identity", "dhcp-lease-or-client-identity-wrong", "dhcp_identity_valid"),
    ("network-bootstrap", "architecture-or-bootfile-mismatch", "network_bootstrap_valid"),
    ("ipxe-chain", "ipxe-chainload-loop-or-script-failed", "ipxe_chain_valid"),
    ("image-source", "image-source-unavailable", "image_source_valid"),
    ("image-integrity", "image-digest-or-signature-invalid", "image_integrity_valid"),
    ("agent-boot", "ephemeral-agent-did-not-boot", "agent_boot_valid"),
    ("agent-callback", "agent-callback-missing-or-misdirected", "agent_callback_valid"),
    ("inspection-freshness", "hardware-inspection-stale", "inspection_fresh"),
    ("cpu-inventory", "cpu-inventory-or-capability-wrong", "cpu_inventory_valid"),
    ("memory-inventory", "memory-inventory-or-health-wrong", "memory_inventory_valid"),
    ("storage-identity", "physical-storage-identity-unbound", "storage_identity_bound"),
    ("raid-realization", "desired-and-current-raid-diverged", "raid_realization_valid"),
    ("root-device", "root-device-selection-ambiguous", "root_device_valid"),
    ("nic-identity", "nic-mac-port-or-firmware-unbound", "nic_identity_bound"),
    ("switch-edge", "switch-port-vlan-bond-or-mtu-wrong", "switch_edge_valid"),
    ("time", "controller-bmc-agent-or-host-clock-diverged", "time_valid"),
    ("allocation", "allocation-owner-or-lease-invalid", "allocation_valid"),
    ("scheduling", "resource-class-or-trait-mismatch", "scheduling_valid"),
    ("provision-state", "provision-state-stalled-or-failed", "provision_state_valid"),
    ("disk-write", "image-write-incomplete-or-wrong-device", "disk_write_valid"),
    ("boot-artifacts", "partition-filesystem-or-bootloader-invalid", "boot_artifacts_valid"),
    ("instance-data", "metadata-or-config-drive-identity-wrong", "instance_data_valid"),
    ("first-boot", "cloud-init-or-first-boot-failed", "first_boot_valid"),
    ("os-identity", "installed-os-identity-unbound", "os_identity_bound"),
    ("host-network", "installed-host-network-invalid", "host_network_valid"),
    ("workload-readiness", "workload-not-ready", "workload_ready"),
    ("user-transaction", "original-user-operation-failed", "user_transaction_validated"),
    ("cross-plane-correlation", "bmc-controller-agent-os-evidence-uncorrelated", "cross_plane_correlated"),
    ("thermal-cooling", "thermal-fan-or-cooling-envelope-failed", "thermal_cooling_valid"),
    ("corrected-errors", "corrected-hardware-error-rate-unacceptable", "corrected_errors_bounded"),
    ("fatal-errors", "uncorrected-or-fatal-hardware-error", "fatal_errors_absent"),
    ("media-health", "disk-media-or-smart-health-failed", "media_health_valid"),
    ("redundancy", "power-network-storage-failure-domain-collapsed", "redundancy_valid"),
    ("capacity", "rack-power-cooling-or-fleet-reserve-insufficient", "capacity_reserve_sufficient"),
    ("burn-in", "burn-in-unbounded-failed-or-unreviewed", "burn_in_valid"),
    ("drain", "workload-drain-or-evacuation-unproved", "drain_valid"),
    ("maintenance-isolation", "maintenance-scope-or-fencing-invalid", "maintenance_isolation_valid"),
    ("upgrade-canary", "firmware-or-controller-canary-failed", "upgrade_canary_valid"),
    ("rollback-recovery", "rollback-recovery-or-reconciliation-unproved", "rollback_recovery_valid"),
    ("sanitization-method", "sanitization-method-does-not-match-risk", "sanitization_method_valid"),
    ("sanitization-evidence", "sanitization-verification-or-validation-failed", "sanitization_evidence_valid"),
    ("audit-cleanup", "cmdb-audit-ownership-or-cleanup-incomplete", "audit_cleanup_exact"),
)

KNOWN_FIELDS = {field for _, _, field in GATES}


def fail(reason: str) -> NoReturn:
    raise ValueError(reason)


def boundary(candidate: dict) -> str:
    for name, _, field in GATES:
        if candidate[field] is not True:
            return name
    return "operable-within-model"


def load(path: str) -> dict:
    document = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(document, dict) or set(document) != {"schema_version", "base"}:
        fail("top-level-shape")
    if document["schema_version"] != 1:
        fail("schema-version")
    if not isinstance(document["base"], dict) or set(document["base"]) != KNOWN_FIELDS:
        fail("base-fields")
    if any(type(value) is not bool for value in document["base"].values()):
        fail("base-types")
    if len(GATES) != 62:
        fail("gate-count")
    return document


def all_cases(document: dict) -> list[dict]:
    cases = [{"name": "baseline", "overrides": {}, "expected_boundary": "operable-within-model"}]
    cases.extend(
        {"name": case_name, "overrides": {field: False}, "expected_boundary": boundary_name}
        for boundary_name, case_name, field in GATES
    )
    return cases


def find_case(document: dict, name: str) -> dict:
    for case in all_cases(document):
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
        cases = all_cases(document)
        if action == "validate":
            for case in cases:
                observed = boundary({**document["base"], **case["overrides"]})
                if observed != case["expected_boundary"]:
                    fail(f"expectation:{case['name']}:{observed}")
            print(f"model=valid cases={len(cases)} gates={len(GATES)}")
        elif action == "list":
            print("\n".join(case["name"] for case in cases))
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
            for case in cases:
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
