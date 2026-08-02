# ASM-0045 independent response template

This is a blank evidence structure, not an answer key. Complete it outside the LES-0020 registered lab root. A reviewer, not the harness, evaluates the submission.

## Independence declaration

- Attempt identifier:
- Start date and time with timezone:
- Help, hints, tools, guided material, source, answer files, or prior responses seen:
- I captured raw scenario before any observe command: yes / no
- I kept this response outside lab-owned state: yes / no
- I did not use network, elevation, cloud, or cluster access: yes / no

## Runtime and safety boundary

| Field | Evidence |
|---|---|
| Windows edition/build |  |
| PowerShell version |  |
| Effective identity and elevation state |  |
| Go executable and version |  |
| GOOS, GOARCH, CGO_ENABLED |  |
| Module path and physical directory |  |
| GOPROXY and GOSUMDB during lab |  |
| RELIABILITY_ATLAS_STATE_HOME |  |
| Registered lab root |  |
| Expected local changes |  |
| Abort conditions |  |
| Ubuntu/WSL limitation |  |

## Baseline

| Observation | Value | Proves | Does not prove |
|---|---|---|---|
| Initial state |  |  |  |
| Setup |  |  |  |
| Baseline accepted jobs |  |  |  |
| Baseline terminal results |  |  |  |
| Baseline consumer readback |  |  |  |

## Raw independent scenario

Paste only the unmodified output from lab.ps1 scenario before any observe command:

~~~json

~~~

- Capture time:
- Forbidden derived-field scan:
- Why this remains an input rather than a diagnosis:

## Prediction before derived evidence

- Promised user operation:
- Stable logical operation ID:
- Client-observed facts:
- Local durable facts:
- Facts unknown to the modeled authority:
- Current replay permission: allowed / refused / unknown
- Reason:

| Hypothesis | State owner | Predicted observation | Disconfirming check |
|---|---|---|---|
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

## Architecture and state flow

Draw and label:

~~~text
CLI/controller -> strict input -> typed intent -> context/deadline
       -> bounded queue/workers -> effect adapter -> authority
       -> reconciliation -> receipt publication -> verification
       -> logs/metrics/traces -> stdout/stderr/exit
~~~

Your diagram:

~~~text

~~~

Text alternative:

## Concurrency ownership table

| Resource/channel | Owner/sender | Receiver | Closer | Capacity | Cancellation path | Join/retirement proof |
|---|---|---|---|---:|---|---|
|  |  |  |  |  |  |  |

## Chronological evidence

| Order/time | Command or source | Observation | Classification | Proves | Does not prove | Next discriminating check |
|---|---|---|---|---|---|---|
|  |  | observation / fact / calculation / inference / hypothesis / unknown |  |  |  |  |

## Diagnosis

- First failed boundary:
- Immediate mechanism:
- State owner:
- Root cause:
- Contributing conditions:
- Supporting evidence:
- Rejected alternative and evidence:
- Remaining unknowns:

## Go design

- Module, source, toolchain, target, and artifact identity:
- CLI configuration precedence:
- Wire types and strict JSON rules:
- Internal named types and invariants:
- Consumer-owned interfaces:
- Error types, wrapping, Is/As, and exit translation:
- Root context, overall deadline, cancellation cause:
- Goroutine admission and worker cap:
- Channel ownership, close, and join:
- Memory synchronization:
- Shared HTTP Client and Transport:
- DNS/connect/TLS/header/body limits:
- Status, body-size, strict decode, and Close contract:
- Stable idempotency identity:
- Unknown-outcome reconciliation:
- Attempt cap, backoff, jitter, and retry budget:
- Receipt publication, visibility, and durability scope:
- Signal and graceful shutdown:
- Logs, metrics, traces, redaction, and cardinality:

## Recovery decision card

| Field | Decision and evidence |
|---|---|
| Actor and authorization |  |
| Exact target/namespace |  |
| Stable operation ID |  |
| Preconditions |  |
| Blast radius |  |
| Overall deadline |  |
| Abort threshold |  |
| Prior state retained |  |
| Retry eligibility |  |
| Rollback boundary |  |
| Compensation boundary |  |
| Operation verification |  |
| Remaining-risk owner |  |

## Verification matrix

| Case | Expected result | Evidence | Proves | Remaining unknown |
|---|---|---|---|---|
| valid strict input |  |  |  |  |
| unknown JSON field |  |  |  |  |
| oversized input |  |  |  |  |
| cancel before admission |  |  |  |  |
| cancel after request write |  |  |  |  |
| response lost after commit |  |  |  |  |
| proven no effect |  |  |  |  |
| duplicate delivery |  |  |  |  |
| concurrent runner |  |  |  |  |
| receipt conflict |  |  |  |  |
| race detector |  |  |  |  |
| fuzz target |  |  |  |  |
| goroutine retirement |  |  |  |  |
| reparse or tamper refusal |  |  |  |  |
| unexpected artifact cleanup refusal |  |  |  |  |
| original operation readback |  |  |  |  |

## CI or Kubernetes transfer

- Trigger/controller retry composition:
- Artifact provenance and digest:
- Runtime image/toolchain:
- User, service account, and RBAC:
- Namespace and target identity:
- Queue and worker bounds:
- HTTP/TLS/proxy/network policy:
- Authoritative state and checkpoint owner:
- Lease, conflict, and fencing boundary:
- Secret delivery and redaction:
- Observability and cardinality:
- Capacity and cost:
- Canary scope:
- Kill switch and abort thresholds:
- Rollback versus compensation:
- Local model claims that do not transfer:

## Validation transcript

### gofmt

~~~text

~~~

### go test

~~~text

~~~

### go vet

~~~text

~~~

### build and go version -m

~~~text

~~~

### race detector: pass, fail, or unsupported

~~~text

~~~

### complete verify.ps1

~~~text

~~~

### final absence

~~~text

~~~

Why these results do not prove production safety or mastery:

## Incident communication

- User impact:
- Immediate mitigation:
- Known committed operations:
- Known no-effect operations:
- Unknown operations:
- Recovery performed:
- Original operation verification:
- Root cause:
- Contributing conditions:
- Prevention items, owners, and deadlines:
- Remaining risk and owner:
