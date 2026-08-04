#!/usr/bin/env python3
"""Fail-closed guards for the LES-0040 disposable localhost lab."""

from __future__ import annotations

import argparse
import json
import os
import re
import stat
import sys
from pathlib import Path

LESSON = "les0040"
UID = os.getuid() if hasattr(os, "getuid") else -1
CONTROLLER = Path(f"/tmp/reliability-atlas-{LESSON}-controller-{UID}")
MANAGED = Path(f"/tmp/reliability-atlas-{LESSON}-managed-{UID}")
SENTINEL = ".les0040-sentinel"

FIXTURE_FILES = {
    "ansible.cfg",
    "inventory.ini",
    "playbook.yml",
    "roles/managed_service/defaults/main.yml",
    "roles/managed_service/tasks/main.yml",
    "roles/managed_service/handlers/main.yml",
    "roles/managed_service/templates/service.conf.j2",
    "roles/managed_service/files/payload.txt",
}
OUTPUT_NAMES = {
    "inventory.out",
    "preflight.out",
    "check-initial.out",
    "apply-initial.out",
    "apply-steady.out",
    "check-drift.out",
    "repair.out",
}
EXPECTED_CONFIG = (
    "# Managed by LES-0040. Manual edits are controlled drift.\n"
    "name=atlas-api\n"
    "owner=reliability-team\n"
    "port=8080\n"
)
EXPECTED_PAYLOAD = "artifact=reliability-atlas-les0040\nrevision=1\n"
EXPECTED_MARKER = "configuration-reloaded\n"
DRIFT_CONFIG = "name=drifted-by-les0040\nport=1\n"


def fail(message: str) -> None:
    raise SystemExit(f"guard=fail reason={message}")


def assert_identity() -> None:
    if UID <= 0:
        fail("normal non-root POSIX user required")


def exact_root(raw: str, expected: Path, *, may_be_absent: bool = False) -> Path:
    path = Path(raw)
    if not path.is_absolute() or path != expected:
        fail(f"path must equal {expected}")
    if not path.exists():
        if may_be_absent:
            return path
        fail(f"required path absent: {path}")
    if path.is_symlink():
        fail(f"root is symlink: {path}")
    resolved = path.resolve(strict=True)
    if resolved != expected:
        fail(f"resolved path differs: {resolved}")
    if path.stat().st_uid != UID:
        fail(f"wrong owner for {path}")
    return path


def walk_regular(root: Path) -> set[str]:
    found: set[str] = set()
    for path in root.rglob("*"):
        rel = path.relative_to(root).as_posix()
        info = path.lstat()
        if stat.S_ISLNK(info.st_mode):
            fail(f"symlink forbidden: {rel}")
        if info.st_uid != UID:
            fail(f"wrong owner: {rel}")
        if path.is_file():
            if not stat.S_ISREG(info.st_mode):
                fail(f"non-regular file: {rel}")
            found.add(rel)
        elif not path.is_dir():
            fail(f"unsupported entry: {rel}")
    return found


def static_fixture(raw: str) -> None:
    root = Path(raw).resolve(strict=True)
    files = walk_regular(root)
    if files != FIXTURE_FILES:
        fail(f"fixture inventory mismatch: {sorted(files ^ FIXTURE_FILES)}")
    inventory = (root / "inventory.ini").read_text(encoding="utf-8")
    if inventory != (
        "[lab]\n"
        "les0040-local ansible_connection=local "
        "ansible_python_interpreter=/usr/bin/python3\n"
    ):
        fail("inventory must contain exactly one local host")
    sources = "\n".join(
        (root / name).read_text(encoding="utf-8")
        for name in sorted(FIXTURE_FILES)
        if name.endswith((".yml", ".ini", ".cfg", ".j2", ".txt"))
    )
    forbidden = {
        r"(?im)^\s*become\s*:\s*true\s*$": "privilege escalation",
        r"ansible\.builtin\.(?:shell|command|raw|uri|get_url)\s*:": "imperative or network module",
        r"(?i)https?://": "network URL",
        r"(?i)ansible_(?:host|user|ssh_|password)": "remote connection variable",
    }
    for pattern, label in forbidden.items():
        if re.search(pattern, sources):
            fail(f"forbidden {label}")
    modules = set(re.findall(r"(?m)^\s{2}ansible\.builtin\.([a-z_]+):\s*$", sources))
    allowed_modules = {"assert", "file", "template", "copy"}
    if modules != allowed_modules:
        fail(f"module allow-list mismatch: {sorted(modules)}")
    print(f"static=pass files={len(files)} modules={','.join(sorted(modules))}")


def validate_inventory(raw: str) -> None:
    data = json.loads(Path(raw).read_text(encoding="utf-8"))
    meta = data.get("_meta", {}).get("hostvars", {})
    hosts = sorted(name for name in meta if not name.startswith("_"))
    if hosts != ["les0040-local"]:
        fail(f"resolved hosts differ: {hosts}")
    values = meta["les0040-local"]
    if values.get("ansible_connection") != "local":
        fail("connection is not local")
    if values.get("ansible_python_interpreter") != "/usr/bin/python3":
        fail("interpreter differs")
    print("inventory=pass hosts=1 connection=local")


