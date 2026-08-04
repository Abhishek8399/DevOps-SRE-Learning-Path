# Decision Log

Last updated: 2026-08-02

This file records material project decisions so future contributors do not need chat history. Decision IDs are permanent. A later decision may supersede an earlier one, but history is not rewritten.

## Status vocabulary

- `ACCEPTED`: governs current work.
- `PROVISIONAL`: currently used but scheduled for validation or migration.
- `DEFERRED`: a decision is intentionally postponed.
- `SUPERSEDED`: retained for history and linked to its replacement.

## Decision index

| ID | Date | Status | Decision |
|---|---|---|---|
| `DEC-001` | 2026-07-20 | `ACCEPTED` | Operate local-first without online cloud resources |
| `DEC-002` | 2026-07-20 | `ACCEPTED` | Use WSL 2 Ubuntu 24.04 as the primary learning environment |
| `DEC-003` | 2026-07-20 | `ACCEPTED` | Permit reviewed local dependency installation, never implicit installation |
| `DEC-004` | 2026-07-20 | `DEFERRED` | Defer a primary public-cloud provider |
| `DEC-005` | 2026-08-01 | `ACCEPTED` | Keep Git as durable truth and the website as a reading interface |
| `DEC-006` | 2026-08-01 | `ACCEPTED` | Separate content availability, browser state, project delivery, and mastery |
| `DEC-007` | 2026-08-01 | `ACCEPTED` | Use a lightweight local website rather than a graphics-heavy course |
| `DEC-008` | 2026-08-02 | `ACCEPTED` | Teach first and ask only focused evidence questions at real gates |
| `DEC-009` | 2026-08-02 | `ACCEPTED` | Use five-lesson editorial batches without treating them as competency gates |
| `DEC-010` | 2026-08-02 | `ACCEPTED` | Choose the least powerful safe lab boundary |
| `DEC-011` | 2026-08-02 | `ACCEPTED` | Make Ubuntu-first commands and labs the default |
| `DEC-012` | 2026-08-02 | `ACCEPTED` | Use Docker only when isolation or controlled exhaustion is the mechanism |
| `DEC-013` | 2026-08-02 | `ACCEPTED` | Reserve disposable VMs and local Kubernetes for mechanisms that require them |
| `DEC-014` | 2026-08-02 | `PROVISIONAL` | Keep current lessons in typed TypeScript, migrate future content toward structured Markdown |
| `DEC-015` | 2026-08-02 | `ACCEPTED` | Replace the single long page with a routed book reader |
| `DEC-016` | 2026-08-02 | `ACCEPTED` | Store only convenience state in browser localStorage |
| `DEC-017` | 2026-08-02 | `ACCEPTED` | Do not let the browser silently execute shell, write Git, or promote mastery |
| `DEC-018` | 2026-08-02 | `ACCEPTED` | Teach mechanisms before vendor tools and map tools afterward |
| `DEC-019` | 2026-08-02 | `ACCEPTED` | Treat safety, security, observability, reliability, capacity, cost, and rollback as cross-cutting |
| `DEC-020` | 2026-08-02 | `ACCEPTED` | Use stable IDs and progressive disclosure for durable maintenance |
| `DEC-021` | 2026-08-02 | `ACCEPTED` | Optimize for accessible text, CSS, compact diagrams, print, and privacy |
| `DEC-022` | 2026-08-02 | `ACCEPTED` | Do not claim public safety while dependency or lab findings remain unresolved |
| `DEC-023` | 2026-08-02 | `ACCEPTED` | Commit and push logical validated training changes to `origin/main` |
| `DEC-024` | 2026-08-02 | `ACCEPTED` | Permit exact legacy-fixture cleanup only as a one-way migration to the hardened fixture |
| `DEC-025` | 2026-08-02 | `ACCEPTED` | A container ownership descriptor covers every safety-relevant runtime boundary it claims |
| `DEC-026` | 2026-08-02 | `ACCEPTED` | Use opaque IDs and strict JSON front matter for structured content |
| `DEC-027` | 2026-08-02 | `ACCEPTED` | Scope lesson order and adjacency to a volume while keeping routes explicit |
| `DEC-028` | 2026-08-02 | `PROVISIONAL` | Load canonical Markdown through an exact virtual-module registry |
| `DEC-029` | 2026-08-02 | `ACCEPTED` | Render prerequisites as advisory navigation, never as access or mastery gates |
| `DEC-030` | 2026-08-02 | `ACCEPTED` | Use Reliability Atlas as the official title and keep homepage journey states truthful |
| `DEC-031` | 2026-08-02 | `ACCEPTED` | Preserve curriculum ownership while publishing cross-volume lesson batches atomically |
| `DEC-032` | 2026-08-02 | `ACCEPTED` | Transfer deep connectivity curriculum ownership without changing the legacy lesson identity |
| `DEC-033` | 2026-08-02 | `ACCEPTED` | Keep structured curriculum IDs in their canonical volume homes before publication |

