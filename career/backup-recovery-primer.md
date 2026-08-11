# Backup and recovery: prove the path, not the checkbox

Continuity is a user outcome. Backups, replicas, standby systems, and runbooks are only components of a recovery path until an isolated test proves data and service correctness.

```text
write -> durable source -> protected copy -> isolated restore -> fenced writer -> user validation
   |          |                 |                 |                 |              |
 authority  retention         integrity          timing            split-brain    journey
```

## RPO and RTO

RPO is the maximum acceptable data loss measured in time. RTO is the maximum acceptable time to restore the service. Define both per critical workflow, including dependencies, DNS/routes, credentials, queues, and human approvals. A single application-wide number hides the hardest path.

## Backup layers

Logical exports, physical snapshots, replication, and immutable copies have different failure modes. Replication can copy corruption or deletion; snapshots can depend on the same account or key; exports can miss permissions, schema, or ordering. Use layered protection and record source, timestamp, version, encryption, retention, and restore owner.

## Restore sequence

Familiarize the team with inventory, isolate the target, fence old writers, restore data, apply compatible schema/configuration, reconnect dependencies, reconcile queues and caches, and validate the user journey. Measure each stage. Never promote a second writer while the first can still accept traffic.

## Safe local exercise

Create a disposable SQLite database and a dated logical copy. Delete the working copy, restore into a new directory, run an integrity check and application read-only validation, and record elapsed time and data-loss boundary. Use a copied fixture only; do not touch application or production data.

## Triage sequence

1. Declare the affected workflow, last known good point, RPO/RTO, and recovery authority.
2. Protect evidence and fence unsafe writers before changing state.
3. Select the newest verified artifact that satisfies integrity and compatibility checks.
4. Restore in isolation, measure each step, and reconcile dependent state.
5. Validate user success, freshness, permissions, queues, and monitoring.
6. Record gaps as owned actions and repeat the test after changes.

## Interview defense

**Question:** “How do you know backups work?”

**Strong answer:** “A recent isolated restore test proves artifact integrity, ordering, credentials, schema compatibility, measured RPO/RTO, writer fencing, and user-visible correctness. The existence or age of a backup object alone proves none of those.”

**Question:** “Why can replication make disaster recovery worse?”

**Strong answer:** “It can replicate corruption, deletion, bad credentials, or an operator mistake. I combine point-in-time or immutable recovery, independent validation, fencing, and a tested promotion/reconciliation path.”

## Teach-back checkpoint

Choose one critical workflow. State its RPO/RTO, authoritative writer, backup layers, fencing step, restore evidence, dependency checks, and the user action that proves recovery.
