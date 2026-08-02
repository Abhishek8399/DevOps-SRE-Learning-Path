#!/usr/bin/env python3
"""Typed, offline build/test actions shared by both local teaching engines."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import sys
from pathlib import Path


def refuse_root() -> None:
    if os.geteuid() == 0:
        raise SystemExit("root-is-refused-run-as-a-normal-user")


def require_private_directory(path: Path) -> int:
    info = os.lstat(path)
    if not stat.S_ISDIR(info.st_mode) or stat.S_ISLNK(info.st_mode):
        raise ValueError("workspace-is-not-a-real-directory")
    if info.st_uid != os.geteuid():
        raise ValueError("workspace-owner-invalid")
    if stat.S_IMODE(info.st_mode) != 0o700:
        raise ValueError("workspace-mode-invalid")
    flags = os.O_RDONLY | os.O_DIRECTORY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags)
    opened = os.fstat(descriptor)
    if (opened.st_dev, opened.st_ino) != (info.st_dev, info.st_ino):
        os.close(descriptor)
        raise ValueError("workspace-identity-changed")
    return descriptor


def write_once(directory_fd: int, name: str, content: bytes) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(name, flags, 0o600, dir_fd=directory_fd)
    try:
        os.fchmod(descriptor, 0o600)
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written <= 0:
                raise OSError("short write")
            view = view[written:]
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def read_regular(directory_fd: int, name: str) -> bytes:
    flags = os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(name, flags, dir_fd=directory_fd)
    try:
        info = os.fstat(descriptor)
        if not stat.S_ISREG(info.st_mode):
            raise ValueError("artifact-is-not-regular")
        if info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) != 0o600:
            raise ValueError("artifact-owner-or-mode-invalid")
        if info.st_nlink != 1:
            raise ValueError("artifact-link-count-invalid")
        chunks: list[bytes] = []
        while True:
            chunk = os.read(descriptor, 65536)
            if not chunk:
                break
            chunks.append(chunk)
        return b"".join(chunks)
    finally:
        os.close(descriptor)


def digest(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def emit(payload: dict[str, object]) -> None:
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="offline typed portable CI job")
    subparsers = result.add_subparsers(dest="command", required=True)
    build = subparsers.add_parser("build")
    build.add_argument("--workspace", required=True)
    build.add_argument("--value", required=True)
    test = subparsers.add_parser("test")
    test.add_argument("--workspace", required=True)
    test.add_argument("--expected", required=True)
    return result


def main() -> None:
    refuse_root()
    args = parser().parse_args()
    workspace = Path(args.workspace)
    directory_fd = require_private_directory(workspace)
    try:
        if args.command == "build":
            content = args.value.encode("utf-8")
            write_once(directory_fd, "artifact.bin", content)
            emit(
                {
                    "action": "build",
                    "artifactSha256": digest(content),
                    "bytes": len(content),
                    "environmentKeys": sorted(os.environ),
                    "status": "passed",
                }
            )
        else:
            content = read_regular(directory_fd, "downloaded-output.bin")
            expected = args.expected.encode("utf-8")
            if content != expected:
                raise ValueError("downloaded-artifact-content-mismatch")
            emit(
                {
                    "action": "test",
                    "artifactSha256": digest(content),
                    "bytes": len(content),
                    "environmentKeys": sorted(os.environ),
                    "status": "passed",
                }
            )
    finally:
        os.close(directory_fd)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as error:
        print(f"portable-job-refused={error}", file=sys.stderr)
        raise SystemExit(65) from error
