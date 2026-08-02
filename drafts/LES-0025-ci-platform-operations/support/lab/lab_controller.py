#!/usr/bin/env python3
"""Guarded lifecycle for the offline LES-0025 dual-engine CI lab."""

from __future__ import annotations

import argparse
import contextlib
import ctypes
import fcntl
import hashlib
import json
import os
import re
import secrets
import stat
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Iterator


LESSON = "LES-0025"
SCHEMA_VERSION = 1
CURRENT_UID = os.geteuid()
BASE = Path(__file__).resolve().parent
STATE_PATH = Path(f"/tmp/reliability-atlas-{LESSON}-{CURRENT_UID}.state.d")
ROOT_PREFIX_NAME = f"reliability-atlas-{LESSON}-{CURRENT_UID}."
ROOT_PATTERN = re.compile(
    rf"^/tmp/{re.escape(ROOT_PREFIX_NAME)}[A-Za-z0-9_-]+$"
)

EX_USAGE = 64
EX_DATAERR = 65
EX_UNAVAILABLE = 69
EX_CANTCREAT = 73
EX_TEMPFAIL = 75
EX_NOPERM = 77

SOURCE_PATHS = (
    "engines/engine_runtime.py",
    "engines/graph_engine.py",
    "engines/stage_engine.py",
    "jobs/portable_job.py",
    "lab.sh",
    "lab_controller.py",
    "pipelines/expected-contract.json",
    "pipelines/graph.json",
    "pipelines/stage-broken.json",
    "pipelines/stage-fixed.json",
)

ROOT_RECORDS = (
    "graph.record.json",
    "stage-broken.record.json",
    "comparison.record.json",
    "stage-fixed.record.json",
    "verification.record.json",
)
ROOT_CHILDREN = {".sentinel", "runs", *ROOT_RECORDS}
WORKSPACES = ("graph", "stage-broken", "stage-fixed")
WORKSPACE_LAYOUT = {
    "build": {"artifact.bin"},
    "artifact-store": {"build-output.bin"},
    "test": {"downloaded-output.bin"},
}

REPORT_KEYS = {
    "artifactHandoff",
    "artifactSha256",
    "concurrency",
    "configSha256",
    "credentialInputsObserved",
    "dependencyEdges",
    "engine",
    "engineEnvironmentKeys",
    "externalEffects",
    "jobOrder",
    "jobEnvironmentKeys",
    "networkTargets",
    "permissions",
    "pipelineIdentity",
    "schemaVersion",
    "secretInputs",
    "sourceIdentity",
    "status",
    "timeoutSeconds",
}


class LabRefusal(Exception):
    def __init__(self, token: str, status: int = EX_DATAERR) -> None:
        super().__init__(token)
        self.token = token
        self.status = status


def refuse(token: str, status: int = EX_DATAERR) -> None:
    raise LabRefusal(token, status)


def bool_text(value: bool) -> str:
    return "true" if value else "false"


def emit(pairs: list[tuple[str, object]]) -> None:
    for key, value in pairs:
        if isinstance(value, bool):
            rendered = bool_text(value)
        elif isinstance(value, list):
            rendered = ",".join(str(item) for item in value) if value else "none"
        else:
            rendered = str(value)
        print(f"{key}={rendered}")


def same_identity(left: os.stat_result, right: os.stat_result) -> bool:
    return (left.st_dev, left.st_ino) == (right.st_dev, right.st_ino)


def rename_noreplace(
    source_parent_fd: int,
    source_name: str,
    destination_parent_fd: int,
    destination_name: str,
) -> None:
    """Linux renameat2(RENAME_NOREPLACE), avoiding destination replacement."""

    libc = ctypes.CDLL(None, use_errno=True)
    renameat2 = getattr(libc, "renameat2", None)
    if renameat2 is None:
        refuse("renameat2-noreplace-unavailable", EX_UNAVAILABLE)
    renameat2.argtypes = (
        ctypes.c_int,
        ctypes.c_char_p,
        ctypes.c_int,
        ctypes.c_char_p,
        ctypes.c_uint,
    )
    renameat2.restype = ctypes.c_int
    result = renameat2(
        source_parent_fd,
        os.fsencode(source_name),
        destination_parent_fd,
        os.fsencode(destination_name),
        1,
    )
    if result != 0:
        error_number = ctypes.get_errno()
        raise OSError(error_number, os.strerror(error_number), source_name)


def new_quarantine_name(parent_fd: int, original_name: str) -> str:
    for _ in range(16):
        token = secrets.token_hex(16)
        if original_name == STATE_PATH.name or original_name.startswith(
            ROOT_PREFIX_NAME
        ):
            # A top-level interrupted quarantine must remain visible to orphan scans.
            candidate = f"{ROOT_PREFIX_NAME}cleanup_{token}"
        else:
            candidate = f".les0025-delete-{token}"
        try:
            os.stat(candidate, dir_fd=parent_fd, follow_symlinks=False)
        except FileNotFoundError:
            return candidate
    refuse("cannot-allocate-cleanup-quarantine-name", EX_TEMPFAIL)
    raise AssertionError("unreachable")


def restore_quarantined_replacement(
    parent_fd: int, quarantine_name: str, original_name: str, label: str
) -> None:
    try:
        rename_noreplace(parent_fd, quarantine_name, parent_fd, original_name)
    except OSError as error:
        refuse(
            f"replacement-preserved-in-quarantine-{label}-{error.errno}",
            EX_TEMPFAIL,
        )
    os.fsync(parent_fd)


def unlink_regular_bound(
    parent_fd: int,
    name: str,
    label: str,
    expected_mode: int = 0o600,
    before_quarantine: Callable[[], None] | None = None,
) -> None:
    """Quarantine by no-replace rename, verify inode, then unlink that inode name."""

    descriptor = open_regular_at(parent_fd, name, label, expected_mode)
    original = os.fstat(descriptor)
    quarantine_name = new_quarantine_name(parent_fd, name)
    try:
        if before_quarantine is not None:
            before_quarantine()
        try:
            rename_noreplace(parent_fd, name, parent_fd, quarantine_name)
        except OSError as error:
            refuse(f"cannot-quarantine-file-{label}-{error.errno}", EX_TEMPFAIL)
        os.fsync(parent_fd)
        try:
            quarantined = os.stat(
                quarantine_name, dir_fd=parent_fd, follow_symlinks=False
            )
        except FileNotFoundError:
            refuse(f"quarantined-file-disappeared-{label}", EX_TEMPFAIL)
        if not same_identity(original, quarantined):
            restore_quarantined_replacement(
                parent_fd, quarantine_name, name, label
            )
            refuse(f"deletion-target-identity-changed-{label}", EX_TEMPFAIL)
        validate_regular_info(quarantined, label, expected_mode)
        final = os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
        if not same_identity(original, final):
            refuse(f"quarantine-identity-changed-{label}", EX_TEMPFAIL)
        os.unlink(quarantine_name, dir_fd=parent_fd)
        os.fsync(parent_fd)
        if os.fstat(descriptor).st_nlink != 0:
            refuse(f"quarantined-file-unlink-not-proven-{label}")
    finally:
        os.close(descriptor)


