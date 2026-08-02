# Reliability Atlas Reader

An offline-first reading and practice interface for the evidence-driven DevOps, SRE, platform, data, and production-engineering field manual.

## Purpose

The cockpit trains five complementary learning behaviors:

- **See the system:** architecture, request path, state, and failure-flow diagrams.
- **Break the system:** choose-the-next-move incident decisions with immediate reasoning feedback.
- **Read the field manual:** retain the complete explanation, signal map, safe-recovery path, and lab instructions for each available topic.
- **Recall the system:** compact flashcards that require an answer before reveal.
- **Teach and defend:** Feynman notes and product-company interview drills.

The dashboard never raises mastery by itself. The repository ledger remains the evidence source of truth.

## Ready lessons

The reader currently publishes eight lessons across two volumes.

Volume 00 starts with:

1. Systems thinking: state, queues, dependencies, and failure domains.
2. Evidence-driven troubleshooting: FRAME, hypotheses, and safe moves.

Volume 01 publishes six Linux foundation lessons:

1. Filesystems, blocks, inodes, and ENOSPC.
2. Processes, signals, exit codes, and systemd.
3. CPU, load, memory pressure, swap, and OOM.
4. DNS, routing, TCP, TLS, HTTP, and sockets.
5. Identity, permissions, traversal, and least privilege.
6. Boot, kernel, initramfs, systemd, and the journal.

`LES-0007` and `LES-0008` in Volume 00 and `LES-0006` in Volume 01 are schema-backed `substantive-draft` lessons: available to study, but still subject to review. `LES-0008` adds the reusable FRAME worksheet, a bounded virtual Ubuntu incident lab, two complete-answer assessments, and answer-isolated `ASM-0009`; its project gates and mentor-operated Ubuntu verifier pass, while formal acceptance and learner evidence remain open. Linux lessons 1-5 retain their established reader implementations, routes, and device-local state IDs. Every availability label describes content state, not demonstrated mastery. The progress ledger remains authoritative.

Each explanatory lesson is designed to stand on its own: prerequisite vocabulary appears before the mechanism, Ubuntu command output is decoded field by field, and teaching checkpoints and product-company questions include answers from first-year foundations through senior production reasoning. Independent transfer assessments intentionally store no model answer. The page always separates:

```text
question -> evidence -> field meanings -> combined interpretation -> safest next proof
```

## Reader routes

- `/` - lightweight home, current mission, and learning map.
- `/book` - complete knowledge library and planned volumes.
- `/book/start` - Volume 00 index and safe operator foundation.
- `/book/start/<lesson-id>` - one Volume 00 lesson per URL.
- `/book/linux` - Ubuntu-first Volume 01 index and preflight.
- `/book/linux/<lesson-id>` - one statically generated lesson per URL.
- `/practice/storage` - practice separated from the explanatory chapter.
- `/search` - offline search by symptom, command, term, title, or stable lesson ID.
- `/my-learning` - device-local bookmarks, recent lessons, and private reading markers.

The routed structure keeps individual pages lightweight as the manual grows. Desktop uses a persistent table of contents; smaller screens use a collapsible book menu. Previous and next links stay inside a volume; an explicit continuation link crosses into the next volume. Structured lessons also show resolved prerequisite IDs in a labelled advisory navigation panel. Those links never lock access, mark completion, or infer mastery; unresolved identities do not become guessed routes.

## Local use

Prerequisite: Node.js 22.13 or newer. The validated local version is Node.js 26.4.0.

```bash
npm ci
npm run dev
```

Open `http://127.0.0.1:3000` in a local browser. No cloud deployment, account, credential, or external API is required.

On Windows, double-click `start-learning.cmd`. It installs locked dependencies on the first run, requires the exact loopback development endpoint `127.0.0.1:3000`, refuses startup when that port is already occupied, starts with the explicit port, and opens the site. Keep its command window open while learning; press `Ctrl+C` there to stop the server.

```text
start-learning.cmd
```

## Device-local data

Teach-back notes and reader preferences are stored only in browser `localStorage`. They are not sent to a server and are not competency evidence until submitted and reviewed.

| Key | Purpose |
|---|---|
| `devops-sre-teachback` | Private draft explanation |
| `field-manual-theme` | Paper or night reading mode |
| `field-manual-reading-size` | Compact, comfortable, or large body text |
| `field-manual-learning-library-v1` | Fixed lesson IDs, bookmarks, reading markers, and recent-open timestamps |

The floating reader controls also show page progress and provide a print view. Theme colors, keyboard focus, mobile navigation, and reduced-motion behavior are part of the reader contract.

Clear the relevant browser keys to reset local state. Search terms are not stored. The reading library has no free-text fields and never changes the competency ledger. Browser storage is origin-specific, so `localhost`, `127.0.0.1`, and different ports keep separate state. Do not enter employer information, credentials, secrets, or production data.

## Validation

```bash
npm run lint
npm run typecheck
npm run validate:content
npm run test:content-schema
npm run test:reader
npm run build
npm audit  # optional network-backed advisory check
```

The lockfile is committed for reproducible installation. `npm audit` sends dependency metadata to the configured npm registry, so run it only when that network disclosure is acceptable. Review findings rather than running `npm audit fix --force`, which may introduce breaking dependency changes.

The content validator checks the six project-memory files, local Markdown links and anchors, duplicate curriculum IDs, requirements 1-46 coverage, all three structured record schemas, reviewed schema-policy digests, permanent legacy identities, and live cross-record relationships without adding another package dependency. The current corpus has three lessons, nine assessments, and 24 references. Content validation reports `root-memory=6/6 markdown=35 local-links=47 explicit-anchors=0 heading-anchors=639 curriculum-ids=107 requirements=46/46`; the 39-case schema suite reports 38 passes plus one Windows `EPERM` symlink skip. The suite uses disposable repositories to exercise malformed or weakened schemas, title/heading parity, answer leakage, identity collisions, volume-aware routes and ordering, unsafe paths, case drift, symlinks, broken ownership, dangling links, prerequisite cycles, safe Markdown destinations, and the live corpus. Run the file-symlink case on Linux or symlink-capable Windows before a public release.

The 21-case reader suite passes for all eight lessons, including canonical `LES-0001` through `LES-0008` search, LES-0008 catalog/state migration, trusted prerequisite resolution, advisory prerequisite rendering, and `ASM-0009` answer isolation. The suite exercises malformed browser state, storage failures, trusted lesson IDs, bookmark and reading transitions, capped recent history, immutable legacy routes, volume-local adjacency, additive state migration, schema-backed lesson parsing, CommonMark heading/fence parity, answer isolation, safe links, multi-volume search ranking, and virtual-content loader refusal using Node's built-in test runner. The structured renderer consumes inert parsed Markdown and an explicit server-side catalog; it does not execute embedded HTML or publish assessment answers into search metadata.

`npm run dev` now validates canonical content before startup. Build and development load each structured lesson through an exact virtual-module registry that reads only its declared canonical Markdown path and registers that file for change watching. Unknown or path-like lesson IDs fail closed. Adding a structured lesson therefore requires an explicit registry entry until the planned generated manifest replaces this small fixed catalog.

---

## Implementation

- React 19 and vinext
- Device-local browser storage only
- No authentication, database, upload, or server-side persistence
- No external application API calls
- `.openai/hosting.json` contains no D1 or R2 bindings and is retained only for the starter build plugin
