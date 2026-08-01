# Systems Reliability Field Manual Reader

An offline-first reading and practice interface for the evidence-driven DevOps, SRE, platform, data, and production-engineering field manual.

## Purpose

The cockpit trains five complementary learning behaviors:

- **See the system:** architecture, request path, state, and failure-flow diagrams.
- **Break the system:** choose-the-next-move incident decisions with immediate reasoning feedback.
- **Read the field manual:** retain the complete explanation, signal map, safe-recovery path, and lab instructions for each completed topic.
- **Recall the system:** compact flashcards that require an answer before reveal.
- **Teach and defend:** Feynman notes and product-company interview drills.

The dashboard never raises mastery by itself. The repository ledger remains the evidence source of truth.

## Ready lessons

Volume 1 currently contains five substantial Linux foundation lessons:

1. Filesystems, blocks, inodes, and ENOSPC.
2. Processes, signals, exit codes, and systemd.
3. CPU, load, memory pressure, swap, and OOM.
4. DNS, routing, TCP, TLS, HTTP, and sockets.
5. Identity, permissions, traversal, and least privilege.

`Ready to study` describes content availability, not demonstrated mastery. The progress ledger remains authoritative.

Each lesson is designed to stand on its own: prerequisite vocabulary appears before the mechanism, Ubuntu command output is decoded field by field, and every checkpoint and product-company question includes a teaching answer from first-year foundations through senior production reasoning. The page always separates:

```text
question -> evidence -> field meanings -> combined interpretation -> safest next proof
```

## Reader routes

- `/` - lightweight home, current mission, and learning map.
- `/book` - complete knowledge library and planned volumes.
- `/book/linux` - Ubuntu-first Volume 01 index and preflight.
- `/book/linux/<lesson-id>` - one statically generated lesson per URL.
- `/practice/storage` - practice separated from the explanatory chapter.
- `/search` - offline search by symptom, command, term, title, or stable lesson ID.
- `/my-learning` - device-local bookmarks, recent lessons, and private reading markers.

The routed structure keeps individual pages lightweight as the manual grows. Desktop uses a persistent table of contents; smaller screens use a collapsible book menu. Previous and next links preserve the reading path.

## Local use

Prerequisite: Node.js 22.13 or newer. The validated local version is Node.js 26.4.0.

```bash
npm ci
npm run dev
```

Open `http://127.0.0.1:3000` in a local browser. No cloud deployment, account, credential, or external API is required.

On Windows, double-click `start-learning.cmd`. It installs locked dependencies on the first run, starts the loopback-only development server, and opens the site. Keep its command window open while learning; press `Ctrl+C` there to stop the server.

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

The content validator checks the six project-memory files, local Markdown links and anchors, duplicate curriculum IDs, requirements 1-46 coverage, all three structured record schemas, reviewed schema-policy digests, permanent legacy identities, and live cross-record relationships without adding another package dependency. The 34-case schema suite builds disposable repositories to exercise malformed or weakened schemas, answer leakage, identity collisions, unsafe paths, case drift, symlinks, broken ownership, dangling links, and prerequisite cycles. File-symlink creation can skip with `EPERM` on restricted Windows; run that case on Linux or symlink-capable Windows before a public release.

The reader tests exercise malformed browser state, storage failures, trusted lesson IDs, bookmark and reading transitions, capped recent history, and local search normalization/ranking using Node's built-in test runner.

---

## Implementation

- React 19 and vinext
- Device-local browser storage only
- No authentication, database, upload, or server-side persistence
- No external application API calls
- `.openai/hosting.json` contains no D1 or R2 bindings and is retained only for the starter build plugin
