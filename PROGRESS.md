# Project Progress

Last updated: 2026-08-02

This file reports delivery of the repository and website. It does not award competency. Learner evidence and levels remain in `progress/ledger.md`.

## Snapshot

| Field | Current value |
|---|---|
| Branch | `main` |
| Latest substantive checkpoint | `836c29e feat: add offline search and device-local reading desk` |
| Remote | `origin` points to `Abhishek8399/DevOps-SRE-Learning-Path` |
| Source checkpoint parity | `HEAD` and `origin/main` were confirmed at `836c29e` after the non-force push |
| Worktree | Structured schema, validator, tests, and governance updates are under validation; no mastery is inferred from this work |
| Current milestone | `PLAN-ARC-004` / `PLAN-MS-01` - structured content foundation and the next curriculum batch |
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

The committed baseline is useful and runnable, but it does not satisfy the complete curriculum or prove any skill beyond the evidence recorded in the learner ledger.

## Current committed checkpoint scope

| Plan IDs | Capability present on `main` | Delivery state |
|---|---|---|
| `PLAN-GOV-001`, `PLAN-GOV-003`, `PLAN-GOV-004` | Persistent control documents, book architecture, lesson/lab standard, and contributor workflow | Committed in `aa3ede8`; root controls are durable, while the contribution dry-run and full public-release review remain |
| `PLAN-ARC-001`, `PLAN-ARC-003`, `PLAN-ARC-006` | Volume map, typed glossary data, command decoders, complete teaching answers, and deeper lesson rendering | Committed in `aa3ede8`; structured-content migration and full lesson-standard acceptance remain |
| `PLAN-WEB-002`, `PLAN-WEB-003` | Routed library, Linux volume, dynamic lesson routes, breadcrumbs, desktop/mobile contents, and separate storage practice route | Committed in `aa3ede8`; all nine declared routes return 200 with exactly one `h1`, the invalid lesson returns 404, and the corrected practice link resolves; full manual navigation review remains |
| `PLAN-WEB-004`, `PLAN-WEB-008`, `PLAN-WEB-009` | Paper/night modes, text sizes, reading progress, print behavior, responsive layout, and lightweight local design | Committed in `aa3ede8`; full accessibility, print, privacy, and performance audits remain incomplete |
| `PLAN-WEB-006`, `PLAN-INT-001`, `PLAN-INT-002` | Incident, recall, teach-back, interview modes plus detailed Linux answer guides | Committed in `aa3ede8`; storage renders seven closed explicit-reveal answer panels and zero eager-open panels; complete schema/rubrics and other volumes remain |
| `PLAN-LAB-001`, `PLAN-LAB-101`, `PLAN-LAB-103`, `PLAN-LAB-104`, `PLAN-LAB-105` | Ubuntu-first environment cards and bounded storage, process, observation, and loopback labs with stronger cleanup controls | Committed in `aa3ede8`; all three shell scripts pass `bash -n`, while remaining lifecycle and failure matrices are pending |
| `PLAN-LAB-003`, `PLAN-LAB-102` | Pinned digest bootstrap, full v2 shell/status security envelope, removal-only reviewed-v1 envelope, `check` verifier, and descriptor-gated `reset` | Committed in `aa3ede8` and statically re-audited; lifecycle and one-field tamper tests remain blocked until Docker is integrated into Ubuntu |
| `PLAN-LAB-106` | Non-root permissions lab and guarded cleanup | Committed in `aa3ede8`; Ubuntu normal cleanup and child-symlink refusal passed, the external target survived, and bounded cleanup succeeded. Other misuse-matrix cases remain pending |
| `PLAN-GOV-005` | Ledger records the routed reader as a project artifact without awarding learner mastery | Committed in `aa3ede8` and remains evidence-neutral |
| `PLAN-QUA-001`, `PLAN-QUA-002`, `PLAN-QUA-004`, `PLAN-QUA-006` | Lint, typecheck, production build, content/link/anchor/ID/requirement validation, route/404/heading/asset checks, dependency audit, and patch whitespace validation | Passed and recorded for `aa3ede8`; only the documented build warnings remain. Broader lesson-schema, accessibility, privacy, licenses, and reproducibility gates remain |

## Current reader checkpoint scope

The following capabilities are committed in `836c29e`; `PARTIAL` means their complete acceptance criteria still require the named evidence.

| Plan IDs | Capability implemented | Remaining acceptance work |
|---|---|---|
| `PLAN-ARC-008` | Compact server-built search catalog for five lessons, with deterministic client ranking across stable IDs, curriculum IDs, titles, symptoms, commands, terms, and guidance | Topic/role/difficulty filters, complete cross-volume schema, production-catalog fixtures, and disconnected-browser proof |
| `PLAN-WEB-005` | Stable lesson links, device-local bookmarks, recent history, resume, reading markers, clear/reset flow, and origin/privacy explanation | Browser restart, real cross-tab, storage-disabled, and offline interaction tests |
| `PLAN-WEB-011` | Safe malformed/unsupported-state recovery, visible storage fallback, empty/no-result search states, and invalid-lesson 404 | Occupied-port, dependency-install, start-failure, and runtime error UX |
| `PLAN-AUD-005` | Fixed allowlisted state schema and repeated UI boundaries keep reading actions separate from competency; eight pure transition/search tests pass | Full evidence lineage, answer-key isolation, mentor-output, and assessment-state audit |

## Current structured-content checkpoint (worktree)

