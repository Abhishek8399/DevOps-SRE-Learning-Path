# ASM-0018 independent response template

This is a blank evidence structure, not an answer key. It contains no transfer
values, diagnosis, hidden hint, score, or model solution. A reviewer compares
original evidence with `ASM-0018.json`.

## Independence declaration

- Attempt date:
- Help, hints, tools, fixture source, prior solutions, or generated files seen:
- I did not inspect `fixtures/isolation_model.py` or receive a diagnosis before submission: yes / no
- If no, I classify this run as guided practice: yes / no

## Environment and safety card

- Ubuntu release and kernel:
- WSL or virtualization boundary:
- Bash and Python versions:
- Effective UID:
- cgroup filesystem branch:
- Repository and lab scope:
- Network/port/cloud boundary:
- Exact resources changed by the lab:
- Stop conditions:
- Supported recovery command:
- Supported cleanup proof:
- Sanitization performed:

## Operation and identity

- Exact modeled operation:
- Expected result:
- Observed result:
- Workload ID:
- Instance ID:
- Namespace-view ID:
- cgroup ID:
- Why these records are or are not comparable:
- Recovery target:

## Boundary diagram

Draw and label:

```text
modeled user operation
        -> application/process identity
        -> namespace view
        -> cgroup hierarchy and controller
        -> adjacent identity/security controls
        -> virtual runtime outcome
```

For every arrow name the state owner, evidence point, unit, time scope, trust
boundary, and first observed abnormal transition.

## Evidence classification

| Field | Baseline | Current | Type | Unit | Scope / identity | Collection point | Valid delta? | Proves | Does not prove | Next evidence |
|---|---:|---:|---|---|---|---|---|---|---|---|
|  |  |  | identity / config / gauge / cumulative counter / outcome / status |  |  |  |  |  |  |  |

## Counter continuity and reset check

- Counter object identity:
- Baseline collection point:
- Current collection point:
- Identity continuity evidence:
- Reset or recreation risk:
- Calculation:
- Interpretation limit:

## Facts, observations, and unknowns

| Category | Statement | Source | Confidence | Boundary / limitation |
|---|---|---|---|---|
| Supplied fact |  |  |  |  |
| Local observation |  |  |  |  |
| Assumption |  |  |  |  |
| Inference |  |  |  |  |
| Unknown |  |  |  |  |

## Ranked mechanism hypotheses

| Rank | Mechanism, not component name | Supporting evidence | Contradicting evidence | Prediction | Falsifier | Safest next evidence |
|---:|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  |
| 2 |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |

## First abnormal boundary

- Matched healthy input:
- First abnormal output:
- State owner:
- Evidence:
- Why this is "first observed" rather than guaranteed first causal event:
- Why the loudest error, host-like capacity, status word, or recent change is insufficient:

## Recovery and verification

- Recovery command and result:
- Recovery scope:
- Verification command and modeled operation:
- Correct and durable modeled result:
- Duplicate/lost result check:
- Remaining causal uncertainty:
- Why fixture restoration is not a production remediation:

## Cleanup evidence

- Cleanup command and result:
- Following check and `state=absent` evidence:
- Any refusal:
- If refused, state preserved and escalation path:

## Production transfer

- Chosen Docker, Kubernetes, systemd, CI runner, or private-cloud scenario:
- User operation and recovery objective:
- Workload/container/process identities:
- Namespace owner views:
- cgroup and ancestor owners:
- Capabilities/seccomp/LSM/filesystem boundary:
- Runtime/orchestrator evidence:
- Two-sample counter method and reset handling:
- Smallest reversible remediation and authorization:
- Success, abort, rollback, and operation/data reconciliation:
- Reliability and observability consequence:
- Security consequence:
- Capacity and cost consequence:
- Fixture facts that do not transfer:
