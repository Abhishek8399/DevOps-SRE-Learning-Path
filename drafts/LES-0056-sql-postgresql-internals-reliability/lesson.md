---
{"schemaVersion":1,"kind":"lesson","id":"LES-0056","slug":"sql-postgresql-internals-reliability","aliases":["V06-L01","sql-postgresql-internals-reliability"],"curriculumIds":["DST-002"],"route":"/book/state/sql-postgresql-internals-reliability","order":1,"volume":"06-state-distributed-systems","title":"SQL and PostgreSQL reliability: follow the transaction, not the dashboard","summary":"Build and operate relational state from data contracts and query plans through MVCC, locks, pools, vacuum, replication, backup, restore and incident response.","domain":"state","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0010","LES-0021"],"prerequisiteCurriculumIds":["LNX-006","AUT-005"],"testedEnvironments":[{"platform":"PostgreSQL documentation","version":"18.4 current documentation reviewed 2026-08-05","support":"concept-only","notes":"SQL, constraints, indexes, EXPLAIN, MVCC, isolation, locks, statistics, connection settings, vacuum, backup and streaming-replication documentation reviewed."},{"platform":"Ubuntu","version":"24.04 normal user with Docker Engine or Docker Desktop integration","support":"required","notes":"Bounded local lab; Docker access is privileged host authority."},{"platform":"PostgreSQL","version":"18.4-bookworm OCI-pinned official image","support":"required","notes":"Ephemeral internal-network database with no published host port or durable volume."}],"targetRoles":["database-reliability-engineer","site-reliability-engineer","platform-engineer","devops-engineer","backend-engineer","cloud-engineer","solutions-architect","technical-lead"],"learningObjectives":["Model relational data with keys, constraints and transaction boundaries that preserve business invariants.","Trace a SQL operation from client pool through parse, plan, execution, MVCC visibility, locks, WAL and response.","Read EXPLAIN ANALYZE evidence without treating estimated cost as milliseconds or running unsafe statements in production.","Distinguish isolation anomalies, blocking, deadlocks and application retry obligations.","Diagnose connection exhaustion, long transactions, lock waits, plan regressions, bloat and replication lag from bounded evidence.","Explain why indexes speed selected reads while increasing write, storage, cache and maintenance cost.","Operate vacuum, autovacuum and statistics as correctness and performance machinery rather than optional cleanup.","Separate high availability, replication, backup, point-in-time recovery and verified restore.","Design least-privilege database access, protected credentials, encrypted transport and auditable changes.","Build user-centered database SLIs, capacity models, incident mitigations and recovery proof."],"productionSignals":["user operation success latency correctness freshness and idempotency outcome","database name role application_name client address backend PID transaction state and query fingerprint","query calls rows total mean and tail latency blocks read hit dirtied and written WAL bytes and temporary bytes","EXPLAIN estimated rows actual rows loops node timing buffers WAL and sort spill","active idle idle-in-transaction waiting state wait_event_type wait_event and transaction age","blocking PID blocked PID lock type mode relation transaction ID virtual transaction and granted state","deadlocks lock timeouts statement timeouts canceled statements and application retry outcomes","connection pool active idle waiting maximum timeout churn and database max reserved slots","table live tuples dead tuples modifications vacuum analyze timestamps and wraparound age","index size scans tuples read tuples fetched uniqueness validity and write amplification","checkpoint WAL generation archiving replay location replay lag replica state and replication slot retention","backup start end integrity retention restore elapsed time recovery target and business reconciliation","CPU memory filesystem IOPS latency cache ratio network RTT and cgroup or VM limits","schema migration version lock duration rollout state compatibility and rollback decision","error budget capacity headroom cost per transaction storage growth and recovery reserve"],"diagrams":[{"id":"LES-0056-DIA-001","title":"Relational request and state path","direction":"left-to-right","boundaries":["client","connection pool","PostgreSQL backend","planner and executor","buffer cache and files","WAL and replica","response"],"evidencePoints":["request ID","pool wait","backend PID","plan node","buffers","LSN","transaction result"],"textAlternative":"A client operation waits for a pooled connection, runs in one PostgreSQL backend through planner and executor, reads or changes pages, records WAL, may stream to a replica, then commits or aborts before the user result."},{"id":"LES-0056-DIA-002","title":"Transaction state machine","direction":"cyclic","boundaries":["begin","read and write","lock and visibility","commit WAL flush","abort","application retry"],"evidencePoints":["transaction ID","snapshot","wait event","SQLSTATE","commit LSN","idempotency key"],"textAlternative":"A transaction begins, observes a snapshot, reads and writes under locks, then commits durable intent or aborts; only the application can decide whether and how an aborted unit is safe to retry."},{"id":"LES-0056-DIA-003","title":"Plan evidence ladder","direction":"top-to-bottom","boundaries":["SQL and parameters","statistics","candidate paths","estimated plan","actual execution","user outcome"],"evidencePoints":["fingerprint","estimated rows","node type","actual rows and loops","buffers and WAL","latency and correctness"],"textAlternative":"SQL shape and parameters meet statistics; the planner estimates candidate paths, the executor produces actual rows and resource evidence, and the user outcome determines whether the query is acceptable."},{"id":"LES-0056-DIA-004","title":"MVCC tuple lifetime","direction":"left-to-right","boundaries":["inserted version","visible snapshots","updated or deleted version","dead tuple","vacuum reclaim","freeze"],"evidencePoints":["xmin","xmax","transaction age","dead tuples","vacuum progress","relfrozenxid age"],"textAlternative":"Updates create new tuple versions while old snapshots can retain older versions; dead versions become reclaimable only after visibility rules permit vacuum, and freezing prevents transaction-ID wraparound."},{"id":"LES-0056-DIA-005","title":"Protection and recovery chain","direction":"left-to-right","boundaries":["primary state","WAL","standby","backup and archive","isolated restore","business validation"],"evidencePoints":["commit LSN","flush LSN","replay LSN","recovery point","timeline","RPO and RTO"],"textAlternative":"Primary commits create WAL that can feed standbys and archived recovery; none proves recoverability until an isolated restore reaches a chosen point and the business invariant is validated."},{"id":"LES-0056-DIA-006","title":"Database failure-domain ladder","direction":"hierarchical","boundaries":["statement","transaction","backend","instance","storage","zone or region","application dependency"],"evidencePoints":["timeout","rollback","process state","readiness","integrity","failover","user SLI"],"textAlternative":"Failures widen from one statement through transaction, backend, database instance, storage and location to the application dependency; each scope needs different evidence and recovery."}],"commands":[{"id":"LES-0056-CMD-001","question":"Is this Ubuntu host safe and ready for the bounded lab?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0056 support/lab as a normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"declared local prerequisites and image pin are present","nextEvidence":"inspect Compose then setup"},{"when":"lab=fail","meaning":"the named prerequisite or safety boundary failed","nextEvidence":"fix that boundary without bypassing the guard"}],"proves":"local prerequisite and guard checks","doesNotProve":"container startup or database behavior"},{"id":"LES-0056-CMD-002","question":"Can the disposable database initialize without a host port?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0056 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one exact Compose project is healthy with seeded rows","nextEvidence":"status and plan"},{"when":"nonzero","meaning":"initialization or safety check failed","nextEvidence":"preserve first error then run guarded cleanup if setup reached container creation"}],"proves":"this disposable initialization","doesNotProve":"durable production deployment","cleanup":"Run bash lab.sh cleanup after successful setup."},{"id":"LES-0056-CMD-003","question":"What server, row and connection state exists now?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0056 support/lab after setup","expectedBranches":[{"when":"version and orders print","meaning":"bounded database responds","nextEvidence":"bind later findings to this instance"},{"when":"refusal","meaning":"state or readiness differs","nextEvidence":"inspect named guard or container state"}],"proves":"sampled server identity row count and session count","doesNotProve":"correctness or performance"},{"id":"LES-0056-CMD-004","question":"How does PostgreSQL execute the unindexed lookup?","risk":"sampled-read-only","command":"bash lab.sh plan-before","runFrom":"LES-0056 support/lab after setup","expectedBranches":[{"when":"Seq Scan appears","meaning":"executor scans table pages for this fixture","nextEvidence":"compare estimated and actual rows, loops and buffers"},{"when":"another node appears","meaning":"environment or state differs","nextEvidence":"inspect indexes statistics and parameters"}],"proves":"one actual SELECT plan on disposable data","doesNotProve":"production plan stability"},{"id":"LES-0056-CMD-005","question":"What changes when a fitting composite index is added?","risk":"mutating-bounded","command":"bash lab.sh add-index","runFrom":"LES-0056 support/lab after plan-before","expectedBranches":[{"when":"index=pass","meaning":"index exists and statistics refreshed","nextEvidence":"plan-after"},{"when":"nonzero","meaning":"DDL or analysis failed","nextEvidence":"inspect transaction and server error"}],"proves":"bounded schema mutation","doesNotProve":"net production benefit","cleanup":"Ephemeral database disappears during lab cleanup."},{"id":"LES-0056-CMD-006","question":"Does the actual lookup use the new index?","risk":"sampled-read-only","command":"bash lab.sh plan-after","runFrom":"LES-0056 support/lab after add-index","expectedBranches":[{"when":"index node appears","meaning":"planner selected an index path for this dataset","nextEvidence":"compare rows buffers timing and write trade-off"},{"when":"Seq Scan remains","meaning":"planner still estimates scan cheaper","nextEvidence":"inspect selectivity statistics ordering and cost inputs"}],"proves":"one post-index actual plan","doesNotProve":"all parameter values or workload benefit"},{"id":"LES-0056-CMD-007","question":"What does a bounded row-lock wait look like?","risk":"destructive-disposable","command":"bash lab.sh lock-wait","runFrom":"LES-0056 support/lab only","expectedBranches":[{"when":"waiter_timeout=true","meaning":"one waiter was bounded and holder committed","nextEvidence":"map blocker and application timeout policy"},{"when":"failure","meaning":"expected contention evidence was absent","nextEvidence":"preserve outputs and inspect transaction timing"}],"proves":"synthetic lock timeout behavior","doesNotProve":"production blocker cause","cleanup":"Generated lock evidence and the ephemeral database are removed by the guarded lab cleanup."},{"id":"LES-0056-CMD-008","question":"How does PostgreSQL break a deadlock cycle?","risk":"destructive-disposable","command":"bash lab.sh deadlock","runFrom":"LES-0056 support/lab only","expectedBranches":[{"when":"victim_count=1","meaning":"server aborted one transaction and the other committed","nextEvidence":"design ordered access and whole-transaction retry"},{"when":"failure","meaning":"cycle or expected evidence differed","nextEvidence":"inspect both session outputs"}],"proves":"synthetic deadlock detection","doesNotProve":"application retry correctness","cleanup":"Generated deadlock evidence and the ephemeral database are removed by the guarded lab cleanup."},{"id":"LES-0056-CMD-009","question":"What happens when ordinary connection slots are consumed?","risk":"destructive-disposable","command":"bash lab.sh connections","runFrom":"LES-0056 support/lab only","expectedBranches":[{"when":"normal_slots_exhausted=true","meaning":"ordinary sessions were rejected while admin reserve remained","nextEvidence":"relate pool budgets to database slots"},{"when":"failure","meaning":"concurrency or slot evidence differed","nextEvidence":"inspect session files and settings"}],"proves":"bounded connection-limit behavior","doesNotProve":"a production pool size","cleanup":"Generated connection evidence and the ephemeral database are removed by the guarded lab cleanup."},{"id":"LES-0056-CMD-010","question":"Can a logical backup restore into an isolated database and pass a business check?","risk":"destructive-disposable","command":"bash lab.sh backup-restore","runFrom":"LES-0056 support/lab only","expectedBranches":[{"when":"business_validation=true","meaning":"custom-format dump restored and expected counts match","nextEvidence":"retain limits and design PITR separately"},{"when":"failure","meaning":"dump restore or validation failed","nextEvidence":"preserve first error and investigate without overwriting source"}],"proves":"one logical restore of this fixture","doesNotProve":"PITR, production scale, complete invariants or RTO","cleanup":"The restored database is dropped by the command and the dump is removed by guarded lab cleanup."},{"id":"LES-0056-CMD-011","question":"Does the full lifecycle, refusal and cleanup contract pass?","risk":"destructive-disposable","command":"bash verify.sh","runFrom":"LES-0056 support/lab from an absent state","expectedBranches":[{"when":"verify=pass","meaning":"all bounded cases and final absence passed","nextEvidence":"record environment and limitations"},{"when":"nonzero","meaning":"candidate lab rejected","nextEvidence":"preserve first failure and state before recovery"}],"proves":"this exact local teaching lifecycle","doesNotProve":"production reliability or learner mastery","cleanup":"Verifier proves exact project and UID-scoped state absence."},{"id":"LES-0056-CMD-012","question":"Can every lab resource and generated artifact be removed exactly?","risk":"destructive-disposable","command":"bash lab.sh cleanup","runFrom":"LES-0056 support/lab after successful setup","expectedBranches":[{"when":"cleanup=pass","meaning":"exact Compose resources and state are absent","nextEvidence":"confirm no matching container remains"},{"when":"refusal","meaning":"guard detected unsafe or unexpected state","nextEvidence":"inspect without broad deletion"}],"proves":"guarded cleanup for the known lab shape","doesNotProve":"unrelated Docker cleanup","cleanup":"No wildcard or global Docker prune is used."}],"labs":[{"id":"LES-0056-LAB-001","title":"Guided PostgreSQL plan, contention, capacity and restore evidence","mode":"guided","environment":"Ubuntu 24.04 normal user, Docker Engine or Docker Desktop integration, Compose v2, locally available pinned PostgreSQL image","timeMinutes":240,"privilege":"normal user with Docker access; root refused; Docker access is host-privileged","network":"internal Compose network only after the exact image is locally available; no host port","changes":["one exact UID-scoped Compose project","one generated password under an exact temporary root","one ephemeral PostgreSQL data directory on tmpfs","synthetic plan lock deadlock connection and restore artifacts"],"abortConditions":["root execution","database or cloud credential environment variables","unpinned or unavailable image","published host port","symlink or wrong-owned state","unknown state artifact","non-disposable data"],"recovery":"Preserve the first failing output. Use the exact guarded cleanup only after the state passes ownership, sentinel and inventory checks; never use Docker system prune.","cleanupProof":"Exact Compose project has no containers or volumes and the exact UID-scoped temporary root is absent.","path":"drafts/LES-0056-sql-postgresql-internals-reliability/support/lab"},{"id":"LES-0056-LAB-002","title":"Independent relational production-readiness review","mode":"independent","environment":"Reviewer-owned sanitized schema, query samples, plan captures, workload envelope and recovery packet; no production connection","timeMinutes":240,"privilege":"normal user; read-only local artifacts","network":"none","changes":["local architecture diagram","query and transaction evidence table","capacity and recovery calculations","review notes"],"abortConditions":["production credential","live database endpoint","customer data","unapproved schema mutation","EXPLAIN ANALYZE on mutating SQL","restore over source","destructive command"],"recovery":"Discard reviewer-owned local artifacts after scored evidence is preserved.","cleanupProof":"Reviewer confirms no credential, connection, database process or external resource was created.","path":"drafts/LES-0056-sql-postgresql-internals-reliability/support/lab"}],"incidents":[{"id":"LES-0056-INC-001","signal":"Checkout p99 rises after a release while CPU is moderate and the database is healthy.","firstThought":"Healthy instance metrics do not clear the database path; a query shape, parameter distribution, plan, pool wait, lock or downstream transaction boundary may have changed.","safePath":"Bind one operation to release, query fingerprint, pool wait, backend PID, wait event, plan and transaction outcome; mitigate the confirmed cohort and verify the user SLI.","trap":"Restart PostgreSQL or add an index from a single slow-query log line."},{"id":"LES-0056-INC-002","signal":"Sessions accumulate and many show active or idle in transaction.","firstThought":"The database may be waiting on application-held transactions, locks or pool behavior rather than lacking CPU.","safePath":"Measure connection states and ages, map blocked to blocker, protect new work with bounded timeouts, stop the harmful application cohort safely, then correct transaction scope.","trap":"Increase max_connections until memory or scheduler pressure causes a wider outage."},{"id":"LES-0056-INC-003","signal":"A deployment triggers deadlocks and duplicate order attempts.","firstThought":"Concurrent transactions acquire shared resources in inconsistent order, and retry behavior may not be idempotent.","safePath":"Capture the deadlock graph and SQLSTATE, roll back the full victim transaction, enforce stable lock ordering, retry with a budget using an idempotency key, and verify one business effect.","trap":"Retry only the failed statement in the same aborted transaction."},{"id":"LES-0056-INC-004","signal":"Disk grows quickly while tables have many dead tuples and a replication slot lags.","firstThought":"Long snapshots, ineffective vacuum, write churn or retained WAL may be preventing reclamation; deleting rows may increase short-term work.","safePath":"Separate heap and WAL growth, find old transactions and slot consumers, preserve required recovery, repair the blocking owner, tune and validate vacuum, then measure reclaimable versus returned space.","trap":"Disable autovacuum, delete more rows or remove a slot without confirming recovery ownership."},{"id":"LES-0056-INC-005","signal":"Primary failover completes but users see stale reads, timeouts and uncertain writes.","firstThought":"Infrastructure role change is not transaction recovery; clients, DNS, pools, replay position, timelines and ambiguous commits need reconciliation.","safePath":"Fence the old writer, establish authoritative timeline and endpoint, drain stale pools, reconcile ambiguous operations by idempotency identity, measure freshness, and verify new writes plus restores.","trap":"Promote another node repeatedly or replay every timed-out request blindly."}],"assessmentIds":["ASM-0151","ASM-0152","ASM-0153"],"referenceIds":["REF-0598","REF-0599","REF-0600","REF-0601","REF-0602","REF-0603","REF-0604","REF-0605","REF-0606","REF-0607","REF-0608","REF-0609","REF-0610","REF-0611","REF-0612"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The lab is disposable and has no durable storage, host port, TLS, external clients, pooler, standby, archive, failover or production traffic.","One hundred thousand synthetic rows cannot represent production distributions, concurrency, hardware, cache state or data volume.","A logical dump and count check do not prove physical backup, point-in-time recovery, every business invariant or a production RTO.","Docker access is privileged host authority and the lab must be inspected and run only on an approved local system.","PostgreSQL behavior, defaults and observability fields are version-dependent; verify against the deployed version.","Formal review, publication, reviewer-scored transfer, delayed recall and learner evidence remain required."]}
---
# SQL and PostgreSQL reliability: follow the transaction, not the dashboard

