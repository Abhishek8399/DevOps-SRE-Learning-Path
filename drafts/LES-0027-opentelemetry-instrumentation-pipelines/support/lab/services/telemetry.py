"""Small, explicit OpenTelemetry setup for the bounded LES-0027 services."""

from __future__ import annotations

import hashlib
import os
import threading

from opentelemetry import propagate, trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import IdGenerator, TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
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


def configure_tracing():
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
    exporter = OTLPSpanExporter(endpoint=endpoint, timeout=2)
    provider.add_span_processor(
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
        )
    )
    trace.set_tracer_provider(provider)
    return trace.get_tracer(service_name, "1.0.0")


def inject_trace_context(carrier: dict[str, str]) -> None:
    propagate.inject(carrier)


def extract_trace_context(carrier: dict[str, str]):
    return propagate.extract(carrier)


def trace_id_hex(span) -> str:
    return f"{span.get_span_context().trace_id:032x}"


def span_id_hex(span) -> str:
    return f"{span.get_span_context().span_id:016x}"
