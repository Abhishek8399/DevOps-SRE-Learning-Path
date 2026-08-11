# Performance engineering: measure before tuning

Performance work starts with a user outcome and a controlled comparison. A faster benchmark that changes the workload, cache state, correctness, or cost is not evidence of improvement.

```text
user SLI -> workload contract -> baseline -> profile -> hypothesis -> bounded change -> compare/rollback
    |            |                 |           |            |              |              |
 latency     rate/size/mix       repeat      hotspot     cause         canary         proof
```

## Define the workload

Record request rate, concurrency, payload mix, cache state, data size, dependency behavior, warm-up, duration, and success criteria. Use percentiles and error rate, not just averages. Separate CPU, memory, I/O, network, queue, lock, and dependency time.

## Profile before guessing

A profile identifies where time or resources were spent; it does not explain user value by itself. Correlate profiles with traces, logs, saturation, and the workload. Sampling, clock overhead, and observer effect matter. Preserve the exact build, flags, machine, and dataset.

## Capacity and performance knees

Increase load gradually and find where latency, queue age, or error rate bends sharply. Capacity is bounded by the first constrained resource or dependency. A local microbenchmark does not prove production capacity; use it to test a mechanism, then validate at the relevant boundary.

## Safe tuning

Change one variable, define a rollback threshold, canary the smallest scope, and soak long enough to expose cache, leak, or queue effects. Record ownership and persistence of every tunable. Never trade correctness, security, or recovery for an unmeasured benchmark win.

## Safe local exercise

Run a deterministic local workload against a fixture server. Capture baseline latency percentiles, throughput, errors, CPU, and memory. Change one bounded parameter, repeat with the same dataset, compare confidence and cost, then restore the fixture. Do not claim production capacity.

## Triage sequence

1. Confirm user impact, workload, build, and comparison baseline.
2. Locate the first saturated or delayed boundary.
3. Profile and correlate; distinguish queueing, contention, I/O, and dependency time.
4. Apply one reversible change with a canary and abort threshold.
5. Compare SLI, correctness, capacity headroom, cost, and long-run behavior.

## Interview defense

**Question:** “How do you investigate a latency regression?”

**Strong answer:** “I define the affected journey and compare the same workload/build across time. I inspect percentile latency, errors, saturation, queues, dependencies, recent changes, and profiles, then test the smallest hypothesis. I canary and roll back based on user SLI, not a single CPU graph.”

**Question:** “Why is a benchmark misleading?”

**Strong answer:** “It may change data, cache, concurrency, warm-up, correctness checks, or environment. I preserve the workload contract, repeat runs, measure variance and percentiles, and correlate the result with resource and user evidence.”

## Teach-back checkpoint

Design a performance test. State workload, baseline, percentile objective, observer effect, bottleneck evidence, one change, rollback threshold, cost guard, and proof that correctness remained intact.