## What you see and first thought

A service says database timeout. Your first job is not to fix PostgreSQL. Your first job is to name the failed operation.

Ask which user operation, request ID, application version, database, role, query shape, parameter class, transaction and time window are involved. A timeout may be time spent waiting for a pool connection, a network handshake, a row lock, storage, CPU, a replica to catch up, or the application itself. The final error says where patience ended, not where delay began.

Keep this sentence in memory:

> Follow one transaction from caller to durable outcome. A green database dashboard is not proof that the transaction succeeded, and a slow statement is not proof that the database is the cause.

A relational database is a concurrency and durability system. It accepts operations at the same time, decides what each transaction may see, protects invariants, orders conflicting work, persists a recovery history, and returns a result whose meaning the application must understand.

Use FRAME:

1. Frame one failed operation and its correctness contract.
2. Restrict scope by cohort, release, query fingerprint, role, database, instance and time.
3. Acquire evidence from the client, pool, PostgreSQL and operating system.
4. Mitigate the earliest confirmed harmful boundary with a reversible action.
5. Evaluate a fresh user operation, backlog, saturation and business invariant.

Do not start with kill, restart, failover, VACUUM FULL, a new index, a larger instance or a higher connection limit. Each can turn a narrow symptom into blocking, data loss, capacity collapse or a longer recovery.

