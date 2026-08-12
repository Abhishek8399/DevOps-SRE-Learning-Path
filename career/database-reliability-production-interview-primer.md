# Database reliability production interview: protect correctness before restoring speed

For a database incident, “the database is up” is weak evidence. You need to know which writer is authoritative, whether committed data is durable, whether reads are fresh enough, and whether the next action can make data loss or corruption worse.

```text
client -> pool -> primary writer -> transaction log -> replica/backup -> restore or read path
  |         |           |                 |                |                 |
timeout  saturation   authority       durability        freshness        recovery proof
```

## Scenario 1: connection pool exhaustion

**Question:** Application errors say “too many connections,” while database CPU is 25%. Do you increase the connection limit?

**Strong answer:** I establish active, idle and waiting connections by client identity; pool size/minimum/timeout; transaction duration; lock waits; slow queries; deployment changes; and database memory/file-descriptor limits. Low CPU does not mean the database is unconstrained: connections consume memory and can be held by an application, a leaked transaction, a slow dependency or lock contention. I contain by reducing known unsafe concurrency, pausing a bad rollout or shedding noncritical work under the incident authority. I correct the owner: close leaked paths, bound pools per process, reduce query/transaction duration, fix lock contention or scale the appropriate database capacity after evidence. I verify user transactions, pool wait time, error rate and database health. Prevention is a connection budget shared across replicas/processes, lifecycle tests, pool telemetry and alerting on wait/held-transaction age—not only CPU.

**Weak answer:** “Set max connections to a huge number.” That may convert a controlled rejection into memory pressure, scheduler collapse or a longer recovery.

**Senior follow-up:** Why is each pod having a small pool still risky? Many replicas multiply it. A pool of 20 across 100 pods can demand 2,000 connections before admin and maintenance traffic.

## Scenario 2: a query becomes slow after a data-growth event

**Question:** A page that used to take 100 ms now takes 12 seconds. What is your evidence path?

**Strong answer:** I capture the normalized query shape and parameters, execution plan, estimated versus actual rows, index/constraint state, statistics freshness, lock/wait events, buffer/cache behavior, data distribution and a healthy comparison. I check whether the query changed, a predicate became unselective, a join multiplied rows, an index is absent/unused, statistics are stale, or another workload is saturating I/O. I test a candidate improvement on a representative safe dataset or read-only plan first. An index is a write/storage/maintenance trade-off, not an automatic fix; I confirm it improves the actual workload and does not break write objectives. I use a bounded rollout and validate p50/p95/p99 plus error/load effects. Prevention is query review, explain-plan baselines for critical paths, distribution-aware indexes, data-retention/archival policy and capacity forecasts.

**Weak answer:** “Restart the database.” Restarting may briefly clear cache or cancel work but loses diagnostic state and does not fix data shape or query logic.

**Senior follow-up:** Why compare estimated and actual row counts? A major difference often reveals that statistics or assumptions about correlation/selectivity are wrong, which can make the optimizer choose a poor plan.

## Scenario 3: replication lag during an incident

**Question:** Read replicas are 20 minutes behind. Can you keep serving reads from them to protect the primary?

**Strong answer:** I first classify every read by freshness/correctness requirement. A stale product catalog may be acceptable with explicit policy; account balance, authorization, recently written order status or a security decision may not be. I identify replication mechanism, current replay position/time, apply errors, primary write rate, WAL/log retention, replica I/O/CPU/storage, long transactions, schema changes and failover eligibility. I route only approved stale-tolerant traffic with observability and a clear user contract; I do not silently make critical decisions on stale data. I remove the actual lag cause and protect the primary from uncontrolled retries. If promotion is contemplated, I verify data-loss boundary, fencing, client routing, recovery objective and authority. Recovery includes a bounded freshness measurement and reconciled critical paths, not merely a replica process running.

**Weak answer:** “All reads can use replicas.” That confuses availability optimization with correctness policy.

**Senior follow-up:** What can lag time fail to show? A replica can report a small time difference while missing a specific transaction, stopped on an error, or applying a workload with a different customer impact; use positions and workload evidence too.

