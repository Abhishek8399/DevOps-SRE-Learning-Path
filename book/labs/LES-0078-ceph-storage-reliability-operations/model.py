#!/usr/bin/env python3
"""Deterministic Ceph evidence-boundary model; it calls no cluster or service."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import NoReturn

GATES = (
    ("user-operation", "user-operation-undefined", "user_operation_defined"),
    ("cluster-identity", "cluster-fsid-unbound", "cluster_fsid_bound"),
    ("release-identity", "release-unproved", "release_identity_bound"),
    ("client-identity", "cephx-identity-unbound", "client_identity_bound"),
    ("client-capabilities", "cephx-capabilities-excessive", "client_capabilities_least_privilege"),
    ("monitor-quorum", "monitor-quorum-lost", "monitor_quorum_healthy"),
    ("clock-coherence", "cluster-clock-skew", "clock_coherent"),
    ("cluster-map", "cluster-map-unavailable", "cluster_map_available"),
    ("client-map", "stale-client-map", "client_map_current"),
    ("pool-identity", "pool-identity-unbound", "pool_identity_bound"),
    ("pool-application", "pool-application-uninitialized", "pool_application_bound"),
    ("pool-policy", "pool-policy-invalid", "pool_policy_valid"),
    ("protection-policy", "protection-policy-insufficient", "protection_policy_safe"),
    ("crush-topology", "crush-topology-unproved", "crush_topology_matches_physical"),
    ("crush-failure-domain", "crush-correlated-domain", "crush_failure_domains_independent"),
    ("pg-mapping", "object-pg-mapping-unbound", "object_pg_mapping_bound"),
    ("up-set", "pg-up-set-unavailable", "pg_up_set_available"),
    ("acting-set", "pg-acting-set-unresolved", "pg_acting_set_bound"),
    ("primary-authority", "pg-primary-ambiguous", "pg_primary_authoritative"),
    ("peering", "pg-peering-incomplete", "pg_peering_complete"),
    ("pg-availability", "pg-inactive", "pg_active"),
    ("pg-cleanliness", "active-degraded", "pg_clean"),
    ("shard-availability", "replica-or-shard-missing", "required_shards_available"),
    ("osd-liveness", "osd-down", "osds_up"),
    ("osd-membership", "osd-out-unexpected", "osds_membership_expected"),
    ("device-health", "osd-device-failing", "osd_devices_healthy"),
    ("bluestore-metadata", "bluestore-db-wal-unhealthy", "bluestore_metadata_healthy"),
    ("public-network", "public-network-degraded", "public_network_healthy"),
    ("cluster-network", "cluster-network-degraded", "cluster_network_healthy"),
    ("client-connection", "client-primary-connection-failed", "client_connection_healthy"),
    ("primary-queue", "primary-op-queue-saturated", "primary_queue_healthy"),
    ("media-commit", "primary-media-commit-failed", "primary_media_committed"),
    ("shard-acknowledgement", "replica-or-shard-ack-missing", "shard_acknowledgement_complete"),
    ("object-version", "object-version-diverged", "object_version_consistent"),
    ("client-retry", "client-retry-unbounded", "client_retry_bounded"),
    ("scrub-freshness", "scrub-backlog-stale", "scrub_fresh"),
    ("data-consistency", "pg-inconsistent", "data_consistency_validated"),
    ("recovery-progress", "recovery-stalled", "recovery_progressing"),
    ("backfill-reserve", "backfill-reserve-exhausted", "backfill_reserve_available"),
    ("recovery-contention", "recovery-user-slo-contention", "recovery_contention_bounded"),
    ("raw-capacity", "raw-capacity-unbound", "raw_capacity_known"),
    ("eligible-capacity", "crush-eligible-capacity-low", "eligible_capacity_sufficient"),
    ("fullness-distribution", "fullest-osd-imbalanced", "fullness_distribution_safe"),
    ("fullness-admission", "fullest-osd-at-full-ratio", "fullness_admission_safe"),
    ("failure-reserve", "failure-reserve-insufficient", "failure_capacity_reserved"),
    ("manager-observability", "manager-view-stale", "manager_observability_fresh"),
    ("evidence-correlation", "object-pg-osd-correlation-missing", "evidence_correlated"),
    ("rbd-identity", "rbd-image-unbound", "rbd_identity_bound"),
    ("rbd-lock", "rbd-lock-ambiguous", "rbd_lock_consistent"),
    ("openstack-linkage", "openstack-rbd-link-missing", "openstack_linkage_bound"),
    ("writer-authority", "rbd-writer-authority-ambiguous", "writer_authority_singular"),
    ("upgrade-compatibility", "mixed-release-incompatible", "upgrade_compatible"),
    ("rollback-recovery", "rollback-or-recovery-unproved", "rollback_recovery_tested"),
    ("user-io", "clean-user-slo-failed", "user_io_validated"),
    ("audit-cleanup", "orphan-or-cleanup-unproved", "audit_cleanup_exact"),
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
    if len(GATES) != 55:
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
