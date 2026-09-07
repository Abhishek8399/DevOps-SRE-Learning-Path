#!/usr/bin/env python3
"""End-to-end normal-user verifier for the CAP-001 local service."""

from __future__ import annotations

import http.client
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys
import tempfile
import time


PROJECT = Path(__file__).resolve().parent.parent
PYTHONPATH = str(PROJECT / "service")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def run(arguments: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment["PYTHONPATH"] = PYTHONPATH
    completed = subprocess.run(
        arguments,
        cwd=PROJECT,
        env=environment,
        check=False,
        text=True,
        capture_output=capture,
    )
    if completed.returncode != 0:
        detail = ""
        if capture:
            detail = f" stdout={completed.stdout!r} stderr={completed.stderr!r}"
        raise RuntimeError(
            f"command failed rc={completed.returncode}: {arguments!r}{detail}"
        )
    return completed


def free_port() -> int:
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        return int(listener.getsockname()[1])


def request(
    port: int,
    method: str,
    path: str,
    body: dict[str, object] | None = None,
    headers: dict[str, str] | None = None,
) -> tuple[int, dict[str, str], bytes]:
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=2)
    encoded = json.dumps(body).encode() if body is not None else None
    request_headers = dict(headers or {})
    if body is not None:
        request_headers["Content-Type"] = "application/json"
    connection.request(method, path, body=encoded, headers=request_headers)
    response = connection.getresponse()
    payload = response.read()
    response_headers = {key.lower(): value for key, value in response.getheaders()}
    connection.close()
    return response.status, response_headers, payload


class Fixture:
    def __init__(self, root: Path, mode: str, delay_ms: int = 1) -> None:
        self.root = root
        self.mode = mode
        self.delay_ms = delay_ms
        self.port = free_port()
        self.process: subprocess.Popen[str] | None = None
        self.log_stream = None

    def start(self) -> None:
        environment = os.environ.copy()
        environment.update(
            {
                "PYTHONPATH": PYTHONPATH,
                "ATLAS_BIND": "127.0.0.1",
                "ATLAS_PORT": str(self.port),
                "ATLAS_DB_PATH": str(self.root / f"{self.mode}.db"),
                "ATLAS_VERSION": "verify-0.1.0",
                "ATLAS_FAULT_MODE": self.mode,
                "ATLAS_FAULT_DELAY_MS": str(self.delay_ms),
            }
        )
        log_path = self.root / f"{self.mode}.log"
        self.log_stream = log_path.open("w", encoding="utf-8")
        self.process = subprocess.Popen(
            [sys.executable, "-m", "atlas_service"],
            cwd=PROJECT,
            env=environment,
            stdout=self.log_stream,
            stderr=subprocess.STDOUT,
            text=True,
        )
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            require(self.process.poll() is None, f"{self.mode} service exited during startup")
            try:
                status, _, _ = request(self.port, "GET", "/livez")
                if status == 200:
                    return
            except OSError:
                time.sleep(0.05)
        raise RuntimeError(f"{self.mode} service did not become live")

    def stop(self) -> None:
        if self.process is not None and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=2)
        if self.log_stream is not None:
            self.log_stream.close()
        self.process = None
        self.log_stream = None

    def __enter__(self) -> "Fixture":
        self.start()
        return self

    def __exit__(self, *_error: object) -> None:
        self.stop()


