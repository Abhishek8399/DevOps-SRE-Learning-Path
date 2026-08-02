#!/usr/bin/env python3
"""Guarded lifecycle for the offline LES-0026 observability teaching lab."""

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


LESSON = "LES-0026"
SCHEMA_VERSION = 1
CURRENT_UID = os.geteuid()
BASE = Path(__file__).resolve().parent
STATE_PATH = Path(f"/tmp/reliability-atlas-{LESSON}-{CURRENT_UID}.state.d")
ROOT_PREFIX_NAME = f"reliability-atlas-{LESSON}-{CURRENT_UID}."
ROOT_PATTERN = re.compile(rf"^/tmp/{re.escape(ROOT_PREFIX_NAME)}[A-Za-z0-9_-]+$")
STATE_RECOVERY_PATTERN = re.compile(
    rf"^/tmp/reliability-atlas-{LESSON}-{CURRENT_UID}\.state\.d\."
    rf"(?P<stage>cleanup|final)\.(?P<token>[0-9a-f]{{32}})\."
    rf"(?P<device>[0-9a-f]+)\.(?P<inode>[0-9a-f]+)$"
)
PRIVATE_REGRESSION_QUARANTINE_PATTERN = re.compile(
    rf"^/tmp/\.les0026-dir-{re.escape(ROOT_PREFIX_NAME)}"
    rf"regression-(?:removal|unexpected)-[A-Za-z0-9_-]+$"
)

EX_USAGE = 64
EX_DATAERR = 65
EX_UNAVAILABLE = 69
EX_CANTCREAT = 73
EX_TEMPFAIL = 75
EX_NOPERM = 77

SOURCE_PATHS = (
    "config/scenario.json",
    "lab.sh",
    "lab_controller.py",
    "model/telemetry_model.py",
)
CASES = ("guided", "missing-signal")
HYPOTHESES = (
    "not-produced",
    "sampled",
    "dropped",
    "delayed",
    "query-scope",
    "correlation-defect",
)
OUTPUT_FILES = (
    "metrics.json",
    "logs.ndjson",
    "traces.ndjson",
    "events.ndjson",
    "profile.json",
    "pipeline-counters.json",
    "cardinality.json",
    "retention.json",
    "privacy.json",
    "evidence-limits.json",
    "signal-manifest.json",
    "case-report.json",
)
MANIFEST_FILES = (
    "cardinality.json",
    "events.ndjson",
    "evidence-limits.json",
    "logs.ndjson",
    "metrics.json",
    "pipeline-counters.json",
    "privacy.json",
    "profile.json",
    "retention.json",
    "traces.ndjson",
)
ROOT_RECORDS = (
    "guided.record.json",
    "missing-signal.record.json",
    "guided-verification.json",
    "missing-signal-attempt.json",
    "missing-signal-inspection.json",
    "operation-verification.json",
)
ROOT_CHILDREN = {".sentinel", "runs", *ROOT_RECORDS}
CLEANUP_INTENT = "cleanup.intent.json"
FAULT_POINTS = {
    "after-cleanup-intent",
    "after-file-quarantine",
    "after-file-unlink",
    "after-directory-quarantine",
    "after-directory-rmdir",
    "after-root-record-removal",
    "after-first-artifact-removal",
    "after-root-quarantine",
    "before-root-final-rmdir",
    "after-state-quarantine",
    "after-state-descriptor-removal",
    "after-state-lock-removal",
    "before-state-final-rmdir",
}


class LabRefusal(Exception):
    def __init__(self, token: str, status: int = EX_DATAERR) -> None:
        super().__init__(token)
        self.token = token
        self.status = status


def refuse(token: str, status: int = EX_DATAERR) -> None:
    raise LabRefusal(token, status)


def validate_fault_request() -> None:
    requested = os.environ.get("LAB_FAULT_POINT")
    if requested is not None and requested not in FAULT_POINTS:
        refuse("invalid-cleanup-fault-point", EX_USAGE)


def maybe_inject_fault(point: str) -> None:
    if os.environ.get("LAB_FAULT_POINT") == point:
        refuse(f"fault-injected-{point}", EX_TEMPFAIL)


def emit(pairs: list[tuple[str, object]]) -> None:
    for key, value in pairs:
        if isinstance(value, bool):
            rendered = "true" if value else "false"
        elif isinstance(value, (list, tuple)):
            rendered = ",".join(str(item) for item in value) if value else "none"
        else:
            rendered = str(value)
        print(f"{key}={rendered}")


def canonical_bytes(payload: object) -> bytes:
    return (json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n").encode(
        "utf-8"
    )


def sha256_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def same_identity(left: os.stat_result, right: os.stat_result) -> bool:
    return (left.st_dev, left.st_ino) == (right.st_dev, right.st_ino)


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


def open_tmp_parent() -> int:
    before = os.lstat("/tmp")
    if not stat.S_ISDIR(before.st_mode) or stat.S_ISLNK(before.st_mode):
        refuse("tmp-parent-type-invalid")
    if before.st_uid != 0 or mode_of(before) != 0o1777:
        refuse("tmp-parent-owner-or-mode-invalid")
    flags = os.O_RDONLY | os.O_DIRECTORY | getattr(os, "O_NOFOLLOW", 0)
    descriptor = os.open("/tmp", flags)
    if not same_identity(before, os.fstat(descriptor)):
        os.close(descriptor)
        refuse("tmp-parent-identity-changed")
    return descriptor


def open_directory_path(path: Path, label: str) -> tuple[int, os.stat_result]:
    try:
        before = os.lstat(path)
    except FileNotFoundError:
        refuse(f"missing-directory-{label}")
    validate_directory_info(before, label)
    flags = os.O_RDONLY | os.O_DIRECTORY | getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(path, flags)
    except OSError as error:
        refuse(f"cannot-open-directory-{label}-{error.errno}")
    opened = os.fstat(descriptor)
    if not same_identity(before, opened):
        os.close(descriptor)
        refuse(f"directory-identity-changed-{label}")
    return descriptor, opened


def open_directory_at(parent_fd: int, name: str, label: str) -> int:
    try:
        before = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        refuse(f"missing-directory-{label}")
    validate_directory_info(before, label)
    flags = os.O_RDONLY | os.O_DIRECTORY | getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(name, flags, dir_fd=parent_fd)
    except OSError as error:
        refuse(f"cannot-open-directory-{label}-{error.errno}")
    if not same_identity(before, os.fstat(descriptor)):
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
    flags = (os.O_RDWR if writable else os.O_RDONLY) | getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(name, flags, dir_fd=parent_fd)
    except FileNotFoundError:
        refuse(f"missing-file-{label}")
    except OSError as error:
        refuse(f"cannot-open-file-{label}-{error.errno}")
    validate_regular_info(os.fstat(descriptor), label, expected_mode)
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
    parent_fd: int, name: str, content: bytes, expected_mode: int = 0o600
) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0)
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


