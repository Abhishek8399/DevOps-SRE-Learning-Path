#!/usr/bin/env python3
"""Bounded loopback request sampler that emits one JSON record per request."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import http.client
import json
import time
from urllib.parse import urlsplit


def sample(host: str, port: int, path: str, timeout: float, sequence: int) -> dict[str, object]:
    started = time.monotonic()
    status = 0
    error = None
    try:
        connection = http.client.HTTPConnection(host, port, timeout=timeout)
        connection.request("GET", path, headers={"X-Request-ID": f"load-{sequence:05d}"})
        response = connection.getresponse()
        response.read()
        status = response.status
        connection.close()
    except OSError as exc:
        error = type(exc).__name__
    duration = time.monotonic() - started
    return {
        "sequence": sequence,
        "status": status,
        "success": 200 <= status < 300,
        "latency_seconds": round(duration, 9),
        "error": error,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", default="http://127.0.0.1:8080/api/v1/items")
    parser.add_argument("--requests", type=int, default=100)
    parser.add_argument("--concurrency", type=int, default=4)
    parser.add_argument("--timeout", type=float, default=2.0)
    args = parser.parse_args()
    target = urlsplit(args.url)
    if target.scheme != "http" or target.hostname not in {"127.0.0.1", "::1", "localhost"}:
        raise SystemExit("load: refusal: target must be loopback HTTP")
    if not 1 <= args.requests <= 1000:
        raise SystemExit("load: refusal: --requests must be 1..1000")
    if not 1 <= args.concurrency <= 32:
        raise SystemExit("load: refusal: --concurrency must be 1..32")
    if not 0.05 <= args.timeout <= 10:
        raise SystemExit("load: refusal: --timeout must be 0.05..10 seconds")
    port = target.port or 80
    path = target.path or "/"
    with ThreadPoolExecutor(max_workers=args.concurrency) as executor:
        futures = [
            executor.submit(sample, target.hostname, port, path, args.timeout, sequence)
            for sequence in range(1, args.requests + 1)
        ]
        records = [future.result() for future in as_completed(futures)]
    for record in sorted(records, key=lambda value: value["sequence"]):
        print(json.dumps(record, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    main()
