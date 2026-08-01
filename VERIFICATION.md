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

## Current release gate

`PLAN-AUD-001` remains blocked by unavailable Docker-in-Ubuntu runtime verification and other pending P0 gates. The permissions-lab escape and incomplete Docker-envelope source findings are corrected and statically re-reviewed, but static review is not lifecycle evidence. Commit `aa3ede8` is a durable in-progress checkpoint; it must not be described as a publication-safe or accepted release until all P0 rows below pass and all failures have an explicit disposition.

### Repository and documentation

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-DOC-001` | Patch whitespace and conflict markers | `git diff --check` plus marker scan | `PASS` | No whitespace error or merge marker |
| `REL-DOC-002` | Only intended files changed | `git status --short`; full `git diff` review | `PASS` for checkpoint `aa3ede8` | Every change maps to a plan ID; no unrelated file or secret |
| `REL-DOC-003` | Root controls agree | Cross-check `MASTER_PLAN.md`, `PROGRESS.md`, `DECISIONS.md`, `VERIFICATION.md`, ledger | `PARTIAL` | Current statuses, blockers, evidence, and next actions agree; final full-ledger sign-off remains |
| `REL-DOC-004` | Markdown links and anchors | Local link/anchor checker | `PASS` | All scanned local links resolve, generated heading anchors are unique, and the corrected home practice route resolves |
| `REL-DOC-005` | Generated artifact hygiene | Inspect `tsconfig.tsbuildinfo` and build outputs before/after tests | `PASS` for checkpoint `aa3ede8` | `*.tsbuildinfo` is ignored; final validation leaves no other unexplained generated files |

### Website and content

Run from `learning-cockpit/` unless stated otherwise.

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-WEB-001` | Locked dependency install | `npm ci` in a clean dependency directory | `PENDING` | Exit 0 with lockfile unchanged; advisory output recorded |
| `REL-WEB-002` | Lint | `npm run lint` | `PASS` | Exit 0 against final worktree |
| `REL-WEB-003` | Type safety | `npm run typecheck` | `PASS` | No TypeScript error; type check does not emit tracked changes |
| `REL-WEB-004` | Production build | `npm run build` | `PASS` with two warning classes | Exit 0; vinext route-classification and Node `module.register` deprecation warnings retained |
| `REL-WEB-005` | Route matrix | Start loopback server; request `/`, `/book`, `/book/linux`, five lesson URLs, `/practice/storage`, and an invalid ID | `PASS` | Nine declared routes return 200 with one `h1` each; invalid lesson returns 404; no external script/link/image asset |
| `REL-WEB-006` | Navigation and links | Automated crawl plus manual desktop/mobile keyboard use | `PARTIAL` | Corrected home practice link resolves; full route/anchor crawl and manual focus/navigation review remain |
| `REL-WEB-007` | Content completeness | Validate required lesson sections, glossary, decoders, answers, labs, and IDs | `PARTIAL` | Current routes render expected structures and storage answer panels; full lesson-standard/schema audit remains |
| `REL-WEB-008` | Browser interactions | Exercise reading size, theme, progress, print, practice modes, note save/load, and storage-disabled fallback | `PARTIAL` | Storage answer panels start closed and reveal explicitly; remaining controls and failure states remain |
| `REL-WEB-009` | Error behavior | Invalid lesson, unavailable localStorage, occupied port, and failed start scenarios | `PARTIAL` | Invalid lesson returns 404; storage, port, and start failure cases remain |
| `REL-WEB-010` | Answer disclosure | Inspect storage answer panels before and after explicit reveal | `PASS` | Seven panels are closed initially, zero are eager-open, and answers require an explicit reveal action |

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

### Accessibility, privacy, security, and performance

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-A11Y-001` | Automated accessibility | axe or equivalent against all route templates | `PENDING` | No critical/serious violation; remaining issues documented |
| `REL-A11Y-002` | Keyboard and focus | Manual keyboard-only route/control/table/details navigation | `PENDING` | All functions reachable; visible focus; sensible order; no trap |
| `REL-A11Y-003` | Contrast and themes | Measure every text/control/state pair in paper and night modes | `PARTIAL` | WCAG AA for applicable text; selected prior pairs alone are insufficient |
| `REL-A11Y-004` | Responsive and print | Phone/tablet/desktop, zoom, long commands/tables/diagrams, print preview | `PENDING` | No hidden content, unusable overflow, or clipped essential information |
| `REL-SEC-001` | Secret and sensitive-data scan | Scan tracked/untracked source and full staged diff; manually review samples | `PASS` for checkpoint `aa3ede8`; Git-history scan not included | No credential, token, key, employer detail, internal URL, or production evidence |
| `REL-SEC-002` | Dependency audit | Authorized current registry-backed `npm audit` plus manual dependency-tree review | `PARTIAL`: current audit passed | Registry findings are absent or dispositioned, and the dependency-tree/license review is complete; historical offline zero alone is not closure |
| `REL-SEC-003` | External-request/privacy audit | Browser/network capture during normal reading and interactions | `PARTIAL` | Rendered routes contain no external script, link, or image assets; browser-network capture remains |
| `REL-SEC-004` | Loopback binding | Inspect listening socket during launch | `PENDING` | Website listens only on intended loopback address |
| `REL-PERF-001` | Build and route weight | Bundle/build output plus local page performance | `PENDING` | Agreed budgets established and met; no unnecessary graphics/framework weight |

### Reproducibility and release

| ID | Required check | Command or method | Current result | Acceptance |
|---|---|---|---|---|
| `REL-REP-001` | Fresh clone | Clone into an isolated path; follow only repository instructions | `PENDING` | Install, launch, navigate, and selected labs work without chat context |
| `REL-REP-002` | Offline normal reading | Disconnect after dependency bootstrap; start and read | `PENDING` | Normal book use requires no cloud account or external application API |
| `REL-REP-003` | Git review | `git diff`, `git diff --check`, secret scan, generated-file check | `PASS` for checkpoint `aa3ede8` | Logical, reviewable, safe diff |
| `REL-REP-004` | Commit and push | Non-interactive commit/push after all required checks | `PASS` for checkpoint `aa3ede8`; final audited release pending | `main` and `origin/main` match; no force push; commit ID recorded |

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
