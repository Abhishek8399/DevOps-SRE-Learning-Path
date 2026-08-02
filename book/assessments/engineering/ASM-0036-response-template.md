# ASM-0036 independent response template

Use this template only after selecting the independent case and running `bash lab.sh observe input`. Do not inspect the fixture source. Replace prompts with your own evidence; do not invent outputs.

## Candidate and environment

```text
Date and timezone:
Ubuntu release:
Bash version:
Effective UID:
Repository revision or working-tree note:
Lab preflight result:
```

## Raw-first prediction

Complete before any derived observation.

```text
Exact failed operation:
Actor and target:
Expected postcondition:
Actual raw observation:
Local state owner:
Remote state owner:
Coordination boundary:
Likely failure boundary:
Alternative hypothesis 1:
Alternative hypothesis 2:
Evidence that would distinguish them:
Smallest move that preserves evidence:
Unsafe action I will avoid:
Prediction timestamp:
```

## Command transcript

For each command record exact command, relevant output, exit status, and why it was the safest next evidence. Redact no real secret because no real secret should enter this lab.

| Sequence | Command | Relevant output | Status | Question answered |
|---:|---|---|---:|---|
| 1 | `bash lab.sh check` |  |  |  |
| 2 | `bash lab.sh setup` |  |  |  |
| 3 | `bash lab.sh run baseline` |  |  |  |
| 4 | `bash lab.sh inject independent` |  |  |  |
| 5 | `bash lab.sh observe input` |  |  |  |
| 6 | chosen derived view |  |  |  |
| 7 | chosen derived view |  |  |  |
| 8 | chosen derived view |  |  |  |
| 9 | `bash lab.sh recover` |  |  |  |
| 10 | `bash lab.sh verify-operation` |  |  |  |
| 11 | `bash lab.sh cleanup` |  |  |  |
| 12 | `bash lab.sh check` |  |  |  |
| 13 | `bash verify.sh` from a fresh state |  |  |  |

## Evidence ledger

| Evidence | Category: observation, fact, calculation, inference, hypothesis, unknown | Scope and time | Proves | Does not prove | Next evidence |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Include the input and argument counts, pipeline statuses, local and remote state, operation IDs, lock domains, retry classification, baseline comparison, recovery result, operation verification, and cleanup proof.

## Diagrams

Draw two diagrams and provide text alternatives.

### Shell execution path

```text
source -> parse -> expand -> redirect -> execute -> status -> caller decision
```

Mark where evidence shows a healthy or failed boundary.

Text alternative:

### Intent and effect state machine

```text
intent -> attempt -> committed / rejected / unknown -> reconcile -> complete / retry / compensate
```

Add two runners, local lock domains, stable logical identity, remote authoritative state, interruption points, and evidence locations.

Text alternative:

## Diagnosis

```text
Immediate mechanism:
Why this mechanism fits the evidence:
Evidence against the strongest alternative:
Partial state already committed:
Unknown state:
Contributing conditions:
Root cause:
Why a restart or blind retry is unsafe:
Confidence and remaining uncertainty:
```

## Safe move and recovery

```text
Admission or containment step:
Local coordination step:
Authoritative reconciliation query:
Stable operation identity:
Decision for definite commit:
Decision for definite transient rejection:
Decision for unknown outcome:
Candidate publication boundary:
Rollback or compensation boundary:
Cleanup boundary:
```

Explain why a lock path, advisory lock, distributed lease or scheduler control, and remote idempotency key are different mechanisms.

## Implementation outline

Provide reviewed pseudocode or a patch outline, not a production command. Cover:

- explicit subcommand and option parsing;
- required/optional/default values and stable exit statuses;
- quoting, arrays, record framing, and leading-option handling;
- path, owner, mode, symlink, size, and schema validation;
- stdout/stderr/result-artifact contract;
- pipeline status and partial candidate handling;
- secure temporary state and atomic local publication limits;
- trap, TERM/INT, SIGKILL/startup recovery;
- local lock scope and state reread;
- durable logical operation ID and remote status lookup;
- retryable classes, attempts, elapsed deadline, backoff, jitter;
- secret channel and log redaction;
- rollback and cleanup proof.

## Verification matrix

| Case | Injection | Expected status | Expected durable state | Real postcondition | Cleanup proof |
|---|---|---:|---|---|---|
| Normal success | none |  |  |  |  |
| Hostile record values | spaces, newline, wildcard, leading dash, empty |  |  |  |  |
| Producer permanent failure | status 23 |  |  |  |  |
| Partial candidate | fail after write before validation |  |  |  |  |
| Timeout before effect | deadline |  |  |  |  |
| Timeout after effect | drop response after commit |  |  |  |  |
| Same run repeated | same logical ID |  |  |  |  |
| Concurrent run | barrier and second contender |  |  |  |  |
| TERM | signal at each transition |  |  |  |  |
| Abrupt loss | process disappears before cleanup |  |  |  |  |
| Cleanup refusal | unexpected child or ownership mismatch in disposable fixture |  |  |  |  |

State what each test still cannot prove.

## Production transfer

### CI

```text
Runner image and shell:
Working directory and filesystem:
Job retry owner:
Concurrency policy:
Secret injection:
Artifact and log retention:
Durable operation state:
Rollback:
```

### Kubernetes

```text
Pod identity and service account:
PID 1 and signal path:
Ephemeral versus durable state:
Job/controller retry behavior:
Cross-Pod coordination:
Remote idempotency:
Termination grace and abrupt loss:
Real postcondition:
```

## Incident communication

Write a concise update:

```text
Impact:
Known facts:
Unknowns:
Mitigation:
Risk of action:
Next evidence and time:
Recovery proof:
```

Then write a blameless prevention table:

| Prevention | Failed boundary addressed | Owner | Acceptance evidence | Due or review trigger |
|---|---|---|---|---|
|  |  |  |  |  |

## Self-check before review

- [ ] Raw prediction precedes derived evidence.
- [ ] Observation, fact, calculation, inference, hypothesis, and unknown are separate.
- [ ] No root, sudo, package installation, network, fixture edit, or manual path deletion occurred.
- [ ] No blind replay, unbounded retry, `eval`, wildcard cleanup, or fabricated result is recommended.
- [ ] Immediate cause, root cause, and contributing conditions are distinct.
- [ ] Remote timeout remains unknown until authoritative reconciliation.
- [ ] Local and distributed coordination are not confused.
- [ ] Verification checks the modeled operation, repeat, concurrency, interruption, and cleanup.
- [ ] Final preflight proves state absent.
- [ ] Limitations and remaining unknowns are explicit.
