"""Small, explicit OpenTelemetry setup for the bounded LES-0027 services."""

from __future__ import annotations

import hashlib
import os
import threading
from collections.abc import Sequence
from typing import Any

from opentelemetry import propagate, trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import IdGenerator, SpanProcessor, TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    ReadableSpan,
    SpanExportResult,
    SpanExporter,
)
from opentelemetry.sdk.trace.sampling import ParentBased, TraceIdRatioBased


def _positive_identifier(material: bytes, width: int) -> int:
    value = int.from_bytes(hashlib.sha256(material).digest()[:width], "big")
    return value or 1


class DeterministicLabIdGenerator(IdGenerator):
    """Repeatable IDs make the sampling exercise reproducible, not production-like."""

    def __init__(self, service_name: str) -> None:
        self._service_name = service_name
        self._lock = threading.Lock()
        self._trace_counter = 0
        self._span_counter = 0

    def generate_span_id(self) -> int:
        with self._lock:
            self._span_counter += 1
            counter = self._span_counter
        material = f"LES-0027:{self._service_name}:span:{counter}".encode()
        return _positive_identifier(material, 8)

    def generate_trace_id(self) -> int:
        with self._lock:
            self._trace_counter += 1
            counter = self._trace_counter
        material = f"LES-0027:{self._service_name}:trace:{counter}".encode()
        return _positive_identifier(material, 16)


class TelemetryCounters:
    """Process-local counters exposed only through the guarded lab network."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._values = {
            "spansStarted": 0,
            "spansEnded": 0,
            "exportAttemptedSpans": 0,
            "exportSucceededSpans": 0,
            "exportFailedSpans": 0,
        }

    def add(self, name: str, amount: int = 1) -> None:
        with self._lock:
            self._values[name] += amount

    def snapshot(self) -> dict[str, int]:
        with self._lock:
            return dict(self._values)


class CountingSpanExporter(SpanExporter):
    def __init__(self, delegate: SpanExporter, counters: TelemetryCounters) -> None:
        self._delegate = delegate
        self._counters = counters

    def export(self, spans: Sequence[ReadableSpan]) -> SpanExportResult:
        count = len(spans)
        self._counters.add("exportAttemptedSpans", count)
        try:
            result = self._delegate.export(spans)
        except Exception:
            self._counters.add("exportFailedSpans", count)
            raise
        if result is SpanExportResult.SUCCESS:
            self._counters.add("exportSucceededSpans", count)
        else:
            self._counters.add("exportFailedSpans", count)
        return result

    def shutdown(self) -> None:
        self._delegate.shutdown()

    def force_flush(self, timeout_millis: int = 30000) -> bool:
        return self._delegate.force_flush(timeout_millis)


class CountingSpanProcessor(SpanProcessor):
    def __init__(self, delegate: SpanProcessor, counters: TelemetryCounters) -> None:
        self._delegate = delegate
        self._counters = counters

    def on_start(self, span: Any, parent_context: Any = None) -> None:
        self._counters.add("spansStarted")
        self._delegate.on_start(span, parent_context)

    def on_end(self, span: ReadableSpan) -> None:
        self._counters.add("spansEnded")
        self._delegate.on_end(span)

    def shutdown(self) -> None:
        self._delegate.shutdown()

    def force_flush(self, timeout_millis: int = 30000) -> bool:
        return self._delegate.force_flush(timeout_millis)


_PROVIDER: TracerProvider | None = None
_COUNTERS: TelemetryCounters | None = None


def configure_tracing():
    global _COUNTERS, _PROVIDER
    if _PROVIDER is not None:
        raise RuntimeError("tracing is already configured")
    service_name = os.environ["OTEL_SERVICE_NAME"]
    endpoint = os.environ["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"]
    ratio_text = os.environ.get("OTEL_TRACES_SAMPLER_ARG", "1.0")
    ratio = float(ratio_text)
    if not 0.0 <= ratio <= 1.0:
        raise ValueError("OTEL_TRACES_SAMPLER_ARG must be between 0.0 and 1.0")

    provider = TracerProvider(
        resource=Resource.create(
            {
                "service.name": service_name,
                "service.namespace": "reliability-atlas-lab",
                "deployment.environment.name": "local-training",
                "lab.lesson": "LES-0027",
            }
        ),
        sampler=ParentBased(root=TraceIdRatioBased(ratio)),
        id_generator=DeterministicLabIdGenerator(service_name),
    )
    counters = TelemetryCounters()
    exporter = CountingSpanExporter(
        OTLPSpanExporter(endpoint=endpoint, timeout=2), counters
    )
    processor = CountingSpanProcessor(
        BatchSpanProcessor(
            exporter,
            max_queue_size=int(os.environ.get("OTEL_BSP_MAX_QUEUE_SIZE", "128")),
            max_export_batch_size=int(
                os.environ.get("OTEL_BSP_MAX_EXPORT_BATCH_SIZE", "32")
            ),
            schedule_delay_millis=int(
                os.environ.get("OTEL_BSP_SCHEDULE_DELAY", "200")
            ),
            export_timeout_millis=2000,
        ),
        counters,
    )
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    _PROVIDER = provider
    _COUNTERS = counters
    return trace.get_tracer(service_name, "1.0.0")


def telemetry_snapshot(force_flush: bool = False) -> dict[str, object]:
    if _PROVIDER is None or _COUNTERS is None:
        raise RuntimeError("tracing is not configured")
    flush_succeeded = None
    if force_flush:
        flush_succeeded = _PROVIDER.force_flush(timeout_millis=2000)
    return {
        "counterUnit": "spans",
        "forceFlushRequested": force_flush,
        "forceFlushSucceeded": flush_succeeded,
        "counters": _COUNTERS.snapshot(),
    }


def shutdown_tracing() -> None:
    global _PROVIDER
    if _PROVIDER is not None:
        _PROVIDER.force_flush(timeout_millis=2000)
        _PROVIDER.shutdown()
        _PROVIDER = None


def inject_trace_context(carrier: dict[str, str]) -> None:
    propagate.inject(carrier)


def extract_trace_context(carrier: dict[str, str]):
    return propagate.extract(carrier)


def trace_id_hex(span) -> str:
    return f"{span.get_span_context().trace_id:032x}"


def span_id_hex(span) -> str:
    return f"{span.get_span_context().span_id:016x}"
