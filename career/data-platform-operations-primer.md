# Data-platform operations: protect truth from ingestion to insight

Data reliability is more than a job finishing. The result must be complete enough, fresh enough, correctly interpreted, traceable to its inputs, and safe to replay when something fails.

```text
sources -> ingest -> durable log/lake -> transform -> catalog/schema
   |         |             |              |             |
contract  lag/loss      retention      checkpoint    lineage
                                      |
                           batch/stream serving -> user/ML decision
                                |       |                 |
                            freshness  quality         outcome
```

## Know each plane

* **Ingestion:** contracts, offsets, partitions, duplicates, late data, poison records, and backpressure.
* **Storage/lakehouse:** immutable objects, table metadata, snapshots, schema evolution, compaction, retention, and small-file economics.
* **Compute:** Spark/Flink-style task attempts, checkpoints, watermarks, shuffle, skew, retries, and resource queues.
* **Query/serving:** Trino/Pinot-style latency and freshness trade-offs, indexes/segments, replicas, cache, and admission limits.
* **Orchestration:** Airflow-style DAG identity, schedule/data interval, retries, backfills, dependencies, and false-green prevention.
* **Catalog/governance:** ownership, lineage, classification, access, quality expectations, and deprecation.

The key identity is often `(dataset, partition, interval, code/version)`, not merely a task name. Without that identity, a retry or backfill can overwrite the wrong result or make a stale result look current.

## Freshness is a contract

Define freshness, completeness, correctness, and availability separately. A dashboard can be available while showing yesterday’s data. A stream can be fresh while missing a partition. Alert on user impact and distinguish source delay, processing lag, watermark delay, serving staleness, and query failure.

## Replay without corruption

Make transformations idempotent or write to versioned outputs, checkpoint progress, quarantine bad records, and reconcile counts/checksums or business invariants. A backfill should be isolated from the live path, have bounded concurrency and cost, and publish only after validation. “Just rerun the DAG” is unsafe when side effects, non-deterministic inputs, or mutable tables exist.

## Safe local exercise

Use newline-delimited JSON or CSV as a tiny source and build a shell/Python pipeline with a schema check, durable raw copy, checkpoint, quarantine file, aggregate, and quality report. Inject a duplicate, malformed record, late partition, and partial write. Replay the interval and prove the output is unchanged or explain the reconciliation. Label the pipeline as a local model; do not claim Spark, Flink, Trino, Iceberg, Airflow, or Cassandra behavior unless those runtimes are actually exercised.

## Triage sequence

1. Identify the user decision, dataset/table/stream, interval, code/schema version, and freshness/correctness symptom.
2. Check source arrival, offsets/partitions, backlog, task attempts, checkpoints, watermark, storage metadata, and serving cache/index state.
3. Separate missing, late, duplicated, malformed, and incorrectly interpreted data.
4. Stop unsafe publication, quarantine the affected slice, and isolate backfill from live traffic.
5. Reconcile counts/invariants and validate the downstream user or ML outcome before reopening publication.

## Interview defense

**Question:** “How do you make a data pipeline reliable?”

**Strong answer:** “I define dataset and interval identity, schema and ownership, freshness/completeness/correctness indicators, durable raw inputs, idempotent or versioned outputs, checkpoints and bounded retries, quarantine and replay, lineage, access controls, and a publish gate. I validate the consumer outcome, not just task success.”

**Question:** “Why did a successful backfill make the dashboard wrong?”

**Strong answer:** “Task success did not prove the correct interval, schema, or publication authority. I check partition identity, late/duplicate data, code and snapshot versions, serving caches/indexes, and reconciliation invariants, then republish only a validated version.”

**Question:** “How do you control data-platform cost?”

**Strong answer:** “Measure cost per useful dataset or decision, control small files and scan volume, bound backfills and shuffle/concurrency, tier retention, and enforce ownership and quotas. I preserve required freshness, recovery, and quality rather than deleting evidence blindly.”

## Teach-back checkpoint

Design a daily-plus-streaming pipeline. Name the dataset identity, freshness/completeness/correctness SLIs, checkpoint, replay boundary, quarantine path, publication gate, lineage owner, consumer outcome, and cost control. Explain how you would recover from a late or duplicated partition without corrupting the live result.
