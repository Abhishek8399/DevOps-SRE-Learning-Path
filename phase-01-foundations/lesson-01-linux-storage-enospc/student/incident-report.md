# Lesson 1 FRAME Incident Report

Date:

AI or external help used: none / describe exactly

Hints used: 0

## F — Frame the problem

User impact:

Scope and blast radius:

Expected behavior:

Known changes and timing:

Safety constraints:

## R — Retrieve evidence

### Known facts

### Assumptions

### Evidence collected

| Order | Read-only command | Prediction recorded before execution | Sanitized observation | What it confirms or falsifies |
|---:|---|---|---|---|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |

## A — Analyze hypotheses

| Rank | Hypothesis | Supporting evidence | Contradicting evidence | Next falsification test |
|---:|---|---|---|---|
| 1 |  |  |  |  |
| 2 |  |  |  |  |
| 3 |  |  |  |  |

## M — Make the safest informative move

Proposed next move:

Required authorization:

Predicted result:

Success criteria:

Abort criteria:

Recovery or rollback:

## E — Evaluate and encode

Diagnosis and causal chain:

System and user-visible recovery verification:

Prevention or detection improvement:

## Confidence calibration

Confidence before evidence (0–100%):

Confidence after evidence (0–100%):

Most important missing evidence:

## Teach-back

Explain pathname resolution, mounts, allocation resources, and this failure in plain language. Include one analogy and where the analogy breaks.

## Mentor environment verification

- Date: 2026-07-20
- Learner-supplied setup evidence: image build completed and `incident_ready=true` was returned for `devops-sre-p1-enospc`.
- Learner-supplied status evidence: container running, health healthy, network mode `none`, and read-only root enabled.
- Mentor fixture verification: passed with the intended bounded block and inode conditions.
- Safety verification: expected training label, running state, readiness marker, disabled networking, read-only root, all capabilities dropped, and bounded tmpfs configuration confirmed.
- Evidence classification: valid environment and fixture evidence; it does not establish learner diagnosis or mastery.

The student-authored FRAME sections above remain intentionally blank until the learner submits predictions and observations.

## Mentor safety observation

- Date: 2026-07-21
- Learner-supplied capacity evidence: exact-path block use 48% with 8.4 MiB available; inode use 100% with zero available.
- Learner-supplied identity evidence: the interactive shell reported UID/GID 0.
- Missing learner evidence: no written interpretation or confidence was submitted with the command output.
- Mentor verification: `lab.sh shell` explicitly requests UID/GID 65534, but the version 1 image and container default user were root, so alternative exec paths could open a root shell.
- Classification: lab defense-in-depth gap plus a missed safety boundary; the exact shell entry path was not evidenced.
- Immediate control: no write or delete action is permitted in the root shell.

The lab is paused until version 2 is rebuilt with an unprivileged image and container default.

### Mentor remediation verification

- Version 2 image build: passed from the pinned BusyBox digest with runtime networking disabled.
- Separate validation container: healthy with default UID/GID `65534:65534`, network `none`, read-only root, all capabilities dropped, and `no-new-privileges` enabled.
- Fixture verification: passed at 48% block use, 100% inode use, and runtime UID 65534.
- Cleanup verification: the separate validation container was removed; the learner version 1 container was left untouched.
- Remaining action: exit the learner root shell, run the scoped cleanup, and rebuild through `lab.sh setup`.
