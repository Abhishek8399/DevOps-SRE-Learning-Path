#!/usr/bin/env python3
"""Fail-closed state and plan checks for the provider-free LES-0038 lab."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import stat
import sys
from pathlib import Path
from typing import Any

LESSON_ID = "LES-0038"
ALLOWED_CLI_NAMES = {"terraform", "tofu"}
REQUIRED_FIXTURES = {
    "main.tf",
    "valid.tfvars",
    "invalid.tfvars",
    "tests/language.tftest.hcl",
}
ALLOWED_FILES = REQUIRED_FIXTURES | {
    "SENTINEL",
    "manifest.json",
    "cli.json",
    "cli.tfrc",
    "review.tfplan",
    "review.json",
    "graph.dot",
    "invalid-output.txt",
}
ALLOWED_DIRS = {"tests", "mirror", ".terraform"}
EXPECTED_ADDRESSES = {
    "terraform_data.catalog",
    'terraform_data.service["api"]',
    'terraform_data.service["worker"]',
}


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
    require(name in ALLOWED_CLI_NAMES, "CLI name must be terraform or tofu")
    path = Path(path_text)
    require(path.is_absolute(), "CLI path must be absolute")
    require(path.is_file() and not path.is_symlink(), "CLI must be a non-symlink regular file")
    require(path.name in {name, f"{name}.exe"}, "CLI basename does not match product")
    require(re.fullmatch(r"[0-9a-f]{64}", digest) is not None, "CLI digest is invalid")
    require(sha256(path) == digest, "CLI digest changed")
    return path


def validate_fixtures(root: Path) -> None:
    require(root.is_dir() and not root.is_symlink(), "fixture root must be a real directory")
    actual: set[str] = set()
    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        require(not path.is_symlink(), f"fixture symlink refused: {relative}")
        if path.is_file():
            actual.add(relative)
            require(relative in REQUIRED_FIXTURES or relative == "guard.py", f"unexpected fixture: {relative}")
        elif path.is_dir():
            require(relative == "tests", f"unexpected fixture directory: {relative}")
        else:
            raise ValueError(f"unsupported fixture type: {relative}")
    require(REQUIRED_FIXTURES <= actual, "required fixture missing")
    main = (root / "main.tf").read_text(encoding="utf-8")
    tests = (root / "tests/language.tftest.hcl").read_text(encoding="utf-8")
    require('resource "terraform_data" "service"' in main, "built-in service resource missing")
    require('resource "terraform_data" "catalog"' in main, "built-in catalog resource missing")
    require("command = plan" in tests, "tests must remain plan-only")
    combined = "\n".join((main, tests)).lower()
    require("command = apply" not in combined, "apply-mode test refused")
    require("required_providers" not in combined, "external provider declaration refused")
    print(f"valid=true lesson={LESSON_ID} fixtures={len(REQUIRED_FIXTURES)}")


def validate_state(root: Path, uid: int) -> dict[str, Any]:
    expected = Path(f"/tmp/reliability-atlas-les0038-{uid}")
    require(root == expected, "state path text is not exact")
    require(root.exists() and root.is_dir() and not root.is_symlink(), "state root invalid")
    require(root.resolve() == expected, "state real path is not exact")
    require(root.stat().st_uid == uid, "state root owner mismatch")
    require((root / "SENTINEL").read_text(encoding="utf-8") == f"{LESSON_ID}:{uid}\n", "sentinel mismatch")

    for path in root.rglob("*"):
        relative = path.relative_to(root).as_posix()
        mode = path.lstat().st_mode
        require(not stat.S_ISLNK(mode), f"symlink refused: {relative}")
        require(path.stat().st_uid == uid, f"owner mismatch: {relative}")
        if stat.S_ISREG(mode):
            require(relative in ALLOWED_FILES, f"unexpected file: {relative}")
        elif stat.S_ISDIR(mode):
            require(relative in ALLOWED_DIRS, f"unexpected directory: {relative}")
        else:
            raise ValueError(f"unsupported entry type: {relative}")

    for relative in REQUIRED_FIXTURES | {"SENTINEL", "manifest.json", "cli.json", "cli.tfrc"}:
        path = root / relative
        require(path.is_file() and not path.is_symlink(), f"required state file missing: {relative}")
    for directory in ("tests", "mirror"):
        path = root / directory
        require(path.is_dir() and not path.is_symlink(), f"required state directory missing: {directory}")
    terraform_dir = root / ".terraform"
    if terraform_dir.exists():
        require(terraform_dir.is_dir() and not terraform_dir.is_symlink(), ".terraform type invalid")
        require(not any(terraform_dir.iterdir()), ".terraform must remain empty for built-in provider fixture")
    require(not (root / ".terraform.lock.hcl").exists(), "unexpected provider lock file")
    require(not (root / "terraform.tfstate").exists(), "state file proves apply boundary was crossed")

    manifest = load_json(root / "manifest.json")
    require(manifest == {"schemaVersion": 1, "lessonId": LESSON_ID, "uid": uid, "statePath": str(root)}, "manifest mismatch")
    cli = load_json(root / "cli.json")
    require(set(cli) == {"name", "path", "version", "sha256"}, "CLI manifest keys mismatch")
    validate_cli(str(cli["path"]), str(cli["name"]), str(cli["sha256"]))
    require(isinstance(cli["version"], str) and cli["version"].startswith(("Terraform v", "OpenTofu v")), "CLI version invalid")
    return cli


def validate_plan(path: Path) -> dict[str, Any]:
    plan = load_json(path)
    changes = plan.get("resource_changes")
    require(isinstance(changes, list), "resource_changes missing")
    addresses: set[str] = set()
    for item in changes:
        require(isinstance(item, dict), "resource change must be an object")
        address = item.get("address")
        actions = item.get("change", {}).get("actions")
        require(isinstance(address, str), "resource address missing")
        require(actions == ["create"], f"non-create action refused at {address}")
        addresses.add(address)
    require(addresses == EXPECTED_ADDRESSES, f"address set mismatch: {sorted(addresses)}")
    output = plan.get("output_changes", {}).get("service_summary", {})
    require(output.get("after_unknown") is not False, "computed output should remain unknown")
    return {"changes": len(changes), "creates": len(changes), "addresses": sorted(addresses)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    fixtures = commands.add_parser("validate-fixtures")
    fixtures.add_argument("root", type=Path)
    state = commands.add_parser("validate-state")
    state.add_argument("root", type=Path)
    state.add_argument("--uid", required=True, type=int)
    cli = commands.add_parser("cli-info")
    cli.add_argument("root", type=Path)
    cli.add_argument("--uid", required=True, type=int)
    plan = commands.add_parser("validate-plan")
    plan.add_argument("path", type=Path)
    args = parser.parse_args()
    if args.command == "validate-fixtures":
        validate_fixtures(args.root)
    elif args.command == "validate-state":
        value = validate_state(args.root, args.uid)
        print(f"valid=true state={args.root} cli={value['name']} version={value['version']}")
    elif args.command == "cli-info":
        value = validate_state(args.root, args.uid)
        print(value["name"])
        print(value["path"])
        print(value["version"])
        print(value["sha256"])
    else:
        value = validate_plan(args.path)
        print(" ".join(("valid=true", f"changes={value['changes']}", f"creates={value['creates']}", "addresses=" + ",".join(value["addresses"]))))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
        print(f"guard_error={type(exc).__name__} detail={exc}", file=sys.stderr)
        raise SystemExit(65)
