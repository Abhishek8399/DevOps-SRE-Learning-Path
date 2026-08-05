---
{"schemaVersion":1,"kind":"lesson","id":"LES-0059","slug":"nosql-cache-reliability","aliases":["V06-L04","nosql-cache-reliability"],"curriculumIds":["DST-003"],"route":"/book/state/nosql-cache-reliability","order":4,"volume":"06-state-distributed-systems","title":"NoSQL and cache reliability: model access, authority, freshness, and failure","summary":"Choose document, key/value, wide-column and cache mechanisms from access patterns, atomic scope, consistency, partitioning, eviction, invalidation, hot keys and recovery.","domain":"state","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0015","LES-0056","LES-0058"],"prerequisiteCurriculumIds":["NET-005","DST-002","DST-005"],"testedEnvironments":[{"platform":"Official documentation and standards","version":"Redis, HTTP caching, MongoDB, Cassandra, DynamoDB and DAX sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish product configuration or behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, database, cache or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","database-engineer","backend-engineer","cloud-engineer","data-platform-engineer","solutions-architect","technical-lead"],"learningObjectives":["Select a data model from operations, invariants, access patterns, growth and team constraints rather than a NoSQL label.","Separate authoritative state, derived projections, indexes and disposable caches with one-way reconciliation ownership.","Compare relational, document, key/value and wide-column models including atomic, indexing and query boundaries.","Design partition and shard keys from cardinality, skew, hottest-key, item-size and secondary-index distributions.","Name read, write, session and failure guarantees per operation across replicas and regions.","Explain cache-aside, read-through, write-through, write-around and write-behind acknowledgement boundaries.","Design versioned keys and invalidation, bounded TTL, expiry jitter, negative caching and stale-serving policy.","Prevent cache stampedes and origin collapse through coalescing, admission, stale windows and capacity.","Choose eviction, memory ceiling, persistence, replication and failover behavior from cache versus authority roles.","Diagnose stale reads, hot keys, oversized values, eviction storms, invalidation gaps and repair overload.","Secure cached authorization and sensitive data with fail-closed behavior, minimization, isolation and deletion evidence.","Validate cold start, full miss, failover, rebalance, repair, privacy deletion and user correctness in bounded environments."],"productionSignals":["user operation correctness success latency freshness and ambiguity","state owner record key schema/version revision and acknowledgement","query key predicates sort page size returned bytes scanned bytes and fan-out","partition/shard key cardinality skew hottest-key requests bytes and throttle","secondary index key distribution write amplification storage and backfill progress","read preference/read concern/write concern/consistency level and session token","replica role lag conflict repair backlog hint/snapshot/stream progress","cache layer key namespace version value bytes age TTL and source revision","hit miss fill bypass negative-hit stale-hit eviction expiry and invalidation counts","per-key concurrent fills coalesced waiters origin queries and amplification factor","memory dataset metadata allocator fragmentation client output replication and persistence buffers","maximum memory policy rejected writes evicted keys and time above limit","origin pool queue latency saturation error and admission/shedding decision","client retry owner attempts deadline timeout and circuit state","persistence mode last durable point snapshot/AOF/log age and restore validation","failover old/new primary epoch client discovery and ambiguous writes","authentication principal tenant authorization policy cache decision age and revocation version","encryption peer/key identity sensitive fields purge/deletion and access audit","cross-zone/region bytes provisioned/request units memory storage backup telemetry and operator cost","cold-start warm-up duration hit recovery origin headroom and user SLI"],"diagrams":[{"id":"LES-0059-DIA-001","title":"State ownership portfolio","direction":"hierarchical","boundaries":["user operation","authoritative relational/document/key-value/wide-column state","derived search/index/projection","shared cache","process cache","user response"],"evidencePoints":["operation ID","revision","source owner","projection position","cache age","served version"],"textAlternative":"One authoritative owner records each fact; derived stores and cache layers carry explicit revisions and reconcile from that owner before serving a user contract."},{"id":"LES-0059-DIA-002","title":"Access-pattern-to-model decision","direction":"left-to-right","boundaries":["operation and invariant","key and predicates","atomic scope","result shape","partition distribution","data model and indexes"],"evidencePoints":["query","transaction","bytes","cardinality","hot key","chosen structure"],"textAlternative":"Data-model selection begins with operations, atomic boundaries, key distribution and result shapes, then chooses structures and indexes that make those paths explicit."},{"id":"LES-0059-DIA-003","title":"Cache-aside read and refill","direction":"left-to-right","boundaries":["client","application cache lookup","miss coalescer","authoritative origin","versioned fill","response"],"evidencePoints":["logical key","hit age","one refresh owner","origin revision","conditional fill","served revision"],"textAlternative":"On a miss, one bounded owner reads authoritative state and conditionally fills a versioned entry while peers wait or use a bounded stale value, preventing origin amplification and stale overwrite."},{"id":"LES-0059-DIA-004","title":"Hot partition and secondary-index path","direction":"hierarchical","boundaries":["request distribution","base partition key","hot key","secondary index key","physical partition","capacity and throttle"],"evidencePoints":["cardinality","top key RPS","bytes","index fan-out","per-partition limit","rejections"],"textAlternative":"A high-cardinality base key can still have one viral key or low-cardinality secondary index that concentrates requests and bytes on one physical partition."},{"id":"LES-0059-DIA-005","title":"Expiry, eviction, and invalidation","direction":"left-to-right","boundaries":["authoritative revision changes","invalidation event","cache layer tracking","TTL expiry","memory eviction","next request"],"evidencePoints":["revision","delivery","acknowledged layer","age","policy","miss/refill"],"textAlternative":"Invalidation, expiry and eviction remove entries for different reasons; each layer can miss a message, retain a stale value or create origin load on the next request."},{"id":"LES-0059-DIA-006","title":"Failure and recovery ladder","direction":"hierarchical","boundaries":["one key","cache process","cache shard","origin partition","replica group","region","derived stores and privacy copies"],"evidencePoints":["stale value","eviction","hotspot","lag","quorum","outage","reconciliation"],"textAlternative":"Failures widen from one entry through cache and authoritative partitions to regions and untracked copies; recovery restores authority first, prevents stale refill, warms gradually and reconciles user/privacy state."}],"commands":[{"id":"LES-0059-CMD-001","question":"Is this the supported offline lab boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0059 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"OS user credential and Python guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"named prerequisite or safety guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"database or cache behavior"},{"id":"LES-0059-CMD-002","question":"Can the exact synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture identity ownership and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state or fixture rejected","nextEvidence":"preserve first error"}],"proves":"bounded local initialization","doesNotProve":"service setup","cleanup":"Run bash lab.sh cleanup after setup."},{"id":"LES-0059-CMD-003","question":"Does the baseline cross every encoded boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0059 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"all encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"fixture or model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0059-CMD-004","question":"Is authoritative ownership explicit?","risk":"read-only","command":"bash lab.sh evaluate cache-no-authority","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=authority","meaning":"cache/projection cannot be reconciled","nextEvidence":"assign source of truth and direction"}],"proves":"encoded ownership gap","doesNotProve":"data lineage"},{"id":"LES-0059-CMD-005","question":"Does one business invariant exceed the store atomic scope?","risk":"read-only","command":"bash lab.sh evaluate cross-key-invariant","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=atomic-scope","meaning":"operation spans more keys than atomic contract","nextEvidence":"redesign invariant transaction or workflow"}],"proves":"encoded atomic mismatch","doesNotProve":"product transactions"},{"id":"LES-0059-CMD-006","question":"Can the hottest key exceed one partition?","risk":"read-only","command":"bash lab.sh evaluate hot-key","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=hot-key","meaning":"top-key demand exceeds declared per-key capacity","nextEvidence":"read replication coalescing allocation or shedding"}],"proves":"encoded hottest-key arithmetic","doesNotProve":"provider limit"},{"id":"LES-0059-CMD-007","question":"Can the value fit the declared item boundary?","risk":"read-only","command":"bash lab.sh evaluate oversized-value","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=value-size","meaning":"serialized item exceeds design maximum","nextEvidence":"split metadata/blob or remodel"}],"proves":"encoded size mismatch","doesNotProve":"actual serialized memory"},{"id":"LES-0059-CMD-008","question":"Does a session read meet its required revision?","risk":"read-only","command":"bash lab.sh evaluate stale-session-read","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=consistency-contract","meaning":"served revision trails required revision","nextEvidence":"bypass wait route or report pending"}],"proves":"encoded revision gap","doesNotProve":"all consistency histories"},{"id":"LES-0059-CMD-009","question":"Can TTL expiry break a correctness window?","risk":"read-only","command":"bash lab.sh evaluate idempotency-ttl-short","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=ttl-correctness","meaning":"entry can disappear before duplicate/revocation obligation ends","nextEvidence":"durable record and policy retention"}],"proves":"encoded TTL mismatch","doesNotProve":"business duplicate window"},{"id":"LES-0059-CMD-010","question":"Can synchronized misses stampede the origin?","risk":"read-only","command":"bash lab.sh evaluate stampede","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=stampede","meaning":"no coalescing or expiry spread","nextEvidence":"one refresh owner jitter and admission"}],"proves":"encoded stampede controls absent","doesNotProve":"origin capacity"},{"id":"LES-0059-CMD-011","question":"Can a cached security decision fail open?","risk":"read-only","command":"bash lab.sh evaluate authorization-fail-open","runFrom":"LES-0059 support/lab","expectedBranches":[{"when":"boundary=security-fail-open","meaning":"stale/unavailable policy may grant access","nextEvidence":"fail closed revocation version and bounded cache"}],"proves":"encoded unsafe policy","doesNotProve":"authorization implementation"},{"id":"LES-0059-CMD-012","question":"Do all cases, refusal, and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0059 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"fourteen branches refusal and cleanup pass","nextEvidence":"retain model limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"Redis MongoDB Cassandra DynamoDB DAX HTTP cache network persistence failover or production recovery","cleanup":"Verifier proves exact UID-scoped state absence."}],"labs":[{"id":"LES-0059-LAB-001","title":"Guided NoSQL and cache boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one exact UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","cloud/database/cache/Kubernetes credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failed boundary; change only the copied synthetic fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0059-nosql-cache-reliability/support/lab"},{"id":"LES-0059-LAB-002","title":"Independent store-selection, hot-key, stale-cache and recovery transfer","mode":"independent","environment":"Reviewer-owned disposable local data/cache services or history/load simulator with synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns service/network fault capability","network":"isolated local only","changes":["synthetic workload and distributions","disposable authoritative and cache state","approved hot-key/expiry/invalidation/origin faults","reconciliation artifacts"],"abortConditions":["shared or production service","real credential","customer data","global cache flush","host network/clock mutation","unknown cleanup scope"],"recovery":"Preserve histories, revisions and user assertions; reset through the reviewer harness and prove no stale refill.","cleanupProof":"Reviewer proves processes, containers, volumes, files, ports, credentials and synthetic data absent.","path":"drafts/LES-0059-nosql-cache-reliability/support/lab"}],"incidents":[{"id":"LES-0059-INC-001","signal":"One viral key throttles while table-wide capacity appears mostly idle.","firstThought":"Average utilization hides a per-key or physical-partition ceiling; a secondary index may concentrate the same traffic.","safePath":"Bind base/index keys, top-key RPS/bytes/item size and per-partition evidence; coalesce/cache reads, bound demand or redesign allocation without breaking the invariant.","trap":"Increase total capacity without inspecting the hottest key."},{"id":"LES-0059-INC-002","signal":"A price remains stale after an update and successful invalidation publish.","firstThought":"Publish acknowledgement did not prove every cache layer consumed or applied the revision; an old fill may race after invalidation.","safePath":"Trace authority revision, event ID, layer acknowledgements, entry version/age and fill timeline; use versioned keys or conditional fill and reconcile user output.","trap":"Flush every cache."},{"id":"LES-0059-INC-003","signal":"Many popular keys expire together and origin queries rise forty times.","firstThought":"Synchronized expiry plus concurrent misses created a stampede and retry feedback.","safePath":"Protect origin, coalesce per key, use approved bounded stale, TTL jitter/proactive refresh and admission; verify freshness and repeat expiry.","trap":"Add retries and a longer arbitrary TTL."},{"id":"LES-0059-INC-004","signal":"A cache failover reports success but recently acknowledged write-behind updates are missing.","firstThought":"Acknowledgement covered volatile cache state, not a durable buffer or authoritative sink.","safePath":"Stop unsafe acknowledgements, bind operation IDs and durable positions, reconcile missing effects, then make write-behind durable/idempotent or choose write-through/around.","trap":"Promote another cache replica and declare recovery complete."},{"id":"LES-0059-INC-005","signal":"Repair and rebalance traffic increases foreground tail latency and timeouts.","firstThought":"Background convergence competes for disk/network/CPU with user work and may amplify retries.","safePath":"Graph partition lag, streaming, compaction/repair, queues and user SLI; bound background work, preserve failure headroom and recover one scope at a time.","trap":"Run maximum repair parallelism across the cluster."}],"assessmentIds":["ASM-0160","ASM-0161","ASM-0162"],"referenceIds":["REF-0643","REF-0644","REF-0645","REF-0646","REF-0647","REF-0648","REF-0649","REF-0650","REF-0651","REF-0652","REF-0653","REF-0654","REF-0655","REF-0656","REF-0657"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not a database, cache, protocol, benchmark, consistency checker or failure simulator.","Synthetic decisions do not prove any Redis, MongoDB, Cassandra, DynamoDB, DAX, HTTP cache or provider behavior.","No socket, keyspace, shard, replica, persistence file, eviction, failover, repair, load or external resource exists.","Product guarantees, limits, pricing and behavior are version-, configuration-, region- and operation-dependent.","Formal review, canonical publication, representative disposable-service evidence, reviewer transfer, delayed recall and learner evidence remain required."]}
---

# NoSQL and cache reliability: model access, authority, freshness, and failure

## What you see and first thought

The cache dashboard is green. Hit ratio is 99%. Customers still see old prices, one viral product times out, and the origin database is saturated. None of those statements contradicts the others.

A hit means a cache returned an entry. It does not prove the entry is current, authorized, complete, from the correct tenant, or safe for this operation. A high average hit ratio can hide one critical key that always misses, one stale security decision that always hits, or one synchronized expiry that overloads the origin.

Use this first thought:

> Bind the user operation, authoritative state owner, exact key and revision, cache layer, entry age, fill/invalidation history, partition distribution and origin consequence. “Cache up” and “NoSQL scales” are not diagnoses.

One request can cross many state owners:

```text
client/browser cache
       |
       v
edge or proxy cache
       |
       v
application process cache
       |
       v
shared cache -- miss --> authoritative database partition
       |                          |
       v                          v
served revision             derived search/index
```

Every layer can store a different revision, apply a different key, expire at a different time, miss an invalidation, evict under pressure, or fail with a different policy. The design is reliable only when authority, freshness and fallback are explicit at each boundary.

“NoSQL” means “not only one relational model,” not one architecture or guarantee. A document store, key/value service, wide-column database, search index and in-memory data-structure server solve different access patterns and expose different atomicity, consistency, indexing, persistence and recovery contracts.

## Terms before commands

**Source of truth** is the state owner whose accepted value resolves a conflict. It must be named per fact, not per application. A product description may be authoritative in one store while search terms and thumbnails are derived elsewhere.

**Access pattern** describes one operation as key/predicates, sort/order, page and result size, frequency/burst, consistency, atomic scope and retention. “Query products” is not an access pattern.

**Partition key** chooses the logical group and often the physical routing owner. **Shard key** is product terminology for a distribution key. A **clustering** or **sort key** orders items within the partition in some models. A **secondary index** creates another access path and another distribution/cost boundary.

**Cardinality** is the number of distinct key values. High cardinality can help distribution, but one extremely popular value can still be hot. **Skew** describes uneven request, byte or storage distribution.

**Document** stores related fields as one hierarchical record. **Key/value** retrieves a value from an exact key. **Wide-column** commonly organizes rows by partition key and ordered clustering columns for known query shapes. These are modeling families, not guarantees about transactions or availability.

**Cache entry** is a stored response or value intended to avoid repeat work. **Hit** returns a stored entry; **miss** requires another path. **Fill** loads the cache. **Invalidation** marks or removes an entry because authority changed. **Expiry** removes or makes it stale after a time rule. **Eviction** removes it because of capacity policy. They are different mechanisms.

**TTL**, time to live, is a lifetime policy. It is not universal propagation time and should not replace a business correctness window. An idempotency record that must prevent duplicates for 24 hours cannot safely live only in an evictable cache with a one-hour TTL.

**Freshness** is whether an entry is within the operation's allowed age/revision. **Stale-while-revalidate** can return a bounded stale response while refreshing. **Stale-if-error** can prefer bounded stale data to an origin error. Neither is suitable automatically for price, authorization, inventory or privacy decisions.

**Cache stampede** or thundering herd occurs when many callers independently refresh the same missing/expired value and multiply origin work. **Request coalescing** lets one bounded owner refresh while peers wait or use an approved stale result.

**Write-through** synchronously updates authority and cache in one product-defined path. **Write-around** updates authority and lets later reads fill. **Write-behind** acknowledges before the authoritative sink is updated; it needs durable buffering, ordering/idempotency and reconciliation or acknowledged writes can disappear.

## Architecture map

Start with an ownership table:

| Fact | Authority | Derived copies | Reconciliation direction | Failure behavior |
|---|---|---|---|---|
| product identity/attributes | reviewed product state | document projection, search, caches | authority -> projections | authoring may stop; old browse bounded |
| inventory available | transactional inventory owner | browse projection/cache | inventory -> projection | reservation rejects without authority |
| search ranking | search/index system | edge query cache | source events -> index | degrade or serve bounded result |
| authorization decision | policy owner and revocation version | short bounded decision cache | policy -> cache | fail closed for protected operation |

If two stores can independently edit the same field and neither owns conflict resolution, the architecture is unfinished.

Then map operations:

```text
operation -> invariant -> authority -> atomic scope
          -> key/predicates/order/result
          -> partition and index distribution
          -> consistency/acknowledgement
          -> cache layers and freshness
          -> failure/recovery/user proof
```

Choose the smallest portfolio that satisfies these paths. A common reliable design is an authoritative transactional store, one derived search/index, and one bounded cache. Adding a document database, wide-column store and second cache “for scale” creates more replication, schema, identity, deletion, backup, monitoring and on-call work. Add a store only when measured constraints justify its separate failure domain.

Model families:

| Family | Natural strength | Boundary to inspect |
|---|---|---|
| relational | constraints, joins, transactions and flexible queries | horizontal distribution and workload-specific scaling |
| document | aggregate-shaped reads and flexible nested records | document growth, duplication, cross-document invariants and indexing |
| key/value | exact-key lookup and simple conditional operations | query/index limits, value size and per-key hot spots |
| wide-column | partition-key plus range/ordered access at scale | query-first schema, partition size, tombstones/repair and cross-partition work |
| search | text/relevance and multi-field retrieval | derived freshness, indexing lag and non-authoritative results |
| cache | low-latency reuse and origin shielding | staleness, invalidation, eviction, stampede and fallback |

The best choice is often “keep the relational owner and add a derived projection/cache,” not a migration to another data model.

## Request or state path

Write an access-pattern record before creating a table or collection:

```text
operation: get product detail
input: tenant_id + product_id
filter/order: exact key
result: one 12 KiB aggregate
rate: 8k/s typical, 40k/s burst
top key: 5k/s during campaign
consistency: browse may be <=30 s stale; own edit requires revision
atomic scope: one product document, inventory excluded
retention/privacy: product lifecycle + deletion propagation
```

For a history feed:

```text
operation: list device readings
input: tenant_id + device_id + time range
order: event_time descending
page: 100 rows, continuation token
rate/size: measured per device and tenant
atomic scope: append one reading; no cross-device invariant
retention: 30 days hot, archive policy separate
```

This shape may fit a wide-column partition by tenant/device and cluster by time, but calculate worst partition bytes and events—not averages. A device emitting 1,000 events/s for 30 days creates 2.592 billion events in one unbounded partition. Add a time bucket only when queries and deletion can handle it.

Document modeling asks whether data is owned, read and updated together. Embed a bounded set of display attributes that travel with one product. Reference a supplier shared by millions of products or an unbounded review collection. Duplicating a supplier name into product projections can improve reads, but now updates and deletion need versioned propagation and reconciliation.

Key/value modeling asks whether exact identity is enough. Session state, feature snapshots and exact product projections can fit. Searching every value or filtering arbitrary attributes cannot be wished into an exact-key service; it requires indexes, scans or a derived search model.

Every index is another write and failure path. Measure index-key cardinality and skew separately. A high-cardinality primary key does not save an index on `status=ACTIVE` if most writes target one value and one physical range.

## Failure zoom

Zoom into one viral product. The table has ten million product keys, so average distribution looks excellent. One campaign sends 20,000 reads/s and 2,000 conditional writes/s to `product-42`. If one logical key maps to one storage partition, that key's limit matters more than table-wide spare capacity.

Read hot keys can often be handled by:

- versioned cache copies;
- request coalescing;
- follower/read replicas when their consistency fits;
- precomputed immutable snapshots;
- admission and graceful shedding;
- local or edge copies with a bounded stale contract.

Write hot keys are harder because one invariant may require serialization. Salting `product-42` into 100 random keys distributes writes but breaks “one authoritative stock count” unless the business invariant is redesigned. Escrow can allocate stock rights across owners, but adds allocation, expiry, transfer and reconciliation logic.

Measure:

```text
top-key requests/s and bytes/s
top 1/10/100 key share
per-partition consumed capacity and throttles
item serialized size
secondary-index write/read distribution
retry attempts per logical operation
```

The same problem appears with low-cardinality tenants, timestamps, booleans, status fields, monotonically increasing keys and celebrity users. Write sharding is safe only when the read/aggregate and correctness path are explicit.

Large values create multiple costs: network bytes, serialization CPU, allocator overhead, replication, persistence logs, compaction, cache memory and eviction pressure. Store large immutable blobs in an object store when appropriate and keep validated identity, digest, size and authorization metadata in the database. Splitting one atomic record into chunks introduces partial-read/update and cleanup rules.

Now zoom into a synchronized cache expiry:

```text
10:00:00  key expires on 200 application instances
10:00:00  20,000 requests all miss
10:00:00  each instance opens origin query
10:00:01  origin pool queues; latency rises
10:00:02  clients retry; attempts multiply
10:00:05  fills complete out of order; older revision may overwrite newer
```

The cache remained healthy. The reliability failure is ownership of refill and origin admission. Use one bounded refresh owner per key, conditional/versioned fill, TTL jitter, stale-while-revalidate within a safe window, retry budgets and origin protection.

Eviction and expiry can look similar from the application but need different fixes. Expiry is time policy; eviction is capacity policy. A burst of large entries can evict hot smaller entries even when their TTL remains. A volatile-only eviction policy can behave like no-eviction if eligible keys are absent. Inspect actual configuration and runtime counters.

Failure can also create false hits. A deleted account remains in process cache; authorization returns allow. A negative “product absent” entry remains after creation. A query-result cache is not invalidated when one item changes. The fix is not “more cache availability”; it is revision-aware invalidation, bounded absence, fail-closed security and user-level validation.

## Internals and state ownership

Cache patterns define different acknowledgements.

**Cache-aside read:**

```text
read cache
  hit -> validate age/revision as required -> return
  miss -> coalesce -> read authority -> conditional/versioned fill -> return
```

The application owns misses, fills, invalidation and race handling. A slow fill for revision 41 must not overwrite revision 42 after invalidation. Put the revision in the key, value or conditional write.

**Read-through** moves miss/fill behavior into a cache/provider library. It reduces application code but does not remove key, freshness, origin, stampede or error-policy decisions. Verify the product's actual behavior.

**Write-through** sends a write through the cache layer to authority and updates the cache as part of the defined path. The success boundary must state whether authority committed before response and which cache layers updated. Bypass writers can still create staleness.

**Write-around** writes authority directly and invalidates or lets later reads refill. It avoids caching write-only data but creates a post-write miss and a stale-entry race.

**Write-behind** updates cache and asynchronously writes authority:

```text
client -> cache accepted -> durable ordered buffer? -> sink effect -> checkpoint
```

If the buffer is volatile, “success” can vanish on failover. If replay is possible, the sink needs stable identity and idempotent/conditional application. If ordering matters, partition the buffer by the invariant and preserve sequence. Cache replication alone may not equal durable write-behind.

Invalidation choices:

- **delete then refill:** simple, but a delayed old fill can repopulate stale data;
- **update cache:** avoids miss but duplicates write paths and can diverge;
- **versioned immutable key:** write `product:42:v17` and update a small pointer/revision; old values age out;
- **event-driven invalidation:** scalable across layers but delivery, ordering and consumer state matter;
- **short TTL:** bounds some staleness but does not guarantee immediate revocation or prevent stale fill;
- **validation token:** compare ETag/revision before using or refreshing.

Invalidation acknowledgement must be scoped. “Published event” does not prove every browser, edge, process and shared cache removed the value. Track event ID, authoritative revision, consumer position and entry version.

HTTP caches add method/status/header rules, `Vary`-dependent cache keys, validators such as ETag, freshness lifetime and `Age`. A response cached without tenant or authorization variation can leak data. Shared caches must not store private responses contrary to policy. Treat cache key composition as a security boundary.

Negative caching stores absence. It prevents repeated expensive misses, but the absent entity may later appear. Bind negative entries to exact query/tenant/schema, use a shorter justified lifetime, coalesce creation races, and invalidate on creation. Never turn transient origin errors into “not found.”

Data-store internals differ:

- MongoDB documents have operation- and deployment-specific read/write concern, replica and sharding behavior.
- Cassandra wide-column tables route by partition key, replicate ranges and require repair/convergence operations.
- DynamoDB operations expose item/index/consistency and partition capacity rules; DAX item and query caches have distinct behavior.
- Redis provides data structures, memory/eviction, replication and optional persistence; whether it is disposable cache or authority changes required durability and recovery.

Do not transfer a guarantee by name. “Majority,” “strong read,” “transaction,” “TTL,” and “replica” have product-specific scopes.

## Evidence table

| Question | Minimum evidence | Does not prove |
|---|---|---|
| what does the user need? | operation, invariant, acknowledgement, revision/freshness | implementation |
| is the model suitable? | measured access patterns and atomic scope | capacity |
| is partitioning balanced? | per-key/index distributions and physical throttles | future skew |
| is a read current enough? | required and served revision/age plus read mode | all histories |
| is cache effective? | hits/misses by outcome, fill cost, origin amplification | correctness |
| why was a key absent? | expiry, eviction, invalidation or never-filled evidence | authority absence |
| can failover lose writes? | acknowledgement, durable position, replica/persistence state | business reconciliation |
| did repair complete? | version/range comparison, backlog zero, user checks | backup recoverability |
| was privacy deletion complete? | owner inventory, purge positions, refill prevention, audit | unknown copies |

Cache hit ratio:

```text
hit_ratio = hits / (hits + misses)
```

Useful, but pair it with:

- hit freshness and correctness;
- per-key/tenant/operation distribution;
- miss service time and origin work;
- fill concurrency and amplification;
- evictions versus expirations;
- stale and negative hits;
- memory/headroom and failure mode.

At 99% hit ratio and 100,000 requests/s, 1,000 misses/s reach the origin. If each logical miss causes 50 concurrent fills, the origin sees 50,000 queries/s. Average hit ratio did not reveal the stampede.

Memory planning:

```text
usable data memory
  = process/container memory
  - executable/runtime
  - key/value metadata
  - allocator/fragmentation reserve
  - client/output buffers
  - replication/persistence buffers
  - fork/copy-on-write or maintenance reserve
  - failure headroom
```

Measure serialized key/value distributions—P50, P95, P99 and maximum—not object counts alone. Include replicas and multi-layer duplication. Never set a process memory limit equal to the cache data target.

For NoSQL stores observe:

- operation latency/error/throttle by consistency mode;
- scanned versus returned rows/bytes;
- partition/index skew and hottest keys;
- replica/partition ownership and lag;
- compaction, tombstone, repair and streaming pressure where applicable;
- item/document/partition size growth;
- connection, queue, CPU, disk and network saturation;
- backup/restore and reconciliation status.

Histories decide consistency claims:

```text
write product rev=42 returns committed
read requires rev>=42
cache hit returns rev=39 age=12s
```

Even if 12 seconds is below a browse TTL, it violates a read-your-writes minimum-revision request. Operation scope wins over a global cache setting.

## Command decoders

`bash lab.sh doctor` checks only the offline host boundary. It refuses root, unsupported Ubuntu versions, missing Python and common credential variables. Passing it does not show that a cache or database exists.

`bash lab.sh setup` creates one exact UID-scoped state directory and copies a synthetic case file. It checks path, type, owner, sentinel, symlink and inventory. It never starts a service.

`bash lab.sh evaluate cache-no-authority` returns `boundary=authority` because an evictable copy has no declared reconciliation source. The design correction is to name authority, not enable persistence blindly.

`bash lab.sh evaluate cross-key-invariant` detects that three keys participate while the declared atomic limit is one. Decide whether to co-locate the invariant, use a real multi-key transaction, redesign with allocation, or coordinate a workflow.

`bash lab.sh evaluate hot-key` compares hottest-key demand with per-key capacity. It does not assume table-wide capacity can help one key.

`bash lab.sh evaluate oversized-value` catches an encoded value-size boundary. Real memory and request cost require serialization and runtime measurement.

`bash lab.sh evaluate stale-session-read` compares required with served revision. The recovery could bypass cache, route, wait, validate or return pending—depending on the operation contract.

`bash lab.sh evaluate idempotency-ttl-short` teaches that eviction/expiry cannot end a business duplicate-prevention obligation.

`bash lab.sh evaluate stampede` requires at least one of coalescing or spread in this simplified model. Production protection also needs origin admission, deadlines, stable revisions and capacity.

`bash lab.sh evaluate authorization-fail-open` refuses cached security decisions that grant during authority failure. Real authorization policy may have carefully reviewed offline capabilities, but the default for protected resources is not stale allow.

`bash verify.sh` evaluates fourteen declared branches, injects an unexpected entry, proves guard refusal, removes only that entry, and proves final absence. It is model evidence only.

When using real product commands later, decode every flag and output. A command such as Redis `INFO memory` or Cassandra repair preview shows one product boundary at one time. It does not establish user correctness, global consistency or recovery by itself.

## Decision path

Use this sequence:

1. **Operation:** what does the caller do and what response is promised?
2. **Invariant:** what must never become false?
3. **Authority:** which store resolves conflicts for each fact?
4. **Access:** exact key, predicates, order, page/result bytes, rates and bursts?
5. **Atomic scope:** one field/document/key/partition, many keys, or workflow?
6. **Distribution:** cardinality, skew, top key, secondary indexes, item and partition size?
7. **Consistency:** read/write/session contract and partition behavior?
8. **Cache:** which copy, key/version, fill, write, invalidation, TTL, negative/stale and failure policy?
9. **Capacity:** memory, per-partition throughput, origin, repair and failure headroom?
10. **Recovery:** prevent stale refill, restore authority, warm gradually, reconcile user/privacy outcomes?

Selection examples:

- Strong multi-row invariants and flexible joins: relational first.
- One bounded aggregate read/updated together with evolving optional fields: document may fit.
- Exact key with simple conditional update: key/value may fit.
- Massive known partition-plus-range queries with bounded partitions: wide-column may fit.
- Full text/relevance: derived search index.
- Repeated expensive reads with tolerated staleness: cache.

Reject a cache when correctness requires every read from authority and the saved work is small; cache complexity can exceed benefit. Reject a new database when existing indexed/projection designs meet objectives. “Schemaless” does not remove schema—producers, consumers, indexes and old records still need evolution rules.

For every selected store, write an ADR with workload evidence, guarantees, limits, alternative, failure behavior, recovery, cost and exit plan.

## Guided Ubuntu lab

The lab does not require Docker or a data service. It teaches architecture boundary order without pretending deterministic JSON is a database.

From Ubuntu 24.04 as a normal user:

```bash
cd drafts/LES-0059-nosql-cache-reliability/support/lab
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected shape:

```text
doctor=pass runtime=offline-nosql-cache-model
fixture=valid cases=14
setup=pass state=/tmp/reliability-atlas-les0059-nosql-cache-<uid> network=none
status=ready cases=14 network=none
```

If `doctor` refuses, do not bypass it. Remove credential variables from this shell, use the supported normal user and OS, or treat the lifecycle as unverified.

Run:

```bash
bash lab.sh evaluate baseline
bash lab.sh evaluate unknown-access-pattern
bash lab.sh evaluate cross-key-invariant
bash lab.sh evaluate hot-key
bash lab.sh evaluate oversized-value
```

Expected boundary order:

```text
operable
access-pattern
atomic-scope
hot-key
value-size
```

This order matters. Selecting a partition key before defining the access pattern is guesswork. Claiming the store scales when one invariant spans more keys than its atomic contract is a correctness gap. Average cardinality cannot hide a hot key. Payload size affects capacity even with perfect distribution.

Continue:

```bash
bash lab.sh evaluate stale-session-read
bash lab.sh evaluate idempotency-ttl-short
bash lab.sh evaluate unversioned-invalidation
bash lab.sh evaluate stampede
bash lab.sh evaluate unbounded-negative-cache
```

Say what each means:

- served revision is older than the session requires;
- a disposable entry expires before its correctness obligation;
- fills/invalidation have no revision to prevent stale overwrite;
- synchronized misses have no coalescing or expiry spread;
- absence may be retained without a bounded creation/update path.

Finally:

```bash
bash lab.sh evaluate authorization-fail-open
bash lab.sh evaluate volatile-write-behind
bash lab.sh evaluate repair-disabled
```

These separate security, durability and convergence. Caching “allow” cannot grant through policy outage by default. A volatile write-behind buffer cannot support a durable success acknowledgement. Replicas do not converge merely because repair is expected.

Inspect one case:

```bash
bash lab.sh show stampede
```

Change only the copied fixture inside the exact `/tmp` state for practice. Predict the next boundary before rerunning. Do not weaken `model.py` to manufacture a pass.

Clean and verify:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected:

```text
cleanup=pass state_absent=true
verify=pass cases=14 refusal=true cleanup=true
```

If cleanup refuses, preserve the error and inspect the exact directory. Do not recursively delete a computed path.

The independent lab uses a reviewer-owned disposable environment:

1. Record baseline workload distributions and operation histories.
2. Build only the minimum authoritative store/cache topology needed.
3. Prove read/write/session guarantees and authoritative recovery without cache.
4. Add cache-aside with versioned entries, TTL jitter and coalescing.
5. Inject synchronized expiry and prove origin amplification is bounded.
6. Inject a stale invalidation/fill race and prove old revision cannot overwrite new.
7. Drive one hot key and one skewed secondary index; measure throttle and user effect.
8. Fill memory to the reviewed ceiling; observe eviction, buffers and failure behavior.
9. Restart/fail over disposable services and reconcile ambiguous writes.
10. Purge one synthetic sensitive identity across authority, derived index and cache; prevent stale refill.
11. Restore, warm gradually, validate user operations, then prove exact cleanup.

Passing the offline model cannot substitute for this.

## Production transfer

Incident order:

**1. User contract.** Capture operation ID, expected/served value and revision, consistency/freshness requirement, endpoint and timestamp.

**2. Ownership.** Identify authoritative record, derived stores and every cache layer/key.

**3. Distribution.** Record partition/shard/index keys, top-key request/byte rates and physical owner/throttle evidence.

**4. Cache state.** Key namespace/version, hit/miss, entry age/TTL, fill owner, invalidation event/position, eviction and expiry reason.

**5. Origin state.** Pool/queue/latency, read/write mode, replica lag, capacity, errors and retry multiplication.

**6. Contain.** Prevent stale/security harm, protect origin, bound retries/fills/repair and preserve evidence.

**7. Recover authority first.** Restore correct state and supported replication/quorum before bulk warming.

**8. Prevent stale refill.** Increment namespace/revision, drain old fills and reconcile derived copies.

**9. Validate.** User correctness, freshness, tail latency, distribution, next expiry/failover and privacy deletion.

### Viral key with idle total capacity

Do not scale the whole table before finding the limiting key and index. Query or metric aggregation can hide that one physical partition is saturated. Read copies/cache/coalescing may help reads; a write invariant needs serialization, allocation or business redesign. Confirm retries are not multiplying a small base load.

### Price stale after “successful invalidation”

Trace authoritative revision, invalidation event ID, every consumer position, cache entry version, fill start/finish and client layer. A fill that started before update can finish afterward. Versioned/conditional fill prevents old revision from winning. A successful publish is not global purge proof.

### Cache outage becomes origin outage

A reliable origin path should survive a planned cache bypass at a bounded admitted rate, not necessarily full cached traffic. Shed optional work, prioritize critical operations, coalesce misses and use only approved stale data. Restore cache gradually; a fleet-wide warm-up can be a denial of service.

### Write-behind loss after failover

Bind each successful response to a durable queue/log position and sink receipt. If no durable position exists, the acknowledgement was stronger than the mechanism. Stop further loss, reconcile by operation identity, and change to durable idempotent write-behind or a safer write-through/around path.

### Repair overload

Correlate repair/streaming/compaction with disk, network, CPU, cache eviction, request queue, replica lag and user SLI. Throttle background work, preserve failure headroom and recover one partition/failure domain at a time. “Repair complete” requires version/range and business checks, not command exit alone.

Production readiness review:

- schema and access paths tested with representative distributions;
- item/document/partition growth ceilings and alerts;
- consistency and acknowledgement table;
- cache disabled/degraded behavior;
- cold-start and synchronized-expiry test;
- stale-fill and invalidation-loss test;
- hot-key/index skew test;
- memory/eviction/persistence/failover test;
- repair/rebalance with foreground load;
- backup/restore and business reconciliation;
- privacy deletion with refill prevention;
- runbooks, ownership, cost and change controls.

## Reliability, security, observability, capacity, and cost

Reliability begins with correct cache bypass. For each operation define:

- authoritative direct path;
- maximum admitted bypass rate;
- timeout and retry owner;
- whether stale data can serve and for how long;
- what becomes unavailable;
- how recovery avoids a warm-up storm.

Do not make every operation depend on cache availability. Conversely, do not promise the origin can absorb 100% of cached peak without paying for it. A deliberate degradation plan might preserve checkout while shedding recommendations.

Security:

- include tenant, subject, policy/version and relevant request dimensions in security cache keys;
- never key private responses only by URL when authorization changes content;
- fail closed for protected operations when revocation/current policy cannot be proved;
- encrypt transport and storage according to data classification;
- isolate administrative, flush, persistence, restore and membership privileges;
- minimize payloads in keys/logs because cache keys and command traces leak context;
- audit mass invalidation and restore;
- prevent stale refill after deletion/revocation.

Authorization caches require revocation objectives. A 10-minute TTL means an allow may persist for roughly that window unless push invalidation or version checking exists. State that risk explicitly.

Observability should expose outcome, not just cache mechanics:

```text
user SLI
  + served revision/age
  + cache layer/key version
  + hit/miss/stale/negative outcome
  + fill and invalidation ID
  + origin request and revision
  + partition/index owner and throttle
```

Avoid raw customer keys and unbounded cardinality in metrics. Use controlled top-key diagnostics with access protection and sampling.

Capacity model:

```text
origin peak admitted requests
  >= cold-miss traffic after coalescing
   + unavoidable writes
   + repair/rebalance overhead
   + failure reserve
```

Cache memory includes data, metadata, fragmentation, client buffers, replication/persistence and maintenance. Cache throughput includes network and serialization. Partition capacity includes item size and secondary-index amplification. Measure tail latency under failure, not only average steady-state.

Cost:

- memory is often more expensive per byte than disk/object storage;
- multi-region replicas and invalidation traffic add network cost;
- secondary indexes multiply writes/storage;
- short TTL increases origin/provider request cost;
- long TTL increases staleness and incident risk;
- high-cardinality telemetry can exceed cache cost;
- each database adds backups, upgrades, security and on-call skill.

Optimize total user/business cost, not hit ratio or monthly memory alone.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| choose “NoSQL for scale” | no access, invariant or team evidence | measured workload and ADR |
| call document data schemaless | producers/consumers/indexes still depend on shape | version, validate and migrate |
| use average key cardinality | one key/index can dominate | top-key and physical distribution |
| salt a correctness key | breaks single-owner invariant | allocation/aggregation redesign |
| treat cache as authority | eviction/failover can erase truth | explicit durable owner |
| use TTL as invalidation | stale until expiry and race remains | versioned invalidation plus TTL bound |
| flush all caches | destroys evidence and stampedes origin | exact key/layer purge and admission |
| maximize hit ratio | can retain stale/low-value entries | outcome/freshness/origin measures |
| retry misses everywhere | multiplies origin work | one retry/fill owner and budgets |
| cache authorization fail-open | stale allow bypasses revocation | fail closed and version policy |
| acknowledge volatile write-behind | failover loses accepted work | durable buffer/idempotent sink |
| run repair at maximum | starves user/quorum traffic | bounded repair and failure headroom |

One preventive sentence for reviews:

> When this entry is absent, stale, evicted, invalidated late, filled concurrently or unavailable, the user operation does ___, the origin admits ___, and correctness remains true because ___.

If the team cannot fill those blanks, the cache is not production-ready.

## Memory card and retrieval

Rebuild:

```text
OPERATION -> INVARIANT -> AUTHORITY -> ACCESS PATTERN
          -> ATOMIC SCOPE -> PARTITION/INDEX DISTRIBUTION
          -> CONSISTENCY -> CACHE KEY/REVISION
          -> FILL/INVALIDATE/TTL/EVICT
          -> ORIGIN CAPACITY -> REPAIR -> USER/PRIVACY PROOF
```

Rapid recall:

1. Hit does not mean correct.
2. TTL does not mean invalidation.
3. Eviction does not mean expiry.
4. High cardinality does not rule out a hot key.
5. Replication does not replace repair or backup.
6. Write-behind success is safe only with durable, replayable, reconciled intent.
7. Restore authority before warming copies.

After one day, explain a stale-price incident without notes. After one week, design a different cache key and predict its privacy, hot-key and invalidation failures. Reading completion is not mastery.

## Complete answers

**Why is NoSQL not the opposite of relational?**

The name groups systems that do not center only on the traditional relational model. Their data structures, query languages, indexes, transactions, distribution and guarantees differ. A document database can support transactions; a key/value service can offer conditional writes; a relational store can hold JSON and partition tables. Choose from the exact mechanism and operation, not the label.

**When should a document be embedded?**

Embed bounded data that shares ownership, lifecycle, access and update patterns with the parent. It can make one aggregate read and atomic update straightforward. Reference independently owned, shared, unbounded or separately updated entities. Check maximum/typical document growth, write contention, index cost, partial-update semantics, duplication and deletion.

**What makes a partition key good?**

It routes the required query/invariant, has enough distinct values, spreads requests/bytes/storage under real distributions, avoids unbounded partitions, works with required ordering and deletion, and remains operable during rebalance. Evaluate base and secondary-index keys. There is no universally good key outside an access pattern.

**Why can a table with millions of keys have a hot partition?**

Traffic is not uniform. One celebrity, tenant, timestamp bucket, status value or index key can receive most operations. Physical partitioning and provider adaptation may have finite per-key/partition ceilings. Measure top-key RPS/bytes and throttles.

**Can salting always fix a hot key?**

It distributes independent writes when reads can fan out/aggregate and ordering/invariants tolerate it. It cannot safely split one balance, unique name or last-unit count without a new coordination/allocation design. The repair must preserve correctness, not merely throughput.

**What does cache hit ratio omit?**

Freshness, correctness, tenant/authorization scope, per-key skew, miss cost, fill amplification, stale/negative hits, value size, eviction cause, origin saturation and user impact. Segment it by operation/outcome and correlate with origin and revision.

**Should the database be called on every cache write?**

It depends on the acknowledgement contract. Cache-aside/write-around write authority then invalidate/fill later. Write-through routes through a defined cache layer to authority. Write-behind acknowledges before the sink and therefore requires durable buffering, stable identity, ordering as needed, idempotent sink and reconciliation. Pick from write latency, durability and failure requirements.

**How should TTL be selected?**

From maximum acceptable staleness, change/revocation behavior, origin capacity, key popularity, negative-cache risk, cold-start behavior and cost. Add jitter to avoid synchronized expiry where appropriate. Do not let TTL shorten a business obligation such as idempotency, retention or revocation proof.

**What is the difference between invalidation, expiry and eviction?**

Invalidation reacts to authoritative change. Expiry applies a time rule. Eviction removes data under capacity policy. An entry can be invalidated before TTL, evicted while still fresh, or remain stale until expiry after invalidation is missed. Observe them separately.

**How does request coalescing prevent a stampede?**

For one logical key, one bounded owner performs the origin refresh while concurrent callers await that result or use an approved stale response. Timeouts and errors must release/transfer ownership safely. Conditional/versioned fill prevents an old owner from overwriting a newer revision.

**Should stale data be served during origin failure?**

Only when the operation's invariant and business/security policy permit a bounded age. A product description may be acceptable; an authorization allow, revocation, last inventory unit or safety control may not. Record age/revision, impose a hard stale limit and validate user communication.

**How do you recover after cache loss?**

Prove authoritative state and origin capacity first. Bound admission and retries, coalesce fills, prioritize critical hot keys, use revision-aware population and warm gradually. Prevent old clients/fills from restoring stale entries. Verify user SLI/freshness and do not bulk scan/warm without a measured plan.

**Does persistence make an in-memory cache a database?**

It changes restart durability options but does not automatically supply the data model, consistency, failover, backup, restore, security and operational contract required for authority. Decide the role first, then configure/test persistence and recovery accordingly.

**Why is repair required in some replicated stores?**

Replicas can miss writes during unavailability; hints or normal reads may not cover every range. Anti-entropy repair compares and streams differences. Without timely repair, divergence and tombstone/retention interactions can create loss or resurrection risks. Run product-specific repair within resource and correctness limits.

## Product-company interview

**System design: Build a session store for 20 million users.**

A strong answer first defines session identity, maximum size, read/write rate, TTL/logout/revocation, cross-device behavior, regional routing, consistency, privacy and loss consequence. Exact-key access suggests key/value, but security changes the design: keys bind tenant/user/session, values minimize sensitive data, authentication happens outside key secrecy, logout/revocation has a bounded propagation objective, and fail-open is rejected for protected sessions. Decide whether sessions are disposable/reconstructable or authoritative. If losing an acknowledged session is unacceptable, persistence/replication acknowledgement and recovery must be explicit. Model hot service accounts, mass expiry, memory overhead, eviction policy, cross-region failover and deletion. A strong candidate describes user behavior during store outage rather than saying “Redis with TTL.”

**System design: Design a time-series device store.**

Use the required queries: device/time range, tenant fleet range, latest reading, retention and aggregation. A wide-column partition by tenant/device plus bounded time bucket can fit device-range reads, but calculate worst device rate and partition bytes. Fleet-wide queries need a separate index/aggregate path. Define late/out-of-order events, deduplication, timestamp trust, retention/tombstone behavior, repair and archive. One hot device or tenant can still skew. Do not use event time alone as uniqueness or ordering.

**Troubleshooting: Hit ratio fell after a deployment.**

Check key namespace/version, serialization, tenant dimensions, TTL, process fleet size, cache topology, eviction, value size, route and invalidation behavior. A new key version intentionally causes cold misses; a missing tenant dimension creates security risk; a larger value causes eviction; a shorter TTL causes expiry. Correlate deploy cohort, per-key outcomes, origin amplification and user SLI. Roll back only when the causal and compatibility path is clear.

**Staff follow-up: When would you not cache?**

When work is cheap, reuse is low, freshness must be immediate, invalidation/privacy risk is high, origin capacity already meets objectives, or cache failure complexity outweighs latency/cost benefit. Caching is a state consistency feature, not free performance.

**Staff follow-up: How do you choose MongoDB, Cassandra, DynamoDB, Redis or PostgreSQL?**

Do not choose from brand comparison. Present operation/invariant/access distributions; required atomicity and consistency; key/index/query shapes; scale/failure geography; security/recovery; team and cost. Map each candidate's exact current contract and reject unsupported paths. Often PostgreSQL plus a derived cache/search projection is simplest. A managed service changes who patches servers, not application semantics.

Interview warning signs:

- “NoSQL is eventually consistent.”
- “Redis is single-threaded so it is always fast.”
- “Cassandra has no downtime.”
- “DynamoDB scales automatically, so keys do not matter.”
- “MongoDB is schemaless.”
- “Set a long TTL so hit ratio increases.”
- “Flush cache during inconsistency.”

Each sentence erases an operation or configuration boundary.

## Independent transfer and rubric

`ASM-0162` contains no model answer. The reviewer provides:

- unfamiliar operation and invariant list;
- query/key/value-size and rate distributions;
- one topology and failure history;
- one cache timeline with expiry/invalidation/fill evidence;
- one security/privacy requirement;
- a changed constraint after the first design.

Your packet must include:

1. operation, invariant, acknowledgement and authority table;
2. access-pattern inventory with distributions and growth;
3. minimum-store portfolio and rejected alternatives;
4. partition/index keys, hot-key and atomic-scope analysis;
5. consistency/session and failure contracts;
6. cache key/version, fill/write/invalidation/TTL/stale/negative policy;
7. stampede/origin protection and cold-start plan;
8. memory/throughput/storage/repair/failure-capacity calculations;
9. incident recovery, reconciliation and user/privacy validation;
10. revised ADR after the changed constraint and exact cleanup.

The reviewer scores ten dimensions at ten points each. A strong score requires observable unfamiliar reasoning, not matching product names. The reviewer must see safe handling, refusal of destructive flushes, evidence preservation, exact cleanup and a delayed explanation.

For a changed constraint—“authorization revocation must take effect within five seconds”—revisit cache TTL, push invalidation, policy-version check, disconnected behavior and failure mode. Do not merely lower every TTL: that increases authority load and still may not prove revocation to isolated clients.

For “one product becomes 30% of all traffic,” revisit per-key limits, cache replication, coalescing, origin admission and the write invariant. Table-wide capacity is not the answer.

Repository validation, the offline model and self-scoring remain project evidence only.

## References and review

The fifteen records `REF-0643` through `REF-0657` are stored with this lesson:

- Redis data structures, eviction, client tracking and persistence: `REF-0643`–`REF-0646`;
- HTTP cache semantics and bounded stale controls: `REF-0647`–`REF-0648`;
- MongoDB document modeling, read concern and sharding: `REF-0649`–`REF-0651`;
- Cassandra architecture, guarantees and repair: `REF-0652`–`REF-0654`;
- DynamoDB partition keys/read consistency and DAX cache behavior: `REF-0655`–`REF-0657`.

These sources prove documented behavior only for their stated versions and configurations. They do not prove a running service, managed-provider behavior in one region, application correctness, capacity or recovery.

Before applying product guidance:

1. pin exact server/service and client versions;
2. inspect configuration and topology;
3. verify operation-specific guarantees;
4. test representative keys, values and distributions;
5. test failure/recovery and privacy deletion;
6. record costs/quotas and review dates.

Known limitations:

- the model is ordered Boolean/arithmetic validation, not a stateful cache;
- it has no concurrent histories, network, clock, memory allocator, eviction algorithm or database;
- it does not validate real serialization, query plans, indexes, persistence, failover, repair or security;
- WSL availability determines whether the guarded Ubuntu lifecycle can run;
- formal technical/editorial review, canonical publication, representative runtime, independent reviewer transfer and delayed recall remain required.

The next lesson applies the same ownership/partition/consistency reasoning to queues and streams: brokers add durable ordering positions, consumer groups, backlog, replay and poison-message behavior, but they do not remove duplicate effects or state ownership.
