# Project Progress

Last updated: 2026-08-02

This file reports delivery of the repository and website. It does not award competency. Learner evidence and levels remain in `progress/ledger.md`.

## Snapshot

| Field | Current value |
|---|---|
| Branch | `main` |
| Committed HEAD at snapshot start | `d958043 feat: add five-lesson Linux foundation volume` |
| Remote | `origin` points to `Abhishek8399/DevOps-SRE-Learning-Path` |
| Remote parity before current work | `HEAD` and `origin/main` both at `d958043` |
| Worktree | Dirty: routed-reader, content-depth, design, lab-safety, governance, and progress changes are not yet committed |
| Current milestone | `PLAN-MS-00` - stabilize the field-manual foundation |
| Current learner gate | `PLAN-CUR-101` / `PLAN-LAB-102` - learner-operated inode remediation evidence is pending |
| Cloud policy | Local only; no online cloud resources |

## Completed and committed foundation

| Date | Plan IDs | Result | Evidence |
|---|---|---|---|
| 2026-07-20 | `PLAN-LAB-003`, `PLAN-LAB-102` foundations | Created a bounded ENOSPC diagnostic container and initial evidence workflow | Commits `75bc494` through `b514c6d` |
| 2026-07-31 | `PLAN-LAB-102` | Hardened the fixture to run as UID/GID 65534 and documented Docker recovery plus safe inode remediation | Commits `55544da`, `571cccb`, `8af031e` |
| 2026-08-01 | `PLAN-INT-003`, `PLAN-WEB-001`, `PLAN-WEB-006` foundations | Added target-role mapping and the first local, Git-backed learning cockpit | Commit `798404e` |
| 2026-08-02 | `PLAN-CUR-101` through `PLAN-CUR-105` initial content | Added the first five Linux foundation lessons, diagrams, guided labs, optional checks, and interview prompts | Commit `d958043` |

The committed baseline is useful and runnable, but it does not satisfy the complete curriculum or prove any skill beyond the evidence recorded in the learner ledger.

## Current uncommitted work

| Plan IDs | Work present in the worktree | Delivery state |
|---|---|---|
| `PLAN-GOV-001`, `PLAN-GOV-003`, `PLAN-GOV-004` | Persistent control documents, book architecture, lesson/lab standard, and contributor workflow | In progress; root controls are being added now |
| `PLAN-ARC-001`, `PLAN-ARC-003`, `PLAN-ARC-006` | Volume map, typed glossary data, command decoders, complete teaching answers, and deeper lesson rendering | Implemented locally; acceptance rerun pending |
| `PLAN-WEB-002`, `PLAN-WEB-003` | Routed library, Linux volume, dynamic lesson routes, breadcrumbs, desktop/mobile contents, and separate storage practice route | All nine declared routes return 200 with exactly one `h1`; the invalid lesson returns 404 and the corrected home practice link resolves; full anchor/manual-navigation review remains |
| `PLAN-WEB-004`, `PLAN-WEB-008`, `PLAN-WEB-009` | Paper/night modes, text sizes, reading progress, print behavior, responsive layout, and lightweight local design | Implemented locally; full accessibility/print/performance audit incomplete |
| `PLAN-WEB-006`, `PLAN-INT-001`, `PLAN-INT-002` | Incident, recall, teach-back, interview modes plus detailed Linux answer guides | Storage renders seven closed, explicit-reveal answer panels and zero eager-open panels; complete schema/rubrics and other volumes remain |
| `PLAN-LAB-001`, `PLAN-LAB-101`, `PLAN-LAB-103`, `PLAN-LAB-104`, `PLAN-LAB-105` | Ubuntu-first environment cards and bounded storage, process, observation, and loopback labs with stronger cleanup controls | Implemented locally; all three shell scripts pass `bash -n`, while remaining lifecycle and failure matrices are pending |
| `PLAN-LAB-003`, `PLAN-LAB-102` | Pinned digest bootstrap, full v2 shell/status security envelope, removal-only reviewed-v1 envelope, `check` verifier, and descriptor-gated `reset` | Implemented and statically re-audited; lifecycle and one-field tamper tests remain blocked until Docker is integrated into Ubuntu |
| `PLAN-LAB-106` | Non-root permissions lab and guarded cleanup | Ubuntu normal cleanup and child-symlink refusal passed; the external target survived and bounded cleanup succeeded. Other misuse-matrix cases remain pending |
| `PLAN-GOV-005` | Ledger records the routed reader as a project artifact without awarding learner mastery | Updated locally; must remain evidence-neutral |
| `PLAN-QUA-001`, `PLAN-QUA-002`, `PLAN-QUA-004`, `PLAN-QUA-006` | Lint, typecheck, production build, content/link/anchor/ID/requirement validation, route/404/heading/asset checks, dependency audit, and patch whitespace validation | Current post-source checks pass; only the documented build warnings remain. Broader lesson-schema, accessibility, privacy, licenses, and reproducibility gates remain |

