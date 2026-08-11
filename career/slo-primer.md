# SLOs: turn reliability into an operating agreement

An SLO is a reliability target for a defined user outcome over a defined window. It is not a decorative percentage and not a promise that every request succeeds.

```text
user journey -> valid events -> SLI calculation -> SLO target
                                      |                 |
                              error budget       action policy
```

## Define the good event first

Start with the user operation: “checkout completes within 800 ms,” not “the API pod is healthy.” Define the valid population, exclusions, success condition, latency boundary, aggregation window, and data freshness. If the query cannot distinguish missing telemetry from success, the SLO is unsafe.

For availability, `good / total` is meaningful only when `total` includes every eligible attempt. For latency, use a distribution or percentile and state whether the measurement is at the edge, service, or dependency. Averages can hide a painful tail.

## Budget arithmetic

If a 30-day availability objective is 99.9%, the allowed unavailability is 0.1% of the valid events or time represented by the chosen SLI. The budget is a decision aid: feature work consumes it; reliability work restores confidence. A target without an owner, window, and policy is only a number.

## Alerts and policy

Page when the current burn predicts material budget exhaustion soon enough to act, and use a slower warning for sustained risk. Pair the alert with scope, query, owner, runbook, and safe containment. Low traffic needs special care: a single failure can look catastrophic, while zero traffic can make a broken measurement look perfect.

```text
fast burn -> page and contain user impact
slow burn -> investigate, schedule reliability work
budget healthy -> normal delivery with reviewable evidence
```

## SLO versus SLA

An SLO is an engineering target. An SLA is an external or contractual commitment with defined consequences. An SLA may use an SLO, but an internal dashboard percentage does not become a contract by being called one.

## Safe local exercise

Use a local CSV of timestamped request outcomes. Write a small script that rejects malformed rows, calculates valid total/good count, reports missing intervals, and computes the objective and remaining budget. Inject a period with no telemetry and prove it is reported as unknown rather than good. Keep the fixture disposable.

## Production triage

1. Confirm the affected journey, SLI definition, freshness, and scope.
2. Recalculate from immutable events or a trusted alternate view.
3. Check burn rate, budget remaining, recent changes, and dependency evidence.
4. Contain the user impact before debating target wording.
5. Record policy decisions and review whether the indicator still represents user value.

## Interview defense

**Question:** “Why is 99.9% not enough?”

**Strong answer:** “The number has no meaning without a user journey, valid population, measurement boundary, window, and policy. I would define the good event, account for missing data and low traffic, calculate the error budget, and connect burn to an owner and safe action.”

**Question:** “The error budget is exhausted. Do you stop all releases?”

**Strong answer:** “I follow the agreed policy and scope. I pause changes that increase the affected risk while allowing emergency fixes and unrelated low-risk work with explicit review. The decision is evidence-based, reversible, and revisited when the budget recovers.”

## Teach-back checkpoint

Define an SLI and SLO for a login journey. State good/total, latency boundary, window, missing-data behavior, error budget, fast-burn action, slow-burn action, and the evidence that would prove recovery.
