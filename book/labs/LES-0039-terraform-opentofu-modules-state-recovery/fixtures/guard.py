#!/usr/bin/env python3
"""Fail-closed fixture, state, plan, and cleanup checks for LES-0039."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import stat
import sys
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0039"
CLI_NAMES = {"terraform", "tofu"}
V1_ADDRESSES = {"terraform_data.api", "terraform_data.worker"}
V2_ADDRESSES = {
    'module.service.terraform_data.component["api"]',
    'module.service.terraform_data.component["worker"]',
}
MOVE_MAP = {
    "terraform_data.api": 'module.service.terraform_data.component["api"]',
    "terraform_data.worker": 'module.service.terraform_data.component["worker"]',
}
FIXTURE_FILES = {"v1/main.tf", "v2/main.tf", "v2/modules/service/main.tf"}
BASE_FILES = {"SENTINEL", "manifest.json", "cli.json", "cli.tfrc", "stage.txt", "main.tf"}
RUNTIME_FILES = {
    "terraform.tfstate", "terraform.tfstate.backup", "protected.tfstate",
    "protected.sha256", "v1.tfplan", "v1-plan.json", "refactor.tfplan",
    "refactor-plan.json", "state-view.json", "corrupt-output.txt",
    "v1-state.json",
    ".state-view.json.tmp", ".v1-state.json.tmp", ".v1-plan.json.tmp", ".refactor-plan.json.tmp",
    ".corrupt-output.tmp", ".terraform.tfstate.restore",
}
ALLOWED_DIRS = {"mirror", ".terraform", ".terraform/modules", "modules", "modules/service"}
ALLOWED_NESTED_FILES = {".terraform/modules/modules.json", "modules/service/main.tf"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def load_json(path: Path) -> dict[str, Any]:
    require(path.is_file() and not path.is_symlink(), f"not a regular JSON file: {path}")
    value = json.loads(path.read_text(encoding="utf-8-sig"))
    require(isinstance(value, dict), f"JSON root must be an object: {path}")
    return value


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_cli(path_text: str, name: str, digest: str) -> Path:
    require(name in CLI_NAMES, "CLI name must be terraform or tofu")
    path = Path(path_text)
    require(path.is_absolute(), "CLI path must be absolute")
    require(path.is_file() and not path.is_symlink(), "CLI must be a non-symlink file")
    require(path.name in {name, f"{name}.exe"}, "CLI basename does not match product")
    require(re.fullmatch(r"[0-9a-f]{64}", digest) is not None, "CLI digest invalid")
    require(sha256(path) == digest, "CLI digest changed")
    return path


def validate_fixtures(root: Path) -> None:
    require(root.is_dir() and not root.is_symlink(), "fixture root invalid")
    actual: set[str] = set()
    allowed_dirs = {"v1", "v2", "v2/modules", "v2/modules/service"}
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        require(not path.is_symlink(), f"fixture symlink refused: {relative}")
        if path.is_file():
            require(relative in FIXTURE_FILES or relative == "guard.py", f"unexpected fixture: {relative}")
            if relative != "guard.py":
                actual.add(relative)
        elif path.is_dir():
            require(relative in allowed_dirs, f"unexpected fixture directory: {relative}")
        else:
            raise ValueError(f"unsupported fixture type: {relative}")
    require(actual == FIXTURE_FILES, f"fixture inventory mismatch: {sorted(actual)}")
    v1 = (root / "v1/main.tf").read_text(encoding="utf-8")
    v2 = (root / "v2/main.tf").read_text(encoding="utf-8")
    child = (root / "v2/modules/service/main.tf").read_text(encoding="utf-8")
    require("terraform_data" in v1 and "api" in v1 and "worker" in v1, "v1 resources missing")
    require("module" in v2 and "service" in v2 and v2.count("moved {") == 2, "v2 module/moves invalid")
    require("terraform_data" in child and "component" in child and "for_each" in child, "v2 child invalid")
    combined = "\n".join((v1, v2, child)).lower()
    for refused in ("required_providers", "provisioner", "local-exec", "remote-exec", "import {", "removed {"):
        require(refused not in combined, f"refused fixture construct: {refused}")
    print(f"valid=true lesson={LESSON_ID} fixtures={len(FIXTURE_FILES)}")


def validate_state_root(root: Path, uid: int) -> dict[str, Any]:
    expected = Path(f"/tmp/reliability-atlas-les0039-{uid}")
    require(root == expected, "state path text is not exact")
    require(root.exists() and root.is_dir() and not root.is_symlink(), "state root invalid")
    require(root.resolve() == expected, "state real path is not exact")
    require(root.stat().st_uid == uid, "state root owner mismatch")
    sentinel = (root / "SENTINEL").read_text(encoding="utf-8")
    require(sentinel == f"{LESSON_ID}:{uid}\n", "sentinel mismatch")
    stage = (root / "stage.txt").read_text(encoding="utf-8").strip()
    require(stage in {"v1", "v2"}, "stage invalid")
    allowed_files = BASE_FILES | RUNTIME_FILES | ALLOWED_NESTED_FILES
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        mode = path.lstat().st_mode
        require(not stat.S_ISLNK(mode), f"symlink refused: {relative}")
        require(path.stat().st_uid == uid, f"owner mismatch: {relative}")
        if stat.S_ISREG(mode):
            require(relative in allowed_files, f"unexpected file: {relative}")
        elif stat.S_ISDIR(mode):
            require(relative in ALLOWED_DIRS, f"unexpected directory: {relative}")
        else:
            raise ValueError(f"unsupported entry type: {relative}")
    for relative in BASE_FILES:
        path = root / relative
        require(path.is_file() and not path.is_symlink(), f"required file missing: {relative}")
    require((root / "mirror").is_dir() and not (root / "mirror").is_symlink(), "mirror invalid")
    require(not (root / ".terraform.lock.hcl").exists(), "external provider lock file refused")
    require(not (root / ".terraform.tfstate.lock.info").exists(), "persistent state lock refused")
    main = (root / "main.tf").read_text(encoding="utf-8")
    if stage == "v1":
        require("terraform_data" in main and "api" in main and not (root / "modules").exists(), "v1 content invalid")
    else:
        require("module" in main and "service" in main and main.count("moved {") == 2, "v2 content invalid")
        require((root / "modules/service/main.tf").is_file(), "v2 child missing")
    manifest = load_json(root / "manifest.json")
    expected_manifest = {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(root)}
    require(manifest == expected_manifest, "manifest mismatch")
    cli = load_json(root / "cli.json")
    require(set(cli) == {"name", "path", "version", "sha256"}, "CLI manifest keys mismatch")
    validate_cli(str(cli["path"]), str(cli["name"]), str(cli["sha256"]))
    version = cli["version"]
    expected_prefix = "Terraform v" if cli["name"] == "terraform" else "OpenTofu v"
    require(isinstance(version, str) and version.startswith(expected_prefix), "CLI product/version mismatch")
    return cli


def state_addresses(snapshot: dict[str, Any]) -> tuple[set[str], dict[str, str]]:
    addresses: set[str] = set()
    ids: dict[str, str] = {}
    resources = snapshot.get("resources", [])
    require(isinstance(resources, list), "state resources missing")
    for resource in resources:
        require(isinstance(resource, dict), "state resource invalid")
        require(resource.get("mode") == "managed", "unexpected resource mode")
        require(resource.get("type") == "terraform_data", "unexpected resource type")
        module = resource.get("module")
        name = resource.get("name")
        instances = resource.get("instances")
        require(isinstance(name, str) and isinstance(instances, list), "state resource fields invalid")
        for instance in instances:
            require(isinstance(instance, dict), "state instance invalid")
            base = f"terraform_data.{name}"
            key = instance.get("index_key")
            if key is not None:
                require(isinstance(key, str), "only string instance keys allowed")
                base += f"[{json.dumps(key)}]"
            address = f"{module}.{base}" if isinstance(module, str) else base
            attributes = instance.get("attributes")
            require(isinstance(attributes, dict), f"attributes missing: {address}")
            object_id = attributes.get("id")
            require(isinstance(object_id, str) and object_id, f"ID missing: {address}")
            require(address not in addresses, f"duplicate address: {address}")
            addresses.add(address)
            ids[address] = object_id
    return addresses, ids


def inspect_state(path: Path, expected_stage: str) -> dict[str, Any]:
    snapshot = load_json(path)
    lineage = snapshot.get("lineage")
    serial = snapshot.get("serial")
    require(isinstance(lineage, str) and lineage, "lineage missing")
    require(isinstance(serial, int) and serial >= 1, "serial invalid")
    addresses, ids = state_addresses(snapshot)
    expected = V1_ADDRESSES if expected_stage == "v1" else V2_ADDRESSES
    require(addresses == expected, f"state addresses mismatch: {sorted(addresses)}")
    require(len(set(ids.values())) == 2, "object IDs must be unique")
    return {"lineage": lineage, "serial": serial, "digest": sha256(path), "addresses": sorted(addresses), "ids": ids}


def inspect_v1_plan(path: Path) -> dict[str, Any]:
    plan = load_json(path)
    changes = plan.get("resource_changes")
    require(isinstance(changes, list), "resource_changes missing")
    addresses: set[str] = set()
    for item in changes:
        require(isinstance(item, dict), "resource change invalid")
        address = item.get("address")
        change = item.get("change")
        require(isinstance(change, dict), "change body missing")
        require(isinstance(address, str) and change.get("actions") == ["create"], f"v1 action invalid: {address}")
        addresses.add(address)
    require(addresses == V1_ADDRESSES, f"v1 addresses mismatch: {sorted(addresses)}")
    return {"creates": 2, "addresses": sorted(addresses)}


def inspect_refactor_plan(path: Path) -> dict[str, Any]:
    plan = load_json(path)
    changes = plan.get("resource_changes")
    require(isinstance(changes, list), "resource_changes missing")
    observed: dict[str, str] = {}
    for item in changes:
        require(isinstance(item, dict), "resource change invalid")
        address = item.get("address")
        previous = item.get("previous_address")
        change = item.get("change")
        require(isinstance(change, dict), "change body missing")
        require(isinstance(address, str) and isinstance(previous, str), "move addresses missing")
        require(change.get("actions") == ["no-op"], f"non-move action refused: {address}")
        observed[previous] = address
    require(observed == MOVE_MAP, f"move map mismatch: {observed}")
    return {"moves": len(observed), "creates": 0, "updates": 0, "deletes": 0}


def compare_states(before_path: Path, after_path: Path) -> dict[str, Any]:
    before = inspect_state(before_path, "v1")
    after = inspect_state(after_path, "v2")
    require(before["lineage"] == after["lineage"], "state lineage changed during refactor")
    require(after["serial"] > before["serial"], "state serial did not advance")
    for old_address, new_address in MOVE_MAP.items():
        require(before["ids"][old_address] == after["ids"][new_address],
                f"object ID changed during move: {old_address} -> {new_address}")
    return {
        "lineage": after["lineage"],
        "beforeSerial": before["serial"],
        "afterSerial": after["serial"],
        "preserved": len(MOVE_MAP),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    fixture_cmd = commands.add_parser("validate-fixtures")
    fixture_cmd.add_argument("root", type=Path)
    state_cmd = commands.add_parser("validate-state-root")
    state_cmd.add_argument("root", type=Path)
    state_cmd.add_argument("--uid", required=True, type=int)
    cli_cmd = commands.add_parser("cli-info")
    cli_cmd.add_argument("root", type=Path)
    cli_cmd.add_argument("--uid", required=True, type=int)
    inspect_cmd = commands.add_parser("inspect-state")
    inspect_cmd.add_argument("path", type=Path)
    inspect_cmd.add_argument("--stage", required=True, choices=("v1", "v2"))
    v1_cmd = commands.add_parser("inspect-v1-plan")
    v1_cmd.add_argument("path", type=Path)
    refactor_cmd = commands.add_parser("inspect-refactor-plan")
    refactor_cmd.add_argument("path", type=Path)
    compare_cmd = commands.add_parser("compare-states")
    compare_cmd.add_argument("before", type=Path)
    compare_cmd.add_argument("after", type=Path)
    args = parser.parse_args()
    if args.command == "validate-fixtures":
        validate_fixtures(args.root)
    elif args.command == "validate-state-root":
        cli = validate_state_root(args.root, args.uid)
        print(f"valid=true state={args.root} cli={cli['name']} version={cli['version']}")
    elif args.command == "cli-info":
        cli = validate_state_root(args.root, args.uid)
        print(cli["name"])
        print(cli["path"])
        print(cli["version"])
        print(cli["sha256"])
    elif args.command == "inspect-state":
        value = inspect_state(args.path, args.stage)
        print(f"valid=true stage={args.stage} lineage={value['lineage']} serial={value['serial']} digest={value['digest']} addresses={','.join(value['addresses'])}")
    elif args.command == "inspect-v1-plan":
        value = inspect_v1_plan(args.path)
        print(f"valid=true creates={value['creates']} addresses={','.join(value['addresses'])}")
    elif args.command == "inspect-refactor-plan":
        value = inspect_refactor_plan(args.path)
        print(f"valid=true moves={value['moves']} creates=0 updates=0 deletes=0")
    else:
        value = compare_states(args.before, args.after)
        print(f"valid=true preserved={value['preserved']} lineage={value['lineage']} before_serial={value['beforeSerial']} after_serial={value['afterSerial']}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
        print(f"guard_error={type(exc).__name__} detail={exc}", file=sys.stderr)
        raise SystemExit(65)