def rmdir_empty_bound(
    parent_fd: int,
    name: str,
    opened_directory_fd: int,
    label: str,
    before_quarantine: Callable[[], None] | None = None,
) -> None:
    """Quarantine by no-replace rename, verify directory inode, then rmdir."""

    original = os.fstat(opened_directory_fd)
    validate_directory_info(original, label)
    if os.listdir(opened_directory_fd):
        refuse(f"directory-not-empty-before-removal-{label}")
    quarantine_name = new_quarantine_name(parent_fd, name)
    if before_quarantine is not None:
        before_quarantine()
    try:
        rename_noreplace(parent_fd, name, parent_fd, quarantine_name)
    except OSError as error:
        refuse(f"cannot-quarantine-directory-{label}-{error.errno}", EX_TEMPFAIL)
    os.fsync(parent_fd)
    try:
        quarantined = os.stat(
            quarantine_name, dir_fd=parent_fd, follow_symlinks=False
        )
    except FileNotFoundError:
        refuse(f"quarantined-directory-disappeared-{label}", EX_TEMPFAIL)
    if not same_identity(original, quarantined):
        restore_quarantined_replacement(parent_fd, quarantine_name, name, label)
        refuse(f"deletion-target-identity-changed-{label}", EX_TEMPFAIL)
    validate_directory_info(quarantined, label)
    if os.listdir(opened_directory_fd):
        refuse(f"quarantined-directory-not-empty-{label}")
    final = os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    if not same_identity(original, final):
        refuse(f"quarantine-identity-changed-{label}", EX_TEMPFAIL)
    os.rmdir(quarantine_name, dir_fd=parent_fd)
    os.fsync(parent_fd)


def canonical_bytes(payload: object) -> bytes:
    return (
        json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n"
    ).encode("utf-8")


def sha256_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def sha256_path(path: Path) -> str:
    info = os.lstat(path)
    if not stat.S_ISREG(info.st_mode) or stat.S_ISLNK(info.st_mode):
        refuse(f"reviewed-source-not-regular-{path.name}")
    digest = hashlib.sha256()
    flags = os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags)
    try:
        opened = os.fstat(descriptor)
        if (opened.st_dev, opened.st_ino) != (info.st_dev, info.st_ino):
            refuse(f"reviewed-source-identity-changed-{path.name}")
        while True:
            chunk = os.read(descriptor, 65536)
            if not chunk:
                break
            digest.update(chunk)
    finally:
        os.close(descriptor)
    return digest.hexdigest()


def source_manifest() -> dict[str, str]:
    manifest: dict[str, str] = {}
    for relative in SOURCE_PATHS:
        path = BASE / relative
        if not path.exists():
            refuse(f"missing-reviewed-source-{relative.replace('/', '-')}", EX_UNAVAILABLE)
        manifest[relative] = sha256_path(path)
    return manifest


def source_manifest_digest(manifest: dict[str, str]) -> str:
    return sha256_bytes(canonical_bytes(manifest))


def mode_of(info: os.stat_result) -> int:
    return stat.S_IMODE(info.st_mode)


def validate_directory_info(
    info: os.stat_result, label: str, expected_mode: int = 0o700
) -> None:
    if not stat.S_ISDIR(info.st_mode) or stat.S_ISLNK(info.st_mode):
        refuse(f"expected-directory-{label}")
    if info.st_uid != CURRENT_UID:
        refuse(f"directory-owner-invalid-{label}")
    if mode_of(info) != expected_mode:
        refuse(f"directory-mode-invalid-{label}")


def validate_regular_info(
    info: os.stat_result, label: str, expected_mode: int = 0o600
) -> None:
    if not stat.S_ISREG(info.st_mode):
        refuse(f"expected-regular-file-{label}")
    if info.st_uid != CURRENT_UID:
        refuse(f"file-owner-invalid-{label}")
    if mode_of(info) != expected_mode:
        refuse(f"file-mode-invalid-{label}")
    if info.st_nlink != 1:
        refuse(f"file-link-count-invalid-{label}")


def open_directory_path(path: Path, label: str) -> tuple[int, os.stat_result]:
    try:
        before = os.lstat(path)
    except FileNotFoundError:
        refuse(f"missing-directory-{label}")
    validate_directory_info(before, label)
    flags = os.O_RDONLY | os.O_DIRECTORY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(path, flags)
    except OSError as error:
        refuse(f"cannot-open-directory-{label}-{error.errno}")
    opened = os.fstat(descriptor)
    if (opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino):
        os.close(descriptor)
        refuse(f"directory-identity-changed-{label}")
    return descriptor, opened


def open_tmp_parent() -> int:
    path = Path("/tmp")
    before = os.lstat(path)
    if not stat.S_ISDIR(before.st_mode) or stat.S_ISLNK(before.st_mode):
        refuse("tmp-parent-type-invalid")
    if before.st_uid != 0 or mode_of(before) != 0o1777:
        refuse("tmp-parent-owner-or-mode-invalid")
    flags = os.O_RDONLY | os.O_DIRECTORY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags)
    opened = os.fstat(descriptor)
    if not same_identity(before, opened):
        os.close(descriptor)
        refuse("tmp-parent-identity-changed")
    return descriptor


def open_directory_at(parent_fd: int, name: str, label: str) -> int:
    try:
        before = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        refuse(f"missing-directory-{label}")
    validate_directory_info(before, label)
    flags = os.O_RDONLY | os.O_DIRECTORY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(name, flags, dir_fd=parent_fd)
    opened = os.fstat(descriptor)
    if (opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino):
        os.close(descriptor)
        refuse(f"directory-identity-changed-{label}")
    return descriptor


def open_regular_at(
    parent_fd: int,
    name: str,
    label: str,
    expected_mode: int = 0o600,
    writable: bool = False,
) -> int:
    flags = os.O_RDWR if writable else os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(name, flags, dir_fd=parent_fd)
    except FileNotFoundError:
        refuse(f"missing-file-{label}")
    except OSError as error:
        refuse(f"cannot-open-file-{label}-{error.errno}")
    info = os.fstat(descriptor)
    validate_regular_info(info, label, expected_mode)
    return descriptor


def read_descriptor_bytes(descriptor: int, label: str) -> bytes:
    os.lseek(descriptor, 0, os.SEEK_SET)
    chunks: list[bytes] = []
    total = 0
    while True:
        chunk = os.read(descriptor, 65536)
        if not chunk:
            break
        total += len(chunk)
        if total > 1024 * 1024:
            refuse(f"file-too-large-{label}")
        chunks.append(chunk)
    return b"".join(chunks)


def read_regular_at(
    parent_fd: int, name: str, label: str, expected_mode: int = 0o600
) -> bytes:
    descriptor = open_regular_at(parent_fd, name, label, expected_mode)
    try:
        return read_descriptor_bytes(descriptor, label)
    finally:
        os.close(descriptor)


