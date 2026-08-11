# Data systems: protect truth, throughput, and recovery

Databases are where user intent becomes durable state. Treat them as part of the reliability boundary, not as a black box behind the application.

```text
client -> API -> transaction -> primary
                    |             |
                 outbox       replica/read model
                    |             |
                  queue -> worker -> cache/search
```

## Start with the invariant

Before choosing PostgreSQL, Redis, a queue, or a stream, write the rule that must never be violated: a payment is captured once, an order has one owner, or a balance cannot become negative. Then identify the authoritative writer, transaction boundary, consistency requirement, and recovery evidence. “It is in the database” is not enough if a replica, cache, search index, or downstream projection can disagree.

## Transactions and locks

A transaction groups changes so readers do not observe an invalid intermediate state. Isolation controls which concurrent changes a transaction may observe. Locks prevent conflicting work, but long transactions consume connections, retain old row versions, and can block progress. During an incident, inspect transaction age and blocking relationships before killing a session; the oldest blocker may be the root cause, but terminating it can roll back valuable work.

```text
T1: read stock=1 ---- update stock=0 ---- commit
T2: read stock=1 ---- waits or conflicts -------- commit
```

The safe design depends on the invariant: a conditional update, row lock, optimistic version, or serializable retry may be appropriate. Never increase isolation or lock scope blindly; measure contention and retry behavior.

## Indexes are a trade-off

An index can reduce reads but adds write cost, memory pressure, storage, and maintenance. A plan that looks fast for ten rows may fail at ten million. Compare the query predicate, ordering, selectivity, returned columns, and actual rows—not only estimated cost. A missing index is not proven until the slow query, plan, and workload are correlated.

## Replicas, caches, and queues

Replicas can lag. A read-after-write user journey must either read from the writer, wait for a known position, or show a pending state. A cache can serve stale data or stampede the origin. A queue decouples work but introduces backlog, duplicate delivery, poison messages, and replay obligations.

```text
producer --event(id)--> durable queue --at-least-once--> consumer
                                |                         |
                         retry/dead-letter          idempotent write
```

At-least-once delivery is often the honest contract. Make the consumer idempotent with an event ID, unique constraint, or processed-event record. “Exactly once” usually means carefully bounded effects, not magical network delivery.

## Backup is not recovery

A backup proves only that bytes were copied. Recovery requires a usable artifact, correct ordering, credentials, schema compatibility, writer fencing, a measured restore time, and a user-visible validation. Define RPO (maximum acceptable data loss) and RTO (maximum acceptable restoration time) for a workflow, then test them in an isolated environment.

## Safe local exercise

Use a disposable SQLite database. Create an orders table with a unique idempotency key, a processed-events table, and an outbox table. Run a script that inserts an order and its outbox event in one transaction. Re-run the same event twice and prove the unique constraint prevents a duplicate effect. Copy the database, restore it to a new path, run an integrity check, and record the evidence. Do not use production files.

## Triage sequence

1. Name the affected user operation and its authoritative state.
2. Separate connection exhaustion, lock contention, slow execution, storage pressure, replication lag, and downstream backlog.
3. Capture query/transaction IDs, age, wait state, and safe read-only metrics.
4. Protect the database: shed optional work, bound concurrency, pause unsafe consumers, or route reads deliberately.
5. Reconcile caches, replicas, queues, and outbox records after recovery.
6. Validate the user journey, not merely database process health.

## Interview defense

**Question:** “A replica is healthy but users report missing updates. What do you check?”

**Strong answer:** “I compare the writer commit position with replica replay position and map the affected read path. I check whether the journey requires read-after-write, then route that path to the writer or expose a pending state within an explicit budget. I avoid declaring the replica broken until lag, freshness, and application behavior are correlated.”

**Question:** “How do you make a queue consumer safe to retry?”

**Strong answer:** “Give each event a stable ID, make the state change atomic with its deduplication record or enforce a unique constraint, acknowledge only after durable success, and isolate poison messages. I measure duplicate attempts, age, retries, and downstream capacity.”

## Teach-back checkpoint

Explain why a backup is not proof of recoverability, why a replica can be healthy yet stale, and how an idempotency key changes a retry from a duplicate write into a safe replay. Then choose one invariant and name the authoritative writer, evidence, containment, and restore validation.
