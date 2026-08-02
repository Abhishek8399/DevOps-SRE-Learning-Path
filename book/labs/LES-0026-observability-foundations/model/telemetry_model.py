#!/usr/bin/env python3
"""Deterministic, provider-neutral telemetry teaching model for LES-0026."""

from __future__ import annotations

import argparse
import cProfile
import hashlib
import json
import os
import pstats
import stat
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Iterable


OUTPUT_FILES = (
    "metrics.json",
    "logs.ndjson",
    "traces.ndjson",
    "events.ndjson",
    "profile.json",
    "pipeline-counters.json",
    "cardinality.json",
    "retention.json",
    "privacy.json",
    "evidence-limits.json",
    "signal-manifest.json",
    "case-report.json",
)
MODELED_TRACE_DROP_REASON = "export_queue_full"
INGEST_DELAY_MS_BY_SEQUENCE = {2: 4500}


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(
        "utf-8"
    )


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def write_bytes(path: Path, content: bytes) -> None:
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        view = memoryview(content)
        while view:
            written = os.write(descriptor, view)
            if written <= 0:
                raise RuntimeError(f"short write for {path.name}")
            view = view[written:]
    finally:
        os.close(descriptor)


def write_json(path: Path, value: object) -> None:
    write_bytes(path, canonical_bytes(value))


def write_ndjson(path: Path, rows: Iterable[dict[str, Any]]) -> None:
    content = b"".join(canonical_bytes(row) for row in rows)
    write_bytes(path, content)


def parse_time(value: str) -> datetime:
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError("timestamp must include a timezone")
    return parsed.astimezone(timezone.utc)


def format_time(value: datetime) -> str:
    rendered = value.astimezone(timezone.utc).isoformat(timespec="milliseconds")
    return rendered.replace("+00:00", "Z")


def nearest_rank(values: list[int], fraction: float) -> int:
    ordered = sorted(values)
    if not ordered:
        raise ValueError("percentile requires at least one value")
    rank = max(1, int(len(ordered) * fraction + 0.999999999))
    return ordered[min(rank, len(ordered)) - 1]


def status_class(status_code: int) -> str:
    return f"{status_code // 100}xx"


def checksum_step(value: int) -> int:
    return ((value * 17) ^ (value >> 1)) % 65521


def profile_work(units: int) -> int:
    result = 0
    for value in range(units):
        result = (result + checksum_step(value)) % 65521
    return result


def deterministic_profile() -> dict[str, Any]:
    profiler = cProfile.Profile()
    profiler.enable()
    checksum = profile_work(12)
    profiler.disable()
    stats = pstats.Stats(profiler)
    wanted = {"profile_work", "checksum_step"}
    calls: dict[str, int] = {}
    for (_filename, _line, function_name), values in stats.stats.items():
        if function_name in wanted:
            primitive_calls, total_calls = int(values[0]), int(values[1])
            if primitive_calls != total_calls:
                raise RuntimeError("unexpected recursive profile function")
            calls[function_name] = total_calls
    expected = {"checksum_step": 12, "profile_work": 1}
    if calls != expected:
        raise RuntimeError(f"unexpected deterministic profile calls: {calls!r}")
    return {
        "functions": [
            {"callCount": calls[name], "name": name} for name in sorted(calls)
        ],
        "kind": "python-cprofile-call-count-summary",
        "resultChecksum": checksum,
        "timingFieldsOmitted": True,
        "timingReason": "wall and CPU durations are nondeterministic on a shared host",
    }


def validate_config(config: object) -> dict[str, Any]:
    if not isinstance(config, dict):
        raise ValueError("configuration must be an object")
    required = {
        "analysisTime",
        "baseTime",
        "environment",
        "lesson",
        "missingSignalCase",
        "privacy",
        "requests",
        "retentionSeconds",
        "scenarioId",
        "schemaVersion",
        "service",
        "thresholds",
    }
    if set(config) != required:
        raise ValueError("configuration keys do not match the reviewed contract")
    if config["schemaVersion"] != 1 or config["lesson"] != "LES-0026":
        raise ValueError("configuration identity is invalid")
    requests = config["requests"]
    if not isinstance(requests, list) or len(requests) != 8:
        raise ValueError("exactly eight synthetic requests are required")
    request_keys = {
        "method",
        "queueMs",
        "requestId",
        "route",
        "sequence",
        "serviceMs",
        "status",
        "syntheticTraceKey",
    }
    if any(not isinstance(request, dict) or set(request) != request_keys for request in requests):
        raise ValueError("request keys do not match the reviewed contract")
    expected_sequences = list(range(1, 9))
    if [request.get("sequence") for request in requests] != expected_sequences:
        raise ValueError("request sequences must be the integers one through eight")
    if [request.get("requestId") for request in requests] != [
        f"req-{sequence:04d}" for sequence in expected_sequences
    ]:
        raise ValueError("request identifiers are not deterministic")
    if [request.get("syntheticTraceKey") for request in requests] != [
        f"trace-key-{sequence:04d}" for sequence in expected_sequences
    ]:
        raise ValueError("synthetic trace keys are not deterministic")
    if config["missingSignalCase"] != {"traceDropSequences": [3, 7]}:
        raise ValueError("missing-signal configuration is invalid")
    return config