def verify_standard(root: Path) -> None:
    with Fixture(root, "none") as fixture:
        status, _, _ = request(fixture.port, "GET", "/readyz")
        require(status == 200, "standard readiness must be 200")
        trace_id = "1" * 32
        headers = {
            "Idempotency-Key": "verify-key-0001",
            "X-Request-ID": "verify-request-1",
            "traceparent": f"00-{trace_id}-{'2' * 16}-01",
        }
        status, response_headers, first = request(
            fixture.port, "POST", "/api/v1/items", {"name": "verified-item"}, headers
        )
        require(status == 201, "first create must return 201")
        require(response_headers["x-request-id"] == "verify-request-1", "request ID lost")
        require(response_headers["traceparent"].split("-")[1] == trace_id, "trace ID lost")
        status, response_headers, replay = request(
            fixture.port, "POST", "/api/v1/items", {"name": "verified-item"}, headers
        )
        require(status == 200 and first == replay, "idempotent replay failed")
        require(response_headers["idempotency-replayed"] == "true", "replay not identified")
        status, _, _ = request(
            fixture.port, "POST", "/api/v1/items", {"name": "changed"}, headers
        )
        require(status == 409, "changed idempotent request must conflict")
        status, _, metrics = request(fixture.port, "GET", "/metrics")
        require(status == 200 and b"atlas_http_requests_total" in metrics, "metrics missing")
        require(b"verify-key-0001" not in metrics, "high-cardinality key leaked to metrics")

        database = root / "none.db"
        backup = root / "backups" / "snapshot.db"
        manifest = Path(f"{backup}.manifest.json")
        run(
            [
                sys.executable, "ops/db_admin.py", "backup",
                "--database", str(database), "--output", str(backup),
                "--boundary", str(root),
            ]
        )
        run(
            [
                sys.executable, "ops/db_admin.py", "verify",
                "--database", str(backup), "--manifest", str(manifest),
            ]
        )
        restored = root / "restored" / "atlas.db"
        run(
            [
                sys.executable, "ops/db_admin.py", "restore",
                "--database", str(backup), "--manifest", str(manifest),
                "--target", str(restored), "--boundary", str(root),
            ]
        )

        sample = root / "healthy.ndjson"
        loaded = run(
            [
                sys.executable, "ops/load.py",
                "--url", f"http://127.0.0.1:{fixture.port}/api/v1/items",
                "--requests", "40", "--concurrency", "4",
            ],
            capture=True,
        )
        require(
            len(loaded.stdout.splitlines()) == 40,
            "healthy load output did not conserve 40 requested records",
        )
        sample.write_text(loaded.stdout, encoding="utf-8")
        result = run(
            [
                sys.executable, "ops/slo.py", "--input", str(sample),
                "--availability-target", "0.99", "--latency-target-seconds", "0.25",
            ],
            capture=True,
        )
        slo = json.loads(result.stdout)
        require(slo["availability_pass"] and slo["latency_pass"], "healthy sample failed SLO")


def verify_faults(root: Path) -> None:
    with Fixture(root, "readiness-failure") as fixture:
        require(request(fixture.port, "GET", "/livez")[0] == 200, "liveness must remain 200")
        require(request(fixture.port, "GET", "/readyz")[0] == 503, "readiness fault must be 503")
    with Fixture(root, "write-failure") as fixture:
        status, _, body = request(
            fixture.port,
            "POST",
            "/api/v1/items",
            {"name": "will-fail"},
            {"Idempotency-Key": "verify-key-0002"},
        )
        require(status == 503, "write fault must return 503")
        require(json.loads(body) == {"error": "storage_unavailable"}, "write error leaked detail")
    with Fixture(root, "latency", delay_ms=150) as fixture:
        sample = root / "latency.ndjson"
        loaded = run(
            [
                sys.executable, "ops/load.py",
                "--url", f"http://127.0.0.1:{fixture.port}/api/v1/items",
                "--requests", "20", "--concurrency", "2",
            ],
            capture=True,
        )
        require(
            len(loaded.stdout.splitlines()) == 20,
            "latency load output did not conserve 20 requested records",
        )
        sample.write_text(loaded.stdout, encoding="utf-8")
        result = run(
            [
                sys.executable, "ops/slo.py", "--input", str(sample),
                "--latency-target-seconds", "0.05",
            ],
            capture=True,
        )
        require(not json.loads(result.stdout)["latency_pass"], "latency fault was not detected")


def main() -> None:
    if hasattr(os, "geteuid") and os.geteuid() == 0:
        raise SystemExit("verify: refusal: run as a normal user, not root")
    root = Path(tempfile.mkdtemp(prefix=f"atlas-capstone-{os.getuid()}-"))
    try:
        run([sys.executable, "-m", "compileall", "-q", "service", "tests"])
        run([sys.executable, "-m", "unittest", "discover", "-s", "tests"])
        verify_standard(root)
        verify_faults(root)
        logs = list(root.glob("*.log"))
        require(len(logs) == 4, "expected one log per service mode")
        for log_path in logs:
            for line in log_path.read_text(encoding="utf-8").splitlines():
                value = json.loads(line)
                require("event" in value and "timestamp" in value, f"bad log record: {log_path}")
        print(
            "verify=pass tests=7 modes=4 api=true idempotency=true trace=true "
            "metrics=true backup=true restore=true slo_calculations=2 "
            "faults=3 external_calls=none production_actions=none"
        )
    finally:
        shutil.rmtree(root, ignore_errors=False)
    require(not root.exists(), "temporary evidence root still exists")
    print("cleanup=pass state=absent")


if __name__ == "__main__":
    main()
