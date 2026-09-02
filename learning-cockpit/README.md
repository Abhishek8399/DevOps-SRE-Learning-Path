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

Canonical feature `f2e3e23` exposes twenty-six lessons across five populated volumes. LES-0026 is pushed with exact remote parity; real-browser and formal-acceptance gates remain open.

The local reader also exposes sixty-six complete extended-study chapters at `/drafts`, spanning observability, SRE, infrastructure as code, Kubernetes, cloud, data systems, AI engineering, security, private cloud, architecture, leadership, and capstones. They are deliberately labelled as staged reading previews: they are available for careful study and practice, but are not silently represented as canonical publication, validated runtime behavior, production evidence, or learner mastery.

Volume 00 publishes two safe-start lessons:

1. Systems thinking: state, queues, dependencies, and failure domains.
2. Evidence-driven troubleshooting: FRAME, hypotheses, and safe moves.

Volume 01 publishes eight Linux lessons:

1. Filesystems, blocks, inodes, and ENOSPC.
2. Processes, signals, exit codes, and systemd.
3. CPU, load, memory pressure, swap, and OOM.
4. DNS, routing, TCP, TLS, HTTP, and sockets.
5. Identity, permissions, traversal, and least privilege.
6. Boot, kernel, initramfs, systemd, and the journal.
7. Block I/O, page cache, writeback, queues, latency, throughput, and durability.
8. Linux namespaces, cgroups v2, resource policy, and the container isolation model.

Volume 02 publishes five connectivity lessons:

1. Ethernet, IP, CIDR, route selection, neighbors, NAT, return paths, and MTU.
2. TCP, UDP, sockets, queues, retransmission, flow/congestion control, TIME_WAIT, and exhaustion.
3. DNS resolution, delegation, caches, negative answers, split DNS, and service discovery.
4. HTTP semantics, proxies, caching, health checks, load balancing, pools, retries, and request identity.
5. TLS handshakes, X.509 identity, PKI trust, mTLS, termination, failure diagnosis, and safe rotation.

Volume 03 publishes ten engineering-and-delivery lessons:

1. Safe local engineering: Ubuntu/WSL shell behavior, Git states, secrets, rollback, and cleanup.
2. Safe Bash automation: parsing, quoting, statuses, traps, inputs, concurrency, retries, tests, and recovery.
3. Python operational automation: typed boundaries, subprocesses, exceptions, durable state, retries, concurrency, packaging, testing, and telemetry.
4. PowerShell operational automation: typed object pipelines, binding, error and native-process contracts, `ShouldProcess`, idempotency, security, and verification.
5. Go infrastructure tooling: modules, interfaces, context cancellation, bounded concurrency, HTTP/JSON boundaries, tests, profiling, and trustworthy exits.
6. API contracts and serialization: bytes, HTTP/JSON schemas, authorization, idempotency, pagination, versioning, webhooks, recovery, and user outcomes.
7. Reproducible builds and dependencies: input closure, lock integrity, nondeterminism, context, caches, artifacts, SBOMs, provenance, and promotion.
8. OCI containers and Docker: image/layer identity, namespaces/cgroups, filesystems, networking, PID 1, resources, runtime security, registry trust, and lifecycle.
9. CI/CD architecture: event and pipeline graphs, runner trust, caches, immutable artifacts, promotion, approvals, deployment control, telemetry, and user verification.
10. CI platform operations: provider-neutral control and execution planes, GitHub Actions, GitLab CI/CD, Jenkins, Azure Pipelines, runner trust, queues, reusable configuration, upgrades, migrations, incidents, and proof limits.

Volume 04 currently publishes one reliability-and-operations lesson:

1. Observability foundations: metrics, logs, traces, events, profiles, evidence pipelines, clocks, context, loss, ordering, cardinality, sampling, retention, privacy, cost, RED, USE, and golden-signal reasoning.

