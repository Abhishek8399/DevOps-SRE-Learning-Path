# Observability production interview: make the hidden request path explainable before you change it

Monitoring tells you that a defined signal crossed a threshold. Observability is the ability to ask useful new questions about a system from the evidence it emits. Neither lets you skip the work of defining the user outcome and tracing the path that produces it.

```text
user journey -> edge -> service -> dependency -> state
     |            |         |            |           |
  synthetic     metrics   traces       logs        profiles
     \____________ correlation identity, time, scope, owner ____________/
                                      |
                                safe decision
```

When an alert arrives, start with: **which user operation is failing or degrading, for whom, since when, and what evidence can disprove my first guess?**

## Scenario 1: CPU is normal but customers see slow checkout

**Question:** The checkout service CPU dashboard is green, yet the p99 checkout latency alert is firing. What do you do?

**Strong answer:** I do not let normal CPU close the incident. I establish the affected journey, region/tenant/cohort, time window, success/error/latency distribution and baseline. I trace the request from edge through application and dependencies using a correlation ID where available. I compare edge latency, queue time, application spans, database/cache/external-call latency, connection pools, DNS/TLS, retries, payload sizes and saturation signals such as run queue, memory pressure, I/O wait, pool exhaustion or concurrency. CPU can be low while requests wait on a dependency, lock, queue, network path or rate limiter. I check recent releases, configuration/feature changes and traffic mix, then contain the earliest safe failing boundary—perhaps rollback a regression, reduce a harmful feature cohort, limit concurrency or isolate a slow dependency. I verify the representative customer operation and tail distribution recover, not merely that a host metric becomes green. Prevention is an owned journey SLI, trace/log correlation, dependency dashboards and alerts that distinguish latency, errors and saturation.

**Weak answer:** "Add more application instances." Scaling can amplify connection pressure, retries or a downstream bottleneck while leaving the actual wait unchanged.

**Senior follow-up:** Why is p99 important here? Averages can look healthy while a meaningful tail of users is slow. But p99 needs enough traffic, a stable definition and cohort context; it is not automatically a diagnosis.

## Scenario 2: the error-rate alert is noisy and responders ignore it

**Question:** A service pages every night because error rate exceeds 2%, but most pages are expected client cancellations. How do you improve the alert?

**Strong answer:** I inspect the exact numerator and denominator, status/error classes, request route, caller, cancellation semantics, retry behavior, traffic volume and user outcome. I do not simply raise the threshold. Client cancellation may be expected, may indicate user navigation, or may reveal upstream timeouts; classification must be owned and tested. I separate meaningful server failures, dependency failures, rejected/invalid requests, controlled rate limiting and client-abandoned work where the contract supports that distinction. I use an alert tied to a user-impact objective with a suitable observation window and burn rate, plus a runbook that says what evidence to collect and when to escalate. I add a low-urgency diagnostic signal for unusual cancellation changes rather than paging on a known steady baseline. After change, I review missed/false alerts, response time and the distribution of suppressed events; alert reduction is not success if real failures disappear. Prevention is versioned telemetry contracts, error taxonomy, dashboard ownership and regular alert quality review.

**Weak answer:** "Mute the alert overnight." That removes a symptom without determining whether the signal is expected, misclassified or a real recurring degradation.

**Senior follow-up:** What is alert fatigue? Repeated low-actionability pages train people to delay or ignore signals, increasing the chance that a real incident is missed. It is a reliability problem, not merely an annoyance.

## Scenario 3: traces are sampled and the one failing request is absent

**Question:** A high-value customer reports one failed transaction. The trace system has no trace for its request ID. How do you proceed?

**Strong answer:** I state the evidence gap instead of inventing a trace. I validate the request identity, timestamp/time zone, customer-safe identifiers, edge/gateway records, application logs, audit/event records, database/queue effects, deployment version and relevant dependency evidence under appropriate access control. I examine sampling policy, ingestion loss, propagation headers, retention, tail-sampling decisions and clock skew to understand why the trace is absent. A trace may be deliberately sampled out, incorrectly correlated or unavailable during a telemetry outage. For a high-value or error case, I may use bounded error/slow-request tail sampling, durable audit events or targeted temporary instrumentation that respects privacy/cardinality budgets. I do not enable 100% verbose tracing globally in an incident without considering cost, latency, sensitive data and collector capacity. I reconstruct the smallest defensible timeline, recover the customer outcome where authorized, and improve the telemetry contract so failure classes retain enough evidence.

**Weak answer:** "The trace system has no record, so the request never arrived." Absence can be caused by sampling, ingestion, propagation, retention, clock or query failures.

