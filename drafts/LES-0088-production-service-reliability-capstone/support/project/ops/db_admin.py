#!/usr/bin/env python3
"""Guarded SQLite backup, verification, and restore utility."""

from __future__ import annotations

import argparse
from contextlib import closing
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sqlite3
import sys
import tempfile


def fail(message: str) -> "NoReturn":
    raise SystemExit(f"db-admin: refusal: {message}")


def regular_resolved(path: Path, *, must_exist: bool) -> Path:
    if path.is_symlink():
        fail(f"symlink path is not allowed: {path}")
    resolved = path.resolve()
    if must_exist and (not resolved.is_file() or resolved.is_symlink()):
        fail(f"regular file is required: {resolved}")
    return resolved


def within(path: Path, boundary: Path) -> bool:
    try:
        path.relative_to(boundary)
        return True
    except ValueError:
        return False


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def inspect_database(path: Path) -> dict[str, object]:
    try:
        with closing(sqlite3.connect(f"file:{path}?mode=ro", uri=True)) as connection:
            integrity = connection.execute("PRAGMA integrity_check").fetchone()
            schema = connection.execute(
                "SELECT schema_version FROM schema_metadata WHERE singleton = 1"
            ).fetchone()
            count = connection.execute("SELECT COUNT(*) FROM items").fetchone()
    except sqlite3.Error as exc:
        fail(f"database inspection failed for {path}: {exc}")
    if integrity is None or integrity[0] != "ok":
        fail(f"integrity_check did not return ok for {path}")
    if schema is None or schema[0] != 1:
        fail(f"schema version is not 1 for {path}")
    return {"integrity": "ok", "schema_version": 1, "item_count": int(count[0])}


def read_manifest(path: Path) -> dict[str, object]:
    resolved = regular_resolved(path, must_exist=True)
    try:
        value = json.loads(resolved.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"manifest is unreadable JSON: {exc}")
    required = {"schema", "database_sha256", "database_bytes", "item_count", "created_at"}
    if not isinstance(value, dict) or set(value) != required or value["schema"] != 1:
        fail("manifest shape or schema is invalid")
    return value


def verify_pair(database: Path, manifest_path: Path) -> dict[str, object]:
    database = regular_resolved(database, must_exist=True)
    manifest = read_manifest(manifest_path)
    actual_hash = sha256(database)
    actual_size = database.stat().st_size
    details = inspect_database(database)
    if manifest["database_sha256"] != actual_hash:
        fail("backup hash differs from manifest")
    if manifest["database_bytes"] != actual_size:
        fail("backup size differs from manifest")
    if manifest["item_count"] != details["item_count"]:
        fail("backup item count differs from manifest")
    return {**details, "sha256": actual_hash, "bytes": actual_size}


def backup(args: argparse.Namespace) -> None:
    source = regular_resolved(args.database, must_exist=True)
    boundary = args.boundary.resolve()
    output = regular_resolved(args.output, must_exist=False)
    manifest_path = Path(f"{output}.manifest.json")
    if not within(source, boundary) or not within(output, boundary):
        fail("source and output must remain inside --boundary")
    if output.exists() or manifest_path.exists():
        fail("backup output and manifest must not already exist")
    output.parent.mkdir(parents=True, exist_ok=True)
    try:
        with closing(sqlite3.connect(f"file:{source}?mode=ro", uri=True)) as source_db:
            with closing(sqlite3.connect(output)) as target_db:
                source_db.backup(target_db)
        details = inspect_database(output)
        manifest = {
            "schema": 1,
            "database_sha256": sha256(output),
            "database_bytes": output.stat().st_size,
            "item_count": details["item_count"],
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        manifest_path.write_text(
            json.dumps(manifest, sort_keys=True, separators=(",", ":")) + chr(10),
            encoding="utf-8",
        )
        verify_pair(output, manifest_path)
    except BaseException:
        output.unlink(missing_ok=True)
        manifest_path.unlink(missing_ok=True)
        raise
    print(f"backup=pass items={details['item_count']} sha256={manifest['database_sha256']}")


def verify(args: argparse.Namespace) -> None:
    details = verify_pair(args.database, args.manifest)
    print(
        f"backup_verify=pass items={details['item_count']} "
        f"bytes={details['bytes']} sha256={details['sha256']}"
    )


def restore(args: argparse.Namespace) -> None:
    backup_path = regular_resolved(args.database, must_exist=True)
    boundary = args.boundary.resolve()
    target = regular_resolved(args.target, must_exist=False)
    if not within(backup_path, boundary) or not within(target, boundary):
        fail("backup and target must remain inside --boundary")
    if target.exists() or target.is_symlink():
        fail("restore target must not already exist")
    source_details = verify_pair(backup_path, args.manifest)
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, stage_name = tempfile.mkstemp(
        prefix=f".{target.name}.restore-", dir=target.parent
    )
    os.close(descriptor)
    stage = Path(stage_name)
    stage.unlink()
    try:
        with closing(sqlite3.connect(f"file:{backup_path}?mode=ro", uri=True)) as source_db:
            with closing(sqlite3.connect(stage)) as target_db:
                source_db.backup(target_db)
        restored = inspect_database(stage)
        if restored["item_count"] != source_details["item_count"]:
            fail("restored item count differs from verified backup")
        os.replace(stage, target)
    except BaseException:
        stage.unlink(missing_ok=True)
        target.unlink(missing_ok=True)
        raise
    print(f"restore=pass items={source_details['item_count']} target={target}")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    subcommands = result.add_subparsers(dest="command", required=True)
    create = subcommands.add_parser("backup")
    create.add_argument("--database", type=Path, required=True)
    create.add_argument("--output", type=Path, required=True)
    create.add_argument("--boundary", type=Path, required=True)
    create.set_defaults(function=backup)
    check = subcommands.add_parser("verify")
    check.add_argument("--database", type=Path, required=True)
    check.add_argument("--manifest", type=Path, required=True)
    check.set_defaults(function=verify)
    recover = subcommands.add_parser("restore")
    recover.add_argument("--database", type=Path, required=True)
    recover.add_argument("--manifest", type=Path, required=True)
    recover.add_argument("--target", type=Path, required=True)
    recover.add_argument("--boundary", type=Path, required=True)
    recover.set_defaults(function=restore)
    return result


def main() -> None:
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        fail("run as a normal user, not root")
    args = parser().parse_args()
    args.function(args)


if __name__ == "__main__":
    main()
