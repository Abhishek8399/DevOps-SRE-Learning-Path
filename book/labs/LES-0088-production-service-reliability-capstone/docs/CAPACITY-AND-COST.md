# Capacity, performance and cost model

## First-order concurrency

Little's Law provides a consistency check:

```text
concurrency = arrival rate * mean time in system
at 20 requests/second and 0.25 seconds: 20 * 0.25 = 5 concurrent requests
at 100 requests/second and 0.25 seconds: 100 * 0.25 = 25 concurrent requests
```

This is not a benchmark. The service uses threads, a single SQLite file and an immediate transaction for creates. Read concurrency, write lock time, CPU, file descriptors and storage latency must be measured together. Increasing thread count can increase queueing and lock contention rather than capacity.

## Required experiment

Run at least three repeated load points after warm-up, preserve raw samples, record hardware/runtime versions, compare p50/p95/p99, throughput, errors, CPU, memory, open descriptors, database lock failures and file growth. Find the knee where latency or errors grow nonlinearly. Repeat with writes and with a recovery operation. Stop before host instability.

The included loader is capped at 1,000 requests and concurrency 32. It is a functional sampler, not a high-scale load generator.

## Storage growth

Estimate item and idempotency-key growth separately:

```text
daily rows = accepted writes/second * 86,400
raw annual bytes = daily rows * average bytes/row * 365
provisioned bytes = raw data + indexes + WAL + free space + backups + telemetry
```

Retention is deliberately unresolved. Idempotency keys cannot grow forever in a real service, but expiry must not allow a late retry to duplicate a still-material operation.

## Cost boundary

Local Docker has no cloud invoice, but it still consumes CPU, memory, disk, network and engineer time. A real cost model must include compute, persistent storage, backup copies, telemetry cardinality/retention, transfer, CI minutes, certificates, incident labor and idle reserve. Optimize only after linking cost to a user or reliability outcome; deleting recovery copies to make a storage chart green is not FinOps.