def signal_times(base: datetime, sequence: int) -> tuple[str, str, str]:
    event = base + timedelta(seconds=sequence)
    observed = event + timedelta(milliseconds=50)
    ingested = observed + timedelta(
        milliseconds=INGEST_DELAY_MS_BY_SEQUENCE.get(sequence, 50)
    )
    return format_time(event), format_time(observed), format_time(ingested)


def build_rows(config: dict[str, Any], case_name: str) -> dict[str, Any]:
    requests = config["requests"]
    base = parse_time(config["baseTime"])
    latency_threshold = int(config["thresholds"]["latencyMs"])
    queue_threshold = int(config["thresholds"]["queueMs"])
    dropped_sequences = (
        set(config["missingSignalCase"]["traceDropSequences"])
        if case_name == "missing-signal"
        else set()
    )

    logs: list[dict[str, Any]] = []
    traces: list[dict[str, Any]] = []
    latency_values: list[int] = []
    queue_values: list[int] = []
    errors = 0
    safe_series: set[tuple[str, str, str]] = set()

    for request in requests:
        sequence = int(request["sequence"])
        event_time, observed_time, ingest_time = signal_times(base, sequence)
        queue_ms = int(request["queueMs"])
        service_ms = int(request["serviceMs"])
        total_ms = queue_ms + service_ms
        status = int(request["status"])
        outcome = "error" if status >= 500 else "ok"
        errors += int(outcome == "error")
        latency_values.append(total_ms)
        queue_values.append(queue_ms)
        safe_series.add((request["route"], request["method"], status_class(status)))
        shared = {
            "eventTime": event_time,
            "ingestTime": ingest_time,
            "observedTime": observed_time,
            "requestId": request["requestId"],
            "sequence": sequence,
            "syntheticTraceKey": request["syntheticTraceKey"],
        }
        logs.append(
            {
                **shared,
                "customerEmail": config["privacy"]["outputReplacement"],
                "kind": "request-log",
                "latencyMs": total_ms,
                "level": "ERROR" if outcome == "error" else "INFO",
                "message": "synthetic request completed",
                "method": request["method"],
                "outcome": outcome,
                "route": request["route"],
                "service": config["service"],
                "status": status,
            }
        )
        if sequence not in dropped_sequences:
            root_span_key = f"span-key-{sequence:04d}-r"
            traces.append(
                {
                    **shared,
                    "kind": "request-trace",
                    "service": config["service"],
                    "spans": [
                        {
                            "durationMs": total_ms,
                            "name": "request.total",
                            "parentSyntheticSpanKey": None,
                            "startOffsetMs": 0,
                            "syntheticSpanKey": root_span_key,
                        },
                        {
                            "durationMs": queue_ms,
                            "name": "queue.wait",
                            "parentSyntheticSpanKey": root_span_key,
                            "startOffsetMs": 0,
                            "syntheticSpanKey": f"span-key-{sequence:04d}-q",
                        },
                        {
                            "durationMs": service_ms,
                            "name": "service.handle",
                            "parentSyntheticSpanKey": root_span_key,
                            "startOffsetMs": queue_ms,
                            "syntheticSpanKey": f"span-key-{sequence:04d}-s",
                        },
                    ],
                    "status": "error" if outcome == "error" else "ok",
                }
            )

    event_rows = [
        {
            "eventTime": format_time(base),
            "eventType": "release-marker",
            "ingestTime": format_time(base + timedelta(milliseconds=100)),
            "kind": "change-event",
            "observedTime": format_time(base + timedelta(milliseconds=50)),
            "releaseId": "release-local-0001",
            "sequence": 0,
        },
        {
            "eventTime": signal_times(base, 3)[0],
            "eventType": "queue-threshold-crossed",
            "ingestTime": signal_times(base, 3)[2],
            "kind": "operational-event",
            "observedTime": signal_times(base, 3)[1],
            "sequence": 3,
            "thresholdMs": queue_threshold,
        },
        {
            "eventTime": signal_times(base, 4)[0],
            "eventType": "request-error-observed",
            "ingestTime": signal_times(base, 4)[2],
            "kind": "operational-event",
            "observedTime": signal_times(base, 4)[1],
            "sequence": 4,
            "status": 503,
        },
    ]

    exemplar_request = max(
        requests, key=lambda request: int(request["queueMs"]) + int(request["serviceMs"])
    )
    metrics = {
        "counters": {
            "errors": errors,
            "latencyBreaches": sum(
                1
                for request in requests
                if int(request["queueMs"]) + int(request["serviceMs"])
                > latency_threshold
            ),
            "queueBreaches": sum(
                1 for request in requests if int(request["queueMs"]) > queue_threshold
            ),
            "requests": len(requests),
        },
        "exemplar": {
            "note": "shared identifiers correlate records but do not establish causality",
            "requestId": exemplar_request["requestId"],
            "syntheticTraceKey": exemplar_request["syntheticTraceKey"],
        },
        "kind": "aggregate-metrics",
        "latencyMs": {
            "max": max(latency_values),
            "p50NearestRank": nearest_rank(latency_values, 0.50),
            "p95NearestRank": nearest_rank(latency_values, 0.95),
            "values": sorted(latency_values),
        },
        "queueMs": {
            "max": max(queue_values),
            "p50NearestRank": nearest_rank(queue_values, 0.50),
            "p95NearestRank": nearest_rank(queue_values, 0.95),
            "values": sorted(queue_values),
        },
        "window": {
            "end": format_time(base + timedelta(seconds=8, milliseconds=100)),
            "start": format_time(base),
        },
    }
    cardinality = {
        "actualBoundedSeries": len(safe_series),
        "boundedDimensions": ["route", "method", "status_class"],
        "boundedSeries": [
            {"method": method, "route": route, "statusClass": status_value}
            for route, method, status_value in sorted(safe_series)
        ],
        "requestIdAsMetricLabel": False,
        "unsafeRequestIdSeriesEstimate": len(requests),
        "warning": "request, trace, user, and unbounded URL values belong in controlled event data, not metric labels",
    }
    analysis_time = parse_time(config["analysisTime"])
    age_seconds = int((analysis_time - base).total_seconds())
    retention = {
        "analysisTime": format_time(analysis_time),
        "recordAgeSeconds": age_seconds,
        "signals": {
            name: {
                "policySeconds": int(seconds),
                "retainedAtAnalysisTime": age_seconds <= int(seconds),
            }
            for name, seconds in sorted(config["retentionSeconds"].items())
        },
        "warning": "modeled retention decisions do not delete files or prove a production policy",
    }
    privacy = {
        "outputReplacement": config["privacy"]["outputReplacement"],
        "prohibitedMetricLabels": ["request_id", "trace_id", "customer_email"],
        "rawSyntheticValuePresent": False,
        "redactedLogRows": len(logs),
        "sourceSensitiveFields": ["customerEmail"],
    }
    profile = deterministic_profile()
    counters = {
        "case": case_name,
        "stages": {
            "events": {"dropped": 0, "exported": len(event_rows), "produced": len(event_rows)},
            "logs": {"dropped": 0, "exported": len(logs), "produced": len(logs)},
            "metrics": {"dropped": 0, "exported": 1, "produced": 1},
            "profiles": {"dropped": 0, "exported": 1, "produced": 1},
            "traces": {
                "dropReason": (
                    MODELED_TRACE_DROP_REASON if dropped_sequences else None
                ),
                "dropped": len(dropped_sequences),
                "droppedSequences": sorted(dropped_sequences),
                "exported": len(traces),
                "produced": len(requests),
            },
        },
    }
    evidence_limits = {
        "claims": [
            {
                "doesNotProve": "that the threshold is a valid production objective",
                "proves": "the deterministic input contains two queue-threshold breaches",
                "signal": "metrics",
            },
            {
                "doesNotProve": "why the request failed or whether a user retried",
                "proves": "one synthetic request record reports status 503",
                "signal": "logs",
            },
            {
                "doesNotProve": "causality, host isolation, or behavior of a vendor tracer",
                "proves": "exported spans share modeled request and synthetic trace keys",
                "signal": "traces",
            },
            {
                "doesNotProve": "that the release marker caused later latency or errors",
                "proves": "the release marker was recorded earlier in modeled event time",
                "signal": "events",
            },
            {
                "doesNotProve": "wall time, CPU saturation, or production hot paths",
                "proves": "Python cProfile observed the declared local function call counts",
                "signal": "profiles",
            },
            {
                "doesNotProve": "that an absent production trace was never produced",
                "proves": "the missing-signal artifact contains fewer exported traces than requests",
                "signal": "absence",
            },
        ],
        "correlationIsCausality": False,
        "modelBoundary": "provider-neutral local teaching model",
        "traceContextStandard": "none; synthetic keys are not W3C traceparent identifiers",
    }
    return {
        "cardinality": cardinality,
        "counters": counters,
        "events": event_rows,
        "evidenceLimits": evidence_limits,
        "logs": logs,
        "metrics": metrics,
        "privacy": privacy,
        "profile": profile,
        "retention": retention,
        "traces": traces,
    }


def build_case(config: dict[str, Any], case_name: str, workspace: Path) -> dict[str, Any]:
    if case_name not in {"guided", "missing-signal"}:
        raise ValueError("case is not allowed")
    if not workspace.is_dir() or workspace.is_symlink():
        raise ValueError("workspace must be an existing non-symlink directory")
    info = workspace.stat()
    if info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) != 0o700:
        raise ValueError("workspace owner or mode is invalid")
    if any(workspace.iterdir()):
        raise ValueError("workspace must begin empty")

    rows = build_rows(config, case_name)
    write_json(workspace / "metrics.json", rows["metrics"])
    write_ndjson(workspace / "logs.ndjson", rows["logs"])
    write_ndjson(workspace / "traces.ndjson", rows["traces"])
    write_ndjson(workspace / "events.ndjson", rows["events"])
    write_json(workspace / "profile.json", rows["profile"])
    write_json(workspace / "pipeline-counters.json", rows["counters"])
    write_json(workspace / "cardinality.json", rows["cardinality"])
    write_json(workspace / "retention.json", rows["retention"])
    write_json(workspace / "privacy.json", rows["privacy"])
    write_json(workspace / "evidence-limits.json", rows["evidenceLimits"])

    manifest_entries: dict[str, dict[str, Any]] = {}
    row_counts = {
        "cardinality.json": 1,
        "events.ndjson": len(rows["events"]),
        "evidence-limits.json": len(rows["evidenceLimits"]["claims"]),
        "logs.ndjson": len(rows["logs"]),
        "metrics.json": 1,
        "pipeline-counters.json": 5,
        "privacy.json": 1,
        "profile.json": len(rows["profile"]["functions"]),
        "retention.json": len(rows["retention"]["signals"]),
        "traces.ndjson": len(rows["traces"]),
    }
    for name in sorted(row_counts):
        content = (workspace / name).read_bytes()
        manifest_entries[name] = {
            "rowCount": row_counts[name],
            "sha256": sha256_bytes(content),
        }
    manifest = {
        "case": case_name,
        "entries": manifest_entries,
        "schemaVersion": 1,
    }
    write_json(workspace / "signal-manifest.json", manifest)

    report = {
        "case": case_name,
        "correlationIsCausality": False,
        "eventRows": len(rows["events"]),
        "files": list(OUTPUT_FILES),
        "logRows": len(rows["logs"]),
        "manifestSha256": sha256_bytes(canonical_bytes(manifest)),
        "metricRequests": rows["metrics"]["counters"]["requests"],
        "networkTargets": [],
        "profileKind": rows["profile"]["kind"],
        "schemaVersion": 1,
        "secretInputs": [],
        "traceRows": len(rows["traces"]),
    }
    write_json(workspace / "case-report.json", report)
    return report


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description="LES-0026 deterministic telemetry model")
    result.add_argument("--case", choices=("guided", "missing-signal"), required=True)
    result.add_argument("--config", required=True)
    result.add_argument("--workspace", required=True)
    return result


def read_config(path: Path) -> dict[str, Any]:
    before = os.lstat(path)
    if not stat.S_ISREG(before.st_mode) or stat.S_ISLNK(before.st_mode):
        raise ValueError("configuration must be a regular non-symlink file")
    descriptor = os.open(path, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
    try:
        opened = os.fstat(descriptor)
        if (opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino):
            raise ValueError("configuration identity changed while opening")
        chunks: list[bytes] = []
        total = 0
        while True:
            chunk = os.read(descriptor, 65536)
            if not chunk:
                break
            total += len(chunk)
            if total > 1024 * 1024:
                raise ValueError("configuration is unexpectedly large")
            chunks.append(chunk)
    finally:
        os.close(descriptor)
    try:
        payload = json.loads(b"".join(chunks).decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError("configuration is not valid UTF-8 JSON") from error
    return validate_config(payload)


def main() -> None:
    if os.geteuid() == 0:
        print("root-is-refused-run-as-a-normal-user", file=sys.stderr)
        raise SystemExit(77)
    args = parser().parse_args()
    config_path = Path(args.config)
    config = read_config(config_path)
    report = build_case(config, args.case, Path(args.workspace))
    sys.stdout.buffer.write(canonical_bytes(report))


if __name__ == "__main__":
    os.umask(0o077)
    main()
