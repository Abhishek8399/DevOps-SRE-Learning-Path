---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0090",
  "slug":"distributed-data-reliability-capstone",
  "aliases":["V11-L03","distributed-data-reliability-capstone"],
  "curriculumIds":["CAP-003"],
  "route":"/book/capstones/distributed-data-reliability-capstone",
  "order":3,
  "volume":"11-capstones",
  "title":"Distributed data reliability capstone: one order, every boundary, honest recovery",
  "summary":"Integrate transactions, idempotency, outbox delivery, partitioned events, duplicate-safe effects, cache semantics, analytical quality, lineage, capacity and isolated recovery.",
  "domain":"capstone-engineering",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0089"],
  "prerequisiteCurriculumIds":["AUT-002","DST-002","DST-004","DST-006","DMP-001","DMP-002","OBS-001","SRE-002","DR-001"],
  "testedEnvironments":[
    {"platform":"Windows and Ubuntu","version":"Windows 11 host, Ubuntu 24.04 WSL and Python 3.12","support":"required","notes":"Thirteen unit tests and the 214-second three-cycle verifier pass without sudo, cloud access or production data."},
    {"platform":"Docker Desktop","version":"29.6.2 with Linux/amd64 containers","support":"required","notes":"Runs pinned PostgreSQL 18.4, Redis 8.6.5 and Apache Kafka 4.3.1 with no host ports and network_mode none."},
    {"platform":"Production and distributed engines","version":"not executed","support":"concept-only","notes":"No representative Spark, Flink, Iceberg, quorum topology, real workload, production objective or mastery is claimed."}
  ],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","data-platform-engineer","production-engineer","staff-engineer"],
  "learningObjectives":[
    "Trace one operation through source transaction, outbox, log, effect, cache, analytical fact and recovery.",
    "Explain idempotent request, stable event identity, duplicate delivery and atomic inbox/effect boundaries.",
    "Calculate per-partition lag and connect skew, arrival rate, service rate and catch-up time.",
    "Gate analytical trust with identities, counts, domain totals, mismatch, freshness and lineage.",
    "Verify isolated restore and replay without turning local evidence into production claims."
  ],
  "productionSignals":[
    "The source accepts orders while derived facts or reads remain stale.",
    "Kafka health is green while one partition stops advancing.",
    "Counts match while identities or monetary control totals differ.",
    "Duplicate records create repeated effects or poison input blocks progress.",
    "A backup exists but no isolated restore and reconciliation has run."
  ],
  "diagrams":[
    {"id":"LES-0090-DIA-001","title":"One order across two truth paths","direction":"left-to-right","boundaries":["request","order and outbox","relay","Kafka partition","inbox and fact","cache","quality and lineage"],"evidencePoints":["request hash","transaction receipt","event identity","partition and offset","effect receipt","cache convergence","reconciliation"],"textAlternative":"A request commits order and outbox, a relay appends a stable event, a consumer atomically materializes it, cache remains derived and quality gates facts."},
    {"id":"LES-0090-DIA-002","title":"Partition backlog and skew","direction":"hierarchical","boundaries":["topic","partition 0","partition 1","partition 2","consumer group","sink"],"evidencePoints":["end offset","next offset","age","assignment","service rate","fact count"],"textAlternative":"Each ordered partition has one active consumer-group member, so a hot partition can dominate freshness while aggregate signals look healthy."},
    {"id":"LES-0090-DIA-003","title":"Isolated restore and replay","direction":"left-to-right","boundaries":["backup","manifest","isolated database","retained events","replay","reconciliation","promotion"],"evidencePoints":["digest","counts","restore time","watermarks","effect identity","control totals","decision"],"textAlternative":"A verified backup restores away from active state, retained events rebuild projections and reconciliation gates promotion."}
  ],
  "commands":[
    {"id":"LES-0090-CMD-001","question":"Does the full bounded lifecycle pass?","risk":"mutating-bounded","command":"python verify.py","runFrom":"support/project with Docker Desktop and no CAP-003 resources","expectedBranches":[{"when":"verify=pass and runtime_end=absent","meaning":"three declared scenarios and exact cleanups passed","nextEvidence":"inspect individual receipts and proof limits"},{"when":"verify=fail","meaning":"a command or evidence assertion differed","nextEvidence":"preserve first failure; allow only descriptor-gated cleanup"}],"proves":"one bounded local lifecycle","doesNotProve":"production readiness, scale, compliance or mastery","cleanup":"Verifier invokes exact cleanup for runtime it owns."},
    {"id":"LES-0090-CMD-002","question":"Is analytical output trustworthy?","risk":"mutating-bounded","command":"python datactl.py reconcile","runFrom":"support/project after initialization or consumption","expectedBranches":[{"when":"exit 4 and reconcile=fail","meaning":"a declared quality control failed and a failed receipt remains","nextEvidence":"repair cause without editing evidence"},{"when":"reconcile=pass","meaning":"implemented controls match for this snapshot","nextEvidence":"inspect lineage and limits"}],"proves":"implemented source/fact, amount, mismatch, publication and quarantine controls","doesNotProve":"all semantics or future correctness","cleanup":"Exact project cleanup removes the disposable receipt."},
    {"id":"LES-0090-CMD-003","question":"Can the snapshot restore safely?","risk":"mutating-bounded","command":"python datactl.py restore","runFrom":"support/project after backup with no atlas_restore database","expectedBranches":[{"when":"restore=pass target=isolated_database","meaning":"integrity and snapshot counts matched in a new target","nextEvidence":"replay and reconcile"},{"when":"target already exists","meaning":"overwrite guard worked","nextEvidence":"inspect ownership and preserve evidence"}],"proves":"one isolated local restore","doesNotProve":"production RTO, PITR, failover or promotion","cleanup":"Exact cleanup removes the disposable volume and known runtime files."},
    {"id":"LES-0090-CMD-004","question":"Can retained events rebuild derived state?","risk":"mutating-bounded","command":"python datactl.py replay-restore","runFrom":"support/project after isolated restore","expectedBranches":[{"when":"replay-restore=pass and missing_facts=0","meaning":"compatible events rebuilt facts and cache under implemented controls","nextEvidence":"review watermarks and promotion"},{"when":"retention or reconciliation fails","meaning":"recovery chain is incomplete","nextEvidence":"do not promote; preserve first mismatch"}],"proves":"bounded replay into one isolated snapshot","doesNotProve":"full historical coverage or real cutover","cleanup":"Run exact cleanup after evidence capture."},
    {"id":"LES-0090-CMD-005","question":"Did cleanup remove only owned state?","risk":"destructive-disposable","command":"python datactl.py cleanup","runFrom":"support/project when exact descriptors match","expectedBranches":[{"when":"all owned resources are absent","meaning":"fixture returned to absence","nextEvidence":"independently list project labels and .runtime"},{"when":"descriptor mismatch","meaning":"ownership is unproved","nextEvidence":"stop and inspect; never broaden deletion"}],"proves":"exact fixture cleanup","doesNotProve":"unrelated Docker hygiene","cleanup":"This is terminal cleanup and refuses broad prune."}
  ],
  "labs":[
    {"id":"LES-0090-LAB-001","title":"Guided transaction, stream, quality and recovery lifecycle","mode":"guided","environment":"Ubuntu 24.04 WSL or Windows Python 3.12 with Docker Desktop","timeMinutes":240,"privilege":"normal user; no sudo, cloud, production endpoint, credential or real data","network":"network_mode none and no host ports","changes":["three containers","two volumes","synthetic records","ignored recovery artifacts","isolated restore database"],"abortConditions":["unexpected resource","public network","real data","identity mismatch","in-place restore","unknown cleanup target"],"recovery":"Preserve first failure and use only descriptor-gated project cleanup.","cleanupProof":"Verifier returns each cycle to zero containers, volumes and runtime artifacts.","path":"drafts/LES-0090-distributed-data-reliability-capstone/support/project"},
    {"id":"LES-0090-LAB-002","title":"Independent data reliability transfer","mode":"independent","environment":"Fresh clone and reviewer-selected new operation plus hidden faults","timeMinutes":240,"privilege":"normal user and independent reviewer; no answer key or external target","network":"bounded local containers only","changes":["new contracts","hidden fault fixtures","quality and recovery evidence"],"abortConditions":["guided copy","real data","unbounded load","payload leak","quality bypass","unsafe restore","broad cleanup"],"recovery":"Reviewer stops unsafe work and learner restores only named local state.","cleanupProof":"Reviewer verifies exact absence and no sensitive or external mutation.","path":"drafts/LES-0090-distributed-data-reliability-capstone/support/project"}
  ],
  "incidents":[
    {"id":"LES-0090-INC-001","signal":"Retry returns the same order and event IDs.","firstThought":"The first transaction committed and idempotent replay is working.","safePath":"Compare key, request hash and source receipt.","trap":"Create a new key for every timeout."},
    {"id":"LES-0090-INC-002","signal":"Two offsets contain one event ID.","firstThought":"Relay retried across publish and acknowledgement ambiguity.","safePath":"Consume with inbox/effect idempotency and reconcile one effect.","trap":"Delete records or claim exactly once."},
    {"id":"LES-0090-INC-003","signal":"Broker is healthy while one partition lags.","firstThought":"Progress or skew is partition-local.","safePath":"Inspect offsets, age, assignment, errors and sink rate.","trap":"Add replicas blindly or flush the log."},
    {"id":"LES-0090-INC-004","signal":"One unsupported event is quarantined.","firstThought":"Containment worked but compatibility remains unresolved.","safePath":"Preserve minimal evidence, correct ownership and govern replay.","trap":"Log payload or retry forever."},
    {"id":"LES-0090-INC-005","signal":"Backup exists and restore target already exists.","firstThought":"Overwrite guard protected ambiguous state.","safePath":"Inspect manifest, target and prior receipt before cleanup.","trap":"Overwrite active state."}
  ],
  "assessmentIds":["ASM-0253","ASM-0254","ASM-0255"],
  "referenceIds":["REF-1140","REF-1141","REF-1142","REF-1143","REF-1144","REF-1145","REF-1146","REF-1147","REF-1148","REF-1149","REF-1150","REF-1151","REF-1152","REF-1153","REF-1154","REF-1155","REF-1156","REF-1157","REF-1158","REF-1159"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "All services are single processes on one laptop; no quorum or failure-domain availability is proved.",
    "The console client and logical dump expose concepts but do not model production client groups, PITR or failover.",
    "Spark, Flink, Iceberg and telemetry systems are concept transfer only.",
    "Local counts, timings and verifier results are not production SLO, capacity, RPO, RTO or mastery evidence."
  ]
}
---

