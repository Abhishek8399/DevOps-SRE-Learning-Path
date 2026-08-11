# Distributed systems: reason from partial failure

Distributed systems are not “one big computer.” They are several computers that must coordinate while networks delay, packets disappear, clocks disagree, and processes fail independently.

```text
request -> API -> queue -> worker -> database
   |         |       |        |          |
 timeout   retry   backlog  duplicate  stale read
```

## The mental model

Whenever a request crosses a process or machine boundary, assume the answer can be delayed, duplicated, reordered, or lost. A timeout means “I do not know,” not “the operation definitely failed.” That single sentence prevents unsafe retries and duplicate payments.

## The five questions to ask

1. **Who owns the truth?** Identify the authoritative store and fields that must be consistent.
2. **What is the failure boundary?** Separate client, network, process, node, zone, and data-store failures.
3. **What happens after a timeout?** Decide whether the operation is safe to retry, needs an idempotency key, or requires reconciliation.
4. **Where does pressure accumulate?** Measure queue depth, age, concurrency, latency, connection pools, and storage growth.
5. **How do we recover?** Define replay, deduplication, backfill, rollback, and operator visibility before an incident.

## Consistency without magic words

Strong consistency makes a read reflect the latest committed write according to the system contract, usually with more coordination and latency. Eventual consistency allows replicas or projections to converge later. Choose per workflow.

```text
write order:  A -> B -> C
strong read:  every reader observes A,B,C in that order
eventual:     reader 1 may see A, reader 2 may see A,B; both converge
```

Write the invariant first: “a charge is captured at most once,” “inventory never becomes negative,” or “search may lag the catalog by 30 seconds.” Then select transactions, version checks, an outbox, or reconciliation that protects it.

## Retries, idempotency, and backpressure

Retries convert a transient failure into more traffic. Use bounded attempts, exponential backoff with jitter, deadlines, and a retry budget. A state-changing request needs an idempotency key or deduplication record so a retry cannot create a second effect.

```text
healthy:  producer -> bounded queue -> worker -> ack
overload: producer -> unbounded queue -> memory full -> outage
safe:     producer <- 429/backoff, queue limit, worker drains steadily
```

Backpressure is the system asking the caller to slow down. Alert on queue age and oldest message, not only length. A short queue of very old work can be worse than a long queue of fresh work.

## Time and ordering

Wall clocks can jump because of NTP, VM pause, or timezone mistakes. Use monotonic time for durations and deadlines. Use request IDs, event IDs, sequence numbers, or logical versions for ordering. Do not infer causality solely from timestamps produced by different hosts.

## Caches and failure modes

A cache is a second copy, not the source of truth. Decide TTL, invalidation, stale-read tolerance, stampede protection, and behavior when the cache is unavailable. A cache miss during an outage can overload the database; bounded concurrency and request coalescing protect the origin.

## Safe local exercise

Run two local processes that append numbered events to a file-backed queue. Kill the worker between “process” and “ack,” restart it, and observe the duplicate. Add an event-ID set, rerun the same failure, and prove the result is processed once. Record commands, failure window, evidence, and cleanup in an evidence file; use no production data.

## Production triage sequence

1. Establish the user symptom and time window.
2. Compare request rate, error rate, latency, queue age, saturation, and dependency health.
3. Check whether timeouts represent unknown outcomes; pause unsafe retries.
4. Protect the dependency with rate limits, circuit breaking, or feature reduction.
5. Reconcile ambiguous writes before declaring recovery.
6. Preserve IDs and timelines for the post-incident review.

## Interview defense

**Question:** “A payment API timed out; would you retry?”

**Strong answer:** “First I determine whether the timeout is before or after the provider could have committed. I retry only with the same idempotency key, a deadline, bounded jittered attempts, and reconciliation. I watch duplicate rate, provider errors, queue age, and customer-visible state. If the outcome is unknown, I expose a pending state rather than charging twice.”

**Question:** “How do you scale a queue worker?”

**Strong answer:** “Scale from oldest-message age and service time, bounded by downstream capacity and connection limits. Add consumers gradually, preserve ordering where required, use a poison-message path, and verify retries do not create a feedback loop.”

## Teach-back checkpoint

Explain without notes why a timeout is not proof of failure; how idempotency prevents duplicate effects; and why unbounded queues hide overload. Then change one assumption: the database is healthy but the network is partitioned. State which evidence changes, what you contain first, and how you reconcile after recovery.
