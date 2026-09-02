# Contributing to Reliability Atlas

This repository is a public-quality engineering field manual, a local lab system, and an evidence-backed learning program. A future human or AI contributor must be able to understand a chapter without reading the chat that created it.

## Source-of-truth rules

- Git holds durable lessons, labs, diagrams, references, evidence, and reviewed progress.
- The website renders that knowledge; it is not the mastery authority.
- Browser reading position, theme, text size, bookmarks, and notes are conveniences only.
- `progress/ledger.md` changes only after reviewed learner evidence.
- Published means available to study, not mastered.
- Stable lesson IDs are never renamed or reused after publication.

## Add knowledge in dependency order

Before writing a chapter:

1. locate its volume and prerequisites in `book/README.md`;
2. decide the reader's expected starting knowledge;
3. identify the production failure or design decision the chapter enables;
4. choose the least powerful environment that safely demonstrates the mechanism;
5. separate guided instruction from independent mastery evidence.

Do not add a tool merely because it appears in a job description. Teach the underlying mechanism first, then show how the tool implements or exposes it.

## Required chapter shape

Follow `book/LESSON-STANDARD.md`. At minimum, a chapter contains:

```text
signal and first thought
  -> prerequisite words in plain and precise language
  -> system picture
  -> precise mechanism
  -> commands as evidence
  -> realistic output decoded field by field
  -> Ubuntu-first guided lab
  -> recovery and cleanup proof
  -> production and scale transfer
  -> retrieval and interview questions with complete model answers
  -> separate mastery challenge
```

Use plain technical language. Explain what an engineer should think when seeing a signal, then provide the exact term. Avoid unexplained acronyms, command dumps, and textbook definitions disconnected from operations.

## Lab environment decision

Use the smallest safe boundary:

| Learning goal | Environment |
|---|---|
| Observe host state | Ubuntu, read-only |
| Create bounded user files, sockets, or processes | Ubuntu, non-root temporary resources |
| Exhaust resources or manipulate namespaces and cgroups | Hardened Docker container |
| Change boot, systemd, kernel, firewall, LVM, or host mounts | Disposable VM |
| Teach reconciliation, Services, policy, scheduling, RBAC, or volumes | Local Kubernetes |

Every runnable block states privilege, mutation, network use, scope, stop conditions, expected observation, cleanup, and what the result does not prove.

## Safety review for shell examples

Before publishing, verify:

- every path variable is quoted;
- temporary paths use a lesson-specific `mktemp` prefix;
- cleanup checks a sentinel and exact ownership or identity;
- recursive deletion is avoided; when unavoidable, realpath, parent, prefix, owner, and sentinel are all validated;
- recorded PIDs are re-identified before signaling;
- ports are checked before binding and services bind to loopback unless remote access is the lesson;
- no command performs implicit `sudo`, installation, download, login, or cloud mutation;
- placeholders are visually different from exact runnable commands;
- destructive actions have a narrower reviewed filter than discovery actions;
- cleanup proves that files, sockets, processes, containers, or namespaces are absent.

## Structured content contract

The first five lessons currently use React and typed TypeScript data while the contract is stabilized. New content uses schema-v1 non-executable Markdown with strict JSON front matter:

```text
book/
|-- volumes/<volume-slug>/<LES-id>-<slug>/lesson.md
|-- assessments/<domain>/<ASM-id>.json
|-- references/<REF-id>.json
`-- schema/
```

Follow [`schema/README.md`](schema/README.md), inspect canonical and staged registries before allocating IDs, and run both contract commands before review. The canonical corpus contains thirty-six structured `substantive-draft` lessons, 108 assessments, and 345 references; all five legacy bodies are exact-identity migrations and no typed body remains. Staged `LES-0037` through `LES-0092` reserve `ASM-0094` through `ASM-0261` and `REF-0319` through `REF-1199`; the next free support IDs are `ASM-0277` and `REF-1227`. `LES-0004` alone has a tested complete-identity exception for its historical Volume-01/NET-003 combination; do not generalize it. Every chapter still requires formal review and independently reviewed learner evidence, and none establishes mastery. Choose editorial work from [`MASTER_PLAN.md`](../MASTER_PLAN.md). The permanent legacy map prevents reuse of any published identity or learning-state key.

After creating or moving structured lessons, assessments, or references, run `npm run generate:content-registry` from `learning-cockpit/` before validation. Commit the deterministic generated files with the content. Never hand-edit them; `npm run validate:content` rejects a stale registry.

Declare prerequisite lesson IDs only when the referenced concept is genuinely required. The reader resolves them through the trusted catalog and displays them as advisory links; contributors must not use a prerequisite to hide content, mutate reading state, infer completion, or award mastery. Unknown identities must fail validation rather than be converted into guessed routes.

The website should remain a renderer over structured content. Do not grow a single page or one giant TypeScript constant indefinitely. Do not migrate a typed lesson until route, text, diagram, answer, lab, search, and device-state compatibility are separately proven.

## Definition of done

A chapter is ready only when:

1. its prerequisites, objective, environment, risk, and limitations are explicit;
2. no prerequisite term or acronym is used before it is explained;
3. diagrams have text equivalents and a clear reading direction;
4. commands state their question, realistic output, every field and unit, interpretation branches, and what they do not prove;
5. every checkpoint and interview prompt includes a direct answer, first-year explanation, senior production answer, weak-answer analysis, evidence, and answered follow-ups;
6. the guided lab succeeds on its stated Ubuntu version;
7. abort, recovery, and cleanup paths are tested;
8. narrow lint, type, content, and build checks pass;
9. internal links and responsive navigation work;
10. paper, night, keyboard, reduced-motion, and print views remain readable;
11. no credential, employer data, internal URL, or secret is present;
12. the change is documented in the ledger as a project artifact, never as learner competency evidence.

## Validation commands

From `learning-cockpit/`:

```bash
npm run lint
npm run typecheck
npm run validate:content
npm run test:master-plan
npm run test:content-schema
npm run test:reference-freshness
npm run report:references -- --fail-overdue
npm run build
```

`npm run validate:content` also runs the master-plan contract. Every `PLAN-*` row must have a unique permanent ID, the documented row shape, a P0-P3 priority where applicable, non-empty acceptance and verification fields, and exactly one of `PENDING`, `IN_PROGRESS`, `BLOCKED`, `REVIEW_REQUIRED`, or `COMPLETE`. Do not introduce synonym statuses: completion audits depend on these values having one stable meaning.

The reference report scans canonical records plus every staged chapter's local support records. By default it warns 90 days before `reviewAfter` and fails malformed collection state; `--fail-overdue` also makes an expired review window fail CI. Use `--as-of YYYY-MM-DD` for reproducible review evidence and `--json` when another tool needs the complete result. A repeated URL is reported for editorial review but is not automatically an error because multiple lessons can legitimately cite the same primary source.

From the repository root, run the teaching-structure coverage audit as well:

```bash
node tools/audit-lesson-standard.mjs
```

For shell labs, run `shellcheck` when available, exercise each supported action, and prove cleanup from a fresh shell. Review the Git diff and scan for credentials, signed URLs, employer data, local paths, and secrets before committing.
