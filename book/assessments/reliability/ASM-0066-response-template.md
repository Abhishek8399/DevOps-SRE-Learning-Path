# ASM-0066 independent transfer response

This is a blank evidence template. It contains no model answer, fault location, expected diagnosis or passing claim. Complete it only for an authorized unseen disposable case. A reviewer decides the score.

## Independence and authorization gate

Complete and timestamp this section before inspecting derived evidence or changing the case.

| Field | Learner record |
|---|---|
| gate timestamp and timezone | |
| unseen-case source and owner | |
| prior exposure to similar cases | |
| help received before gate | |
| answer material not opened | |
| authorized operations | |
| forbidden operations and boundaries | |
| expected mutations | |
| abort conditions | |
| rollback path | |
| cleanup proof path | |

Environment identity verified locally:

| Evidence | Exact local value | Sanitized submitted value | Why the redaction preserves proof |
|---|---|---|---|
| operating system and kernel | | | |
| native, WSL or container boundary | | | |
| numeric UID and GID | | | |
| privilege | | | |
| process and network namespace | | | |
| workspace resolution and path type | | | |
| clock and timezone | | | |
| relevant tool versions | | | |

Authorization blocker, if any:

## User operation and telemetry architecture

Architecture diagram:

Text alternative:

| Hop | Producing or owning component | Input | Output | Version or configuration identity | Trust boundary | Possible loss or distortion | Available evidence |
|---|---|---|---|---|---|---|---|
| user entry | | | | | | | |
| service boundary | | | | | | | |
| synchronous dependency | | | | | | | |
| asynchronous boundary | | | | | | | |
| downstream worker or dependency | | | | | | | |
| SDK processor and exporter | | | | | | | |
| Collector receiver | | | | | | | |
| Collector processor | | | | | | | |
| Collector exporter | | | | | | | |
| backend ingest and query | | | | | | | |

## Version and maturity ledger

| Component or contract | Exact version | Status or maturity source | Configuration identity | Compatibility assumption | Evidence | Unknown |
|---|---|---|---|---|---|---|
| OpenTelemetry specification | | | | | | |
| language API and SDK | | | | | | |
| automatic instrumentation | | | | | | |
| manual or library instrumentation | | | | | | |
| OTLP | | | | | | |
| Collector distribution | | | | | | |
| Collector components | | | | | | |
| Semantic Conventions | | | | | | |

## Instrumentation ownership and semantic contract

| Operation | Boundary | Auto, manual or library owner | Expected span name and kind | Resource identity | Instrumentation scope | Required bounded attributes | Prohibited attributes | Convention version and status |
|---|---|---|---|---|---|---|---|---|
| ingress | | | | | | | | |
| internal domain work | | | | | | | | |
| synchronous client | | | | | | | | |
| publish or send | | | | | | | | |
| consume or process | | | | | | | | |
| downstream dependency | | | | | | | | |

Duplicate, missing or conflicting instrumentation observations:

## Expected trace topology

| Scenario | Expected operation sequence | Parent or link decision | Expected resource and scope | Sampling assumption | Proof limit |
|---|---|---|---|---|---|
| successful synchronous path | | | | | |
| asynchronous path | | | | | |
| retry | | | | | |
| batch or fan-in | | | | | |
| error | | | | | |
| slow operation | | | | | |

## Carrier and context contract

| Boundary and carrier | Inject owner | Sanitized serialized fields | Extract owner | Valid-context behavior | Missing-context behavior | Malformed or oversized behavior | Trust and baggage policy | Evidence |
|---|---|---|---|---|---|---|---|---|
| synchronous ingress | | | | | | | | |
| synchronous egress | | | | | | | | |
| asynchronous publish | | | | | | | | |
| asynchronous consume | | | | | | | | |
| third-party boundary | | | | | | | | |

Business correlation identifiers and why they are not trace authority:

## Source-to-query invariants

Use counts or bounded relationships. Mark unavailable evidence explicitly.