# Distributed data reliability capstone: one order, every boundary, honest recovery

## What you see and first thought

The checkout API says an order was accepted. Kafka says its broker is healthy. Redis answers quickly. The pipeline job is green. Yet the finance fact table is missing rows and its monetary total is wrong.

Here is the habit that separates a reliable data engineer from a tool operator:

> Never ask only, "Is Kafka up?" Ask, "Where is this business operation authoritative, how far has its evidence travelled, and what proves the final result is correct?"

A distributed data path has several kinds of success. They are not interchangeable:

```text
request accepted
  != event durably published
  != event processed
  != business effect committed
  != cache current
  != analytical output correct
  != user objective met
```

When a symptom arrives, name the operation and the first missing invariant. "Data platform down" is too broad. "Order `ord-...` exists in source, its event is retained at partition 0 offset 83, but no fact with that event identity exists" is operationally useful.

Use this first-thought map:

```text
same API request repeats                    -> idempotency decision
source row exists, outbox missing           -> source transaction invariant
outbox pending                              -> relay progress
two broker offsets, same event ID           -> duplicate delivery window
broker end advances, consumer position not  -> backlog or consumer failure
one partition grows                         -> skew, assignment or partition-local fault
event rejected by contract                  -> compatibility and quarantine
fact exists twice                           -> effect idempotency failure
cache misses, source/fact correct            -> derived cache reconstruction
job green, controls fail                    -> analytical correctness failure
backup file exists, restore untested         -> recovery remains unproved
```

Do not delete first. Do not flush the topic. Do not create a new idempotency key to "unstick" a timeout. Preserve identities, positions, counts, timestamps and the first meaningful error. Reliable recovery depends on the evidence that panic destroys.

## Terms before commands

**Authoritative state** is the state allowed to decide business truth. In this lab, PostgreSQL owns orders, idempotency decisions and durable materialized effects. Kafka owns retained event positions. Redis owns no business truth; it is a disposable projection.

**Idempotency** means repeating the same intended operation produces the same accepted result rather than another business effect. It does not mean every request succeeds. Reusing one key with changed payload is a conflict and should fail loudly.

**Atomic transaction** means all writes inside that database transaction commit together or none commit. It does not automatically include Kafka, Redis or another service.

**Outbox** is an event-publication intent stored in the same transaction as the business row. A relay later publishes it. This closes the "database committed but no event intent exists" gap, while leaving a smaller publish-versus-acknowledge ambiguity that must tolerate duplicates.

**Stable event identity** is one identifier for one logical event across retries and positions. Partition and offset identify a transport record; event ID identifies the logical event. You need both.

**At-least-once delivery** means a valid event may arrive more than once. It does not promise loss, but real retention, acknowledgement and failure behavior define the exact boundary.

**Inbox** is a durable claim that a consumer has applied one logical event. When the inbox row and business effect commit together, retry can see the claim and avoid duplicating the effect.

**Partition** is an ordered shard of a Kafka topic. Ordering is within a partition, not globally across all partitions. Within a consumer group, one partition has at most one active consumer member.

**End offset** is the next broker offset after the last retained record. **Next processed offset** here is one past the greatest delivery position recorded by the effect pipeline. Their difference is record lag.

**Oldest-event age** is how long the oldest waiting eligible record has waited. Count and age answer different questions: one measures work; the other measures user freshness.

**Skew** means work or storage is distributed unevenly. A topic can have low total lag while one customer, key or partition is badly behind.

**Poison event** is an event that cannot be processed under the supported contract. It may be malformed, incompatible or semantically invalid. "Poison" describes processing, not blame.

**Quarantine** is controlled containment with enough identity to investigate. It is not resolution, and raw sensitive payloads should not automatically be copied there.

**Reconciliation** compares independently owned evidence to find divergence: identities, counts, amounts, hashes, watermarks and status.

**Control total** is a domain aggregate that detects errors counts miss. Two datasets can each contain 100 rows while one has the wrong payment amount.

**Lineage** links a run to its job, code or config identity, inputs, outputs, watermarks and result. A screenshot of a green job is not lineage.

**RPO** is acceptable loss measured from a declared recovery boundary. **RTO** is acceptable time to restore a declared service outcome. Neither is the backup schedule alone.

**Replay** reads retained input again. Replay is safe only when contracts, state, effects and external calls are designed for it.

## Architecture map

Follow one order across the complete local path:

```text
Caller
  |
  | order_id + idempotency_key + payload
  v
PostgreSQL transaction
  +-----------------------+
  | atlas.orders          |  authoritative request result
  | atlas.outbox          |  publication intent, same commit
  +-----------------------+
            |
            | relay reads unpublished row
            v
Kafka topic orders.v1
  partition + offset + stable event_id + versioned payload
            |
            | bounded consumer, delivery may repeat
            v
PostgreSQL transaction
  +-----------------------+
  | consumer_inbox        |  one claim per event_id
  | delivery_attempts     |  every first-seen transport position
  | order_facts           |  one durable effect
  +-----------------------+
            |
            +-----------> Redis order:<id>, TTL projection
            |
            +-----------> reconciliation and lineage receipt
```

There are two paths:

- The **transactional path** decides whether the order was accepted and records event intent.
- The **analytical path** converges asynchronously and decides whether derived facts are trustworthy.

Do not force them into one vague "pipeline." Different owners, clocks and failure modes require different evidence. The source transaction can succeed while the analytical path is late. That may be acceptable inside a freshness objective, but it must be observable. It becomes a correctness incident when required derived state is absent beyond the declared boundary or values diverge.

