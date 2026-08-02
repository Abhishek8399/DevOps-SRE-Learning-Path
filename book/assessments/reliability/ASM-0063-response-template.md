# ASM-0063 independent response template

This is a blank evidence structure, not an answer key. It contains no incident diagnosis, expected output, fault verdict, telemetry design decision or model response. It is valid only for an instructor-provided unseen disposable local case or a learner-created and learner-owned unseen disposable local case. The published LES-0026 guided lab and its missing-signal walkthrough are excluded. A qualified reviewer scores original learner-operated evidence against `ASM-0063.json`.

Private evidence stays private. Verify exact identity and resolved paths locally, but do not paste user names, group names, home directories, employer or customer names, or personal/employer path segments here. Submit numeric UID and GID, privilege state, boundary type, ownership and mode proof, and sanitized path structure using tokens such as `<USER>`, `<ORG>` and `<WORKSPACE>`. Never submit the secret mapping behind those tokens.

## Reviewer threshold and decision rule

A reviewer may record **Pass** only when all of these conditions are met:

- the rubric total is at least **80 out of 100**;
- no rubric criterion scores below **6 out of 10**;
- `Independence, authorization and evidence integrity`, `Safe containment, recovery and cleanup`, and `Security, privacy and profiling safety` each score at least **7 out of 10**;
- the independence and authorization gates are credible, the prescribed cleanup is proved, and no answer leakage or fabricated evidence is found.

Meeting the numeric threshold does not automatically pass the attempt. The reviewer must confirm the mandatory gates and evidence authenticity. Passing demonstrates only the submitted case under this rubric; it does not certify production safety, security, future behavior, interview readiness or professional mastery.

| Rubric criterion | Score / 10 | Reviewer evidence and reason |
|---|---:|---|
| Independence, authorization and evidence integrity | | |
| Architecture, user journey and state ownership | | |
| Five-signal contracts and semantic correctness | | |
| Baseline and experimental discipline | | |
| Diagnosis and missing-signal reasoning | | |
| Safe containment, recovery and cleanup | | |
| Telemetry pipeline reliability and observability | | |
| Cardinality, sampling, capacity and cost | | |
| Security, privacy and profiling safety | | |
| Production design, communication and proof limits | | |
| **Total / 100** | | |

Reviewer decision: pass / revise / invalid independence / blocked

Reviewer identifier, sanitized or explicitly approved, and date:

## Independence and authorization gate

- Attempt date, time and timezone:
- Attempt identifier:
- LES-0026 material seen before this gate:
- Answered assessments, worked examples, generated solutions or other learner responses seen before this gate:
- Help received before this gate:
- Help received after starting:
- I confirm this is an unseen case and not the LES-0026 guided or missing-signal case: yes / no
- I will not open `ASM-0061.json`, `ASM-0062.json`, the LES-0026 guided or missing-signal walkthrough, or any solution after this gate: yes / no
- If no, reviewer decision on whether a fresh case is required:
- Selected instructor-provided or learner-owned unseen disposable local case:
- Why I am authorized to inspect and change it:
- Production, shared, employer or external systems explicitly out of scope:
- Data categories expected:
- Evidence-sanitization method:
- Exact identity and resolved path verified locally before sanitization: yes / no
- Redaction tokens used, without their private mapping:

| Environment field | Sanitized submitted value or unknown | Evidence source | Proof limit |
|---|---|---|---|
| operating system and release | | | |
| kernel | | | |
| native, WSL, VM or container boundary | | | |
| numeric effective UID and GID, supplementary GIDs and privilege state; no user or group names | | | |
| sanitized resolved workspace boundary and path type; no personal or employer segments | | | |
| process or container boundary and sanitized identity | | | |
| relevant tool versions | | | |
| configuration or source revision | | | |
| clock source, timezone and synchronization state | | | |
| network access expected | | | |
| privilege expected | | | |

## Safety contract

| Field | Learner declaration |
|---|---|
| exact allowed mutation | |
| resources that may change | |
| resources that must not change | |
| expected start state | |
| expected faulted state | |
| expected recovered state | |
| abort conditions | |
| recovery control | |
| sanitized cleanup verification path or command | |
| escalation or blocker rule | |