## Decision records

### DEC-001 - Local-only delivery

**Context:** The learner explicitly excluded online cloud resources and wants a repository that remains useful without accounts, cost, or employer access.

**Decision:** Normal teaching, labs, website use, simulations, plans, and architecture work remain local. Cloud concepts may use local emulation, configuration validation, diagrams, and failure reasoning, but no cloud resource is created without a future explicit scope change.

**Consequences:** No cloud cost or credential requirement. Some managed-service behavior must be modeled rather than claimed as hands-on cloud evidence. Provider-specific competence cannot be inferred from local simulation.

**Revisit when:** The learner explicitly authorizes a non-production account, provider, budget, and cleanup policy.

### DEC-002 - Ubuntu 24.04 in WSL 2 is the primary workbench

**Context:** Ubuntu 24.04.1, systemd, cgroup v2, Docker integration, and sufficient local capacity were observed.

**Decision:** Write runnable examples for Ubuntu 24.04 first and state whether WSL is supported. Prefer Linux paths and commands.

**Consequences:** The book stays close to Linux production systems. WSL-specific kernel, networking, storage, and resource differences must be called out. Windows-native paths are limited to launch/bootstrap integration.

### DEC-003 - Dependency installation is explicit

**Context:** Required local tools may be installed, but installation changes state, may use the network, and can affect shared environments.

**Decision:** Check `command -v` and versions first. Show package mapping separately. Label `apt-get` as mutating, networked, and privileged; never auto-install, auto-sudo, or download during a lesson script.

**Consequences:** Setup is slightly more deliberate but remains auditable and safer.

### DEC-004 - Provider choice is deferred

**Context:** Target jobs emphasize AWS and EKS, with some GCP and hybrid/private-cloud requirements, but online cloud use is excluded.

**Decision:** Build provider-neutral Linux, networking, distributed-systems, IAM, IaC, reliability, and architecture foundations first. Preserve an AWS/EKS specialist track without assigning provider competence.

**Revisit when:** Core evidence and a safe provider scope exist.

### DEC-005 - Git is durable truth; the website is a renderer

**Context:** The learner wants the full book, labs, and history to survive browser resets, machine changes, and future AI sessions.

**Decision:** Version lessons, diagrams, labs, rubrics, evidence, decisions, and reviewed progress in Git. The website reads and presents them.

**Consequences:** A fresh clone can reconstruct durable knowledge. Browser-only drafts are disposable. Website features must not become an undocumented database.

### DEC-006 - Mastery is separate from reading and delivery

**Context:** A polished chapter, a completed checkbox, or mentor-run output can create false confidence.

**Decision:** Maintain four distinct states:

```text
content published != project accepted != learner submitted evidence != durable mastery
```

Only `progress/ledger.md`, updated after reviewed learner evidence, changes competency. Durable mastery additionally requires independent transfer and delayed recall.

### DEC-007 - Lightweight technical field manual

**Context:** The learner wants a beautiful, memorable, fast book rather than a slow, graphics-heavy course.