**Senior follow-up:** What should a correlation ID prove? It links records according to a defined propagation contract. It does not prove every downstream side effect completed, that clocks agree, or that a missing record means no event occurred.

## Scenario 4: a dashboard query becomes the outage

**Question:** During a traffic spike, the observability backend is overloaded. Teams add more high-cardinality labels to find the culprit. What do you do?

**Strong answer:** I protect the telemetry system as a production dependency and stop changes that worsen its cardinality or query load. I identify the objective: what decision is blocked, what low-cardinality aggregate or sampled evidence can answer it, and which data source is still healthy? Unbounded labels such as user IDs, request IDs, full URLs or error messages multiply time series/index entries and can harm cost, ingestion and query latency. I preserve stable dimensions such as service, operation, status class, region and bounded tenant tier, then use traces/logs/audits with access controls for per-request investigation. I apply ingestion/query limits, recording/aggregation rules, retention tiers, collector health alerts and a priority path for incident-critical telemetry. If capacity must grow, I do it with a cost/retention plan, not by accepting unbounded identity in metrics. After recovery, I perform a telemetry post-incident: schema owner, cardinality budget, load test, dashboard query review and fallback signals.

**Weak answer:** "More labels always make metrics more observable." More dimensions can make a metric unaffordable, slow or unusable while still failing to capture the causal evidence.

**Senior follow-up:** Where should high-cardinality diagnosis usually live? In controlled logs, traces, audit records or targeted profiling/sampling with retention, access and cost controls—not as an unlimited metric label.

## Scenario 5: a synthetic check is green but real users fail

**Question:** The homepage synthetic check returns 200 every minute, yet users cannot complete account registration. What is missing?

**Strong answer:** The check proves only its configured path from its configured location/identity at its execution time. I map the full registration journey: DNS/edge, authentication/verification, form/API validation, feature flags, queue/email/SMS provider, database write, session/cookie behavior, regional routing and the user cohort. A homepage 200 might never exercise authentication, a write, a third party, browser behavior or the affected geography. I create or validate a safe synthetic transaction with dedicated test identity/data, cleanup, rate limits, secrets handling and an explicit boundary between test and customer state. I combine it with real-user monitoring or outcome metrics where privacy/consent permits. I investigate the earliest diverging boundary and verify an end-to-end registration outcome after repair. Prevention is journey-level SLIs, representative synthetic coverage, change-aware checks and periodic validation that the test still reflects the product contract.

**Weak answer:** "The site is up because the homepage is 200." Availability of a static or shallow endpoint is not availability of a user task.

**Senior follow-up:** Why can a synthetic transaction be misleading too? It may use privileged credentials, an unrepresentative region/browser, cached data, a different feature flag or a test-only dependency path. Treat it as scoped evidence.

## Scenario 6: profiling shows a hot function during a latency incident

**Question:** A profile points to JSON serialization as the top CPU consumer. Do you optimize it immediately?

**Strong answer:** A profile is useful evidence about sampled execution time, but I connect it to the user symptom and workload change first. I verify profile scope, duration, sample bias, service version, request mix, CPU throttling and whether the hot function is causal or merely the place time accumulates after another change. I compare before/after profiles and traces, inspect payload growth, serialization configuration, compression, caching, allocation/GC and downstream effects. If serialization is a real bottleneck, I choose the narrowest safe remedy—payload contract reduction, bounded pagination, efficient encoding, caching, a compatible library/configuration or capacity—with benchmarks and correctness/security tests. I deploy via a measured canary with latency, error, resource and cost guardrails. I do not optimize a function in isolation if the actual user problem is queueing, a dependency or a pathological cohort.

**Weak answer:** "Rewrite it in a faster language." A rewrite expands risk and may not change the dominant request-path wait. First prove the bottleneck and the expected outcome.

**Senior follow-up:** What is the difference between a hotspot and a bottleneck? A hotspot consumes visible resources; a bottleneck is the limiting boundary for the relevant workload and objective. They can overlap, but do not have to.

## Observability answer map

1. Start from the user operation, cohort and time window; then trace boundaries.
2. Make metric numerator, denominator, classification and action explicit.
3. Treat missing telemetry as an evidence gap with known failure modes, not proof of absence.
4. Budget cardinality, retention and query load so observability remains available during stress.
5. Test real user journeys, not only shallow liveness endpoints.
6. Use profiles and every other signal to form and test a hypothesis, then verify recovery from the user's view.

The sentence worth remembering is: **"A green dashboard is a clue about one measurement; the customer journey is the thing I am responsible for proving."**