## Terms before commands

**SQL** is a declarative language: you describe the result or state change, not an exact loop over bytes. PostgreSQL parses the statement, rewrites it where applicable, plans candidate access paths and executes a chosen plan.

A **relation** is the formal idea behind a table-like set of tuples. A **row** or tuple represents one record. A **column** has a type and meaning. A **schema** is both a namespace in PostgreSQL and, more broadly, the data contract made from tables, types, constraints, indexes and relationships.

A **primary key** uniquely identifies a row and cannot be null. A **foreign key** requires a referenced value to exist, subject to its action rules. A **unique constraint** prevents duplicate key values under PostgreSQL's null semantics. A **check constraint** requires a Boolean rule for new or changed rows. Constraints are executable business boundaries: they defend data even when two application instances race.

An **index** is a separate access structure that maps selected key values toward table rows. It can avoid examining most table pages, preserve useful ordering, or enforce uniqueness. It consumes storage and cache, and every relevant insert, update and delete must maintain it. Add an index is therefore a workload trade, not free speed.

A **transaction** is an all-or-nothing unit of database work. COMMIT makes its changes successful as a unit; ROLLBACK abandons them. Atomic does not mean the client always knows the result: a connection can disappear after commit but before the acknowledgement arrives. That is an **ambiguous commit**, and the application needs an operation identity or idempotency design to reconcile it.

**Isolation** controls how concurrent transactions' effects become observable. PostgreSQL implements isolation with **multiversion concurrency control (MVCC)**: readers usually see a snapshot of row versions instead of blocking every writer. MVCC reduces read/write blocking; it does not remove locks, anomalies, retries or cleanup.

A **snapshot** describes which transactions and tuple versions are visible to a statement or transaction. A tuple carries transaction visibility information commonly discussed through xmin and xmax. Those are database-internal transaction identifiers, not business timestamps.

A **lock** protects a resource or coordinates conflicting operations. A **blocker** owns a lock another session needs. The second session is blocked or waiting. A **deadlock** is a cycle: transaction A waits for B while B, directly or indirectly, waits for A. PostgreSQL detects a cycle and aborts one victim; the application must roll back and may retry the complete unit if safe.

The **planner** estimates row counts and costs from statistics. The **executor** runs plan nodes. EXPLAIN shows estimates without executing the statement. EXPLAIN ANALYZE actually runs it and adds measured evidence. On INSERT, UPDATE or DELETE, that means real mutation unless you deliberately wrap and roll back a safe disposable test.

A **sequential scan** reads table pages to test rows. An **index scan** follows an index and visits matching heap tuples. An **index-only scan** can answer from the index when it contains needed values and the visibility map permits avoiding heap checks. A **bitmap scan** gathers matching locations before visiting heap pages. The cheapest node depends on selectivity, ordering, cache, statistics and cost assumptions; sequential scans are not inherently bad.

The **buffer cache** is PostgreSQL-managed shared memory containing database pages. The operating system also caches files. A cache hit avoids a database file read request at that layer, but is not automatically a fast query.

The **write-ahead log (WAL)** records changes needed for crash recovery before changed data pages must reach their final files. A **log sequence number (LSN)** names a WAL position. WAL supports crash recovery, physical replication and point-in-time recovery. WAL is not a substitute for a verified backup.

**Vacuum** makes dead tuple space reusable after no required snapshot can see those versions. It also maintains visibility information and helps prevent transaction-ID wraparound. Ordinary vacuum normally returns reusable space to the table, not immediately to the filesystem. VACUUM FULL rewrites and takes a strong lock; it is not routine incident cleanup.

A **connection** maps to a PostgreSQL server process in the common process model. It consumes memory and scheduling capacity even when little useful work happens. A **connection pool** reuses a bounded set of database connections. PgBouncer can pool by session, transaction or statement; compatibility changes as state is allowed to outlive shorter pool assignments.

A **standby** replays WAL from a primary. Streaming replication is asynchronous by default, so a commit can be acknowledged before a standby has replayed it. Synchronous configuration can strengthen acknowledgment rules at a latency and availability cost. Replication copies good changes, bad changes and many forms of operator error; it is availability machinery, not historical recovery by itself.

**RPO** is the maximum tolerable data loss measured in time or business units. **RTO** is the maximum tolerable time to restore the required operation. Both need business meaning and measured restore evidence.

## Architecture map

Start with the path rather than the product logo:

    customer request
        |
        v
    application worker -- request_id / operation_id / transaction boundary
        |
        v
    connection pool -- waiters / active / idle / timeout / maximum
        |
        v
    PostgreSQL backend -- PID / role / database / state / wait event
        |
        +--> parser -> rewriter -> planner -> executor
        |                            |
        |                            +--> table and index pages
        |                            +--> locks and MVCC snapshot
        |
        +--> WAL buffers -> WAL files -> archive / standby replay
        |
        v
    COMMIT or ROLLBACK -> application acknowledgement -> user outcome

Text equivalent for LES-0056-DIA-001: one operation may wait before it reaches PostgreSQL, then one backend plans and executes under MVCC and locks, records durable intent in WAL, commits or aborts, and returns through the application. Evidence must join these boundaries.

Separate three planes:

    control: roles, parameters, schema migration, backup policy, failover decision
    data:    SQL sessions, transactions, pages, indexes, locks, WAL, replicas
    proof:   request traces, query statistics, plans, wait events, logs, restore results

Control-plane success does not prove data-plane usefulness. A promoted standby is not recovered until clients reach the authoritative writer and complete correct transactions. A migration tool reporting success does not prove old and new application versions remain compatible.

The protection path differs from the serving path:

    primary commit LSN -> WAL stream -> standby replay LSN
            |
            +-> archived WAL + base backup -> isolated recovery -> validation
            |
            +-> logical dump -------------> new database ------> validation

Text equivalent for LES-0056-DIA-005: a standby reduces some outage durations; archived WAL and backups create recovery choices; only isolated restore and business validation measure recoverability.

## Request or state path

Trace POST /orders rather than the database:

1. The caller supplies an authenticated customer context, an operation or idempotency key and an explicit deadline.
2. The application validates the request and asks its pool for a connection. Record pool wait separately from SQL execution.
3. The connection authenticates as a narrow database role and selects the intended database. TLS and server identity belong here in real deployments.
4. The application begins a transaction only when it is ready to perform the unit. Long network calls must not casually sit inside the transaction.
5. It checks or inserts the idempotency key under a unique constraint. A prior successful operation returns the recorded result; a conflicting in-progress operation follows an explicit policy.
6. It locks or conditionally updates required rows in a stable order.
7. PostgreSQL parses SQL, chooses a plan from indexes and statistics, obtains required locks, evaluates visibility and creates new tuple versions.
8. Constraint checks protect valid references, positive amounts, uniqueness and other invariants.
9. WAL describes the changes. At commit, configured durability rules determine what must be flushed or acknowledged.
10. PostgreSQL releases transaction locks and returns commit success. The application records the outcome without logging credentials or sensitive payload.
11. If the connection breaks near commit, the application does not blindly repeat the side effect. It queries by operation identity and reconciles.
12. The user SLI observes success, latency and correctness; database metrics explain the path but do not replace that outcome.

State changes also have deployment compatibility:

    expand schema -> deploy code that tolerates old and new -> backfill in bounded batches
                  -> verify invariants -> switch reads/writes -> contract obsolete schema

This **expand-and-contract** pattern avoids requiring every application replica and every row to change at one instant. A safe migration estimates lock level and duration, validates on representative data, sets a bounded lock timeout, has a cancellation and recovery path, and separates schema compatibility from data correctness.

