# Data pipeline and ML reliability interview: a successful run is not trustworthy data

Data systems can produce a green task, a fresh table, and a wrong business decision at the same time. Reliability starts by naming the dataset contract, authority, freshness boundary, lineage, and recovery path.

```text
source -> ingest -> validate -> transform -> publish -> feature/model consumer
  |         |           |            |             |              |
late/dup   checkpoint   quality      schema         lineage        decision safety
```

## Scenario 1: the daily pipeline succeeds but data is incomplete

**Question:** An orchestration run is green, but a source delivered late records and the report is wrong. What do you do?

**Strong answer:** Scheduler success means tasks reached their configured completion state; it does not prove source completeness. I establish the dataset's event-time window, expected partitions/records, source watermark, ingestion lag, allowed lateness, business cutoff, and consumer impact. I compare the published partition with the authoritative source and lineage rather than rerunning blindly.

I choose a bounded correction: hold publication, mark the dataset incomplete, or backfill the exact affected window with idempotent writes and a versioned/reconciled output. I do not overwrite a trusted partition without preserving lineage and rollback evidence. Prevention is an explicit freshness/completeness SLO, source contract, late-data policy, anomaly checks, and a consumer-visible status when data is not fit for a decision.

**Weak answer:** "The DAG is green, so tell users the report is ready." A green scheduler sees task mechanics, not whether the promised source facts arrived.

**Senior follow-up:** What proves a backfill is safe? The selected window, input lineage, transform revision, idempotent output semantics, reconciliation result, and downstream impact are all recorded and validated.

## Scenario 2: a stream replay creates duplicate business effects

**Question:** A consumer restarts and reprocesses messages, creating duplicate notifications or ledger entries. How do you design the fix?

**Strong answer:** I assume delivery can repeat and make the effect idempotent. The consumer derives a stable effect identity from the authoritative event and business operation, records the durable effect state atomically where possible, and returns the existing outcome on a repeat. A consumer offset or acknowledgement alone is not sufficient proof that the external/database effect happened exactly once.

For recovery, I identify the replay window, event identities, consumer group/offset state, effect records, poison failures, and required reconciliation. I replay only the authorized range and verify no duplicate customer outcome. The design includes retention long enough for recovery, schema compatibility, partition/order assumptions, and a dead-letter or quarantine process with ownership—not an ignored error topic.

**Weak answer:** "Commit the offset before processing." That can lose an effect on crash; committing after processing can repeat it. The effect needs its own idempotency and reconciliation contract.

**Senior follow-up:** Can exactly-once processing solve this universally? Usually no. State the narrower truth: repeated delivery plus idempotent effect, with recovery from durable evidence.

## Scenario 3: a schema change silently changes a metric

**Question:** A producer adds a field and a downstream aggregate shifts unexpectedly without failure. How do you prevent silent semantic drift?

**Strong answer:** Compatibility is more than parsable syntax. I define field meaning, units, null/default behavior, enumeration lifecycle, cardinality, timestamp semantics, privacy classification, and owner. A new field can alter a join, default, aggregation, feature, cache key, or downstream generated client even if every serializer accepts it.

I use versioned schemas/contracts, compatibility checks, representative producer-consumer tests, data-quality assertions, and dual-read/dual-publish or shadow comparison when semantics change. I monitor key distribution and business aggregates around the rollout, segment by producer/consumer revision, and maintain an explicit deprecation/migration path. If a metric is already wrong, I preserve the affected output/version, identify the first divergent partition, correct through a reviewed backfill, and label any reports that were based on the invalid data.

**Weak answer:** "The schema registry accepted it." Registry compatibility is useful evidence; it is not proof that business meaning stayed compatible.

**Senior follow-up:** Why preserve bad output? It supports lineage, impact assessment, correction audit, and avoids silently rewriting historical decisions without an accountable record.

## Scenario 4: a backfill overwhelms the warehouse and production workloads

**Question:** A year-long backfill is urgent. Engineers want maximum parallelism to finish quickly. What is your plan?

