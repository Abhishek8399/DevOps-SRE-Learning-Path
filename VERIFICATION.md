# Verification Register

Last updated: 2026-08-02

This register separates observed results from planned checks. A statement in a lesson, plan, or ledger is not silently converted into a test result.

## Result vocabulary

| Result | Meaning |
|---|---|
| `PASS` | The named command or observation actually succeeded for the stated revision and environment. |
| `FAIL` | The named check ran and exposed a defect. |
| `RECORDED PASS` | A repository record says the check passed, but this documentation task did not rerun it; scope and later edits are stated. |
| `PENDING` | Required before acceptance and not yet run against the final worktree. |
| `NOT RUN` | Deliberately not attempted in the stated context. |
| `BLOCKED` | Attempted or required, but the environment/authority prevented execution. |
| `NOT APPLICABLE` | The check does not apply to that artifact. |

## Evidence rules

- Record the exact command, date, environment, revision or worktree scope, result, and important output.
- A pass applies only to the tested state. Any relevant edit makes that acceptance check pending again.
- Never use mentor-generated output as learner competency evidence.
- Never replace a failed network-backed security result with a smaller offline result.
- Preserve failures and limitations; do not report only the final green command.

## Verification history

| ID | Date | Scope | Check | Result | Evidence and limitation |
|---|---|---|---|---|---|
| `VER-001` | 2026-08-02 | Commit `d958043` website | `npm run lint` | `PASS` | Reported in the completed five-lesson release work; no lint failure remained at that commit |
| `VER-002` | 2026-08-02 | Commit `d958043` website | `npm run build` | `PASS` | Production build completed; non-blocking vinext route-classification and Node deprecation warnings remained |
| `VER-003` | 2026-08-02 | Commit `d958043` local server | HTTP smoke and rendered-title checks | `PASS` | Loopback returned HTTP 200 and the index, five lesson titles, labs, optional checks, and interview prompts were observed |
| `VER-004` | 2026-08-02 | Commit `d958043` repository | Credential-shaped assignment scan | `PASS` | No credential-shaped assignment was reported; this is not a complete secret-history audit |
| `VER-005` | 2026-08-02 | Earlier routed-reader worktree | ESLint and production build | `RECORDED PASS` | `progress/ledger.md` records both passes; safety and documentation edits occurred afterward, so final rerun is pending |
| `VER-006` | 2026-08-02 | Earlier routed-reader worktree | Six expected routes return 200; invalid lesson returns 404 | `RECORDED PASS` | Recorded in `progress/ledger.md`; route implementation changed within the same uncommitted release and requires final rerun |
| `VER-007` | 2026-08-02 | Earlier reader theme | Key night-mode color pairs | `RECORDED PASS` | Ledger records measured contrast of 5.77:1 or higher; this is not a full WCAG/axe audit and must be rerun if colors changed |
| `VER-008` | 2026-08-02 | Earlier Ubuntu lab snippets | Storage, permissions, process, and loopback-network happy paths plus cleanup | `RECORDED PASS` | Ledger records Ubuntu 24.04 success; later adversarial safety review changed cleanup commands, so final matrix is pending |
| `VER-009` | 2026-07-31 | ENOSPC version 2 validation fixture | Separate remediation run | `PASS` | Inode use recovered from 100% to about 3%, retained data survived, and controlled file creation succeeded; this was mentor validation, not learner evidence |
| `VER-010` | 2026-08-02 | Earlier dependency installation state | Registry-backed install advisory summary | `FAIL` | The install reported 18 advisories: 1 low, 4 moderate, 13 high. This historical result is preserved; the later current registry-backed audit in `VER-024` found zero vulnerabilities |
| `VER-011` | 2026-08-02 | Dependency cache | `npm audit --offline --json` | `PASS` with limitation | Local cache returned zero advisories; it does not override `VER-010` because cached advisory data can be absent or stale |
| `VER-012` | 2026-08-02 | Current repository inspection | `git status --short`, `git diff --stat`, `git diff --name-status`, file inventory | `PASS` | Confirmed a dirty worktree with routed-reader, content, lab, and documentation work; no source file was assumed committed |
| `VER-013` | 2026-08-02 | Current `lab.sh` syntax attempt | WSL `bash -n` | `BLOCKED` | WSL returned `Wsl/Service/E_ACCESSDENIED`; no syntax result was obtained |
| `VER-014` | 2026-08-02 | Current `lab.sh` syntax attempt | Git Bash `bash -n` | `BLOCKED` | Git Bash could not create its signal pipe with Win32 error 5; static reading is not recorded as an automated pass |
| `VER-015` | 2026-08-02 | Earlier permissions cleanup revision | Adversarial child-symlink review | `FAIL` | At that revision, nested `app/config/settings` removal could follow a replaced intermediate symlink outside the lab. The corrected source-level result is recorded separately in `VER-016` |
| `VER-016` | 2026-08-02 | Corrected permissions cleanup | Static adversarial child-path re-review | `PASS` with limitation | Before deletion, `app` and `config` must be non-symlink owned directories at exact resolved paths, and `settings` must be a non-symlink owned regular file at its exact path. This closes the source-level finding from `VER-015`; Ubuntu symlink-refusal and normal-cleanup execution remain pending |
| `VER-017` | 2026-08-02 | Five rendered Ubuntu labs | Static safety and command-correctness re-review of storage, process, CPU/memory, loopback networking, and permissions snippets | `PASS` with limitation | Mutations are bounded to owned `/tmp` paths, one token/UID-verified child process, or one checked loopback listener; CPU/memory is read-only. Destructive steps revalidate identity and avoid recursive deletion. Static review does not prove shell parsing, concurrent race behavior, dependencies, or runtime cleanup |
| `VER-018` | 2026-08-02 | Current ENOSPC `lab.sh` and rendered cleanup guidance | Static five-field descriptor and legacy-retirement re-review | `PASS` with limitation | The five compared fields correctly keep v1 removal-only and v2-only for status/shell. This pass was limited to label/image-name/user/network/read-only behavior; the expanded boundary audit in `VER-027` found that calling those five fields the full hardened descriptor is insufficient |
| `VER-019` | 2026-08-02 | Current website worktree | `npm run lint` | `RECORDED PASS` | The release agent reports exit 0 after the latest edits; this documentation subtask did not rerun the command |
| `VER-020` | 2026-08-02 | Current website worktree in restricted Windows sandbox | First `npm run build` attempt | `FAIL` | Build startup hit Windows `spawn EPERM`. The environmental failure is preserved instead of being hidden; the identical escalated rerun is recorded separately |
| `VER-021` | 2026-08-02 | Current website worktree with approved escalation | Identical `npm run build` rerun | `RECORDED PASS` | The release agent reports a successful production build after leaving the process-spawn-restricted sandbox; this does not erase `VER-020` |
| `VER-022` | 2026-08-02 | Current website worktree | `npm run typecheck` | `RECORDED PASS` | The explicit typecheck passed after stale Cloudflare globals were replaced by a structural `ASSETS` binding and an unused `DB` binding was removed |
| `VER-023` | 2026-08-02 | Current repository in Ubuntu 24.04 | `bash -n` against both shell scripts | `RECORDED PASS` | The release agent reports syntax success for both scripts after the earlier Windows-sandbox attempts in `VER-013` and `VER-014` were blocked |
| `VER-024` | 2026-08-02 | Current dependency graph | `npm audit --audit-level=high` | `RECORDED PASS` | Current registry-backed output reported `found 0 vulnerabilities`; the earlier install warning remains in `VER-010` as historical evidence |
| `VER-025` | 2026-08-02 | Current generated TypeScript state | `git check-ignore -v -- learning-cockpit/tsconfig.tsbuildinfo` | `PASS` | `.gitignore:34:*.tsbuildinfo` matched the generated file; this proves that artifact is ignored, not that every possible build artifact has been audited |
| `VER-026` | 2026-08-02 | Canonical ID declarations in the five control/matrix documents | Namespace uniqueness script over first-column declaration rows | `PASS` | Found 114 unique `PLAN-*` IDs, 107 unique curriculum IDs, 8 unique `FIND-*` IDs, 25 unique `DEC-*` IDs, and 70 unique `VER-*`/`REL-*`/`LRN-*` IDs; each set had zero internal duplicates and the combined sets had zero cross-namespace collisions |
| `VER-027` | 2026-08-02 | Earlier five-field ENOSPC `lab.sh` ownership boundary | Expanded counterfeit-container static review | `FAIL` | `container_descriptor` compared only five fields. A same-name counterfeit with those values could retain host mounts, privileged/capability settings, omit no-new-privileges and resource ceilings, and still reach `lab.sh shell`. The corrected source-level result is recorded in `VER-028` |
| `VER-028` | 2026-08-02 | Corrected ENOSPC `lab.sh` ownership boundary | Expanded full-envelope static re-review | `PASS` with limitation | Status/shell require the current image ID, fixed entrypoint, v2 identity/tmpfs, isolated network/ports and namespaces, read-only/non-privileged runtime, dropped capabilities, no-new-privileges, exact limits, zero host exposure, and safe restart behavior. Cleanup accepts the full reviewed v2 or v1 envelope only, and v1 remains removal-only. Docker tamper/lifecycle execution is still blocked |
| `VER-029` | 2026-08-02 | Current repository in Ubuntu 24.04 | `bash -n` against all three shell scripts | `RECORDED PASS` | The release agent reports syntax success for `lab.sh`, `internal/verify-fixture.sh`, and `internal/inject-incident.sh` after the full-envelope, `check`, `reset`, and umask edits |
| `VER-030` | 2026-08-02 | Final post-source website worktree | `npm run lint` | `RECORDED PASS` | The release agent reports exit 0 after the final source edits |
| `VER-031` | 2026-08-02 | Final post-source website worktree | `npm run typecheck` | `RECORDED PASS` | The explicit no-emit TypeScript check completed without an error |
| `VER-032` | 2026-08-02 | Final post-source website worktree with approved process-spawn escalation | `npm run build` | `RECORDED PASS` | Production build completed; only vinext route-classification and Node `module.register` deprecation warnings remained |
| `VER-033` | 2026-08-02 | Final tracked worktree diff before this evidence-only update | `git diff --check` | `RECORDED PASS` | No tracked patch whitespace error was reported. The subsequently edited untracked control documents are checked separately in `VER-041` |
| `VER-034` | 2026-08-02 | Final post-source dependency graph | `npm audit --audit-level=high` | `RECORDED PASS` | Current registry-backed output reported zero vulnerabilities |
| `VER-035` | 2026-08-02 | Final post-source local reader | Nine-route HTTP and rendered-HTML audit plus invalid lesson | `RECORDED PASS` | All nine declared routes returned 200, each contained exactly one `h1`, and none contained an external `script`, `link`, or `img` asset. The invalid lesson returned 404 |
| `VER-036` | 2026-08-02 | Final storage lesson rendering | Answer-disclosure audit | `RECORDED PASS` | Storage rendered seven closed explicit-reveal answer panels and zero eager-open answer panels |
| `VER-037` | 2026-08-02 | Final home-page navigation | Practice-link regression | `RECORDED PASS` | The corrected home practice link resolves to the declared local practice route |
| `VER-038` | 2026-08-02 | Corrected permissions lab in Ubuntu 24.04 | Normal cleanup plus replaced-child-symlink refusal regression | `RECORDED PASS` | Normal cleanup succeeded. The child-symlink case was refused, the external target survived, and subsequent bounded lab cleanup succeeded |
| `VER-039` | 2026-08-02 | Final three shell scripts in Ubuntu 24.04 | `bash -n` | `RECORDED PASS` | `lab.sh`, `internal/verify-fixture.sh`, and `internal/inject-incident.sh` all passed after the final source edits |
| `VER-040` | 2026-08-02 | Docker profile-matching logic without a daemon | In-memory current/counterfeit/legacy cases | `RECORDED PASS` with limitation | The exact current profile was accepted, a one-bind counterfeit was refused, and legacy was refused shell access. This does not execute Docker lifecycle, cleanup, `check`, `reset`, or the complete tamper matrix |
| `VER-041` | 2026-08-02 | Final canonical ID declarations and four control documents | Namespace, target, table, whitespace, marker, and relative-link revalidation | `PASS` | Found 114 unique `PLAN-*` IDs, 107 unique curriculum IDs, 8 unique `FIND-*` IDs, 25 unique `DEC-*` IDs, and 84 unique `VER-*`/`REL-*`/`LRN-*` IDs; zero internal duplicates, cross-namespace collisions, missing plan targets, malformed tables, trailing whitespace, conflict markers, or missing relative links |
| `VER-042` | 2026-08-02 | Final repository content | `npm run validate:content` | `PASS` | Exit 0: `root-memory=6/6 markdown=28 local-links=38 explicit-anchors=0 heading-anchors=306 curriculum-ids=107 requirements=46/46` |
| `VER-043` | 2026-08-02 | Staged 41-file foundation checkpoint | Staged whitespace, conflict-marker, credential-shape, local-identity-path, generated-artifact, and independent read-only diff review | `PASS` | No blocker, unintended file, patch/build artifact, credential/private-key shape, user/employer path, false Docker claim, or false learner-mastery claim was found |
| `VER-044` | 2026-08-02 | Commit `aa3ede8` and `origin/main` | Commit, non-force push, branch-parity check, and exact revision readback | `PASS` | Commit `aa3ede8fd8f20c5b05fea8f6afaadaaf7fa7338e` was pushed; `git status --branch --short` reported `main...origin/main` with no worktree changes |
| `VER-045` | 2026-08-02 | Initial offline-reader worktree in restricted Windows sandbox | First `npm run test:reader` attempt | `FAIL` | Node test startup hit `spawn EPERM`. The environmental failure is preserved; the identical escalated rerun is separate |
| `VER-046` | 2026-08-02 | Initial offline-reader worktree with approved process-spawn escalation | Identical `npm run test:reader` rerun | `PASS` | Seven dependency-free state and search tests passed |
| `VER-047` | 2026-08-02 | Offline-reader worktree | `npm run typecheck` | `PASS` | TypeScript no-emit check completed without error |
| `VER-048` | 2026-08-02 | Offline-reader components | Targeted ESLint over search, reading desk, navigation, copy, and lesson integration | `PASS` | Exit 0 |
| `VER-049` | 2026-08-02 | Tracked reader changes before staging | `git diff --check` | `PASS` with limitation | No tracked whitespace error; untracked files require staged/full-source review |
| `VER-050` | 2026-08-02 | Integrated offline-reader worktree | Full lint, typecheck, and content validator | `PASS` | Lint and typecheck exited 0; content remained `root-memory=6/6 markdown=28 local-links=38 explicit-anchors=0 heading-anchors=306 curriculum-ids=107 requirements=46/46` |
| `VER-051` | 2026-08-02 | Integrated offline-reader worktree with approved process-spawn escalation | `npm run build` | `PASS` | Production build completed; only vinext route-classification and Node `module.register` deprecation warning classes remained |
| `VER-052` | 2026-08-02 | Built offline-reader worktree on temporary loopback server | Eleven-route HTML, 404, external-asset, listener, and cleanup smoke | `PASS` | Eleven declared routes returned 200 with one `h1` and zero external script/link/image assets; invalid lesson returned 404; listener was exactly `127.0.0.1:4179`; exact server stopped with no remaining listener |
| `VER-053` | 2026-08-02 | Unchanged locked dependency graph | Fresh `npm audit --audit-level=high` attempt | `BLOCKED` | Execution was rejected before registry transmission because manifest disclosure was not explicitly authorized. `package-lock.json` is unchanged from `VER-034`; no fresh result is claimed and no workaround was attempted |
| `VER-054` | 2026-08-02 | Reader worktree after storage, focus, contrast, and copy-label review fixes | `npm run test:reader` | `PASS` | Eight of eight tests passed, including safe persisted-state removal and clear refusal |
| `VER-055` | 2026-08-02 | Reader worktree after review fixes | Full lint, typecheck, tracked whitespace check, and independent read-only blocker review | `PASS` with limitation | Commands passed and review found no Critical, High, or Medium issue; production-catalog fixtures and browser-level interaction/visual QA remain |
| `VER-056` | 2026-08-02 | Final post-review reader and documentation worktree | Lint, typecheck, content validation, reader tests, production build, enhanced eleven-route smoke, payload assertions, exact listener, and cleanup | `PASS` with limitation | Content reported `root-memory=6/6 markdown=28 local-links=38 explicit-anchors=0 heading-anchors=307 curriculum-ids=107 requirements=46/46`; eight tests passed; build retained two known warning classes; all routes/404/assets passed; search exposed five trusted IDs; non-mastery/lesson controls rendered; loopback server stopped cleanly. Manual browser interaction and visual QA remain |
| `VER-057` | 2026-08-02 | Staged 30-file reader checkpoint and commit `836c29e` | Staged name/stat/whitespace review, credential/private-key/token/local-identity scan, commit, non-force push, and revision parity | `PASS` | No unexpected file or sensitive/local path shape was found; commit `836c29ead467aca21a840a04e73a995ac0dc3945` was pushed; `HEAD` and `origin/main` matched exactly afterward |
| `VER-058` | 2026-08-02 | Intermediate structured-content hardening worktree | First post-review `npm run test:content-schema` rerun | `FAIL` | 17 passed and 9 failed: assessment-domain logic referenced an undefined variable and the canonical-path fixture used the wrong volume. Both defects were corrected before the green runs below; live validation had passed only because the structured production corpus was empty |
| `VER-059` | 2026-08-02 | Hardened structured-content contract worktree | `npm run test:content-schema` and adversarial review | `PASS` with one platform skip | 34 tests ran: 33 passed and the real policy-file symlink case skipped because this restricted Windows token cannot create file symlinks (`EPERM`). Executed cases cover malformed JSON/fences/HTML, URL normalization, answer isolation, schema weakening, immutable legacy identity, exact path/case, ownership, directory/junction containment, backlinks, and cycles; policy-file symlink refusal is implemented and remains a fresh-clone/privileged-platform runtime check |
| `VER-060` | 2026-08-02 | Structured-content worktree in restricted Windows sandbox | First `npm run test:reader`, then dependency-free isolation fix and identical script rerun | `PASS` after preserved environmental failure | The first command hit `spawn EPERM`; adding `--test-isolation=none` avoided child-process creation and the package script then passed all 8 reader/search tests without escalation |
| `VER-061` | 2026-08-02 | Integrated structured-content worktree | Lint, typecheck, content validation, JSON/Node syntax, production build, and patch whitespace | `PASS` with known build warnings | Lint/typecheck/syntax/whitespace passed; content reported `root-memory=6/6 markdown=29 local-links=42 explicit-anchors=0 heading-anchors=318 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=0 assessments=0 references=0 legacy-reservations=5}`; production build completed with only the existing vinext route-classification and Node `module.register` warning classes |
| `VER-062` | 2026-08-02 | Structured-content checkpoint review | Two independent read-only schema/security reviews plus targeted follow-up probes | `PASS` with scope limitation | All reported High/Medium findings were corrected and re-probed. The live structured corpus is intentionally empty, so this proves the publishing contract and disposable cross-record behavior, not a production chapter, browser rendering parity, public release, or learner mastery |
| `VER-063` | 2026-08-02 | Staged 25-file structured-content checkpoint and commit `4c1b922` | Staged name/stat/whitespace review, credential/private-key/local-identity scan, commit, non-force push, and exact revision parity | `PASS` | No unintended path, patch error, conflict marker, secret shape, or local identity path was found. Commit `4c1b9220d3caa339224e2dcc2f59e4af5657f0f4` was pushed; `HEAD` and `origin/main` matched exactly and `git status --branch --short` reported `main...origin/main` afterward |
| `VER-064` | 2026-08-02 | Initial LES-0006 lesson, adapter, renderer, and catalog worktree before independent review | Content validation, schema suite, reader suite, lint, typecheck, build, and structured-route assertions | `PASS` with pre-audit scope | The live corpus contained 1 lesson, 3 assessments, and 7 references; 16 reader tests and the initial structured route passed. This was a pre-audit result and was superseded by the corrected final checkpoint below |
| `VER-065` | 2026-08-02 | First production-route harness attempt | Twelve-route/404/listener smoke harness | `FAIL` in the harness only | The harness treated a single PowerShell listener object as an array and rejected the result shape. The server was stopped cleanly; no application-route failure was established, and the harness was corrected before rerun |
| `VER-066` | 2026-08-02 | Corrected pre-audit LES-0006 route harness | Twelve routes, one-H1 assertions, structured payload, six-ID search, 404, exact listener, and cleanup | `PASS` | All 12 declared routes returned 200 with one `h1`; the structured lesson and six searchable identities rendered; the invalid lesson returned 404; the listener was `127.0.0.1:4179`; cleanup removed the listener |
| `VER-067` | 2026-08-02 | LES-0006 independent content and adapter review | Three independent read-only audits plus targeted parser probes | `FAIL`, findings corrected | Review found CommonMark fence-parity gaps plus lesson safety, semantic-accuracy, field-decoding, answer-transfer, and reference-coverage gaps. No checkpoint was released from this state; each finding was fixed and re-audited in `VER-068` |
| `VER-068` | 2026-08-02 | Final post-review LES-0006 worktree | Content validation, 36-case schema suite, 17-case reader suite, lint, typecheck, production build, targeted probes, and independent re-audits | `PASS` with one platform skip and known build warnings | Content reported `root-memory=6/6 markdown=30 local-links=42 explicit-anchors=0 heading-anchors=383 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=1 assessments=3 references=8 legacy-reservations=5}`; schema tests passed 35 with one Windows `EPERM` symlink skip; all 17 reader tests passed; re-audits found no remaining blocker; build retained only documented non-fatal warnings |
| `VER-069` | 2026-08-02 | Exact LES-0006 command matrix in Ubuntu 24.04 through WSL | First read-only matrix attempt | `BLOCKED` by sandbox | WSL startup returned `Wsl/Service/E_ACCESSDENIED`; no lesson command result was inferred from the blocked run |
| `VER-070` | 2026-08-02 | Approved Ubuntu 24.04 WSL execution | Thirteen exact read-only boot, PID 1, kernel, journal, socket, unit, and property checks with output suppressed | `PASS` | All 13 lesson commands completed successfully without mutation; this verifies command compatibility in the stated environment, not incident recovery or learner skill |
| `VER-071` | 2026-08-02 | Final built LES-0006 reader on temporary loopback server | Twelve routes, H1 count, executable-asset scan, structured status/reference payload, six-ID search, 404, listener, and cleanup | `PASS` | All declared routes returned 200 with one `h1`; external executable/style assets were absent; metadata-derived `substantive-draft` and `REF-0008` rendered; all six lesson IDs were searchable; invalid route returned 404; exact loopback listener stopped cleanly |
| `VER-072` | 2026-08-02 | In-app browser QA attempt | Browser runtime setup followed by browser-instance discovery | `BLOCKED` by environment | Runtime setup completed but no browser instance was available. No manual or automated visual, keyboard, persistence, clipboard, responsive, print, or network-capture claim is made |
| `VER-073` | 2026-08-02 | Staged 37-file LES-0006 feature and commit `24201bb` | Staged name/stat/whitespace review, conflict/credential/private-key/token/local-identity scans, commit, non-force push, and exact revision parity | `PASS` | No unexpected path, whitespace error, conflict marker, secret shape, or local identity path was found. Commit `24201bb3694304323e925402ae935f88d3ed086c` was pushed and `HEAD` matched `origin/main` exactly afterward |
| `VER-074` | 2026-08-02 | Five-document LES-0006 evidence follow-up worktree | Root-control consistency audit, `git diff --check`, content validation, schema suite, and reader suite | `PASS` with one inherited platform skip | Independent audit found and then confirmed closure of two stale current-state descriptions. Final content reported `root-memory=6/6 markdown=30 local-links=43 explicit-anchors=0 heading-anchors=383 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=1 assessments=3 references=8 legacy-reservations=5}`; schema remained 35 pass plus one Windows `EPERM` skip; all 17 reader tests passed; no learner level changed |
| `VER-075` | 2026-08-02 | Current LES-0007 lesson, assessments, references, and bounded queue-model lab | Exact lesson-to-lab contract review and independent content review | `PASS` with acceptance limitation | The substantive draft contains all 18 required sections, 3 diagrams, 6 field decoders, 12 command cards, 2 incidents, 3 assessments, and 8 primary references. Lesson commands, filenames, fields, profiles, and cleanup claims align with the executable lab. This is artifact review, not formal chapter acceptance or learner evidence |
| `VER-076` | 2026-08-02 | Initial cross-volume reader integration | Independent architecture, security, compatibility, and answer-isolation audit | `FAIL`, findings corrected | The audit found global rather than volume-local pagination, validator/runtime heading-parity drift, missing pre-development validation, incorrect cross-volume search labels and tie-breaking, a stale Linux lesson count, and missing direct virtual-loader tests. All findings were corrected before the final suites below; no Critical or High issue was found |
| `VER-077` | 2026-08-02 | WSL distribution discovery in restricted Windows sandbox | Initial `wsl --list --verbose` attempt | `BLOCKED` | WSL returned `Wsl/Service/E_ACCESSDENIED`; no distribution or lab result was inferred from the blocked attempt |
| `VER-078` | 2026-08-02 | Approved WSL distribution discovery | Identical distribution query with approved escalation | `PASS` | Ubuntu 24.04 was present and running; this environment fact does not itself verify a lesson or learner action |
| `VER-079` | 2026-08-02 | LES-0007 lab in Ubuntu 24.04 through WSL | `bash -n lab.sh`, `bash -n verify.sh`, `bash verify.sh`, then `bash lab.sh check` | `PASS` | Verifier reported `verification_passed=true`, profiles `stable,saturated,recovered`, repeat-run/manifest-tamper/unexpected-artifact refusals, and `cleanup_proven=true`; the post-run check reported `state=absent`. Execution used bounded virtual time, normal-user scope, no network, Docker, sudo, package install, or listening port. This mentor-operated run is not learner completion evidence |
| `VER-080` | 2026-08-02 | Post-audit LES-0007 application and repository worktree | Content validation, 39-case schema suite, 20-case reader suite, lint, typecheck, and patch whitespace | `PASS` with one inherited platform skip | Content reported `root-memory=6/6 markdown=32 local-links=44 explicit-anchors=0 heading-anchors=485 curriculum-ids=107 requirements=46/46 structured={schemas=3/3 lessons=2 assessments=6 references=16 legacy-reservations=5}`; schema passed 38 cases with the documented Windows `EPERM` policy-symlink skip; all 20 reader tests, lint, typecheck, and patch whitespace passed. These checks do not imply curriculum acceptance |
| `VER-081` | 2026-08-02 | First final production-build attempt | `npm run build` | `FAIL` | Build could not replace `dist/server/index.js` because a verified temporary production-server process created during this work still held the file (`EBUSY`, PID 46940, loopback port 4179). The exact process was stopped and absence was checked before retry |
| `VER-082` | 2026-08-02 | Same worktree after exact temporary-process cleanup | Identical `npm run build` rerun | `PASS` | Production build completed; only the existing vinext route-classification and Node `module.register` deprecation warning classes remained |
| `VER-083` | 2026-08-02 | Fresh production build on exact temporary loopback server | Fourteen-route, H1, external-asset, payload, two-invalid-route, listener, and cleanup smoke | `PASS` | All 14 declared routes returned 200 with one `h1` and no external executable asset. Search exposed all seven lesson identities; LES-0007 exposed its non-mastery status, lab cleanup proof, `REF-0016`, and `ASM-0006`; both invalid volume lesson URLs returned 404. The exact `127.0.0.1:4184` listener process was stopped and the port was clear |
| `VER-084` | 2026-08-02 | Fresh development server on exact temporary loopback server | Volume routes, structured lesson, search, virtual-content payload, and cleanup smoke | `PASS` | Four representative routes returned 200 with one `h1`; LES-0007 exposed `REF-0016`, proving the allowlisted virtual Markdown module loaded canonical content in development. The exact `127.0.0.1:4183` process was stopped and its listeners were absent |
| `VER-085` | 2026-08-02 | In-app browser QA attempt for the LES-0007 reader | Browser runtime setup, required troubleshooting, and browser-instance discovery | `BLOCKED` by environment | Runtime setup completed, but no browser instance was available. No visual, keyboard, persistence, cross-tab, clipboard, responsive, print, or browser-network-capture claim is made |
| `VER-086` | 2026-08-02 | Staged 56-file LES-0007 checkpoint and commit `817bb60` | Staged inventory/stat/whitespace review, merge-marker/generated-artifact/known-secret/local-identity scans, commit, non-force push, and exact revision parity | `PASS` | No unintended file, patch error, marker, generated artifact, known key/secret shape, or local user/employer path was found. One broad credential scan matched only the parser assertion that URL username/password fields are empty. Commit `817bb609cd2957d5b183246612dc2b078cfb2cb3` was pushed and `HEAD` matched `origin/main` immediately afterward |