## Failure zoom

Widen scope one boundary at a time:

    one statement -> one transaction -> one backend -> one pool
                  -> one instance -> storage -> standby/failover
                  -> application dependency -> user journey

Text equivalent for LES-0056-DIA-006: each wider boundary needs distinct evidence. A statement timeout normally cancels one statement. A deadlock aborts one transaction. A backend crash can end one connection. Instance recovery affects every session. Storage or location failure can require failover or restore. The user only cares whether the complete operation remains correct.

| Symptom | Possible first boundary | Evidence that separates it |
|---|---|---|
| request timeout | pool wait | pool queue and acquisition duration |
| SQL active for a long time | executor work | plan nodes, actual rows, buffers, CPU, I/O |
| SQL active but waiting | lock or resource | wait event, blocker graph |
| many rejected connections | slot exhaustion | pool totals, session states, limits |
| stale success response | replica replay lag | endpoint, commit/replay LSN, freshness SLI |

A timeout is a budget, not a cure. Use an end-to-end deadline and allocate less time to each downstream step so cancellation can propagate before the caller gives up. PostgreSQL's statement, lock and idle-in-transaction timeouts protect different boundaries. A global value safe for a web query may break a migration or restore.

## Internals and state ownership

PostgreSQL commonly uses a supervisor process and a separate backend process per client connection, plus background workers such as checkpointer, WAL writer, autovacuum workers and replication processes. Therefore thousands of mostly idle application connections are not free. Each adds process, memory and scheduler costs, and active queries contend for CPU, cache, locks and I/O.

When SQL arrives, parse analysis resolves names and types. The rewriter applies rules and views. The planner creates candidate strategies and estimates cost. Cost units compare alternatives inside the planner; they are not milliseconds. Estimates depend on table statistics. The executor then runs a tree of nodes. A parent repeatedly asks children for tuples, so actual rows must be read with loops; work can be approximately rows times loops.

An index lookup is powerful when the predicate selects a useful fraction of rows and matches leading key order. For (customer_id, created_at DESC), PostgreSQL can find one customer and produce newest-first order. Included payload columns can support index-only access. But every order write now updates more index data, WAL grows, cache space changes, vacuum maintains more structures, and low-selectivity queries may still scan.

MVCC avoids logically overwriting a row version in place. An update creates a new visible version and marks the old version as ended by a transaction. Different snapshots can legally see different versions. A transaction left open can retain an old snapshot, preventing vacuum from reclaiming dead versions. Idle in transaction is dangerous because it can hold locks and visibility horizons while doing no useful database work.

PostgreSQL's default Read Committed gives each statement a new snapshot. Two statements in one transaction can observe different committed worlds. Repeatable Read gives a stable transaction snapshot in PostgreSQL, but concurrent writes can still force failure. Serializable detects dangerous dependency patterns and aborts a participant so committed results are equivalent to serial ordering. Stronger isolation transfers work to retry handling; it does not make external side effects transactional.

Locks exist at several scopes. Row changes acquire row-level locks and table-level modes that coexist with many readers. DDL often needs stronger table locks. Advisory locks are application-defined coordination keys and work only when every participant follows the contract. Inspect blockers before termination: the visible waiter may be protecting the system while one old transaction is the real owner.

Deadlock detection resolves a cycle by aborting a victim. Prevention uses stable resource order, short transactions and fewer unnecessary locks. Recovery rolls back the whole failed transaction and retries from a clean boundary only when the business operation is idempotent. After an error in a transaction, subsequent statements normally receive an aborted-transaction error until rollback.

WAL separates commit durability from later data-page writes. Checkpoints bound crash-recovery work by ensuring older dirty pages reach storage, but aggressive checkpoints can create I/O bursts. WAL volume depends on writes, indexes, full-page images, settings and workload. Replication slots can retain required WAL; an abandoned slot can fill storage.

Autovacuum responds to changed-row thresholds and cost settings, with special urgency for transaction-ID wraparound. It makes dead tuple space reusable when visibility permits, updates visibility information and can analyze statistics. It may fall behind on large or heavily updated tables because thresholds, workers, I/O limits, long snapshots or lock conflicts do not match workload reality. Tune from measured table behavior, not by disabling it.

Ordinary VACUUM generally leaves a relation file at its high-water size while making pages reusable. Future writes can reuse it. Reclaiming filesystem space can require a rewrite with lock, I/O, WAL, temporary-space and replication effects. First distinguish reusable space inside the relation, filesystem free space, WAL retention and long-term capacity.

The application owns transaction boundaries, idempotency, pool budgets, cancellation, query shapes, parameter distributions, compatible migrations, retry rules, ambiguous-commit reconciliation and user SLIs.

The database platform owns supported versions, parameter baselines, capacity, storage, WAL, backup, restore, role and network guardrails, vacuum, statistics, replication, failover fencing and operational evidence.

Managed database moves selected host, storage and control-plane duties. It does not take ownership of schema design, workload, transactions, connection storms, restore validation or user correctness.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| database is reachable | endpoint, TLS identity, authentication, database, role | query is authorized or fast |
| query is slow | fingerprint, parameter class, measured duration, rows | database is root cause |
| plan is wrong | estimated versus actual rows, node work, buffers | one index is the right fix |
| index helps | before/after plan and workload read/write evidence | benefit across every parameter |
| session is blocked | backend PID, wait event, blocker ownership | blocker is safe to terminate |
| deadlock occurred | deadlock graph or SQLSTATE 40P01 | retry is safe |
| connections exhausted | pool queue, states, limits, roles, memory | raising limit is safe |
| vacuum is behind | dead tuples, transaction horizon, history, rate | VACUUM FULL is needed |
| replica is healthy | sender/receiver and LSN lag | read freshness or safe promotion |
| backup completed | artifact, timestamps, retention, integrity | restore works or meets RTO |
| restore completed | isolated instance, recovery point, DB checks | business operation is correct |
| failover completed | fenced old writer, timeline, endpoint | ambiguous writes reconciled |
| incident recovered | fresh transaction, latency, stable backlog | prevention is complete |

Evidence has scope. pg_stat_activity is a current view, not full history. pg_stat_statements aggregates normalized statement shapes when enabled, but parameter skew can hide inside one fingerprint. Logs show configured events, not everything. Plans measured on a warm disposable database do not predict cold production storage.

## Command decoders

Start with identity and session evidence:

    SELECT version(), current_database(), current_user;
    SELECT pid, usename, application_name, client_addr, state,
           wait_event_type, wait_event, xact_start, query_start,
           left(query, 120) AS query_sample
    FROM pg_stat_activity
    WHERE datname = current_database()
    ORDER BY xact_start NULLS LAST, query_start NULLS LAST;

pid joins session evidence and supports targeted cancellation after review. Active means a backend is executing or waiting inside a query. Idle in transaction means the transaction remains open between statements. wait_event_type tells whether and where a backend waits; active does not necessarily mean CPU.

Find blocked sessions:

    SELECT blocked.pid AS blocked_pid, blocker.pid AS blocker_pid,
           blocked.wait_event_type, blocked.wait_event,
           age(clock_timestamp(), blocker.xact_start) AS blocker_xact_age,
           left(blocked.query, 100) AS blocked_query,
           left(blocker.query, 100) AS blocker_query
    FROM pg_stat_activity AS blocked
    CROSS JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS b(pid)
    JOIN pg_stat_activity AS blocker ON blocker.pid = b.pid;

The result proves a sampled blocking relation, not who is at fault. Before cancellation or termination, identify owner, transaction semantics, rollback cost, failover role and retry behavior. Canceling a statement may be enough; terminating a session rolls back its open transaction.

Decode a plan:

    EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, FORMAT TEXT)
    SELECT order_id, status, total_cents
    FROM orders
    WHERE customer_id = 4242
    ORDER BY created_at DESC
    LIMIT 20;

- cost is a planner comparison unit, not milliseconds.
- rows before execution is an estimate at that node.
- actual time, rows and loops are measured because ANALYZE executed the statement.
- shared hit means pages found in PostgreSQL shared buffers; read means file reads were requested.
- WAL reports write-ahead-log work for mutating plans.
- sort method and disk use expose spills.
- planning and execution time omit pool wait and much application/network time.

Never run EXPLAIN ANALYZE on a modifying statement in production expecting a harmless plan. Use plain EXPLAIN, a safe replica where semantics permit, or a reviewed rollback in an isolated environment.

Inspect maintenance:

    SELECT relname, n_live_tup, n_dead_tup, n_mod_since_analyze,
           last_autovacuum, last_autoanalyze,
           vacuum_count, autovacuum_count
    FROM pg_stat_user_tables
    ORDER BY n_dead_tup DESC;

These are estimates and counters. Combine them with transaction age, workload rate, relation size, autovacuum logs or progress and storage trends.

Inspect replication:

    SELECT application_name, state, sync_state,
           sent_lsn, write_lsn, flush_lsn, replay_lsn,
           pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS byte_lag
    FROM pg_stat_replication;

Byte lag is not directly seconds, data loss or user staleness. Write rate varies. A connected standby may be far behind, and a zero-byte sample does not prove promotion readiness or client routing.

