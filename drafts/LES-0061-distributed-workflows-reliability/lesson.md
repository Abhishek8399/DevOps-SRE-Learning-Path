---
{"schemaVersion":1,"kind":"lesson","id":"LES-0061","slug":"distributed-workflows-reliability","aliases":["V06-L06","distributed-workflows-reliability"],"curriculumIds":["DST-006"],"route":"/book/state/distributed-workflows-reliability","order":6,"volume":"06-state-distributed-systems","title":"Distributed workflow reliability: make partial success recoverable","summary":"Design cross-service workflows with explicit state, local transactions, sagas, compensation, transactional outboxes, idempotent effects, deterministic replay, reconciliation and owned manual recovery.","domain":"state","level":{"from":"advanced","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0057","LES-0058","LES-0060"],"prerequisiteCurriculumIds":["DST-001","DST-002","DST-004","RES-001"],"testedEnvironments":[{"platform":"Official documentation","version":"Current primary sources reviewed 2026-08-05","support":"concept-only","notes":"Documentation review does not establish a deployment's behavior."},{"platform":"Ubuntu","version":"24.04 normal-user offline model","support":"required","notes":"Guarded deterministic architecture-boundary model only."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions; no socket, workflow engine, database, broker or third-party package."}],"targetRoles":["site-reliability-engineer","platform-engineer","devops-engineer","backend-engineer","cloud-engineer","data-platform-engineer","solutions-architect","technical-lead"],"learningObjectives":["Keep one local ACID transaction when one authority can safely own the invariant.","Explain when 2PC is available and why its coordinator, locks and failure behavior may be unsuitable.","Model a cross-service business operation as an explicit durable state machine.","Choose choreography or orchestration from workflow complexity, coupling, ownership and observability.","Classify steps as compensable, pivot or retryable and order irreversible effects safely.","Treat compensation as a new idempotent business action that can fail, not a time-reversing rollback.","Close the state-and-publish gap with a transactional outbox while retaining duplicate-aware consumers.","Design stable workflow, operation, step, event, effect and compensation identities.","Place effects and checkpoints so every crash window is retryable or reconcilable.","Bound retry, timeout, deadline, terminal state and human intervention ownership.","Version workflow history and event schemas so old executions remain recoverable.","Use semantic locks, versions or commutative operations to control concurrent workflows.","Reconcile authoritative records, workflow history, outbox, downstream effects and user outcome.","Operate workflow capacity, retention, security, observability and cost as one recovery envelope."],"productionSignals":["business operation workflow and user outcome","workflow ID run ID operation ID step ID event ID effect ID","workflow state version transition reason and timestamp","participant command attempt result latency and deadline","forward step compensation pivot and terminal classification","retry class attempt budget next time and exhausted reason","workflow history size age version replay and nondeterminism","local transaction commit and outbox row identity","outbox oldest age row count bytes relay position and publish latency","relay lease epoch fencing and duplicate publish count","inbox/dedupe hit effect result and checkpoint","compensation attempts result age and manual escalation","concurrent workflow entity version semantic lock and conflict","schema version compatibility failure and unknown field","authorization decision principal policy version and effect time","reconciliation mismatch type age owner and repair result","stuck active workflows by state age and business value","dependency latency errors saturation and circuit state","worker queue poll execution heartbeat and task age","retention remaining versus maximum recovery horizon","trace links logs metrics audit and user-correlation coverage","CPU memory database locks IOPS broker bytes history storage and cost"],"diagrams":[{"id":"LES-0061-DIA-001","title":"Distributed operation ownership path","direction":"left-to-right","boundaries":["client intent","workflow authority","participant local transaction","outbox and relay","downstream effect","checkpoint","reconciliation and user proof"],"evidencePoints":["operation ID","workflow state","commit","event ID","effect ID","step state","outcome"],"textAlternative":"A stable business operation crosses a durable workflow, local commits, outbox delivery, idempotent effects, checkpoints and final reconciliation."},{"id":"LES-0061-DIA-002","title":"Local transaction versus distributed workflow","direction":"hierarchical","boundaries":["one authority and database","local ACID transaction","multiple independent authorities","2PC option","saga option","manual recovery"],"evidencePoints":["invariant owner","transaction scope","participants","prepare state","compensation","terminal owner"],"textAlternative":"Use local ACID when one authority owns the invariant; cross-service work requires an explicit coordination and recovery choice."},{"id":"LES-0061-DIA-003","title":"Saga state machine","direction":"left-to-right","boundaries":["requested","validated","compensable steps","pivot","retryable steps","completed","compensating","manual"],"evidencePoints":["state version","step ID","result","pivot record","attempt","terminal reason","owner"],"textAlternative":"Validations precede compensable actions, the pivot marks the point of no return, and later retryable steps must reach a terminal state."},{"id":"LES-0061-DIA-004","title":"Transactional outbox crash closure","direction":"hierarchical","boundaries":["business transaction","domain state row","outbox row","transaction log","relay lease","broker","idempotent consumer"],"evidencePoints":["commit ID","event ID","log position","relay epoch","publish ack","inbox key"],"textAlternative":"Business state and outbox record commit atomically; a fenced relay may publish more than once, so the consumer deduplicates by stable event ID."},{"id":"LES-0061-DIA-005","title":"Effect and checkpoint crash windows","direction":"left-to-right","boundaries":["step scheduled","dedupe claim","external effect","effect result","workflow checkpoint","redelivery","reconciliation"],"evidencePoints":["step ID","effect key","provider response","result record","history event","attempt","ledger comparison"],"textAlternative":"External effects can succeed before a workflow records success; stable effect identity and reconciliation make the ambiguous window recoverable."},{"id":"LES-0061-DIA-006","title":"Workflow recovery envelope","direction":"hierarchical","boundaries":["active workflows","worker capacity","dependency capacity","outbox retention","history retention","schema/code versions","manual queue","business objective"],"evidencePoints":["arrival rate","service rate","oldest age","recovery horizon","build ID","owner age","user SLI"],"textAlternative":"Recovery requires enough worker and dependency spare capacity, retained evidence, compatible code and an owned manual path before the business deadline."}],"commands":[{"id":"LES-0061-CMD-001","question":"Is this the supported offline boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0061 support/lab as normal Ubuntu 24.04 user","expectedBranches":[{"when":"doctor=pass","meaning":"guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a guard failed","nextEvidence":"correct without bypass"}],"proves":"local preconditions","doesNotProve":"workflow engine behavior"},{"id":"LES-0061-CMD-002","question":"Can synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"fixture and inventory pass","nextEvidence":"baseline"},{"when":"failure","meaning":"state is rejected","nextEvidence":"preserve first error"}],"proves":"bounded initialization","doesNotProve":"distributed transaction setup","cleanup":"Run bash lab.sh cleanup."},{"id":"LES-0061-CMD-003","question":"Does the baseline cross every declared boundary?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0061 support/lab after setup","expectedBranches":[{"when":"boundary=operable","meaning":"encoded conditions pass","nextEvidence":"negative cases"},{"when":"another boundary","meaning":"model differs","nextEvidence":"inspect the first failed boundary"}],"proves":"baseline model decision","doesNotProve":"production readiness"},{"id":"LES-0061-CMD-004","question":"Is a distributed workflow actually necessary?","risk":"read-only","command":"bash lab.sh evaluate single-store-overcomplicated","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=transaction-boundary","meaning":"one local authority can own the invariant","nextEvidence":"prefer local ACID"}],"proves":"encoded scope error","doesNotProve":"service ownership"},{"id":"LES-0061-CMD-005","question":"Can state commit without its notification?","risk":"read-only","command":"bash lab.sh evaluate state-outbox-split","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=state-publish-gap","meaning":"dual write can diverge","nextEvidence":"atomic outbox or equivalent"}],"proves":"encoded dual-write gap","doesNotProve":"database atomicity"},{"id":"LES-0061-CMD-006","question":"Can redelivery duplicate the external effect?","risk":"read-only","command":"bash lab.sh evaluate effect-not-idempotent","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=duplicate-effect","meaning":"retry can apply the business effect twice","nextEvidence":"stable effect key and reconciliation"}],"proves":"encoded duplicate window","doesNotProve":"provider behavior"},{"id":"LES-0061-CMD-007","question":"Can compensation itself duplicate?","risk":"read-only","command":"bash lab.sh evaluate compensation-not-idempotent","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=duplicate-compensation","meaning":"recovery action is unsafe to retry","nextEvidence":"idempotent compensation identity"}],"proves":"encoded compensation gap","doesNotProve":"business reversibility"},{"id":"LES-0061-CMD-008","question":"Is the irreversible step ordered safely?","risk":"read-only","command":"bash lab.sh evaluate pivot-before-validation","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=irreversible-order","meaning":"point of no return precedes required validation","nextEvidence":"reorder or add explicit manual outcome"}],"proves":"encoded pivot-order gap","doesNotProve":"legal reversibility"},{"id":"LES-0061-CMD-009","question":"Can old history replay under new code?","risk":"read-only","command":"bash lab.sh evaluate replay-nondeterministic","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=nondeterministic-replay","meaning":"history no longer determines the same decisions","nextEvidence":"version workflow logic"}],"proves":"encoded replay gap","doesNotProve":"engine compatibility"},{"id":"LES-0061-CMD-010","question":"Can an old authorization decision cause a later effect?","risk":"read-only","command":"bash lab.sh evaluate authorization-stale","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=stale-authorization","meaning":"effect uses stale authority","nextEvidence":"authorize at durable effect boundary"}],"proves":"encoded authorization timing gap","doesNotProve":"policy correctness"},{"id":"LES-0061-CMD-011","question":"Can drift remain silent?","risk":"read-only","command":"bash lab.sh evaluate reconciliation-missing","runFrom":"LES-0061 support/lab","expectedBranches":[{"when":"boundary=silent-drift","meaning":"no independent correctness comparison exists","nextEvidence":"define reconciliation and owner"}],"proves":"encoded detection gap","doesNotProve":"records agree"},{"id":"LES-0061-CMD-012","question":"Do cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0061 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"nineteen branches and cleanup pass","nextEvidence":"retain limitations"},{"when":"failure","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"offline teaching lifecycle","doesNotProve":"workflow database broker CDC effect replay capacity or production behavior","cleanup":"Verifier proves UID-scoped state absence."}],"labs":[{"id":"LES-0061-LAB-001","title":"Guided distributed-workflow boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python standard library","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one synthetic fixture"],"abortConditions":["root","credential","network endpoint","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure; change only copied fixture or candidate code.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0061-distributed-workflows-reliability/support/lab"},{"id":"LES-0061-LAB-002","title":"Independent saga, outbox, crash and reconciliation transfer","mode":"independent","environment":"Reviewer-owned disposable local services with synthetic business records","timeMinutes":240,"privilege":"normal user where possible; reviewer owns faults","network":"isolated local only","changes":["synthetic workflow and participant state","disposable outbox relay and effects","approved crash faults","reconciliation artifacts"],"abortConditions":["shared service","real credential","customer data","host network/clock mutation","unbounded retries","unknown cleanup"],"recovery":"Preserve histories and reset through the reviewer harness.","cleanupProof":"Reviewer proves processes, files, ports, volumes and synthetic data absent.","path":"drafts/LES-0061-distributed-workflows-reliability/support/lab"}],"incidents":[{"id":"LES-0061-INC-001","signal":"Orders are paid but remain in PROCESSING after worker restarts.","firstThought":"The effect may have succeeded before the workflow checkpoint became durable.","safePath":"Contain retries, bind operation/step/effect identities, query provider and history, record the known result, then reconcile users.","trap":"Mark every old workflow complete or retry every payment."},{"id":"LES-0061-INC-002","signal":"Database rows change but some downstream services never receive the event.","firstThought":"A non-atomic state-and-publish dual write lost one side.","safePath":"Preserve commit/outbox/broker evidence, repair missing events from authority, then implement atomic outbox and idempotent consumption.","trap":"Increase producer retries without fixing the gap."},{"id":"LES-0061-INC-003","signal":"A failed workflow issues two refunds during compensation retries.","firstThought":"Compensation is a repeated business effect without stable identity.","safePath":"Stop unsafe compensation, reconcile the ledger, reuse one compensation key, persist result and resume from durable state.","trap":"Assume compensation is database rollback."},{"id":"LES-0061-INC-004","signal":"A deployment causes thousands of old workflows to fail replay.","firstThought":"New workflow code changed decisions for existing event histories.","safePath":"Stop rollout, pin compatible workers/build IDs, preserve histories, version the decision path and test replay before migration.","trap":"Delete histories and restart workflows."},{"id":"LES-0061-INC-005","signal":"Outbox age and manual-review queue rise while aggregate CPU looks low.","firstThought":"Relay fencing, a hot participant, dependency limits or unowned terminal work blocks progress.","safePath":"Measure per-state arrival/service rates, oldest age, relay lease, dependency latency and owner capacity; restore the limiting path within retention.","trap":"Add generic workers or extend retention without a drain plan."}],"assessmentIds":["ASM-0166","ASM-0167","ASM-0168"],"referenceIds":["REF-0673","REF-0674","REF-0675","REF-0676","REF-0677","REF-0678","REF-0679","REF-0680","REF-0681","REF-0682","REF-0683","REF-0684","REF-0685","REF-0686","REF-0687"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["The offline model is not a workflow engine, database, broker, CDC relay, transaction coordinator, payment provider, benchmark or history checker.","Synthetic decisions do not prove Temporal, Step Functions, PostgreSQL, Debezium, broker, client, network or provider behavior.","No socket, workflow, transaction, event, effect, account, external resource, replay or load exists.","Semantics, defaults, limits and metrics are version-, provider-, SDK-, configuration- and topology-dependent.","Formal review, publication, representative runtime, transfer, delayed recall and learner evidence remain required."]}
---

