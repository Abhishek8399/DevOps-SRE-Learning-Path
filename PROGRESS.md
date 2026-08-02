# Project Progress

Last updated: 2026-08-02

This file reports delivery of the repository and website. It does not award competency. Learner evidence and levels remain in `progress/ledger.md`.

## Snapshot

| Field | Current value |
|---|---|
| Branch | `main` |
| Latest substantive checkpoint | `817bb60` — `LES-0007` systems-thinking foundation lesson and Volume 00 reader path |
| Remote | `origin` points to `Abhishek8399/DevOps-SRE-Learning-Path` |
| Source checkpoint parity | Commit `817bb609cd2957d5b183246612dc2b078cfb2cb3` was pushed to `origin/main`; parity was confirmed immediately after the feature push |
| Worktree | Seven lessons across Volumes 00 and 01, including two schema-backed structured lessons; publication does not change learner competency |
| Current milestone | `PLAN-CUR-000` / `FND-001` - systems-thinking foundation lesson and bounded Ubuntu model |
| Current learner gate | `PLAN-CUR-101` / `PLAN-LAB-102` - learner-operated inode remediation evidence is pending |
| Cloud policy | Local only; no online cloud resources |

## Completed and committed foundation

| Date | Plan IDs | Result | Evidence |
|---|---|---|---|
| 2026-07-20 | `PLAN-LAB-003`, `PLAN-LAB-102` foundations | Created a bounded ENOSPC diagnostic container and initial evidence workflow | Commits `75bc494` through `b514c6d` |
| 2026-07-31 | `PLAN-LAB-102` | Hardened the fixture to run as UID/GID 65534 and documented Docker recovery plus safe inode remediation | Commits `55544da`, `571cccb`, `8af031e` |
| 2026-08-01 | `PLAN-INT-003`, `PLAN-WEB-001`, `PLAN-WEB-006` foundations | Added target-role mapping and the first local, Git-backed learning cockpit | Commit `798404e` |
| 2026-08-02 | `PLAN-CUR-101` through `PLAN-CUR-105` initial content | Added the first five Linux foundation lessons, diagrams, guided labs, optional checks, and interview prompts | Commit `d958043` |
| 2026-08-02 | `PLAN-MS-00`, governance, architecture, routed reader, Linux-depth, lab-safety, and quality checkpoint | Added durable project controls, the canonical 107-ID curriculum map, routed/deep Linux reader, detailed decoders and answer guides, hardened ENOSPC ownership boundaries, and dependency-free content validation | Commit `aa3ede8` |
| 2026-08-02 | `PLAN-ARC-008`, `PLAN-WEB-005`, `PLAN-WEB-011`, `PLAN-AUD-005` reader checkpoint | Added five-lesson local search, bookmarks, recent/resume state, private reading markers, command-copy feedback, safe storage fallback/reset, current-page navigation, and dependency-free tests without changing mastery | Commit `836c29e`; pushed to `origin/main` |
| 2026-08-02 | `PLAN-ARC-004`, `PLAN-ARC-007`, `PLAN-QUA-002` structured-content checkpoint | Added strict lesson/assessment/reference schemas, immutable legacy identity, answer-isolated independent transfer, cross-record validation, path/symlink/case hardening, and disposable adversarial tests | Commit `4c1b922`; pushed to `origin/main` |
| 2026-08-02 | `PLAN-ARC-004`, `PLAN-CUR-106`, `PLAN-WEB-005`, `PLAN-AUD-005`, `PLAN-QUA-002` first structured-lesson checkpoint | Published schema-backed `LES-0006` as a `substantive-draft`, added its renderer/catalog adapter, three assessments, eight primary references, safe Ubuntu command cards, bounded practice, answer isolation, and parity coverage without changing any learner level | Commit `24201bb`; pushed to `origin/main` |
| 2026-08-02 | `PLAN-CUR-000`, `PLAN-LAB-100`, `PLAN-ARC-008`, `PLAN-WEB-005`, `PLAN-AUD-005`, `PLAN-QUA-002` systems-thinking checkpoint | Added schema-backed `LES-0007` as a `substantive-draft`, Volume 00 routing, cross-volume search and state migration, three assessments, eight primary references, and a bounded Ubuntu queue-model lab without changing learner evidence | Commit `817bb60`; pushed to `origin/main` |

