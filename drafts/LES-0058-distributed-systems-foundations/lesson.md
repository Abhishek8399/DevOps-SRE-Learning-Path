---
{"schemaVersion":1,"kind":"lesson","id":"LES-0058","slug":"distributed-systems-foundations","aliases":["V06-L03","distributed-systems-foundations"],"curriculumIds":["DST-005"],"route":"/book/state/distributed-systems-foundations","order":3,"volume":"06-state-distributed-systems","title":"Distributed systems foundations: decide what remains true when communication fails","summary":"Reason from operation invariants through failure models, replication, partitions, consistency, quorums, consensus, elections, clocks, leases, fencing and repair.","domain":"state","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0007","LES-0012","LES-0056"],"prerequisiteCurriculumIds":["FND-001","NET-003","DST-002"],"testedEnvironments":[{"platform":"Primary research and official documentation","version":"CAP, PACELC, Lamport clocks, Paxos, Raft, FLP, Dynamo, Spanner, etcd, Kubernetes and related sources reviewed 2026-08-05","support":"concept-only","notes":"Research and documentation review does not prove a product implementation."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic boundary model; no cluster or network fault."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, package, process or external resource."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","database-engineer","backend-engineer","cloud-engineer","kubernetes-engineer","solutions-architect","technical-lead"],"learningObjectives":["Define business invariants, operation acknowledgements, safety and liveness before selecting a distributed technology.","Distinguish crash, omission, delay, partition, clock, storage-corruption and Byzantine failure assumptions.","Explain replication roles, commit, apply, lag, durability, placement and repair without treating copies as availability.","Choose partition keys and failure-domain placement from workload, hotspot and invariant boundaries.","Name linearizable, sequential, causal, eventual and session guarantees at operation scope.","Apply CAP only during communication partitions and PACELC to normal latency-consistency trade-offs.","Calculate quorum intersection and explain why arithmetic alone does not prove linearizability.","Trace consensus through election, replicated log, commit, apply, membership change and client routing.","Use happened-before, logical clocks and bounded physical-time uncertainty without treating timestamps as truth.","Explain leases, epochs and fencing, and require stale-writer rejection at external state owners.","Design conflict detection, convergence, anti-entropy, read repair and reconciliation for weaker-consistency paths.","Diagnose quorum loss, split brain, stale reads, clock failures, lag and repair incidents from evidence."],"productionSignals":["business operation invariant acknowledgement and ambiguity rate","cluster identity membership configuration voter and learner roles","term epoch leader ID election duration and leadership changes","per-replica reachable peers health role and failure domain","proposed committed durable and applied log index","quorum size healthy voters and last successful quorum operation","client endpoint route redirect retry deadline and observed consistency mode","replication byte or entry lag time lag catch-up rate snapshot progress","read source version revision session token and staleness age","physical clock offset uncertainty step frequency and synchronization source","lease grant renew expiry elapsed-time source and owner","fencing generation accepted and rejected by each external state owner","conflict siblings version vectors merge decisions and unresolved count","anti-entropy scan mismatch repair backlog and convergence duration","request latency throughput rejection saturation and queue age by operation","disk latency free space corruption alarms snapshot and restore status","network round-trip loss retransmission partition matrix and cross-domain path","authentication principal authorization decision TLS peer and audit event","cross-zone or region bytes replica storage snapshots telemetry and operator cost","user journey correctness freshness availability and recovery objective"],"diagrams":[{"id":"LES-0058-DIA-001","title":"Operation-to-guarantee path","direction":"left-to-right","boundaries":["user operation","invariant and acknowledgement","partition owner","leader or coordinator","replica quorum","commit and apply","projection or external effect"],"evidencePoints":["operation ID","rule","key","epoch","votes","index","receipt"],"textAlternative":"A user operation becomes safe only when its invariant, owner, coordination path, durable decision and external effects use compatible identities and guarantees."},{"id":"LES-0058-DIA-002","title":"Failure uncertainty map","direction":"hierarchical","boundaries":["client","process","host","storage","network","clock","failure domain","operator"],"evidencePoints":["timeout","heartbeat","I/O","loss","offset","correlation","change"],"textAlternative":"A timeout is an observation compatible with process failure, delay, loss, overload, storage stall, clock error or observer isolation; the failure model states which possibilities the protocol handles."},{"id":"LES-0058-DIA-003","title":"Replicated write and read path","direction":"left-to-right","boundaries":["client","leader","replicated log","write quorum","commit index","state machine apply","read source"],"evidencePoints":["request ID","term","log index","durable acknowledgements","commit","applied index","revision"],"textAlternative":"The leader proposes an operation, an intersecting quorum durably records it, the commit rule makes it chosen, replicas apply it in order, and reads must use a path compatible with their promised consistency."},{"id":"LES-0058-DIA-004","title":"Partition and quorum decision","direction":"hierarchical","boundaries":["five-voter configuration","three-voter component","two-voter component","clients","external state owner"],"evidencePoints":["membership","reachability","majority","rejection","fencing generation"],"textAlternative":"During a five-voter partition only the three-voter component can form a majority; the two-voter component must reject quorum writes and external state owners must reject its stale generations."},{"id":"LES-0058-DIA-005","title":"Time and authority layers","direction":"top-to-bottom","boundaries":["physical wall clock","monotonic elapsed time","logical happened-before","term or epoch","lease","fencing validation"],"evidencePoints":["uncertainty","duration","causal token","generation","renewal","rejection"],"textAlternative":"Wall time labels events, monotonic time measures local duration, logical time captures causality, epochs identify authority, leases bound expected ownership, and fencing makes stale ownership harmless at the target."},{"id":"LES-0058-DIA-006","title":"Divergence and repair loop","direction":"left-to-right","boundaries":["replicas diverge","version comparison","conflict policy","authoritative or merged state","anti-entropy","business reconciliation"],"evidencePoints":["siblings","causal relation","merge decision","digest","repair backlog","user outcome"],"textAlternative":"Availability-oriented replicas may accept divergent versions; convergence requires explicit version comparison, deterministic or business-aware resolution, anti-entropy and user-level reconciliation."}],"commands":[{"id":"LES-0058-CMD-001","question":"Is this host the supported offline lab boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0058 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"OS, user, credential and Python guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"named prerequisite or safety guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"distributed behavior"},{"id":"LES-0058-CMD-002","question":"Can the exact synthetic state initialize safely?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture identity and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state or fixture rejected","nextEvidence":"preserve first error"}],"proves":"bounded local initialization","doesNotProve":"cluster setup","cleanup":"Run bash lab.sh cleanup after setup."},{"id":"LES-0058-CMD-003","question":"Does the baseline cross every encoded boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0058 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"all encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"fixture or model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"consensus correctness"},{"id":"LES-0058-CMD-004","question":"Can the surviving component form a write quorum?","risk":"read-only","command":"bash lab.sh evaluate quorum-loss","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=quorum-loss","meaning":"reachable voters are below configured write quorum","nextEvidence":"reject progress and restore a voter"}],"proves":"encoded quorum arithmetic","doesNotProve":"member health"},{"id":"LES-0058-CMD-005","question":"Do read and write sets necessarily intersect?","risk":"read-only","command":"bash lab.sh evaluate unsafe-quorums","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=quorum-intersection","meaning":"R plus W does not exceed N","nextEvidence":"correct protocol and test histories"}],"proves":"encoded set-intersection failure","doesNotProve":"linearizability when corrected"},{"id":"LES-0058-CMD-006","question":"Can two writers claim authority?","risk":"read-only","command":"bash lab.sh evaluate dual-writer","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=split-brain","meaning":"encoded design permits concurrent authority","nextEvidence":"quorum authority and fencing"}],"proves":"declared dual-writer risk","doesNotProve":"a real split occurred"},{"id":"LES-0058-CMD-007","question":"Is a reachable leader still backed by quorum?","risk":"read-only","command":"bash lab.sh evaluate isolated-old-leader","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=stale-leader","meaning":"reachability is not authority","nextEvidence":"stop writes and inspect term commit index"}],"proves":"encoded authority gap","doesNotProve":"live leader state"},{"id":"LES-0058-CMD-008","question":"Does lease safety depend on adjustable wall time?","risk":"read-only","command":"bash lab.sh evaluate wall-clock-lease","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=clock-safety","meaning":"elapsed ownership uses an unsafe time source","nextEvidence":"monotonic duration and protocol assumptions"}],"proves":"encoded clock misuse","doesNotProve":"clock synchronization"},{"id":"LES-0058-CMD-009","question":"Can an expired actor mutate external state?","risk":"read-only","command":"bash lab.sh evaluate expired-worker-no-fence","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=stale-writer","meaning":"target does not reject old generations","nextEvidence":"end-to-end fencing"}],"proves":"encoded fencing omission","doesNotProve":"target implementation"},{"id":"LES-0058-CMD-010","question":"Can a dependent read violate causality?","risk":"read-only","command":"bash lab.sh evaluate missing-causal-token","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=causal-order","meaning":"dependency context is absent","nextEvidence":"carry session or causal context"}],"proves":"encoded causal gap","doesNotProve":"all histories"},{"id":"LES-0058-CMD-011","question":"Can a promised strong read serve an older revision?","risk":"read-only","command":"bash lab.sh evaluate stale-linearizable-read","runFrom":"LES-0058 support/lab","expectedBranches":[{"when":"boundary=stale-read","meaning":"served index trails required index","nextEvidence":"leader ReadIndex quorum or revision-aware path"}],"proves":"encoded stale-read condition","doesNotProve":"product read semantics"},{"id":"LES-0058-CMD-012","question":"Do all cases, refusal and exact cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0058 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"thirteen branches refusal and cleanup pass","nextEvidence":"retain model limitation"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"network partition replication consensus time or production recovery","cleanup":"Verifier proves exact UID-scoped state absence."}],"labs":[{"id":"LES-0058-LAB-001","title":"Guided distributed-boundary decision model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one exact UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","cloud database or Kubernetes credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failed boundary; correct only the copied teaching fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0058-distributed-systems-foundations/support/lab"},{"id":"LES-0058-LAB-002","title":"Independent partition, leader-loss and repair transfer","mode":"independent","environment":"Reviewer-owned disposable local cluster or deterministic history harness with synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns any network or process fault capability","network":"isolated local only","changes":["disposable replicas","synthetic operations","approved message delay or loss","leader and membership transitions","repair and reconciliation artifacts"],"abortConditions":["shared or production system","real credential","host clock mutation","host firewall or default route","customer data","unreviewed process termination","unknown cleanup scope"],"recovery":"Use the harness reset; preserve histories, indexes, epochs and business reconciliation before cleanup.","cleanupProof":"Reviewer proves processes, namespaces, volumes, files, routes and credentials absent and host state unchanged.","path":"drafts/LES-0058-distributed-systems-foundations/support/lab"}],"incidents":[{"id":"LES-0058-INC-001","signal":"A five-voter cluster partitions three versus two and both sides still answer health checks.","firstThought":"Health endpoint reachability does not prove quorum authority; only the three-voter component can form a majority.","safePath":"Bind configuration, term, leader, commit and apply indexes; stop minority writes, fence old epochs, route clients to current quorum and reconcile escaped effects.","trap":"Choose the side with the newest wall-clock timestamp."},{"id":"LES-0058-INC-002","signal":"A follower serves an older value immediately after the client received a successful write.","firstThought":"The read path is weaker than the user's read-after-write or linearizable expectation, or apply lag exceeds routing assumptions.","safePath":"Bind operation receipt, required revision, read source, served revision and advertised consistency; route or wait using supported revision-aware mechanisms.","trap":"Call it eventual consistency without checking the contract."},{"id":"LES-0058-INC-003","signal":"An expired job runner resumes after a pause and overwrites output from its replacement.","firstThought":"A lease expired, but the external state owner did not enforce a newer fencing generation.","safePath":"Stop unsafe writes, compare generations and operation IDs, reconcile output, then require monotonic fencing at every target.","trap":"Increase the lease duration."},{"id":"LES-0058-INC-004","signal":"Replica lag and repair traffic rise together until foreground tail latency and elections worsen.","firstThought":"Repair is competing with quorum work for disk, CPU or network, creating a positive feedback loop.","safePath":"Graph commit/apply lag, I/O, bandwidth, queues, elections and user latency; bound repair, restore headroom and recover one failure domain at a time.","trap":"Run maximum parallel repair everywhere."},{"id":"LES-0058-INC-005","signal":"Two available replicas return sibling values after a partition heals.","firstThought":"The design accepted concurrent versions; physical last-write-wins may discard a valid update.","safePath":"Compare causal metadata, apply declared deterministic or business merge, run anti-entropy and reconcile user-visible state.","trap":"Select the largest timestamp without a trusted clock and semantic rule."}],"assessmentIds":["ASM-0157","ASM-0158","ASM-0159"],"referenceIds":["REF-0628","REF-0629","REF-0630","REF-0631","REF-0632","REF-0633","REF-0634","REF-0635","REF-0636","REF-0637","REF-0638","REF-0639","REF-0640","REF-0641","REF-0642"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not a replicated state machine, consensus protocol, database, network partition, clock or consistency checker.","Synthetic decisions do not prove Raft, Paxos, etcd, Kubernetes, Dynamo-style, Spanner or provider behavior.","No real log, voter, quorum, election, lease, fencing target, replica, conflict, repair, restore or user history exists.","Product guarantees and behavior are version-, configuration-, topology- and operation-dependent.","Formal review, canonical publication, representative disposable-cluster evidence, reviewer transfer, delayed recall and learner evidence remain required."]}
---

# Distributed systems foundations: decide what remains true when communication fails

## What you see and first thought

You see two dashboards. Region A says the leader is healthy. Region B also says the leader is healthy. Requests sometimes succeed, sometimes time out, and inventory totals disagree. The beginner question is, “Which server is broken?” The production question is, “What fact can each observer actually prove?”

That change of question is the heart of distributed systems.

A process can prove that it sent a message. It cannot prove the receiver saw it merely because the send call returned. A client can prove that its deadline expired. It cannot infer that the server did nothing. A node can prove that its local clock reads 12:00. It cannot infer that another clock, or even its own clock a moment later after adjustment, defines a universal order. A replica can answer a health check while being isolated from the current majority. A successful write response may mean “accepted into memory,” “persisted locally,” “recorded by a quorum,” “applied to the state machine,” or “completed at an external system.” Those are different contracts.

When a distributed incident starts, use this first-thought sentence:

> A timeout, heartbeat failure, or reachable endpoint is an observation—not authority, truth, or proof of failure. Bind the operation, invariant, membership, version, quorum, committed state, applied state, and external effects before changing anything.

Here is the request path to keep in your head:

```text
user intent
   |
   v
operation ID -> invariant -> partition owner -> leader/epoch
                                                |
                                                v
                                      replicated log entry
                                                |
                              durable acknowledgements from quorum
                                                |
                                       commit -> ordered apply
                                                |
                              response / projection / external effect
```

Every arrow can delay, duplicate, fail, recover late, or be observed from a different point. Reliability comes from making each arrow's guarantee explicit.

## Terms before commands

By the end, you should be able to take a product claim such as “five replicas give high availability” and turn it into testable questions:

- Five voting replicas, or two voters plus three read copies?
- Placed in which independent failure domains?
- Which failures are assumed: crash, delayed message, data corruption, malicious actor?
- What number must acknowledge before a write is committed?
- What does “committed” mean in this product?
- Can a stale leader reach an external database or device?
- Which read operations are linearizable, causal, session-consistent, bounded-stale, or merely eventual?
- What happens to each user operation when a majority is unavailable?
- How are lagging or divergent replicas repaired?
- Which history or business check proves recovery?

Prerequisites are systems thinking, packet-path reasoning, and relational transaction foundations. You should already know that an application is a chain of state owners and queues; that packets can be delayed, lost, retransmitted or routed asymmetrically; and that a transaction boundary defines what one database can commit atomically. This lesson extends those ideas across independent machines.

Do not use this material as authorization to fault a shared system. The guided lab is deliberately offline. A real partition or clock experiment belongs only in a reviewer-owned disposable environment with a written blast radius and cleanup plan.

The mastery boundary is equally important: reading this chapter or passing its deterministic model is not evidence that you can operate a consensus cluster. Mastery requires an unseen history, a safe fault exercise, a changed constraint, and a reviewer who scores your reasoning and recovery.

## Architecture map

A distributed system is not “many servers.” It is independent state and computation joined by communication whose delay is significant and not perfectly predictable. Even two processes on one host can have distributed-system problems if they coordinate through messages, queues, files, or another state owner.

Start with six nouns:

1. **Operation** — what the user or controller wants: reserve stock, acquire leadership, update configuration.
2. **Invariant** — what must never become false: the last unit is not confirmed twice; only one current generation may program the device.
3. **Replica** — one stored or computed copy, with a role and known freshness.
4. **Protocol** — rules that turn messages and local state into decisions.
5. **History** — invocations and responses ordered by real time and causal relationships.
6. **Failure model** — the faults and timing behavior the protocol promises to handle.

Then separate safety and liveness:

- **Safety:** nothing forbidden happens. Two different values are not both chosen for one consensus position. A stale worker does not overwrite a newer result.
- **Liveness:** desired work eventually progresses under stated conditions. A healthy majority eventually elects a leader and commits work.

A system can preserve safety by stopping. That is why “unavailable during majority loss” may be correct behavior, not a reliability defect. A system can appear available while violating safety by letting isolated writers accept conflicting state. Your business operation determines which compromise is acceptable.

Do not describe a whole product as simply “consistent” or “available.” Write an operation table:

| Operation | Owner | Invariant | Acknowledgement | Read guarantee | Partition behavior |
|---|---|---|---|---|---|
| browse inventory | regional projection | freshness within declared objective | projection served revision | bounded stale | serve with age or degrade |
| reserve last unit | authoritative stock key | confirmations never exceed stock | conditional transition quorum-committed | linearizable | minority rejects |
| show own reservation | session view | accepted reservation is visible | at least returned revision observed | read-your-writes | wait, route, or say pending |

This table is more useful than arguing whether the service is “CP.”

## Request or state path

A protocol is correct only inside its assumptions. Saying “it handles failures” without naming them is like saying a bridge handles weight without stating how much.

Common failure classes:

- **Crash-stop:** a process stops and never returns in the same identity.
- **Crash-recovery:** a process stops, restarts, and may retain durable state while losing memory state.
- **Omission:** a message is lost, a send or receive is skipped, or storage fails to persist an operation.
- **Delay:** a message, process, disk, scheduler, garbage collector, or queue pauses for an unknown duration.
- **Partition:** communication succeeds within groups but fails or delays across groups long enough to affect the protocol.
- **Clock fault:** wall time steps, drifts, freezes, differs between nodes, or has larger uncertainty than assumed.
- **Corruption:** bits or logical state differ from what was written; checksums and replicated copies may share a bad source.
- **Byzantine behavior:** a component behaves arbitrarily, including contradictory or malicious messages. Ordinary Raft and Paxos crash-fault designs do not provide Byzantine fault tolerance.

The operational trap is an inaccurate failure detector. Suppose node A misses heartbeats from B. At least five realities fit:

```text
A isolated | B isolated | network congested | B paused | B crashed
```

A cannot distinguish them from silence alone. Timeouts let a protocol make progress assumptions; they do not convert uncertainty into fact. Practical consensus protocols preserve safety despite incorrect suspicions and regain liveness when communication becomes timely enough for long enough.

The FLP result is often misquoted as “consensus is impossible.” The useful operational reading is narrower: in a fully asynchronous model, a deterministic consensus algorithm cannot guarantee termination if even one process may crash. Real systems introduce timing assumptions, randomized elections, failure detectors, operator boundaries, and periods of eventual synchrony. They do not repeal uncertainty.

Write the failure model in an architecture decision:

```text
Handled: crash-recovery of up to two of five voters, temporary message loss,
delay and reordering, one failure-domain outage, bounded storage corruption
detection.

Not handled by protocol: malicious voters, three simultaneous voter losses,
shared credential compromise, correlated bad configuration, or external
state owners that ignore fencing.
```

That “not handled” list is not weakness. It tells engineers where controls, backups, isolation, and manual recovery must exist.

## Failure zoom

Replication places related state on multiple failure domains. It can improve read capacity, locality, durability, or availability, but each benefit requires a protocol. Five corrupted copies are not durable. Five replicas in one rack do not survive that rack. Five writable replicas without conflict rules can create five versions of truth.

Know the roles:

- A **voter** participates in decisions such as elections and commits.
- A **leader** or primary orders writes for a term or epoch in a leader-based protocol.
- A **follower** receives and persists the log; it may or may not serve reads.
- A **learner** or non-voter catches up without changing quorum size.
- A **read replica** serves some read contract but does not necessarily participate in write consensus.
- A **projection** is derived state rebuilt from an authoritative source.

Follow one replicated write:

1. The client sends a stable operation identity to the current leader.
2. The leader validates authority and appends a proposed entry in its current term.
3. Followers receive the entry and durably acknowledge according to the product's persistence contract.
4. When the commit rule is satisfied—commonly a majority plus protocol-specific term rules—the entry is committed.
5. Each replica applies committed entries in order to its deterministic state machine.
6. The leader replies at the documented boundary.

“Stored on the leader,” “replicated to a majority,” “committed,” and “applied everywhere” are not synonyms. Monitor at least:

```text
leader term=18 last_log=932 committed=930 applied=930
follower-a term=18 last_log=930 committed=930 applied=929
follower-b term=18 last_log=927 committed=927 applied=927
```

Follower A has the committed prefix but its state machine is one entry behind. Follower B has replication lag. A read served from either may violate a strong-read promise unless the product uses a supported barrier, revision, leader check, or waiting rule.

Asynchronous replication often acknowledges before every replica has the update. It reduces foreground latency but creates a loss or staleness window if the acknowledged copies fail. Synchronous replication waits for a defined set, increasing confidence at the cost of latency and possibly availability. “Synchronous” is still incomplete: which copies, which durable medium, which failure domains, and what happens when they are slow?

Replication is not backup. A mistaken delete, compromised credential, bad migration, or logical corruption can replicate successfully. Backups preserve separate historical recovery points, and restore testing proves they are usable.

Placement determines correlated risk. For five voters across three zones, a 2-2-1 layout survives any one zone if the other two can communicate. But adding voters is not free. More voters mean more write fan-out, more disks and networks in the tail, more membership operations, and sometimes no increase in tolerated failures. A three-voter majority is two; a four-voter majority is three, so both tolerate only one voter loss. Odd voter counts commonly use resources more efficiently for crash-fault majority systems.

## Internals and state ownership

Partitioning, or sharding, assigns subsets of data or work to owners. It improves scale when independent keys can progress independently. It does not remove coordination inside one invariant.

A good partition key:

- matches common access and transaction boundaries;
- spreads load and storage across owners;
- remains stable enough to route and recover;
- avoids unbounded growth on one key;
- does not expose sensitive information unnecessarily;
- permits controlled rebalancing.

Suppose inventory is partitioned by stock-keeping unit. Reservations for different items can proceed on different groups. Reservations for the last unit of one viral item still serialize on that item's invariant. Hashing the requests across 100 shards cannot make “sell at most one” independent. You can reduce read load, queue attempts, shed excess, or change the business rule with preallocated escrow. You cannot optimize away a shared correctness condition.

Three layers are often confused:

1. **Data partition:** which keys one replication group owns.
2. **Network partition:** which members can communicate right now.
3. **Failure domain:** which components may fail together—host, rack, zone, region, control plane, identity provider, or operator path.

Draw all three. A shard with three replicas in one zone has distributed processes but one zone failure domain. Two regional copies behind the same control-plane credential may share a security failure domain. A cross-region design can survive a site loss while suffering unacceptable quorum latency.

Rebalancing is a distributed transaction over ownership. Safe movement needs a generation or configuration identity, a source snapshot or log position, catch-up, an ownership cutover, client routing, stale-owner fencing, and cleanup. Copying data and changing DNS is not enough. During transition, ask:

- Can both owners accept writes?
- Which generation does the target validate?
- Do old and new quorums intersect?
- How does a client refresh stale routing?
- What proves no key was lost or duplicated?
- Can rollback preserve acknowledged work?

Consistent hashing reduces the number of keys remapped when membership changes. It does not by itself solve replication, quorum, hot keys, skew, cross-key transactions, or membership safety.

## Evidence table

Consistency describes which histories clients are allowed to observe. It is not the same as durability, isolation, convergence, or correctness of your business logic.

Use these distinctions:

- **Linearizability:** each operation appears to take effect atomically between invocation and response, respecting real-time order. If write A completed before read B began, B cannot return an older value.
- **Sequential consistency:** operations appear in one total order that preserves each client's program order, but that order need not respect real-time order between clients.
- **Serializability:** transactions are equivalent to some serial transaction order. Without a real-time constraint it is not automatically strict serializability.
- **Strict serializability:** serializable transactions plus real-time ordering; conceptually joins transaction isolation with linearizability.
- **Causal consistency:** causally related operations are observed in causal order; concurrent operations may be observed in different orders.
- **Eventual consistency:** if updates stop and communication/repair continue under assumptions, replicas converge. It says little about how stale a read can be before convergence.
- **Bounded staleness:** a read may trail by an explicit time, version, or operation bound.

Session guarantees make weaker systems usable:

- **read-your-writes:** a client sees its accepted updates;
- **monotonic reads:** once a client sees version 12, it does not later see version 9;
- **monotonic writes:** one client's writes are applied in its order;
- **writes-follow-reads:** a write based on a read is ordered after that read.

Do not infer a guarantee from endpoint choice. Reading from “the leader” can still be stale if the leader lost quorum and does not verify current authority, if apply lags commit, or if the implementation's read mode is weaker. Reading from a follower can be safe for a revision-aware request if the follower waits until it has applied that revision. Product documentation and history tests decide.

Translate a user statement into a model:

> “After I receive reservation confirmed, refreshing must show it.”

That might require a linearizable read, a session token carrying the committed revision, routing to a sufficiently current replica, or a UI that shows the accepted receipt while a projection catches up. “Use eventual consistency” does not answer the user contract.

Histories are the strongest evidence:

```text
10:00:00.000 invoke write(x=7) by client A
10:00:00.120 return  ok rev=42 to client A
10:00:00.150 invoke read(x, min_rev=42) by client A
10:00:00.190 return  x=6 rev=39
```

That history violates the stated minimum-revision contract. Metrics showing “replicas healthy” do not erase it.

## Command decoders

CAP is about a precise impossibility under communication failure, not a menu where a database permanently chooses two letters.

For an atomic read/write service, when communication partitions prevent components from learning one another's state, a component cannot both:

- always return a response; and
- always return a value compatible with the single-copy atomic history.

If one side accepted a completed write, the other isolated side cannot know whether that happened. It can wait or fail, preserving the strong guarantee, or answer with the risk of an incompatible value. A sufficiently long delay creates the same operational uncertainty as loss.

Three corrections keep CAP useful:

1. **Partition tolerance is not optional** when the network can fail. The design chooses operation behavior during the partition.
2. **Availability in the theorem is not “four nines.”** It is a liveness property requiring every request to eventually receive a non-error response from a non-failing node. Real systems use deadlines and degraded responses.
3. **Consistency means an atomic/linearizable-style single-copy contract in the theorem's formulation, not any use of the word consistency.**

Most real services segment choices. Browsing may serve stale projections. Payment capture may reject without authority. A profile update may accept concurrent versions and merge. Describe each operation.

PACELC adds the normal case:

```text
if Partition: choose Availability or Consistency for the operation
Else: trade Latency against Consistency even while the network works
```

A quorum across distant regions can preserve a stronger acknowledgment contract but add wide-area tail latency. A local asynchronous replica can answer faster but may be stale. This is not a theorem telling you one choice; it is a design prompt requiring measured latency, business risk, and failure behavior.

Spanner is a useful antidote to simplistic CAP claims. Its design combines consensus replication with explicit physical-time uncertainty to provide strong transaction semantics and high practical availability, but it still has assumptions, quorum requirements, failure behavior, latency, and unavailable cases. “CA database” is not an adequate description.

When someone says “the system is AP,” ask:

- Which operation?
- What response is guaranteed during which partition?
- What conflicting states may exist?
- How are they detected, merged, and reconciled?
- What user-visible invariant is weakened?
- What happens after communication heals?

## Decision path

A quorum is a subset large enough for a protocol decision. In a crash-fault majority system with `N` voters:

```text
majority = floor(N / 2) + 1
N=3 -> 2
N=5 -> 3
N=7 -> 4
```

Any two majorities intersect in at least one voter. That shared voter carries information between decisions, subject to the protocol's rules. This is why two disconnected components cannot both form a majority of the same fixed configuration.

For some quorum-register designs, a common condition is:

```text
W > N/2          prevents disjoint successful write sets
R + W > N        makes every read set intersect every write set
```

With `N=5`, `W=3` and `R=3` intersect. With `W=2` and `R=3`, equality is not enough; a two-member write set and a disjoint three-member read set can exist.

Do not turn the arithmetic into a universal proof. Linearizability also depends on how versions are selected, concurrent writes, coordinator failure, durable acknowledgements, membership, read protocol, and real-time order. Dynamo-style “sloppy quorums” may use temporary nodes outside a key's preferred replica set, so the symbols do not automatically mean intersecting fixed sets. Product semantics matter.

Availability arithmetic must include placement. Five voters tolerate two individual crash failures only if the remaining three can communicate and persist. If three share one power domain, that domain loss removes quorum. If a slow disk participates in every commit tail, nominal reachability may still miss user deadlines.

Never “fix” quorum loss by independently removing multiple unreachable voters or forcing a minority to become authoritative. Membership itself is consensus state. Unsafe changes can create two configurations that each believe they own the history.

Use a failure matrix before deployment:

| Fault | Remaining voters | Quorum? | Expected writes | Recovery owner |
|---|---:|---:|---|---|
| one process crash | 4/5 | yes | continue with degraded redundancy | automation/operator |
| one two-voter zone lost | 3/5 | yes | continue, protect repair capacity | incident team |
| three-voter side unreachable from client | client-dependent | quorum exists elsewhere | reroute; never use minority | network/service owner |
| only two voters mutually reachable | 2/5 | no | reject or read under documented weak mode | reviewed recovery |

Quorum protects agreement, not capacity. After losing two of five replicas, the surviving three must handle full load plus recovery. If that saturation triggers missed heartbeats, the failure can cascade.

### Consensus and replicated state machines

Consensus lets participants choose one value for a decision despite some failures. A consensus problem normally requires:

- **agreement:** correct participants do not decide different values;
- **validity:** the decided value comes from an allowed proposal;
- **termination:** participants eventually decide under the protocol's liveness assumptions.

A replicated state machine uses consensus repeatedly to agree on an ordered command log. If every replica begins with the same state and applies the same deterministic commands in the same order, it reaches the same state.

```text
log index     930             931                 932
command       create key      reserve item        cancel item
chosen term   17              18                   18
state after   key exists      available=0          available=1
```

Raft makes the operating path visible through terms, leader election, log replication, commitment, application and membership. Paxos decomposes agreement differently. Knowing the names is less important than tracing the implementation's safety rule accurately. Never mix a Raft commit rule, a generic `R/W/N` rule, and a database's acknowledgment setting as though they are interchangeable.

In a leader-based log:

1. Followers time out and one becomes a candidate in a higher term.
2. The candidate requests votes. A voter grants at most one vote per term and applies the protocol's log freshness rule.
3. A majority elects the leader.
4. The leader sends append operations, using previous log identity to find and repair follower divergence.
5. An entry becomes committed only according to the algorithm's commit rule.
6. Committed entries are applied in index order.

The distinction between **proposed**, **persisted**, **committed**, and **applied** prevents many incidents. A leader may contain uncommitted entries that disappear after a new leader is chosen. A follower may persist a committed entry but not yet apply it. A snapshot may compact old log entries without being a business backup.

Consensus protects the log, not everything around it. These can still fail:

- client receives no response after commit and retries with a new identity;
- a deterministic state machine calls a nondeterministic external API;
- a leader writes to a device that does not validate its epoch;
- a schema upgrade makes old replicas apply the same bytes differently;
- all voters replicate a destructive command;
- operators restore the wrong cluster identity;
- control-plane consensus is healthy while application data is unavailable.

Keep external effects outside deterministic log application unless the design provides an idempotent, fenced, reconcilable boundary. A common pattern records intent and stable identity in the consensus state, then a worker performs the effect; retries and ambiguous outcomes are reconciled against the target.

Consensus cost is visible. A write waits for leader processing, quorum communication and persistence, commit, apply policy, and response. Elections pause or redirect work. Large entries increase network, disk, snapshot and recovery costs. Slow or overloaded voters stretch tail latency. Put compact critical metadata in consensus stores; do not use them as unbounded blob or telemetry databases merely because they are reliable.

### Leader election, membership, and split brain

A leader is a protocol role for a term or epoch, not a permanent machine. A reachable old leader may be stale. A new leader may be elected while delayed messages from the old term still exist. Safety comes from term-aware voting, log rules, quorum intersection, client behavior, and fencing—not from a “leader=true” label.

During a five-voter 3/2 partition:

```text
component A: v1 v2 v3 -> can form majority 3 -> may elect and commit
component B: v4 v5    -> cannot form majority -> must not commit
```

If component B continues external writes based on an old lease, you have split authority even if the consensus log itself remains safe. That is why the whole request path matters.

Election tuning trades detection speed against false elections. A very short timeout detects a failed leader quickly but converts ordinary scheduler pauses, storage stalls, or network jitter into churn. A long timeout reduces churn but extends unavailability after genuine failure. Measure heartbeat round trips, disk latency, pauses, cross-domain tails and recovery objectives. Randomized election timeouts reduce repeated vote collisions; they do not solve saturated disks or broken routing.

Observe:

- current term or epoch and leader identity;
- election count and duration;
- leader changes correlated with latency, packet loss, CPU pauses and disk;
- last log, match, commit and applied indexes by replica;
- rejected stale-term messages;
- client redirection and retry behavior;
- time since last successful quorum commit.

Membership is part of the safety protocol. A naive change from old configuration `{A,B,C}` to new `{D,E,F}` can create disjoint majorities. Safe mechanisms use an algorithm that preserves overlap—such as joint configuration or a proven one-member-at-a-time scheme—while new members catch up.

Before a membership operation:

1. Prove cluster identity, current configuration, health and backups.
2. Add a learner/non-voter if supported and wait for bounded catch-up.
3. Change one reviewed membership step through the authoritative API.
4. Verify the committed configuration from a quorum, not one UI.
5. Test leader failure and client routing before removing recovery capacity.
6. Preserve an exact rollback or restore decision; never reuse stale data directories as a shortcut.

Do not confuse **split brain** with any partition. Split brain means more than one component acts as authoritative for state that requires one authority. A correct majority consensus system can experience a partition without split brain because the minority stops. Split brain often appears outside the consensus boundary: DNS routes to an isolated primary, a storage target accepts stale writes, or operators force two clusters.

### Time, clocks, ordering, and causality

Distributed systems need three different ideas of time.

**Wall clock** answers “what civil time label should appear?” It can step because of synchronization or manual change, drift, and disagree between hosts. Use it for human correlation, certificates, retention and business schedules with explicit uncertainty—not as an unquestioned order of truth.

**Monotonic clock** measures elapsed duration on one running system. It should not go backward when civil time adjusts. Use it for local timeouts, retry budgets and lease elapsed time when the implementation supports it. It does not directly compare two hosts.

**Logical clock** represents ordering derived from communication. Lamport's happened-before relation says:

- earlier events in one process happen before its later events;
- sending a message happens before receiving that message;
- the relation is transitive.

If neither `a -> b` nor `b -> a`, events are concurrent in this model. A Lamport counter can produce an order consistent with causality but cannot tell whether two events were concurrent. Vector clocks or version vectors retain more causal information by tracking per-participant progress, at metadata cost.

Example:

```text
client writes profile version {mobile:4, web:7}
mobile makes offline edit -> {mobile:5, web:7}
web makes concurrent edit -> {mobile:4, web:8}
```

Neither vector dominates the other, so the edits are concurrent. Choosing the largest wall-clock timestamp can silently discard one. The application needs field-level merge, a deterministic conflict rule, or human reconciliation.

Total order is not automatically causal correctness. A broker can assign partition offsets, but events in different partitions lack one global business order unless another protocol creates it. A trace timestamp helps investigation but clock skew can make a child appear before its parent. Use trace relationships, operation IDs, log indexes, terms, revisions and causal tokens alongside time.

Physical time can support stronger semantics when uncertainty is explicitly bounded and incorporated into the algorithm. Spanner's TrueTime design exposes an interval rather than pretending a clock reading is exact, then waits where necessary to preserve external consistency. The transferable lesson is not “synchronize NTP and use timestamps.” It is: make time uncertainty a first-class protocol input and fail safely when the bound is not trustworthy.

Clock monitoring should include offset, estimated error or uncertainty, synchronization source, leap/step events and monotonic-duration anomalies. Never change a host clock casually during a shared-system incident; certificates, leases, logs, databases and schedulers may all react.

### Leases, epochs, and fencing

A lease grants expected ownership for a limited duration. It can reduce repeated coordination, but it is not magic exclusion.

Imagine worker A holds a 30-second lease:

1. A pauses for 45 seconds because of scheduling or a runtime stop.
2. The coordinator expires A's lease and grants worker B generation 18.
3. B writes current output.
4. A resumes. Its local execution continues from before the pause.
5. If the output store accepts A's old write, B's correct work is overwritten.

Killing A is not a complete defense; the termination signal may be delayed, A may be isolated, or the side effect may already be in flight. A longer lease only increases how long recovery waits and still cannot eliminate pauses.

Use an **epoch** or **fencing token** that increases whenever authority changes:

```text
coordinator grants A token=17
coordinator later grants B token=18
target records highest accepted token=18
A resumes with token=17 -> target rejects stale generation
```

The target that owns the mutable resource must compare the token atomically with the write. Logging a token without enforcing it is observability, not fencing. Every external effect boundary—database row, object, device, job output, cloud resource—needs either fencing, a conditional version, an idempotent state transition, or a reconciliation design compatible with the invariant.

Lease safety requires explicit assumptions:

- how grant and renewal are committed;
- whether duration uses monotonic elapsed time;
- how clock drift or uncertainty is bounded;
- what happens during long pauses;
- how a client proves current epoch to the target;
- whether reads as well as writes require current authority;
- how the system behaves when renewal is ambiguous.

Kubernetes Lease objects are coordination records used for component heartbeats and leader election. The object does not automatically fence an arbitrary external system. A controller elected with a Lease must still make its reconciliation idempotent and protect effects from stale actors.

When diagnosing a lease incident, collect grant ID, holder, resource version, renew time, duration, observer clock evidence, process pause, epoch, target's highest accepted epoch, operation ID and output version. Do not infer authority from a recently printed renewal timestamp alone.

### Conflict detection, convergence, and repair

Systems that accept writes in multiple partitions need an answer for concurrent versions. “Eventually consistent” is an aspiration unless update propagation, version comparison, conflict resolution and repair are defined.

Version mechanisms include:

- a single authoritative log index or revision;
- per-key generation with conditional compare-and-set;
- Lamport timestamp plus tie-breaker for deterministic order;
- vector or dotted version information for causality;
- immutable event identity and aggregate sequence;
- application semantic versions such as cart item quantities by actor.

Conflict policies have consequences:

- **last-write-wins** is simple but depends on its ordering source and may discard valid concurrent work;
- **deterministic merge** converges only if the merge is associative, commutative and idempotent for the intended state;
- **CRDT-style data types** encode specific convergent operations but do not make arbitrary business invariants coordination-free;
- **application reconciliation** can preserve meaning but costs time, ownership and sometimes user involvement;
- **escrow/allocation** divides a bounded resource so partitions can act within assigned rights, shifting complexity into allocation and rebalancing.

Repair mechanisms:

- **hinted handoff:** temporarily store an update for an unavailable intended replica;
- **read repair:** compare versions during reads and update stale copies;
- **anti-entropy:** compare replica summaries or ranges and synchronize differences;
- **log catch-up:** stream missing ordered entries;
- **snapshot install:** replace a replica from a trusted point plus subsequent log;
- **business reconciliation:** compare derived or external state with authoritative intent.

Repair consumes the same CPU, disk and network resources as user traffic. An aggressive repair after a zone returns can overload leaders, increase commit latency, trigger elections and make recovery worse. Set concurrency, bandwidth and I/O budgets; prioritize quorum health; retain failure headroom; and measure time to convergence.

Before deleting or rebuilding a divergent replica, preserve:

- cluster and member identity;
- configuration, term/epoch and log boundaries;
- committed and applied indexes;
- checksums or version summaries;
- user-operation receipts and ambiguous effects;
- snapshot identity and source;
- the exact supported recovery procedure.

Never merge consensus logs by picking files with newer timestamps. Determine the majority-committed history through the product's protocol and supported tools. A divergent minority may contain uncommitted proposals or unique external effects; the former must not become truth, while the latter may still require business reconciliation.

### Operability: capacity, observability, security, and cost

The distributed algorithm is one part of the service. Operators need an envelope in which its safety assumptions and user objectives remain practical.

Start with user signals:

- correctness violations and ambiguous operations;
- success, rejection and timeout by operation;
- latency by consistency mode and failure state;
- freshness or served revision;
- availability during ordinary, degraded and recovery periods.

Then connect protocol signals:

```text
user timeout
  -> client route/retry/deadline
  -> leader and term
  -> quorum reachability
  -> proposal/commit/apply index
  -> disk/network/CPU queue
  -> external effect receipt
```

Do not alert on leader changes alone. An intentional rolling change may elect once without user impact. Alert when election rate, time without a leader, time without quorum commit, commit/apply lag, request failures or user latency threaten an objective. A useful dashboard lets the incident lead answer:

1. Is safety suspected, or only liveness/performance?
2. Which configuration and term are authoritative?
3. Can a majority communicate and persist?
4. Is the leader accepting, committing, and applying?
5. Are clients routed to a valid path?
6. Did any external effect escape under a stale epoch?
7. Is repair consuming failure headroom?

Capacity is failure capacity, not average capacity. If five voters lose two, the remaining three need to process peak foreground traffic, replication, snapshots, repair, monitoring and operator queries without losing heartbeats. Model:

```text
surviving useful capacity
  >= peak admitted foreground work
   + protocol overhead
   + bounded repair
   + recovery reserve
```

Queue or shed work before the consensus group saturates. Client retries multiply proposals and can turn a slow quorum into collapse. Use one retry owner, stable operation identity, exponential backoff with jitter, attempt limits, an overall deadline and admission control.

Security changes the failure model. Crash-fault consensus assumes members follow the protocol; a compromised voter, stolen recovery credential or malicious operator can violate that assumption. Use mutually authenticated encrypted transport, unique member identities, least-privilege runtime roles, separate membership/restore authority, protected keys, audited force operations, artifact verification and secret rotation that preserves quorum. Network membership is not user authorization.

Data minimization applies to logs, snapshots, traces and conflict siblings. A repair dump can expose the whole keyspace. Protect diagnostic artifacts, redact payloads while retaining identities and revisions, set retention, and record access.

Cost is part of the design:

- voter and read-replica compute;
- replicated storage and write amplification;
- cross-zone/region bytes and quorum latency;
- snapshot, backup and retained-log storage;
- repair headroom and idle failure capacity;
- telemetry cardinality and retention;
- test environments and operator time;
- complexity cost of custom conflict handling.

A cheaper three-node regional group may meet one service's objectives better than a five-region design. A managed service may reduce some operating work but does not outsource your operation semantics, client behavior, data validation, recovery objectives or vendor failure model.

Run controlled game days in a representative disposable environment:

- one follower crash and recovery;
- current leader crash;
- delayed/lost communication between selected members;
- majority loss and safe refusal;
- slow or full disk;
- lagging replica catch-up and snapshot;
- rolling version and membership change;
- clock offset or process pause through a harness, never an uncontrolled host-clock mutation;
- backup restore with cluster-identity and business validation;
- stale actor attempting a fenced external write.

Record the hypothesis, blast radius, abort signals, exact fault, user impact, protocol evidence, recovery, cleanup and gaps. Fault injection without a business assertion is theater.

## Guided Ubuntu lab

The included lab is intentionally small. It does not implement messages or consensus. It turns architecture claims into a deterministic decision order so you learn to name the first broken guarantee.

From Ubuntu 24.04, enter:

```bash
cd drafts/LES-0058-distributed-systems-foundations/support/lab
bash lab.sh doctor
```

Expected:

```text
doctor=pass runtime=offline-distributed-boundary-model
```

`doctor` refuses root, a non-Ubuntu 24.04 host, cloud/database/Kubernetes credential hints, or missing Python. It does not install anything. Next:

```bash
bash lab.sh setup
bash lab.sh status
```

Expected shape:

```text
fixture=valid cases=13
setup=pass state=/tmp/reliability-atlas-les0058-distributed-<uid> network=none
status=ready cases=13 network=none
```

Setup creates one mode-0700 directory tied to your numeric user ID, a sentinel and a copied fixture. The guard validates path, type, owner, symlinks and exact inventory before every action.

Run the healthy model:

```bash
bash lab.sh evaluate baseline
```

Expected:

```text
case=baseline decision=operable boundary=operable
```

This proves only that the synthetic case satisfies the model's declared checks. Now work outward:

```bash
bash lab.sh evaluate quorum-loss
bash lab.sh evaluate unsafe-quorums
bash lab.sh evaluate dual-writer
bash lab.sh evaluate isolated-old-leader
```

Expected boundaries:

```text
quorum-loss
quorum-intersection
split-brain
stale-leader
```

Read the distinction aloud:

- **quorum loss:** too few configured voters can participate in a write decision;
- **quorum intersection:** selected read/write sizes can be disjoint;
- **split brain:** the design permits concurrent authority;
- **stale leader:** a reachable previous authority no longer has current quorum.

Continue:

```bash
bash lab.sh evaluate wall-clock-lease
bash lab.sh evaluate expired-worker-no-fence
bash lab.sh evaluate missing-causal-token
bash lab.sh evaluate stale-linearizable-read
```

The first catches unsafe local-duration measurement, the second catches a target that accepts stale generations, the third catches missing dependency context, and the fourth binds a promised strong read to the required versus served revision.

Inspect a case:

```bash
bash lab.sh show expired-worker-no-fence
```

Change only the copied fixture in `/tmp` for an exercise. Do not weaken `model.py` to make a case pass. Ask what design fact must change, then predict which later boundary becomes visible.

Run the complete verifier from an absent state:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected:

```text
verify=pass cases=13 refusal=true cleanup=true
```

The verifier evaluates thirteen paths, injects an unexpected file, proves the guard refuses it, removes only that exact file, and proves the UID-scoped state is absent. If cleanup fails, stop and inspect; do not use recursive deletion.

Independent lab design:

1. The reviewer provides a disposable three- or five-member cluster or a history simulator with synthetic data.
2. You document the invariant, failure assumptions, membership and operation guarantees before starting.
3. Establish baseline histories for a write, a strong read and a weaker read.
4. Inject one approved leader loss; prove election, committed-prefix preservation and client behavior.
5. Inject one approved 2/1 or 3/2 communication partition; prove minority refusal and majority progress.
6. Pause a lease holder, replace it, then resume the old holder against a fencing-aware target; prove stale rejection.
7. Create lag, bound repair, and prove convergence without destroying foreground SLOs.
8. Reconcile every ambiguous operation and validate business state.
9. Restore exact host and harness state and have the reviewer verify cleanup.

Passing the offline lab does not satisfy this independent exercise.

## Production transfer

Use the same investigation order during every distributed-state incident.

**1. Bind the user operation.** Capture logical operation ID, invocation/response times, deadline, endpoint, acknowledgement, expected invariant, required revision and observed value.

**2. Bind identity and configuration.** Record cluster ID, current and previous membership, voter roles, failure domains, software/config versions and recent changes.

**3. Build reachability as a matrix.** “Network is up” is meaningless. Test or inspect member-to-member communication in both directions at the relevant protocol and time.

**4. Separate leadership from authority.** Record terms/epochs, votes, leader identity, quorum reachability, committed index and applied index from multiple members.

**5. Inspect resources.** Disk latency/fullness, CPU pauses, memory pressure, network loss, queues and clock state can appear as elections.

**6. Trace external effects.** Find fencing generations, target receipts and ambiguous operations that exist outside the replicated log.

**7. Contain safely.** Stop minority or stale writes, bound retries and repair, preserve evidence, protect the surviving quorum and communicate degraded semantics.

**8. Recover through supported state transitions.** Catch up or replace members, preserve membership safety, route clients correctly and reconcile business effects.

**9. Verify at three levels.** Protocol convergence, application state, and real user operation. Then prove cleanup and update the runbook.

### Incident A: both health endpoints are green

Do not choose a winner by health status. Ask each component for cluster/configuration identity, term, leader, quorum and commit/apply indexes. In a 3/2 partition, preserve the three-voter majority and fence the minority. If both sides mutated an external store, consensus repair alone is insufficient; reconcile those effects.

### Incident B: successful write, stale refresh

Bind the write receipt revision and the read's source/served revision. The defect may be follower apply lag, stale routing, missing session token, an isolated leader, projection delay, or a contract that never promised read-your-writes. Fix the promise or implementation; do not silently rename a surprise as “eventual.”

### Incident C: elections during repair

Correlate election events with disk latency, repair bandwidth, snapshot generation, CPU throttling and heartbeat tails. Throttle repair, protect foreground quorum capacity, and restore redundancy one domain at a time. Adding retrying clients or maximum repair parallelism worsens the feedback loop.

### Incident D: conflicting values after heal

Preserve siblings and version metadata. Determine whether one causally dominates or they are concurrent. Apply the declared semantic merge or reconciliation; do not use largest wall timestamp unless the system explicitly guarantees the clock/order rule and the business accepts lost concurrent updates.

Interview question: **“Explain CAP.”**

Strong answer: “For an atomic read/write-style service during a communication partition, an isolated component cannot guarantee both a correct single-copy response and a response to every request. I apply that at operation scope. A critical conditional write may reject without quorum, while a cached browse read may serve bounded-stale data. Outside partitions, PACELC reminds me that stronger coordination can cost normal tail latency. I would state the consistency model, acknowledgement, degraded behavior and reconciliation rather than label the whole product CP or AP.”

Weak signs: “Pick any two,” treating partition tolerance as a feature switch, calling five-nines availability CAP availability, or never mentioning an operation.

Senior follow-up: **“If R + W > N, is it linearizable?”**

Strong answer: “Intersection is a useful necessary condition for some quorum-register protocols, not a standalone proof. I also need write serialization/version rules, concurrent-operation handling, durability, fixed or safely changing membership, read selection, failure behavior and real-time ordering. Sloppy quorums or temporary replica sets can change the intersection assumption.”

Interview question: **“Why do we need fencing if we already have a lease?”**

Strong answer: “Lease expiry lets the coordinator grant a replacement, but the old actor may be paused or isolated and later resume. A monotonic fencing generation carried to and atomically validated by the target makes old authority harmless. Killing the process or lengthening the lease does not prove stale messages or actors cannot write.”

Interview question: **“Can clocks order distributed events?”**

Strong answer: “Wall clocks label events but have drift, offset and adjustments. Monotonic clocks measure local durations. Logical clocks encode happened-before; vector-style metadata can distinguish causality from concurrency. Strong physical-time designs expose and respect uncertainty. I would not elect truth by the largest timestamp without a justified time and conflict model.”

Interview question: **“How many nodes should a consensus cluster have?”**

Strong answer: “Enough voters to tolerate the required independent failures while meeting latency, capacity and cost objectives. Three tolerates one crash, five tolerates two, assuming placement and communication preserve a majority. Four still tolerates one and adds quorum cost, so odd voter counts are common. I also size surviving capacity, failure domains, learners/read replicas, and recovery.”

## Reliability, security, observability, capacity, and cost

Review the whole system with one table rather than separate dashboards:

| Concern | Design question | Runtime evidence | Unsafe shortcut |
|---|---|---|---|
| reliability | which invariant survives each modeled fault? | operation history, committed revision, user result | count replicas |
| security | who may join, vote, restore, force, or mutate? | peer identity, authorization and audit decision | trust the network |
| observability | can one operation be traced through commit and effect? | operation ID, term, index, target receipt | correlate only by time |
| capacity | can a surviving quorum serve peak plus repair? | queue, disk, network, lag and tail latency | size for averages |
| cost | which failure tolerance is purchased? | voters, bytes, storage, telemetry and labor | maximize replicas |

Create separate SLOs where user consequences differ. A leader-election duration is a mechanism metric. “Reservation requests remain correct and 99.9% complete within the objective” is a user reliability statement. Freshness needs its own signal when weak reads are intentional.

For security, assume a stolen recovery credential can bypass normal protocol safeguards. Membership, snapshot restore, force-new-cluster, clock administration and fencing-target policy deserve stronger separation and audit than ordinary reads. A backup is a high-value copy; encrypt it, control its readers, verify provenance, and restore only into an isolated identity until validation succeeds.

For capacity, test failure and recovery together. Healthy peak load plus one unavailable domain plus follower catch-up is more revealing than a no-fault throughput record. Abort a test when user correctness, quorum, host isolation, or cleanup becomes uncertain.

For cost, compare at least two valid designs. A regional majority with asynchronous remote recovery may offer lower latency and cost with a larger regional-loss RPO. A multi-region quorum may reduce acknowledged-loss exposure while increasing normal tail latency, transfer cost and dependency surface. The correct choice comes from the business objectives and measured envelope.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “The endpoint is reachable, so it is leader.” | isolation can leave an old role answering | verify current term, quorum and fencing |
| “Timeout means rollback.” | commit or effect may have completed | stable operation ID plus authoritative reconciliation |
| “Five replicas tolerate any two failures.” | placement, roles, reachability and capacity differ | failure-domain and surviving-capacity matrix |
| “R plus W greater than N proves consistency.” | protocol, membership, versions and concurrency still matter | name guarantee and test histories |
| “Use the newest timestamp.” | clocks and concurrent meaning may disagree | causal/version rule plus business merge |
| “A lease prevents two workers.” | an expired worker can resume | target-enforced monotonic fencing |
| “Repair as fast as possible.” | repair can starve quorum traffic | bounded repair with abort thresholds |
| “Restore the latest replica directory.” | it may have wrong identity or uncommitted history | supported snapshot/log recovery and validation |
| “Consensus means no data loss.” | bad commands and external effects still exist | backups, idempotency, fencing and reconciliation |
| “Eventual means a few seconds.” | no bound follows from the word | explicit freshness objective and convergence evidence |

Preventive design reviews should force one sentence for every acknowledgement: “When the caller receives this response, exactly ___ is durably true, and if the response is lost the caller can discover the result by ___.” If the blanks cannot be filled, the retry and recovery contract is not finished.

## Memory card and retrieval

Close the page and reconstruct this card:

```text
OPERATION -> INVARIANT -> OWNER -> FAILURE MODEL
          -> CONSISTENCY -> QUORUM/ORDER -> ACKNOWLEDGEMENT
          -> EPOCH/LEASE -> FENCING -> REPAIR -> USER PROOF
```

Five retrieval prompts:

1. What does a timeout prove? Only that the observer's deadline expired.
2. What does quorum intersection contribute? Information overlap between decisions.
3. What is the difference between commit and apply? Chosen order versus executed state.
4. Why is a fencing token stronger than process termination? The target rejects stale authority even if it resumes.
5. What completes recovery? Protocol convergence, business reconciliation, user validation, and cleanup.

Repeat the card after one day and one week using a new scenario. Delayed recall is evidence of retention; rereading fluency is not.

## Complete answers

Answer these before revealing the guidance.

**1. A client times out after a write. Did the write fail?**

No conclusion is justified. The request may not have arrived; it may be proposed but uncommitted; committed but not applied; applied but the response was lost; or completed at an external target while bookkeeping failed. Reuse one logical operation identity, query an authoritative receipt or state, and reconcile before retrying. A timeout is ambiguity, not rollback.

**2. Why can a correct minority be unavailable?**

Because it cannot distinguish “the majority elected a new leader and committed a newer value” from “messages are merely delayed.” Returning a strong answer or accepting a write could contradict the majority's history. Rejecting protects safety until authority can be proved.

**3. Why does five replicas not always survive two failures?**

The five may not all be voters, the failures may remove three through one shared domain, remaining members may not communicate, disks may be unhealthy, latency may exceed deadlines, or surviving capacity may collapse under load and repair. Count roles, placement, reachability, persistence and capacity—not icons.

**4. What is the difference between commit and apply?**

Commit means the protocol has chosen an ordered log entry according to its safety rule. Apply means a replica's state machine has executed committed entries up to an index. A replica can know entry 42 is committed while its materialized state is still at 39. Read semantics must account for that gap.

**5. Does eventual consistency mean “data becomes correct after a few seconds”?**

No. It generally describes convergence if updates stop and communication/repair continue under assumptions. It does not state a universal time bound, conflict semantics, session behavior or business correctness. Add a measurable freshness objective, version/merge rules and repair evidence.

**6. When is last-write-wins acceptable?**

Only when the ordering source is trustworthy enough for the stated model and discarding concurrent updates matches the business rule. It may fit refreshable cache metadata; it is dangerous for balances, reservations or independent profile edits. State which update may be lost and why that is acceptable.

**7. How do you prove a distributed design?**

You do not prove it from one green dashboard. Combine protocol review, invariants, formal or model checking where warranted, history-based consistency tests, deterministic state-machine tests, fault injection in representative disposable environments, capacity tests, restore/reconciliation exercises and production observability. Each proves a boundary and has limitations.

Practical architecture exercise:

Create a design packet for a global job scheduler. Include:

- job state machine and exactly which transitions may occur once;
- partition key and fairness/hot-key handling;
- voter placement, quorum and majority-loss behavior;
- leader election, membership and client routing;
- lease duration assumptions plus fencing at every execution target;
- operation IDs and ambiguous submission reconciliation;
- linearizable versus weaker reads;
- capacity during one failure domain loss;
- repair, backup, restore and business validation;
- security roles, audit, cost and a fault matrix.

Then change one constraint: jobs now control physical equipment and stale execution can cause harm. Your design should become stricter at the target: hardware or its gateway must validate generations, safe shutdown behavior must exist, credentials must be isolated, and ambiguity may require human authorization. Adding a longer timeout is not sufficient.

Keep these wisdom sentences:

- Replicas are copies; the protocol tells you what the copies mean.
- A timeout is uncertainty; an operation receipt resolves uncertainty.
- Reachability is not authority; quorum and epoch establish authority.
- A lease says who should be current; fencing makes stale actors harmless.
- A timestamp labels an observation; it is not automatically truth.
- CAP is a partition-time impossibility at operation scope, not a product personality.
- Quorum arithmetic is necessary evidence, not a complete consistency proof.
- Recovery is incomplete until protocol state, business state and user behavior agree.

The next state lessons build on this foundation: NoSQL and cache access patterns, queues and streams, and workflow coordination. In each, ask the same questions—who owns the invariant, what acknowledgement means, what happens under partition, which ordering exists, how duplicates or conflicts converge, and what evidence proves repair.

## Product-company interview

**System design prompt:** Design a globally available feature-flag control plane whose flags affect safety-critical workloads.

A strong answer begins by separating authoring, authoritative state, distribution and evaluation. Flag publication needs stable identity, schema, validation, authorization, audit and a quorum-committed revision. Regional agents can consume a signed or authenticated ordered snapshot/log and evaluate locally for low latency. The data plane needs an explicit last-known-good and expiry policy; “always available” cannot mean applying an untrusted or partially written flag. Safety-critical flags may fail closed, while cosmetic flags may retain a bounded-stale value. Rollout cohorts, monotonic revision, rollback-as-a-new-revision, fencing of publishers, watch lag, agent freshness and user effect are observable. Recovery proves the authoritative revision, distribution convergence and workload behavior. The answer should compare a multi-region quorum with regional authority plus controlled promotion, including tail latency, isolation behavior and operator complexity.

Weak signs are “put it in Redis,” relying on wall-clock last-write-wins, letting every region write the same flag without conflict policy, or describing control-plane health without workload evaluation.

**Troubleshooting prompt:** A three-member cluster loses one follower; writes succeed but become slow. When the follower returns, elections begin.

A strong answer correlates quorum-write latency with the remaining follower's disk/network tail, then correlates the returning member's log or snapshot catch-up with leader disk, network, CPU and heartbeat delay. It preserves the healthy majority, bounds catch-up, controls client retries, checks commit/apply indexes and user latency, and restores redundancy without repeatedly restarting members. It does not assume “three nodes means one failure is free”; two surviving nodes now form the entire quorum and have no further margin.

**Staff-level follow-up:** When would you deliberately use weaker consistency?

When the operation's invariant tolerates it and the availability/latency benefit is material. Examples may include recommendations, browse projections, presence, telemetry aggregation or independently mergeable preferences. The answer must still define staleness, session behavior, conflict semantics, deletion/privacy behavior, repair, user communication and a path for operations that require stronger coordination.

What the interviewer evaluates:

- whether you start from invariants rather than products;
- whether failure assumptions and unavailable cases are explicit;
- whether you separate replication, consensus, consistency and backup;
- whether time, leases and external effects are handled correctly;
- whether recovery includes business and user proof;
- whether you can change the design when latency, geography, cost or safety changes.

## Independent transfer and rubric

The answer-isolated assessment `ASM-0159` is the mastery gate for this lesson. The reviewer supplies an unfamiliar topology, operation history and sanitized fault packet. You may use primary documentation, but you must not use a model answer or modify a live system.

Produce:

1. operation/invariant/acknowledgement table;
2. failure and timing assumptions, including what cannot be distinguished;
3. state ownership, partition, role, membership and failure-domain map;
4. consistency and session guarantee per operation;
5. quorum, leader, commit, apply and client trace;
6. clock, lease, epoch and fencing analysis;
7. conflict and repair mechanism;
8. incident timeline, containment and ambiguous-effect reconciliation;
9. capacity, latency, security, observability and cost envelope;
10. revised design after the reviewer changes one major constraint.

The ten rubric dimensions are worth ten points each. A score is evidence only when the reviewer observed the unfamiliar work, safety decisions, cleanup and changed-constraint reasoning. Repository content, the offline model, self-scoring or a revealed answer cannot award mastery.

Minimum qualitative standard:

- **unsafe:** changes membership, clocks, networks or state before binding identity and blast radius;
- **developing:** names concepts but cannot connect them to one operation history;
- **operational:** preserves evidence, calculates quorum, restores supported state and validates the user path;
- **senior:** exposes assumptions and non-guarantees, fences external effects, budgets recovery and compares alternatives;
- **expert transfer:** adapts coherently when the reviewer changes a fundamental constraint and identifies new failure modes without prompting.

Repeat a different scenario after a delay. A one-time rehearsed answer does not prove durable transfer.

## References and review

The reference records `REF-0628` through `REF-0642` are stored beside this lesson. They include foundational papers for CAP, PACELC, happened-before, Raft, Paxos, FLP, Dynamo and Spanner; official etcd API/failure documentation; Kubernetes Lease documentation; Google SRE operational consensus guidance; AWS leader-election guidance; and a consistency-model map.

Use them by question:

- CAP/PACELC and safety/liveness: `REF-0628`, `REF-0629`;
- causality and clocks: `REF-0630`, `REF-0635`, `REF-0642`;
- agreement and liveness assumptions: `REF-0631`, `REF-0632`, `REF-0633`;
- availability-oriented conflicts and repair: `REF-0634`;
- operation-level production guarantees: `REF-0636`, `REF-0637`;
- leases and operational leadership: `REF-0638`, `REF-0639`, `REF-0640`;
- consistency terminology: `REF-0641`.

Primary papers define models, not universal product behavior. Official documentation is versioned and configuration-dependent. Before operating a product, verify its exact release, persistence settings, read mode, membership procedure, failure guidance and backup/restore contract.

Review limitations:

- the Python model has no messages, nondeterminism or state exploration;
- it cannot prove consensus safety, linearizability or convergence;
- no network, process, clock, disk, replica, leader, external target or real user is involved;
- passing each branch proves only deterministic fixture behavior;
- authoritative URLs resolved during the 2026-08-05 review, but content can change;
- formal technical/editorial review, representative disposable-cluster evidence, independent transfer and delayed recall remain open.

When extending the lesson, add a reference only if it resolves a real instructional claim. Do not turn the bibliography into an unexplained link dump.
