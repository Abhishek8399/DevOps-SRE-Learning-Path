# SQL and PostgreSQL: protect invariants under concurrency

A database is a concurrency and durability system, not just a place to store rows. Start with the invariant, transaction boundary, access pattern, and recovery contract.

```text
request -> pool -> transaction -> query plan/locks -> WAL/storage -> commit -> response
   |        |           |               |                 |            |
 deadline  budget      invariant      wait/scan          durability   evidence
```

## Plans and indexes

Read the actual execution plan and compare estimated versus actual rows, join choice, scan, sort, memory, and I/O. An index helps a predicate and ordering only when selectivity, write cost, storage, and maintenance justify it. Never tune from query text alone.

## Transactions and locks

Choose isolation for the invariant. Keep transactions short, access shared rows in a consistent order, and understand lock waits and deadlocks. A retry after a serialization or deadlock error must be bounded and safe; retrying a non-idempotent external effect inside a transaction can duplicate it.

## Connection pools and saturation

Pool size is a concurrency budget shared by callers, not a free performance knob. Too many connections increase memory, context switching, lock contention, and downstream pressure. Observe acquisition wait, active/idle, transaction age, and database saturation.

## Durability and replication

Commit acknowledgement has a defined durability/replication meaning. A healthy replica can lag; a backup can be valid but untested. Define read-after-write behavior, failover authority, writer fencing, and restore evidence.

## Safe local exercise

Use SQLite or an approved local PostgreSQL fixture. Create a table with a unique invariant, run concurrent fixture transactions, inspect query behavior, force a duplicate or lock timeout, and verify the safe failure. Capture a logical backup and restore into a new directory; delete fixtures only.

## Triage sequence

1. Identify user operation, query, transaction age, pool wait, lock owner, and database boundary.
2. Compare latency/error distributions, plan, rows, I/O, CPU, locks, connections, and replication lag.
3. Protect the database by bounding work and pausing optional consumers.
4. Change one query/index/transaction or route with rollback and correctness checks.
5. Verify user journey, invariant, durability, replica freshness, and recovery evidence.

## Interview defense

**Question:** “The database CPU is low but requests are slow. Why?”

**Strong answer:** “I check pool acquisition, lock waits, I/O latency, plan regressions, network/dependency time, and transaction age. CPU is one signal; I locate the first delayed boundary and correlate query, wait, and user evidence.”

**Question:** “Why did an index make writes worse?”

**Strong answer:** “Every write maintains the index, consuming I/O, memory, and vacuum/compaction work. I verify selectivity and workload benefit, compare plans and write latency, and remove or redesign it only through a measured, reversible change.”

## Teach-back checkpoint

Design a transaction for one invariant. State isolation, lock order, index, pool budget, retry rule, replication/read behavior, backup/restore proof, and the evidence that proves correctness under concurrency.