The committed baseline is useful and runnable, but it does not satisfy the complete curriculum or prove any skill beyond the evidence recorded in the learner ledger.

Commit `817bb60` adds `LES-0007` / `V00-L01` / `FND-001` as a second `substantive-draft` structured lesson, three assessments, eight references, a bounded Ubuntu 24.04 systems-thinking lab, Volume 00 routes, and cross-volume reader support. This is project-delivery evidence only.

## Current committed checkpoint scope

| Plan IDs | Capability present on `main` | Delivery state |
|---|---|---|
| `PLAN-GOV-001`, `PLAN-GOV-003`, `PLAN-GOV-004` | Persistent control documents, book architecture, lesson/lab standard, and contributor workflow | Committed in `aa3ede8`; root controls are durable, while the contribution dry-run and full public-release review remain |
| `PLAN-ARC-001`, `PLAN-ARC-003`, `PLAN-ARC-006` | Volume map, typed glossary data, command decoders, complete teaching answers, and deeper lesson rendering | Committed through `817bb60`; `LES-0006` and `LES-0007` are schema-backed production lessons, while the five legacy lessons and full curriculum acceptance remain |
| `PLAN-WEB-002`, `PLAN-WEB-003` | Routed library, Volume 00 and Linux volume, dynamic lesson routes, breadcrumbs, desktop/mobile contents, separate storage practice, and a structured lesson renderer | Committed through `817bb60`; all 14 declared routes return 200 with exactly one `h1`, invalid lesson routes in both volumes return 404, and the five pre-existing lesson routes remain unchanged; full manual navigation review remains |
| `PLAN-WEB-004`, `PLAN-WEB-008`, `PLAN-WEB-009` | Paper/night modes, text sizes, reading progress, print behavior, responsive layout, and lightweight local design | Committed in `aa3ede8`; full accessibility, print, privacy, and performance audits remain incomplete |
| `PLAN-WEB-006`, `PLAN-INT-001`, `PLAN-INT-002` | Incident, recall, teach-back, interview modes plus detailed answer guides and schema-backed assessment rendering | Committed through `817bb60`; storage still renders seven closed explicit-reveal answer panels, while `LES-0006` and `LES-0007` together add four complete answer guides and two answer-isolated independent-transfer assessments; complete banks and calibrated rubrics remain |
| `PLAN-LAB-001`, `PLAN-LAB-101`, `PLAN-LAB-103`, `PLAN-LAB-104`, `PLAN-LAB-105` | Ubuntu-first environment cards and bounded storage, process, observation, and loopback labs with stronger cleanup controls | Committed in `aa3ede8`; all three shell scripts pass `bash -n`, while remaining lifecycle and failure matrices are pending |
| `PLAN-LAB-003`, `PLAN-LAB-102` | Pinned digest bootstrap, full v2 shell/status security envelope, removal-only reviewed-v1 envelope, `check` verifier, and descriptor-gated `reset` | Committed in `aa3ede8` and statically re-audited; lifecycle and one-field tamper tests remain blocked until Docker is integrated into Ubuntu |
| `PLAN-LAB-106` | Non-root permissions lab and guarded cleanup | Committed in `aa3ede8`; Ubuntu normal cleanup and child-symlink refusal passed, the external target survived, and bounded cleanup succeeded. Other misuse-matrix cases remain pending |
| `PLAN-GOV-005` | Ledger records the routed reader as a project artifact without awarding learner mastery | Committed in `aa3ede8` and remains evidence-neutral |
| `PLAN-QUA-001`, `PLAN-QUA-002`, `PLAN-QUA-004`, `PLAN-QUA-006` | Lint, typecheck, production build, content/link/anchor/ID/requirement validation, schema/relationship and reader tests, route/404/heading/asset checks, dependency audit, and patch whitespace validation | Passed and recorded through `817bb60`; one Windows policy-symlink test remains an explicit `EPERM` skip and only the documented build warnings remain. Accessibility, privacy, licenses, fresh-clone reproducibility, and manual browser gates remain |

## Current reader checkpoint scope

The reader is committed through `817bb60`. `PARTIAL` means the complete acceptance criteria still require the named evidence.