Inspect connection budgets:

    SHOW max_connections;
    SHOW reserved_connections;
    SELECT usename, state, count(*)
    FROM pg_stat_activity
    GROUP BY usename, state
    ORDER BY count(*) DESC;

PostgreSQL 18 reserved_connections protects slots for roles with the corresponding privilege after ordinary slots are consumed; superuser-reserved slots are a further boundary. Version-check the field.

    database usable slots
    - operator and migration reserve
    - replication and platform needs
    - other services
    = budget for this service

    service budget / maximum live application replicas
    = upper bound per replica, with headroom

Transaction-pooling PgBouncer can reduce server-session demand but breaks assumptions that rely on session-local state. Prepared statements, temporary tables, SET behavior, advisory locks and listen/notify need compatibility review for the chosen mode and version.

## Decision path

When a database-backed operation is slow or failing, walk this order. It prevents random tuning:

1. **Prove the user symptom.** Is it failure, latency, staleness, duplicate effect or unavailable capacity? Name the SLI and affected cohort.
2. **Split application time.** Separate queueing, pool acquisition, network, server execution and response processing. If pool wait consumes 900 ms and SQL takes 8 ms, query tuning is the wrong first move.
3. **Bind database identity.** Record environment, endpoint, database, role, application name, server version and topology. Avoid executing on the wrong writer or replica.
4. **Classify session state.** Is the backend running, waiting, idle, idle in transaction, missing, or already canceled?
5. **If waiting, identify the owner.** Build the blocker graph and resource type. Do not treat the waiter as the cause.
6. **If running, inspect workload and plan.** Use a normalized fingerprint, representative parameter class, calls, rows, actual plan and resource evidence.
7. **Check change correlation.** Application release, migration, statistics refresh, parameter change, failover, pool rollout, traffic shape and data growth are separate change streams.
8. **Check saturation.** CPU run queue, memory pressure, storage latency and throughput, filesystem capacity, WAL, checkpoints, pool queue, connections and replication retention can interact.
9. **Choose the smallest reversible mitigation.** Pause a bad rollout, reduce concurrency, cancel one reviewed statement, route reads deliberately, add a timeout, or apply a reviewed index. Write the rollback condition first.
10. **Verify the complete operation.** Confirm fresh correctness and latency, draining waiters, stable resource headroom, no unintended data effects and no growing recovery debt.

### Index decision

Do not begin with the index name. Begin with the access contract:

- Which query fingerprints and parameter distributions matter?
- Which predicates are equality, range or expressions?
- Which ordering and limit are required?
- How many rows are returned and how selective is the prefix?
- What are the insert, update and delete rates?
- Which existing index overlaps?
- What storage, WAL, cache and build-time headroom exists?
- Can index creation block or saturate the system?
- How will you compare before and after at workload level?
- How will you remove the index if it harms writes?

A B-tree is the default fit for equality, ordering and range behavior across orderable types. Hash, GiST, SP-GiST, GIN and BRIN serve different data and access patterns. Partial indexes cover rows satisfying a predicate. Expression indexes store computed keys. Multicolumn order matters. Do not memorize them as a shopping list; match operator, distribution and workload.

### Isolation decision

Choose the weakest isolation level that preserves the actual invariant with a design you can explain and test:

| Need | Candidate design | Operational obligation |
|---|---|---|
| each statement sees committed data | Read Committed | re-check assumptions across statements |
| stable snapshot for a read workflow | Repeatable Read | handle serialization-style write conflicts |
| database transactions equivalent to serial order | Serializable | retry complete transactions with bounded backoff |
| claim work without double processing | row lock or atomic state transition | lease expiry, ordering and crash recovery |
| exactly one business effect after network uncertainty | unique operation key plus result record | reconcile ambiguous commit |

Exactly-once delivery is usually the wrong phrase. Ask for exactly one **business effect** under a named scope. A message may be delivered twice while a database uniqueness constraint and transaction make the effect idempotent.

### Pool decision

Start from database capacity, not client enthusiasm. A pool protects PostgreSQL only if acquisition queues and timeouts are bounded. If 100 application replicas each open 50 server connections, theoretical demand is 5,000 sessions even if the database safely executes only 100 concurrent queries. Smaller pools can improve throughput by reducing contention and preserve predictable latency.

Monitor pool acquisition p50/p95/p99, waiting count, in-use count, checkout timeout, session lifetime and churn. Align application deadline, pool timeout, connect timeout, statement timeout and lock timeout so inner work ends before the caller abandons it.

### Cancel, terminate, fail over or restore

- **Cancel one statement** when it is confirmed harmful work and rollback is acceptable.
- **Terminate one session** when session state is harmful, after understanding rollback and reconnect behavior.
- **Throttle or pause an application cohort** when it creates a connection, retry or write storm.
- **Fail over** when the serving failure domain cannot recover within the objective and a qualified standby, fencing and client plan exist.
- **Restore** when required history cannot be recovered from the serving topology.

Failover changes the active copy. Restore reconstructs a chosen past state. They solve different problems.

## Guided Ubuntu lab

The lab is at:

    drafts/LES-0056-sql-postgresql-internals-reliability/support/lab

It uses an OCI-pinned PostgreSQL 18.4 official image, one internal-only Compose network and tmpfs database storage. No host port is published. The database and generated credential disappear at guarded cleanup. Docker access is privileged host authority, so read lab.sh and compose.yaml before execution.

### Safety and prerequisites

Use Ubuntu 24.04 as a normal user with Docker Engine or Docker Desktop WSL integration and Compose v2. The exact image must already be available or Docker may need registry access; the verifier itself does not authorize a pull. Stop if the directory is not the repository lesson lab, if root is in use, if a database credential is already exported, or if any path guard refuses.

The lab refuses UID zero, a wrong operating-system version, common PostgreSQL credential variables, a missing Docker daemon, a changed image pin, an existing exact state root or project, and symlinked, wrong-owned or unknown artifacts. Do not bypass a refusal. Understand it.

### Step 1: inspect and diagnose readiness

    cd drafts/LES-0056-sql-postgresql-internals-reliability/support/lab
    sed -n '1,260p' lab.sh
    sed -n '1,220p' compose.yaml
    bash lab.sh doctor

Expected:

    doctor=pass runtime=postgresql-18.4-local-only

This proves declared local guards and daemon access. It does not prove the container initializes.

### Step 2: create only the disposable environment

    bash lab.sh setup
    bash lab.sh status

Expected shape:

    setup=pass project=reliabilityatlasles0056... host_ports=none rows=100000
    version=18.4 ... orders=100000 connections=...

Setup creates an exact UID-scoped directory under /tmp, a random lab password, one exact Compose project and an ephemeral database. Initialization creates accounts, orders and ledger tables with keys, constraints and a narrow application role. Seed data contains 100,000 orders.

If setup fails after creating resources, preserve the first error. Do not run broad Docker cleanup. Use only the exact lab cleanup when its guards accept the state.

### Step 3: read the unindexed plan

    bash lab.sh plan-before

The SQL uses EXPLAIN with ANALYZE, BUFFERS, WAL and JSON output for a SELECT. Find Node Type, Plan Rows, Actual Rows, Actual Loops, buffers, sort work and timing.

The verifier expects a sequential scan before the new index. That does not mean PostgreSQL is defective. With no useful customer/time index, scanning is a rational available path.

### Step 4: add and evaluate a fitting index

    bash lab.sh add-index
    bash lab.sh plan-after

The index begins with customer_id, then created_at descending, and includes projected payload columns. ANALYZE refreshes statistics. The expected plan uses an index, index-only or bitmap path.

| Before | After | Question |
|---|---|---|
| pages examined | pages examined | was I/O work reduced? |
| actual rows and loops | actual rows and loops | is cardinality stable? |
| sort work | sort work | did index ordering remove it? |
| execution time | execution time | is the sample materially different? |
| no index maintenance | new write/WAL/storage cost | is net workload benefit positive? |

The fixture is small and probably warm. It proves a planner choice under one dataset, not production speed.

### Step 5: observe blocking

    bash lab.sh lock-wait

One transaction locks account 1 for about three seconds. Another sets a 500 ms lock timeout and attempts an update.

    lock_wait=pass waiter_timeout=true holder_committed=true

The lesson is not that 500 ms is universally correct. Blocking must be bounded below an end-to-end deadline, and blocker evidence matters more than the waiter's text.

### Step 6: observe deadlock resolution

    bash lab.sh deadlock

Transaction A updates account 1 then wants account 2. Transaction B does the reverse. PostgreSQL aborts one victim and lets the survivor commit:

    deadlock=pass victim_count=1 survivor_committed=true

Prevention is stable resource order. Recovery is rollback and safe retry of the whole victim transaction.

### Step 7: consume ordinary connection slots

    bash lab.sh connections

The lab opens bounded sleeping application sessions, then proves another ordinary connection is rejected while an administrative path remains.

    connections=pass normal_slots_exhausted=true admin_reserve_preserved=true

The production fix is not automatically a larger max_connections value. Find multiplying pool configuration, leaked transactions, retry storm, service ownership and useful database concurrency.

### Step 8: back up, restore and validate

    bash lab.sh backup-restore

The lab streams a custom-format logical dump into the guarded root, restores to a separate database, validates order and ledger counts, then removes only that restored database.

    backup_restore=pass format=custom business_validation=true

