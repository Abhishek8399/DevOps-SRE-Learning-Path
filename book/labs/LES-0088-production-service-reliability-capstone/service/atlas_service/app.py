"""HTTP boundary for the local reliability capstone."""

from __future__ import annotations

from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import re
import time
from typing import Any
from urllib.parse import urlsplit

from .config import Settings
from .storage import IdempotencyConflict, StorageUnavailable, Store
from .telemetry import Metrics, RequestContext, log_event, request_context


ITEM_ID = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")
IDEMPOTENCY_KEY = re.compile(r"^[A-Za-z0-9._:-]{8,128}$")


class AtlasServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.store = Store(settings.database_path)
        self.store.initialize()
        self.metrics = Metrics(settings.service_version)
        super().__init__((settings.bind, settings.port), AtlasHandler)


class AtlasHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "AtlasCapstone"
    sys_version = ""
    server: AtlasServer

    def log_message(self, _format: str, *args: object) -> None:
        return

    def _route(self, path: str) -> str:
        if ITEM_ID.fullmatch(path.removeprefix("/api/v1/items/")):
            return "/api/v1/items/{item_id}"
        known = {
            "/", "/version", "/livez", "/readyz", "/metrics", "/api/v1/items",
        }
        return path if path in known else "unmatched"

    def _context(self) -> RequestContext:
        return request_context(
            self.headers.get("traceparent"),
            self.headers.get("X-Request-ID"),
        )

    def _send(
        self,
        status: int,
        body: dict[str, Any] | list[Any] | str,
        context: RequestContext,
        *,
        content_type: str = "application/json",
        extra_headers: dict[str, str] | None = None,
    ) -> None:
        encoded = (
            body.encode("utf-8")
            if isinstance(body, str)
            else json.dumps(body, sort_keys=True, separators=(",", ":")).encode("utf-8")
        )
        self.send_response(status)
        self.send_header("Content-Type", f"{content_type}; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Request-ID", context.request_id)
        self.send_header("traceparent", context.traceparent)
        for key, value in (extra_headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(encoded)

    def _json_body(self) -> dict[str, Any]:
        raw_length = self.headers.get("Content-Length")
        if raw_length is None:
            raise ValueError("Content-Length is required")
        try:
            content_length = int(raw_length)
        except ValueError as exc:
            raise ValueError("Content-Length must be an integer") from exc
        if content_length < 1 or content_length > self.server.settings.max_body_bytes:
            raise ValueError("request body size is outside the accepted boundary")
        content_type = self.headers.get("Content-Type", "").split(";", 1)[0].strip().lower()
        if content_type != "application/json":
            raise ValueError("Content-Type must be application/json")
        try:
            value = json.loads(self.rfile.read(content_length))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ValueError("request body must be valid UTF-8 JSON") from exc
        if not isinstance(value, dict):
            raise ValueError("request body must be a JSON object")
        return value

    def _dispatch(
        self, method: str, path: str
    ) -> tuple[int, object, dict[str, str] | None]:
        settings = self.server.settings
        if settings.fault_mode == "latency" and path.startswith("/api/"):
            time.sleep(settings.fault_delay_ms / 1000)

        if method == "GET" and path == "/":
            return HTTPStatus.OK, {
                "service": "atlas-capstone",
                "version": settings.service_version,
                "boundary": "local-training-fixture-not-production",
            }, None
        if method == "GET" and path == "/version":
            return HTTPStatus.OK, {"version": settings.service_version}, None
        if method == "GET" and path == "/livez":
            return HTTPStatus.OK, {"status": "alive"}, None
        if method == "GET" and path == "/readyz":
            ready = settings.fault_mode != "readiness-failure" and self.server.store.ready()
            self.server.metrics.set_ready(ready)
            status = HTTPStatus.OK if ready else HTTPStatus.SERVICE_UNAVAILABLE
            return status, {"status": "ready" if ready else "not-ready"}, None
        if method == "GET" and path == "/metrics":
            return HTTPStatus.OK, self.server.metrics.render(), {"Content-Type": "text/plain"}
        if method == "GET" and path == "/api/v1/items":
            return HTTPStatus.OK, {"items": self.server.store.list_items()}, None
        if method == "GET" and path.startswith("/api/v1/items/"):
            item_id = path.removeprefix("/api/v1/items/")
            if not ITEM_ID.fullmatch(item_id):
                return HTTPStatus.BAD_REQUEST, {"error": "invalid_item_id"}, None
            item = self.server.store.get_item(item_id)
            if item is None:
                return HTTPStatus.NOT_FOUND, {"error": "item_not_found"}, None
            return HTTPStatus.OK, item, None
        if method == "POST" and path == "/api/v1/items":
            if settings.fault_mode == "write-failure":
                raise StorageUnavailable("injected write failure")
            key = self.headers.get("Idempotency-Key", "")
            if not IDEMPOTENCY_KEY.fullmatch(key):
                return HTTPStatus.BAD_REQUEST, {"error": "invalid_idempotency_key"}, None
            value = self._json_body()
            if set(value) != {"name"}:
                return HTTPStatus.BAD_REQUEST, {"error": "body_requires_only_name"}, None
            name = value["name"]
            if not isinstance(name, str) or not 1 <= len(name.strip()) <= 120:
                return HTTPStatus.BAD_REQUEST, {"error": "invalid_name"}, None
            result = self.server.store.create_item(name.strip(), key)
            status = HTTPStatus.CREATED if result.created else HTTPStatus.OK
            return status, result.item, {
                "Idempotency-Replayed": "false" if result.created else "true"
            }
        return HTTPStatus.NOT_FOUND, {"error": "route_not_found"}, None

    def _handle(self, method: str) -> None:
        started = time.monotonic()
        path = urlsplit(self.path).path
        route = self._route(path)
        context = self._context()
        status = HTTPStatus.INTERNAL_SERVER_ERROR
        try:
            status, body, headers = self._dispatch(method, path)
            content_type = "application/json"
            if headers and "Content-Type" in headers:
                content_type = headers.pop("Content-Type")
            self._send(status, body, context, content_type=content_type, extra_headers=headers)
        except IdempotencyConflict:
            status = HTTPStatus.CONFLICT
            self._send(status, {"error": "idempotency_conflict"}, context)
        except ValueError as exc:
            status = HTTPStatus.BAD_REQUEST
            self._send(status, {"error": "invalid_request", "detail": str(exc)}, context)
        except StorageUnavailable:
            status = HTTPStatus.SERVICE_UNAVAILABLE
            self.server.metrics.storage_error()
            self._send(status, {"error": "storage_unavailable"}, context)
        except (BrokenPipeError, ConnectionResetError):
            status = 499
        except Exception:
            status = HTTPStatus.INTERNAL_SERVER_ERROR
            self._send(status, {"error": "internal_error"}, context)
            log_event("unhandled_request_error", level="error", request_id=context.request_id)
        finally:
            duration = time.monotonic() - started
            self.server.metrics.observe_request(method, route, int(status), duration)
            log_event(
                "request_complete",
                request_id=context.request_id,
                trace_id=context.trace_id,
                span_id=context.span_id,
                method=method,
                route=route,
                status=int(status),
                duration_ms=round(duration * 1000, 3),
            )

    def do_GET(self) -> None:
        self._handle("GET")

    def do_POST(self) -> None:
        self._handle("POST")

    def do_PUT(self) -> None:
        self._handle("PUT")

    def do_DELETE(self) -> None:
        self._handle("DELETE")