# Distributed workflow reliability: make partial success recoverable

## What you see and first thought

The order service says the request succeeded. The payment provider shows a charge. Inventory is still reserved. The workflow dashboard says `RUNNING` for two hours. A worker restart makes the payment activity run again.

Do not begin with “restart the workflow” or “roll everything back.” Begin with this:

> A distributed workflow is a chain of separately durable facts. Find the last fact whose owner can prove it, then decide whether the next safe action is retry, compensate, continue, reconcile, or ask a human.

The word “transaction” can make this feel like one database operation. It is not. Once independent services commit separately, there is no magical global undo button. Some steps can be compensated, some can only be retried forward, and some are irreversible. A timeout tells you that the caller stopped waiting; it does not tell you whether the remote effect happened.

```text
client intent
    |
    v
durable workflow ---- state/version/history
    |
    +--> participant A local transaction
    |        +--> business state
    |        +--> outbox event
    |
    +--> relay/broker --> participant B idempotent effect
    |
    +--> checkpoint --> reconciliation --> user outcome
```

Whenever you see “stuck,” translate it into a state question:

1. Which business invariant is the workflow trying to preserve?
2. Which system owns the authoritative record for each step?
3. What stable identities bind the operation, step, event, effect and compensation?
4. What exactly committed before the failure or timeout?
5. Which actions are safe to repeat, and which require evidence or human approval?
6. What independent reconciliation proves the final user outcome?

This framing stays useful across home-grown state machines, Temporal, Step Functions, Airflow-style orchestration, Kubernetes controllers and message-driven choreography. Products differ. Partial failure does not.

## Terms before commands

### One business operation is not one database transaction

A **business operation** is the outcome the user asked for: place an order, provision an environment, transfer funds, publish a model or revoke access. It may span seconds, days and many authorities.

A **local transaction** is atomic work inside one transactional authority, usually one database. It either commits all included changes or none. If one database and one service can own the invariant, keep the work local. Splitting it into events and compensation creates failure states you did not need.

A **distributed transaction** coordinates commit across multiple transactional participants. **Two-phase commit (2PC)** first asks participants to prepare, then directs commit or rollback. It is real and supported by systems such as PostgreSQL under an external transaction manager. It is not automatically available across an HTTP API, a payment provider and a broker. Prepared work can hold resources, the coordinator is critical, participants can remain in doubt, and long business workflows are usually a poor fit.

A **workflow** is a durable state machine coordinating a business operation over time. **Durable** means its decisions and progress survive process failure; it does not mean every external effect is automatically exactly once.

A **saga** is a workflow made from local transactions. When a later step fails, business-specific compensating actions may repair earlier completed work. A saga trades global isolation for explicit recovery.

### Choreography and orchestration

In **choreography**, services react to events and publish new events. There is no single central workflow controller. This can be simple for a short, stable flow, but the real state machine becomes distributed across subscriptions. Cycles, hidden coupling and incident reconstruction grow quickly.

In **orchestration**, one durable authority stores workflow state and tells participants which command to perform. This makes state, deadlines, retries and compensation visible. The orchestrator must itself be durable, scalable and highly available; an in-memory coordinator is only a delayed outage.

Choose from ownership, not fashion:

| Question | Choreography tends to fit | Orchestration tends to fit |
|---|---|---|
| How many steps and branches? | few and stable | many, conditional or long-running |
| Who owns the end-to-end outcome? | genuinely distributed | one product capability/team |
| Is global progress easy to infer? | yes from a few events | no; explicit state is needed |
| Are deadlines and compensation complex? | minimal | central policy is valuable |
| Will the flow evolve independently? | participants accept event coupling | versioned workflow controls change |

### Forward actions, compensation and the pivot

A **compensable step** has a business action that can bring the system to another valid state. “Cancel reservation” is compensation for “reserve inventory.” It may charge a fee, preserve an audit record or fail temporarily. It is not deletion of history.

A **pivot** is the point of no return. Before it, the workflow can still choose compensation. After it, remaining steps must normally retry forward until the system reaches a valid terminal state. Sending a legally binding instruction or releasing physical goods may be a pivot.

A **retryable step** is safe to invoke again under the same stable identity. Safe does not mean “the API returned 200 twice.” It means repeated attempts produce one intended business effect or a known equivalent result.

Order the workflow deliberately:

```text
validate -> reserve (compensable) -> authorize (compensable)
         -> PIVOT: capture/commit -> notify (retryable)
                                -> complete
```

Run cheap, decisive validation before irreversible work. If the domain cannot compensate an effect, either move it after all critical checks, redesign the contract, or expose an owned manual outcome.

### Identity is the recovery handle

Use different names because they answer different questions:

- **operation ID**: one user intent across retries;
- **workflow ID**: the durable coordination instance;
- **run ID**: one execution generation when the engine creates generations;
- **step ID**: one logical workflow transition;
- **event ID**: one immutable published fact;
- **effect ID or idempotency key**: one external business effect;
- **compensation ID**: one logical reversal action.

An attempt number is not an identity. If attempt two generates a new payment key, retry safety is already lost. Derive stable keys from durable business identity, not wall-clock time or worker process identity.

### Checkpoint, history and reconciliation

A **checkpoint** is the durable statement that the workflow may advance beyond a step. If it is recorded before the external effect, a crash can lose work. If the effect happens first, a crash can repeat it. Stable effect identity, persisted results and reconciliation close that ambiguity.

**Workflow history** is the sequence of durable decisions and results used to reconstruct state. A replay-based engine may execute workflow code again against history. That code must be deterministic: the same recorded history must make the same decisions. Random numbers, current wall time, unordered iteration and direct network calls inside replay logic can break recovery unless the platform records or wraps them.

**Reconciliation** independently compares authorities. It asks whether source state, workflow history, outbox, participant records, external provider and user-visible result agree. Retrying moves work. Reconciliation proves correctness.

## Architecture map

### Start with the smallest valid transaction boundary

```text
Can one authority own the invariant?
          |
      yes |----------------> one local ACID transaction
          |
       no v
Are all participants transactional and is short 2PC acceptable?
          |
      yes |----------------> evaluate 2PC coordinator/lock/failure cost
          |
       no v
explicit durable workflow
   | choreography or orchestration
   | local transaction per participant
   | outbox/inbox identities
   | retry + compensation + manual terminal state
   + reconciliation
```

Microservices are not a reason to abandon atomicity inside a service. For example, creating an order row and an outbox row in the same relational database should normally be one local transaction. Do not publish first and hope the state commit succeeds. Do not commit state first and hope a later process publishes unless the authoritative log itself is the handoff.

### Ownership table

| Artifact | Durable owner | Safe to forget when | Minimum evidence |
|---|---|---|---|
| user intent | request boundary / operation store | terminal outcome is durable | operation ID, principal, request hash |
| workflow state | workflow store/engine | retention and audit policy permits | workflow ID, state, version, history |
| participant command | workflow/task queue | participant result is durable | step ID, attempt, deadline |
| local state change | participant database | domain retention permits | commit ID, entity version |
| outbox row | participant database | relay ack and recovery policy permit | event ID, log/relay position |
| external effect | external authority plus effect ledger | never merely because caller timed out | effect key, response, provider record |
| compensation | domain owner | compensated terminal state is reconciled | compensation ID, result, audit |
| manual case | named operational/business owner | disposition is approved and recorded | reason, age, owner, decision |

Every handoff needs an answer to “who may forget what now?” If both sides can forget, there is a loss window. If both sides can act under different identities, there is a duplicate window.

## Request or state path

### Happy path with a transactional outbox

Consider an order workflow:

1. The API accepts `operation_id=op-731` and creates workflow `wf-731` once.
2. The workflow records `VALIDATING` with state version 1.
3. Inventory receives step `wf-731/reserve/v1`.
4. Inventory begins one local transaction, conditionally reserves stock and inserts outbox event `evt-731-reserved`.
5. One commit makes both inventory state and the notification recoverable.
6. A polling relay or CDC connector observes the outbox record and publishes it. The relay can crash after publishing but before recording progress, so duplicate publication remains possible.
7. The orchestrator or next participant deduplicates by event/step identity.
8. Payment receives effect key `op-731/payment-capture`. Every retry uses the same key.
9. The workflow records the provider result before advancing.
10. Final reconciliation compares order, inventory, payment and workflow state before reporting completion.

```text
workflow         inventory DB        relay/broker       payment
   | command(step-1) |                    |                 |
   |---------------->| BEGIN              |                 |
   |                 | reserve row         |                 |
   |                 | insert outbox(evt)  |                 |
   |                 | COMMIT              |                 |
   |                 |-------------------->| publish(evt)    |
   |<--------------------- evt/dedupe ------|                 |
   | command(step-2, stable effect key) -------------------->|
   |<---------------- provider result -----------------------|
   | checkpoint result |                    |                 |
   | reconcile and complete                                  |
```

The outbox solves one problem precisely: state and the intent to publish are in one local commit. It does not promise one publish. It does not make the consumer effect idempotent. It does not decide retention, ordering, privacy or schema compatibility.

### Failure path is part of the design

Assume payment succeeded and the worker died before recording the result:

- The task becomes eligible again.
- A new worker must use the same effect key.
- The provider should return the previously committed result or reject a conflicting payload.
- If the provider has no idempotency feature, the participant needs its own effect ledger, a query/reconciliation API, or a manual boundary.
- Only after the effect is known does the workflow checkpoint the step.

A timeout alone creates an **ambiguous outcome**. The safe state is not `FAILED` and not `SUCCEEDED`. It is “unknown, reconcile before another non-idempotent attempt.”

## Failure zoom

### The state-and-publish gap

Without an outbox, application code often does this:

```text
UPDATE orders SET status='APPROVED';
COMMIT;
publish OrderApproved;
```

Crash after commit and before publish: the order changed, but no consumer learns about it. Reverse the lines and a publish can escape even when the database commit fails. Retrying does not remove the gap because the process cannot atomically know which side succeeded.

The transactional outbox changes the boundary:

```sql
BEGIN;
UPDATE orders
   SET status = 'APPROVED', version = version + 1
 WHERE order_id = :order_id
   AND version = :expected_version;
INSERT INTO outbox(event_id, aggregate_id, event_type, payload, created_at)
VALUES (:stable_event_id, :order_id, 'OrderApproved', :payload, CURRENT_TIMESTAMP);
COMMIT;
```

Both records commit or neither does. A relay later publishes the row. A CDC relay reads the database transaction log; a polling relay queries rows and claims batches. Both need operational ownership:

- a stable event ID and aggregate ordering key;
- a lease or fencing mechanism so a stale relay cannot claim current authority;
- retry with the same identity;
- oldest-row age and publish latency alarms;
- bounded retention that exceeds outage and rebuild time;
- schema version and privacy classification;
- safe cleanup only after the recovery contract permits forgetting.

“Delete after publish” is unsafe if publish acknowledgement is ambiguous. “Never delete” eventually becomes a storage incident. Treat outbox lifecycle as an evidence-retention design, not housekeeping.

### The effect-and-checkpoint gap

Suppose a worker calls an external payment API and then records step completion:

| Crash point | What may be true | Safe recovery |
|---|---|---|
| before request | no effect | retry same step identity |
| request in flight | effect unknown | query/reconcile by stable key |
| effect committed, response lost | effect happened | repeat same idempotency key or query |
| response received, checkpoint absent | effect happened, workflow unaware | persist/query result, then checkpoint |
| checkpoint committed | workflow may advance | do not repeat logical effect |

You cannot solve this with a local database transaction if the external provider does not participate in it. You solve it with stable identity, an effect-side uniqueness boundary, result persistence and reconciliation.