## Current release gate

`PLAN-AUD-001` remains blocked by unavailable Docker-in-Ubuntu runtime verification and other pending P0 gates. The permissions-lab escape and incomplete Docker-envelope source findings are corrected and statically re-reviewed, but static review is not lifecycle evidence. Commit `817bb60` is the latest durable substantive checkpoint; both structured lessons are only `substantive-draft` and must not be described as a publication-safe release, an accepted chapter, or learner mastery until the corresponding gates pass and all failures have an explicit disposition.

### Repository and documentation

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-DOC-001` | Patch whitespace and conflict markers | `git diff --check` plus marker scan | `PASS` | No whitespace error or merge marker |
| `REL-DOC-002` | Only intended files changed | `git status --short`; full `git diff` review | `PASS` for checkpoint `817bb60` | Every feature change maps to a plan ID; no unrelated file or secret was staged |
| `REL-DOC-003` | Root controls agree | Cross-check `MASTER_PLAN.md`, `PROGRESS.md`, `DECISIONS.md`, `VERIFICATION.md`, ledger | `PARTIAL` | Current statuses, blockers, evidence, and next actions agree; final full-ledger sign-off remains |
| `REL-DOC-004` | Markdown links and anchors | Local link/anchor checker | `PASS` | All scanned local links resolve, generated heading anchors are unique, and the corrected home practice route resolves |
| `REL-DOC-005` | Generated artifact hygiene | Inspect `tsconfig.tsbuildinfo` and build outputs before/after tests | `PASS` for checkpoint `817bb60` | `*.tsbuildinfo` remains ignored; feature validation left no unexplained generated source artifact |

### Website and content

Run from `learning-cockpit/` unless stated otherwise.

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-WEB-001` | Locked dependency install | `npm ci` in a clean dependency directory | `PENDING` | Exit 0 with lockfile unchanged; advisory output recorded |
| `REL-WEB-002` | Lint | `npm run lint` | `PASS` | Exit 0 against final worktree |
| `REL-WEB-003` | Type safety | `npm run typecheck` | `PASS` | No TypeScript error; type check does not emit tracked changes |
| `REL-WEB-004` | Production build | `npm run build` | `PASS` with two warning classes | Exit 0; vinext route-classification and Node `module.register` deprecation warnings retained |
| `REL-WEB-005` | Route matrix | Start loopback server; request all declared volume, lesson, practice, search, and learning routes plus invalid IDs | `PASS` | Fourteen declared routes return 200 with one `h1` each; invalid lessons in both volumes return 404; no external executable/style asset |
| `REL-WEB-006` | Navigation and links | Automated crawl plus manual desktop/mobile keyboard use | `PARTIAL` | Current-page `aria-current`, corrected practice link, and all declared routes work; full internal crawl and manual focus/navigation review remain |
| `REL-WEB-007` | Content completeness | Validate required lesson sections, glossary, decoders, answers, labs, and IDs | `PARTIAL` | LES-0006 and LES-0007 each validate the required structured sections and linked artifacts; the corpus has 2 lessons, 6 assessments, and 16 references. Full chapter acceptance and remaining-curriculum audits remain |
| `REL-WEB-008` | Browser interactions | Exercise reading size, theme, progress, print, practice modes, reading desk, search, copy, and storage-disabled fallback | `PARTIAL` | Pure reading-state/search transitions and answer disclosure pass; browser persistence, cross-tab sync, shortcuts, reset, clipboard, and visual states remain |
| `REL-WEB-009` | Error behavior | Invalid lesson, malformed/unavailable localStorage, occupied port, and failed start scenarios | `PARTIAL` | Invalid lesson and pure malformed/unavailable storage logic are tested; browser injection, port, dependency, and start failure cases remain |
| `REL-WEB-010` | Answer disclosure and isolation | Inspect storage panels and structured assessment projections | `PASS` with scoped browser limitation | Seven storage panels remain closed initially; each structured lesson exposes two complete answer guides while its independent transfer projection excludes answer fields. Browser interaction remains unverified |
| `REL-WEB-011` | Reader state, search, adapter, and isolation suite | `npm run test:reader` | `PASS` | Twenty dependency-free tests cover schema recovery, storage failure/clear, transitions, recents, deterministic cross-volume search, additive state migration, structured parsing, virtual-loader allowlisting, and independent-answer isolation |
| `REL-WEB-012` | Clipboard and assistive interaction | Real browser success/refusal, keyboard, focus, and announcement checks | `PENDING` | Copy works or gives usable manual guidance; controls have correct accessible feedback |

