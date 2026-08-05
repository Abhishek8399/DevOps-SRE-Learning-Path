---
{"schemaVersion":1,"kind":"lesson","id":"LES-0062","slug":"data-pipeline-reliability","aliases":["V06-L07","data-pipeline-reliability"],"curriculumIds":["DMP-001"],"route":"/book/state/data-pipeline-reliability","order":7,"volume":"06-state-distributed-systems","title":"Data pipeline reliability: prove replay, state, quality, and lineage","summary":"Operate batch and stream pipelines by tracing source identity, event time, deterministic transforms, checkpoints, state, sink commits, data quality, lineage, replay, capacity, privacy and consumer outcomes.","domain":"state","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0026","LES-0060","LES-0061"],"prerequisiteCurriculumIds":["DST-004","PERF-001","K8S-002"],"testedEnvironments":[{"platform":"Official documentation","version":"Apache Spark 4.2, Apache Flink 2.3, Beam, OpenLineage and W3C sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, engine, state backend, catalog or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","data-engineer","data-platform-engineer","ml-platform-engineer","solutions-architect","technical-lead"],"learningObjectives":["Distinguish bounded and unbounded data from batch and streaming execution choices.","Trace one data record from immutable source identity and position through transforms, state, checkpoint, sink and consumer decision.","Separate event time, processing time, watermark, window, trigger, allowed lateness and finality.","State the prerequisites behind end-to-end processing guarantees rather than repeating engine slogans.","Design replayable sources, deterministic/versioned transforms and idempotent or transactional sinks.","Distinguish working state, checkpoint storage, savepoints and source retention.","Test checkpoint durability, restore compatibility, rescaling and rollback before deployment.","Diagnose skew, hot partitions, shuffles, backpressure, checkpoint delay and recovery capacity.","Define data-quality contracts with severity, ownership, quarantine and user-impact policy.","Capture run, job, dataset, schema, code, source-range and quality lineage.","Plan isolated backfill/replay with pinned inputs/code/config/schema and reconciled promotion.","Govern privacy, deletion, retention, audit, capacity and cost across raw, state, checkpoint and output copies."],"productionSignals":["consumer decision and data product SLI","pipeline job run attempt code artifact and config version","source dataset snapshot partition event ID and position range","schema version compatibility and parse failures","event time ingestion time processing time watermark and lateness","window trigger pane accumulation and correction count","operator/subtask partition key rows bytes and skew distribution","input output processed and dropped record counts","shuffle read/write spill fetch and straggler duration","busy idle and backpressured time by subtask","state entries bytes TTL backend and compaction","checkpoint trigger start delay alignment duration size age and failure reason","restore source position state version and recovery duration","sink transaction/batch/effect ID commit and duplicate count","quality assertion dimension threshold observed value severity and disposition","quarantine count age reason owner retention and redrive result","lineage run job dataset input/output source-range and code links","arrival service backlog oldest age drain and dependency headroom","raw/checkpoint/state/output retention privacy deletion and audit","CPU memory network disk IOPS object requests compute time and unit cost"],"diagrams":[{"id":"LES-0062-DIA-001","title":"End-to-end data correctness path","direction":"left-to-right","boundaries":["consumer decision","source snapshot/position","schema","transform graph","state/checkpoint","sink commit","quality","lineage and reconciliation"],"evidencePoints":["data product SLI","source range","schema ID","code hash","checkpoint ID","output version","assertion result","run lineage"],"textAlternative":"A data product is trustworthy only when source identity, computation, recoverable state, sink commit, quality evidence and lineage connect to the consumer decision."},{"id":"LES-0062-DIA-002","title":"Bounded and unbounded execution","direction":"hierarchical","boundaries":["bounded collection","finite batch","unbounded collection","event-time windows","watermarks","triggers","late corrections"],"evidencePoints":["snapshot","run","event timestamp","window","watermark","pane","revision"],"textAlternative":"Bounded input can finish as a batch; unbounded input needs finite windows, progress estimates and an explicit late-data correction contract."},{"id":"LES-0062-DIA-003","title":"Checkpoint recovery boundary","direction":"left-to-right","boundaries":["replayable source","source position","operator state","barrier/snapshot","durable checkpoint store","restore","idempotent sink"],"evidencePoints":["offset","state version","checkpoint ID","storage URI","restore result","sink key"],"textAlternative":"Recovery binds replayable source positions and compatible operator state in durable storage, then safely repeats output through a sink contract."},{"id":"LES-0062-DIA-004","title":"Time and window semantics","direction":"left-to-right","boundaries":["event produced","ingested","processed","watermark advances","window emits","late event","correction/final policy"],"evidencePoints":["event time","ingest time","processing time","watermark","pane","lateness","output revision"],"textAlternative":"Watermarks estimate event-time progress; late-data policy decides whether a window is corrected, quarantined or treated as final."},{"id":"LES-0062-DIA-005","title":"Skew and backpressure path","direction":"hierarchical","boundaries":["source partitions","key distribution","shuffle","hot subtask","slow sink/dependency","upstream backpressure","checkpoint delay"],"evidencePoints":["top key","partition bytes","task duration","busy/backpressure","dependency latency","alignment delay"],"textAlternative":"A slow sink or hot partition propagates pressure upstream and can delay checkpoint barriers despite apparently idle aggregate resources."},{"id":"LES-0062-DIA-006","title":"Lineage, quality, and replay promotion","direction":"hierarchical","boundaries":["identified input datasets","versioned job run","output dataset","quality assertions","quarantine","isolated replay output","reconciliation","consumer promotion"],"evidencePoints":["dataset namespace/name","run ID","code/schema","assertion","owner","replay range","diff","approval"],"textAlternative":"Lineage identifies inputs, run and outputs; quality and reconciliation gate promotion of an isolated replay to consumers."}],"commands":[{"id":"LES-0062-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0062 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"data-engine behavior"},{"id":"LES-0062-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"pipeline setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0062-CMD-003","question":"Does the baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0062 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0062-CMD-004","question":"Can the exact input be replayed?","risk":"read-only","command":"bash lab.sh evaluate source-not-replayable","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=source-replay","meaning":"recovery input is unavailable","nextEvidence":"retain immutable source or recovery copy"}],"proves":"encoded source gap","doesNotProve":"source retention"},{"id":"LES-0062-CMD-005","question":"Will replay compute the same meaning?","risk":"read-only","command":"bash lab.sh evaluate transform-nondeterministic","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=transform-replay","meaning":"transform depends on unrecorded changing input","nextEvidence":"pin or record it"}],"proves":"encoded determinism gap","doesNotProve":"code behavior"},{"id":"LES-0062-CMD-006","question":"Can recovered output duplicate?","risk":"read-only","command":"bash lab.sh evaluate sink-not-idempotent","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=sink-duplicate","meaning":"reprocessing can apply output twice","nextEvidence":"transactional/idempotent output identity"}],"proves":"encoded sink gap","doesNotProve":"sink semantics"},{"id":"LES-0062-CMD-007","question":"Can the checkpoint survive and restore?","risk":"read-only","command":"bash lab.sh evaluate checkpoint-not-durable","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=checkpoint-durability","meaning":"state snapshot is not recoverable","nextEvidence":"durable protected checkpoint store"}],"proves":"encoded durability gap","doesNotProve":"restore compatibility"},{"id":"LES-0062-CMD-008","question":"Does event-time policy cover observed delay?","risk":"read-only","command":"bash lab.sh evaluate lateness-too-short","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=late-data-policy","meaning":"valid late records exceed policy","nextEvidence":"change policy or correction path"}],"proves":"encoded lateness mismatch","doesNotProve":"watermark behavior"},{"id":"LES-0062-CMD-009","question":"Can quality failures become owned work?","risk":"read-only","command":"bash lab.sh evaluate quarantine-unowned","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=quality-quarantine","meaning":"bad data accumulates without disposition","nextEvidence":"owner SLA retention and redrive"}],"proves":"encoded ownership gap","doesNotProve":"data validity"},{"id":"LES-0062-CMD-010","question":"Can one hot partition cap progress?","risk":"read-only","command":"bash lab.sh evaluate hot-partition","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=data-skew","meaning":"local demand exceeds local capacity","nextEvidence":"key distribution and plan repair"}],"proves":"encoded skew","doesNotProve":"engine plan"},{"id":"LES-0062-CMD-011","question":"Can replay touch the live sink?","risk":"read-only","command":"bash lab.sh evaluate replay-live-sink","runFrom":"LES-0062 support/lab","expectedBranches":[{"when":"boundary=replay-side-effect","meaning":"backfill can corrupt live output","nextEvidence":"isolated namespace and promotion"}],"proves":"encoded replay gap","doesNotProve":"sink isolation"},{"id":"LES-0062-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0062 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"eighteen branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"Spark Flink Beam checkpoint state sink quality lineage replay load or production behavior","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0062-LAB-001","title":"Guided data-pipeline boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0062-data-pipeline-reliability/support/lab"},{"id":"LES-0062-LAB-002","title":"Independent batch/stream checkpoint, quality and replay transfer","mode":"independent","environment":"Reviewer-owned disposable local engine and synthetic datasets","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic source state checkpoints and outputs","disposable jobs and quality/lineage records","approved faults and replay artifacts"],"abortConditions":["shared service","real credential","customer data","host network/clock mutation","unbounded input/replay","unknown cleanup"],"recovery":"Preserve histories and reset through the reviewer harness.","cleanupProof":"Reviewer proves processes, files, ports, volumes, checkpoints and data absent.","path":"drafts/LES-0062-data-pipeline-reliability/support/lab"}],"incidents":[{"id":"LES-0062-INC-001","signal":"The stream job is green but yesterday's revenue is lower than the source ledger.","firstThought":"Progress and quality may be green while late, dropped, duplicated or mis-keyed records change the business result.","safePath":"Bind source range, event time/watermarks, schema, transform version, sink commits and quality/reconciliation by operation.","trap":"Restart the job and trust the status."},{"id":"LES-0062-INC-002","signal":"A restart doubles rows in the serving table.","firstThought":"Source/state recovery repeated output into a non-idempotent sink.","safePath":"Stop writes, preserve checkpoint/source/sink evidence, reconcile stable row/effect keys, repair and make commit replay-safe.","trap":"Delete the checkpoint and restart from earliest."},{"id":"LES-0062-INC-003","signal":"Checkpoint duration grows until the job repeatedly fails.","firstThought":"Backpressure, state growth, I/O or one long record delays snapshot progress.","safePath":"Trace per-subtask busy/backpressure, barrier delay, state bytes, storage I/O and dependency capacity before tuning alignment.","trap":"Enable unaligned checkpoints blindly."},{"id":"LES-0062-INC-004","signal":"One task runs for hours while most executors are idle.","firstThought":"Key/file/join skew or a straggling dependency dominates the critical path.","safePath":"Inspect partition rows/bytes/top keys/plan/spill and redesign distribution or isolate the hot key with correctness proof.","trap":"Add more executors without changing the hot partition."},{"id":"LES-0062-INC-005","signal":"A backfill repairs a dashboard but overwrites live corrections and exposes deleted data.","firstThought":"Replay was not isolated or governed by code/schema/privacy/output versions.","safePath":"Stop promotion, preserve ranges, isolate output, apply deletion policy, reconcile revisions and promote through an approved atomic boundary.","trap":"Rerun directly into the live sink."}],"assessmentIds":["ASM-0169","ASM-0170","ASM-0171"],"referenceIds":["REF-0688","REF-0689","REF-0690","REF-0691","REF-0692","REF-0693","REF-0694","REF-0695","REF-0696","REF-0697","REF-0698","REF-0699","REF-0700","REF-0701","REF-0702"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not Spark, Flink, Beam, a scheduler, broker, state backend, checkpoint store, data lake, catalog, lineage/quality service or benchmark.","Synthetic decisions do not prove engine, connector, storage, sink, schema, quality, lineage, privacy or recovery behavior.","No socket, job, dataset, checkpoint, stream, table, effect, replay, load or external resource exists.","Semantics, defaults, limits and metrics are version-, connector-, storage-, configuration- and topology-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Data pipeline reliability: prove replay, state, quality, and lineage

## What you see and first thought

The job dashboard is green. Every scheduled run completed. Consumer dashboards are wrong.

That is not a contradiction. A job can process every record it received while the source omitted data. It can checkpoint successfully while the sink duplicates output. It can meet latency while dropping late events. It can pass a row-count check while corrupting money. It can produce a correct table that nobody can trace to code, input or policy.

Keep this first thought:

> A green job proves execution state. Trustworthy data requires an evidence chain from one consumer decision back through output version, quality result, sink commit, state/checkpoint, transform code, schema and exact source range.

```text
consumer decision
      ^
      | data-product SLI + reconciliation
output version <-- quality assertions <-- sink commit
      ^                                  ^
      |                              checkpoint/state
transform graph + code/config/schema
      ^
source dataset/snapshot/partition/position
```

During an incident, ask:

1. Which consumer decision is wrong or at risk?
2. Which output dataset/version/partition served it?
3. Which job run, code, configuration and schema produced that output?
4. Which exact source snapshot or position range was read?
5. What checkpoint and sink-commit contract governs recovery?
6. Which quality and reconciliation evidence detects semantic error?

Do not begin by deleting a checkpoint, increasing parallelism or replaying into the live sink. Those are mutations that can turn a visible delay into silent duplication or corruption.

## Terms before commands

### Bounded data, unbounded data, batch, and stream

A **bounded dataset** has a finite extent for the operation: a named snapshot, files under a sealed manifest, or source positions `1000..2000`. A batch run can eventually finish reading it.

An **unbounded dataset** continues to arrive. A stream processor cannot wait for “all data,” so it needs finite windows, triggers and progress policy. Batch and stream describe execution styles; bounded and unbounded describe the input. A system can process bounded data with a streaming engine or unbounded data through recurring micro-batches.

A **micro-batch** collects a finite input range for each trigger and runs batch-like work repeatedly. A **continuous** or record-at-a-time mode reduces latency but may expose different delivery/checkpoint semantics. Product names do not replace the end-to-end contract.

### Event time, processing time, windows, and watermarks

**Event time** is when the business event happened. **Ingestion time** is when the platform received it. **Processing time** is when an operator handled it. They differ during mobile offline periods, queues, outages and clock error.

A **window** groups unbounded events into a finite logical interval. Fixed windows do not overlap; sliding windows can; session windows depend on inactivity.

A **watermark** is the system's estimate that event time before a point is mostly complete. It is not proof that no earlier event will arrive. **Allowed lateness** and **trigger** policy decide when to emit early results, corrections and when state may be discarded.

An idle input partition can hold back a combined watermark forever unless idleness is declared correctly. An overly aggressive idle timeout can let the watermark advance while a merely slow partition still has valid old events.

### Source position, checkpoint, state, and sink

A **source position** identifies progress in a replayable input: offset, sequence, file manifest, snapshot ID or partition cursor. “Latest” is not a reproducible position.

**Operator state** is working memory across records: counts, joins, windows, timers, dedupe keys. A **state backend** stores the working representation; **checkpoint storage** holds durable snapshots. Fast local state is not automatically durable recovery state.

A **checkpoint** binds compatible operator state to source positions so recovery can reproduce a failure-free logical execution within the engine's documented assumptions. A checkpoint file existing does not prove it is complete, durable, compatible with new code, restorable at a new parallelism or sufficient for the sink.

A **savepoint** is commonly an operator-managed, deliberately retained state snapshot used for controlled changes. Product semantics vary; never use the words interchangeably without checking versioned documentation.

The **sink** owns output. It may support transactional commit, overwrite of an immutable output version, upsert by stable key, or only append. Recovery semantics stop at any sink that cannot make repeated output safe.

### Data quality and lineage

A **schema contract** describes shape and types. **Data quality** describes whether data is fit for an intended use. Useful dimensions include completeness, validity, uniqueness, consistency, timeliness, accuracy and distribution—but each must become a measurable rule tied to consumer impact.

“Null rate < 1%” is incomplete without dataset/version, column, population, window, threshold rationale, severity, owner, disposition and observed value.

**Lineage** connects identified datasets, job definitions, runs, code/configuration and outputs. It answers “what produced this?” and “what depends on this?” It does not prove correctness; it makes impact analysis and evidence navigation possible.

## Architecture map

### The data ownership chain

```text
source authority
  | immutable identity + position + schema
  v
reader -> parse/validate -> transform/shuffle/state -> sink commit
             |                    |                |
         quarantine          checkpoint        output version
             |                    |                |
             +---------- lineage/run ------------+
                                      |
                                  quality gate
                                      |
                               consumer promotion
```

| Boundary | Owner | May forget only when | Evidence |
|---|---|---|---|
| raw input | source/data owner | recovery/privacy policy permits | snapshot/positions, digest, schema |
| in-flight input | engine/source connector | checkpoint owns replay position | range, attempt, checkpoint |
| operator state | engine/state backend | durable compatible snapshot exists | state schema/version/bytes |
| checkpoint | checkpoint store/operator | no active rollback/recovery needs it | ID, completion, storage, restore test |
| output | sink/data-product owner | successor version is validated and retained | transaction/version/row identity |
| invalid data | quarantine owner | repaired, approved rejected or expired | rule, reason, lineage, disposition |
| lineage | metadata/governance owner | audit and impact horizon permits | run/job/dataset/code relations |

If input can disappear before checkpoint ownership, recovery loses data. If output can apply twice after checkpoint recovery, recovery duplicates data. If quality failure has no owner, quarantine becomes a quieter outage.

### Batch and stream share the same proof

Batch reliability needs immutable input manifests, deterministic code, atomic output publication and retry-safe runs. Stream reliability needs the same properties plus event-time, state and long-running checkpoint concerns.

A good batch pattern:

```text
read immutable input version
 -> write new isolated output version
 -> validate/reconcile
 -> atomically move catalog/pointer to new version
```

A good stream pattern:

```text
read replayable positions
 -> deterministic stateful transform
 -> durable checkpoint
 -> idempotent/transactional output
 -> continuous quality + lineage + corrections
```

Neither should overwrite the only good output while still computing.

## Request or state path

### One record through the system

Take payment event `evt-731`:

1. Source stores it at topic `payments`, partition 7, offset 41,992 with schema version 4 and event time 12:00.
2. Run `run-884` reads a declared range including that position.
3. Parser validates required identity, currency and amount.
4. Transform version `git:abc123` converts minor units and keys by account.
5. Window state records the event under the business event time, not arrival time.
6. Checkpoint `cp-220` captures source progress and compatible operator state in durable storage.
7. Sink commits output under stable key `account/day/event` or a transactional batch/version.
8. Quality asserts row conservation, nonnegative totals and reconciliation to the authoritative ledger.
9. Lineage links source dataset/range, job/run/code/schema, quality results and output dataset.
10. A catalog or serving pointer exposes the validated output to consumers.

The record is not “done” when transform code ran. It is done for this data product when the sink result is durable, required quality/reconciliation passes, and the consumer-facing version is published under the stated freshness/completeness policy.

### Recovery path

After a worker failure, the engine restores a completed checkpoint and replays source records after its captured positions. That can repeat transforms and sink attempts. Correctness requires:

- source still retains the exact range;
- restored state matches source positions;
- code can deserialize and interpret old state;
- nondeterministic external lookups are recorded/versioned;
- sink repeat uses stable identity or transaction;
- late-data and quality behavior remains defined;
- lineage identifies the recovery run;
- output is reconciled before consumer promotion.

“Exactly once” is a conditional statement about this whole chain. If the source is not replayable or the sink is a non-idempotent external API, the engine cannot extend its internal guarantee across that boundary.

## Failure zoom

### Green execution, wrong data

A pipeline can succeed mechanically and fail semantically:

- source export completed before one region uploaded its file;
- parser silently converted invalid values to null;
- an inner join dropped unmatched business entities;
- a timezone change moved records across daily windows;
- a dimension lookup used current rather than event-time state;
- duplicate input was appended twice at the sink;
- a quality test measured only accepted rows and ignored quarantine;
- a backfill used new business logic but replaced historical results without revision.

Job state is one signal. Data reliability needs conservation and invariant checks at boundaries:

```text
input accepted = output represented + explicitly rejected/quarantined
business total = valid output total + explained adjustments
```

Not every transform preserves row count, so declare the expected relationship: one-to-one, filtered with reason, one-to-many, aggregation, join or correction. Compare counts, keys, sums and distributions appropriate to the invariant.

### Checkpoint completed, restore fails

A completed checkpoint can still be operationally useless if:

- storage was local to the failed node;
- permissions or encryption keys are unavailable;
- retention deleted the referenced source positions;
- operator identity changed;
- state serializer/schema is incompatible;
- connector version interprets positions differently;
- new parallelism cannot redistribute custom state;
- the rollback build cannot read state written by the new build.

Therefore checkpoint success and restore success are separate evidence gates. Regularly restore into a disposable environment, verify source/state alignment and compare output. Test forward upgrade and rollback before production deployment.

### Watermark stalls or advances too far

Suppose 31 source partitions are active and one has no traffic. If the global watermark follows the minimum, the idle partition can prevent windows from closing and state grows. Declaring it idle may let progress continue.

But if that partition is slow rather than idle, a short idleness timeout can advance the watermark past events still arriving from it. Those events become late and may be discarded or corrected depending on policy.

Diagnose with:

- event-time distribution per source partition;
- watermark per source/operator;
- last record time and idleness transitions;
- allowed lateness and dropped/late counts;
- state/window size and cleanup;
- consumer tolerance for preliminary versus final results.

Watermark configuration is a business completeness decision expressed through engine mechanics.

### Skew and the straggler

Average partition size hides the critical path. If 99 partitions hold 1 GB and one holds 300 GB, adding workers does not split the already assigned 300 GB task unless the engine/plan changes distribution.

Common causes:

- null/default key concentrates data;
- a celebrity/customer/device dominates one key;
- many small files overload listing and scheduling;
- a join key has extreme frequency;
- one compressed file cannot split;
- a UDF makes one record expand massively;
- one sink partition or API quota is slow.

Inspect rows, bytes, top-key frequency, shuffle read/write, spill, GC, task duration and dependency time by partition. Remedies include correcting keys, salting only when recombination preserves semantics, pre-aggregating, broadcasting a truly small side, splitting files, adaptive skew handling, isolating hot keys or changing the data model.

### Backpressure and checkpoint coupling

Backpressure travels opposite the records: a slow sink exhausts its input capacity; upstream output buffers fill; upstream operators slow. In an aligned checkpoint, barriers can wait behind buffered records, so checkpoint start/alignment time grows. State grows while reliable snapshots become older—the failure gets harder to recover from.

Unaligned checkpoints can capture in-flight buffers and reduce barrier delay under some conditions. They add checkpoint I/O and state, have topology/ordering/watermark limitations, and do not repair the slow sink. First find the pressure source. A tuning switch is not a capacity plan.

### Replay damages live output

A replay may produce correct historical rows and still be unsafe:

- notifications or billing effects fire again;
- new code interprets old schema differently;
- current dimension values rewrite historical meaning;
- output competes with live work and causes lag;
- replay overwrites newer corrections;
- deleted/private records reappear;
- lineage cannot distinguish replay from original run.

Replay into an isolated namespace/table/topic. Pin source range, code, config, schema and reference datasets. Gate external effects, rate-limit below residual capacity, run quality and reconciliation, compare revisions, obtain approval and promote through an atomic pointer/snapshot change where possible.

## Internals and state ownership

### Logical and physical plans

The logical transform says what result is wanted. The physical plan decides exchanges, joins, partitions, sorts and stages. Two equivalent logical queries can have radically different reliability and cost.

Read plans for:

- full scans versus partition pruning;
- exchange/shuffle boundaries;
- broadcast size and timeout;
- join order and strategy;
- estimated versus runtime rows;
- partition count and adaptive changes;
- skew splitting;
- repeated scans or recomputation.

Statistics are evidence used by the optimizer, not eternal truth. Missing/stale statistics can create a poor plan. A hint is a request whose support and applicability must be verified; it is not proof the engine chose it.

### State and checkpoint anatomy

State is usually partitioned by key or operator. A checkpoint coordinates:

```text
source positions
 + operator/keyed state
 + timers/windows
 + sometimes in-flight buffers
 + metadata mapping state to operators/parallelism
```

Checkpoint interval trades recovery loss/rework against snapshot overhead. Short intervals increase I/O and coordination. Long intervals increase recovery time and source-retention need. The minimum safe interval comes from measured checkpoint duration, source/sink behavior and recovery objectives—not a copied default.

Track:

- time from trigger until first barrier reaches each operator;
- alignment time;
- synchronous pause;
- asynchronous upload duration;
- full and incremental bytes;
- failure/expiration reason;
- age of newest completed checkpoint;
- restore/download/replay duration;
- state growth and compaction.

### Sink commit strategies

**Versioned replace:** write immutable output version, validate, then atomically update a catalog/pointer. Excellent for batch and backfill when supported.

**Stable-key upsert:** write by deterministic primary key and revision. Repeated processing converges when conflict semantics are correct.

**Transactional batch/epoch:** stage writes and commit one engine epoch atomically using a sink protocol. Guarantees depend on connector and sink.

**Append only:** safe only if duplicates are acceptable or consumers deduplicate by stable record identity.

**External side effect:** requires the workflow/effect patterns from LES-0061; an engine checkpoint does not automatically include it.

### Quality as a contract

For each important rule record:

```text
dataset + version/population
dimension and assertion
expected threshold/range
observed value and sample-safe evidence
severity and consumer impact
action: fail, warn, quarantine, correct, continue
owner and response objective
lineage to job/run/code/source
retention and redrive/revalidation
```

Failing every anomaly can destroy availability. Warning on every anomaly can destroy trust. Tie severity to an explicit consumer invariant. For example, duplicate payment IDs may block financial publication, while a small optional marketing-field null increase may warn and continue.

Quality checks need their own quality: detect whether the test ran over the intended population, whether thresholds were calibrated, whether sensitive samples leak, and whether passing tests cover the important invariant.

### Lineage as evidence navigation

Use stable identities for:

- dataset namespace and name;
- physical version/snapshot/partition;
- job namespace/name;
- run ID and parent run;
- code artifact/hash and configuration;
- source and output schema;
- input/output facets including ranges;
- quality assertions;
- responsible agent/team.

Lineage collected only after success misses failed and partial runs. Emit lifecycle state such as start, complete, fail or abort with additive metadata. Make lineage delivery retry-safe and monitor gaps. Lineage is itself an operational data product with freshness, completeness, retention and access controls.

### Privacy and deletion across copies

One source record can appear in raw files, broker retention, shuffle, state, checkpoints, savepoints, quarantine, outputs, caches, event logs, lineage facets and backups. A deletion policy that names only the serving table is incomplete.

Inventory every copy and classify whether it is:

- authoritative;
- derived/rebuildable;
- transient;
- recovery evidence;
- legal/audit evidence;
- prohibited from containing sensitive fields.

Use minimization, field-level protection, pseudonymous stable IDs where appropriate, least privilege and bounded retention. Test deletion propagation and prove that replay cannot resurrect data contrary to policy. Do not put raw record samples in metric labels or lineage fields.

## Evidence table

| Question | Evidence | Proves | Does not prove |
|---|---|---|---|
| What exact input was processed? | snapshot/manifest/partition positions and digest | source identity/range | source truth completeness |
| Did parsing preserve records? | accepted/rejected counts and reasons | accounted parsing population | semantic correctness |
| Which computation ran? | artifact hash, config, plan, schema | selected definition | deterministic output |
| Is event-time progress healthy? | partition watermarks, lateness, idle state | engine progress estimate | no future late events |
| Is state recoverable? | completed checkpoint metadata and protected storage | snapshot persisted | successful compatible restore |
| Did restore work? | disposable restore/replay and output diff | tested version/topology | every failure or scale |
| Did sink commit once? | transaction/version/key and sink audit | sampled output commit | all consumer correctness |
| Is data fit for use? | assertion result, population, observed values | checked dimensions | untested invariants |
| Can impact be traced? | run/job/dataset/code lineage | recorded dependency path | lineage completeness itself |
| Is one partition limiting? | rows/bytes/top keys/task and dependency time | skew/local bottleneck | safe repartition |
| Can backlog drain? | arrival, sustainable completion, oldest age | measured recovery trend | quality |
| Is replay safe? | isolated output, pinned range/code, effects gated, diff | controlled replay | production promotion |
| Was private data governed? | copy inventory, policy, deletion/retention proof | tested handling | all historical copies absent |

## Command decoders

The offline model asks architecture questions; it does not run a data engine:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh evaluate baseline
bash lab.sh evaluate checkpoint-incompatible
bash lab.sh evaluate hot-partition
bash lab.sh evaluate replay-live-sink
```

Read `boundary=checkpoint-compatibility` as “the fixture states that retained state cannot be restored by the candidate.” Production evidence would include exact engine/connector versions, state serializer/operator identity, checkpoint ID, restore command, first error and rollback-build test.

Inspect without mutation:

```bash
bash lab.sh show lateness-too-short
```

The two numbers force a policy comparison. They are synthetic and do not measure your events.

Run:

```bash
bash verify.sh
```

The verifier evaluates 18 branches, refuses an unexpected artifact and proves exact temporary-state cleanup. It proves no Spark/Flink/Beam guarantee.

For a real platform, write a command contract before any restore, reset, backfill, savepoint, checkpoint deletion or live-sink replay:

```text
question and consumer impact:
job/run/source/output scope:
read-only command/API:
possible branches and proof limits:
next evidence:
mutation preconditions:
isolated target:
rollback:
reconciliation:
cleanup:
```

## Decision path

### Design

1. Name the consumer decision and acceptable freshness, completeness and correction.
2. Identify authoritative source, immutable version/positions and retention.
3. Declare bounded/unbounded input and event-time policy.
4. Version schema, code, config and reference data.
5. Choose partition/key/window/state from the invariant and distributions.
6. Select checkpoint/state storage and prove restore compatibility.
7. Choose sink commit semantics that survive repeated execution.
8. Define quality populations, assertions, severity and owned quarantine.
9. Capture lineage for start, partial, failure, completion and replay.
10. Size steady state, outage backlog, catch-up, checkpoint and replay headroom.
11. Govern every raw/state/checkpoint/quarantine/output copy.
12. Fault-test and reconcile the consumer outcome.

### Incident

```text
consumer harm?
  -> contain publication/replay; preserve input/checkpoint/output evidence
  -> bind dataset/job/run/code/schema/source range
  -> find first divergence: source | parse | transform | time/state
                           | checkpoint | sink | quality | lineage
  -> recover into isolated output
  -> quality + reconciliation + privacy validation
  -> reviewed promotion
```

### Recovery arithmetic

If an outage lasts `T` seconds at arrival rate `lambda`, backlog is approximately `B=lambda*T`. With sustainable bottleneck completion `mu` and continuing arrival, ideal drain is:

```text
B / (mu - lambda), only when mu > lambda
```

Include late events, retries, checkpoint I/O, quality, lineage and sink quotas. Calculate for the hottest partition and slowest operator, not only aggregate cluster throughput.

## Guided Ubuntu lab

### Safety

Run only from the lesson's `support/lab` directory as a normal Ubuntu 24.04 user. The lab refuses root and credential hints. It creates one exact UID-scoped directory under `/tmp`, uses no network and deletes only its sentinel and copied fixture after validating ownership and inventory.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected status contains `cases=18 network=none`. A pre-existing path is refused, not overwritten.

### Read failure boundaries

```bash
bash lab.sh evaluate source-not-replayable
bash lab.sh evaluate sink-not-idempotent
bash lab.sh evaluate idle-input-unhandled
bash lab.sh evaluate state-retention-too-short
bash lab.sh evaluate lineage-incomplete
bash lab.sh evaluate backlog-no-drain
```

Translate:

| Boundary | Human meaning |
|---|---|
| `source-replay` | checkpoint recovery asks for data the source cannot reproduce |
| `sink-duplicate` | repeated processing may create repeated output |
| `watermark-idleness` | one input can stall event-time progress |
| `state-horizon` | required recovery outlives retained state/evidence |
| `lineage-gap` | impact and reproduction cannot connect all inputs/outputs |
| `recovery-drain` | capacity cannot meet the declared recovery window |

Change only the copied fixture if experimenting. Predict which boundary will become first; then evaluate. This teaches that a design can have multiple weaknesses while an incident path often stops at the first unsafe dependency.

Finish:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line is `verify=pass cases=18 refusal=true cleanup=true`. This is teaching-model evidence only.

## Production transfer

### Representative disposable pipeline

A reviewer should provide a small but real local engine, replayable input and transactional/versioned output. The learner must discover versions and configuration rather than receive a recipe.

Required faults:

1. crash before and after checkpoint completion;
2. sink commit succeeds but acknowledgement is lost;
3. checkpoint state schema/operator identity changes;
4. one source partition goes idle, then returns late data;
5. one key creates a skewed partition;
6. sink slowdown creates backpressure and checkpoint delay;
7. one schema and one semantic quality failure;
8. lineage delivery is missing for one failed run;
9. replay targets an isolated sink and compares with live;
10. privacy deletion remains deleted after replay.

For each, predict, inject, observe, recover, reconcile and clean up. Evidence includes exact source ranges, checkpoint IDs, plans, task/subtask distributions, output versions, quality results and lineage.

### Incident: revenue incomplete despite green jobs

Contain consumer promotion for the affected partition/date, not necessarily the whole platform. Preserve source manifests/positions, job event history, code/config/schema, checkpoints, sink versions and quality results.

Build a reconciliation table by source business key:

| Classification | Meaning | Action |
|---|---|---|
| absent from captured source | extraction/source boundary | repair source/export then replay |
| rejected by parser | schema/value boundary | quarantine owner decides correct/reject |
| lost by transform/join | logic/key/time boundary | fix versioned transform and replay |
| output commit missing | sink/transaction boundary | repeat safely under stable output identity |
| output present, consumer stale | catalog/cache/serving boundary | repair publication/invalidation |
| duplicate output | recovery/idempotency boundary | reconcile and implement stable key/version |

Never infer absence from a sample query alone. Bind population, snapshot and partition filters.

### Incident: checkpoint storm under backpressure

Capture per-subtask busy/idle/backpressured time, input/output rate, sink latency/quota, checkpoint start delay/alignment/snapshot/upload time, state bytes, network buffers, task duration and failure reason.

If the sink is slower than input, reduce/admit input, restore sink capacity or change the output path. Scaling stateless upstream work can worsen pressure. If one hot key dominates, repartitioning count alone may not split it. Consider unaligned checkpoints only after confirming alignment behind buffers and testing added state-store I/O plus recovery semantics.

Recovery is not “one checkpoint completed.” Prove newest-checkpoint age remains within objective, a restore succeeds, output has no duplicate/gap, backlog drains, quality holds and consumer freshness recovers.

### Backfill change plan

```text
scope: exact input snapshots/positions and affected outputs
versions: code, config, schema, reference datasets, engine/connectors
target: isolated output namespace/version
effects: disabled or idempotently gated
capacity: rate below reserved live headroom
privacy: current deletion/retention policy applied
quality: assertions and reconciliation populations
lineage: replay run linked to original and reason
promotion: reviewed atomic pointer/version change
rollback: previous consumer pointer retained
cleanup: isolated artifacts and temporary compute proved absent
```

## Reliability, security, observability, capacity, and cost

### Reliability

Define data-product SLIs:

- freshness: eligible partitions available within objective;
- completeness: required source facts represented or explained;
- correctness: invariant/reconciliation success;
- uniqueness: stable output identity count;
- availability: successful reads for the published version;
- correction latency: late/bad data repaired within objective;
- lineage coverage: outputs with complete source/run/code links.

Engine uptime is a supporting indicator. A stopped pipeline can serve last-known-good data; a running pipeline can rapidly publish corruption.

### Security and privacy

Authenticate and authorize source, checkpoint, state, sink, quarantine, catalog and lineage separately. Engine workers should have only the partitions and operations required. Separate publication approval from raw-data write where risk requires.

Encrypt in transit and at rest, but also control who can infer sensitive data from metrics, plans, logs, lineage and rejected samples. Treat checkpoint/savepoint access as sensitive: state may contain raw values and credentials must never be serialized into it.

Apply deletion and retention to every copy. Audit replay and manual quality overrides. A backfill is privileged because it can rewrite history and re-expose data.

### Observability

Use four evidence planes:

- **execution:** job/stage/task/operator/subtask and restart;
- **data:** records/bytes/schema/time/windows/state/output;
- **quality:** assertions, distributions, quarantine and reconciliation;
- **lineage:** source/job/run/code/output and consumers.

Correlate with `job_id`, `run_id`, `dataset_namespace/name/version`, `source_range`, `artifact_hash`, `schema_version`, `checkpoint_id` and `output_version`. Keep high-cardinality values out of ordinary metric labels; use logs, exemplars or lineage records.

Page on actionable user risk: freshness/completeness burn, failed restores, no recent valid checkpoint, unrecoverable source horizon, blocking quality failure, replay touching live output or privacy mismatch. Ticket slower lineage gaps and nonblocking quality drift with owners.

### Capacity

Model:

```text
source read -> parse -> shuffle/join/state -> checkpoint store
           -> sink -> quality -> lineage -> consumer
```

The minimum sustainable capacity across required stages is the service rate. Include:

- largest/hottest partition, not just totals;
- p99 record expansion and state per key;
- shuffle/network/spill and small-file overhead;
- checkpoint and compaction I/O;
- dependency and sink quotas;
- retry/restart/backfill traffic;
- quality and reconciliation scans;
- scheduler startup and autoscaling delay.

Reserve headroom for recovery. A platform at 90% sustainable sink capacity needs about 10x as long as the outage to drain an equal-rate backlog, even before overhead.

### Cost

Track unit cost per useful data product: input/output bytes, compute time, shuffle, state/checkpoint storage, object requests, retained copies, quality scans, lineage volume and support effort.

Cheap changes can increase risk:

- longer checkpoint intervals reduce I/O but increase recovery/replay;
- short source retention reduces storage but can make restore impossible;
- tiny files reduce write buffering but explode metadata/listing;
- indefinite raw/checkpoint retention violates privacy and grows cost;
- aggressive quality scanning improves detection but competes with live work;
- duplicate reprocessing can double provider/storage bills.

Optimize against SLO and correctness, with sensitivity analysis for volume, skew, outage and retention.

## Traps and prevention

### Trap: job success equals data success

**Prevention:** gate consumer publication on data-product quality and reconciliation, not process exit alone.

### Trap: checkpoint existence equals recovery

**Prevention:** restore regularly with exact engine/code/state versions, source positions and sink comparison; test rollback too.

### Trap: watermark equals complete

**Prevention:** treat it as an estimate; define lateness, corrections, idleness and consumer finality explicitly.

### Trap: exactly once without boundaries

**Prevention:** name replayable source, state/checkpoint and sink transaction/idempotency assumptions; exclude unsupported external effects.

### Trap: more workers fix skew

**Prevention:** measure hottest keys/partitions and change distribution or logic with semantic proof.

### Trap: quarantine forever

**Prevention:** owner, severity, response objective, retention, privacy, repair/reject decision and controlled redrive.

### Trap: lineage proves correctness

**Prevention:** use lineage to navigate evidence and impact; use quality/reconciliation to test meaning.

### Trap: backfill the live sink

**Prevention:** isolated version, pinned inputs/code, gated effects, bounded rate, quality/diff, reviewed promotion and rollback.

### Trap: retention only at the source

**Prevention:** inventory raw, broker, shuffle, state, checkpoints, quarantine, outputs, cache, lineage and backups.

## Memory card and retrieval

Remember:

```text
source identity -> deterministic computation -> recoverable state
-> replay-safe sink -> quality -> lineage -> consumer proof
```

And:

```text
event time != processing time
watermark != proof of completeness
checkpoint != tested restore
job success != correct data
lineage != quality
replay != safe promotion
```

Ask from memory tomorrow:

1. What conditions make engine replay end-to-end safe?
2. How can one idle partition stall windows?
3. Why can enabling unaligned checkpoints be the wrong fix?
4. What evidence distinguishes missing source data from a bad join?
5. Why does a backfill need an isolated sink?
6. Which copies must a privacy-deletion policy cover?

## Complete answers

### 1. What makes replay safe?

Replay needs the exact retained source range, stable source positions, versioned and deterministic transform inputs, compatible state/checkpoint or an intentional rebuild, compatible schema, and a sink that makes repeated output transactional, versioned or idempotent. Reference datasets and policy must be pinned when historical meaning depends on them. The replay target is isolated, external effects are gated, rate fits residual capacity, lineage distinguishes the run, quality/reconciliation passes, privacy policy is applied and promotion has rollback.

If any input is “whatever is current now,” replay may be a new computation rather than reproduction.

### 2. Does a checkpoint guarantee exactly once?

No. A checkpoint can coordinate engine source positions and operator state under documented conditions. End-to-end behavior also depends on source replay, connector semantics, deterministic computation and sink commit. A non-idempotent HTTP sink can repeat an effect after recovery. A retained checkpoint can be incompatible with new code. State stored locally can vanish. State the guarantee with its exact source-engine-sink boundary.

### 3. How do watermarks and lateness work?

Event time says when a fact occurred. The watermark estimates how far event-time progress has advanced. A window trigger may emit when the watermark passes its end. A record with earlier event time arriving afterward is late. Allowed-lateness and accumulation policy decide whether to update the result, emit a correction, quarantine or drop it and when state can be removed.

The policy balances latency, completeness, state size and correction cost. Measure real delay distributions and consumer needs; do not copy a five-minute watermark because it looks normal.

### 4. How do you debug one long-running task?

Compare that task with peers: input rows/bytes, key frequencies, file splitability, shuffle read/write, spill, GC, record expansion, CPU and dependency time. Inspect the physical plan around exchanges and joins. If one key dominates, adding executors does not split one key's state. Correct null/default keys, pre-aggregate, use a safe salt-and-merge technique, isolate the hot key, split input or select a different join/partition strategy. Validate output equivalence.

### 5. Backpressure or no input?

Use per-subtask busy, idle and backpressured time plus input/output rate. An idle operator awaits input. A busy operator computes. A backpressured operator cannot emit because downstream buffers are unavailable. Trace downstream until the first slow/busy dependency or sink. Aggregate CPU cannot distinguish these.

### 6. Aligned versus unaligned checkpoint?

Aligned checkpoint barriers wait until earlier records on input channels are processed consistently, so heavy backpressure can delay them. An unaligned checkpoint can include in-flight buffered data so barriers overtake pressure. This adds checkpoint bytes and I/O and has documented topology, ordering and watermark considerations. Use it only when measurements show barrier alignment is the bottleneck and checkpoint storage/recovery can handle the added state. It does not increase a slow sink's service rate.

### 7. How should a quality failure behave?

It depends on consumer harm. Define the exact dataset population, assertion, threshold, observed value and severity. A critical financial uniqueness failure can block publication and page an owner. A noncritical optional-field drift may publish with warning. Invalid records can quarantine only if ownership, retention, privacy, ordering and redrive are defined. Always account for accepted plus rejected populations and record the result in lineage.

### 8. What does complete lineage contain?

Identified input and output datasets/versions, job definition, run ID and lifecycle, code artifact, configuration, schema, source ranges/partitions, transformation/parent relationships, quality results and responsible agent/team. It should include failed and replay runs, not only successes. Complete lineage aids reproduction and impact analysis; it cannot certify that transform logic is correct.

### 9. How do you size recovery?

Calculate backlog from arrival during outage. Divide by spare sustainable throughput at the slowest required stage, including continuing demand. Then add restart, restore, checkpoint, late-data, retry, quality and reconciliation time. Check hottest-partition capacity and compare the result with source/state/checkpoint retention and the consumer SLO. If service is not greater than arrival, there is no drain.

### 10. How do you prevent deletion resurrection?

Maintain lineage and a copy inventory. Apply deletion/tombstone policy to raw, state, checkpoints, quarantine, derived outputs, caches and replay inputs according to legal design. Ensure replay reads the current deletion policy or an approved privacy-safe historical representation. Test a deletion, run a backfill and verify the subject does not reappear in published output while required audit evidence remains appropriately protected.

## Product-company interview

### “Design a reliable real-time fraud feature pipeline.”

Start with the decision: fraud scoring needs bounded freshness, known late correction and no cross-tenant leakage. Identify replayable event sources and stable IDs. Use event time and per-source watermark/idleness based on observed delay. Key by the invariant entity while measuring hot accounts. Maintain versioned state and durable checkpoints. Make the feature sink upsert by entity, feature definition and event/source revision. Version schemas, code and reference data. Define quality for completeness, range, uniqueness and freshness. Capture lineage from source ranges through run/model-feature version. Isolate backfill, gate serving promotion, reconcile against authoritative ledgers, and capacity-test outage catch-up plus state/checkpoint storage.

### “Spark/Flink says exactly once. Are we done?”

No. Ask which mode, sources, connectors, checkpoint store and sinks the claim covers. Verify source replay positions, state durability/compatibility and transactional/idempotent output. External databases/APIs may weaken the boundary. Restore and sink-failure testing plus reconciliation are required.

### “Our pipeline is slow; should we add executors?”

First identify whether the bottleneck is input, CPU, skew, shuffle/spill, state/checkpoint I/O, backpressure or sink quota. More executors help parallel work but not a single hot key, unsplittable file, serial stage or fixed downstream quota. Use per-partition/task evidence and the physical plan, then change the limiting mechanism.

### “How would you run a backfill safely?”

Exact source range; pinned code/config/schema/reference versions; isolated output; effects gated; resource quota below live headroom; current privacy policy; explicit quality/reconciliation; lineage linked to reason/original runs; reviewed atomic promotion; previous version retained for rollback; exact cleanup.

### “What should page the data on-call?”

User-impacting freshness/completeness/error-budget burn, no restorable recent checkpoint before source expiry, blocking financial/security quality failure, rapidly growing unrecoverable backlog, replay writing live output or privacy-policy violation. A single bad optional row may be quarantined/ticketed instead, depending on policy.

### “What is the difference between data quality and observability?”

Observability supplies evidence about execution and data behavior. Quality evaluates declared fitness rules for a population and consumer use. Metrics showing a null rate are observability; a versioned rule saying which null rate is acceptable, why, with severity and action is quality. Reconciliation against an authority tests a business invariant beyond generic health.

### Senior answer pattern

Lead with consumer invariant and source authority. State source/position, time/window, computation/state/checkpoint, sink, quality/lineage and publication boundaries. Quantify skew and drain. Explain failure/replay/privacy paths and rejected alternatives. End with user-level validation, not a tool list.

## Independent transfer and rubric

A reviewer supplies an unfamiliar batch/stream pipeline packet with synthetic data, a hidden skew, checkpoint history, event-time delay, schema/quality changes, sink behavior, lineage gaps and one consumer incident.

Deliver:

1. consumer decision, data-product SLI and authority map;
2. bounded/unbounded and batch/stream choice;
3. event/ingest/processing-time, watermark/window/trigger/lateness policy;
4. source identity and replay contract;
5. transform plan, partition/skew and deterministic-version contract;
6. state/checkpoint storage, compatibility, restore and rollback plan;
7. sink commit/idempotency and output-promotion design;
8. quality assertions, quarantine, reconciliation and lineage;
9. security/privacy/retention, capacity/cost and observability;
10. fault recovery, isolated replay, validation and cleanup.

The reviewer changes scale, delay distribution, sink semantics, privacy retention or one schema. Revise and defend after a delay.

| Criterion | Points | Observable evidence |
|---|---:|---|
| consumer and authority | 10 | decision, SLI, source/output ownership |
| time and collection model | 10 | boundedness, windows, watermarks, lateness |
| reproducibility | 10 | source range, code/config/schema/reference versions |
| state and recovery | 10 | checkpoint durability, compatibility, restore and rollback |
| sink correctness | 10 | transaction/version/idempotency and crash test |
| quality and lineage | 10 | assertions, disposition, run/job/dataset links |
| performance and capacity | 10 | plan, skew, backpressure and drain arithmetic |
| security/privacy/lifecycle | 10 | least privilege, copy inventory, deletion and retention |
| incident and replay | 10 | containment, isolated output, reconciliation and promotion |
| transfer judgment | 10 | changed constraint, delayed defense and exact cleanup |

Maximum 100. Reading and the offline model do not award mastery.

## References and review

Primary sources reviewed 2026-08-05:

1. [Spark Structured Streaming](https://spark.apache.org/docs/latest/streaming/index.html) — incremental, micro-batch, checkpoint and processing-mode semantics.
2. [Spark SQL performance tuning](https://spark.apache.org/docs/latest/sql-performance-tuning.html) — partitions, statistics, joins, adaptive execution and skew.
3. [Spark monitoring](https://spark.apache.org/docs/latest/monitoring.html) — metrics, event history and streaming progress.
4. [Flink checkpointing](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/fault-tolerance/checkpointing/) — source/storage prerequisites and configured guarantees.
5. [Flink backpressure monitoring](https://nightlies.apache.org/flink/flink-docs-stable/docs/ops/monitoring/back_pressure/) — busy, idle and backpressured evidence.
6. [Flink watermarks](https://nightlies.apache.org/flink/flink-docs-stable/docs/dev/datastream/event-time/generating_watermarks/) — event-time progress, idleness and alignment.
7. [Flink state backends](https://nightlies.apache.org/flink/flink-docs-stable/docs/ops/state/state_backends/) — working state, storage and recovery trade-offs.
8. [Flink task failure recovery](https://nightlies.apache.org/flink/flink-docs-stable/docs/ops/state/task_failure_recovery/) — restart and failover behavior.
9. [Flink checkpointing under backpressure](https://nightlies.apache.org/flink/flink-docs-stable/docs/ops/state/checkpointing_under_backpressure/) — alignment, in-flight state and limitations.
10. [Flink large-state tuning](https://nightlies.apache.org/flink/flink-docs-stable/docs/ops/state/large_state_tuning/) — checkpoint scale and catch-up capacity.
11. [Apache Beam programming guide](https://beam.apache.org/documentation/programming-guide/) — bounded/unbounded data, windows, triggers and lateness.
12. [OpenLineage specification](https://github.com/OpenLineage/OpenLineage/blob/main/spec/OpenLineage.md) — run, job, dataset and facet identities.
13. [OpenLineage data-quality assertions](https://openlineage.io/docs/spec/facets/dataset-facets/data_quality_assertions/) — assertion outcomes linked to datasets.
14. [W3C Data Quality Vocabulary](https://www.w3.org/TR/vocab-dqv/) — metrics, measurements, policies and provenance.
15. [W3C PROV-O](https://www.w3.org/TR/prov-o/) — entities, activities, agents and derivation.

Review status: substantive draft. Exact URLs resolved during the source audit. Direct schemas, static lab checks, canonical regressions and the production build are required before checkpoint. Ubuntu runtime, real engine/connectors/storage/sink, representative load/faults, formal review, reviewer transfer, delayed recall, publication and learner evidence remain separate.
