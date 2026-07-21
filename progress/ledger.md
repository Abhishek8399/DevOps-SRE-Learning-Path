# Progress Ledger

Last updated: 2026-07-21
Current state: initial diagnostic in progress

`Not assessed` is intentionally different from L0. L0 will only be assigned when evidence shows that a concept is unfamiliar.

| Skill | Level 0–5 | Last practiced | Evidence | Hints used | Confidence | Recurring error | Next review | Next challenge |
|---|---:|---|---|---:|---:|---|---|---|
| Engineering and systems thinking | Not assessed | — | None | 0 | — | — | After baseline | Initial diagnostic |
| Linux and operating systems | Not assessed | — | None | 0 | — | — | After baseline | [Lesson 1 ENOSPC diagnostic](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) |
| Linux filesystems — exact-path mount mapping and ENOSPC | L0 | 2026-07-21 | Attempt 4: exact-path output shows 48% block use and 100% inode use; interpretation missing; root-shell safety divergence observed | 5 | Not stated | None established; path-name assumption observed once | Same session after hardened rebuild | Rebuild non-root lab, interpret evidence, then unfamiliar transfer |
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
| [Lesson 1 — Linux storage and ENOSPC triage](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) | Paused — validated version 2 awaits learner rebuild | Learner supplied valid capacity output but no interpretation; version 2 passed non-root identity, fixture, safety, and cleanup checks |

Environment prerequisite note: the Ubuntu Docker CLI initially crashed because Docker Desktop’s WSL CLI-tools loop mount returned input/output errors. A Docker Desktop restart restored Windows and Ubuntu client/server checks. See the [recovery runbook](../environment/troubleshooting/docker-wsl-cli-segfault.md). This mentor-operated recovery is not learner competency evidence.

## Completed labs

None.

## Project artifacts

None.

## Incident simulations

| Simulation | Status | Evidence |
|---|---|---|
| Lesson 1 bounded ENOSPC incident | Paused for learner rebuild | Version 2 non-root default validated independently; current learner version 1 container remains root-default and must be replaced |

## Architecture exercises

None.

## Interview scores

None.

## Dangerous misconceptions

None dangerous confirmed. One non-dangerous assumption is under correction: a directory named `cache` was treated as proof of temporary backing storage.

## Weak prerequisite links

Storage stack vocabulary: immediate inode recall succeeded after teaching; exact-path mount mapping and independent command interpretation still require practice.

## Reviews due

Guided practical begins now. First delayed terminology and transfer review scheduled for 2026-07-21.

## Study time

| Period | Planned | Completed |
|---|---:|---:|
| Initial session | Pending learner choice | In progress |

## AI-free practice

| Date | Exercise | Evidence | Result |
|---|---|---|---|
| 2026-07-20 | Initial diagnostic problem 1 | Attempt 3 recalled `inode` after Hint 5 instruction | Correct coached recall; not AI-free or independent evidence |
