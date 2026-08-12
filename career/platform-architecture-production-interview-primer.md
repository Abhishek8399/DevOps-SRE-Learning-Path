# Platform architecture production interview: make the important boundaries explicit

System-design answers become vague when they begin with products. Begin with the user outcome, correctness rule, workload shape and failure boundary. Components are choices made to satisfy those facts—not decorations in a diagram.

```text
user -> edge -> identity -> service -> authoritative state -> asynchronous work -> derived views
          |          |          |             |                    |                 |
       rate limit  trust     SLI/SLO       transaction          idempotency       freshness
```

A dependable architecture can explain what happens when every arrow is slow, unavailable, duplicated, stale, unauthorized or partially complete.

## Scenario 1: design a payment-like request path

**Question:** Design an API that accepts a customer request and must never create two charge-like effects for one client action.

**Strong answer:** I start by clarifying the invariant: one accepted client intent maps to at most one authoritative business effect, while the API may be retried. I define caller identity, idempotency-key scope/lifetime, request fingerprint, authorization, response semantics, authoritative transaction boundary, external-provider contract, timeout/retry behavior, audit record and reconciliation. The service records the client intent and idempotency key atomically with the local authoritative state; an outbox or durable workflow carries the external effect. Repeated same-key/same-payload calls return the recorded result, while same-key/different-payload calls are a contract violation. I avoid claiming a distributed transaction with an external provider unless it exists. I define compensating/reconciliation behavior for crash windows, protect the path with rate/concurrency limits, and measure accepted intents, duplicate suppression, provider ambiguity, pending age and reconciliation backlog. Recovery is a reconciled ledger and correct client result, not merely HTTP 200.

**Weak answer:** “Use a cache lock.” A lock can expire, be partitioned, be bypassed by another writer, or fail to represent durable business truth.

**Senior follow-up:** Is exactly once a single database setting? No. It is an end-to-end claim across identity, durable state, retries, side effects, recovery and reconciliation; usually the practical target is at-least-once delivery plus idempotent effects.

## Scenario 2: traffic rises tenfold during a launch

**Question:** Your team expects 10x traffic tomorrow. What architecture and operational questions come before autoscaling?

**Strong answer:** I quantify request rate, burst, read/write mix, payload size, latency objective, active connections, data growth, retry behavior and critical user journey. I map each shared limit: edge/WAF, load balancer, application concurrency, database connections/locks/IOPS, cache memory/evictions, queue partitions/retention, third-party quotas, DNS/IP capacity, deployment/bootstrap speed and human operational capacity. I distinguish elastic stateless compute from nonelastic dependencies. I set load shedding, admission control, queueing/backpressure, cache and timeout/retry budgets deliberately, with a safe degraded mode for noncritical work. I test a representative bounded load and failure scenario, monitor saturation/latency/errors/freshness, and establish authority for pausing a release or limiting a feature. Scaling is successful only if the user journey and data correctness stay within objectives; instance count is not a service-level outcome.

**Weak answer:** “Set CPU autoscaling to 70%.” CPU is often unrelated to the narrow boundary: a connection pool, hot key, IOPS limit, quota, dependency or queue.

**Senior follow-up:** Why can retries turn a capacity event into an outage? When clients and services retry faster than the dependency recovers, they multiply work and consume the remaining capacity. Timeouts, budgets, jitter and load shedding are part of capacity design.

## Scenario 3: add search without making it authoritative

**Question:** Product wants fast full-text search over orders, but the transactional database is already busy. How do you design it?

**Strong answer:** I explicitly separate authority from projection. The transactional store remains the source of truth for order state and authorization. A durable change record/outbox/CDC path produces an idempotent search projection keyed by stable order identity and version. I define index freshness objective, ordering/out-of-order rules, deletion/retention/privacy behavior, reindex process, access filtering boundary and what users see when the index is stale. Search results that lead to an action revalidate current authority from the source of truth; the index is not permitted to approve a forbidden action. I measure change-to-index age, failed/dead-letter events, version conflicts, reindex progress and result quality. A full rebuild is planned as an isolated, throttled process that cannot overload the database.

**Weak answer:** “Let the search index be the database.” A derived index can lag, omit deletions, have different authorization semantics, or be rebuilt from a source it cannot replace.