def parse_json_bytes(content: bytes, label: str, require_canonical: bool = True) -> dict[str, Any]:
    try:
        payload = json.loads(content.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise LabRefusal(f"invalid-json-{label}") from error
    if not isinstance(payload, dict):
        refuse(f"expected-json-object-{label}")
    if require_canonical and content != canonical_bytes(payload):
        refuse(f"json-not-canonical-{label}")
    return payload


def parse_ndjson_bytes(content: bytes, label: str) -> list[dict[str, Any]]:
    if not content or not content.endswith(b"\n"):
        refuse(f"invalid-ndjson-{label}")
    rows: list[dict[str, Any]] = []
    for index, line in enumerate(content.splitlines(), start=1):
        try:
            row = json.loads(line.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            raise LabRefusal(f"invalid-ndjson-{label}-line-{index}") from error
        if not isinstance(row, dict) or line + b"\n" != canonical_bytes(row):
            refuse(f"invalid-ndjson-{label}-line-{index}")
        rows.append(row)
    return rows


def sha256_path(path: Path) -> str:
    try:
        before = os.lstat(path)
    except FileNotFoundError:
        refuse(f"missing-reviewed-source-{path.name}", EX_UNAVAILABLE)
    if not stat.S_ISREG(before.st_mode) or stat.S_ISLNK(before.st_mode):
        refuse(f"reviewed-source-not-regular-{path.name}")
    descriptor = os.open(path, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
    digest = hashlib.sha256()
    try:
        if not same_identity(before, os.fstat(descriptor)):
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
    return {relative: sha256_path(BASE / relative) for relative in SOURCE_PATHS}


def source_manifest_digest(manifest: dict[str, str]) -> str:
    return sha256_bytes(canonical_bytes(manifest))


def rename_noreplace(
    source_parent_fd: int,
    source_name: str,
    destination_parent_fd: int,
    destination_name: str,
) -> None:
    """Use Linux renameat2(RENAME_NOREPLACE) for a bound cleanup target."""

    libc = ctypes.CDLL(None, use_errno=True)
    function = getattr(libc, "renameat2", None)
    if function is None:
        refuse("renameat2-noreplace-unavailable", EX_UNAVAILABLE)
    function.argtypes = (
        ctypes.c_int,
        ctypes.c_char_p,
        ctypes.c_int,
        ctypes.c_char_p,
        ctypes.c_uint,
    )
    function.restype = ctypes.c_int
    if function(
        source_parent_fd,
        os.fsencode(source_name),
        destination_parent_fd,
        os.fsencode(destination_name),
        1,
    ) != 0:
        number = ctypes.get_errno()
        raise OSError(number, os.strerror(number), source_name)


def validate_allowlisted_basename(name: str) -> None:
    if re.fullmatch(r"[A-Za-z0-9._-]+", name) is None or name in {".", ".."}:
        refuse("cleanup-basename-invalid")


def file_quarantine_name(original_name: str) -> str:
    validate_allowlisted_basename(original_name)
    return f".les0026-file-{original_name}"


def directory_quarantine_name(original_name: str) -> str:
    validate_allowlisted_basename(original_name)
    return f".les0026-dir-{original_name}"


def restore_quarantined_replacement(
    parent_fd: int, quarantine_name: str, original_name: str, label: str
) -> None:
    try:
        rename_noreplace(parent_fd, quarantine_name, parent_fd, original_name)
    except OSError as error:
        refuse(f"replacement-preserved-in-quarantine-{label}-{error.errno}", EX_TEMPFAIL)
    os.fsync(parent_fd)


def unlink_regular_bound(
    parent_fd: int,
    name: str,
    label: str,
    expected_mode: int = 0o600,
    before_quarantine: Callable[[], None] | None = None,
) -> None:
    quarantine_name = file_quarantine_name(name)
    try:
        os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        pass
    else:
        try:
            os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
        except FileNotFoundError:
            descriptor = open_regular_at(
                parent_fd, quarantine_name, f"{label}-recovery", expected_mode
            )
            try:
                opened = os.fstat(descriptor)
                named = os.stat(
                    quarantine_name, dir_fd=parent_fd, follow_symlinks=False
                )
                if not same_identity(opened, named):
                    refuse(f"quarantine-identity-changed-{label}", EX_TEMPFAIL)
                os.unlink(quarantine_name, dir_fd=parent_fd)
                os.fsync(parent_fd)
                if os.fstat(descriptor).st_nlink != 0:
                    refuse(f"quarantined-file-unlink-not-proven-{label}")
            finally:
                os.close(descriptor)
            return
        refuse(f"original-and-quarantine-both-present-{label}")

    descriptor = open_regular_at(parent_fd, name, label, expected_mode)
    original = os.fstat(descriptor)
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
            restore_quarantined_replacement(parent_fd, quarantine_name, name, label)
            refuse(f"deletion-target-identity-changed-{label}", EX_TEMPFAIL)
        validate_regular_info(quarantined, label, expected_mode)
        maybe_inject_fault("after-file-quarantine")
        final = os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
        if not same_identity(original, final):
            refuse(f"quarantine-identity-changed-{label}", EX_TEMPFAIL)
        os.unlink(quarantine_name, dir_fd=parent_fd)
        os.fsync(parent_fd)
        if os.fstat(descriptor).st_nlink != 0:
            refuse(f"quarantined-file-unlink-not-proven-{label}")
        maybe_inject_fault("after-file-unlink")
    finally:
        os.close(descriptor)


def rmdir_empty_bound(
    parent_fd: int,
    name: str,
    opened_directory_fd: int,
    label: str,
    before_quarantine: Callable[[], None] | None = None,
) -> None:
    original = os.fstat(opened_directory_fd)
    validate_directory_info(original, label)
    if os.listdir(opened_directory_fd):
        refuse(f"directory-not-empty-before-removal-{label}")
    quarantine_name = directory_quarantine_name(name)
    try:
        os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        pass
    else:
        refuse(f"directory-quarantine-already-present-{label}")
    if before_quarantine is not None:
        before_quarantine()
    try:
        rename_noreplace(parent_fd, name, parent_fd, quarantine_name)
    except OSError as error:
        refuse(f"cannot-quarantine-directory-{label}-{error.errno}", EX_TEMPFAIL)
    os.fsync(parent_fd)
    try:
        quarantined = os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        refuse(f"quarantined-directory-disappeared-{label}", EX_TEMPFAIL)
    if not same_identity(original, quarantined):
        restore_quarantined_replacement(parent_fd, quarantine_name, name, label)
        refuse(f"deletion-target-identity-changed-{label}", EX_TEMPFAIL)
    validate_directory_info(quarantined, label)
    if os.listdir(opened_directory_fd):
        refuse(f"quarantined-directory-not-empty-{label}")
    maybe_inject_fault("after-directory-quarantine")
    final = os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    if not same_identity(original, final):
        refuse(f"quarantine-identity-changed-{label}", EX_TEMPFAIL)
    os.rmdir(quarantine_name, dir_fd=parent_fd)
    os.fsync(parent_fd)
    maybe_inject_fault("after-directory-rmdir")


def rename_directory_bound(
    parent_fd: int,
    current_name: str,
    destination_name: str,
    opened_directory_fd: int,
    label: str,
) -> None:
    """Move an opened directory to a deterministic recovery name and bind its inode."""

    original = os.fstat(opened_directory_fd)
    validate_directory_info(original, label)
    try:
        rename_noreplace(parent_fd, current_name, parent_fd, destination_name)
    except OSError as error:
        refuse(f"cannot-quarantine-directory-{label}-{error.errno}", EX_TEMPFAIL)
    os.fsync(parent_fd)
    try:
        quarantined = os.stat(
            destination_name, dir_fd=parent_fd, follow_symlinks=False
        )
    except FileNotFoundError:
        refuse(f"quarantined-directory-disappeared-{label}", EX_TEMPFAIL)
    if not same_identity(original, quarantined):
        restore_quarantined_replacement(
            parent_fd, destination_name, current_name, label
        )
        refuse(f"deletion-target-identity-changed-{label}", EX_TEMPFAIL)
    validate_directory_info(quarantined, label)


def rmdir_recovery_directory(
    parent_fd: int, name: str, opened_directory_fd: int, label: str
) -> None:
    """Finish a deterministic quarantine; rmdir itself is an atomic outcome."""

    opened = os.fstat(opened_directory_fd)
    validate_directory_info(opened, label)
    if os.listdir(opened_directory_fd):
        refuse(f"directory-not-empty-before-final-removal-{label}")
    try:
        named = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        refuse(f"recovery-directory-disappeared-{label}", EX_TEMPFAIL)
    if not same_identity(opened, named):
        refuse(f"recovery-directory-identity-changed-{label}", EX_TEMPFAIL)
    os.rmdir(name, dir_fd=parent_fd)
    os.fsync(parent_fd)


def remove_regular_if_present(
    parent_fd: int, name: str, label: str, expected_mode: int = 0o600
) -> None:
    original_present = True
    quarantine_present = True
    try:
        os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        original_present = False
    try:
        os.stat(file_quarantine_name(name), dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        quarantine_present = False
    if not original_present and not quarantine_present:
        return
    unlink_regular_bound(parent_fd, name, label, expected_mode)


def remove_empty_directory_if_present(parent_fd: int, name: str, label: str) -> None:
    quarantine_name = directory_quarantine_name(name)
    original_present = True
    quarantine_present = True
    try:
        os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        original_present = False
    try:
        os.stat(quarantine_name, dir_fd=parent_fd, follow_symlinks=False)
    except FileNotFoundError:
        quarantine_present = False
    if original_present and quarantine_present:
        refuse(f"original-and-quarantine-both-present-{label}")
    if quarantine_present:
        directory_fd = open_directory_at(
            parent_fd, quarantine_name, f"{label}-recovery"
        )
        try:
            rmdir_recovery_directory(
                parent_fd, quarantine_name, directory_fd, f"{label}-recovery"
            )
        finally:
            os.close(directory_fd)
        return
    if not original_present:
        return
    directory_fd = open_directory_at(parent_fd, name, label)
    try:
        rmdir_empty_bound(parent_fd, name, directory_fd, label)
    finally:
        os.close(directory_fd)


def validate_descriptor(payload: dict[str, Any]) -> None:
    expected_keys = {
        "lesson",
        "lifecycleToken",
        "phase",
        "root",
        "rootCleanup",
        "rootDevice",
        "rootFinal",
        "rootInode",
        "schemaVersion",
        "sources",
        "stateCleanup",
        "stateDevice",
        "stateFinal",
        "stateInode",
        "uid",
    }
    if set(payload) != expected_keys:
        refuse("descriptor-keys-invalid")
    if payload["schemaVersion"] != SCHEMA_VERSION or payload["lesson"] != LESSON:
        refuse("descriptor-identity-invalid")
    if payload["uid"] != CURRENT_UID or payload["phase"] != "active":
        refuse("descriptor-owner-or-phase-invalid")
    token = payload["lifecycleToken"]
    if not isinstance(token, str) or re.fullmatch(r"[0-9a-f]{32}", token) is None:
        refuse("descriptor-lifecycle-token-invalid")
    root = payload["root"]
    if not isinstance(root, str) or ROOT_PATTERN.fullmatch(root) is None:
        refuse("registered-root-pattern-invalid")
    if payload["rootCleanup"] != f"{root}_cleanup_{token}" or ROOT_PATTERN.fullmatch(
        str(payload["rootCleanup"])
    ) is None:
        refuse("registered-root-cleanup-pattern-invalid")
    if payload["rootFinal"] != f"{root}_final_{token}" or ROOT_PATTERN.fullmatch(
        str(payload["rootFinal"])
    ) is None:
        refuse("registered-root-final-pattern-invalid")
    if not isinstance(payload["stateDevice"], int) or not isinstance(
        payload["stateInode"], int
    ):
        refuse("registered-state-identity-invalid")
    identity_suffix = f"{payload['stateDevice']:x}.{payload['stateInode']:x}"
    expected_state_cleanup = f"{STATE_PATH}.cleanup.{token}.{identity_suffix}"
    expected_state_final = f"{STATE_PATH}.final.{token}.{identity_suffix}"
    if payload["stateCleanup"] != expected_state_cleanup or STATE_RECOVERY_PATTERN.fullmatch(
        str(payload["stateCleanup"])
    ) is None:
        refuse("registered-state-cleanup-pattern-invalid")
    if payload["stateFinal"] != expected_state_final or STATE_RECOVERY_PATTERN.fullmatch(
        str(payload["stateFinal"])
    ) is None:
        refuse("registered-state-final-pattern-invalid")
    if not isinstance(payload["rootDevice"], int) or not isinstance(
        payload["rootInode"], int
    ):
        refuse("registered-root-identity-invalid")
    sources = payload["sources"]
    if not isinstance(sources, dict) or set(sources) != set(SOURCE_PATHS):
        refuse("descriptor-source-manifest-invalid")
    for relative, digest in sources.items():
        if not isinstance(relative, str) or re.fullmatch(r"[0-9a-f]{64}", str(digest)) is None:
            refuse("descriptor-source-entry-invalid")


def validate_current_sources(payload: dict[str, Any]) -> None:
    current = source_manifest()
    for relative in SOURCE_PATHS:
        if current[relative] != payload["sources"][relative]:
            refuse(f"reviewed-source-digest-changed-{relative.replace('/', '-')}")


def root_sentinel(payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "lesson": LESSON,
        "lifecycleToken": payload["lifecycleToken"],
        "rootDevice": payload["rootDevice"],
        "rootInode": payload["rootInode"],
        "schemaVersion": SCHEMA_VERSION,
        "stateDevice": payload["stateDevice"],
        "stateInode": payload["stateInode"],
        "uid": CURRENT_UID,
    }


def cleanup_intent_payload(
    payload: dict[str, Any], descriptor_bytes: bytes
) -> dict[str, Any]:
    return {
        "descriptorSha256": sha256_bytes(descriptor_bytes),
        "lesson": LESSON,
        "lifecycleToken": payload["lifecycleToken"],
        "rootDevice": payload["rootDevice"],
        "rootInode": payload["rootInode"],
        "schemaVersion": SCHEMA_VERSION,
        "stateDevice": payload["stateDevice"],
        "stateInode": payload["stateInode"],
        "uid": CURRENT_UID,
    }


def validate_cleanup_intent(
    content: bytes, payload: dict[str, Any], descriptor_bytes: bytes
) -> None:
    intent = parse_json_bytes(content, CLEANUP_INTENT)
    if intent != cleanup_intent_payload(payload, descriptor_bytes):
        refuse("cleanup-intent-binding-invalid")


def validate_workspace(
    workspace_fd: int,
    case_name: str,
    complete: bool = False,
    cleanup: bool = False,
) -> None:
    children = set(os.listdir(workspace_fd))
    quarantine_files = {file_quarantine_name(name) for name in OUTPUT_FILES}
    allowed = set(OUTPUT_FILES) | (quarantine_files if cleanup else set())
    unexpected = children - allowed
    if unexpected:
        refuse(f"unexpected-workspace-child-{case_name}-{sorted(unexpected)[0]}")
    if complete and children != set(OUTPUT_FILES):
        missing = sorted(set(OUTPUT_FILES) - children)[0]
        refuse(f"incomplete-workspace-{case_name}-{missing}")
    for name in children:
        descriptor = open_regular_at(workspace_fd, name, f"{case_name}-{name}")
        os.close(descriptor)


def validate_root_contents(
    root_fd: int, payload: dict[str, Any], cleanup: bool = False
) -> None:
    children = set(os.listdir(root_fd))
    file_quarantines = {
        file_quarantine_name(name) for name in (".sentinel", *ROOT_RECORDS)
    }
    runs_quarantine = directory_quarantine_name("runs")
    allowed_children = ROOT_CHILDREN | (
        file_quarantines | {runs_quarantine} if cleanup else set()
    )
    unexpected = children - allowed_children
    if unexpected:
        refuse(f"unexpected-root-child-{sorted(unexpected)[0]}")
    if not cleanup and ".sentinel" not in children:
        refuse("missing-file-.sentinel")
    if ".sentinel" in children:
        content = read_regular_at(root_fd, ".sentinel", ".sentinel", 0o400)
        if content != canonical_bytes(root_sentinel(payload)):
            refuse("sentinel-content-invalid")
    if not cleanup and "runs" not in children:
        refuse("missing-directory-runs")
    if "runs" in children:
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        try:
            workspaces = set(os.listdir(runs_fd))
            case_quarantines = {directory_quarantine_name(name) for name in CASES}
            allowed_workspaces = set(CASES) | (case_quarantines if cleanup else set())
            unexpected_cases = workspaces - allowed_workspaces
            if unexpected_cases:
                refuse(f"unexpected-runs-child-{sorted(unexpected_cases)[0]}")
            for case_name in workspaces & set(CASES):
                workspace_fd = open_directory_at(runs_fd, case_name, case_name)
                try:
                    complete = f"{case_name}.record.json" in children
                    validate_workspace(workspace_fd, case_name, complete, cleanup)
                finally:
                    os.close(workspace_fd)
            for quarantine_name in workspaces & case_quarantines:
                quarantine_fd = open_directory_at(
                    runs_fd, quarantine_name, quarantine_name
                )
                try:
                    if os.listdir(quarantine_fd):
                        refuse(f"case-quarantine-not-empty-{quarantine_name}")
                finally:
                    os.close(quarantine_fd)
        finally:
            os.close(runs_fd)
    if runs_quarantine in children:
        quarantine_fd = open_directory_at(root_fd, runs_quarantine, runs_quarantine)
        try:
            if os.listdir(quarantine_fd):
                refuse("runs-quarantine-not-empty")
        finally:
            os.close(quarantine_fd)
    for record_name in children & set(ROOT_RECORDS):
        content = read_regular_at(root_fd, record_name, record_name)
        parse_json_bytes(content, record_name)
    for quarantine_name in children & file_quarantines:
        expected_mode = (
            0o400
            if quarantine_name == file_quarantine_name(".sentinel")
            else 0o600
        )
        descriptor = open_regular_at(
            root_fd, quarantine_name, quarantine_name, expected_mode
        )
        os.close(descriptor)


def scan_orphan_roots() -> list[str]:
    roots: list[str] = []
    with os.scandir("/tmp") as entries:
        for entry in entries:
            candidate = f"/tmp/{entry.name}"
            if ROOT_PATTERN.fullmatch(candidate) or PRIVATE_REGRESSION_QUARANTINE_PATTERN.fullmatch(
                candidate
            ):
                roots.append(candidate)
    return sorted(roots)


def scan_state_recovery_paths() -> list[str]:
    paths: list[str] = []
    with os.scandir("/tmp") as entries:
        for entry in entries:
            candidate = f"/tmp/{entry.name}"
            if STATE_RECOVERY_PATTERN.fullmatch(candidate):
                paths.append(candidate)
    return sorted(paths)


@dataclass
class LockedState:
    state_fd: int
    lock_fd: int
    root_fd: int | None
    root_location: Path | None
    cleanup: bool
    payload: dict[str, Any]


@contextlib.contextmanager
def locked_state() -> Iterator[LockedState]:
    state_fd, _ = open_directory_path(STATE_PATH, "state")
    lock_fd = -1
    root_fd: int | None = None
    root_location: Path | None = None
    try:
        state_children = set(os.listdir(state_fd))
        allowed_state_children = {"descriptor.json", "lock", CLEANUP_INTENT}
        if not {"descriptor.json", "lock"} <= state_children or not state_children <= allowed_state_children:
            extra = sorted(state_children - allowed_state_children)
            refuse(f"state-layout-invalid-{extra[0] if extra else 'missing-entry'}")
        lock_fd = open_regular_at(state_fd, "lock", "state-lock")
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            refuse("lab-state-is-busy", EX_TEMPFAIL)
        descriptor_bytes = read_regular_at(state_fd, "descriptor.json", "descriptor.json")
        payload = parse_json_bytes(descriptor_bytes, "descriptor.json")
        validate_descriptor(payload)
        state_info = os.fstat(state_fd)
        if (state_info.st_dev, state_info.st_ino) != (
            payload["stateDevice"],
            payload["stateInode"],
        ):
            refuse("registered-state-identity-invalid")
        if read_descriptor_bytes(lock_fd, "state-lock") != descriptor_bytes:
            refuse("state-lock-payload-invalid")
        validate_current_sources(payload)
        cleanup = CLEANUP_INTENT in state_children
        if cleanup:
            intent_bytes = read_regular_at(
                state_fd, CLEANUP_INTENT, CLEANUP_INTENT
            )
            validate_cleanup_intent(intent_bytes, payload, descriptor_bytes)
        root_candidates = [Path(payload["root"])]
        if cleanup:
            root_candidates.extend(
                [Path(payload["rootCleanup"]), Path(payload["rootFinal"])]
            )
        existing_roots = [path for path in root_candidates if os.path.lexists(path)]
        if len(existing_roots) > 1:
            refuse("multiple-registered-root-stages-present")
        if existing_roots:
            root_location = existing_roots[0]
            root_fd, opened = open_directory_path(root_location, "registered-root")
            if (opened.st_dev, opened.st_ino) != (
                payload["rootDevice"],
                payload["rootInode"],
            ):
                refuse("registered-root-identity-invalid")
            validate_root_contents(root_fd, payload, cleanup)
        elif not cleanup:
            refuse("registered-root-missing")
        yield LockedState(
            state_fd, lock_fd, root_fd, root_location, cleanup, payload
        )
    finally:
        if root_fd is not None:
            os.close(root_fd)
        if lock_fd >= 0:
            os.close(lock_fd)
        os.close(state_fd)


def command_check() -> None:
    state_exists = os.path.lexists(STATE_PATH)
    recovery_paths = scan_state_recovery_paths()
    roots = scan_orphan_roots()
    if state_exists:
        state_value = "present"
    elif recovery_paths:
        state_value = "cleanup-recovery"
    else:
        state_value = "absent"
    emit(
        [
            ("lesson", LESSON),
            ("state", state_value),
            ("state_recovery_count", len(recovery_paths)),
            ("orphan_count", len(roots)),
            ("normal_user_required", True),
            ("network_required", False),
        ]
    )


def rollback_setup(root_path: Path | None, state_created: bool) -> None:
    """Best-effort, exact-name rollback; never recurse or guess ownership."""

    if state_created and os.path.lexists(STATE_PATH):
        try:
            state_fd, _ = open_directory_path(STATE_PATH, "setup-rollback-state")
            try:
                children = set(os.listdir(state_fd))
                if children <= {"lock", "descriptor.json"}:
                    remove_regular_if_present(state_fd, "descriptor.json", "descriptor.json")
                    remove_regular_if_present(state_fd, "lock", "state-lock")
                    if not os.listdir(state_fd):
                        tmp_fd = open_tmp_parent()
                        try:
                            rmdir_empty_bound(
                                tmp_fd,
                                STATE_PATH.name,
                                state_fd,
                                "setup-rollback-state",
                            )
                        finally:
                            os.close(tmp_fd)
            finally:
                os.close(state_fd)
        except (LabRefusal, OSError):
            pass
    if root_path is not None and os.path.lexists(root_path):
        try:
            root_fd, _ = open_directory_path(root_path, "setup-rollback-root")
            try:
                if set(os.listdir(root_fd)) <= {".sentinel", "runs"}:
                    remove_regular_if_present(root_fd, ".sentinel", ".sentinel", 0o400)
                    if "runs" in set(os.listdir(root_fd)):
                        runs_fd = open_directory_at(root_fd, "runs", "runs")
                        try:
                            if not os.listdir(runs_fd):
                                rmdir_empty_bound(root_fd, "runs", runs_fd, "runs")
                        finally:
                            os.close(runs_fd)
                    if not os.listdir(root_fd):
                        tmp_fd = open_tmp_parent()
                        try:
                            rmdir_empty_bound(
                                tmp_fd, root_path.name, root_fd, "setup-rollback-root"
                            )
                        finally:
                            os.close(tmp_fd)
            finally:
                os.close(root_fd)
        except (LabRefusal, OSError):
            pass


def command_setup() -> None:
    if os.path.lexists(STATE_PATH):
        refuse("state-already-exists", EX_CANTCREAT)
    if scan_state_recovery_paths():
        refuse("cleanup-recovery-state-exists", EX_CANTCREAT)
    roots = scan_orphan_roots()
    if roots:
        refuse("unregistered-lesson-root-found-refusing-to-guess", EX_CANTCREAT)
    sources = source_manifest()
    if os.environ.get("LAB_DRY_RUN") == "1":
        emit(
            [
                ("lesson", LESSON),
                ("dry_run", True),
                ("would_create_state", STATE_PATH),
                ("source_manifest_sha256", source_manifest_digest(sources)),
                ("mutation_performed", False),
            ]
        )
        return

    root_path: Path | None = None
    state_created = False
    state_info: os.stat_result | None = None
    try:
        lifecycle_token = secrets.token_hex(16)
        root_path = Path(tempfile.mkdtemp(prefix=ROOT_PREFIX_NAME, dir="/tmp"))
        os.chmod(root_path, 0o700, follow_symlinks=False)
        root_fd, root_info = open_directory_path(root_path, "new-root")
        try:
            os.mkdir("runs", 0o700, dir_fd=root_fd)
            os.mkdir(STATE_PATH, 0o700)
            state_created = True
            state_fd, _ = open_directory_path(STATE_PATH, "new-state")
            try:
                state_info = os.fstat(state_fd)
                state_identity = f"{state_info.st_dev:x}.{state_info.st_ino:x}"
                payload = {
                    "lesson": LESSON,
                    "lifecycleToken": lifecycle_token,
                    "phase": "active",
                    "root": str(root_path),
                    "rootCleanup": f"{root_path}_cleanup_{lifecycle_token}",
                    "rootDevice": root_info.st_dev,
                    "rootFinal": f"{root_path}_final_{lifecycle_token}",
                    "rootInode": root_info.st_ino,
                    "schemaVersion": SCHEMA_VERSION,
                    "sources": sources,
                    "stateCleanup": f"{STATE_PATH}.cleanup.{lifecycle_token}.{state_identity}",
                    "stateDevice": state_info.st_dev,
                    "stateFinal": f"{STATE_PATH}.final.{lifecycle_token}.{state_identity}",
                    "stateInode": state_info.st_ino,
                    "uid": CURRENT_UID,
                }
                descriptor_bytes = canonical_bytes(payload)
                write_new_at(state_fd, "lock", descriptor_bytes)
                write_new_at(state_fd, "descriptor.json", descriptor_bytes)
                write_new_at(
                    root_fd,
                    ".sentinel",
                    canonical_bytes(root_sentinel(payload)),
                    0o400,
                )
            finally:
                os.close(state_fd)
        finally:
            os.close(root_fd)
    except Exception:
        rollback_setup(root_path, state_created)
        raise

    emit(
        [
            ("lesson", LESSON),
            ("setup_complete", True),
            ("root", root_path),
            ("root_identity", f"{root_info.st_dev}:{root_info.st_ino}"),
            ("state", STATE_PATH),
            ("state_identity", f"{state_info.st_dev}:{state_info.st_ino}"),
            ("lifecycle_token", lifecycle_token),
            ("state_cleanup", payload["stateCleanup"]),
            ("state_final", payload["stateFinal"]),
            ("source_manifest_sha256", source_manifest_digest(sources)),
            ("network_targets", 0),
        ]
    )


def read_source_config() -> dict[str, Any]:
    path = BASE / "config/scenario.json"
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise LabRefusal("invalid-source-configuration") from error
    if not isinstance(payload, dict):
        refuse("invalid-source-configuration")
    return payload


def ordered_timestamp_rows(rows: list[dict[str, Any]], label: str) -> None:
    previous_sequence = -1
    for row in rows:
        sequence = row.get("sequence")
        if not isinstance(sequence, int) or sequence <= previous_sequence:
            refuse(f"sequence-order-invalid-{label}")
        previous_sequence = sequence
        event_time = row.get("eventTime")
        observed_time = row.get("observedTime")
        ingest_time = row.get("ingestTime")
        if not all(isinstance(value, str) for value in (event_time, observed_time, ingest_time)):
            refuse(f"timestamp-missing-{label}")
        if not event_time <= observed_time <= ingest_time:
            refuse(f"timestamp-order-invalid-{label}")


def artifact_digests(workspace_fd: int) -> dict[str, str]:
    return {
        name: sha256_bytes(read_regular_at(workspace_fd, name, name))
        for name in OUTPUT_FILES
    }


def validate_case_artifacts(
    root_fd: int, case_name: str
) -> tuple[dict[str, Any], dict[str, Any]]:
    runs_fd = open_directory_at(root_fd, "runs", "runs")
    try:
        workspace_fd = open_directory_at(runs_fd, case_name, case_name)
    finally:
        os.close(runs_fd)
    try:
        validate_workspace(workspace_fd, case_name, complete=True)
        raw = {name: read_regular_at(workspace_fd, name, name) for name in OUTPUT_FILES}
        combined = b"".join(raw.values())
        if b"synthetic-user@example.invalid" in combined:
            refuse(f"raw-synthetic-identifier-leaked-{case_name}")
        if b'"traceId"' in combined or b'"spanId"' in combined:
            refuse(f"standard-trace-field-implied-{case_name}")

        metrics = parse_json_bytes(raw["metrics.json"], "metrics.json")
        logs = parse_ndjson_bytes(raw["logs.ndjson"], "logs.ndjson")
        traces = parse_ndjson_bytes(raw["traces.ndjson"], "traces.ndjson")
        events = parse_ndjson_bytes(raw["events.ndjson"], "events.ndjson")
        profile = parse_json_bytes(raw["profile.json"], "profile.json")
        counters = parse_json_bytes(raw["pipeline-counters.json"], "pipeline-counters.json")
        cardinality = parse_json_bytes(raw["cardinality.json"], "cardinality.json")
        retention = parse_json_bytes(raw["retention.json"], "retention.json")
        privacy = parse_json_bytes(raw["privacy.json"], "privacy.json")
        evidence = parse_json_bytes(raw["evidence-limits.json"], "evidence-limits.json")
        manifest = parse_json_bytes(raw["signal-manifest.json"], "signal-manifest.json")
        report = parse_json_bytes(raw["case-report.json"], "case-report.json")

        expected_trace_sequences = (
            [1, 2, 3, 4, 5, 6, 7, 8]
            if case_name == "guided"
            else [1, 2, 4, 5, 6, 8]
        )
        if metrics.get("counters") != {
            "errors": 1,
            "latencyBreaches": 1,
            "queueBreaches": 2,
            "requests": 8,
        }:
            refuse(f"metric-counters-invalid-{case_name}")
        if metrics.get("latencyMs") != {
            "max": 465,
            "p50NearestRank": 65,
            "p95NearestRank": 465,
            "values": [45, 50, 62, 65, 100, 270, 295, 465],
        }:
            refuse(f"latency-metrics-invalid-{case_name}")
        if metrics.get("queueMs") != {
            "max": 260,
            "p50NearestRank": 12,
            "p95NearestRank": 260,
            "values": [5, 5, 10, 12, 15, 20, 240, 260],
        }:
            refuse(f"queue-metrics-invalid-{case_name}")
        if [row.get("sequence") for row in logs] != list(range(1, 9)):
            refuse(f"log-sequences-invalid-{case_name}")
        if [row.get("sequence") for row in traces] != expected_trace_sequences:
            refuse(f"trace-sequences-invalid-{case_name}")
        if [row.get("sequence") for row in events] != [0, 3, 4]:
            refuse(f"event-sequences-invalid-{case_name}")
        ordered_timestamp_rows(logs, f"logs-{case_name}")
        ordered_timestamp_rows(traces, f"traces-{case_name}")
        ordered_timestamp_rows(events, f"events-{case_name}")
        ingest_order = [
            row["sequence"] for row in sorted(logs, key=lambda row: row["ingestTime"])
        ]
        if ingest_order != [1, 3, 4, 5, 6, 2, 7, 8]:
            refuse(f"ingest-reordering-invalid-{case_name}")
        queue_by_sequence = {1: 5, 2: 10, 3: 260, 4: 20, 5: 240, 6: 15, 7: 5, 8: 12}
        service_by_sequence = {1: 40, 2: 55, 3: 35, 4: 80, 5: 30, 6: 450, 7: 45, 8: 50}
        for trace in traces:
            sequence = trace["sequence"]
            queue_ms = queue_by_sequence[sequence]
            service_ms = service_by_sequence[sequence]
            root_key = f"span-key-{sequence:04d}-r"
            expected_spans = [
                {
                    "durationMs": queue_ms + service_ms,
                    "name": "request.total",
                    "parentSyntheticSpanKey": None,
                    "startOffsetMs": 0,
                    "syntheticSpanKey": root_key,
                },
                {
                    "durationMs": queue_ms,
                    "name": "queue.wait",
                    "parentSyntheticSpanKey": root_key,
                    "startOffsetMs": 0,
                    "syntheticSpanKey": f"span-key-{sequence:04d}-q",
                },
                {
                    "durationMs": service_ms,
                    "name": "service.handle",
                    "parentSyntheticSpanKey": root_key,
                    "startOffsetMs": queue_ms,
                    "syntheticSpanKey": f"span-key-{sequence:04d}-s",
                },
            ]
            if trace.get("spans") != expected_spans:
                refuse(f"trace-topology-invalid-{case_name}-{sequence}")
        if any(row.get("customerEmail") != "[REDACTED]" for row in logs):
            refuse(f"log-redaction-invalid-{case_name}")
        if profile.get("functions") != [
            {"callCount": 12, "name": "checksum_step"},
            {"callCount": 1, "name": "profile_work"},
        ] or profile.get("timingFieldsOmitted") is not True:
            refuse(f"profile-summary-invalid-{case_name}")
        if cardinality.get("requestIdAsMetricLabel") is not False or cardinality.get(
            "actualBoundedSeries"
        ) != 3:
            refuse(f"cardinality-model-invalid-{case_name}")
        if privacy.get("rawSyntheticValuePresent") is not False or privacy.get(
            "redactedLogRows"
        ) != 8:
            refuse(f"privacy-model-invalid-{case_name}")
        retained = {
            name: details.get("retainedAtAnalysisTime")
            for name, details in retention.get("signals", {}).items()
        }
        if retained != {
            "events": True,
            "logs": True,
            "metrics": True,
            "profiles": False,
            "traces": False,
        }:
            refuse(f"retention-model-invalid-{case_name}")
        if evidence.get("correlationIsCausality") is not False or evidence.get(
            "traceContextStandard"
        ) != "none; synthetic keys are not W3C traceparent identifiers":
            refuse(f"evidence-boundary-invalid-{case_name}")

        trace_stage = counters.get("stages", {}).get("traces", {})
        expected_drop = 0 if case_name == "guided" else 2
        if trace_stage.get("produced") != 8 or trace_stage.get("exported") != len(
            traces
        ) or trace_stage.get("dropped") != expected_drop:
            refuse(f"pipeline-counters-invalid-{case_name}")
        if case_name == "guided":
            if trace_stage.get("dropReason") is not None or trace_stage.get(
                "droppedSequences"
            ) != []:
                refuse("guided-pipeline-drop-invalid")
        elif trace_stage.get("dropReason") != "export_queue_full" or trace_stage.get(
            "droppedSequences"
        ) != [3, 7]:
            refuse("missing-signal-pipeline-drop-invalid")

        entries = manifest.get("entries")
        if manifest.get("case") != case_name or not isinstance(entries, dict) or set(
            entries
        ) != set(MANIFEST_FILES):
            refuse(f"manifest-layout-invalid-{case_name}")
        expected_rows = {
            "cardinality.json": 1,
            "events.ndjson": 3,
            "evidence-limits.json": 6,
            "logs.ndjson": 8,
            "metrics.json": 1,
            "pipeline-counters.json": 5,
            "privacy.json": 1,
            "profile.json": 2,
            "retention.json": 5,
            "traces.ndjson": len(traces),
        }
        for name in MANIFEST_FILES:
            if entries[name] != {
                "rowCount": expected_rows[name],
                "sha256": sha256_bytes(raw[name]),
            }:
                refuse(f"manifest-entry-invalid-{case_name}-{name}")
        if report.get("case") != case_name or report.get("files") != list(OUTPUT_FILES):
            refuse(f"case-report-invalid-{case_name}")
        if report.get("networkTargets") != [] or report.get("secretInputs") != []:
            refuse(f"external-input-boundary-invalid-{case_name}")
        if report.get("correlationIsCausality") is not False:
            refuse(f"correlation-claim-invalid-{case_name}")

        result = {
            "metrics": metrics,
            "logs": logs,
            "traces": traces,
            "events": events,
            "profile": profile,
            "counters": counters,
            "cardinality": cardinality,
            "retention": retention,
            "privacy": privacy,
            "evidence": evidence,
            "manifest": manifest,
            "report": report,
        }
        return result, {name: sha256_bytes(content) for name, content in raw.items()}
    finally:
        os.close(workspace_fd)


def require_root(state: LockedState) -> int:
    if state.cleanup:
        refuse("cleanup-in-progress", EX_USAGE)
    if state.root_fd is None:
        refuse("registered-root-missing")
    return state.root_fd


def record_name(case_name: str) -> str:
    return f"{case_name}.record.json"


def config_sha256() -> str:
    return sha256_path(BASE / "config/scenario.json")


def case_record_payload(
    state: LockedState,
    case_name: str,
    artifacts: dict[str, Any],
    digests: dict[str, str],
) -> dict[str, Any]:
    return {
        "artifactDigests": digests,
        "case": case_name,
        "configSha256": config_sha256(),
        "eventRows": len(artifacts["events"]),
        "logRows": len(artifacts["logs"]),
        "reportSha256": digests["case-report.json"],
        "schemaVersion": SCHEMA_VERSION,
        "sourceManifestSha256": source_manifest_digest(state.payload["sources"]),
        "traceRows": len(artifacts["traces"]),
    }


def load_case_record(
    state: LockedState, case_name: str
) -> tuple[bytes, dict[str, Any], dict[str, Any], dict[str, str]]:
    root_fd = require_root(state)
    name = record_name(case_name)
    content = read_regular_at(root_fd, name, name)
    record = parse_json_bytes(content, name)
    expected_keys = {
        "artifactDigests",
        "case",
        "configSha256",
        "eventRows",
        "logRows",
        "reportSha256",
        "schemaVersion",
        "sourceManifestSha256",
        "traceRows",
    }
    if set(record) != expected_keys or record.get("schemaVersion") != SCHEMA_VERSION:
        refuse(f"case-record-layout-invalid-{case_name}")
    if record.get("case") != case_name or record.get("configSha256") != config_sha256():
        refuse(f"case-record-identity-invalid-{case_name}")
    if record.get("sourceManifestSha256") != source_manifest_digest(
        state.payload["sources"]
    ):
        refuse(f"case-record-source-invalid-{case_name}")
    artifacts, digests = validate_case_artifacts(root_fd, case_name)
    expected = case_record_payload(state, case_name, artifacts, digests)
    if record != expected:
        refuse(f"case-record-evidence-invalid-{case_name}")
    return content, record, artifacts, digests


def child_environment() -> dict[str, str]:
    return {
        "LANG": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        "PATH": "/usr/bin:/bin",
        "PYTHONDONTWRITEBYTECODE": "1",
        "PYTHONHASHSEED": "0",
    }


def command_run(case_name: str) -> None:
    with locked_state() as state:
        if state.cleanup:
            refuse("cleanup-in-progress", EX_USAGE)
        root_fd = require_root(state)
        children = set(os.listdir(root_fd))
        if record_name(case_name) in children:
            refuse(f"record-already-exists-{record_name(case_name)}", EX_USAGE)
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        try:
            if case_name in set(os.listdir(runs_fd)):
                refuse(f"workspace-already-exists-{case_name}-cleanup-required", EX_USAGE)
            os.mkdir(case_name, 0o700, dir_fd=runs_fd)
        finally:
            os.close(runs_fd)

        workspace = f"/proc/self/fd/{root_fd}/runs/{case_name}"
        command = [
            sys.executable,
            "-S",
            str(BASE / "model/telemetry_model.py"),
            "--case",
            case_name,
            "--config",
            str(BASE / "config/scenario.json"),
            "--workspace",
            workspace,
        ]
        completed = subprocess.run(
            command,
            cwd=BASE,
            env=child_environment(),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=20,
            check=False,
            pass_fds=(root_fd,),
        )
        if completed.returncode != 0:
            refuse(f"telemetry-model-failed-{case_name}-{completed.returncode}")
        validate_current_sources(state.payload)
        artifacts, digests = validate_case_artifacts(root_fd, case_name)
        expected_stdout = canonical_bytes(artifacts["report"])
        if completed.stdout != expected_stdout or completed.stderr:
            refuse(f"telemetry-model-output-invalid-{case_name}")
        record = case_record_payload(state, case_name, artifacts, digests)
        write_new_at(root_fd, record_name(case_name), canonical_bytes(record))
        emit(
            [
                ("case", case_name),
                ("request_rows", 8),
                ("log_rows", len(artifacts["logs"])),
                ("trace_rows", len(artifacts["traces"])),
                ("event_rows", len(artifacts["events"])),
                ("profile_kind", artifacts["profile"]["kind"]),
                ("external_targets", 0),
                ("run_complete", True),
            ]
        )


def command_status() -> None:
    with locked_state() as state:
        root_fd = require_root(state)
        children = set(os.listdir(root_fd))
        cases = [case for case in CASES if record_name(case) in children]
        stages = [
            name
            for name in (
                "guided-verification.json",
                "missing-signal-attempt.json",
                "missing-signal-inspection.json",
                "operation-verification.json",
            )
            if name in children
        ]
        emit(
            [
                ("lesson", LESSON),
                ("phase", "cleanup" if state.cleanup else "active"),
                ("root", state.payload["root"]),
                ("completed_cases", cases),
                ("evidence_stages", stages),
                ("state_validated", True),
            ]
        )


def command_inspect_signals(case_name: str) -> None:
    with locked_state() as state:
        _record_bytes, _record, artifacts, _digests = load_case_record(state, case_name)
        missing = 8 - len(artifacts["traces"])
        pairs: list[tuple[str, object]] = [
            ("case", case_name),
            ("metric_request_count", 8),
            ("metric_error_count", 1),
            ("log_rows", len(artifacts["logs"])),
            ("trace_rows", len(artifacts["traces"])),
            ("event_rows", len(artifacts["events"])),
            ("profile_function_rows", len(artifacts["profile"]["functions"])),
            ("missing_trace_rows", missing),
            ("timestamps", "event,observed,ingest"),
            ("correlation_keys", "requestId,syntheticTraceKey,sequence"),
            ("trace_context_standard", "none-synthetic-keys-only"),
            ("correlation_is_causality", False),
        ]
        if missing:
            pairs.extend(
                [
                    ("cause_determined", False),
                    (
                        "candidate_causes",
                        HYPOTHESES,
                    ),
                    ("next_evidence", "record-hypothesis-then-inspect-pipeline"),
                ]
            )
        else:
            pairs.extend(
                [
                    ("latency_breach_sequence", 6),
                    ("error_sequence", 4),
                    ("queue_breach_sequences", [3, 5]),
                    ("cause_determined", False),
                ]
            )
        emit(pairs)


def command_inspect_ordering() -> None:
    with locked_state() as state:
        _record_bytes, _record, artifacts, _digests = load_case_record(
            state, "guided"
        )
        logs = artifacts["logs"]
        sequence_order = [row["sequence"] for row in logs]
        event_order = [
            row["sequence"] for row in sorted(logs, key=lambda row: row["eventTime"])
        ]
        ingest_order = [
            row["sequence"] for row in sorted(logs, key=lambda row: row["ingestTime"])
        ]
        missing_sequences = sorted(set(range(1, 9)) - set(sequence_order))
        if sequence_order != list(range(1, 9)) or event_order != list(range(1, 9)):
            refuse("ordering-exercise-source-order-invalid")
        if ingest_order != [1, 3, 4, 5, 6, 2, 7, 8]:
            refuse("ordering-exercise-ingest-order-invalid")
        emit(
            [
                ("case", "guided"),
                ("sequence_order", sequence_order),
                ("event_time_order", event_order),
                ("ingest_time_order", ingest_order),
                ("missing_sequences", missing_sequences),
                ("ingest_reordered", True),
                ("fixture_explanation", "sequence-2-modeled-ingest-delay"),
                ("production_cause_proven", False),
            ]
        )


def command_verify_guided() -> None:
    with locked_state() as state:
        root_fd = require_root(state)
        if "guided-verification.json" in set(os.listdir(root_fd)):
            refuse("record-already-exists-guided-verification.json", EX_USAGE)
        case_bytes, _record, artifacts, digests = load_case_record(state, "guided")
        verification = {
            "artifactDigests": digests,
            "caseRecordSha256": sha256_bytes(case_bytes),
            "correlationIsCausality": False,
            "deterministicFailureSequences": {
                "error": [4],
                "latency": [6],
                "queue": [3, 5],
            },
            "localTeachingFixturePassed": True,
            "networkTargets": [],
            "productionCausalityProven": False,
            "schemaVersion": SCHEMA_VERSION,
            "syntheticTraceKeysAreW3CTraceIds": False,
            "vendorBehaviorProven": False,
        }
        if len(artifacts["traces"]) != 8 or len(artifacts["logs"]) != 8:
            refuse("guided-signal-completeness-invalid")
        write_new_at(root_fd, "guided-verification.json", canonical_bytes(verification))
        emit(
            [
                ("guided_verified", True),
                ("deterministic_latency_sequence", 6),
                ("deterministic_error_sequence", 4),
                ("deterministic_queue_sequences", [3, 5]),
                ("signal_families", "metrics,logs,traces,events,profiles"),
                ("correlation_is_causality", False),
                ("production_causality_proven", False),
            ]
        )


def command_record_hypothesis(hypothesis: str) -> None:
    with locked_state() as state:
        root_fd = require_root(state)
        if "missing-signal-attempt.json" in set(os.listdir(root_fd)):
            refuse("record-already-exists-missing-signal-attempt.json", EX_USAGE)
        case_bytes, _record, _artifacts, _digests = load_case_record(
            state, "missing-signal"
        )
        attempt = {
            "attemptedBeforeReveal": True,
            "case": "missing-signal",
            "caseRecordSha256": sha256_bytes(case_bytes),
            "hypothesis": hypothesis,
            "scoredAssessment": False,
            "schemaVersion": SCHEMA_VERSION,
        }
        write_new_at(
            root_fd, "missing-signal-attempt.json", canonical_bytes(attempt)
        )
        emit(
            [
                ("hypothesis_recorded", hypothesis),
                ("attempted_before_reveal", True),
                ("scored_assessment", False),
                ("next_command", "inspect-pipeline-missing-signal"),
            ]
        )


def command_inspect_pipeline(case_name: str) -> None:
    if case_name != "missing-signal":
        refuse("pipeline-inspection-is-for-missing-signal-case", EX_USAGE)
    with locked_state() as state:
        root_fd = require_root(state)
        if "missing-signal-inspection.json" in set(os.listdir(root_fd)):
            refuse("record-already-exists-missing-signal-inspection.json", EX_USAGE)
        case_bytes, _record, artifacts, digests = load_case_record(state, case_name)
        if "missing-signal-attempt.json" not in set(os.listdir(root_fd)):
            refuse("pipeline-reveal-requires-hypothesis-attempt", EX_USAGE)
        attempt_bytes = read_regular_at(
            root_fd, "missing-signal-attempt.json", "missing-signal-attempt.json"
        )
        attempt = parse_json_bytes(attempt_bytes, "missing-signal-attempt.json")
        if (
            attempt.get("attemptedBeforeReveal") is not True
            or attempt.get("caseRecordSha256") != sha256_bytes(case_bytes)
            or attempt.get("hypothesis") not in HYPOTHESES
            or attempt.get("scoredAssessment") is not False
        ):
            refuse("missing-signal-attempt-binding-invalid")
        trace_stage = artifacts["counters"]["stages"]["traces"]
        manifest_entry = artifacts["manifest"]["entries"]["traces.ndjson"]
        inspection = {
            "caseRecordSha256": sha256_bytes(case_bytes),
            "correlationIsCausality": False,
            "hypothesisAttemptSha256": sha256_bytes(attempt_bytes),
            "manifestTraceEntry": manifest_entry,
            "modeledExporterCounters": trace_stage,
            "productionAbsenceExplained": False,
            "schemaVersion": SCHEMA_VERSION,
            "traceArtifactSha256": digests["traces.ndjson"],
        }
        write_new_at(
            root_fd,
            "missing-signal-inspection.json",
            canonical_bytes(inspection),
        )
        emit(
            [
                ("case", case_name),
                ("walkthrough", True),
                ("attempt_recorded_before_reveal", True),
                ("pipeline_trace_produced", trace_stage["produced"]),
                ("pipeline_trace_exported", trace_stage["exported"]),
                ("pipeline_trace_dropped", trace_stage["dropped"]),
                ("modeled_drop_sequences", trace_stage["droppedSequences"]),
                ("modeled_drop_reason", trace_stage["dropReason"]),
                ("manifest_trace_rows", manifest_entry["rowCount"]),
                ("missing_signal_explained_for_fixture", True),
                ("production_absence_explained", False),
                ("correlation_is_causality", False),
            ]
        )


def command_verify_operation() -> None:
    with locked_state() as state:
        root_fd = require_root(state)
        children = set(os.listdir(root_fd))
        if "operation-verification.json" in children:
            refuse("record-already-exists-operation-verification.json", EX_USAGE)
        if "guided-verification.json" not in children:
            refuse("operation-requires-guided-verification", EX_USAGE)
        if "missing-signal-inspection.json" not in children:
            refuse("operation-requires-missing-signal-inspection", EX_USAGE)
        guided_case_bytes, _gr, _ga, guided_digests = load_case_record(state, "guided")
        missing_case_bytes, _mr, _ma, missing_digests = load_case_record(
            state, "missing-signal"
        )
        guided_verification_bytes = read_regular_at(
            root_fd, "guided-verification.json", "guided-verification.json"
        )
        guided_verification = parse_json_bytes(
            guided_verification_bytes, "guided-verification.json"
        )
        inspection_bytes = read_regular_at(
            root_fd,
            "missing-signal-inspection.json",
            "missing-signal-inspection.json",
        )
        inspection = parse_json_bytes(
            inspection_bytes, "missing-signal-inspection.json"
        )
        attempt_bytes = read_regular_at(
            root_fd, "missing-signal-attempt.json", "missing-signal-attempt.json"
        )
        if guided_verification.get("caseRecordSha256") != sha256_bytes(
            guided_case_bytes
        ) or guided_verification.get("artifactDigests") != guided_digests:
            refuse("guided-verification-binding-invalid")
        trace_stage = inspection.get("modeledExporterCounters", {})
        if inspection.get("caseRecordSha256") != sha256_bytes(
            missing_case_bytes
        ) or trace_stage != {
            "dropReason": "export_queue_full",
            "dropped": 2,
            "droppedSequences": [3, 7],
            "exported": 6,
            "produced": 8,
        }:
            refuse("missing-signal-inspection-binding-invalid")
        if inspection.get("traceArtifactSha256") != missing_digests["traces.ndjson"]:
            refuse("missing-signal-trace-binding-invalid")
        if inspection.get("hypothesisAttemptSha256") != sha256_bytes(attempt_bytes):
            refuse("missing-signal-attempt-inspection-binding-invalid")
        final = {
            "correlationIsCausality": False,
            "guidedVerificationSha256": sha256_bytes(guided_verification_bytes),
            "localVerificationPassed": True,
            "missingSignalInspectionSha256": sha256_bytes(inspection_bytes),
            "networkTargets": [],
            "productionCausalityProven": False,
            "schemaVersion": SCHEMA_VERSION,
            "vendorBehaviorProven": False,
        }
        write_new_at(root_fd, "operation-verification.json", canonical_bytes(final))
        emit(
            [
                ("guided_signal_families", "metrics,logs,traces,events,profiles"),
                ("deterministic_failures", "latency,error,queue"),
                ("missing_signal_diagnosed", "export_queue_full"),
                ("correlation_is_causality", False),
                ("vendor_behavior_proven", False),
                ("network_targets", 0),
                ("local_verification_passed", True),
            ]
        )


def remove_workspace(
    runs_fd: int, case_name: str, fault_state: dict[str, bool]
) -> None:
    original_present = True
    try:
        os.stat(case_name, dir_fd=runs_fd, follow_symlinks=False)
    except FileNotFoundError:
        original_present = False
    if original_present:
        workspace_fd = open_directory_at(runs_fd, case_name, case_name)
        try:
            validate_workspace(
                workspace_fd, case_name, complete=False, cleanup=True
            )
            for name in OUTPUT_FILES:
                had_entry = False
                for candidate in (name, file_quarantine_name(name)):
                    try:
                        os.stat(candidate, dir_fd=workspace_fd, follow_symlinks=False)
                        had_entry = True
                    except FileNotFoundError:
                        pass
                remove_regular_if_present(
                    workspace_fd, name, f"{case_name}-{name}"
                )
                if had_entry and not fault_state["artifact_removed"]:
                    fault_state["artifact_removed"] = True
                    maybe_inject_fault("after-first-artifact-removal")
            if os.listdir(workspace_fd):
                refuse(
                    f"workspace-not-empty-after-allowlisted-cleanup-{case_name}"
                )
        finally:
            os.close(workspace_fd)
    remove_empty_directory_if_present(runs_fd, case_name, case_name)


def cleanup_owned_root(state: LockedState) -> None:
    if state.root_fd is None:
        return
    root_fd = state.root_fd
    validate_root_contents(root_fd, state.payload, cleanup=True)

    # Remove records first. A workspace is considered complete only while its
    # case record exists, so interruption can never leave a record pointing at
    # partially deleted artifacts.
    for name in reversed(ROOT_RECORDS):
        remove_regular_if_present(root_fd, name, name)
    maybe_inject_fault("after-root-record-removal")

    if "runs" in set(os.listdir(root_fd)):
        runs_fd = open_directory_at(root_fd, "runs", "runs")
        try:
            fault_state = {"artifact_removed": False}
            for case_name in CASES:
                remove_workspace(runs_fd, case_name, fault_state)
            if os.listdir(runs_fd):
                refuse("runs-not-empty-after-allowlisted-cleanup")
        finally:
            os.close(runs_fd)
    remove_empty_directory_if_present(root_fd, "runs", "runs")
    remove_regular_if_present(root_fd, ".sentinel", ".sentinel", 0o400)
    if os.listdir(root_fd):
        refuse("root-not-empty-after-allowlisted-cleanup")

    if state.root_location is None:
        refuse("registered-root-location-missing")
    tmp_fd = open_tmp_parent()
    try:
        original = Path(state.payload["root"])
        cleanup_path = Path(state.payload["rootCleanup"])
        final_path = Path(state.payload["rootFinal"])
        if state.root_location == original:
            rename_directory_bound(
                tmp_fd,
                original.name,
                cleanup_path.name,
                root_fd,
                "registered-root",
            )
            state.root_location = cleanup_path
            maybe_inject_fault("after-root-quarantine")
        if state.root_location == cleanup_path:
            rename_directory_bound(
                tmp_fd,
                cleanup_path.name,
                final_path.name,
                root_fd,
                "registered-root-final",
            )
            state.root_location = final_path
            maybe_inject_fault("before-root-final-rmdir")
        if state.root_location != final_path:
            refuse("registered-root-stage-invalid")
        rmdir_recovery_directory(
            tmp_fd, final_path.name, root_fd, "registered-root-final"
        )
        state.root_location = None
    finally:
        os.close(tmp_fd)


def state_cleanup_allowed_children() -> set[str]:
    logical = {"descriptor.json", "lock", CLEANUP_INTENT}
    return logical | {file_quarantine_name(name) for name in logical}


def existing_regular_name(parent_fd: int, logical_name: str) -> str | None:
    present: list[str] = []
    for candidate in (logical_name, file_quarantine_name(logical_name)):
        try:
            os.stat(candidate, dir_fd=parent_fd, follow_symlinks=False)
            present.append(candidate)
        except FileNotFoundError:
            pass
    if len(present) > 1:
        refuse(f"original-and-quarantine-both-present-{logical_name}")
    return present[0] if present else None


def validate_state_recovery_path(
    path: Path, state_fd: int
) -> re.Match[str]:
    match = STATE_RECOVERY_PATTERN.fullmatch(str(path))
    if match is None:
        refuse("state-recovery-path-invalid")
    info = os.fstat(state_fd)
    validate_directory_info(info, "state-recovery")
    if (info.st_dev, info.st_ino) != (
        int(match.group("device"), 16),
        int(match.group("inode"), 16),
    ):
        refuse("state-recovery-identity-invalid")
    children = set(os.listdir(state_fd))
    unexpected = children - state_cleanup_allowed_children()
    if unexpected:
        refuse(f"unexpected-state-recovery-child-{sorted(unexpected)[0]}")
    return match


def load_state_recovery_authority(
    state_fd: int, path: Path, match: re.Match[str]
) -> tuple[dict[str, Any] | None, bytes | None, int]:
    authority_contents: list[bytes] = []
    for logical_name in ("descriptor.json", "lock"):
        actual_name = existing_regular_name(state_fd, logical_name)
        if actual_name is not None:
            authority_contents.append(
                read_regular_at(state_fd, actual_name, actual_name)
            )
    if authority_contents and any(
        content != authority_contents[0] for content in authority_contents[1:]
    ):
        refuse("state-recovery-authority-disagrees")
    authority_bytes = authority_contents[0] if authority_contents else None
    payload: dict[str, Any] | None = None
    if authority_bytes is not None:
        payload = parse_json_bytes(authority_bytes, "state-recovery-authority")
        validate_descriptor(payload)
        validate_current_sources(payload)
        if payload["lifecycleToken"] != match.group("token"):
            refuse("state-recovery-token-invalid")
        if (payload["stateDevice"], payload["stateInode"]) != (
            int(match.group("device"), 16),
            int(match.group("inode"), 16),
        ):
            refuse("state-recovery-payload-identity-invalid")
        expected_path = (
            payload["stateCleanup"]
            if match.group("stage") == "cleanup"
            else payload["stateFinal"]
        )
        if str(path) != expected_path:
            refuse("state-recovery-payload-path-invalid")
        intent_name = existing_regular_name(state_fd, CLEANUP_INTENT)
        if intent_name is not None:
            validate_cleanup_intent(
                read_regular_at(state_fd, intent_name, intent_name),
                payload,
                authority_bytes,
            )

    lock_fd = -1
    lock_name = existing_regular_name(state_fd, "lock")
    if lock_name is not None:
        lock_fd = open_regular_at(state_fd, lock_name, "state-recovery-lock")
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            os.close(lock_fd)
            refuse("lab-state-is-busy", EX_TEMPFAIL)
    return payload, authority_bytes, lock_fd


def finish_state_directory_cleanup(
    state_fd: int,
    lock_fd: int,
    payload: dict[str, Any] | None,
    current_path: Path,
) -> None:
    match = validate_state_recovery_path(current_path, state_fd)
    remove_regular_if_present(state_fd, CLEANUP_INTENT, CLEANUP_INTENT)
    remove_regular_if_present(state_fd, "descriptor.json", "descriptor.json")
    maybe_inject_fault("after-state-descriptor-removal")
    remove_regular_if_present(state_fd, "lock", "state-lock")
    if lock_fd >= 0 and os.fstat(lock_fd).st_nlink != 0:
        refuse("state-lock-unlink-not-proven")
    maybe_inject_fault("after-state-lock-removal")
    if os.listdir(state_fd):
        refuse("state-not-empty-after-allowlisted-cleanup")

    if payload is not None:
        final_path = Path(payload["stateFinal"])
    else:
        final_path = Path(
            str(current_path).replace(".state.d.cleanup.", ".state.d.final.", 1)
        )
    if STATE_RECOVERY_PATTERN.fullmatch(str(final_path)) is None:
        refuse("state-final-path-invalid")
    tmp_fd = open_tmp_parent()
    try:
        if match.group("stage") == "cleanup":
            rename_directory_bound(
                tmp_fd,
                current_path.name,
                final_path.name,
                state_fd,
                "state-directory-final",
            )
            current_path = final_path
            maybe_inject_fault("before-state-final-rmdir")
        if current_path != final_path:
            refuse("state-recovery-stage-invalid")
        rmdir_recovery_directory(
            tmp_fd, final_path.name, state_fd, "state-directory-final"
        )
    finally:
        os.close(tmp_fd)


def recover_state_cleanup(path: Path, expected_token: str | None) -> None:
    state_fd, _ = open_directory_path(path, "state-recovery")
    lock_fd = -1
    try:
        match = validate_state_recovery_path(path, state_fd)
        if expected_token is not None and match.group("token") != expected_token:
            refuse("cleanup-instance-mismatch", EX_NOPERM)
        payload, _authority, lock_fd = load_state_recovery_authority(
            state_fd, path, match
        )
        if payload is not None:
            registered_paths = {
                payload["root"],
                payload["rootCleanup"],
                payload["rootFinal"],
            }
            if any(os.path.lexists(candidate) for candidate in registered_paths):
                refuse("registered-root-remains-before-state-recovery")
        elif scan_orphan_roots():
            refuse("orphan-root-remains-before-state-recovery")
        finish_state_directory_cleanup(state_fd, lock_fd, payload, path)
    finally:
        if lock_fd >= 0:
            os.close(lock_fd)
        os.close(state_fd)


def prove_cleanup_absence() -> None:
    if (
        os.path.lexists(STATE_PATH)
        or scan_state_recovery_paths()
        or scan_orphan_roots()
    ):
        refuse("cleanup-final-absence-not-proven")


def emit_cleanup_success() -> None:
    emit(
        [
            ("lesson", LESSON),
            ("cleanup_proven", True),
            ("state", "absent"),
            ("state_recovery_count", 0),
            ("orphan_count", 0),
        ]
    )


def command_cleanup(expected_token: str | None = None) -> None:
    validate_fault_request()
    if expected_token is not None and re.fullmatch(r"[0-9a-f]{32}", expected_token) is None:
        refuse("cleanup-expected-token-invalid", EX_USAGE)
    recovery_paths = scan_state_recovery_paths()
    if not os.path.lexists(STATE_PATH):
        if len(recovery_paths) > 1:
            refuse("multiple-state-recovery-paths-present")
        if recovery_paths:
            recovery_path = Path(recovery_paths[0])
            if os.environ.get("LAB_DRY_RUN") == "1":
                emit(
                    [
                        ("lesson", LESSON),
                        ("dry_run", True),
                        ("would_resume_state", recovery_path),
                        ("mutation_performed", False),
                    ]
                )
                return
            recover_state_cleanup(recovery_path, expected_token)
            prove_cleanup_absence()
            emit_cleanup_success()
            return
        roots = scan_orphan_roots()
        if roots:
            refuse("unregistered-lesson-root-found-refusing-to-guess")
        emit_cleanup_success()
        return

    if recovery_paths:
        refuse("canonical-and-recovery-state-both-present")
    with locked_state() as state:
        if expected_token is not None and state.payload["lifecycleToken"] != expected_token:
            refuse("cleanup-instance-mismatch", EX_NOPERM)
        if os.environ.get("LAB_DRY_RUN") == "1":
            emit(
                [
                    ("lesson", LESSON),
                    ("dry_run", True),
                    ("would_remove_root", state.payload["root"]),
                    ("would_remove_state", STATE_PATH),
                    ("cleanup_strategy", "exact-allowlist-restartable"),
                    ("mutation_performed", False),
                ]
            )
            return
        if not state.cleanup:
            descriptor_bytes = read_regular_at(
                state.state_fd, "descriptor.json", "descriptor.json"
            )
            write_new_at(
                state.state_fd,
                CLEANUP_INTENT,
                canonical_bytes(
                    cleanup_intent_payload(state.payload, descriptor_bytes)
                ),
            )
            state.cleanup = True
            maybe_inject_fault("after-cleanup-intent")

        cleanup_owned_root(state)
        if state.root_location is not None:
            refuse("registered-root-removal-not-proven")

        state_cleanup_path = Path(state.payload["stateCleanup"])
        tmp_fd = open_tmp_parent()
        try:
            rename_directory_bound(
                tmp_fd,
                STATE_PATH.name,
                state_cleanup_path.name,
                state.state_fd,
                "state-directory",
            )
        finally:
            os.close(tmp_fd)
        maybe_inject_fault("after-state-quarantine")
        finish_state_directory_cleanup(
            state.state_fd,
            state.lock_fd,
            state.payload,
            state_cleanup_path,
        )
    prove_cleanup_absence()
    emit_cleanup_success()


def expect_identity_change(callback: Callable[[], None], label: str) -> None:
    try:
        callback()
    except LabRefusal as error:
        if error.token != f"deletion-target-identity-changed-{label}" or error.status != EX_TEMPFAIL:
            raise
    else:
        refuse(f"replacement-race-not-detected-{label}")


def finalize_private_regression_root(
    root_path: Path,
    root_fd: int,
    root_info: os.stat_result,
    regular_files: dict[str, int],
    directories: tuple[str, ...],
) -> None:
    """Remove only a bound regression root's known entries; preserve surprises."""

    if root_path.parent != Path("/tmp") or ROOT_PATTERN.fullmatch(str(root_path)) is None:
        refuse("private-regression-root-pattern-invalid")
    opened = os.fstat(root_fd)
    validate_directory_info(opened, "private-regression-root")
    if not same_identity(root_info, opened):
        refuse("private-regression-root-open-identity-changed", EX_TEMPFAIL)
    tmp_fd = open_tmp_parent()
    try:
        try:
            named = os.stat(
                root_path.name, dir_fd=tmp_fd, follow_symlinks=False
            )
        except FileNotFoundError:
            refuse("private-regression-root-missing", EX_TEMPFAIL)
        validate_directory_info(named, "private-regression-root")
        if not same_identity(opened, named):
            refuse("private-regression-root-name-identity-changed", EX_TEMPFAIL)

        allowed_files = {
            candidate: mode
            for logical_name, mode in regular_files.items()
            for candidate in (logical_name, file_quarantine_name(logical_name))
        }
        allowed_directories = {
            candidate
            for logical_name in directories
            for candidate in (logical_name, directory_quarantine_name(logical_name))
        }
        children = set(os.listdir(root_fd))
        unexpected = children - set(allowed_files) - allowed_directories
        if unexpected:
            refuse(
                f"unexpected-private-regression-child-{sorted(unexpected)[0]}"
            )
        for logical_name in regular_files:
            if {
                logical_name,
                file_quarantine_name(logical_name),
            } <= children:
                refuse(
                    f"original-and-quarantine-both-present-{logical_name}"
                )
        for logical_name in directories:
            if {
                logical_name,
                directory_quarantine_name(logical_name),
            } <= children:
                refuse(
                    f"original-and-quarantine-both-present-{logical_name}"
                )

        # Validate every known entry before deleting any of them. A changed type,
        # owner, mode, link count, or non-empty directory is preserved fail-closed.
        for name in sorted(children & set(allowed_files)):
            descriptor = open_regular_at(
                root_fd, name, f"private-regression-{name}", allowed_files[name]
            )
            os.close(descriptor)
        for name in sorted(children & allowed_directories):
            directory_fd = open_directory_at(
                root_fd, name, f"private-regression-{name}"
            )
            try:
                if os.listdir(directory_fd):
                    refuse(f"private-regression-directory-not-empty-{name}")
            finally:
                os.close(directory_fd)

        inherited_fault = os.environ.pop("LAB_FAULT_POINT", None)
        try:
            for name, mode in regular_files.items():
                remove_regular_if_present(
                    root_fd, name, f"private-regression-{name}", mode
                )
            for name in directories:
                remove_empty_directory_if_present(
                    root_fd, name, f"private-regression-{name}"
                )
            if os.listdir(root_fd):
                refuse("private-regression-root-not-empty")
            rmdir_empty_bound(
                tmp_fd, root_path.name, root_fd, "private-regression-root"
            )
        finally:
            if inherited_fault is not None:
                os.environ["LAB_FAULT_POINT"] = inherited_fault
    finally:
        os.close(tmp_fd)


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
    root_path = Path(
        tempfile.mkdtemp(
            prefix=f"{ROOT_PREFIX_NAME}regression-removal-",
            dir="/tmp",
        )
    )
    os.chmod(root_path, 0o700, follow_symlinks=False)
    root_fd, root_info = open_directory_path(root_path, "removal-regression-root")
    try:
        run_regular_replacement_regression(root_fd)
        run_directory_replacement_regression(root_fd, "directory-race")
        if os.listdir(root_fd):
            refuse("removal-regression-root-not-empty")
    finally:
        try:
            finalize_private_regression_root(
                root_path,
                root_fd,
                root_info,
                {
                    "regular-race.target": 0o600,
                    "regular-race.original": 0o600,
                },
                ("directory-race.target", "directory-race.original"),
            )
        finally:
            os.close(root_fd)
    emit(
        [
            ("removal_race_regressions", "passed"),
            ("cases", ["regular-file", "owned-directory"]),
            ("replacement_preserved", True),
            ("atomic_deletion_claimed", False),
        ]
    )


def command_verify_unexpected_preservation() -> None:
    root_path = Path(
        tempfile.mkdtemp(
            prefix=f"{ROOT_PREFIX_NAME}regression-unexpected-",
            dir="/tmp",
        )
    )
    os.chmod(root_path, 0o700, follow_symlinks=False)
    root_fd, root_info = open_directory_path(root_path, "unexpected-regression-root")
    try:
        token = secrets.token_hex(16)
        payload = {
            "lifecycleToken": token,
            "rootDevice": root_info.st_dev,
            "rootInode": root_info.st_ino,
            "stateDevice": root_info.st_dev,
            "stateInode": root_info.st_ino,
        }
        os.mkdir("runs", 0o700, dir_fd=root_fd)
        write_new_at(
            root_fd, ".sentinel", canonical_bytes(root_sentinel(payload)), 0o400
        )
        protected = b"unexpected-content-must-survive-refusal\n"
        write_new_at(root_fd, "protected.foreign", protected)
        before = os.stat("protected.foreign", dir_fd=root_fd, follow_symlinks=False)
        try:
            validate_root_contents(root_fd, payload, cleanup=False)
        except LabRefusal as error:
            if error.token != "unexpected-root-child-protected.foreign":
                raise
        else:
            refuse("unexpected-child-was-not-refused")
        after = os.stat("protected.foreign", dir_fd=root_fd, follow_symlinks=False)
        if not same_identity(before, after) or read_regular_at(
            root_fd, "protected.foreign", "protected.foreign"
        ) != protected:
            refuse("unexpected-child-was-mutated")
        unlink_regular_bound(root_fd, "protected.foreign", "protected.foreign")
        unlink_regular_bound(root_fd, ".sentinel", ".sentinel", 0o400)
        remove_empty_directory_if_present(root_fd, "runs", "runs")
        if os.listdir(root_fd):
            refuse("unexpected-regression-root-not-empty")
    finally:
        try:
            finalize_private_regression_root(
                root_path,
                root_fd,
                root_info,
                {".sentinel": 0o400, "protected.foreign": 0o600},
                ("runs",),
            )
        finally:
            os.close(root_fd)
    emit(
        [
            ("unexpected_child_refused", True),
            ("unexpected_child_preserved_before_explicit_removal", True),
            ("cleanup_scope", "private-regression-root-only"),
        ]
    )


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="guarded offline LES-0026 lab")
    subparsers = result.add_subparsers(dest="command", required=True)
    subparsers.add_parser("check")
    subparsers.add_parser("setup")
    subparsers.add_parser("status")
    run_parser = subparsers.add_parser("run")
    run_parser.add_argument("case", choices=CASES)
    inspect_parser = subparsers.add_parser("inspect-signals")
    inspect_parser.add_argument("case", choices=CASES)
    subparsers.add_parser("inspect-ordering")
    subparsers.add_parser("verify-guided")
    hypothesis_parser = subparsers.add_parser("record-hypothesis")
    hypothesis_parser.add_argument("hypothesis", choices=HYPOTHESES)
    pipeline_parser = subparsers.add_parser("inspect-pipeline")
    pipeline_parser.add_argument("case", choices=("missing-signal",))
    subparsers.add_parser("verify-operation")
    cleanup_parser = subparsers.add_parser("cleanup")
    cleanup_parser.add_argument("--expect-token")
    subparsers.add_parser(
        "verify-removal-races",
        help="verifier-internal cooperative replacement regression",
    )
    subparsers.add_parser(
        "verify-unexpected-preservation",
        help="verifier-internal unexpected-child preservation regression",
    )
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
        command_run(args.case)
    elif args.command == "inspect-signals":
        command_inspect_signals(args.case)
    elif args.command == "inspect-ordering":
        command_inspect_ordering()
    elif args.command == "verify-guided":
        command_verify_guided()
    elif args.command == "record-hypothesis":
        command_record_hypothesis(args.hypothesis)
    elif args.command == "inspect-pipeline":
        command_inspect_pipeline(args.case)
    elif args.command == "verify-operation":
        command_verify_operation()
    elif args.command == "cleanup":
        command_cleanup(args.expect_token)
    elif args.command == "verify-removal-races":
        command_verify_removal_races()
    elif args.command == "verify-unexpected-preservation":
        command_verify_unexpected_preservation()


if __name__ == "__main__":
    os.umask(0o077)
    try:
        main()
    except LabRefusal as error:
        print(error.token, file=sys.stderr)
        raise SystemExit(error.status) from error
    except subprocess.TimeoutExpired as error:
        print("telemetry-model-timeout", file=sys.stderr)
        raise SystemExit(EX_TEMPFAIL) from error
    except (OSError, ValueError) as error:
        print(f"lab-controller-refused={error}", file=sys.stderr)
        raise SystemExit(EX_DATAERR) from error