| Stage | Expected invariant | Baseline | Case state | Recovered | Final | Window and denominator | Evidence source | Proof limit |
|---|---|---:|---:|---:|---:|---|---|---|
| created | | | | | | | | |
| recording or sampled | | | | | | | | |
| SDK exported or failed | | | | | | | | |
| Collector accepted or refused | | | | | | | | |
| processed or dropped | | | | | | | | |
| queued or retried | | | | | | | | |
| Collector exported | | | | | | | | |
| backend accepted | | | | | | | | |
| query visible and fresh | | | | | | | | |

## Baseline evidence

| Time and timezone | Class | Command or query | Configuration and software identity | Workload, window and denominator | Raw sanitized observation | Natural variation | Proves | Does not prove |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |

Baseline acceptance statement:

## Predictions and hypotheses

Write these before derived diagnosis.

| ID | Hypothesis | State owner | Predicted evidence | Disconfirming evidence | Next safe observation | Initial probability or rank | Status and timestamp |
|---|---|---|---|---|---|---|---|
| H1 instrumentation or propagation | | | | | | | |
| H2 SDK or sampling | | | | | | | |
| H3 Collector configuration or policy | | | | | | | |
| H4 transport, backend or query | | | | | | | |

Plausible unrelated change and the evidence required before rejecting it:

## Authorized case activation

| Field | Record |
|---|---|
| activation timestamp | |
| exact owned control | |
| before state | |
| changed state | |
| expected scope | |
| abort checks | |
| rollback | |
| proof that unrelated resources did not change | |

## Chronological evidence ledger

| Time and timezone | Class: observation, contract, calculation, inference, hypothesis or unknown | Source and sanitized identity | Command, query or evidence | Window, sample, unit and denominator | Observation | Hypothesis update | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |
| | | | | | | | | | |
| | | | | | | | | | |
| | | | | | | | | | |

## Effective SDK and Collector configuration

SDK evidence:

| Process | Provider | Sampler | Processor | Exporter and protocol | Endpoint and timeout | Resource | Propagator | Shutdown or flush | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |

Collector evidence:

| Component instance | Defined | Enabled by service configuration | Listener or destination | Identity and transport | Stability and version | Runtime evidence | Proof limit |
|---|---|---|---|---|---|---|---|
| receiver | | | | | | | |
| processor | | | | | | | |
| exporter | | | | | | | |
| connector | | | | | | | |
| extension | | | | | | | |

Configuration validation result:

Runtime-to-file identity proof:

## Sampling and routing

| Decision point | Head or tail | Input population | Policy | Propagated decision | Routing key and state owner | Decision wait or late-span policy | Capacity evidence | Bias and proof limit |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |
| | | | | | | | | |

Controlled trace-set results:

| Journey class | Generated | Recording | Reached decision point | Retained | Complete by declared topology | Late or partial | Query visible | Explanation and limits |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| success | | | | | | | | |
| error | | | | | | | | |
| slow | | | | | | | | |
| async | | | | | | | | |

## Reliability, capacity and cost

| Quantity | Formula | Measured inputs | Estimated inputs and uncertainty | Result and unit | Budget | Owner and action |
|---|---|---|---|---|---|---|
| operations per second | | | | | | |
| spans or items per operation | | | | | | |
| admitted items per second | | | | | | |
| encoded bytes per second | | | | | | |
| tail decision occupancy | | | | | | |
| batch and queue memory | | | | | | |
| recoverable outage interval | | | | | | |
| retained bytes | | | | | | |
| application overhead | | | | | | |
| network, storage or query cost | | | | | | |

| Failure | Expected behavior | Retry boundary | Queue or persistence boundary | Shedding or backpressure action | Alert evidence | Recovery and proof limit |
|---|---|---|---|---|---|---|
| receiver unavailable | | | | | | |
| processor pressure | | | | | | |
| exporter or backend slow | | | | | | |
| process restart | | | | | | |
| disk full or failed | | | | | | |
| routing rebalance | | | | | | |

Unknown prices or unmeasured factors not invented:

## Security and privacy

| Boundary or data | Classification | Collection purpose | Allowlisted fields | Prohibited fields | Trust validation | Transport and access | Retention | Test evidence | Residual risk |
|---|---|---|---|---|---|---|---|---|---|
| trace context | | | | | | | | | |
| baggage | | | | | | | | | |
| span attributes | | | | | | | | | |
| metric attributes | | | | | | | | | |
| logs | | | | | | | | | |
| Collector diagnostics | | | | | | | | | |
| backend and query | | | | | | | | | |
| submitted evidence | | | | | | | | | |