This is stronger than backup completed because a restore ran. It remains incomplete: counts are not every invariant; there is no PITR, external retention, corruption exercise, replica or production RTO.

### Step 9: prove hostile-state refusal and exact cleanup

    bash lab.sh inject-unknown
    bash lab.sh status

Status must refuse because the inventory contains an unexpected artifact. Then:

    bash lab.sh clear-unknown
    bash lab.sh cleanup

Expected:

    cleanup=pass project_absent=true state_absent=true

A cleanup script must know exactly what it owns. Unexpected state must never become permission to delete more broadly.

### Full verifier

From an absent lab state:

    bash verify.sh

Expected final line:

    verify=pass plan=true lock=true deadlock=true connections=true restore=true cleanup=true

If Docker is unavailable, record that limitation. Static syntax success is not runtime success.

## Production transfer

The lab teaches evidence shapes. Production adds data value, durability, identity, encryption, topology, latency and shared ownership. Build this transfer sheet before touching a live system:

| Boundary | Record |
|---|---|
| operation | user action, correctness, idempotency, deadline |
| workload | QPS, concurrency, read/write mix, parameter distributions |
| client | version, pool mode, limits, timeouts, retry policy |
| identity | endpoint, database, role, application_name, TLS authority |
| transaction | isolation, statements, lock order, external side effects |
| plan | fingerprint, parameters, estimated/actual rows, buffers, spills |
| state | constraints, indexes, live/dead tuples, growth |
| durability | commit settings, WAL rate, archive and retention |
| topology | writer, standbys, sync mode, failure domains, fencing |
| recovery | backup type, restore order, recovery target, validation |
| objectives | SLI, SLO, RPO, RTO, capacity and cost limits |

### Release causes checkout latency

Checkout p99 rises, database CPU stays moderate, active connections rise, sessions show lock waits and retries triple. Freeze unrelated changes, split pool and SQL latency, compare fingerprints and transaction age, map waiters to blockers, and check whether a new external call occurs inside a transaction. Bound retries and concurrency. Roll back the harmful cohort if evidence supports it. Verify fresh checkout correctness, p99, pool wait, lock queue and duplicate effects.

The cause may be an application transaction expanded around a remote payment call. Adding CPU or an index would not release held row locks.

### Plan regression from data skew

One normalized query is fast for most tenants and slow for a very large tenant. Aggregated mean latency looks fine. Investigate parameter classes, estimate error, actual rows, loops and buffers. One generic plan may not fit both distributions. Options include better or extended statistics, query or schema change, justified partitioning and deliberate plan-cache behavior.

Verify small, median and large parameter classes; realistic cache conditions; read latency and write overhead; plan stability after analyze and deploy; and rollback.

### WAL storage growth

Separate current WAL generation, checkpoint behavior, archive failures, replication slot retention, standby delay and recovery needs. Deleting WAL files by hand can destroy recovery. Dropping a slot can force a consumer rebuild. Establish retention owner, consequence and resynchronization plan while protecting remaining headroom.

### Schema change transfer

For a large-table change:

1. Identify version-specific behavior.
2. Determine lock mode and rewrite behavior.
3. Estimate rows, bytes, WAL, temporary space and replica impact.
4. Test on representative scale.
5. Bound lock acquisition.
6. Preserve old/new application compatibility.
7. Backfill in bounded resumable batches.
8. Validate constraints and business invariants.
9. Define rollback and its cost.
10. Observe primary and standby until debt drains.

No zero-downtime claim is valid without lock acquisition, compatibility, backfill, validation, replication and rollback evidence.

## Reliability, security, observability, capacity, and cost

### Reliability

Build reliability around the operation, not database uptime. Useful SLIs include transaction success, correctness, latency including queueing, freshness for replica reads, and ambiguous outcome rate. Constraints are the last invariant defense. Idempotency identities protect externally retried work. Keep transactions short, lock in stable order, bound every queue and propagate cancellation.

High availability needs independent failure domains, a known writer, a replication and lag objective, surviving capacity, fencing, client reconnection, compatible versions, ambiguous-write reconciliation and tested failback.

### Security

Use a distinct least-privilege role per workload or trust boundary. Applications normally should not own schemas, create roles or use superuser. Separate migration identity from runtime identity. Limit CONNECT and schema privileges; review default privileges.

Protect credentials outside code and images, prefer short-lived integration where supported, rotate safely and require TLS with server identity verification across untrusted networks. Do not log passwords, secret-bearing URIs, unrestricted SQL parameters or customer payloads. Query samples and plans can expose data.

Backups are sensitive copies. Encrypt and isolate them, separate delete authority, enforce retention, audit access and restore through a separate identity. Use parameter binding against SQL injection; application authorization is still required.

### Observability

Layer user transaction SLIs, request traces, pool queues, PostgreSQL activity/waits/plans, WAL/vacuum/replication/backup evidence, host resources and change events.

Control cardinality and sensitivity. Query fingerprints are useful; raw parameters can be unsafe and unbounded. Alert on actionable conditions: error-budget burn, oldest transaction, pool exhaustion, dangerous lock queues, storage runway, archive failure, lag against freshness, backup age and failed restore exercises.

### Capacity

    useful throughput <= min(
      application workers,
      pool budget,
      database CPU concurrency,
      memory and cache,
      storage IOPS and throughput,
      lock-serialized path,
      WAL and replication drain,
      downstream capacity
    )

Measure arrivals, service time, concurrency, row/index/WAL growth, backup duration, replica catch-up and restore throughput. Leave failure headroom. Little's Law gives a sanity check: average concurrency equals arrival rate times average time in system. At 500 transactions per second and 100 ms average time, average concurrency is about 50, not automatically 500 connections.

### Cost

Cost includes compute, memory, I/O, storage, indexes, WAL, backups, replicas, transfer, telemetry, licensing or service tier, engineering time and incident risk.

An index can reduce query I/O but increase storage, write latency, WAL, replica lag and backup size. A read replica adds freshness and failover complexity. Retention buys recovery options and costs storage. Optimization must preserve SLO, RPO, RTO, security and operator capacity.

## Traps and prevention

### Trap: “The database is healthy”

**Why it fails:** instance CPU, memory and readiness can be green while a user cohort waits on one lock, a pool queue, a stale replica or a bad parameter-specific plan.

**Prevention:** pair component signals with a user-operation SLI and correlation identity. Make dashboards able to pivot from operation to pool, session, fingerprint, wait, plan and transaction result.

### Trap: increase max_connections

**Why it fails:** more backend processes consume memory and scheduling capacity and can admit more concurrent work than CPU, storage or locks can serve. Queueing moves into PostgreSQL where control is weaker.

**Prevention:** budget connections globally, reserve operations access, bound pools per maximum replica count, monitor pool wait, and load-test useful concurrency.

### Trap: every sequential scan is bad

**Why it fails:** reading a large fraction of a small or cached table sequentially can be cheaper than random heap access through an index.

**Prevention:** inspect selectivity, rows, loops, buffers, ordering and workload. Create indexes for query contracts and measure the write trade.

### Trap: estimated cost is execution time

**Why it fails:** planner cost is an internal weighted comparison, not milliseconds. An estimate also lacks actual parameter and runtime evidence.

**Prevention:** distinguish EXPLAIN from EXPLAIN ANALYZE; use actual rows, loops, buffers and timing only in a safe execution environment.

### Trap: retry every database error

**Why it fails:** authentication, syntax, constraint and permission errors are not transient. Unbounded retries amplify load. An ambiguous commit may duplicate a business effect.

**Prevention:** classify SQLSTATE, roll back the complete failed transaction, use bounded backoff and jitter for retryable classes, and require idempotency or reconciliation.

### Trap: kill the oldest query

**Why it fails:** it may be a critical migration, backup or blocker whose rollback is more expensive than completion. The oldest visible waiter may not own the lock.

**Prevention:** map waiters to blockers, identify application and owner, estimate rollback, choose cancel versus terminate, and record approval and verification.

### Trap: long transaction with a remote call

**Why it fails:** locks and snapshots remain while a separate network dependency consumes unpredictable time. Contention and vacuum debt grow.

**Prevention:** move remote work outside the database transaction, use durable workflow state, outbox/inbox or saga patterns where needed, and keep the database unit short.

### Trap: disable autovacuum because it uses I/O

**Why it fails:** dead space, stale statistics and wraparound risk grow. Emergency anti-wraparound vacuum can be more disruptive.

**Prevention:** find long snapshots and table-specific rates, tune workers, thresholds and cost controls, preserve I/O headroom, and observe progress.

### Trap: DELETE returns disk space

**Why it fails:** delete creates dead versions and WAL. Ordinary vacuum usually makes internal space reusable rather than shrinking the file.

**Prevention:** distinguish logical removal, reusable relation space and filesystem return. Plan retention, partition lifecycle or reviewed rewrite based on the real objective.

### Trap: replica equals backup

**Why it fails:** deletion, bad migration and many logical corruptions replicate. A lagging or broken replica can also be unavailable when needed.

**Prevention:** retain isolated recovery points and WAL according to RPO; test restores and business reconciliation; protect backup deletion authority.

### Trap: failover equals recovery

**Why it fails:** clients may retain old connections, the old writer may remain reachable, reads may be stale and writes near failure may be ambiguous.

**Prevention:** fence, establish authoritative timeline, update and verify routing, drain pools, reconcile operation IDs, validate freshness and perform a new write.

### Trap: logical dump is a complete DR plan

**Why it fails:** large restore time, roles, extensions, global objects, ownership, privileges, sequences and external dependencies may not fit the objective.

**Prevention:** choose logical, physical and PITR mechanisms from recovery requirements; automate isolated restoration and validate full service behavior.

### Trap: online schema change means zero risk

**Why it fails:** even optimized operations acquire locks, consume WAL and I/O, interact with long transactions and affect replicas.

**Prevention:** test version-specific behavior, bound lock acquisition, use compatible phases, observe debt, retain pause and rollback controls.

## Memory card and retrieval

### The six sentences

1. Follow one user transaction from pool wait to durable and acknowledged outcome.
2. MVCC gives snapshots and row versions; it reduces blocking but creates cleanup obligations.
3. A plan estimate is a hypothesis; actual rows, loops, buffers and safe execution test it.
4. Waiting work is evidence of an owner; map the blocker before canceling anything.
5. Connections, retries and queues are capacity multipliers, not free availability.
6. Replication serves availability; only an isolated validated restore proves recovery.

### The 30-second incident card

    OPERATION: success, latency, correctness, freshness, deadline
    SCOPE: release, cohort, database, role, endpoint, time
    CLIENT: pool wait, timeout, retry, idempotency
    SESSION: PID, state, wait, transaction age, blocker
    QUERY: fingerprint, parameters, plan, rows, loops, buffers
    STATE: locks, vacuum, WAL, replication, storage
    ACTION: smallest reversible mitigation and rollback trigger
    PROOF: fresh transaction, invariant, SLI, backlog, headroom

### Retrieval prompts

Answer without looking, then check:

1. Why can an update consume space even when row count stays constant?
2. Why can 10 GB be free while writes still fail?
3. What does EXPLAIN ANALYZE do that EXPLAIN does not?
4. Why is a blocker different from a slow query?
5. What must an application do after a deadlock victim error?
6. Why can higher max_connections reduce reliability?
7. What does ordinary vacuum reclaim, and what may it not return?
8. Why can a standby be caught up but still unready for promotion?
9. What is the difference between failover and restore?
10. What proves recovery?

Short answers: MVCC creates new versions; capacity can fail at inodes, WAL, tablespace, quota, temporary space or limits; ANALYZE executes; blockers own required resources; roll back and safely retry the whole transaction; more sessions amplify contention; vacuum makes tuple space reusable but usually does not shrink files; fencing, configuration, capacity and clients may be unready; failover selects another serving copy while restore reconstructs history; isolated restore plus business validation and measured objectives.

Review after one day, one week and one month. Reading state is not demonstrated skill. Keep evidence from the guided lab and complete the independent transfer without using the answers below.

## Complete answers

### Question 1: Why did an index make one query faster but the service slower?

**Foundation answer:** the index reduced work for the selected read, but every relevant write now maintains another structure. The service may be write-heavy, cache may hold less useful data, WAL and replica lag may rise, or index creation may have competed with production.

**Strong diagnostic answer:** compare the exact read fingerprint and parameter classes before and after, then measure write latency, WAL bytes, buffer and storage work, index size, checkpoint behavior, replica lag and total user SLI. Verify whether the index duplicates an existing prefix, whether included columns are worth their size, and whether the query improvement affects enough traffic to repay write cost.

**Senior judgment:** an index is accepted on net workload evidence and rollback readiness, not one plan. I would keep the before/after plan, traffic mix, build effect, storage runway and removal condition in the change record.

### Question 2: The database CPU is 35 percent but requests time out. What next?

CPU headroom does not clear pool queueing, locks, I/O latency, single-core saturation, connection setup, stale replicas or an external dependency inside a transaction.

Split end-to-end latency. Inspect pool acquisition and waiters. Bind sessions through application_name and request correlation. Classify pg_stat_activity states and wait events. If waiting on locks, map blockers. If running, inspect the representative plan and host/storage evidence. Compare release and migration timelines. Mitigate only the first confirmed harmful boundary, then verify the operation and backlog.

A weak answer says restart or scale the database. That destroys evidence and may add no capacity to a serialized lock path.

### Question 3: Explain MVCC as if mentoring a new engineer.

Imagine the database keeps approved editions of a row. A transaction reads from a catalog of editions that were valid for its snapshot. When another transaction updates the row, it writes a newer edition instead of making the older edition instantly disappear. Old readers can finish consistently; new readers can see the committed newer version.

The price is lifecycle management. Old editions become dead only when no relevant snapshot needs them. Vacuum then makes their space reusable and manages transaction-ID safety. Long transactions delay that work. MVCC explains why readers and writers often coexist, why updates generate extra storage and WAL, and why idle-in-transaction sessions can hurt a busy system.

### Question 4: Read Committed, Repeatable Read or Serializable?

At Read Committed, each statement receives a fresh snapshot. It is suitable when each statement may use the newest committed state and the application safely rechecks assumptions.

At PostgreSQL Repeatable Read, a transaction keeps a stable snapshot. It is useful for internally consistent multi-statement reads, but concurrent update patterns can still abort and require retry.

Serializable adds detection so committed transactions behave as though ordered serially. It may abort work under conflict. Use it for invariants that are hard to protect otherwise, with short transactions and tested whole-transaction retry. Do not include unrepeatable external side effects inside a retryable unit.

The correct answer begins with the business anomaly to prevent, not “strongest is always safest.”

### Question 5: How do you respond to a deadlock?

Capture SQLSTATE 40P01, involved statements, transaction boundaries and the server deadlock graph if logging supplies it. PostgreSQL has already chosen and aborted a victim. The victim transaction must roll back. The application may retry the complete unit from a clean transaction with a budget and jitter only if its effects are idempotent.

Prevent recurrence by acquiring shared resources in stable order, shortening transaction scope and removing unnecessary locks. Track deadlock rate and the user effect. Raising deadlock_timeout only changes detection timing and logging behavior; it does not remove the cycle.

### Question 6: How do you size a connection pool?

Find useful database concurrency from load tests and resource behavior. Subtract operations, migration, replication and other service reservations from database connection capacity. Divide the remaining service allocation across the maximum simultaneous application replicas, keeping failure and rollout headroom.

Then load-test throughput and p99 while varying pool size. A pool of 20 per replica across 10 replicas means up to 200 server sessions. Autoscaling to 50 replicas changes that to 1,000 unless the budget follows. Monitor acquisition queue and timeout. A pool should queue briefly and reject predictably rather than overwhelm the database.

### Question 7: What would you do when disk fills because a replication slot retains WAL?

Confirm filesystem runway, current WAL generation, slot name, consumer owner, restart or flush position and whether the slot is required for replication or change-data capture. Reduce nonessential write pressure and repair the consumer if it can catch up before capacity is exhausted.

Do not manually delete WAL. Do not drop the slot until the owner and recovery impact are understood. If the consumer cannot resume, approve a controlled slot removal and full resynchronization with documented data-consistency consequence. Verify WAL retention declines, archive remains healthy, consumer state is rebuilt, and the user path is stable.

### Question 8: What is a good backup strategy?

Start with business RPO, RTO, retention, corruption and region-loss threats. Combine mechanisms as needed: physical base backups plus archived WAL for PITR, logical exports for selective portability, and replicas for availability. Isolate credentials and deletion authority, encrypt, monitor completeness and preserve version-compatible recovery procedures.

Schedule isolated restores to a clean environment. Select recovery points, measure elapsed phases, validate schema, roles, extensions, sequences and business invariants, then test the application. Record achieved RPO/RTO and cleanup. A backup job success without restoration is inventory, not recovery proof.

### Question 9: How do you make a schema migration production-safe?

Determine exact version behavior, lock mode, rewrite, row and byte scale, WAL, temporary storage and replica effect. Test against representative scale. Use expand-and-contract: add compatible structures, deploy tolerant code, backfill in bounded resumable batches, validate, switch behavior, then remove obsolete state later.

Set bounded lock acquisition where appropriate, observe blockers, define pause and rollback, and avoid one transaction that holds locks for the entire backfill. Verify old and new application versions, constraints, replica catch-up and user SLIs.

### Question 10: What is the reliable response to an ambiguous commit?

Do not assume failure because the client timed out. The server may have committed and lost the acknowledgement. Query durable operation state by an idempotency key or domain identity. If the recorded result exists, return it. If it is absent and the design proves no effect, retry under the same identity. If state is indeterminate, route to reconciliation rather than duplicating money movement or fulfillment.

This is why operation identity, unique constraints and result recording belong in initial design rather than incident improvisation.

## Product-company interview

### Interview 1: Diagnose a slow API backed by PostgreSQL

**Level:** mid to senior
**Interviewer evaluates:** layered latency decomposition, evidence discipline, SQL/plan literacy and safe mitigation.

**Strong answer:** I first define the affected operation, cohort and correctness. I split application time into queue, pool acquisition, network, SQL and response. I bind endpoint, database, role, version and request to a backend. Waiting sessions lead to blocker and transaction-age analysis; executing sessions lead to fingerprint, parameter distribution, actual plan, rows, loops, buffers and host/storage evidence. I compare recent code, migration, statistics and topology changes. I mitigate the confirmed boundary reversibly and verify user latency, correctness, queue drain and resource headroom.

