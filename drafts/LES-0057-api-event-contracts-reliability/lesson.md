---
{"schemaVersion":1,"kind":"lesson","id":"LES-0057","slug":"api-event-contracts-reliability","aliases":["V06-L02","api-event-contracts-reliability"],"curriculumIds":["DST-001"],"route":"/book/state/api-event-contracts-reliability","order":2,"volume":"06-state-distributed-systems","title":"API and event architecture: make time, ownership, and delivery explicit","summary":"Choose and operate request/reply, long-running operations, events and webhooks through explicit contracts, state ownership, compatibility, delivery, ordering, replay, security and recovery.","domain":"state","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0015","LES-0021"],"prerequisiteCurriculumIds":["AUT-005","NET-005"],"testedEnvironments":[{"platform":"Standards and primary documentation","version":"HTTP, OpenAPI, AsyncAPI, JSON Schema, CloudEvents, Kafka, Trace Context and related sources reviewed 2026-08-05","support":"concept-only","notes":"No provider, gateway, broker, registry or webhook endpoint is used."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic compatibility and delivery model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions with no socket or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","backend-engineer","integration-engineer","cloud-engineer","solutions-architect","technical-lead"],"learningObjectives":["Choose synchronous request/reply, asynchronous operation, event or webhook boundaries from timing, coupling and ownership requirements.","State exactly what an acknowledgement proves and which component owns authoritative state.","Design operation and event identities that survive retries, duplicates, timeouts and replay.","Separate commands, domain events, integration events, notifications and event-carried state.","Evolve OpenAPI, AsyncAPI and schema contracts across independently deployed producers and consumers.","Design publication and consumption transaction boundaries without claiming unsupported distributed atomicity.","Scope ordering, partition keys, checkpoints, poison handling, retention and replay by business invariant.","Secure APIs and webhooks with authentication, authorization, signature, freshness, least privilege and data minimization.","Correlate request, operation, event, delivery and business outcomes without using trace context as authorization.","Diagnose compatibility, duplicate, ordering, backlog, replay and retry-amplification incidents safely."],"productionSignals":["user operation success latency correctness freshness and duplicate-effect rate","request ID logical operation ID attempt ID deadline status problem type and authoritative receipt","API contract identity server version client version media type and deprecation cohort","event ID source type subject occurrence time schema identity aggregate ID and sequence","producer version publication intent outbox position broker acknowledgement partition and offset","consumer group instance delivery attempt checkpoint processing result and effect receipt","backlog messages bytes age ingress egress retry rate dead-letter or quarantine count","partition count key distribution hot partition throughput and ordering scope","webhook provider delivery ID signature key algorithm timestamp age validation and acknowledgement","compatibility matrix producer consumer schema and actual unknown-field enum and default behavior","trace ID span links request operation event and business correlation with sampling state","authentication principal audience authorization resource tenant and policy decision","payload size sensitive fields retention replay horizon deletion and access audit","queue pool worker concurrency dependency saturation deadline budget and shedding","cost per request event byte retained byte replay telemetry and recovery reserve"],"diagrams":[{"id":"LES-0057-DIA-001","title":"Integration choice map","direction":"hierarchical","boundaries":["immediate request reply","long-running operation resource","durable command","domain or integration event","partner webhook"],"evidencePoints":["caller wait","acknowledgement meaning","state owner","delivery identity","recovery path"],"textAlternative":"Choose request reply for an immediate result, an operation resource for work outliving the request, durable commands for accepted intent, events for past facts and webhooks for external callback delivery."},{"id":"LES-0057-DIA-002","title":"Request to event state path","direction":"left-to-right","boundaries":["client","API boundary","authoritative transaction","outbox","relay and broker","consumer inbox and effect","user view"],"evidencePoints":["operation ID","commit receipt","outbox row","event ID","partition offset","effect receipt","business SLI"],"textAlternative":"A client operation commits authoritative state and publication intent locally, a relay publishes with a stable event ID, and each consumer durably claims and applies one effect before advancing its position."},{"id":"LES-0057-DIA-003","title":"Contract compatibility matrix","direction":"top-to-bottom","boundaries":["old producer","new producer","old consumer","new consumer","schema policy","wire tests"],"evidencePoints":["removed field","required field","type","enum","meaning","unknown behavior"],"textAlternative":"Every producer and consumer version pair is tested because syntax-only schema comparison cannot reveal strict unknown-field handling, changed meaning or runtime defaults."},{"id":"LES-0057-DIA-004","title":"Delivery and ordering path","direction":"left-to-right","boundaries":["producer attempt","broker append","partition order","consumer delivery","local effect","checkpoint","redelivery"],"evidencePoints":["event ID","broker acknowledgement","partition and offset","attempt","effect key","committed position","duplicate"],"textAlternative":"Producer, broker and consumer acknowledgements cover different durable facts; a failure between effect and checkpoint creates redelivery, so the effect needs stable identity and reconciliation."},{"id":"LES-0057-DIA-005","title":"Webhook trust and replay path","direction":"left-to-right","boundaries":["provider","TLS ingress","raw signed material","signature and key","freshness","delivery claim","authorized effect","acknowledgement"],"evidencePoints":["delivery ID","peer","digest","timestamp","age","unique claim","receipt","response"],"textAlternative":"A webhook is accepted only after provider-defined raw signature verification, freshness and durable delivery claiming, then tenant and action authorization precede one effect and prompt acknowledgement."},{"id":"LES-0057-DIA-006","title":"Failure-domain and recovery ladder","direction":"hierarchical","boundaries":["one attempt","one operation or event","consumer instance","partition or queue","broker or region","authoritative state","user journey"],"evidencePoints":["timeout","receipt","restart","backlog","availability","reconciliation","SLI"],"textAlternative":"Failures widen from one attempt through logical work, consumer, partition, broker and state owner to the user; recovery must preserve position, identity and business correctness at each scope."}],"commands":[{"id":"LES-0057-CMD-001","question":"Is the Ubuntu host safe for the offline model?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0057 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"local prerequisites and credential guard pass","nextEvidence":"inspect and setup"},{"when":"lab=fail","meaning":"named safety boundary failed","nextEvidence":"fix without bypass"}],"proves":"local preconditions","doesNotProve":"model or integration behavior"},{"id":"LES-0057-CMD-002","question":"Can the guarded fixture initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"exact local state and fixture validate","nextEvidence":"baseline"},{"when":"failure","meaning":"guard or fixture failed","nextEvidence":"preserve first error"}],"proves":"bounded local initialization","doesNotProve":"API or broker behavior","cleanup":"Run bash lab.sh cleanup after successful setup."},{"id":"LES-0057-CMD-003","question":"Does the baseline cross every encoded boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0057 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded controls pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"fixture or model differs","nextEvidence":"inspect first failure"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0057-CMD-004","question":"Does removing a field break supported consumers?","risk":"read-only","command":"bash lab.sh evaluate removed-field","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"compatibility-remove","meaning":"old field contract was withdrawn","nextEvidence":"versioned migration"}],"proves":"encoded removal boundary","doesNotProve":"real consumer behavior"},{"id":"LES-0057-CMD-005","question":"Does adding a required field reject older producers?","risk":"read-only","command":"bash lab.sh evaluate new-required","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"compatibility-required","meaning":"old producers cannot satisfy new input","nextEvidence":"optional expansion then migration"}],"proves":"encoded required-field boundary","doesNotProve":"schema-registry policy"},{"id":"LES-0057-CMD-006","question":"Did type or meaning change incompatibly?","risk":"read-only","command":"bash lab.sh evaluate changed-type","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"compatibility-type","meaning":"wire type changed","nextEvidence":"new field or explicit version"}],"proves":"encoded type boundary","doesNotProve":"semantic compatibility"},{"id":"LES-0057-CMD-007","question":"Can an older strict consumer accept an additive field?","risk":"read-only","command":"bash lab.sh evaluate strict-consumer","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"forward-compatibility","meaning":"unknown-field rejection breaks the pair","nextEvidence":"actual old/new matrix"}],"proves":"encoded consumer behavior","doesNotProve":"all consumers"},{"id":"LES-0057-CMD-008","question":"Can redelivery produce one business effect?","risk":"read-only","command":"bash lab.sh evaluate duplicate-no-claim","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"duplicate-safety","meaning":"identity or durable claim is missing","nextEvidence":"inbox or idempotent state transition"}],"proves":"encoded duplicate gap","doesNotProve":"end-to-end exactly once"},{"id":"LES-0057-CMD-009","question":"Is required ordering preserved?","risk":"read-only","command":"bash lab.sh evaluate ordering-no-sequence","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"ordering","meaning":"key or sequence cannot prove aggregate order","nextEvidence":"scope order and reconciliation"}],"proves":"encoded order gap","doesNotProve":"broker ordering"},{"id":"LES-0057-CMD-010","question":"Can an authentic old webhook be replayed?","risk":"read-only","command":"bash lab.sh evaluate replay-no-freshness","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"replay","meaning":"freshness control is absent","nextEvidence":"timestamp window and durable delivery claim"}],"proves":"encoded replay gap","doesNotProve":"signature security"},{"id":"LES-0057-CMD-011","question":"Are multiple retry owners amplifying work?","risk":"read-only","command":"bash lab.sh evaluate multi-retry-owners","runFrom":"LES-0057 support/lab","expectedBranches":[{"when":"retry-amplification","meaning":"ownership budget or deadline is unsafe","nextEvidence":"one owner and fleet budget"}],"proves":"encoded amplification boundary","doesNotProve":"traffic rate"},{"id":"LES-0057-CMD-012","question":"Does every case, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0057 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"twelve cases refusal and absence pass","nextEvidence":"record model limits"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"HTTP broker registry webhook provider or production behavior","cleanup":"Verifier proves exact UID-scoped state absence."}],"labs":[{"id":"LES-0057-LAB-001","title":"Guided compatibility and delivery-boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one exact UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","cloud or database credential","network or endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and correct only the copied fixture or model under review.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0057-api-event-contracts-reliability/support/lab"},{"id":"LES-0057-LAB-002","title":"Independent integration architecture review","mode":"independent","environment":"Reviewer-owned sanitized OpenAPI, AsyncAPI, schema, event and incident packet; no live endpoint","timeMinutes":240,"privilege":"normal user","network":"none","changes":["local diagrams","compatibility matrix","capacity and recovery notes"],"abortConditions":["credential","live endpoint","broker","customer payload","production mutation","unapproved replay"],"recovery":"Discard reviewer-owned artifacts after scored evidence is retained.","cleanupProof":"Reviewer proves no process, credential, connection or external resource exists.","path":"drafts/LES-0057-api-event-contracts-reliability/support/lab"}],"incidents":[{"id":"LES-0057-INC-001","signal":"New optional event field causes one consumer group to reject every delivery.","firstThought":"Compatibility depends on actual old-consumer unknown-field behavior, not additive syntax.","safePath":"Preserve log and position, contain amplification, test old/new matrix, repair or version, replay and reconcile effects.","trap":"Retry forever or delete the poison event."},{"id":"LES-0057-INC-002","signal":"Client timed out, retried with a new key, and two orders exist.","firstThought":"Attempt identity replaced logical-operation identity and commit was ambiguous.","safePath":"Reconcile authoritative receipts, stop unsafe retries, preserve one stable operation key and correct duplicate state by business policy.","trap":"Assume timeout means rollback."},{"id":"LES-0057-INC-003","signal":"Consumer restart repeats a financial effect after processing but before checkpoint.","firstThought":"Effect and checkpoint are separate commits; redelivery is expected.","safePath":"Claim stable event identity with the effect, reconcile duplicates, then resume from preserved position.","trap":"Advance offsets before effects or claim end-to-end exactly once."},{"id":"LES-0057-INC-004","signal":"Validly signed old webhooks repeat notifications.","firstThought":"Authenticity did not prove freshness or once-only processing.","safePath":"Verify raw signature contract, bound timestamp age, durably claim delivery ID, authorize effect and acknowledge according to provider rules.","trap":"Rotate the secret and ignore replay state."},{"id":"LES-0057-INC-005","signal":"Backlog age rises while retries, consumers and dependency errors all grow.","firstThought":"Retry and concurrency amplification exceed the slowest dependency or partition capacity.","safePath":"Graph arrivals attempts age partitions concurrency and dependency saturation; choose one retry owner, bound work, protect critical flow and verify drain.","trap":"Add consumers without checking hot keys or downstream limits."}],"assessmentIds":["ASM-0154","ASM-0155","ASM-0156"],"referenceIds":["REF-0613","REF-0614","REF-0615","REF-0616","REF-0617","REF-0618","REF-0619","REF-0620","REF-0621","REF-0622","REF-0623","REF-0624","REF-0625","REF-0626","REF-0627"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The model opens no socket and is not an API server, broker, schema registry, webhook receiver or provider emulator.","Synthetic compatibility decisions do not prove real serializer, generator, consumer or broker behavior.","No durable log, partition, offset, outbox, inbox, replay, signature, TLS, identity or external effect exists.","Versions, specifications, provider webhook rules and product behavior require current review.","Formal review, publication, reviewer transfer, delayed recall and learner evidence remain required."]}
---

# API and event architecture: make time, ownership, and delivery explicit

## What you see and first thought

When someone says “the event was lost” or “the API succeeded,” slow down. Those sentences hide several different facts.

Ask: which user operation, which logical operation ID, which attempt, which state owner, which acknowledgement, which event ID, which producer and consumer versions, which partition or delivery, and which business effect? A 202 response may prove only that work was accepted. A broker acknowledgement may prove an append, not consumption. A consumer checkpoint may prove position advanced, not that an external payment happened once.

Remember:

> Every acknowledgement has a scope. Reliability begins when you can say exactly what durable fact it proves and what remains unknown.

Do not choose REST, Kafka or webhooks by fashion. Choose the interaction shape from time, coupling, ownership, audience and failure:

- Does the caller need an immediate answer?
- Can work outlive the request?
- Is the message an instruction or a fact?
- Who owns truth?
- Can consumers be temporarily unavailable?
- Must effects be ordered, and within what key?
- Can messages repeat?
- Can old and new versions coexist?
- How will ambiguity be reconciled?

## Terms before commands

A **request/reply** interaction couples a caller to a responder for the duration of one attempt. It is useful when the caller needs an immediate result. It is not automatically tightly coupled in every dimension, but timing and availability are connected.

A **long-running operation resource** lets a server accept work, return a stable operation identity and expose later state. The initial response must say accepted, not completed.