| Plan IDs | Capability implemented | Remaining acceptance work |
|---|---|---|
| `PLAN-ARC-008` | Server-built cross-volume search catalog for seven lessons, including schema-backed `LES-0006` and `LES-0007`, with deterministic client ranking across stable IDs, curriculum IDs, titles, symptoms, commands, terms, and guidance | Topic/role/difficulty filters, a lightweight generated metadata manifest before the corpus grows large, and disconnected-browser proof |
| `PLAN-WEB-005` | Stable lesson links, additive device-state migration, device-local bookmarks, recent history, resume, reading markers, clear/reset flow, and origin/privacy explanation | Browser restart, real cross-tab, storage-disabled, and offline interaction tests |
| `PLAN-WEB-011` | Safe malformed/unsupported-state recovery, visible storage fallback, empty/no-result search states, and invalid-lesson 404 | Occupied-port, dependency-install, start-failure, and runtime error UX |
| `PLAN-AUD-005` | Fixed allowlisted state schema and repeated UI boundaries keep reading actions separate from competency; 20 reader/search/adapter tests pass, including additive migration and independent-answer isolation | Full evidence lineage, mentor-output, and assessment-state audit |

## Current structured-content checkpoint

Schema v1 has strict lesson, assessment, and reference records; opaque IDs separate from aliases, routes, slugs, and curriculum IDs; permanent reservations for all five legacy lessons; and dependency-free repository validation. The committed corpus contains two lessons (`LES-0006` and `LES-0007`), six assessments, and 16 primary references. The 39-case schema suite covers malformed and duplicate JSON, pinned schema policy, required/non-empty body sections, H1/title parity, CommonMark fence and raw-HTML ambiguity, URL normalization, independent answer isolation, safe lab realpaths and command policy, canonical-content and policy-file symlinks, dangling links and exact path/file case, legacy migration and collisions, ownership, backlinks, and prerequisite cycles. On this restricted Windows token, 38 passed and the real policy-file symlink case skipped because file-symlink creation returned `EPERM`; that runtime case remains for Linux or symlink-capable Windows.

`LES-0006` / `V01-L06` / `LNX-005` is the first production lesson published through the schema-backed renderer and catalog adapter at `/book/linux/boot-kernel-systemd-journal`. Its 18 required sections, three diagrams, 12 read-only command cards, bounded guided lab, two incidents, two complete answer guides, independent transfer prompt, and reference set are marked `substantive-draft`. The five existing typed lessons remain authoritative for their routes, and their URLs and device-local IDs are unchanged.

`LES-0007` / `V00-L01` / `FND-001` is the second structured lesson at `/book/start/systems-thinking`. It adds the Volume 00 entry point, state/queue/dependency/failure-domain reasoning, three assessments, eight references, and a bounded local Ubuntu model. Commit `4c1b922` established the publishing contract, commit `24201bb` proved its first additive production path, and commit `817bb60` adds the second path. This is artifact-delivery evidence only: `substantive-draft`, publication, or a mentor-run verifier is not chapter acceptance, completed learner practice, retained knowledge, independent transfer, or learner mastery.

## Recorded results versus current acceptance

The repository ledger records that, earlier in this 2026-08-02 work session, six local routes returned HTTP 200, an invalid lesson returned 404, selected night-mode color pairs measured at least 5.77:1, and bounded Ubuntu labs produced cleanup proof. Those remain historical results for the worktree state at the time they ran.

For the historical `836c29e` reader checkpoint, full lint, explicit typecheck, content validation, the escalated production build, eight reader/search tests, and `git diff --check` passed. Content validation reported all six memory files, 28 Markdown files, 38 valid local links, 307 heading anchors, 107 unique curriculum IDs, and all 46 requirements. The build retained only vinext route-classification and Node `module.register` deprecation warnings. Eleven declared routes returned 200 with exactly one `h1` and no external script/link/image assets; the search payload contained all five trusted lesson IDs; the reading desk and non-mastery boundary rendered; the invalid lesson returned 404; the temporary production server listened only on `127.0.0.1:4179` and was stopped cleanly. An attempted fresh registry audit was rejected before transmission because external manifest disclosure was not authorized; `package-lock.json` is unchanged from the prior zero-advisory audit, but no new registry result is claimed.

