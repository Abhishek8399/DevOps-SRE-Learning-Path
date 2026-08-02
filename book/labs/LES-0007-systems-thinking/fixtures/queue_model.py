#!/usr/bin/env python3
"""Deterministic bounded queue model for LES-0007.

The model advances virtual milliseconds. It does not sleep, open sockets,
create child processes, or generate host CPU, memory, disk, or network load.
"""

from __future__ import annotations

import argparse
import math
from collections import deque
from dataclasses import dataclass
from typing import Deque, Dict, List, Optional, Tuple


@dataclass(frozen=True)
class Profile:
    name: str
    jobs: int
    workers: int
    arrival_ms: int
    service_ms: int
    queue_capacity: int


PROFILES: Dict[str, Profile] = {
    "stable": Profile(
        name="stable",
        jobs=12,
        workers=1,
        arrival_ms=400,
        service_ms=300,
        queue_capacity=3,
    ),
    "saturated": Profile(
        name="saturated",
        jobs=12,
        workers=1,
        arrival_ms=100,
        service_ms=300,
        queue_capacity=3,
    ),
    "recovered": Profile(
        name="recovered",
        jobs=12,
        workers=3,
        arrival_ms=100,
        service_ms=300,
        queue_capacity=3,
    ),
}


def nearest_rank(values: List[int], percentile: float) -> int:
    """Return the nearest-rank percentile for a non-empty integer sample."""

    ordered = sorted(values)
    rank = max(1, math.ceil(percentile * len(ordered)))
    return ordered[rank - 1]


def simulate(profile: Profile) -> Dict[str, str]:
    """Run a finite first-in, first-out queue simulation."""

    events: List[Dict[str, Optional[int]]] = [
        {
            "offered_at": job_id * profile.arrival_ms,
            "admitted_at": None,
            "started_at": None,
            "completed_at": None,
        }
        for job_id in range(profile.jobs)
    ]

    pending: Deque[int] = deque()
    waiting: Deque[int] = deque()
    workers: List[Optional[Tuple[int, int]]] = [None] * profile.workers
    next_offer = 0
    completed_jobs = 0
    now_ms = 0
    max_queue = 0
    producer_blocked_ms = 0

    last_offer_ms = events[-1]["offered_at"]
    assert isinstance(last_offer_ms, int)
    abort_after_ms = last_offer_ms + profile.jobs * profile.service_ms + 1_000

    while completed_jobs < profile.jobs:
        for worker_index, assignment in enumerate(workers):
            if assignment is None:
                continue
            job_id, finish_ms = assignment
            if finish_ms == now_ms:
                events[job_id]["completed_at"] = now_ms
                workers[worker_index] = None
                completed_jobs += 1

        for worker_index, assignment in enumerate(workers):
            if assignment is None and waiting:
                job_id = waiting.popleft()
                events[job_id]["started_at"] = now_ms
                workers[worker_index] = (
                    job_id,
                    now_ms + profile.service_ms,
                )

        while next_offer < profile.jobs:
            offered_at = events[next_offer]["offered_at"]
            assert isinstance(offered_at, int)
            if offered_at > now_ms:
                break
            pending.append(next_offer)
            next_offer += 1

        while pending:
            idle_worker = next(
                (
                    worker_index
                    for worker_index, assignment in enumerate(workers)
                    if assignment is None
                ),
                None,
            )
            job_id = pending[0]

            if idle_worker is not None:
                pending.popleft()
                events[job_id]["admitted_at"] = now_ms
                events[job_id]["started_at"] = now_ms
                workers[idle_worker] = (
                    job_id,
                    now_ms + profile.service_ms,
                )
                continue

            if len(waiting) < profile.queue_capacity:
                pending.popleft()
                events[job_id]["admitted_at"] = now_ms
                waiting.append(job_id)
                continue

            break

        max_queue = max(max_queue, len(waiting))
        if pending:
            producer_blocked_ms += 1

        if completed_jobs == profile.jobs:
            break

        now_ms += 1
        if now_ms > abort_after_ms:
            raise RuntimeError("simulation exceeded its finite safety bound")

    offered_values: List[int] = []
    admitted_values: List[int] = []
    started_values: List[int] = []
    completed_values: List[int] = []

    for event in events:
        offered_at = event["offered_at"]
        admitted_at = event["admitted_at"]
        started_at = event["started_at"]
        completed_at = event["completed_at"]
        if not all(
            isinstance(value, int)
            for value in (
                offered_at,
                admitted_at,
                started_at,
                completed_at,
            )
        ):
            raise RuntimeError("a job did not complete all lifecycle stages")

        assert isinstance(offered_at, int)
        assert isinstance(admitted_at, int)
        assert isinstance(started_at, int)
        assert isinstance(completed_at, int)
        if not offered_at <= admitted_at <= started_at <= completed_at:
            raise RuntimeError("job timestamps violate lifecycle ordering")

        offered_values.append(offered_at)
        admitted_values.append(admitted_at)
        started_values.append(started_at)
        completed_values.append(completed_at)

    waits = [
        started - admitted
        for admitted, started in zip(admitted_values, started_values)
    ]
    admission_delays = [
        admitted - offered
        for offered, admitted in zip(offered_values, admitted_values)
    ]
    completion_latencies = [
        completed - offered
        for offered, completed in zip(offered_values, completed_values)
    ]
    elapsed_ms = max(completed_values) - min(offered_values)

    if max_queue > profile.queue_capacity:
        raise RuntimeError("queue capacity invariant was violated")
    if elapsed_ms <= 0:
        raise RuntimeError("elapsed virtual time must be positive")

    throughput = profile.jobs * 1_000 / elapsed_ms
    arrival_rate = 1_000 / profile.arrival_ms
    service_capacity = profile.workers * 1_000 / profile.service_ms

    return {
        "profile": profile.name,
        "jobs": str(profile.jobs),
        "completed": str(profile.jobs),
        "workers": str(profile.workers),
        "arrival_ms": str(profile.arrival_ms),
        "service_ms": str(profile.service_ms),
        "elapsed_ms": str(elapsed_ms),
        "throughput_per_s": f"{throughput:.3f}",
        "max_queue": str(max_queue),
        "mean_wait_ms": f"{sum(waits) / len(waits):.3f}",
        "p95_wait_ms": str(nearest_rank(waits, 0.95)),
        "queue_capacity": str(profile.queue_capacity),
        "offered_rate_per_s": f"{arrival_rate:.3f}",
        "nominal_capacity_per_s": f"{service_capacity:.3f}",
        "backpressure_jobs": str(
            sum(delay > 0 for delay in admission_delays)
        ),
        "producer_blocked_ms": str(producer_blocked_ms),
        "max_admission_delay_ms": str(max(admission_delays)),
        "mean_completion_latency_ms": (
            f"{sum(completion_latencies) / len(completion_latencies):.3f}"
        ),
        "p95_completion_latency_ms": str(
            nearest_rank(completion_latencies, 0.95)
        ),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run one bounded virtual queue profile."
    )
    parser.add_argument(
        "--profile",
        required=True,
        choices=tuple(PROFILES),
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    result = simulate(PROFILES[args.profile])
    for key, value in result.items():
        print(f"{key}={value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