An inbox table is one common participant pattern:

```sql
BEGIN;
INSERT INTO inbox(step_id, received_at)
VALUES (:stable_step_id, CURRENT_TIMESTAMP)
ON CONFLICT (step_id) DO NOTHING;

-- Only the transaction that claimed the step applies local state.
UPDATE inventory
   SET reserved = reserved + :quantity
 WHERE sku = :sku
   AND available - reserved >= :quantity;

INSERT INTO outbox(...);
COMMIT;
```

This can make a local state change and its dedupe marker atomic. It still does not atomically include a remote payment or email provider.

### Compensation can fail

Imagine reserve inventory succeeded, payment authorization succeeded, and fraud validation later failed. The workflow requests release inventory and void authorization. Release succeeds. Void times out.

The original workflow is not simply “rolled back.” It is in a compensation state with one known completed compensation and one ambiguous compensation. Recovery requires:

1. durable compensation progress;
2. one stable compensation key per original effect;
3. a timeout and retry policy appropriate to the provider;
4. query/reconciliation for ambiguous results;
5. a terminal manual state if automation cannot decide;
6. user and financial correction after the true state is known.

Compensation order is a business rule. Reverse order is a useful default, not a law. A sensitive resource may need release first. Independent compensations may run in parallel. Concurrent user actions may mean “restore the old row” would overwrite valid newer work. Compensation should create a new valid state with an auditable reason.

### Concurrent sagas have no automatic isolation

Two workflows can both read “10 units available,” each reserve 7, and violate the invariant unless the inventory authority uses a conditional local transaction. Saga coordination does not replace participant concurrency control.

Useful controls include:

- **entity version check**: update only if the expected revision still matches;
- **semantic lock**: mark an entity as undergoing a named business operation;
- **commutative operation**: represent deltas that are safe in either order;
- **escrow/allocation**: pre-partition a limited resource;
- **pessimistic local lock**: short lock inside one participant transaction;
- **risk-based serialization**: serialize only high-value conflicting cases.

Do not hold a database lock across a minutes-long workflow. Store durable business state that other operations can interpret.

### Replay and versioning failure

Durable execution may reconstruct a workflow by replaying recorded history through code. If version 2 inserts a new branch before a decision that old history already recorded, replay can disagree. The symptom appears during deployment, failover or a rare old execution—not necessarily in a new happy-path test.

Keep these separately versioned:

- workflow decision logic;
- activity/participant input and output schemas;
- event envelope and payload schema;
- retry and timeout policy;
- compensation behavior;
- authorization policy reference;
- external provider contract.

Use platform-supported build routing or version markers. Test old production-like histories against new code before rollout. Retain compatible workers until every old execution is migrated or complete. Never make workflow code fetch current time, random values or remote state during deterministic replay unless the platform records that result as history.

### Retry amplification

One failing dependency can be retried by the HTTP client, participant, task queue, workflow engine and user. If each layer makes three attempts, one user action can create up to `3 x 3 x 3 x 3 = 81` calls before concurrency is considered.

Define one retry budget across the path:

- classify errors as transient, permanent, conflict, ambiguous or policy-denied;
- use a deadline that includes queue time and downstream work;
- back off with jitter for shared transient failure;
- cap attempts or elapsed time;
- do not retry validation or authorization denial as if transient;
- move exhausted work to an owned terminal state;
- rate-limit recovery so it cannot starve new work.

The workflow should know why it is waiting. `WAITING_FOR_RETRY`, `WAITING_FOR_USER`, `COMPENSATING` and `MANUAL_REVIEW` are more operable than `RUNNING`.

## Internals and state ownership

### Durable workflow state machine

A useful state record contains more than a status string:

```json
{
  "workflowId": "wf-731",
  "operationId": "op-731",
  "workflowType": "PlaceOrder",
  "definitionVersion": 4,
  "state": "PAYMENT_UNKNOWN",
  "stateVersion": 8,
  "currentStepId": "wf-731/payment-capture/v1",
  "attempt": 2,
  "deadline": "2026-08-05T12:30:00Z",
  "lastKnownResult": "request_sent_response_missing",
  "nextAction": "reconcile_payment",
  "owner": "payments-oncall",
  "updatedAt": "2026-08-05T12:22:11Z"
}
```

State version prevents two workers from advancing the same execution concurrently. A compare-and-set transition can reject a stale worker:

```sql
UPDATE workflow
   SET state = :next_state,
       state_version = state_version + 1,
       updated_at = CURRENT_TIMESTAMP
 WHERE workflow_id = :workflow_id
   AND state = :expected_state
   AND state_version = :expected_version;
```

Zero rows updated is evidence of lost ownership or a competing transition. It is not permission to overwrite.

### Choreography still has a state machine

In choreography, the state machine is encoded in:

- event types and schemas;
- which service subscribes to which event;
- local dedupe and state transitions;
- correlation and causation IDs;
- timeouts for events that never arrive;
- compensating events;
- replay order and retention.

Draw that state machine explicitly. If no team can answer “what terminal states exist?” the architecture has hidden ownership. A central read model for visibility is not necessarily an orchestrator, but it must not be mistaken for the authority that commands recovery.

### 2PC without slogans

Two-phase commit can be correct when:

- every required participant supports the protocol;
- transactions are short;
- lock/resource duration is bounded;
- the coordinator log is durable and highly available;
- recovery of prepared/in-doubt transactions is owned;
- availability trade-offs match the invariant.

It is usually a poor match for:

- human approval over hours;
- services with only HTTP business APIs;
- external SaaS effects;
- disconnected participants;
- operations needing business compensation rather than database rollback.

The senior answer is neither “always use sagas” nor “2PC is impossible.” It is: choose the smallest mechanism whose participants, blocking behavior and recovery contract actually cover the invariant.

### Relay designs

A **polling publisher** queries outbox rows, claims a bounded batch, publishes and records progress. It is simple but creates polling load and needs a lease/fencing design. Use short claims, monotonic epochs or database-supported skip-locked patterns carefully; measure stale claims and oldest age.

A **CDC relay** reads committed database-log changes and routes outbox inserts. It avoids application polling and preserves transaction-log order within documented scopes. It introduces connector state, log retention, privileges, schema-change handling and another recovery position. If the connector is down long enough for the source log to disappear, the outbox table alone may or may not be sufficient depending on configuration and cleanup.

Neither design removes duplicates around publish acknowledgement. Consumers remain idempotent.

### Schema and data lifecycle

An event persists longer than the producing code. Schema compatibility therefore belongs to recovery:

- preserve the event envelope’s stable `id`, `source`, `type`, subject and schema reference;
- add optional fields with documented defaults;
- do not reuse removed Protobuf field numbers; reserve them;
- retain Avro writer schemas so old payloads can be resolved by newer readers;
- test old writer/new reader and new writer/old reader combinations required by rollout;
- separate personally sensitive fields from routing metadata;
- delete or redact only under a policy that still allows required audit and replay;
- keep workflow history and outbox retention at least as long as maximum recovery, rollback, delayed effect and investigation horizons.

Retention is not “30 days because storage is cheap.” It is a bound across technical recovery, business dispute, legal/audit, privacy minimization and cost.

### Security at the effect boundary

A workflow may wait for days. The user who was authorized at creation may be disabled before the irreversible step. Decide which policy applies:

- **authorize once** when the approved intent itself is the durable authority;
- **authorize again** when current privilege is required at execution;
- **dual control** for high-risk transitions;
- **service delegation** constrained to workflow type, tenant, resource and operation.

Record the principal, tenant, policy/rule version, decision time and scope without storing secrets. Re-evaluate at the durable effect boundary where required. Encrypt histories and payloads, restrict operator mutation, sign or audit manual actions, and never place reusable credentials in workflow history.

## Evidence table

| Question | Evidence to bind | What it proves | What it does not prove |
|---|---|---|---|
| Did one user intent create one workflow? | operation ID, request hash, workflow uniqueness result | request dedupe at entry | downstream effect count |
| Which definition controls this execution? | workflow type, build/definition version, history | selected decision logic | external API behavior |
| Did participant state commit? | database commit/row version | local durable state | event publication |
| Did notification become recoverable? | outbox event ID in same transaction | durable publish intent | broker acceptance |
| Did relay progress? | log/row position, lease epoch, publish ack | sampled handoff | consumer effect |
| Did a participant repeat work? | step ID, attempts, inbox/dedupe rows | delivery/retry history | remote effect count |
| Did external effect happen? | stable effect key, provider response/ledger | provider-side outcome | user reconciliation |
| Did workflow checkpoint after effect? | history event and timestamps | recorded progression | correctness of effect |
| Did compensation happen once? | compensation key, domain ledger, result | sampled recovery effect | every dependent state |
| Can old execution replay? | history replay test against candidate build | tested compatibility | every unseen history |
| Are concurrent operations isolated? | entity versions, conflicts, semantic locks | ownership conflicts | business correctness alone |
| Can recovery finish in time? | per-state arrival/service, oldest age, dependency ceiling | drain envelope | semantic correctness |
| Are manual cases owned? | queue age, assignee, SLA, audit decision | operational ownership | correctness of decision |
| Do authorities agree? | reconciliation report across source/workflow/effects/user | compared invariants | future stability |