### Lab safety and execution

Run inside the stated Ubuntu 24.04 environment. Do not substitute Windows, production, employer, or privileged host state.

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-LAB-001` | Shell syntax | `bash -n` for every repository shell script | `PASS` | Exit 0 in approved Ubuntu environment |
| `REL-LAB-002` | Static shell analysis | `shellcheck` when installed | `PENDING` | No unreviewed error/warning; suppressions are justified |
| `REL-LAB-003` | Root refusal | Run each host-mutation setup as root only in a safe test harness | `PENDING` | No file, process, listener, or stale-variable mutation occurs |
| `REL-LAB-004` | Temp-path boundary | Set a hostile `TMPDIR`; run setup/cleanup | `PENDING` | Creation remains in explicit `/tmp/sre-<lesson>.*`; cleanup proves path, parent, prefix, UID, sentinel |
| `REL-LAB-005` | Storage Ubuntu lab | Happy path, stale variable, wrong owner/sentinel, unexpected file, failed `rmdir`, cleanup retry | `PENDING` | Only 100 objects plus sentinel are created; refusal paths preserve state; cleanup proves absence |
| `REL-LAB-006` | Process lab | Happy path, missing PID, stale/reused PID, wrong UID/token | `PENDING` | Only exact token/UID child is signaled; graceful exit and absence proven |
| `REL-LAB-007` | Loopback lab | Free/occupied port, start failure, dead/reused PID, wrong directory, unexpected file, lost variable, cleanup retry | `PENDING` | Binds only 127.0.0.1; unique response; unrelated PID/listener untouched; file/socket/process absence proven |
| `REL-LAB-008` | Permissions lab | Happy path, root, wrong owner/sentinel, unexpected file, child symlink, cleanup retry | `PARTIAL`: normal and symlink regression passed | Child symlink is refused, external target survives, bounded normal cleanup succeeds; remaining misuse cases pass |
| `REL-LAB-009` | ENOSPC v2 fixture | `bash lab.sh setup`, status, check, internal verifier, remediation, retained-data/write checks, reset, cleanup | `BLOCKED`: Docker unavailable in Ubuntu | Real bounded ENOSPC; strict v2 envelope enforcement; check/reset, remediation, and cleanup pass |
| `REL-LAB-010` | Counterfeit container refusal | Create safe test containers with one envelope mismatch at a time | `PARTIAL`: in-memory bind case passed; Docker unavailable | Only the complete hardened v2 boundary permits status/shell; only the exact reviewed v2 or removal-only v1 boundary permits cleanup; every other mismatch is refused |
| `REL-LAB-011` | Legacy-v1 fixture retirement | Exercise exact v1 status/shell refusal, cleanup, v2 setup, v2 status/shell, and final cleanup | `PARTIAL`: in-memory shell refusal passed; Docker unavailable | Exact v1 can be removed but never opened as a lesson shell; unrelated descriptors remain untouched; rebuilt v2 is hardened and removable |
| `REL-LAB-012` | Hardened runtime boundary | Vary binds, structured mounts, privilege, capabilities, security options, PIDs, memory/swap/CPU, tmpfs, namespaces, restart, and image identity one at a time | `PARTIAL`: exact current and one-bind logic passed; Docker unavailable | Any safety-relevant mismatch prevents status/shell, and cleanup never accepts a container outside the two explicitly reviewed removal envelopes |
| `REL-LAB-013` | LES-0007 bounded systems model | Syntax, stable/saturated/recovered profiles, repeat-run, manifest-tamper, unexpected-artifact, cleanup, and post-cleanup absence | `PASS` for mentor-operated project verifier | Ubuntu 24.04 verifier and cleanup pass without root, network, Docker, packages, or ports; learner execution, hostile `TMPDIR`, and ShellCheck remain separate evidence gates |

### Accessibility, privacy, security, and performance

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-A11Y-001` | Automated accessibility | axe or equivalent against all route templates | `PENDING` | No critical/serious violation; remaining issues documented |
| `REL-A11Y-002` | Keyboard and focus | Manual keyboard-only route/control/table/details navigation | `PENDING` | All functions reachable; visible focus; sensible order; no trap |
| `REL-A11Y-003` | Contrast and themes | Measure every text/control/state pair in paper and night modes | `PARTIAL` | WCAG AA for applicable text; selected prior pairs alone are insufficient |
| `REL-A11Y-004` | Responsive and print | Phone/tablet/desktop, zoom, long commands/tables/diagrams, print preview | `PENDING` | No hidden content, unusable overflow, or clipped essential information |
| `REL-SEC-001` | Secret and sensitive-data scan | Scan tracked/untracked source and full staged diff; manually review samples | `PASS` for checkpoint `817bb60`; Git-history scan not included | No credential, token, key, employer detail, internal URL, local identity path, or production evidence was found; the single broad-pattern parser match was an explicit empty-username/password safety check |
| `REL-SEC-002` | Dependency audit | Authorized current registry-backed `npm audit` plus manual dependency-tree review | `PARTIAL`: lockfile unchanged since prior zero-advisory audit; fresh request blocked | Registry findings are absent or dispositioned, and the dependency-tree/license review is complete; no unapproved manifest disclosure |
| `REL-SEC-003` | External-request/privacy audit | Browser/network capture during normal reading and interactions | `PARTIAL` | Fourteen rendered routes contain no external executable/style assets; browser-network capture remains unavailable and unclaimed |
| `REL-SEC-004` | Loopback binding | Inspect listening socket during launch | `PASS` for current production smoke | Temporary server listened exactly on `127.0.0.1:4184` and stopped cleanly; fresh-clone launcher smoke remains separate |
| `REL-PERF-001` | Build and route weight | Bundle/build output plus local page performance | `PENDING` | Agreed budgets established and met; no unnecessary graphics/framework weight |

### Reproducibility and release

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-REP-001` | Fresh clone | Clone into an isolated path; follow only repository instructions | `PENDING` | Install, launch, navigate, and selected labs work without chat context |
| `REL-REP-002` | Offline normal reading | Disconnect after dependency bootstrap; start and read | `PENDING` | Normal book use requires no cloud account or external application API |
| `REL-REP-003` | Git review | `git diff`, `git diff --check`, secret scan, generated-file check | `PASS` for checkpoint `817bb60` | Logical, reviewable, safe feature diff |
| `REL-REP-004` | Commit and push | Non-interactive commit/push after all required checks | `PASS` for checkpoint `817bb60`; final audited release pending | `main` and `origin/main` matched exactly after the non-force push; full commit ID is recorded in `VER-086` |

## Learner-evidence verification

These checks are intentionally separate from project release verification.

| ID | Evidence gate | Current result | Pass condition |
|---|---|---|---|
| `LRN-101` | Block-versus-inode explanation | `PASS` at coached L1 scope | Correctly distinguishes bytes from object records and uses exact-path `df -hT` plus `df -i` |
| `LRN-102` | Safe inode-population selection | `PENDING` | Learner identifies only the approved `.part` population and states why directory name is not authorization |
| `LRN-103` | Remediation and retained data | `PENDING` | Learner deletes only approved fixture files and proves retained data survives |
| `LRN-104` | User-operation recovery | `PENDING` | Learner proves inode headroom and successful controlled file creation, then cleans the test file |
| `LRN-105` | Independent unfamiliar transfer | `PENDING` | Learner diagnoses a changed case without answer-key dependence and explains evidence/safety |
| `LRN-106` | Delayed recall | `PENDING` | Correct explanation and decision path after a separated review interval |

No entry after `LRN-101` may be marked pass from mentor-operated fixture output.

## Release sign-off template

When `PLAN-AUD-001` is ready, append a dated entry containing:

```text
Revision or commit:
Environment:
Commands run:
Passed IDs:
Failed or waived IDs and rationale:
Open risks:
Generated-file state:
Secret/dependency result:
Fresh-clone result:
Reviewer:
Decision: accepted / rejected
```
