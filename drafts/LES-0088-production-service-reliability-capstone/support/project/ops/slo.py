#!/usr/bin/env python3
"""Calculate bounded availability, latency, error-budget, and burn evidence."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path


def percentile(values: list[float], percentile_value: float) -> float:
    ordered = sorted(values)
    index = max(0, math.ceil(percentile_value * len(ordered)) - 1)
    return ordered[index]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--availability-target", type=float, default=0.99)
    parser.add_argument("--latency-target-seconds", type=float, default=0.25)
    parser.add_argument("--latency-percentile", type=float, default=0.95)
    args = parser.parse_args()
    if not 0 < args.availability_target < 1:
        raise SystemExit("slo: refusal: availability target must be between 0 and 1")
    if not 0 < args.latency_percentile <= 1:
        raise SystemExit("slo: refusal: latency percentile must be between 0 and 1")
    if not 0 < args.latency_target_seconds <= 10:
        raise SystemExit("slo: refusal: latency target must be within 0..10 seconds")
    records = []
    for line_number, line in enumerate(args.input.read_text(encoding="utf-8").splitlines(), 1):
        try:
            value = json.loads(line)
        except json.JSONDecodeError as exc:
            raise SystemExit(f"slo: invalid JSON at line {line_number}: {exc}") from exc
        if (
            not isinstance(value, dict)
            or not isinstance(value.get("success"), bool)
            or not isinstance(value.get("latency_seconds"), (int, float))
            or value["latency_seconds"] < 0
        ):
            raise SystemExit(f"slo: invalid request record at line {line_number}")
        records.append(value)
    if not records:
        raise SystemExit("slo: refusal: input contains no request records")

    total = len(records)
    good = sum(1 for value in records if value["success"])
    availability = good / total
    failure_ratio = 1 - availability
    error_budget_ratio = 1 - args.availability_target
    burn_rate = failure_ratio / error_budget_ratio
    p_value = percentile(
        [float(value["latency_seconds"]) for value in records],
        args.latency_percentile,
    )
    result = {
        "requests": total,
        "good": good,
        "availability": round(availability, 6),
        "availability_target": args.availability_target,
        "error_budget_ratio": round(error_budget_ratio, 6),
        "observed_failure_ratio": round(failure_ratio, 6),
        "burn_rate": round(burn_rate, 6),
        "latency_percentile": args.latency_percentile,
        "latency_seconds": round(p_value, 6),
        "latency_target_seconds": args.latency_target_seconds,
        "availability_pass": availability >= args.availability_target,
        "latency_pass": p_value <= args.latency_target_seconds,
        "sample_boundary": "bounded-local-sample-not-production-window",
    }
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    main()
