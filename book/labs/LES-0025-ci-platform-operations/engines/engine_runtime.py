#!/usr/bin/env python3
"""Filesystem and typed-job runtime shared by independent local schedulers."""

from __future__ import annotations

import hashlib
import json
import os
import stat
import subprocess
import sys
from pathlib import Path
from typing import Any


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

MINIMAL_ENVIRONMENT = {
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "PYTHONHASHSEED": "0",
    "PYTHONDONTWRITEBYTECODE": "1",
}


def canonical_json(payload: object) -> str:
    return json.dumps(payload, sort_keys=True, separators=(",", ":"))


def sha256_bytes(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def load_json(path: Path) -> tuple[bytes, dict[str, Any]]:
    info = os.lstat(path)
    if not stat.S_ISREG(info.st_mode) or stat.S_ISLNK(info.st_mode):
        raise ValueError(f"expected-regular-config-{path.name}")
    content = path.read_bytes()
    payload = json.loads(content)
    if not isinstance(payload, dict):
        raise ValueError(f"expected-object-config-{path.name}")
    return content, payload


def require_exact_keys(payload: dict[str, Any], expected: set[str], label: str) -> None:
    if set(payload) != expected:
        raise ValueError(f"{label}-keys-invalid")


def require_private_directory(path: Path) -> None:
    info = os.lstat(path)
    if not stat.S_ISDIR(info.st_mode) or stat.S_ISLNK(info.st_mode):
        raise ValueError("engine-workspace-type-invalid")
    if info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) != 0o700:
        raise ValueError("engine-workspace-owner-or-mode-invalid")
    with os.scandir(path) as entries:
        if any(entries):
            raise ValueError("engine-workspace-not-empty")


def make_private_directory(parent: Path, name: str) -> Path:
    if name not in {"build", "artifact-store", "test"}:
        raise ValueError("runtime-directory-name-not-allowlisted")
    path = parent / name
    os.mkdir(path, 0o700)
    os.chmod(path, 0o700, follow_symlinks=False)
    return path


def minimal_environment() -> dict[str, str]:
    return dict(MINIMAL_ENVIRONMENT)


def run_portable_job(
    python_executable: str,
    portable_job: Path,
    action: str,
    workspace: Path,
    value: str,
) -> dict[str, Any]:
    if action not in {"build", "test"}:
        raise ValueError("portable-action-not-allowlisted")
    value_flag = "--value" if action == "build" else "--expected"
    completed = subprocess.run(
        [
            python_executable,
            "-S",
            str(portable_job),
            action,
            "--workspace",
            str(workspace),
            value_flag,
            value,
        ],
        check=False,
        cwd=workspace,
        env=minimal_environment(),
        capture_output=True,
        text=True,
        timeout=10,
    )
    if completed.returncode != 0:
        raise ValueError(f"portable-{action}-failed-{completed.returncode}")
    if completed.stderr:
        raise ValueError(f"portable-{action}-unexpected-stderr")
    try:
        payload = json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise ValueError(f"portable-{action}-output-invalid") from error
    expected_keys = {
        "action",
        "artifactSha256",
        "bytes",
        "environmentKeys",
        "status",
    }
    if not isinstance(payload, dict) or set(payload) != expected_keys:
        raise ValueError(f"portable-{action}-record-invalid")
    if payload["action"] != action or payload["status"] != "passed":
        raise ValueError(f"portable-{action}-status-invalid")
    if payload["environmentKeys"] != sorted(MINIMAL_ENVIRONMENT):
        raise ValueError(f"portable-{action}-environment-invalid")
    return payload


def open_regular(path: Path) -> tuple[int, os.stat_result]:
    flags = os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags)
    info = os.fstat(descriptor)
    if not stat.S_ISREG(info.st_mode):
        os.close(descriptor)
        raise ValueError(f"expected-regular-file-{path.name}")
    if info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) != 0o600:
        os.close(descriptor)
        raise ValueError(f"file-owner-or-mode-invalid-{path.name}")
    if info.st_nlink != 1:
        os.close(descriptor)
        raise ValueError(f"file-link-count-invalid-{path.name}")
    return descriptor, info


def read_regular(path: Path) -> bytes:
    descriptor, _ = open_regular(path)
    try:
        chunks: list[bytes] = []
        while True:
            chunk = os.read(descriptor, 65536)
            if not chunk:
                break
            chunks.append(chunk)
        return b"".join(chunks)
    finally:
        os.close(descriptor)


def copy_regular_once(source: Path, destination: Path) -> str:
    content = read_regular(source)
    parent_info = os.lstat(destination.parent)
    if not stat.S_ISDIR(parent_info.st_mode) or stat.S_ISLNK(parent_info.st_mode):
        raise ValueError("artifact-destination-parent-invalid")
    if parent_info.st_uid != os.geteuid() or stat.S_IMODE(parent_info.st_mode) != 0o700:
        raise ValueError("artifact-destination-parent-owner-or-mode-invalid")
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(destination, flags, 0o600)
    try:
        os.fchmod(descriptor, 0o600)
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written <= 0:
                raise OSError("short artifact copy")
            view = view[written:]
        os.fsync(descriptor)
    finally:
        os.close(descriptor)
    return sha256_bytes(content)


class Runtime:
    """Execute only the two allowlisted portable actions."""

    def __init__(self, workspace: Path, portable_job: Path, expected_value: str) -> None:
        require_private_directory(workspace)
        self.workspace = workspace
        self.portable_job = portable_job
        self.expected_value = expected_value
        self.build_directory = make_private_directory(workspace, "build")
        self.store_directory = make_private_directory(workspace, "artifact-store")
        self.test_directory = make_private_directory(workspace, "test")
        self.executed: list[str] = []
        self.job_environment_keys: list[str] | None = None
        self.artifact_digest: str | None = None

    def execute(self, job_id: str, action: str) -> None:
        if job_id in self.executed:
            raise ValueError(f"job-executed-twice-{job_id}")
        if action == "build":
            if self.executed:
                raise ValueError("build-must-be-first")
            result = run_portable_job(
                sys.executable,
                self.portable_job,
                "build",
                self.build_directory,
                self.expected_value,
            )
            published = copy_regular_once(
                self.build_directory / "artifact.bin",
                self.store_directory / "build-output.bin",
            )
            if result["artifactSha256"] != published:
                raise ValueError("published-artifact-digest-mismatch")
            self.artifact_digest = published
        elif action == "test":
            if self.artifact_digest is None:
                raise ValueError("test-requires-published-artifact")
            downloaded = copy_regular_once(
                self.store_directory / "build-output.bin",
                self.test_directory / "downloaded-output.bin",
            )
            if downloaded != self.artifact_digest:
                raise ValueError("downloaded-artifact-digest-mismatch")
            result = run_portable_job(
                sys.executable,
                self.portable_job,
                "test",
                self.test_directory,
                self.expected_value,
            )
            if result["artifactSha256"] != self.artifact_digest:
                raise ValueError("tested-artifact-digest-mismatch")
        else:
            raise ValueError(f"action-not-allowlisted-{action}")
        observed_environment = result["environmentKeys"]
        if self.job_environment_keys is None:
            self.job_environment_keys = observed_environment
        elif self.job_environment_keys != observed_environment:
            raise ValueError("portable-job-environment-drift")
        self.executed.append(job_id)

    def report(
        self,
        config_bytes: bytes,
        config: dict[str, Any],
        engine: str,
        dependency_edges: list[str],
    ) -> dict[str, Any]:
        if (
            self.executed != ["build", "test"]
            or self.artifact_digest is None
            or self.job_environment_keys is None
        ):
            raise ValueError("pipeline-did-not-complete-required-jobs")
        contract = config["contract"]
        observed_environment_keys = set(os.environ) | set(self.job_environment_keys)
        credential_markers = (
            "TOKEN",
            "PASSWORD",
            "SECRET",
            "CREDENTIAL",
            "PRIVATE_KEY",
            "AWS_",
            "AZURE_",
            "GOOGLE_",
            "GITHUB_",
            "GITLAB_",
            "JENKINS_",
            "HOME",
        )
        credential_inputs = sorted(
            key
            for key in observed_environment_keys
            if any(marker in key.upper() for marker in credential_markers)
        )
        report: dict[str, Any] = {
            "artifactHandoff": True,
            "artifactSha256": self.artifact_digest,
            "concurrency": contract["concurrency"],
            "configSha256": sha256_bytes(config_bytes),
            "credentialInputsObserved": credential_inputs,
            "dependencyEdges": dependency_edges,
            "engine": engine,
            "engineEnvironmentKeys": sorted(os.environ),
            "externalEffects": [],
            "jobOrder": self.executed,
            "jobEnvironmentKeys": self.job_environment_keys,
            "networkTargets": contract["networkTargets"],
            "permissions": contract["permissions"],
            "pipelineIdentity": config["pipelineIdentity"],
            "schemaVersion": 1,
            "secretInputs": contract["secretInputs"],
            "sourceIdentity": config["sourceIdentity"],
            "status": "passed",
            "timeoutSeconds": contract["timeoutSeconds"],
        }
        if set(report) != REPORT_KEYS:
            raise AssertionError("internal report schema mismatch")
        return report


def validate_contract(config: dict[str, Any]) -> None:
    contract = config.get("contract")
    if not isinstance(contract, dict):
        raise ValueError("contract-must-be-object")
    require_exact_keys(
        contract,
        {"concurrency", "networkTargets", "permissions", "secretInputs", "timeoutSeconds"},
        "contract",
    )
    if not isinstance(contract["permissions"], list) or not all(
        isinstance(value, str) for value in contract["permissions"]
    ):
        raise ValueError("permissions-invalid")
    if contract["permissions"] != sorted(set(contract["permissions"])):
        raise ValueError("permissions-must-be-sorted-and-unique")
    if not isinstance(contract["concurrency"], str) or not contract["concurrency"]:
        raise ValueError("concurrency-invalid")
    if not isinstance(contract["timeoutSeconds"], int) or contract["timeoutSeconds"] < 0:
        raise ValueError("timeout-invalid")
    if contract["secretInputs"] != [] or contract["networkTargets"] != []:
        raise ValueError("lab-requires-empty-secret-and-network-inputs")