The lab services have no Docker network and expose no host port. The controller enters each fixed container with `docker exec`. That unusual topology is deliberate: it permits local process interaction through loopback inside each container while preventing accidental external reachability. It does not model production network security, TLS or service authentication.

```text
                     TRANSACTIONAL TRUTH
caller -> validation -> [orders + outbox] --relay--> retained event
                            |                         partition/offset
                            |                              |
                            +----------- identity --------+
                                                           |
                     DERIVED TRUTH                         v
quality/lineage <- fact <- [inbox + effect] <- consumer <-+
                        |
                        +--> Redis cache (rebuildable)
```

Every arrow is a failure boundary. Every box needs an owner. Every claim needs a receipt.

## Request or state path

### 1. Validate caller intent before mutation

The request has exactly five fields: schema version, order identity, idempotency key, customer reference and amount. Unknown fields fail. Amount must be an integer in a bounded domain; booleans are rejected even though Python treats `bool` as a subclass of `int`.

The controller canonicalizes JSON and calculates SHA-256. Canonicalization is not encryption. The hash binds the idempotency key to normalized intent so an identical retry can return the original outcome and changed intent can be rejected.

### 2. Commit order and outbox atomically

PostgreSQL locks any existing idempotency row. If its hash matches, the function returns the original order and event identity with `replayed=true`. If it differs, it raises `idempotency_conflict`. For new intent, it inserts the order and event payload in one transaction.

The important sentence is not "we use PostgreSQL." It is:

> No committed order can exist without its publication intent under this function, and no outbox intent can reference an absent order.

That is a local invariant. It still says nothing about Kafka.

### 3. Relay across the non-atomic boundary

The relay reads one unpublished outbox row, publishes it with event ID as key and then marks the outbox row published. Those actions cannot share the PostgreSQL transaction in this design.

The controlled exit after broker acknowledgement demonstrates the uncertainty:

```text
Kafka append succeeded
process stops
PostgreSQL published flag remains false
relay retries
same logical event appears at another offset
```

The correct response is not to invent a second event ID. Stable identity lets downstream code say "new delivery position, already applied logical event."

### 4. Partition and retain

Kafka applies murmur2 to the serialized key and maps it to a partition. Same key means same partition while partition count and partitioner remain compatible. The local seed command deliberately searches for event keys that land on one partition so skew is observed, not drawn.

Offsets are positions, not business identities. They are useful for ordering and progress. Retention, replication and acknowledgements determine durability; an offset printed once is not an eternal archive.

### 5. Claim and apply one effect

The consumer verifies that the Kafka key equals payload event ID, validates all versioned fields and hashes the canonical payload. PostgreSQL records a delivery position. It then locks the inbox identity:

- absent identity: insert inbox and fact in one transaction;
- same identity and same hash: classify duplicate and do not insert another effect;
- same identity and different hash: raise identity conflict.

This is stronger than "check then insert" in application code because the database transaction owns the race.

### 6. Update the disposable cache

Only after the durable effect commits does the controller write Redis with a TTL. If cache write fails, durable state remains correct and the cache can be rebuilt. If Redis were written first, a source or effect failure could expose data that never committed.

### 7. Gate analytical trust

Reconciliation checks source versus fact count, monetary totals, missing facts, orphan facts, field mismatches, unpublished outbox and unresolved quarantine.

Every attempt writes `atlas.pipeline_runs` with run identity, named input and output datasets, metrics and status. The failed receipt remains. Reliability is not editing a threshold until the run becomes green.

### 8. Recover state by class

The logical backup captures PostgreSQL state plus a manifest of hash, bytes, counts, broker watermarks and local objectives. Restore targets `atlas_restore`, never active `atlas`. Replay rebuilds facts from retained events and resets or reconstructs only the disposable cache. Reconciliation, not the restore exit code, decides whether recovered data is internally ready.

## Failure zoom

### Failure 1: client timeout after source commit

The client does not know whether the transaction committed. A retry with the same idempotency key and identical canonical payload returns original identities. A new key creates a new operation and can double charge or allocate.

First evidence: request key, request hash, source transaction receipt and existing row. Do not begin at Kafka because the unknown commit occurred earlier.

### Failure 2: same key, changed amount

This is not a retry. It is two intents competing for one identity. The database raises `idempotency_conflict` and the transaction creates no new row. Find whether the client reused a key incorrectly, serialized a value differently or is attempting an unsupported update.

### Failure 3: relay publish before acknowledgement

Two offsets with one event ID are expected after the controlled crash. They prove duplicate transport records in this fixture. They do not prove Kafka duplicated a successfully acknowledged producer request by itself; the relay retried because its source acknowledgement was missing.

### Failure 4: effect commit before consumer acknowledgement

The same pattern appears downstream. The effect can commit and the process can stop before its position is acknowledged. Replay must see inbox identity and return duplicate without repeating the effect. External calls such as sending money or email need their own idempotency contract; a database inbox cannot retroactively make an arbitrary third-party API safe.

### Failure 5: incompatible event

The v99 event has a syntactically valid identity but unsupported schema and type. The consumer records partition, offset, event ID, payload hash and reason. It does not copy raw payload into quarantine or logs. Valid records continue.

Containment is not deletion. A producer owner must decide whether to stop emission, deploy a compatible consumer, translate safely or retire the record under governance.

### Failure 6: hot partition

Nine generated keys land on partition 0. End offsets become 9,0,0 and pre-consumption lag is 9,0,0. Dominant share is 100%. Ten consumer replicas would still give that partition one active group member.

The immediate task is restore progress. The design task is determine why the key domain is skewed and whether ordering scope is too broad. Repartitioning is a compatibility change because the same key may map differently after partition count changes.

### Failure 7: job green, data red

Before consumption, reconciliation records nine source rows, zero facts and 9,160 versus zero cents. The command exits 4. Infrastructure executed correctly; the data product is not publishable.

After consumption, rows and totals match and the second receipt passes. Keep both receipts. The transition is part of the evidence.

### Failure 8: cache empty

A Redis restart or eviction can remove keys by design. Durable effect remains. Rebuild from authoritative or reconciled projection and measure hit, miss and rebuild load. Never promote Redis to source of truth merely because it responds faster.

### Failure 9: backup exists, restore unknown

A file and successful scheduled job prove bytes were produced. They do not prove the file is complete, readable under the current engine, contains required state or can meet recovery objectives.

The lab hashes the dump, inventories counts, restores into a new database, compares the snapshot and then replays derived state.

### Failure 10: second restore wants the same target

The controller refuses. That is safety, not inconvenience. An existing target could contain prior evidence or be mistaken for an active system. Determine ownership before replacement. Exact cleanup removes the disposable volume only after descriptors match.

## Internals and state ownership

### PostgreSQL: authoritative local transactions

PostgreSQL isolation controls what concurrent transactions can observe; WAL records changes before data pages are considered durable. Those mechanisms support database correctness and recovery, but application invariants still require constraints, locking and transactional design.

The source and outbox share one database transaction. The consumer inbox and fact share another. This is deliberate local atomicity around each side of the broker.

The lab uses `md5` only to derive a short deterministic teaching event identity from already hashed synthetic input. It is not a password or integrity primitive. SHA-256 protects backup and payload-comparison use cases.

PostgreSQL is not magically authoritative because it is relational. It becomes authoritative because the design assigns it that role, constrains writes and provides recovery. If another service can independently overwrite the same business decision, ownership is ambiguous.

### Kafka: retained ordered partitions

Kafka stores records by partition. Ordering is partition-scoped. A key gives stable placement only within a compatible partitioning contract. Consumer positions describe progress, not business correctness.

The lab uses one KRaft broker with replication factor one. `acks=all` therefore means all in-sync replicas in a one-replica set: one. Configuration words do not create absent failure domains.

In production, distinguish:

- record append acknowledgement;
- replication and in-sync replica state;
- controller quorum;
- retention or compaction policy;
- consumer committed position;
- business effect acknowledgement.

Each answers a different recovery question.

### Redis: derived and bounded

