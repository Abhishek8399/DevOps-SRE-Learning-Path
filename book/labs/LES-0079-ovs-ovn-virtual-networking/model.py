#!/usr/bin/env python3
"""Deterministic OVS/OVN evidence-boundary model; it calls no network runtime."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("user-operation", "user-operation-undefined", "user_operation_defined"),
    ("resource-identity", "workload-or-network-identity-unbound", "resource_identity_bound"),
    ("release-identity", "ovs-ovn-release-unproved", "release_identity_bound"),
    ("schema-compatibility", "database-schema-incompatible", "schema_compatible"),
    ("cms-intent", "cms-intent-revision-stale", "cms_intent_current"),
    ("nb-identity", "northbound-database-unbound", "nb_database_bound"),
    ("nb-quorum", "northbound-quorum-lost", "nb_quorum_healthy"),
    ("nb-progress", "northbound-commit-stalled", "nb_progress_current"),
    ("northd-availability", "northd-unavailable", "northd_available"),
    ("northd-compilation", "northd-stalled", "northd_compilation_current"),
    ("sb-identity", "southbound-database-unbound", "sb_database_bound"),
    ("sb-quorum", "southbound-quorum-lost", "sb_quorum_healthy"),
    ("sb-progress", "southbound-commit-stalled", "sb_progress_current"),
    ("chassis-identity", "chassis-system-id-ambiguous", "chassis_identity_bound"),
    ("chassis-heartbeat", "chassis-stale", "chassis_heartbeat_fresh"),
    ("encapsulation-advertisement", "encapsulation-advertisement-wrong", "encapsulation_advertisement_valid"),
    ("port-binding", "logical-port-binding-missing", "port_binding_present"),
    ("binding-placement", "logical-port-bound-wrong-chassis", "binding_chassis_correct"),
    ("controller-connectivity", "controller-database-disconnected", "controller_connected"),
    ("controller-convergence", "controller-stale", "controller_converged"),
    ("ovsdb-identity", "local-ovsdb-unbound", "ovsdb_identity_bound"),
    ("integration-bridge", "integration-bridge-missing", "integration_bridge_valid"),
    ("bridge-mapping", "provider-bridge-mapping-wrong", "bridge_mapping_valid"),
    ("interface-identity", "interface-or-ofport-unbound", "interface_identity_bound"),
    ("interface-link", "interface-link-down", "interface_link_ready"),
    ("mtu-envelope", "endpoint-mtu-inconsistent", "endpoint_mtu_valid"),
    ("openflow-protocol", "openflow-protocol-mismatch", "openflow_protocol_compatible"),
    ("flow-ownership", "flow-owner-or-cookie-unbound", "flow_ownership_bound"),
    ("logical-flow-correlation", "logical-to-openflow-correlation-missing", "logical_flow_correlated"),
    ("flow-installation", "openflow-generation-stale", "openflow_installation_current"),
    ("pipeline-selection", "table-priority-shadowed", "pipeline_selection_correct"),
    ("policy-membership", "stale-address-set", "policy_membership_current"),
    ("conntrack-state", "conntrack-zone-or-state-wrong", "conntrack_state_valid"),
    ("nat-state", "nat-or-load-balancer-state-wrong", "nat_state_valid"),
    ("gateway-placement", "gateway-binding-stale", "gateway_placement_valid"),
    ("provider-path", "provider-bridge-or-vlan-wrong", "provider_path_valid"),
    ("next-hop", "route-or-neighbor-unresolved", "next_hop_valid"),
    ("tunnel-key", "logical-tunnel-key-mismatch", "tunnel_key_valid"),
    ("tunnel-endpoints", "tunnel-endpoint-mismatch", "tunnel_endpoints_valid"),
    ("underlay-route", "underlay-route-failed", "underlay_route_valid"),
    ("underlay-mtu", "underlay-mtu-failed", "underlay_mtu_valid"),
    ("underlay-bidirectional", "underlay-return-failed", "underlay_bidirectional"),
    ("tunnel-transport", "encapsulation-or-decapsulation-failed", "tunnel_transport_valid"),
    ("datapath-cache", "datapath-cache-stale", "datapath_cache_coherent"),
    ("upcall-pressure", "upcall-or-revalidation-saturated", "upcall_pressure_bounded"),
    ("offload-parity", "hardware-offload-diverged", "offload_parity_valid"),
    ("source-transmit", "source-packet-not-transmitted", "source_packet_transmitted"),
    ("remote-receive", "remote-outer-packet-not-received", "remote_packet_received"),
    ("destination-delivery", "destination-vif-not-delivered", "destination_delivered"),
    ("reply-generation", "application-reply-not-generated", "reply_generated"),
    ("reverse-logical", "reverse-policy-or-route-failed", "reverse_logical_valid"),
    ("reverse-transport", "reverse-path-failed", "reverse_transport_valid"),
    ("user-transaction", "packet-path-user-operation-failed", "user_transaction_validated"),
    ("observability", "network-evidence-stale", "observability_fresh"),
    ("capacity-reserve", "flow-tunnel-gateway-capacity-exhausted", "capacity_reserve_sufficient"),
    ("upgrade-compatibility", "mixed-version-incompatible", "upgrade_compatible"),
    ("rollback-cleanup", "rollback-or-cleanup-unproved", "rollback_cleanup_exact"),
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
    if len(GATES) != 57:
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
