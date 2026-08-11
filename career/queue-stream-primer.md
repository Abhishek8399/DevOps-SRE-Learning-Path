# Queues and streams: make delivery semantics explicit

A queue decouples producers and consumers; a retained stream adds replay and partitioned ordering. Both create operational state: offsets, backlog, retries, ownership, and poison work.

```text
producer -> partition/log -> consumer group -> durable effect -> ack/offset
    |           |                 |               |                |
 rate      ordering/retention   ownership       idempotency      progress
```

## Delivery semantics

At-most-once may lose work; at-least-once may duplicate it; “exactly once” is meaningful only across a defined effect boundary. Acknowledge after durable effect, use stable event IDs, and make retries safe. Ordering is usually per partition/key, not global.

## Backlog and rebalancing

Watch oldest-message age, lag, throughput, retry rate, and drain time. Consumer groups trade parallelism for partition ordering and rebalance pauses. Scaling consumers beyond partitions adds no throughput and can increase coordination or downstream pressure.

## Poison messages and replay

A malformed or permanently failing message must leave the main path through a quarantine/dead-letter policy with reason, attempts, and lineage. Replay from retained input only after fixing the effect or schema; otherwise it repeats the outage.

## Safe local exercise

Use a local JSON-lines fixture as a retained log. Partition by key, consume with two worker identities, inject a duplicate and malformed event, quarantine the latter, and replay a bounded range into an idempotent output file. Compare counts, IDs, and checksums; delete only fixtures.

## Triage sequence

1. Identify topic/queue, partition, offset, consumer owner, event age, and effect destination.
2. Separate producer rate, broker/retention, consumer capacity, downstream latency, and poison/retry causes.
3. Pause unsafe consumers or retries while preserving retained input.
4. Quarantine or repair poison work, then drain with bounded concurrency.
5. Verify effects, duplicates, ordering contract, freshness, and replay receipts.

## Interview defense

**Question:** “The queue is healthy but users see duplicate emails. What do you inspect?”

**Strong answer:** “I trace event IDs and consumer acknowledgements to the email effect boundary. At-least-once delivery is expected; the effect needs idempotency or a dedupe record. I check retries, crashes between effect and ack, and provider idempotency before changing broker settings.”

**Question:** “Why did adding consumers not reduce lag?”

**Strong answer:** “I check partition count, rebalance time, downstream capacity, processing time, and retry/poison work. Consumers beyond partitions cannot increase partition parallelism and may amplify dependency pressure.”

## Teach-back checkpoint

State delivery semantics, ordering scope, ack boundary, idempotency key, poison policy, backlog alert, scaling limit, and replay proof for one event workflow.
