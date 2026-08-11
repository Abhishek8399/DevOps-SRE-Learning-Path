# Data pipeline reliability: preserve meaning across time

Data systems fail by losing, duplicating, delaying, reordering, corrupting, or misinterpreting records. Reliability means the downstream result is complete, correct enough for its contract, explainable, and recoverable.

```text
source -> ingest -> durable log/checkpoint -> transform -> quality -> serving
   |        |              |                   |           |          |
schema   offset        replay point          version     quarantine  lineage
```

## Contracts and lineage

Define event identity, schema/version, ordering, lateness, required fields, privacy, retention, and ownership. Record where a dataset came from, which code and configuration produced it, what inputs and windows were used, and which validation passed. A timestamp is not lineage.

## Batch versus stream

Batch recomputes a bounded window; stream processing handles ongoing events with checkpoints, watermarks, partitions, and replay. Both need a clear boundary for completeness. “Processed successfully” can still mean a late partition, duplicate event, or silently dropped record.

## Checkpoints and replay

A checkpoint records progress, not necessarily durable output. Commit offsets only after the effect is durable, make writes idempotent, and retain enough input to replay. Schema and code changes require compatibility or a new output version; replaying old data through new logic can change history.

## Quality and quarantine

Measure freshness, completeness, validity, uniqueness, distribution drift, and referential integrity. Quarantine bad records with reason and lineage instead of silently dropping them. Alert on user-impacting freshness or quality thresholds and define backfill ownership.

## Safe local exercise

Use a small CSV event fixture with duplicates, a late row, a malformed record, and a schema version. Build a local transform that deduplicates by event ID, checkpoints after durable output, quarantines invalid rows, and replays a window. Compare output checksum and lineage before and after replay. Delete only the fixture.

## Triage sequence

1. Identify source window, schema version, partition/offset, checkpoint, and downstream consumer.
2. Compare expected versus observed count, freshness, duplicates, late data, and quarantine volume.
3. Stop unsafe publication; preserve raw input and lineage.
4. Choose replay, backfill, or forward correction with idempotent effects.
5. Validate downstream user decisions and record the recovery boundary.

## Interview defense

**Question:** “How do you recover after a consumer crash?”

**Strong answer:** “Resume from a durable checkpoint or retained input, process with idempotent effects, commit progress only after durable output, and verify counts, duplicates, freshness, and downstream correctness. I do not claim exactly-once delivery without defining the effect boundary.”

**Question:** “Why quarantine bad records?”

**Strong answer:** “Silent drops destroy completeness and make recovery invisible. Quarantine preserves the record, reason, lineage, and owner so the pipeline can continue safely while backfill or correction is planned.”

## Teach-back checkpoint

Design a pipeline contract. State event identity, schema evolution, checkpoint boundary, replay window, quality checks, quarantine behavior, privacy/retention rules, and the evidence proving a backfill is complete.