**Strong answer:** I treat backfill as a separate production workload with a budget. I estimate data volume, partitioning, read/write amplification, concurrency, slot/compute limits, spill/storage, queue time, downstream refresh impact, and cost. I identify workloads that must retain headroom—interactive queries, customer APIs, scheduled critical jobs—and isolate or rate-limit the backfill accordingly.

I run a small representative slice, verify correctness and cost, then ramp with gates on latency, errors, queueing, warehouse health, and spend. The job is resumable and partition-idempotent, records source/transform/output versions, and can pause without corrupting published results. I do not let "urgent" remove ownership of capacity, query safety, or rollback/reconciliation.

**Weak answer:** "Use all available workers overnight." Available compute may be shared capacity, and a fast backfill can create an expensive or customer-visible outage.

**Senior follow-up:** What proves completion? Expected partitions and records reconcile to the source, quality/freshness contracts pass, consumers read the intended version, and the workload did not violate its capacity/cost guardrails.

## Scenario 5: ML feature freshness looks good but predictions degrade

**Question:** The feature pipeline meets its freshness SLA, yet model quality drops. What do you investigate?

**Strong answer:** Freshness is one dimension of feature reliability. I compare training and serving definitions, feature values/distributions, missingness, labels/outcomes, source revisions, entity joins, point-in-time correctness, model version, inference environment, and population segments. A feature can arrive on time but be stale in business meaning, shifted in distribution, joined to the wrong entity, or computed differently online and offline.

I use feature/model lineage to identify the exact training dataset, feature transform/version, model artifact, serving payload, and affected decision window. I can route to a reviewed prior model, bounded fallback, or abstention path only if its product/safety contract permits it. The prevention is a feature contract with owners, training-serving parity tests, distribution/drift monitoring, quality checks, model performance feedback with delay awareness, and rollback that includes feature/model compatibility.

**Weak answer:** "Retrain the model." Retraining can bake in corrupted data or hide a serving/training mismatch without identifying the root cause.

**Senior follow-up:** What does a feature freshness SLA not prove? Correctness, representativeness, point-in-time validity, privacy compliance, model calibration, or decision fairness.

## Scenario 6: sensitive data appears in a notebook or catalog export

**Question:** A shared analyst notebook exposes sensitive columns from a pipeline. What is your response?

**Strong answer:** I contain access through the owning data/security process, preserve necessary audit evidence, identify the dataset/version, catalog permissions, notebook/export/artifact copies, recipients, retention, and the applicable data classification. I do not paste values into incident channels or assume removing a notebook cell removes cached results, downloads, or derivative tables.

I revoke or reduce access as authorized, rotate affected credentials where applicable, and fix the data contract: classification at ingestion, least-privilege access, column/row controls, masking/tokenization, approved purpose/retention, audit logs, and reviewed export paths. I trace lineage to identify derived outputs that may require treatment. The durable control is not a reminder to be careful; it is a policy and platform path that makes unsafe sharing difficult and visible.

**Weak answer:** "Delete the notebook." That can destroy evidence while leaving copies, permissions, and the pipeline classification gap unresolved.

**Senior follow-up:** What proves containment? The stated access paths are revoked or bounded, derivative scope is assessed, required rotation/notification decisions are owned, and the corrected policy is enforced and tested. It does not prove every historical copy is absent.

## Fast decision map

| Signal | Remember | First safe move |
|---|---|---|
| green pipeline, wrong report | Task success is not source completeness | Check watermarks, partitions, lineage, and data contract |
| replayed stream | Offset is not business effect | Reconcile durable event/effect identities |
| accepted schema change | Syntax is not semantic compatibility | Compare producer/consumer meaning and key distributions |
| urgent backfill | Compute is a shared reliability budget | Test a slice and ramp with capacity/cost gates |
| fresh features, poor model | Freshness is not correctness | Trace training-serving parity and feature/model lineage |
| sensitive notebook output | Deletion is not containment | Bound access, assess lineage, then enforce data controls |

## Practice

For any data incident, say: authoritative source; intended decision; event-time/freshness contract; lineage needed; smallest safe correction; reconciliation proof; prevention owner. This turns a data job from a scheduled script into a reliable product boundary.
