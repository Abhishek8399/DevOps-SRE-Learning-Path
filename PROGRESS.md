# Project Progress

Last updated: 2026-08-02

This file reports delivery of the repository and website. It does not award competency. Learner evidence and levels remain in `progress/ledger.md`.

## Snapshot

| Field | Current value |
|---|---|
| Branch | `main` |
| Latest substantive checkpoint | `142fb82` — `LES-0009` through `LES-0018`, Volumes 02 and 03, ten guarded labs, and eighteen-lesson reader integration |
| Remote | `origin` is configured for this dedicated learning-path repository |
| Source checkpoint parity | Commit `142fb826065b145333e5cae8a32d352468a11b34` was pushed to `origin/main`; `HEAD` and `origin/main` parity was confirmed at that feature revision |
| Worktree | `main` contains eighteen routed identities across Volumes 00 through 03: five legacy lessons and thirteen schema-backed `substantive-draft` lessons; project validation does not change learner competency |
| Official title | `Reliability Atlas`; production HTTP, title, privacy, and route assertions pass, while visual, keyboard, night-mode, and mobile browser QA remain unavailable and unclaimed |
| Current milestone | The `LES-0009` through `LES-0018` content-first checkpoint is pushed; the next batch is `LES-0019` through `LES-0023` with a generated content manifest |
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
| 2026-08-02 | `DBG-001`, `PLAN-LAB-107`, `PLAN-WEB-002`, `PLAN-AUD-005`, `PLAN-QUA-002` troubleshooting and Reliability Atlas checkpoint | Added schema-backed `LES-0008`, FRAME worksheet, three assessments, eight references, bounded verified lab, advisory prerequisites, canonical eight-lesson search, strict local launcher, truthful nine-stage homepage, title migration, and privacy scrub without changing learner evidence | Commit `22d3160`; pushed to `origin/main` |
| 2026-08-02 | `PLAN-CUR-000`, `PLAN-CUR-107`, `PLAN-CUR-108`, `PLAN-CUR-200` through `PLAN-CUR-204`, `PLAN-CUR-300`, `PLAN-CUR-301`, reader and quality workstreams | Added ten exact-18-section `substantive-draft` lessons (`LES-0009` through `LES-0018`), ten guarded Ubuntu labs, thirty assessments, eighty references, Volume 02/03 routes, eighteen-identity search/state integration, and audited documentation without changing learner evidence | Commit `142fb82`; pushed to `origin/main` with exact parity |
The committed baseline is useful and runnable, but it does not satisfy the complete curriculum or prove any skill beyond the evidence recorded in the learner ledger.

Commit `817bb60` adds `LES-0007` / `V00-L01` / `FND-001` as a second `substantive-draft` structured lesson, three assessments, eight references, a bounded Ubuntu 24.04 systems-thinking lab, Volume 00 routes, and cross-volume reader support. This is project-delivery evidence only.

Commit `22d3160` adds `LES-0008` / `V00-L02` / `DBG-001` as a third `substantive-draft` structured lesson. It adds the reusable `book/frameworks/FRAME.md` worksheet, `ASM-0007` through `ASM-0009` with `ASM-0009` answer-isolated, `REF-0017` through `REF-0024`, a bounded normal-user virtual incident lab, advisory prerequisite navigation, and eight-lesson catalog/search/state integration. Content/schema/reader/lint/type/build/route/link gates and mentor-operated `REL-LAB-014` pass. ShellCheck, concurrency, browser QA, formal acceptance, learner transfer, and mastery remain pending.
Commit `142fb82` adds `LES-0009` through `LES-0018`: a safe local workbench, block-I/O and isolation foundations, packet and transport paths, DNS, HTTP, TLS, Bash, and Python operational automation. The ten lessons contain approximately 148,487 whitespace-delimited words, exactly 18 required sections each, thirty assessments, eighty references, and guarded labs. Automated project gates and the recorded Ubuntu verification pass, but formal review, learner execution, real-environment transfers, delayed recall, and mastery remain open.


## Current committed checkpoint scope

| Plan IDs | Capability present on `main` | Delivery state |
|---|---|---|
| `PLAN-GOV-001`, `PLAN-GOV-003`, `PLAN-GOV-004` | Persistent control documents, book architecture, lesson/lab standard, contributor workflow, and canonical ownership rules | Committed through `142fb82`; controls describe the thirteen-lesson structured corpus and next ID `LES-0019`, while a fresh-contributor dry run and full public-release review remain |
| `PLAN-ARC-001`, `PLAN-ARC-003`, `PLAN-ARC-006` | Volume map, typed glossary data, command decoders, complete teaching answers, and deeper lesson rendering | Committed through `142fb82`; `LES-0006` through `LES-0018` are thirteen schema-backed lessons across Volumes 00 through 03, while the five legacy bodies and full curriculum acceptance remain |
| `PLAN-WEB-002`, `PLAN-WEB-003` | Routed library, four routed volumes, dynamic lesson routes, breadcrumbs, desktop/mobile contents, separate storage practice, and the structured lesson renderer | Committed through `142fb82`; the production HTTP audit passes 27 declared routes, 27 internal links, and four invalid-route 404s with exact loopback cleanup; full manual navigation review remains unavailable |
| `PLAN-WEB-004`, `PLAN-WEB-008`, `PLAN-WEB-009` | Paper/night modes, text sizes, reading progress, print behavior, responsive layout, and lightweight local design | Committed through `142fb82`; privacy and source scans pass, while formal accessibility, visual, night-mode, mobile, print, and performance audits remain incomplete |
| `PLAN-WEB-006`, `PLAN-INT-001`, `PLAN-INT-002` | Incident, recall, teach-back, interview modes plus detailed answer guides and schema-backed assessment rendering | Committed through `142fb82`; thirteen structured lessons provide thirty-nine validated assessments, including thirteen answer-isolated independent transfers; complete banks, learner submissions, and calibrated rubrics remain |
| `PLAN-LAB-001` and `LES-0009` through `LES-0018` labs | Ubuntu-first environment cards, guarded lifecycle scripts, deterministic guided and changed-constraint cases, explicit root refusal, and exact cleanup | All twenty `lab.sh`/`verify.sh` scripts pass ShellCheck; Ubuntu syntax and all ten verifiers pass, every root probe refuses, and final `/tmp` state/residue checks are absent. Learner execution and representative real-system transfers remain |
| `PLAN-LAB-003`, `PLAN-LAB-102` | Pinned digest bootstrap, full v2 shell/status security envelope, removal-only reviewed-v1 envelope, `check` verifier, and descriptor-gated `reset` | Committed in `aa3ede8` and statically re-audited; lifecycle and one-field tamper tests remain blocked until Docker is integrated into Ubuntu |
| `PLAN-LAB-106` | Non-root permissions lab and guarded cleanup | Committed in `aa3ede8`; Ubuntu normal cleanup and child-symlink refusal passed, the external target survived, and bounded cleanup succeeded. Other misuse-matrix cases remain pending |
| `PLAN-GOV-005` | Ledger records the routed reader as a project artifact without awarding learner mastery | Committed in `aa3ede8` and remains evidence-neutral |
| `PLAN-QUA-001`, `PLAN-QUA-002`, `PLAN-QUA-004`, `PLAN-QUA-006` | Lint, typecheck, production build, content/link/anchor/ID/requirement validation, schema/relationship and reader tests, route/404/link checks, privacy and source hygiene | Passed and recorded through `142fb82`; schema reports 38 passes, zero failures, and one Windows `EPERM` skip, while build retains only known vinext classification and Node `module.register` warnings. Fresh-clone, browser, dependency/license, Docker, and public-release gates remain |

## Current reader checkpoint scope

The reader is committed through `142fb82`. `PARTIAL` means the complete acceptance criteria still require the named evidence.

The committed catalog exposes eighteen routed identities: five legacy lessons and thirteen structured lessons across Volumes 00 through 03. It resolves stable prerequisite IDs through the trusted catalog and renders them as advisory links; it does not lock access, mark prerequisites complete, or infer mastery.

| Plan IDs | Capability implemented | Remaining acceptance work |
|---|---|---|
| `PLAN-ARC-008` | Server-built cross-volume search catalog for eighteen lessons; canonical `LES-0001` through `LES-0018` queries, deterministic ranking, and stable adjacency pass | Topic/role/difficulty filters, the next-batch generated metadata manifest, and disconnected-browser proof |
| `PLAN-WEB-005` | Stable lesson links, additive device-state migration, device-local bookmarks, recent history, resume, reading markers, clear/reset flow, and origin/privacy explanation | Browser restart, real cross-tab, storage-disabled, and offline interaction tests |
| `PLAN-WEB-011` | Safe malformed/unsupported-state recovery, visible storage fallback, empty/no-result search states, four invalid-route 404s, and strict port-3000 occupied-port refusal | Dependency-install, remaining start-failure, browser-injected, and runtime error UX |
| `PLAN-AUD-005` | Fixed allowlisted state schema and repeated UI boundaries keep reading actions separate from competency; 21 reader/search/adapter tests pass, including additive migration and independent-answer isolation | Full evidence lineage, mentor-output, and assessment-state audit |

