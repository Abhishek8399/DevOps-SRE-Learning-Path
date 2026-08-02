# ASM-0015 independent response template

This is a blank learner-evidence structure, **not** an answer key. It contains
no diagnosis, expected metric ranking, hidden hint, score, or model solution.
A reviewer evaluates the original evidence against `ASM-0015.json`.

## Independence declaration

- Attempt date:
- Evidence package or disposable environment identity:
- Help, hints, tools, or prior solutions seen:
- I confirm that I did not read another learner's diagnosis or request a model solution before submission: yes / no

## Safety and provenance card

- Ubuntu release and kernel:
- Virtualization or container boundary:
- Effective UID:
- Evidence source and integrity identifier:
- Exact path and workload scope:
- Sample start/end and clock:
- Commands and versions:
- Mutations performed (expected: none unless separately authorized):
- Stop conditions:
- Sanitization performed:
- Cleanup or no-change proof:

## User operation and impact

- Operation:
- Expected result and latency objective:
- Observed result:
- Affected scope:
- Healthy comparison:
- Recovery target:
- Unknowns:

## Path diagram

Draw the application, system-call, page-cache, filesystem, logical-device,
parent-device, and lower-storage boundaries. Label owner, state, identity,
evidence point, unit, failure domain, and first observed divergence.

## Normalized evidence

| Observation | Source | Scope / identity | Interval | Unit / statistic | Value | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---:|---|---|---|
|  |  |  |  |  |  |  |  |  |

## Baseline-versus-incident comparison

| Boundary | Healthy | Affected | Comparable? Why? | Interpretation limit |
|---|---:|---:|---|---|
| User operation |  |  |  |  |
| Cache / memory |  |  |  |  |
| Filesystem / mount |  |  |  |  |
| Logical device |  |  |  |  |
| Parent / lower layer |  |  |  |  |
| Process or cgroup |  |  |  |  |

## Ranked hypotheses

| Rank | Mechanism | Supporting evidence | Contradicting evidence | Falsifier | Safest next observation |
|---:|---|---|---|---|---|
| 1 |  |  |  |  |  |
| 2 |  |  |  |  |  |
| 3 |  |  |  |  |  |
| 4 |  |  |  |  |  |

## Queueing calculation or refusal

- Request definition:
- Arrival/completion rate and interval:
- Average time and interval:
- Calculated average in-flight work:
- Steady-state and scope assumptions:
- Cross-check against observed queue/concurrency:
- If calculation is invalid, exact reason:

## Bounded experiment decision

- Run no experiment / run one experiment:
- Hypothesis and prewritten prediction:
- Authorization:
- Maximum path/process/time/resource scope:
- Control comparison:
- Support result:
- Rejection result:
- Abort condition:
- Rollback and evidence preservation:
- Correctness condition:

## Recovery and verification

| Check | Expected | Observed | Evidence source | Remaining unknown |
|---|---|---|---|---|
| Real read operation |  |  |  |  |
| Correct result |  |  |  |  |
| Tail latency |  |  |  |  |
| Errors / timeouts / retries |  |  |  |  |
| Queue / lower layer |  |  |  |  |
| Healthy control |  |  |  |  |
| Recurrence window |  |  |  |  |

## Production transfer

- Chosen environment:
- Method that transfers:
- Fixture facts that do not transfer:
- New owners and hidden layers:
- Reliability and recovery trade-off:
- Security and evidence handling:
- Observability gap:
- Capacity and cost trade-off:
