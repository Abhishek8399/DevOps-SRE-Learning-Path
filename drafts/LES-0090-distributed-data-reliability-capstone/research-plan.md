# LES-0090 research and implementation plan

## Identity and purpose

- Lesson: `LES-0090`
- Public alias: `V11-L03`
- Curriculum: `CAP-003`
- Route: `/book/capstones/distributed-data-reliability-capstone`
- Prerequisite: `LES-0089`
- Assessments: reserve `ASM-0253` through `ASM-0255`
- References: reserve `REF-1140` through `REF-1159`

The capstone must connect transactional correctness, asynchronous delivery and analytical correctness. It is not a catalogue of PostgreSQL, Redis, Kafka, Spark or Flink commands.

## User operation

```text
submit order with idempotency key
  -> commit order + outbox atomically
  -> relay immutable event identity
  -> append to retained partitioned log
  -> consume at least once
  -> claim inbox identity + apply materialized effect atomically
  -> refresh derived cache
  -> produce quality-checked analytical output and lineage receipt
  -> reconcile source, event, effect, cache and analytical counts
```

The success claim is not “message consumed.” It is: one accepted order has one authoritative business effect, its event remains traceable and replayable, derived views converge, and every exclusion or quarantine is visible.

## State and ownership model

| State | Intended authority | Loss/recovery path |
|---|---|---|
| order and idempotency record | PostgreSQL transaction | database backup/restore plus business reconciliation |
| outbox publication intent | same PostgreSQL commit | relay retries from unpublished rows |
| retained event and partition offset | Kafka-compatible log | broker replication/retention and controlled replay |
| consumer inbox and business effect | PostgreSQL transaction | duplicate-safe replay and reconciliation |
| serving cache | Redis-derived state | invalidate/rebuild from authoritative store |
| analytical run/output | versioned local batch artifact | isolated rerun from immutable input interval |
| lineage/quality receipt | append-only project evidence | reproduce from source/run/dataset identities |
| runtime telemetry | bounded observability store | operational evidence, not business authority |

## Planned local boundary

Use Docker Compose on one laptop with loopback-only published ports and fixed project names. Prefer official, checksum/digest-pinned images and small Python clients. The candidate topology is:

- PostgreSQL for orders, idempotency, outbox, inbox/effects and restore evidence;
- one Kafka-compatible local broker for retained delivery semantics;
- Redis used only as a disposable cache with bounded memory and explicit eviction;
- Python API/relay/consumer/batch/reconciler components with strict schemas and structured evidence;
- Prometheus-compatible metrics or deterministic exported samples for request, relay, consumer, lag, quarantine, quality and reconciliation paths.

A single local broker/database/cache cannot prove quorum availability, distributed failure domains or production throughput. Real Spark/Flink/Iceberg transfer may be documented and separately assessed unless a bounded runtime stage fits the final resource/safety budget.

## Required failure matrix

1. Duplicate API request with the same key and same payload returns the original outcome.
2. Same key with a different payload is rejected as conflict.
3. Relay crashes after publish but before outbox acknowledgement; duplicate delivery does not duplicate effect.
4. Consumer crashes after effect but before offset commit; replay is harmless.
5. Poison or incompatible event is quarantined with source identity and does not block unrelated partitions indefinitely.
6. Slow consumer creates measurable backlog; drain-rate and catch-up-capacity arithmetic are explicit.
7. Hot key or partition skews work; aggregate averages must not hide the maximum.
8. Redis eviction or restart creates misses but not lost business state.
9. Analytical quality gate rejects incomplete/duplicate/schema-invalid output before promotion.
10. Database restore and event replay use an isolated target, reconcile counts/hashes and never overwrite the only active copy.

## Safety gates

- refuse root, default production contexts, host-network mode, public binds and unreviewed downloads;
- use project-local names, loopback ports, bounded CPU/memory/storage and exact cleanup;
- never embed a real credential or customer record;
- record image digests, source revision, schema version, topic/partition/offset and database transaction identities;
- stop on identity mismatch, unexpected container/volume/network or broad cleanup target;
- do not use `docker system prune`, wildcard deletion or in-place destructive restore;
- preserve the first meaningful failure and use recovery traps only for the named fixture.

## Source plan

Lock twenty primary or official records across:

- PostgreSQL isolation, WAL and point-in-time recovery;
- Kafka architecture, delivery semantics, consumers, KRaft and authorization;
- Redis eviction, persistence, replication and security;
- Flink checkpoint/state/backpressure and Spark Structured Streaming transfer;
- Iceberg snapshots/concurrency/evolution;
- OpenTelemetry messaging semantics, Prometheus instrumentation/alerting;
- OpenLineage run/job/dataset identity and OWASP security logging.

Fast-moving references receive a three-month review window. General standards receive no more than six months. Image tags and digests are recorded separately from documentation versions.

## Acceptance boundary

The repository candidate may be called substantive only after direct schemas, static checks, guarded absent-to-absent runtime, fault/recovery matrix, exact cleanup, canonical content/schema/reader/lint/type/build and hygiene pass. It remains quarantined until formal review and independent hidden-fault transfer.

No fixture output awards learner mastery or production experience.
