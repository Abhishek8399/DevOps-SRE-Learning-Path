# API and distributed systems production interview: an answer is not an outcome

Most distributed failures begin with a reasonable but dangerous sentence: "the request failed." From one caller's view, that can mean the server never received it, accepted it, completed it, completed it twice, or completed it but the caller lost the answer.

```text
caller -> gateway -> service -> queue -> consumer -> datastore -> side effect
   |        |          |         |         |           |            |
timeout  retry      deadline  backlog   duplicate    stale read    customer result
```

The systems question is always the same: **which boundary owns the truth, what can the evidence prove, and how do we recover safely when the outcome is uncertain?**

## Scenario 1: payment-like request timed out, then the customer retries

**Question:** A client times out while creating an order. It retries, and the customer sees two orders. What do you change?

**Strong answer:** A timeout is an unknown outcome, not proof the first create failed. I give the customer operation a stable idempotency key created at the boundary that understands the customer intent. The service stores or atomically reserves that key with a request fingerprint and final/processing result. A repeat with the same compatible intent returns the original result; a repeat using the key for different content is rejected or explicitly handled rather than silently joining two operations.

The decision record must survive process restart and be durable enough for the effect at risk. A memory cache is not sufficient for a payment-like action. I define the key lifetime from product retry behavior and legal/audit requirements, protect it against cross-tenant reuse, enforce request-size and rate limits, and make the response include the operation identity. If the downstream side effect is external, I propagate or map the key where possible and record enough state to reconcile a partial result. I test timeout-after-accept, timeout-after-effect, caller retry, service restart, duplicate delivery, malformed key, conflicting payload, and a late response.

**Weak answer:** "Retry only once." Fewer retries reduce probability; they do not establish exactly-once customer intent.

**Senior follow-up:** Can you promise exactly once? Usually only for a narrowly defined state transition inside one durable authority. Across networks and external systems, state the real contract: at-least-once delivery plus idempotent effect and reconciliation.

## Scenario 2: queue depth rises but consumers look healthy

**Question:** A dashboard shows all consumers running, yet backlog grows for hours. The team wants to add consumers. What do you inspect first?

**Strong answer:** A running process is not evidence of useful throughput. I establish the backlog arrival rate, successful completion rate, age of oldest message, partition or shard distribution, consumer-group assignment, acknowledgement/commit position, retry and poison-message rates, downstream latency, and resource constraints. Backlog grows whenever arrival exceeds durable completion over the relevant window; adding consumers helps only if there is parallelizable work, unassigned capacity, partition headroom, and a downstream that can absorb more requests.

I check for a hot partition, stuck offset, repeated message failure, an external dependency bottleneck, concurrency limit, mis-sized batch, auth failure, or an acknowledgement occurring before durable effect. I preserve the failing message identity and correlation, then choose bounded containment: pause noncritical producers, throttle intake, route a known poison class to an approved quarantine path, or reduce unsafe retries. I do not skip messages or reset offsets simply to make a graph green; that changes the data contract and needs explicit owner approval.

**Weak answer:** "Scale consumers until the queue is empty." That can overload the database, multiply duplicates, or leave one hot partition unchanged.

**Senior follow-up:** What proves recovery? Backlog age and depth trend down under normal arrival, consumer effects reconcile correctly, error/retry rates stay bounded, and a representative produced message reaches its owned outcome. A zero process error count is not enough.

## Scenario 3: an API change breaks only some clients

**Question:** A new optional API field caused failures in a few old clients. How do you handle contract evolution?

**Strong answer:** I identify the actual contract—not just the server schema. That includes client versions, generated SDK behavior, enum handling, null versus absent semantics, unknown-field tolerance, pagination, error shapes, authentication claims, rate limits, and asynchronous callback/event consumers. "Optional" on the server may still break a strict decoder, a signed payload, a cache key, or a downstream schema.

I stop broad expansion and segment affected traffic by client/version/tenant without exposing private data. The safest recovery is often to restore a compatible response shape or gate the new behavior, then publish an explicit versioning and deprecation path. I use contract tests that exercise old and new clients against realistic responses, compatibility review for every producer and consumer, and telemetry that identifies adoption/error rates by stable version dimension. Versioning is an operational rollout, not an endpoint-name decision.

**Weak answer:** "Clients should ignore unknown fields." That is a good compatibility property, but it does not protect clients that cannot implement it or changes to meaning, ordering, defaults, auth, pagination, and events.

**Senior follow-up:** When should you make a new API version? When compatible evolution cannot preserve the old semantic contract safely. A version is not a substitute for ownership, migration communication, limits, test coverage, and retirement evidence.

## Scenario 4: cache has 99% hit rate, but users see incorrect data

**Question:** The cache dashboard is green and cheap, but some customers receive stale authorization or product data. What do you do?