def write_all(descriptor: int, content: bytes) -> None:
    view = memoryview(content)
    while view:
        written = os.write(descriptor, view)
        if written <= 0:
            refuse("short-write")
        view = view[written:]


def write_new_at(
    parent_fd: int,
    name: str,
    content: bytes,
    expected_mode: int = 0o600,
) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(name, flags, expected_mode, dir_fd=parent_fd)
    except FileExistsError:
        refuse(f"record-already-exists-{name}", EX_USAGE)
    try:
        os.fchmod(descriptor, expected_mode)
        write_all(descriptor, content)
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    os.fsync(parent_fd)


def rewrite_descriptor(parent_fd: int, payload: dict[str, Any]) -> None:
    descriptor = open_regular_at(
        parent_fd, "descriptor.json", "descriptor.json", 0o600, writable=True
    )
    try:
        os.ftruncate(descriptor, 0)
        os.lseek(descriptor, 0, os.SEEK_SET)
        write_all(descriptor, canonical_bytes(payload))
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    os.fsync(parent_fd)


def parse_json_bytes(content: bytes, label: str) -> dict[str, Any]:
    try:
        decoded = content.decode("utf-8")
        payload = json.loads(decoded)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise LabRefusal(f"invalid-json-{label}") from error
    if not isinstance(payload, dict):
        refuse(f"expected-json-object-{label}")
    return payload


def validate_descriptor(payload: dict[str, Any]) -> None:
    expected_keys = {
        "lesson",
        "phase",
        "root",
        "rootDevice",
        "rootInode",
        "schemaVersion",
        "sources",
        "uid",
    }
    if set(payload) != expected_keys:
        refuse("descriptor-keys-invalid")
    if payload["schemaVersion"] != SCHEMA_VERSION or payload["lesson"] != LESSON:
        refuse("descriptor-identity-invalid")
    if payload["uid"] != CURRENT_UID:
        refuse("descriptor-uid-invalid")
    if payload["phase"] not in {"active", "cleanup"}:
        refuse("descriptor-phase-invalid")
    root = payload["root"]
    if not isinstance(root, str) or ROOT_PATTERN.fullmatch(root) is None:
        refuse("registered-root-pattern-invalid")
    if not isinstance(payload["rootDevice"], int) or not isinstance(
        payload["rootInode"], int
    ):
        refuse("registered-root-identity-invalid")
    sources = payload["sources"]
    if not isinstance(sources, dict) or set(sources) != set(SOURCE_PATHS):
        refuse("descriptor-source-manifest-invalid")
    for relative, digest in sources.items():
        if not isinstance(relative, str) or not isinstance(digest, str):
            refuse("descriptor-source-entry-invalid")
        if re.fullmatch(r"[0-9a-f]{64}", digest) is None:
            refuse("descriptor-source-digest-invalid")


def validate_current_sources(payload: dict[str, Any]) -> None:
    current = source_manifest()
    recorded = payload["sources"]
    for relative in SOURCE_PATHS:
        if current[relative] != recorded[relative]:
            refuse(f"reviewed-source-digest-changed-{relative.replace('/', '-')}")


def root_sentinel(payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "lesson": LESSON,
        "rootDevice": payload["rootDevice"],
        "rootInode": payload["rootInode"],
        "schemaVersion": SCHEMA_VERSION,
        "uid": CURRENT_UID,
    }


def validate_workspace(workspace_fd: int, workspace_name: str) -> None:
    children = set(os.listdir(workspace_fd))
    unexpected = children - set(WORKSPACE_LAYOUT)
    if unexpected:
        refuse(
            f"unexpected-workspace-child-{workspace_name}-{sorted(unexpected)[0]}"
        )
    for directory_name, allowed_files in WORKSPACE_LAYOUT.items():
        if directory_name not in children:
            continue
        directory_fd = open_directory_at(
            workspace_fd,
            directory_name,
            f"{workspace_name}-{directory_name}",
        )
        try:
            files = set(os.listdir(directory_fd))
            extra = files - allowed_files
            if extra:
                refuse(
                    f"unexpected-job-child-{workspace_name}-{directory_name}-{sorted(extra)[0]}"
                )
            for filename in files:
                descriptor = open_regular_at(
                    directory_fd,
                    filename,
                    f"{workspace_name}-{directory_name}-{filename}",
                )
                os.close(descriptor)
        finally:
            os.close(directory_fd)


def validate_root_contents(root_fd: int, payload: dict[str, Any]) -> None:
    children = set(os.listdir(root_fd))
    unexpected = children - ROOT_CHILDREN
    if unexpected:
        refuse(f"unexpected-root-child-{sorted(unexpected)[0]}")

    cleanup_phase = payload["phase"] == "cleanup"
    if not cleanup_phase and ".sentinel" not in children:
        refuse("missing-file-.sentinel")
    if ".sentinel" in children:
        content = read_regular_at(root_fd, ".sentinel", ".sentinel", 0o400)
        if content != canonical_bytes(root_sentinel(payload)):
            refuse("sentinel-content-invalid")

    if not cleanup_phase and "runs" not in children:
        refuse("missing-directory-runs")
    if "runs" in children:
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        try:
            workspaces = set(os.listdir(runs_fd))
            unexpected_workspaces = workspaces - set(WORKSPACES)
            if unexpected_workspaces:
                refuse(
                    f"unexpected-runs-child-{sorted(unexpected_workspaces)[0]}"
                )
            for workspace_name in workspaces:
                workspace_fd = open_directory_at(
                    runs_fd, workspace_name, f"workspace-{workspace_name}"
                )
                try:
                    validate_workspace(workspace_fd, workspace_name)
                finally:
                    os.close(workspace_fd)
        finally:
            os.close(runs_fd)

    for record_name in ROOT_RECORDS:
        if record_name in children:
            descriptor = open_regular_at(root_fd, record_name, record_name)
            os.close(descriptor)


@dataclass
class LockedState:
    state_fd: int
    lock_fd: int
    root_fd: int | None
    state_device: int
    state_inode: int
    payload: dict[str, Any]