Build a timeline in monotonic or server-recorded order where possible. Wall clocks across services may skew. Use IDs and causal links to connect traces; do not force one synchronous parent span across days. Messaging and workflow spans often need links that preserve causation across retries and fan-out.

## Command decoders

### The offline model is a reasoning instrument

The lab model evaluates declared architecture facts in a fixed order. It deliberately does not emulate a workflow product. This is useful because you can learn to name the failed boundary without installing a database, broker or cloud service.

Start from the lesson lab directory:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
bash lab.sh evaluate baseline
```

Read `boundary=operable` as “all encoded statements in this synthetic case are true.” Do not read it as “the design is production ready.”

Use paired cases to train diagnosis:

```bash
bash lab.sh evaluate single-store-overcomplicated
bash lab.sh evaluate state-outbox-split
bash lab.sh evaluate compensation-not-idempotent
bash lab.sh evaluate replay-nondeterministic
bash lab.sh evaluate authorization-stale
bash lab.sh evaluate reconciliation-missing
```

Each result points to the first unsafe ownership boundary. `state-publish-gap` means the case says the business state and publish intent are not atomic. It does not inspect a real transaction log.

Inspect the case before changing it:

```bash
bash lab.sh show state-outbox-split
```

The fields are assertions to challenge in an architecture review. For example, `relayFenced=true` should lead to real evidence about lease ownership and stale-writer rejection—not a box checked because only one replica is currently running.

Run the verifier only from absent lab state:

```bash
bash verify.sh
```

It proves all 19 expected decisions, an unexpected-artifact refusal and exact UID-scoped cleanup. It creates no network endpoint or external resource.

### Production commands are product-specific

In a real incident, use the supported read-only tooling for the actual platform to collect:

- workflow description, history and current task;
- worker/build routing and task-queue backlog;
- database transaction/outbox/inbox rows;
- connector/relay positions and leases;
- broker event positions;
- provider effect lookup by idempotency key;
- reconciliation report.

Write a command contract before running any mutation:

```text
question:
exact scope:
read-only command/API:
possible output branches:
what each branch proves:
what it cannot prove:
next safe evidence:
mutation/rollback if later approved:
```

“Retry workflow” is not a diagnostic command. It is a state mutation that may repeat effects. “Terminate,” “reset,” “redrive,” “delete outbox,” “skip event” and “force complete” need explicit blast radius, identity scope, precondition, audit and reconciliation.

## Decision path

### Design path

Use this path before selecting a product:

1. **Name the invariant and authority.** What must never be simultaneously true? Which service can enforce it locally?
2. **Minimize the transaction scope.** If one database can own the invariant, use one local transaction.
3. **List independent durable effects.** A database, broker, payment provider, email service and human approval are separate authorities.
4. **Evaluate coordination choices.** 2PC only if every participant and failure objective support it; otherwise make the long-running state explicit.
5. **Choose workflow ownership.** Use orchestration when end-to-end state, branches, deadlines and compensation need one authority. Use choreography only when distributed ownership remains understandable and operable.
6. **Classify every step.** Mark it compensable, pivot/irreversible, or retryable. Move validations before the pivot.
7. **Assign stable identities.** Operation, workflow, step, event, effect and compensation IDs must survive attempts.
8. **Close local gaps.** Commit participant state with outbox/inbox records where supported.
9. **Design ambiguous outcomes.** For every external effect, define query, dedupe or manual reconciliation.
10. **Define terminal states.** Completed, compensated, rejected, expired and manual-review are explicit; “running forever” is not.
11. **Version and retain recovery evidence.** Old histories, schemas and compatible workers must survive the longest execution.
12. **Prove by fault injection and reconciliation.** Crash at each ownership boundary and compare user-visible outcomes.

### Incident path

When a workflow is stuck or inconsistent:

```text
user harm continuing?
  | yes -> contain unsafe new effects; preserve evidence
  v
bind operation/workflow/step/event/effect/compensation IDs
  |
  v
last independently proven durable fact?
  |
  +-- before effect --------> retry same identity if policy permits
  +-- effect unknown -------> query/reconcile; do not invent a new key
  +-- effect known ---------> persist/checkpoint or compensate by policy
  +-- compensation unknown -> query/reconcile compensation
  +-- history incompatible -> route compatible build; stop rollout
  +-- no automated decision -> owned manual terminal state
  |
  v
