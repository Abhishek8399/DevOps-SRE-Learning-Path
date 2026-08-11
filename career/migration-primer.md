# Migration engineering: move state without losing the contract

A migration is a change to ownership, data, traffic, dependencies, or operating model. The hard part is preserving user outcomes while authority moves between old and new systems.

```text
inventory -> compatibility -> foundation -> dual/read path -> cutover -> reconcile -> retire
    |           |              |             |                 |          |
 authority    contract       rollback      evidence          owner      decommission
```

## Start with the invariant

Name the user journey, authoritative writer, data-loss boundary, security obligations, RPO/RTO, cost limit, and rollback condition. “Move to Kubernetes/cloud/new database” is an implementation idea, not a safe migration plan.

## Coexistence and authority

Build foundations and observability before moving traffic. Use backward-compatible schemas, explicit writer ownership, dual-read or dual-write only when reconciliation is defined, and a shadow or canary path to compare outcomes. Two writers without fencing create divergence.

## Cutover and retirement

Cut over with a checkpoint, owner, abort threshold, and user-SLI evidence. Reconcile old/new counts, IDs, freshness, permissions, queues, and side effects. Keep the old system read-only or fenced until confidence and recovery criteria are met; retirement requires dependency, backup, access, and cost cleanup evidence.

## Safe local exercise

Migrate a fixture JSON dataset between two local directories with a versioned schema. Validate counts/checksums, run a shadow comparison, switch a manifest pointer, verify reads, and roll back once. Delete only fixture directories.

## Triage sequence

1. Identify current authority, target authority, user scope, and migration phase.
2. Compare compatibility, data counts/checksums, freshness, permissions, and dependency paths.
3. Pause traffic or writes at the smallest safe boundary when evidence diverges.
4. Reconcile or roll back using the documented checkpoint; do not improvise a second writer.
5. Verify user outcomes, recovery, cost, and decommission prerequisites.

## Interview defense

**Question:** “How do you migrate a database with no downtime?”

**Strong answer:** “I define the user invariant and RPO/RTO, establish compatible schema and replication, prove lag and reconciliation, move reads or traffic gradually, fence the old writer at a checkpoint, verify user SLIs and data correctness, and retain a tested recovery path. ‘No downtime’ does not mean no risk.”

**Question:** “When do you retire the old system?”

**Strong answer:** “After authority, data, dependencies, backups, access, observability, cost, and recovery evidence meet explicit exit criteria. I keep a bounded read-only or rollback window rather than deleting the only recovery path.”

## Teach-back checkpoint

Design a migration wave. State invariant, authority, compatibility window, cutover evidence, abort threshold, reconciliation, rollback, and retirement criteria.