def validate_state(raw: str) -> None:
    root = exact_root(raw, MANAGED)
    files = walk_regular(root)
    expected = {SENTINEL, "service.conf", "payload.txt", "reload.marker"}
    if files != expected:
        fail(f"managed inventory mismatch: {sorted(files ^ expected)}")
    if stat.S_IMODE(root.stat().st_mode) != 0o700:
        fail("managed root mode is not 0700")
    values = {
        SENTINEL: f"{LESSON}:{UID}\n",
        "service.conf": EXPECTED_CONFIG,
        "payload.txt": EXPECTED_PAYLOAD,
        "reload.marker": EXPECTED_MARKER,
    }
    for name, expected_text in values.items():
        path = root / name
        if stat.S_IMODE(path.stat().st_mode) != 0o600:
            fail(f"{name} mode is not 0600")
        if path.read_text(encoding="utf-8") != expected_text:
            fail(f"{name} content differs")
    print("state=pass files=4 modes=pass content=pass")


def validate_empty(raw: str) -> None:
    root = exact_root(raw, MANAGED)
    files = walk_regular(root)
    if files != {SENTINEL}:
        fail(f"initial managed inventory differs: {sorted(files)}")
    sentinel = root / SENTINEL
    if stat.S_IMODE(sentinel.stat().st_mode) != 0o600:
        fail("managed sentinel mode is not 0600")
    if sentinel.read_text(encoding="utf-8") != f"{LESSON}:{UID}\n":
        fail("managed sentinel differs")
    print("managed_initial=pass files=1")


def validate_managed_known(raw: str) -> None:
    root = exact_root(raw, MANAGED)
    files = walk_regular(root)
    if files == {SENTINEL}:
        validate_empty(raw)
    elif files == {SENTINEL, "service.conf", "payload.txt", "reload.marker"}:
        validate_state(raw)
    else:
        fail(f"managed inventory is not an accepted state: {sorted(files)}")


def validate_controller(raw: str) -> None:
    controller = exact_root(raw, CONTROLLER)
    sentinel = controller / SENTINEL
    if sentinel.is_symlink() or sentinel.read_text(encoding="utf-8") != f"{LESSON}:{UID}\n":
        fail("controller sentinel differs")
    top = {entry.name for entry in controller.iterdir()}
    allowed = {"fixtures", SENTINEL} | OUTPUT_NAMES
    if not top <= allowed:
        fail(f"unexpected controller entries: {sorted(top - allowed)}")
    static_fixture(str(controller / "fixtures"))
    print("controller=pass")


def validate_drift(raw: str) -> None:
    root = exact_root(raw, MANAGED)
    path = root / "service.conf"
    if path.is_symlink() or path.read_text(encoding="utf-8") != DRIFT_CONFIG:
        fail("controlled drift is absent or differs")
    print("drift=present")


def validate_recap(raw: str, minimum: int, maximum: int) -> None:
    text = Path(raw).read_text(encoding="utf-8", errors="replace")
    ansi = re.compile(r"\x1b\[[0-9;]*m")
    text = ansi.sub("", text)
    pattern = re.compile(
        r"les0040-local\s*:\s*ok=(\d+)\s+changed=(\d+)\s+"
        r"unreachable=(\d+)\s+failed=(\d+)"
    )
    matches = pattern.findall(text)
    if not matches:
        fail("play recap not found")
    ok, changed, unreachable, failed = map(int, matches[-1])
    if unreachable != 0 or failed != 0:
        fail(f"recap failure unreachable={unreachable} failed={failed}")
    if not minimum <= changed <= maximum:
        fail(f"changed={changed} outside [{minimum},{maximum}]")
    print(f"recap=pass ok={ok} changed={changed} unreachable=0 failed=0")


def validate_cleanup(raw_controller: str, raw_managed: str) -> None:
    validate_controller(raw_controller)
    managed = exact_root(raw_managed, MANAGED, may_be_absent=True)
    if managed.exists():
        validate_managed_known(str(managed))
    print("cleanup_guard=pass")


def validate_absent(*raw_paths: str) -> None:
    for raw in raw_paths:
        path = Path(raw)
        if path not in {CONTROLLER, MANAGED}:
            fail(f"absence path not approved: {path}")
        if path.exists() or path.is_symlink():
            fail(f"path remains: {path}")
    print("state_absent=true")


def main() -> None:
    assert_identity()
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("static")
    p.add_argument("root")
    p = sub.add_parser("inventory")
    p.add_argument("json_file")
    p = sub.add_parser("state")
    p.add_argument("root")
    p = sub.add_parser("empty")
    p.add_argument("root")
    p = sub.add_parser("managed-known")
    p.add_argument("root")
    p = sub.add_parser("controller")
    p.add_argument("root")
    p = sub.add_parser("drift")
    p.add_argument("root")
    p = sub.add_parser("recap")
    p.add_argument("output")
    p.add_argument("minimum", type=int)
    p.add_argument("maximum", type=int)
    p = sub.add_parser("cleanup")
    p.add_argument("controller")
    p.add_argument("managed")
    p = sub.add_parser("absent")
    p.add_argument("paths", nargs="+")
    args = parser.parse_args()

    if args.command == "static":
        static_fixture(args.root)
    elif args.command == "inventory":
        validate_inventory(args.json_file)
    elif args.command == "state":
        validate_state(args.root)
    elif args.command == "empty":
        validate_empty(args.root)
    elif args.command == "managed-known":
        validate_managed_known(args.root)
    elif args.command == "controller":
        validate_controller(args.root)
    elif args.command == "drift":
        validate_drift(args.root)
    elif args.command == "recap":
        validate_recap(args.output, args.minimum, args.maximum)
    elif args.command == "cleanup":
        validate_cleanup(args.controller, args.managed)
    elif args.command == "absent":
        validate_absent(*args.paths)


if __name__ == "__main__":
    main()
