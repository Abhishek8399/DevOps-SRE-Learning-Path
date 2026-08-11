# OpenTelemetry: carry trustworthy context across boundaries

OpenTelemetry provides common APIs, SDKs, context propagation, and collector patterns for telemetry. It does not automatically make instrumentation correct, cheap, or private.

```text
request -> service A -> service B -> datastore
   |          |            |             |
trace/span  attributes   propagation   export
                         collector -> backend
```

## Context and propagation

Propagate trace context across trusted service boundaries and create spans around meaningful operations. Validate that parent/child relationships, service identity, timestamps, status, and sampling decisions are coherent. Do not propagate secrets or accept untrusted baggage as authorization.

## Signals and semantic quality

Metrics aggregate bounded dimensions; traces explain a request path; logs carry event detail. Use stable service/route/status attributes, avoid request IDs as metric labels, and define what missing or sampled data means. A trace with broken propagation can look complete while hiding the failing hop.

## Collectors and cost

A collector can batch, retry, filter, redact, sample, and route telemetry, but it becomes another capacity and failure boundary. Bound queues, memory, export retries, and retention. Protect telemetry from taking down the workload or leaking sensitive data.

## Safe local exercise

Create a local fixture that emits a trace-like request tree and metrics with bounded labels. Remove propagation at one hop, inject a timeout, and compare what can and cannot be inferred. Apply a redaction rule and queue limit in the fixture, then inspect dropped/sampled counts. Use no external backend.

## Triage sequence

1. Confirm instrumentation version, service identity, sampling, clock, and export path.
2. Follow one request through each boundary and identify missing parent/child evidence.
3. Separate application failure from collector/export/backpressure failure.
4. Redact or drop unsafe data and protect workload capacity.
5. Verify user SLI and telemetry completeness after recovery.

## Interview defense

**Question:** “Why is a trace missing the database span?”

**Strong answer:** “I check context propagation, instrumentation coverage/version, sampling, clock, exporter/collector queues, and database client boundaries. I distinguish an absent span from a failed export and repair the earliest evidence gap.”

**Question:** “How do you control observability cost?”

**Strong answer:** “Bound metric cardinality, sample traces deliberately, filter/redact at a controlled boundary, retain detail according to user and incident needs, and monitor collector capacity and dropped data. I never solve cost by hiding the SLI.”

## Teach-back checkpoint

Draw one request through two services and a collector. State what context crosses each boundary, what is sampled or redacted, what each signal proves, and how you detect telemetry loss.