Redis has eviction, persistence and replication options, each with trade-offs. This fixture disables persistence, limits memory and gives keys a TTL so the learner must treat cache state as disposable.

In a production design, choose cache-aside, write-through or another behavior from staleness and failure requirements. Then test database loss, cache loss, stampede, eviction and invalidation. "Redis is fast" is not a consistency model.

### Analytical engine transfer

Flink checkpoints coordinate operator state and source positions so a job can recover consistently when sources and sinks participate correctly. Backpressure can delay checkpoints and reveal bottlenecks.

Spark Structured Streaming models incremental execution over a stream and relies on checkpointing and sink semantics. Neither engine automatically makes an arbitrary external side effect exactly once.

Iceberg separates table metadata, snapshots, manifests and data files. Atomic metadata commits and schema or partition evolution improve table reliability, but catalogs, object storage, compaction, snapshot expiry and orphan cleanup still require ownership.

The local PostgreSQL fact table is a small executable model of identities and control totals. It is not performance or failure equivalence to those engines.

### Telemetry: operational evidence

Metrics should use bounded labels such as topic, consumer group, result and reason—not event ID, order ID or customer ID. High-cardinality identities belong in sampled traces or access-controlled logs.

Logs need timestamps, operation or run identity, component, outcome and safe reason. They must not contain credentials, payment payloads or raw quarantined records. OpenTelemetry semantic conventions help names align; they do not guarantee propagation or backend retention.

### Lineage: data-operation evidence

OpenLineage separates job, run and dataset concepts. The lab persists a compact analogous receipt. A production lineage design also needs code and config artifact identity, namespace, dataset versions or watermarks, facets, ownership, retention and access control.

### The state table to remember

| State | Authority | Can be rebuilt? | Primary recovery evidence |
|---|---|---:|---|
| Order and idempotency | PostgreSQL source transaction | Not safely from cache | backup/WAL plus reconciliation |
| Outbox intent | same source transaction | from authoritative order only under explicit rules | unpublished age and source invariant |
| Kafka record | retained partition log | perhaps from outbox/source inside retention contract | topic, partition, offset, event ID |
| Inbox and fact | PostgreSQL effect transaction | yes, from compatible retained events | replay plus identity/control totals |
| Redis key | disposable projection | yes | rebuilt key/value and user read |
| Pipeline receipt | operational/data governance evidence | rerunnable but history matters | immutable run/dataset linkage |
| Metrics/logs/traces | operational context | usually not business authority | retention and query coverage |

## Evidence table

| Evidence | What it proves | What it does not prove |
|---|---|---|
| First submit returns `replayed=false` | one new source and outbox result committed | event reached Kafka or consumer |
| Identical submit returns same IDs and `replayed=true` | fixture recognized identical intent | caller will always retry safely |
| Changed amount returns `idempotency_conflict` | same key cannot silently mutate intent | a business update workflow exists |
| Relay exits 75 after broker acknowledgement | controlled ambiguity was reached | source publication acknowledgement |
| Two offsets contain one event ID | duplicate transport positions exist | two business effects |
| One inbox and one fact remain | tested database effect is idempotent | external effects are safe |
| Quarantine has ID, offset, hash and reason only | implemented table excludes raw payload | no sensitive data exists elsewhere |
| End offsets are 9,0,0 | broker retained nine records on partition 0 | why the key domain is skewed |
| Lag is 9 then 0 | recorded positions caught broker ends | facts are semantically correct |
| Failed reconciliation receipt | declared controls found an untrusted candidate | root cause is known |
| Passing reconciliation receipt | declared snapshot controls match | future data or all semantic rules |
| Backup digest and byte count match | artifact integrity matches manifest | restore or application correctness |
| Isolated counts equal manifest | snapshot restored for listed counts | continuous recovery or production RPO |
| Replay creates six reconciled facts | retained compatible events rebuilt projection | retention covers all real history |
| Restore takes about one second | one local operation met its lab target | production RTO |
| Second restore refuses | overwrite guard is active | existing target is valid |
| Final project label selects nothing | declared containers and volumes are absent | unrelated Docker resources are healthy |

When presenting evidence, finish the sentence "This does not prove..." That single discipline makes incident updates and interviews more credible.

## Command decoders

### `python datactl.py check requests/order-001.json`

`check` selects a read-only contract path. The request path is resolved and must remain beneath `requests/`; symlinks and escape paths fail. The output hash is a comparison identity, not a secret and not an acceptance receipt.

### `python datactl.py up`

Before creating anything, the controller lists fixed names and Compose project labels. Any existing matching container or volume causes refusal. Compose starts digest-pinned services and waits. The controller re-inspects image references, `network_mode=none`, labels, running state and health.

"Healthy" is narrow:

- PostgreSQL answers `pg_isready`.
- Redis answers `PING`.
- Kafka can list topics.

It does not mean schema, topic, user operation, correctness or redundancy.

### `python datactl.py init`

This applies the SQL schema and creates `orders.v1` with three partitions and replication factor one. Repeating schema initialization is mostly safe because objects use `IF NOT EXISTS` and functions are replaced, but topic compatibility still deserves review in real systems.

### `python datactl.py relay --stop-after-publish`

Exit 75 is intentional. Shell harnesses must preserve it instead of letting a later diagnostic overwrite `$LASTEXITCODE`. The next relay publishes the same identity again and marks the outbox row published. Read both receipts.

### `python datactl.py consume`

The consumer reads from the beginning with a maximum of 1,000 records and timeout. This makes replay visible and bounded. It is not a continuously running group member. Each line exposes partition, offset, key and payload; malformed formatter output fails closed.

### `python datactl.py seed-backlog --count 9 --partition 0`

The controller creates valid synthetic source transactions whose event IDs map to the selected partition under Kafka murmur2. It publishes and acknowledges each outbox row but deliberately does not consume. Count is limited to 30 to bound local work.

### `python datactl.py backlog`

For each partition:

```text
next_processed = max(recorded delivery or quarantine offset) + 1
lag            = max(0, broker_end_offset - next_processed)
```

The report also shows dominant partition share. A real system should use consumer-group committed offsets and event-time age; this fixture uses its database delivery ledger because the console consumer intentionally has no committed group state.

### `python datactl.py reconcile`

Exit 4 means the data-quality decision is fail, not a controller crash. Automation should hold candidate output, retain receipt and alert the owning data product. It should not treat every quality failure as infrastructure paging; severity depends on user impact and contract.

### `python datactl.py backup`

`pg_dump` produces a plain logical dump for the `atlas` schema. The manifest records bytes, SHA-256, counts and broker watermarks. The directory is local, ignored and synthetic-only. A production backup must address encryption, access, retention, geographic failure, engine compatibility and key recovery.

### `python datactl.py restore`

The controller verifies artifact set, rejects symlinks, checks manifest fields, digest and bytes, proves `atlas_restore` absent, creates it and loads the dump. Snapshot counts must match. RTO timing begins before artifact validation and ends after comparison of listed counts.

### `python datactl.py replay-restore`

The command flushes only the disposable lab cache, processes compatible retained events into the isolated database, rebuilds cache keys and requires source or fact reconciliation. It checks that current broker ends have not moved behind backup watermarks. Production replay also needs start boundaries, schema compatibility, throttling, downstream isolation and promotion approval.

### `python datactl.py cleanup`

Cleanup is destructive only inside the disposable boundary. It requires exact container names, images, Compose labels, network mode and volumes. Runtime files must be a subset of three allowed names. Unknown state causes refusal. `docker system prune` is never a substitute for ownership.

## Decision path

### 1. Did the source operation commit?

Look for idempotency key, request hash, order ID, transaction outcome and outbox identity. A client timeout is uncertainty, not failure proof. Retry only under the same logical identity.

### 2. Does every accepted source operation have publication intent?

Compare source and outbox identities, not only counts. Missing outbox means the atomic source invariant failed. An unpublished outbox means relay work remains.

### 3. Did the relay append the stable event?

Use topic, partition, offset, event ID and payload hash. Multiple offsets can be valid duplicates. No record plus pending outbox means retry; no record plus "published" needs deeper acknowledgement and audit evidence.

