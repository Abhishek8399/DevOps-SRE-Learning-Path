"""Dependency-free structured logs, trace correlation, and bounded metrics."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timezone
import json
import re
import secrets
import sys
from threading import Lock


TRACEPARENT = re.compile(
    r"^00-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})$"
)
REQUEST_ID = re.compile(r"^[A-Za-z0-9._:-]{1,64}$")
LATENCY_BUCKETS = (0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5)


@dataclass(frozen=True, slots=True)
class RequestContext:
    request_id: str
    trace_id: str
    span_id: str
    trace_flags: str

    @property
    def traceparent(self) -> str:
        return f"00-{self.trace_id}-{self.span_id}-{self.trace_flags}"


def request_context(traceparent: str | None, request_id: str | None) -> RequestContext:
    match = TRACEPARENT.fullmatch((traceparent or "").strip().lower())
    if match and match.group(1) != "0" * 32 and match.group(2) != "0" * 16:
        trace_id, _parent_span, flags = match.groups()
    else:
        trace_id, flags = secrets.token_hex(16), "00"
    safe_request_id = request_id if request_id and REQUEST_ID.fullmatch(request_id) else None
    return RequestContext(
        request_id=safe_request_id or secrets.token_hex(12),
        trace_id=trace_id,
        span_id=secrets.token_hex(8),
        trace_flags=flags,
    )


def log_event(event: str, **fields: object) -> None:
    record = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "level": fields.pop("level", "info"),
        "event": event,
        **fields,
    }
    print(json.dumps(record, sort_keys=True, separators=(",", ":")), file=sys.stdout, flush=True)


class Metrics:
    def __init__(self, version: str) -> None:
        self.version = version
        self._lock = Lock()
        self._requests: Counter[tuple[str, str, str]] = Counter()
        self._duration_count: Counter[tuple[str, str]] = Counter()
        self._duration_sum: Counter[tuple[str, str]] = Counter()
        self._duration_buckets: Counter[tuple[str, str, float]] = Counter()
        self._storage_errors = 0
        self._ready = 0

    def observe_request(
        self, method: str, route: str, status: int, duration_seconds: float
    ) -> None:
        status_class = f"{status // 100}xx"
        with self._lock:
            self._requests[(method, route, status_class)] += 1
            self._duration_count[(method, route)] += 1
            self._duration_sum[(method, route)] += duration_seconds
            for boundary in LATENCY_BUCKETS:
                if duration_seconds <= boundary:
                    self._duration_buckets[(method, route, boundary)] += 1

    def storage_error(self) -> None:
        with self._lock:
            self._storage_errors += 1

    def set_ready(self, ready: bool) -> None:
        with self._lock:
            self._ready = 1 if ready else 0

    @staticmethod
    def _labels(**labels: str) -> str:
        escaped = []
        slash = chr(92)
        for key, value in labels.items():
            clean = value.replace(slash, slash + slash)
            clean = clean.replace(chr(10), slash + chr(110))
            clean = clean.replace(chr(34), slash + chr(34))
            escaped.append(f'{key}={chr(34)}{clean}{chr(34)}')
        return "{" + ",".join(escaped) + "}"

    def render(self) -> str:
        with self._lock:
            requests = self._requests.copy()
            counts = self._duration_count.copy()
            sums = self._duration_sum.copy()
            buckets = self._duration_buckets.copy()
            storage_errors = self._storage_errors
            ready = self._ready

        lines = [
            "# HELP atlas_build_info Build identity of the local capstone service.",
            "# TYPE atlas_build_info gauge",
            f'atlas_build_info{self._labels(version=self.version)} 1',
            "# HELP atlas_ready Whether the durable-state readiness check succeeds.",
            "# TYPE atlas_ready gauge",
            f"atlas_ready {ready}",
            "# HELP atlas_storage_errors_total Storage operations that failed.",
            "# TYPE atlas_storage_errors_total counter",
            f"atlas_storage_errors_total {storage_errors}",
            "# HELP atlas_http_requests_total Completed HTTP requests.",
            "# TYPE atlas_http_requests_total counter",
        ]
        for (method, route, status_class), value in sorted(requests.items()):
            lines.append(
                "atlas_http_requests_total"
                + self._labels(method=method, route=route, status_class=status_class)
                + f" {value}"
            )
        lines.extend(
            [
                "# HELP atlas_http_request_duration_seconds Request latency in seconds.",
                "# TYPE atlas_http_request_duration_seconds histogram",
            ]
        )
        for method, route in sorted(counts):
            labels = {"method": method, "route": route}
            for boundary in LATENCY_BUCKETS:
                lines.append(
                    "atlas_http_request_duration_seconds_bucket"
                    + self._labels(**labels, le=str(boundary))
                    + f" {buckets[(method, route, boundary)]}"
                )
            lines.append(
                "atlas_http_request_duration_seconds_bucket"
                + self._labels(**labels, le="+Inf")
                + f" {counts[(method, route)]}"
            )
            lines.append(
                "atlas_http_request_duration_seconds_count"
                + self._labels(**labels)
                + f" {counts[(method, route)]}"
            )
            lines.append(
                "atlas_http_request_duration_seconds_sum"
                + self._labels(**labels)
                + f" {sums[(method, route)]:.9f}"
            )
        return chr(10).join(lines) + chr(10)
