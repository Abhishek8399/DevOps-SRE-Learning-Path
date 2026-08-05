---
{"schemaVersion":1,"kind":"lesson","id":"LES-0065","slug":"specialized-data-service-reliability","aliases":["V06-L10","specialized-data-service-reliability"],"curriculumIds":["DMP-004"],"route":"/book/state/specialized-data-service-reliability","order":10,"volume":"06-state-distributed-systems","title":"Specialized data-service reliability: Cassandra, vector search, and trustworthy catalogs","summary":"Operate Cassandra-shaped distributed stores, vector-search systems and metadata catalogs by proving data models, placement, consistency, repair, deletion, retrieval quality, index capacity, lineage freshness, access, backup and recovery.","domain":"state","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0058","LES-0059","LES-0063"],"prerequisiteCurriculumIds":["DST-005","DST-003","DMP-002"],"testedEnvironments":[{"platform":"Official documentation","version":"Apache Cassandra 5.0, current Qdrant and OpenMetadata 1.12.x sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, database, vector index, catalog or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","data-engineer","data-platform-engineer","database-reliability-engineer","machine-learning-engineer","solutions-architect","technical-lead"],"learningObjectives":["Choose Cassandra from partition-key access patterns rather than relational expectations.","Trace Cassandra writes and reads through coordinator, token, replicas, commit log, memtable, SSTables and reconciliation.","State consistency guarantees using replication factor, topology, consistency level and failure assumptions without overclaiming.","Control hot/wide partitions, clock-sensitive last-write-wins conflicts, hints, repair, compaction, tombstones and deletion resurrection.","Design backup and restore evidence separately from replication and snapshots.","Define vector identity across source object, chunk, embedding model/version, dimensions, distance metric, point ID and payload.","Measure approximate-nearest-neighbor recall against an exact labeled baseline while controlling latency, memory and filtering.","Operate vector indexes, segments, WAL, shards, replicas, transfers, snapshots and embedding migrations with reversible state.","Treat a metadata catalog as a potentially stale representation of source authority, not the source data or access authority.","Validate lineage provenance, freshness, direction, entity identity and coverage before impact or compliance claims.","Protect sensitive metadata, samples, query history, classifications and lineage with least privilege and auditable ingestion identities.","Connect reliability, security, observability, capacity, recovery, privacy and cost across all three service classes."],"productionSignals":["consumer operation and correctness/latency SLI","CQL statement shape partition/clustering keys consistency level coordinator and request ID","keyspace replication strategy factor datacenter rack token range and replica endpoints","write acknowledgement commit-log/memtable/SSTable path mutation timestamp and timeout","read replicas digests reconciliation speculative retry and latency","partition bytes rows cells tombstones and per-key traffic skew","node/rack/DC health ownership pending hints dropped messages and clock offset","repair scope age progress streams failures and unrepaired bytes","compaction pending bytes throughput SSTable count overlap amplification and free space","snapshot/incremental backup manifest schema checksum location age and restore result","vector collection point/source/chunk embedding model dimension metric payload and version","query vector/filter/top-K/index parameters candidates latency recall and rerank result","segment/WAL/index state optimizer debt memory page faults disk and CPU","vector shard/replica peer placement transfer state update ordering and snapshot restore","catalog entity stable name/source identity/version/owner/classification and policy","ingestion run connector/source checkpoint start/end status coverage and lag","lineage edge source method evidence time confidence and verification","catalog API/store/search-index health consistency lag and authorization result","principal action resource policy version secret reference encryption and audit","data/vector/metadata copies retention deletion legal hold recovery and unit cost"],"diagrams":[{"id":"LES-0065-DIA-001","title":"Cassandra request and storage path","direction":"left-to-right","boundaries":["client query","coordinator","token and replicas","commit log and memtable","SSTables","read reconciliation","consumer"],"evidencePoints":["partition key","consistency level","replica endpoints","acknowledgements","mutation timestamp","SSTables","result"],"textAlternative":"A Cassandra coordinator maps the partition key to replicas, coordinates acknowledgements and local durable storage, then reconciles reads according to the requested contract."},{"id":"LES-0065-DIA-002","title":"Deletion and repair safety cycle","direction":"cyclic","boundaries":["delete mutation","replica tombstones","node outage","repair horizon","compaction and grace","purge or resurrection"],"evidencePoints":["timestamp","replica coverage","last repair","gc grace","repaired SSTables","absence proof"],"textAlternative":"Tombstones must reach replicas through repair before grace and compaction permit purge, otherwise stale data can return."},{"id":"LES-0065-DIA-003","title":"Vector retrieval evidence path","direction":"left-to-right","boundaries":["source object and chunk","embedding model","point and payload","vector and payload indexes","filter and ANN candidates","rerank","consumer result"],"evidencePoints":["source/version","model/dimensions/metric","point ID","index version","candidate count","exact baseline","relevance"],"textAlternative":"Vector retrieval depends on source/chunk and embedding identity, compatible collection schema, filtered approximate candidate generation and evaluated ranking."},{"id":"LES-0065-DIA-004","title":"Vector storage and distribution","direction":"hierarchical","boundaries":["collection","shards","replicas","WAL","segments","vector index","payload index","snapshot"],"evidencePoints":["collection schema","shard key","peer placement","operation sequence","segment state","index memory","filter cardinality","restore"],"textAlternative":"A collection splits into placed shards and replicas; updates pass through durable ordering into segments and indexes whose memory and recovery must be operated."},{"id":"LES-0065-DIA-005","title":"Catalog truth and freshness path","direction":"left-to-right","boundaries":["authoritative source","connector observation","ingestion run","metadata store","lineage graph","search index","catalog consumer"],"evidencePoints":["source identity/version","checkpoint","run status","entity version","edge provenance","index lag","as-of time"],"textAlternative":"A catalog is an ingested representation whose entity, lineage and search views can lag or disagree with the authoritative source."},{"id":"LES-0065-DIA-006","title":"Cross-service operating envelope","direction":"hierarchical","boundaries":["user SLI","data/search/catalog contract","live capacity","maintenance and rebuild","security/privacy","backup/restore","cost"],"evidencePoints":["correctness/recall/freshness","identity","headroom","drain time","authorization","recovery proof","unit cost"],"textAlternative":"Each specialized service needs an explicit correctness metric, live and maintenance capacity, access boundary, tested recovery and outcome-linked cost."}],"commands":[{"id":"LES-0065-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0065 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"Cassandra, Qdrant or OpenMetadata behavior"},{"id":"LES-0065-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"service setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0065-CMD-003","question":"Does the baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0065 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0065-CMD-004","question":"Does the query bind its partition?","risk":"read-only","command":"bash lab.sh evaluate query-without-partition-key","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=partition-query","meaning":"access pattern conflicts with partitioned model","nextEvidence":"redesign query/table"}],"proves":"encoded access gap","doesNotProve":"CQL planner behavior"},{"id":"LES-0065-CMD-005","question":"Can repair finish before tombstone grace?","risk":"read-only","command":"bash lab.sh evaluate repair-window-missed","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=repair-horizon","meaning":"deletion can outlive synchronization safety","nextEvidence":"stop purge and restore repair discipline"}],"proves":"encoded horizon gap","doesNotProve":"replica convergence"},{"id":"LES-0065-CMD-006","question":"Is maintenance capacity positive?","risk":"read-only","command":"bash lab.sh evaluate compaction-no-headroom","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=maintenance-headroom","meaning":"compaction/repair competes unsafely with live work","nextEvidence":"admission and drain plan"}],"proves":"encoded capacity gap","doesNotProve":"disk throughput"},{"id":"LES-0065-CMD-007","question":"Is embedding identity pinned?","risk":"read-only","command":"bash lab.sh evaluate embedding-model-unversioned","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=embedding-version","meaning":"stored/query vectors lack one comparable meaning","nextEvidence":"version and migration boundary"}],"proves":"encoded identity gap","doesNotProve":"embedding quality"},{"id":"LES-0065-CMD-008","question":"Is ANN recall measured?","risk":"read-only","command":"bash lab.sh evaluate recall-baseline-missing","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=recall-baseline","meaning":"latency improvement has no correctness comparator","nextEvidence":"exact/labeled evaluation set"}],"proves":"encoded evaluation gap","doesNotProve":"retrieval relevance"},{"id":"LES-0065-CMD-009","question":"Does the index fit its memory budget?","risk":"read-only","command":"bash lab.sh evaluate index-memory-exceeded","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=index-memory","meaning":"planned index exceeds admitted memory","nextEvidence":"reduce/repartition/on-disk/test trade-off"}],"proves":"encoded memory gap","doesNotProve":"runtime page behavior"},{"id":"LES-0065-CMD-010","question":"Is catalog freshness within its SLO?","risk":"read-only","command":"bash lab.sh evaluate catalog-ingestion-stale","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=catalog-freshness","meaning":"catalog view is older than its consumer contract","nextEvidence":"source checkpoint and ingestion path"}],"proves":"encoded freshness gap","doesNotProve":"source correctness"},{"id":"LES-0065-CMD-011","question":"Is lineage evidence verified?","risk":"read-only","command":"bash lab.sh evaluate lineage-unverified","runFrom":"LES-0065 support/lab","expectedBranches":[{"when":"boundary=lineage-evidence","meaning":"edge lacks trusted provenance/coverage","nextEvidence":"verify against jobs/queries/source"}],"proves":"encoded lineage gap","doesNotProve":"impact completeness"},{"id":"LES-0065-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0065 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"twenty-three branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"database vector catalog query repair backup index lineage load or production behavior","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0065-LAB-001","title":"Guided specialized data-service boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0065-specialized-data-service-reliability/support/lab"},{"id":"LES-0065-LAB-002","title":"Independent Cassandra/vector/catalog recovery transfer","mode":"independent","environment":"Reviewer-owned disposable local services and synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic tables, vectors, metadata and indexes","disposable repair/rebuild/ingestion/recovery state","approved faults"],"abortConditions":["shared service","real credential","customer data","host network/clock mutation","unbounded repair/rebuild/load","unknown ownership"],"recovery":"Preserve identities/history and reset through reviewer harness.","cleanupProof":"Reviewer proves processes, ports, files, volumes, tables, collections, entities and artifacts absent.","path":"drafts/LES-0065-specialized-data-service-reliability/support/lab"}],"incidents":[{"id":"LES-0065-INC-001","signal":"One Cassandra partition times out while cluster averages look healthy.","firstThought":"A partition-key access pattern or hot/wide partition can saturate its replica set behind healthy cluster averages.","safePath":"Bind query/key/token/replicas, size and per-key traffic; contain the key and redesign bounded buckets from measured access.","trap":"Add random nodes and retry harder."},{"id":"LES-0065-INC-002","signal":"Deleted Cassandra rows reappear after a node returns.","firstThought":"A replica missed tombstones and repair did not converge before safe purge/grace.","safePath":"Stop destructive compaction, preserve timestamps/repair history, isolate stale replica, restore authoritative deletion through reviewed repair and verify all replicas.","trap":"Delete the rows again at a weaker consistency level."},{"id":"LES-0065-INC-003","signal":"Vector search is faster after index tuning but relevant results disappear for filtered queries.","firstThought":"Approximate candidate budget and payload filtering changed recall; latency alone is not retrieval correctness.","safePath":"Pin corpus/embedding/query/filter/index versions, compare against exact/labeled baseline by slice, restore prior index/settings, then retune within recall and resource gates.","trap":"Increase top K without measuring recall."},{"id":"LES-0065-INC-004","signal":"A vector shard move completes but latency and missing-result reports rise.","firstThought":"Placement, replica state, transfer ordering, index rebuild or page-cache/memory state may be incomplete.","safePath":"Freeze moves, bind collection/shard/peer/operation versions, verify replica/index state and sampled recall, then restore or complete through supported transfer/recovery.","trap":"Move more shards to rebalance averages."},{"id":"LES-0065-INC-005","signal":"Catalog lineage shows no downstream impact, but a dashboard breaks after schema change.","firstThought":"Catalog freshness, connector coverage, entity matching or lineage provenance is incomplete; absence of an edge is not absence of dependency.","safePath":"Stop the change, bind source/catalog versions and ingestion run/checkpoint, verify edges against query/job evidence, restore compatibility, and repair freshness/coverage monitoring.","trap":"Declare the dashboard undocumented and continue."}],"assessmentIds":["ASM-0178","ASM-0179","ASM-0180"],"referenceIds":["REF-0733","REF-0734","REF-0735","REF-0736","REF-0737","REF-0738","REF-0739","REF-0740","REF-0741","REF-0742","REF-0743","REF-0744","REF-0745","REF-0746","REF-0747"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not Cassandra, Qdrant, OpenMetadata, a database, vector index, catalog, query engine, backup system or benchmark.","Synthetic decisions do not prove partition, replication, consistency, repair, compaction, retrieval, index, shard, ingestion, lineage, authorization or recovery behavior.","No socket, service, table, partition, replica, vector, collection, metadata entity, query, backup, repair, rebuild, load or external resource exists.","Semantics, defaults, guarantees, metrics and security controls are version-, topology-, workload-, storage-, configuration- and client-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Specialized data-service reliability: Cassandra, vector search, and trustworthy catalogs

## What you see and first thought

Three incidents arrive during the same on-call shift:

- one Cassandra query times out for a single customer while cluster CPU is 35 percent;
- semantic search became faster after tuning, but users say obvious documents disappeared;
- the data catalog reports no downstream dependencies, yet a dashboard broke after a column changed.

These look unrelated. They share one operating lesson: a healthy service average is not proof that the service's specialized correctness contract is intact.

For Cassandra, correctness starts with the partition-key access pattern, replica placement, requested consistency and repair history. For vector search, correctness includes retrieval recall and embedding identity, not only HTTP success and latency. For a metadata catalog, correctness includes freshness, source identity and lineage provenance; an empty graph can mean "no dependency" or "we failed to observe it."

Use this first thought:

> Specialized data systems optimize one shape of work. During an incident, prove that the request still matches that shape before scaling the service or changing a knob.

Bind the user operation to exact evidence:

```text
Cassandra:
request -> partition key -> token -> replica set -> acknowledgements
        -> commit log/memtable/SSTables -> repair/compaction history -> result

Vector search:
query -> embedding version/dimensions/metric -> filter -> ANN candidates
      -> optional rerank -> source objects -> relevance outcome

Catalog:
source object/version -> connector checkpoint -> ingestion run
       -> metadata entity/lineage edge -> search index -> consumer decision
```

Do not begin with a major compaction, forced repair, index rebuild, shard move, or catalog reingestion. Those actions mutate evidence and consume the same resources the incident needs.

## Terms before commands

### Wide-column store, keyspace, table, partition, and row

A **wide-column store** organizes rows by a primary key and is designed around partition-oriented access. In Cassandra, a **keyspace** defines replication policy for tables. A table has columns and a primary key.

The **partition key** is the part of the primary key that determines placement. Every row sharing that value belongs to one logical partition. Optional **clustering columns** order rows inside the partition and make bounded range retrieval efficient.

This is not a relational table with joins removed. The table should be designed from a query: "For this partition key, return this bounded clustering range." If the operation cannot supply the partition key, Cassandra may be the wrong table or the wrong store.

### Token, token range, vnode, coordinator, and replica

Cassandra hashes a partition key to a **token**. Nodes own token ranges, commonly through multiple **virtual nodes** or vnodes. A client contacts a node acting as **coordinator**. The coordinator maps the token to the replicas selected by the keyspace's replication strategy and topology.

The coordinator is a role for that request, not a permanent leader. **Replication factor** says how many replicas should store a partition. It does not prove those replicas occupy independent racks or datacenters, are healthy, or contain converged data.

### Consistency level and acknowledgement

A **consistency level** controls how many and which replica responses a coordinator requires before responding. It does not change how many replicas the write is intended for. For example, a quorum-style read/write relation can provide overlap only under its stated replication and failure assumptions.

Do not say "Cassandra is strongly consistent" or "eventually consistent" without scope. State:

- operation and table;
- replication factor and topology;
- read and write consistency levels;
- concurrent-write and clock assumptions;
- whether lightweight transaction semantics are used;
- behavior during unavailable or partitioned replicas.

An acknowledgement proves the requested response threshold at that time. It is not a backup, global convergence, or consumer correctness proof.

### Commit log, memtable, SSTable, and bloom filter

On a replica, a mutation enters the **commit log** for crash recovery and an in-memory sorted **memtable**. When flushed, the memtable becomes an immutable **SSTable** on disk. Updates do not edit old SSTables; later values coexist until reads reconcile timestamps and compaction rewrites files.

A **bloom filter** is a probabilistic structure that can say "definitely absent" or "possibly present." A possible result still requires checking storage. Bloom filters reduce unnecessary SSTable reads but do not solve hot partitions, poor queries or excessive overlapping files.

### Timestamp, last-write-wins, hint, read repair, and anti-entropy repair

Cassandra mutations carry timestamps and conflicting cells use last-write-wins behavior. Client-supplied or coordinator clocks therefore affect which value wins. A later clock is not business truth.

A **hint** records a missed delivery for later best-effort replay. It is not a permanent substitute for repair. Read-path reconciliation can repair some divergence observed by reads. **Anti-entropy repair** compares replica data for token ranges, identifies disagreement and streams differences. Repair is an owned recurring operation with network, disk and compaction cost.

### Tombstone, TTL, grace, zombie, and compaction

A delete writes a timestamped **tombstone**. An expired **TTL** also becomes deletion state. Replicas must learn the deletion before the tombstone can be safely purged. The grace horizon gives unavailable replicas time to return and repair to converge.

If stale data survives on a replica after the deletion marker is purged elsewhere, repair can make that deleted value live again. This is a **zombie** or resurrection.

**Compaction** merges immutable SSTables, keeps winning values and may purge deletion/expired state only when safety conditions permit. It can improve reads and reclaim space, but it creates read/write I/O, temporary disk demand and further compaction work. A major compaction is not routine first aid.

### Snapshot, incremental backup, restore, RPO, and RTO

A Cassandra snapshot creates local hard links to SSTables and captures schema information according to product behavior. Incremental backup retains SSTables produced after flush. Replication protects availability against some failures; it is not an independent backup against operator error, corruption, security compromise or region-wide loss.

**RPO** is the tolerated data-loss window. **RTO** is the tolerated service-recovery time. A backup file proves neither. Restore into an isolated target, verify schema/topology compatibility, load data through a supported process, and reconcile application invariants.

### Vector, embedding, dimensions, distance metric, point, and payload

A **vector** is an ordered numeric representation. An **embedding model** transforms source content into that representation. **Dimensions** are the vector length. A **distance metric** or similarity function defines what "near" means.

A vector database stores a **point** with stable ID, one or more vectors and optional **payload** metadata. Payload supports filters such as tenant, region, type or access class. Source object ID, chunking algorithm, embedding model/version, normalization, dimensions, metric, point ID and payload schema form one compatibility contract.

Vectors from different embedding spaces are not comparable merely because dimensions match. A model change is a data migration, evaluation and cutover, not an in-place software upgrade.

### Exact search, approximate nearest neighbor, top K, recall, and relevance

**Exact nearest-neighbor search** compares against the complete eligible corpus. **Approximate nearest neighbor** (ANN) indexes search a candidate subset to trade some recall for speed and resource efficiency. **Top K** is the number of returned candidates.

For a query set, **recall@K** can be expressed as:

```text
recall@K = relevant exact neighbors found by ANN / relevant exact neighbors in top K
```

Exact-neighbor recall measures approximation loss. Human-labeled **relevance** evaluates whether retrieved content helps the user. A system can have high ANN recall against a semantically poor embedding model. Measure both when the decision needs both.

### HNSW, payload index, segment, WAL, shard, and replica

**HNSW** is a graph-based ANN index. Build/search parameters trade memory, construction time, latency and recall. A **payload index** accelerates and estimates filters. Filtering and ANN interact: generating too few candidates before a restrictive filter can return fewer than K useful points.

In a Qdrant-shaped store, a collection is divided into **segments** containing points, payloads and indexes. A write-ahead log orders changes before segment application. **Shards** partition a collection; **replicas** provide redundant shard copies. Placement determines failure tolerance. Shard movement may transfer records or snapshots and may require index reconstruction or queued update catch-up.

### Catalog, metadata entity, ingestion, lineage, classification, and glossary

A **data catalog** stores representations of assets: databases, tables, topics, pipelines, dashboards, models and their metadata. An **entity** needs stable identity tied to its authoritative source. A connector **ingests** observed metadata and checkpoints its progress.

**Lineage** is a directed relationship such as "job reads source and produces target." An edge should retain source method, observation time, entity versions and confidence or verification state. SQL parsing, pipeline declarations and manual curation have different evidence strength and coverage.

A **classification** tags sensitivity or category. A **business glossary** defines organizational meaning. Neither automatically enforces access in the underlying data system. The catalog can expose sensitive names, schemas, samples, query history and relationships even when it does not store table rows.

### Source authority versus catalog representation

The database, object/table catalog, broker or application remains authoritative for its own data and access decisions. The metadata catalog is authoritative only for catalog-owned facts such as an approved business description or stewardship workflow, if governance says so.

Always say "as observed by connector X at checkpoint Y" for ingested metadata. Search indexes may lag the catalog store, which may lag the source. A catalog 200 response proves availability, not freshness.

## Architecture map

### Cassandra request ownership

```text
client and driver
    |
    | CQL + partition key + consistency + deadline
    v
coordinator
    |
    | hash key -> token -> replication strategy/topology
    v
replica A        replica B        replica C
commit log       commit log       commit log
memtable         memtable         memtable
SSTables         SSTables         SSTables
    \                |               /
     acknowledgements / read reconciliation
                    |
                    v
              client result
```

The driver owns contact-point discovery, routing policy, request deadline, retries and idempotency assumptions. The coordinator owns the request fan-out and response threshold. Each replica owns local durability and storage. Repair owns eventual convergence beyond a single request.

### Vector retrieval and storage

```text
source object/version -> chunker -> embedding model/version
                              -> point ID + vector + payload
                                             |
collection -> shard -> replica -> WAL -> segments
                                  |       | vector index
                                  |       | payload index
query text -> same embedding contract -> filter + ANN -> rerank -> result
                                                     \-> recall/relevance evidence
```

Vector search has two correctness layers. Storage correctness asks whether the intended points and versions exist and survive failure. Retrieval correctness asks whether the chosen encoder, filters, candidate generation and ranking return useful results.

### Catalog observation graph

```text
authoritative sources
  database  pipeline  dashboard  model registry
      \        |          |             /
        connectors with source checkpoints
                         |
                    ingestion runs
                         |
            metadata API/store + audit
                    /           \
              lineage graph    search index
                    \           /
                 catalog consumer
```

One failed connector can make only part of the graph stale. One entity-normalization bug can split one source asset into two catalog identities. One search-index lag can hide an entity that is present in the metadata store. Diagnose these as separate boundaries.

### Shared operating envelope

Cassandra repair/compaction, vector index rebuild/shard transfer and catalog ingestion/reindexing are background maintenance. Each competes with live traffic. Give maintenance:

- an admitted scope;
- a bottleneck and spare-capacity calculation;
- progress and pause signals;
- compatibility and correctness checks;
- rollback or recovery;
- exact ownership and audit.

## Request or state path

### Cassandra write

1. The application selects a table designed for the query and supplies the partition key.
2. The driver chooses a coordinator and sends deadline, consistency and mutation.
3. The coordinator maps the key to a token and replicas according to replication strategy/topology.
4. Replicas append durable recovery state and update memtables according to implementation.
5. The coordinator waits for the required responses.
6. The application receives success, timeout, unavailable or another error.
7. A timeout is an unknown outcome until the operation is reconciled.
8. Memtables later flush to immutable SSTables; compaction and repair handle different forms of storage and replica convergence.

Use a stable operation identity for effects that cannot tolerate duplicate application. Do not let driver and application retries multiply without one total budget.

### Cassandra read

1. The coordinator maps the partition key and selects replicas for the requested consistency.
2. Replicas consult memtables and SSTables, using metadata and bloom filters to reduce work.
3. Each replica resolves cell versions by timestamp.
4. The coordinator compares required responses and resolves returned versions.
5. Speculative retry may contact another replica for tail latency, depending on configuration.
6. The consumer receives a result that satisfies that request contract—not proof of all-replica convergence.

Log safely enough to correlate request, table, consistency, coordinator and latency without exposing keys or values.

### Vector upsert and query

An ingestion pipeline derives a stable point ID from source identity and chunk identity, computes an embedding with a pinned model and preprocessing version, validates dimensions and finite numeric values, then upserts vector plus access/filter payload.

A query must use the compatible embedding model and distance metric. Authorization/tenant filters apply before data is returned. The engine selects exact scan or ANN/index strategy, generates candidates, applies filter semantics, optionally reranks, and returns point/source identities. Offline evaluation joins those results to exact neighbors and human relevance labels.

### Catalog ingestion and use

A connector authenticates to a source with least privilege, records source and connector versions, reads a bounded checkpoint, normalizes stable entity identities, and writes metadata and lineage with run identity. The catalog persists the graph and updates its search view. Consumers must see "last observed" and freshness/coverage state.

Before using catalog lineage for a destructive schema change, verify the relevant source ingestion succeeded, entity matching is correct, and the lineage method covers that operation class. Empty lineage is not safe approval.

## Failure zoom

### Hot partition behind healthy averages

One tenant key owns millions of rows and most writes. Its token's replica set saturates while other nodes remain idle. Adding nodes may not split that single partition because its hash remains one token.

Contain the tenant or expensive query, identify exact partition size/rate and replica pressure, then redesign with a bounded bucket such as tenant plus time window or hash suffix derived from required reads. Bucketing increases read fan-out; choose it from access patterns and enforce a partition-size/rate budget.

### Timeout plus clock-skewed retry

A write times out after some replicas accept it. Another client with a clock 30 seconds ahead writes an older business value whose timestamp wins. Retrying at stronger consistency does not restore business ordering.

Preserve mutation identities/timestamps, stop uncontrolled retries, reconcile current replicas and business version, then use authoritative versioning or lightweight transactions where the invariant justifies coordination. Monitor clock offset, but do not confuse synchronized clocks with transactional order.

### Deleted data returns

A replica remains unavailable longer than the safe deletion synchronization window. Other replicas compact away the tombstone. When the stale replica returns, repair sees its old value without the deletion marker and can propagate it.

Stop purge/unsafe maintenance, isolate the stale node, preserve repair and SSTable evidence, restore deletion from an authorized source, repair within a reviewed procedure, and verify every replica plus consumers. Fix repair scheduling, grace, outage replacement and monitoring as one policy.

### Fast vector search loses filtered results

An ANN parameter reduces candidate exploration. A tenant/type filter is applied to those candidates and fewer than K survive. p99 improves, yet recall for a critical tenant collapses.

Pin corpus, query set, embedding, metric, filter and index versions. Compare the candidate against exact search and labeled relevance by filter slice. Restore previous settings or exact fallback, create/select payload indexes, and tune candidate effort under recall, latency and memory gates.

### Catalog says no impact

The lineage connector last succeeded three days ago. A new dashboard and its query were created yesterday. Search looks healthy and the entity has no downstream edges.

Contain the schema change. Compare source version/time with connector checkpoint, ingestion status, catalog entity and search-index state. Verify lineage from query/job evidence. Restore compatibility, then make freshness and connector coverage visible at the decision point.

## Internals and state ownership

### Data model is load placement

A Cassandra primary key is simultaneously identity, placement and ordered storage design. Partition-key cardinality distributes work; clustering keys organize bounded rows inside that placement. Secondary indexes and filtering features do not erase the need to model cardinality, selectivity and failure locality.

Duplicate data across query-specific tables is expected when each table has a clear producer and reconciliation contract. The cost is write amplification and consistency ownership. Do not add denormalized copies without naming how partial writes are detected and repaired.

### Consistency arithmetic has assumptions

For one replication domain with replication factor `N`, a common overlap condition is:

```text
R + W > N
```

where `R` and `W` are replica response requirements. This indicates read/write quorum overlap under the stated model. It does not provide cross-partition transactions, correct concurrent business ordering, immunity to clock skew, or global multi-datacenter linearizability.

Lightweight transactions add coordination for compare-and-set semantics in their supported scope. Use them for an actual invariant, measure contention and latency, and do not use a logged batch as a relational transaction substitute.

### LSM write/read/space amplification

Log-structured storage turns random updates into sequential append/flush work. The deferred cost appears later:

- **write amplification:** bytes rewritten by compaction;
- **read amplification:** SSTables/levels consulted to assemble a result;
- **space amplification:** live plus obsolete/temporary copies during compaction.

Compaction strategy must match write/update/delete/time-series patterns and storage. Monitor pending compaction and disk headroom. Throttling compaction too hard can build debt until reads and disk fail; running it too aggressively can starve live requests.

### Repair and deletion are one safety system

Hints, read repair and anti-entropy repair have different coverage. An explicit repair schedule must cover token ranges before the deletion safety horizon, including failed runs. Track repair age per range/table, not only the last job's green state.

Changing grace or enabling aggressive expiration is a data-safety decision. It depends on maximum replica outage, repair completion and policy. "Tombstones are slow" is not approval to purge deletion evidence.

### Vector index is a derived structure

The source object and embedding-generation record should be recoverable independently of the ANN index. Indexes can be rebuilt, but rebuild duration, CPU/memory/disk, live-query impact and exact corpus version determine RTO.

HNSW build/search effort changes recall and memory. Quantization or on-disk placement changes precision, memory and I/O behavior. Test with the production filter and query distribution; a benchmark without filters and cold/warm-state disclosure is incomplete.

### Stable vector identity and migration

Use point identity derived from source object version and chunk identity, or maintain an explicit mapping. Upsert makes retries converge. Deletion must remove every chunk/version and respect retention/legal policy.

For a new embedding model, create a separate named vector or collection/versioned namespace, backfill deterministically, measure coverage and quality, dual-read or shadow, cut over, preserve rollback, then retire old state under policy. Mixing spaces in one index silently corrupts similarity.

### Catalog is a graph with observation lag

Catalog entities and edges are metadata state. Ingestion can partially succeed: tables may update while lineage fails; the metadata store may commit while search indexing lags. Track per-connector/source coverage, watermark and failure class.

Manual descriptions and owners can be catalog-authoritative governance facts. Automatically ingested schema remains a representation. Keep field ownership explicit so reingestion does not overwrite stewardship and manual edits do not masquerade as source truth.

### Metadata has a threat model

Names, descriptions, schema, classifications, lineage, samples and query history can reveal sensitive systems and relationships. Search discovery itself may be restricted. Separate view-basic, view-sensitive, edit, ingest, classify, administer and delete permissions. Connector bots need only bounded read in the source and bounded write in the catalog.

## Evidence table

Use this as a routing map. One signal rarely proves one cause. Ask which boundary must be unhealthy for the user symptom to exist, then seek independent confirmation.

| Symptom | Bind first | Evidence collected together | Safe next move |
|---|---|---|---|
| One Cassandra key is slow | query to partition | CQL shape, bound key, token, replicas, per-key rate, partition size | contain the key; inspect the model |
| Many keys are slow | shared path | client/coordinator latency, dropped messages, disk latency, compaction debt, runtime pauses, network | split compute, network and storage timelines |
| Write times out | acknowledgement | replication/topology, consistency level, live replicas, acks, request ID, timestamp | use idempotent retry; determine outcome |
| Read is old or disputed | reconciliation | responding replicas, timestamps, consistency, concurrent writers, repair age | preserve versions; establish business authority |
| Deleted data returns | deletion horizon | tombstone time, outage, range-repair history, grace policy, compaction | stop unsafe purge; isolate stale replica |
| Disk falls during compaction | maintenance headroom | live/debt/temp bytes, write and drain rate, repair/stream/snapshot load | reduce admission or add verified headroom |
| Backup job is green | recovery chain | schema, manifests, checksums, external copy, keys/config, restore duration and invariant checks | restore into isolation |
| Vector results changed | semantic identity | source/chunk/model versions, dimensions, metric, collection/index, filter, reranker | restore pinned version; compare baseline |
| Filtered search misses items | filter plus ANN path | selectivity, payload index, candidate budget, exact result set, recall by slice | tune against exact/labeled truth |
| Vector memory grows | index capacity | points, dimensions, encoding, graph, payload indexes, replicas, segments, RSS/cache | enforce admission; measure layout |
| Shard move completes but misses rise | placement/rebuild | shard/replica/peer IDs, transfer/WAL sequence, segment/index state, sampled recall | freeze moves; verify every replica |
| Catalog search is stale | observation path | source version, checkpoint, ingestion timestamps, entity version, index watermark | show as-of time; repair failed stage |
| Catalog shows no lineage | evidence coverage | connector/parser versions, query-history window, identity match, edge provenance | label unknown; corroborate elsewhere |
| Catalog leaks metadata | authorization | principal, policy version, classification, returned fields, audit and cache/index | revoke narrowly; preserve evidence |

Evidence must share identity and time. Record timezone and clock source; cluster and object; partition token, point ID or entity identity; client/coordinator/peer/connector; configuration version; query, filter, consistency or index parameters; and measurement window. Facts that cannot be joined by identity and time are context, not proof.

Absence is dangerous. "No downstream edge" is safe only when the observation path is healthy, expected scope is covered, the checkpoint is newer than the change, identity matching succeeded and retention includes the event. Otherwise the conclusion is **unknown**, not **no dependency**.

## Command decoders

These commands run only the offline decision model. They neither install nor operate Cassandra, Qdrant or OpenMetadata.

### Establish the boundary

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

`doctor` checks normal-user, ownership, interpreter and no-network guards. `setup` creates a synthetic UID-scoped worksheet; it is not a service deployment. `status` describes that worksheet, not database health. A guard failure is a stop signal—never bypass it with `sudo`.

### Read the complete healthy chain

```bash
bash lab.sh evaluate baseline
```

Expected: `boundary=operable`. This proves only that all encoded conditions pass in dependency order. Each negative case stops at the first unsafe boundary.

### Expose Cassandra boundaries

```bash
bash lab.sh evaluate query-without-partition-key
bash lab.sh evaluate repair-window-missed
bash lab.sh evaluate compaction-no-headroom
```

The expected boundaries are `partition-query`, `repair-horizon` and `maintenance-headroom`. They mean the operation conflicts with its distribution contract, deletion evidence may not have reached replicas in time, or maintenance cannot coexist safely with live work. They do **not** authorize an unbounded scan, full repair or major compaction.

### Expose vector boundaries

```bash
bash lab.sh evaluate embedding-model-unversioned
bash lab.sh evaluate recall-baseline-missing
bash lab.sh evaluate index-memory-exceeded
```

The expected boundaries are `embedding-version`, `recall-baseline` and `index-memory`. Dimensions alone do not prove semantic compatibility. HTTP success and latency do not prove retrieval quality. Raw vector bytes do not prove resident memory.

### Expose catalog boundaries

```bash
bash lab.sh evaluate catalog-ingestion-stale
bash lab.sh evaluate lineage-unverified
```

Expected boundaries are `catalog-freshness` and `lineage-evidence`. Trace source version through checkpoint, ingestion, metadata commit and search projection. A visible edge needs method, provenance, time and coverage.

### Verify and clean up

```bash
bash verify.sh
bash lab.sh cleanup
```

The verifier starts absent, exercises all twenty-three cases, checks each expected first boundary, tests refusal behavior, cleans up and proves state absence. A pass proves the teaching artifact's lifecycle—not real service behavior.

For production, identify the exact product/version, open its official command reference, prefer read-only status, scope the object, capture output and time, peer-review mutation, and define abort plus rollback before repair, compaction, rebuild, restore, move, purge or reingestion.

## Decision path

### Cassandra: slow, unavailable, wrong or resurrected?

```text
Symptom
  -> bind request, query and time
  -> query binds designed partition and bounded range?
       no: data-model boundary
  -> one key/token/replica set dominant?
       yes: hot/wide-partition path
  -> required replicas acknowledged/responded?
       no: topology/network/node/storage path
  -> value disputed?
       yes: timestamps + consistency + writer authority
  -> deleted value returned?
       yes: freeze purge; repair/tombstone/grace investigation
  -> maintenance debt rising?
       yes: admission + headroom + drain decision
```

A timeout means the client may not know whether a write applied. Blindly retrying a non-idempotent operation can duplicate effects. Keep operation identity and make retries converge. "Latest timestamp" may not mean "correct business event"; preserve versions and resolve domain authority.

### Vector retrieval: availability, latency or relevance?

```text
Complaint
  -> bind query, collection/version, corpus and deployment
  -> model/preprocessing/dimensions/metric compatible?
       no: identity or migration incident
  -> expected source/chunk point IDs present?
       no: ingestion/deletion/replication path
  -> exact/labeled baseline contains expected result?
       no: corpus, label or embedding-quality path
  -> ANN loses it, especially with filters?
       yes: candidate/index/filter path
  -> correct but slow?
       yes: CPU/memory/I/O/segment/shard/rerank path
```

Track availability, latency and retrieval quality separately. A defensible gate is "p95 below 180 ms while recall@10 stays at least 0.93 in every critical language and filter slice."

### Catalog: stale, incomplete or unauthorized?

```text
Wrong catalog claim
  -> establish authoritative source identity/version
  -> connector observed it?
       no: source access/checkpoint path
  -> ingestion committed entity and edge?
       no: transform/match/store path
  -> search reached metadata-store version?
       no: projection/index lag
  -> lineage method and coverage sufficient?
       no: label unknown; corroborate with job/query evidence
  -> viewer authorized for fields and relationships?
       no: contain access and assess exposure
```

Never use catalog silence as schema-change approval. Combine catalog evidence with repository search, job/query telemetry, ownership confirmation and compatibility tests.

## Guided Ubuntu lab

This lab trains dependency-order diagnosis. It creates no service, opens no socket and needs no cloud account. Run it on Ubuntu 24.04 as a normal user. Think of it as a flight-simulator panel: it teaches which instrument to inspect first, but cannot certify a real database.

From the repository:

```bash
cd drafts/LES-0065-specialized-data-service-reliability/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Confirm that the state root is scoped to your numeric user, data is synthetic, inventory is exact and `status` reports model state rather than service health.

### Exercise 1 — learn the healthy chain

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Trace Cassandra query, placement, consistency, repair, maintenance and recovery; then vector identity, quality, index, distribution and recovery; then catalog authority, freshness, lineage and access. For every boundary write: "This evidence is required before the next conclusion because …"

### Exercise 2 — separate Cassandra failure classes

```bash
bash lab.sh evaluate query-without-partition-key
bash lab.sh evaluate hot-partition
bash lab.sh evaluate tombstone-purge-unsafe
```

The first is a data-model mismatch, the second is workload skew despite spare aggregate capacity, and the third threatens deletion correctness. For each, record the first unsafe boundary, production evidence, one evidence-destroying action, one reversible containment and one prevention control.

Compare `repair-window-missed` with `tombstone-purge-unsafe`. The first asks whether deletion evidence reached replicas in time. The second asks whether observed convergence justifies removing it. They are linked but not identical.

### Exercise 3 — test vector correctness, not speed alone

```bash
bash lab.sh evaluate embedding-model-unversioned
bash lab.sh evaluate dimension-metric-mismatch
bash lab.sh evaluate recall-baseline-missing
bash lab.sh evaluate filter-index-missing
bash lab.sh evaluate index-memory-exceeded
```

Create a migration manifest containing old, candidate and rollback values for source snapshot, chunking version, embedding model, preprocessing, dimensions, metric, collection/index, payload schema, evaluation set and quality/latency gates. Unknown identity makes the comparison irreproducible. Destructively rewriting the same collection is not rollback.

### Exercise 4 — make catalog uncertainty visible

```bash
bash lab.sh evaluate catalog-ingestion-stale
bash lab.sh evaluate lineage-unverified
bash lab.sh evaluate metadata-access-overbroad
```

Split source-to-search lag into schedule wait, extraction, queue, transform/store and search projection. Describe a lineage edge with upstream/downstream identity, direction, method, evidence, observation time, coverage, confidence, verifier and blind spots. Then list which fields a basic viewer truly needs; metadata can itself disclose sensitive systems.

### Exercise 5 — verification, cleanup and recall

```bash
bash verify.sh
bash lab.sh cleanup
bash lab.sh status
```

If verification fails, preserve the first error and never weaken an assertion. State the limitation in your evidence: no actual Cassandra, vector index or catalog runtime was exercised.

Close the lesson and answer from memory: Why can one key fail while average CPU is low? How can deletion resurrect? What identities make vectors comparable? Why can lower ANN latency be a regression? Why is empty lineage not proof of no dependency? What does a green backup job fail to prove? Correct missed boundaries after one day and one week.

## Production transfer

This transfer is reviewer-owned. Use disposable local services and synthetic data only. Record exact versions, isolated addresses, ports and credentials; CPU/memory/disk ceilings; created objects; fault duration; abort thresholds; reset procedure; and final absence of processes, ports, files, volumes and objects.

### Cassandra transfer

Create a table from a declared bounded query such as "last N synthetic events for tenant and day." Generate distributed keys and one hot key. Under review:

1. record replication, topology and consistency assumptions;
2. observe per-partition latency and replica work;
3. make one replica unavailable, issue a synthetic deletion, restore it and use the supported scoped repair path;
4. create bounded compaction debt and measure drain without exhausting disk;
5. back up schema, manifests and checksums;
6. restore separately and validate row-level invariants.

Passing evidence includes query-to-key rationale, measured skew, repair scope/history, deletion convergence on every replica, headroom arithmetic and a timed restore—not merely successful commands.

### Vector transfer

Use a small licensed or synthetic corpus with stable object/chunk IDs, two distinguishable model/index versions and an exact or reviewed labeled baseline. Prove idempotent upsert; compare exact and ANN recall by filter slice; change one index parameter at a time; observe missing payload-index behavior; perform a bounded shard/replica transfer; snapshot with semantic manifest; restore separately; and migrate through a versioned collection or named-vector boundary with rollback.

A restore that returns HTTP 200 but serves another corpus/model or fails recall is unsuccessful.

### Catalog transfer

Create synthetic entities and a job/query graph, including one manually governed field and one sensitive classification. Measure entity-store and search freshness separately. Fail one bounded ingestion stage, expose age and partial coverage, corroborate lineage against independent job/query evidence, test viewer/steward/bot permissions, and restore while preserving identities and manual governance fields.

Submit architecture and identity maps, manifests, raw timestamps, calculations, fault timeline, before/after correctness and performance, recovery proof, authorization matrix, cleanup proof, limitations and one unresolved risk. The reviewer owns faults and attests cleanup.

## Reliability, security, observability, capacity, and cost

### Cassandra service levels and hot partitions

Track success at the declared consistency level, correct-value checks, latency by key slice, maximum repair age per range/table, deletion convergence, tested restore and maintenance headroom.

For 99.95 percent availability in a 30-day month:

```text
30 * 24 * 60 * (1 - 0.9995) = 21.6 minutes
```

Availability can remain green while stale or resurrected data is served, so correctness needs a separate SLI.

If one tenant generates 3,000 requests/s out of 20,000:

```text
hottest-key share = 3,000 / 20,000 = 15%
```

That work remains concentrated on one replica set. Adding random nodes does not split a partition. Bucketing can, but it adds read fan-out and must follow a bounded query plan.

### Maintenance drain, headroom and repair horizon

```text
net drain rate = maintenance processing rate - new debt arrival rate
drain time = queued debt / net drain rate
```

With 900 GiB queued, 80 MiB/s processing and 50 MiB/s arriving, net drain is 30 MiB/s and drain time is about 8.53 hours. At 80 MiB/s arrival, debt never drains. Reduce admitted work or increase verified capacity.

Free space must cover peak temporary rewrite, live growth during maintenance, concurrent repair/streaming, retained local snapshots, operating reserve and uncertainty. A folklore free-space percentage is not universal.

Let `O` be maximum replica outage, `S` repair scheduling delay, `D` worst measured repair duration, `M` margin and `G` deletion grace:

```text
O + S + D + M < G
```

This is necessary, not sufficient: repair must cover the correct ranges and succeed. If those terms are 24, 12, 30 and 12 hours, the required horizon exceeds 78 hours; 48 hours is unsafe.

### Vector memory, recall and migration

Raw vector bytes are a lower bound:

```text
bytes = points * dimensions * bytes per component
10,000,000 * 768 * 4 = 30,720,000,000 bytes ≈ 28.6 GiB
```

Add graph links, IDs, payload indexes, segments, allocator overhead, replicas, rebuild overlap and cache. If measured resident demand is 1.8 times raw bytes per replica with two replicas, the scenario is about 103 GiB. The 1.8 factor is measured input, not a universal constant.

```text
recall@K = |ANN results intersect exact relevant top-K| / |exact relevant top-K|
```

Nine matching items out of an exact top ten means recall@10 of 0.9. Measure by language, tenant, filter selectivity and content age; aggregate recall can hide harmed users.

```text
rebuild duration = admitted points / sustained indexed points per second
```

Forty million points at a measured 4,000 points/s take about 2.78 hours before ingestion catch-up and validation. Migration storage includes old and new versions, snapshots and working headroom. If catch-up is slower than live arrival, cutover never converges.

### Catalog freshness and backlog

```text
observation lag =
  schedule wait
  + extraction
  + queue wait
  + transform/store
  + search projection
```

For 1.2 million queued entities, 600/s processing and 400/s arrivals, net drain is 200/s and drain time is 100 minutes. At 600/s arrival it never drains. Alert on age and time-to-SLO-breach, not only connector success.

### Security, privacy and cost

Cassandra needs authenticated clients/nodes, narrow table privileges, transport encryption, separated application/repair/admin identities and protected backups. Vector systems need tenant-aware collection/payload authorization, protected embeddings and snapshots, stable point identity and safe administrative audit. Catalogs need discovery and field-level policy for metadata, lineage, classifications, samples and query history; bounded connectors; external secret references; and audited governance changes.

Measure cost against a useful outcome:

- Cassandra: cost per successful bounded operation plus repair and recovery overhead;
- vector: cost per query meeting latency **and** recall gates;
- catalog: cost per entity/source kept inside freshness and coverage SLO.

Cheap but stale, irrelevant or unrecoverable service is not efficient. Attribute serving, replication, maintenance, backup, rebuild, ingestion and reserve separately before removing safety margin.

## Traps and prevention

### Model Cassandra after entities instead of queries

A normalized entity model often forces scans or fan-out that contradict partition-local access. Prevention: begin with named operations, required partition/clustering keys, result bounds, ordering, amplification and expected skew. Use separate tables when queries require different distributions.

### Call replication a backup

Replication quickly copies useful writes and accidental deletion, corruption or bad output. Prevention: keep independent versioned artifacts outside the failure domain; include schema/config/keys; rehearse restoration and application invariants against RPO/RTO.

### Treat a timeout as a failed write

Some replicas may have applied the mutation. Prevention: stable operation IDs, idempotent writes or domain deduplication; determine outcome before compensation; retain request and replica evidence.

### Cure tombstone latency by reducing grace

Purging deletion evidence before replicas converge can resurrect data. Prevention: bind outage, repair coverage/duration and compaction; monitor maximum repair age; review grace changes as data-safety changes.

### Run broad repair or compaction during uncertainty

Both consume I/O, network, CPU and disk while changing evidence. Prevention: preserve state, scope range/table, calculate headroom and drain, set abort thresholds, and use the version-specific supported procedure.

### Compare vectors by dimension only

Equal-length arrays from different models, preprocessing or metrics may be incomparable. Prevention: store semantic identity; migrate into a versioned boundary; shadow, evaluate, cut over and retain rollback.

### Optimize ANN by latency only

Lower candidate work can drop relevant results. Prevention: gate tuning on exact/labeled recall and relevance by critical slice, alongside latency and resources.

### Estimate index memory from vector bytes

Graph links, payload indexes, segments, replicas, allocators, rebuild overlap and cache add demand. Prevention: use raw bytes as a floor, measure representative layouts, admit to a budget and reserve migration headroom.

### Accept control-plane completion as data-plane correctness

A transfer or build can complete while a served replica is cold, incomplete or semantically different. Prevention: bind operation and replica IDs, verify counts/sequence/index state, then replay a versioned recall suite through serving.

### Treat the catalog as authority

It is an observation plus governed metadata and can lag or misidentify. Prevention: record source identity, checkpoints, coverage, as-of time, edge provenance and field ownership; corroborate high-impact claims.

### Assume metadata is harmless

Names, schemas, samples, owners, lineage and query history reveal sensitive structure. Prevention: classify metadata, enforce least privilege for discovery and fields, separate ingestion identities and audit reads plus changes.

## Memory card and retrieval

Remember **PARTITION — VECTOR — CATALOG**:

```text
PARTITION
  Query -> key -> token -> replicas -> acknowledgement
  Timestamp -> repair -> tombstone grace -> compaction
  Backup -> isolated restore -> invariant

VECTOR
  Source/chunk -> model/version -> dimensions/metric -> point
  Filter -> ANN candidates -> rerank -> recall/relevance
  WAL/segments -> index -> shards/replicas -> restore

CATALOG
  Source/version -> checkpoint -> ingestion -> metadata store
  Lineage provenance -> search watermark -> consumer
  Viewer/policy -> as-of time -> decision with uncertainty
```

Five incident sentences:

1. A healthy average can hide one hot identity.
2. An acknowledgement proves only its requested threshold at that moment.
3. Deletion stays correct only while replicas receive its evidence before purge.
4. Faster search can be less correct; measure recall and relevance.
5. Missing metadata evidence means unknown until coverage is proven.

Four calculations:

```text
maintenance drain = queued debt / (processing rate - arrival rate)
raw vector bytes = points * dimensions * bytes/component
recall@K = intersection with exact top-K / exact top-K
catalog drain = backlog / (processing rate - arrival rate)
```

At the next review, redraw all three paths and explain why replication is not recovery, dimensions are not semantic identity and a catalog edge needs provenance.

## Complete answers

### Why can one Cassandra partition time out while cluster CPU is low?

The partition key hashes to one token and one replica set. A hot tenant or oversized partition can saturate those replicas, their disks or queues while most nodes are idle. Cluster-average CPU hides the local bottleneck.

Bind query, key, token and replicas. Compare per-key rate, partition size/tombstones, replica latency and maintenance. Contain with key-specific admission. Redesign a bounded bucket only after defining how reads find and limit buckets. Adding arbitrary nodes does not split one logical partition.

### What does a Cassandra write timeout mean?

The coordinator did not receive the acknowledgements required by the requested consistency level before timeout. It does not prove that zero replicas wrote. Retrying a non-idempotent effect may duplicate it. Preserve operation identity, prefer convergent writes or deduplication, and determine the business outcome before compensation.

### How can deleted data reappear?

A delete is a timestamped tombstone. If replica C is unavailable while A and B receive it, repair fails or misses the range, and A/B later purge that evidence, C can return with an older live value. Nothing then defeats that stale value.

Stop accelerated purge, preserve deletion/outage/repair history and isolate the stale replica if required. Use a reviewed scoped recovery that restores authoritative deletion, then verify every replica and consumer. Prevention joins maximum outage, repair schedule/duration/margin and grace with proven range coverage.

### Why are quorum formulas not universal strong consistency?

An overlap such as `R + W > N` describes replica intersection under stated assumptions. It does not resolve concurrent writes into business intent, fix clock errors, make multi-object work atomic, guarantee all datacenters participate or prove clients used those levels. State operation, topology, levels, concurrent-writer/clock assumptions and failure behavior.

### Why is a backup incomplete until restore?

Artifact creation omits schema/config, keys, incremental order, checksums, independent location, capacity and application validation. An isolated rehearsal is what measures RPO/RTO and proves the consumer can use recovered state.

### What makes two vectors comparable?

They need compatible source/chunk semantics, exact embedding model/version, preprocessing, dimensions, representation and distance metric. The served collection/named-vector schema must match. Equal dimensions prove shape only.

Use an immutable manifest. Migrate into a separate version, backfill deterministically, measure coverage/recall, shadow or dual-read, cut over reversibly and retain rollback.

### Why can faster approximate search be a regression?

ANN saves work by pruning candidates. More pruning can lower latency while dropping relevant items, especially with selective filters. Pin corpus, query set, filter distribution, warm state, concurrency and index version; compare with exact search or reviewed labels; gate recall/relevance by slice alongside latency and resources.

### Why is raw-vector memory arithmetic insufficient?

It excludes graph links, point IDs, payload indexes, segments, allocator fragmentation, replicas, rebuild overlap and cache. Treat it as a floor. Measure representative resident and peak rebuild demand, then preserve failure and migration headroom.

### Why is empty lineage not proof of no dependency?

Source access may fail, checkpoints may be old, parsers may not understand queries, history may expire, entity matching may fail, ingestion may partially commit or search may lag. Absence is meaningful only after observation health, coverage, identity and time are proven. Corroborate risky changes with jobs, query history, code, owners and tests.

### What should an SRE do first when a catalog is stale?

Bind one source object/version and expected SLO. Trace source access, connector checkpoint, ingestion run, entity commit and search watermark. Preserve run evidence, expose as-of time, contain dependent decisions and repair the first diverging stage. Reingesting everything first may amplify load and erase the diagnostic boundary.

## Product-company interview

### Design Cassandra for a multi-tenant event timeline

Start from: "Fetch newest bounded N events for tenant T over a bounded date interval." A candidate partition key is tenant plus time bucket; event time and stable event ID cluster rows. Bucket size follows measured rate, row size, retention and read fan-out.

Cover rack/DC replication, per-operation consistency, idempotent ingest, timestamp ownership, TTL/deletion and repair horizon, workload-appropriate compaction, skew, headroom, backup/restore and evolution. Global search needs another query table or system.

**Senior follow-up:** one tenant becomes 20 percent of traffic. Nodes alone do not split its partition. Apply tenant admission, then migrate to a versioned sharding/bucketing scheme that preserves ordering, bounded reads and rollback.

### Deleted records return after a node rejoins. Lead the incident.

Declare correctness and possible privacy impact. Freeze aggressive purge/compaction and topology work. Bind table/keys, deletion times, replicas/ranges, outage, grace and repair coverage. Isolate stale service if propagation is possible. Preserve logs and storage/repair/config evidence.

Recover through an approved scoped procedure with capacity limits; verify replicas and downstream views; assess notification obligations. Prevent with per-range repair-age SLO, failed-repair alerting, deletion drills and controlled grace review.

**Senior follow-up:** deleting again may not reach all stale replicas or repair the synchronization mechanism, and it destroys evidence of scope.

### Design a vector migration without blind cutover

Define source snapshot, chunking, model/preprocessing, dimensions, metric, point IDs, payload and index. Create a separate versioned collection or named vector. Backfill idempotently, track coverage/catch-up, evaluate recall and relevance by slice, measure tail latency/resources, shadow traffic, then switch through reversible routing.

Retain old state and manifests through rollback. Restore the candidate separately and replay the same suite. Capacity includes both versions, replicas, snapshot and rebuild headroom.

**Senior follow-up:** if aggregate recall rises but one critical language falls, the release fails its per-slice gate.

### Catalog says a breaking change has no consumers. Approve?

No. Establish source version and catalog as-of time; verify connector coverage/checkpoint, lineage method, parser/history coverage, identity matching and search lag. Corroborate with query logs, schedulers, code search, contracts and owners. Prefer additive compatibility, deprecation telemetry and rollback.

The senior insight: absence of an observed edge is not absence of dependency until observation completeness is proven.

### How do you set SLOs across these services?

Cassandra: availability/latency at declared consistency, correctness, repair age, deletion convergence and restore. Vector: availability, latency, recall/relevance by slice and freshness. Catalog: source-to-search freshness, coverage, authorization correctness and restore.

Define identity, windows, exclusions and unknown-data handling. Error budgets apply to user outcomes; safety invariants are not casually traded for release velocity.

### What automation would you build first?

Evidence automation: request/object identity packets, per-range repair age/headroom, versioned vector evaluation, source-to-index catalog watermarks and recovery manifest checks. Then automate reversible containment with bounds and approvals. A bot that launches broad repair, rebuild or reingestion from a noisy alert magnifies incidents.

## Independent transfer and rubric

The learner receives a new synthetic scenario and bounded evidence, not the answers above. They must map the consumer operation, find the first unsafe boundary, separate known/inferred/unknown, calculate skew/drain/memory/recall where relevant, propose reversible containment, build a versioned diagnosis, design prevention/SLOs, and specify recovery plus cleanup proof.

- **90–100:** complete identity/time chain; correctness, capacity, security and recovery integrated; explicit calculations, limitations and reversible actions.
- **75–89:** safe diagnosis with minor evidence or calculation gaps.
- **60–74:** useful pieces, but one major correctness, quality, freshness or recovery contract is weak.
- **below 60:** command-first mutation, average-only reasoning, unsupported absence or unsafe handling.

Automatic failure includes shared/production targets, real credentials/data, destructive repair/rebuild/purge without review, fabricated evidence, hidden uncertainty or missing cleanup. Reading and a model pass do not award mastery; reviewer-observed transfer and delayed retrieval are required.

## References and review

Primary sources reviewed:

- [Apache Cassandra architecture overview](https://cassandra.apache.org/doc/stable/cassandra/architecture/overview.html) — cluster, tokens, replication and requests.
- [Dynamo foundations](https://cassandra.apache.org/doc/stable/cassandra/architecture/dynamo.html) — partitioning and replication lineage.
- [Cassandra storage engine](https://cassandra.apache.org/doc/stable/cassandra/architecture/storage-engine.html) — commit log, memtable, SSTables and compaction.
- [Cassandra guarantees](https://cassandra.apache.org/doc/stable/cassandra/architecture/guarantees.html) — scoped guarantees and timestamps.
- [Cassandra repair](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/repair.html) — anti-entropy operations.
- [Cassandra compaction overview](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/compaction/overview.html) — strategies and effects.
- [Cassandra backups](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/backups.html) — snapshot and incremental concepts.
- [Cassandra security](https://cassandra.apache.org/doc/stable/cassandra/managing/operating/security.html) — authentication, authorization and encryption.
- [Qdrant overview](https://qdrant.tech/documentation/overview/) — collections, points, payload and search.
- [Qdrant indexing](https://qdrant.tech/documentation/manage-data/indexing/) — vector and payload indexes.
- [Qdrant storage](https://qdrant.tech/documentation/storage/) — storage, WAL, segments and snapshots.
- [Qdrant distributed deployment](https://qdrant.tech/documentation/scaling/distributed_deployment/) — shards, replicas and peers.
- [OpenMetadata system architecture](https://docs.open-metadata.org/v1.12.x/developers/architecture) — service, metadata store and search.
- [OpenMetadata lineage ingestion](https://docs.open-metadata.org/v1.12.x/connectors/ingestion/lineage) — lineage workflow.
- [OpenMetadata roles and policies](https://docs.open-metadata.org/v1.12.x/how-to-guides/admin-guide/roles-policies) — authorization concepts.

Exact defaults, flags and metrics remain version-, topology-, workload- and configuration-dependent. Arithmetic is illustrative, not a capacity promise. The offline model proves only deterministic boundaries and lifecycle safety. Publication requires technical, instructional, safety and source review. Mastery requires representative runtime evidence, independent transfer and delayed retrieval.
