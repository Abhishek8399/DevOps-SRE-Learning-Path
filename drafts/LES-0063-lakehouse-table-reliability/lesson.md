---
{"schemaVersion":1,"kind":"lesson","id":"LES-0063","slug":"lakehouse-table-reliability","aliases":["V06-L08","lakehouse-table-reliability"],"curriculumIds":["DMP-002"],"route":"/book/state/lakehouse-table-reliability","order":8,"volume":"06-state-distributed-systems","title":"Lakehouse table reliability: prove catalogs, snapshots, plans, and maintenance","summary":"Operate Trino and Iceberg-shaped lakehouse systems by tracing catalog authority, atomic table snapshots, manifests, file statistics, schema and partition evolution, query plans, compaction, retention, security, recovery, capacity and cost.","domain":"state","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0056","LES-0058","LES-0062"],"prerequisiteCurriculumIds":["DST-002","DST-005","LNX-006"],"testedEnvironments":[{"platform":"Official documentation","version":"Trino 483 and Apache Iceberg 1.11.0 sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, engine, catalog, object store, table or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","data-engineer","data-platform-engineer","analytics-engineer","solutions-architect","technical-lead"],"learningObjectives":["Trace an analytic query from consumer decision through Trino coordinator, plan, stages, tasks, connector, catalog metadata, Iceberg snapshot tree and selected files.","Separate table-format metadata, catalog authority, object storage, compute engine and governance ownership.","Explain Iceberg metadata JSON, snapshots, manifest lists, manifests, data files and delete files without treating a directory listing as table truth.","Reason about atomic commits, optimistic concurrency, conflict validation, retries, orphan files and ambiguous outcomes.","Evaluate reader/writer support before enabling a table format version or feature.","Evolve schemas by stable field identity and partition/sort layouts without binding queries to physical paths.","Diagnose planning latency, poor pruning, skew, small files, delete amplification, stale statistics, exchange pressure and connector bottlenecks.","Design compaction, manifest rewrite, snapshot expiration and orphan cleanup from measured triggers and safe retention horizons.","Protect rollback, time travel, legal hold, privacy deletion and in-flight writers with explicit snapshot/reference policy.","Use EXPLAIN and EXPLAIN ANALYZE as different evidence, including the risk that ANALYZE executes the statement.","Separate query retry, task retry, table commit and client acknowledgement semantics.","Apply workload isolation, least privilege, audit/lineage, SLOs, capacity and unit-cost controls to a shared lakehouse."],"productionSignals":["consumer decision and data-product SLI","query ID user source client tags resource group and attempt","analysis planning queued execution blocked CPU and wall time","plan fragment stage task split operator and exchange","input/output rows bytes files partitions manifests and snapshots","catalog namespace table metadata location current snapshot and sequence","snapshot parent operation schema ID partition spec and commit summary","manifest count size pruning ratio and planning latency","data/delete file count bytes size distribution and read amplification","predicate dynamic filter partition/file pruning and scanned-to-returned ratio","join distribution build/probe size skew spill and exchange bytes","worker active/lost count memory CPU disk network and task failures","retry policy exchange storage bytes latency errors and encryption","writer base snapshot candidate metadata conflict retry and final commit","schema field IDs format version reader/writer compatibility","partition/sort spec versions and distribution by layout","compaction input/output files bytes duration conflicts and benefit","snapshot/reference age retention legal hold rollback and time-travel demand","orphan scan roots path normalization cutoff candidates and deletion result","authorization decision principal action catalog schema table column and policy version","audit/lineage query run snapshot source files code policy and output","object requests metadata reads/listings bytes scanned compute time and unit cost"],"diagrams":[{"id":"LES-0063-DIA-001","title":"Consumer-to-file query evidence path","direction":"left-to-right","boundaries":["consumer decision","Trino coordinator","distributed plan","workers and connector","catalog authority","table metadata and snapshot","manifests","selected data/delete files"],"evidencePoints":["SLI","query ID","plan","stage/task/split","catalog/table","snapshot ID","manifest pruning","file scan"],"textAlternative":"An analytic answer is produced by a distributed query plan that resolves an authoritative table snapshot and selects files through its metadata tree."},{"id":"LES-0063-DIA-002","title":"Iceberg metadata tree","direction":"hierarchical","boundaries":["catalog pointer","table metadata JSON","snapshot","manifest list","manifests","data files","delete files"],"evidencePoints":["metadata location","current snapshot","parent and sequence","manifest path","file metrics","content type"],"textAlternative":"The catalog identifies current table metadata, which identifies a snapshot, its manifest list, manifests and the exact data and delete files in table state."},{"id":"LES-0063-DIA-003","title":"Optimistic table commit","direction":"left-to-right","boundaries":["read base snapshot","write candidate files","write candidate metadata","validate requirements/conflicts","atomic catalog pointer swap","acknowledge or reconcile"],"evidencePoints":["base snapshot","new files","candidate metadata","requirements","committed snapshot","operation ID"],"textAlternative":"Writers prepare immutable files, validate the base state and publish by atomically replacing the authoritative metadata pointer; ambiguous acknowledgement requires reconciliation."},{"id":"LES-0063-DIA-004","title":"Evolution compatibility matrix","direction":"hierarchical","boundaries":["field identity","schema version","partition spec","sort order","format version","writer capability","reader capability"],"evidencePoints":["field ID","schema ID","spec ID","sort ID","format version","engine/connector version"],"textAlternative":"Safe evolution requires stable field identity and every active reader and writer to understand the chosen schema, partition, sort and format features."},{"id":"LES-0063-DIA-005","title":"Maintenance and retention safety","direction":"left-to-right","boundaries":["measured table condition","isolated maintenance plan","new snapshot","validation","retention/reference graph","safe expiration","orphan cutoff"],"evidencePoints":["file distribution","candidate scope","snapshot ID","query comparison","rollback horizon","live references","oldest writer"],"textAlternative":"Compaction and metadata rewrites publish new snapshots; expiration and orphan deletion happen only after validation and retention/reference safety checks."},{"id":"LES-0063-DIA-006","title":"Query performance and workload path","direction":"hierarchical","boundaries":["predicate","catalog/metadata planning","manifest/file pruning","splits","scan","exchange/join","resource group","consumer result"],"evidencePoints":["plan","planning latency","selected files","bytes scanned","skew","blocked time","queue/concurrency","result SLI"],"textAlternative":"Query cost and latency emerge from metadata planning, pruning, split distribution, scans, exchanges and workload policy—not from worker CPU alone."}],"commands":[{"id":"LES-0063-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0063 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"Trino or Iceberg behavior"},{"id":"LES-0063-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"lakehouse setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0063-CMD-003","question":"Does the baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0063 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0063-CMD-004","question":"Who owns current table state?","risk":"read-only","command":"bash lab.sh evaluate catalog-not-authoritative","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=catalog-authority","meaning":"no trusted current-metadata authority exists","nextEvidence":"define catalog and atomic pointer owner"}],"proves":"encoded authority gap","doesNotProve":"catalog behavior"},{"id":"LES-0063-CMD-005","question":"Is the snapshot metadata closure intact?","risk":"read-only","command":"bash lab.sh evaluate manifest-incomplete","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=manifest-closure","meaning":"snapshot cannot resolve its complete file set","nextEvidence":"preserve metadata and inspect references"}],"proves":"encoded closure gap","doesNotProve":"object integrity"},{"id":"LES-0063-CMD-006","question":"Can all active engines read the chosen format?","risk":"read-only","command":"bash lab.sh evaluate reader-format-incompatible","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=format-compatibility","meaning":"a reader lacks required feature support","nextEvidence":"compatibility matrix or delayed upgrade"}],"proves":"encoded compatibility gap","doesNotProve":"connector support"},{"id":"LES-0063-CMD-007","question":"Can cleanup race a live writer?","risk":"read-only","command":"bash lab.sh evaluate orphan-cleanup-races-writer","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=orphan-retention","meaning":"cutoff overlaps possible in-flight files","nextEvidence":"increase horizon and prove writer bounds"}],"proves":"encoded retention race","doesNotProve":"safe deletion"},{"id":"LES-0063-CMD-008","question":"Does file layout create planning and open cost?","risk":"read-only","command":"bash lab.sh evaluate small-files","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=small-files","meaning":"average file size is below measured policy","nextEvidence":"scoped compaction plan"}],"proves":"encoded file-size gap","doesNotProve":"query improvement"},{"id":"LES-0063-CMD-009","question":"Do delete files dominate reads?","risk":"read-only","command":"bash lab.sh evaluate delete-files-dominate","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=delete-amplification","meaning":"delete-file ratio exceeds policy","nextEvidence":"rewrite candidate and correctness test"}],"proves":"encoded read-amplification gap","doesNotProve":"engine performance"},{"id":"LES-0063-CMD-010","question":"Will the query exceed its scan budget?","risk":"read-only","command":"bash lab.sh evaluate scan-budget-exceeded","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=scan-budget","meaning":"planned scan exceeds consumer budget","nextEvidence":"predicate/pruning/layout/plan diagnosis"}],"proves":"encoded cost boundary","doesNotProve":"runtime bytes"},{"id":"LES-0063-CMD-011","question":"Is maintenance isolated from interactive work?","risk":"read-only","command":"bash lab.sh evaluate maintenance-not-isolated","runFrom":"LES-0063 support/lab","expectedBranches":[{"when":"boundary=workload-isolation","meaning":"maintenance can consume shared critical capacity","nextEvidence":"resource group and admission design"}],"proves":"encoded isolation gap","doesNotProve":"scheduler enforcement"},{"id":"LES-0063-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0063 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"twenty branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"Trino Iceberg catalog object-store snapshot manifest query compaction retention load or production behavior","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0063-LAB-001","title":"Guided lakehouse/table boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0063-lakehouse-table-reliability/support/lab"},{"id":"LES-0063-LAB-002","title":"Independent Trino/Iceberg table and query recovery transfer","mode":"independent","environment":"Reviewer-owned disposable local engine, catalog, storage and synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic catalog/table/snapshots/files and query artifacts","disposable workload and maintenance state","approved faults and recovery evidence"],"abortConditions":["shared service","real credential","customer data","host network/clock mutation","unbounded query/cleanup","unknown ownership"],"recovery":"Preserve query/table histories and reset through the reviewer harness.","cleanupProof":"Reviewer proves processes, ports, files, volumes, catalog objects and data absent.","path":"drafts/LES-0063-lakehouse-table-reliability/support/lab"}],"incidents":[{"id":"LES-0063-INC-001","signal":"Queries suddenly return different row counts although the data directory looks unchanged.","firstThought":"Directory contents are not table state; catalog pointer, snapshot, manifests, delete files or reader compatibility may have changed.","safePath":"Bind query ID to catalog/table metadata location, snapshot ID, manifest closure, selected data/delete files and consumer reconciliation.","trap":"Repair the table from an object-store directory listing."},{"id":"LES-0063-INC-002","signal":"A failed writer left files and retry reports an unknown commit outcome.","firstThought":"Prepared immutable files and committed table state are separate; acknowledgement may be lost after the atomic pointer swap.","safePath":"Preserve operation/base/candidate metadata IDs, reload catalog authority, reconcile whether candidate snapshot committed, then retry idempotently or classify true orphans after a safe horizon.","trap":"Delete new files or blindly rerun the write."},{"id":"LES-0063-INC-003","signal":"Planning takes minutes and workers are mostly idle.","firstThought":"Catalog latency, metadata growth, manifests, missing pruning or excessive files can bottleneck before scan tasks exist.","safePath":"Separate analysis/planning/execution, inspect snapshot/manifest/file counts and predicate-to-pruning evidence, then target metadata or layout.","trap":"Add workers to a coordinator/metadata bottleneck."},{"id":"LES-0063-INC-004","signal":"Maintenance improves one query but breaks rollback and overwhelms interactive users.","firstThought":"Compaction, rewrite and expiration have different correctness, retention and capacity effects and were not isolated.","safePath":"Stop maintenance, preserve references/snapshots, confirm new snapshot and old rollback anchors, reconcile queries, restore workload isolation and revise measured trigger/capacity policy.","trap":"Expire more snapshots to reduce metadata faster."},{"id":"LES-0063-INC-005","signal":"After an engine upgrade, one reader returns null/wrong columns or refuses the table.","firstThought":"Field identity, schema/format feature, partition spec or connector support is incompatible across active readers/writers.","safePath":"Freeze writes, capture table format/schema/spec IDs and engine/connector matrix, restore compatible reader or snapshot, then stage a governed upgrade.","trap":"Rename files or columns in storage paths."}],"assessmentIds":["ASM-0172","ASM-0173","ASM-0174"],"referenceIds":["REF-0703","REF-0704","REF-0705","REF-0706","REF-0707","REF-0708","REF-0709","REF-0710","REF-0711","REF-0712","REF-0713","REF-0714","REF-0715","REF-0716","REF-0717"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not Trino, Iceberg, a catalog, metastore, object store, distributed query engine, table-format implementation, authorization service, workload manager or benchmark.","Synthetic decisions do not prove engine, connector, catalog, storage, snapshot, manifest, file, query, transaction, evolution, maintenance, security or recovery behavior.","No socket, service, dataset, table, snapshot, manifest, file, query, commit, compaction, cleanup, load or external resource exists.","Semantics, defaults, limits, feature support and metrics are version-, connector-, catalog-, storage-, configuration- and topology-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Lakehouse table reliability: prove catalogs, snapshots, plans, and maintenance

## What you see and first thought

The query engine is healthy. Workers are idle. A dashboard query spends four minutes planning, scans ten times more data than yesterday, and returns a row count that disagrees with finance.

Do not begin with “add workers” or “the object store is slow.” A lakehouse answer crosses several independent systems:

```text
consumer question
  -> SQL session and authorization
  -> coordinator analysis and distributed plan
  -> connector
  -> catalog's authoritative table pointer
  -> table metadata and chosen snapshot
  -> manifest list and manifests
  -> selected data and delete files
  -> worker scans, exchanges and operators
  -> result and consumer reconciliation
```

The engine can be healthy while the table points to the wrong snapshot. The table can be correct while planning is slow because metadata exploded. Planning can be fast while workers scan too much because predicates do not prune. The query can finish successfully while a schema-compatibility mistake changes meaning.

Keep this first thought:

> A directory full of files is storage inventory. A lakehouse table is an authoritative metadata graph that names one committed snapshot and the exact files that belong to it.

During an incident, name the user operation before the component:

1. Which consumer decision is late or wrong?
2. Which query ID, user, source and session produced it?
3. Which catalog, schema, table and snapshot did the query resolve?
4. Which metadata file, manifest list, manifests, data files and delete files formed that snapshot?
5. Which plan fragments, stages, tasks, splits and exchanges performed the work?
6. Which change—write, schema evolution, partition evolution, compaction, expiration, engine upgrade or policy change—occurred?
7. Which independent evidence proves correctness after recovery?

That sequence prevents an operational reflex from mutating the only useful evidence.

## Terms before commands

### Data lake, warehouse, lakehouse, and table format

A **data lake** usually stores data in scalable file or object storage. Storage is economical and open, but a directory hierarchy alone does not provide atomic multi-file table changes, safe schema evolution or consistent snapshots.

A **data warehouse** usually combines managed storage, table metadata, SQL execution and workload management behind one service boundary. This can simplify ownership, but it may couple data to one system.

A **lakehouse** is an architecture, not one product. It keeps data in file/object storage while adding table metadata and transactional rules so multiple engines can treat collections of immutable files as evolving tables.

An **open table format** defines the persistent metadata and data-file contract. Apache Iceberg is one example. Trino is a distributed SQL query engine, not a table format or object store. A catalog is not the data plane. These distinctions matter because each boundary can fail independently.

### Catalog, namespace, table, and metadata pointer

A **catalog** maps a logical table identity to authoritative table metadata. In Trino, “catalog” also names a configured connector instance, so always clarify whether you mean the Trino catalog configuration or the external table catalog service.

A **namespace** groups tables, often presented as a schema or database. It is an organizational and authorization boundary, not proof that all tables share storage or transactions.

For an Iceberg-shaped table, the catalog identifies the current table metadata location. That metadata records schemas, partition specs, properties, snapshots and which snapshot is current. Replacing this pointer atomically is the publication boundary for a table commit.

If two engines use different catalogs or stale cached pointers for what humans call “the same table,” they can observe different histories. A copied metadata file does not become authoritative merely because it exists.

### Snapshot, manifest list, manifest, data file, and delete file

A **snapshot** represents table state at a point in its history. It has an identity, usually a parent, an operation summary and a manifest-list reference.

A **manifest list** belongs to one snapshot and lists manifests with summary information that helps pruning.

A **manifest** lists a subset of data files or delete files. It includes partition tuples, file-level metrics and tracking state. Manifests are immutable and may be reused across snapshots.

A **data file** stores rows in a columnar format such as Parquet, ORC or Avro. A **delete file** represents rows removed by position or equality in table format versions that support row-level deletes. Readers may need to combine data and delete files, which creates read amplification.

The table is not “all files under the prefix.” It is the closure reachable from the authoritative metadata pointer:

```text
catalog pointer
  -> metadata JSON
     -> current snapshot
        -> manifest list
           -> manifests
              -> data files
              -> delete files
```

An unreferenced file may be an abandoned writer artifact, but it may also belong to an in-flight write that has not committed yet. That is why orphan cleanup needs a safe age horizon.

### Coordinator, worker, stage, task, split, and exchange

The Trino **coordinator** parses SQL, analyzes names and types, asks connectors for metadata and splits, creates a distributed plan, schedules work and returns results.

A **worker** executes tasks. A **stage** is one section of a distributed plan. Each stage becomes tasks across workers. A **split** is a unit of source work supplied by a connector, often corresponding to a file or portion of a file. An **exchange** moves intermediate data between stages for joins, aggregations, repartitioning or final collection.

Adding workers helps only when executable work exists and the bottleneck scales with workers. It does not automatically fix coordinator CPU, catalog latency, object-store throttling, one hot partition, a broadcast that is too large, a single final stage or millions of tiny files.

### Metadata authority versus object-store inventory

Object storage tells you which objects a listing returned. Table metadata tells you which files a committed snapshot references. Those are different questions.

Never reconstruct current table state by guessing from file timestamps or prefixes during an incident. File names can be nondeterministic; obsolete snapshots may still retain files; an in-flight writer may have staged files; delete files can change logical rows without rewriting data files.

### Atomicity, optimistic concurrency, and ambiguous acknowledgement

Writers commonly:

1. read a base snapshot;
2. create immutable data/delete/metadata files;
3. validate that required table state still holds;
4. atomically replace the catalog's current metadata pointer;
5. acknowledge success.

With **optimistic concurrency**, writers work without a long-held table lock, then validate conflicts at commit. Compatible updates may retry against a new base. Conflicting updates must fail or be reconciled according to operation semantics.

An acknowledgement can be lost after commit. The client sees a timeout, but the new snapshot is authoritative. Retrying without operation identity or reconciliation can duplicate logical work. Check the catalog and snapshot history before deciding that a timeout means failure.

### Schema identity, partition evolution, and format compatibility

Safe schema evolution requires stable field identity. Tracking fields only by name or ordinal makes rename, reorder, drop and name reuse dangerous. Iceberg uses field IDs so a renamed field remains the same logical field and a newly created field with an old name is not accidentally the deleted field.

**Hidden partitioning** derives physical partition values from source columns while queries remain expressed against data columns. **Partition evolution** allows old and new layouts to coexist; the planner derives filters for each spec. Changing the spec does not rewrite old files.

The **format version** controls persistent table features. A writer's ability to create a feature is irrelevant if one active reader cannot interpret it. Build a reader/writer/connector compatibility matrix before upgrading.

### Compaction, expiration, and orphan cleanup

**Data-file compaction** rewrites many small files into fewer larger files and commits a new snapshot. It should preserve logical rows, but it consumes read/write capacity and can conflict with other writers.

**Manifest rewrite** reorganizes metadata to improve planning. It does not mean the same thing as data-file compaction.

**Snapshot expiration** removes old snapshots from table history and can make files eligible for deletion when no retained snapshot or reference needs them. It reduces rollback and time-travel history.

**Orphan cleanup** finds objects not referenced by valid table metadata and older than a cutoff. A cutoff shorter than the longest possible write can delete in-flight files and corrupt a later commit. Path normalization differences can also create false candidates. Treat deletion as a high-risk governed operation.

## Architecture map

### Five owners, one answer

```text
identity/policy owner
       |
query client -> Trino coordinator -> workers/exchanges
                    |                    |
                    v                    v
               connector ----------> object storage
                    |
                    v
              catalog authority
                    |
                    v
            Iceberg metadata graph
```

| Boundary | Owns | Does not automatically own | First evidence |
|---|---|---|---|
| consumer/data product | meaning, freshness and correctness SLI | query-engine health | affected decision and reconciliation |
| identity/policy | authentication, authorization, masking, audit | table snapshot correctness | principal, action, policy version, decision |
| Trino coordinator | analysis, planning, scheduling, query state | persistent table truth | query ID, timings, plan, failure class |
| Trino workers | tasks, operators, splits, exchange work | catalog pointer | task/operator/skew/blocked evidence |
| connector | engine-to-source translation and capabilities | source implementation correctness | connector/version/config/capability |
| catalog | logical table to current metadata authority | object durability or query execution | table identity, metadata location, commit |
| table format | metadata graph and snapshot/file semantics | engine support | format/schema/spec/snapshot IDs |
| object store | bytes, durability, requests and access path | which files are logically current | object identity, version/checksum, request evidence |
| governance | retention, privacy, legal hold and lifecycle policy | correct execution | policy, approval, audit and deletion proof |

When ownership is blurry, teams use the wrong repair: storage operators delete “unused” files, query operators restart workers for catalog latency, or data engineers expire history that SRE needs for rollback.

### Read path

```text
client submits SQL + identity/session
 -> coordinator parses and analyzes
 -> access control approves objects/columns
 -> connector resolves catalog table
 -> catalog returns authoritative metadata location
 -> metadata selects snapshot
 -> manifest list prunes manifests
 -> manifests prune data/delete files
 -> connector creates splits
 -> coordinator schedules stages/tasks
 -> workers scan, join, aggregate, exchange
 -> result reaches client
 -> consumer-level correctness/freshness check
```

Each arrow needs an identity. “It read the table” is too vague. Record table name, metadata location, snapshot ID, query ID, plan and output version or digest.

### Write path

```text
operation ID + base snapshot
 -> write immutable candidate data/delete files
 -> build manifests and manifest list
 -> build candidate table metadata
 -> validate base and operation-specific conflicts
 -> atomic catalog pointer change
 -> new snapshot becomes visible
 -> acknowledge
 -> quality/reconciliation and lineage
```

Files written before the pointer change are not yet committed table state. A committed snapshot remains table state even if the writer missed the acknowledgement. Recovery begins by discovering which state is authoritative, not by assuming the client result.

## Request or state path

### Trace one slow query

Use a worksheet that prevents aggregate metrics from hiding the boundary:

| Question | Record |
|---|---|
| consumer operation | dashboard tile, report or API decision |
| result contract | rows, aggregates, freshness and snapshot expectation |
| query identity | query ID, attempt, user, source, client tags |
| workload policy | resource group, queue, concurrency and scan limits |
| table identity | catalog, namespace, table and metadata location |
| table version | snapshot ID, parent, sequence, schema/spec/format IDs |
| planning | analysis time, planning time, manifests/files considered and selected |
| execution | stages, tasks, splits, bytes, rows, skew, blocked/CPU time |
| dependencies | catalog latency, object requests, exchange storage, network |
| proof | independent reconciliation against the same snapshot |

Compare a good query and a bad query with the same logical purpose. Change one dimension at a time: snapshot, predicate, plan, engine version, connector version, workload pressure or table layout.

### Trace one commit

For a write, capture:

- operation or job-run identity;
- base snapshot and candidate snapshot;
- input range and deterministic code/config/schema;
- created data/delete/manifest/metadata files;
- validation requirements and conflict result;
- catalog commit attempt and authoritative result;
- acknowledgement state;
- row/file/quality reconciliation;
- orphan candidates that remain after failure.

A timeout is not a state. Record “client did not receive an acknowledgement.” Then query the authority to distinguish committed, not committed, superseded or indeterminate.

### Trace one maintenance operation

Maintenance is a table write plus operational policy:

```text
measured trigger
 -> bounded candidate partitions/files
 -> workload admission and capacity budget
 -> base snapshot/reference inventory
 -> rewrite candidate
 -> optimistic commit
 -> logical equivalence + performance comparison
 -> retain rollback anchor
 -> later expiration
 -> still later orphan cleanup
```

Compaction does not require immediate expiration. Keeping the old snapshot for a tested rollback interval separates “new layout is committed” from “old recovery path is destroyed.”

## Failure zoom

### Incident A: correct engine, wrong table state

Symptom: two tools query the same human-readable table name and disagree.

Possible mechanisms:

- they use different catalogs or namespaces;
- one catalog cache still points to older metadata;
- one engine lacks a format/delete feature and rejects or misinterprets state;
- one query explicitly time-travels while the other uses current state;
- authorization or row/column filtering differs;
- the consumer compares different time zones, currencies or business definitions.

Containment is to freeze destructive maintenance and new writers only when the evidence justifies it. Capture both fully qualified table identities, metadata locations, snapshot IDs, schemas, connector/engine versions, principals and query plans. Re-run a small deterministic comparison against an explicitly pinned snapshot.

Do not compare object-store file counts. Old snapshots legitimately share files, and delete files alter logical rows.

### Incident B: lost acknowledgement after commit

Symptom: a writer timed out. Candidate files exist. The scheduler plans to retry.

There are at least four states:

1. candidate files exist but no table commit occurred;
2. commit occurred and acknowledgement was lost;
3. another writer committed first and this operation failed conflict validation;
4. commit status cannot yet be read reliably from the authority.

The safe sequence is:

1. stop automatic duplicate retry if its sink identity is unsafe;
2. preserve operation ID, base snapshot and candidate metadata location;
3. refresh or directly query the catalog authority;
4. inspect snapshot history and summaries for the operation identity;
5. reconcile the expected row/file effect;
6. if committed, acknowledge/recover without rewriting;
7. if not committed, retry from a current base under conflict validation;
8. classify leftover files as orphan candidates only after the maximum writer/retry horizon.

This is the table-format version of the distributed-systems rule: a timeout says what the caller observed, not what the authority committed.

### Incident C: planning bottleneck

Symptom: analysis or planning is slow, workers are idle, and adding workers does nothing.

Split the pre-execution path:

```text
name/type analysis
 -> access-control calls
 -> catalog lookup
 -> metadata JSON
 -> snapshot/manifest list
 -> manifest reads and pruning
 -> split enumeration
 -> distributed plan ready
```

Evidence to compare:

- coordinator CPU, heap, garbage collection and request concurrency;
- catalog request latency/error/throttle/cache behavior;
- metadata-file and manifest counts/sizes;
- candidate versus selected manifests and files;
- object request count/latency;
- predicate shape and partition transforms;
- connector metadata cache state;
- recent streaming writes or maintenance that created many metadata objects.

If most time is before tasks exist, worker CPU is a distraction.

### Incident D: small files and delete amplification

Small files hurt through more than storage:

- more objects and open requests;
- more manifest entries and splits;
- more task scheduling overhead;
- less useful sequential read;
- more per-file footer/metadata work;
- larger commit and maintenance graphs.

Delete files can multiply the work needed to produce live rows. Measure data-file count/size distribution, delete-file count/bytes, delete-to-data ratio, rows removed, partitions affected and read cost. “Many files” is not an incident threshold. Tie it to planning SLO, scan latency, request cost and maintenance capacity.

Compaction is not free. If a table receives 2 TiB/hour and compaction can rewrite only 1 TiB/hour, the debt grows even when the job stays green. Calculate sustainable arrival, rewrite capacity, conflict rate and allowed maintenance window.

### Incident E: unsafe retention

Snapshot expiration, metadata cleanup and orphan deletion solve different problems.

Before snapshot expiration, inventory:

- rollback and time-travel SLO;
- branches and tags;
- legal/audit holds;
- delayed consumers and reproducibility needs;
- active and paused jobs that reference old snapshots;
- privacy policy and deletion commitments;
- disaster-recovery copies and catalog backups.

Before orphan cleanup, additionally prove:

- all valid table roots and authorities are scanned consistently;
- path representations match;
- the cutoff exceeds the maximum write, retry and visibility horizon with margin;
- candidate objects are absent from every live snapshot/reference;
- deletion is bounded, logged and recoverable where possible.

The cheapest storage cleanup can become the most expensive corruption event.

## Internals and state ownership

### The Iceberg metadata graph as a persistent tree

Immutable metadata enables snapshots to reuse unchanged manifests and files. A new append need not rewrite every previous file reference. It can produce new data files and manifests, then a new snapshot and table metadata file that reuse older nodes.

This has three consequences:

1. Multiple snapshots can share one data file. Deleting a file because one snapshot expired is unsafe if another retained reference still reaches it.
2. Metadata growth can occur even when logical row growth is modest, especially with frequent commits.
3. Recovery and audit can reason from snapshot identity, not storage modification time.

The current table metadata location is the mutable authority edge. The graph below it is predominantly immutable. This is why the catalog's compare-and-swap or equivalent commit behavior is critical.

### Snapshot sequence and operation semantics

A snapshot records an operation such as append, replace, overwrite or delete. The label is evidence, not a complete business proof. For example, a compaction may be represented as replace because it changes physical files without intending to change logical rows.

For every commit, record:

- parent/base snapshot;
- new snapshot ID and sequence;
- operation type and summary;
- added/removed data and delete files;
- schema, partition spec and sort-order IDs;
- job/operation identity;
- validation rules;
- quality and reconciliation result.

Sequence order helps reason about changes, but “latest sequence” does not tell you whether the business output is correct.

### Optimistic concurrency and validation scope

Atomic pointer replacement prevents partial visibility, but concurrent correctness also depends on validation. An append can often be rebased safely when another append wins first. An overwrite of the same logical rows may conflict. A compaction that replaces files must confirm those files are still live.

Ask:

- What base state did the writer assume?
- Which files, partitions, predicates or rows did it read and intend to replace?
- Which concurrent changes are compatible?
- What requirements does the commit assert?
- Does retry recompute against current state or reuse stale decisions?
- Is the business operation idempotent?

“Optimistic concurrency” does not mean “all conflicts resolve automatically.”

### Schema evolution by identity

Suppose field 7 is named `customer_id`. Renaming it to `buyer_id` should preserve field 7. Dropping field 7 and later creating a new `customer_id` should allocate a different field ID. Readers map stored columns to logical fields through identity, not only name or position.

An evolution review should include:

| Change | Questions |
|---|---|
| add optional field | default/null semantics; old reader behavior |
| add required field | how existing rows receive a value |
| rename | field ID preserved; downstream name-bound code |
| widen type | every reader/writer supports it; semantic range |
| drop | downstream usage, retention/privacy, name reuse |
| reorder | ordinal readers or exports affected |
| format upgrade | all active engines/connectors support every used feature |

The table schema can be technically compatible while a dashboard, export or model is semantically incompatible. Lineage and consumer contracts close that gap.

### Partition and sort evolution

Hidden partitioning means a filter on `event_time` can become filters for `day(event_time)` or `hour(event_time)` without exposing a synthetic partition column to users.

After partition evolution, old files retain the old spec and new files use the new spec. Planning evaluates files under their own spec. Therefore:

- changing the spec does not rewrite history;
- performance benefits apply gradually unless data is rewritten;
- mixed-spec planning must be supported by each reader;
- query evidence should show pruning separately for old and new layouts;
- rollback must preserve both specs and their metadata.

Sort order affects clustering and file statistics. It can improve pruning or merge behavior, but global sorting costs shuffle, memory and time. Select it from measured predicates and join/range patterns.

### Query planning mechanics

Use `EXPLAIN` to inspect a plan without executing the query. Useful questions:

- Which tables and columns are inputs?
- Which predicates reach the scan?
- How are fragments distributed: source, hash, broadcast, round robin or single?
- Which side of a join is built?
- Where do exchanges occur?
- Are estimates known or unknown?

Use `EXPLAIN ANALYZE` only when executing the statement is safe and bounded. It runs the statement and adds observed statistics. For data-changing statements, that is a mutation, not a harmless inspection.

Runtime evidence includes rows/bytes, CPU, scheduled and blocked time, per-task averages and variation. High input standard deviation suggests skew. High blocked time must be classified: waiting for input, output, memory, exchange or a dependency has different remedies.

### Pruning layers

```text
SQL predicate
 -> connector predicate translation
 -> partition-transform pruning
 -> manifest-list pruning
 -> manifest/file-statistics pruning
 -> row-group/page filtering
 -> remaining rows evaluated
```

Measure candidate and selected items at each layer. A query returning 10 MiB after scanning 5 TiB has a different problem from a query scanning 10 MiB but waiting on catalog calls.

Pruning can fail because:

- a function or cast prevents pushdown;
- time-zone semantics do not match the partition transform;
- statistics are missing, stale or truncated;
- data is poorly clustered;
- old partition specs are too coarse;
- the connector cannot express the predicate;
- the query genuinely asks for most data.

### Fault-tolerant query execution

Trino query retry and task retry are compute-execution mechanisms. Task retry generally requires external exchange storage so failed task output can be rescheduled. Connector support varies, especially for writes.

Do not confuse:

- retrying a query/task;
- committing an Iceberg snapshot;
- returning results to the client;
- idempotently applying a downstream effect.

Fault-tolerant execution can increase exchange storage traffic and cost. Large batch work and short interactive queries may need separate clusters or resource policies. Encrypt and lifecycle spool data according to its sensitivity and recovery window.

## Evidence table

| Symptom | First boundary | Evidence that separates causes | Unsafe shortcut |
|---|---|---|---|
| wrong row count | snapshot/semantic contract | query ID, snapshot, data+delete files, reconciliation | count objects in directory |
| writer timeout | catalog commit | base/candidate snapshot, operation ID, history | rerun immediately |
| long planning | coordinator/catalog/metadata | phase timings, manifests/files considered, request latency | add workers |
| high scan cost | pruning/layout | predicate, plan, selected files/bytes, file stats | raise scan limit |
| one slow stage | skew/exchange/dependency | per-task distribution, top keys, blocked reason | add uniform workers |
| many small files | write layout | file-size histogram, commit rate, request/planning cost | compact whole table |
| slow reads after deletes | delete amplification | data/delete file ratio, files applied, row effect | expire snapshots |
| commit conflicts | concurrent writers | base snapshot, replaced scope, validation and retries | disable validation |
| lost time travel | retention/reference policy | snapshot/reference graph and expiration audit | restore from file listing |
| unauthorized metadata action | policy boundary | principal, action, decision, policy version, audit | grant catalog-wide write |

An evidence table is a discipline: it maps one observation to competing mechanisms and names the next discriminating measurement.

## Command decoders

### Read a Trino query timeline

Interpret these durations separately:

- **queued:** admission or resource-group waiting;
- **analysis:** parse, names, types, permissions and metadata resolution;
- **planning:** optimizer, connector planning and split discovery;
- **execution:** scheduled distributed work;
- **CPU:** active computation, summed across workers;
- **scheduled:** task time eligible/running;
- **blocked:** waiting, which requires a reason;
- **wall:** user-visible elapsed time.

CPU can exceed wall time because work runs in parallel. Wall time can dwarf CPU when the query waits on metadata, input, output, memory or exchange. A low cluster CPU average does not prove spare capacity on the constrained resource.

### Decode EXPLAIN

Start at table scans and move toward the output:

1. verify fully qualified table and predicates;
2. identify projected columns;
3. note estimates and unknowns;
4. inspect fragment boundaries and exchanges;
5. inspect join distribution and build side;
6. find single-node/final bottlenecks;
7. compare plan between good and bad snapshots/configurations.

`EXPLAIN (TYPE IO, FORMAT JSON)` can expose inputs and outputs for supported statements. Treat it as planned access, not proof of runtime bytes or correctness.

### Decode EXPLAIN ANALYZE

Before running it, ask whether the statement is read-only, bounded and acceptable to execute. Then compare estimated versus observed:

- input/output rows and bytes;
- per-task average and standard deviation;
- CPU versus blocked time;
- peak memory and spill/exchange evidence;
- stage critical path;
- selected files/splits;
- result digest or business reconciliation.

One fast sample is not a capacity test. Short queries can also produce noisy relative timings.

### Decode table metadata

Do not edit metadata files. Read them through supported metadata tables/APIs and record:

- current metadata location;
- current snapshot and parent;
- snapshot operation and timestamp;
- schema ID and field IDs;
- partition and sort-order IDs;
- manifest/file counts;
- branches/tags and retention;
- table format version and properties.

The purpose is to reconstruct authority and history, not to bypass the catalog.

### Decode the offline lab

`bash lab.sh evaluate small-files` returning:

```text
case=small-files decision=not-operable boundary=small-files
```

proves only that the synthetic case crosses its configured file-size threshold. It does not prove an ideal production target, a Trino plan, Iceberg compaction benefit or actual object-store cost. Replace model values with measurements before making a real decision.

## Decision path

### When correctness is wrong

```text
consumer result wrong
 -> pin query identity and expected contract
 -> resolve authoritative catalog/table/snapshot
 -> verify metadata closure and reader compatibility
 -> compare data/delete file set and operation history
 -> reconcile same snapshot independently
 -> contain writers/maintenance if evidence requires
 -> choose rollback, forward repair or consumer correction
 -> verify and preserve lineage
```

Rollback is appropriate only if the target snapshot remains valid, compatible, authorized and consistent with downstream effects. If consumers already acted on bad output, table rollback alone does not undo those effects.

### When latency is high

```text
high latency
 -> queued? fix admission/fairness
 -> analysis/planning? inspect coordinator/catalog/metadata
 -> scan? inspect pruning/files/object path
 -> exchange/join? inspect distribution/skew/memory
 -> dependency blocked? inspect target capacity
 -> final/single stage? inspect serial bottleneck
 -> validate consumer SLI and cost after change
```

### When storage cost is high

Break cost into:

```text
retained data + delete files + snapshots/history + metadata
+ object requests + bytes read/write
+ query compute + exchange/spill
+ maintenance compute/read/write
+ catalog/control plane
+ backup/replication/egress
```

Optimize the dominant unit without destroying rollback, correctness or privacy evidence.

### When considering deletion

Deletion requires a proof chain:

1. identify governing privacy/retention/legal policy;
2. identify every table/reference/replica/cache/export that can expose data;
3. distinguish logical row deletion from physical file removal;
4. preserve permitted audit evidence without retaining prohibited content;
5. wait until no retained snapshot/reference needs the file;
6. use a cutoff beyond all possible active writers;
7. log candidates and bounded outcomes;
8. independently verify absence and consumer behavior.

“Expired from current snapshot” and “physically unrecoverable everywhere” are not synonyms.

## Guided Ubuntu lab

### Purpose and boundary

This lab teaches decision order with synthetic JSON. It deliberately does not install or emulate Trino, Iceberg, a catalog or object storage. That narrow boundary makes it safe to repeat and prevents a passing model from being mistaken for platform proof.

Run it only in Ubuntu 24.04 as a normal user. It refuses root, common cloud/data credentials, symlinked or wrongly owned state and unknown artifacts. It writes only:

```text
/tmp/reliability-atlas-les0063-lakehouse-table-<uid>/
  .les0063-sentinel
  cases.json
```

### Step 1: inspect before execution

From `drafts/LES-0063-lakehouse-table-reliability/support/lab`:

```bash
pwd
id
sed -n '1,220p' README.md
sed -n '1,240p' lab.sh
sed -n '1,260p' model.py
```

Explain before running:

- why UID 0 is refused;
- which variables are treated as credential/endpoints;
- the exact allowed temporary path;
- why an unknown child blocks cleanup;
- what the model cannot prove.

Inspection proves only what source you intend to execute. It does not prove runtime behavior.

### Step 2: doctor and setup

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected shape:

```text
doctor=pass runtime=offline-lakehouse-table-model
fixture=valid cases=20
setup=pass state=/tmp/reliability-atlas-les0063-lakehouse-table-<uid> network=none
status=ready cases=20 network=none
```

If doctor fails, stop. Do not export fake variables, run as root or edit the operating-system identity to bypass it.

### Step 3: establish baseline

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Walk the fields in model order:

1. catalog authority and atomic pointer;
2. snapshot/manifest/file closure;
3. field identity and reader compatibility;
4. partition evolution and conflict validation;
5. snapshot/orphan retention and rollback anchor;
6. file and delete amplification;
7. statistics and scan budget;
8. workload isolation, authorization and audit.

The model returns the **first** unsafe boundary. That mimics production triage: fix or explain the earliest broken ownership assumption before tuning downstream work.

### Step 4: compare focused failures

```bash
bash lab.sh evaluate catalog-not-authoritative
bash lab.sh evaluate pointer-commit-not-atomic
bash lab.sh evaluate reader-format-incompatible
bash lab.sh evaluate orphan-cleanup-races-writer
bash lab.sh evaluate small-files
bash lab.sh evaluate delete-files-dominate
bash lab.sh evaluate scan-budget-exceeded
bash lab.sh evaluate maintenance-not-isolated
```

For each output, say:

- what the boundary means;
- which real system owns it;
- which production evidence would validate it;
- one dangerous reaction;
- one safe next action.

Example:

> `boundary=orphan-retention` means the configured candidate age does not exceed the longest modeled writer duration. I would stop deletion, identify every writer/retry horizon, verify catalog references and path normalization, increase the safety interval, run a report-only candidate scan, and require reviewed deletion evidence. This model does not prove actual Iceberg cleanup behavior.

### Step 5: prove fail-closed inventory

```bash
bash lab.sh inject-unknown
bash lab.sh status
```

Status must fail because an unexpected file exists. This proves the guard refuses to operate on state it cannot account for.

Then:

```bash
bash lab.sh clear-unknown
bash lab.sh status
```

The clear operation removes only the exact known injected artifact after checking path, type and ownership.

### Step 6: cleanup and full verifier

```bash
bash lab.sh cleanup
test ! -e "/tmp/reliability-atlas-les0063-lakehouse-table-$(id -u)"
bash verify.sh
```

The verifier covers twenty model outcomes, the unknown-artifact refusal and final state absence. Preserve the transcript as model evidence only.

### Lab reflection

Answer aloud:

1. Why is the catalog pointer more authoritative than an object listing?
2. Why can orphan cleanup corrupt a writer even when the file is not in a current snapshot?
3. Why is `EXPLAIN ANALYZE` not always read-only?
4. Why does compaction need both correctness and capacity evidence?
5. Which evidence would turn each model field into a real claim?

## Production transfer

### Reviewer-owned disposable topology

The independent lab should use synthetic data and a version-pinned local topology:

```text
SQL client
  -> Trino coordinator
       -> Trino workers
       -> Iceberg connector
            -> disposable catalog
            -> disposable object storage
       -> protected metrics/event evidence
```

The reviewer owns versions, network isolation, credentials, bounded resource limits, fault injection and cleanup. The learner receives architecture and product goals, not expected answers.

### Baseline proof

Before faults:

- record image/binary digests and configuration;
- prove service identities and least privilege;
- create a bounded synthetic table;
- record metadata location, snapshot, schema/spec/format IDs;
- run a query with known result and capture plan/runtime evidence;
- prove predicate pruning and selected files;
- capture file-size and delete-file distribution;
- record query and table lineage;
- prove exact teardown plan.

### Required fault matrix

| Fault | Required observation | Recovery evidence |
|---|---|---|
| catalog unavailable/slow | analysis/planning impact separate from scan | authority restored, no invented state |
| writer loses acknowledgement | candidate files plus ambiguous client state | committed/not-committed reconciled |
| two conflicting writers | validation and retry behavior | invariant preserved |
| missing/corrupt metadata object | snapshot closure failure | supported restore/rollback, no manual pointer guess |
| incompatible reader | explicit capability failure | compatibility restored or feature rolled back |
| small-file burst | planning/split/request amplification | scoped compaction and measured improvement |
| many delete files | read amplification | rewrite with row-equivalence proof |
| stale/missing statistics | plan/estimate change | refreshed evidence and safer plan |
| skewed join | per-task distribution and blocked path | distribution repair |
| worker loss | retry-policy behavior and exchange use | bounded recovery with correct result |
| maintenance contention | interactive SLI impact | admission/resource isolation |
| unsafe expiration proposal | reference/rollback conflict | deletion refused |
| privacy deletion | logical plus physical lifecycle | governed cross-copy proof |

### Transfer acceptance

Passing means the learner can:

- explain why each fault manifests where it does;
- preserve authority and history before mutation;
- distinguish table commit, query execution and client acknowledgement;
- calculate bottleneck and recovery capacity;
- choose rollback or forward repair from evidence;
- validate rows, files, plan, latency and cost;
- respond to a changed constraint without memorized commands;
- clean the entire disposable topology.

A successful query is necessary but not sufficient.

## Reliability, security, observability, capacity, and cost

### Reliability contracts

Define SLIs at distinct levels:

| Layer | Example SLI |
|---|---|
| consumer | correct/fresh decision by deadline |
| query service | successful bounded query latency by class |
| planning | metadata-to-plan latency and failure rate |
| execution | task success, retry, spill/exchange and result delivery |
| table | valid current snapshot and commit success/conflict rate |
| maintenance | debt age, completion, conflicts and equivalence |
| recovery | RTO to known-good snapshot and independently reconciled result |

Do not combine user errors, policy denial, capacity rejection, internal faults and dependency faults into one “failed query” number. Each has different ownership.

### Security and privacy

Protect:

- client-to-coordinator and internal transport;
- catalog and object-store credentials;
- coordinator/worker service identities;
- table/namespace/column/row actions;
- metadata procedures such as rollback, expiration and orphan cleanup;
- branches/tags and historical snapshots;
- query text, plans, metrics, lineage and audit logs that may expose sensitive names or values;
- exchange/spill files and temporary outputs.

Least privilege separates read, write, schema evolution, maintenance and destructive lifecycle capabilities. A BI reader should not inherit snapshot-expiration permission. A compactor should touch only approved tables/partitions and should not administer authorization policy.

Privacy deletion is a distributed lifecycle. Current-table logical deletion may leave data in retained snapshots, branches, tags, backups, caches, exports and query results. Document the allowed horizon and prove each copy's disposition without printing sensitive values into logs.

### Observability

Connect identifiers:

```text
consumer operation
 -> query ID / attempt / principal / resource group
 -> plan / stage / task / split
 -> catalog / table / metadata location / snapshot
 -> manifests / data and delete files
 -> object requests / exchange
 -> output / quality / lineage
```

Alert on user-impacting combinations:

- planning latency plus catalog/metadata errors;
- query burn rate by workload class;
- queued age plus rejected queries;
- worker loss plus retry/exchange saturation;
- manifest/file growth plus planning SLO;
- small-file or delete debt age plus projected drain time;
- commit conflict/ambiguity plus consumer freshness risk;
- retention jobs approaching rollback/legal/privacy boundaries.

Avoid alerting on every failed query or raw file count without context.

### Capacity

Model each required path:

```text
interactive demand
+ scheduled batch demand
+ ingestion writes
+ compaction/manifest maintenance
+ recovery/retry/backfill
= admitted work
```

Capacity is bounded by the slowest required resource:

- coordinator analysis/planning concurrency;
- catalog requests and commit throughput;
- object request and byte throughput;
- worker CPU/memory/network;
- exchange/spool storage;
- hottest split/partition/key;
- connector or downstream rate limits;
- maintenance rewrite throughput.

If table debt arrives at `A` GiB/hour and maintenance rewrites at `S` GiB/hour while normal demand continues, spare drain rate is `S - A`. For debt `B` GiB:

```text
drain_time_hours = B / (S - A), only when S > A
```

Include conflict retries and validation overhead. If `S <= A`, no scheduling trick drains the debt.

### Cost

Use units:

- cost per successful consumer query;
- bytes scanned per returned row or decision;
- object requests per query;
- metadata bytes/requests per planned query;
- compute-seconds per TiB scanned;
- exchange/spool bytes per retried query;
- maintenance bytes read/written per useful file consolidated;
- storage bytes by current data, delete files, retained snapshots and metadata.

Compaction can reduce query/open cost while increasing rewrite cost. Longer retention increases rollback value and storage. Better clustering may improve pruning but increase writer shuffle. State the chosen trade-off.

## Traps and prevention

### Trap: list the directory to find table state

Why it fails: listings include old, orphan, staged and shared files and omit logical delete meaning.

Prevention: begin at the catalog authority and follow snapshot metadata closure.

### Trap: retry every timed-out write

Why it fails: the commit may have succeeded before acknowledgement was lost.

Prevention: use operation identity, inspect authoritative history and make business effects idempotent/reconcilable.

### Trap: enable a format feature because one writer supports it

Why it fails: any active reader or maintenance tool may be incompatible.

Prevention: maintain and test a versioned reader/writer/connector compatibility matrix.

### Trap: compact everything on a schedule

Why it fails: unnecessary rewrites create cost, conflicts and contention without proving benefit.

Prevention: use measured file/delete/manifest thresholds, bounded candidates, isolated resources and before/after evidence.

### Trap: expire snapshots to fix query speed

Why it fails: snapshot history and current planning metadata are related but not interchangeable; expiration can destroy rollback.

Prevention: identify the actual planning bottleneck, preserve references and meet the rollback/time-travel policy.

### Trap: use a short orphan cutoff

Why it fails: in-flight writers create unreferenced files before commit.

Prevention: cutoff must exceed the maximum writer, retry and visibility horizon with margin; report before delete.

### Trap: add workers for every slow query

Why it fails: coordinator, catalog, metadata, object requests, one hot task or a serial stage may dominate.

Prevention: separate queued, analysis, planning and execution, then inspect the critical path.

### Trap: trust aggregate CPU and average file size

Why it fails: tails, hottest partitions and distributions govern incidents.

Prevention: retain histograms/quantiles and per-stage/task/partition evidence.

### Trap: give the engine storage-admin credentials

Why it fails: compromise or operator error can bypass table and retention controls.

Prevention: separate catalog, data read/write, maintenance and policy permissions; audit destructive procedures.

### Trap: call time travel a backup

Why it fails: snapshots can share the same storage and catalog failure domain and can be expired or deleted.

Prevention: define independent backup/restore of catalog metadata and required objects, then test restoration.

## Memory card and retrieval

### The sentence to keep

> Start at the consumer and catalog authority, follow the committed snapshot to manifests and files, then explain the query plan and maintenance policy with measured evidence.

### The seven-boundary card

```text
C  Consumer contract
A  Authority: catalog -> current metadata
S  Snapshot closure: manifest list -> manifests -> files
E  Evolution: field/spec/format compatibility
P  Plan: pruning -> splits -> exchanges -> result
M  Maintenance: rewrite -> validate -> retain -> expire
G  Governance: identity, privacy, audit, capacity, cost
```

Say “CAS-EPMG” only as a retrieval cue; the evidence path matters more than the acronym.

### Fast incident questions

1. What consumer decision is affected?
2. Which query and snapshot produced it?
3. Which catalog owns the current metadata pointer?
4. Is the snapshot-to-file graph complete and readable?
5. Is this queued, planning, scan, exchange or dependency time?
6. What changed in schema, format, partitioning, files, deletes, statistics, engine or policy?
7. Which mutation is reversible and which destroys evidence?
8. How will correctness, latency, capacity, cost and cleanup be proved?

### One-minute self-test

Without looking back, explain:

- why an object listing is not table state;
- how an atomic metadata-pointer change publishes a snapshot;
- why field IDs matter;
- why partition evolution does not rewrite old files;
- how small files affect both planning and execution;
- why snapshot expiration differs from orphan deletion;
- why `EXPLAIN ANALYZE` can be dangerous;
- why query retry is not table-commit exactly once.

If one explanation becomes product slogans, return to the owner and failure boundary.

## Complete answers

### Answer 1: Why is the catalog pointer more authoritative than storage listing?

The table's logical state is defined by a committed metadata graph. The catalog identifies the current table metadata file. That metadata identifies the current snapshot, which identifies a manifest list, manifests, and finally the data and delete files that participate in the table.

A storage listing answers a different question: “Which objects did this listing operation observe under this path?” It can include:

- files referenced only by older retained snapshots;
- files shared by several snapshots;
- abandoned files from a failed writer;
- files from a writer that is still running and has not committed;
- metadata files no longer current;
- objects for another table or layout;
- delete files whose effect cannot be inferred from filename;
- objects hidden by a different path representation or access policy.

Therefore a listing cannot tell you current logical rows. The safe diagnostic path begins with catalog/table identity and the current metadata location, then follows references. Listings are useful later for storage inventory, orphan-candidate analysis and cost, but not as the authority for table reconstruction.

### Answer 2: What exactly happens in an optimistic Iceberg-shaped commit?

A writer reads a base snapshot and plans its operation against that state. It writes immutable candidate data or delete files, then manifests, a manifest list and candidate table metadata. Before publication it validates requirements such as “the current snapshot is still the expected base” or more operation-specific conflict rules.

The commit attempts an atomic change at the catalog boundary from the old metadata pointer to the candidate metadata pointer. If it succeeds, readers that resolve the new pointer see the whole new snapshot; they do not see a half-written mixture. If another writer changed the pointer first, validation decides whether the operation can be retried/rebased or must fail.

The client acknowledgement happens after or around that authoritative change. A timeout does not prove the commit failed. Recovery reloads the authority and searches history using base/candidate/operation identity. Candidate files that never became reachable may later be orphaned, but deleting them immediately can race an in-flight or retrying commit.

### Answer 3: Why do field IDs matter more than column names?

Names are user-facing labels and can change or be reused. Positions can change when columns are reordered. A stable field ID represents logical identity across evolution.

Suppose field ID 12 is named `account_status`. Renaming it to `state` should not make old files lose the value; the identity remains 12. If field 12 is dropped and years later a new `account_status` is created, it must receive a new ID. Otherwise an old physical column could be mistaken for the new business meaning—effectively undeleting data or corrupting interpretation.

Field IDs solve the persistent table mapping problem, but downstream systems can still bind to names or order. A safe evolution includes table-format compatibility plus application, export, BI and model contracts.

### Answer 4: Why can old and new partition layouts coexist?

Each file is recorded with a partition spec identity and partition tuple. The query remains expressed against data values, such as a predicate on `event_time`. The planner derives an appropriate partition predicate for each spec.

When a table changes from `day(event_time)` to `hour(event_time)`, old files remain under the old spec and new writes use the new spec. This is a metadata evolution, not an automatic data rewrite. It avoids a disruptive migration, but it also means:

- performance gains apply immediately only to new data;
- mixed-spec planning must remain compatible;
- pruning should be measured by spec;
- a later rewrite is a separate, capacity-consuming decision.

Hidden partitioning separates logical query syntax from physical layout, reducing user error and enabling evolution.

### Answer 5: A query plans slowly with idle workers. What do you do?

First prove that the time is analysis/planning, not queueing or execution. Capture the query timeline. If tasks have not started, inspect the coordinator, access-control path, catalog calls, metadata cache, metadata JSON, manifest list, manifests and split enumeration.

Compare:

- catalog request latency/error/throttling;
- current snapshot and recent commit rate;
- manifest and file counts/sizes;
- candidate versus selected manifests/files;
- object metadata request latency;
- coordinator CPU/heap/GC/concurrency;
- predicate translation and partition/file pruning;
- good and bad query plans against pinned snapshots.

Adding workers cannot accelerate work that has not been scheduled. Repairs might include catalog capacity/cache correction, manifest rewrite, reducing commit-driven metadata debt, query predicate correction, or connector/version fixes. Validate both planning latency and result correctness after the change.

### Answer 6: When should you compact?

Compact from a measured service problem, not a calendar alone. Candidate evidence can include a file-size distribution below policy, excessive splits/object requests, planning SLO burn, read amplification, and a demonstrated relationship between layout and consumer latency/cost.

Then:

1. select bounded partitions/files;
2. estimate bytes read/written, runtime, conflict and object-request cost;
3. isolate maintenance from critical workloads;
4. pin the base snapshot and operation identity;
5. rewrite and commit through supported concurrency rules;
6. compare logical rows/aggregates on old and new snapshots;
7. compare plan, files, latency and cost;
8. retain the old snapshot/reference for rollback;
9. expire only when policy permits.

Compaction that cannot outpace incoming debt is not a solution. If 500 GiB/hour of small-file debt arrives and the safe spare rewrite rate is 300 GiB/hour, backlog grows 200 GiB/hour.

### Answer 7: Why is orphan cleanup more dangerous than it sounds?

A writer creates files before it commits them. During that interval the files are intentionally unreferenced. A failed writer can also retry for hours. If cleanup defines “orphan” as “not currently referenced” and uses a cutoff shorter than these horizons, it can delete a file the writer is about to publish.

Other hazards include inconsistent path normalization, scanning the wrong root, stale catalog visibility, branches/tags not included in reachability and insufficient permission to see every reference.

Safe cleanup requires report-first candidates, authoritative reference closure, a cutoff greater than maximum write/retry/visibility time with margin, bounded scope, path-consistency checks, audit, deletion throttling and independent verification. Snapshot expiration should precede physical deletion only under policy; the two are not one command conceptually.

### Answer 8: How do you separate snapshot expiration, rollback, time travel, backup and privacy?

- **Snapshot expiration** removes history from the table metadata and can make unreferenced files eligible for deletion.
- **Rollback** changes current table state to a retained valid snapshot; it needs that snapshot and its files.
- **Time travel** reads a retained historical snapshot without making it current.
- **Backup/restore** must survive failures in the primary catalog/storage failure domain and is tested separately.
- **Privacy deletion** enforces policy across current state, retained snapshots/references, backups, exports, caches and logs on an approved timeline.

Long retention helps reproducibility and rollback but delays physical deletion and costs storage. Short retention reduces history but increases recovery risk. Branches/tags can intentionally protect snapshots. The policy must reconcile operational RTO, audit/legal obligations, consumer reproducibility and privacy—not allow one maintenance default to decide all of them.

### Answer 9: How do EXPLAIN and EXPLAIN ANALYZE differ?

`EXPLAIN` shows the planned logical/distributed structure without running the statement. It helps inspect scans, predicates, estimates, fragments, exchanges and join distribution.

`EXPLAIN ANALYZE` executes the statement and reports observed work such as rows, bytes, CPU, blocked time and per-task variation. It gives stronger runtime evidence but consumes real resources and can mutate data if applied to a data-changing statement. Even a read can be expensive or impact shared users.

Use plain EXPLAIN first. Run ANALYZE only with bounded inputs, understood statement semantics, workload authorization and an abort plan. Neither proves business correctness; reconcile the output.

### Answer 10: Does fault-tolerant query execution make writes exactly once?

No. Query/task retry can recover compute work using retry policy and exchange storage, subject to connector and statement support. Table-format commits have their own atomicity, conflict and retry semantics. Client acknowledgement is another boundary. Downstream effects are another.

State the claim precisely:

```text
query/task execution retry
 + connector write support
 + atomic table snapshot commit
 + operation identity/reconciliation
 + safe client retry
 + idempotent downstream effects
= bounded end-to-end behavior under named failures
```

Remove any term and the guarantee changes.

### Answer 11: How do you calculate whether maintenance can catch up?

Measure incoming debt `A`, total safe maintenance service `S`, backlog `B` and recovery window `W` in consistent units. Spare rate is `S - A`. If it is non-positive, debt cannot drain while arrivals continue. If positive:

```text
drain_time = B / (S - A)
required_service = A + B / W
```

Then constrain the result by the actual bottleneck: catalog commit rate, object request limits, bytes, worker capacity, hottest partition, conflict rate and interactive workload reserve. Include read and write amplification. A theoretical byte rate is not enough if catalog commits or one partition serialize progress.

### Answer 12: What proves recovery?

Recovery proof is an evidence chain:

- the intended catalog/table is authoritative;
- the selected snapshot and metadata closure are valid;
- every active reader supports the format/schema/spec;
- expected rows and aggregates reconcile independently;
- query plan and latency meet the consumer SLI;
- writes/maintenance are safely resumed;
- rollback/forward-repair state is documented;
- orphan and retention actions remain deferred until safe;
- audit/lineage connects incident, change and outcome;
- disposable artifacts or temporary privileges are removed.

A green query alone proves only that one execution completed.

## Product-company interview

### Question 1: Design a multi-engine lakehouse table

A strong answer begins with consumer operations and invariants, not brands. Define table/catalog authority, object storage, engines and their reader/writer matrix. Explain atomic snapshot commits, stable field IDs, hidden/evolving partitions, deterministic jobs, quality/lineage, least privilege and workload classes. Add file/manifest maintenance, snapshot/reference retention, backup/restore, privacy lifecycle, query/table SLIs, capacity and unit cost. Name failure modes and prove recovery.

A weak answer lists Trino, Spark, Iceberg and object storage without ownership, commit or compatibility semantics.

### Question 2: Trino queries are slow after streaming ingestion

Separate queue, analysis, planning and execution. Frequent streaming commits may create small files and metadata/manifest growth. Compare snapshot history, file-size distribution, manifest counts, selected files, object requests, split count and plan/runtime stats. Check predicates, partition specs, delete files and catalog latency. Use scoped compaction or manifest rewrite only if the evidence points there, isolate it, retain rollback and compare correctness/performance/cost.

### Question 3: A write timed out; can you rerun it?

Not until commit state is reconciled. Capture operation/base/candidate IDs, query catalog authority and snapshot history, and check the expected logical effect. If it committed, recover acknowledgement without duplicating. If not, retry from current state under correct conflict validation and stable operation identity. Leave candidate files until the safe orphan horizon.

### Question 4: How do you upgrade an Iceberg table format?

Inventory every reader, writer, connector, maintenance tool and recovery process. Map exact versions to required features, test old/new snapshots and read/write/rollback in a disposable representative environment, canary a bounded table, monitor compatibility and preserve rollback. Upgrading the table is unsafe until the least-capable active consumer is handled.

### Question 5: How do you operate compaction as SRE?

Define debt and user SLI, measure arrival/service rates, select bounded candidates, isolate workload, preserve base/new snapshot IDs, use conflict-safe commits, reconcile logical equivalence, compare file/plan/latency/cost, retain rollback, and alert on debt age/drain time. Never combine rewrite success with immediate destructive expiration.

### Question 6: What would you alert on?

Alert on consumer and mechanism combinations: freshness/correctness burn; planning latency with catalog/manifest evidence; queued age and rejections by resource group; query failure by class; worker retry plus exchange saturation; small-file/delete/metadata debt projected beyond SLO; commit conflict/ambiguity; and retention jobs approaching rollback/legal/privacy boundaries. Route each alert to the owner and include query/table/snapshot identity.

## Independent transfer and rubric

The reviewer provides an unseen, sanitized packet containing:

- consumer SLI and workload mix;
- table metadata/snapshot/manifest summaries;
- file and delete-file distributions;
- schema/spec/format and engine compatibility matrix;
- query plans and phase/task statistics;
- catalog/object/exchange signals;
- commit, maintenance and retention history;
- one injected correctness or performance incident;
- one changed constraint after the initial proposal.

The learner must produce:

1. consumer-to-file architecture and ownership map;
2. authoritative table-state and commit explanation;
3. compatibility and evolution plan;
4. query diagnosis with competing hypotheses;
5. safe incident containment and recovery;
6. compaction/metadata/retention/orphan strategy;
7. workload, security, privacy and audit design;
8. capacity/drain and unit-cost model;
9. independent correctness/performance validation;
10. revised design after the changed constraint.

Scoring is defined in `ASM-0174`. The task intentionally contains no model answer. Direct answers elsewhere in this lesson cannot be copied as a solution because the evidence packet, fault and constraint are unseen.

Mastery requires reviewer-observed execution, explanation, safe handling of ambiguity, cleanup, delayed recall and transfer. Reading completion, model output or website state does not award it.

## References and review

### Source map

| IDs | Use |
|---|---|
| REF-0703 | Trino coordinator, worker, stage, task, split and connector concepts |
| REF-0704..0705 | planned and executed query-plan evidence |
| REF-0706 | resource groups, queueing, concurrency and fairness |
| REF-0707 | fault-tolerant query/task execution and exchange boundaries |
| REF-0708 | Trino Iceberg connector, catalogs, snapshots, procedures and compatibility |
| REF-0709 | protected OpenMetrics observability |
| REF-0710 | system/catalog access control |
| REF-0711 | normative Iceberg table metadata, snapshot, manifest and commit semantics |
| REF-0712..0713 | hidden partitioning and schema/partition/sort evolution |
| REF-0714 | expiration, orphan deletion, data compaction and manifest maintenance |
| REF-0715 | branches, tags and snapshot retention |
| REF-0716 | manifest/file pruning and scan planning |
| REF-0717 | REST catalog protocol and change-based commit behavior |

### Review rules

The sources are primary or official, but documentation versions move. Revalidate connector support, format versions, command semantics, defaults, security controls and retention safeguards against the exact deployed versions before action.

This candidate is intentionally quarantined. The offline model can test decision ordering and fail-closed cleanup only. It cannot establish Trino, Iceberg, catalog, object-store, query, commit, evolution, compaction, retention, authorization, performance, production or learner behavior.

### Final retrieval

When a lakehouse incident feels confusing, return to:

```text
consumer
 -> query identity and phase
 -> catalog authority
 -> snapshot metadata closure
 -> compatibility
 -> pruning and distributed plan
 -> maintenance/retention
 -> correctness, recovery, capacity, cost and audit proof
```

That path converts “the lakehouse is slow or wrong” into owned, testable engineering questions.
