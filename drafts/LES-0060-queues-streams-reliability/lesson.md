---
{"schemaVersion":1,"kind":"lesson","id":"LES-0060","slug":"queues-streams-reliability","aliases":["V06-L05","queues-streams-reliability"],"curriculumIds":["DST-004"],"route":"/book/state/queues-streams-reliability","order":5,"volume":"06-state-distributed-systems","title":"Queues and streams reliability: own delivery, order, backlog, and replay","summary":"Design and operate brokers, queues, logs, partitions, consumer groups, acknowledgements, checkpoints, retries, dead letters, retention and replay without false exactly-once claims.","domain":"state","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0057","LES-0058","LES-0059"],"prerequisiteCurriculumIds":["DST-001","DST-005"],"testedEnvironments":[{"platform":"Official documentation","version":"Apache Kafka 4.3, current RabbitMQ and NATS JetStream sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, broker or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","backend-engineer","cloud-engineer","data-platform-engineer","solutions-architect","technical-lead"],"learningObjectives":["Choose queue, publish/subscribe or retained-log semantics from fan-out, replay, ordering and recovery needs.","Trace one event through producer, partition, broker acknowledgement, replication, consumer effect and checkpoint.","Define publisher and consumer acknowledgement meanings without confusing receipt, durability and business completion.","Use stable event identity across ambiguous producer retries.","Choose partition keys from ordering scope, then test skew and hottest-partition capacity.","Explain groups, assignments, rebalances, offsets, prefetch and in-flight work as separate boundaries.","Place effects, deduplication and checkpoints so crash windows are recoverable.","Distinguish delivery semantics from end-to-end business exactly-once claims.","Bound poison retries, quarantine ownership, redrive and reconciliation.","Calculate backlog growth, drain time, retention horizon and recovery headroom.","Plan replay with isolated effects, versioned code, rate limits and reconciliation.","Diagnose duplicates, gaps, lag, hotspots, rebalance storms, replica loss and replay damage."],"productionSignals":["user correctness duplicate missing-effect latency and ambiguity","operation ID event ID schema key attempt deadline","record and batch bytes compression and serialization failures","publish attempts errors retries throttling and acknowledgement latency","broker leader epoch partition position and acknowledgement contract","partition count replication membership leader and in-sync state","append/fetch records bytes segments storage retention and cleanup","key cardinality top key and hottest-partition demand","consumer identity assignment generation epoch and member state","end processed committed positions and time/record/byte lag","poll fetch prefetch in-flight handler and dependency time","redelivery duplicate detection retry age and acknowledgement timeout","poison signature attempt budget quarantine age and owner","effect ID dedupe result external response and checkpoint","rebalance count duration revoked work and stale-owner rejection","ingress service rate backlog oldest age drain estimate and headroom","retention remaining versus outage rebuild and replay horizon","authentication authorization encryption privacy and audit evidence","replay range code/config output namespace rate and reconciliation","broker/client CPU memory disk network descriptors and cost"],"diagrams":[{"id":"LES-0060-DIA-001","title":"End-to-end message ownership path","direction":"left-to-right","boundaries":["business transaction","producer/outbox","serializer and partitioner","broker and replicas","consumer assignment","idempotent effect","checkpoint and user proof"],"evidencePoints":["operation ID","event/schema","key","ack/position","generation","effect ID","checkpoint"],"textAlternative":"One stable event crosses a named broker acknowledgement, one current consumer owner, a recoverable effect and a checkpoint after that effect."},{"id":"LES-0060-DIA-002","title":"Queue and retained-log ownership","direction":"hierarchical","boundaries":["publisher","work queue","competing workers","retained partitioned log","independent groups","replay readers"],"evidencePoints":["routing key","delivery tag","owner","offset","group position","retention"],"textAlternative":"A queue distributes work while a retained log preserves partitioned records for independent positions and replay."},{"id":"LES-0060-DIA-003","title":"Partition-local ordering path","direction":"left-to-right","boundaries":["entity invariant","stable key","partition function","leader","ordered offsets","active owner"],"evidencePoints":["entity","key","partition","epoch","offset","generation"],"textAlternative":"A stable key keeps one invariant on one ordered partition; separate partitions do not form a global order."},{"id":"LES-0060-DIA-004","title":"Producer acknowledgement and replication","direction":"hierarchical","boundaries":["producer attempt","network ambiguity","leader append","replica agreement","publisher acknowledgement","same-ID retry"],"evidencePoints":["attempt","deadline","epoch","required replicas","ack","event ID"],"textAlternative":"An ambiguous timeout requires a same-identity retry; acknowledgement and replication define only a broker boundary."},{"id":"LES-0060-DIA-005","title":"Effect and checkpoint crash windows","direction":"left-to-right","boundaries":["delivery","dedupe","business effect","effect durability","checkpoint","redelivery"],"evidencePoints":["event ID","dedupe","effect ID","commit","position","redelivery"],"textAlternative":"Checkpoint-before-effect loses work; effect-before-checkpoint can duplicate, so stable identity and idempotent or atomic effects are required."},{"id":"LES-0060-DIA-006","title":"Backlog and recovery envelope","direction":"hierarchical","boundaries":["ingress","partition distribution","service rate","outage backlog","spare drain","retention","user recovery"],"evidencePoints":["input rate","hot partition","output rate","oldest age","drain time","horizon","SLI"],"textAlternative":"Recovery needs partition-local service above ongoing ingress, enough retention and dependency headroom."}],"commands":[{"id":"LES-0060-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0060 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"broker behavior"},{"id":"LES-0060-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"queue or topic setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0060-CMD-003","question":"Does the baseline cross every boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0060 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect first boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0060-CMD-004","question":"Is publisher acknowledgement explicit?","risk":"read-only","command":"bash lab.sh evaluate ambiguous-publisher-ack","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=publisher-ack","meaning":"durable boundary is unspecified","nextEvidence":"name each acknowledgement"}],"proves":"encoded ack gap","doesNotProve":"durability"},{"id":"LES-0060-CMD-005","question":"Can redelivery repeat an effect?","risk":"read-only","command":"bash lab.sh evaluate non-idempotent-effect","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=consumer-duplicate","meaning":"one event can effect twice","nextEvidence":"stable ID and idempotent effect"}],"proves":"encoded duplicate gap","doesNotProve":"downstream behavior"},{"id":"LES-0060-CMD-006","question":"Can checkpoint timing lose work?","risk":"read-only","command":"bash lab.sh evaluate checkpoint-before-effect","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=effect-loss","meaning":"position advances first","nextEvidence":"checkpoint after recoverable effect"}],"proves":"encoded loss window","doesNotProve":"transaction correctness"},{"id":"LES-0060-CMD-007","question":"Can poison work loop forever?","risk":"read-only","command":"bash lab.sh evaluate poison-unbounded","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=poison-loop","meaning":"no terminal attempt budget","nextEvidence":"bound and quarantine"}],"proves":"encoded retry gap","doesNotProve":"message validity"},{"id":"LES-0060-CMD-008","question":"Can backlog drain in time?","risk":"read-only","command":"bash lab.sh evaluate backlog-no-drain","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=backlog-drain","meaning":"spare capacity is insufficient","nextEvidence":"change demand capacity or objective"}],"proves":"encoded drain arithmetic","doesNotProve":"measured rate"},{"id":"LES-0060-CMD-009","question":"Is one partition overloaded?","risk":"read-only","command":"bash lab.sh evaluate hot-partition","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=hot-partition","meaning":"aggregate headroom hides a hotspot","nextEvidence":"fix key or local capacity"}],"proves":"encoded hotspot","doesNotProve":"partitioning"},{"id":"LES-0060-CMD-010","question":"Does retention cover recovery?","risk":"read-only","command":"bash lab.sh evaluate retention-too-short","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=replay-horizon","meaning":"input expires too soon","nextEvidence":"govern retention or another source"}],"proves":"encoded horizon mismatch","doesNotProve":"stored records"},{"id":"LES-0060-CMD-011","question":"Can a revoked consumer write?","risk":"read-only","command":"bash lab.sh evaluate rebalance-no-fence","runFrom":"LES-0060 support/lab","expectedBranches":[{"when":"boundary=stale-consumer","meaning":"ownership is not fenced","nextEvidence":"enforce epoch at effect owner"}],"proves":"encoded stale-owner gap","doesNotProve":"protocol behavior"},{"id":"LES-0060-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0060 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"sixteen branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"Kafka RabbitMQ NATS network replication storage delivery or replay","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0060-LAB-001","title":"Guided queue and stream boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0060-queues-streams-reliability/support/lab"},{"id":"LES-0060-LAB-002","title":"Independent broker, duplicate, backlog, poison and replay transfer","mode":"independent","environment":"Reviewer-owned disposable local broker or history simulator with synthetic events","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic broker state","disposable producers consumers and effects","approved faults","reconciliation artifacts"],"abortConditions":["shared broker","real credential","customer data","host network/clock mutation","unbounded replay","unknown cleanup"],"recovery":"Preserve histories and reset through the reviewer harness.","cleanupProof":"Reviewer proves processes, volumes, files, ports and data absent.","path":"drafts/LES-0060-queues-streams-reliability/support/lab"}],"incidents":[{"id":"LES-0060-INC-001","signal":"Lag rises while group CPU and aggregate broker capacity look low.","firstThought":"A hot partition, blocked dependency, imbalance or retry loop caps progress.","safePath":"Bind group partition assignment positions oldest age handler dependency and retries; recover the limiting partition.","trap":"Add consumers without finding the limit."},{"id":"LES-0060-INC-002","signal":"Restarts cause duplicate charges although the log contains one event.","firstThought":"The effect succeeded but its acknowledgement/checkpoint was lost.","safePath":"Stop unsafe consumers, reconcile by event/effect ID, add target idempotency, then redrive.","trap":"Enable automatic offset commits."},{"id":"LES-0060-INC-003","signal":"One malformed event is delivered thousands of times and blocks progress.","firstThought":"An unbounded poison retry has no owned terminal state.","safePath":"Classify the error, bound retries, quarantine with context, alert an owner and test redrive.","trap":"Discard without audit or retry faster."},{"id":"LES-0060-INC-004","signal":"Deployments trigger rebalances and overlapping workers write out of order.","firstThought":"Membership is unstable and revoked owners are not fenced.","safePath":"Inspect generations, assignments, heartbeats and stale writes; bound work and enforce epoch-aware effects.","trap":"Increase timeouts blindly."},{"id":"LES-0060-INC-005","signal":"Replay repairs a projection but resends emails and overloads a database.","firstThought":"Replay reused live effects and capacity without isolation.","safePath":"Pause, preserve range, gate effects, isolate output, rate-limit, reconcile and validate before promotion.","trap":"Reset every group to the beginning."}],"assessmentIds":["ASM-0163","ASM-0164","ASM-0165"],"referenceIds":["REF-0658","REF-0659","REF-0660","REF-0661","REF-0662","REF-0663","REF-0664","REF-0665","REF-0666","REF-0667","REF-0668","REF-0669","REF-0670","REF-0671","REF-0672"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not a broker, protocol, transaction coordinator, benchmark or history checker.","Synthetic decisions do not prove Kafka, RabbitMQ, NATS, client, network or provider behavior.","No socket, topic, queue, stream, partition, message, offset, replica, effect, replay or load exists.","Guarantees, defaults, limits and metrics are version-, client-, configuration- and topology-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Queues and streams reliability: own delivery, order, backlog, and replay

## What you see and first thought

The broker dashboard is green. Producers report successful sends. Consumers are running. Customers still receive duplicate charges, one account's events appear out of order, and the oldest unprocessed event is two hours old.

Those facts can all be true.

A healthy broker process proves that a broker process is reachable. It does not prove that the producer knows what its acknowledgement meant, that the correct partition accepted the event, that enough replicas hold it, that the current consumer owns the partition, that the business effect happened once, that the checkpoint follows the effect, or that the user sees the right result.

Keep this first thought:

> Follow one logical operation by stable identity from business commit to publish acknowledgement, partition position, consumer ownership, effect, checkpoint and user outcome. Never replace that chain with "the message was sent."

The useful unit is not a generic message. It is a business fact or work request with an owner, identity, schema, ordering scope, retention obligation and recovery plan.

```text
business operation
      |
      v
transaction/outbox -- event ID --> producer
      |                              |
      |                         serialize + key
      |                              |
      v                              v
authoritative state          broker partition/queue
                                     |
                              ack + retained position
                                     |
                                     v
                           current consumer assignment
                                     |
                              idempotent effect
                                     |
                                     v
                           checkpoint + user proof
```

When an incident begins, ask six questions before changing anything:

1. What user operation or invariant is wrong?
2. What stable event or work ID represents it?
3. What did the producer acknowledgement prove, exactly?
4. Which queue, stream, partition and position owns the record?
5. Which consumer generation owns processing, and what effect is recoverable?
6. What checkpoint, reconciliation and user evidence closes the incident?

If any answer is "probably," preserve evidence. Retrying, resetting offsets, deleting a dead letter, increasing concurrency or replaying a range can turn an observable gap into duplicate or irreversible work.

Why use a broker at all? It decouples time, rate and ownership. A producer can commit work without waiting for every consumer. Consumers can scale or recover independently. A retained stream can rebuild a projection. A work queue can distribute expensive jobs. But the broker moves uncertainty rather than deleting it: publish can be ambiguous, records can be duplicated, consumers can be stale, storage is finite, and recovery traffic is real traffic.

The lesson therefore uses one repeating frame:

```text
operation -> identity -> route -> acknowledgement -> position
          -> current owner -> effect -> checkpoint
          -> retry/quarantine -> recovery -> user proof
```

## Terms before commands

**Message**, **record** and **event** are often used interchangeably by products, but the architecture should distinguish intent. A **command** asks an owner to perform work. An **event** states that something happened. A **notification** may only tell a consumer to fetch current state. The broker does not repair an unclear contract.

A **broker** accepts, stores or routes records between producers and consumers. A broker acknowledgement has a configured boundary. It may mean accepted by one process, appended by a leader, replicated to a required set, or merely written to an operating-system buffer. It never means the final business effect completed unless a separate application protocol proves that.

A **queue** commonly represents work distributed among competing consumers. After acknowledged processing, the queue may remove the delivery. A **retained log** or **stream** normally appends records to an ordered partition and retains them by time, bytes or policy so independent consumers can keep positions and replay. Products can combine these modes, so select semantics, not a product label.

A **topic**, **subject**, **exchange** or routing key names a logical flow. A **queue** may receive routed copies. A **partition** is a shard of an ordered log and a unit of parallelism, leadership, replication and consumer assignment. Ordering is normally local to one queue or partition, not global across a distributed broker.

The **partition key** maps related records to a partition. Choose it from the smallest invariant that requires order or state locality. If all customer events need per-customer order, a stable customer ID may be appropriate. A random key improves distribution but destroys that order. One constant key preserves global order but collapses throughput and availability to one partition.

An **offset**, **sequence** or delivery position identifies a place in a retained stream or consumer view. A **committed offset**, acknowledgement floor or checkpoint records consumer progress. It is not proof of the downstream effect unless they are committed atomically or reconciliation binds them.

A **consumer group** lets multiple instances cooperate. The group coordinator or broker assigns partitions or deliveries. A **rebalance** changes ownership when membership, subscriptions or partitions change. The old consumer can still be executing when ownership moves. **Fencing** makes a stale owner unable to write by checking a generation, epoch, lease or token at the effect target.

**Prefetch**, fetch size, batch size and maximum in-flight records bound how much work a consumer owns before acknowledging. Larger values can improve throughput but increase memory, duplicate work on failure and the number of records trapped behind a slow handler.

**At-most-once** permits loss but avoids broker redelivery by acknowledging or checkpointing before processing. **At-least-once** retries uncertain work and therefore permits duplicates. A product's **exactly-once** feature usually has a defined boundary, such as idempotent writes into one log or atomic consumption and production within that platform. It does not automatically make an email, payment, HTTP call or external database update happen exactly once.

**Idempotency** means repeating the same logical operation has the same intended effect. It requires a stable identity reused across retries. "Set balance to 10 under revision 7" can be idempotent; "add 10" is not. A deduplication table with a TTL shorter than the redelivery or replay horizon is not a durable idempotency design.

A **poison message** repeatedly fails for a stable reason: invalid schema, impossible invariant, revoked identity, software defect or unsupported value. A **dead-letter queue** or quarantine is a terminal holding area, not a trash bin. It needs an owner, reason, source identity, attempt history, retention, alert, repair procedure and safe redrive.

**Backlog** is accepted but unfinished work. Count alone is incomplete. Track records, bytes and oldest age per partition or routing scope. **Lag** is the distance between a producer/end position and a consumer position; it can be measured in offsets, records, bytes or time. Offset distance alone may not match work because records vary in size and cost.

**Retention** controls how long or how much input remains available. It must exceed the maximum legitimate outage, rebuild, audit and replay horizon with margin. Retention is not backup: deletion, corruption, operator mistakes or a compromised cluster can affect all retained replicas.

**Replay** reads an earlier range again. It is a production change. The same historical input processed by new code can create different output; the same external effects can fire again; and replay traffic competes with live traffic.

**Publisher confirm**, **producer acknowledgement**, **consumer acknowledgement**, **offset commit** and **business completion** are separate proof points. Use the exact product term when operating a product, but translate it into the ownership question: who can now forget the record, and what durable evidence allows that?

## Architecture map

Start with the interaction contract, not the broker brand:

| Need | Queue-shaped fit | Retained-log-shaped fit | Question that decides |
|---|---|---|---|
| one worker performs one task | strong | possible with work-sharing semantics | should another independent consumer replay it later? |
| many independent consumers see the fact | route or fan-out copies | separate consumer positions | must a late consumer recover history? |
| strict order for one entity | one ordered queue or keyed partition | stable keyed partition | what is the smallest ordering scope? |
| rebuild a projection | awkward if consumed work disappears | natural within retention | what is the maximum rebuild horizon? |
| per-message priority or request/reply | often natural | may be unnatural | can priority violate order or starve normal work? |
| high-throughput history | product-dependent | append, batch and partition design | how are skew and storage bounded? |

Do not conclude "Kafka for events, RabbitMQ for queues." Apache Kafka has multiple consumption models, RabbitMQ has queues and retained streams, and JetStream combines queueing and streaming behaviors. Capabilities change. Keep the architecture readable without product names:

```text
operation/invariant
  -> command, event or notification
  -> authority and publication boundary
  -> stable identity + schema + key
  -> queue or retained-log semantics
  -> acknowledgement + replication contract
  -> consumer ownership + flow control
  -> effect + checkpoint crash window
  -> retry/quarantine/replay
  -> capacity + security + recovery + user proof
```

An order system might use an outbox:

```text
order transaction
  | same database transaction
  +--> order row
  +--> outbox(event_id, order_id, revision, payload)
             |
             v
        relay publishes with stable event_id
             |
             v
      orders partitioned by order_id
        |             |             |
        v             v             v
 inventory group  billing group  notification group
        |             |             |
     inbox/effect  idempotency    replay-aware
        |             |          external messages
        +------ user reconciliation ------+
```

The outbox closes the database-commit-versus-publish gap, but not every gap. The relay can publish twice. Consumers can be redelivered. External effects can succeed while acknowledgements are lost. Every boundary still needs stable identity and reconciliation.

Map ownership explicitly:

| State | Owner | May forget when | Recovery evidence |
|---|---|---|---|
| business operation | source transaction | authoritative commit and audit exist | operation ID and source revision |
| unpublished event | durable outbox/producer buffer | broker acceptance under declared contract | event ID and publish result |
| retained record | broker partition/queue | retention or acknowledged removal policy permits | topic/queue, partition, position |
| assigned delivery | current consumer generation | effect is recoverable and checkpoint accepted | generation, event ID, effect ID |
| failed record | retry/quarantine owner | repaired, redriven or disposition approved | attempts, reason, audit |
| projection | downstream state owner | rebuilt and compared to authority | input range, code version, reconciliation |

If two components can both forget before the next component owns durable recovery, there is a loss window. If two components can both act without stable deduplication, there is a duplicate window.

### Ordering is a scoped contract

Global order sounds simple and usually creates a single bottleneck. Ask which decisions actually conflict. Events for one account may require order; events for unrelated accounts usually do not. Use the smallest key that preserves the invariant.

Partition-local order still has caveats:

- Producers may concurrently publish different events for the same key unless source revisions define order.
- Retries can reorder when product/client idempotence and in-flight settings do not preserve sequence.
- A consumer can process a batch concurrently and complete later offsets first.
- Rebalances can leave old and new owners overlapping without fencing.
- Dead-lettering one event and continuing later events can violate entity state order.
- Cross-topic or cross-partition records have no automatic total order.

A sequence number from the authoritative entity is often more useful than wall-clock time. The consumer can reject, buffer, reconcile or rebuild when revision 12 arrives before revision 11. The choice depends on latency, retention and invariant.

### Fan-out is independent ownership

When inventory, billing and analytics each need an order event, they should usually have independent consumer identities or routed copies. One group's checkpoint must not mean another group completed. A slow analytics consumer should not block billing unless the business explicitly couples them.

Fan-out multiplies storage reads, schema compatibility, authorization, incident ownership and replay cost. A new consumer is not free just because the producer code does not change.

## Request or state path

Trace a record in seven stages.

**1. Business commit.** The source service accepts an operation and decides what fact is authoritative. If database state commits and publish happens later without an outbox or equivalent durable handoff, a crash can leave state without its event. If publish happens first, consumers may observe an event for state that never commits.

**2. Event construction.** Create one stable event ID for the logical fact, not one per network attempt. Include the entity key, schema/type version, source revision, occurred time when meaningful, and correlation/causation identifiers. Do not put secrets into headers merely because they are convenient for tracing.

**3. Serialization and routing.** Serialize under a compatible schema and enforce size limits before the broker. Choose the partition or routing key from the ordering/state scope. Record the resulting topic, queue or subject and, where available, partition and position. A null or changing key can distribute related events and destroy order.

**4. Broker acceptance.** The producer waits, batches or sends asynchronously according to its latency and durability contract. A timeout is ambiguous: the broker may have accepted the record while the response was lost. Retrying with a new event ID converts ambiguity into an undetectable duplicate.

**5. Storage and replication.** A leader or queue owner appends or routes the record; replicas follow according to product rules. A replication factor is not the same as an acknowledgement requirement, and an acknowledgement requirement is not a backup. Under-replicated or quorum-lost partitions may reject writes, reduce durability or become unavailable according to configuration.

**6. Delivery and effect.** A consumer receives or fetches work under a current assignment. It validates identity, schema, authorization and invariant; checks or creates an idempotency record; performs the business effect; makes that effect durable; and only then advances the acknowledgement or checkpoint unless an atomic transaction couples them.

**7. Recovery and proof.** On error, classify transient versus permanent. Bound retries and quarantine permanent failures. Reconcile source facts, broker positions, effects and user outcomes. Backlog is recovered only when oldest age returns inside objective and correctness checks pass, not when a graph line merely slopes down.

The two classic consumer crash windows are:

| Sequence | Crash point | Result | Required control |
|---|---|---|---|
| checkpoint, then effect | after checkpoint | record appears consumed but effect is missing | do not checkpoint first; couple or reconcile |
| effect, then checkpoint | after effect | record is redelivered and effect may repeat | stable ID plus idempotent or atomic effect |

This is why "exactly once" cannot be answered by naming one client setting. Ask exactly once **what**, between **which owners**, during **which failures**, for **how long**, and how it is **proved**.

### Publisher path and ambiguity

Suppose a producer sends event `evt-731` and waits three seconds. The leader appends and replicates it, but the acknowledgement packet is lost. The producer times out. Three responses are possible:

1. Drop it: perhaps lose an accepted business fact.
2. Retry as `evt-992`: create a logically new identity and make duplicate detection impossible.
3. Retry as `evt-731` under the product's idempotence/deduplication contract: preserve ambiguity as one logical operation.

The third is normally the recoverable design, but the deduplication scope and time window are product-specific. The source still needs reconciliation because an acknowledgement cannot prove every downstream effect.

### Consumer path and checkpoints

For a database effect, a common pattern is an inbox table keyed by event ID in the same transaction as the business update:

```sql
BEGIN;
INSERT INTO consumer_inbox(event_id, source_position)
VALUES (:event_id, :position)
ON CONFLICT DO NOTHING;

-- Only apply the business update when this transaction owns the new inbox row.
UPDATE projection
SET state = :state, source_revision = :revision
WHERE entity_id = :entity_id
  AND source_revision < :revision;
COMMIT;
```

The SQL is conceptual: syntax and concurrency behavior must match the selected database. Its important property is one transaction covering deduplication and effect. The broker checkpoint follows commit. A crash before commit changes neither; a crash after commit but before checkpoint causes redelivery, which the inbox detects.

For an external API with an idempotency key, send the stable operation ID and persist the external response before checkpointing. If the API has no idempotency contract, "exactly once" is unavailable; design reconciliation, a single effect owner, compensation or a different integration.

## Failure zoom

Zoom into failures by boundary, not by symptom.

### Publish ambiguity and duplicate ingress

Producer timeouts, connection resets and leader changes create an uncertainty interval. The producer may not know whether the broker accepted the record. The safe question is not "should retries be enabled?" but:

- Does every retry reuse the same logical event identity?
- What broker or client mechanism recognizes a repeated attempt?
- How long does that recognition survive?
- Does acknowledgement require the intended replica set?
- What happens when required replicas are unavailable?
- Can reconciliation compare source operations to accepted records?

An idempotent producer can prevent duplicate appends inside its defined session/protocol boundary. It cannot deduplicate two separately created event IDs or prevent an external consumer effect from repeating.

### Lost publication

The classic dual-write failure is:

```text
database commit succeeds
       |
process crashes
       X
broker publish never happens
```

Retrying the original HTTP request may not repair it, especially after the user saw success. A transactional outbox records the state change and unpublished event together. A relay publishes with stable identity and marks progress. The relay is at-least-once; consumers remain duplicate-safe. Periodic reconciliation finds old unpublished rows and compares source facts to broker/effect evidence.

### Duplicate effect after consumer crash

Timeline:

```text
t0 receive evt-731 at partition 4 offset 918
t1 charge provider accepts idempotency key order-44
t2 local process dies before checkpoint 919
t3 broker assigns partition 4 to another consumer
t4 evt-731 is delivered again
```

If the provider honors the same idempotency key and the consumer can recover the stored result, the duplicate delivery need not duplicate the charge. If the consumer generated a new key on each attempt, the second delivery becomes a second charge. The broker did what at-least-once recovery promised.

### Missing effect from early checkpoint

Automatic checkpointing can advance beyond work still executing. A crash then starts after the committed position, skipping unfinished effects. Batch and parallel consumers worsen the gap: record 20 can finish before record 19, while a checkpoint through 20 declares both recoverable.

Options include sequential partition processing, a contiguous-completion tracker, per-record acknowledgement when supported, or transactional coupling. The correct choice depends on throughput, ordering and effect system.

### Poison-message head-of-line blocking

A deterministic schema or invariant failure does not become transient through repetition. Immediate retries can consume CPU, logs, broker bandwidth and dependency capacity while holding later records behind the poison record.

Use a decision:

```text
error
  -> transient and within budget? retry with backoff/jitter
  -> permanent or exhausted? quarantine with full context
  -> security/privacy violation? isolate access and alert
  -> unknown? stop or bound according to business risk
```

Quarantine should preserve original bytes or an approved secure representation, source topic/queue, partition/position, event ID, schema, first/last error, attempt count, timestamps, owner and disposition. Sensitive payloads need the same or stronger controls as the source.

Redrive creates a new controlled attempt. Fix the consumer or data, select an exact immutable set, preserve identity, use a separate redrive marker, rate-limit, observe effects and record completion. Never point a generic producer at an entire dead-letter queue without a plan.

### Backlog growth and false scaling confidence

Let:

- `lambda` = continuing ingress records per second,
- `mu` = sustainable service records per second,
- `T_out` = outage seconds,
- `B` = accumulated backlog,
- `T_drain` = time to clear backlog while ingress continues.

The first approximation is:

```text
B = lambda * T_out
spare = mu - lambda
T_drain = B / spare, only when mu > lambda
```

Example: 400 records/s continue during a 900-second outage. Backlog is 360,000 records. After restart the group can safely process 1,000 records/s, so spare capacity is 600 records/s and ideal drain time is 600 seconds. That is a lower bound. Retries, skew, cold caches, dependency limits and rebalances make reality slower.

If service is 350 records/s, there is no drain time: backlog grows by 50 records/s. Adding consumers helps only until a partition count, hot partition, dependency, broker quota, database lock or external rate limit becomes the ceiling.

Track oldest-message age because it maps to user harm. A million tiny analytics records may be less urgent than one 30-minute-old payment command.

### Hot partitions

Aggregate service can exceed ingress while one partition falls behind:

```text
partition 0: ingress 40/s, service 100/s
partition 1: ingress 45/s, service 100/s
partition 2: ingress 260/s, service 100/s  <-- grows 160/s
partition 3: ingress 35/s, service 100/s
```

More consumers cannot split one exclusively assigned partition in a conventional group. Fix the key distribution or the work behind that key. Random salting increases parallelism but may violate order and requires a merge strategy. A high-cardinality key is not enough; inspect the hottest value and time-local bursts.

### Rebalance and stale ownership

Rebalances are normal, but excessive rebalances reduce useful work. Common triggers include process churn, long blocking handlers, missed heartbeats or polls, unstable subscriptions, partition changes and deployment waves.

During revocation:

1. stop accepting new work for the revoked assignment;
2. finish or cancel bounded in-flight work according to the protocol;
3. persist recoverable progress;
4. make stale effects fail through target-side fencing;
5. release resources;
6. let the new generation resume.

Static membership or cooperative assignment can reduce movement in supported systems, but neither repairs an unbounded handler or missing fencing. Increasing timeouts only delays failure detection and can lengthen duplicate or unavailable windows.

### Replica loss and acknowledgement trade-off

Replication factor, available replicas and required acknowledgements define a safety/availability point. If a design requires two replica acknowledgements but only one replica is available, rejecting writes may be correct. Lowering the requirement during an incident increases the accepted-loss window.

Do not change durability settings from pressure alone. Bind:

- business loss tolerance;
- current leader and replica state;
- acknowledged positions;
- recovery and rollback options;
- whether unclean leadership or stale replicas are possible;
- exact user-facing behavior.

A replicated broker is not a backup. Test restore or cross-failure recovery for the actual retention and business objective.

### Replay side effects

Replay can be logically correct and operationally destructive. Historical records can:

- resend notifications;
- repeat non-idempotent calls;
- overwrite newer state with old schema logic;
- violate current authorization or deletion policy;
- saturate live dependencies;
- consume retention before completion;
- create outputs indistinguishable from live output.

Use an isolated output or shadow projection first. Pin code, configuration, schema and input range. Disable, stub or idempotently gate external side effects. Rate-limit below measured spare capacity. Compare replay output with authority and promote only through an explicit decision.

## Internals and state ownership

Products differ, but several internal mechanisms explain the evidence you see.

### Append logs, segments and page cache

A retained stream commonly appends batches to a partition log. The log is split into segments for retention, indexing and file management. Sequential append, batching, compression and operating-system page cache can provide high throughput. Consumers fetch from positions rather than forcing the broker to delete each record immediately.

Operational consequences:

- many tiny records amplify request, index and metadata overhead;
- very large records increase memory, network and recovery cost;
- compression saves network/storage but uses CPU and works best across similar batches;
- retention deletion occurs at segment/policy boundaries, not necessarily the instant one record reaches an age;
- caught-up reads may come from page cache while replay reads compete for disk;
- TLS and encryption can change CPU and data paths;
- disk-full behavior can stop partitions even when CPU is idle.

Do not use vendor benchmark numbers as a capacity plan. Measure your record sizes, key distribution, batching, compression, replication, security, retention and failure mode.

### Partition leadership and replicas

Each partitioned log has an owner or leader for appends and replicas that follow under a product protocol. Metadata tells clients where to send. Leader epochs or similar terms distinguish old from current leadership. Replicas can be caught up, lagging, unavailable or ineligible.

An acknowledgement such as "all" must be interpreted with the product's in-sync or quorum configuration. "All" does not necessarily mean every configured replica forever; it means the product-defined required set at that moment. Record exact versions and settings when making claims.

Replication protects against some node failures. It also multiplies disk and network, makes recovery traffic compete with foreground traffic, and can reduce availability when a quorum is lost. More replicas are not free durability.

### Producer batching, ordering and idempotence

Producers usually buffer records to form batches. Batch size and linger-like delay trade a small wait for fewer network and disk operations. Compression operates on batches. Buffer exhaustion and delivery timeouts are backpressure signals, not reasons to retry without limit.

Ordering depends on the key-to-partition mapping, one producer's sequencing, retry behavior and in-flight requests. Product-specific idempotent producer protocols associate identities and sequence numbers with batches to reject duplicate retries. Transactional IDs may also fence older producer instances. These mechanisms have configuration and lifecycle boundaries; they do not identify a business fact unless the application supplies stable identity.

### Consumer positions and group coordination

A retained-log consumer fetches from a chosen position. The application can keep a local processed position while the group stores a committed position. Lag often compares the log end with the committed position. If commits are infrequent, reported lag can overstate rework after a crash; if commits run ahead of effects, lag can look healthy while work is missing.

Group coordination maintains membership and assignment. A generation or epoch identifies the current ownership decision. Heartbeats prove liveness, but a live consumer may still be unable to process. Poll timing, handler duration and in-flight design must fit the protocol.

In queue protocols, a delivery tag and manual acknowledgement often transfer responsibility for individual or multiple deliveries on a channel. Automatic acknowledgement can improve throughput but makes a connection loss able to lose in-flight work from the application's perspective. Prefetch bounds unacknowledged deliveries and therefore memory, fairness and rework.

### Retention, deletion and compaction

Time or size retention deletes old log segments according to policy. A queue may delete after acknowledged consumption. A stream may retain independent of consumer progress. Interest or work-queue policies can combine retention with acknowledgements. Read the selected product contract.

Log compaction retains a latest record per key according to product rules; it is not an immediate unique-key table and does not preserve every historical intermediate value. Tombstones and deletion retention require careful privacy and rebuild reasoning. Compaction plus time retention may remove different evidence.

Capacity requires both steady state and recovery:

```text
daily stored bytes ~= ingress_records_per_second
                    * average_encoded_bytes
                    * 86,400
                    * retention_days
                    * replication_factor
                    * overhead_factor
```

This approximation excludes compression variability, indexes, metadata, safety margin, temporary duplicate segments, compaction and re-replication. Measure them.

### Transactions and exactly-once boundaries

Some platforms can atomically consume input positions and produce output records within their own transaction system. That is powerful for broker-to-broker pipelines. It does not automatically include an arbitrary database, payment provider or email service.

State the boundary precisely:

> For records read under isolation X and outputs written to broker Y with transactional identity Z, committed input positions and output records are atomic under the documented failure model. External effect Q remains at-least-once and is protected by idempotency key R.

That sentence is longer than "exactly once," but it is operationally useful.

### Quorum queues, streams and consumer state

RabbitMQ quorum queues use replicated consensus and have product-specific poison, delivery-limit and dead-letter features. RabbitMQ streams retain append-only data and use offsets; superstreams partition a logical stream. NATS JetStream separates streams, which store records under retention policy, from consumers, which track delivery and acknowledgement state.

These examples show why "queue" and "stream" are semantic choices, not mutually exclusive products. For every mechanism, ask:

- What state is replicated?
- What acknowledgement moves ownership?
- What position is durable?
- What happens after lost acknowledgement?
- What limits storage and delivery attempts?
- How is a stale producer or consumer fenced?
- What evidence supports replay and cleanup?

## Evidence table

Start with user harm and walk backward. Metric names vary, so bind meaning rather than memorizing one dashboard label.

| Question | Minimum evidence | What it can prove | What it cannot prove |
|---|---|---|---|
| Is the user operation correct? | operation ID, source revision, expected effect, actual effect, timestamp | sampled business outcome | every record is correct |
| Was the event created? | source transaction and outbox row by stable ID | durable publication intent | broker acceptance |
| Did the broker accept it? | producer result, topic/queue, partition/position, acknowledgement config, leader epoch | one product boundary for that attempt | consumer effect |
| Is it sufficiently replicated? | configured replicas, current in-sync/quorum membership, required acknowledgements | sampled replica/availability contract | independent backup |
| Is order preserved? | entity key, source revision, partition, offsets, producer sequence, consumer completion order | scoped history for sampled entity | global order |
| Who owns processing? | group/durable consumer, member, assignment, generation, heartbeat/poll state | current coordination view | old worker is fenced |
| Did the effect happen? | event ID, inbox/dedupe row, effect transaction/external response | recoverable sampled effect | checkpoint is correct |
| Did progress advance safely? | processed and committed positions, commit result and timestamps | relationship for sampled position | all in-flight work completed |
| Why is lag growing? | per-partition ingress, service, end/processed/committed position, oldest age, handler/dependency latency | limiting scope and growth rate | future drain rate |
| Is one event poison? | stable error signature, schema, attempts, handler version, neighbor progress | repeated deterministic failure | data is safe to discard |
| Can recovery finish? | backlog, continuing ingress, sustainable service, partition ceiling, retention remaining | bounded drain estimate | untested failure throughput |
| Is replay safe? | approved range, code/config/schema versions, isolated output, effect gates, rate and reconciliation | planned replay boundary | correctness before validation |

### Evidence bundle for one incident

Capture a small, correlated bundle:

```text
incident_id
user_operation_id
event_id / entity_id / source_revision
topic_or_queue / partition / position
producer_attempt / ack_result / leader_epoch
consumer_group / member / generation / assignment
delivery_count / handler_version / error_class
effect_id / dedupe_result / downstream_result
processed_position / committed_position
backlog_count_bytes_oldest_age / retention_remaining
```

Avoid logging full payloads by default. Use hashes, approved identifiers or access-controlled samples. Broker headers and dead letters often escape normal application redaction paths.

### Backlog evidence

Graph at least:

- ingress records and encoded bytes per second;
- successful service rate, not merely fetched rate;
- backlog records and bytes;
- oldest unprocessed event age;
- per-partition lag and hottest key;
- handler time separated from downstream wait;
- retry/redelivery and poison counts;
- number of active assignments and useful concurrency;
- dependency utilization, throttles and errors;
- retention time remaining for the oldest required record.

If reported lag drops because offsets were reset or records were discarded, the user backlog did not necessarily recover. Reconcile effects.

### Duplicate and gap evidence

For duplicates, group by stable event ID and stable business effect ID. Separate:

- duplicate event construction at source;
- duplicate broker append after ambiguous retry;
- broker redelivery of one stored record;
- replay of historical input;
- duplicate external effect despite one delivery.

For gaps, compare source authoritative sequence with broker and effect sequences. A missing number may be a legitimate filtered event, so use the contract. Do not infer loss from non-contiguous offsets: compaction, retention, aborted transactions or product rules can create visible gaps.

## Command decoders

The bundled commands operate only on a synthetic JSON model. They intentionally avoid invented live-broker commands because exact syntax, authentication, TLS, version and topology must come from the selected environment.

### `bash lab.sh doctor`

- `bash` runs the wrapper.
- `lab.sh` is the exact local script.
- `doctor` performs read-only guards.

Expected success:

```text
doctor=pass runtime=offline-queue-stream-model
```

It proves Ubuntu 24.04, non-root identity, absent credential hints and Python availability. It does not connect to any broker.

### `bash lab.sh setup`

Setup creates one exact mode-0700 directory under `/tmp` for the current numeric UID, writes a sentinel, copies the fixture and validates its identity and fields.

Expected lines include:

```text
fixture=valid cases=16
setup=pass state=/tmp/reliability-atlas-les0060-queues-streams-<uid> network=none
```

If state already exists, setup refuses. Inspect it; do not delete an unknown path. Cleanup accepts only the exact sentinel, owner and inventory.

### `bash lab.sh evaluate baseline`

The model evaluates boundaries in a deliberate order:

```text
publisher acknowledgement
-> stable event identity
-> partition and ordering contract
-> producer retry identity
-> idempotent consumer effect
-> checkpoint after effect
-> bounded poison retries
-> owned quarantine
-> backlog drain capacity
-> hot partition
-> retention horizon
-> rebalance fencing
-> guarded replay
-> replica requirement
-> scoped authorization
```

Expected:

```text
case=baseline decision=operable boundary=operable
```

"Operable" only means the declared synthetic values pass these rules. It is not a broker health verdict.

### Negative cases

`bash lab.sh evaluate ambiguous-publisher-ack` returns `publisher-ack` because no durable acceptance meaning is declared.

`bash lab.sh evaluate non-idempotent-effect` returns `consumer-duplicate` because a redelivered stable event can repeat its effect.

`bash lab.sh evaluate checkpoint-before-effect` returns `effect-loss` because progress may advance before durable work.

`bash lab.sh evaluate poison-unbounded` returns `poison-loop` because there is no terminal attempt budget.

`bash lab.sh evaluate backlog-no-drain` returns `backlog-drain`. Its fixture uses 100 records/s ingress, 110 records/s service, a 60-second outage and a 300-second recovery window. Backlog is 6,000; spare service is 10/s; only 3,000 can drain in the window.

`bash lab.sh evaluate hot-partition` returns `hot-partition` because the hottest partition receives 150/s while its declared capacity is 120/s.

`bash lab.sh evaluate retention-too-short` returns `replay-horizon` because retention is 3,600 seconds and required recovery is 43,200 seconds.

`bash lab.sh evaluate rebalance-no-fence` returns `stale-consumer` because a revoked worker can still write.

Other fixture cases cover unstable event IDs, retry-created identities, unowned quarantine, unguarded replay, insufficient replicas and unscoped authorization.

### `bash verify.sh`

The verifier requires absent starting state, runs every case, injects an unexpected artifact to prove refusal, removes that exact artifact through a guarded path, cleans up and proves state absence.

Expected final line:

```text
verify=pass cases=16 refusal=true cleanup=true
```

It does not start Kafka, RabbitMQ or NATS. A passing verifier cannot support claims about real delivery, performance, replication, transactions or recovery.

## Decision path

Use this path for design and incidents:

```text
1. operation and invariant
   |
2. command/event/notification + authority
   |
3. fan-out, replay, latency, retention
   |
4. stable event ID + schema + entity key
   |
5. queue or retained log + partition/ordering scope
   |
6. producer acknowledgement + replica requirement
   |
7. current consumer ownership + flow control
   |
8. effect/checkpoint crash windows + idempotency
   |
9. retry classification + quarantine/redrive
   |
10. backlog/hot partition/retention capacity
   |
11. security/privacy/cost
   |
12. fault test + reconciliation + user proof
```

### Choose the interaction

Use synchronous request/reply when the caller needs immediate authoritative success and can safely wait. Use a command queue when work can be accepted and completed later by one logical owner. Use an event when a fact already happened and independent consumers decide their effects. Use a retained log when history, multiple positions or rebuild is required.

Do not publish a command disguised as an event to many competing owners. Do not use asynchronous acknowledgement to hide that the user actually requires completion.

### Choose the ordering key

Write the invariant:

> Updates for one account must apply in source revision order; unrelated accounts may progress independently.

That suggests account ID as the ordering key. Then test:

- top account traffic and byte rate;
- large-tenant isolation;
- partition-count change behavior;
- cross-account operations;
- delayed or dead-lettered earlier revisions;
- consumer parallelism within a partition.

If one tenant can exceed a partition, redesign the invariant or introduce sub-keys with an explicit merge/serialization mechanism. Hashing alone cannot preserve an unstated global order.

### Choose delivery and effect semantics

For each effect, fill this table:

| Effect | Loss allowed? | Duplicate allowed? | Stable identity | Atomic boundary | Reconciliation |
|---|---:|---:|---|---|---|
| analytics count | maybe bounded | correctable | event ID | stream transaction or dedupe | rebuild from retained range |
| projection update | no | harmless under revision | entity + revision | inbox plus update | compare to authority |
| payment charge | no | no | payment operation ID | provider idempotency plus local record | provider/source ledger |
| email | business-dependent | usually no | notification intent ID | provider support varies | delivery log and suppression |

If neither atomicity nor idempotency nor reconciliation exists, at-least-once delivery is not safe for that effect.

### Choose retry and terminal state

Retry only when the failure may change and the deadline permits. Use exponential backoff with jitter and a total attempt/time budget. Respect dependency rate limits. Permanent validation or authorization failures go to an owned terminal path. Unknown failures should not loop forever.

Define redrive before launch: who approves, how the set is selected, which code/schema applies, how side effects are gated, what rate is safe, how success is reconciled and how the source quarantine is marked.

### Choose capacity and retention

Capacity plan per partition and dependency, not only cluster average. Include:

- peak and burst ingress records/bytes;
- record-size percentiles;
- hottest key and partition;
- sustainable handler rate during dependency latency;
- partition count and useful consumer parallelism;
- replication, compression and TLS cost;
- outage backlog and drain objective;
- cold start, rebalance and replica recovery;
- retention for outage, rebuild, audit and replay;
- disk and network safety margin;
- quarantine growth.

Reject a design whose recovery consumes all live headroom.

## Guided Ubuntu lab

This lab teaches architecture boundaries with no broker. That is intentional while the representative runtime remains unavailable.

### Safety contract

Run only in Ubuntu 24.04 as a normal user. The scripts refuse root, known cloud/broker/database/Kubernetes credential hints, symlinks, wrong ownership, unknown files and pre-existing state. They open no socket.

From the lesson's `support/lab` directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Stop if any command differs from the documented path or reports `lab=fail`. Do not bypass a guard.

### Establish the safe baseline

```bash
bash lab.sh evaluate baseline
```

Write a one-sentence explanation for every true input in the baseline. For example:

- `stableEventId=true` means retries refer to one logical fact.
- `checkpointAfterEffect=true` means progress cannot knowingly move before recoverable work.
- `servicePerSecond=300` and `ingressPerSecond=100` leave 200/s ideal spare capacity.
- `availableReplicas=3` and `requiredReplicas=2` satisfy the declared boundary.

These are declarations, not measured facts.

### Walk the duplicate and loss windows

```bash
bash lab.sh evaluate producer-retry-new-id
bash lab.sh evaluate non-idempotent-effect
bash lab.sh evaluate checkpoint-before-effect
```

For each, draw a timeline with the last durable state before a crash and the first action after restart. State whether the result is duplicate, loss or ambiguity. Then propose stable identity, effect-side idempotency and checkpoint placement.

### Walk poison and quarantine

```bash
bash lab.sh evaluate poison-unbounded
bash lab.sh evaluate quarantine-no-owner
```

Design an attempt record with event ID, source position, schema, handler version, error class, first/last failure, count and next action. Name the terminal owner and retention. Explain why a dead-letter queue without an owner is delayed data loss.

### Calculate drain and hotspot

```bash
bash lab.sh show backlog-no-drain
bash lab.sh evaluate backlog-no-drain
bash lab.sh show hot-partition
bash lab.sh evaluate hot-partition
```

Recalculate the fixture by hand. Then create two paper alternatives:

1. a safe capacity alternative that increases sustainable service without overloading the dependency;
2. a demand-control alternative using admission, prioritization or shedding that preserves the business invariant.

For the hot partition, do not merely say "add partitions." Explain whether changing the key preserves order and how historical records map during migration.

### Walk retention, rebalance and replay

```bash
bash lab.sh evaluate retention-too-short
bash lab.sh evaluate rebalance-no-fence
bash lab.sh evaluate unguarded-replay
```

Create:

- a retention equation covering maximum outage, rebuild, investigation and margin;
- a target-enforced fencing token design;
- a replay plan with exact range, immutable input, pinned code, shadow output, side-effect gate, rate limit and reconciliation.

### Verify and clean

Return to absent state first if you have an active setup:

```bash
bash lab.sh cleanup
bash verify.sh
```

Success is the exact verifier line and absent UID-scoped state. Preserve your calculations and reasoning separately; the verifier does not grade them.

### Expected learning evidence

The guided lab is complete only when the learner can explain why:

- publisher success is not consumer success;
- stable identity turns ambiguous retry into a detectable repeat;
- at-least-once delivery requires duplicate-safe effects;
- checkpoint-before-effect can lose work;
- one poison event needs a terminal owner;
- aggregate capacity can hide an undrainable partition;
- retention must cover recovery;
- revoked consumers need target-side fencing;
- replay is a change with live capacity and side effects.

## Production transfer

The offline model gives vocabulary and boundary reasoning. Production transfer requires a disposable representative broker, real client libraries, a real effect store and observed histories.

### Minimum representative topology

Use an isolated local or approved test environment with:

- enough broker nodes to exercise the intended replication/quorum behavior;
- at least two partitions or queue shards;
- a producer that preserves stable event IDs across retries;
- at least two consumers in one group or work-sharing identity;
- a transactional or idempotent effect store;
- a quarantine path with an owner record;
- telemetry for positions, lag, attempts, assignments and effects;
- synthetic data only;
- exact setup, reset and cleanup.

One single-node broker can teach APIs but cannot prove leader failover, quorum, in-sync replica behavior or partition recovery.

### Fault matrix

Run one fault at a time and preserve the timeline:

| Fault | Expected observation | Correctness proof | Recovery proof |
|---|---|---|---|
| producer loses acknowledgement | retry uses same event ID; broker may contain one or a recognized repeat | one logical source operation | reconciliation finds no missing/extra effect |
| consumer dies after effect | redelivery occurs | effect ID remains single | checkpoint advances after duplicate-safe handling |
| consumer checkpoints before injected effect failure | test must expose loss window and reject design | missing effect detected | revised implementation closes gap |
| poison schema | attempts stop at budget | healthy work progresses according to order contract | owned quarantine and safe corrected redrive |
| one hot key | one partition saturates | entity order preserved | key/capacity design meets objective |
| dependency slowdown | in-flight work and oldest age rise | no uncontrolled retry/duplicate | admission and drain preserve dependency |
| consumer deployment | assignment changes | stale owner cannot write | stable group returns within objective |
| broker leader/node loss | acknowledgement/availability follows declared replica policy | no unproved acknowledged loss | leadership and replicas recover |
| retention pressure | oldest required input approaches boundary | alarm fires before deletion | governed capacity/retention action |
| replay | shadow output builds at bounded rate | external effects gated; output reconciles | promotion and cleanup are exact |

Record observed product version, client version, every non-default setting and the exact fault. Do not generalize a single successful run to all partitions or failure combinations.

### Example incident workflow: rising lag

1. **Scope user harm.** Which event class, tenant and oldest age affect which user action?
2. **Freeze harmful automation.** Stop autoscaling or retries only if evidence shows amplification; preserve state.
3. **Split lag.** Inspect per group, topic/queue, partition, key and time.
4. **Compare rates.** Measure ingress, successful effects and spare capacity.
5. **Inspect ownership.** Assignment, generation, rebalances, in-flight work and fencing.
6. **Inspect handlers.** CPU, memory, serialization, handler time, dependency waits and errors.
7. **Inspect poison/retry.** Delivery attempts and one repeated position.
8. **Protect dependencies.** Bound concurrency/retries, prioritize critical work, shed only approved work.
9. **Recover limiting scope.** Fix poison, hotspot, dependency or assignment rather than changing everything.
10. **Validate.** Oldest age, correct effects, duplicate/gap checks, retention remaining and user SLI.

"Lag is decreasing" is insufficient if the drain estimate exceeds retention or users still see stale state.

### Example incident workflow: duplicates

Build one identity chain:

```text
source operation
 -> outbox row
 -> producer attempts
 -> broker positions
 -> delivery attempts
 -> dedupe/inbox rows
 -> external effect IDs
 -> checkpoints
 -> user-visible outcomes
```

Then classify where the count increased. A single broker record delivered twice is different from two source events or one delivery causing two effects. Containment follows the location.

### Change and rollback

Treat partition-count changes, key migrations, retention reductions, acknowledgement changes, replica changes, consumer concurrency, retry policy, dead-letter routing and offset resets as production changes.

Before:

- declare affected flows and invariants;
- capture positions, assignments and replica state;
- estimate movement, storage and replay;
- define abort signals;
- verify rollback does not reapply effects;
- obtain owner approval for destructive or irreversible actions.

After:

- compare user correctness and latency;
- verify key distribution and order;
- verify no group was reset unintentionally;
- reconcile quarantined and in-flight work;
- confirm retention and cost;
- record exact final settings.

## Reliability, security, observability, capacity, and cost

### Reliability

Reliability is an end-to-end ownership argument:

```text
source commit
AND recoverable publication intent
AND broker acceptance under declared replica policy
AND stable identity across retries
AND current consumer ownership
AND duplicate-safe durable effect
AND safe checkpoint
AND bounded poison/replay paths
AND reconciliation to user outcome
```

If one term is unknown, the guarantee is unknown.

Use failure budgets, not optimism. Specify:

- maximum acceptable publish ambiguity;
- allowed duplicate and loss rate by effect;
- oldest-event objective;
- maximum outage and drain time;
- quarantine age objective;
- replay completion objective;
- replica/quorum loss behavior;
- recovery evidence and owner.

Backpressure must cross boundaries. A full producer buffer, broker throttle, high unacknowledged count or saturated downstream pool should slow or reject work deliberately. Hiding pressure with unbounded memory, local disk or retries creates a later cliff.

Graceful degradation might defer analytics, lower noncritical replay rate or reject new batch jobs while preserving payment commands. Priority must be bounded so low-priority work cannot starve forever and high-priority work cannot violate entity order.

### Security and privacy

Apply least privilege separately to producers, consumers and operators:

- publish only to approved topics, queues or subjects;
- consume only required flows and groups;
- restrict creation, deletion, retention change, offset reset and redrive;
- separate application identities from operator identities;
- authenticate brokers and peers; encrypt in transit where required;
- rotate credentials and certificates without mass rebalance or outage;
- audit administrative and data-plane denials without logging secrets.

Treat event data as durable data. Classify payloads and headers. Avoid credentials, tokens and unnecessary personal data. Encrypt storage where required and protect backups, replicas, dead letters and replay outputs.

Retention and immutability complicate deletion rights. Design references or tokenization so sensitive data can be removed or rendered unusable while required non-sensitive audit facts remain. Log compaction or tombstones have product-specific delays and do not prove every replica, backup, cache, quarantine or downstream copy is deleted. Maintain a deletion evidence chain.

Multi-tenancy needs namespace, quota and authorization isolation. A tenant-controlled partition key can create a hotspot attack. Large records can exhaust memory and network. Enforce schema, size, rate and resource limits at trusted boundaries.

Schema registries, connectors, broker plugins and client libraries are supply-chain surfaces. Pin and scan artifacts, restrict plugin installation, protect schema compatibility controls and audit connector destinations.

### Observability

Build four connected views:

1. **User view:** correct completion, duplicate/missing outcome, age and latency.
2. **Flow view:** source operation, event identity, route, partition/position, consumer and effect.
3. **Broker view:** leaders, replicas, storage, requests, throttling, network and retention.
4. **Recovery view:** retries, quarantine, backlog drain, replay range and reconciliation.

Alert on symptoms that need action:

- oldest critical event exceeds objective;
- per-partition lag grows for a sustained window;
- no spare drain capacity remains;
- under-replicated or unavailable scope crosses policy;
- publish error/timeout or acknowledgement latency threatens the deadline;
- rebalance frequency/duration exceeds the normal deployment envelope;
- poison attempts or quarantine age exceed budget;
- retention remaining approaches drain/rebuild time;
- duplicate or missing-effect reconciliation fails.

Avoid alerts for a nonzero queue count, one brief rebalance or one retry without user/risk context. Use runbook links and ownership.

Trace propagation helps connect producer and consumer, but replayed traces, batch consumers and asynchronous timing require explicit event and causation IDs. Sampling must retain enough error/slow/poison evidence without exposing payloads.

### Capacity

Capacity has at least five ceilings:

1. producer serialization/buffer/network;
2. broker partition leader CPU/network/disk;
3. replication and recovery traffic;
4. consumer partition/in-flight/handler capacity;
5. downstream effect system.

Overall throughput is the minimum relevant ceiling. More consumers cannot exceed partition parallelism or downstream limits.

Useful calculations:

```text
encoded_ingress_bytes_per_second
  = records_per_second * average_encoded_record_bytes

replicated_write_bytes_per_second
  ~= encoded_ingress_bytes_per_second * replication_factor

outage_backlog_records
  = ingress_records_per_second * outage_seconds

ideal_drain_seconds
  = backlog_records / (service_rate - ingress_rate)
  only if service_rate > ingress_rate

minimum_retention
  >= maximum_outage + investigation + rebuild_or_replay + safety_margin
```

Use percentiles and distributions. Average record size hides a 20 MiB outlier. Average partition rate hides a viral tenant. Average handler time hides timeouts that hold prefetch slots.

Load test steady state, burst, cold start, one unavailable broker, replica catch-up, consumer restart, dependency slowdown, poison event and replay. Test cleanup. A benchmark with acknowledgements disabled, replication reduced or payloads tiny is not evidence for the production contract.

### Cost

Count:

- broker compute and memory;
- replicated hot storage and retained bytes;
- cross-zone/region replication and consumer egress;
- backups or archival recovery sources;
- schema registry, connectors and gateways;
- observability volume and high-cardinality labels;
- quarantine and replay shadow storage;
- consumer compute and downstream database/API work;
- engineering and on-call toil.

Longer retention improves recovery but costs storage. More partitions improve parallelism but cost metadata, files, replication and coordination. More replicas improve some failure tolerance but cost write bandwidth and recovery time. More consumer concurrency can increase downstream cost without improving completed throughput.

Optimize after preserving invariants. Compression, batching, tiered storage, retention classes and workload schedules can reduce cost, but validate latency, CPU, replay and failure behavior.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| "send succeeded, so the order is processed" | broker acknowledgement stops before consumer effect | name every acknowledgement and reconcile user outcome |
| generate a new event ID on retry | ambiguity becomes an undetectable duplicate | create identity once at business intent |
| enable automatic consumer commit for convenience | progress can outrun effects | bind checkpoint to recoverable completion |
| claim exactly once without a boundary | external effects and histories remain uncovered | state owners, failure model and proof |
| use timestamp for global order | clocks and concurrent sources do not form authority | entity revision and scoped partition order |
| add consumers to fix all lag | partition or dependency ceiling remains | inspect per-partition and downstream capacity |
| use one partition for order | throughput and availability collapse | reduce ordering scope or design merge |
| salt a hot key casually | entity order and aggregation break | redesign invariant and migration explicitly |
| retry poison work forever | it blocks progress and burns capacity | classify, bound, quarantine and own |
| use a dead-letter queue as trash | failures age into silent loss | alert, retain, repair, redrive and audit |
| reset offsets to make lag green | work can be lost or repeated | approved range, effect analysis and reconciliation |
| replay into live output | old effects and load repeat | shadow output, gates, rate limits and promotion |
| lower acknowledgement/replica safety during outage | accepted-loss window expands | business-approved degradation and evidence |
| size by average rate | bursts, bytes and hotspots dominate | distributions, failure headroom and soak tests |
| retain forever | privacy, storage and blast radius grow | governed horizons and recovery sources |
| log full failed payloads | dead letters and logs leak data | minimize, redact and access-control evidence |

Prevent incidents in design review by requiring:

- one operation and authority table;
- one acknowledgement ownership table;
- event identity and schema evolution;
- ordering/key distribution analysis;
- effect/checkpoint crash-window tests;
- retry/quarantine/redrive policy;
- backlog and retention math;
- security/privacy/tenant boundaries;
- fault matrix and reconciliation;
- cost and on-call ownership.

## Memory card and retrieval

### The sentence to remember

> A broker makes work durable and decoupled only inside its configured boundary; stable identity, scoped order, current ownership, idempotent effects, safe checkpoints, bounded recovery and user reconciliation make the system reliable.

### The seven ownership points

```text
source -> publish intent -> broker acceptance -> retained position
       -> consumer assignment -> durable effect -> checkpoint/user proof
```

### The three dangerous gaps

1. source commit without recoverable publication;
2. effect without stable duplicate handling;
3. checkpoint without recoverable effect.

### The backlog equations

```text
backlog = ingress * outage
spare = service - ingress
drain = backlog / spare, only when spare > 0
```

Always apply per hot partition and downstream dependency.

### Retrieval prompts

Without looking back, answer:

1. What exactly did the publisher acknowledgement prove?
2. What ID survives every retry and replay?
3. What is the smallest required ordering scope?
4. Which partition is hottest, not merely average?
5. Can an effect repeat after crash?
6. Can a checkpoint hide unfinished work?
7. Where does poison work stop, and who owns it?
8. Can sustainable service exceed continuing ingress during recovery?
9. Does retention exceed the complete recovery horizon?
10. Can a revoked owner still write?
11. Are replay side effects isolated?
12. What user evidence closes recovery?

Repeat after one day and one week. Reading fluency is not transfer; explain a new system and defend trade-offs.

## Complete answers

### 1. Queue or retained log: how do you choose?

Start with ownership and recovery. Choose queue-shaped semantics when one logical worker should own each task, completion removes or terminally acknowledges the task, and independent historical replay is not a primary requirement. Choose retained-log semantics when multiple independent consumers need the same fact, consumers need durable positions, or projections must rebuild from history.

Then qualify the choice with ordering, retention, priority, routing, fan-out, throughput, storage, security and product operations. Modern products can support both shapes, so do not select from brand stereotypes. Document the required semantics and test the chosen configuration.

### 2. Does a successful producer send mean the event is safe?

Only inside the configured acknowledgement boundary. Determine whether success means local client buffering, broker receipt, leader append, required replica acceptance or another documented state. Bind the result to topic/queue, partition/position, leader epoch and exact settings.

It never proves that a consumer processed the event or the user outcome completed. A timeout can also be ambiguous: acceptance may have succeeded while the reply was lost. Preserve one event identity across retries and reconcile source intent against broker/effect evidence.

### 3. Why can at-least-once delivery create duplicates?

The broker or consumer cannot distinguish every crash state. A consumer may complete an effect and crash before its acknowledgement reaches the broker. Redelivery is the safe response because dropping the record could lose work.

Make the effect duplicate-safe with a stable event or operation ID. Prefer an inbox/deduplication record committed atomically with the business effect, a target API that honors an idempotency key, or explicit reconciliation. Do not generate a new key on every attempt.

### 4. Why can checkpoint-before-effect lose work?

The checkpoint tells the broker where recovery should resume. If position 101 is committed before the effect for record 100 becomes durable, a crash can restart at 101 and never repeat 100. Metrics may show zero lag while the user effect is missing.

Commit after recoverable completion, or atomically couple input position and output when the platform supports the whole boundary. With parallel processing, advance only through the highest contiguous completed position or use product-supported per-record acknowledgement. Validate by crashing at each boundary.

### 5. What does exactly once really mean?

It is incomplete without a noun and boundary. Ask: exactly once appended to which log, exactly once consumed and produced within which transaction coordinator, or exactly once charged by which provider? Also ask which failures, retry window, identity and evidence apply.

A broker can offer idempotent producer writes or atomic input-position/output commits within itself. An external database, payment or email is not automatically part of that transaction. Protect external effects with idempotency and reconciliation and describe the broker-scoped guarantee precisely.

### 6. How do partitions affect order and scalability?

A partition is both an ordered-log shard and a parallelism/ownership unit. Records with a stable entity key can share partition-local order. Different partitions do not create a total global order. A consumer group normally assigns each partition to one active member, so useful parallelism is limited by partitions and hotspots.

Choose the smallest invariant requiring order. Test key cardinality, hottest-key rate, bytes, tenant skew and time bursts. More partitions add parallelism but increase metadata, files, replication, rebalance work and cost. Changing partition count or key function can alter mapping and therefore order assumptions.

### 7. How do you diagnose rising consumer lag?

Begin with user age and per-partition evidence. Compare end, processed and committed positions; ingress and successful effect rates; oldest age; assignments and rebalances; fetch/in-flight/handler time; dependency latency and errors; retries and poison signatures; broker throttles and replica state.

Calculate whether sustainable service exceeds continuing ingress. If not, backlog cannot drain. Find the limiting partition or dependency before scaling. Contain amplification, isolate poison work, restore safe spare capacity and validate duplicates/gaps plus user outcomes while oldest age returns within objective.

### 8. What is safe poison-message handling?

Classify errors. Transient failures get bounded attempts, backoff, jitter and deadline-aware retry. Permanent or exhausted failures move to an access-controlled quarantine with original identity, source position, schema, handler version, error, attempt history, owner, retention and disposition.

Alert the owner. Repair consumer or data. Redrive an exact reviewed set with stable IDs, versioned code, rate limits, side-effect controls and reconciliation. A dead-letter queue without an owner and age objective is silent loss.

### 9. How do you calculate backlog recovery?

For a first bound:

```text
backlog = ingress_rate * outage_seconds
spare = sustainable_service_rate - continuing_ingress_rate
drain_time = backlog / spare
```

Drain exists only when spare is positive. Apply it to the hottest partition and every downstream ceiling. Add cold start, retry, rebalance, replica recovery and safety margin. Compare drain time plus investigation to retention remaining and the user age objective.

### 10. Why is replay dangerous?

Replay runs historical input through code and dependencies again. It can repeat external effects, overwrite newer state, violate current deletion/authorization rules, overload live systems and produce outputs that look live.

Approve an exact immutable range. Pin code, configuration and schemas. Use a shadow output. Disable or idempotently gate external effects. Rate-limit below measured spare capacity. Track progress and retention. Reconcile output to authority, obtain review, then promote and clean up exactly.

### 11. How do rebalances cause correctness problems?

A rebalance changes assignment, but a revoked process may still finish slow work. Without target-enforced generation/epoch fencing, old and new owners can both write. Frequent rebalances also discard warm state and cause duplicate work.

Inspect membership, assignment, generation, heartbeat/poll and handler timing. Bound in-flight work and implement revocation. Use cooperative or static membership only with documented behavior. Enforce current generation or a monotonic token at the effect owner; liveness alone cannot fence.

### 12. Are broker replicas a backup?

No. Replication improves availability and durability for selected node failures, but replicas share operator actions, retention, software defects, security compromise and logical deletion. Lagging replicas and acknowledgement settings also change the accepted-loss boundary.

Use a separate recovery design where required: governed retention, archive or backup, restore/rebuild procedure, credentials, integrity verification and tested RPO/RTO. Prove restoration and reconciliation, not merely replica count.

## Product-company interview

### Scenario: a payment consumer occasionally charges twice

**What the interviewer evaluates:** whether you trace identities and crash windows instead of blaming the broker.

**Strong answer:** "I first stop or isolate the unsafe consumer and reconcile affected users. I trace source operation ID, event ID, broker positions and delivery attempts, consumer generation, provider idempotency key, provider response, local effect record and checkpoint. A common window is provider success followed by consumer crash before acknowledgement, leading to redelivery. I preserve the same payment operation ID on every attempt and require provider-side idempotency, then store the response and dedupe/effect state durably before checkpoint. If the provider has no idempotency contract, I use a single effect owner and ledger reconciliation; I do not claim exactly once. I fault-test crashes before/after every boundary."

**Weak signs:** enabling automatic acknowledgement, deleting duplicate broker records, or asserting the broker should never redeliver.

**Follow-up:** What if duplicate broker records have different event IDs? Then the bug is earlier: source construction or producer retry created two logical identities. Fix source/outbox identity and reconcile both effects.

### Scenario: lag rises after traffic doubles, but cluster utilization is 35%

**What the interviewer evaluates:** partition-aware capacity reasoning.

**Strong answer:** "I scope oldest age and per-partition lag, then compare partition ingress and completed effect rates. Cluster average can hide one hot key, one consumer blocked on a database, assignment imbalance or poison retry. I inspect keys, record bytes, group assignments/rebalances, handler versus dependency time, retries and broker throttles. I compute drain from sustainable service minus ongoing ingress at the limiting partition. Adding instances does nothing if one partition or downstream database is the ceiling. I protect the dependency, isolate poison work, fix key/capacity design and validate user outcomes plus retention."

**Weak signs:** add ten consumers or partitions immediately.

**Follow-up:** Why not salt the key? It can break required per-entity order; salting needs an explicit merge and migration design.

### Scenario: design an event flow for orders, inventory and notifications

**What the interviewer evaluates:** contracts, ownership and fan-out.

**Strong answer:** "The order transaction is authoritative and writes an outbox event with stable ID, order ID, revision and schema in the same transaction. A relay publishes at-least-once with order ID as the ordering key if order-local sequence is required. Inventory, billing and notification have independent consumer identities and checkpoints. Each owns an inbox/idempotency record and business effect; notifications use a stable intent ID and suppress replay. I define publisher acknowledgement/replica policy, retry/quarantine/redrive, retention for rebuild, per-partition capacity, schema compatibility, tenant authorization and reconciliation from order facts to effects."

**Weak signs:** one shared consumer group for unrelated effects or "Kafka guarantees exactly once."

**Follow-up:** What if one order produces huge traffic? Revisit invariant granularity, split independent subflows only when merge/order rules remain explicit, and apply admission.

### Scenario: one event blocks a partition

**What the interviewer evaluates:** poison handling without data loss.

**Strong answer:** "I capture event ID, source position, schema, handler version, deterministic error and attempts. I distinguish transient dependency failure from permanent data/code failure. I bound retries with backoff; when exhausted I quarantine with an owner and audit. Whether later records may proceed depends on entity order. If they depend on this revision, I hold or route the entity for repair; blindly dead-lettering and continuing would corrupt order. I repair and redrive an exact set with stable identity and reconcile."

**Weak signs:** discard, infinite retry, or skip without considering order.

### Scenario: migrate from one queue to a partitioned stream

**What the interviewer evaluates:** migration correctness and operability.

**Strong answer:** "I document semantic differences: routing, one-work-item ownership, retention, acknowledgement, order, retry, dead letter, priority and replay. I dual-write only with stable identity and reconciliation, or use a durable bridge with an explicit cutover position. Consumers run in shadow with effects disabled. I compare ordering and outputs, establish retention/capacity/security, then cut over producers and effect owners with a rollback that cannot duplicate work. I keep old recovery data until reconciliation and rollback windows close."

**Weak signs:** mirror messages and switch DNS.

### Scenario: a replay of six months is requested

**What the interviewer evaluates:** senior change and capacity judgment.

**Strong answer:** "I verify the range still exists and that current privacy policy permits processing it. I pin input, code, config and schema. I build a shadow output, disable or idempotently gate emails/payments/webhooks, estimate bytes and dependency work, and set a rate below live spare capacity. I checkpoint replay separately, can pause/resume, and track retention remaining. I reconcile sample and aggregate invariants, review, promote atomically where possible, and retain an audit and cleanup proof."

**Weak signs:** reset the production group to earliest.

### Scenario: a broker loses quorum during peak

**What the interviewer evaluates:** safety versus availability.

**Strong answer:** "I state the configured replication and acknowledgement contract, current members and affected partitions. If the system rejects writes because required replicas are absent, that may preserve the declared durability. I do not lower acknowledgements or allow stale leadership without business approval and quantified loss risk. I degrade at the application boundary, preserve publish intents, restore quorum safely, reconcile ambiguous operations and validate acknowledged positions and user outcomes."

**Weak signs:** force a leader or reduce replica requirements to make graphs green.

### Scenario: explain Kafka, RabbitMQ queues and JetStream without marketing

**What the interviewer evaluates:** mechanism-first comparison.

**Strong answer:** "I compare the exact selected mechanisms. A Kafka partition is a replicated retained append log with offsets and consumer/group positioning. RabbitMQ offers queue semantics with consumer acknowledgements/publisher confirms, quorum queues for replicated queue state, and streams for retained offset-based consumption. JetStream separates stored streams and stateful consumers with retention and acknowledgement policies. I choose from work distribution, fan-out, replay, order, latency, throughput, operational skill, security and recovery, then verify current product versions. None removes application idempotency or reconciliation."

**Weak signs:** simplistic brand rules or universal delivery claims.

## Independent transfer and rubric

The reviewer supplies an unfamiliar synthetic workload packet with:

- business operations and invariants;
- event samples and schemas;
- producer acknowledgement and retry history;
- topic/queue/stream topology and replica settings;
- key and partition distributions;
- consumer assignments, positions, handler/dependency timings;
- duplicate, poison, backlog, rebalance or replay evidence;
- security/privacy and cost constraints;
- one changed constraint after the first design.

The learner must produce:

1. operation, authority and acknowledgement ownership tables;
2. command/event/notification and queue/log decision with rejected alternatives;
3. stable identity, schema and ordering/partition key design;
4. publisher acknowledgement, replica and ambiguity handling;
5. consumer group, flow control, effect and checkpoint crash-window design;
6. idempotency, retry, quarantine and redrive workflow;
7. per-partition backlog/drain, retention, storage/network and dependency calculations;
8. incident containment, recovery, replay and user reconciliation;
9. authentication, authorization, encryption, privacy, observability and cost controls;
10. a revised ADR after the changed constraint, delayed explanation and cleanup proof.

Safety boundaries:

- reviewer-owned disposable local environment only;
- no production/shared broker, real credentials or customer data;
- no host network or clock mutation;
- no unbounded publish, replay or fault;
- preserve exact histories before recovery;
- prove cleanup of processes, ports, files, volumes and data.

Rubric, 100 points:

| Criterion | Points | Observable evidence |
|---|---:|---|
| operation and authority | 10 | invariant, source fact, command/event meaning |
| identity and schema | 10 | stable event/operation IDs, compatibility and size |
| queue/log and routing | 10 | fan-out, replay, order and rejected alternatives |
| acknowledgement and replication | 10 | exact ownership transfer and ambiguity |
| effect and checkpoint | 10 | crash windows, idempotency and reconciliation |
| retry and quarantine | 10 | classification, budget, owner and safe redrive |
| capacity and retention | 10 | per-partition rates, drain, storage and horizons |
| incident and replay | 10 | containment, bounded recovery and user proof |
| security, observability and cost | 10 | least privilege, privacy, signals and trade-offs |
| transfer judgment | 10 | changed-constraint ADR, delayed recall and cleanup |

A score is not awarded by self-report or by the offline verifier. A reviewer must observe the work. Passing requires no critical safety/correctness gap and at least 80/100. Mastery requires successful unseen transfer and delayed recall, not one familiar scenario.

## References and review

Primary sources reviewed on 2026-08-05:

1. REF-0658, Apache Kafka 4.3 design: append-log, batching, partitions, consumer position, delivery semantics, replication and compaction.
2. REF-0659, Kafka producer configurations: acknowledgements, idempotence, retries, in-flight requests, batching, compression and transactions.
3. REF-0660, Kafka consumer/share consumer configurations: group identity, positions, polling, assignment and isolation.
4. REF-0661, Kafka topic configurations: retention, cleanup, message limits and minimum in-sync behavior.
5. REF-0662, Kafka broker configurations: cluster, replication, quotas and security settings.
6. REF-0663, Kafka monitoring: operational metrics and their product-defined scope.
7. REF-0664, Kafka basic operations: topic/group inspection, reassignment and controlled position changes.
8. REF-0665, RabbitMQ reliability guide: connections, acknowledgements and ownership transfer.
9. REF-0666, RabbitMQ acknowledgements and confirms: consumer acknowledgement, publisher confirm, requeue and prefetch.
10. REF-0667, RabbitMQ queues: queue properties, ordering, durability and consumers.
11. REF-0668, RabbitMQ quorum queues: replicated queue behavior, availability, poison handling and dead lettering.
12. REF-0669, RabbitMQ streams and superstreams: retained append data, offsets, replay and partitioning.
13. REF-0670, RabbitMQ consumers: consumer lifecycle, prefetch, capacity and cancellation.
14. REF-0671, NATS JetStream concepts: streams, retention, replay, acknowledgement and flow.
15. REF-0672, NATS JetStream pull consumers: durable consumer state, acknowledgement and redelivery controls.

Product behavior is version- and configuration-dependent. Before a real design or incident change, reopen the exact-version official documentation and client documentation, capture non-default settings, and validate in a disposable representative environment.

Review boundaries:

- This draft has not been formally accepted or published.
- The offline model opens no socket and proves no broker behavior.
- No producer, consumer, message, partition, queue, stream, replica, effect or replay was created.
- No throughput, durability, ordering or exactly-once claim is inferred from synthetic cases.
- Representative runtime faults, reviewer-owned transfer, delayed recall and learner evidence remain mandatory.

Final lesson summary:

1. Name the business operation and authority.
2. Preserve one stable identity through publication, retry, delivery and replay.
3. Treat acknowledgement, replication, effect and checkpoint as separate ownership boundaries.
4. Order only the smallest required scope and capacity-test the hottest partition.
5. Assume redelivery; make effects idempotent, atomic or reconcilable.
6. Bound poison retries and own quarantine/redrive.
7. Recover backlog with spare capacity before retention expires.
8. Fence revoked owners and isolate replay effects.
9. Prove user outcomes, not merely broker health.