Blocked gate, if applicable:

```text

```

Why I stopped without installing, elevating, authenticating, contacting an external service, weakening a control or inspecting unauthorized data:

## User journey and system boundary

- User or synthetic operation:
- Observation point:
- Success definition:
- Failure definition:
- Population and exclusions:
- Expected workload:
- Time window:

Architecture diagram:

```text

```

Text alternative:

| Boundary or component | State owner | Input identity | Output identity | Failure visible where? | Evidence available | Evidence unavailable or unknown |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |
| | | | | | | |

## Telemetry evidence path

```text

```

Text alternative:

| Stage | Owner role and sanitized identity | Receives | May transform or drop | Forwards or stores | Health evidence | Proof limit |
|---|---|---|---|---|---|---|
| source or instrumentation | | | | | | |
| receiver | | | | | | |
| processor | | | | | | |
| exporter | | | | | | |
| transport | | | | | | |
| backend ingestion | | | | | | |
| retention or index | | | | | | |
| query | | | | | | |
| dashboard or alert | | | | | | |

## Five-signal contracts

### Metric contract

| Field | Value and evidence |
|---|---|
| operational question | |
| name and owner | |
| type and temporality, if known | |
| unit | |
| population and denominator | |
| labels or dimensions and their bounds | |
| timestamp owner | |
| collection path and interval | |
| query and window | |
| retention and access | |
| cost driver | |
| proves | |
| does not prove | |

### Structured-log contract

| Field | Value and evidence |
|---|---|
| operational question | |
| source and event schema | |
| severity semantics | |
| bounded context and correlation | |
| timestamp owner | |
| journal, file or stream boundary | |
| collection and query scope | |
| rate limit, rotation and retention | |
| access and sensitive-field policy | |
| proves | |
| does not prove | |

### Trace or correlated-request contract

| Field | Value and evidence |
|---|---|
| operational question | |
| ingress context policy | |
| trace and span identity source | |
| boundaries crossed | |
| propagation mechanism | |
| sampling policy | |
| export and retention path | |
| completeness test | |
| trust and sensitive-data limits | |
| proves | |
| does not prove | |

### Change-event contract

| Field | Value and evidence |
|---|---|
| operational question | |
| event type and state owner | |
| immutable operation or revision identity | |
| occurrence time | |
| observation or ingestion time | |
| actor or automation identity, sanitized | |
| before and intended-after state | |
| collection and retention path | |
| proves | |
| does not prove | |

### Profile or profiling-decision contract

| Field | Value and evidence |
|---|---|
| operational question | |
| profile or event type | |
| process, thread, CPU, cgroup or host scope | |
| build and workload identity | |
| duration and sampling settings | |
| privilege and authorization | |
| overhead measurement | |
| sensitive-data risk and protection | |
| stored artifact identity and cleanup | |
| reason unavailable or unsafe, if applicable | |
| proves | |
| does not prove | |

## Baseline

- Baseline window:
- Workload definition:
- Sample count and denominators:
- Expected natural variation:
- Configuration identity:
- Telemetry configuration identity:

| Signal or state | Exact command or query | Raw sanitized evidence location | Unit and window | Baseline observation | Proof limit |
|---|---|---|---|---|---|
| user or black-box | | | | | |
| service RED | | | | | |
| resource USE | | | | | |
| change events | | | | | |
| telemetry pipeline | | | | | |
| profile or profiling decision | | | | | |

Baseline raw evidence:

```text

```

## Predictions before fault injection

Prediction timestamp:

| Hypothesis | State owner | Predicted evidence | Disconfirming evidence | Next safe observation | Status |
|---|---|---|---|---|---|
| H1 | | | | | untested |
| H2 | | | | | untested |
| H3 | | | | | untested |
| H4, optional | | | | | untested |

Unknowns I will not infer:

## Fault injection record

| Field | Exact value and evidence |
|---|---|
| provided or owned fault control | |
| start time and clock | |
| exact state changed | |
| expected affected boundary | |
| expected unaffected boundaries | |
| expected signal | |
| abort threshold | |
| rollback or recovery control | |
| observed control output | |

Fault-control raw evidence:

```text

```

## Faulted observations

| Signal or state | Exact command or query | Raw sanitized evidence location | Unit, window and denominator | Observation | Classification | Proof limit |
|---|---|---|---|---|---|---|
| user or black-box | | | | | | |
| RED rate | | | | | | |
| RED errors | | | | | | |
| RED duration | | | | | | |
| USE utilization | | | | | | |
| USE saturation | | | | | | |
| USE errors | | | | | | |
| change event | | | | | | |
| log | | | | | | |
| trace or correlation | | | | | | |
| profile or profiling decision | | | | | | |
| telemetry pipeline | | | | | | |

Faulted raw evidence:

```text

```

## Timestamp and correlation audit

| Source | Occurrence time | Observation time | Ingestion or query time | Clock and timezone | Measured skew | Correlation identity | Sampling or completeness limit |
|---|---|---|---|---|---|---|---|
| | | | | | | | |
| | | | | | | | |
| | | | | | | | |

## Missing, misleading or degraded signal

- Signal under investigation:
- Expected evidence contract:
- First confirmed present boundary:
- First confirmed absent, stale, distorted or mismatched boundary:
- Current classification: source / collection / processing / export / storage / retention / permission / query / schema / clock / unknown

| Candidate boundary | Observation | Predicted if responsible | Disconfirming evidence | Result | Next safe evidence |
|---|---|---|---|---|---|
| source | | | | | |
| receiver | | | | | |
| processor | | | | | |
| exporter or transport | | | | | |
| backend ingestion | | | | | |
| retention or index | | | | | |
| permission or query | | | | | |

What the gap prevents me from concluding:

## Diagnostic conclusion

- User impact supported by evidence:
- First violated contract supported by evidence:
- Mechanism supported by evidence:
- Contributing condition supported by evidence:
- Telemetry failure supported by evidence:
- Competing hypotheses not eliminated:
- Unknowns:
- Smallest authorized containment:
- Evidence that would change this conclusion:

## Recovery and cleanup

| Step | Exact control | Expected state | Abort condition | Observed evidence | Proof limit |
|---|---|---|---|---|---|
| recovery | | | | | |
| user verification | | | | | |
| service verification | | | | | |
| resource verification | | | | | |
| telemetry verification | | | | | |
| cleanup | | | | | |

Recovery window, workload, samples and denominators:

Recovered raw evidence:

```text

```

| Cleanup target | Expected final state | Exact check | Observed final state | Residual difference or risk |
|---|---|---|---|---|
| process or container | | | | |
| port or socket | | | | |
| file or artifact | | | | |
| configuration | | | | |
| namespace, network or volume | | | | |
| telemetry state | | | | |

## Cardinality, sampling, retention and cost

### Cardinality worksheet

| Metric or signal | Dimension | Measured or estimated distinct values | Churn window | Required decision | Keep, aggregate, move or remove | Evidence or assumption |
|---|---|---:|---|---|---|---|
| | | | | | | |
| | | | | | | |

Series or equivalent volume formula:

```text

```

Calculated result, unit and uncertainty:

### Sampling and volume worksheet

| Signal | Population rate | Item size | Sampling or filter policy | Retained rate | Known bias | Decision preserved | Evidence or assumption |
|---|---:|---:|---|---:|---|---|---|
| | | | | | | | |
| | | | | | | | |

### Retention and cost worksheet

| Signal or tier | Resolution | Retention | Access need | Estimated bytes or cost unit | Replication or index assumption | Owner | Review date |
|---|---|---|---|---:|---|---|---|
| | | | | | | | |
| | | | | | | | |

Budget, threshold and action:

Unknown prices or cost factors not invented:

## Security, privacy and profiling review

| Data or boundary | Classification | Collection purpose | Minimum required fields | Prohibited fields | Access | Retention | Test evidence | Residual risk |
|---|---|---|---|---|---|---|---|---|
| metric labels | | | | | | | | |
| logs | | | | | | | | |
| trace attributes and baggage | | | | | | | | |
| change events | | | | | | | | |
| profile artifacts | | | | | | | | |
| local raw evidence | | | | | | | | |