## Current structured-content checkpoint

Schema v1 has strict lesson, assessment, and reference records; opaque IDs separate from aliases, routes, slugs, and curriculum IDs; permanent reservations for all five legacy lessons; and dependency-free repository validation. The committed corpus contains thirteen lessons (`LES-0006` through `LES-0018`), thirty-nine assessments, and 104 primary references across Volumes 00 through 03. The 39-case schema suite covers malformed and duplicate JSON, pinned schema policy, required/non-empty body sections, H1/title parity, CommonMark fence and raw-HTML ambiguity, URL normalization, independent answer isolation, safe lab realpaths and command policy, canonical-content and policy-file symlinks, dangling links and exact path/file case, legacy migration and collisions, canonical ownership, backlinks, and prerequisite cycles. On this restricted Windows token, 38 passed, zero failed, and the real policy-file symlink case skipped because file-symlink creation returned `EPERM`; that runtime case remains for Linux or symlink-capable Windows.

Content validation passes with `root-memory=6/6 markdown=61 local-links=47 explicit-anchors=0 heading-anchors=1774 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=13 assessments=39 references=104 legacy-reservations=5}`. The schema run reports 38 passes, zero failures, and one Windows `EPERM` symlink skip.

`LES-0006` / `V01-L06` / `LNX-005` is the first production lesson published through the schema-backed renderer and catalog adapter at `/book/linux/boot-kernel-systemd-journal`. Its 18 required sections, three diagrams, 12 read-only command cards, bounded guided lab, two incidents, two complete answer guides, independent transfer prompt, and reference set are marked `substantive-draft`. The five existing typed lessons remain authoritative for their routes, and their URLs and device-local IDs are unchanged.

`LES-0007` / `V00-L01` / `FND-001` is the second structured lesson at `/book/start/systems-thinking`. It adds the Volume 00 entry point, state/queue/dependency/failure-domain reasoning, three assessments, eight references, and a bounded local Ubuntu model. Commit `4c1b922` established the publishing contract, commit `24201bb` proved its first additive production path, and commit `817bb60` adds the second path. This is artifact-delivery evidence only: `substantive-draft`, publication, or a mentor-run verifier is not chapter acceptance, completed learner practice, retained knowledge, independent transfer, or learner mastery.

`LES-0008` / `V00-L02` / `DBG-001` is the third structured lesson at `/book/start/evidence-driven-troubleshooting`. It teaches FRAME from foundation through expert transfer, preserves proof boundaries, uses competing hypotheses and safe experiments, and separates mitigation, restoration, verification, causal analysis, and prevention. Its project checks and mentor-operated Ubuntu verifier pass, while formal acceptance and learner-operated evidence remain absent.

`LES-0009` through `LES-0018` add the safe workbench, Linux I/O and isolation, connectivity stack, and Bash/Python automation paths. Each has exactly 18 required sections, three assessments, eight references, and a guarded lab. Together the ten lesson bodies contain approximately 148,487 whitespace-delimited words. Passing project checks and mentor-operated verifiers do not constitute technical acceptance, learner practice, independent transfer, retained knowledge, or mastery.

## Recorded results versus current acceptance

The repository ledger records that, earlier in this 2026-08-02 work session, six local routes returned HTTP 200, an invalid lesson returned 404, selected night-mode color pairs measured at least 5.77:1, and bounded Ubuntu labs produced cleanup proof. Those remain historical results for the worktree state at the time they ran.

For the historical `836c29e` reader checkpoint, full lint, explicit typecheck, content validation, the escalated production build, eight reader/search tests, and `git diff --check` passed. Content validation reported all six memory files, 28 Markdown files, 38 valid local links, 307 heading anchors, 107 unique curriculum IDs, and all 46 requirements. The build retained only vinext route-classification and Node `module.register` deprecation warnings. Eleven declared routes returned 200 with exactly one `h1` and no external script/link/image assets; the search payload contained all five trusted lesson IDs; the reading desk and non-mastery boundary rendered; the invalid lesson returned 404; the temporary production server listened only on `127.0.0.1:4179` and was stopped cleanly. An attempted fresh registry audit was rejected before transmission because external manifest disclosure was not authorized; `package-lock.json` is unchanged from the prior zero-advisory audit, but no new registry result is claimed.

