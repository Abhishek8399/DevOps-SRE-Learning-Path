#!/usr/bin/env python3
"""Generate bounded loopback probes and evaluate a declared local SLO window."""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import math
import os
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any


class MeasurementError(ValueError):
    pass


def atomic_lines(path: Path, values: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".probes.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            for value in values:
                handle.write(json.dumps(value, sort_keys=True) + "\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    except BaseException:
        Path(temporary).unlink(missing_ok=True)
        raise


def validate_loopback(url: str) -> None:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "http" or parsed.hostname not in {"127.0.0.1", "localhost", "::1"}:
        raise MeasurementError("probe URL must use HTTP on loopback")
    if parsed.username or parsed.password or parsed.query or parsed.fragment:
        raise MeasurementError("probe URL must not contain credentials, query or fragment")


def one_probe(url: str, timeout: float, sequence: int) -> dict[str, Any]:
    started = time.perf_counter()
    status = 0
    error = ""
    try:
        with urllib.request.urlopen(url, timeout=timeout) as response:
            status = response.status
            response.read(4096)
    except (urllib.error.URLError, TimeoutError, OSError) as failure:
        error = type(failure).__name__
    latency_ms = round((time.perf_counter() - started) * 1000, 3)
    return {
        "sequence": sequence,
        "eligible": True,
        "status": status,
        "success": status == 200,
        "latencyMs": latency_ms,
        "errorClass": error,
    }


def probe(url: str, count: int, concurrency: int, timeout: float, output: Path) -> None:
    validate_loopback(url)
    if not 1 <= count <= 500 or not 1 <= concurrency <= 20 or concurrency > count:
        raise MeasurementError("requests must be 1..500 and concurrency 1..20 without exceeding requests")
    if not 0.1 <= timeout <= 5:
        raise MeasurementError("timeout must be 0.1..5 seconds")
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        values = list(executor.map(lambda n: one_probe(url, timeout, n), range(1, count + 1)))
    values.sort(key=lambda item: item["sequence"])
    atomic_lines(output, values)
    print(f"probe=pass requests={count} concurrency={concurrency} output={output} external_calls=none")


def percentile(values: list[float], quantile: float) -> float:
    if not values:
        raise MeasurementError("percentile requires at least one value")
    ordered = sorted(values)
    index = max(0, math.ceil(quantile * len(ordered)) - 1)
    return ordered[index]


def load_events(path: Path) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    try:
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            value = json.loads(line)
            if not isinstance(value, dict):
                raise MeasurementError(f"line {number} is not an object")
            if not isinstance(value.get("eligible"), bool) or not isinstance(value.get("success"), bool):
                raise MeasurementError(f"line {number} lacks boolean eligibility or success")
            latency = value.get("latencyMs")
            if not isinstance(latency, (int, float)) or latency < 0:
                raise MeasurementError(f"line {number} has invalid latencyMs")
            events.append(value)
    except (OSError, json.JSONDecodeError) as error:
        raise MeasurementError(f"cannot read events: {error}") from error
    if not events:
        raise MeasurementError("event window is empty")
    return events


def evaluate(events: list[dict[str, Any]], availability_objective: float, latency_objective_ms: float) -> dict[str, Any]:
    if not 0 < availability_objective < 1:
        raise MeasurementError("availability objective must be between zero and one")
    if latency_objective_ms <= 0:
        raise MeasurementError("latency objective must be positive")
    eligible = [event for event in events if event["eligible"]]
    if not eligible:
        raise MeasurementError("no eligible events")
    good = [event for event in eligible if event["success"]]
    fast = [event for event in good if event["latencyMs"] <= latency_objective_ms]
    total, successes = len(eligible), len(good)
    failures = total - successes
    availability = successes / total
    allowed_failures = total * (1 - availability_objective)
    return {
        "schemaVersion": 1,
        "windowKind": "bounded-local-probes",
        "eligibleEvents": total,
        "successfulEvents": successes,
        "failedEvents": failures,
        "availability": round(availability, 6),
        "availabilityObjective": availability_objective,
        "objectiveMet": availability >= availability_objective,
        "allowedFailuresFractional": round(allowed_failures, 3),
        "errorBudgetConsumedRatio": round(failures / allowed_failures, 6) if allowed_failures else None,
        "latencyObjectiveMs": latency_objective_ms,
        "fastSuccessfulEvents": len(fast),
        "p95LatencyMs": percentile([float(event["latencyMs"]) for event in eligible], 0.95),
        "claimBoundary": "local fixture window; not a production SLO or capacity promise",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    probe_parser = subparsers.add_parser("probe")
    probe_parser.add_argument("--url", default="http://127.0.0.1:18080/readyz")
    probe_parser.add_argument("--requests", type=int, default=100)
    probe_parser.add_argument("--concurrency", type=int, default=5)
    probe_parser.add_argument("--timeout", type=float, default=2)
    probe_parser.add_argument("--output", type=Path, required=True)
    evaluate_parser = subparsers.add_parser("evaluate")
    evaluate_parser.add_argument("--input", type=Path, required=True)
    evaluate_parser.add_argument("--availability", type=float, default=0.99)
    evaluate_parser.add_argument("--latency-ms", type=float, default=200)
    evaluate_parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    try:
        if args.command == "probe":
            probe(args.url, args.requests, args.concurrency, args.timeout, args.output)
        else:
            receipt = evaluate(load_events(args.input), args.availability, args.latency_ms)
            serialized = json.dumps(receipt, indent=2, sort_keys=True) + "\n"
            if args.output:
                atomic_lines(args.output, [receipt])
            print(serialized, end="")
        return 0
    except MeasurementError as error:
        print(f"measurement=failed reason={error}", file=os.sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
