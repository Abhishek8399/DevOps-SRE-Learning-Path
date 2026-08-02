# FRAME: an evidence-driven incident worksheet

FRAME is the field manual's repeatable troubleshooting loop:

```text
Frame -> Retrieve -> Analyze -> Make a safe move -> Evaluate and encode
```

Use it when a production signal is ambiguous, when several systems could own the failure, or when the first tempting action carries risk. FRAME is not a promise that five headings will reveal a root cause. It is a discipline for making uncertainty visible, gathering evidence from the correct boundary, restoring service safely, and preserving what the team learns.

The complete teaching chapter is [`LES-0008`](../volumes/00-start-safely/LES-0008-evidence-driven-troubleshooting/lesson.md). This worksheet is deliberately reusable across Linux, networking, CI/CD, Kubernetes, data, cloud, and application incidents.

## The non-negotiable evidence vocabulary

| Label | Meaning | Safe wording |
|---|---|---|
| Fact | A supplied or directly observed statement whose source, scope, and time are named | “The exact-path `df -i` sample reported zero available inodes at 10:14 UTC.” |
| Assumption | Something currently treated as true so work can continue, but not yet verified | “We assume both dashboards cover the same pods and five-minute interval.” |
| Inference | A bounded conclusion supported by stated facts | “Accepted work exceeded completions during the aligned interval, so measured backlog should have grown.” |
| Hypothesis | A falsifiable explanation that may be wrong | “A full connection pool is limiting useful completions.” |
| Unknown | A material unanswered question | “We do not yet know whether retries are counted as new arrivals.” |
| Documented claim | Behavior stated by an identified manual, specification, or upstream source | “The cited manual defines this field as a cumulative counter.” |
| Local observation | Behavior seen in the named environment and version | “Ubuntu 24.04 in this lab returned exit status 1 for the no-match branch.” |
| Unverified claim | A statement awaiting a named source or experiment | “VERIFY: determine whether this exporter resets the counter after restart.” |

Never promote an assumption to a fact because it sounds likely. Never promote correlation to causation because it occurred after a deploy. Never call a component the root cause when the evidence establishes only a symptom at that component.

## Proof-boundary sentence

For every important signal, write both halves:

> This proves ___ for ___ scope during ___ interval. It does not prove ___.

Examples:

- “A successful TCP connection proves one connection reached the selected address and port. It does not prove the correct application handled the request.”
- “A service manager reports the unit active. That proves its state machine reached `active`; it does not prove the user operation succeeds.”
- “The canary completed after the configuration rollback. That supports the rollback as a restoration step for the canary cohort; it does not yet prove the whole fleet is recovered or the causal chain is complete.”

## Prediction rule

Before an experiment, record:

1. the hypothesis being tested;
2. the exact evidence expected if it is supported;
3. the exact evidence expected if it is weakened or rejected;
4. the affected scope and maximum duration;
5. the abort condition;
6. the rollback or recovery action;
7. the real user operation that will verify restoration.

An experiment without a prediction is easy to reinterpret after the result. An experiment without an abort condition is an uncontrolled change.

## Blank incident worksheet

Copy the section below into a sanitized incident record. Do not paste credentials, private URLs, customer data, employer identifiers, access tokens, or unrestricted production logs.

---

### Incident identity

- Record ID:
- Date and timezone:
- Author or incident role:
- Environment and namespace:
- Sanitization performed:
- AI, external help, or hints used:

### F — Frame the problem

#### User or workload operation

- Who initiates the operation?
- What exact outcome should succeed?
- What is observed instead?
- What is the recovery target?

#### Scope and impact

- First known affected time:
- Affected and healthy cohorts:
- User, data, security, cost, or delivery impact:
- Current blast radius:
- Potential blast radius if the next action is wrong:

#### Constraints

- Actions currently forbidden:
- Required authorization:
- Data or work that must be preserved:
- Maximum acceptable experiment scope and duration:
- Communication or escalation deadline:

#### Recent changes

| Time | Change | Scope | Source of this fact | Correlation only, or causal evidence? |
|---|---|---|---|---|
|  |  |  |  |  |

### R — Retrieve evidence

#### Facts, assumptions, inferences, and unknowns

