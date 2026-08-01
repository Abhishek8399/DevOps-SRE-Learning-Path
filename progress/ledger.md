# Progress Ledger

Last updated: 2026-08-02
Current state: initial diagnostic in progress

`Not assessed` is intentionally different from L0. L0 will only be assigned when evidence shows that a concept is unfamiliar.

| Skill | Level 0–5 | Last practiced | Evidence | Hints used | Confidence | Recurring error | Next review | Next challenge |
|---|---:|---|---|---:|---:|---|---|---|
| Engineering and systems thinking | Not assessed | — | None | 0 | — | — | After baseline | Initial diagnostic |
| Linux and operating systems | Not assessed | — | None | 0 | — | — | After baseline | [Lesson 1 ENOSPC diagnostic](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) |
| Linux filesystems — exact-path mount mapping and ENOSPC | L1 | 2026-08-02 | Learner independently recalled that ENOSPC can mean block or inode exhaustion and selected `df -hT` and `df -i`; precise inode-record wording was reinforced; learner remediation evidence is pending | 5 | Not stated | Earlier path-name assumption and mounting/inode conflation have not recurred; exact command syntax was lightly corrected | Immediate practical remediation | Identify the approved inode population, remediate safely, verify recovery, then complete an unfamiliar transfer |
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
| 2026-08-01 | Use a lightweight local website backed by Git as the learning interface | Learner requested a durable, visual, documentation-like experience; repository remains the evidence source of truth and browser localStorage is scratch space only |

Machine readiness evidence is recorded in [../environment/local-baseline.md](../environment/local-baseline.md). These decisions do not establish competency.

## Active assessment work

| Exercise | Status | Evidence |
|---|---|---|
| [Lesson 1 — Linux storage and ENOSPC triage](../phase-01-foundations/lesson-01-linux-storage-enospc/README.md) | Active — guided remediation | Learner now recalls the block-versus-inode diagnosis and exact commands; hardened version 2 remains the practical gate; learner remediation evidence is pending |

Environment prerequisite note: the Ubuntu Docker CLI initially crashed because Docker Desktop’s WSL CLI-tools loop mount returned input/output errors. A Docker Desktop restart restored Windows and Ubuntu client/server checks. See the [recovery runbook](../environment/troubleshooting/docker-wsl-cli-segfault.md). This mentor-operated recovery is not learner competency evidence.

## Completed labs

None.

## Project artifacts

| Artifact | Status | Evidence |
|---|---|---|
| [Local learning cockpit](../learning-cockpit/README.md) | Volume 1 contains five detailed Linux lessons; not learner competency evidence | On 2026-08-02 ESLint and production build passed; loopback HTTP returned 200 and rendered the index, all five lesson titles, guided labs, optional self-checks, and interview prompts |
| [Systems Reliability Field Manual reader](../learning-cockpit/README.md) | Routed, Ubuntu-first reader architecture and safety standard implemented; not learner competency evidence | On 2026-08-02 ESLint and production build passed; six local routes returned HTTP 200, invalid lessons returned 404, key night-mode color pairs measured 5.77:1 or higher, and bounded storage, permissions, process, and loopback-network labs passed on Ubuntu 24.04 with cleanup proof |
| [Offline search and device-local reading desk](../learning-cockpit/README.md) | Five-lesson search, bookmarks, recent/resume history, private reading markers, and command-copy feedback implemented; reading state is not learner competency evidence | Commit `836c29e`; `VER-045` through `VER-057` record storage-safety tests, lint, typecheck, content validation, production build, route/payload/listener checks, staged safety review, commit, push, and revision parity |

## Incident simulations

| Simulation | Status | Evidence |
|---|---|---|
| Lesson 1 bounded ENOSPC incident | Active — awaiting learner remediation | Version 2 is running as UID/GID 65534; current learner fixture remains at 100% inode use; separate remediation validation passed |

## Architecture exercises

None.

## Interview scores

None.

## Dangerous misconceptions

None dangerous confirmed. One non-dangerous assumption is under correction: a directory named `cache` was treated as proof of temporary backing storage.

## Weak prerequisite links

Storage diagnosis vocabulary is now recalled. Exact-path mount mapping, safe population selection, and end-to-end remediation still require learner-operated evidence.

## Reviews due

Hardened-lab remediation is due in the current session. Schedule delayed reviews only after the practical gate succeeds.

## Study time

| Period | Planned | Completed |
|---|---:|---:|
| Initial session | Pending learner choice | In progress |

## AI-free practice

| Date | Exercise | Evidence | Result |
|---|---|---|---|
| 2026-07-20 | Initial diagnostic problem 1 | Attempt 3 recalled `inode` after Hint 5 instruction | Correct coached recall; not AI-free or independent evidence |