**Decision:** Prefer semantic HTML, text, CSS, compact system diagrams, progressive sections, and small interactions. Avoid video backgrounds, decorative animation frameworks, large image bundles, analytics, external fonts, and unnecessary APIs.

### DEC-008 - Teaching-first cadence

**Context:** Repeated questions slowed learning and sometimes tested material before it was explained.

**Decision:** Deliver a coherent explanation, system picture, command interpretation, production decision path, and guided practice first. Use optional self-checks freely; require one focused response only for safety, evidence, transfer, or mastery gates.

### DEC-009 - Five-lesson editorial batches

**Context:** The learner wants enough material ready to study without waiting for one conversational turn per concept.

**Decision:** Publish coherent groups of approximately five lessons in prerequisite order. Batch availability never auto-advances skills or phases. After LES-0008, the next content-first editorial batch uses `LES-0009` through `LES-0013`, beginning with the next unused ID `LES-0009`.

### DEC-010 - Least powerful safe boundary

**Context:** Labs should teach real mechanisms without risking host, employer, or production state.

**Decision:** Choose environments in this order:

| Mechanism | Boundary |
|---|---|
| Observation | Ubuntu, read-only |
| Bounded user files/processes/sockets | Ubuntu, non-root, lesson-specific temporary resources |
| Resource exhaustion, namespaces, mounts, cgroups | Hardened Docker container |
| Boot, kernel, systemd, firewall, LVM, host-mount mutation | Disposable VM |
| Reconciliation, Services, policy, scheduling, RBAC, volumes | Local Kubernetes |

**Consequences:** Docker and Kubernetes are not used merely because they are popular. Some advanced labs depend on future VM or cluster harnesses.

### DEC-011 - Ubuntu-first reproducibility

**Context:** The core book should be useful with an Ubuntu installation and should explain commands rather than hide them behind automation.

**Decision:** Each lesson includes an environment card, dependency detection, exact commands, expected branches, risk, abort conditions, cleanup, and proof. Automation may wrap substantial labs, but the book still explains the underlying Ubuntu operations.

### DEC-012 - Docker for isolated ENOSPC and similar failures

**Context:** Deliberately exhausting host inodes, memory, PIDs, or mounts is unsafe, while a bounded container can reproduce the actual kernel failure.

**Decision:** Use pinned images, non-root users, no host mounts or secrets, disabled networking where possible, read-only root filesystems, dropped capabilities, resource ceilings, and descriptor-gated cleanup.

### DEC-013 - VM and Kubernetes are mechanism-specific

**Context:** Containers do not faithfully represent every host boot, kernel, systemd, firewall, storage, or multi-node control-plane behavior.

**Decision:** Use a resettable VM for host-sensitive mutation and a local Kubernetes cluster only for Kubernetes-specific behavior. Namespace every cluster exercise and require diff, rollback, and teardown evidence.

### DEC-014 - Typed now, structured Markdown after parity

**Context:** The first five lessons use TypeScript structures, which provided fast type feedback while the lesson schema evolved. Those files are becoming large and mix content with application code.

**Decision:** Keep the current typed data model while stabilizing the standard. New volumes move toward validated, non-executable Markdown under `book/volumes/...`; migrate existing lessons only after parity tests exist.

**Consequences:** There is temporary duplication between the book architecture and React data. Avoid expanding one giant constant. The migration must preserve stable IDs and URLs.

### DEC-015 - Routed reader

**Context:** A single long page becomes slow to navigate and hard to share as content grows.

**Decision:** Use separate routes for the library, volume indexes, lessons, and practice. Preserve breadcrumbs, desktop/mobile contents, 404 behavior, and deep links.

### DEC-016 - Browser state is convenience only

**Context:** Theme, text size, reading position, bookmarks, and draft notes improve reading but localStorage can be erased or machine-specific.

**Decision:** Store only non-sensitive convenience state locally. Do not store secrets, employer data, production evidence, or authoritative competency there.