@contextlib.contextmanager
def locked_state() -> Iterator[LockedState]:
    if not os.path.lexists(STATE_PATH):
        refuse("state-not-registered", EX_USAGE)
    state_fd, state_info = open_directory_path(STATE_PATH, "state")
    lock_fd = -1
    root_fd: int | None = None
    try:
        lock_fd = open_regular_at(
            state_fd, "lock", "state-lock", 0o600, writable=True
        )
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise LabRefusal("state-lock-contended", EX_TEMPFAIL) from error

        try:
            current_state = os.lstat(STATE_PATH)
        except FileNotFoundError:
            refuse("state-path-disappeared")
        if (current_state.st_dev, current_state.st_ino) != (
            state_info.st_dev,
            state_info.st_ino,
        ):
            refuse("state-path-identity-changed")

        descriptor_bytes = read_regular_at(
            state_fd, "descriptor.json", "descriptor.json"
        )
        payload = parse_json_bytes(descriptor_bytes, "descriptor")
        if descriptor_bytes != canonical_bytes(payload):
            refuse("descriptor-not-canonical")
        validate_descriptor(payload)
        validate_current_sources(payload)

        root_path = Path(payload["root"])
        try:
            root_info = os.lstat(root_path)
        except FileNotFoundError:
            if payload["phase"] != "cleanup":
                refuse("registered-root-missing")
        else:
            validate_directory_info(root_info, "registered-root")
            if (root_info.st_dev, root_info.st_ino) != (
                payload["rootDevice"],
                payload["rootInode"],
            ):
                refuse("registered-root-identity-mismatch")
            root_fd, opened_root = open_directory_path(root_path, "registered-root")
            if (opened_root.st_dev, opened_root.st_ino) != (
                payload["rootDevice"],
                payload["rootInode"],
            ):
                refuse("opened-root-identity-mismatch")
            validate_root_contents(root_fd, payload)

        yield LockedState(
            state_fd=state_fd,
            lock_fd=lock_fd,
            root_fd=root_fd,
            state_device=state_info.st_dev,
            state_inode=state_info.st_ino,
            payload=payload,
        )
    finally:
        if root_fd is not None:
            os.close(root_fd)
        if lock_fd >= 0:
            try:
                fcntl.flock(lock_fd, fcntl.LOCK_UN)
            except OSError:
                pass
            os.close(lock_fd)
        os.close(state_fd)


def scan_orphan_roots() -> list[str]:
    roots: list[str] = []
    try:
        entries = os.scandir("/tmp")
    except OSError as error:
        refuse(f"cannot-scan-tmp-{error.errno}")
    with entries:
        for entry in entries:
            candidate = f"/tmp/{entry.name}"
            if ROOT_PATTERN.fullmatch(candidate) is None:
                continue
            roots.append(candidate)
    return sorted(roots)


def command_check() -> None:
    if not os.path.lexists(STATE_PATH):
        roots = scan_orphan_roots()
        emit(
            [
                ("lesson", LESSON),
                ("state", "absent" if not roots else "orphaned"),
                ("orphan_count", len(roots)),
            ]
        )
        if roots:
            refuse("unregistered-lesson-root-found-refusing-to-guess")
        return
    with locked_state() as state:
        emit(
            [
                ("lesson", LESSON),
                ("state", "registered"),
                ("phase", state.payload["phase"]),
                ("root", state.payload["root"]),
            ]
        )


def rollback_setup(
    state_fd: int | None,
    root_fd: int | None,
    root_path: Path | None,
    state_created: bool,
) -> None:
    if root_fd is not None:
        if "runs" in set(os.listdir(root_fd)):
            runs_fd = open_directory_at(root_fd, "runs", "rollback-runs")
            try:
                rmdir_empty_bound(
                    root_fd, "runs", runs_fd, "rollback-runs"
                )
            finally:
                os.close(runs_fd)
        if ".sentinel" in set(os.listdir(root_fd)):
            unlink_regular_bound(
                root_fd, ".sentinel", "rollback-sentinel", 0o400
            )
        if root_path is not None and not os.listdir(root_fd):
            tmp_fd = open_tmp_parent()
            try:
                rmdir_empty_bound(
                    tmp_fd,
                    root_path.name,
                    root_fd,
                    "rollback-root",
                )
            finally:
                os.close(tmp_fd)
        try:
            os.close(root_fd)
        except OSError:
            pass
    if state_fd is not None:
        for name in ("descriptor.json", "lock"):
            if name in set(os.listdir(state_fd)):
                unlink_regular_bound(
                    state_fd, name, f"rollback-{name}"
                )
        if state_created and not os.listdir(state_fd):
            tmp_fd = open_tmp_parent()
            try:
                rmdir_empty_bound(
                    tmp_fd,
                    STATE_PATH.name,
                    state_fd,
                    "rollback-state",
                )
            finally:
                os.close(tmp_fd)
        try:
            os.close(state_fd)
        except OSError:
            pass


def command_setup() -> None:
    if os.path.lexists(STATE_PATH):
        refuse("state-already-exists", EX_CANTCREAT)
    orphan_roots = scan_orphan_roots()
    if orphan_roots:
        refuse("unregistered-lesson-root-found-refusing-to-guess")
    manifest = source_manifest()
    if os.environ.get("LAB_DRY_RUN") == "1":
        emit(
            [
                ("lesson", LESSON),
                ("dry_run", True),
                ("would_create_state", STATE_PATH),
                ("would_create_random_root_prefix", f"/tmp/{ROOT_PREFIX_NAME}"),
                ("source_manifest_sha256", source_manifest_digest(manifest)),
                ("network_targets", 0),
                ("cloud_calls", 0),
            ]
        )
        return

    state_fd: int | None = None
    root_fd: int | None = None
    root_path: Path | None = None
    state_created = False
    lock_fd: int | None = None
    success = False
    try:
        try:
            os.mkdir(STATE_PATH, 0o700)
        except FileExistsError:
            refuse("state-already-exists", EX_CANTCREAT)
        state_created = True
        os.chmod(STATE_PATH, 0o700, follow_symlinks=False)
        state_fd, state_info = open_directory_path(STATE_PATH, "state")
        flags = os.O_RDWR | os.O_CREAT | os.O_EXCL
        if hasattr(os, "O_NOFOLLOW"):
            flags |= os.O_NOFOLLOW
        lock_fd = os.open("lock", flags, 0o600, dir_fd=state_fd)
        os.fchmod(lock_fd, 0o600)
        os.fsync(lock_fd)
        fcntl.flock(lock_fd, fcntl.LOCK_EX)

        root_path = Path(tempfile.mkdtemp(prefix=ROOT_PREFIX_NAME, dir="/tmp"))
        os.chmod(root_path, 0o700, follow_symlinks=False)
        root_fd, root_info = open_directory_path(root_path, "registered-root")
        os.mkdir("runs", 0o700, dir_fd=root_fd)
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        os.close(runs_fd)

        payload: dict[str, Any] = {
            "lesson": LESSON,
            "phase": "active",
            "root": str(root_path),
            "rootDevice": root_info.st_dev,
            "rootInode": root_info.st_ino,
            "schemaVersion": SCHEMA_VERSION,
            "sources": manifest,
            "uid": CURRENT_UID,
        }
        write_new_at(root_fd, ".sentinel", canonical_bytes(root_sentinel(payload)), 0o400)
        write_new_at(state_fd, "descriptor.json", canonical_bytes(payload), 0o600)
        os.fsync(root_fd)
        os.fsync(state_fd)

        current_state = os.lstat(STATE_PATH)
        current_root = os.lstat(root_path)
        if (current_state.st_dev, current_state.st_ino) != (
            state_info.st_dev,
            state_info.st_ino,
        ):
            refuse("state-path-identity-changed-during-setup")
        if (current_root.st_dev, current_root.st_ino) != (
            root_info.st_dev,
            root_info.st_ino,
        ):
            refuse("root-path-identity-changed-during-setup")
        validate_root_contents(root_fd, payload)
        success = True
        emit(
            [
                ("lesson", LESSON),
                ("setup_complete", True),
                ("root", root_path),
                ("source_manifest_sha256", source_manifest_digest(manifest)),
                ("state_device", state_info.st_dev),
                ("state_inode", state_info.st_ino),
                ("network_targets", 0),
                ("hosted_ci_calls", 0),
                ("cloud_calls", 0),
            ]
        )
    finally:
        if lock_fd is not None:
            try:
                fcntl.flock(lock_fd, fcntl.LOCK_UN)
            except OSError:
                pass
            os.close(lock_fd)
        if success:
            if root_fd is not None:
                os.close(root_fd)
            if state_fd is not None:
                os.close(state_fd)
        else:
            rollback_setup(state_fd, root_fd, root_path, state_created)