A **command** asks an owner to attempt a state change: CreateOrder. A **domain event** states a past fact meaningful inside a domain: OrderAccepted. An **integration event** is a deliberately published fact for other domains. Naming an instruction as a past-tense event hides ownership and rejection semantics.

A **notification event** says something changed and consumers query the owner for current truth. An **event-carried-state transfer** includes enough state for consumers to update a local view without calling back. The latter improves autonomy but duplicates data and expands schema, privacy, retention and staleness responsibilities.

A **channel** is a logical path for messages. A **broker** accepts, stores or forwards messages according to its contract. A **queue** commonly distributes work among consumers; a **stream or log** commonly retains ordered records for independent readers. Product behavior varies.

A **producer** emits a message. A **consumer group** coordinates instances sharing a logical subscription. A **partition** is an ordered shard in many logs. Ordering is normally scoped to one partition, not the whole system. The **partition key** decides which records share that order and load.

An **offset** or checkpoint names consumer progress. Advancing it before an effect risks loss; advancing after an effect can permit redelivery. Therefore the effect needs idempotency or an inbox transaction.

**At-most-once** can lose but avoids protocol redelivery. **At-least-once** can redeliver and requires duplicate-safe effects. Product **exactly-once** mechanisms have a defined transaction scope; they do not automatically make an email, payment or external database effect happen once.

