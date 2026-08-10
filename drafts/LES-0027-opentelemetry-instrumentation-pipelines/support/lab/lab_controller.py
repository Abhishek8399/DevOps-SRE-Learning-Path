"""Guarded controller for the quarantined LES-0027 local lab.

The repository deliberately ships incomplete artifact locks. Static checks and
the model remain useful, but runtime output is OpenTelemetry evidence only after
reviewed locks, explicit preparation, and runtime verification all succeed.
"""

from __future__ import annotations

import contextlib
import datetime as dt
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
import time
import urllib.parse
from pathlib import Path
from typing import Any, Iterator, Sequence


LESSON = "LES-0027"
CURRENT_UID = os.geteuid()
CURRENT_GID = os.getegid()

if CURRENT_UID == 0:
    print("root-is-refused-run-as-a-normal-user", file=sys.stderr)
    raise SystemExit(77)

os.umask(0o077)

LAB_DIR = Path(__file__).resolve().parent
LOCK_PATH = LAB_DIR / "artifacts.lock.json"
REQUIREMENTS_PATH = LAB_DIR / "requirements.lock"
COMPOSE_PATH = LAB_DIR / "compose.yaml"
ARTIFACTS_PATH = Path(
    f"/tmp/reliability-atlas-LES-0027-{CURRENT_UID}.artifacts.d"
)
PREPARE_LOCK_PATH = Path(
    f"/tmp/reliability-atlas-LES-0027-{CURRENT_UID}.artifacts.prepare.lock"
)
STATE_PATH = Path(f"/tmp/reliability-atlas-LES-0027-{CURRENT_UID}.state.d")
STATE_SETUP_PATH = Path(f"{STATE_PATH}.setup")
STATE_RECOVERY_GLOB = f"{STATE_PATH.name}.cleanup.*"
PROJECT_NAME = f"reliability-atlas-les0027-u{CURRENT_UID}"
EXPECTED_SERVICES = {"service-a", "service-b", "agent-a", "agent-b", "gateway"}
LEGACY_LOOPBACK_BINDINGS = {
    "service-a": {"8080/tcp": [{"HostIp": "127.0.0.1", "HostPort": "18027"}]},
    "service-b": {},
    "agent-a": {"8888/tcp": [{"HostIp": "127.0.0.1", "HostPort": "18889"}]},
    "agent-b": {"8888/tcp": [{"HostIp": "127.0.0.1", "HostPort": "18890"}]},
    "gateway": {"8888/tcp": [{"HostIp": "127.0.0.1", "HostPort": "18888"}]},
}
RUNTIME_MEMORY_BYTES = 192 * 1024 * 1024
RUNTIME_NANO_CPUS = 500_000_000
RUNTIME_PIDS_LIMIT = 96
RECORD_NAMES = {
    "baseline.json",
    "broken-context.json",
    "recovery.json",
    "gateway-interruption.json",
    "sampling.json",
}
ACTION_RISKS = {
    "doctor": "read-only",
    "model": "read-only",
    "prepare": "networked-install",
    "validate-configs": "mutating-bounded",
    "setup": "mutating-bounded",
    "status": "read-only",
    "check": "read-only",
    "run": "mutating-bounded",
    "recover-context": "mutating-bounded",
    "interrupt-gateway": "mutating-bounded",
    "compare-sampling": "mutating-bounded",
    "verify-operation": "sampled-read-only",
    "cleanup": "destructive-disposable",
}


class LabError(RuntimeError):
    def __init__(self, code: int, token: str):
        super().__init__(token)
        self.code = code
        self.token = token


def abort(code: int, token: str) -> None:
    raise LabError(code, token)


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def identity(path: Path) -> str:
    info = path.stat(follow_symlinks=False)
    return f"{info.st_dev}:{info.st_ino}"


def validate_owned_directory(path: Path, expected_identity: str | None = None) -> None:
    try:
        info = path.stat(follow_symlinks=False)
    except FileNotFoundError:
        abort(66, f"required-directory-missing-{path.name}")
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISDIR(info.st_mode):
        abort(65, f"unsafe-directory-type-{path.name}")
    if info.st_uid != CURRENT_UID or stat.S_IMODE(info.st_mode) != 0o700:
        abort(65, f"unsafe-directory-owner-or-mode-{path.name}")
    if expected_identity is not None and identity(path) != expected_identity:
        abort(65, f"directory-identity-changed-{path.name}")


def validate_owned_file(path: Path, mode: int = 0o600) -> None:
    try:
        info = path.stat(follow_symlinks=False)
    except FileNotFoundError:
        abort(66, f"required-file-missing-{path.name}")
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
        abort(65, f"unsafe-file-type-{path.name}")
    if info.st_uid != CURRENT_UID or stat.S_IMODE(info.st_mode) != mode or info.st_nlink != 1:
        abort(65, f"unsafe-file-owner-mode-or-links-{path.name}")


def write_exclusive(path: Path, value: bytes, mode: int = 0o600) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags, mode)
    try:
        with os.fdopen(descriptor, "wb", closefd=False) as handle:
            handle.write(value)
            handle.flush()
            os.fsync(handle.fileno())
    finally:
        os.close(descriptor)


def write_json_exclusive(path: Path, value: dict[str, Any]) -> None:
    write_exclusive(path, (json.dumps(value, sort_keys=True, indent=2) + "\n").encode())


def read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        abort(65, f"invalid-json-{path.name}-{type(exc).__name__}")
    if not isinstance(value, dict):
        abort(65, f"json-root-must-be-object-{path.name}")
    return value


def command(
    argv: Sequence[str],
    *,
    timeout: float = 20,
    check: bool = True,
    extra_env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment.update({"COMPOSE_ANSI": "never", "DOCKER_CLI_HINTS": "false"})
    if extra_env:
        environment.update(extra_env)
    try:
        result = subprocess.run(
            list(argv),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout,
            env=environment,
            check=False,
        )
    except FileNotFoundError:
        abort(69, f"missing-required-command-{argv[0]}")
    except subprocess.TimeoutExpired:
        abort(75, f"command-timeout-{Path(argv[0]).name}")
    if check and result.returncode != 0:
        summary = " ".join(result.stdout.strip().splitlines()[-2:])[:400]
        abort(70, f"command-failed-{Path(argv[0]).name}-{result.returncode}-{summary}")
    return result


def docker_ready() -> tuple[bool, str]:
    version = command(
        ["docker", "version", "--format", "{{.Client.Version}}"],
        timeout=45,
        check=False,
    )
    if version.returncode != 0:
        return False, "client-unavailable"
    info = command(
        ["docker", "info", "--format", "{{.ServerVersion}}"],
        timeout=45,
        check=False,
    )
    if info.returncode != 0:
        return False, "daemon-unavailable"
    compose = command(["docker", "compose", "version", "--short"], check=False)
    if compose.returncode != 0:
        return False, "compose-unavailable"
    return True, f"server-{info.stdout.strip()}-compose-{compose.stdout.strip()}"


def parse_locks() -> dict[str, Any]:
    raw_lock = LOCK_PATH.read_bytes()
    raw_requirements = REQUIREMENTS_PATH.read_bytes()
    if b"RECORD_REAL_" in raw_lock or b"RECORD_REAL_" in raw_requirements:
        abort(78, "artifact-lock-incomplete-record-reviewed-digests-first")
    lock = read_json(LOCK_PATH)
    if lock.get("schemaVersion") != 1 or lock.get("lesson") != LESSON:
        abort(65, "artifact-lock-identity-invalid")
    if lock.get("platform") != "linux/amd64":
        abort(65, "artifact-lock-platform-invalid")
    images = lock.get("images")
    if not isinstance(images, dict) or set(images) != {"python", "collector"}:
        abort(65, "artifact-lock-images-invalid")
    refs: dict[str, str] = {}
    for name, item in images.items():
        if not isinstance(item, dict):
            abort(65, f"artifact-image-record-invalid-{name}")
        repository, tag, digest = item.get("repository"), item.get("tag"), item.get("digest")
        if not isinstance(repository, str) or not re.fullmatch(r"[a-z0-9./_-]+", repository):
            abort(65, f"artifact-image-repository-invalid-{name}")
        if not isinstance(tag, str) or not re.fullmatch(r"[A-Za-z0-9._-]+", tag):
            abort(65, f"artifact-image-tag-invalid-{name}")
        if not isinstance(digest, str) or not re.fullmatch(r"sha256:[0-9a-f]{64}", digest):
            abort(65, f"artifact-image-digest-invalid-{name}")
        refs[name] = f"{repository}@{digest}"

    requirements: list[dict[str, str]] = []
    pattern = re.compile(
        r"^([A-Za-z0-9_.-]+)==([A-Za-z0-9_.+-]+) --hash=sha256:([0-9a-f]{64})$"
    )
    for line_number, raw_line in enumerate(raw_requirements.decode().splitlines(), 1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        match = pattern.fullmatch(line)
        if match is None:
            abort(65, f"requirements-lock-line-invalid-{line_number}")
        requirements.append(
            {"name": match.group(1), "version": match.group(2), "sha256": match.group(3)}
        )
    if not requirements or len({item["name"].lower() for item in requirements}) != len(requirements):
        abort(65, "requirements-lock-set-invalid")
    return {
        "lock": lock,
        "refs": refs,
        "requirements": requirements,
        "digest": sha256_bytes(raw_lock + b"\0" + raw_requirements),
    }


def inspect_lock_material() -> dict[str, Any]:
    raw_lock = LOCK_PATH.read_bytes()
    raw_requirements = REQUIREMENTS_PATH.read_bytes()
    lock = read_json(LOCK_PATH)
    images = lock.get("images")
    if (
        lock.get("schemaVersion") != 1
        or lock.get("lesson") != LESSON
        or lock.get("platform") != "linux/amd64"
        or not isinstance(images, dict)
        or set(images) != {"python", "collector"}
    ):
        abort(65, "artifact-lock-identity-invalid")
    image_placeholder_states: list[bool] = []
    image_records: dict[str, dict[str, str]] = {}
    for name, value in images.items():
        if not isinstance(value, dict):
            abort(65, f"artifact-image-record-invalid-{name}")
        repository = value.get("repository")
        tag = value.get("tag")
        digest = value.get("digest")
        if not all(isinstance(item, str) for item in (repository, tag, digest)):
            abort(65, f"artifact-image-record-invalid-{name}")
        placeholder = "RECORD_REAL_" in digest
        image_placeholder_states.append(placeholder)
        image_records[name] = {
            "repository": repository,
            "tag": tag,
            "digest": digest,
            "declared": f"{repository}:{tag}",
        }

    requirement_lines = [
        line.strip()
        for line in raw_requirements.decode().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    if not requirement_lines:
        abort(65, "requirements-lock-set-invalid")
    requirement_placeholder_states = ["RECORD_REAL_" in line for line in requirement_lines]
    all_placeholders = all(image_placeholder_states + requirement_placeholder_states)
    no_placeholders = not any(image_placeholder_states + requirement_placeholder_states)
    if all_placeholders:
        state = "incomplete"
    elif no_placeholders:
        parse_locks()
        state = "complete"
    else:
        state = "invalid-mixed-placeholder-and-real-digests"
    return {
        "state": state,
        "images": image_records,
        "requirementCount": len(requirement_lines),
        "artifactLockFileSha256": sha256_bytes(raw_lock),
        "requirementsLockFileSha256": sha256_bytes(raw_requirements),
        "combinedDigest": sha256_bytes(raw_lock + b"\0" + raw_requirements),
    }


def lock_status() -> str:
    try:
        parsed = parse_locks()
    except LabError as exc:
        if exc.code == 78:
            return "incomplete"
        return f"invalid:{exc.token}"
    return f"complete:{parsed['digest']}"


def validate_artifacts(parsed: dict[str, Any]) -> dict[str, Any]:
    validate_owned_directory(ARTIFACTS_PATH)
    wheels = ARTIFACTS_PATH / "wheels"
    validate_owned_directory(wheels)
    ready_path = ARTIFACTS_PATH / "ready.json"
    validate_owned_file(ready_path)
    ready = read_json(ready_path)
    if ready.get("lesson") != LESSON or ready.get("lockDigest") != parsed["digest"]:
        abort(65, "prepared-artifact-receipt-lock-mismatch")
    if ready.get("imageRefs") != parsed["refs"]:
        abort(65, "prepared-artifact-receipt-image-mismatch")
    receipt_wheels = ready.get("wheels")
    if not isinstance(receipt_wheels, dict):
        abort(65, "prepared-wheel-receipt-invalid")
    allowed_hashes = {item["sha256"] for item in parsed["requirements"]}
    found: dict[str, str] = {}
    for child in wheels.iterdir():
        if not re.fullmatch(r"[A-Za-z0-9_.+-]+\.whl", child.name):
            abort(65, f"unexpected-wheelhouse-entry-{child.name}")
        validate_owned_file(child)
        digest = sha256_file(child)
        if digest not in allowed_hashes:
            abort(65, f"wheel-digest-not-allowlisted-{child.name}")
        found[child.name] = digest
    if len(found) != len(parsed["requirements"]) or set(found.values()) != allowed_hashes:
        abort(65, "wheelhouse-does-not-exactly-match-requirements-lock")
    if found != receipt_wheels:
        abort(65, "wheelhouse-receipt-content-mismatch")
    if set(child.name for child in ARTIFACTS_PATH.iterdir()) != {"wheels", "ready.json"}:
        abort(65, "unexpected-artifacts-entry")
    return ready


def normalize_repository(repository: str) -> str:
    if repository.startswith("docker.io/"):
        repository = repository[len("docker.io/") :]
    if repository.startswith("library/"):
        repository = repository[len("library/") :]
    return repository


def image_is_local(ref: str) -> bool:
    result = command(
        ["docker", "image", "inspect", "--format", "{{json .RepoDigests}}", ref],
        check=False,
    )
    if result.returncode != 0:
        return False
    try:
        repo_digests = json.loads(result.stdout)
    except json.JSONDecodeError:
        return False
    if not isinstance(repo_digests, list):
        return False
    expected_repository, expected_digest = ref.rsplit("@", 1)

    for candidate in repo_digests:
        if not isinstance(candidate, str) or "@" not in candidate:
            continue
        repository, digest = candidate.rsplit("@", 1)
        if (
            normalize_repository(repository) == normalize_repository(expected_repository)
            and digest == expected_digest
        ):
            return True
    return False


def require_offline_runtime() -> dict[str, Any]:
    parsed = parse_locks()
    validate_artifacts(parsed)
    ready, detail = docker_ready()
    if not ready:
        abort(69, f"docker-runtime-unavailable-{detail}")
    for name, ref in parsed["refs"].items():
        if not image_is_local(ref):
            abort(78, f"pinned-image-not-local-{name}-run-explicit-prepare")
    return parsed


def cleanup_prepare_tree(path: Path, expected_identity: str) -> None:
    if not path.exists():
        return
    validate_owned_directory(path, expected_identity)
    for child in list(path.iterdir()):
        if child.name == "wheels":
            validate_owned_directory(child)
            for wheel in list(child.iterdir()):
                if not re.fullmatch(r"[A-Za-z0-9_.+-]+\.whl", wheel.name):
                    abort(65, f"unsafe-prepare-entry-{wheel.name}")
                validate_owned_file(wheel)
                wheel.unlink()
            child.rmdir()
        elif child.name == "ready.json":
            validate_owned_file(child)
            child.unlink()
        else:
            abort(65, f"unsafe-prepare-entry-{child.name}")
    path.rmdir()


def prepare(argv: list[str]) -> None:
    if argv != ["--allow-network-downloads"]:
        abort(64, "prepare-requires-explicit---allow-network-downloads")
    parsed = parse_locks()
    if ARTIFACTS_PATH.exists():
        validate_artifacts(parsed)
        print("prepare_complete=true")
        print("downloads_performed=false")
        print(f"lock_digest={parsed['digest']}")
        return
    ready, detail = docker_ready()
    if not ready:
        abort(69, f"docker-runtime-unavailable-{detail}")

    try:
        PREPARE_LOCK_PATH.mkdir(mode=0o700)
    except FileExistsError:
        abort(73, "prepare-already-running-or-stale-lock-present")
    lock_identity = identity(PREPARE_LOCK_PATH)
    token = secrets.token_hex(8)
    staging = ARTIFACTS_PATH.parent / f"{ARTIFACTS_PATH.name}.prepare.{token}"
    staging_identity = ""
    try:
        staging.mkdir(mode=0o700)
        staging_identity = identity(staging)
        wheels = staging / "wheels"
        wheels.mkdir(mode=0o700)

        for name, ref in parsed["refs"].items():
            result = command(
                ["docker", "pull", "--platform", "linux/amd64", ref],
                timeout=240,
                check=False,
            )
            if result.returncode != 0 or not image_is_local(ref):
                abort(70, f"pinned-image-download-or-verification-failed-{name}")

        python_ref = parsed["refs"]["python"]
        container_name = f"reliability-atlas-les0027-prepare-{CURRENT_UID}-{token}"
        create = command(
            [
                "docker",
                "create",
                "--name",
                container_name,
                "--pull",
                "never",
                "--platform",
                "linux/amd64",
                "--user",
                f"{CURRENT_UID}:{CURRENT_GID}",
                "--network",
                "bridge",
                "--read-only",
                "--cap-drop",
                "ALL",
                "--security-opt",
                "no-new-privileges:true",
                "--pids-limit",
                "64",
                "--memory",
                "256m",
                "--cpus",
                "0.75",
                "--tmpfs",
                f"/tmp:rw,nosuid,nodev,size=64m,uid={CURRENT_UID},gid={CURRENT_GID},mode=0700",
                "--mount",
                f"type=bind,src={REQUIREMENTS_PATH},dst=/requirements.lock,readonly",
                "--mount",
                f"type=bind,src={wheels},dst=/out",
                "--label",
                "com.reliability-atlas.managed=true",
                "--label",
                f"com.reliability-atlas.lesson={LESSON}",
                "--label",
                f"com.reliability-atlas.owner-token={token}",
                python_ref,
                "python",
                "-m",
                "pip",
                "download",
                "--disable-pip-version-check",
                "--no-cache-dir",
                "--no-deps",
                "--require-hashes",
                "--only-binary=:all:",
                "--dest=/out",
                "-r",
                "/requirements.lock",
            ],
            timeout=30,
        )
        container_id = create.stdout.strip()
        if not re.fullmatch(r"[0-9a-f]{64}", container_id):
            abort(70, "prepare-container-id-invalid")
        try:
            started = command(
                ["docker", "start", "--attach", container_id], timeout=240, check=False
            )
            inspected = command(
                [
                    "docker",
                    "container",
                    "inspect",
                    "--format",
                    "{{.State.ExitCode}}",
                    container_id,
                ]
            )
            if started.returncode != 0 or inspected.stdout.strip() != "0":
                abort(70, "wheel-download-container-failed")
        finally:
            command(["docker", "container", "rm", "--force", container_id], check=False)

        allowed = {item["sha256"] for item in parsed["requirements"]}
        receipt_wheels: dict[str, str] = {}
        for wheel in wheels.iterdir():
            if not re.fullmatch(r"[A-Za-z0-9_.+-]+\.whl", wheel.name):
                abort(65, f"unexpected-downloaded-entry-{wheel.name}")
            if wheel.is_symlink() or not wheel.is_file():
                abort(65, f"unsafe-downloaded-entry-{wheel.name}")
            os.chmod(wheel, 0o600)
            digest = sha256_file(wheel)
            if digest not in allowed:
                abort(65, f"downloaded-wheel-digest-not-allowlisted-{wheel.name}")
            receipt_wheels[wheel.name] = digest
        if len(receipt_wheels) != len(parsed["requirements"]) or set(
            receipt_wheels.values()
        ) != allowed:
            abort(65, "downloaded-wheel-set-does-not-match-lock")
        write_json_exclusive(
            staging / "ready.json",
            {
                "schemaVersion": 1,
                "lesson": LESSON,
                "lockDigest": parsed["digest"],
                "imageRefs": parsed["refs"],
                "wheels": receipt_wheels,
            },
        )
        if ARTIFACTS_PATH.exists():
            abort(73, "artifacts-path-appeared-during-prepare-preserved")
        os.rename(staging, ARTIFACTS_PATH)
        staging_identity = ""
        validate_artifacts(parsed)
        print("prepare_complete=true")
        print("downloads_performed=true")
        print("network_scope=official-pinned-image-and-wheel-artifacts")
        print(f"lock_digest={parsed['digest']}")
    finally:
        if staging_identity:
            cleanup_prepare_tree(staging, staging_identity)
        if PREPARE_LOCK_PATH.exists():
            validate_owned_directory(PREPARE_LOCK_PATH, lock_identity)
            PREPARE_LOCK_PATH.rmdir()


def state_document(state_path: Path = STATE_PATH) -> dict[str, Any]:
    validate_owned_directory(state_path)
    state_file = state_path / "state.json"
    validate_owned_file(state_file)
    if set(child.name for child in state_path.iterdir()) - {"state.json", "operation.lock"}:
        abort(65, "unexpected-state-directory-entry")
    value = read_json(state_file)
    required = {
        "schemaVersion": 1,
        "lesson": LESSON,
        "uid": CURRENT_UID,
        "gid": CURRENT_GID,
        "project": PROJECT_NAME,
        "labDirectory": str(LAB_DIR),
    }
    for key, expected in required.items():
        if value.get(key) != expected:
            abort(65, f"state-identity-mismatch-{key}")
    token = value.get("token")
    if not isinstance(token, str) or not re.fullmatch(r"[0-9a-f]{32}", token):
        abort(65, "state-token-invalid")
    if value.get("stateIdentity") != identity(state_path):
        abort(65, "state-directory-identity-mismatch")
    root_text = value.get("root")
    if not isinstance(root_text, str) or not re.fullmatch(
        rf"/tmp/reliability-atlas-LES-0027-{CURRENT_UID}\.[A-Za-z0-9_-]+", root_text
    ):
        abort(65, "state-root-path-invalid")
    root = Path(root_text)
    validate_owned_directory(root, value.get("rootIdentity"))
    value["_statePath"] = state_path
    value["_rootPath"] = root
    return value


@contextlib.contextmanager
def operation_lock(
    state: dict[str, Any], *, delete_state_on_success: bool = False
) -> Iterator[None]:
    state_path: Path = state["_statePath"]
    initial_lock = state_path / "operation.lock"
    flags = os.O_RDWR | os.O_CREAT
    if hasattr(os, "O_CLOEXEC"):
        flags |= os.O_CLOEXEC
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        descriptor = os.open(initial_lock, flags, 0o600)
    except OSError as exc:
        abort(65, f"operation-lock-open-failed-{type(exc).__name__}")
    lock_acquired = False
    sentinel_claimed = False
    operation_completed = False
    try:
        info = os.fstat(descriptor)
        if (
            not stat.S_ISREG(info.st_mode)
            or info.st_uid != CURRENT_UID
            or stat.S_IMODE(info.st_mode) != 0o600
            or info.st_nlink != 1
        ):
            abort(65, "unsafe-operation-lock-owner-mode-or-links")
        lock_identity = f"{info.st_dev}:{info.st_ino}"
        try:
            path_identity = identity(initial_lock)
        except OSError as exc:
            abort(65, f"operation-lock-path-check-failed-{type(exc).__name__}")
        if path_identity != lock_identity:
            abort(65, "operation-lock-path-identity-changed")
        try:
            fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            abort(73, "another-lab-operation-is-active")
        lock_acquired = True
        os.lseek(descriptor, 0, os.SEEK_SET)
        previous = os.read(descriptor, 128)
        expected = (state["token"] + "\n").encode()
        if previous not in {b"", expected}:
            abort(65, "operation-lock-token-mismatch")
        os.ftruncate(descriptor, 0)
        os.lseek(descriptor, 0, os.SEEK_SET)
        if os.write(descriptor, expected) != len(expected):
            abort(74, "operation-lock-short-write")
        os.fsync(descriptor)
        sentinel_claimed = True
        yield
        operation_completed = True
    finally:
        try:
            if lock_acquired:
                try:
                    if sentinel_claimed:
                        final_state_path: Path = state["_statePath"]
                        lock = final_state_path / "operation.lock"
                        validate_owned_file(lock)
                        if identity(lock) != lock_identity:
                            abort(65, "operation-lock-identity-changed")
                        if delete_state_on_success and operation_completed:
                            validate_owned_directory(
                                final_state_path, state["stateIdentity"]
                            )
                            if set(child.name for child in final_state_path.iterdir()) != {
                                "state.json",
                                "operation.lock",
                            }:
                                abort(65, "unexpected-final-cleanup-state-entry")
                            state_file = final_state_path / "state.json"
                            validate_owned_file(state_file)
                            state_file.unlink()
                        lock.unlink()
                        if delete_state_on_success and operation_completed:
                            final_state_path.rmdir()
                finally:
                    fcntl.flock(descriptor, fcntl.LOCK_UN)
        finally:
            os.close(descriptor)


def runtime_env(parsed: dict[str, Any], token: str, ratio: str = "1.0") -> str:
    return "\n".join(
        [
            f"LAB_PROJECT_NAME={PROJECT_NAME}",
            f"LAB_OWNER_TOKEN={token}",
            f"LAB_UID={CURRENT_UID}",
            f"LAB_GID={CURRENT_GID}",
            f"LAB_PYTHON_IMAGE={parsed['refs']['python']}",
            f"LAB_COLLECTOR_IMAGE={parsed['refs']['collector']}",
            f"LAB_WHEELHOUSE_PATH={ARTIFACTS_PATH / 'wheels'}",
            f"LAB_SAMPLE_RATIO={ratio}",
            "",
        ]
    )


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="microseconds").replace(
        "+00:00", "Z"
    )


def compose_environment(
    refs: dict[str, str], owner_token: str, ratio: str = "1.0"
) -> dict[str, str]:
    return {
        "LAB_PROJECT_NAME": PROJECT_NAME,
        "LAB_OWNER_TOKEN": owner_token,
        "LAB_UID": str(CURRENT_UID),
        "LAB_GID": str(CURRENT_GID),
        "LAB_PYTHON_IMAGE": refs["python"],
        "LAB_COLLECTOR_IMAGE": refs["collector"],
        "LAB_WHEELHOUSE_PATH": str(ARTIFACTS_PATH / "wheels"),
        "LAB_SAMPLE_RATIO": ratio,
    }


def validate_resolved_compose(
    document: dict[str, Any], refs: dict[str, str], owner_token: str
) -> None:
    services = document.get("services")
    networks = document.get("networks")
    if not isinstance(services, dict) or set(services) != EXPECTED_SERVICES:
        abort(65, "resolved-compose-service-set-invalid")
    if not isinstance(networks, dict) or set(networks) != {"telemetry"}:
        abort(65, "resolved-compose-network-set-invalid")
    network = networks["telemetry"]
    if network.get("internal") is not True:
        abort(65, "resolved-compose-network-not-internal")
    network_labels = network.get("labels", {})
    if (
        network_labels.get("com.reliability-atlas.lesson") != LESSON
        or network_labels.get("com.reliability-atlas.owner-token") != owner_token
    ):
        abort(65, "resolved-compose-network-labels-invalid")
    for name, service in services.items():
        labels = service.get("labels", {})
        expected_image = (
            refs["python"] if name in {"service-a", "service-b"} else refs["collector"]
        )
        if service.get("image") != expected_image:
            abort(65, f"resolved-compose-image-invalid-{name}")
        if (
            service.get("read_only") is not True
            or service.get("privileged") is True
            or "ALL" not in (service.get("cap_drop") or [])
            or "no-new-privileges:true" not in (service.get("security_opt") or [])
            or service.get("pull_policy") != "never"
            or labels.get("com.reliability-atlas.lesson") != LESSON
            or labels.get("com.reliability-atlas.owner-token") != owner_token
        ):
            abort(65, f"resolved-compose-safety-invalid-{name}")
        expected_user = (
            f"{CURRENT_UID}:{CURRENT_GID}"
            if name in {"service-a", "service-b"}
            else "10001:10001"
        )
        expected_tmpfs = (
            f"/tmp:rw,nosuid,nodev,size=96m,uid={CURRENT_UID},"
            f"gid={CURRENT_GID},mode=0700"
            if name in {"service-a", "service-b"}
            else "/tmp:rw,nosuid,nodev,noexec,size=16m,uid=10001,gid=10001,mode=0700"
        )
        if (
            service.get("user") != expected_user
            or service.get("cpus") != 0.5
            or service.get("mem_limit") != str(RUNTIME_MEMORY_BYTES)
            or service.get("pids_limit") != RUNTIME_PIDS_LIMIT
            or service.get("restart") != "no"
            or service.get("tmpfs") != [expected_tmpfs]
            or set((service.get("networks") or {}).keys()) != {"telemetry"}
        ):
            abort(65, f"resolved-compose-resource-contract-invalid-{name}")
        if service.get("ports"):
            abort(65, f"resolved-compose-published-port-{name}")
        serialized = json.dumps(service, sort_keys=True).lower()
        if "docker.sock" in serialized or service.get("network_mode") == "host":
            abort(65, f"resolved-compose-forbidden-host-access-{name}")


def render_compose(
    refs: dict[str, str], owner_token: str, binding: str
) -> dict[str, Any]:
    rendered = command(
        [
            "docker",
            "compose",
            "--file",
            str(COMPOSE_PATH),
            "config",
            "--format",
            "json",
        ],
        timeout=30,
        extra_env=compose_environment(refs, owner_token),
    )
    try:
        document = json.loads(rendered.stdout)
    except json.JSONDecodeError:
        abort(65, "resolved-compose-json-invalid")
    if not isinstance(document, dict):
        abort(65, "resolved-compose-root-invalid")
    validate_resolved_compose(document, refs, owner_token)
    canonical = json.dumps(document, sort_keys=True, separators=(",", ":")).encode()
    return {
        "binding": binding,
        "sourceSha256": sha256_file(COMPOSE_PATH),
        "resolvedSha256": sha256_bytes(canonical),
        "serviceCount": len(document["services"]),
        "networkCount": len(document["networks"]),
        "publishedPortCount": sum(
            len(service.get("ports", []))
            for service in document["services"].values()
        ),
        "document": document,
    }


def render_compose_for_lock() -> dict[str, Any]:
    inspection = inspect_lock_material()
    if inspection["state"] == "invalid-mixed-placeholder-and-real-digests":
        abort(65, "artifact-lock-mixed-placeholder-state")
    if inspection["state"] == "complete":
        refs = parse_locks()["refs"]
        binding = "exact-reviewed-lock"
    else:
        zero_digest = "0" * 64
        refs = {
            "python": f"docker.io/library/python@sha256:{zero_digest}",
            "collector": (
                "docker.io/otel/opentelemetry-collector-contrib@sha256:"
                f"{zero_digest}"
            ),
        }
        binding = "synthetic-substitution-for-static-render-only"
    result = render_compose(refs, "static-validation-owner", binding)
    result["lockState"] = inspection["state"]
    return result


def compose_command(
    state: dict[str, Any], *args: str, timeout: float = 60, check: bool = True
):
    env_path = state["_rootPath"] / "runtime.env"
    validate_owned_file(env_path)
    return command(
        [
            "docker",
            "compose",
            "--project-name",
            PROJECT_NAME,
            "--env-file",
            str(env_path),
            "--file",
            str(COMPOSE_PATH),
            *args,
        ],
        timeout=timeout,
        check=check,
    )


def container_ids(project: str) -> list[str]:
    result = command(
        [
            "docker",
            "container",
            "ls",
            "--all",
            "--filter",
            f"label=com.docker.compose.project={project}",
            "--format",
            "{{.ID}}",
        ]
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def network_ids(project: str) -> list[str]:
    result = command(
        [
            "docker",
            "network",
            "ls",
            "--filter",
            f"label=com.docker.compose.project={project}",
            "--format",
            "{{.ID}}",
        ]
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def inspect_container(container_id: str) -> dict[str, Any]:
    result = command(["docker", "container", "inspect", container_id])
    value = json.loads(result.stdout)
    if not isinstance(value, list) or len(value) != 1:
        abort(70, "container-inspection-shape-invalid")
    return value[0]


def validate_runtime_resources(
    state: dict[str, Any],
    require_all: bool = True,
    allow_cleanup_only_legacy_loopback_ports: bool = False,
) -> dict[str, str]:
    parsed = parse_locks()
    if state.get("lockDigest") != parsed["digest"]:
        abort(65, "active-runtime-artifact-lock-changed")
    by_service: dict[str, str] = {}
    for container_id in container_ids(PROJECT_NAME):
        record = inspect_container(container_id)
        labels = record.get("Config", {}).get("Labels", {})
        service = labels.get("com.docker.compose.service")
        if (
            labels.get("com.reliability-atlas.managed") != "true"
            or labels.get("com.reliability-atlas.lesson") != LESSON
            or labels.get("com.reliability-atlas.owner-token") != state["token"]
            or labels.get("com.docker.compose.project") != PROJECT_NAME
            or service not in EXPECTED_SERVICES
            or service in by_service
        ):
            abort(65, f"unexpected-or-unowned-project-container-{container_id}")
        expected_image = (
            parsed["refs"]["python"]
            if service in {"service-a", "service-b"}
            else parsed["refs"]["collector"]
        )
        configured_image = record.get("Config", {}).get("Image")
        if not isinstance(configured_image, str) or "@" not in configured_image:
            abort(65, f"runtime-image-not-digest-addressed-{service}")
        configured_repository, configured_digest = configured_image.rsplit("@", 1)
        expected_repository, expected_digest = expected_image.rsplit("@", 1)
        if (
            configured_digest != expected_digest
            or normalize_repository(configured_repository)
            != normalize_repository(expected_repository)
        ):
            abort(65, f"runtime-image-digest-mismatch-{service}")
        host_config = record.get("HostConfig", {})
        expected_user = (
            f"{CURRENT_UID}:{CURRENT_GID}"
            if service in {"service-a", "service-b"}
            else "10001:10001"
        )
        expected_tmpfs = (
            {
                "/tmp": (
                    f"rw,nosuid,nodev,size=96m,uid={CURRENT_UID},"
                    f"gid={CURRENT_GID},mode=0700"
                )
            }
            if service in {"service-a", "service-b"}
            else {
                "/tmp": "rw,nosuid,nodev,noexec,size=16m,uid=10001,gid=10001,mode=0700"
            }
        )
        network_settings = record.get("NetworkSettings", {}).get("Networks") or {}
        if (
            host_config.get("Privileged") is not False
            or host_config.get("ReadonlyRootfs") is not True
            or host_config.get("CapDrop") != ["ALL"]
            or (host_config.get("CapAdd") or [])
            or host_config.get("SecurityOpt") != ["no-new-privileges:true"]
            or host_config.get("NetworkMode") != f"{PROJECT_NAME}_telemetry"
            or set(network_settings) != {f"{PROJECT_NAME}_telemetry"}
            or record.get("Config", {}).get("User") != expected_user
            or host_config.get("Memory") != RUNTIME_MEMORY_BYTES
            or host_config.get("NanoCpus") != RUNTIME_NANO_CPUS
            or host_config.get("PidsLimit") != RUNTIME_PIDS_LIMIT
            or host_config.get("RestartPolicy", {}).get("Name") != "no"
            or host_config.get("AutoRemove") is not False
            or host_config.get("Tmpfs") != expected_tmpfs
        ):
            abort(65, f"runtime-container-safety-contract-mismatch-{service}")
        port_bindings = host_config.get("PortBindings") or {}
        if port_bindings and (
            not allow_cleanup_only_legacy_loopback_ports
            or port_bindings != LEGACY_LOOPBACK_BINDINGS[service]
        ):
            abort(65, f"runtime-published-port-binding-{service}")
        for mount in record.get("Mounts", []):
            source = str(mount.get("Source", "")).lower()
            destination = str(mount.get("Destination", "")).lower()
            if "docker.sock" in source or "docker.sock" in destination:
                abort(65, f"runtime-docker-socket-mount-{service}")
            if mount.get("Type") == "bind" and mount.get("RW") is not False:
                abort(65, f"runtime-writable-bind-mount-{service}")
        if require_all and record.get("State", {}).get("Running") is not True:
            abort(70, f"runtime-service-not-running-{service}")
        by_service[service] = record["Id"]
    if require_all and set(by_service) != EXPECTED_SERVICES:
        abort(70, "runtime-service-set-incomplete")
    networks = network_ids(PROJECT_NAME)
    if require_all and len(networks) != 1:
        abort(70, "runtime-network-set-incomplete")
    for network_id in networks:
        inspected = command(["docker", "network", "inspect", network_id])
        values = json.loads(inspected.stdout)
        if not isinstance(values, list) or len(values) != 1:
            abort(70, "network-inspection-shape-invalid")
        network = values[0]
        labels = network.get("Labels", {})
        if (
            labels.get("com.reliability-atlas.managed") != "true"
            or labels.get("com.reliability-atlas.lesson") != LESSON
            or labels.get("com.reliability-atlas.owner-token") != state["token"]
            or labels.get("com.docker.compose.project") != PROJECT_NAME
            or labels.get("com.docker.compose.network") != "telemetry"
            or not network.get("Internal")
        ):
            abort(65, f"unexpected-or-unowned-project-network-{network_id}")
    return by_service


def runtime_compose_receipt(state: dict[str, Any]) -> dict[str, Any]:
    parsed = parse_locks()
    rendered = compose_command(state, "config", "--format", "json", timeout=30)
    try:
        document = json.loads(rendered.stdout)
    except json.JSONDecodeError:
        abort(65, "active-runtime-compose-json-invalid")
    if not isinstance(document, dict):
        abort(65, "active-runtime-compose-root-invalid")
    validate_resolved_compose(document, parsed["refs"], state["token"])
    canonical = json.dumps(document, sort_keys=True, separators=(",", ":")).encode()
    return {
        "sourceSha256": sha256_file(COMPOSE_PATH),
        "resolvedSha256": sha256_bytes(canonical),
    }


def runtime_resource_receipts(state: dict[str, Any]) -> dict[str, Any]:
    resources = validate_runtime_resources(state)
    receipts: dict[str, Any] = {}
    relevant_environment_keys = {
        "LAB_DOWNSTREAM_URL",
        "OTEL_BSP_MAX_EXPORT_BATCH_SIZE",
        "OTEL_BSP_MAX_QUEUE_SIZE",
        "OTEL_BSP_SCHEDULE_DELAY",
        "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT",
        "OTEL_SERVICE_NAME",
        "OTEL_TRACES_SAMPLER_ARG",
        "PYTHONDONTWRITEBYTECODE",
        "PYTHONPATH",
    }
    for service, container_id in sorted(resources.items()):
        record = inspect_container(container_id)
        config = record.get("Config", {})
        environment_entries = sorted(config.get("Env") or [])
        environment_map = {
            entry.split("=", 1)[0]: entry.split("=", 1)[1]
            for entry in environment_entries
            if "=" in entry
        }
        command_document = {
            "entrypoint": config.get("Entrypoint"),
            "command": config.get("Cmd"),
        }
        security_document = {
            "autoRemove": record.get("HostConfig", {}).get("AutoRemove"),
            "capAdd": record.get("HostConfig", {}).get("CapAdd"),
            "capDrop": record.get("HostConfig", {}).get("CapDrop"),
            "memory": record.get("HostConfig", {}).get("Memory"),
            "nanoCpus": record.get("HostConfig", {}).get("NanoCpus"),
            "networkMode": record.get("HostConfig", {}).get("NetworkMode"),
            "networkMembership": sorted(
                (record.get("NetworkSettings", {}).get("Networks") or {}).keys()
            ),
            "pidsLimit": record.get("HostConfig", {}).get("PidsLimit"),
            "portBindings": record.get("HostConfig", {}).get("PortBindings"),
            "privileged": record.get("HostConfig", {}).get("Privileged"),
            "readonlyRootfs": record.get("HostConfig", {}).get("ReadonlyRootfs"),
            "restartPolicy": record.get("HostConfig", {}).get("RestartPolicy"),
            "securityOpt": record.get("HostConfig", {}).get("SecurityOpt"),
            "tmpfs": record.get("HostConfig", {}).get("Tmpfs"),
            "user": config.get("User"),
        }
        mount_document = sorted(
            (
                {
                    "type": mount.get("Type"),
                    "sourceSha256": sha256_bytes(
                        str(mount.get("Source", "")).encode()
                    ),
                    "destination": mount.get("Destination"),
                    "readWrite": mount.get("RW"),
                }
                for mount in record.get("Mounts", [])
            ),
            key=lambda item: str(item["destination"]),
        )
        receipts[service] = {
            "containerId": record.get("Id"),
            "containerCreatedAt": record.get("Created"),
            "imageReference": config.get("Image"),
            "imageContentId": record.get("Image"),
            "effectiveCommandSha256": sha256_bytes(
                json.dumps(
                    command_document, sort_keys=True, separators=(",", ":")
                ).encode()
            ),
            "effectiveEnvironmentSha256": sha256_bytes(
                json.dumps(environment_entries, separators=(",", ":")).encode()
            ),
            "effectiveEnvironmentKeys": sorted(environment_map),
            "relevantEnvironment": {
                key: environment_map[key]
                for key in sorted(relevant_environment_keys & set(environment_map))
            },
            "securityContractSha256": sha256_bytes(
                json.dumps(
                    security_document, sort_keys=True, separators=(",", ":")
                ).encode()
            ),
            "mountContractSha256": sha256_bytes(
                json.dumps(
                    mount_document, sort_keys=True, separators=(",", ":")
                ).encode()
            ),
        }
    return receipts


def evidence_binding(
    state: dict[str, Any],
    action: str,
    workload: dict[str, Any],
    window_started_at: str,
    window_finished_at: str,
) -> dict[str, Any]:
    compose_receipt = runtime_compose_receipt(state)
    lock_inspection = inspect_lock_material()
    return {
        "schemaVersion": 1,
        "evidenceId": secrets.token_hex(16),
        "action": action,
        "windowStartedAt": window_started_at,
        "windowFinishedAt": window_finished_at,
        "lifecycleTokenSha256": sha256_bytes(state["token"].encode()),
        "stateIdentity": state["stateIdentity"],
        "rootIdentity": state["rootIdentity"],
        "project": PROJECT_NAME,
        "artifactLockCombinedDigest": lock_inspection["combinedDigest"],
        "artifactLockFileSha256": lock_inspection["artifactLockFileSha256"],
        "requirementsLockFileSha256": lock_inspection["requirementsLockFileSha256"],
        "composeSourceSha256": compose_receipt["sourceSha256"],
        "composeResolvedSha256": compose_receipt["resolvedSha256"],
        "collectorConfigSha256": {
            name: sha256_file(LAB_DIR / "config" / name)
            for name in ("agent-a.yaml", "agent-b.yaml", "gateway.yaml")
        },
        "serviceSourceSha256": {
            name: sha256_file(LAB_DIR / "services" / name)
            for name in ("telemetry.py", "service_a.py", "service_b.py")
        },
        "controllerSourceSha256": sha256_file(LAB_DIR / "lab_controller.py"),
        "wrapperSourceSha256": sha256_file(LAB_DIR / "lab.sh"),
        "resources": runtime_resource_receipts(state),
        "networkIds": network_ids(PROJECT_NAME),
        "workload": workload,
    }


def validate_collector_config(config_path: Path, image_ref: str) -> dict[str, Any]:
    image_record = command(["docker", "image", "inspect", image_ref])
    try:
        image_values = json.loads(image_record.stdout)
    except json.JSONDecodeError:
        abort(65, "collector-image-inspection-json-invalid")
    if not isinstance(image_values, list) or len(image_values) != 1:
        abort(65, "collector-image-inspection-shape-invalid")
    image_content_id = image_values[0].get("Id")
    if not isinstance(image_content_id, str) or not re.fullmatch(
        r"sha256:[0-9a-f]{64}", image_content_id
    ):
        abort(65, "collector-image-content-id-invalid")
    token = secrets.token_hex(8)
    name = f"reliability-atlas-les0027-config-{CURRENT_UID}-{token}"
    validation_started = utc_now()
    create = command(
        [
            "docker",
            "create",
            "--name",
            name,
            "--pull",
            "never",
            "--platform",
            "linux/amd64",
            "--network",
            "none",
            "--read-only",
            "--user",
            "10001:10001",
            "--cap-drop",
            "ALL",
            "--security-opt",
            "no-new-privileges:true",
            "--pids-limit",
            "32",
            "--memory",
            "128m",
            "--cpus",
            "0.50",
            "--tmpfs",
            "/tmp:rw,nosuid,nodev,noexec,size=16m,uid=10001,gid=10001,mode=0700",
            "--mount",
            f"type=bind,src={config_path},dst=/etc/otelcol/config.yaml,readonly",
            "--label",
            "com.reliability-atlas.managed=true",
            "--label",
            f"com.reliability-atlas.lesson={LESSON}",
            "--label",
            f"com.reliability-atlas.owner-token={token}",
            image_ref,
            "validate",
            "--config=/etc/otelcol/config.yaml",
        ]
    )
    container_id = create.stdout.strip()
    if not re.fullmatch(r"[0-9a-f]{64}", container_id):
        abort(70, "collector-validation-container-id-invalid")
    try:
        start_result = command(
            ["docker", "start", "--attach", container_id], timeout=30, check=False
        )
        inspected = inspect_container(container_id)
        state = inspected.get("State", {})
        started_at = state.get("StartedAt")
        finished_at = state.get("FinishedAt")
        if (
            start_result.returncode != 0
            or state.get("Status") != "exited"
            or state.get("Running") is not False
            or state.get("ExitCode") != 0
            or not isinstance(started_at, str)
            or not isinstance(finished_at, str)
            or started_at.startswith("0001-")
            or finished_at.startswith("0001-")
        ):
            abort(65, f"collector-config-validation-failed-{config_path.name}")
        receipt = {
            "config": config_path.name,
            "configSha256": sha256_file(config_path),
            "imageRef": image_ref,
            "imageContentId": image_content_id,
            "validationContainerId": container_id,
            "effectiveEntrypointSha256": sha256_bytes(
                json.dumps(
                    {
                        "entrypoint": inspected.get("Config", {}).get("Entrypoint"),
                        "command": inspected.get("Config", {}).get("Cmd"),
                    },
                    sort_keys=True,
                    separators=(",", ":"),
                ).encode()
            ),
            "startedAt": started_at,
            "finishedAt": finished_at,
            "controllerStartedAt": validation_started,
            "controllerFinishedAt": utc_now(),
            "exitCode": 0,
            "stdoutSha256": sha256_bytes(start_result.stdout.encode()),
            "networkMode": inspected.get("HostConfig", {}).get("NetworkMode"),
        }
    finally:
        removal = command(
            ["docker", "container", "rm", container_id], timeout=15, check=False
        )
        if removal.returncode != 0:
            command(
                ["docker", "container", "rm", "--force", container_id],
                timeout=15,
                check=False,
            )
            abort(70, "collector-validation-container-exact-removal-failed")
    absence = command(["docker", "container", "inspect", container_id], check=False)
    if absence.returncode == 0:
        abort(70, "collector-validation-container-still-present")
    absence_detail = "\n".join(
        value
        for value in (absence.stdout, absence.stderr)
        if isinstance(value, str) and value
    )
    if not re.search(
        r"No such (?:object|container)", absence_detail, re.IGNORECASE
    ):
        abort(70, "collector-validation-container-absence-not-specific")
    return receipt


def validate_configs(parsed: dict[str, Any] | None = None) -> None:
    render = render_compose_for_lock()
    print("verification_mode=configuration-preflight")
    print("compose_render=passed")
    print(f"compose_render_binding={render['binding']}")
    print(f"compose_source_sha256={render['sourceSha256']}")
    print(f"compose_resolved_sha256={render['resolvedSha256']}")
    print(f"compose_service_count={render['serviceCount']}")
    print(f"compose_network_count={render['networkCount']}")
    print(f"compose_published_port_count={render['publishedPortCount']}")
    inspection = inspect_lock_material()
    if inspection["state"] != "complete":
        print("collector_config_validation=blocked")
        print(f"collector_config_validation_reason=artifact-lock-{inspection['state']}")
        print("opentelemetry_runtime_executed=false")
        abort(78, "collector-config-validation-blocked-artifact-lock-incomplete")
    if parsed is None:
        parsed = require_offline_runtime()
    receipts = []
    for name in ("agent-a.yaml", "agent-b.yaml", "gateway.yaml"):
        receipt = validate_collector_config(
            LAB_DIR / "config" / name, parsed["refs"]["collector"]
        )
        receipts.append(receipt)
        print(f"collector_config_valid={name}")
        print(f"collector_config_sha256_{name[:-5]}={receipt['configSha256']}")
        print(f"collector_validation_image_id_{name[:-5]}={receipt['imageContentId']}")
        print(f"collector_validation_container_id_{name[:-5]}={receipt['validationContainerId']}")
    print("collector_config_validation_complete=true")
    print("network_mode=none")
    print(f"collector_validation_receipt_sha256={sha256_bytes(json.dumps(receipts, sort_keys=True, separators=(',', ':')).encode())}")


def setup() -> None:
    parsed = require_offline_runtime()
    if (
        STATE_PATH.exists()
        or STATE_SETUP_PATH.exists()
        or list(STATE_PATH.parent.glob(STATE_RECOVERY_GLOB))
    ):
        abort(73, "state-already-exists")
    if container_ids(PROJECT_NAME) or network_ids(PROJECT_NAME):
        abort(73, "untracked-project-resources-already-exist")
    validate_configs(parsed)

    try:
        STATE_SETUP_PATH.mkdir(mode=0o700)
    except FileExistsError:
        abort(73, "state-race-lost")
    setup_identity = identity(STATE_SETUP_PATH)
    token = secrets.token_hex(16)
    root: Path | None = None
    published = False
    try:
        root = Path(
            tempfile.mkdtemp(
                prefix=f"reliability-atlas-LES-0027-{CURRENT_UID}.", dir="/tmp"
            )
        )
        os.chmod(root, 0o700)
        write_exclusive(root / "runtime.env", runtime_env(parsed, token).encode())
        state_seed = {
            "schemaVersion": 1,
            "lesson": LESSON,
            "uid": CURRENT_UID,
            "gid": CURRENT_GID,
            "token": token,
            "project": PROJECT_NAME,
            "labDirectory": str(LAB_DIR),
            "lockDigest": parsed["digest"],
            "stateIdentity": setup_identity,
            "root": str(root),
            "rootIdentity": identity(root),
        }
        write_json_exclusive(STATE_SETUP_PATH / "state.json", state_seed)
        state_document(STATE_SETUP_PATH)
        if STATE_PATH.exists():
            abort(73, "state-path-appeared-before-publish")
        os.rename(STATE_SETUP_PATH, STATE_PATH)
        published = True
        state = state_document()
        compose_command(state, "config", "--quiet", timeout=30)
        compose_command(
            state,
            "up",
            "--detach",
            "--pull",
            "never",
            "--no-build",
            "--wait",
            "--wait-timeout",
            "60",
            timeout=90,
        )
        resources = validate_runtime_resources(state)
        wait_for_service(resources["service-a"])
        print("setup_complete=true")
        print(f"lifecycle_token={token}")
        print(f"state_identity={state['stateIdentity']}")
        print(f"root={root}")
        print(f"root_identity={state['rootIdentity']}")
        print(f"project={PROJECT_NAME}")
        print(f"containers={len(resources)}")
        print("network_internal=true")
        print("runtime_pull_policy=never")
        print("runtime_package_index=disabled")
    except Exception:
        if not published:
            if root is not None and root.exists():
                validate_owned_directory(root)
                for child in list(root.iterdir()):
                    if child.name != "runtime.env":
                        abort(65, f"unexpected-unpublished-root-child-{child.name}")
                    validate_owned_file(child)
                    child.unlink()
                root.rmdir()
            if STATE_SETUP_PATH.exists():
                validate_owned_directory(STATE_SETUP_PATH, setup_identity)
                for child in list(STATE_SETUP_PATH.iterdir()):
                    if child.name != "state.json":
                        abort(65, f"unexpected-unpublished-state-child-{child.name}")
                    validate_owned_file(child)
                    child.unlink()
                STATE_SETUP_PATH.rmdir()
            print("setup_unpublished_state_cleaned=true", file=sys.stderr)
        else:
            print(f"setup_incomplete_lifecycle_token={token}", file=sys.stderr)
            print(
                "setup_recovery=run-status-then-token-guarded-cleanup",
                file=sys.stderr,
            )
        raise


CONTAINER_HTTP_GET = (
    "import json,sys,urllib.request;"
    "response=urllib.request.urlopen(sys.argv[1],timeout=float(sys.argv[2]));"
    "print(json.dumps({'status':response.status,'body':response.read().decode()},"
    "separators=(',',':')))"
)


def container_http_get(container_id: str, url: str, timeout: float) -> dict[str, Any]:
    if not re.fullmatch(r"[0-9a-f]{64}", container_id):
        abort(70, "container-http-target-id-invalid")
    result = command(
        [
            "docker",
            "container",
            "exec",
            container_id,
            "python",
            "-c",
            CONTAINER_HTTP_GET,
            url,
            str(timeout),
        ],
        timeout=timeout + 5,
        check=False,
    )
    if result.returncode != 0:
        abort(70, f"container-http-request-failed-exit-{result.returncode}")
    try:
        value = json.loads(result.stdout)
    except json.JSONDecodeError:
        abort(70, "container-http-response-invalid-json")
    if not isinstance(value, dict) or not isinstance(value.get("status"), int):
        abort(70, "container-http-response-shape-invalid")
    return value


def request_checkout(
    service_a_id: str, mode: str, operation_id: str | None = None
) -> dict[str, Any]:
    if operation_id is None:
        operation_id = secrets.token_hex(8)
    if not re.fullmatch(r"[0-9a-f]{16}", operation_id):
        abort(70, "controller-operation-id-invalid")
    url = (
        "http://127.0.0.1:8080/checkout?"
        + urllib.parse.urlencode({"mode": mode, "operation_id": operation_id})
    )
    envelope = container_http_get(service_a_id, url, 4)
    if envelope["status"] != 200:
        abort(70, f"service-response-status-{envelope['status']}")
    try:
        value = json.loads(envelope["body"])
    except json.JSONDecodeError:
        abort(70, "service-response-invalid-json")
    if not isinstance(value, dict):
        abort(70, "service-response-shape-invalid")
    if value.get("operation_id") != operation_id:
        abort(70, "service-response-operation-id-mismatch")
    return value


def wait_for_service(service_a_id: str) -> None:
    deadline = time.monotonic() + 30
    last_error = "not-attempted"
    while time.monotonic() < deadline:
        try:
            response = container_http_get(
                service_a_id, "http://127.0.0.1:8080/healthz", 1
            )
            if response["status"] == 200:
                return
            last_error = f"status-{response['status']}"
        except LabError as exc:
            last_error = exc.token
        time.sleep(0.25)
    abort(70, f"service-health-timeout-{last_error}")


def ensure_record_absent(root: Path, name: str) -> Path:
    path = root / name
    if path.exists() or path.is_symlink():
        abort(73, f"record-already-exists-{name}")
    return path


def save_record(state: dict[str, Any], name: str, value: dict[str, Any]) -> None:
    if name not in RECORD_NAMES:
        abort(70, "controller-record-name-not-allowlisted")
    if not isinstance(value.get("evidenceBinding"), dict):
        abort(70, "controller-record-missing-evidence-binding")
    payload = {
        "schemaVersion": 2,
        "lesson": LESSON,
        "recordName": name,
        "recordCreatedAt": utc_now(),
        **value,
    }
    payload["recordPayloadSha256"] = sha256_bytes(
        json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    )
    write_json_exclusive(
        ensure_record_absent(state["_rootPath"], name),
        payload,
    )


def load_record(state: dict[str, Any], name: str) -> dict[str, Any]:
    if name not in RECORD_NAMES:
        abort(70, "controller-record-name-not-allowlisted")
    path = state["_rootPath"] / name
    validate_owned_file(path)
    value = read_json(path)
    if (
        value.get("lesson") != LESSON
        or value.get("schemaVersion") != 2
        or value.get("recordName") != name
    ):
        abort(65, f"record-identity-invalid-{name}")
    recorded_digest = value.get("recordPayloadSha256")
    unsigned = dict(value)
    unsigned.pop("recordPayloadSha256", None)
    expected_digest = sha256_bytes(
        json.dumps(unsigned, sort_keys=True, separators=(",", ":")).encode()
    )
    if recorded_digest != expected_digest:
        abort(65, f"record-payload-digest-invalid-{name}")
    binding = value.get("evidenceBinding")
    if not isinstance(binding, dict):
        abort(65, f"record-evidence-binding-missing-{name}")
    expected_actions = {
        "baseline.json": "run-baseline",
        "broken-context.json": "run-broken-context",
        "recovery.json": "recover-context",
        "gateway-interruption.json": "interrupt-gateway",
        "sampling.json": "compare-sampling",
    }
    if (
        binding.get("schemaVersion") != 1
        or not re.fullmatch(r"[0-9a-f]{32}", str(binding.get("evidenceId", "")))
        or binding.get("action") != expected_actions[name]
        or not isinstance(binding.get("workload"), dict)
    ):
        abort(65, f"record-evidence-envelope-invalid-{name}")
    try:
        window_started = dt.datetime.fromisoformat(
            str(binding["windowStartedAt"]).replace("Z", "+00:00")
        )
        window_finished = dt.datetime.fromisoformat(
            str(binding["windowFinishedAt"]).replace("Z", "+00:00")
        )
        record_created = dt.datetime.fromisoformat(
            str(value["recordCreatedAt"]).replace("Z", "+00:00")
        )
    except (KeyError, ValueError):
        abort(65, f"record-time-boundary-invalid-{name}")
    if not window_started < window_finished <= record_created:
        abort(65, f"record-time-order-invalid-{name}")
    inspection = inspect_lock_material()
    compose_receipt = runtime_compose_receipt(state)
    expected_static_values = {
        "lifecycleTokenSha256": sha256_bytes(state["token"].encode()),
        "stateIdentity": state["stateIdentity"],
        "rootIdentity": state["rootIdentity"],
        "project": PROJECT_NAME,
        "artifactLockCombinedDigest": inspection["combinedDigest"],
        "artifactLockFileSha256": inspection["artifactLockFileSha256"],
        "requirementsLockFileSha256": inspection["requirementsLockFileSha256"],
        "composeSourceSha256": sha256_file(COMPOSE_PATH),
        "composeResolvedSha256": compose_receipt["resolvedSha256"],
        "controllerSourceSha256": sha256_file(LAB_DIR / "lab_controller.py"),
        "wrapperSourceSha256": sha256_file(LAB_DIR / "lab.sh"),
    }
    for key, expected in expected_static_values.items():
        if binding.get(key) != expected:
            abort(65, f"record-evidence-binding-invalid-{name}-{key}")
    expected_config_hashes = {
        config_name: sha256_file(LAB_DIR / "config" / config_name)
        for config_name in ("agent-a.yaml", "agent-b.yaml", "gateway.yaml")
    }
    if binding.get("collectorConfigSha256") != expected_config_hashes:
        abort(65, f"record-config-binding-invalid-{name}")
    expected_source_hashes = {
        source_name: sha256_file(LAB_DIR / "services" / source_name)
        for source_name in ("telemetry.py", "service_a.py", "service_b.py")
    }
    if binding.get("serviceSourceSha256") != expected_source_hashes:
        abort(65, f"record-source-binding-invalid-{name}")
    resources = binding.get("resources")
    if not isinstance(resources, dict) or set(resources) != EXPECTED_SERVICES:
        abort(65, f"record-resource-binding-invalid-{name}")
    current_resources = validate_runtime_resources(state)
    current_receipts = runtime_resource_receipts(state)
    for stable_service in ("agent-a", "agent-b", "gateway"):
        if resources[stable_service].get("containerId") != current_resources[stable_service]:
            abort(65, f"record-stable-resource-changed-{name}-{stable_service}")
        if resources[stable_service] != current_receipts[stable_service]:
            abort(65, f"record-stable-resource-receipt-changed-{name}-{stable_service}")
    if binding.get("networkIds") != network_ids(PROJECT_NAME):
        abort(65, f"record-network-binding-invalid-{name}")
    workload = binding["workload"]
    if name in {"baseline.json", "broken-context.json", "recovery.json"}:
        response = value.get("response")
        if (
            not isinstance(response, dict)
            or workload.get("operationCount") != 1
            or workload.get("operationId") != response.get("operation_id")
            or workload.get("mode") != response.get("mode")
        ):
            abort(65, f"record-workload-binding-invalid-{name}")
    elif name == "gateway-interruption.json":
        if (
            workload.get("operationCount") != 4
            or workload.get("operationIds") != value.get("operationIds")
            or workload.get("gatewayContainerId") != current_resources["gateway"]
        ):
            abort(65, "record-workload-binding-invalid-gateway-interruption")
    else:
        full_ids = workload.get("fullOperationIds")
        quarter_ids = workload.get("quarterOperationIds")
        if (
            workload.get("operationCountPerRatio") != 32
            or workload.get("ratios") != [1.0, 0.25]
            or workload.get("restoredRatio") != 1.0
            or not isinstance(full_ids, list)
            or not isinstance(quarter_ids, list)
            or len(full_ids) != 32
            or len(quarter_ids) != 32
            or len(set(full_ids)) != 32
            or len(set(quarter_ids)) != 32
        ):
            abort(65, "record-workload-binding-invalid-sampling")
    return value


PROMETHEUS_SAMPLE = re.compile(
    r"^([a-zA-Z_:][a-zA-Z0-9_:]*)(?:\{([^}]*)\})?\s+"
    r"([-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)$"
)
PROMETHEUS_LABEL = re.compile(r'([a-zA-Z_][a-zA-Z0-9_]*)="([^"\\]*)"')


def parse_prometheus_samples(text: str) -> list[dict[str, Any]]:
    samples: list[dict[str, Any]] = []
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        match = PROMETHEUS_SAMPLE.fullmatch(line)
        if match is None:
            continue
        labels = {
            key: value for key, value in PROMETHEUS_LABEL.findall(match.group(2) or "")
        }
        samples.append(
            {"name": match.group(1), "labels": labels, "value": float(match.group(3))}
        )
    return samples


def metric_total(
    samples: list[dict[str, Any]], name: str, required_labels: dict[str, str]
) -> tuple[int | float, bool]:
    matches = [
        sample
        for sample in samples
        if sample["name"] == name
        and all(sample["labels"].get(key) == value for key, value in required_labels.items())
    ]
    total = sum(sample["value"] for sample in matches)
    value: int | float = int(total) if total.is_integer() else total
    return value, bool(matches)


def collector_metric_snapshot(
    probe_container_id: str, collector: str
) -> dict[str, Any]:
    if collector not in {"agent-a", "agent-b", "gateway"}:
        abort(70, "collector-metric-target-not-allowlisted")
    envelope = container_http_get(
        probe_container_id, f"http://{collector}:8888/metrics", 3
    )
    if envelope["status"] != 200 or not isinstance(envelope.get("body"), str):
        abort(70, f"collector-metrics-response-invalid-{collector}")
    body = envelope["body"]
    samples = parse_prometheus_samples(body)
    receiver_labels = {
        "receiver": "otlp",
        "transport": "grpc" if collector == "gateway" else "http",
    }
    processor_labels = {"processor": "memory_limiter"}
    exporter_labels = {
        "exporter": "debug" if collector == "gateway" else "otlp/gateway"
    }
    selectors = {
        "receiverAcceptedSpans": ("otelcol_receiver_accepted_spans", receiver_labels),
        "receiverRefusedSpans": ("otelcol_receiver_refused_spans", receiver_labels),
        "processorAcceptedSpans": (
            "otelcol_processor_memory_limiter_accepted_spans",
            processor_labels,
        ),
        "processorRefusedSpans": (
            "otelcol_processor_memory_limiter_refused_spans",
            processor_labels,
        ),
        "exporterSentSpans": ("otelcol_exporter_sent_spans", exporter_labels),
        "exporterSendFailedSpans": (
            "otelcol_exporter_send_failed_spans",
            exporter_labels,
        ),
        "exporterEnqueueFailedSpans": (
            "otelcol_exporter_enqueue_failed_spans",
            exporter_labels,
        ),
    }
    if collector != "gateway":
        selectors.update(
            {
                "exporterQueueSize": (
                    "otelcol_exporter_queue_size",
                    {"exporter": "otlp/gateway", "data_type": "traces"},
                ),
                "exporterQueueCapacity": (
                    "otelcol_exporter_queue_capacity",
                    {"exporter": "otlp/gateway", "data_type": "traces"},
                ),
            }
        )
    values: dict[str, int | float] = {}
    presence: dict[str, bool] = {}
    for field, (metric_name, labels) in selectors.items():
        values[field], presence[field] = metric_total(samples, metric_name, labels)
    return {
        "collector": collector,
        "counterUnit": "spans",
        "gaugeUnit": "queue-items",
        "values": values,
        "metricPresent": presence,
        "rawExpositionSha256": sha256_bytes(body.encode()),
    }


def service_telemetry_snapshot(
    probe_container_id: str, hostname: str, port: int
) -> dict[str, Any]:
    if (hostname, port) not in {("127.0.0.1", 8080), ("service-b", 8081)}:
        abort(70, "service-telemetry-target-not-allowlisted")
    envelope = container_http_get(
        probe_container_id,
        f"http://{hostname}:{port}/telemetryz?flush=true",
        4,
    )
    if envelope["status"] != 200:
        abort(70, f"service-telemetry-status-{envelope['status']}")
    try:
        document = json.loads(envelope["body"])
    except json.JSONDecodeError:
        abort(70, "service-telemetry-response-invalid-json")
    telemetry = document.get("telemetry") if isinstance(document, dict) else None
    counters = telemetry.get("counters") if isinstance(telemetry, dict) else None
    expected = {
        "spansStarted",
        "spansEnded",
        "exportAttemptedSpans",
        "exportSucceededSpans",
        "exportFailedSpans",
    }
    if (
        not isinstance(counters, dict)
        or set(counters) != expected
        or any(not isinstance(value, int) or value < 0 for value in counters.values())
        or telemetry.get("counterUnit") != "spans"
        or telemetry.get("forceFlushRequested") is not True
        or telemetry.get("forceFlushSucceeded") is not True
    ):
        abort(70, "service-telemetry-contract-invalid")
    return telemetry


def pipeline_snapshot(resources: dict[str, str]) -> dict[str, Any]:
    service_a_id = resources["service-a"]
    service_a = service_telemetry_snapshot(service_a_id, "127.0.0.1", 8080)
    service_b = service_telemetry_snapshot(service_a_id, "service-b", 8081)
    time.sleep(0.1)
    return {
        "capturedAt": utc_now(),
        "resourceContainerIds": dict(sorted(resources.items())),
        "resourceProcessStartedAt": {
            service: inspect_container(container_id).get("State", {}).get("StartedAt")
            for service, container_id in sorted(resources.items())
        },
        "serviceA": service_a,
        "serviceB": service_b,
        "agentA": collector_metric_snapshot(service_a_id, "agent-a"),
        "agentB": collector_metric_snapshot(service_a_id, "agent-b"),
        "gateway": collector_metric_snapshot(service_a_id, "gateway"),
    }


def nested_delta(before: dict[str, Any], after: dict[str, Any], *path: str) -> int | float:
    before_value: Any = before
    after_value: Any = after
    for key in path:
        before_value = before_value[key]
        after_value = after_value[key]
    if not isinstance(before_value, (int, float)) or not isinstance(
        after_value, (int, float)
    ):
        abort(70, "pipeline-counter-value-invalid")
    delta = after_value - before_value
    return int(delta) if isinstance(delta, float) and delta.is_integer() else delta


def reconcile_single_operation(
    before: dict[str, Any],
    after: dict[str, Any],
    freshness_seconds: float,
    operation_count: int = 1,
    allow_gateway_restart: bool = False,
) -> dict[str, Any]:
    if operation_count < 1 or operation_count > 16:
        abort(70, "pipeline-operation-count-out-of-bounds")
    if before["resourceContainerIds"] != after["resourceContainerIds"]:
        abort(70, "pipeline-counter-reset-boundary-crossed")
    process_changes = {
        service
        for service in EXPECTED_SERVICES
        if before["resourceProcessStartedAt"].get(service)
        != after["resourceProcessStartedAt"].get(service)
    }
    expected_process_changes = {"gateway"} if allow_gateway_restart else set()
    if process_changes != expected_process_changes:
        abort(70, "pipeline-process-reset-boundary-unexpected")
    paths = {
        "serviceASpansEnded": ("serviceA", "counters", "spansEnded"),
        "serviceBSpansEnded": ("serviceB", "counters", "spansEnded"),
        "serviceAExportSucceeded": (
            "serviceA",
            "counters",
            "exportSucceededSpans",
        ),
        "serviceBExportSucceeded": (
            "serviceB",
            "counters",
            "exportSucceededSpans",
        ),
        "serviceAExportFailed": ("serviceA", "counters", "exportFailedSpans"),
        "serviceBExportFailed": ("serviceB", "counters", "exportFailedSpans"),
        "agentAReceiverAccepted": ("agentA", "values", "receiverAcceptedSpans"),
        "agentBReceiverAccepted": ("agentB", "values", "receiverAcceptedSpans"),
        "agentAProcessorAccepted": ("agentA", "values", "processorAcceptedSpans"),
        "agentBProcessorAccepted": ("agentB", "values", "processorAcceptedSpans"),
        "agentAExporterSent": ("agentA", "values", "exporterSentSpans"),
        "agentBExporterSent": ("agentB", "values", "exporterSentSpans"),
        "agentAReceiverRefused": ("agentA", "values", "receiverRefusedSpans"),
        "agentBReceiverRefused": ("agentB", "values", "receiverRefusedSpans"),
        "agentAProcessorRefused": ("agentA", "values", "processorRefusedSpans"),
        "agentBProcessorRefused": ("agentB", "values", "processorRefusedSpans"),
        "agentAExporterSendFailed": (
            "agentA",
            "values",
            "exporterSendFailedSpans",
        ),
        "agentBExporterSendFailed": (
            "agentB",
            "values",
            "exporterSendFailedSpans",
        ),
        "agentAExporterEnqueueFailed": (
            "agentA",
            "values",
            "exporterEnqueueFailedSpans",
        ),
        "agentBExporterEnqueueFailed": (
            "agentB",
            "values",
            "exporterEnqueueFailedSpans",
        ),
        "gatewayReceiverAccepted": ("gateway", "values", "receiverAcceptedSpans"),
        "gatewayProcessorAccepted": ("gateway", "values", "processorAcceptedSpans"),
        "gatewayExporterSent": ("gateway", "values", "exporterSentSpans"),
        "gatewayReceiverRefused": ("gateway", "values", "receiverRefusedSpans"),
        "gatewayProcessorRefused": (
            "gateway",
            "values",
            "processorRefusedSpans",
        ),
        "gatewayExporterSendFailed": (
            "gateway",
            "values",
            "exporterSendFailedSpans",
        ),
    }
    deltas = {name: nested_delta(before, after, *path) for name, path in paths.items()}
    if allow_gateway_restart:
        for field in (
            "gatewayReceiverAccepted",
            "gatewayProcessorAccepted",
            "gatewayExporterSent",
            "gatewayReceiverRefused",
            "gatewayProcessorRefused",
            "gatewayExporterSendFailed",
        ):
            deltas[field] = after["gateway"]["values"][
                {
                    "gatewayReceiverAccepted": "receiverAcceptedSpans",
                    "gatewayProcessorAccepted": "processorAcceptedSpans",
                    "gatewayExporterSent": "exporterSentSpans",
                    "gatewayReceiverRefused": "receiverRefusedSpans",
                    "gatewayProcessorRefused": "processorRefusedSpans",
                    "gatewayExporterSendFailed": "exporterSendFailedSpans",
                }[field]
            ]
    expected = {
        "serviceASpansEnded": 2 * operation_count,
        "serviceBSpansEnded": operation_count,
        "serviceAExportSucceeded": 2 * operation_count,
        "serviceBExportSucceeded": operation_count,
        "serviceAExportFailed": 0,
        "serviceBExportFailed": 0,
        "agentAReceiverAccepted": 2 * operation_count,
        "agentBReceiverAccepted": operation_count,
        "agentAProcessorAccepted": 2 * operation_count,
        "agentBProcessorAccepted": operation_count,
        "agentAExporterSent": 2 * operation_count,
        "agentBExporterSent": operation_count,
        "agentAReceiverRefused": 0,
        "agentBReceiverRefused": 0,
        "agentAProcessorRefused": 0,
        "agentBProcessorRefused": 0,
        "agentAExporterSendFailed": 0,
        "agentBExporterSendFailed": 0,
        "agentAExporterEnqueueFailed": 0,
        "agentBExporterEnqueueFailed": 0,
        "gatewayReceiverAccepted": 3 * operation_count,
        "gatewayProcessorAccepted": 3 * operation_count,
        "gatewayExporterSent": 3 * operation_count,
        "gatewayReceiverRefused": 0,
        "gatewayProcessorRefused": 0,
        "gatewayExporterSendFailed": 0,
    }
    passed = deltas == expected
    return {
        "counterUnit": "spans",
        "freshnessUnit": "seconds",
        "freshnessSeconds": round(freshness_seconds, 6),
        "operationCount": operation_count,
        "counterResetBoundaryCrossed": bool(process_changes),
        "expectedProcessRestarts": sorted(expected_process_changes),
        "observedProcessRestarts": sorted(process_changes),
        "gatewayDeltaSemantics": (
            "absolute-counters-from-new-process-start"
            if allow_gateway_restart
            else "same-process-counter-delta"
        ),
        "before": before,
        "after": after,
        "deltas": deltas,
        "expectedDeltas": expected,
        "perHopReconciliationPassed": passed,
    }


def wait_for_single_operation_evidence(
    resources: dict[str, str], before: dict[str, Any], started: float, timeout: float = 15
) -> dict[str, Any]:
    deadline = time.monotonic() + timeout
    last_evidence: dict[str, Any] | None = None
    while time.monotonic() < deadline:
        after = pipeline_snapshot(resources)
        last_evidence = reconcile_single_operation(
            before, after, time.monotonic() - started
        )
        if last_evidence["perHopReconciliationPassed"]:
            return last_evidence
        time.sleep(0.25)
    if last_evidence is not None:
        print(
            "pipeline_observed_deltas="
            + json.dumps(last_evidence["deltas"], sort_keys=True, separators=(",", ":")),
            file=sys.stderr,
        )
    abort(70, "single-operation-per-hop-reconciliation-timeout")


def wait_for_gateway_traces(
    state: dict[str, Any],
    evidence_tokens: set[str],
    since: str,
    timeout: float = 15,
) -> dict[str, Any] | None:
    resources = validate_runtime_resources(state)
    gateway_id = resources["gateway"]
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        logs = command(
            ["docker", "logs", "--timestamps", "--since", since, gateway_id],
            timeout=10,
            check=False,
        ).stdout
        normalized = logs.lower()
        if all(token.lower() in normalized for token in evidence_tokens):
            evidence_lines = [
                line[:512]
                for line in logs.splitlines()
                if any(token.lower() in line.lower() for token in evidence_tokens)
            ][:64]
            if not evidence_lines:
                abort(70, "gateway-evidence-line-selection-empty")
            return {
                "gatewayContainerId": gateway_id,
                "windowStartedAt": since,
                "collectedAt": utc_now(),
                "soughtTokensSha256": sha256_bytes(
                    json.dumps(sorted(evidence_tokens), separators=(",", ":")).encode()
                ),
                "soughtTokenCount": len(evidence_tokens),
                "allSoughtTokensObserved": True,
                "boundedGatewayLogSha256": sha256_bytes(logs.encode()),
                "boundedGatewayLogLineCount": len(logs.splitlines()),
                "sanitizedEvidenceLines": evidence_lines,
                "sanitizedEvidenceLinesSha256": sha256_bytes(
                    json.dumps(evidence_lines, separators=(",", ":")).encode()
                ),
                "sanitizedEvidenceLineLimit": 64,
                "sanitizedEvidenceCharacterLimitPerLine": 512,
                "logSelection": "docker-logs-timestamps-since-current-operation-start",
            }
        time.sleep(0.5)
    return None


def run_case(case: str) -> None:
    if case not in {"baseline", "broken-context"}:
        abort(64, "run-case-must-be-baseline-or-broken-context")
    state = state_document()
    require_offline_runtime()
    with operation_lock(state):
        resources = validate_runtime_resources(state)
        before = pipeline_snapshot(resources)
        window_started_at = utc_now()
        measurement_started = time.monotonic()
        operation_id = secrets.token_hex(8)
        response = request_checkout(
            resources["service-a"],
            "propagate" if case == "baseline" else "drop-context",
            operation_id,
        )
        expected_joined = case == "baseline"
        if (
            response.get("joined_context") is not expected_joined
            or response.get("async_context_joined") is not expected_joined
            or response.get("parentage_matches") is not True
        ):
            abort(70, f"context-outcome-unexpected-{case}")
        trace_ids = {
            str(response["trace_id"]),
            str(response["worker_trace_id"]),
            str(response["downstream_trace_id"]),
        }
        log_receipt = wait_for_gateway_traces(
            state, trace_ids | {operation_id}, window_started_at
        )
        if log_receipt is None:
            abort(70, f"gateway-debug-export-evidence-timeout-{case}")
        per_hop = wait_for_single_operation_evidence(
            resources, before, measurement_started
        )
        window_finished_at = utc_now()
        binding = evidence_binding(
            state,
            f"run-{case}",
            {
                "operationCount": 1,
                "operationId": operation_id,
                "mode": response["mode"],
                "sourceSampled": response.get("sampled"),
                "carrierType": "bounded-in-process-queue",
            },
            window_started_at,
            window_finished_at,
        )
        save_record(
            state,
            f"{case}.json",
            {
                "case": case,
                "response": response,
                "evidenceBinding": binding,
                "gatewayLogReceipt": log_receipt,
                "perHopEvidence": per_hop,
                "sourceSpanCreationObserved": True,
                "asyncCarrierBoundaryObserved": True,
                "directSdkExportCounterMeasured": True,
                "collectorPerHopCountersMeasured": True,
                "backendIngestProven": False,
            },
        )
    print(f"case={case}")
    print(f"context_joined={str(expected_joined).lower()}")
    print("async_carrier=bounded-in-process-queue")
    print("async_parentage_matches=true")
    print(f"operation_id={operation_id}")
    print("gateway_debug_tokens_observed_in_current_window=true")
    print("direct_sdk_export_counter_measured=true")
    print("collector_per_hop_counters_measured=true")
    print("per_hop_reconciliation_passed=true")
    print(f"source_span_creation_delta={sum(per_hop['deltas'][key] for key in ('serviceASpansEnded', 'serviceBSpansEnded'))}")
    print(f"sdk_export_success_delta={sum(per_hop['deltas'][key] for key in ('serviceAExportSucceeded', 'serviceBExportSucceeded'))}")
    print(f"gateway_sink_visibility_delta={per_hop['deltas']['gatewayExporterSent']}")
    print("backend_ingest_proven=false")


def recover_context() -> None:
    state = state_document()
    require_offline_runtime()
    load_record(state, "broken-context.json")
    with operation_lock(state):
        resources = validate_runtime_resources(state)
        before = pipeline_snapshot(resources)
        window_started_at = utc_now()
        measurement_started = time.monotonic()
        operation_id = secrets.token_hex(8)
        response = request_checkout(resources["service-a"], "propagate", operation_id)
        if (
            response.get("joined_context") is not True
            or response.get("async_context_joined") is not True
            or response.get("parentage_matches") is not True
        ):
            abort(70, "context-recovery-did-not-join")
        trace_ids = {
            str(response["trace_id"]),
            str(response["worker_trace_id"]),
            str(response["downstream_trace_id"]),
        }
        log_receipt = wait_for_gateway_traces(
            state, trace_ids | {operation_id}, window_started_at
        )
        if log_receipt is None:
            abort(70, "gateway-debug-export-evidence-timeout-recovery")
        per_hop = wait_for_single_operation_evidence(
            resources, before, measurement_started
        )
        window_finished_at = utc_now()
        save_record(
            state,
            "recovery.json",
            {
                "case": "recovery",
                "response": response,
                "evidenceBinding": evidence_binding(
                    state,
                    "recover-context",
                    {
                        "operationCount": 1,
                        "operationId": operation_id,
                        "mode": "propagate",
                        "carrierType": "bounded-in-process-queue",
                    },
                    window_started_at,
                    window_finished_at,
                ),
                "gatewayLogReceipt": log_receipt,
                "perHopEvidence": per_hop,
                "asyncCarrierBoundaryObserved": True,
                "directSdkExportCounterMeasured": True,
                "collectorPerHopCountersMeasured": True,
                "backendIngestProven": False,
            },
        )
    print("context_recovered=true")
    print("async_carrier=bounded-in-process-queue")
    print("async_parentage_matches=true")
    print(f"operation_id={operation_id}")
    print("gateway_debug_tokens_observed_in_current_window=true")
    print("collector_per_hop_counters_measured=true")
    print("per_hop_reconciliation_passed=true")
    print("backend_ingest_proven=false")


def bounded_retry_log_evidence(
    resources: dict[str, str], since: str
) -> dict[str, Any]:
    selected: dict[str, list[str]] = {}
    for agent in ("agent-a", "agent-b"):
        result = command(
            [
                "docker",
                "logs",
                "--timestamps",
                "--since",
                since,
                resources[agent],
            ],
            timeout=10,
            check=False,
        )
        if result.returncode != 0:
            abort(70, f"agent-retry-log-read-failed-{agent}")
        selected[agent] = [
            line[:512]
            for line in result.stdout.splitlines()
            if "internal/retry_sender.go" in line and "Will retry" in line
        ][:64]
    return {
        "selection": "collector-retry-sender-current-operation-window",
        "windowStartedAt": since,
        "recordUnit": "retry-log-records",
        "recordCountByAgent": {
            agent: len(lines) for agent, lines in selected.items()
        },
        "sanitizedRecords": selected,
        "sanitizedRecordsSha256": sha256_bytes(
            json.dumps(selected, sort_keys=True, separators=(",", ":")).encode()
        ),
        "recordLimitPerAgent": 64,
        "characterLimitPerRecord": 512,
    }


def interrupt_gateway() -> None:
    state = state_document()
    require_offline_runtime()
    with operation_lock(state):
        resources = validate_runtime_resources(state)
        gateway_id = resources["gateway"]
        responses: list[dict[str, Any]] = []
        operation_ids: list[str] = []
        before = pipeline_snapshot(resources)
        measurement_started = time.monotonic()
        restored = False
        window_started_at = utc_now()
        peak_queue = {"agent-a": 0, "agent-b": 0}
        queue_capacity = {"agent-a": 0, "agent-b": 0}
        queue_observed_at: str | None = None
        oldest_queue_observation_started: float | None = None
        retry_evidence: dict[str, Any] | None = None
        try:
            stopped = command(
                ["docker", "container", "stop", "--time", "3", gateway_id],
                timeout=10,
                check=False,
            )
            if stopped.returncode != 0:
                abort(70, "gateway-stop-failed")
            for _ in range(4):
                operation_id = secrets.token_hex(8)
                response = request_checkout(
                    resources["service-a"], "propagate", operation_id
                )
                if (
                    response.get("joined_context") is not True
                    or response.get("async_context_joined") is not True
                    or response.get("parentage_matches") is not True
                ):
                    abort(70, "request-during-gateway-outage-lost-context")
                operation_ids.append(operation_id)
                responses.append(response)
                if oldest_queue_observation_started is None:
                    oldest_queue_observation_started = time.monotonic()
            service_telemetry_snapshot(
                resources["service-a"], "127.0.0.1", 8080
            )
            service_telemetry_snapshot(resources["service-a"], "service-b", 8081)
            observation_deadline = time.monotonic() + 6
            while time.monotonic() < observation_deadline:
                for agent in ("agent-a", "agent-b"):
                    snapshot = collector_metric_snapshot(
                        resources["service-a"], agent
                    )
                    size = int(snapshot["values"]["exporterQueueSize"])
                    capacity = int(snapshot["values"]["exporterQueueCapacity"])
                    peak_queue[agent] = max(peak_queue[agent], size)
                    queue_capacity[agent] = capacity
                retry_evidence = bounded_retry_log_evidence(resources, window_started_at)
                retry_count = sum(retry_evidence["recordCountByAgent"].values())
                if sum(peak_queue.values()) > 0 and retry_count > 0:
                    queue_observed_at = utc_now()
                    break
                time.sleep(0.1)
            if sum(peak_queue.values()) <= 0:
                abort(70, "gateway-outage-queue-occupancy-not-observed")
            if retry_evidence is None or sum(
                retry_evidence["recordCountByAgent"].values()
            ) <= 0:
                abort(70, "gateway-outage-retry-record-not-observed")
        finally:
            recovery_started = time.monotonic()
            started = command(
                ["docker", "container", "start", gateway_id], timeout=15, check=False
            )
            restored = started.returncode == 0
        if not restored:
            abort(70, "gateway-restore-failed")
        trace_ids = {
            str(response[key])
            for response in responses
            for key in ("trace_id", "worker_trace_id", "downstream_trace_id")
        }
        log_receipt = wait_for_gateway_traces(
            state,
            trace_ids | set(operation_ids),
            window_started_at,
            timeout=20,
        )
        if log_receipt is None:
            abort(70, "agent-retry-evidence-timeout-after-gateway-recovery")
        if oldest_queue_observation_started is None or queue_observed_at is None:
            abort(70, "gateway-outage-queue-time-boundary-missing")
        final_evidence: dict[str, Any] | None = None
        drain_deadline = time.monotonic() + 20
        while time.monotonic() < drain_deadline:
            after = pipeline_snapshot(resources)
            candidate = reconcile_single_operation(
                before,
                after,
                time.monotonic() - measurement_started,
                operation_count=4,
                allow_gateway_restart=True,
            )
            queues_drained = all(
                after[key]["values"]["exporterQueueSize"] == 0
                for key in ("agentA", "agentB")
            )
            if candidate["perHopReconciliationPassed"] and queues_drained:
                final_evidence = candidate
                break
            time.sleep(0.25)
        if final_evidence is None:
            abort(70, "gateway-outage-per-hop-drain-reconciliation-timeout")
        retry_evidence = bounded_retry_log_evidence(resources, window_started_at)
        retry_count = sum(retry_evidence["recordCountByAgent"].values())
        drain_observation_seconds = round(time.monotonic() - recovery_started, 6)
        oldest_observed_queue_residence_seconds = round(
            time.monotonic() - oldest_queue_observation_started, 6
        )
        window_finished_at = utc_now()
        save_record(
            state,
            "gateway-interruption.json",
            {
                "boundedStopSeconds": 3,
                "requestsSucceeded": len(responses),
                "operationIds": operation_ids,
                "traceIds": sorted(trace_ids),
                "gatewayRestored": True,
                "gatewayLogReceipt": log_receipt,
                "gatewayDebugTokensObservedAfterRecovery": True,
                "drainObservationSeconds": drain_observation_seconds,
                "queueOccupancyMeasured": True,
                "queueItemSemantics": "one-span-batch-under-exact-agent-config",
                "peakQueueItemsByAgent": peak_queue,
                "queueCapacityItemsByAgent": queue_capacity,
                "queueObservedAt": queue_observed_at,
                "oldestQueueAgeMeasured": True,
                "oldestObservedQueueResidenceSeconds": (
                    oldest_observed_queue_residence_seconds
                ),
                "oldestQueueAgeSemantics": (
                    "controller-observed-lower-bound-from-first-completed-outage-request-"
                    "to-proven-drain"
                ),
                "retryAttemptsMeasured": True,
                "retryLogRecordCount": retry_count,
                "retryLogEvidence": retry_evidence,
                "refusedItemsMeasured": True,
                "refusedSpanDelta": sum(
                    final_evidence["deltas"][key]
                    for key in (
                        "agentAReceiverRefused",
                        "agentBReceiverRefused",
                        "agentAProcessorRefused",
                        "agentBProcessorRefused",
                        "gatewayReceiverRefused",
                        "gatewayProcessorRefused",
                    )
                ),
                "droppedItemsMeasured": True,
                "droppedSpanDelta": sum(
                    final_evidence["deltas"][key]
                    for key in (
                        "serviceAExportFailed",
                        "serviceBExportFailed",
                        "agentAExporterSendFailed",
                        "agentBExporterSendFailed",
                        "agentAExporterEnqueueFailed",
                        "agentBExporterEnqueueFailed",
                        "gatewayExporterSendFailed",
                    )
                ),
                "perHopEvidence": final_evidence,
                "perHopReconciliationMeasured": True,
                "queueExperimentComplete": True,
                "evidenceBinding": evidence_binding(
                    state,
                    "interrupt-gateway",
                    {
                        "operationCount": 4,
                        "operationIds": operation_ids,
                        "mode": "propagate",
                        "gatewayContainerId": gateway_id,
                        "boundedStopSeconds": 3,
                    },
                    window_started_at,
                    window_finished_at,
                ),
                "backendIngestProven": False,
            },
        )
    print("gateway_interruption_bounded_seconds=3")
    print("requests_succeeded_during_gateway_stop=4")
    print("gateway_restored=true")
    print("gateway_debug_tokens_observed_after_recovery=true")
    print(f"drain_observation_seconds={drain_observation_seconds}")
    print("queue_occupancy_measured=true")
    print(f"peak_queue_items={sum(peak_queue.values())}")
    print("oldest_queue_age_measured=true")
    print(f"oldest_observed_queue_residence_seconds={oldest_observed_queue_residence_seconds}")
    print("retry_attempts_measured=true")
    print(f"retry_log_record_count={retry_count}")
    print("refused_items_measured=true")
    print("refused_span_delta=0")
    print("dropped_items_measured=true")
    print("dropped_span_delta=0")
    print("per_hop_reconciliation_measured=true")
    print("queue_experiment_complete=true")
    print("backend_ingest_proven=false")


def replace_sample_ratio(state: dict[str, Any], ratio: str) -> None:
    env_path = state["_rootPath"] / "runtime.env"
    validate_owned_file(env_path)
    parsed = parse_locks()
    expected_prefixes = {
        line.split("=", 1)[0]
        for line in runtime_env(parsed, state["token"]).splitlines()
        if line
    }
    current_lines = [
        line for line in env_path.read_text(encoding="utf-8").splitlines() if line
    ]
    if {line.split("=", 1)[0] for line in current_lines} != expected_prefixes:
        abort(65, "runtime-environment-key-set-invalid")
    next_path = state["_rootPath"] / "runtime.env.next"
    if next_path.exists() or next_path.is_symlink():
        abort(73, "runtime-environment-next-file-already-exists")
    write_exclusive(next_path, runtime_env(parsed, state["token"], ratio).encode())
    os.replace(next_path, env_path)
    validate_owned_file(env_path)


def recreate_services(state: dict[str, Any]) -> dict[str, str]:
    compose_command(
        state,
        "up",
        "--detach",
        "--no-deps",
        "--force-recreate",
        "--pull",
        "never",
        "--no-build",
        "--wait",
        "--wait-timeout",
        "60",
        "service-a",
        "service-b",
        timeout=90,
    )
    resources = validate_runtime_resources(state)
    wait_for_service(resources["service-a"])
    return resources


def sample_requests(
    service_a_id: str, count: int
) -> tuple[int, list[dict[str, Any]]]:
    sampled = 0
    responses: list[dict[str, Any]] = []
    for _ in range(count):
        response = request_checkout(service_a_id, "propagate", secrets.token_hex(8))
        if (
            response.get("joined_context") is not True
            or response.get("async_context_joined") is not True
            or response.get("parentage_matches") is not True
        ):
            abort(70, "sampling-request-context-not-joined")
        sampled += int(response.get("sampled") is True)
        responses.append(response)
    return sampled, responses


def compare_sampling() -> None:
    state = state_document()
    require_offline_runtime()
    with operation_lock(state):
        validate_runtime_resources(state)
        overall_started_at = utc_now()
        replace_sample_ratio(state, "1.0")
        full_runtime = recreate_services(state)
        full_window_started_at = utc_now()
        full_resources = runtime_resource_receipts(state)
        full_count, full_responses = sample_requests(full_runtime["service-a"], 32)
        if full_count != 32:
            abort(70, f"full-sampling-observed-count-unexpected-{full_count}")
        full_tokens = {
            str(response[token])
            for response in full_responses
            for token in ("operation_id", "trace_id")
        }
        full_log_receipt = wait_for_gateway_traces(
            state, full_tokens, full_window_started_at, timeout=20
        )
        if full_log_receipt is None:
            abort(70, "full-sampling-gateway-retention-evidence-timeout")
        quarter_count = -1
        quarter_responses: list[dict[str, Any]] = []
        quarter_resources: dict[str, Any] = {}
        quarter_log_receipt: dict[str, Any] | None = None
        try:
            replace_sample_ratio(state, "0.25")
            quarter_runtime = recreate_services(state)
            quarter_window_started_at = utc_now()
            quarter_resources = runtime_resource_receipts(state)
            quarter_count, quarter_responses = sample_requests(
                quarter_runtime["service-a"], 32
            )
            quarter_tokens = {
                str(response[token])
                for response in quarter_responses
                if response.get("sampled") is True
                for token in ("operation_id", "trace_id")
            }
            quarter_log_receipt = wait_for_gateway_traces(
                state, quarter_tokens, quarter_window_started_at, timeout=20
            )
            if quarter_log_receipt is None:
                abort(70, "quarter-sampling-gateway-retention-evidence-timeout")
        finally:
            replace_sample_ratio(state, "1.0")
            recreate_services(state)
        if not 0 < quarter_count < full_count:
            abort(70, f"quarter-sampling-observed-count-not-discriminating-{quarter_count}")
        full_ids = [str(response["trace_id"]) for response in full_responses]
        quarter_ids = [str(response["trace_id"]) for response in quarter_responses]
        overall_finished_at = utc_now()
        save_record(
            state,
            "sampling.json",
            {
                "requestsPerRun": 32,
                "fullRatio": 1.0,
                "fullSampled": full_count,
                "fullGatewayRetained": full_count,
                "fullGatewayLogReceipt": full_log_receipt,
                "quarterRatio": 0.25,
                "quarterSampled": quarter_count,
                "quarterGatewayRetained": quarter_count,
                "quarterGatewayLogReceipt": quarter_log_receipt,
                "deterministicTraceIdsEqualAcrossRestarts": full_ids == quarter_ids,
                "unsampledRequestsStillSucceeded": 32 - quarter_count,
                "samplingRunResources": {
                    "full": full_resources,
                    "quarter": quarter_resources,
                },
                "evidenceBinding": evidence_binding(
                    state,
                    "compare-sampling",
                    {
                        "operationCountPerRatio": 32,
                        "ratios": [1.0, 0.25],
                        "restoredRatio": 1.0,
                        "fullOperationIds": [
                            response["operation_id"] for response in full_responses
                        ],
                        "quarterOperationIds": [
                            response["operation_id"] for response in quarter_responses
                        ],
                    },
                    overall_started_at,
                    overall_finished_at,
                ),
                "backendIngestProven": False,
            },
        )
    print("sampling_requests_per_run=32")
    print(f"sampling_full_observed={full_count}")
    print(f"sampling_full_gateway_retained={full_count}")
    print(f"sampling_quarter_observed={quarter_count}")
    print(f"sampling_quarter_gateway_retained={quarter_count}")
    print(f"deterministic_trace_ids_equal={str(full_ids == quarter_ids).lower()}")
    print("sampling_is_not-request-loss=true")
    print("gateway_retention_bound_to_current_log_windows=true")
    print("backend_ingest_proven=false")


def verify_operation(argv: list[str]) -> None:
    state = state_document()
    require_offline_runtime()
    if argv:
        if (
            len(argv) != 2
            or argv[0] != "--expect-token"
            or argv[1] != state["token"]
        ):
            abort(64, "verify-operation-expect-token-invalid")
    with operation_lock(state):
        validate_runtime_resources(state)
        root: Path = state["_rootPath"]
        present_records = sorted(
            name for name in RECORD_NAMES if (root / name).is_file()
        )
        if set(present_records) != RECORD_NAMES:
            abort(64, "verification-requires-all-five-runtime-records")
        records = {name: load_record(state, name) for name in present_records}
        baseline = records["baseline.json"]
        broken = records["broken-context.json"]
        recovery = records["recovery.json"]
        context_expectations = {
            "baseline.json": True,
            "broken-context.json": False,
            "recovery.json": True,
        }
        for name, expected_joined in context_expectations.items():
            record = records[name]
            response = record.get("response", {})
            receipt = record.get("gatewayLogReceipt", {})
            lines = receipt.get("sanitizedEvidenceLines")
            per_hop = record.get("perHopEvidence", {})
            if (
                response.get("joined_context") is not expected_joined
                or response.get("async_context_joined") is not expected_joined
                or response.get("parentage_matches") is not True
                or response.get("downstream_parent_span_id")
                != response.get("worker_span_id")
                or receipt.get("allSoughtTokensObserved") is not True
                or not isinstance(lines, list)
                or not lines
                or len(lines) > 64
                or any(not isinstance(line, str) or len(line) > 512 for line in lines)
                or receipt.get("sanitizedEvidenceLinesSha256")
                != sha256_bytes(json.dumps(lines, separators=(",", ":")).encode())
                or record.get("directSdkExportCounterMeasured") is not True
                or record.get("collectorPerHopCountersMeasured") is not True
                or per_hop.get("perHopReconciliationPassed") is not True
                or per_hop.get("deltas") != per_hop.get("expectedDeltas")
                or per_hop.get("counterUnit") != "spans"
                or per_hop.get("counterResetBoundaryCrossed") is not False
            ):
                abort(65, f"context-record-bound-evidence-invalid-{name}")
        interruption = records["gateway-interruption.json"]
        queue_evidence = interruption.get("perHopEvidence", {})
        retry_evidence = interruption.get("retryLogEvidence", {})
        retry_records = retry_evidence.get("sanitizedRecords")
        peak_queue = interruption.get("peakQueueItemsByAgent")
        queue_capacity = interruption.get("queueCapacityItemsByAgent")
        if (
            interruption.get("queueOccupancyMeasured") is not True
            or interruption.get("oldestQueueAgeMeasured") is not True
            or interruption.get("retryAttemptsMeasured") is not True
            or interruption.get("refusedItemsMeasured") is not True
            or interruption.get("droppedItemsMeasured") is not True
            or interruption.get("perHopReconciliationMeasured") is not True
            or interruption.get("queueExperimentComplete") is not True
            or interruption.get("refusedSpanDelta") != 0
            or interruption.get("droppedSpanDelta") != 0
            or not isinstance(peak_queue, dict)
            or not isinstance(queue_capacity, dict)
            or set(peak_queue) != {"agent-a", "agent-b"}
            or set(queue_capacity) != {"agent-a", "agent-b"}
            or sum(peak_queue.values()) <= 0
            or any(
                not 0 <= peak_queue[agent] <= queue_capacity[agent] == 256
                for agent in ("agent-a", "agent-b")
            )
            or not isinstance(retry_records, dict)
            or set(retry_records) != {"agent-a", "agent-b"}
            or interruption.get("retryLogRecordCount")
            != sum(len(lines) for lines in retry_records.values())
            or interruption.get("retryLogRecordCount", 0) <= 0
            or retry_evidence.get("sanitizedRecordsSha256")
            != sha256_bytes(
                json.dumps(
                    retry_records, sort_keys=True, separators=(",", ":")
                ).encode()
            )
            or queue_evidence.get("perHopReconciliationPassed") is not True
            or queue_evidence.get("deltas") != queue_evidence.get("expectedDeltas")
            or queue_evidence.get("expectedProcessRestarts") != ["gateway"]
            or queue_evidence.get("observedProcessRestarts") != ["gateway"]
            or queue_evidence.get("counterResetBoundaryCrossed") is not True
        ):
            abort(65, "gateway-interruption-bound-evidence-invalid")
        sampling = records["sampling.json"]
        full_sampled = sampling.get("fullSampled")
        quarter_sampled = sampling.get("quarterSampled")
        if (
            sampling.get("requestsPerRun") != 32
            or full_sampled != 32
            or sampling.get("fullGatewayRetained") != full_sampled
            or not isinstance(quarter_sampled, int)
            or not 0 < quarter_sampled < full_sampled
            or sampling.get("quarterGatewayRetained") != quarter_sampled
            or sampling.get("deterministicTraceIdsEqualAcrossRestarts") is not True
            or sampling.get("unsampledRequestsStillSucceeded") != 32 - quarter_sampled
            or sampling.get("fullGatewayLogReceipt", {}).get(
                "allSoughtTokensObserved"
            )
            is not True
            or sampling.get("quarterGatewayLogReceipt", {}).get(
                "allSoughtTokensObserved"
            )
            is not True
        ):
            abort(65, "sampling-bound-evidence-invalid")
        baseline_deltas = baseline["perHopEvidence"]["deltas"]
    print("verification_mode=runtime-evidence-audit")
    print("runtime_control_records_verified=true")
    print(f"runtime_records_validated={','.join(present_records)}")
    print("instrumentation=opentelemetry-python-sdk")
    print("collector_topology=two-agents-one-gateway")
    print("async_carrier_boundary=bounded-in-process-queue")
    print("baseline_parentage_bound_to_current_operation=true")
    print(f"source_creation_delta={baseline_deltas['serviceASpansEnded'] + baseline_deltas['serviceBSpansEnded']}")
    print(f"sdk_export_delta={baseline_deltas['serviceAExportSucceeded'] + baseline_deltas['serviceBExportSucceeded']}")
    print(f"agent_receive_delta={baseline_deltas['agentAReceiverAccepted'] + baseline_deltas['agentBReceiverAccepted']}")
    print(f"agent_process_delta={baseline_deltas['agentAProcessorAccepted'] + baseline_deltas['agentBProcessorAccepted']}")
    print(f"agent_export_delta={baseline_deltas['agentAExporterSent'] + baseline_deltas['agentBExporterSent']}")
    print(f"gateway_receive_delta={baseline_deltas['gatewayReceiverAccepted']}")
    print(f"gateway_process_delta={baseline_deltas['gatewayProcessorAccepted']}")
    print(f"gateway_export_delta={baseline_deltas['gatewayExporterSent']}")
    print(f"sink_visibility_delta={baseline_deltas['gatewayExporterSent']}")
    print("counter_units=spans")
    print("counter_reset_boundaries=bound-by-container-process-start")
    print(f"freshness_window_seconds={baseline['perHopEvidence']['freshnessSeconds']}")
    print(f"queue_peak_items={sum(peak_queue.values())}")
    print(f"retry_log_records={interruption['retryLogRecordCount']}")
    print("refused_span_delta=0")
    print("dropped_span_delta=0")
    print("per_hop_reconciliation_passed=true")
    print("sampling_deterministic_trace_ids_equal=true")
    print("host_bindings=none")
    print("runtime_network=internal")
    print("runtime_pull_policy=never")
    print("runtime_package_index=disabled")
    print("backend_ingest_proven=false")
    print("production_behavior_proven=false")
    print("runtime_evidence_complete=true")
    print("runtime_verification_passed=true")


def safe_model() -> None:
    trace_ids = [
        int.from_bytes(
            hashlib.sha256(f"LES-0027:model:{index}".encode()).digest()[:16], "big"
        )
        for index in range(32)
    ]
    threshold = int(0.25 * (1 << 64))
    quarter = sum(
        1 for value in trace_ids if (value & ((1 << 64) - 1)) < threshold
    )
    print("engine=deterministic-contract-model")
    print("opentelemetry_executed=false")
    print("collector_executed=false")
    print("network_targets=0")
    print("filesystem_mutations=0")
    print("baseline_context_joined=true")
    print("broken_context_joined=false")
    print("recovery_context_joined=true")
    print("modeled_gateway_queue_depth=4")
    print("modeled_gateway_recovered_exports=4")
    print("modeled_sampling_full=32")
    print(f"modeled_sampling_quarter={quarter}")
    print("model_is_not-runtime-evidence=true")


def probe_command(argv: list[str], timeout: float = 20) -> tuple[bool, str]:
    try:
        result = command(argv, timeout=timeout, check=False)
    except LabError as exc:
        return False, exc.token
    if result.returncode != 0:
        return False, f"exit-{result.returncode}"
    first_line = next(
        (line.strip() for line in result.stdout.splitlines() if line.strip()), "available"
    )
    return True, re.sub(r"\s+", "_", first_line)[:160]


def doctor() -> None:
    inspection = inspect_lock_material()
    os_release: dict[str, str] = {}
    for line in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            os_release[key] = value.strip().strip('"')
    ubuntu_ready = (
        os_release.get("ID") == "ubuntu" and os_release.get("VERSION_ID") == "24.04"
    )
    bash_ready, bash_detail = probe_command(["bash", "--version"])
    curl_ready, curl_detail = probe_command(["curl", "--version"])
    docker_client_ready, docker_client_detail = probe_command(
        ["docker", "version", "--format", "{{.Client.Version}}"]
    )
    compose_ready, compose_detail = probe_command(
        ["docker", "compose", "version", "--short"]
    )
    docker_daemon_ready, docker_daemon_detail = probe_command(
        ["docker", "info", "--format", "{{.ServerVersion}}"], timeout=45
    )
    artifacts = "absent"
    if ARTIFACTS_PATH.exists():
        try:
            parsed = parse_locks()
            validate_artifacts(parsed)
            artifacts = "verified"
        except LabError as exc:
            artifacts = f"unusable:{exc.token}"
    render_state = "unavailable"
    render_binding = "none"
    render_digest = "unavailable"
    if compose_ready:
        try:
            render = render_compose_for_lock()
            render_state = "passed"
            render_binding = render["binding"]
            render_digest = render["resolvedSha256"]
        except LabError as exc:
            render_state = f"failed:{exc.token}"
    image_states: dict[str, str] = {}
    if inspection["state"] == "complete" and docker_daemon_ready:
        parsed = parse_locks()
        for name, ref in parsed["refs"].items():
            image_states[name] = "matched" if image_is_local(ref) else "absent-or-mismatched"
    else:
        for name in inspection["images"]:
            image_states[name] = f"not-checkable-lock-{inspection['state']}"
    runtime_ready = all(
        [
            ubuntu_ready,
            bash_ready,
            curl_ready,
            docker_client_ready,
            compose_ready,
            docker_daemon_ready,
            inspection["state"] == "complete",
            artifacts == "verified",
            all(value == "matched" for value in image_states.values()),
            render_state == "passed",
            render_binding == "exact-reviewed-lock",
        ]
    )
    print("verification_mode=doctor-read-only-preflight")
    print(f"platform={sys.platform}")
    print(f"uid={CURRENT_UID}")
    print("caller_root=false")
    print(f"ubuntu_id={os_release.get('ID', 'unknown')}")
    print(f"ubuntu_version={os_release.get('VERSION_ID', 'unknown')}")
    print(f"ubuntu_24_04_ready={str(ubuntu_ready).lower()}")
    print(f"tool_bash={'available' if bash_ready else 'unavailable'}")
    print(f"tool_bash_detail={bash_detail}")
    print(f"tool_python3=available")
    print(f"tool_python3_detail={sys.version.split()[0]}")
    print(f"tool_curl={'available' if curl_ready else 'unavailable'}")
    print(f"tool_curl_detail={curl_detail}")
    print(f"tool_docker_client={'available' if docker_client_ready else 'unavailable'}")
    print(f"tool_docker_client_detail={docker_client_detail}")
    print(f"tool_docker_compose={'available' if compose_ready else 'unavailable'}")
    print(f"tool_docker_compose_detail={compose_detail}")
    print(f"docker_daemon_ready={str(docker_daemon_ready).lower()}")
    print(f"docker_daemon_detail={docker_daemon_detail}")
    print("published_host_ports=0")
    print(f"artifact_lock={inspection['state']}")
    print(f"artifact_lock_file_sha256={inspection['artifactLockFileSha256']}")
    print(f"requirements_lock_file_sha256={inspection['requirementsLockFileSha256']}")
    print(f"artifact_lock_combined_digest={inspection['combinedDigest']}")
    print(f"requirements_lock_count={inspection['requirementCount']}")
    for name, image in sorted(inspection["images"].items()):
        print(f"image_{name}_declared={image['declared']}")
        print(f"image_{name}_locked_digest={image['digest']}")
        print(f"image_{name}_local_digest_status={image_states[name]}")
    print(f"prepared_artifacts={artifacts}")
    print(f"compose_render={render_state}")
    print(f"compose_render_binding={render_binding}")
    print(f"compose_resolved_sha256={render_digest}")
    if runtime_ready:
        collector_validation_state = "available-next-step"
    elif inspection["state"] != "complete":
        collector_validation_state = f"blocked-lock-{inspection['state']}"
    else:
        collector_validation_state = "blocked-runtime-prerequisites"
    print(f"collector_config_validation={collector_validation_state}")
    print(f"runtime_ready={str(runtime_ready).lower()}")
    print("normal_setup_network_access=false")
    print("prepare_network_access=explicit-only")


def find_state_candidates() -> list[Path]:
    candidates = []
    if STATE_PATH.exists() or STATE_PATH.is_symlink():
        candidates.append(STATE_PATH)
    if STATE_SETUP_PATH.exists() or STATE_SETUP_PATH.is_symlink():
        candidates.append(STATE_SETUP_PATH)
    candidates.extend(sorted(STATE_PATH.parent.glob(STATE_RECOVERY_GLOB)))
    return candidates


def status() -> None:
    candidates = find_state_candidates()
    if not candidates:
        print("state=absent")
        print("state_recovery_count=0")
        try:
            ready, _ = docker_ready()
            resources = (
                len(container_ids(PROJECT_NAME)) + len(network_ids(PROJECT_NAME))
                if ready
                else -1
            )
        except LabError:
            resources = -1
        print(f"project_resource_count={resources}")
        return
    if len(candidates) != 1:
        abort(65, f"ambiguous-state-candidates-{len(candidates)}")
    state = state_document(candidates[0])
    active_state = candidates[0] == STATE_PATH
    if active_state:
        print("state=active")
    elif candidates[0] == STATE_SETUP_PATH:
        print("state=setup-recovery")
    else:
        print("state=cleanup-recovery")
    print(f"lifecycle_token={state['token']}")
    print(f"state_identity={state['stateIdentity']}")
    print(f"root={state['root']}")
    print(f"root_identity={state['rootIdentity']}")
    print(f"project={PROJECT_NAME}")
    ready, detail = docker_ready()
    if ready:
        print(f"project_container_count={len(container_ids(PROJECT_NAME))}")
        print(f"project_network_count={len(network_ids(PROJECT_NAME))}")
        if active_state:
            validate_runtime_resources(state)
            root: Path = state["_rootPath"]
            present_records = sorted(
                name for name in RECORD_NAMES if (root / name).is_file()
            )
            print("verification_mode=runtime-status-evidence-audit")
            print(
                "evidence_records="
                + (",".join(present_records) if present_records else "none")
            )
            records = {name: load_record(state, name) for name in present_records}
            for name, record in records.items():
                print(
                    f"evidence_record_sha256_{name[:-5]}="
                    f"{record['recordPayloadSha256']}"
                )
            baseline = records.get("baseline.json")
            if baseline:
                response = baseline["response"]
                print(f"baseline_operation_id={response['operation_id']}")
                print(f"baseline_source_trace_id={response['trace_id']}")
                print(f"baseline_source_span_id={response['source_span_id']}")
                print(f"baseline_worker_trace_id={response['worker_trace_id']}")
                print(f"baseline_worker_span_id={response['worker_span_id']}")
                print(
                    "baseline_worker_parent_span_id="
                    f"{response['worker_parent_span_id']}"
                )
                print(f"baseline_downstream_trace_id={response['downstream_trace_id']}")
                print(
                    "baseline_async_carrier_keys="
                    + ",".join(response["async_carrier_keys"])
                )
                print(
                    "baseline_async_context_joined="
                    f"{str(response['async_context_joined']).lower()}"
                )
                print(
                    "baseline_parentage_matches="
                    f"{str(response['parentage_matches']).lower()}"
                )
                print("baseline_gateway_window_bound=true")
            broken = records.get("broken-context.json")
            if broken:
                print(
                    "broken_async_context_joined="
                    f"{str(broken['response']['async_context_joined']).lower()}"
                )
                print(
                    "broken_worker_parent_span_id="
                    f"{broken['response']['worker_parent_span_id']}"
                )
            recovery = records.get("recovery.json")
            if recovery:
                print(
                    "recovery_async_context_joined="
                    f"{str(recovery['response']['async_context_joined']).lower()}"
                )
            interruption = records.get("gateway-interruption.json")
            if interruption:
                for field in (
                    "queueOccupancyMeasured",
                    "oldestQueueAgeMeasured",
                    "retryAttemptsMeasured",
                    "refusedItemsMeasured",
                    "droppedItemsMeasured",
                    "perHopReconciliationMeasured",
                    "queueExperimentComplete",
                ):
                    print(
                        f"gateway_interruption_{field}="
                        f"{str(interruption[field]).lower()}"
                    )
            sampling = records.get("sampling.json")
            if sampling:
                print(f"sampling_full_source_sampled={sampling['fullSampled']}")
                print(
                    f"sampling_full_gateway_retained={sampling['fullGatewayRetained']}"
                )
                print(f"sampling_quarter_source_sampled={sampling['quarterSampled']}")
                print(
                    "sampling_quarter_gateway_retained="
                    f"{sampling['quarterGatewayRetained']}"
                )
            if baseline:
                deltas = baseline["perHopEvidence"]["deltas"]
                print(
                    "source_creation_delta="
                    f"{deltas['serviceASpansEnded'] + deltas['serviceBSpansEnded']}"
                )
                print(
                    "sdk_export_delta="
                    f"{deltas['serviceAExportSucceeded'] + deltas['serviceBExportSucceeded']}"
                )
                print(
                    "agent_receive_process_export_deltas="
                    f"{deltas['agentAReceiverAccepted'] + deltas['agentBReceiverAccepted']},"
                    f"{deltas['agentAProcessorAccepted'] + deltas['agentBProcessorAccepted']},"
                    f"{deltas['agentAExporterSent'] + deltas['agentBExporterSent']}"
                )
                print(
                    "gateway_receive_process_export_deltas="
                    f"{deltas['gatewayReceiverAccepted']},"
                    f"{deltas['gatewayProcessorAccepted']},"
                    f"{deltas['gatewayExporterSent']}"
                )
                print(f"sink_visibility_delta={deltas['gatewayExporterSent']}")
                print("counter_units=spans")
                print("counter_reset_boundaries=bound-by-container-process-start")
                print(
                    "freshness_window_seconds="
                    f"{baseline['perHopEvidence']['freshnessSeconds']}"
                )
            else:
                print("per_hop_baseline_evidence=absent")
            if interruption:
                print(
                    "refused_retry_drop_deltas="
                    f"{interruption['refusedSpanDelta']},"
                    f"{interruption['retryLogRecordCount']},"
                    f"{interruption['droppedSpanDelta']}"
                )
            else:
                print("refused_retry_drop_deltas=absent")
            print(
                "per_hop_evidence_complete="
                f"{str(set(records) == RECORD_NAMES).lower()}"
            )
    else:
        print("project_container_count=unavailable")
        print("project_network_count=unavailable")
        print(f"docker_detail={detail}")


def remove_runtime_resources(state: dict[str, Any]) -> None:
    by_service = validate_runtime_resources(
        state,
        require_all=False,
        allow_cleanup_only_legacy_loopback_ports=True,
    )
    for service, container_id in sorted(by_service.items()):
        record = inspect_container(container_id)
        if record.get("State", {}).get("Running"):
            command(
                ["docker", "container", "stop", "--time", "5", container_id],
                timeout=12,
                check=False,
            )
        removed = command(
            ["docker", "container", "rm", container_id], timeout=12, check=False
        )
        if removed.returncode != 0:
            abort(70, f"container-removal-failed-{service}")
    for network_id in network_ids(PROJECT_NAME):
        inspected = command(["docker", "network", "inspect", network_id])
        value = json.loads(inspected.stdout)[0]
        labels = value.get("Labels", {})
        if (
            labels.get("com.reliability-atlas.owner-token") != state["token"]
            or labels.get("com.reliability-atlas.lesson") != LESSON
            or labels.get("com.docker.compose.network") != "telemetry"
        ):
            abort(65, f"network-ownership-mismatch-{network_id}")
        removed = command(
            ["docker", "network", "rm", network_id], timeout=12, check=False
        )
        if removed.returncode != 0:
            abort(70, "network-removal-failed-preserved-state")
    if container_ids(PROJECT_NAME) or network_ids(PROJECT_NAME):
        abort(70, "project-resources-reappeared-or-remain")


def remove_local_artifacts(state: dict[str, Any]) -> None:
    root: Path = state["_rootPath"]
    validate_owned_directory(root, state["rootIdentity"])
    allowed = RECORD_NAMES | {"runtime.env", "runtime.env.next"}
    children = list(root.iterdir())
    for child in children:
        if child.name not in allowed:
            abort(65, f"unexpected-root-child-{child.name}")
        validate_owned_file(child)
    for child in children:
        child.unlink()
    root.rmdir()

def cleanup(argv: list[str]) -> None:
    if (
        len(argv) != 2
        or argv[0] != "--expect-token"
        or not re.fullmatch(r"[0-9a-f]{32}", argv[1])
    ):
        abort(64, "cleanup-requires---expect-token-from-setup-or-status")
    candidates = find_state_candidates()
    if not candidates:
        if container_ids(PROJECT_NAME) or network_ids(PROJECT_NAME):
            abort(65, "state-absent-but-project-resources-present-preserved")
        print("cleanup_proven=true")
        print("state=absent")
        print("atomic_deletion_claimed=false")
        return
    if len(candidates) != 1:
        abort(65, f"ambiguous-state-candidates-{len(candidates)}")
    candidate = candidates[0]
    state = state_document(candidate)
    if state["token"] != argv[1]:
        abort(65, "cleanup-token-mismatch")
    with operation_lock(state, delete_state_on_success=True):
        if not candidate.name.startswith(f"{STATE_PATH.name}.cleanup."):
            recovery = Path(
                f"{STATE_PATH}.cleanup.{state['token']}.{secrets.token_hex(4)}"
            )
            os.rename(candidate, recovery)
            state["_statePath"] = recovery
            state = state_document(recovery)
        ready, detail = docker_ready()
        if not ready:
            abort(69, f"cleanup-needs-docker-to-prove-resource-absence-{detail}")
        remove_runtime_resources(state)
        remove_local_artifacts(state)
    if find_state_candidates():
        abort(70, "state-still-present-after-cleanup")
    print("cleanup_proven=true")
    print("state=absent")
    print("project_resources=absent")
    print("cooperative_replacement_race_preserved=true")
    print("atomic_deletion_claimed=false")


def usage() -> None:
    print(
        "usage: bash lab.sh "
        "{doctor|model|prepare --allow-network-downloads|validate-configs|setup|status|"
        "run baseline|run broken-context|recover-context|interrupt-gateway|"
        "compare-sampling|verify-operation [--expect-token TOKEN]|"
        "cleanup --expect-token TOKEN}",
        file=sys.stderr,
    )


def main(argv: list[str]) -> int:
    if not argv:
        usage()
        return 64
    action, rest = argv[0], argv[1:]
    if action == "doctor" and not rest:
        doctor()
    elif action == "model" and not rest:
        safe_model()
    elif action == "prepare":
        prepare(rest)
    elif action == "validate-configs" and not rest:
        validate_configs()
    elif action == "setup" and not rest:
        setup()
    elif action in {"status", "check"} and not rest:
        status()
    elif action == "run" and len(rest) == 1:
        run_case(rest[0])
    elif action == "recover-context" and not rest:
        recover_context()
    elif action == "interrupt-gateway" and not rest:
        interrupt_gateway()
    elif action == "compare-sampling" and not rest:
        compare_sampling()
    elif action == "verify-operation":
        verify_operation(rest)
    elif action == "cleanup":
        cleanup(rest)
    else:
        usage()
        return 64
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except LabError as exc:
        print(exc.token, file=sys.stderr)
        raise SystemExit(exc.code)