def command_status() -> None:
    if not os.path.lexists(STATE_PATH):
        roots = scan_orphan_roots()
        emit(
            [
                ("lesson", LESSON),
                ("state", "absent" if not roots else "orphaned"),
                ("orphan_count", len(roots)),
            ]
        )
        return
    with locked_state() as state:
        if state.root_fd is None:
            records: list[str] = []
        else:
            children = set(os.listdir(state.root_fd))
            records = [name for name in ROOT_RECORDS if name in children]
        emit(
            [
                ("lesson", LESSON),
                ("state", "registered"),
                ("phase", state.payload["phase"]),
                ("root", state.payload["root"]),
                ("records", records),
                ("source_manifest_sha256", source_manifest_digest(state.payload["sources"])),
            ]
        )


def minimal_environment() -> dict[str, str]:
    return {
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "PYTHONHASHSEED": "0",
        "PYTHONDONTWRITEBYTECODE": "1",
    }


def load_config(relative: str) -> tuple[bytes, dict[str, Any]]:
    path = BASE / relative
    content = path.read_bytes()
    payload = parse_json_bytes(content, Path(relative).name)
    return content, payload


def expected_artifact_bytes(config: dict[str, Any]) -> bytes:
    value = config.get("portableInput")
    if not isinstance(value, str):
        refuse("config-portable-input-invalid")
    return value.encode("utf-8")


def read_workspace_artifact(
    root_fd: int, workspace_name: str, directory_name: str, filename: str
) -> bytes:
    runs_fd = open_directory_at(root_fd, "runs", "runs")
    try:
        workspace_fd = open_directory_at(
            runs_fd, workspace_name, f"workspace-{workspace_name}"
        )
        try:
            directory_fd = open_directory_at(
                workspace_fd,
                directory_name,
                f"{workspace_name}-{directory_name}",
            )
            try:
                return read_regular_at(
                    directory_fd,
                    filename,
                    f"{workspace_name}-{directory_name}-{filename}",
                )
            finally:
                os.close(directory_fd)
        finally:
            os.close(workspace_fd)
    finally:
        os.close(runs_fd)


def validate_complete_workspace(
    root_fd: int, workspace_name: str, expected_content: bytes
) -> None:
    expected = {
        ("build", "artifact.bin"),
        ("artifact-store", "build-output.bin"),
        ("test", "downloaded-output.bin"),
    }
    for directory_name, filename in expected:
        content = read_workspace_artifact(
            root_fd, workspace_name, directory_name, filename
        )
        if content != expected_content:
            refuse(
                f"workspace-artifact-content-invalid-{workspace_name}-{directory_name}"
            )


def engine_spec(label: str) -> tuple[str, str, str, str]:
    specs = {
        "graph": (
            "engines/graph_engine.py",
            "pipelines/graph.json",
            "graph",
            "graph.record.json",
        ),
        "stage-broken": (
            "engines/stage_engine.py",
            "pipelines/stage-broken.json",
            "stage-broken",
            "stage-broken.record.json",
        ),
        "stage-fixed": (
            "engines/stage_engine.py",
            "pipelines/stage-fixed.json",
            "stage-fixed",
            "stage-fixed.record.json",
        ),
    }
    try:
        return specs[label]
    except KeyError as error:
        raise LabRefusal(f"unknown-engine-run-{label}", EX_USAGE) from error


def validate_report(
    report: dict[str, Any],
    config_bytes: bytes,
    config: dict[str, Any],
    workspace_name: str,
    root_fd: int,
) -> None:
    if set(report) != REPORT_KEYS:
        refuse(f"engine-report-keys-invalid-{workspace_name}")
    engine = "local-graph" if workspace_name == "graph" else "local-stage"
    contract = config.get("contract")
    if not isinstance(contract, dict):
        refuse(f"config-contract-invalid-{workspace_name}")
    expected_content = expected_artifact_bytes(config)
    expected = {
        "artifactHandoff": True,
        "artifactSha256": sha256_bytes(expected_content),
        "concurrency": contract.get("concurrency"),
        "configSha256": sha256_bytes(config_bytes),
        "credentialInputsObserved": [],
        "dependencyEdges": ["build->test"],
        "engine": engine,
        "engineEnvironmentKeys": sorted(minimal_environment()),
        "externalEffects": [],
        "jobOrder": ["build", "test"],
        "jobEnvironmentKeys": sorted(minimal_environment()),
        "networkTargets": contract.get("networkTargets"),
        "permissions": contract.get("permissions"),
        "pipelineIdentity": config.get("pipelineIdentity"),
        "schemaVersion": SCHEMA_VERSION,
        "secretInputs": contract.get("secretInputs"),
        "sourceIdentity": config.get("sourceIdentity"),
        "status": "passed",
        "timeoutSeconds": contract.get("timeoutSeconds"),
    }
    if report != expected:
        refuse(f"engine-report-content-invalid-{workspace_name}")
    validate_complete_workspace(root_fd, workspace_name, expected_content)

    expected_contract_bytes, expected_contract = load_config(
        "pipelines/expected-contract.json"
    )
    del expected_contract_bytes
    projected_contract = {
        "artifactHandoff": report["artifactHandoff"],
        "concurrency": report["concurrency"],
        "dependencyEdges": report["dependencyEdges"],
        "jobOrder": report["jobOrder"],
        "networkTargets": report["networkTargets"],
        "permissions": report["permissions"],
        "pipelineIdentity": report["pipelineIdentity"],
        "secretInputs": report["secretInputs"],
        "sourceIdentity": report["sourceIdentity"],
        "timeoutSeconds": report["timeoutSeconds"],
    }
    contract_matches = projected_contract == expected_contract
    if workspace_name in {"graph", "stage-fixed"} and not contract_matches:
        refuse(f"expected-contract-mismatch-{workspace_name}")
    if workspace_name == "stage-broken":
        differing_fields = {
            key
            for key in expected_contract
            if projected_contract.get(key) != expected_contract[key]
        }
        if differing_fields != {"concurrency", "permissions", "timeoutSeconds"}:
            refuse("broken-stage-mismatch-set-invalid")