A **schema** describes allowed message structure. **Backward compatibility** lets newer producers or providers keep supported older consumers working. **Forward compatibility** lets older consumers tolerate allowed newer data. Actual serializer and consumer behavior decides compatibility.

A **poison message** repeatedly fails deterministic processing. A **dead-letter** or quarantine path isolates it under policy; it is not a trash can. Preserve identity, reason, payload governance, original position and a replay or reconciliation owner.

**Replay** reads retained messages again. Rebuilding a derived view may be safe. Repeating an external side effect may not be. Replay needs a target, time or position range, idempotency boundary, rate limit and validation.

A **webhook** is an HTTP callback from an external producer. Delivery is normally retryable and can repeat. A valid signature can authenticate protected material; freshness, authorization and duplicate claiming remain separate controls.

## Architecture map

Use this choice map:

    immediate decision needed?
      yes -> request/reply with deadline and idempotency
      no  -> work outlives request?
               yes -> operation resource or durable command
               no  -> past fact useful to independent consumers?
                        yes -> domain/integration event
                        external callback -> webhook delivery contract

Then trace state:

    client request
      -> API validation and authorization
      -> authoritative local transaction
           + business state
           + operation receipt
           + outbox publication intent
      -> relay -> broker append -> partition and offset
      -> consumer delivery -> inbox/effect transaction -> checkpoint
      -> read model or external outcome -> user SLI

