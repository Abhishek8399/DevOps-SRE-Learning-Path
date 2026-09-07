#!/usr/bin/env python3
"""Offline private-cloud reliability teaching simulator.

This module deliberately has no subprocess, socket, HTTP, virtualization or
infrastructure client. It models decisions and emits bounded evidence only.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent
TOPOLOGY_PATH = ROOT / "topology.json"
WORKLOADS_PATH = ROOT / "workloads.json"
RUNTIME = ROOT / ".runtime"
DESCRIPTOR = RUNTIME / "descriptor.json"
STATE_PATH = RUNTIME / "baseline.json"
DOSSIER_PATH = RUNTIME / "design-dossier.md"
RECEIPTS = RUNTIME / "receipts"
PROJECT_ID = "atlas-private-cloud-lab"
RUNTIME_SCHEMA = 1
ID_PATTERN = re.compile(r"^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$")
TOKEN_PATTERN = re.compile(r"^[a-z0-9][a-z0-9.-]{0,63}$")
FORBIDDEN_INPUT_KEYS = {
    "address", "bmc", "credential", "endpoint", "hostName", "hostname",
    "password", "privateKey", "secret", "token", "uri", "url", "username",
}
ALLOWED_RUNTIME_FILES = {"descriptor.json", "baseline.json", "design-dossier.md"}
SCENARIOS = (
    "compute-host-loss",
    "rack-loss",
    "placement-generation-conflict",
    "gateway-failure",
    "mtu-mismatch",
    "ceph-osd-down",
    "ceph-near-full",
    "migration-incompatible",
    "upgrade-boundary",
    "restore-divergence",
    "bmc-ambiguous",
    "policy-violation",
)


class GuardError(ValueError):
    """A fail-closed input, authority or ownership refusal."""


class DuplicateKeyError(GuardError):
    """A JSON object contained a duplicate key."""


def _object_no_duplicates(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def canonical_json(value: Any) -> str:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def ensure_normal_user() -> None:
    getuid = getattr(os, "geteuid", None)
    if getuid is not None and getuid() == 0:
        raise GuardError("refusing root: run the simulator as a normal user")


def ensure_project_file(path: Path) -> None:
    if path.parent != ROOT or path.name not in {"topology.json", "workloads.json"}:
        raise GuardError(f"input must be an allowlisted project file: {path.name}")
    if path.is_symlink():
        raise GuardError(f"input may not be a symlink: {path.name}")
    if not path.is_file():
        raise GuardError(f"required input is missing: {path.name}")
    if path.resolve().parent != ROOT:
        raise GuardError(f"input escapes project root: {path.name}")


def load_json_strict(path: Path) -> dict[str, Any]:
    ensure_project_file(path)
    try:
        value = json.loads(path.read_text(encoding="utf-8"),
                           object_pairs_hook=_object_no_duplicates)
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        raise GuardError(f"invalid JSON in {path.name}: {exc}") from exc
    if not isinstance(value, dict):
        raise GuardError(f"{path.name} root must be an object")
    return value


def require_exact_keys(value: dict[str, Any], expected: set[str], context: str) -> None:
    actual = set(value)
    missing = sorted(expected - actual)
    unknown = sorted(actual - expected)
    if missing or unknown:
        raise GuardError(f"{context} keys mismatch missing={missing} unknown={unknown}")


def require_id(value: Any, context: str) -> str:
    if not isinstance(value, str) or not ID_PATTERN.fullmatch(value):
        raise GuardError(f"{context} must be a narrow lowercase synthetic identifier")
    return value


def require_token(value: Any, context: str) -> str:
    if not isinstance(value, str) or not TOKEN_PATTERN.fullmatch(value):
        raise GuardError(f"{context} must be a narrow lowercase capability token")
    if ".." in value or value.endswith((".", "-")):
        raise GuardError(f"{context} contains an unsafe token boundary")
    return value


def require_int(value: Any, context: str, minimum: int, maximum: int) -> int:
    if isinstance(value, bool) or not isinstance(value, int):
        raise GuardError(f"{context} must be an integer")
    if value < minimum or value > maximum:
        raise GuardError(f"{context} must be between {minimum} and {maximum}")
    return value


def reject_forbidden_keys(value: Any, context: str = "$") -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            if key in FORBIDDEN_INPUT_KEYS:
                raise GuardError(f"{context}.{key} is prohibited in this simulator")
            reject_forbidden_keys(child, f"{context}.{key}")
    elif isinstance(value, list):
        for index, child in enumerate(value):
            reject_forbidden_keys(child, f"{context}[{index}]")


def unique_ids(records: list[dict[str, Any]], context: str) -> set[str]:
    ids = [require_id(item.get("id"), f"{context}.id") for item in records]
    if len(ids) != len(set(ids)):
        raise GuardError(f"{context} contains duplicate IDs")
    return set(ids)


def validate_topology(topology: dict[str, Any]) -> None:
    require_exact_keys(
        topology,
        {"schemaVersion", "kind", "id", "release", "racks", "controllers",
         "computes", "gateways", "network", "storage", "policy"},
        "topology",
    )
    if topology["schemaVersion"] != 1 or topology["kind"] != "private-cloud-topology":
        raise GuardError("unsupported topology schema or kind")
    if topology["id"] != PROJECT_ID:
        raise GuardError("topology identity mismatch")
    if topology["release"] != "2026.1":
        raise GuardError("fixture release must be the reviewed 2026.1 baseline")
    reject_forbidden_keys(topology)

    for field in ("racks", "controllers", "computes", "gateways"):
        if not isinstance(topology[field], list) or not topology[field]:
            raise GuardError(f"topology.{field} must be a non-empty array")
    rack_ids = unique_ids(topology["racks"], "racks")
    if len(rack_ids) != 3:
        raise GuardError("fixture must model exactly three rack failure domains")
    power_domains: set[str] = set()
    network_domains: set[str] = set()
    for rack in topology["racks"]:
        require_exact_keys(rack, {"id", "powerDomain", "networkDomain"}, "rack")
        power_domains.add(require_id(rack["powerDomain"], "rack.powerDomain"))
        network_domains.add(require_id(rack["networkDomain"], "rack.networkDomain"))
    if len(power_domains) != 3 or len(network_domains) != 3:
        raise GuardError("every rack needs distinct power and network domains")

    controller_ids = unique_ids(topology["controllers"], "controllers")
    controller_racks: set[str] = set()
    for item in topology["controllers"]:
        require_exact_keys(item, {"id", "rack", "services", "version"}, "controller")
        if item["rack"] not in rack_ids:
            raise GuardError("controller references an unknown rack")
        controller_racks.add(item["rack"])
        if not isinstance(item["services"], list) or "database" not in item["services"]:
            raise GuardError("each controller must declare its modeled services")
        if item["version"] != topology["release"]:
            raise GuardError("controller version differs from topology release")
    if len(controller_ids) < 3 or len(controller_ids) % 2 == 0 or len(controller_racks) < 3:
        raise GuardError("controller quorum must be odd and span three racks")

    unique_ids(topology["computes"], "computes")
    for item in topology["computes"]:
        require_exact_keys(
            item,
            {"id", "rack", "vcpus", "memoryGiB", "diskGiB", "cpuModel",
             "machineType", "traits", "generation"},
            "compute",
        )
        if item["rack"] not in rack_ids:
            raise GuardError("compute references an unknown rack")
        require_int(item["vcpus"], "compute.vcpus", 1, 1024)
        require_int(item["memoryGiB"], "compute.memoryGiB", 1, 16384)
        require_int(item["diskGiB"], "compute.diskGiB", 1, 100000)
        require_int(item["generation"], "compute.generation", 0, 2_000_000_000)
        require_token(item["cpuModel"], "compute.cpuModel")
        require_token(item["machineType"], "compute.machineType")
        if not isinstance(item["traits"], list) or not item["traits"]:
            raise GuardError("compute.traits must be a non-empty array")
        for trait in item["traits"]:
            require_id(trait, "compute.trait")

    unique_ids(topology["gateways"], "gateways")
    gateway_racks: set[str] = set()
    priorities: set[int] = set()
    for item in topology["gateways"]:
        require_exact_keys(item, {"id", "rack", "priority"}, "gateway")
        if item["rack"] not in rack_ids:
            raise GuardError("gateway references an unknown rack")
        gateway_racks.add(item["rack"])
        priorities.add(require_int(item["priority"], "gateway.priority", 1, 1000))
    if len(gateway_racks) < 2 or len(priorities) != len(topology["gateways"]):
        raise GuardError("gateway HA needs distinct racks and priorities")

    network = topology["network"]
    require_exact_keys(
        network,
        {"overlay", "tenantMtu", "underlayMtu", "encapsulationOverhead",
         "externalGatewayCount", "defaultDeny"},
        "network",
    )
    if network["overlay"] != "geneve" or network["defaultDeny"] is not True:
        raise GuardError("fixture requires Geneve and default-deny policy")
    tenant_mtu = require_int(network["tenantMtu"], "network.tenantMtu", 576, 9216)
    underlay_mtu = require_int(network["underlayMtu"], "network.underlayMtu", 576, 9216)
    overhead = require_int(network["encapsulationOverhead"],
                           "network.encapsulationOverhead", 1, 512)
    if underlay_mtu < tenant_mtu + overhead:
        raise GuardError("underlay MTU cannot carry the declared tenant frame and overlay")
    if network["externalGatewayCount"] != len(topology["gateways"]):
        raise GuardError("gateway count disagrees with gateway inventory")

    storage = topology["storage"]
    require_exact_keys(
        storage,
        {"pool", "size", "minSize", "failureDomain", "nearFullRatio",
         "fullRatio", "osds"},
        "storage",
    )
    require_id(storage["pool"], "storage.pool")
    if storage["size"] != 3 or storage["minSize"] != 2:
        raise GuardError("fixture protection must be size=3 and minSize=2")
    if storage["failureDomain"] != "rack":
        raise GuardError("fixture must protect across rack failure domains")
    if not (0 < storage["nearFullRatio"] < storage["fullRatio"] < 1):
        raise GuardError("storage fullness ratios are invalid")
    if not isinstance(storage["osds"], list) or len(storage["osds"]) < 6:
        raise GuardError("fixture needs at least six OSDs")
    unique_ids(storage["osds"], "osds")
    osd_racks: set[str] = set()
    for osd in storage["osds"]:
        require_exact_keys(osd, {"id", "rack", "capacityGiB", "usedGiB"}, "osd")
        if osd["rack"] not in rack_ids:
            raise GuardError("OSD references an unknown rack")
        osd_racks.add(osd["rack"])
        capacity = require_int(osd["capacityGiB"], "osd.capacityGiB", 1, 1_000_000)
        used = require_int(osd["usedGiB"], "osd.usedGiB", 0, 1_000_000)
        if used > capacity:
            raise GuardError("OSD used capacity exceeds physical capacity")
    if len(osd_racks) < storage["size"]:
        raise GuardError("not enough rack domains for the declared replica size")

    policy = topology["policy"]
    require_exact_keys(
        policy,
        {"quotaVcpus", "quotaMemoryGiB", "quotaVolumesGiB",
         "requiredImageTrust", "requiredComputeTrait", "reserveComputeRatio",
         "reserveStorageRatio"},
        "policy",
    )
    require_int(policy["quotaVcpus"], "policy.quotaVcpus", 1, 100000)
    require_int(policy["quotaMemoryGiB"], "policy.quotaMemoryGiB", 1, 1_000_000)
    require_int(policy["quotaVolumesGiB"], "policy.quotaVolumesGiB", 0, 10_000_000)
    if policy["requiredImageTrust"] != "signed":
        raise GuardError("fixture must require signed images")
    require_id(policy["requiredComputeTrait"], "policy.requiredComputeTrait")
    for name in ("reserveComputeRatio", "reserveStorageRatio"):
        if not isinstance(policy[name], (int, float)) or isinstance(policy[name], bool):
            raise GuardError(f"policy.{name} must be numeric")
        if not 0 < policy[name] < 1:
            raise GuardError(f"policy.{name} must be between zero and one")


def validate_workloads(document: dict[str, Any], topology: dict[str, Any]) -> None:
    require_exact_keys(
        document,
        {"schemaVersion", "kind", "topologyId", "workloads"},
        "workload document",
    )
    if document["schemaVersion"] != 1 or document["kind"] != "private-cloud-workloads":
        raise GuardError("unsupported workload schema or kind")
    if document["topologyId"] != topology["id"]:
        raise GuardError("workload topology identity mismatch")
    reject_forbidden_keys(document)
    if not isinstance(document["workloads"], list) or not document["workloads"]:
        raise GuardError("workloads must be a non-empty array")
    unique_ids(document["workloads"], "workloads")
    allowed_cpu = {item["cpuModel"] for item in topology["computes"]}
    allowed_machine = {item["machineType"] for item in topology["computes"]}
    for item in document["workloads"]:
        require_exact_keys(
            item,
            {"id", "replicas", "vcpusEach", "memoryGiBEach", "rootDiskGiBEach",
             "dataVolumeGiB", "persistentData", "imageTrust", "requiredTrait",
             "antiAffinity", "cpuModel", "machineType", "serviceTier",
             "userOperation", "requiresExternalPath"},
            "workload",
        )
        require_int(item["replicas"], "workload.replicas", 1, 100)
        require_int(item["vcpusEach"], "workload.vcpusEach", 1, 512)
        require_int(item["memoryGiBEach"], "workload.memoryGiBEach", 1, 8192)
        require_int(item["rootDiskGiBEach"], "workload.rootDiskGiBEach", 1, 100000)
        require_int(item["dataVolumeGiB"], "workload.dataVolumeGiB", 0, 1_000_000)
        for flag in ("persistentData", "requiresExternalPath"):
            if not isinstance(item[flag], bool):
                raise GuardError(f"workload.{flag} must be boolean")
        if item["imageTrust"] not in {"signed", "unsigned"}:
            raise GuardError("workload.imageTrust is invalid")
        require_id(item["requiredTrait"], "workload.requiredTrait")
        if item["antiAffinity"] not in {"rack", "none"}:
            raise GuardError("workload.antiAffinity is invalid")
        if item["cpuModel"] not in allowed_cpu or item["machineType"] not in allowed_machine:
            raise GuardError("workload requests an unknown CPU or machine baseline")
        if item["serviceTier"] not in {"protected", "rebuildable"}:
            raise GuardError("workload.serviceTier is invalid")
        require_id(item["userOperation"], "workload.userOperation")


def load_inputs() -> tuple[dict[str, Any], dict[str, Any]]:
    topology = load_json_strict(TOPOLOGY_PATH)
    workloads = load_json_strict(WORKLOADS_PATH)
    validate_topology(topology)
    validate_workloads(workloads, topology)
    return topology, workloads


def expected_descriptor() -> dict[str, Any]:
    return {
        "schemaVersion": RUNTIME_SCHEMA,
        "kind": "private-cloud-simulator-runtime",
        "projectId": PROJECT_ID,
        "topologySha256": sha256_file(TOPOLOGY_PATH),
        "workloadsSha256": sha256_file(WORKLOADS_PATH),
        "authority": "local-simulation-only",
    }


def ensure_runtime_absent() -> None:
    if RUNTIME.exists() or RUNTIME.is_symlink():
        raise GuardError("runtime already exists; inspect or use guarded cleanup")


def ensure_runtime_owned() -> dict[str, Any]:
    if RUNTIME.is_symlink() or not RUNTIME.is_dir():
        raise GuardError("runtime is missing or is not a real directory")
    if DESCRIPTOR.is_symlink() or not DESCRIPTOR.is_file():
        raise GuardError("runtime descriptor is missing or unsafe")
    try:
        descriptor = json.loads(
            DESCRIPTOR.read_text(encoding="utf-8"),
            object_pairs_hook=_object_no_duplicates,
        )
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        raise GuardError(f"invalid runtime descriptor: {exc}") from exc
    if descriptor != expected_descriptor():
        raise GuardError("runtime descriptor does not match current project inputs")
    for item in RUNTIME.iterdir():
        if item.is_symlink():
            raise GuardError(f"runtime contains symlink: {item.name}")
        if item.is_file() and item.name not in ALLOWED_RUNTIME_FILES:
            raise GuardError(f"runtime contains unknown file: {item.name}")
        if item.is_dir() and item.name != "receipts":
            raise GuardError(f"runtime contains unknown directory: {item.name}")
    if RECEIPTS.exists():
        if RECEIPTS.is_symlink() or not RECEIPTS.is_dir():
            raise GuardError("receipts path is unsafe")
        for item in RECEIPTS.iterdir():
            if item.is_symlink() or not item.is_file():
                raise GuardError(f"receipt entry is unsafe: {item.name}")
            if item.name not in {f"{name}.json" for name in SCENARIOS}:
                raise GuardError(f"unknown receipt file: {item.name}")
    return descriptor


def write_json(path: Path, value: Any) -> None:
    if path.parent not in {RUNTIME, RECEIPTS}:
        raise GuardError("write target is outside the allowlisted runtime")
    if path.exists() and path.is_symlink():
        raise GuardError(f"refusing symlink write target: {path.name}")
    temporary = path.with_name(path.name + ".tmp")
    if temporary.exists() or temporary.is_symlink():
        raise GuardError(f"temporary write target already exists: {temporary.name}")
    temporary.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n",
                         encoding="utf-8")
    temporary.replace(path)


def initialize() -> dict[str, Any]:
    ensure_normal_user()
    load_inputs()
    ensure_runtime_absent()
    RUNTIME.mkdir(mode=0o700)
    RECEIPTS.mkdir(mode=0o700)
    write_json(DESCRIPTOR, expected_descriptor())
    ensure_runtime_owned()
    return {"initialize": "pass", "projectId": PROJECT_ID, "runtime": ".runtime"}


def host_compatible(host: dict[str, Any], workload: dict[str, Any]) -> bool:
    return (
        workload["requiredTrait"] in host["traits"]
        and workload["cpuModel"] == host["cpuModel"]
        and workload["machineType"] == host["machineType"]
    )


def build_baseline(topology: dict[str, Any], document: dict[str, Any]) -> dict[str, Any]:
    policy = topology["policy"]
    allocations: list[dict[str, Any]] = []
    used: dict[str, dict[str, int]] = {
        host["id"]: {"vcpus": 0, "memoryGiB": 0, "diskGiB": 0}
        for host in topology["computes"]
    }
    total_vcpus = 0
    total_memory = 0
    total_volumes = 0
    for workload in document["workloads"]:
        if workload["imageTrust"] != policy["requiredImageTrust"]:
            raise GuardError(f"{workload['id']} violates image-trust policy")
        total_vcpus += workload["replicas"] * workload["vcpusEach"]
        total_memory += workload["replicas"] * workload["memoryGiBEach"]
        total_volumes += workload["dataVolumeGiB"]
        selected_racks: set[str] = set()
        for replica in range(workload["replicas"]):
            candidates = []
            for host in topology["computes"]:
                capacity = used[host["id"]]
                if not host_compatible(host, workload):
                    continue
                if workload["antiAffinity"] == "rack" and host["rack"] in selected_racks:
                    continue
                if capacity["vcpus"] + workload["vcpusEach"] > host["vcpus"]:
                    continue
                if capacity["memoryGiB"] + workload["memoryGiBEach"] > host["memoryGiB"]:
                    continue
                if capacity["diskGiB"] + workload["rootDiskGiBEach"] > host["diskGiB"]:
                    continue
                candidates.append(host)
            if not candidates:
                raise GuardError(f"no compatible capacity for {workload['id']} replica {replica}")
            candidates.sort(key=lambda host: (
                used[host["id"]]["vcpus"] / host["vcpus"],
                host["id"],
            ))
            chosen = candidates[0]
            selected_racks.add(chosen["rack"])
            used[chosen["id"]]["vcpus"] += workload["vcpusEach"]
            used[chosen["id"]]["memoryGiB"] += workload["memoryGiBEach"]
            used[chosen["id"]]["diskGiB"] += workload["rootDiskGiBEach"]
            allocations.append({
                "workloadId": workload["id"],
                "replica": replica,
                "hostId": chosen["id"],
                "rack": chosen["rack"],
                "generation": chosen["generation"],
            })
    if total_vcpus > policy["quotaVcpus"]:
        raise GuardError("workload set exceeds vCPU quota")
    if total_memory > policy["quotaMemoryGiB"]:
        raise GuardError("workload set exceeds memory quota")
    if total_volumes > policy["quotaVolumesGiB"]:
        raise GuardError("workload set exceeds volume quota")

    total_compute = sum(host["vcpus"] for host in topology["computes"])
    used_compute = sum(item["vcpus"] for item in used.values())
    compute_reserve = (total_compute - used_compute) / total_compute
    total_storage = sum(osd["capacityGiB"] for osd in topology["storage"]["osds"])
    used_storage = sum(osd["usedGiB"] for osd in topology["storage"]["osds"])
    storage_reserve = (total_storage - used_storage) / total_storage
    active_gateway = sorted(topology["gateways"],
                            key=lambda item: (-item["priority"], item["id"]))[0]
    return {
        "schemaVersion": 1,
        "kind": "private-cloud-baseline",
        "projectId": PROJECT_ID,
        "release": topology["release"],
        "allocations": allocations,
        "hostUsage": used,
        "quota": {
            "vcpus": total_vcpus,
            "memoryGiB": total_memory,
            "volumesGiB": total_volumes,
        },
        "capacity": {
            "computeReserveRatio": round(compute_reserve, 6),
            "storageReserveRatio": round(storage_reserve, 6),
            "computeReservePass": compute_reserve >= policy["reserveComputeRatio"],
            "storageReservePass": storage_reserve >= policy["reserveStorageRatio"],
        },
        "controlQuorum": {"members": 3, "required": 2, "healthy": 3},
        "network": {
            "intent": "present",
            "activeGateway": active_gateway["id"],
            "mtuPass": topology["network"]["underlayMtu"]
            >= topology["network"]["tenantMtu"]
            + topology["network"]["encapsulationOverhead"],
            "externalProbe": "pass",
        },
        "storage": {
            "replicaSize": topology["storage"]["size"],
            "minSize": topology["storage"]["minSize"],
            "failureDomain": topology["storage"]["failureDomain"],
            "healthyRacks": 3,
            "health": "clean",
        },
        "userOperations": {
            item["userOperation"]: "pass" for item in document["workloads"]
        },
        "proofLimit": "deterministic local simulation only",
    }


def run_baseline() -> dict[str, Any]:
    ensure_normal_user()
    ensure_runtime_owned()
    topology, workloads = load_inputs()
    baseline = build_baseline(topology, workloads)
    if not all(baseline["capacity"][name] for name in
               ("computeReservePass", "storageReservePass")):
        raise GuardError("baseline violates declared reserve policy")
    write_json(STATE_PATH, baseline)
    return {
        "baseline": "pass",
        "allocations": len(baseline["allocations"]),
        "computeReserveRatio": baseline["capacity"]["computeReserveRatio"],
        "storageReserveRatio": baseline["capacity"]["storageReserveRatio"],
        "userOperations": baseline["userOperations"],
    }


def load_baseline() -> dict[str, Any]:
    ensure_runtime_owned()
    if STATE_PATH.is_symlink() or not STATE_PATH.is_file():
        raise GuardError("baseline is missing; run baseline first")
    try:
        value = json.loads(STATE_PATH.read_text(encoding="utf-8"),
                           object_pairs_hook=_object_no_duplicates)
    except (json.JSONDecodeError, UnicodeDecodeError) as exc:
        raise GuardError(f"invalid baseline: {exc}") from exc
    if not isinstance(value, dict) or value.get("projectId") != PROJECT_ID:
        raise GuardError("baseline identity mismatch")
    return value


def scenario_result(
    name: str,
    result: str,
    signal: str,
    decision: str,
    evidence: list[str],
    recovery: list[str],
    proves: str,
    does_not_prove: str,
) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "kind": "private-cloud-scenario-receipt",
        "projectId": PROJECT_ID,
        "scenario": name,
        "result": result,
        "signal": signal,
        "decision": decision,
        "evidence": evidence,
        "recovery": recovery,
        "proves": proves,
        "doesNotProve": does_not_prove,
    }


def evaluate_scenario(
    name: str,
    topology: dict[str, Any],
    workloads: dict[str, Any],
    baseline: dict[str, Any],
) -> dict[str, Any]:
    del workloads
    checkout = [
        item for item in baseline["allocations"]
        if item["workloadId"] == "checkout-api"
    ]
    if name == "compute-host-loss":
        failed = checkout[0]
        remaining = [item for item in checkout if item["hostId"] != failed["hostId"]]
        return scenario_result(
            name, "degraded",
            f"{failed['hostId']} is down; one checkout replica remains",
            "keep the surviving replica, fence the failed host and replace capacity before restoring anti-affinity",
            [f"failed_rack={failed['rack']}", f"surviving_replicas={len(remaining)}",
             "persistent_volume=ceph", "compatible_spare_racks=0"],
            ["prove fencing", "validate surviving user operation",
             "add compatible x86-64-v3/pc-q35-9.2 capacity in another rack",
             "rebuild the replica and recheck anti-affinity"],
            "the model preserves one protected replica and refuses a false HA repair",
            "real guest state, fencing, evacuation or data durability",
        )
    if name == "rack-loss":
        failed_rack = "rack-a"
        controllers = sum(item["rack"] != failed_rack for item in topology["controllers"])
        checkout_remaining = sum(item["rack"] != failed_rack for item in checkout)
        storage_racks = len({
            item["rack"] for item in topology["storage"]["osds"]
            if item["rack"] != failed_rack
        })
        return scenario_result(
            name, "degraded",
            f"{failed_rack} power and network are unavailable",
            "hold new risk, serve from surviving quorum/replica and restore the failure domain deliberately",
            [f"controllers_healthy={controllers}", "controllers_required=2",
             f"checkout_replicas_healthy={checkout_remaining}",
             f"ceph_replica_racks_available={storage_racks}",
             f"ceph_min_size={topology['storage']['minSize']}"],
            ["confirm correlated failure scope", "validate external path through another gateway",
             "watch Ceph degraded/recovery state and latency",
             "restore rack components in dependency order", "reconcile placement and replicas"],
            "the declared three-rack topology retains minimum service paths after one rack loss",
            "real quorum timing, Ceph object availability, network convergence or workload correctness",
        )
    if name == "placement-generation-conflict":
        host = topology["computes"][0]
        observed = host["generation"]
        attempted = observed - 1
        return scenario_result(
            name, "blocked",
            f"allocation expected generation {attempted}, current generation is {observed}",
            "reject the stale allocation and repeat candidate selection from current inventory",
            [f"provider={host['id']}", f"expected_generation={attempted}",
             f"current_generation={observed}", "allocation_written=false"],
            ["reload provider inventory", "recalculate candidates and quota",
             "retry with bounded conflict handling", "reconcile consumer allocation"],
            "stale capacity cannot be committed by this model",
            "real Placement concurrency behavior or scheduler correctness",
        )
    if name == "gateway-failure":
        ordered = sorted(topology["gateways"], key=lambda item: (-item["priority"], item["id"]))
        failed, successor = ordered[0], ordered[1]
        return scenario_result(
            name, "degraded",
            f"active gateway {failed['id']} is unavailable",
            f"bind external responsibility to {successor['id']} and validate a fresh user flow",
            [f"intent_gateway_members={len(ordered)}", f"successor_rack={successor['rack']}",
             "northbound_intent=present", "existing_session_continuity=unknown"],
            ["confirm chassis liveness", "observe southbound binding and local flows",
             "validate underlay neighbor/routing", "probe the exact external user operation"],
            "a separate gateway candidate exists outside the failed rack",
            "session survival, real OVN convergence or underlay reachability",
        )
    if name == "mtu-mismatch":
        required = (
            topology["network"]["tenantMtu"]
            + topology["network"]["encapsulationOverhead"]
        )
        injected = required - 30
        return scenario_result(
            name, "unavailable",
            f"underlay MTU {injected} is below required encapsulated size {required}",
            "stop rollout; repair the end-to-end MTU contract before retrying the user path",
            [f"tenant_mtu={topology['network']['tenantMtu']}",
             f"encapsulation_overhead={topology['network']['encapsulationOverhead']}",
             f"injected_underlay_mtu={injected}", "neutron_status=ACTIVE",
             "large_packet_probe=fail"],
            ["trace source vNIC, OVS, tunnel, underlay and gateway MTUs",
             "repair the narrowest incorrect boundary", "repeat small and large packet probes",
             "validate TCP/TLS/application operation"],
            "API state can be healthy while the data path violates its frame contract",
            "real packet delivery, PMTUD or vendor offload behavior",
        )
    if name == "ceph-osd-down":
        osd = topology["storage"]["osds"][0]
        return scenario_result(
            name, "degraded",
            f"{osd['id']} is down and recovery competes with client I/O",
            "preserve client latency and replica safety; investigate before changing recovery limits",
            [f"osd={osd['id']}", f"rack={osd['rack']}", "pool_size=3",
             "pool_min_size=2", "available_replica_racks=3", "slow_ops=possible"],
            ["check monitor quorum and detailed health", "locate affected PGs and acting sets",
             "verify remaining failure-domain copies", "bound recovery/backfill impact",
             "replace or restore the OSD and wait for clean evidence"],
            "one OSD loss reduces redundancy but does not cross the modeled min_size boundary",
            "object-level availability, integrity, latency or real recovery duration",
        )
    if name == "ceph-near-full":
        injected_ratio = 0.875
        return scenario_result(
            name, "blocked",
            "all modeled OSDs are 87.5% used, above the 85% near-full threshold",
            "reject new capacity demand and preserve space for recovery before any host/rack maintenance",
            [f"used_ratio={injected_ratio}", "near_full_ratio=0.85",
             "full_ratio=0.95", "new_allocation=false",
             "recovery_headroom=insufficient"],
            ["stop nonessential writes or growth", "identify skew and reclaimable data safely",
             "add and rebalance capacity with an abort threshold",
             "prove recovery headroom before reopening admission"],
            "the admission policy protects a declared storage reserve",
            "real object distribution, compaction, backfill amplification or time to full",
        )
    if name == "migration-incompatible":
        source = topology["computes"][0]
        target = topology["computes"][2]
        return scenario_result(
            name, "blocked",
            f"{source['id']} and {target['id']} have incompatible CPU/machine baselines",
            "do not force live migration; use a compatible target or a reviewed cold rebuild path",
            [f"source_cpu={source['cpuModel']}", f"target_cpu={target['cpuModel']}",
             f"source_machine={source['machineType']}",
             f"target_machine={target['machineType']}", "migration_started=false"],
            ["select a host matching CPU and machine baseline",
             "verify storage/network/device compatibility", "set abort and convergence limits",
             "validate guest and user operation after movement"],
            "the model refuses a known-incompatible live migration",
            "QEMU device compatibility, dirty-page convergence, downtime or application tolerance",
        )
    if name == "upgrade-boundary":
        return scenario_result(
            name, "blocked",
            "requested 2027.1 controller jump exceeds the reviewed 2026.1 compatibility window",
            "stop before mutation; build a supported hop-by-hop plan with quorum, schema and rollback gates",
            ["current_release=2026.1", "requested_release=2027.1",
             "reviewed_direct_hop=false", "services_changed=0"],
            ["read release-specific upgrade notes", "back up and rehearse control-state restore",
             "canary stateless services", "expand only while API, queue, DB and cell checks pass",
             "upgrade computes/storage in documented order"],
            "unreviewed release jumps fail closed",
            "actual release compatibility, database rollback or mixed-version production behavior",
        )
    if name == "restore-divergence":
        return scenario_result(
            name, "blocked",
            "restored API allocations disagree with compute runtime and Ceph attachment identities",
            "keep the restore isolated and reconcile every authority before any traffic or promotion",
            ["api_allocations=3", "compute_domains=2", "ceph_attachments=2",
             "ovn_ports=3", "promotion=false"],
            ["preserve the isolated snapshot and manifests",
             "compare server, allocation, port, volume and guest identities",
             "choose authoritative correction per state class",
             "repeat consistency and user-path validation", "approve promotion separately"],
            "count and identity divergence blocks an unsafe control-state promotion",
            "real database consistency, guest filesystem correctness or recoverability",
        )
    if name == "bmc-ambiguous":
        return scenario_result(
            name, "blocked",
            "power request returned an asynchronous task and client observation timed out",
            "do not repeat power action; poll the task and re-read exact system power/boot identity",
            ["request_status=202", "task_state=running", "system_identity=compute-a",
             "repeat_action=false"],
            ["validate system UUID/serial through an authorized inventory",
             "poll task monitor to terminal state", "read power and boot state",
             "fence only after an explicit ambiguous-outcome decision"],
            "ambiguous hardware actions require reconciliation before retry",
            "a real BMC task outcome, fencing safety or hardware health",
        )
    if name == "policy-violation":
        return scenario_result(
            name, "blocked",
            "request is unsigned, exceeds vCPU quota and asks to bypass default-deny networking",
            "reject the request without weakening global policy; return each violated contract",
            ["image_trust=unsigned", "requested_vcpus=64", "quota_vcpus=48",
             "network_default_deny_bypass=true", "resources_created=0"],
            ["supply a trusted image", "resize or obtain reviewed quota",
             "declare the minimum network policy", "repeat normal admission"],
            "multiple tenant-policy violations are rejected before allocation",
            "real Keystone policy, signature verification or Neutron enforcement",
        )
    raise GuardError(f"unknown scenario: {name}")


def run_scenario(name: str) -> dict[str, Any]:
    ensure_normal_user()
    if name not in SCENARIOS:
        raise GuardError(f"scenario must be one of: {', '.join(SCENARIOS)}")
    topology, workloads = load_inputs()
    baseline = load_baseline()
    receipt = evaluate_scenario(name, topology, workloads, baseline)
    write_json(RECEIPTS / f"{name}.json", receipt)
    return receipt


def build_dossier() -> dict[str, Any]:
    ensure_normal_user()
    topology, workloads = load_inputs()
    baseline = load_baseline()
    receipts = []
    for name in SCENARIOS:
        path = RECEIPTS / f"{name}.json"
        if path.is_symlink() or not path.is_file():
            raise GuardError(f"scenario receipt missing: {name}")
        value = json.loads(path.read_text(encoding="utf-8"),
                           object_pairs_hook=_object_no_duplicates)
        if value.get("projectId") != PROJECT_ID or value.get("scenario") != name:
            raise GuardError(f"scenario receipt identity mismatch: {name}")
        receipts.append(value)
    rack_rows = "\n".join(
        f"| {rack['id']} | {rack['powerDomain']} | {rack['networkDomain']} |"
        for rack in topology["racks"]
    )
    workload_rows = "\n".join(
        f"| {item['id']} | {item['replicas']} | {item['serviceTier']} | "
        f"{item['cpuModel']} / {item['machineType']} | {item['persistentData']} |"
        for item in workloads["workloads"]
    )
    scenario_rows = "\n".join(
        f"| {item['scenario']} | {item['result']} | {item['decision']} |"
        for item in receipts
    )
    dossier = f"""# CAP-004 generated design dossier

