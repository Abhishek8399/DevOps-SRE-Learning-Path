"""Public lab service with an explicit bounded asynchronous carrier."""

from __future__ import annotations

import json
import os
import queue
import re
import sys
import threading
import urllib.error
import urllib.parse
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from opentelemetry import trace as otel_trace
from opentelemetry.trace import Status, StatusCode

from telemetry import (
    configure_tracing,
    extract_trace_context,
    inject_trace_context,
    span_id_hex,
    trace_id_hex,
)


TRACER = configure_tracing()
DOWNSTREAM_URL = os.environ["LAB_DOWNSTREAM_URL"]
ALLOWED_MODES = {"propagate", "drop-context"}
WORK_QUEUE: queue.Queue[dict[str, object]] = queue.Queue(maxsize=8)


def _json_bytes(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


def _call_downstream(
    carrier: dict[str, str], operation_id: str
) -> dict[str, object]:
    target = f"{DOWNSTREAM_URL}?{urllib.parse.urlencode({'operation_id': operation_id})}"
    request = urllib.request.Request(target, headers=carrier, method="GET")
    with urllib.request.urlopen(request, timeout=2) as response:
        value = json.loads(response.read().decode())
    if not isinstance(value, dict):
        raise ValueError("downstream response must be an object")
    return value


def _worker_loop() -> None:
    while True:
        job = WORK_QUEUE.get()
        done = job["done"]
        result = job["result"]
        try:
            if not isinstance(done, threading.Event) or not isinstance(result, dict):
                raise TypeError("invalid internal work item")
            raw_carrier = job["carrier"]
            operation_id = job["operation_id"]
            if not isinstance(raw_carrier, dict) or not all(
                isinstance(key, str) and isinstance(value, str)
                for key, value in raw_carrier.items()
            ):
                raise TypeError("invalid internal trace carrier")
            if not isinstance(operation_id, str) or not re.fullmatch(
                r"[0-9a-f]{16}", operation_id
            ):
                raise TypeError("invalid internal operation identity")
            parent_context = extract_trace_context(raw_carrier)
            extracted_parent = otel_trace.get_current_span(parent_context).get_span_context()
            with TRACER.start_as_current_span(
                "checkout.async_worker", context=parent_context
            ) as worker_span:
                worker_span.set_attribute("lab.carrier.type", "bounded-in-process-queue")
                worker_span.set_attribute("lab.operation.id", operation_id)
                downstream_carrier: dict[str, str] = {}
                inject_trace_context(downstream_carrier)
                downstream = _call_downstream(downstream_carrier, operation_id)
                result.update(
                    {
                        "worker_trace_id": trace_id_hex(worker_span),
                        "worker_span_id": span_id_hex(worker_span),
                        "worker_parent_span_id": (
                            f"{extracted_parent.span_id:016x}"
                            if extracted_parent.is_valid
                            else None
                        ),
                        "downstream_trace_id": str(downstream["trace_id"]),
                        "carrier_keys": sorted(raw_carrier),
                    }
                )
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, KeyError, TypeError, ValueError) as exc:
            result["error"] = type(exc).__name__
        finally:
            if isinstance(done, threading.Event):
                done.set()
            WORK_QUEUE.task_done()


class Handler(BaseHTTPRequestHandler):
    server_version = "LES0027ServiceA/1.0"

    def log_message(self, format_string: str, *args: object) -> None:
        event = {"event": "http_access", "service": "service-a", "detail": format_string % args}
        print(json.dumps(event, sort_keys=True), flush=True)

    def reply(self, status: int, value: object) -> None:
        body = _json_bytes(value)
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 - BaseHTTPRequestHandler contract
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/healthz":
            self.reply(200, {"status": "ok", "service": "service-a"})
            return
        if parsed.path != "/checkout":
            self.reply(404, {"error": "not-found"})
            return

        query = urllib.parse.parse_qs(parsed.query, strict_parsing=False)
        mode = query.get("mode", ["propagate"])[0]
        if mode not in ALLOWED_MODES:
            self.reply(400, {"error": "invalid-mode", "allowed": sorted(ALLOWED_MODES)})
            return
        operation_id = query.get("operation_id", [""])[0]
        if not re.fullmatch(r"[0-9a-f]{16}", operation_id):
            self.reply(400, {"error": "invalid-operation-id"})
            return

        with TRACER.start_as_current_span("checkout") as span:
            span.set_attribute("lab.operation", "checkout")
            span.set_attribute("lab.context.mode", mode)
            span.set_attribute("lab.operation.id", operation_id)
            carrier: dict[str, str] = {}
            if mode == "propagate":
                inject_trace_context(carrier)
            done = threading.Event()
            worker_result: dict[str, object] = {}
            try:
                WORK_QUEUE.put(
                    {
                        "carrier": dict(carrier),
                        "operation_id": operation_id,
                        "done": done,
                        "result": worker_result,
                    },
                    timeout=0.5,
                )
            except queue.Full as exc:
                span.record_exception(exc)
                span.set_status(Status(StatusCode.ERROR, "async-queue-full"))
                self.reply(503, {"error": "async-queue-full"})
                return
            if not done.wait(timeout=3):
                span.set_status(Status(StatusCode.ERROR, "async-worker-timeout"))
                self.reply(504, {"error": "async-worker-timeout"})
                return
            if "error" in worker_result:
                span.set_status(Status(StatusCode.ERROR, "async-worker-failed"))
                self.reply(502, {"error": "async-worker-failed"})
                return

            own_trace_id = trace_id_hex(span)
            own_span_id = span_id_hex(span)
            worker_trace_id = str(worker_result["worker_trace_id"])
            downstream_trace_id = str(worker_result["downstream_trace_id"])
            result = {
                "service": "service-a",
                "mode": mode,
                "operation_id": operation_id,
                "trace_id": own_trace_id,
                "source_span_id": own_span_id,
                "worker_trace_id": worker_trace_id,
                "worker_span_id": worker_result["worker_span_id"],
                "worker_parent_span_id": worker_result["worker_parent_span_id"],
                "downstream_trace_id": downstream_trace_id,
                "async_carrier_keys": worker_result["carrier_keys"],
                "async_context_joined": (
                    own_trace_id == worker_trace_id == downstream_trace_id
                ),
                "joined_context": own_trace_id == worker_trace_id == downstream_trace_id,
                "parentage_matches": (
                    worker_result["worker_parent_span_id"] == own_span_id
                    if mode == "propagate"
                    else worker_result["worker_parent_span_id"] is None
                ),
                "sampled": bool(span.get_span_context().trace_flags.sampled),
            }
            self.reply(200, result)


def main() -> int:
    worker = threading.Thread(
        target=_worker_loop, name="les0027-async-worker", daemon=True
    )
    worker.start()
    server = ThreadingHTTPServer(("0.0.0.0", 8080), Handler)
    server.daemon_threads = True
    print(json.dumps({"event": "ready", "service": "service-a", "port": 8080}), flush=True)
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