### 4. Is the consumer current?

Compare end and next offsets per partition and measure oldest-event age. Check assignment, exceptions, restarts, rebalances, throttles, downstream latency and quarantine.

### 5. Is work skewed?

Compare per-partition volume and service rate. More replicas help only until active members equal useful partitions. Fix a hot-key design through a versioned compatibility plan, not an emergency partition-count click.

### 6. Did each logical event create one effect?

Compare event identities, delivery attempts, inbox claims and fact identities. Same ID with changed hash is corruption or identity misuse and must fail. Duplicate positions with one effect are expected under replay.

### 7. Is the cache merely stale?

Validate authoritative source and effect first. Rebuild cache under bounded load. If the product cannot tolerate misses or staleness, that is a design and SLO requirement, not permission to call cache authoritative.

### 8. Is analytical output trustworthy?

Require identity, row, control-total, schema, duplicate, orphan, mismatch, quarantine and freshness gates appropriate to the domain. Retain the failed run. Scheduler "success" is only execution evidence.

### 9. What state must recovery restore?

List authoritative source, event retention, effect or fact projection, cache and telemetry. Decide whether each is restored, replayed, rebuilt or accepted as lost. Do not use one backup for state it never contained.

### 10. Is recovery ready to promote?

Verify artifact integrity, isolated restore, watermarks, replay compatibility, reconciliation, application reads, security controls and observed objective. Promotion is a separate decision with owner, abort and rollback or roll-forward path.

## Guided Ubuntu lab

The lab lets you learn the system without installing PostgreSQL, Kafka or Redis directly in Ubuntu. Docker Desktop must be running. Cached images remain after cleanup; containers, volumes and recovery files do not.

### Step 0: enter the exact directory

```bash
cd /path/to/DevOps-SRE-Learning-Path/drafts/LES-0090-distributed-data-reliability-capstone/support/project
pwd
python --version
docker version
```

Stop if this is not the learning repository, if Docker targets a remote or production daemon, or if any real data or credential is present.

### Step 1: inspect before execution

```bash
python datactl.py --help
docker compose --env-file toolchain.env config
python -m unittest discover -s tests -v
```

Read image digests, fixed names, resource ceilings, `network_mode: none`, Redis persistence settings and the two named volumes. Thirteen tests validate input boundaries, event contract, Kafka formatter parsing, murmur2 vectors, reconciliation controls and path safety. They do not start services.

### Step 2: run the complete verifier

```bash
python verify.py
```

Budget about four minutes on the tested laptop. Do not judge success only from the last line. Find these transitions:

1. identical request replay and changed-intent conflict;
2. relay exit 75, retry and duplicate delivery;
3. poison containment and harmless second replay;
4. nine records on one partition;
5. reconciliation fail before consume and pass after;
6. backup, isolated restore and retained replay;
7. second restore refusal;
8. three exact cleanups and final absence.

### Step 3: slow down the first cycle

Start a fresh runtime:

```bash
python datactl.py up
python datactl.py init
python datactl.py check requests/order-001.json
python datactl.py submit requests/order-001.json
python datactl.py submit requests/order-001.json
```

The first submit says `replayed=false`; the second returns the same order and event IDs with `replayed=true`.

Now run changed intent:

```bash
python datactl.py submit requests/order-001-conflict.json
```

Expected exit is 2 and the database message includes `idempotency_conflict`. Do not "fix" the test by changing the key.

### Step 4: create relay ambiguity

```bash
python datactl.py relay --stop-after-publish
python datactl.py relay
python datactl.py inject-poison
python datactl.py consume
python datactl.py consume
python datactl.py status
```

Interpretation:

- first relay stops deliberately after broker acknowledgement;
- retry publishes the same event again;
- first consume sees three records: two compatible duplicates and one incompatible event;
- one new effect, one duplicate and one quarantine are recorded;
- second consume creates zero new effects.

### Step 5: clean before another scenario

```bash
python datactl.py cleanup
docker ps -a --filter label=com.docker.compose.project=atlas-data-capstone
docker volume ls --filter label=com.docker.compose.project=atlas-data-capstone
```

The two Docker listings should contain no project member.

### Step 6: observe skew and quality

```bash
python datactl.py up
python datactl.py init
python datactl.py seed-backlog --count 9 --partition 0
python datactl.py backlog
python datactl.py reconcile
```

The first reconciliation intentionally exits 4. Its failure is correct: nine source rows exist and zero facts exist. Continue only after reading failed metrics.

```bash
python datactl.py consume
python datactl.py backlog
python datactl.py reconcile
python datactl.py cleanup
```

Lag should become zero and counts or totals should match. The 100% dominant share remains a design signal even after the queue drains.

### Step 7: rehearse recovery

```bash
python datactl.py up
python datactl.py init
python datactl.py seed-backlog --count 6 --partition 1
python datactl.py backup
python datactl.py restore
python datactl.py replay-restore
```

Notice the snapshot initially has six orders and zero facts because backup occurs before derived consumption. Restore must reproduce that exact snapshot. Replay then creates six facts in `atlas_restore` and six cache keys.

Run restore again:

```bash
python datactl.py restore
```

Expected result is refusal. Finish:

```bash
python datactl.py cleanup
test ! -e .runtime
```

If your shell is PowerShell, use `Test-Path .runtime` and expect `False` instead of `test`.

### Step 8: write an evidence narrative

For each scenario, write:

1. user operation and impact;
2. earliest uncertain boundary;
3. immutable identities and time window;
4. one hypothesis;
5. evidence that supports or falsifies it;
6. mutation, blast radius, abort and recovery;
7. validation across state and user outcome;
8. what remains unproved.

That narrative is more valuable than a command transcript without reasoning.

## Production transfer

### Transaction and API boundary

Use a durable idempotency store with retention aligned to client retry windows. Bind keys to authenticated caller, operation and canonical intent. Decide whether concurrent duplicates wait, return in-progress or return committed receipt. Protect hot keys and abusive cardinality.

For critical writes, constraints and transaction isolation need concurrency tests, not only unit tests. Include deadlock retry, serialization failure, connection loss after commit and replica-read staleness.

### Outbox and change data capture

A polling relay is simple and visible. CDC can reduce application polling and expose database log positions, but it adds connector state, schema or history topics, snapshot behavior and operational ownership.

Choose based on transaction rate, latency, database load, ordering, replay and team capability. In both cases, monitor oldest unpublished age, attempts, failures, source log retention and downstream acknowledgement.

### Broker topology

Production Kafka requires multiple brokers, controller quorum, rack or zone awareness, replication, minimum in-sync replicas, storage and network capacity, authentication, authorization, encryption, quotas, retention and upgrade planning.

Test broker loss, controller change, ISR shrink, disk pressure, partition movement and client compatibility. Never call one local KRaft process HA.

### Consumer design

Use a real group with explicit commit semantics. Decide whether position is acknowledged before or after effect; understand each loss or duplicate window. Handle rebalance callbacks so revoked partitions do not keep writing under stale ownership.

Bound retries. Separate transient dependency failures from poison data. Use per-partition pause and resume carefully so one poison record does not freeze unrelated partitions or violate ordering requirements.

### Schema governance

Version contracts and test producer or consumer compatibility. Prefer additive evolution when it preserves semantics. Removing, renaming or changing meaning needs a rollout matrix:

```text
old producer -> old consumer
old producer -> new consumer
new producer -> old consumer
new producer -> new consumer
replay old history -> current consumer
```

A schema registry can enforce shapes, but semantic compatibility still needs humans and domain tests.

### Batch and stream engines

Flink state and checkpoints, Spark streaming checkpoints and table-format snapshots all have identity and compatibility boundaries. Test upgrade from actual state, checkpoint size and duration under backpressure, sink idempotency and replay.

For Iceberg, track catalog authority, snapshot lineage, manifest and file reachability, commit conflicts, schema field IDs, partition evolution, compaction and safe expiry. A query engine reading files directly can bypass table semantics.

### Data quality and publication

Classify gates:

- **hard correctness:** identity uniqueness, monetary conservation, referential integrity;
- **compatibility:** schema and enum acceptance;
- **freshness:** watermark or age inside objective;
- **distribution:** nulls, range and volume anomaly;
- **business plausibility:** domain-specific expectations.

Hard failures hold publication. Soft anomalies may publish with warning only under explicit policy. Every exception needs owner, reason, scope, expiry and follow-up.

### Recovery and disaster readiness

PostgreSQL logical dumps are useful but insufficient alone. Production recovery may combine physical base backup, WAL archive and PITR. Verify restore with the same rigor as backup. Protect credentials and encryption keys separately.

Kafka retention is not a universal backup. Retention may expire, compaction may remove old values and producer history may not contain all source authority. Record exact offset or time boundary and test replay before depending on it.

Recovery promotion needs traffic, identity, routing, security, dependent service and data validation. Reconciliation should run before and after promotion.

## Reliability, security, observability, capacity, and cost

### Reliability

Define separate objectives:

- source acceptance availability and latency;
- event-publication freshness;
- consumer processing freshness;
- analytical completeness and correctness;
- user read freshness;
- recovery objectives.

An example 99.9% source SLO says nothing about a 30-minute analytical delay unless that delay has its own indicator. Eligibility rules must define planned maintenance, malformed requests and unknown telemetry.

Use error budgets to govern change, not excuse known corruption. Correctness failures often need zero tolerance or a separately approved policy because one wrong payment may matter more than many delayed dashboards.

### Security

The lab is sealed and synthetic. A reachable system needs:

- authenticated workload identities and least privilege per topic, table, schema, keyspace and backup;
- TLS in transit and managed encryption at rest;
- secret rotation and no credentials in images, Git, event payloads or logs;
- producer authorization that prevents arbitrary schema or type emission;
- consumer authorization that limits groups and topics;
- database roles separating application, relay, consumer, migration, backup and restore;
- audit events for access, schema, ACL, retention, replay, exception and promotion changes;
- data classification, minimization, deletion and residency controls;
- protected backup keys and restore identities.

Hashes are not anonymization. Event IDs may still be linkable. Quarantine metadata needs access control and retention.

### Observability

Instrument the journey:

```text
request accepted
outbox pending age
publish attempts and result
broker end offsets
consumer next offsets and oldest age
processing result and latency
quarantine by bounded reason
cache hit, miss and rebuild
quality pass or fail
source and fact reconciliation
restore and replay result
```

Metrics carry bounded dimensions. Traces carry sampled per-operation paths. Logs carry detailed controlled context. Lineage carries run and dataset history. Alerts carry symptoms with owner and action.

Page on user-impacting freshness or correctness burn and imminent retention or recovery risk. Ticket long-term skew or cost when immediate human action is unnecessary. A page saying "Kafka CPU above 70%" without user or capacity context is weak.

### Capacity and performance

Let:

- `lambda` be arrival records per second;
- `mu` be sustainable service rate per active useful partition;
- `B` be backlog records;
- `T` be desired catch-up time.

Required total service rate is approximately:

```text
required_rate = lambda + B / T
```

If arrivals are 500/s, backlog is 180,000 and recovery target is 10 minutes:

```text
required_rate = 500 + 180000/600 = 800 records/s
```

That average is feasible only if partition distribution, database writes, checkpoints, network and failure headroom support it. For one hot partition, cluster-wide spare rate cannot be borrowed automatically.

Measure percentiles and saturation at each boundary. Include retry amplification, rebalances, compaction, backup I/O and catch-up load. Test failure capacity, not only healthy steady state.

### Cost

Cost follows retained bytes, replication, partitions, requests, state or checkpoints, query scans, cache memory, telemetry cardinality, backup copies and human operation.

Useful unit measures include cost per accepted business operation, retained GB-day, successful quality-checked dataset and recovery rehearsal.

Do not cut replication, retention, backup or observability without recalculating reliability loss. Do not overpartition blindly: partitions also consume metadata, files, memory and operational attention.

## Traps and prevention

### Trap: "Kafka is healthy, so data is current"

Broker health proves a broker operation answered. Prevent this mistake with consumer position, oldest-event age, effect and user or data SLI dashboards.

### Trap: a new idempotency key on retry

A new key means a new logical operation. Prevent it with client libraries that persist one key for one intent and server receipts that make conflict understandable.

### Trap: "Exactly once" without naming the effect

Ask exactly once where: producer sequence, broker transaction, database fact, email, payment provider or analytical row? Prove each boundary instead of using the phrase as architecture.

### Trap: offset used as event identity

Offsets identify records in one partition. Stable event identity survives duplicate positions, retry and replay.

### Trap: check-then-insert deduplication

Concurrent consumers can both pass an application-side check. Use a unique constraint and atomic inbox or effect transaction. Test concurrency rather than assuming it.

### Trap: poison retry forever

Infinite retry consumes capacity and hides ownership. Bound retry, classify, quarantine minimally and govern correction or replay.

### Trap: raw payload in logs or dead-letter storage

Apply minimization, redaction, encryption, access, retention and deletion. A temporary debug shortcut can become a long-lived breach.

### Trap: total lag hides skew

Show per-partition lag, age and throughput. Alert on maxima and distribution, not only sums or averages.

### Trap: more consumers than partitions

Consumer-group parallelism is bounded by useful partitions. Diagnose key and partition design before spending on replicas.

### Trap: adding partitions is harmless

Key placement and ordering assumptions can change. Version migration and test old or new producers, consumers and replay.

### Trap: low CPU means spare capacity

The bottleneck may be one partition, database lock, disk I/O, network, throttle, checkpoint or downstream rate limit.

### Trap: cache count equals correctness

Cache is derived. Compare identities and values with authoritative state, then test misses, stampede and rebuild.

### Trap: job success equals data success

Require quality gates and retain failed lineage receipts. A scheduler can execute a perfectly wrong transform.

### Trap: row counts only

Use identity sets and domain control totals. Equal counts can contain different or wrong rows.

### Trap: quarantine equals resolved

Containment needs an owner, compatibility decision, correction and governed replay or retirement.

### Trap: backup success equals recovery

Verify integrity, restore isolated, reconcile, measure and rehearse the human procedure.

### Trap: restore over the only active copy

Use a separate target and explicit promotion. Refuse ambiguous destinations.

### Trap: Redis persistence assumed from product name

Read actual configuration. RDB, AOF, replication and no persistence have different loss windows.

### Trap: `acks=all` means multi-zone durability

It means all current in-sync replicas. With replication factor one, that is one process.

### Trap: local test becomes production guarantee

Report topology, scale, window, data and exclusions. Keep production blockers visible.

### Trap: broad cleanup

Select exact owned names and labels, inspect before deletion and refuse unknown members. Never teach `docker system prune` as lab cleanup.

### Trap: interview answer becomes a tool list

Start with business operation, ownership, invariants and failure model. Tools implement the design; they are not the design.

## Memory card and retrieval

When you see **request timeout**, remember:

```text
same logical intent -> same idempotency key -> inspect original outcome
```

When you see **duplicate Kafka records**, remember:

```text
offset identifies delivery
event ID identifies logic
inbox + effect commit together
```

When you see **green broker, stale facts**, remember:

```text
end offset - next processed offset = lag
then inspect oldest age, partition max, consumer and sink
```

When you see **one hot partition**, remember:

```text
one partition -> one active group member
more replicas do not split that ordering lane
```

When you see **poison data**, remember:

```text
contain minimally -> keep valid work moving -> assign owner -> correct -> governed replay
```

When you see **pipeline green**, remember:

```text
execution is not correctness
identity + count + value + freshness + lineage
```

When you see **cache lost**, remember:

```text
prove durable authority -> rebuild projection -> validate load and staleness
```

When you see **backup completed**, remember:

```text
hash -> inventory -> isolated restore -> replay -> reconcile -> promotion decision
```

Five retrieval questions:

1. Which state owns business truth?
2. Which identity survives retry?
3. What is the earliest uncertain commit boundary?
4. What evidence proves correctness, not merely progress?
5. What remains unproved after recovery?