Text equivalent for LES-0057-DIA-002: local state and publication intent commit together, while publication and consumption remain retryable; stable identities and receipts connect each boundary.

Separate contracts:

    OpenAPI: request/reply operations and representations
    AsyncAPI: channels, operations, messages and bindings
    JSON Schema: selected data-shape vocabulary
    CloudEvents: interoperable event context envelope
    runtime policy: timing, ordering, retries, compatibility, retention

Machine descriptions never capture every semantic and operational promise. Keep prose and tests for acknowledgement meaning, idempotency scope, consumer expectations, deprecation, rate limits and recovery.

## Request or state path

Trace checkout:

1. Client creates one logical operation ID and a deadline.
2. API authenticates the principal, authorizes the exact resource and validates the request contract.
3. A short database transaction claims the operation ID, changes order state and writes an outbox record.
4. Commit makes the order and publication intent durable together.
5. The API returns the committed order or an operation resource. It never calls queued work completed.
6. A relay reads the outbox and publishes a stable event ID. A lost acknowledgement can cause republish.
7. The broker assigns partition and position according to its contract.
8. A consumer receives the event, validates envelope and schema, checks authorization or tenant scope, and atomically claims event ID with its local effect.
9. Only after durable effect does it settle or checkpoint. Failure before that can redeliver.
10. Derived views and downstream work expose freshness and correctness.
11. Correlation links request, operation, event, delivery and business outcome.

For a webhook, replace broker append with provider delivery. Preserve provider-defined raw signed bytes, verify the key and algorithm, check timestamp freshness, durably claim the delivery ID, authorize the tenant action, store the effect receipt, and acknowledge quickly. A lost response means redelivery is normal.

## Failure zoom

    one attempt -> one logical operation -> one message
                -> one consumer group -> one partition
                -> broker or region -> authoritative state -> user journey

A caller timeout does not reveal commit state. A publish timeout does not reveal whether the broker appended. A consumer crash does not reveal whether its local effect committed. Treat each as unknown until the state owner or durable receipt answers.

Compatibility failure is another scope. One strict consumer can fail while tolerant consumers continue. A schema registry accepting a change proves policy evaluation, not every generated client, default, enum or semantic assumption.

Ordering failure also has scope. If order 42 events use one stable key, that aggregate can retain partition order. Cross-order global order may not exist. Changing partition count or key algorithm can change placement; a sequence number and reconciliation rule help detect stale or missing transitions.

## Internals and state ownership

The request handler owns one attempt, not necessarily the final workflow. The authoritative database owns order state. An operation record owns long-running status. The outbox owns publication intent. The broker owns records within its retention and acknowledgement contract. Each consumer owns its local derived state and checkpoint. The user-facing service owns the final SLI.

The dual-write gap appears when code commits business state and publishes separately. If state commits but publication fails, consumers miss the fact. If publish succeeds but state rolls back, consumers see a fact that never became true. An outbox puts business state and publication intent in one local transaction. A relay publishes repeatedly until acknowledged. This closes one local gap but still permits duplicates.

On consumption, doing the effect then checkpointing permits duplicate effect after a crash. Checkpointing first permits loss. An inbox or idempotency record committed with the local effect makes redelivery detectable. External effects still require their own operation identity and reconciliation.

Event envelopes need stable identity, source, type, subject where useful, time semantics, data content type and schema identity. Domain data needs an aggregate or business identity and, when order matters, a sequence or version. Do not use trace ID as event identity: sampling and retried traces have different lifecycles.

Compatibility is semantic:

| Change | Common risk |
|---|---|
| remove field | old consumer requires it |
| add required input | old producer cannot send it |
| change type | parser or generated client fails |
| narrow enum | existing value becomes invalid |
| add enum value | exhaustive old consumer fails |
| change default | behavior changes without wire difference |
| reuse field | same bytes acquire new meaning |
| add optional field | strict unknown-field consumer rejects |

Use expand, migrate, contract. Add tolerant representations, deploy consumers, observe inventory and adoption, switch producers, drain retained old data, then remove only after the support contract permits it.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| request accepted | operation ID and durable receipt | work completed |
| broker acknowledged | producer identity, topic, partition and position | consumer effect |
| event processed | event ID and local effect receipt | external side effect once |
| checkpoint advanced | group, partition and position | prior effects correct |
| change is compatible | actual old/new producer-consumer matrix | unknown future consumer |
| ordering preserved | key, partition, sequence and observed range | global order |
| duplicate safe | repeated event yields one business effect | every downstream dependency |
| webhook authentic | exact protected material, key and signature result | freshness or authorization |
| replay complete | range, counts, gaps, duplicates and target validation | unrelated effects unchanged |
| recovered | fresh user operation, correct state and stable backlog | prevention complete |