def create_workspace(root_fd: int, workspace_name: str) -> Path:
    runs_fd = open_directory_at(root_fd, "runs", "runs")
    try:
        try:
            os.mkdir(workspace_name, 0o700, dir_fd=runs_fd)
        except FileExistsError:
            refuse(f"workspace-already-exists-{workspace_name}", EX_USAGE)
        workspace_fd = open_directory_at(
            runs_fd, workspace_name, f"workspace-{workspace_name}"
        )
        os.close(workspace_fd)
    finally:
        os.close(runs_fd)
    return (
        Path("/proc")
        / str(os.getpid())
        / "fd"
        / str(root_fd)
        / "runs"
        / workspace_name
    )


def execute_engine(state: LockedState, label: str) -> dict[str, Any]:
    if state.payload["phase"] != "active" or state.root_fd is None:
        refuse("cleanup-is-in-progress-use-cleanup-to-resume", EX_USAGE)
    engine_relative, config_relative, workspace_name, record_name = engine_spec(label)
    if record_name in set(os.listdir(state.root_fd)):
        refuse(f"record-already-exists-{record_name}", EX_USAGE)

    workspace_bound = create_workspace(state.root_fd, workspace_name)
    # The /proc path keeps execution bound to the controller's validated root descriptor.
    if not workspace_bound.exists():
        refuse(f"workspace-registration-failed-{workspace_name}")

    engine_path = BASE / engine_relative
    config_path = BASE / config_relative
    portable_job = BASE / "jobs/portable_job.py"
    completed = subprocess.run(
        [
            sys.executable,
            "-S",
            str(engine_path),
            "--config",
            str(config_path),
            "--workspace",
            str(workspace_bound),
            "--portable-job",
            str(portable_job),
        ],
        check=False,
        cwd=workspace_bound,
        env=minimal_environment(),
        capture_output=True,
        text=True,
        timeout=20,
    )
    if completed.returncode != 0:
        refuse(f"engine-run-failed-{label}-{completed.returncode}")
    if completed.stderr:
        refuse(f"engine-run-unexpected-stderr-{label}")
    try:
        report = json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise LabRefusal(f"engine-output-invalid-{label}") from error
    if not isinstance(report, dict):
        refuse(f"engine-output-not-object-{label}")
    config_bytes, config = load_config(config_relative)
    validate_report(report, config_bytes, config, workspace_name, state.root_fd)
    write_new_at(state.root_fd, record_name, canonical_bytes(report))
    return report


def command_run(label: str) -> None:
    if label not in {"graph", "stage-broken"}:
        refuse(f"run-label-not-allowed-{label}", EX_USAGE)
    with locked_state() as state:
        report = execute_engine(state, label)
        emit(
            [
                ("lesson", LESSON),
                ("run", label),
                ("engine", report["engine"]),
                ("status", report["status"]),
                ("jobs", report["jobOrder"]),
                ("artifact_sha256", report["artifactSha256"]),
                ("network_targets", len(report["networkTargets"])),
                ("secret_inputs", len(report["secretInputs"])),
            ]
        )


def load_engine_record(
    state: LockedState, label: str
) -> tuple[bytes, dict[str, Any]]:
    if state.root_fd is None:
        refuse("registered-root-missing")
    _, config_relative, workspace_name, record_name = engine_spec(label)
    if record_name not in set(os.listdir(state.root_fd)):
        refuse(f"missing-engine-record-{label}", EX_USAGE)
    content = read_regular_at(state.root_fd, record_name, record_name)
    report = parse_json_bytes(content, record_name)
    if content != canonical_bytes(report):
        refuse(f"record-not-canonical-{record_name}")
    config_bytes, config = load_config(config_relative)
    validate_report(report, config_bytes, config, workspace_name, state.root_fd)
    return content, report


def comparison_payload(
    graph_bytes: bytes,
    graph: dict[str, Any],
    stage_bytes: bytes,
    stage: dict[str, Any],
    stage_label: str,
) -> dict[str, Any]:
    checks = {
        "artifactDigestEqual": graph["artifactSha256"] == stage["artifactSha256"],
        "artifactHandoffEqual": graph["artifactHandoff"] == stage["artifactHandoff"],
        "bothGreen": graph["status"] == stage["status"] == "passed",
        "concurrencyContractEqual": graph["concurrency"] == stage["concurrency"],
        "jobGraphEqual": (
            graph["jobOrder"] == stage["jobOrder"]
            and graph["dependencyEdges"] == stage["dependencyEdges"]
        ),
        "networkContractEqual": graph["networkTargets"] == stage["networkTargets"],
        "permissionContractEqual": graph["permissions"] == stage["permissions"],
        "pipelineIdentityEqual": graph["pipelineIdentity"] == stage["pipelineIdentity"],
        "secretContractEqual": graph["secretInputs"] == stage["secretInputs"],
        "sourceIdentityEqual": graph["sourceIdentity"] == stage["sourceIdentity"],
        "timeoutContractEqual": graph["timeoutSeconds"] == stage["timeoutSeconds"],
    }
    return {
        **checks,
        "graphRecordSha256": sha256_bytes(graph_bytes),
        "comparisonScope": "observed-local-output-plus-declared-contract-fields",
        "encodedComparisonEqual": all(checks.values()),
        "schemaVersion": SCHEMA_VERSION,
        "stageLabel": stage_label,
        "stageRecordSha256": sha256_bytes(stage_bytes),
    }


def command_compare() -> None:
    with locked_state() as state:
        if state.root_fd is None:
            refuse("registered-root-missing")
        children = set(os.listdir(state.root_fd))
        if "graph.record.json" not in children:
            refuse("compare-requires-graph-record", EX_USAGE)
        if "stage-broken.record.json" not in children:
            refuse("compare-requires-stage-broken-record", EX_USAGE)
        if "comparison.record.json" in children:
            refuse("record-already-exists-comparison.record.json", EX_USAGE)
        graph_bytes, graph = load_engine_record(state, "graph")
        stage_bytes, stage = load_engine_record(state, "stage-broken")
        comparison = comparison_payload(
            graph_bytes, graph, stage_bytes, stage, "stage-broken"
        )
        if comparison["encodedComparisonEqual"] is not False:
            refuse("expected-negative-case-not-observed")
        expected_false = {
            "permissionContractEqual",
            "concurrencyContractEqual",
            "timeoutContractEqual",
        }
        actual_false = {
            key for key, value in comparison.items() if value is False
        }
        if actual_false != expected_false | {"encodedComparisonEqual"}:
            refuse("negative-case-mismatch-set-invalid")
        write_new_at(
            state.root_fd,
            "comparison.record.json",
            canonical_bytes(comparison),
        )
        emit(
            [
                ("both_green", comparison["bothGreen"]),
                ("source_identity_equal", comparison["sourceIdentityEqual"]),
                ("pipeline_identity_equal", comparison["pipelineIdentityEqual"]),
                ("artifact_digest_equal", comparison["artifactDigestEqual"]),
                ("job_graph_equal", comparison["jobGraphEqual"]),
                ("permission_contract_equal", comparison["permissionContractEqual"]),
                ("concurrency_contract_equal", comparison["concurrencyContractEqual"]),
                ("timeout_contract_equal", comparison["timeoutContractEqual"]),
                ("secret_contract_equal", comparison["secretContractEqual"]),
                ("network_contract_equal", comparison["networkContractEqual"]),
                ("encoded_comparison_equal", comparison["encodedComparisonEqual"]),
                ("declarative_fields_behaviorally_enforced", False),
            ]
        )


