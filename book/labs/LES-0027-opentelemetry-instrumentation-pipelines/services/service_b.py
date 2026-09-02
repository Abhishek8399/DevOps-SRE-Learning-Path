"""Private lab service: extract W3C context and create a child span."""

from __future__ import annotations

import json
import re
import signal
import sys
import threading
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from opentelemetry import trace as otel_trace

from telemetry import (
    configure_tracing,
    extract_trace_context,
    shutdown_tracing,
    span_id_hex,
    telemetry_snapshot,
    trace_id_hex,
)


TRACER = configure_tracing()


def _json_bytes(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()


class Handler(BaseHTTPRequestHandler):
    server_version = "LES0027ServiceB/1.0"

    def log_message(self, format_string: str, *args: object) -> None:
        event = {"event": "http_access", "service": "service-b", "detail": format_string % args}
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
            self.reply(200, {"status": "ok", "service": "service-b"})
            return
        if parsed.path == "/telemetryz":
            query = urllib.parse.parse_qs(parsed.query, strict_parsing=False)
            flush = query.get("flush", ["false"])[0] == "true"
            self.reply(
                200,
                {"service": "service-b", "telemetry": telemetry_snapshot(flush)},
            )
            return
        if parsed.path != "/work":
            self.reply(404, {"error": "not-found"})
            return
        query = urllib.parse.parse_qs(parsed.query, strict_parsing=False)
        operation_id = query.get("operation_id", [""])[0]
        if not re.fullmatch(r"[0-9a-f]{16}", operation_id):
            self.reply(400, {"error": "invalid-operation-id"})
            return

        carrier = {key.lower(): value for key, value in self.headers.items()}
        parent_context = extract_trace_context(carrier)
        extracted_parent = otel_trace.get_current_span(parent_context).get_span_context()
        with TRACER.start_as_current_span("inventory.lookup", context=parent_context) as span:
            span.set_attribute("lab.operation", "inventory.lookup")
            span.set_attribute("lab.operation.id", operation_id)
            self.reply(
                200,
                {
                    "service": "service-b",
                    "operation_id": operation_id,
                    "trace_id": trace_id_hex(span),
                    "span_id": span_id_hex(span),
                    "parent_span_id": (
                        f"{extracted_parent.span_id:016x}"
                        if extracted_parent.is_valid
                        else None
                    ),
                    "sampled": bool(span.get_span_context().trace_flags.sampled),
                },
            )


def main() -> int:
    server = ThreadingHTTPServer(("0.0.0.0", 8081), Handler)
    server.daemon_threads = True
    def request_shutdown(_signum: int, _frame: object) -> None:
        threading.Thread(target=server.shutdown, daemon=True).start()

    signal.signal(signal.SIGTERM, request_shutdown)
    signal.signal(signal.SIGINT, request_shutdown)
    print(json.dumps({"event": "ready", "service": "service-b", "port": 8081}), flush=True)
    try:
        server.serve_forever(poll_interval=0.2)
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        shutdown_tracing()
    return 0


if __name__ == "__main__":
    sys.exit(main())