**Weak signs:** starts with restart; asks only for CPU; assumes a sequential scan is bad; proposes an index without write or rollback analysis.

**Follow-ups:**

- If SQL is 5 ms but pool wait is 2 s, what changes? Investigate admitted concurrency, pool budget, connection churn and transaction duration rather than query speed.
- If only one tenant is slow? Compare parameter distribution, estimates and plans by tenant class.
- If EXPLAIN ANALYZE is unsafe? Use plain EXPLAIN, captured production-safe telemetry or an isolated representative replay.

### Interview 2: Design reliable order creation

**Level:** senior
**Interviewer evaluates:** data modeling, concurrency, idempotency and failure ambiguity.

**Strong answer:** define order identity, state transitions and invariants. Put uniqueness, positive totals and references in constraints. Require an idempotency key scoped to caller and operation. In one short transaction, claim the key, create or retrieve the order, append an outbox event and commit the durable result. Never hold the transaction across an external call. A worker publishes from the outbox with retry and consumer deduplication. On ambiguous client result, reconcile by key. Lock shared resources in stable order, bound timeouts and test concurrent duplicates, crash points and retry storms.

**Weak signs:** claims exactly-once HTTP delivery; uses only an application if-check for uniqueness; retries every error; calls a payment provider inside the transaction.

### Interview 3: A primary failed. Promote the replica?

**Level:** senior to staff
**Interviewer evaluates:** failure-domain reasoning, data loss, fencing and recovery leadership.

**Strong answer:** establish whether the primary is unreachable or merely slow and whether storage/control/network scope is known. Compare the best standby's receive, flush and replay position with the last known primary commit and business RPO. Confirm version, recovery configuration, capacity and replication health. Obtain incident authority, fence the old writer before accepting a new writer, promote one candidate, establish authoritative timeline and endpoint, recycle client pools, and reconcile ambiguous writes by operation identity. Verify new reads and writes, freshness, backlog and downstream behavior. Plan replica restoration and failback separately.

**Weak signs:** promotes the first reachable replica; ignores old-writer fencing; treats zero lag as proof; has no client or ambiguous-write plan.

### Interview 4: Vacuum is running and latency is high

**Level:** advanced
**Interviewer evaluates:** causal caution and MVCC maintenance understanding.

**Strong answer:** correlation is not causation. I inspect workload change, wait events, storage latency, vacuum progress, dead tuples, old transactions, table/index size and checkpoint/WAL behavior. Canceling vacuum can preserve the source of bloat and wraparound risk. If it is consuming constrained I/O, I may tune or reschedule ordinary work after protecting transaction-ID safety, but first remove long snapshots and fix per-table thresholds or capacity. I verify workload latency and maintenance debt.

**Weak signs:** disable autovacuum; run VACUUM FULL immediately; assume file shrink is the goal.

### Interview 5: Design PostgreSQL observability

**Level:** staff
**Interviewer evaluates:** user-centered telemetry, cardinality, privacy and actionability.

**Strong answer:** start with transaction success, latency, correctness, freshness and ambiguous-outcome SLIs. Correlate requests to application version, pool metrics, database/application identity, normalized fingerprint and sampled backend evidence. Collect session states and waits, query aggregate calls/rows/time/buffers/WAL, locks, deadlocks, transaction age, vacuum/analyze, table/index growth, checkpoint/WAL/archive, replication positions, backup/restore and host resources. Apply access, redaction, retention and cardinality controls. Alerts map to runbook decisions and error budgets. Periodic restore and failover exercises provide evidence dashboards cannot.

### Interview 6: When would you use PgBouncer transaction pooling?

**Level:** senior
**Interviewer evaluates:** capacity benefit versus session semantic risk.

**Strong answer:** use it when many client connections need a smaller number of server sessions and transactions are short enough for reuse. Inventory every session-dependent feature: temporary tables, session SET, prepared statements under exact versions, advisory locks, listen/notify and driver assumptions. Make transaction boundaries explicit, budget pool queues, reserve administration access and test failover and cancellation. Choose session pooling when compatibility outweighs multiplexing, and avoid statement pooling for multi-statement transaction requirements.

### Staff follow-up: one-region versus multi-region relational writes

Do not answer “multi-region is more reliable.” Define latency, consistency, conflict, sovereignty, partition behavior, RPO/RTO and operating skill. A single-writer region with tested cross-region recovery may offer clearer correctness. Synchronous cross-region acknowledgment raises latency and can reduce write availability during partitions. Multi-writer designs move conflict semantics into the data model and application. Present at least two architectures, their failure modes, cost and migration path.

## Independent transfer and rubric

Use assessment ASM-0153 without reading any model answer. A reviewer supplies an unseen relational workload and later changes a major constraint. No live or production database is permitted.

Required evidence:

1. operation, state transition, invariant, idempotency, SLI, RPO and RTO;
2. normalized data model with keys, constraints and ownership;
3. transaction boundaries, isolation choice, lock order and retry classes;
4. three representative query shapes with parameter distributions and proposed evidence;
5. index design with read/write/storage/WAL trade-offs;
6. pool and timeout budget under normal, burst and failure capacity;
7. migration and rollback plan;
8. primary, standby, fencing, lag and client behavior;
9. backup, PITR or logical protection and isolated restore validation;
10. observability, security, cost and changed-constraint response.

| Criterion | 0 | 5 | 10 |
|---|---|---|---|
| operation contract | missing | partial | correctness, identity, objectives explicit |
| data invariants | application-only | some constraints | keys, constraints and races defended |
| transactions | vague | isolation named | boundaries, anomalies, locks and retry justified |
| query evidence | generic | SQL listed | distributions, estimates, actual evidence and safety |
| indexes | shopping list | read benefit | net workload and rollback evaluated |
| pools/capacity | per-instance guess | slot count | global budget, burst/failure headroom and queues |
| migration | one-step DDL | compatibility noted | locks, phases, backfill, validation and rollback |
| availability | replica equals HA | promotion described | lag, fencing, clients, ambiguity and failback |
| recovery/security | backup checkbox | restore named | isolated validation, RPO/RTO, identity and protection |
| transfer judgment | no adaptation | change acknowledged | design recalculated and trade-offs defended |

Maximum: 100. A passing score is not mastery by itself. Require at least 80, no safety-critical failure, reviewer observation, an unfamiliar changed constraint and delayed recall.

Safety-critical failures include using a production credential, executing a mutating plan against live data, restoring over the source, printing secrets, dropping recovery state without ownership, proposing unfenced promotion, or using unbounded retry.

After the review, answer:

- Which claim had the weakest evidence?
- Which decision changes first if write rate grows tenfold?
- Which failure produces an ambiguous user outcome?
- Which resource becomes the next bottleneck after the proposed fix?
- What evidence would make you reverse the decision?

## References and review

Primary sources reviewed for this candidate:

- REF-0598 — PostgreSQL SQL language tutorial: tables, queries, joins, aggregates and changes.
- REF-0599 — PostgreSQL constraints: check, not-null, unique, primary and foreign keys.
- REF-0600 — PostgreSQL indexes: index concepts, types and operational trade-offs.
- REF-0601 — PostgreSQL EXPLAIN: estimates, actual execution, buffers and plan interpretation.
- REF-0602 — PostgreSQL MVCC introduction: concurrency and visibility model.
- REF-0603 — PostgreSQL transaction isolation: anomalies and version-specific semantics.
- REF-0604 — PostgreSQL explicit locking: table, row, advisory locks and deadlocks.
- REF-0605 — PostgreSQL statistics monitoring: activity, tables, indexes, WAL and replication views.
- REF-0606 — PostgreSQL connection settings: maximum and reserved connections.
- REF-0607 — PostgreSQL routine vacuuming: space reuse, statistics and wraparound prevention.
- REF-0608 — PostgreSQL backup and restore overview.
- REF-0609 — PostgreSQL pg_dump documentation and logical-backup boundaries.
- REF-0610 — PostgreSQL warm standby and streaming replication.
- REF-0611 — PgBouncer feature matrix and pooling-mode compatibility.
- REF-0612 — Docker Official Postgres image source and initialization contract.

Version-sensitive claims were reviewed against PostgreSQL 18.4 current documentation on 2026-08-05. Before using this material against another version, recheck isolation behavior, monitoring fields, reserved connection features, planner output, replication and maintenance settings.

Review checklist:

- Can a beginner explain every displayed term without an outside search?
- Do commands state question, risk, expected branches, proof and limit?
- Are plans treated as evidence rather than verdicts?
- Are transaction, application and database responsibilities separated?
- Do HA, replication, backup and restore remain distinct?
- Does every remediation preserve data and recovery options?
- Do security and privacy cover SQL, logs, plans, dumps and credentials?
- Are capacity and cost connected to workload and failure headroom?
- Are complete answers deep enough to teach reasoning, not memorized phrases?
- Is independent transfer answer-isolated and reviewer-scored?

This chapter is a substantive quarantined candidate. Publication does not award mastery. The local lab is not production, and automated validation is not a human technical review.