For `24201bb`, content validation reported `root-memory=6/6`, 30 Markdown files, 42 valid local links, zero explicit-anchor errors, 383 heading anchors, 107 unique curriculum IDs, all 46 requirements, three valid schemas, one structured lesson, three assessments, eight references, and five legacy reservations. The 36-case schema suite completed with 35 passes and the documented Windows `EPERM` symlink skip; all 17 reader/search/adapter tests, lint, explicit typecheck, production build, and patch checks passed. Twelve declared routes returned 200 with exactly one `h1` and no external executable assets; the structured route exposed the metadata-derived `substantive-draft` status and `REF-0008`; search returned all six lesson IDs; the invalid lesson returned 404; and the loopback-only server stopped cleanly. An escalated Ubuntu 24.04 matrix executed the lesson's 13 exact read-only runtime checks successfully with command output suppressed. Independent content and adapter re-audits passed after parser, safety, accuracy, and reference fixes.

For `817bb60`, content validation reported `root-memory=6/6`, 32 Markdown files, 44 valid local links, zero explicit-anchor errors, 485 heading anchors, 107 unique curriculum IDs, all 46 requirements, three valid schemas, two lessons, six assessments, 16 references, and five legacy reservations. Lint, explicit typecheck, production build, all 20 reader tests, and 38 of 39 schema cases passed; the remaining case was the documented Windows `EPERM` policy-symlink skip. Fourteen declared routes returned HTTP 200 with exactly one `h1` and no external executable assets, and both invalid lesson routes returned 404. The bounded `LES-0007` lifecycle verifier passed in Ubuntu 24.04 and confirmed its state was absent after cleanup. That verifier run was mentor-operated project evidence, not learner lab completion or competency evidence.

These are repository and artifact checks, not learner evidence. Browser automation setup succeeded but no browser instance was available, so keyboard, persistence, cross-tab, clipboard, night/mobile/print, visual, and disconnected interaction claims remain incomplete. Docker lifecycle/tamper execution also remains blocked.

## Open findings and blockers

| ID | Severity | Affects | Finding | Required closure |
|---|---|---|---|---|
| `FIND-006` | Program gate | `PLAN-GOV-005`, `PLAN-CUR-101`, `PLAN-LAB-102` | Learner understands blocks versus inodes but has not supplied the required remediation and transfer evidence. | Learner runs the bounded remediation, preserves retained data, proves write recovery and cleanup, then completes unfamiliar transfer and delayed recall |
| `FIND-007` | Environment blocker | `PLAN-LAB-102`, `REL-LAB-009` through `REL-LAB-012` | Docker is not currently integrated into the Ubuntu 24.04 distribution, so the revised container lifecycle and descriptor behavior cannot be exercised there. | Restore Docker Desktop WSL integration, confirm `docker info`, then run exact-v2, exact-legacy-v1, full-envelope counterfeit, check, and reset tests without weakening the script |

## Resolved findings awaiting final release review

| ID | Original severity | Resolution in the current worktree | Remaining evidence |
|---|---|---|---|
| `FIND-001` | High | Permissions cleanup requires exact non-symlink/type/UID/path checks. Ubuntu normal cleanup and a replaced-child-symlink refusal both passed; the external target survived and bounded lab cleanup succeeded. | Original finding is operationally closed; retain the transcript and complete the broader root/wrong-owner/sentinel/unexpected-entry/retry matrix as separate release coverage |
| `FIND-002` | High | A current registry-backed `npm audit --audit-level=high` reported `found 0 vulnerabilities`. The earlier install warning remains historical evidence rather than a current finding. | Retain the exact current audit result and perform the planned manual dependency-tree/license review before public release |
| `FIND-003` | Medium | Root `.gitignore` now excludes `*.tsbuildinfo`, so TypeScript incremental-build state is not treated as source. | Confirm the final build leaves no other unexplained generated files |
| `FIND-004` | Medium | All three repository shell scripts now pass `bash -n` in Ubuntu 24.04 after the earlier Windows-sandbox attempts failed. | ShellCheck and runtime lifecycle/failure-path tests remain separate pending checks |
| `FIND-008` | High | The current gate now compares current image ID, entrypoint, mounts/devices/ports, namespace modes, privilege and capabilities, security options, resource ceilings, restart/auto-remove, and exact generation-specific tmpfs options. The full legacy envelope is cleanup-only; status/shell require v2. Expanded static re-review found no remaining counterfeit path within the documented accidental-misuse threat model. | Run one-field-at-a-time counterfeit refusal, v1 migration, v2 `check`/`reset`, and normal cleanup tests after Docker integration is restored |
| `FIND-005` | Medium | The first production record now renders through the schema-backed catalog adapter with route, search, answer-isolation, lab, reference, and additive device-state parity; all five legacy URLs and IDs remain unchanged. | The original first-migration finding is closed. Migrate legacy lessons incrementally after parity checks, and replace eager full-content catalog metadata with a lightweight generated manifest before corpus growth makes it costly. |