reconcile every authority and the user outcome
```

Containment depends on the incident:

- pause only the unsafe workflow type, tenant, entity or effect if possible;
- stop deployment/replay churn that changes ownership;
- preserve histories, outbox/inbox records and provider evidence;
- keep new requests from entering an already saturated irreversible step;
- do not delete or edit durable history to make a dashboard green;
- communicate user-visible ambiguity honestly.

### Capacity path

Workflow queues are queues. If arrival rate is `lambda` and sustainable completion is `mu`, backlog drains only when `mu > lambda`. For a backlog `B`, ideal drain time is:

```text
drain_seconds = B / (mu - lambda)
```

But calculate at the limiting state or dependency, not only aggregate workers. A payment activity may be rate-limited to 100/s even when worker CPU can schedule 1,000/s. Compensation and reconciliation also consume capacity.

Example:

- 40 new workflows/s;
- a 20-minute outage creates `40 x 1,200 = 48,000` waiting steps;
- workers complete 70/s after recovery;
- ideal spare is 30/s;
- ideal drain is `48,000 / 30 = 1,600 seconds`, about 26.7 minutes.

If the provider allows only 45/s, real spare is 5/s and drain is 160 minutes before retry overhead. If the oldest outbox evidence expires in 90 minutes, the system has no valid recovery envelope. Options are reduce/admit new demand, increase the true bottleneck safely, extend evidence retention with capacity approval, or invoke a different recovery source. Adding generic workers does not change a provider quota.

## Guided Ubuntu lab

### Safety contract

This lab is intentionally small. It teaches decision boundaries without pretending to be a distributed system.

- Ubuntu 24.04 normal user only; root is refused.
- Python standard library only.
- no network, broker, database, workflow engine or credentials;
- one exact `/tmp/reliability-atlas-les0061-distributed-workflows-<uid>` directory;
- symlinks, wrong ownership and unknown artifacts are refused;
- cleanup removes only the exact expected files and proves the directory absent.

Do not copy the cleanup logic into a broader path. Do not bypass a failed guard.

### Walkthrough

From `drafts/LES-0061-distributed-workflows-reliability/support/lab`:

```bash
bash lab.sh doctor
```

Expected branch:

```text
doctor=pass runtime=offline-distributed-workflow-model
```

If it reports `reason=root`, exit the root shell. If it reports `reason=credential`, use a clean lab shell; do not print secret values. OS/version failure means the required environment is not proved.

Initialize:

```bash
bash lab.sh setup
bash lab.sh status
```

Expected status includes `cases=19 network=none`. Setup refuses pre-existing state rather than overwriting it.

Evaluate the baseline and four crash-boundary cases:

```bash
bash lab.sh evaluate baseline
bash lab.sh evaluate state-outbox-split
bash lab.sh evaluate checkpoint-before-effect
bash lab.sh evaluate compensation-not-idempotent
bash lab.sh evaluate history-unversioned
```

Translate each result into a production question:

| Model boundary | Production question |
|---|---|
| `state-publish-gap` | Can state commit while notification is forgotten? |
| `effect-loss` | Can progress advance before recoverable effect completion? |
| `duplicate-compensation` | Does retry use one compensation identity? |
| `history-version` | Can current and rollback builds replay old histories? |

Inspect a fixture:

```bash
bash lab.sh show authorization-stale
```

The false field is `authorizationAtEffect`. In a design review, evidence might be a policy decision record attached to the step and an effect-side check. The fixture itself proves none of that.

Run full verification from clean state:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected:

```text
verify=pass cases=19 refusal=true cleanup=true
```

If verification fails, preserve the first output. Do not delete arbitrary `/tmp` content. The verifier’s cleanup trap is scoped to its exact directory and sentinel.

### Why the lab has no workflow product

A single-laptop product demo can teach commands while hiding the architecture. It may show a retry “working” without proving stable effect identity, state/publish atomicity, version compatibility or reconciliation. The model makes those assumptions visible first. A later reviewer-owned transfer lab must use real disposable components and inject failures.

## Production transfer

### Reviewer-owned fault matrix

The representative lab should use synthetic records and disposable local services. The reviewer chooses products and hides at least one unfamiliar configuration. The learner must not receive a model answer.

Faults to inject:

| Fault | Required evidence | Correctness condition |
|---|---|---|
| crash before participant commit | transaction and history | no state or outbox event |
| crash after state/outbox commit | rows and relay position | event eventually published |
| relay crash after publish ack | event IDs and consumer inbox | duplicate publish causes one effect |
| worker crash after external effect | provider key and history | same effect discovered, not repeated |
| compensation response lost | compensation key and provider record | one compensating effect |
| stale worker resumes | state version/fence rejection | stale transition cannot commit |
| incompatible workflow deploy | old-history replay test | rollout stops or routes compatible build |
| outbox/worker backlog | per-state rates and oldest age | recovery meets retention and SLO |
| authorization revoked mid-workflow | decision records | policy is enforced at chosen boundary |
| reconciliation mismatch | cross-authority report | drift is owned and repaired |

The learner must predict the result before each fault, run it, compare evidence, and explain any difference. Passing a happy path is not mastery.

### Production incident example: paid but stuck

Signal: 84 orders are `PAYMENT_PENDING` for more than 30 minutes. The provider ledger contains charges for 62. Application retries are increasing.

Contain:

1. stop new attempts for only the affected payment step or tenant if scoped controls exist;
2. preserve workflow histories, task attempts, payment keys and provider responses;
3. stop deployment or worker churn;
4. prevent new keys from being generated;
5. notify incident and business owners of the ambiguous set.

Diagnose:

- Partition the 84 by stable effect key: known charged, known not charged, unknown.
- Verify whether every attempt reused the same key and payload hash.
- Compare provider timestamps with workflow task and checkpoint history.
- Check whether the result store committed before worker loss.
- Identify whether the provider lookup is authoritative or eventually consistent.

Recover:

- For known charged, persist/reference the known provider result and advance exactly the matching workflow version.
- For known not charged, retry under the original key within deadline and policy.
- For unknown, wait/query/escalate; do not issue a fresh key.
- Reconcile inventory reservations, payment ledger, order state and user notifications.
- If cancellation is required, issue one stable compensation key and track its own state.

Validate:

- one intended charge or one approved compensation per operation;
- no order completed without required inventory;
- no stale worker committed after containment;
- backlog and oldest age decrease at measured sustainable rate;
- all 84 user outcomes have an auditable disposition.

### Production incident example: outbox backlog

Outbox rows grow from 10,000 to 900,000 while connector CPU is low. Do not assume CPU capacity. Check:

- oldest row and source commit rate;
- transaction-log retention and connector source position;
- relay lease/epoch and repeated fencing failures;
- broker publish latency, quota and authentication;
- poison schema transformation and retries;
- table/index scan cost, vacuum/compaction and storage;
- hot aggregate key or destination partition;
- cleanup deleting rows before replay safety.

Recover the limiting boundary. If the connector lost required log history, decide whether intact outbox rows can be republished under stable event IDs or whether an authority-derived repair is required. Reconciliation determines what downstream effects are missing; row count alone does not.

### ADR: choreography or orchestration

Record:

```text
decision:
business invariant and authorities:
workflow duration and branch count:
chosen coordination model:
durable state owner:
identity and ordering:
local transaction/outbox/inbox:
compensable/pivot/retryable classification:
timeouts/retries/manual states:
versioning and retention:
security and audit:
observability and reconciliation:
capacity/cost:
rejected alternatives:
rollback/migration:
validation evidence:
```

Rejected alternatives matter. “We chose orchestration because Step Functions exists” is not an ADR. Explain why local ACID, 2PC and choreography did or did not cover the invariant and failure objective.

## Reliability, security, observability, capacity, and cost

### Reliability

Reliability is a recoverable ownership chain:

```text
intent -> workflow state -> participant commit -> publish intent
       -> relay -> effect -> checkpoint -> terminal state
       -> reconciliation -> user outcome