| Security boundary | Current evidence | Threat or failure | Proposed control | Validation | Proof limit |
|---|---|---|---|---|---|
| incoming trace context | | | | | |
| telemetry transport | | | | | |
| collector identity and ports | | | | | |
| backend or file access | | | | | |
| profiling privilege | | | | | |
| retention and deletion | | | | | |

Sensitive-field canary or schema-test evidence:

```text

```

## Production observability design

Architecture diagram:

```text

```

Text alternative:

| Design area | Proposed contract | Failure behavior | Capacity or cost bound | Security or privacy control | Rollout and validation | Remaining trade-off |
|---|---|---|---|---|---|---|
| user-journey monitoring | | | | | | |
| service RED | | | | | | |
| resource USE | | | | | | |
| metrics | | | | | | |
| logs | | | | | | |
| traces and context | | | | | | |
| events | | | | | | |
| profiles | | | | | | |
| collector or pipeline | | | | | | |
| storage and retention | | | | | | |
| query and dashboard | | | | | | |
| alert and runbook | | | | | | |

### Dashboard decision map

| Dashboard layer | Audience and decision | Signals | Required dimensions | Freshness and missing-data behavior | Drill-down destination |
|---|---|---|---|---|---|
| user journey | | | | | |
| service and dependency | | | | | |
| resource | | | | | |
| telemetry pipeline | | | | | |
| cost and governance | | | | | |

### Alert and runbook contracts

| Condition | User or evidence consequence | Owner | Urgent action | Runbook path | Resolve condition | Noise or missed-event test |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |

## Chronological evidence ledger

| Time and timezone | Class | Source type and sanitized identity | Command, query or evidence | Window, unit and denominator | Observation | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |
| | | | | | | | | |
| | | | | | | | | |

## Incident handoff

- Impact and scope:
- Current state:
- Strongest observations:
- Supported mechanism:
- Containment and recovery:
- Telemetry gap:
- Security or privacy concern:
- Remaining unknowns:
- Next owner and action:
- Explicit proof boundary:

## Five-minute interview response

```text

```

## Proof-limit register

Provide at least twelve precise claims that current evidence does not establish.

| Claim not established | Why current evidence cannot establish it | Next authorized evidence, if appropriate |
|---|---|---|
| population limit | | |
| time-window limit | | |
| sampling limit | | |
| missing-data limit | | |
| timestamp or clock limit | | |
| correlation limit | | |
| causality limit | | |
| query or aggregation limit | | |
| telemetry-pipeline limit | | |
| privacy or security limit | | |
| profiling or workload limit | | |
| transfer or future-behavior limit | | |

## Final learner self-review

- [ ] I completed the independence and authorization gate before investigation.
- [ ] I used an unseen disposable case and did not use the published LES-0026 guided or missing-signal case.
- [ ] I did not open answered assessments or solution material after the gate.
- [ ] I used only an authorized local target and one bounded reversible fault.
- [ ] I preserved raw sanitized evidence and labeled observation, calculation, contract, inference, hypothesis and unknown separately.
- [ ] I verified exact identity and paths locally but submitted numeric UID/GID, privilege and boundary proof with private names and path segments redacted.
- [ ] I recorded exact windows, samples, denominators, units, clocks, queries and freshness, and retained technical identity evidence after required private-name and path redaction.
- [ ] I applied black-box, RED, USE and golden-signal questions at explicit boundaries.
- [ ] I treated metrics, logs, traces, events and profiles as evidence with limits, not automatic truth.
- [ ] I diagnosed a missing, misleading or degraded signal along the source-to-query path.
- [ ] I verified recovery with user, service, resource and telemetry evidence.
- [ ] I proved cleanup for every resource the exercise could change.
- [ ] I calculated or bounded cardinality, sampling, retention, capacity and cost without invented prices.
- [ ] I tested privacy and security controls and did not copy sensitive values.
- [ ] I supplied at least twelve narrow proof-limit statements.
- [ ] I did not claim that completion or a passing review awards mastery.

Reviewer notes:
