#!/usr/bin/env python3
"""Deterministic Kubernetes-shaped control-loop model. This is not Kubernetes."""

from __future__ import annotations

import argparse
import json
import os
import stat
from pathlib import Path
from typing import Any

UID = os.getuid() if hasattr(os, "getuid") else -1
ROOT = Path(f"/tmp/reliability-atlas-les0041-model-{UID}")
SENTINEL = ".les0041-sentinel"
ALLOWED_FILES = {SENTINEL, "desired.json", "state.json"}
EXPECTED_FIXTURE = {
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "metadata": {"name": "atlas-api", "namespace": "atlas-model"},
    "spec": {"replicas": 2, "version": "v1"},
}


def fail(message: str) -> None:
    raise SystemExit(f"model=fail reason={message}")


def require_user() -> None:
    if UID <= 0:
        fail("normal non-root POSIX user required")


def exact_root(raw: str) -> Path:
    root = Path(raw)
    if root != ROOT or not root.is_absolute():
        fail(f"root must equal {ROOT}")
    if not root.is_dir() or root.is_symlink() or root.resolve(strict=True) != ROOT:
        fail("root absent, unresolved or symlinked")
    if root.stat().st_uid != UID:
        fail("root owner differs")
    for path in root.iterdir():
        info = path.lstat()
        if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
            fail(f"unsupported entry: {path.name}")
        if info.st_uid != UID:
            fail(f"wrong owner: {path.name}")
        if path.name not in ALLOWED_FILES:
            fail(f"unexpected entry: {path.name}")
    sentinel = root / SENTINEL
    if sentinel.read_text(encoding="utf-8") != f"les0041:{UID}\n":
        fail("sentinel differs")
    return root


def load_fixture(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if value != EXPECTED_FIXTURE:
        fail("fixture differs from exact approved input")
    return value


def load_state(root: Path) -> dict[str, Any]:
    path = root / "state.json"
    if not path.is_file() or path.is_symlink():
        fail("state file absent or unsafe")
    value = json.loads(path.read_text(encoding="utf-8"))
    validate(value)
    return value


def save_state(root: Path, state: dict[str, Any]) -> None:
    validate(state)
    target = root / "state.json"
    temporary = root / ".state.json.tmp"
    if temporary.exists() or temporary.is_symlink():
        fail("unexpected temporary state")
    text = json.dumps(state, indent=2, sort_keys=True) + "\n"
    temporary.write_text(text, encoding="utf-8")
    os.chmod(temporary, 0o600)
    os.replace(temporary, target)


def event(state: dict[str, Any], actor: str, action: str, key: str) -> None:
    state["resourceVersion"] += 1
    state["events"].append({
        "sequence": len(state["events"]) + 1,
        "resourceVersion": state["resourceVersion"],
        "actor": actor,
        "action": action,
        "key": key,
    })


def initial_state() -> dict[str, Any]:
    return {
        "modelVersion": 1,
        "runtime": "kubernetes-model-only",
        "phase": "EMPTY",
        "resourceVersion": 0,
        "controllerStalled": False,
        "queue": [],
        "deployment": None,
        "replicaSets": [],
        "pods": [],
        "events": [],
    }


def submit(state: dict[str, Any], desired: dict[str, Any]) -> None:
    if state["phase"] != "EMPTY":
        fail("submit requires EMPTY")
    state["deployment"] = {
        "name": desired["metadata"]["name"],
        "namespace": desired["metadata"]["namespace"],
        "uid": "dep-0001",
        "generation": 1,
        "observedGeneration": 0,
        "replicas": desired["spec"]["replicas"],
        "availableReplicas": 0,
        "version": desired["spec"]["version"],
    }
    state["queue"] = ["Deployment/atlas-api"]
    state["phase"] = "SUBMITTED"
    event(state, "api-server", "persist", "Deployment/atlas-api")


def reconcile_generation(state: dict[str, Any], generation: int, replicas: int) -> None:
    dep = state["deployment"]
    rs_uid = f"rs-{generation:04d}"
    state["replicaSets"].append({
        "name": f"atlas-api-g{generation}",
        "uid": rs_uid,
        "ownerUid": dep["uid"],
        "generation": generation,
        "replicas": replicas,
        "version": dep["version"],
    })
    for index in range(replicas):
        state["pods"].append({
            "name": f"atlas-api-g{generation}-{index}",
            "uid": f"pod-{generation:02d}-{index:02d}",
            "ownerUid": rs_uid,
            "generation": generation,
            "nodeName": None,
            "ready": False,
            "runtimeId": None,
        })
    dep["observedGeneration"] = generation
    state["queue"] = []
    event(state, "deployment-controller", "reconcile", f"ReplicaSet/atlas-api-g{generation}")


def reconcile(state: dict[str, Any]) -> None:
    if state["phase"] != "SUBMITTED" or state["controllerStalled"]:
        fail("reconcile requires non-stalled SUBMITTED")
    reconcile_generation(state, 1, 2)
    state["phase"] = "RECONCILED"


def schedule(state: dict[str, Any]) -> None:
    if state["phase"] != "RECONCILED":
        fail("schedule requires RECONCILED")
    nodes = ["node-a", "node-b"]
    for index, pod in enumerate(state["pods"]):
        if pod["nodeName"] is None:
            pod["nodeName"] = nodes[index % len(nodes)]
            event(state, "scheduler", "bind", f"Pod/{pod['name']}")
    state["phase"] = "SCHEDULED"


def run_kubelet(state: dict[str, Any]) -> None:
    if state["phase"] != "SCHEDULED":
        fail("kubelet requires SCHEDULED")
    for pod in state["pods"]:
        if not pod["ready"]:
            pod["runtimeId"] = f"containerd://{pod['uid']}"
            pod["ready"] = True
            event(state, f"kubelet/{pod['nodeName']}", "ready", f"Pod/{pod['name']}")
    state["deployment"]["availableReplicas"] = state["deployment"]["replicas"]
    event(state, "deployment-controller", "status", "Deployment/atlas-api")
    state["phase"] = "READY"


def update(state: dict[str, Any]) -> None:
    if state["phase"] != "READY":
        fail("update requires READY")
    dep = state["deployment"]
    dep["generation"] = 2
    dep["replicas"] = 3
    dep["version"] = "v2"
    state["queue"] = ["Deployment/atlas-api"]
    state["phase"] = "UPDATED"
    event(state, "client/atlas-lesson", "apply", "Deployment/atlas-api")


def inject_stall(state: dict[str, Any]) -> None:
    if state["phase"] != "UPDATED":
        fail("stall injection requires UPDATED")
    state["controllerStalled"] = True
    state["phase"] = "STALLED"
    event(state, "fault-injector", "pause-controller", "Deployment/atlas-api")


def recover(state: dict[str, Any]) -> None:
    if state["phase"] != "STALLED":
        fail("recovery requires STALLED")
    state["controllerStalled"] = False
    for rs in state["replicaSets"]:
        rs["replicas"] = 0
    old_pods = list(state["pods"])
    state["pods"] = []
    for pod in old_pods:
        event(state, "replicaset-controller", "delete", f"Pod/{pod['name']}")
    reconcile_generation(state, 2, 3)
    nodes = ["node-a", "node-b"]
    for index, pod in enumerate(state["pods"]):
        pod["nodeName"] = nodes[index % len(nodes)]
        event(state, "scheduler", "bind", f"Pod/{pod['name']}")
        pod["runtimeId"] = f"containerd://{pod['uid']}"
        pod["ready"] = True
        event(state, f"kubelet/{pod['nodeName']}", "ready", f"Pod/{pod['name']}")
    state["deployment"]["availableReplicas"] = 3
    event(state, "deployment-controller", "status", "Deployment/atlas-api")
    state["phase"] = "RECOVERED"


def validate(state: dict[str, Any]) -> None:
    required = {
        "modelVersion", "runtime", "phase", "resourceVersion", "controllerStalled",
        "queue", "deployment", "replicaSets", "pods", "events",
    }
    if set(state) != required or state["modelVersion"] != 1:
        fail("state schema differs")
    if state["runtime"] != "kubernetes-model-only":
        fail("runtime boundary differs")
    phases = {"EMPTY", "SUBMITTED", "RECONCILED", "SCHEDULED", "READY", "UPDATED", "STALLED", "RECOVERED"}
    if state["phase"] not in phases:
        fail("unknown phase")
    events = state["events"]
    if [item["sequence"] for item in events] != list(range(1, len(events) + 1)):
        fail("event sequence differs")
    if [item["resourceVersion"] for item in events] != list(range(1, len(events) + 1)):
        fail("resourceVersion is not monotonic")
    if state["resourceVersion"] != len(events):
        fail("current resourceVersion differs")
    if state["phase"] == "EMPTY":
        if state["deployment"] is not None or state["replicaSets"] or state["pods"]:
            fail("EMPTY contains objects")
        return
    dep = state["deployment"]
    if dep["uid"] != "dep-0001" or dep["generation"] not in {1, 2}:
        fail("Deployment identity differs")
    rs_uids = {item["uid"] for item in state["replicaSets"]}
    if len(rs_uids) != len(state["replicaSets"]):
        fail("duplicate ReplicaSet UID")
    if any(item["ownerUid"] != dep["uid"] for item in state["replicaSets"]):
        fail("ReplicaSet owner differs")
    pod_uids = {item["uid"] for item in state["pods"]}
    if len(pod_uids) != len(state["pods"]):
        fail("duplicate Pod UID")
    if any(item["ownerUid"] not in rs_uids for item in state["pods"]):
        fail("Pod owner differs")
    if state["phase"] == "STALLED":
        if dep["generation"] != 2 or dep["observedGeneration"] != 1:
            fail("stalled generation evidence differs")
        if state["queue"] != ["Deployment/atlas-api"] or not state["controllerStalled"]:
            fail("stalled controller evidence differs")
    if state["phase"] in {"READY", "UPDATED", "STALLED"} and dep["uid"] != "dep-0001":
        fail("Deployment UID continuity failed")
    if state["phase"] == "RECOVERED":
        if dep["generation"] != 2 or dep["observedGeneration"] != 2 or dep["availableReplicas"] != 3:
            fail("recovered Deployment differs")
        if len(state["pods"]) != 3 or not all(p["ready"] for p in state["pods"]):
            fail("recovered Pods differ")


def main() -> None:
    require_user()
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=[
        "initialize", "submit", "reconcile", "schedule", "kubelet", "update",
        "inject-stall", "recover", "inspect", "diagnose", "verify",
    ])
    parser.add_argument("root")
    parser.add_argument("--phase")
    args = parser.parse_args()
    root = exact_root(args.root)
    desired = load_fixture(root / "desired.json")

    if args.command == "initialize":
        if (root / "state.json").exists():
            fail("state already exists")
        state = initial_state()
        save_state(root, state)
    else:
        state = load_state(root)
        if args.command == "submit":
            submit(state, desired)
        elif args.command == "reconcile":
            reconcile(state)
        elif args.command == "schedule":
            schedule(state)
        elif args.command == "kubelet":
            run_kubelet(state)
        elif args.command == "update":
            update(state)
        elif args.command == "inject-stall":
            inject_stall(state)
        elif args.command == "recover":
            recover(state)
        elif args.command == "diagnose":
            if state["phase"] != "STALLED":
                fail("diagnosis requires STALLED")
            dep = state["deployment"]
            print(
                f"diagnosis=controller-stalled generation={dep['generation']} "
                f"observedGeneration={dep['observedGeneration']} queue={len(state['queue'])}"
            )
        if args.command in {"submit", "reconcile", "schedule", "kubelet", "update", "inject-stall", "recover"}:
            save_state(root, state)
    if args.phase and state["phase"] != args.phase:
        fail(f"expected phase {args.phase}, got {state['phase']}")
    if args.command in {"inspect", "verify"}:
        print(json.dumps(state, indent=2, sort_keys=True))
    print(
        f"model=pass phase={state['phase']} rv={state['resourceVersion']} "
        f"events={len(state['events'])} runtime=kubernetes-model-only"
    )


if __name__ == "__main__":
    main()