**Senior follow-up:** What is a useful freshness SLO? State the population and measurement: for example, 99% of committed order updates become queryable within a defined duration, excluding explicitly quarantined invalid records with an owned remediation path.

## Scenario 4: choose synchronous versus asynchronous work

**Question:** A checkout request triggers inventory, fraud review, receipt email and analytics. Which parts happen synchronously?

**Strong answer:** I decide from the user-visible contract and invariant. The synchronous path contains only the checks/state changes required to give a truthful response within the latency objective—such as authorization, inventory reservation policy and durable order acceptance. Independent or slower effects become durable asynchronous work with stable identity, retry/deadline policy, idempotent consumers, observability and reconciliation. Fraud may be synchronous, asynchronous or staged depending on whether the business can safely hold/approve the order; I do not pick it from a diagram template. I specify pending states and customer messaging so a timeout does not falsely imply failure or completion. I model the failure paths: worker down, duplicate message, poison payload, provider timeout, partial completion and delayed compensation. This makes the system honest about work that is accepted but not yet finished.

**Weak answer:** “Put everything on a queue.” Queues decouple work but add delay, ordering, replay, retention, consumer, poison and observability responsibilities.

**Senior follow-up:** When is synchronous work safer? When the outcome must be known before granting an irreversible privilege or when an asynchronous compensation would be unsafe, unaffordable or impossible.

## Scenario 5: make a multi-region claim honestly

**Question:** The company asks for active-active across two regions. What do you clarify before drawing it?

**Strong answer:** I ask which failure is being tolerated, the RPO/RTO, acceptable stale/conflicting writes, traffic-routing authority, data ownership, identity/secrets/key behavior, external dependencies, operational access and tested promotion/fencing procedure. “Two regions” does not solve global DNS, control plane, database write conflicts, shared identity, deployment artifacts, third parties or operator decision time. I choose a write model deliberately: single writer with failover, partitioned ownership, or a conflict-resolution model that the business accepts. I document the steady path, degraded path, regional isolation, failover and failback. I require evidence from restore/failover exercises measuring actual data loss/time and user journey behavior. I resist active-active if the consistency model and operating cost do not justify it.

**Weak answer:** “Replicate the database both ways.” Bidirectional replication is not a conflict policy, fencing mechanism, or proof that clients and operators can recover safely.

**Senior follow-up:** What is fencing? Preventing an old or isolated writer from continuing after a new authority is promoted. Without it, both sides can accept conflicting writes during a partition or failover.

## Scenario 6: design observability into the architecture

**Question:** A service has dashboards, logs and traces, yet incidents still take hours. What would you redesign?

**Strong answer:** I begin with the decisions responders must make: is the user journey failing, which population, which dependency/path/version, is the system saturated, and what action is safe? I connect each decision to a bounded signal with owner, cardinality/cost, retention, delay and known blind spots. The service propagates stable request/tenant/workflow identities with privacy controls, records structured outcomes and dependency timings, exposes service and business SLIs, and connects alerts to actionable runbooks. I avoid collecting every field or putting high-cardinality identifiers into metrics. I test telemetry under failure, sampling, retries and partial outages; a trace that disappears during overload is not enough. I add synthetic journeys for critical paths and reconcile them with real-user outcomes. Observability is complete only when it shortens a safe decision, not when it creates a colorful dashboard.

**Weak answer:** “Add more logs.” Unstructured or unbounded logs can raise cost, leak data and still fail to answer who was affected or which change caused the regression.

**Senior follow-up:** What makes an alert actionable? It identifies an owned, time-sensitive user/system risk with enough context and authority to take a safe next action; a graph threshold without a response decision is usually noise.

## Design-defense map

Use this sequence in any architecture round:

1. State the user outcome, invariant, and explicit non-goals.
2. Quantify workload, latency, durability, freshness and recovery objectives.
3. Identify authority: writer, identity, policy, data and decision owner.
4. Draw the happy path, then walk every boundary through timeout, retry, duplicate, stale, unauthorized and partial failure.
5. Choose a bounded recovery and reconciliation method before calling the design resilient.
6. Name the signals, limits, runbook authority and evidence that would prove the objectives.
7. Explain the trade-off you deliberately did *not* choose.

This is how a diagram becomes an operating system for people, not just a collection of boxes.
