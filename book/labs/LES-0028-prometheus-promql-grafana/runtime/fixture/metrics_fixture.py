from __future__ import annotations

import json
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse


LOCK = threading.Lock()
STATE = {
    "success": 120,
    "failure": 3,
    "inflight": 2,
    "buckets": [80, 112, 120, 123],
    "sum": 18.4,
    "count": 123,
}


def metrics() -> bytes:
    with LOCK:
        snapshot = {key: list(value) if isinstance(value, list) else value for key, value in STATE.items()}
    lines = [
        "# HELP training_requests_total Synthetic completed operations.",
        "# TYPE training_requests_total counter",
        f'training_requests_total{{service="checkout",operation="submit",outcome="success"}} {snapshot["success"]}',
        f'training_requests_total{{service="checkout",operation="submit",outcome="failure"}} {snapshot["failure"]}',
        "# HELP training_inflight_requests Synthetic operations currently in flight.",
        "# TYPE training_inflight_requests gauge",
        f'training_inflight_requests{{service="checkout",operation="submit"}} {snapshot["inflight"]}',
        "# HELP training_request_duration_seconds Synthetic operation duration.",
        "# TYPE training_request_duration_seconds histogram",
    ]
    for boundary, count in zip(("0.1", "0.3", "0.6", "+Inf"), snapshot["buckets"], strict=True):
        lines.append(
            'training_request_duration_seconds_bucket'
            f'{{service="checkout",operation="submit",le="{boundary}"}} {count}'
        )
    lines.extend(
        [
            'training_request_duration_seconds_sum{service="checkout",operation="submit"} '
            f'{snapshot["sum"]}',
            'training_request_duration_seconds_count{service="checkout",operation="submit"} '
            f'{snapshot["count"]}',
            "",
        ]
    )
    return "\n".join(lines).encode()


class Handler(BaseHTTPRequestHandler):
    server_version = "ReliabilityAtlasFixture/1"

    def send(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler API
        parsed = urlparse(self.path)
        if parsed.path == "/metrics":
            self.send(200, metrics(), "text/plain; version=0.0.4; charset=utf-8")
            return
        if parsed.path == "/healthz":
            self.send(200, b'{"ready":true}\n', "application/json")
            return
        if parsed.path == "/control":
            mode = parse_qs(parsed.query).get("mode", [""])[0]
            with LOCK:
                if mode == "baseline":
                    STATE.update(success=120, failure=3, inflight=2, buckets=[80, 112, 120, 123], sum=18.4, count=123)
                elif mode == "errors":
                    STATE["success"] += 10
                    STATE["failure"] += 20
                    STATE["buckets"] = [85, 119, 139, 153]
                    STATE["sum"] = 34.9
                    STATE["count"] = 153
                elif mode == "recover":
                    STATE["success"] += 40
                    STATE["failure"] += 1
                    STATE["buckets"] = [110, 154, 179, 194]
                    STATE["sum"] = 39.8
                    STATE["count"] = 194
                else:
                    self.send(400, b'{"error":"unknown-mode"}\n', "application/json")
                    return
                body = (json.dumps({"mode": mode, "state": STATE}, separators=(",", ":")) + "\n").encode()
            self.send(200, body, "application/json")
            return
        self.send(404, b'{"error":"not-found"}\n', "application/json")

    def log_message(self, format: str, *args: object) -> None:
        return


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