Sensitive-field synthetic-canary result:

Exposure escalation record, if required:

## Diagnosis and competing explanations

Strongest direct observations:

Supported mechanism:

Rejected alternatives and disconfirming evidence:

Unresolved alternatives:

Why temporal proximity is or is not causal evidence:

## Recovery and cleanup

| Layer | Before | Case state | Recovery action | Recovered observation | Final cleanup observation | Window or sample | Proves | Does not prove |
|---|---|---|---|---|---|---|---|---|
| user operation | | | | | | | | |
| trace topology | | | | | | | | |
| resource and scope identity | | | | | | | | |
| SDK export | | | | | | | | |
| Collector pipeline | | | | | | | | |
| backend query and freshness | | | | | | | | |
| application overhead | | | | | | | | |
| privacy and security | | | | | | | | |

Cleanup inventory:

| Resource or state | Expected final state | Direct check | Result | Residual state or risk |
|---|---|---|---|---|
| processes | | | | |
| ports and listeners | | | | |
| files and configuration | | | | |
| containers or namespaces | | | | |
| queue or persistent state | | | | |
| debug endpoints | | | | |
| temporary identity or credential references | | | | |

## Production rollout and rollback

| Stage | Change class | Cohort | Preconditions | Observation window | User and overhead gates | Topology and pipeline gates | Security and privacy gates | Abort | Rollback | Owner |
|---|---|---|---|---|---|---|---|---|---|---|
| contract tests | | | | | | | | | | |
| disposable local | | | | | | | | | | |
| one instance | | | | | | | | | | |
| bounded region | | | | | | | | | | |
| controlled waves | | | | | | | | | | |

Failure exercise plan:

## Incident handoff

- Impact and scope:
- Current state:
- Strongest observations:
- Supported mechanism:
- Rejected alternatives:
- Containment:
- Recovery evidence:
- Security or privacy concern:
- Remaining unknowns:
- Next owner and action:
- Explicit proof boundary:

## Five-minute interview response

Response:

## Proof-limit register

Provide at least twelve precise limits.

| Limit class | Claim not established | Why current evidence cannot establish it | Next authorized evidence, if appropriate |
|---|---|---|---|
| population | | | |
| time window | | | |
| workload | | | |
| software and convention version | | | |
| carrier and context trust | | | |
| sampling | | | |
| routing and late spans | | | |
| missing data | | | |
| Collector configuration | | | |
| transport and acknowledgement | | | |
| backend storage and query | | | |
| security and privacy | | | |
| capacity and cost | | | |
| cleanup | | | |
| transfer and future behavior | | | |

## Learner self-review

- [ ] I completed the independence and authorization gate before investigation.
- [ ] I used an unseen disposable local case and did not open answered assessments or the fault manifest.
- [ ] I stayed inside the authorized non-production boundary and submitted blockers for unauthorized operations.
- [ ] I preserved raw evidence locally and submitted only a documented sanitized copy.
- [ ] I mapped the user operation separately from the source-to-query telemetry path.
- [ ] I pinned versions and recorded maturity instead of assuming OpenTelemetry components move in lockstep.
- [ ] I identified manual, automatic and library instrumentation ownership.
- [ ] I tested context carriers and treated incoming context and baggage as untrusted.
- [ ] I justified parent and link relationships without fabricating identity.
- [ ] I distinguished SDK creation, recording, sampling and export states.
- [ ] I distinguished Collector component definition, service enablement, health and data delivery.
- [ ] I disclosed head and tail sampling populations, routing, bias and partial traces.
- [ ] I measured queues, retries, persistence, backpressure, freshness and loss within the authorized case.
- [ ] I calculated overhead and cost with units and uncertainty and invented no prices.
- [ ] I used synthetic sensitive-field tests and preserved least-privilege boundaries.
- [ ] I verified user, topology, pipeline, overhead, privacy and cleanup recovery independently.
- [ ] I kept plausible unrelated changes alive until evidence disconfirmed them.
- [ ] I provided at least twelve precise proof limits and did not claim mastery.

Reviewer notes:
