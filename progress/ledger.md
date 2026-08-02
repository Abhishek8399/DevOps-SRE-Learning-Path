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
| [Local learning cockpit](../learning-cockpit/README.md) | The canonical worktree exposes twenty-five routed lesson identities across Volumes 00 through 03: five legacy and twenty structured; artifact publication is not learner competency evidence | The generated corpus contains 20 lessons, 60 assessments, and 163 references; exact project validation is recorded separately, and manual browser interaction remains unclaimed |
| [Reliability Atlas reader](../learning-cockpit/README.md) | Routed, Ubuntu-first reader serves twenty-five lessons across four volumes, including twenty schema-backed lessons; artifact publication is not learner competency evidence | Canonical `LES-0025` is registered at `/book/engineering/ci-platform-operations`; no reading state, mentor-operated verifier, local teaching engine, or published artifact becomes mastery or provider-acceptance evidence |
| [Offline search and device-local reading desk](../learning-cockpit/README.md) | Twenty-five-result cross-volume catalog/search, bookmarks, recent/resume history, private reading markers, command-copy feedback, and additive state integration are authored; reading state and artifact publication are not learner competency evidence | Canonical `LES-0001` through `LES-0025` search and the additive seventeen-lesson state migration are represented in the generated allowlists; real-browser persistence, keyboard, and clipboard checks remain unavailable |
| [Structured content publishing contract](../book/schema/README.md) | Strict lesson, assessment, reference, identity, path, safety, and relationship validation covers twenty structured lessons, 60 assessments—forty complete-answer records and twenty answer-isolated transfers—and 163 references; artifact publication is not learner competency evidence | The canonical IDs now continue through `LES-0025`, `ASM-0060`, and `REF-0163`; the next unused IDs are `LES-0026`, `ASM-0061`, and `REF-0164` |
| [LES-0006 — Boot, kernel, systemd, and journal](../book/volumes/01-linux-systems/LES-0006-boot-kernel-systemd-journal/lesson.md) | Schema-backed substantive draft published as canonical `LES-0006` / alias `V01-L06`; artifact publication is not learner competency evidence | Commit `24201bb`; 18 required sections, 3 diagrams, 12 read-only command cards, 1 guided lab, 2 incidents, 2 complete-answer assessments, 1 answer-isolated transfer assessment, and 8 primary references passed content, schema, reader, build, independent-audit, and Ubuntu 24.04 read-only command checks |
| [LES-0007 — Systems thinking: state, queues, dependencies, and failure domains](../book/volumes/00-start-safely/LES-0007-systems-thinking/lesson.md) | Schema-backed substantive draft added as canonical `LES-0007` / alias `V00-L01`; artifact publication and mentor execution are not learner competency evidence | Commit `817bb60`; content/schema/reader/build checks passed, and the bounded Ubuntu 24.04 verifier passed before cleanup confirmed state absent; this is project evidence, not a completed learner lab |
| [LES-0008 — Evidence-driven troubleshooting: FRAME, hypotheses, and safe moves](../book/volumes/00-start-safely/LES-0008-evidence-driven-troubleshooting/lesson.md) | Schema-backed `substantive-draft` as canonical `LES-0008` / alias `V00-L02`, with reusable FRAME worksheet, answer-isolated `ASM-0009`, bounded Ubuntu virtual incident lab, and advisory prerequisite navigation; no access lock or mastery inference | Content/schema/reader/lint/type/build/route/link checks and mentor-operated `REL-LAB-014` pass; ShellCheck, concurrency, browser QA, formal acceptance, learner execution, transfer review, and mastery remain pending |
| [LES-0024 — CI/CD architecture](../book/volumes/03-engineering-delivery/LES-0024-ci-cd-architecture/lesson.md) | Schema-backed `substantive-draft` as canonical `LES-0024` / alias `V03-L09`, with three assessments, eight references, and a guarded local pipeline model; artifact publication and mentor execution are not learner competency evidence | Commit `a093474`; clean content/registry/reader/schema/lint/type/build gates, Ubuntu 24.04 verifier, root refusal, cleanup, and current HTTP audit pass; formal acceptance, learner execution, transfer review, and mastery remain pending |
| [LES-0025 — CI platform operations](../book/volumes/03-engineering-delivery/LES-0025-ci-platform-operations/lesson.md) | Schema-backed `substantive-draft` as canonical `LES-0025` / alias `V03-L10` / `CI-002` at `/book/engineering/ci-platform-operations`, with three assessments, eleven official references, and a bounded dual-engine local lab; artifact publication and mentor execution are not learner competency evidence | The local engines demonstrate only their encoded teaching model and do not execute or certify GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines. Formal acceptance, provider-specific evidence, learner execution, independently reviewed transfer, delayed recall, and mastery remain pending |

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

Storage diagnosis vocabulary is now recalled. Exact-path mount mapping, safe population selection, and end-to-end remediation still require learner-operated evidence. Systems thinking and FRAME troubleshooting are available to read but remain `Not assessed`; advisory prerequisite links do not change that learner state.

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
