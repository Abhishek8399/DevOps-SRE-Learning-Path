# Observability: turn system behavior into decisions

Observability is not “install a dashboard.” It is the ability to infer a system’s internal state from useful, trustworthy signals and then choose a safe action.

```text
user journey -> service -> dependency -> storage
      |            |          |            |
   result       metrics      logs        traces
      \______________ shared request/trace identity ______________/
```

## Signal roles

Metrics answer **how much and how often**: request rate, errors, latency, saturation, queue age. Logs answer **what happened with context**: structured events, IDs, decisions, and failures. Traces answer **where time and errors crossed boundaries**. Profiles answer **where a process spent CPU, memory, or locks**. Events explain changes, but a deployment event is not proof that the deployment caused the incident.

## Start from a user journey

Define the operation, successful outcome, valid population, and time window before choosing a query. A green process metric can coexist with failed checkout requests. A high error count can be harmless if it counts expected rejected input. Every alert needs an owner, evidence boundary, urgency, and runbook action.

## Cardinality and cost

Labels such as `service`, `route`, and `status_class` are usually bounded. User IDs, request IDs, URLs, and exception text can create unbounded metric series. Put high-cardinality detail in logs or traces, sample deliberately, and retain only what supports a decision. An observability system can fail by exhausting memory, ingest quota, storage, or query budget.

## Correlation without fabrication

Propagate a request or trace ID across trusted boundaries, but never treat an ID as proof that two events are causally related. Check timestamps, parent/child relationships, deployment changes, and dependency evidence. Redact secrets and personal data before export; logs are durable copies and often have broader access than application state.

## Alert quality

Page on a user-impacting symptom or a rapidly approaching risk with enough evidence to act. Use recording rules and dashboards for exploration. A useful alert states: “what is wrong, who is affected, why now, what evidence supports it, and the first safe action.” Alert on burn rate or queue age when a raw threshold would page on harmless variance.

## Safe local exercise

Run a tiny local HTTP service that emits a counter, latency log, and request ID. Generate successful, invalid, and delayed requests. Calculate request rate, error ratio, and a simple latency percentile from the captured fixture. Then remove the request ID from one hop and explain exactly what correlation becomes impossible. Keep the fixture local and delete it after review.

## Triage sequence

1. Confirm the user operation, scope, and time window.
2. Check rate, errors, latency, saturation, dependency health, and recent change events.
3. Follow one request ID across service boundaries; verify missing links instead of guessing.
4. Compare a healthy control path or region.
5. Choose containment based on the failing boundary, then verify recovery through the journey.
6. Record query definitions, sampling, missing data, and uncertainty in the incident timeline.

## Interview defense

**Question:** “The dashboard is green but customers cannot pay. What do you do?”

**Strong answer:** “I treat the dashboard as evidence about its query, not the whole customer journey. I test a known payment flow, compare edge and backend outcomes, inspect error/latency distributions and dependency responses, and check telemetry freshness and sampling. I page or contain based on verified user impact, then repair the blind spot.”

**Question:** “Why not put request ID in a Prometheus label?”

**Strong answer:** “It creates unbounded cardinality and can exhaust the metrics backend. I keep bounded dimensions in metrics and put request IDs in structured logs/traces with access control and retention limits.”

## Teach-back checkpoint

Explain what each signal proves and does not prove. Design one alert for a checkout journey: define the population, good event, objective, query evidence, owner, first action, and what missing telemetry would make the alert unsafe.