## Recorded results versus current acceptance

The repository ledger records that, earlier in this 2026-08-02 work session, six local routes returned HTTP 200, an invalid lesson returned 404, selected night-mode color pairs measured at least 5.77:1, and bounded Ubuntu labs produced cleanup proof. Those remain historical results for the worktree state at the time they ran.

After the latest source edits, lint, explicit typecheck, content validation, the escalated production build, `git diff --check`, and the current registry-backed `npm audit --audit-level=high` passed. Content validation found all six memory files, 28 Markdown files, 38 valid local links, 306 heading anchors, 107 unique curriculum IDs, and explicit coverage of all 46 requirements. The build retained only vinext route-classification and Node `module.register` deprecation warnings. All nine declared routes returned 200 with exactly one `h1` and no external script/link/image assets; the invalid lesson returned 404. Storage rendered seven closed explicit-reveal answer panels and no eager-open panels, and the home practice link was corrected. All three shell scripts passed `bash -n`. The Ubuntu permissions normal-cleanup and child-symlink-refusal regressions passed with external-target survival and bounded cleanup. These are project validation results, not learner evidence. Real Docker lifecycle/tamper execution and the remaining release gates are incomplete; exact scope is maintained in `VERIFICATION.md`.

## Open findings and blockers

| ID | Severity | Affects | Finding | Required closure |
|---|---|---|---|---|
| `FIND-005` | Medium | `PLAN-ARC-004`, maintainability | Current lessons and depth data remain large TypeScript structures. | Define and validate MDX schema, then migrate without route/content regression |
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
| Website | Local launcher, landing page, routed book worktree, reading controls, four learning modes | Search, bookmarks/resume, structured content renderer, evidence export, failure UX, comprehensive automated accessibility and performance checks |
| Labs | Bounded ENOSPC fixture source plus four Ubuntu-first lab patterns, including runtime-verified symlink-safe permission cleanup | Docker-in-Ubuntu restoration; common host/container/VM/Kubernetes harnesses; Bats/ShellCheck; current/legacy descriptor, fresh-shell, adversarial, and failure-path matrix |
| Interviews | Role matrix, Linux prompts, detailed answer guides, one interactive interview mode | Stable question metadata, full rubrics, timed mocks, role-specific banks, scoring calibration, portfolio defense |
| Reliability evidence | Project ledger and one active incident simulation | Complete incident program, SLOs, observability, capacity, DR, projects, and independent learner transfer |
| Quality | Current lint/typecheck/build, content/link/anchor/ID/requirement validation, patch whitespace, routes/404/headings/assets, answer reveal, shell syntax, registry audit, generated-file hygiene, and permissions regression | Full lesson-schema validation, axe/keyboard/print matrix, ShellCheck and remaining lab runtime matrices, dependency-tree/license review, fresh-clone test, public audit |

## Current learner state

- Linux storage exact-path/ENOSPC is recorded at L1.
- The learner correctly recalls that free blocks do not imply free inodes and selects `df -hT <path>` plus `df -i <path>`.
- The learner has not yet produced the required safe remediation, retained-data, recovered-write, cleanup, independent-transfer, or delayed-recall evidence.
- The remaining technical areas are unassessed. Published lessons must not change those entries.

## Next actions

1. Restore Docker integration in Ubuntu, then run v2 lifecycle, full-boundary tamper/refusal, exact legacy-v1 cleanup, v2 `check`/`reset`, rebuild, and cleanup proof.
2. Complete the remaining host-lab root, wrong-owner/sentinel, unexpected-entry, stale-state, and cleanup-retry cases.
3. Run the still-pending full link/anchor, contrast, keyboard, responsive, print, reduced-motion, secret, and browser-network checks.
4. Run ShellCheck, the manual dependency-tree/license review, and final generated-file/diff hygiene checks.
5. Complete `PLAN-AUD-001`, inspect the entire diff, commit the logical field-manual release, and push `main`.
6. Return to learner-operated `PLAN-LAB-102`; do not advance the competency gate merely because five lessons are readable.

## Update protocol

After each logical change:

1. update the relevant `MASTER_PLAN.md` status only when its stated acceptance scope changed;
2. append exact results or failures to `VERIFICATION.md`;
3. update this file's current/next/findings sections;
4. update `progress/ledger.md` only if reviewed learner evidence changed;
5. commit and push after validation, preserving unrelated work.
