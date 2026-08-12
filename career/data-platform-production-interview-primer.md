# Data-platform and distributed-systems production interview: protect the truth before improving throughput

Data-platform incidents are dangerous because a dashboard can look healthy while the data is duplicated, late, silently missing, or attributed to the wrong version. Start with the business rule, the authoritative record, the affected interval and the replay boundary. Only then tune throughput.

```text
producer -> durable raw record -> validation -> transform/state -> published data -> consumer decision
    |              |                 |              |                 |               |
 identity        retention        quarantine     checkpoint       lineage         business effect
```

The key question is never just “is the job running?” It is “which records were accepted, what result was published, and can we prove or safely repair the difference?”

## Scenario 1: a stream consumer falls behind

**Question:** Consumer lag rises from minutes to hours after traffic increases. Do you add consumers immediately?

**Strong answer:** I first establish whether the metric means source backlog, processing delay, event-time lateness, retry backlog or a stale dashboard. I identify topic/partition ownership, ingress rate, consumer throughput, partition skew, rebalance history, error/retry rate, downstream database/cache/API limits, retention window and the customer/data-product impact. More consumers cannot increase parallelism beyond partitions and can amplify a constrained sink. I contain the known amplifier: pause a noncritical consumer, cap concurrency, protect the authoritative store, or route a bounded workload only with defined authority. I then remove the actual bottleneck—hot partition key, slow transform, failed dependency, bad retry, insufficient partitioning, or sink limit—and verify lag *and* end-to-end output freshness, duplicate rate and error budget. Prevention is capacity based on peak and recovery rate, partition-key review, backpressure, age-of-data SLOs and a replay runbook.

**Weak answer:** “Scale every consumer.” That can create rebalance churn, connection exhaustion, duplicate work, or higher pressure on a database that was already failing.

**Senior follow-up:** Why is zero lag not enough? A consumer may have skipped, quarantined, transformed incorrectly, or written to an unavailable/stale destination. Lag is one transport signal, not a correctness proof.

## Scenario 2: a batch job succeeds but the numbers are wrong

**Question:** The scheduler reports success, but finance sees a 12% drop in daily revenue. Where do you start?

**Strong answer:** Scheduler success proves the orchestrator observed a terminal task state; it does not prove source completeness, correct interval semantics, schema compatibility, join cardinality, deduplication, partition publication or business validity. I freeze or clearly label the suspect downstream publication according to the data contract, capture run ID/code version/config/input partitions/row counts/checksums and compare a healthy day. I trace source arrival and watermark/late-data assumptions, run/data interval versus wall clock, schema evolution, filters, joins, null/default handling, duplicate rules and atomic publish behavior. I reproduce the smallest affected interval in an isolated path, correct the specific logic or input contract, backfill with explicit scope and verify reconciled totals against an independent authoritative source. Prevention includes freshness/completeness/distribution checks, reconciliation ownership, interval contracts, versioned schemas and no “success” definition based only on process exit code.

**Weak answer:** “Rerun the whole job.” A blind rerun can duplicate outputs, overwrite evidence, consume scarce capacity, and repeat the same incorrect logic.

**Senior follow-up:** What is an independent control? A measurement derived through a different path or authority, such as settled ledger totals versus an analytics aggregate. Re-reading the same faulty table is not independent.

## Scenario 3: a checkpoint restore reprocesses events

**Question:** After a streaming job restart, customers receive duplicate notifications. Was the checkpoint broken?

**Strong answer:** I do not assume the checkpoint alone defines end-to-end exactly-once behavior. I map the source offset/sequence contract, checkpoint completion, operator state, sink commit protocol, notification side effect, idempotency key, retry/deadline path and deployment/version change. A framework may restore state correctly while an external side effect is repeated after a crash window. I stop unsafe further delivery if authorized, preserve offsets/checkpoint metadata and delivery evidence, then use a durable idempotency or inbox/outbox boundary to identify and reconcile duplicates. I choose a bounded replay only after defining the exact affected range and proving the sink can reject already-applied effects. Recovery means the authoritative event/accounting state is reconciled and no further duplicate side effect occurs; merely restarting green is insufficient. Prevention is idempotent consumer design, stable event identity, atomic effect recording where possible, tested crash points and reconciliation tooling.

**Weak answer:** “Enable exactly once.” That phrase is meaningless without naming the source, state store, sink, side effect and failure window it covers.

**Senior follow-up:** What is the safest default when uncertain about replay? Prefer a held/quarantined bounded range with evidence and owner approval over an unbounded replay that could duplicate irreversible effects.