Generated from immutable fixture identities. This is simulation evidence, not a deployed-cloud report.

## System boundary

Protected VM intent crosses identity/policy, Placement inventory/allocation, Nova cell lifecycle, KVM/libvirt runtime, Neutron/OVN intent and dataplane realization, Ceph durability, hardware control and user-path validation.

## Failure domains

| Rack | Power | Network |
|---|---|---|
{rack_rows}

## Workload contracts

| Workload | Replicas | Tier | CPU / machine baseline | Persistent data |
|---|---:|---|---|---|
{workload_rows}

## Baseline capacity and operation

- compute reserve: {baseline['capacity']['computeReserveRatio']:.3f}
- storage reserve: {baseline['capacity']['storageReserveRatio']:.3f}
- control quorum: {baseline['controlQuorum']['healthy']} healthy / {baseline['controlQuorum']['required']} required
- storage protection: size {baseline['storage']['replicaSize']}, min_size {baseline['storage']['minSize']}, failure domain {baseline['storage']['failureDomain']}
- user operations: {canonical_json(baseline['userOperations'])}

## Failure decisions

| Scenario | Result | Decision |
|---|---|---|
{scenario_rows}

## State recovery order

1. Identify the user operation and exact failed boundary.
2. Fence ambiguous physical writers before replacement.
3. Preserve controller, Placement, OVN and Ceph evidence independently.
4. Restore each authority to an isolated or explicitly scoped target.
5. Reconcile server, allocation, port, volume, guest and user-operation identities.
6. Promote or return traffic only through a separate reviewed decision.

## Proof limits

No real hypervisor, OpenStack service, OVN database/flow, Ceph object/PG, BMC task, network packet, workload, performance sample, upgrade or restore ran. The model proves only deterministic contract evaluation for its synthetic inputs.
"""
    temporary = DOSSIER_PATH.with_name(DOSSIER_PATH.name + ".tmp")
    if DOSSIER_PATH.is_symlink() or temporary.exists() or temporary.is_symlink():
        raise GuardError("dossier output path is unsafe")
    temporary.write_text(dossier, encoding="utf-8")
    temporary.replace(DOSSIER_PATH)
    return {
        "dossier": "pass",
        "scenarios": len(receipts),
        "path": ".runtime/design-dossier.md",
        "proofLimit": "simulation only",
    }


def cleanup() -> dict[str, Any]:
    ensure_normal_user()
    ensure_runtime_owned()
    removed: list[str] = []
    if RECEIPTS.exists():
        for item in sorted(RECEIPTS.iterdir()):
            item.unlink()
            removed.append(f"receipts/{item.name}")
        RECEIPTS.rmdir()
    for name in ("design-dossier.md", "baseline.json", "descriptor.json"):
        path = RUNTIME / name
        if path.exists():
            path.unlink()
            removed.append(name)
    if any(RUNTIME.iterdir()):
        raise GuardError("runtime is not empty after allowlisted cleanup")
    RUNTIME.rmdir()
    return {"cleanup": "pass", "removed": removed, "runtime": "absent"}


def check() -> dict[str, Any]:
    ensure_normal_user()
    topology, workloads = load_inputs()
    baseline = build_baseline(topology, workloads)
    return {
        "check": "pass",
        "projectId": topology["id"],
        "racks": len(topology["racks"]),
        "controllers": len(topology["controllers"]),
        "computes": len(topology["computes"]),
        "gateways": len(topology["gateways"]),
        "osds": len(topology["storage"]["osds"]),
        "workloads": len(workloads["workloads"]),
        "allocations": len(baseline["allocations"]),
        "authority": "local-simulation-only",
    }


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Offline private-cloud reliability teaching simulator"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    for command in ("check", "initialize", "baseline", "dossier", "cleanup"):
        subparsers.add_parser(command)
    scenario_parser = subparsers.add_parser("scenario")
    scenario_parser.add_argument("name", choices=SCENARIOS)
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(sys.argv[1:] if argv is None else argv)
    try:
        if args.command == "check":
            result = check()
        elif args.command == "initialize":
            result = initialize()
        elif args.command == "baseline":
            result = run_baseline()
        elif args.command == "scenario":
            result = run_scenario(args.name)
        elif args.command == "dossier":
            result = build_dossier()
        elif args.command == "cleanup":
            result = cleanup()
        else:
            raise GuardError(f"unsupported command: {args.command}")
        print(canonical_json(result))
        return 0
    except (GuardError, DuplicateKeyError) as exc:
        print(canonical_json({"error": str(exc), "status": "refused"}), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