For `24201bb`, content validation reported `root-memory=6/6`, 30 Markdown files, 42 valid local links, zero explicit-anchor errors, 383 heading anchors, 107 unique curriculum IDs, all 46 requirements, three valid schemas, one structured lesson, three assessments, eight references, and five legacy reservations. The 36-case schema suite completed with 35 passes and the documented Windows `EPERM` symlink skip; all 17 reader/search/adapter tests, lint, explicit typecheck, production build, and patch checks passed. Twelve declared routes returned 200 with exactly one `h1` and no external executable assets; the structured route exposed the metadata-derived `substantive-draft` status and `REF-0008`; search returned all six lesson IDs; the invalid lesson returned 404; and the loopback-only server stopped cleanly. An escalated Ubuntu 24.04 matrix executed the lesson's 13 exact read-only runtime checks successfully with command output suppressed. Independent content and adapter re-audits passed after parser, safety, accuracy, and reference fixes.

For `817bb60`, content validation reported `root-memory=6/6`, 32 Markdown files, 44 valid local links, zero explicit-anchor errors, 485 heading anchors, 107 unique curriculum IDs, all 46 requirements, three valid schemas, two lessons, six assessments, 16 references, and five legacy reservations. Lint, explicit typecheck, production build, all 20 reader tests, and 38 of 39 schema cases passed; the remaining case was the documented Windows `EPERM` policy-symlink skip. Fourteen declared routes returned HTTP 200 with exactly one `h1` and no external executable assets, and both invalid lesson routes returned 404. The bounded `LES-0007` lifecycle verifier passed in Ubuntu 24.04 and confirmed its state was absent after cleanup. That verifier run was mentor-operated project evidence, not learner lab completion or competency evidence.

For checkpoint `22d3160`, content validation reports `root-memory=6/6 markdown=35 local-links=47 explicit-anchors=0 heading-anchors=640 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=3 assessments=9 references=24 legacy-reservations=5}`. Schema reports 38 passes plus one Windows `EPERM` skip; all 21 reader tests, lint, typecheck, and build pass with only known build warning classes. Fifteen declared routes return 200 with one `h1`, two invalid routes return 404, 15 discovered internal links are non-error, LES-0008 payload/prerequisite/assessment/reference/non-mastery checks pass, and search resolves `LES-0001` through `LES-0008`. The production listener was exactly `127.0.0.1:4186`, then stopped and the port was clear. The Ubuntu 24.04 LES-0008 verifier passes all three cases, its recorded refusal matrix, scoped answer isolation, cleanup, and absent final state. This is mentor project evidence, not formal acceptance, learner completion, or mastery.

For feature checkpoint `142fb826065b145333e5cae8a32d352468a11b34`, `HEAD` and `origin/main` matched after the non-force push. Content, schema, reader, lint, type, and build gates pass with the exact current counts above and only the known vinext classification plus Node `module.register` warning classes. ShellCheck passes all twenty new lab scripts. In Ubuntu 24.04, syntax and all ten `LES-0009` through `LES-0018` verifiers pass, all root probes refuse, final state and residue beneath `/tmp` are absent, and the three explicit `LES-0018` resumable-cleanup recovery states pass. The production HTTP audit passes 27 routes, 27 internal links, four invalid-route 404s, and five LES-0018 payload markers; exact PID 53188 was stopped and its loopback port was clear. Privacy, mojibake, conflict-marker, secret-shape, generated-residue, and raw-command-placeholder scans are clean.

These are repository and artifact checks, not learner evidence. No in-app browser surface was available, so keyboard, persistence, cross-tab, clipboard, night/mobile/print, visual, and disconnected interaction claims remain incomplete. Docker lifecycle/tamper execution, fresh-clone reproduction, formal review, learner evidence, and representative real-environment exercises also remain open.

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
| `FIND-004` | Medium | All twenty `lab.sh`/`verify.sh` scripts for `LES-0009` through `LES-0018` pass ShellCheck and Ubuntu `bash -n`; all ten verifiers and root refusals pass with final state absent. | Retain the exact transcripts and complete any broader legacy-script, concurrency, hostile-state, and representative real-environment matrices required by formal review |
| `FIND-008` | High | The current gate now compares current image ID, entrypoint, mounts/devices/ports, namespace modes, privilege and capabilities, security options, resource ceilings, restart/auto-remove, and exact generation-specific tmpfs options. The full legacy envelope is cleanup-only; status/shell require v2. Expanded static re-review found no remaining counterfeit path within the documented accidental-misuse threat model. | Run one-field-at-a-time counterfeit refusal, v1 migration, v2 `check`/`reset`, and normal cleanup tests after Docker integration is restored |
| `FIND-005` | Medium | The first production record now renders through the schema-backed catalog adapter with route, search, answer-isolation, lab, reference, and additive device-state parity; all five legacy URLs and IDs remain unchanged. | The original first-migration finding is closed. Migrate legacy lessons incrementally after parity checks, and replace eager full-content catalog metadata with a lightweight generated manifest before corpus growth makes it costly. |