**Consequences:** The reading desk uses a versioned schema with allowlisted lesson IDs, validated markers and timestamps, and capped duplicate-free recent history. It never persists arbitrary URLs or free text. Corrupt state resets safely; unavailable storage falls back to explicitly temporary page memory; browser origins remain separate and disposable.

### DEC-017 - No silent local execution or Git mutation from the browser

**Context:** A browser-connected shell or automatic repository writer would expand attack surface and could turn lesson text into unreviewed commands or false evidence.

**Decision:** Current website commands are explanatory/copyable, not executable by the site. A future companion may export or write only explicitly approved, path-validated evidence and may never commit, push, or promote mastery silently.

**Consequences:** Copy controls place only the displayed command text on the clipboard. They never invoke a shell, and clipboard refusal produces visible manual-copy guidance.

### DEC-018 - Mechanisms before tools

**Context:** Job descriptions list AWS, Kubernetes, Terraform, Splunk, Dynatrace, Spark, OpenStack, and many other products. Tool memorization decays and is vulnerable to automation.

**Decision:** Teach Linux, networking, state, failure, consistency, identity, control loops, evidence, safety, and trade-offs first. Then show how products expose or implement those mechanisms.

### DEC-019 - Cross-cutting production judgment

**Context:** Security, reliability, observability, capacity, economics, and rollback cannot be learned as isolated final chapters.

**Decision:** Evaluate these concerns in every relevant lesson and project, while retaining deeper specialist material.

### DEC-020 - Stable IDs and progressive disclosure

**Context:** Humans and future AI agents need durable references; beginners and experts need different entry depths.

**Decision:** Assign immutable IDs and structure each chapter from a five-minute picture through foundation, lab, production operations, scale, and mastery transfer.

### DEC-021 - Accessibility, print, performance, and privacy are product requirements

**Context:** The field manual may be read for long periods, on multiple screen sizes, at night, printed, or shared publicly.

**Decision:** Support semantic structure, keyboard use, contrast, reduced motion, responsive tables/diagrams, print, adjustable type, no telemetry, and loopback operation. Visual beauty must not reduce clarity or speed.

### DEC-022 - Unresolved risk remains visible

**Context:** An offline dependency audit disagreed with a registry-backed install warning, and lab safety review can discover copy-paste escape paths.

**Decision:** Do not call the site or a lab public-safe while an applicable advisory or critical lab finding remains unresolved or lacks an explicit reviewed disposition. Never conceal risk or use `npm audit fix --force` as a substitute for review.

### DEC-023 - Validated changes are pushed to the dedicated repository

**Context:** The learner wants all reusable work preserved in the dedicated remote for future study and future AI assistance.

**Decision:** After narrow validation and full diff review, group changes logically, commit to `main`, and push to the configured `origin`. Never force-push, rewrite history, or include secrets/generated noise.

### DEC-024 - Legacy fixture cleanup is migration-only

**Context:** A learner may still have the earlier root-run ENOSPC v1 container. Requiring the hardened v2 descriptor for every action would strand that known fixture, while broadly relaxing ownership checks could remove an unrelated container or expose an unsafe shell.

**Decision:** Cleanup may accept only the exact current v2 descriptor or the exact known legacy-v1 descriptor. Status and shell access remain strict v2-only. After legacy cleanup, the learner explicitly runs setup to build the hardened non-root v2 fixture; no other descriptor mismatch is accepted.

**Consequences:** The migration path is bounded and one-way. Descriptor-mismatch, exact-legacy cleanup, v1 status/shell refusal, v2 rebuild, and final cleanup require runtime regression coverage.

### DEC-025 - Descriptor gates prove the complete runtime boundary

**Context:** A label, image-name string, configured user, network mode, and read-only-root flag do not prove that a container has no host mounts, dropped capabilities, no privilege escalation, or the intended resource ceilings. Opening a shell based on an incomplete descriptor turns a safety label into a false boundary.

