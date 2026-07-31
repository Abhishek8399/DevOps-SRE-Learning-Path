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

## Learner teach-back evidence

- Date: 2026-07-31
- Correct reasoning: `ENOSPC` must not be treated as proof that the whole disk or data-block capacity is full.
- Correct reasoning: a filesystem can have substantial byte capacity available while zero free inodes prevent creation of another file.
- Correct reasoning: an inode holds filesystem-object metadata and is required to create another file.
- First divergence: inode allocation was described as occurring when a filesystem or file is mounted and associated with caches. Mounting attaches a filesystem to the directory tree; an inode is allocated when a new filesystem object is created.
- Missing evidence: the underlying producer of the excessive file population is still unknown; timing of the recent deployment does not prove causation.
- Missing verification: confidence was not stated and the learner has not supplied version 2 non-root `status` and `id` output.
- Assessment: correct central mental model with one mechanism error; guided evidence supports L1 only.

## Mentor-run hardened environment and remediation validation

- Date: 2026-07-31
- Prior learner container: version 1 was stopped with exit code 255.
- Scoped replacement: `lab.sh cleanup` removed only the labeled lesson container; `lab.sh setup` built and started version 2.
- Current learner container: running and healthy with image version 2, UID/GID `65534:65534`, network `none`, and a read-only root filesystem.
- Read-only discovery: `/var` contains 502 files; the affected upload tree contains 500 files and remains at 100% inode use with zero available.
- Separate validation fixture: contained 499 policy-approved `.part` cache fragments.
- Scoped deletion validation: matching fragments decreased from 499 to 0 and inode use decreased from 100% to 3%, with 498 available after the write test.
- Data-safety validation: `.retained-data` remained present.
- Recovery validation: creation of `/var/lib/api/uploads/7f9c.tmp` succeeded after cleanup.
- Validation cleanup: the separate labeled remediation container was removed and absence verified.
- Learner environment preservation: the running learner container was not remediated and remains at 100% inode use for guided practice.
