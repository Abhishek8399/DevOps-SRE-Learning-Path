from __future__ import annotations

import contextlib
import fcntl
import hashlib
import json
import os
import platform
import re
import secrets
import stat
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any, Iterator


LESSON = "LES-0028"
PROJECT = f"reliability-atlas-les0028-{os.getuid()}"
SERVICES = ("fixture", "prometheus", "alertmanager", "grafana")
HERE = Path(__file__).resolve().parent
LOCK_FILE = HERE / "artifacts.lock.json"
COMPOSE_FILE = HERE / "compose.yaml"
STATE_PATH = Path(f"/tmp/{PROJECT}-runtime-{os.getuid()}")
STATE_SETUP_PATH = Path(f"{STATE_PATH}.setup")
STATE_GLOB = f"{STATE_PATH.name}.cleanup.*"
UID = os.getuid()
GID = os.getgid()
SOURCE_FILES = (
    HERE / "runtime.sh",
    HERE / "runtime_controller.py",
    HERE / "verify.sh",
    HERE / "tests" / "test_runtime_controller.py",
    LOCK_FILE,
    COMPOSE_FILE,
    HERE / "fixture" / "metrics_fixture.py",
    HERE / "prometheus" / "prometheus.yml",
    HERE / "prometheus" / "rules.yml",
    HERE / "alertmanager" / "alertmanager.yml",
    HERE / "grafana" / "provisioning" / "datasources" / "prometheus.yml",
    HERE / "grafana" / "provisioning" / "dashboards" / "provider.yml",
    HERE / "grafana" / "dashboards" / "overview.json",
)


class LabError(RuntimeError):
    def __init__(self, code: int, token: str) -> None:
        super().__init__(token)
        self.code = code
        self.token = token


def abort(code: int, token: str) -> None:
    raise LabError(code, token)


def run(
    argv: list[str], *, timeout: int = 30, check: bool = True
) -> subprocess.CompletedProcess[str]:
    try:
        result = subprocess.run(
            argv,
            cwd=HERE,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        abort(69, f"command-unavailable-or-timeout-{argv[0]}-{type(exc).__name__}")
    if check and result.returncode != 0:
        detail = re.sub(r"[^A-Za-z0-9_.-]+", "-", result.stderr.strip())[:120]
        abort(70, f"command-failed-{Path(argv[0]).name}-{detail or result.returncode}")
    return result


def docker(*args: str, timeout: int = 30, check: bool = True) -> subprocess.CompletedProcess[str]:
    return run(["docker", *args], timeout=timeout, check=check)


def compose(*args: str, timeout: int = 30, check: bool = True) -> subprocess.CompletedProcess[str]:
    return docker(
        "compose", "-f", str(COMPOSE_FILE), "-p", PROJECT, *args,
        timeout=timeout, check=check,
    )


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(65536), b""):
            value.update(block)
    return value.hexdigest()


def identity(path: Path) -> str:
    info = path.lstat()
    return f"{info.st_dev}:{info.st_ino}"


def validate_directory(path: Path, expected_identity: str | None = None) -> None:
    info = path.lstat()
    if (
        not stat.S_ISDIR(info.st_mode)
        or info.st_uid != UID
        or stat.S_IMODE(info.st_mode) != 0o700
        or info.st_nlink < 2
        or (expected_identity is not None and identity(path) != expected_identity)
    ):
        abort(65, f"unsafe-directory-{path.name}")


def validate_file(path: Path, expected_identity: str | None = None) -> None:
    info = path.lstat()
    if (
        not stat.S_ISREG(info.st_mode)
        or info.st_uid != UID
        or stat.S_IMODE(info.st_mode) != 0o600
        or info.st_nlink != 1
        or (expected_identity is not None and identity(path) != expected_identity)
    ):
        abort(65, f"unsafe-file-{path.name}")


def write_json(path: Path, value: dict[str, Any]) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    descriptor = os.open(path, flags, 0o600)
    try:
        data = (json.dumps(value, sort_keys=True, indent=2) + "\n").encode()
        written = 0
        while written < len(data):
            count = os.write(descriptor, data[written:])
            if count <= 0:
                abort(74, "state-short-write")
            written += count
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def source_receipts() -> dict[str, str]:
    receipts: dict[str, str] = {}
    for path in SOURCE_FILES:
        if not path.is_file() or path.is_symlink():
            abort(65, f"source-file-invalid-{path.name}")
        receipts[str(path.relative_to(HERE))] = digest(path)
    return receipts