## Command decoders

Run the offline fixture only from its lab directory:

    bash lab.sh setup
    bash lab.sh evaluate baseline

An operable baseline means only that the model's ordered boundaries pass. It does not mean an architecture with those Boolean fields is production-ready.

    bash lab.sh evaluate removed-field
    bash lab.sh evaluate new-required
    bash lab.sh evaluate changed-type
    bash lab.sh evaluate strict-consumer

These separate removal, required-input, wire-type and actual unknown-field behavior. The model deliberately stops at the first failing boundary. Real compatibility tools must use the exact schema vocabulary and policy, and wire tests must cover serializers and generated code.

    bash lab.sh evaluate duplicate-no-claim
    bash lab.sh evaluate ordering-no-sequence
    bash lab.sh evaluate replay-no-freshness
    bash lab.sh evaluate multi-retry-owners

These outputs are decision prompts. A stable event ID does nothing unless an owner durably claims it with the effect. A sequence detects some ordering problems but cannot restore missing state alone. Signature freshness does not deduplicate. One retry owner still needs a deadline and attempt budget.

## Decision path

Choose interaction shape:

1. If the caller must know the result now and the work fits a bounded deadline, use request/reply.
2. If work outlives the deadline, return an operation resource or accept a durable command.
3. If independent consumers need a past fact, publish an event.
4. If consumers should query current truth, use notification; if autonomy is worth duplicated data and governance, carry state.
5. If an external partner calls you, treat the webhook as at-least-once untrusted input.

For each boundary answer:

- What durable fact does success acknowledge?
- What is the stable logical identity?
- Which state owner can reconcile unknown?
- Where can duplication occur?
- What ordering scope is required?
- Which versions coexist?
- What is retained, replayed and deleted?
- Who owns retry, queue and capacity budgets?

## Guided Ubuntu lab

From Ubuntu 24.04 as a normal user:

    cd drafts/LES-0057-api-event-contracts-reliability/support/lab
    bash lab.sh doctor
    bash lab.sh setup
    bash lab.sh status

Doctor refuses root, wrong OS version and common credential variables. Setup creates one exact UID-scoped temporary directory and copies only the synthetic fixture. No socket or external command is used.

Evaluate baseline, then predict each negative case before running it:

    bash lab.sh evaluate baseline
    bash lab.sh evaluate strict-consumer
    bash lab.sh evaluate duplicate-no-claim
    bash lab.sh evaluate ordering-no-sequence
    bash lab.sh evaluate replay-no-freshness
    bash lab.sh evaluate multi-retry-owners
    bash lab.sh evaluate notification-no-owner

For each, write the first broken boundary, evidence needed in production, smallest safe containment, recovery proof and what the model cannot prove.

Test refusal:

    bash lab.sh inject-unknown
    bash lab.sh status

Status must fail because cleanup ownership is uncertain. Then run:

    bash lab.sh clear-unknown
    bash lab.sh cleanup

The full verifier from absent state is:

    bash verify.sh

Expected final line:

    verify=pass cases=12 refusal=true cleanup=true

## Production transfer

Build an integration inventory with owner, operation or event, producer versions, consumer versions, schema identity, acknowledgement, identity, retry owner, ordering key, retention, replay, data class, SLI and retirement date.

For an incompatible event incident:

1. freeze unrelated contract and consumer changes;
2. preserve topic, partition, offset, event and schema identities;
3. measure affected groups and business backlog age;
4. stop deterministic retry amplification;
5. test actual producer-consumer version pairs;
6. roll back producer, deploy tolerant consumer or route an explicit new contract;
7. replay from preserved position at bounded rate;
8. reconcile effects, gaps, duplicates and user freshness.

For migration from synchronous fan-out to events, do not simply replace calls. Decide which response data the caller still needs, establish authoritative state and operation status, publish facts after local commit, build consumer views, compare shadow outcomes, shift reads and work gradually, and retain rollback until lag and correctness are proven.

## Reliability, security, observability, capacity, and cost

Reliability: use stable operation and event identities, short local transactions, outbox/inbox patterns, bounded deadlines, one retry owner per boundary, poison isolation, reconciliation and user-centered freshness. Avoid global ordering unless the invariant pays its throughput and availability cost.

Security: authenticate producer or caller, authorize action and resource, validate size and schema, protect broker and registry administration, minimize payload, encrypt transport and storage, and audit replay. For webhooks, signature, freshness, durable delivery claim and tenant authorization are independent.

Observability: correlate request, operation, event and effect. Measure logical operations separately from attempts; producer errors, append latency, backlog age, partitions, hot keys, consumer failures, redelivery, poison count, checkpoint lag and business freshness. Trace links explain causality candidates; they do not grant access.

Capacity: arrival rate, message bytes, partitions, consumer service time, dependency concurrency, retention and replay all matter. Average backlog drain requires consumer goodput above arrivals. During replay, reserve live-traffic capacity and bound catch-up so recovery does not create another incident.

Cost: count API compute, gateway, broker ingress/egress, partitions, retained bytes, cross-zone transfer, registry, webhook delivery, replay, telemetry and team operations. Event-driven architecture can decouple time but adds durable state, compatibility and recovery work.

## Traps and prevention

**202 means completed.** It usually means accepted under a defined contract. Prevent false success with an operation resource and final business SLI.

**Broker acknowledgement means user success.** It proves only the broker's documented acceptance scope. Preserve operation state and trace to consumer effect.

**Exactly once means every effect once.** Mechanisms cover named transactions and resources. Use stable business identity, local atomic claim and reconciliation at every external boundary.

**Optional additions never break.** Strict consumers, generated enums and changed defaults break. Maintain consumer inventory and old/new wire matrices.

**New topic equals versioning.** Parallel topics make a migration explicit but add dual publication, retention and retirement. State support windows and ownership.

**One queue preserves global order.** Ordering scope follows product and partition design. Define the smallest business key and sequence; reconcile gaps.

**Dead-letter means solved.** Quarantine without owner, data protection and replay policy becomes silent loss. Alert on age and business impact.

**More consumers always drain faster.** Hot keys, partition count and downstream capacity can cap throughput. Measure useful goodput and failure amplification.

**Signature means safe webhook.** Authentic old data can replay and an authentic provider may request an unauthorized tenant effect. Add freshness, durable claim and authorization.

**Trace ID is idempotency key.** Trace sampling and retry lifecycles differ. Use domain operation and event identities.

## Memory card and retrieval

Remember six sentences:

1. Every acknowledgement proves one bounded durable fact.
2. Commands request change; events state past facts.
3. Outbox closes a local state/publication gap but does not remove duplicates.
4. Effect and checkpoint are separate unless one transaction owns both.
5. Compatibility belongs to actual producer-consumer pairs.
6. Replay is a production change with identity, rate, scope and validation.

Incident card:

    OPERATION: user result and deadline
    IDENTITY: operation event delivery attempt
    OWNER: authoritative state and receipts
    CONTRACT: schema producer consumer versions
    DELIVERY: acknowledgement partition offset checkpoint
    EFFECT: idempotency ordering gaps duplicates
    DEBT: backlog age poison retention replay
    PROOF: fresh operation correct state stable drain

## Complete answers

### When should I use synchronous versus asynchronous integration?

Use synchronous request/reply when the caller needs an immediate result and work fits a bounded deadline. Use an operation resource or durable command when work outlives the request. Publish events when independent consumers need past facts and temporary consumer unavailability should not block the producer.

The senior answer includes trade-offs: asynchronous delivery reduces temporal coupling but adds durable queues, identity, duplicate handling, ordering, compatibility, retention, replay and eventual-consistency UX. Do not choose from product popularity.

### What does at-least-once require?

Assume a message can repeat after lost acknowledgements, consumer crashes or retry. Give it stable identity. Atomically claim identity with the local business effect, or make the state transition conditionally idempotent. Advance position only after the durable effect. Reconcile ambiguous external outcomes.

Deduplicating only in process memory fails after restart. Deduplication retention must cover expected redelivery and replay horizons.

### Explain the outbox pattern and its limits.

The service commits business state and an outbox row in one local transaction. A relay publishes the row and can retry. This prevents committed state with no durable publication intent. A lost broker acknowledgement can still duplicate publication. Consumers still need idempotency. Relay lag, ordering, cleanup, schema and poison rows remain operational work.

### How do you evolve event contracts?

Inventory producers and consumers, define compatibility direction and actual unknown-field, enum and default behavior, then test old/new matrices. Expand with tolerant fields or a new semantic event, deploy consumers, observe adoption, switch producers, drain retained old data and contract only after the support window. Never reuse a field with a new meaning.

### How do you handle out-of-order events?

First state whether order matters and by which aggregate. Use a stable partition key where supported and carry an aggregate sequence or version. Consumers reject or hold impossible transitions, detect gaps, query authoritative state or replay a bounded range, and make corrections idempotent. Do not impose global order for a per-order invariant.

### How do you secure a webhook?

Use TLS, preserve exact provider-defined signed material, verify key and algorithm without leaking the secret, enforce timestamp or expiry freshness, durably claim delivery ID, validate size and schema, authorize tenant/action, store effect receipt and acknowledge promptly. Rotate keys with overlap and tests. A signature alone proves neither freshness nor authorization.

### What does recovery from a poison message require?

Preserve original identity, position, safe payload evidence and error. Stop deterministic retry storms. Decide whether to roll back code, transform under an approved contract, deploy a compatible consumer, quarantine with an owner, or compensate. Replay from a preserved position at bounded rate and verify business gaps, duplicates and backlog.

## Product-company interview

### Design an order event platform

**Strong answer:** define user operations and authoritative order state; synchronous checkout returns committed status or an operation ID. Commit state and outbox together. Publish past-tense integration events with stable IDs, schema identity, aggregate key and sequence. Partition by order when that order matters. Consumers claim event ID with local effects and checkpoint afterward. Maintain compatibility matrices, bounded retries, poison policy, replay runbook, freshness SLI and security/retention controls.

**Weak signs:** Kafka provides exactly once; events never duplicate; a schema registry guarantees compatibility; global order is free.

### Backlog rises after adding consumers

Inspect arrivals versus useful completions, partition assignment, hot keys, rebalances, processing latency, retry attempts, poison records and downstream saturation. More consumers cannot exceed useful partitions or the slowest dependency. Bound retries and concurrency, protect live traffic and scale only the confirmed bottleneck.

### API or event?

Ask what the caller must know now, who owns truth, whether consumers are known, how failure is surfaced and whether temporary unavailability should block work. A query for current truth is naturally request/reply. A past fact for several independent consumers is naturally an event. A command over a broker is still a request to an owner and needs rejection and status semantics.

### Staff follow-up: event notification or event-carried state?

Notification keeps one owner and small messages but creates callback load and temporal coupling during consumer refresh. Event-carried state gives autonomous local reads and replay but duplicates sensitive data and increases contract, retention, deletion and staleness burden. Choose per consumer objective, not one organization-wide rule.

## Independent transfer and rubric

Complete ASM-0156 without model answers. A reviewer changes timing, volume, privacy, compatibility or recovery after the first design.

Required artifacts: interaction decision map; state/trust/failure diagram; acknowledgement ledger; operation and event identity; producer-consumer matrix; publication and effect transaction design; partition/order/checkpoint policy; webhook trust path; capacity/retry/backlog model; recovery and cost review.

Safety-critical failures are live credentials or endpoints, customer payload, unapproved replay, deleting retained messages, treating signature as authorization, unfenced duplicate effects, unbounded retries, or claiming exactly-once beyond evidence.

Pass requires at least 80/100, no safety-critical failure, reviewer observation, changed-constraint adaptation and delayed recall. Reading or automated model output does not award mastery.

## References and review

- REF-0613 and REF-0614: HTTP semantics and problem details.
- REF-0615 through REF-0617: OpenAPI, AsyncAPI and JSON Schema contracts.
- REF-0618 and REF-0619: CloudEvents envelope and rationale.
- REF-0620 and REF-0621: Kafka delivery and producer-idempotence scope.
- REF-0622: backward-compatibility guidance.
- REF-0623 and REF-0624: webhook operations and provider-specific signature validation.
- REF-0625 and REF-0626: trace context and messaging spans.
- REF-0627: API security risk categories.

Review questions: Does every acknowledgement have scope? Is state ownership explicit? Are command and fact distinguished? Are duplicate, order and unknown outcomes recoverable? Does compatibility use real old/new pairs? Can replay avoid repeating external effects? Are security, retention, capacity, cost and user proof present?

This is a quarantined substantive candidate. The offline model is teaching evidence only. It is not protocol, broker, provider, formal review, learner transfer or mastery evidence.