`LES-0006` through `LES-0026` are schema-backed `substantive-draft` lessons: available to study after integrated publication, but still subject to review. Each has two complete-answer assessments, one answer-isolated independent transfer, and a bounded practice contract. `LES-0006` through `LES-0024` have eight primary references each; `LES-0025` has eleven official provider and Git references; `LES-0026` has nine official or primary references. The two `LES-0025` local CI engines do not execute or certify GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines. The `LES-0026` fixture is a deterministic local teaching model, not a representative instrumented service, OpenTelemetry SDK or Collector, Prometheus, Grafana, continuous profiler, vendor backend, production behavior, or learner evidence. Linux lessons 1-5 retain their established reader implementations, routes, and device-local state IDs. Every availability label describes content state, not demonstrated mastery. The progress ledger remains authoritative.

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
- `/book/connectivity` - Volume 02 packet-to-application transport index and preflight.
- `/book/connectivity/<lesson-id>` - one statically generated connectivity lesson per URL.
- `/book/engineering` - Volume 03 engineering-and-delivery index and safe workbench preflight.
- `/book/engineering/<lesson-id>` - one statically generated engineering lesson per URL.
- `/book/reliability` - Volume 04 reliability-and-operations index.
- `/book/reliability/<lesson-id>` - one statically generated reliability lesson per URL.
- `/drafts` - the grouped extended-study library of complete staged chapters, kept distinct from the canonical registry.
- `/drafts/<lesson-id>` - one statically generated staged chapter, including chapter facts, detailed answered-assessment disclosures, and answer-isolated independent transfer.
- `/career` - role map and the complete version-controlled career-primer library.
- `/career/<primer>` - one statically generated career field-manual chapter sourced from `career/*.md`.
- `/practice/interview` - local role-scoped timed mock questions, private response capture, answer reveal, follow-ups, and explicit practice-record export.
- `/practice/storage` - practice separated from the explanatory chapter.
- `/search` - offline search across canonical lessons, extended-study chapters, navigation, and all version-controlled career primers by symptom, command, term, title, or stable identifier.
- `/my-learning` - device-local bookmarks, recent lessons, and private reading markers across all 26 canonical and 66 extended-study chapters.

The routed structure keeps individual pages lightweight as the manual grows. Desktop uses a persistent table of contents; smaller screens use a collapsible book menu. Previous and next links stay inside a volume; an explicit continuation link crosses into the next volume. Structured lessons also show resolved prerequisite IDs in a labelled advisory navigation panel. Those links never lock access, mark completion, or infer mastery; unresolved identities do not become guessed routes.

## Local use

Prerequisite: Node.js 22.13 or newer. The validated local version is Node.js 26.4.0.

```bash
npm ci
npm run dev
```

Open `http://127.0.0.1:3000` in a local browser. No cloud deployment, account, credential, or external API is required.

On Windows, from the repository root, double-click `startlearning.cmd`. It installs locked dependencies on the first run, requires the exact loopback development endpoint `127.0.0.1:3000`, refuses startup when that port is already occupied, starts with the explicit port, and opens the site. Keep its command window open while learning; press `Ctrl+C` there to stop the server.

```text
startlearning.cmd
```

For a production-style local check, build first and then start the generated server:

```bash
npm run build
npm run start -- --hostname 127.0.0.1 --port 3000
```

The pinned vinext `0.0.50` build records nested production static-file cache paths with Windows separators. `npm ci` and `npm run start` therefore run a narrow compatibility script with two reviewed, cache-only guards: it normalizes that exact key and can look up the legacy backslash form without touching the filesystem. The script is idempotent and refuses another dependency version or an unexpected source layout; do not edit `node_modules` by hand. Rebuild first and restart the production process so it cannot retain an older in-memory cache. This local correction is not a substitute for the normal content, test, type, build, and HTTP-asset gates.

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
npm run generate:content-registry  # after adding/removing structured records
npm run lint
npm run typecheck
npm run validate:content
npm run test:content-schema
npm run test:reference-freshness
npm run test:reader
npm run build
npm run audit:web-budget
npm run report:labs
npm run report:references -- --fail-overdue
npm run audit:hygiene
npm audit  # optional network-backed advisory check
```

The lockfile is committed for reproducible installation. `npm audit` sends dependency metadata to the configured npm registry, so run it only when that network disclosure is acceptable. Review findings rather than running `npm audit fix --force`, which may introduce breaking dependency changes.

Run `npm run build` before `npm run audit:web-budget`. The audit checks only generated client assets and intentionally budgets JavaScript at 512 KiB, CSS at 256 KiB, all client assets at 768 KiB, and 80 files. These are repository guardrails for the local reader, not network-performance or browser-rendering measurements; compressed transfer size, runtime performance, accessibility, and visual QA require their own evidence.

`npm run report:labs` produces a read-only inventory of the twenty canonical local lab contracts. It checks for a README, paired runner/verifier, and a basic Bash or PowerShell safety preamble. It deliberately reports runtime evidence as `not assessed`; run each lab's supported lifecycle separately and record its result in `VERIFICATION.md`.

`npm run report:references -- --fail-overdue` scans canonical and staged reference records without contacting their URLs. It rejects malformed collection state and expired `reviewAfter` windows, warns about records entering the default 90-day review window, and reports repeated URLs without assuming they are mistakes. Use `--as-of YYYY-MM-DD` for reproducible evidence or `--json` for the complete machine-readable result.

`npm run audit:hygiene` scans only the contents of tracked text files; it never scans path strings or prints a matched secret. It fails on unresolved merge markers, high-confidence private-key/GitHub/AWS/Slack credential signatures, or the configured removed-name marker. It is a narrow source guardrail rather than complete secret detection, Git-history scanning, credential rotation, or a substitute for human review.

## Continuous integration

The repository runs `.github/workflows/quality.yml` on pull requests and pushes to `main`. The Ubuntu 24.04 job uses the committed lockfile and Node.js 24.8.0, grants only `contents: read`, and runs the same canonical content/schema/reader/type/lint/build/asset-budget/lab-contract gates used locally. Its official checkout and Node-setup actions are pinned to the reviewed v6 commit IDs rather than mutable major tags. It does not deploy the reader, run cloud resources, execute Docker or Kubernetes labs, claim browser visual QA, or infer learner mastery. The workflow's final Git diff check prevents generated or dependency residue from being silently accepted.

The content validator checks the six project-memory files, local Markdown links and anchors, duplicate curriculum IDs, requirements 1-46 coverage, all three structured record schemas, reviewed schema-policy digests, permanent legacy identities, canonical curriculum homes, and live cross-record relationships without adding another package dependency. Canonical feature `f2e3e23` has twenty-one lessons, 63 assessments (forty-two complete-answer records and twenty-one answer-isolated independent transfers), and 172 references. Exact current counters and gate results are recorded in `VERIFICATION.md`; the Windows schema suite retains one documented `EPERM` symlink-policy skip that must run on Linux or symlink-capable Windows before a public release. The suite uses disposable repositories to exercise malformed or weakened schemas, title/heading parity, answer leakage, identity collisions, canonical volume ownership, volume-aware routes and ordering, unsafe paths, case drift, symlinks, broken ownership, dangling links, prerequisite cycles, safe Markdown destinations, and the live corpus.

The reader suite covers all twenty-six canonical lessons, all visible staged chapter source/assessment/reference packages, additive eighteen-lesson catalog/state migration, five-volume adjacency, trusted prerequisite resolution, advisory prerequisite rendering, all twenty-one canonical independent-transfer answer-isolation contracts, bounded local career-primer search records, and staged-shelf filtering. All 34 reader tests pass for the current feature set. The suite also exercises malformed browser state, storage failures, trusted lesson IDs, bookmark and reading transitions, capped recent history, immutable legacy routes, schema-backed lesson parsing, CommonMark heading/fence parity, safe links, whole-career-primer production parsing, multi-volume search ranking, staged chapter navigation, metadata-rich filter normalization, and virtual-content loader refusal using Node's built-in test runner. The structured renderer consumes inert parsed Markdown and an explicit server-side catalog; it does not execute embedded HTML or publish assessment answers into search metadata.

`npm run dev` validates canonical content and the committed generated registries before startup. After adding, removing, or moving a structured record, run `npm run generate:content-registry`; it first validates the repository, then deterministically regenerates the exact virtual lesson paths, eager assessment/reference imports, and browser-safe lesson-ID allowlist. `npm run validate:content` fails when any generated file is stale. Build and development read only those canonical allowlisted paths, watch the selected lesson file, and reject unknown or path-like virtual IDs. The generator does not weaken schema, ownership, path, or answer-isolation validation.

---

## Implementation

- React 19 and vinext
- Device-local browser storage only
- No authentication, database, upload, or server-side persistence
- No external application API calls
- `.openai/hosting.json` contains no D1 or R2 bindings and is retained only for the starter build plugin
