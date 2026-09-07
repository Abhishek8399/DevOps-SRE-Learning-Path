#!/usr/bin/env python3
"""Deterministic OpenStack request-path evidence model; it calls no service."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("user-operation", "user_operation_defined"),
    ("request-identity", "request_identity_bound"),
    ("token-validity", "token_valid"),
    ("token-scope", "token_scope_correct"),
    ("service-catalog", "service_catalog_endpoint_bound"),
    ("endpoint-security", "endpoint_transport_secure"),
    ("api-contract", "api_microversion_compatible"),
    ("policy-authorization", "service_policy_authorized"),
    ("quota-headroom", "quota_headroom_available"),
    ("request-idempotency", "request_retry_bounded"),
    ("api-database", "api_database_available"),
    ("cell-mapping", "instance_cell_mapping_valid"),
    ("cell-health", "target_cell_healthy"),
    ("cell0-evidence", "cell0_failure_observable"),
    ("rpc-routing", "rpc_route_healthy"),
    ("request-spec", "scheduler_request_spec_valid"),
    ("placement-inventory", "placement_inventory_fresh"),
    ("placement-traits", "placement_traits_match"),
    ("placement-allocation", "placement_allocation_consistent"),
    ("scheduler-claim", "scheduler_claim_committed"),
    ("compute-service", "compute_service_healthy"),
    ("compute-admission", "compute_host_admitted"),
    ("image-record", "image_record_active"),
    ("image-bytes", "image_bytes_available"),
    ("image-provenance", "image_provenance_approved"),
    ("image-access", "image_access_authorized"),
    ("port-record", "neutron_port_record_ready"),
    ("port-binding", "neutron_port_binding_valid"),
    ("dataplane-realization", "network_dataplane_realized"),
    ("dhcp-metadata", "dhcp_metadata_path_ready"),
    ("security-policy", "security_group_effective"),
    ("packet-path", "packet_path_validated"),
    ("volume-record", "volume_record_available"),
    ("volume-backend", "volume_backend_healthy"),
    ("volume-attachment", "volume_attachment_consistent"),
    ("writer-authority", "volume_writer_authority"),
    ("hypervisor-spawn", "hypervisor_spawn_succeeded"),
    ("server-state", "server_state_consistent"),
    ("guest-boot", "guest_boot_observable"),
    ("application-readiness", "application_user_flow_ready"),
    ("failure-domains", "failure_domains_independent"),
    ("capacity-reserve", "failure_capacity_reserved"),
    ("database-messaging-ha", "database_messaging_ha_ready"),
    ("service-ha", "control_service_ha_ready"),
    ("fencing", "failed_member_fenced"),
    ("upgrade-compatibility", "rolling_upgrade_compatible"),
    ("data-migrations", "online_data_migrations_complete"),
    ("rollback-recovery", "rollback_recovery_tested"),
    ("observability-correlation", "request_evidence_correlated"),
    ("audit-cleanup", "audit_cleanup_exact"),
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
    return "operable-within-model"


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
    if not isinstance(cases, list) or len(cases) != 51:
        fail("case-count")
    names = set()
    allowed = {"operable-within-model", *(name for name, _ in GATES)}
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
