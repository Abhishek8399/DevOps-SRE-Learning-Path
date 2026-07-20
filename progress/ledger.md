# Progress Ledger

Last updated: 2026-07-20
Current state: initial diagnostic in progress

`Not assessed` is intentionally different from L0. L0 will only be assigned when evidence shows that a concept is unfamiliar.

| Skill | Level 0–5 | Last practiced | Evidence | Hints used | Confidence | Recurring error | Next review | Next challenge |
|---|---:|---|---|---:|---:|---|---|---|
| Engineering and systems thinking | Not assessed | — | None | 0 | — | — | After baseline | Initial diagnostic |
| Linux and operating systems | Not assessed | — | None | 0 | — | — | After baseline | [Lesson 1 ENOSPC diagnostic](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) |
| Linux filesystems — exact-path mount mapping and ENOSPC | L0 | 2026-07-20 | Checkpoint 1: learner reported no current model; no reasoning or command evidence submitted | 5 | Not stated | None established from one observation | Same-session guided transfer; 2026-07-21 if successful | Coached lab, then unfamiliar closed-notes transfer |
| Networking, DNS, HTTP, and PKI | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Git and software delivery | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Scripting, testing, and error handling | Not assessed | — | None | 0 | — | — | After baseline | Pending automation exercise |
| CI/CD and GitOps | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Containers | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Cloud engineering and IAM | Not assessed | — | None | 0 | — | — | After baseline | Assess provider-neutral foundations locally; provider choice deferred |
| Infrastructure and configuration as code | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Kubernetes | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Observability | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| SRE and production operations | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Databases, queues, caches, and data reliability | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Distributed systems | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Security and DevSecOps | Not assessed | — | None | 0 | — | — | After baseline | Pending AI audit |
| Platform engineering | Not assessed | — | None | 0 | — | — | After baseline | Pending diagnostic |
| Architecture and technical leadership | Not assessed | — | None | 0 | — | — | After baseline | Pending SCALE exercise |
| AI-native DevOps, AIOps, MLOps, and LLMOps | Not assessed | — | None | 0 | — | — | After baseline | Pending AI audit |

## Environment decisions

| Date | Decision | Evidence |
|---|---|---|
| 2026-07-20 | Use WSL 2 Ubuntu 24.04 as the primary local lab | Learner approval plus read-only environment verification |
| 2026-07-20 | Permit installation of exercise-required local dependencies | Learner authorization; no installation performed during baseline |
| 2026-07-20 | Exclude online cloud resources | Learner constraint; use local simulation, emulation, validation, and design exercises |
| 2026-07-20 | Use Docker Desktop through Ubuntu WSL integration | Local client/server and Compose queries succeeded; workload execution remains unverified |

Machine readiness evidence is recorded in [../environment/local-baseline.md](../environment/local-baseline.md). These decisions do not establish competency.

## Active assessment work

| Exercise | Status | Evidence |
|---|---|---|
| [Lesson 1 — Linux storage and ENOSPC triage](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) | Guided remediation — Checkpoint 1 not demonstrated | Learner disclosed no current answer; complete guided instruction at Hint 5 supplied; confidence not stated |

## Completed labs

None.

## Project artifacts

None.

## Incident simulations

None.

## Architecture exercises

None.

## Interview scores

None.

## Dangerous misconceptions

None confirmed. Self-reported confidence has not yet been calibrated against performance.

## Weak prerequisite links

Filesystem allocation model: path-to-mount mapping and independent block/inode capacity. Observed 2026-07-20; guided retry pending.

## Reviews due

Same-session guided retry for filesystem allocation. Schedule 2026-07-21 review only if the retry succeeds.

## Study time

| Period | Planned | Completed |
|---|---:|---:|
| Initial session | Pending learner choice | In progress |

## AI-free practice

| Date | Exercise | Evidence | Result |
|---|---|---|---|
| 2026-07-20 | Initial diagnostic problem 1 | No technical answer or confidence submitted; learner requested detailed help | Knowledge gap identified; guided retry active |