def artifact_lock() -> dict[str, Any]:
    try:
        value = json.loads(LOCK_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        abort(65, f"artifact-lock-invalid-{type(exc).__name__}")
    if value.get("schemaVersion") != 1 or value.get("lesson") != LESSON:
        abort(65, "artifact-lock-identity-invalid")
    images = value.get("images")
    if not isinstance(images, dict) or set(images) != {
        "python", "prometheus", "alertmanager", "grafana"
    }:
        abort(65, "artifact-lock-image-set-invalid")
    for name, item in images.items():
        if not isinstance(item, dict):
            abort(65, f"artifact-lock-{name}-invalid")
        repository = item.get("repository")
        image_digest = item.get("digest")
        if not isinstance(repository, str) or not re.fullmatch(r"sha256:[0-9a-f]{64}", str(image_digest)):
            abort(65, f"artifact-lock-{name}-identity-invalid")
    return value


def image_refs() -> dict[str, str]:
    images = artifact_lock()["images"]
    return {name: f"{item['repository']}@{item['digest']}" for name, item in images.items()}


def require_normal_user() -> None:
    if UID == 0:
        abort(77, "root-is-refused-run-as-a-normal-user")


def require_ubuntu() -> None:
    values = platform.freedesktop_os_release()
    if values.get("ID") != "ubuntu" or values.get("VERSION_ID") != "24.04":
        abort(69, "canonical-runtime-requires-ubuntu-24.04")


def require_docker() -> None:
    run(["bash", "-n", str(HERE / "runtime.sh")])
    docker("compose", "version")
    docker("info", timeout=20)


def inspect_json(kind: str, object_id: str) -> dict[str, Any]:
    result = docker("inspect", "--type", kind, object_id)
    try:
        values = json.loads(result.stdout)
    except json.JSONDecodeError:
        abort(70, f"docker-{kind}-inspect-json-invalid")
    if not isinstance(values, list) or len(values) != 1 or not isinstance(values[0], dict):
        abort(70, f"docker-{kind}-inspect-cardinality-invalid")
    return values[0]


def image_available(ref: str) -> bool:
    return docker("image", "inspect", ref, check=False).returncode == 0


def require_images() -> None:
    missing = [name for name, ref in image_refs().items() if not image_available(ref)]
    if missing:
        abort(69, "offline-images-missing-" + "-".join(missing))


def project_container_ids() -> list[str]:
    result = docker(
        "container", "ls", "--all", "--quiet",
        "--filter", f"label=com.docker.compose.project={PROJECT}",
    )
    return sorted(line for line in result.stdout.splitlines() if line)


def project_network_ids() -> list[str]:
    result = docker(
        "network", "ls", "--quiet", "--filter", f"label=com.docker.compose.project={PROJECT}"
    )
    return sorted(line for line in result.stdout.splitlines() if line)


def find_state_candidates() -> list[Path]:
    values = [path for path in [STATE_PATH, STATE_SETUP_PATH] if path.exists() or path.is_symlink()]
    values.extend(STATE_PATH.parent.glob(STATE_GLOB))
    return sorted(set(values), key=str)


def read_state(
    path: Path = STATE_PATH, *, validate_sources: bool = True
) -> dict[str, Any]:
    validate_directory(path)
    if set(child.name for child in path.iterdir()) - {"state.json", "operation.lock"}:
        abort(65, "unexpected-state-entry")
    state_file = path / "state.json"
    validate_file(state_file)
    try:
        value = json.loads(state_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        abort(65, f"state-invalid-{type(exc).__name__}")
    required = {
        "schemaVersion": 1,
        "lesson": LESSON,
        "project": PROJECT,
        "uid": UID,
        "gid": GID,
        "statePath": str(STATE_PATH),
    }
    if any(value.get(key) != expected for key, expected in required.items()):
        abort(65, "state-identity-invalid")
    if not re.fullmatch(r"[0-9a-f]{32}", str(value.get("token"))):
        abort(65, "state-token-invalid")
    if value.get("stateIdentity") != identity(path):
        abort(65, "state-directory-identity-invalid")
    if validate_sources and value.get("sourceReceipts") != source_receipts():
        abort(65, "source-receipts-changed")
    value["_statePath"] = path
    return value


@contextlib.contextmanager
def operation_lock(
    state: dict[str, Any], *, delete_state_on_success: bool = False
) -> Iterator[None]:
    lock_path: Path = state["_statePath"] / "operation.lock"
    flags = os.O_RDWR | os.O_CREAT
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    if hasattr(os, "O_CLOEXEC"):
        flags |= os.O_CLOEXEC
    try:
        descriptor = os.open(lock_path, flags, 0o600)
    except OSError as exc:
        abort(65, f"operation-lock-open-failed-{type(exc).__name__}")
    acquired = False
    claimed = False
    completed = False
    try:
        info = os.fstat(descriptor)
        if not stat.S_ISREG(info.st_mode) or info.st_uid != UID or stat.S_IMODE(info.st_mode) != 0o600 or info.st_nlink != 1:
            abort(65, "unsafe-operation-lock")
        lock_identity = f"{info.st_dev}:{info.st_ino}"
        try:
            path_identity = identity(lock_path)
        except OSError as exc:
            abort(65, f"operation-lock-path-check-failed-{type(exc).__name__}")
        if path_identity != lock_identity:
            abort(65, "operation-lock-identity-race")
        try:
            fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            abort(73, "another-runtime-operation-is-active")
        acquired = True
        os.lseek(descriptor, 0, os.SEEK_SET)
        prior = os.read(descriptor, 128)
        expected = (state["token"] + "\n").encode()
        if prior not in {b"", expected}:
            abort(65, "operation-lock-token-mismatch")
        os.ftruncate(descriptor, 0)
        os.lseek(descriptor, 0, os.SEEK_SET)
        if os.write(descriptor, expected) != len(expected):
            abort(74, "operation-lock-short-write")
        os.fsync(descriptor)
        claimed = True
        yield
        completed = True
    finally:
        try:
            if acquired:
                try:
                    if claimed:
                        final = state["_statePath"] / "operation.lock"
                        validate_file(final, lock_identity)
                        if delete_state_on_success and completed:
                            validate_directory(final.parent, state["stateIdentity"])
                            if set(child.name for child in final.parent.iterdir()) != {
                                "state.json", "operation.lock"
                            }:
                                abort(65, "unexpected-final-state-entry")
                            state_file = final.parent / "state.json"
                            validate_file(state_file)
                            state_file.unlink()
                        final.unlink()
                        if delete_state_on_success and completed:
                            final.parent.rmdir()
                finally:
                    fcntl.flock(descriptor, fcntl.LOCK_UN)
        finally:
            os.close(descriptor)


def rendered_contract() -> dict[str, Any]:
    result = compose("config", "--format", "json")
    try:
        value = json.loads(result.stdout)
    except json.JSONDecodeError:
        abort(70, "compose-render-json-invalid")
    services = value.get("services")
    if not isinstance(services, dict) or set(services) != set(SERVICES):
        abort(65, "compose-service-set-invalid")
    refs = image_refs()
    for name, service in services.items():
        expected_ref = refs["python" if name == "fixture" else name]
        if service.get("image") != expected_ref:
            abort(65, f"compose-image-invalid-{name}")
        if service.get("ports"):
            abort(65, f"compose-host-port-forbidden-{name}")
        if service.get("read_only") is not True or service.get("restart") != "no":
            abort(65, f"compose-runtime-boundary-invalid-{name}")
        if service.get("cap_drop") != ["ALL"] or "no-new-privileges:true" not in service.get("security_opt", []):
            abort(65, f"compose-privilege-boundary-invalid-{name}")
    networks = value.get("networks")
    if not isinstance(networks, dict) or len(networks) != 1 or next(iter(networks.values())).get("internal") is not True:
        abort(65, "compose-network-not-exactly-one-internally-isolated-network")
    return value


def validate_live(state: dict[str, Any], *, record: bool = False) -> dict[str, Any]:
    refs = image_refs()
    ids = project_container_ids()
    networks = project_network_ids()
    if len(ids) != 4 or len(networks) != 1:
        abort(70, "runtime-resource-cardinality-invalid")
    receipts: dict[str, Any] = {"containers": {}, "network": networks[0]}
    network = inspect_json("network", networks[0])
    if network.get("Internal") is not True or network.get("Options") is None:
        abort(70, "runtime-network-boundary-invalid")
    for container_id in ids:
        item = inspect_json("container", container_id)
        labels = item.get("Config", {}).get("Labels", {})
        service = labels.get("com.docker.compose.service")
        if service not in SERVICES or service in receipts["containers"]:
            abort(70, "runtime-service-identity-invalid")
        expected_ref = refs["python" if service == "fixture" else service]
        expected_image_id = inspect_json("image", expected_ref).get("Id")
        if item.get("Image") != expected_image_id or item.get("State", {}).get("Status") != "running":
            abort(70, f"runtime-image-or-state-invalid-{service}")
        host = item.get("HostConfig", {})
        if (
            host.get("ReadonlyRootfs") is not True
            or host.get("CapDrop") != ["ALL"]
            or not any(
                value.startswith("no-new-privileges")
                for value in host.get("SecurityOpt", [])
            )
            or host.get("PortBindings") not in {None, {}}
            or host.get("RestartPolicy", {}).get("Name") != "no"
            or not isinstance(host.get("Memory"), int)
            or host.get("Memory", 0) <= 0
            or host.get("MemorySwap") != host.get("Memory")
            or host.get("PidsLimit", 0) <= 0
        ):
            abort(70, f"runtime-host-boundary-invalid-{service}")
        attached = item.get("NetworkSettings", {}).get("Networks", {})
        if len(attached) != 1 or next(iter(attached.values())).get("NetworkID") != networks[0]:
            abort(70, f"runtime-network-membership-invalid-{service}")
        receipts["containers"][service] = container_id
    if set(receipts["containers"]) != set(SERVICES):
        abort(70, "runtime-service-set-invalid")
    if record:
        state["resources"] = receipts
    elif state.get("resources") != receipts:
        abort(65, "runtime-resource-receipts-changed")
    return receipts


def create_state() -> dict[str, Any]:
    if find_state_candidates():
        abort(73, "runtime-state-already-present")
    if project_container_ids() or project_network_ids():
        abort(65, "state-absent-but-project-resources-present")
    STATE_SETUP_PATH.mkdir(mode=0o700)
    try:
        token = secrets.token_hex(16)
        value: dict[str, Any] = {
            "schemaVersion": 1,
            "lesson": LESSON,
            "project": PROJECT,
            "uid": UID,
            "gid": GID,
            "token": token,
            "statePath": str(STATE_PATH),
            "stateIdentity": identity(STATE_SETUP_PATH),
            "sourceReceipts": source_receipts(),
            "resources": None,
        }
        write_json(STATE_SETUP_PATH / "state.json", value)
        os.rename(STATE_SETUP_PATH, STATE_PATH)
        value["_statePath"] = STATE_PATH
        return value
    except Exception:
        if STATE_SETUP_PATH.is_dir() and not STATE_SETUP_PATH.is_symlink():
            for child in STATE_SETUP_PATH.iterdir():
                validate_file(child)
                child.unlink()
            STATE_SETUP_PATH.rmdir()
        raise


def rewrite_state(state: dict[str, Any]) -> None:
    path: Path = state["_statePath"] / "state.json"
    validate_file(path)
    temporary = state["_statePath"] / "state.json.new"
    persisted = {key: value for key, value in state.items() if not key.startswith("_")}
    write_json(temporary, persisted)
    os.replace(temporary, path)


def api_read(container_id: str, url: str) -> str:
    script = (
        "import json,sys,urllib.request;"
        "r=urllib.request.urlopen(sys.argv[1],timeout=5);"
        "sys.stdout.write(r.read().decode())"
    )
    result = docker("exec", container_id, "python", "-c", script, url, timeout=15)
    return result.stdout


def api_get(container_id: str, url: str) -> Any:
    try:
        return json.loads(api_read(container_id, url))
    except json.JSONDecodeError:
        abort(70, "runtime-api-json-invalid")


def doctor() -> None:
    require_ubuntu()
    require_docker()
    source_receipts()
    artifact_lock()
    rendered_contract()
    state = "active" if STATE_PATH.exists() else "absent"
    print(f"ready=true state={state} images_cached={str(all(image_available(ref) for ref in image_refs().values())).lower()}")


def prepare(argv: list[str]) -> None:
    if argv != ["--allow-network-downloads"]:
        abort(64, "prepare-requires---allow-network-downloads")
    require_ubuntu()
    require_docker()
    if find_state_candidates() or project_container_ids() or project_network_ids():
        abort(73, "prepare-requires-absent-runtime")
    for name, ref in image_refs().items():
        docker("pull", ref, timeout=300)
        if not image_available(ref):
            abort(70, f"prepared-image-not-readable-{name}")
        print(f"prepared_image={name} ref={ref}")
    print("prepare_complete=true network_access_used=true")


def validate_configs() -> None:
    require_ubuntu()
    require_docker()
    require_images()
    rendered_contract()
    refs = image_refs()
    common = ["run", "--rm", "--network", "none", "--read-only", "--cap-drop", "ALL", "--security-opt", "no-new-privileges", "--user"]
    docker(*common, "65532:65532", "-v", f"{HERE / 'prometheus'}:/etc/prometheus:ro", "--entrypoint", "/bin/promtool", refs["prometheus"], "check", "config", "/etc/prometheus/prometheus.yml", timeout=60)
    docker(*common, "65534:65534", "-v", f"{HERE / 'alertmanager' / 'alertmanager.yml'}:/etc/alertmanager/alertmanager.yml:ro", "--entrypoint", "/bin/amtool", refs["alertmanager"], "check-config", "/etc/alertmanager/alertmanager.yml", timeout=60)
    print("config_validation=passed products=prometheus,alertmanager grafana=runtime-only")


def setup() -> None:
    require_ubuntu()
    require_docker()
    require_images()
    validate_configs()
    state = create_state()
    try:
        compose("up", "--detach", "--no-build", "--pull", "never", timeout=120)
        for _ in range(60):
            try:
                receipts = validate_live(state, record=True)
                fixture = receipts["containers"]["fixture"]
                prometheus_ready = api_read(
                    fixture, "http://prometheus:9090/-/ready"
                ) == "Prometheus Server is Ready.\n"
                alertmanager_ready = bool(
                    api_get(fixture, "http://alertmanager:9093/api/v2/status").get(
                        "versionInfo"
                    )
                )
                grafana_ready = api_get(
                    fixture, "http://grafana:3000/api/health"
                ).get("database") == "ok"
                if prometheus_ready and alertmanager_ready and grafana_ready:
                    break
            except LabError:
                pass
            time.sleep(1)
        else:
            abort(70, "runtime-readiness-timeout")
        rewrite_state(state)
        print(f"setup_complete=true lifecycle_token={state['token']} containers=4 network_internal=true host_ports=0")
    except Exception:
        cleanup_resources_unpublished()
        if STATE_PATH.is_dir() and not STATE_PATH.is_symlink():
            for child in STATE_PATH.iterdir():
                if child.is_file() and not child.is_symlink():
                    child.unlink()
            STATE_PATH.rmdir()
        raise


def cleanup_resources_unpublished() -> None:
    for container_id in project_container_ids():
        docker("container", "rm", "--force", container_id, timeout=30, check=False)
    for network_id in project_network_ids():
        docker("network", "rm", network_id, timeout=30, check=False)


def status() -> None:
    require_docker()
    if not find_state_candidates():
        if project_container_ids() or project_network_ids():
            abort(65, "state-absent-but-project-resources-present")
        print("state=absent project_resources=absent")
        return
    state = read_state()
    receipts = validate_live(state)
    print(f"state=active lifecycle_token={state['token']} containers={len(receipts['containers'])} network_internal=true host_ports=0")


def exercise() -> None:
    state = read_state()
    require_docker()
    with operation_lock(state):
        receipts = validate_live(state)
        fixture = receipts["containers"]["fixture"]
        api_get(fixture, "http://fixture:8080/control?mode=baseline")
        time.sleep(6)
        up = api_get(fixture, "http://prometheus:9090/api/v1/query?query=up%7Bjob%3D%22training-fixture%22%7D")
        if up.get("status") != "success" or not up.get("data", {}).get("result"):
            abort(70, "prometheus-scrape-query-failed")
        recorded = api_get(fixture, "http://prometheus:9090/api/v1/query?query=job%3Atraining_requests%3Arate5s")
        if recorded.get("status") != "success" or not recorded.get("data", {}).get("result"):
            abort(70, "prometheus-recording-rule-query-failed")
        datasource = api_get(fixture, "http://grafana:3000/api/datasources/uid/les0028-prometheus")
        dashboard = api_get(fixture, "http://grafana:3000/api/dashboards/uid/les0028-overview")
        alertmanager = api_get(fixture, "http://alertmanager:9093/api/v2/status")
        if datasource.get("uid") != "les0028-prometheus" or dashboard.get("dashboard", {}).get("uid") != "les0028-overview" or not alertmanager.get("versionInfo"):
            abort(70, "provisioning-or-alertmanager-evidence-invalid")
        for _ in range(6):
            api_get(fixture, "http://fixture:8080/control?mode=errors")
            time.sleep(1)
        alerts = api_get(fixture, "http://prometheus:9090/api/v1/alerts")
        states = [item.get("state") for item in alerts.get("data", {}).get("alerts", []) if item.get("labels", {}).get("alertname") == "TrainingFixtureHighErrorRatio"]
        if "firing" not in states:
            abort(70, "prometheus-alert-did-not-fire")
        for _ in range(6):
            api_get(fixture, "http://fixture:8080/control?mode=recover")
            time.sleep(1)
        print("runtime_exercise=passed scrape=up recording_rule=loaded alert=firing alertmanager=ready grafana_datasource=provisioned grafana_dashboard=provisioned")


def cleanup(argv: list[str]) -> None:
    if len(argv) != 2 or argv[0] != "--expect-token" or not re.fullmatch(r"[0-9a-f]{32}", argv[1]):
        abort(64, "cleanup-requires---expect-token")
    candidates = find_state_candidates()
    if not candidates:
        if project_container_ids() or project_network_ids():
            abort(65, "state-absent-but-project-resources-present")
        print("cleanup_proven=true state=absent project_resources=absent")
        return
    if len(candidates) != 1:
        abort(65, "ambiguous-state-candidates")
    state = read_state(candidates[0], validate_sources=False)
    if state["token"] != argv[1]:
        abort(65, "cleanup-token-mismatch")
    with operation_lock(state, delete_state_on_success=True):
        if not candidate.name.startswith(f"{STATE_PATH.name}.cleanup."):
            recovery = Path(f"{STATE_PATH}.cleanup.{state['token']}.{secrets.token_hex(4)}")
            os.rename(candidate, recovery)
            state["_statePath"] = recovery
        ids = project_container_ids()
        networks = project_network_ids()
        if ids or networks:
            receipts = validate_live(state)
            for container_id in receipts["containers"].values():
                docker("container", "stop", "--time", "10", container_id, timeout=30, check=False)
            for container_id in receipts["containers"].values():
                docker("container", "rm", container_id, timeout=30)
            docker("network", "rm", receipts["network"], timeout=30)
        if project_container_ids() or project_network_ids():
            abort(70, "project-resources-remain-after-cleanup")
    print("cleanup_proven=true state=absent project_resources=absent")


def usage() -> None:
    print("usage: bash runtime.sh {doctor|prepare --allow-network-downloads|validate-configs|setup|status|exercise|cleanup --expect-token TOKEN}", file=sys.stderr)


def main(argv: list[str]) -> int:
    require_normal_user()
    if not argv:
        usage(); return 64
    action, rest = argv[0], argv[1:]
    if action == "doctor" and not rest: doctor()
    elif action == "prepare": prepare(rest)
    elif action == "validate-configs" and not rest: validate_configs()
    elif action == "setup" and not rest: setup()
    elif action == "status" and not rest: status()
    elif action == "exercise" and not rest: exercise()
    elif action == "cleanup": cleanup(rest)
    else: usage(); return 64
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except LabError as exc:
        print(exc.token, file=sys.stderr)
        raise SystemExit(exc.code)