def load_comparison(state: LockedState) -> tuple[bytes, dict[str, Any]]:
    if state.root_fd is None:
        refuse("registered-root-missing")
    content = read_regular_at(
        state.root_fd, "comparison.record.json", "comparison.record.json"
    )
    payload = parse_json_bytes(content, "comparison.record.json")
    if content != canonical_bytes(payload):
        refuse("record-not-canonical-comparison.record.json")
    graph_bytes, graph = load_engine_record(state, "graph")
    stage_bytes, stage = load_engine_record(state, "stage-broken")
    expected = comparison_payload(
        graph_bytes, graph, stage_bytes, stage, "stage-broken"
    )
    if payload != expected:
        refuse("comparison-record-content-invalid")
    return content, payload


def command_recover() -> None:
    with locked_state() as state:
        if state.root_fd is None:
            refuse("registered-root-missing")
        if "comparison.record.json" not in set(os.listdir(state.root_fd)):
            refuse("recovery-requires-comparison-record", EX_USAGE)
        _, comparison = load_comparison(state)
        if comparison["encodedComparisonEqual"] is not False:
            refuse("recovery-requires-observed-mismatch")
        report = execute_engine(state, "stage-fixed")
        emit(
            [
                ("lesson", LESSON),
                ("run", "stage-fixed"),
                ("engine", report["engine"]),
                ("contract", "corrected"),
                ("status", report["status"]),
                ("artifact_sha256", report["artifactSha256"]),
                ("network_targets", len(report["networkTargets"])),
                ("secret_inputs", len(report["secretInputs"])),
            ]
        )


def command_verify_operation() -> None:
    with locked_state() as state:
        if state.root_fd is None:
            refuse("registered-root-missing")
        children = set(os.listdir(state.root_fd))
        if "stage-fixed.record.json" not in children:
            refuse("verification-requires-corrected-stage-run", EX_USAGE)
        if "verification.record.json" in children:
            refuse("record-already-exists-verification.record.json", EX_USAGE)
        comparison_bytes, original = load_comparison(state)
        graph_bytes, graph = load_engine_record(state, "graph")
        fixed_bytes, fixed = load_engine_record(state, "stage-fixed")
        corrected = comparison_payload(
            graph_bytes, graph, fixed_bytes, fixed, "stage-fixed"
        )
        if corrected["encodedComparisonEqual"] is not True:
            refuse("encoded-comparison-equality-not-proven")
        if original["encodedComparisonEqual"] is not False:
            refuse("negative-case-evidence-missing")
        verification = {
            "comparisonRecordSha256": sha256_bytes(comparison_bytes),
            "correctedComparison": corrected,
            "expectedContractSha256": sha256_path(
                BASE / "pipelines/expected-contract.json"
            ),
            "externalEffects": [],
            "hostedCiCalls": 0,
            "networkTargets": [],
            "localVerificationPassed": True,
            "originalMismatchObserved": True,
            "schemaVersion": SCHEMA_VERSION,
            "secretInputs": [],
        }
        write_new_at(
            state.root_fd,
            "verification.record.json",
            canonical_bytes(verification),
        )
        emit(
            [
                ("original_mismatch_observed", True),
                ("both_green", corrected["bothGreen"]),
                ("artifact_digest_equal", corrected["artifactDigestEqual"]),
                ("job_graph_equal", corrected["jobGraphEqual"]),
                ("permission_contract_equal", corrected["permissionContractEqual"]),
                ("concurrency_contract_equal", corrected["concurrencyContractEqual"]),
                ("timeout_contract_equal", corrected["timeoutContractEqual"]),
                ("encoded_comparison_equal", corrected["encodedComparisonEqual"]),
                ("declarative_fields_behaviorally_enforced", False),
                ("network_targets", 0),
                ("secret_inputs", 0),
                ("local_verification_passed", True),
            ]
        )


def remove_regular_if_present(
    parent_fd: int, name: str, label: str, expected_mode: int = 0o600
) -> None:
    try:
        os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        return
    unlink_regular_bound(parent_fd, name, label, expected_mode)


def remove_workspace(runs_fd: int, workspace_name: str) -> None:
    try:
        os.stat(workspace_name, dir_fd=runs_fd, follow_symlinks=False)
    except FileNotFoundError:
        return
    workspace_fd = open_directory_at(
        runs_fd, workspace_name, f"workspace-{workspace_name}"
    )
    try:
        validate_workspace(workspace_fd, workspace_name)
        for directory_name, allowed_files in WORKSPACE_LAYOUT.items():
            if directory_name not in set(os.listdir(workspace_fd)):
                continue
            directory_fd = open_directory_at(
                workspace_fd,
                directory_name,
                f"{workspace_name}-{directory_name}",
            )
            try:
                for filename in sorted(allowed_files):
                    remove_regular_if_present(
                        directory_fd,
                        filename,
                        f"{workspace_name}-{directory_name}-{filename}",
                    )
                rmdir_empty_bound(
                    workspace_fd,
                    directory_name,
                    directory_fd,
                    f"{workspace_name}-{directory_name}",
                )
            finally:
                os.close(directory_fd)
        rmdir_empty_bound(
            runs_fd,
            workspace_name,
            workspace_fd,
            f"workspace-{workspace_name}",
        )
    finally:
        os.close(workspace_fd)


def cleanup_owned_root(state: LockedState) -> None:
    if state.root_fd is None:
        return
    root_fd = state.root_fd
    validate_root_contents(root_fd, state.payload)
    if "runs" in set(os.listdir(root_fd)):
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        try:
            for workspace_name in WORKSPACES:
                remove_workspace(runs_fd, workspace_name)
            rmdir_empty_bound(root_fd, "runs", runs_fd, "runs")
        finally:
            os.close(runs_fd)
    for record_name in reversed(ROOT_RECORDS):
        remove_regular_if_present(root_fd, record_name, record_name)
    remove_regular_if_present(root_fd, ".sentinel", ".sentinel", 0o400)
    if os.listdir(root_fd):
        refuse("root-not-empty-after-allowlisted-cleanup")
    root_path = Path(state.payload["root"])
    tmp_fd = open_tmp_parent()
    try:
        rmdir_empty_bound(
            tmp_fd,
            root_path.name,
            root_fd,
            "registered-root",
        )
    finally:
        os.close(tmp_fd)


