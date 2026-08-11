# Progressive delivery: change exposure without gambling the service

Progressive delivery is a control system for releasing change. The question is not “did the deployment finish?” It is “how much real user impact have we allowed, what evidence do we have, and when do we stop?”

```text
artifact + contract -> shadow -> canary -> wider traffic -> full exposure
                         |         |             |                |
                     compare    SLI gate      SLO/budget      confirm + observe
                         +------ abort / rollback / roll-forward <+
```

## Start with the change contract

Write down the artifact digest, compatible API/schema assumptions, owner, affected user journey, expected benefit, and abort authority before changing exposure. Rollback is a mechanism, not a promise: a database migration, emitted event, external payment, or cache warm-up may not be reversible. Prefer expand/contract schemas and forward-compatible clients so old and new versions can coexist.

## Choose the smallest safe strategy

* **Feature flag:** code is deployed but behavior is selected at runtime. Require an owner, expiry, and audit trail.
* **Shadow:** copy requests to the candidate without using its response. Protect privacy and prevent downstream side effects.
* **Canary:** send a small, representative slice to the candidate. Require a stable denominator, baseline comparison, minimum sample, and automatic abort threshold.
* **Blue/green:** keep two environments and switch traffic. Fast cutover, but it doubles capacity and does not solve incompatible state.
* **Rolling:** replace instances gradually. Efficient, but old and new versions coexist, so protocol and schema compatibility are mandatory.

Traffic percentage alone is not safety. A 1% cohort can contain all high-value customers, one region, or a rare failure path. Define the cohort by risk and verify that it represents the journey you protect.

## Gates that mean something

Use user-facing indicators first: successful requests, correctness, latency percentiles, queue age, and dependency saturation. Compare candidate and baseline over the same window and traffic mix. Set a minimum sample and hold time; otherwise noise becomes an automated rollback.

```text
candidate errors/latency/correctness breach budget
OR dependency saturation threatens existing traffic
        => freeze exposure, page owner, preserve evidence, recover
```

Do not gate only on CPU, replica count, or deployment status. Those are diagnostic signals, not proof that the user journey works.

## Safe local exercise

Create two tiny HTTP handlers or scripts with the same contract, then make the candidate fail one controlled request class. Route a deterministic cohort (a header or hash) to the candidate. Record baseline and candidate request count, errors, latency, and the exact abort decision. If no local router exists, model the routing table and replay a saved request set; label it as a simulation.

```bash
cohort="checkout-test-42"
bucket=$(printf '%s' "$cohort" | sha256sum | cut -c1-2)
if [ $((16#$bucket)) -lt 26 ]; then echo candidate; else echo baseline; fi
```

Explain why the cohort is representative, what evidence triggers abort, what state cannot be rolled back, and how recovery will be verified.

## Triage when a canary is bad

1. Freeze exposure; do not increase traffic while investigating.
2. Separate candidate-only symptoms from shared dependency or cohort effects.
3. Compare artifact/config/schema, request mix, logs, traces, saturation, and recent flags.
4. Choose rollback or roll-forward based on state compatibility and blast radius.
5. Verify the user journey after recovery and preserve the timeline and evidence.

## Interview defense

**Question:** “How would you design a canary?”

**Strong answer:** “I define the user journey and compatible contract, select a representative low-risk cohort, publish the immutable artifact identity, compare candidate and baseline SLIs with minimum sample and hold time, and give an owner authority to freeze and recover. I gate on correctness, errors, latency, and dependency saturation—not deployment success—and document rollback limits for stateful changes.”

**Question:** “Why did rollback not fix the incident?”

**Strong answer:** “Rollback restored code but not necessarily schema, emitted side effects, cached data, or external state. I would fence further writes, establish the correct authority, reconcile or roll forward compatibly, and validate the end-user journey rather than trusting the version label.”

**Question:** “When is blue/green worse than a canary?”

**Strong answer:** “Blue/green needs duplicate capacity and can expose every user to a bad state at once. A canary is better when representative traffic and trustworthy gates exist; blue/green is attractive when fast cutover and environment isolation matter more than gradual exposure.”

## Teach-back checkpoint

Design a release for a stateful API. Name the artifact and compatibility contract, cohort, strategy, four gates, sample/hold rule, abort owner, rollback limitation, and post-recovery proof. Replace “we will watch it” with a measurable signal and explicit decision.