**Decision:** Any status or shell gate described as the hardened fixture must compare all safety-relevant runtime settings established by setup, including mount exposure, privilege/capability state, security options, bounded resources, tmpfs configuration, restart behavior, and image identity. Legacy compatibility remains cleanup-only and must match the reviewed legacy settings rather than a relaxed subset.

**Consequences:** Descriptor checks and their prose must evolve together. Adversarial tests vary one field at a time, and an incomplete check is a publication blocker even when the normal setup command is hardened.

### DEC-026 - Structured content uses opaque identity and strict JSON front matter

**Context:** The existing reader uses slugs, `V01-L##` aliases, and curriculum IDs for different purposes. Treating any one of those as canonical identity would break the networking lesson taxonomy, device-local state, routes, or future migrations. Free-form YAML or executable MDX would also expand parser ambiguity and execution risk.

**Decision:** Canonical records use immutable opaque IDs (`LES-####`, `ASM-####`, and `REF-####`). Routes, slugs, public aliases, and curriculum IDs remain explicit separate fields. Schema-v1 lessons use non-executable Markdown with strict JSON front matter. The five typed lessons remain permanently reserved as `LES-0001` through `LES-0005`; new records begin at `LES-0006`.

The repository audits its dependency-free JSON Schema subset, rejects unknown or malformed keywords, validates cross-record ownership and cycles, and compares all published legacy identities to an independently pinned baseline. Durable reference URLs cannot contain credentials, queries, or fragments. Raw HTML cannot define lesson structure. Independent-transfer records exclude model answers by construction. Command risk labels remain review assertions, not automated proof.

**Consequences:** A typed lesson can migrate only with exact identity preservation and separate route/content/state parity evidence. Schema v1 is capped at `review-required`; neither author metadata, a passing build, reading activity, nor answer reveal can award verified-chapter status or learner mastery. Full prerequisite-cycle analysis of range expressions in `CONTENT_MATRIX.md` remains planned and explicitly documented.

### DEC-027 - Volume-local order and explicit routes

**Context:** Volume 00 and Volume 01 both need a Lesson 01. Treating lesson order as globally unique made the curriculum taxonomy fight the reader, while deriving a route from the lesson domain would route Volume 00 foundations under the wrong URL. Global pagination also mislabeled a cross-volume transition as the next lesson in the same volume.

**Decision:** Lesson `order` is unique within its declared volume. Volume IDs map explicitly to reader route segments, and each canonical route must equal that volume route plus the lesson slug. Slugs, canonical IDs, state IDs, and full routes remain globally unique in the current reader. Previous/next adjacency stays within the current volume; crossing a volume boundary uses an explicitly labeled continuation link.

**Consequences:** A new volume requires an explicit route descriptor in the reader and validator plus route/order tests. Search and progress records carry volume metadata rather than inferring Volume 01 from a local lesson number. This navigation decision changes no learner competency or mastery state.

### DEC-028 - Exact virtual modules bridge canonical book content into the reader

**Context:** Canonical lesson Markdown lives under `book/`, outside the application root. Direct parent-directory raw imports worked in production builds but failed in the Cloudflare-backed development module runner. Broad filesystem allowances or request-derived file paths would expand the read boundary.

**Decision:** Development and build resolve structured lesson source through an exact allowlisted virtual-module registry. Each registered opaque lesson ID maps to one fixed canonical `lesson.md` path. The loader validates the ID in both resolution and loading, reads UTF-8 source, and registers the exact file for change watching. Unknown IDs and traversal-shaped IDs fail closed. Development runs content validation before the server starts.

**Consequences:** The local reader and production build consume the same canonical Markdown without copying lesson text into application code or exposing arbitrary filesystem reads. Every new structured lesson must be added deliberately to both the content registry and server bundle, with rejection/load tests. This fixed list is safe for the current small corpus; replace it with a validated generated manifest before manual registration becomes a scaling or drift risk.

### DEC-029 - Prerequisites are advisory navigation, not gates

**Context:** Stable prerequisite IDs should help a reader repair missing context, but hiding or locking a lesson would confuse recommended learning order with authorization or demonstrated competency. A read action, a followed link, or an available answer cannot prove that a prerequisite was practised or retained.

**Decision:** Structured lesson pages resolve declared prerequisite lesson IDs only through the trusted reader catalog and present successful resolutions as labelled native links. The panel is advisory: it never blocks direct access, marks a prerequisite complete, changes browser reading state on its own, or raises a learner level. An unresolved or invalid identity fails closed rather than generating a guessed route.

**Consequences:** Contributors must preserve stable prerequisite IDs and catalog relationships, and tests must cover resolution, order, accessible labelling, and unresolved-ID refusal. The reviewed learner ledger remains the only competency authority; prerequisite navigation is a reading aid, not learner evidence.

### DEC-030 - Official title and truthful homepage journey

**Context:** The public title and landing page must orient a new reader without exposing personal identity or presenting planned curriculum as available.

**Decision:** `Reliability Atlas` is the official title. The homepage presents one dependency-ordered nine-stage journey ending at Capstones & Interviews; only published stages are links, planned stages explicitly have no route, and reading progress remains separate from reviewed evidence and mastery.

**Consequences:** Title migrations require source and rendered-route checks for stale labels and personal-name text. Homepage links, planned boundaries, evidence language, and non-mastery behavior remain release assertions; Git remote/history are unchanged.

### DEC-031 - Cross-volume batches preserve existing ownership

**Context:** A five-lesson editorial batch can cross volume boundaries, while the five established typed lessons permanently reserve their lesson, alias, route, state, and curriculum identities. In particular, legacy `LES-0004` currently owns `NET-003` through `NET-006`. Assigning those curriculum IDs to new DNS, HTTP, or TLS records would create two canonical owners and make future migration ambiguous.

**Decision:** A cross-volume batch becomes a reader checkpoint only when every declared lesson, assessment, reference, lab, exact virtual-module registration, route, catalog/state identity, and relationship test is present and validated together. New lessons claim only currently unowned curriculum IDs. The first structured connectivity records therefore own `NET-001`, `NET-002`, and `NET-007`; `NET-003` through `NET-006` remain with `LES-0004` until a separately audited migration preserves its published identity or an explicit taxonomy migration supersedes this decision.

**Consequences:** The repository cannot temporarily publish dangling references or duplicate curriculum ownership. Deep DNS, HTTP/proxy, and TLS/PKI chapters require deliberate legacy migration design rather than convenient new IDs. Editorial batch completion remains project evidence only and cannot advance learner state.

### DEC-032 - Audited deep-connectivity ownership migration

**Context:** Legacy `LES-0004` is a broad Linux request-path bridge. It historically reserved `NET-003` through `NET-006`, but the dedicated transport, DNS, HTTP/proxy, and TLS chapters need one unambiguous canonical curriculum owner each. Keeping every identity on the bridge would make the deeper chapters second-class duplicates; deleting or renaming the legacy lesson would break its published route, state key, aliases, and learner history.

**Decision:** Preserve every published identity of `LES-0004` -- canonical lesson ID, state ID, slug, route, aliases, content, and reader position -- while narrowing its curriculum ownership to `NET-003`. Transfer `NET-004` to `LES-0014`, `NET-005` to `LES-0015`, and `NET-006` to `LES-0016`. Update the independently pinned legacy identity digest only after reviewing that exact map change. The validator rejects duplicate curriculum owners and rejects curriculum prefixes outside their canonical volume.

This decision supersedes only the temporary ownership deferral in `DEC-031`; its atomic cross-volume checkpoint rule remains in force.

**Consequences:** Old links and device-local reading state remain valid. Search resolves the deep curriculum IDs to their dedicated chapters while `LES-0004` remains the Linux request-path bridge and prerequisite owner for `NET-003`. Future ownership moves require another explicit migration record, updated baseline evidence, and regression tests; a convenient duplicate is never an acceptable intermediate state.

### DEC-033 - Curriculum home controls pre-publication placement

**Context:** `LES-0009` was first drafted beside its Volume 00 prerequisites, but it owns `SCM-001`, whose canonical subject is Volume 03 engineering and delivery. Publishing a source-control lesson under the safe-start volume would make routes, aliases, local order, navigation, and future prerequisite reasoning contradict the curriculum map.

**Decision:** Before the lesson's first commit, place `LES-0009` in `book/volumes/03-engineering-delivery`, route it at `/book/engineering/safe-local-workbench`, assign alias `V03-L01`, and keep Volume 00 lessons as explicit prerequisites. Enforce the same prefix-to-volume rule for every structured curriculum ID: foundation and debugging in Volume 00, Linux in Volume 01, networking in Volume 02, engineering and delivery in Volume 03, reliability in Volume 04, infrastructure and platform in Volume 05, and distributed state in Volume 06.

**Consequences:** Physical path, route, alias, local order, and curriculum identity tell one story. Prerequisites may cross volumes without moving lesson ownership. Because this correction happened before publication, it creates no redirect or browser-state migration; later moves of an already published lesson would require explicit compatibility handling.

### DEC-034 - Quarantined curriculum can advance around an independent runtime blocker

**Context:** The OpenTelemetry candidate has unresolved runtime-safety and immutable-artifact blockers. Waiting on that environment must not silently weaken its promotion gates, but treating the entire dependency-ordered book as blocked would prevent independent authoring and review of downstream concepts such as Prometheus semantics.

**Decision:** A later curriculum item may be checkpointed only as a quarantined draft when its own prerequisite concepts are already available, its direct schemas and answer isolation pass, its evidence boundaries are explicit, and it adds no canonical route, registry entry, learner evidence, or mastery claim. Static or deterministic-model success is never substituted for a required Ubuntu, provider, or real-runtime gate. Each draft keeps its own blockers and must independently satisfy the complete promotion contract.

**Consequences:** `LES-0028` may preserve substantial Prometheus/PromQL/Grafana teaching work while `LES-0027` remains blocked, but neither becomes live through proximity or dependency order. Future contributors and AI agents can continue curriculum authoring without manufacturing evidence; promotion still requires exact runtime, safety, relationship, reader, review, commit, and remote-parity gates for the candidate being moved.

### DEC-035 - The reader is a field manual, while evidence remains a separate system

**Context:** The site was functionally correct but visually behaved like a generic application shell. The book needs to remain lightweight and local while helping readers move among architecture, commands, incidents, labs and review material without losing their place. A more polished interface must not convert reading activity, bookmarks or answer reveals into professional competency claims.

**Decision:** Use a restrained technical-field-manual design: a persistent book shell, section-aware navigation, an optional context rail, editorial code blocks, a device-local reading desk and explicit paper/night/print/responsive states. Canonical content remains in the existing book sources and trusted generated registries; presentation components do not become a second content store. Reading and convenience state remains separate from reviewed learner evidence and mastery. No analytics, remote account or external asset is introduced by the redesign.

**Consequences:** UI feature checkpoint `e746eb8` and documentation checkpoint `481a6cb` improve information architecture without changing lesson IDs, routes, assessment isolation, learner levels or Git remote history. Automated content, schema, reader, lint, type, build and route checks are necessary, while visual quality, keyboard behavior, screen-reader behavior, responsive layout and print still require a real browser backend and human review. Future redesigns must preserve the same content ownership, local-first privacy and non-mastery boundary.

### DEC-036 - Fluid outer workspace, bounded inner manuscript

**Context:** The field-manual shell constrained the book workspace to 1080 px and standalone pages to 1080-1240 px. On a wide monitor those independent caps compounded with the navigation and context rails, leaving large unused corners and reducing the space available to architecture diagrams, labs, evidence tables and learning dashboards. Simply widening all text would damage reading comfort.

**Decision:** Use one responsive `--shell-gutter` for the outer book reader, home, practice, search and learning-dashboard shells, without a fixed desktop cap. Preserve the independent `--manuscript-width` preferences of 640/720/800 px for prose and keep component-specific inner measures where they improve comprehension. Treat wide space as operational canvas for diagrams, tables and workflows, not as permission for unbounded line length.

**Consequences:** Checkpoint `8cd6de2` uses the available viewport while retaining readable lesson measure and small-device gutters. No route, content, progress, mastery or remote dependency changes. Automated CSS/source, lint, type, schema, reader and build checks pass; because no browser backend is available, real visual balance, zoom, keyboard, theme and breakpoint behavior remain review gates rather than inferred claims.

### DEC-037 - Configuration automation evidence is layered, not one green recap

**Context:** A localhost Ansible lab can prove inventory resolution, module behavior, handler notification and convergence without authorizing SSH, privilege or a fleet. Check mode may predict a change without applying it, while a successful play recap can still coexist with a broken service or user journey. Treating any one of these signals as “Ansible works” would manufacture production evidence.

**Decision:** Teach and verify configuration management as a layered chain: bind controller/source/dependencies, resolve the exact host set, establish variable ownership, run static and check prediction, converge a bounded canary, prove an immediate fixed point, inject and repair controlled drift, verify configuration/process/service/user outcomes independently, and clean only an exact guarded inventory. Keep localhost/source checks, Ubuntu execution, remote transport/privilege, fleet rollout, formal review and learner transfer as separate gates. The local fixture pre-creates a sentinel-only managed root so supported file tasks can predict without writing or failing on an absent parent; before/after inventory proves non-mutation.

**Consequences:** `LES-0040` may be checkpointed as a substantial quarantined candidate with direct/static evidence while WSL is blocked, but it cannot be registered or described as runtime-verified. Future Ansible content must not hide mutation with `changed_when: false`, infer service health from `failed=0`, or claim check mode as a universal transaction. Promotion requires the exact normal-user Ubuntu lifecycle plus reviewed remote, security, service/fleet, instructional and learner evidence.

### DEC-038 - Kubernetes understanding starts with level-triggered ownership, while models never count as cluster evidence

**Context:** A learner can memorize component names yet still misdiagnose Kubernetes by treating every event as a command that must be replayed. Kubernetes control loops repeatedly compare desired and observed state; identity, ownership, generation, status and finalization determine which actor may safely change what. A deterministic local model can expose those transitions when no cluster runtime is available, but it cannot exercise an API server, etcd, admission, RBAC, watches, scheduler, kubelet or container runtime.

**Decision:** Teach the control plane as an evidence path from request gates to persisted object, ownership graph, level-triggered reconciliation, binding, node execution, status and user-operation verification. Preserve object identity and monotonically advancing resource-version evidence in the model, distinguish generation from observed generation, make stalled reconciliation and recovery explicit, and reject impossible transition order. Label every such fixture `kubernetes-model-only`. Keep deterministic-model evidence, pinned local-cluster evidence, component-fault evidence, formal review and learner transfer as separate promotion gates.

**Consequences:** `LES-0041` can be checkpointed as a substantial quarantined control-plane candidate without pretending a Python state machine is Kubernetes. Future workload, network, storage, security and operator chapters can reuse the ownership/reconciliation mental model, but each must prove its own manifests, faults, observation paths and exact cleanup on a pinned local cluster before publication. No model result may be cited as API, etcd, controller, scheduler, kubelet, CRI, CNI, CSI or production-runtime evidence.

### DEC-039 - Workload health is a chain, not a Pod phase

**Context:** Running, Ready, available, in an EndpointSlice and serving a correct user response are distinct states owned by different loops. Treating one as overall health causes unsafe deletion, probe storms and false rollout success.

**Decision:** Diagnose workloads through owner/revision, binding, node execution, container history, readiness, endpoint and user-operation evidence. Keep rollout, disruption and autoscaling intent separate from schedulable and serving capacity. A deterministic model may teach boundaries but never counts as Kubernetes runtime.

**Consequences:** `LES-0042` remains quarantined until a pinned local cluster proves the named faults and cleanup. Future chapters must preserve revision-aware user verification and may not use Pod phase as a universal health signal.