Schema v1 now has strict lesson, assessment, and reference records; opaque IDs separate from aliases, routes, slugs, and curriculum IDs; permanent reservations for all five typed lessons; and dependency-free repository validation. Thirty-four focused cases cover malformed and duplicate JSON, pinned schema policy, required/non-empty body sections, CommonMark fence and raw-HTML ambiguity, URL normalization, independent answer isolation, safe lab realpaths, canonical-content and policy-file symlinks, dangling links and exact path/file case, exact locations and filenames, legacy migration and collisions, ownership, backlinks, and prerequisite cycles. On this restricted Windows token, 33 passed and the real policy-file symlink case skipped because file-symlink creation returned `EPERM`; that runtime case remains for Linux or symlink-capable Windows.

No production lesson has migrated to the new format yet. The five current website lessons remain authoritative typed sources and all existing routes remain unchanged. Passing this contract suite proves publishing infrastructure, not chapter acceptance or learner mastery.

The remaining `PLAN-ARC-004` acceptance work is a separately reviewed production record and renderer/catalog adapter with route, text, search, device-state, and content-parity evidence.

## Recorded results versus current acceptance

The repository ledger records that, earlier in this 2026-08-02 work session, six local routes returned HTTP 200, an invalid lesson returned 404, selected night-mode color pairs measured at least 5.77:1, and bounded Ubuntu labs produced cleanup proof. Those remain historical results for the worktree state at the time they ran.

For the reader checkpoint, full lint, explicit typecheck, content validation, the escalated production build, eight reader/search tests, and `git diff --check` passed. Content validation reports all six memory files, 28 Markdown files, 38 valid local links, 307 heading anchors, 107 unique curriculum IDs, and all 46 requirements. The build retained only vinext route-classification and Node `module.register` deprecation warnings. Eleven declared routes returned 200 with exactly one `h1` and no external script/link/image assets; the search payload contained all five trusted lesson IDs; the reading desk and non-mastery boundary rendered; the invalid lesson returned 404; the temporary production server listened only on `127.0.0.1:4179` and was stopped cleanly. An attempted fresh registry audit was rejected before transmission because external manifest disclosure was not authorized; `package-lock.json` is unchanged from the prior zero-advisory audit, but no new registry result is claimed. These are project checks, not learner evidence. Browser-level keyboard, persistence, cross-tab, clipboard, night/mobile/print, and disconnected tests remain incomplete; Docker lifecycle/tamper execution remains blocked.

## Open findings and blockers

| ID | Severity | Affects | Finding | Required closure |
|---|---|---|---|---|
| `FIND-005` | Medium | `PLAN-ARC-004`, maintainability | The strict structured-Markdown contract and migration guard now exist, but current lessons and depth data remain large TypeScript structures. | Migrate one lesson through the catalog adapter with route, text, search, answer, lab, and device-state parity before retiring any typed source |
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

## Gaps by program area

| Area | Present now | Missing before complete |
|---|---|---|
| Curriculum | First five Linux lessons and full knowledge map | Volume 00; remaining Linux internals; Volumes 02-06; seven specialist tracks; references and scheduled review for every lesson |
| Website | Local launcher, landing page, routed book, reading controls, four learning modes, five-lesson search, bookmarks, recent/resume, private reading markers, and command-copy feedback | Cross-volume structured indexing and filters, structured content renderer, evidence export, due-review scheduling, stable-ID migration, browser restart/offline/cross-tab validation, full failure UX, and comprehensive accessibility/performance checks |
| Labs | Bounded ENOSPC fixture source plus four Ubuntu-first lab patterns, including runtime-verified symlink-safe permission cleanup | Docker-in-Ubuntu restoration; common host/container/VM/Kubernetes harnesses; Bats/ShellCheck; current/legacy descriptor, fresh-shell, adversarial, and failure-path matrix |
| Interviews | Role matrix, Linux prompts, detailed answer guides, one interactive interview mode | Stable question metadata, full rubrics, timed mocks, role-specific banks, scoring calibration, portfolio defense |
| Reliability evidence | Project ledger and one active incident simulation | Complete incident program, SLOs, observability, capacity, DR, projects, and independent learner transfer |
| Quality | Current lint/typecheck/build, content/link/anchor/ID/requirement validation, strict schema and relationship tests, patch whitespace, routes/404/headings/assets, answer reveal, shell syntax, registry audit, generated-file hygiene, and permissions regression | Live structured-record corpus and renderer parity, CI wiring, axe/keyboard/print matrix, ShellCheck and remaining lab runtime matrices, dependency-tree/license review, fresh-clone test, public audit |

## Current learner state

- Linux storage exact-path/ENOSPC is recorded at L1.
- The learner correctly recalls that free blocks do not imply free inodes and selects `df -hT <path>` plus `df -i <path>`.
- The learner has not yet produced the required safe remediation, retained-data, recovered-write, cleanup, independent-transfer, or delayed-recall evidence.
- The remaining technical areas are unassessed. Published lessons must not change those entries.

## Next actions

1. Complete the schema checkpoint review, then publish the first new structured lesson and catalog adapter without breaking the five existing URLs or device-local IDs.
2. Publish the next coherent Volume 00/Linux curriculum batch with deep explanations, command decoders, complete answers, and bounded Ubuntu labs.
3. Add production-catalog search fixtures, filters, internal crawling, and browser-level persistence/keyboard/clipboard/visual tests.
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
