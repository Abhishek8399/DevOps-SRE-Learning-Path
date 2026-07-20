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