## Scenario 4: one partition makes a distributed job slow

**Question:** A Spark-like job has hundreds of tasks; nearly all finish quickly, but one runs for an hour. What do you investigate?

**Strong answer:** I recognize skew: parallel task count does not imply even work. I inspect stage plan, partition sizes/records, key distribution, join strategy, shuffle bytes/spill, executor memory/GC, data locality, input file layout and recent data changes. The long task may be a hot customer/tenant/key, a join explosion, a malformed record class or an oversized file. I avoid randomly increasing executors because it cannot split one oversized partition and may worsen shuffle pressure. I make a targeted correction: change partition key/bucketing, pre-aggregate, salt an approved hot key with a correct recombination rule, use an appropriate join strategy, split input safely, or quarantine corrupt data. Then I validate both runtime and result equivalence on a representative bounded sample. Prevention is distribution telemetry, skew-aware capacity tests, data-contract limits and review of high-cardinality/hot-key assumptions.

**Weak answer:** “The cluster needs more CPU.” A single partition may be serial work, disk spill, or a data-shape problem; unused workers do not fix it.

**Senior follow-up:** What must salting preserve? The semantics of grouping, joins and aggregates. A speed improvement that changes totals or ownership is a data incident, not an optimization.

## Scenario 5: an Iceberg-like table shows partial new data

**Question:** Some readers see yesterday’s data and others see today’s partially written data after a deployment. How do you respond?

**Strong answer:** I separate files from a committed table snapshot. I identify table/catalog identity, snapshot/version, writer job/run, commit status, reader engine/version/cache behavior, manifest/metadata path, permission boundary and the exact observation times. Listing object-store files does not prove a consistent table was committed. I stop or fence the unsafe writer through its defined control path, preserve metadata and logs, and select a known-good snapshot/transaction only after confirming impact and rollback semantics. I validate reads from each affected engine against the same explicit snapshot and reconcile expected partitions/row counts. I do not manually delete data files before understanding reachability and retention because metadata may reference them and cleanup may remove forensic evidence. Prevention is atomic commit protocol, immutable/versioned metadata, compatible reader/writer changes, explicit snapshot observability, catalog ownership and a tested rollback procedure.

**Weak answer:** “Refresh the dashboard cache.” Caching may expose the symptom, but cannot establish whether the table commit itself was complete or consistent.

**Senior follow-up:** What does a successful writer exit fail to prove? That the catalog accepted the intended snapshot, all readers can interpret it, data quality rules passed, or downstream consumers saw one coherent version.

## Scenario 6: an ML feature pipeline silently drifts

**Question:** Model accuracy drops, infrastructure dashboards are green, and a feature pipeline has no errors. What evidence do you need?

**Strong answer:** I treat this as a data/model contract investigation, not an infrastructure-only incident. I establish model version, feature definitions, training and serving code versions, feature freshness, source populations, schema/default changes, null/range/distribution shifts, point-in-time join behavior, labels and delayed-ground-truth window. I compare a healthy baseline and affected cohort while protecting customer impact through the approved model/feature rollback, fallback or exposure-control path. I verify offline/online feature parity and lineage before changing thresholds or scaling compute. A green pipeline may be producing a consistent but semantically wrong feature, such as a unit change, timezone shift, default value, leakage fix or upstream selection change. Recovery means measured user/business and model-quality indicators meet the agreed decision criteria for the right population; prediction volume alone is not evidence. Prevention is versioned feature contracts, freshness/distribution/quality monitors, lineage, shadow evaluation, rollbackable aliases and ownership across data, ML and product teams.

**Weak answer:** “Add more GPU or restart the serving pods.” That may restore capacity but cannot correct a changed feature meaning or training-serving mismatch.

**Senior follow-up:** Why can aggregate accuracy hide harm? A model can improve overall while degrading a critical cohort. Reliability needs the declared population and safety/fairness/business boundaries, not one comforting average.

## A fast answer map for data-platform interviews

When a question feels large, say the map out loud:

1. Name the business/data rule and the authoritative record.
2. Bound affected records, population, time interval, versions and side effects.
3. Separate process health from correctness/freshness/completeness.
4. Preserve evidence and contain only the unsafe path.
5. Repair or replay only when identity, idempotency and reconciliation are explicit.
6. Verify the published result with an independent or authoritative control.
7. Turn the discovery into a contract, monitor, runbook and capacity/recovery test.

This sequence is memorable because it keeps the real asset—the truth used for decisions—above the temptation to make a green dashboard quickly.