Use spaced recall instead of rereading only. Close the lesson and draw the order path from memory. Explain why each transaction stops where it does. Calculate one lag and one catch-up example. Then reopen the diagram and correct your gaps.

## Complete answers

### 1. Why not write PostgreSQL and Kafka in one normal transaction?

They are separate systems with separate commit protocols. Without a distributed transaction protocol, one can commit while the other does not. The outbox stores business state and publication intent atomically in PostgreSQL, then uses duplicate-safe asynchronous relay.

### 2. What does identical idempotent retry return?

Original order and event identities. It must not create another order. The server compares a canonical request hash so the key cannot silently represent changed intent.

### 3. Why reject same key with changed payload?

Accepting would make one operation identity mean two business operations and hide caller bugs or abuse. Conflict forces explicit update or correction semantics.

### 4. Why can relay publish twice?

It can receive broker acknowledgement and fail before recording publication in PostgreSQL. Retry sees pending intent and publishes again. This ambiguity is inherent without one atomic protocol spanning both systems.

### 5. Event ID versus partition and offset?

Event ID names the logical event. Partition and offset name one retained transport position. Duplicate publication creates different offsets with the same event ID.

### 6. How does inbox and effect idempotency work?

A unique event identity is claimed in the same database transaction as business effect. Retry either inserts both once or observes the matching claim and performs no second effect.

### 7. What if same event ID has a different payload hash?

Fail. That is identity conflict, not harmless duplicate. Preserve identities and investigate producer corruption, serialization difference, collision or misuse.

### 8. What ordering does Kafka provide?

Record order within a partition. There is no automatic global order across partitions. Consumer concurrency and retries must respect business ordering scope.

### 9. How is lag calculated?

For each partition, broker end offset minus next processed or committed offset, floored at zero. Sum gives total work; maximum and age reveal user-impacting hotspots.

### 10. Why does adding consumers stop helping?

One group member owns a partition at a time. Once active members equal useful partitions, more members remain idle unless work is safely parallelized elsewhere.

### 11. What does low aggregate CPU prove?

Only that aggregate CPU was low in that window. It does not rule out partition skew, locks, I/O, network, throttling, checkpoint delay or downstream saturation.

### 12. What should quarantine contain?

The minimum needed for ownership and replay decision: source position, safe event identity, payload hash, bounded reason, time and status. Raw sensitive payload needs a separately justified protected store, not default logs.

### 13. Why is quarantine not success?

The business event remains unapplied. Containment protects pipeline progress, but an owner must correct compatibility and replay or explicitly retire it.

### 14. Why are row counts insufficient?

Two datasets can have equal counts with different identities or values. Use identity comparison, domain totals, mismatch or orphan checks and schema or freshness controls.

### 15. What should a lineage receipt identify?

Run, job or code or config, input and output datasets, source versions or watermarks, start and end, quality result and relevant immutable artifacts.

### 16. Why is Redis not source of truth here?

It is bounded, expiring and nonpersistent. Data is written after durable effect and can be rebuilt. Losing it harms latency or freshness, not accepted business authority.

### 17. Backup versus restore?

Backup creates a recovery artifact. Restore proves it can reconstruct intended state. Recovery further requires reconciliation, service validation, objective measurement and promotion.

### 18. What does snapshot RPO zero mean in this lab?

The isolated restore matches every listed row at recorded backup boundary. It does not mean no event can ever be lost between periodic production backups.

### 19. Why restore to a separate database?

It preserves active copy, allows comparison and makes promotion reversible. In-place restore can destroy the only good state and erase evidence.

### 20. What did the 214-second verifier prove?

Three named synthetic scenarios passed on tested local topology and returned to exact absence. It did not prove multi-zone HA, production throughput, accepted objectives, security or compliance, or learner mastery.

### 21. When is cache reconstruction complete?

When durable source or effect is reconciled, expected keys and values are rebuilt inside the rate boundary, hit and miss behavior stabilizes and representative user reads meet freshness and latency requirements.

### 22. Why keep failed quality receipts?

They preserve what the system knew, which controls failed and which candidate was blocked. Deleting them hides incident history and makes later pass evidence ambiguous.

### 23. Can Kafka retention replace database backup?

Not generally. Events may omit authoritative fields, retention may expire, compaction may remove history and side effects may not be reconstructible. Use the state inventory and prove the exact replay boundary.

### 24. What is honest exactly-once wording?

"The tested duplicate deliveries produced one durable PostgreSQL fact under stable event identity." That is narrower and more defensible than "the platform is exactly once."

## Product-company interview

### Scenario 1: design an order event platform

Start with authority and semantics. PostgreSQL commits order, idempotency and outbox. Kafka retains versioned events under stable identity. Consumers use inbox and effect atomicity. Redis is derived. Quality and lineage gate facts. Then discuss partitioning, SLOs, security, capacity and state-class recovery.

A weak answer starts with brand names. A staff answer states invariants, failure windows and what the design intentionally does not guarantee.

### Scenario 2: client timed out after payment request

Do not retry with a new identity. Reuse the same idempotency key, inspect canonical request hash and return original receipt if committed. If changed intent appears, reject conflict. Explain connection-loss-after-commit ambiguity.

Mention retention for idempotency keys and concurrent requests. If keys expire before the client's retry window, the guarantee silently weakens.

### Scenario 3: exactly-once requirement

Ask "exactly once which effect?" Kafka transactions can coordinate Kafka reads and writes under conditions; they do not automatically include PostgreSQL or an external payment API. Use stable identity, atomic local effects, reconciliation and explicit external idempotency.

State whether ordering, replay and compensation are required. Exactly-once marketing language often hides these requirements.

### Scenario 4: hot customer key

Show per-partition lag, age and rate. Restore the current consumer. Then revisit ordering scope and key cardinality. A key migration or partition increase needs compatibility testing because placement and ordering change.

If one customer's operations require strict sequence, you cannot simply randomize the key. You may need a hierarchical key, substream with versioning, domain serialization or a separate workflow.

### Scenario 5: consumer lag during peak

Quantify arrival rate, service rate, backlog and desired catch-up time. Identify bottleneck per partition and sink. Scale only where parallelism exists. Protect dependencies and use approved load shedding or freshness degradation policy.

Differentiate a transient backlog with positive catch-up rate from an unstable queue where arrival rate exceeds service rate. The latter will never self-heal.

### Scenario 6: poison event blocks a partition

Preserve position and schema identity, bound retry, quarantine minimally, keep unrelated work moving if ordering permits and assign producer and consumer owners. Correct compatibility and replay under governance.

If ordering prohibits skipping, say so. You may need to stop that partition, restore a compatible consumer or execute a reviewed translation while other partitions continue.

### Scenario 7: pipeline succeeded but money differs

Block publication. Compare source and fact identities and monetary control totals, preserve failed run and lineage, isolate transform or source-window error, rerun from immutable input and require a passing receipt.

Never call this a monitoring false positive until you prove the control is wrong. A correct control that blocks bad data is reliability working.

### Scenario 8: Redis cluster lost

Cache availability can affect user path even when business state survives. Protect database from stampede, rebuild progressively from authority, validate staleness and latency and decide whether cache SLO needs replication or persistence.

Also discuss cache-key versioning and invalidation during schema changes. Reconstructing old serialized values into a new application can create subtle failure.

### Scenario 9: Kafka broker loss

Discuss replication factor, ISR, minimum ISR, acknowledgements, controller quorum, rack awareness and client retries. State that one local broker offers none of desired failure-domain tolerance.

Then discuss what user operations do while quorum is unavailable: reject, buffer safely, degrade read-only or accept under a defined risk. Availability is a product decision as well as a broker setting.

### Scenario 10: database restore

Inventory source authority, backups or WAL, event retention and external state. Verify artifact and key access, restore isolated, replay inside explicit watermarks, reconcile, test application reads and security, then promote with rollback or roll-forward.

Include who declares disaster, who owns data validation and what prevents two writable primaries.

### Scenario 11: schema evolution