**Strong answer:** Cache hit rate measures reuse, not correctness. I trace authority and invalidation: which system owns the value, which key/version/tenant scope selects it, what event or TTL declares it stale, whether negative entries exist, and whether the cache is allowed to serve stale data for this user operation. Authorization, pricing, inventory, and personalized data have different correctness and safety budgets.

I first contain the risky response path: bypass or shorten cache only for the proven key class and safe capacity envelope, or temporarily fail closed for sensitive authorization decisions rather than returning a potentially permitted result. Then I investigate invalidation delivery, write ordering, replication lag, clock assumptions, key collisions, serialization versions, cache stampede protection, and whether a retry repopulated an old value. The fix makes authority explicit—for example versioned keys, write-through/explicit invalidation with reconciliation, or a bounded TTL plus user-journey verification. I measure miss amplification before globally flushing: a cache flush can turn stale data into a dependency outage.

**Weak answer:** "Clear the whole cache." That may hide the evidence, create a thundering herd, and still permit the same invalidation bug to repopulate incorrect data.

**Senior follow-up:** Is eventual consistency always a defect? No. It is a contract choice. The requirement is to name the staleness bound, conflict behavior, visible user effect, and the flows—such as authorization or irreversible payment—that cannot safely use the stale view.

## Scenario 5: database write succeeded but the event was never published

**Question:** An order was committed, but the event that triggers fulfillment was lost when the service crashed. How do you design the boundary?

**Strong answer:** I do not pretend a database transaction and an independent broker publish are one atomic operation unless the actual technology and failure model prove it. I place the domain change and an outbox record in the same local durable transaction. A separate publisher reads committed outbox rows, publishes with a stable event identity, records/reconciles publishing state, and consumers make their effects idempotent. The outbox converts an unsafe dual write into a recoverable delivery pipeline; it does not create global exactly-once magic.

I define ordering, partition key, schema version, retry policy, retention, dead-letter/quarantine ownership, and replay procedure. I monitor outbox age and unprocessed count, not merely publish calls. If fulfillment is delayed, I can identify the committed order, the outbox row, publisher attempt, broker acknowledgment, consumer offset, and effect record. Recovery replays from the authoritative durable record and verifies no duplicate customer outcome.

**Weak answer:** "Publish first, then write the database." That just reverses the inconsistency: consumers may act on an order that never committed.

**Senior follow-up:** Why must consumers be idempotent if the publisher has an outbox? Publishing acknowledgement may be lost, consumers may restart, and replay is necessary for recovery. Delivery can repeat even when the producer is carefully designed.

## Scenario 6: one region is slow and retries amplify the incident

**Question:** A dependency in one region becomes slow. Clients retry across regions and the healthy region begins failing too. How do you stabilize it?

**Strong answer:** I treat retries as extra demand, not free availability. I establish the end-to-end deadline, per-hop timeout budget, current retry rate, retryable classification, concurrency, queue depth, dependency saturation, regional routing policy, and customer impact. A caller must have a deadline that leaves time for meaningful work; every nested dependency cannot independently spend the whole user timeout and retry several times.

I stop the amplification with bounded controls: cap attempts, add jitter, fail fast for proven dependency overload, limit concurrency, shed or degrade noncritical functions, and route only traffic that the alternate region can safely absorb. I do not blindly fail over stateful or affinity-sensitive writes. The recovery plan separates reads from writes, identifies replication/consistency assumptions, and verifies the customer operation after routing changes. Longer term, I set retry budgets, bulkheads, circuit behavior with safe probes, capacity reservations, and load tests that include partial dependency latency—not only complete failure.

**Weak answer:** "Increase the timeout and retry count." That holds resources longer and can convert slow service into full saturation.

**Senior follow-up:** What is a retry budget? A bounded amount of additional attempt traffic allowed relative to successful work. It makes the cost of retries visible and prevents resilience logic from becoming the dominant load during degradation.

## Fast decision map

| When you see this | Remember | First safe move |
|---|---|---|
| timed-out create | Unknown is not failed | Reconcile by stable operation identity before creating again |
| growing backlog | Process health is not useful throughput | Measure arrival, completion, age, partition skew, and effect safety |
| selective client breakage | Server schema is not the whole contract | Segment by version and restore/gate compatible behavior |
| green cache, wrong answer | Hit rate is not correctness | Trace authority, key scope, invalidation, and staleness contract |
| database/event mismatch | Dual writes need recovery design | Use a durable local outbox and idempotent consumers |
| regional slowness | Retries spend capacity | Cap/reclassify retries and enforce an end-to-end deadline |

## Practice: speak in boundaries

For any incident, say these five things before suggesting a command:

1. the customer operation and authoritative state;
2. whether the current result is success, failure, or unknown;
3. the next evidence and what it cannot prove;
4. the smallest reversible containment; and
5. the durable reconciliation and prevention change.

That habit is what makes a distributed-systems answer reliable. It prevents the most expensive mistake in operations: declaring certainty just because one component returned a response.