## Gaps by program area

| Area | Present now | Missing before complete |
|---|---|---|
| Curriculum | Seven lessons across Volumes 00 and 01, including schema-backed `LES-0006` and `LES-0007` at `substantive-draft`, plus the full knowledge map | Remaining Volume 00/Linux internals; Volumes 02-06; seven specialist tracks; acceptance review, primary references, and scheduled review for every lesson |
| Website | Local launcher, landing page, two-volume routed book, reading controls, four learning modes, seven-lesson cross-volume search, schema-backed renderer, bookmarks, recent/resume, private reading markers, and command-copy feedback | Topic/role/difficulty filters, lightweight catalog manifest, evidence export, due-review scheduling, incremental legacy migration, browser restart/offline/cross-tab validation, full failure UX, and comprehensive accessibility/performance checks |
| Labs | Bounded ENOSPC fixture source, four Ubuntu-first lab patterns, and the bounded `LES-0007` systems-thinking model; its mentor-operated Ubuntu 24.04 verifier passed and cleanup left state absent | Learner-operated evidence remains separate; Docker-in-Ubuntu restoration; common host/container/VM/Kubernetes harnesses; Bats/ShellCheck; current/legacy descriptor, fresh-shell, adversarial, and failure-path matrix |
| Interviews | Role matrix, Linux prompts, detailed answer guides, one interactive interview mode, and six schema-backed assessments across `LES-0006` and `LES-0007`, including answer-isolated transfer | Broad stable question metadata, timed mocks, role-specific banks, scoring calibration, and portfolio defense |
| Reliability evidence | Project ledger and one active incident simulation | Complete incident program, SLOs, observability, capacity, DR, projects, and independent learner transfer |
| Quality | Current lint/typecheck/build and content validation pass; 20 reader tests pass; 39 schema cases report 38 passes and one Windows `EPERM` skip; 14 routes return 200 with one `h1` and no external executable assets; two invalid routes return 404; bounded Ubuntu verification and cleanup pass | CI wiring, an available browser instance for axe/keyboard/visual/print/persistence/offline proof, ShellCheck and remaining lab runtime matrices, dependency-tree/license review, fresh-clone test, and public audit |

## Current learner state

- Linux storage exact-path/ENOSPC is recorded at L1.
- The learner correctly recalls that free blocks do not imply free inodes and selects `df -hT <path>` plus `df -i <path>`.
- The learner has not yet produced the required safe remediation, retained-data, recovered-write, cleanup, independent-transfer, or delayed-recall evidence.
- The remaining technical areas are unassessed. Published lessons must not change those entries.

## Next actions

1. Publish the next dependency-ordered Volume 00/Linux structured batch with deep explanations, command decoders, complete answers, bounded Ubuntu labs, and primary references.
2. Migrate legacy lessons incrementally only after route, text, search, answer, lab, and device-state parity checks; introduce a lightweight generated catalog manifest before corpus growth makes eager imports costly.
3. Add cross-volume search filters, internal crawling, and browser-level persistence/keyboard/clipboard/night/mobile/print/visual tests.
4. Restore Docker integration when available, then run the v2 lifecycle, full-boundary tamper/refusal, legacy migration, `check`, `reset`, and cleanup proof.
5. Complete host-lab failure matrices, ShellCheck, accessibility/privacy/performance checks, dependency/license review, and fresh-clone reproducibility.
6. Keep learner-operated `PLAN-LAB-102` at its current evidence gate; published content and reader actions must not auto-advance it.

## Update protocol

After each logical change:

1. update the relevant `MASTER_PLAN.md` status only when its stated acceptance scope changed;
2. append exact results or failures to `VERIFICATION.md`;
3. update this file's current/next/findings sections;
4. update `progress/ledger.md` only if reviewed learner evidence changed;
5. commit and push after validation, preserving unrelated work.