Build producer and consumer compatibility matrix including replayed history. Prefer additive changes, use stable field semantics, stage consumers before producers where needed and monitor unknown or rejected versions.

Changing a field from cents to major currency units while keeping the same type is semantically breaking even if a schema registry says compatible.

### Scenario 12: Flink checkpoint grows slow

Check backpressure, state size, checkpoint alignment or unaligned behavior, storage latency and operator skew. Treat completed checkpoint as recovery evidence only after restore and upgrade testing with sinks.

Measure checkpoint duration, failure, bytes, age of last successful checkpoint and recovery time. A job can be "running" with a recovery point too old for the objective.

### Scenario 13: Spark streaming duplicates

Inspect checkpoint identity, source offsets, retry or restart, sink commit and query identity. Exactly-once processing claims depend on replayable source and idempotent or transactional sink; an arbitrary side effect can still duplicate.

Copying a checkpoint for a new query can incorrectly reuse progress or state. Treat checkpoint location as state identity.

### Scenario 14: Iceberg table shows old or inconsistent data

Inspect catalog pointer, snapshot history, manifest and file closure, engine caching and commit conflicts. Do not edit object files directly. Choose time travel, rollback or corrected commit with retention and concurrent-writer awareness.

Explain that snapshot rollback changes current metadata pointer; it does not necessarily delete later files or fix external consumers.

### Scenario 15: data observability design

Separate service telemetry from data controls. Instrument request, outbox, publish, lag, process, quarantine, cache, quality and recovery. Bound metric cardinality, correlate traces and logs safely and persist lineage for dataset and run history.

Design alerts from user journey and action: freshness SLO burn, correctness gate failure, retention risk, restore failure and runaway quarantine each has a different owner and urgency.

### Scenario 16: reduce data-platform cost

Use unit economics and access patterns. Tune retention, compaction, file sizes, cache, partitions, query scans and telemetry only inside reliability and security boundaries. Quantify failure and recovery plus engineering-cost trade-offs before cutting redundancy.

Cheap storage with expensive scans or slow recovery may raise total cost. Include human toil and incident loss.

### Scenario 17: multi-region design

State operation-specific consistency and failover requirements. Discuss write ownership, replication lag, conflict policy, event duplication, global ordering limits, data residency and regional recovery. Avoid saying "active-active" without a conflict model.

Test regional isolation and failback, not only failover. Reconciliation across regions is part of recovery.

### Scenario 18: GDPR or deletion request in an event system

Inventory every copy: source rows, compacted and noncompacted topics, facts, caches, logs, quarantine, backups and derived features. Define lawful retention, tombstone or redaction semantics, backup expiry and audit proof.

Do not promise physical deletion from immutable backup instantly if policy relies on expiry and access controls; explain the approved mechanism truthfully.

## Independent transfer and rubric

### Your independent assignment

Use `ASM-0255` with a human reviewer. The reviewer chooses a different business operation—shipment reservation, entitlement change, inventory movement or another synthetic domain—and changes at least one contract or recovery requirement after you begin.

You must not copy guided order identifiers or receive the model answer. Build a fresh bounded system or adapt the fixture transparently, then defend three hidden failures. Your packet must show source and image identities, mutations, expected effects, first failures, hypothesis changes, reconciliation and exact cleanup.

The reviewer should choose faults that require transfer, such as:

- same logical identity with semantically changed payload;
- partition-key distribution that defeats your capacity model;
- consumer effect committed before position acknowledgement;
- valid schema with invalid domain meaning;
- quality counts equal but value control differs;
- cache rebuild overloads authority;
- backup hash valid but retention no longer covers replay;
- restore succeeds but security or user validation fails.

Before every mutation, write four lines:

```text
expected effect:
blast radius:
abort condition:
recovery:
```

After mutation, write:

```text
observed evidence:
hypothesis supported or falsified:
next safest action:
claim boundary:
```

### How the reviewer scores it

The 100-point rubric covers:

| Area | Points | Minimum observable evidence |
|---|---:|---|
| Business and reliability contract | 10 | authority, semantics, ordering, SLO, RPO or RTO and non-goals |
| Reproducibility and safety | 10 | fresh clone, immutable identities, bounded runtime, exact cleanup |
| Transaction and event correctness | 10 | idempotency, atomic outbox, duplicate-safe effect and conflict rejection |
| Schema and privacy | 10 | compatibility matrix, safe containment and no payload leakage |
| Partition and capacity | 10 | per-partition lag or age, rate, skew and catch-up arithmetic |
| Quality and lineage | 10 | blocked failure, preserved receipt, reconciled pass and run or dataset links |
| Observability and incident leadership | 10 | user impact, evidence, falsified hypothesis and actionable signals |
| Recovery | 10 | integrity, isolated restore, replay, reconciliation and overwrite refusal |
| Production and security judgment | 10 | HA, access, encryption, retention, migration, cost and blockers |
| Independent defense | 10 | truthful trade-offs without guided copy or mastery claim |

A high score requires artifacts. Fluent explanation without execution is not enough. Passing local execution without correct proof limits is not enough. Real credential or data, external mutation, unsafe restore or broad cleanup is critical safety failure.

### What mastery means here

Publication of this lesson does not award mastery. Mastery requires independently solving a materially changed problem, receiving human review, correcting gaps and demonstrating retained understanding later. The website may remember reading progress; it must not self-award production experience.

Use the assessment results diagnostically:

- weak transaction score: revisit idempotency, isolation and outbox;
- weak stream score: revisit identity, partitioning, acknowledgements and inbox;
- weak data score: revisit controls, lineage and publication;
- weak recovery score: repeat state inventory, isolated restore and reconciliation;
- weak defense score: practice stating evidence limits before naming tools.

## References and review

### Transaction and recovery

- `REF-1140`: PostgreSQL 18 transaction isolation.
- `REF-1141`: PostgreSQL write-ahead logging.
- `REF-1142`: PostgreSQL continuous archiving and point-in-time recovery.

Read these when deciding isolation, durability and production recovery. The local logical dump does not replace WAL or PITR planning.

### Event log and cache

- `REF-1143`: Apache Kafka design and delivery semantics.
- `REF-1144`: Apache Kafka KRaft operations.
- `REF-1145`: Apache Kafka consumer configuration.
- `REF-1146`: Redis key eviction.
- `REF-1147`: Redis persistence.
- `REF-1148`: Redis replication.
- `REF-1149`: Redis security.

These sources explain product mechanisms. Deployed topology and configuration determine actual guarantee.

### Stream, batch and table transfer

- `REF-1150`: Apache Flink state and fault tolerance.
- `REF-1151`: Apache Flink checkpointing under backpressure.
- `REF-1152`: Apache Spark Structured Streaming programming guide.
- `REF-1153`: Apache Iceberg reliability.
- `REF-1154`: Apache Iceberg evolution.

Use these for production transfer, not to claim the local Python and PostgreSQL model executed those engines.

### Telemetry, lineage and privacy

- `REF-1155`: OpenTelemetry semantic conventions.
- `REF-1156`: Prometheus instrumentation practices.
- `REF-1157`: Prometheus alerting practices.
- `REF-1158`: OpenLineage object model.
- `REF-1159`: OWASP Logging Cheat Sheet.

Review names, label cardinality, alert ownership, run or dataset identity and sensitive logging before production instrumentation.

### Claim boundary and next review

The source set was reviewed on 2026-08-07 and is scheduled for review by 2027-02-07, or earlier when PostgreSQL, Kafka, Redis, Flink, Spark, Iceberg, OpenTelemetry, Prometheus or OpenLineage behavior or version changes materially.

Before publication, require technical, security and privacy, data-governance and instructional review plus reviewer-owned independent transfer. Before production, replace single-process lab with representative quorum and failure domains, authenticated encrypted connectivity, real client or group semantics, representative data scale, restore and PITR drills, accepted SLO or RPO or RTO and organizational ownership.

The honest final sentence is:

> This capstone proves a bounded local model can preserve one business effect across duplicate delivery, expose skew and bad data, and reconstruct derived state from verified backup plus retained events. It teaches the reasoning required for production; it is not production evidence itself.