| ID | Class | Statement | Source | Scope and interval | Confidence | What would verify or falsify it? |
|---|---|---|---|---|---:|---|
| E1 | Fact / Assumption / Inference / Unknown |  |  |  |  |  |

#### Operation or state path

```text
[initiator]
    -> [admission]
    -> [queue or handoff]
    -> [worker]
    -> [dependency or durable state]
    -> [published outcome]
```

Mark on the diagram:

- state owner at every stage;
- request, job, trace, revision, or object identity;
- healthy comparison boundary;
- evidence point and clock source;
- trust, host, container, cluster, network, tenant, and failure-domain boundary;
- the first observed abnormal transition, not merely the loudest symptom.

#### Evidence log

| Order | Question | Command or source | Risk and scope | Prediction | Observation | Proves | Does not prove | Next evidence |
|---:|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  |  |  |

Preserve raw evidence where policy allows. Record time source, timezone, query filters, sampling window, aggregation, units, counter type, and any missing data. Do not silently rewrite an observation after forming a hypothesis.

### A — Analyze competing hypotheses

| Rank | Hypothesis | Mechanism | Supporting evidence | Contradicting evidence | Falsification test | Risk if wrong |
|---:|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |

Quality checks:

- At least two hypotheses must be able to explain the current facts.
- Each hypothesis must name an owner and a mechanism, not only a component.
- Each must have evidence that could reject it.
- Rank using impact, likelihood, evidence strength, and cost or risk of the next test.
- Re-rank after each material observation. Do not defend the first guess.

#### Causal chain under review

```text
trigger or condition
  -> first abnormal mechanism
  -> propagation or amplification
  -> failed operation
  -> user-visible impact
```

Label every arrow as observed, documented, inferred, or still hypothetical.

### M — Make the safest informative move

- Selected hypothesis:
- Selected move:
- Why this move is more informative or safer than the alternatives:
- Exact target, identity, namespace, and cohort:
- Risk class:
- Required authorization and approver:
- Maximum scope and duration:

#### Prediction and control envelope

| Item | Recorded before execution |
|---|---|
| Supported-result evidence |  |
| Rejected-result evidence |  |
| Success criterion |  |
| Abort criterion |  |
| Rollback trigger |  |
| Rollback or recovery action |  |
| Evidence preserved before mutation |  |
| Monitoring during the move |  |

Do not widen the move because the first result is inconvenient. Stop at the declared boundary, preserve the result, and return to Analyze.

### E — Evaluate and encode

#### Result and confidence

- Exact observed result:
- Hypothesis supported, weakened, rejected, or unresolved:
- Confidence before the move (0–100%):
- Confidence after the move (0–100%):
- Most important remaining unknown:

#### Restoration verification

| Boundary | Verification | Expected result | Observed result | Time window | Owner |
|---|---|---|---|---|---|
| Component |  |  |  |  |  |
| Dependency |  |  |  |  |  |
| Real user/workload operation |  |  |  |  |  |
| Backlog, retries, errors, or stale state |  |  |  |  |  |

“The process restarted” is not a complete recovery test. Verify the real operation and ensure queued, retried, failed, duplicated, or stale work is reconciled.

#### Cleanup and rollback proof

- Exact changed resources:
- Cleanup or rollback command/path:
- Proof that temporary files, processes, sockets, containers, namespaces, or configuration are absent or restored:
- Artifacts intentionally retained and why:

#### Prevention

| Failure or detection gap | Preventive or detective action | Owner | Due date | Verification method | Rollback if action causes harm |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Prefer actions that change the system: a tested guard, clearer ownership, bounded retry, validation, a useful signal, a safer deploy, restored capacity, or a rehearsed recovery path. “Be careful” and “monitor more” are not complete prevention actions.

#### Knowledge encoded

- Timeline with evidence sources:
- Immediate mechanism:
- Contributing conditions:
- Why detection or containment was insufficient:
- Runbook or automation changed:
- Test or alert added:
- Follow-up verification date:
- Known limitations:

---

## Review boundary

A completed worksheet is an incident artifact. It is not automatically proof of independent skill. A reviewer must examine evidence quality, safety, causal reasoning, verification, communication, and whether assistance changed the independence of the attempt before any competency record changes.