```

Set objectives on user outcomes and stuck age, not merely workflow-engine uptime. Useful SLIs include:

- successful terminal operations / eligible operations;
- operations in ambiguous or manual state beyond objective;
- duplicate or missing business effects found by reconciliation;
- p95/p99 end-to-end completion time by workflow type;
- compensation success and age;
- oldest outbox/task/manual-case age;
- recovery time after worker, relay and dependency failure;
- replay compatibility pass rate for retained histories.

Availability and correctness can trade off. Refusing a second unknown payment attempt may reduce immediate completion but protect financial correctness.

### Security

Use least-privilege identities per workflow participant and operation. Scope task-queue, database, broker and provider permissions by tenant/resource where supported. Separate operators who can view history from those who can mutate or force transitions. Require audit and often approval for manual compensation, force completion or replay.

Do not store passwords, bearer tokens or private keys in history, event payloads or logs. Histories live longer than worker memory and may be replicated or exported. Store a secret reference and retrieve short-lived credentials at execution time.

Protect against confused-deputy behavior: the orchestrator must not turn an untrusted event into an effect outside the original authorized tenant and resource. Bind principal, tenant, operation ID, payload hash and policy decision to the step. Validate event source and schema, but remember a valid signature does not make the requested business action authorized.

### Observability

Metrics answer “how much”; logs answer “what happened”; traces answer “which causal path”; reconciliation answers “is it correct.”

Minimum correlated fields:

```text
operation_id workflow_id run_id workflow_type definition_version
state state_version step_id attempt event_id effect_id compensation_id
entity_id tenant_id deadline result_class next_action owner
```

Avoid putting raw sensitive payloads in labels or high-cardinality metric dimensions. Use metrics aggregated by workflow/state/error class, logs or exemplars for individual IDs, and traces with links across asynchronous delivery. Preserve audit evidence for manual changes separately from ordinary debug logs.

Alert on symptoms that require action:

- oldest active workflow by state exceeds objective;
- outbox/task arrival exceeds sustainable completion;
- compensation or manual queue has no owner;
- reconciliation mismatch rate rises;
- replay nondeterminism occurs;
- stale-worker transition rejection spikes;
- deadline exhaustion or provider ambiguity rises.

“Workflow failed count > 0” usually produces noise without business value, age, retry class or owner.

### Capacity

Model each stage:

| Stage | Capacity limiter |
|---|---|
| workflow decisions | history store, task queue, worker poll/execution |
| local transaction | locks, connections, log I/O, indexes |
| outbox relay | source scan/log, transformation, broker quota |
| participant | concurrency, dependency quota, entity hotspot |
| external effect | provider rate, latency, idempotency lookup |
| compensation | same resources during an incident |
| reconciliation | source scans, provider API and comparison storage |
| manual review | trained people, business hours and case complexity |

Reserve headroom for outage recovery, compensation and replay. If normal traffic consumes 95% of a provider quota, failover does not create recovery capacity. Admission control may be safer than accepting work that will expire before execution.

### Cost

Durability has a bill:

- workflow history and state storage;
- database write amplification for inbox/outbox/audit;
- broker and CDC infrastructure;
- duplicate attempts and provider calls;
- retained schemas, compatible workers and replay environments;
- traces/logs with high-cardinality correlations;
- reconciliation compute and human review;
- multi-region coordinator and data-transfer cost.

Optimize after preserving correctness. History compaction, archival, sampling and shorter retention must respect active-workflow, dispute, rollback and recovery horizons. A cheap system that forgets whether money moved is expensive during an incident.

## Traps and prevention

### Trap: make every operation a saga

**Why it fails:** one local invariant becomes eventual, observable and compensatable without need.

**Prevention:** begin every design with “can one authority and one local transaction own this?”

### Trap: call compensation rollback

**Why it fails:** other actors may have observed or changed state; the original effect may be irreversible; the recovery action can fail.

**Prevention:** model compensation as a new idempotent business command with identity, state, audit, retry and manual terminal handling.

### Trap: outbox means exactly once

**Why it fails:** relay publish can be ambiguous and duplicate. Consumer effects remain outside the producer transaction.

**Prevention:** atomic state/outbox commit plus stable event identity, fenced relay, idempotent inbox/effect and reconciliation.

### Trap: generate a new key on retry

**Why it fails:** the target sees a new logical effect.

**Prevention:** derive the key from durable operation and effect identity; attempts are metadata.

### Trap: checkpoint before the effect

**Why it fails:** a crash after checkpoint can lose the business action.

**Prevention:** record progress after recoverable effect completion or use a platform-supported atomic boundary that truly includes the entire effect.

### Trap: retry every error

**Why it fails:** permanent validation, conflict or authorization errors amplify load and never become success.

**Prevention:** classify failures, share a deadline/budget, back off, and enter explicit terminal/manual states.

### Trap: mutate history to repair the dashboard

**Why it fails:** evidence is destroyed and replay assumptions become false.

**Prevention:** preserve history; use supported versioning, reset or repair procedures with scoped preconditions, audit, rollback and reconciliation.

### Trap: current authorization lasts forever

**Why it fails:** long-running work may execute after access or policy changes.

**Prevention:** explicitly choose authorization-at-intent or authorization-at-effect, record the policy version and apply dual control where required.

### Trap: aggregate worker CPU proves capacity

**Why it fails:** one dependency quota, hot entity, relay lease or manual queue can be the true bottleneck.

**Prevention:** measure arrival, completion, oldest age and saturation at every state and authority.

### Trap: successful workflow means correct user outcome

**Why it fails:** a workflow can record completion while a provider, projection or notification disagrees.

**Prevention:** reconcile independent authorities and measure the user invariant.

## Memory card and retrieval

### The sentence to keep

> In a distributed workflow, partial success is normal. Make every durable fact identifiable, every repeat safe or reconcilable, every irreversible step deliberate, and every terminal state owned.

### Six identities

```text
operation -> workflow -> step -> event -> effect -> compensation
```

Attempts reuse these identities; they do not replace them.

### Three step classes

```text
compensable -> pivot/point of no return -> retryable forward
```

Validate before the pivot. Compensation is another fallible effect.

### Two crash gaps

```text
business state <-> publish intent     close locally with outbox
external effect <-> workflow record  close with stable key + result + reconciliation
```

### One operational rule

Oldest age beats raw count. A backlog of one irreversible ambiguous payment may deserve more attention than 10,000 safe notification retries.

### Retrieval prompts

Without looking back, explain:

1. Why is an outbox still at-least-once at the relay boundary?
2. Why can compensation not restore the exact prior world?
3. What makes a workflow replay nondeterministic?
4. When is local ACID better than a saga?
5. What should happen after an external-effect timeout?
6. Which rate determines recovery: worker capacity or the slowest required authority?

Return after one day and one week. Draw the ownership path and answer again from memory. Reading completion is not demonstration evidence.

## Complete answers

### 1. Why is an outbox still at-least-once?

The application commits domain state and an outbox row atomically. The relay reads that durable row and publishes it. Consider the relay crash window:

1. broker accepts event `evt-731`;
2. broker acknowledgement reaches the relay;
3. relay crashes before its source position or “published” marker becomes durable;
4. replacement relay reads `evt-731` again;
5. broker may accept the same logical event again.

The relay cannot atomically include an arbitrary broker acknowledgement in the original database transaction unless both participate in a shared protocol. Therefore the outbox prevents missing publish intent, but duplicate delivery remains. Stable event identity and idempotent consumers contain it. CDC changes how committed rows are observed; it does not erase the acknowledgement crash window.

### 2. Why is compensation not rollback?

Database rollback makes uncommitted local changes invisible. Compensation occurs after local commits became durable and may have been observed. A reservation cancellation is a new business fact. It may:

- apply a fee;
- be prohibited after shipment;
- race with a user modification;
- notify other systems;
- fail or time out;
- require approval;
- produce a valid state different from the original state.

Therefore compensation needs its own identity, authorization, retry classification, durable progress, audit and reconciliation. “Set the row back to the old value” can overwrite valid concurrent changes.

### 3. What should happen after a timeout?

Classify what timed out. A caller deadline expiring means only that the caller lacks a timely response. If the request could have reached the effect owner, the outcome is ambiguous.

Safe sequence:

1. preserve the stable effect key and request hash;
2. query the effect owner by that key if supported;
3. inspect local request/result records;
4. wait for bounded eventual-consistency delay if documented;
5. repeat only under the same idempotency key when the contract makes that safe;
6. otherwise enter an owned reconciliation/manual state;
7. checkpoint only after the result is known;
8. reconcile the user outcome.

Generating a fresh key converts uncertainty into possible duplication.

### 4. When should one local transaction remain local?

When one authoritative service and transactional store can enforce the invariant without an external effect inside the atomic boundary. Examples:

- order row and order-line rows in one database;
- inventory decrement plus local reservation ledger;
- domain row plus outbox row;
- workflow state transition plus local audit row.

Do not split these merely to imitate microservices. Local ACID provides atomicity and isolation that a saga deliberately gives up. Split when independent ownership, scale, lifecycle or technology boundaries are real and worth the added recovery states.

### 5. When could 2PC be appropriate?

When every participant supports prepare/commit, the transaction is short, the coordinator is durable, prepared-state resource holding is acceptable, and the availability/failure objective allows coordination. The team must monitor and recover prepared or in-doubt transactions.

It does not cover a normal email API, human approval or payment provider that has no 2PC participant. A long-running business process holding prepared database work would create contention and operational risk. Use a durable workflow and business recovery for those boundaries.

### 6. How do choreography and orchestration fail differently?

Choreography distributes decisions. It can fail through hidden cycles, event-contract drift, missing timeout ownership and difficulty reconstructing global progress. A participant can be healthy locally while the business flow has no owner.

Orchestration centralizes decisions. It can fail if coordinator state is volatile, worker routing is incompatible, the task queue is saturated, or the orchestrator becomes an organizational bottleneck. A durable managed engine can remove a single-machine failure but does not make participant effects exactly once.

The choice changes where coordination lives; it does not remove partial failure.

### 7. How do you make an external effect idempotent?

Best case: the effect owner enforces uniqueness for a stable key and returns the original result for equivalent retries. Bind the key to an immutable payload hash so the same key cannot silently mean two requests.

If the provider lacks that feature:

- maintain a local effect ledger with a uniqueness constraint before sending;
- use provider lookup/reference data to reconcile;
- serialize attempts for one effect;
- store request and result state;
- model `UNKNOWN` explicitly;
- require manual decision where a repeat cannot be made safe.

A local “sent=true” flag is insufficient if the process can crash between remote success and updating the flag.

### 8. Why checkpoint after an effect if that can duplicate?

Checkpoint-before-effect creates a loss window: workflow advances, process dies, and no recovery knows the effect is missing. Effect-before-checkpoint creates a duplicate-attempt window, which stable idempotency can contain. Prefer the recoverable ambiguity.

Where a platform supports a real atomic boundary containing both effect and checkpoint—such as local state plus inbox record—use it. Do not claim that boundary includes unrelated external systems.

### 9. How do you handle concurrent workflows?

Enforce the invariant at the participant authority. Use entity version checks, conditional updates, short local locks, semantic locks, escrow or commutative operations. The workflow may retry a conflict from fresh state or route it for review.

Example:

```sql
UPDATE inventory
   SET reserved = reserved + :qty,
       version = version + 1
 WHERE sku = :sku
   AND version = :expected_version
   AND available - reserved >= :qty;
```

Zero affected rows means the precondition failed. It is not a transient database error to retry blindly with stale values.

### 10. How do you deploy workflow-code changes safely?

Inventory active histories and their definition/build versions. Replay representative old histories against the candidate build in CI or a safe validation environment. Use platform-supported version markers or build routing. Keep compatible workers until old workflows complete or are deliberately migrated. Roll out gradually while monitoring nondeterminism, task failures and stuck age.

Rollback must also replay histories created by the new build. A deployment is not rollback-safe merely because the binary starts.

### 11. What should reconciliation compare?

Start from the business invariant, then compare:

```text
accepted operation
  = one workflow
  = expected participant commits
  = expected external effects minus approved compensations
  = terminal workflow outcome
  = user-visible state