def command_cleanup() -> None:
    if not os.path.lexists(STATE_PATH):
        roots = scan_orphan_roots()
        if roots:
            refuse("unregistered-lesson-root-found-refusing-to-guess")
        emit(
            [
                ("lesson", LESSON),
                ("cleanup_proven", True),
                ("state", "absent"),
                ("orphan_count", 0),
            ]
        )
        return
    with locked_state() as state:
        if os.environ.get("LAB_DRY_RUN") == "1":
            emit(
                [
                    ("lesson", LESSON),
                    ("dry_run", True),
                    ("would_remove_root", state.payload["root"]),
                    ("would_remove_state", STATE_PATH),
                    ("cleanup_strategy", "exact-allowlist-nonrecursive"),
                ]
            )
            return
        if state.payload["phase"] != "cleanup":
            state.payload["phase"] = "cleanup"
            rewrite_descriptor(state.state_fd, state.payload)
        cleanup_owned_root(state)
        remove_regular_if_present(
            state.state_fd, "descriptor.json", "descriptor.json"
        )
        # Keep the original lock descriptor open while removing its validated name.
        current_lock = os.fstat(state.lock_fd)
        validate_regular_info(current_lock, "state-lock", 0o600)
        unlink_regular_bound(state.state_fd, "lock", "state-lock", 0o600)
        if os.fstat(state.lock_fd).st_nlink != 0:
            refuse("state-lock-unlink-not-proven")
        if os.listdir(state.state_fd):
            refuse("state-directory-not-empty-after-cleanup")
        tmp_fd = open_tmp_parent()
        try:
            rmdir_empty_bound(
                tmp_fd,
                STATE_PATH.name,
                state.state_fd,
                "state-directory",
            )
        finally:
            os.close(tmp_fd)

    if os.path.lexists(STATE_PATH) or scan_orphan_roots():
        refuse("cleanup-final-absence-not-proven")
    emit(
        [
            ("lesson", LESSON),
            ("cleanup_proven", True),
            ("state", "absent"),
            ("orphan_count", 0),
        ]
    )


def expect_identity_change(callback: Callable[[], None], label: str) -> None:
    try:
        callback()
    except LabRefusal as error:
        expected = f"deletion-target-identity-changed-{label}"
        if error.token != expected or error.status != EX_TEMPFAIL:
            raise
    else:
        refuse(f"replacement-race-not-detected-{label}")


def run_regular_replacement_regression(root_fd: int) -> None:
    target = "regular-race.target"
    backup = "regular-race.original"
    original_content = b"original-owned-file\n"
    replacement_content = b"replacement-must-be-preserved\n"
    write_new_at(root_fd, target, original_content)

    def replace_at_boundary() -> None:
        rename_noreplace(root_fd, target, root_fd, backup)
        write_new_at(root_fd, target, replacement_content)

    expect_identity_change(
        lambda: unlink_regular_bound(
            root_fd,
            target,
            "regular-race",
            before_quarantine=replace_at_boundary,
        ),
        "regular-race",
    )
    if read_regular_at(root_fd, target, target) != replacement_content:
        refuse("regular-race-replacement-not-preserved")
    if read_regular_at(root_fd, backup, backup) != original_content:
        refuse("regular-race-original-not-preserved")
    unlink_regular_bound(root_fd, target, target)
    unlink_regular_bound(root_fd, backup, backup)


def run_directory_replacement_regression(root_fd: int, label: str) -> None:
    target = f"{label}.target"
    backup = f"{label}.original"
    os.mkdir(target, 0o700, dir_fd=root_fd)
    original_fd = open_directory_at(root_fd, target, target)

    def replace_at_boundary() -> None:
        rename_noreplace(root_fd, target, root_fd, backup)
        os.mkdir(target, 0o700, dir_fd=root_fd)

    try:
        expect_identity_change(
            lambda: rmdir_empty_bound(
                root_fd,
                target,
                original_fd,
                label,
                before_quarantine=replace_at_boundary,
            ),
            label,
        )
    finally:
        os.close(original_fd)

    replacement_fd = open_directory_at(root_fd, target, target)
    try:
        rmdir_empty_bound(root_fd, target, replacement_fd, target)
    finally:
        os.close(replacement_fd)
    backup_fd = open_directory_at(root_fd, backup, backup)
    try:
        rmdir_empty_bound(root_fd, backup, backup_fd, backup)
    finally:
        os.close(backup_fd)


def command_verify_removal_races() -> None:
    tmp_fd = open_tmp_parent()
    root_path: Path | None = None
    root_fd: int | None = None
    try:
        root_path = Path(
            tempfile.mkdtemp(
                prefix=f"reliability-atlas-{LESSON}-removal-regression-{CURRENT_UID}.",
                dir="/tmp",
            )
        )
        os.chmod(root_path, 0o700, follow_symlinks=False)
        root_fd, _ = open_directory_path(root_path, "removal-regression-root")
        run_regular_replacement_regression(root_fd)
        for label in (
            "root-race",
            "state-race",
            "rollback-root-race",
            "rollback-state-race",
        ):
            run_directory_replacement_regression(root_fd, label)
        if os.listdir(root_fd):
            refuse("removal-regression-root-not-empty")
        rmdir_empty_bound(
            tmp_fd,
            root_path.name,
            root_fd,
            "removal-regression-root",
        )
        emit(
            [
                ("removal_race_regressions", "passed"),
                (
                    "cases",
                    [
                        "regular-file",
                        "root-directory",
                        "state-directory",
                        "rollback-root",
                        "rollback-state",
                    ],
                ),
                ("replacement_preserved", True),
                ("atomic_deletion_claimed", False),
            ]
        )
    finally:
        if root_fd is not None:
            os.close(root_fd)
        os.close(tmp_fd)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="guarded offline LES-0025 lab")
    subparsers = result.add_subparsers(dest="command", required=True)
    subparsers.add_parser("check")
    subparsers.add_parser("setup")
    subparsers.add_parser("status")
    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("label", choices=("graph", "stage-broken"))
    subparsers.add_parser("compare")
    subparsers.add_parser("recover")
    subparsers.add_parser("verify-operation")
    subparsers.add_parser("cleanup")
    subparsers.add_parser("verify-removal-races", help=argparse.SUPPRESS)
    return result


def main() -> None:
    if CURRENT_UID == 0:
        refuse("root-is-refused-run-as-a-normal-user", EX_NOPERM)
    args = parser().parse_args()
    if args.command == "check":
        command_check()
    elif args.command == "setup":
        command_setup()
    elif args.command == "status":
        command_status()
    elif args.command == "run":
        command_run(args.label)
    elif args.command == "compare":
        command_compare()
    elif args.command == "recover":
        command_recover()
    elif args.command == "verify-operation":
        command_verify_operation()
    elif args.command == "cleanup":
        command_cleanup()
    elif args.command == "verify-removal-races":
        command_verify_removal_races()


if __name__ == "__main__":
    try:
        main()
    except LabRefusal as error:
        print(error.token, file=sys.stderr)
        raise SystemExit(error.status) from error
    except subprocess.TimeoutExpired as error:
        print("engine-run-timeout", file=sys.stderr)
        raise SystemExit(EX_TEMPFAIL) from error
    except (OSError, ValueError) as error:
        print(f"lab-controller-refused={error}", file=sys.stderr)
        raise SystemExit(EX_DATAERR) from error