## Scenario 4: a migration blocks production traffic

**Question:** A schema migration is waiting on a lock and requests are timing out. Do you kill sessions?

**Strong answer:** I identify the exact migration, lock mode, blocker/waiter transaction identities and ages, application versions, rollback compatibility, customer impact and change authority. I do not kill sessions blindly: the blocker may be a critical write, and the migration may be non-transactional or leave an incompatible intermediate state. I contain by pausing further migration steps and unsafe deploy progression, choose the smallest authorized cancellation/rollback/feature-disable action, and validate application/database compatibility. For future changes I use expand/contract: add compatible structures, deploy code tolerant of both forms, backfill in bounded batches, validate, then remove old fields later. I measure lock duration, query effect and data integrity. Prevention is migration review, lock/statement timeouts, rehearsal against realistic data, deployment gates and a documented forward/rollback decision.

**Weak answer:** “Restore the database.” Restore discards valid post-backup writes and is not a normal response to a lock conflict.

**Senior follow-up:** Why is roll-forward often safer? Once new data has been written in a new shape, reverting code/schema may be less safe than completing a compatible corrective change with reconciliation.

## Scenario 5: backup exists but restore is unproven

**Question:** The team says RPO is one hour because backups run hourly. What do you challenge?

**Strong answer:** A scheduled backup proves at most that a job attempted to create an artifact. I ask which data is covered, completion/consistency, encryption/key access, retention/immutability, offsite/account boundary, restore authorization, point-in-time logs, dependency/configuration capture, restore duration and the last independently verified restore. RPO is the maximum accepted data loss, measured from a real recovery point; RTO is the time to restore a usable user journey. I run or review a controlled restore into isolated infrastructure, verify integrity and application-level reads/writes, measure elapsed time and document the gaps. I never “test restore” by overwriting the production database. Prevention is automated restore drills, restore receipts, ownership, monitored backup freshness/failure, and recovery objectives tied to business-approved data classes.

**Weak answer:** “The backup file is in object storage.” It may be incomplete, unreadable, unauthorized, missing logs/keys, too slow, or incompatible with the current version.

**Senior follow-up:** What does a successful checksum prove? Bytes were copied consistently according to that checksum; it does not prove the database can start, recover, meet RPO/RTO, or serve the intended application version.

## Scenario 6: suspected data corruption or accidental deletion

**Question:** A job may have deleted records incorrectly. How do you avoid making it worse?

**Strong answer:** I stop/fence the unsafe writer through the approved path, preserve audit/log/transaction evidence and establish affected table/keys/time/version/actor plus the authoritative correction source. I distinguish soft-delete, logical mistake, replication propagation, physical corruption and visibility/permission issue before proposing recovery. I take an approved consistent snapshot if policy allows, build the repair in an isolated environment or transaction, compare candidate restored records with authoritative evidence and get required owner approval. Point-in-time recovery can restore a whole instance to a time, but using it naively can erase unrelated valid writes; targeted repair/reconciliation is often safer. I verify counts, relationships, downstream projections and user journeys after repair. Prevention is least-privilege write paths, dry-run/guardrails, immutable audit, soft-delete/retention where appropriate, canary/batch limits and tested repair runbooks.

**Weak answer:** “Run the delete inverse.” The original predicate, data history and downstream effects may not be reversible, and a second broad write can compound the incident.

**Senior follow-up:** Why preserve evidence before cleanup? The evidence identifies scope, causality, recovery source and compliance obligations. Deleting it can prevent a safe repair and repeat prevention.

## Database response map

1. Establish authority, durability and the affected data/time boundary.
2. Separate connection, query, lock, storage, replication and correctness symptoms.
3. Preserve evidence and contain the smallest unsafe writer or load amplifier.
4. Choose a reversible, compatible correction with explicit ownership.
5. Verify transactions and data invariants—not just process health.
6. Record the limit, monitor, rehearsal and runbook that would shorten the next response.

That discipline is what lets you recover a database incident without turning it into a data-loss incident.