```

Use stable IDs, amounts, entity versions and status. Classify mismatches: missing effect, duplicate effect, stale workflow, orphan outbox, missing event, compensation mismatch, notification-only gap. Give each class an owner, age objective, safe repair and audit trail.

### 12. How do you prove capacity?

Measure arrival and sustainable completion at every stage under representative dependency limits. Include retry and compensation traffic. Calculate backlog and drain using spare capacity at the bottleneck. Compare drain plus investigation and rollback time with deadlines, outbox/log/history retention and user objective. Fault-test failure and recovery; a steady-state load test alone does not prove drain.

## Product-company interview

### Question: “Design reliable order placement across inventory, payment and shipping.”

A strong answer starts with invariants:

- do not capture payment without an accepted order;
- do not oversell inventory;
- ship only after the point-of-no-return policy;
- every operation has one auditable terminal outcome.

Then:

1. Keep each participant’s local state and outbox atomic.
2. Use a durable orchestrated workflow because the flow has branches, deadlines, compensation and one business owner.
3. Use operation/workflow/step/event/effect/compensation identities.
4. Reserve inventory and authorize payment as compensable steps.
5. Run fraud/address validation before capture/shipping pivot.
6. Make post-pivot shipping/notification retryable or explicitly manual.
7. Make provider calls idempotent and reconcile ambiguous outcomes.
8. Use participant entity versions for concurrent orders.
9. Version history and event schemas.
10. Monitor user outcome, oldest state, outbox age, compensation and reconciliation mismatches.

Mention alternatives: local ACID cannot include independent providers; 2PC is unavailable across typical SaaS APIs; choreography may fit a simpler flow but hides complex recovery ownership here.

### Question: “Does a transactional outbox guarantee exactly once?”

No. It atomically binds local state and publish intent. A relay can publish and crash before recording progress, so duplicates are possible. Use a stable event ID, relay fencing, idempotent consumer/effect and reconciliation. State the exact boundary rather than using “exactly once” without a noun.

### Question: “Why not just retry until success?”

Some failures are permanent, policy-denied, conflicting or ambiguous. Layered retries amplify load. Irreversible effects may already have happened. Use a total deadline, classified errors, bounded attempts, backoff, stable identity and terminal/manual states. Retry is one recovery action, not a correctness strategy.

### Question: “What is the hardest saga problem?”

Not drawing the happy path. The hard problems are missing isolation, ambiguous external effects, compensation that can fail, versioning long-lived executions, retained evidence and proving final business correctness. A senior design makes these explicit and assigns ownership.

### Question: “How would you debug a stuck workflow?”

Contain unsafe effects; bind the operation, workflow, step, event and effect IDs; find the last durable fact from workflow history, participant database, outbox/relay and provider; classify result as not-started, known-success, known-failure or ambiguous; recover using the same identity; and reconcile all authorities and user outcome. Do not force-complete from dashboard status alone.

### Question: “How do you avoid an orchestrator single point of failure?”

Persist workflow state/history durably, run stateless workers with leases or task ownership, replicate the coordination service according to its failure model, test failover, and measure task age. A managed durable engine may provide this infrastructure. Participant idempotency remains necessary because failover can redeliver work.

### Question: “How do you estimate recovery after a dependency outage?”

Backlog equals arrival rate times outage duration, adjusted for admission and retries. Drain time equals backlog divided by sustainable service minus continuing arrival. Use the slowest required state/dependency, not aggregate worker CPU. Include replay/compensation traffic and compare with deadline and evidence retention.

### What interviewers listen for

Weak answers list products. Strong answers name:

- invariant and authority;
- transaction boundary and rejected alternatives;
- identities and crash windows;
- compensation/pivot/retryable classification;
- concurrency control;
- deadlines and manual state;
- versioning and schema lifecycle;
- user-facing SLI and reconciliation;
- capacity, security, rollout and rollback evidence.

## Independent transfer and rubric

### Assignment

A reviewer supplies an unfamiliar synthetic workflow packet with at least three independent authorities, one irreversible effect, one long wait, an outbox or equivalent handoff, current metrics/history and one incident. Design and operate it without a model answer.

Deliver:

1. invariant, authority and transaction-boundary map;
2. local ACID versus 2PC versus saga decision with rejected alternatives;
3. choreography/orchestration ADR;
4. explicit state machine and terminal states;
5. step classification around the pivot;
6. identity and schema contracts;
7. outbox/inbox/relay and effect-checkpoint crash analysis;
8. retry/deadline/manual/reconciliation design;
9. concurrency, security, observability, capacity, retention and cost plan;
10. fault timeline, containment, recovery, validation, rollback and cleanup.

The reviewer then changes one major condition: scale by 20x, add a region, remove provider idempotency, change privacy retention, introduce human approval, or make one step irreversible. Revise the design and defend the trade-off after a delay.

### Safety gates

- no production/shared service;
- no customer data or real credentials;
- no host network, firewall or clock mutation;
- no unbounded retry, replay or effect;
- every mutation has exact scope and rollback;
- external effects are synthetic;
- reviewer controls fault injection;
- cleanup proves processes, ports, files, volumes and records absent.

### Evidence rubric

| Criterion | Points | Observable evidence |
|---|---:|---|
| invariant and authority | 10 | ownership map and local atomic boundaries |
| coordination decision | 10 | ACID/2PC/saga and choreography/orchestration alternatives |
| state machine | 10 | states, versions, deadlines, terminals and owner |
| identities and schemas | 10 | stable operation through compensation and compatibility tests |
| publish/effect correctness | 10 | outbox/inbox, crash windows, idempotency and checkpoint |
| compensation and concurrency | 10 | pivot order, repeat-safe compensation and participant controls |
| operations | 10 | metrics, traces, histories, alerts and reconciliation |
| capacity and lifecycle | 10 | bottleneck drain, retention, replay and cost calculations |
| security and safety | 10 | authorization timing, least privilege, audit and guarded faults |
| transfer judgment | 10 | incident recovery, changed constraint, delayed defense and cleanup |

Maximum: 100. The lesson is not mastered by reading or by the offline model. The reviewer requires observable fault recovery, reconciliation, changed-constraint reasoning and delayed explanation.

### Self-check before submission

- Can every state explain its next legal transitions?
- Can every attempt reuse the same logical identity?
- Can every ambiguous effect be queried or escalated?
- Does compensation have its own failure path?
- Can stale workers or relays be rejected?
- Can current and rollback code replay retained histories?
- Does capacity include compensation and reconciliation?
- Does retention exceed the complete recovery horizon?
- Is authorization evaluated at the chosen durable boundary?
- Does final evidence prove the user invariant?

## References and review

Primary sources reviewed on 2026-08-05:

1. [Saga distributed transactions pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/saga) — local transactions, step classes, choreography/orchestration and saga isolation.
2. [Compensating Transaction pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction) — business-aware, resumable and fallible compensation.
3. [AWS Saga orchestration pattern](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga-orchestration.html) — coordinator, 2PC context, idempotency, semantic locks and observability.
4. [AWS Transactional outbox pattern](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html) — atomic state/publish intent and duplicate-aware processing.
5. [Debezium Outbox Event Router](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html) — outbox IDs, aggregate keys, routing and payload/schema options.
6. [Debezium Architecture](https://debezium.io/documentation/reference/stable/architecture.html) — transaction-log CDC components and positions.
7. [Temporal Workflow](https://docs.temporal.io/workflows) — durable workflow identity, history and replay concepts.
8. [Temporal Activity](https://docs.temporal.io/activities) — external activity boundaries, results and retries.
9. [Temporal Retry Policy](https://docs.temporal.io/encyclopedia/retry-policies) — backoff, attempts and failure classification controls.
10. [AWS Step Functions workflow types](https://docs.aws.amazon.com/step-functions/latest/dg/choosing-workflow-type.html) — execution semantics, history and duration trade-offs.
11. [PostgreSQL Two-Phase Transactions](https://www.postgresql.org/docs/current/two-phase.html) — prepare/commit state and external transaction-manager ownership.
12. [Apache Avro 1.12.0 Specification](https://avro.apache.org/docs/1.12.0/specification/) — writer/reader schemas, defaults, aliases and resolution.
13. [Protocol Buffers proto3 guide](https://protobuf.dev/programming-guides/proto3/) — compatible message evolution and reserved field numbers.
14. [CloudEvents 1.0.2 specification](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md) — event identity, source, type, subject and schema context.
15. [OpenTelemetry trace semantic conventions](https://opentelemetry.io/docs/specs/semconv/general/trace/) — causal trace relationships across asynchronous boundaries.

Use these sources to verify product and standard behavior, not to claim that one documented guarantee automatically covers another product or an external business effect. Defaults and limits can change; check the exact deployed version.

Review status: substantive draft. The primary-source URLs resolved during the 2026-08-05 audit. Direct schema and static lab validation are required before checkpoint. Ubuntu runtime, formal review, representative fault execution, reviewer transfer, delayed recall, publication and learner evidence remain separate gates.