## Gaps by program area

| Area | Present now | Missing before complete |
|---|---|---|
| Curriculum | Eighteen routed identities across Volumes 00 through 03, including thirteen schema-backed `LES-0006` through `LES-0018` lessons at `substantive-draft`, plus the full knowledge map | Formal review and learner evidence for current drafts; remaining Linux, engineering, delivery, Volumes 04-06, specialist tracks, real-environment transfers, and scheduled reference review |
| Website | Local launcher, landing page, four-volume routed book, reading controls, learning modes, validated eighteen-lesson search, thirteen-lesson structured renderer, advisory prerequisites, and device-local reading tools | Topic/role/difficulty filters, generated catalog manifest, evidence export, due-review scheduling, incremental legacy migration, browser restart/offline/cross-tab/keyboard/night/mobile validation, full failure UX, and accessibility/performance checks |
| Labs | Bounded ENOSPC fixture source, established Ubuntu-first patterns, ten new guarded labs, ShellCheck for all twenty new scripts, ten passing Ubuntu verifiers/root refusals, exact cleanup, and three LES-0018 recovery-state passes | Learner-operated evidence; Docker-in-Ubuntu restoration; common host/container/VM/Kubernetes harnesses; representative real-service/system exercises; remaining adversarial, concurrency, and failure-path matrices |
| Interviews | Role matrix, prompts, detailed answer guides, interactive interview mode, and thirty-nine validated schema-backed assessments across `LES-0006` through `LES-0018`, including thirteen answer-isolated transfers | Timed mocks, role-specific banks, independently reviewed learner answers, scoring calibration, and portfolio defense |
| Reliability evidence | Project ledger and one active incident simulation | Complete incident program, SLOs, observability, capacity, DR, projects, and independent learner transfer |
| Quality | Feature commit `142fb82` passes lint/typecheck/build/content, all 21 reader tests, 38 schema passes with one Windows `EPERM` skip, ShellCheck 20/20, Ubuntu verification for ten new labs, a 27-route/27-link/four-404 audit, exact listener cleanup, and source-hygiene scans | CI wiring, available browser surface for axe/keyboard/visual/print/persistence/network proof, Docker verification, remaining lab matrices, dependency-tree/license review, fresh-clone test, formal review, and public audit |

## Current learner state

- Linux storage exact-path/ENOSPC is recorded at L1.
- The learner correctly recalls that free blocks do not imply free inodes and selects `df -hT <path>` plus `df -i <path>`.
- The learner has not yet produced the required safe remediation, retained-data, recovered-write, cleanup, independent-transfer, or delayed-recall evidence.
- The remaining technical areas are unassessed. Published lessons must not change those entries.

## Next actions

1. Build the generated content manifest so lesson, assessment, reference, route, search, and state registration do not require repeated manual eager-import edits.
2. Author `LES-0019` through `LES-0023`: PowerShell automation, Go operational tooling, APIs/JSON/YAML/schema validation, testing/build/dependency reproducibility, and OCI/container-runtime foundations.
3. Keep all thirteen structured lessons at `substantive-draft`; complete formal technical/instructional review, independently reviewed learner transfer, delayed recall, and representative real-environment exercises without changing learner levels from project evidence.
4. Migrate legacy lessons incrementally only after route, text, search, answer, lab, and device-state parity checks.
5. Add search filters and browser-level persistence/keyboard/clipboard/night/mobile/print/visual tests when the in-app browser surface is available.
6. Restore Docker integration when available, then run the v2 lifecycle, full-boundary tamper/refusal, legacy migration, `check`, `reset`, and cleanup proof.
7. Complete remaining host-lab failure matrices, accessibility/privacy/performance checks, dependency/license review, CI wiring, and fresh-clone reproducibility.
8. Keep learner-operated `PLAN-LAB-102` at its current evidence gate; published content, reader actions, and prerequisite navigation must not auto-advance it.

## Update protocol

After each logical change:

1. update the relevant `MASTER_PLAN.md` status only when its stated acceptance scope changed;
2. append exact results or failures to `VERIFICATION.md`;
3. update this file's current/next/findings sections;
4. update `progress/ledger.md` only if reviewed learner evidence changed;
5. commit and push after validation, preserving unrelated work.
