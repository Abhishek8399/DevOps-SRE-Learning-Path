# ASM-0048 independent response template

This is a blank learner-evidence structure, not an answer key. It contains no independent-case outcome, diagnosis, recovery, or model solution. A reviewer evaluates original evidence against `ASM-0048.json`.

## Independence declaration

- Attempt date and time with timezone:
- Clean attempt identifier:
- Help, hints, tools, fixture source, guided answer, or prior answer seen:
- I captured raw scenario input before derived observations: yes / no
- I kept this response outside the guarded lab directory: yes / no

## Environment and safety scope

| Field | Evidence |
|---|---|
| Ubuntu release and native/WSL boundary | |
| Python executable and version | |
| Bash version | |
| Effective UID and groups | |
| Physical repository and lab path | |
| Network and port boundary | |
| Expected local changes | |
| Abort conditions | |
| Supported cleanup | |
| Sensitive data intentionally excluded | |

## Baseline

```text

```

| Baseline field | Meaning | Proves | Does not prove |
|---|---|---|---|
| Request and response media types | | | |
| Parsed JSON types | | | |
| Unicode and byte count | | | |
| Schema/API version | | | |
| Status and consumer readback | | | |

## Raw independent scenario

Paste only the unmodified `bash lab.sh scenario` output:

```text

```

Confirm that the raw scenario contains no derived outcome, receipt, diagnosis, recovery, duplicate count, retry eligibility, or answer key:

## Prediction before derived observations

- Prediction timestamp:
- First boundary I predict failed or became ambiguous:
- Predicted state-owner outcome:
- Is retry currently permitted? Why or why not?
- Minimum next observation and why it discriminates outcomes:

## Competing hypotheses

| ID | Hypothesis | Predicted evidence | Disconfirming evidence | Current status |
|---|---|---|---|---|
| H1 | | | | untested |
| H2 | | | | untested |
| H3 | | | | untested |
| H4, optional | | | | untested |

## Bytes-to-outcome diagram

```text

```

Text alternative:

## Contract table

| Boundary | Declared contract | Observed value | Compatible? | Owner | Failure representation |
|---|---|---|---|---|---|
| Character and encoding | | | | | |
| Request Content-Type | | | | | |
| Response Accept/Content-Type | | | | | |
| JSON top-level and field types | | | | | |
| Unknown/required fields | | | | | |
| API and schema version | | | | | |
| Authentication | | | | | |
| Authorization | | | | | |
| Idempotency key and intent binding | | | | | |
| Deadline and timeout | | | | | |
| Pagination and snapshot | | | | | |
| Rate limit and retry guidance | | | | | |
| Problem-details shape | | | | | |
| Webhook signature/freshness/dedupe | | | | | |

## Chronological evidence ledger

Use only these classes: observation, documented contract, calculation, inference, hypothesis, unknown.

| Time | Class | Command/source | Evidence | Proves | Does not prove | Next safe evidence |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |

## Idempotency and retry state machine

```text

```

- Logical operation identity:
- Canonical non-secret intent fields:
- Key scope and owner:
- Key-to-intent mismatch behavior:
- Known rejection branch:
- Committed branch:
- Proven-absent branch:
- Conflict branch:
- Rate-limited branch:
- Transient known-no-effect branch:
- Unknown branch:
- Overall deadline and attempt budget:
- Fleet retry budget:

## Capacity calculation

State units and assumptions before calculating.

| Quantity | Value | Source or assumption |
|---|---:|---|
| Logical operations per second | | |
| Attempts per logical operation | | |
| Attempt rate per second | | |
| Mean and p99 residence time | | |
| Average and configured in-flight | | |
| Payload/response bytes | | |
| Pagination page size | | |
| Webhook delivery and replay rate | | |
| Safety margin | | |

Calculation and interpretation:

## Recovery card

| Field | Decision |
|---|---|
| Authorized actor | |
| Exact operation/resource target | |
| Authoritative state owner | |
| Preconditions | |
| Scope and cohort size | |
| Concurrency | |
| Attempt and elapsed-time budget | |
| Rate-limit behavior | |
| Action for committed | |
| Action for proven absent | |
| Action for unknown | |
| Prior-state preservation | |
| Abort thresholds | |
| Rollback or compensation | |
| End-to-end verification | |

## Verification matrix

| Case | Expected safe behavior | Evidence | Result | Proof limit |
|---|---|---|---|---|
| Malformed JSON | | | | |
| Valid JSON, wrong field type | | | | |
| Unsupported request media type | | | | |
| Unacceptable response media type | | | | |
| Compatible version | | | | |
| Breaking/unknown version | | | | |
| Timeout after commit | | | | |
| Same key, same intent | | | | |
| Same key, different intent | | | | |
| Concurrent same operation | | | | |
| Insert between pages | | | | |
| 429 with Retry-After | | | | |
| Stale signed webhook | | | | |
| Repeated event ID | | | | |
| Sanitized problem response | | | | |
| Unexpected lab artifact | | | | |
| Symlink/out-of-scope cleanup | | | | |
| Final state absence | | | | |

## Production transfer

Chosen CI, Kubernetes, private-cloud, or internal-platform integration:

| Boundary | What changes from the lab | Required evidence/control |
|---|---|---|
| Runtime and artifact | | |
| Workload identity | | |
| Network, DNS, TLS | | |
| Authentication and authorization | | |
| Secrets | | |
| Gateway and rate limit | | |
| Durable idempotency store | | |
| Controller/client retry ownership | | |
| Pagination consistency | | |
| Webhook ingress and replay store | | |
| Telemetry and redaction | | |
| Capacity and backpressure | | |
| Compatibility rollout | | |
| Rollback and accepted-work reconciliation | | |

## Incident communication

- User impact:
- Current mitigation:
- Known committed / absent / unknown / duplicate counts:
- Recovery progress:
- First violated contract or unresolved boundary:
- Contributing conditions:
- Corrective actions and owners:
- Verification window:
- Remaining unknowns:

## Verifier and cleanup evidence

Normal-user `bash verify.sh` output:

```text

```

Reviewer-supplied root-refusal evidence, if available:

```text

```

Final `bash lab.sh check` output:

```text

```

## Self-review

- [ ] I separated characters, bytes, media type, JSON syntax, schema, authorization, mutation, receipt, and user outcome.
- [ ] I did not turn a timeout into failure or success without owner evidence.
- [ ] I kept one logical operation identity across attempts.
- [ ] I named every retry owner, deadline, attempt cap, backoff/jitter rule, and fleet budget.
- [ ] I treated pagination and webhook replay as consistency problems, not formatting details.
- [ ] I gave exact scope, abort, rollback/compensation, and verification for production actions.
- [ ] I stated what the offline verifier cannot prove.
- [ ] I did not claim mastery without reviewer-scored evidence.
