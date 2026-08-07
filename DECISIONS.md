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

### DEC-040 - Kubernetes network incidents are localized by the last proven hop

**Context:** “Networking is broken” collapses resolver, route, transport, TLS, HTTP, Service selection, dataplane, policy, listener and return-path failures into one unsafe guess.

**Decision:** Bind exact identities and five-tuples, then move from name through address, EndpointSlice membership, policy, Service/port mapping, node path, listener and user response. Use a working direct/same-node path as a control without claiming it proves later paths. Keep control-plane acceptance separate from packet forwarding.

**Consequences:** `LES-0043` remains quarantined until pinned multi-node cluster evidence proves CNI, DNS, Service, policy, Gateway, negative controls and cleanup. Future networking lessons must report the last proven hop instead of assigning blame from a timeout alone.

### DEC-041 - Storage protection is proved by an application restore, not an object status

**Context:** Bound, attached, mounted, writable, snapshotted and restored are different stages. Treating a green PVC or snapshot as data protection hides topology, filesystem and application-consistency failures.

**Decision:** Trace exact PVC/PV/handle identity through provision, bind, schedule, attach, mount, filesystem and application I/O. Treat snapshots as storage evidence only; require isolated restore, integrity, application transaction and measured RPO/RTO before claiming recoverability. Preserve reclaim/finalizer ownership.

**Consequences:** `LES-0044` remains quarantined until pinned CSI/backend evidence proves every stage, faults, restore and exact cleanup. Future DR claims cannot cite snapshot readiness alone.

### DEC-042 - Kubernetes security failures are classified by gate before policy changes

**Context:** Unauthorized, Forbidden, admission denial and runtime permission failures have different owners. Broad RBAC or disabled admission can turn a narrow incident into a cluster compromise.

**Decision:** Bind identity and exact action, then classify authentication, authorization, admission or runtime. Require least-privilege positive and negative tests, protect token/Secret values, preserve audit lineage, and treat admission as both a security and availability dependency. Namespace is one tenant layer, never complete isolation.

**Consequences:** `LES-0045` remains quarantined until a pinned cluster proves allowed/denied actions, revocation, admission/runtime enforcement, tenant negatives and cleanup. Future incident guidance may not use cluster-admin or global policy disablement as default repair.

### DEC-043 - Rendered manifests are proposals, not release evidence

**Context:** Helm and Kustomize can emit valid-looking Kubernetes YAML without contacting the current API, exercising admission, waiting for controller convergence, verifying durable-data compatibility or testing the user journey. A Helm rollback creates another desired-state change; it cannot inherently reverse hook side effects, CRD storage changes or database migrations.

**Decision:** Teach every packaged change as an evidence chain: bind source, dependencies and ordered inputs; render deterministically; validate schema and policy; exercise server dry-run; review normalized live diff and ownership; execute one bounded release; observe revision, generation, conditions and endpoints; then verify the original user operation. Treat Helm package/release state, Kustomize composition, Kubernetes object state and durable application data as separate ownership domains. Rollback requires explicit compatibility evidence and may be replaced by a safer forward fix.

**Consequences:** `LES-0046` remains quarantined until pinned Helm/Kustomize binaries and a disposable cluster prove the package-versus-overlay comparison, API acceptance, diff, hook/CRD boundaries, failed upgrade, compatible rollback or forward recovery, user verification and exact cleanup. Future delivery content may not claim success from `helm template`, `kubectl kustomize`, `helm upgrade`, `helm rollback` or controller readiness alone.

### DEC-044 - Kubernetes extension mechanisms retain separate ownership and failure domains

**Context:** A CRD, controller, conversion webhook and admission extension are often called one “operator,” hiding different data, automation, upgrade and availability contracts. A stored custom object can remain available while reconciliation is down; a fail-closed admission webhook can stop matching API writes while controllers are healthy; forced finalizer removal can restore API deletion while orphaning an external resource.

**Decision:** Choose the smallest extension that meets the lifecycle requirement. Treat the structural API schema and storage version, level-triggered idempotent reconciliation, status freshness, child ownership, external cleanup/finalizers, version conversion/migration and admission policy as separately evidenced boundaries. Prefer in-process schema or validating admission policy when sufficient; every webhook requires narrow matching, bounded latency, explicit side effects and failure policy, dependency-loop analysis and reviewed break-glass. No status is current without matching `observedGeneration`, and no finalizer is removed without cleanup evidence.

**Consequences:** `LES-0047` remains quarantined until a pinned disposable cluster proves positive and negative schema behavior, retry idempotency, stable external identity, status freshness, deletion cleanup, conversion round trips, stored-version migration, admission containment and exact teardown. Future content may not infer automation from a CRD, current truth from stale status, safe deletion from API absence, or admission safety from configuration alone.

### DEC-045 - Kubernetes production changes are dependency-ordered experiments

**Context:** A supported target version, successful node drain, desired HPA replicas, healthy API response or valid etcd snapshot each proves only one boundary. Upgrades can expose webhook/add-on incompatibility; retry storms can consume recovery capacity; PDBs can block unsafe disruption but cannot create replacement capacity; etcd restore can recover API objects while application data or user journeys remain unavailable.

**Decision:** Operate cluster change as an evidence chain: bind exact component/add-on/API inventory and skew; resolve deprecations and conversion/admission compatibility; prove backup integrity and isolated restore; model serving capacity through failure and drain; define canary, wave, soak, abort and communication gates; change one failure domain; then verify control plane, add-ons, workloads, data dependencies and user SLIs. Separate schedulable from serving capacity, HPA intent from node/endpoint realization, and Kubernetes object recovery from complete application recovery. Contain retry amplification before scaling the overloaded control plane.

**Consequences:** `LES-0048` remains quarantined until a pinned multi-node disposable cluster proves a supported upgrade path, drain/PDB/topology behavior, workload/node scaling delay, bounded API fairness fault, etcd isolated restore, dependency-ordered recovery, user RPO/RTO and exact cleanup. Future operations content may not claim upgrade success from version output, availability from PDB presence, capacity from desired replicas, or disaster recovery from snapshot status alone.

### DEC-046 - GitOps desired state is authoritative intent, not observed truth

**Context:** Continuous reconciliation improves auditability and convergence but can also reapply a harmful commit, erase a valid emergency mitigation, amplify API load or prune shared/stateful resources. A controller reporting Synced or Ready proves its comparison/health model, not the user operation. Git history does not reverse database, hook or external side effects.

**Decision:** Bind every promotion to a protected commit, immutable artifact/config dependency and deterministic render. Give each object/field one desired-state owner; classify drift from tracking, managed fields, audit and break-glass intent before self-heal. Treat retries, automated sync, health, ordering, suspension and prune as production policy with explicit timeouts, empty-set/data/ownership guards and expiry. CI builds/tests/signs and proposes desired-state change; the pull reconciler owns cluster deployment. Recover through a reviewed revert or compatible forward fix in the authoritative source, then verify controller, Kubernetes, dependencies and user SLI.

**Consequences:** `LES-0049` remains quarantined until a pinned local Git remote, immutable synthetic artifacts and one reviewed Argo CD or Flux environment prove source/render/policy, promotion, drift, bad-commit/source-outage containment, prune refusal, recovery and exact cleanup. Future delivery content may not claim truth from Git alone, safety from self-heal, deletion safety from repository absence, or application health from GitOps status alone.

### DEC-047 - Cloud architecture is requirements-to-mechanisms reasoning, not service-name matching

**Status:** `ACCEPTED`

**Context:** AWS, Azure and Google Cloud expose comparable capability families but use different identity, hierarchy, scope, location, quota, networking and managed-service contracts. A logo-first comparison hides failure correlation and creates false equivalence. Managed services transfer selected operations but do not transfer accountability for customer data, identity, configuration, recovery or user outcomes. Quota also does not guarantee provider stock.

**Decision:** Teach a provider-neutral workload contract, data/control paths, state scope, ownership, failure domains, survivor capacity, quota/rate/stock, recovery and cost model before translating mechanisms to provider products. Every provider claim is date-, region-, tier- and scope-sensitive. Cloud chapters remain local-only unless a later explicitly governed disposable exercise authorizes runtime work.

**Consequences:** `LES-0050` is the reasoning prerequisite for AWS, Azure, Google Cloud, cloud identity, networking, DR and FinOps chapters. It remains quarantined until Ubuntu lifecycle, formal review and unseen learner transfer pass. Its deterministic model cannot be cited as provider, quota, availability, failover, backup, restore, security, pricing or production evidence.

### DEC-048 - Identity assertions and authorization decisions remain separate evidence

**Status:** `ACCEPTED`

**Context:** A subject can authenticate successfully and receive a correctly signed token yet be denied because audience, immutable subject mapping, session context, action, resource, conditions or inherited policy do not authorize the operation. Decoding a JWT is not validation. Static credentials, broad roles and network-location trust hide attribution and extend compromise windows.

**Decision:** Teach and operate identity as `subject → proof → issuer → assertion → policy → resource → audit`. Human and workload identities stay separate, federation prefers short-lived audience-bound sessions, least privilege requires negative tests, and secret/certificate/key rotation is incomplete until old use is revoked and denial is proved. Zero trust is resource-specific continuous decision-making, not a product or automatic denial.

**Consequences:** `LES-0051` remains quarantined until a reviewer-owned local protocol environment proves validation, federation, policy, rotation, revocation, outage behavior and cleanup. No model output may be cited as identity-provider, OAuth/OIDC, TLS/PKI, CA, KMS, secrets-manager, provider or production evidence.

### DEC-049 - Fluid workspace width and prose readability are separate controls

**Status:** `ACCEPTED`

**Context:** A learning application can feel cramped on a large display when page shells, navigation rails and technical artifacts retain fixed desktop dimensions. Stretching every element to solve that problem makes long-form prose harder to scan and remember. The legacy stylesheet also declared the book grid after the newer shell rules, which could reclaim precedence at responsive breakpoints.

**Decision:** Keep the outer application within a 10-20 px viewport-aware gutter, size the desktop navigation and context rails with bounded `clamp()` values, and let diagrams, labs, evidence grids and assessment panels use up to 1,120 px. Preserve the independent 720 px default manuscript measure and its reader-controlled narrow/standard/wide options. Place the authoritative 1180 px and 980 px shell rules after compatibility styles so tablet overlays and mobile stacking cannot be overridden by legacy declarations.

**Consequences:** Wide displays now improve workspace context instead of adding decorative empty margins, while paragraph line length remains intentionally constrained. Source/build verification can prove the cascade and tokens, but rendered responsive, keyboard and visual quality still require a real browser backend and remain explicitly unclaimed.

### DEC-050 - Network reachability is a bidirectional evidence chain

**Status:** `ACCEPTED`

**Context:** Cloud consoles expose connected peerings, healthy tunnels, established BGP sessions, allowed firewall rules, healthy load-balancer targets and private endpoints as separate green objects. None proves that one named user operation can resolve the intended address, follow a valid forward path, retain the correct translated/stateful tuple, reach a listening dependency and return through a permitted path. Provider network/subnet scope and route priority also differ, so service-name matching creates false equivalence.

**Decision:** Teach and operate cloud/hybrid connectivity as `name -> address -> forward route -> policy -> translation/endpoint/load balancer -> listener/dependency -> return route -> user result`. Bind the original and translated five-tuples, evaluate the effective route and policy at each actual interface, and treat DNS view, address overlap, peering transitivity, NAT/connection state, MTU and dynamic route acceptance as independent evidence boundaries. Translate this model to current provider mechanisms only after scope, failure, quota, cost and ownership review.

**Consequences:** `LES-0052` remains quarantined until the normal-user Ubuntu lifecycle, reviewer-owned isolated transfer, provider-current design review, formal review and unseen learner evidence pass. The deterministic model cannot be cited as a packet forwarder, network emulator, VPN/BGP session, provider feature, cost result or production recovery. Future troubleshooting content may not claim reachability from connected control-plane objects or from forward-path evidence alone.

### DEC-051 - AWS reliability is a user-operation contract, not a managed-service label

**Status:** `ACCEPTED`

**Context:** AWS exposes separate green states for federated sign-in, organization policies, load-balancer target health, Auto Scaling desired capacity, container control planes, Lambda invocations, RDS failover, S3 encryption, CloudWatch alarms and backup jobs. Each state is useful but bounded. None alone proves that one customer operation is authorized, reaches the intended path, performs correct data work, survives a failure, recovers within objective or has an acceptable cost. “Managed” changes the responsibility boundary; it does not remove customer ownership of code, identity, data, limits and user reliability.

**Decision:** Teach and review AWS workloads as `user operation -> organization/account/Region/AZ scope -> authentication/authorization -> DNS/network/entry path -> compute contract -> data/key contract -> quota and failure capacity -> user-centered evidence -> tested recovery -> cost units`. Distinguish guardrails from grants, intent to scale from available capacity, target health from user SLIs, Multi-AZ from backup/DR, quota from provider stock, and configured backup from restored business correctness. Select EC2, ECS, EKS or Lambda from workload and team constraints rather than service prestige.

**Consequences:** `LES-0053` remains quarantined until Ubuntu execution, provider-current design review, sanitized plan review, reviewer-owned failure/recovery transfer, formal review and unseen learner evidence pass. Its local model cannot be cited as IAM evaluation, AWS networking, compute, data, telemetry, quota, failover, restore, pricing or production evidence. Azure and Google Cloud specializations must translate the same operating boundaries rather than copy AWS service names.

### DEC-052 - Azure reliability begins with scope and ends with the user

**Status:** `ACCEPTED`

**Context:** Tenant, management group, subscription, resource group, Region, zone, VNet and resource are different identity, governance, billing, lifecycle, network and failure scopes. Portal provisioning, RBAC assignments, backend probes, zone redundancy, Monitor alerts and backup jobs each expose bounded state but cannot individually prove a customer operation.

**Decision:** Teach Azure as `user operation -> tenant/management scope -> principal/role/scope and Policy -> DNS/VNet/private path -> compute -> data/Key Vault -> quota and zone capacity -> user SLI -> restored business operation -> cost meters`. Keep Policy distinct from permission, management actions distinct from data actions, desired scale distinct from available capacity, redundancy distinct from backup, and resource telemetry distinct from service reliability.

**Consequences:** `LES-0054` stays quarantined until Ubuntu, provider-current design, sanitized plan, reviewer failure/recovery, formal review and learner evidence pass. Its model is not Entra/RBAC/Policy, VNet, VMSS, AKS, Functions, Storage, SQL, Key Vault, Monitor, backup, price or production evidence.

### DEC-053 - Google Cloud reliability crosses global, regional, zonal, and policy scopes

**Status:** `ACCEPTED`

**Context:** Google Cloud combines a hierarchical organization/folder/project authority model, a global VPC with regional subnets, global or regional frontends, zonal workload capacity, regional managed services and product-specific data locations. IAM allow, deny and access-boundary policy, Organization Policy, service perimeters, backend health, autoscaler intent, managed-service state and Monitoring signals each describe only one boundary.

**Decision:** Teach Google Cloud as `user operation -> organization/folder/project ownership -> principal/role/permission/policy -> DNS/frontend/global VPC/regional subnet -> zonal compute -> data/KMS -> quota and surviving capacity -> user SLI -> restored business operation -> cost units`. Keep project scope distinct from network and failure scope, IAM distinct from Organization Policy, quota distinct from stock, regional placement distinct from useful surviving capacity, replication distinct from recovery and resource telemetry distinct from user reliability.

**Consequences:** `LES-0055` remains quarantined until Ubuntu, provider-current design, sanitized plan, reviewer failure/recovery, formal review and learner evidence pass. Its model is not IAM, VPC, MIG, GKE, Cloud Run, Storage, SQL, KMS, Monitoring, quota, failover, restore, price or production evidence.

### DEC-054 - Relational reliability follows the transaction and separates availability from recovery

**Status:** `ACCEPTED`

**Context:** A database can report healthy CPU, storage and readiness while a user operation waits for a pool slot, row lock, parameter-specific plan or stale replica. MVCC reduces reader/writer blocking but creates tuple-lifecycle and vacuum obligations. More connections and retries can amplify overload. A standby copies current state, including bad changes, while a completed backup job does not prove that a useful business state can be restored.

**Decision:** Teach and operate PostgreSQL as `user operation -> pool queue -> authenticated backend -> transaction snapshot and locks -> planner/executor -> pages and WAL -> commit or rollback -> application acknowledgement`. Bind diagnosis to operation identity, session, query fingerprint, parameter class, plan, wait owner and transaction result. Choose constraints, isolation, indexes, pool budgets, timeout layers and retries from explicit correctness and workload contracts. Keep high availability, replication, backup, point-in-time recovery, failover and verified restore as separate mechanisms and evidence.

**Consequences:** `LES-0056` remains quarantined until its Ubuntu/Docker lifecycle, representative scale, physical backup/PITR, standby/fencing/failover, formal review, reviewer-owned unfamiliar transfer and learner evidence pass. The disposable PostgreSQL lab cannot be cited as durable storage, TLS, pooler, replication, production performance, recovery objectives, formal acceptance or mastery.

### DEC-055 - Integration reliability is an acknowledgement and state-ownership contract

**Status:** `ACCEPTED`

**Context:** HTTP responses, broker acknowledgements, consumer checkpoints and webhook responses describe different durable facts. Treating accepted as completed, appended as processed, checkpointed as externally effected, or signed as fresh and authorized produces false success. Compatibility also depends on actual independently deployed producers and consumers, not whether a schema edit appears additive.

**Decision:** Choose request/reply, operation resources, commands, events and webhooks from timing, coupling and ownership. At every boundary record the stable logical identity, exact acknowledgement meaning, authoritative state owner, duplicate and ordering scope, compatible versions, retry owner, retention and reconciliation path. Use local transactions such as outbox/inbox only for the state they actually own; never extend an exactly-once claim across unsupported external effects.

**Consequences:** `LES-0057` remains quarantined until Ubuntu execution, representative API/broker/schema/webhook behavior, failure and replay exercises, formal review, reviewer-owned transfer and learner evidence pass. Its deterministic model cannot prove serialization, compatibility, delivery, ordering, signature security, external effects or production recovery.

### DEC-056 - Distributed correctness is operation-scoped authority, order, and repair

**Status:** `ACCEPTED`

**Context:** Replica count, health endpoints, wall-clock timestamps, leases and product-wide CAP labels do not prove what one user operation may observe or mutate. A timeout is compatible with delay, loss, pause, crash, commit or a lost response. Consensus can preserve one committed log while stale actors still mutate external state. Weaker consistency can preserve availability only when conflicts, convergence and user invariants are explicit.

**Decision:** Design and troubleshoot distributed state as `operation -> invariant and acknowledgement -> owner/partition -> failure and timing model -> consistency/session contract -> configuration/quorum -> election/epoch -> commit/apply -> lease and target-enforced fencing -> conflict/repair -> business and user proof`. Separate safety from liveness, reachability from authority, physical time from causality, replication from backup, and quorum arithmetic from a complete consistency proof. Require supported membership transitions, stable operation identities, explicit partition behavior and bounded repair capacity.

**Consequences:** `LES-0058` remains quarantined until its guarded Ubuntu lifecycle, representative disposable-cluster and history evidence, partition/election/membership/lease/fencing/repair fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its thirteen-case offline model cannot prove consensus, linearizability, availability, time bounds, conflict convergence, recovery or product behavior. No canonical route, registry record or learner level changes.

### DEC-057 - A cache is a controlled copy, and a data model begins with access

**Status:** `ACCEPTED`

**Context:** “NoSQL,” “schemaless,” high key cardinality, cache reachability and hit ratio erase the operation boundaries that determine correctness and capacity. One hot key or secondary index can throttle despite idle table capacity. A cache hit can be stale or unauthorized. TTL, invalidation and eviction are different removal mechanisms. Volatile write-behind can acknowledge data that failover loses, while aggressive warm-up or repair can collapse the authority.

**Decision:** Select the minimum store portfolio through `operation/invariant -> authority -> measured key/predicate/order/result access -> atomic scope -> partition/index distributions -> consistency/session contract -> cache key/revision -> fill/write/invalidation/TTL/negative/stale/eviction policy -> origin and failure capacity -> repair/reconciliation -> user/privacy proof`. Treat relational, document, key/value, wide-column, search and cache as mechanisms with product-specific guarantees. Require revision-aware fills, bounded stampede/origin controls, fail-closed security decisions and durable/reconcilable acknowledgements.

**Consequences:** `LES-0059` remains quarantined until Ubuntu lifecycle, representative data/cache services, measured skew/load/expiry/eviction/failover/repair/privacy-deletion exercises, formal review, reviewer transfer, delayed recall and learner evidence pass. Its model cannot establish database/cache behavior, throughput, consistency, durability, security or recovery. No route, registry or learner-state change is authorized.

### DEC-058 - Message reliability is an ownership chain, not a broker promise

**Status:** `ACCEPTED`

**Context:** A producer acknowledgement, replicated append, consumer delivery, checkpoint and external business effect are different durable facts. At-least-once recovery can redeliver after an effect succeeds, while early checkpoints can hide missing work. Aggregate capacity hides hot partitions; poison loops, rebalances and replay compete with live traffic. Product-scoped exactly-once mechanisms do not automatically include arbitrary external systems.

**Decision:** Design and troubleshoot messaging as `operation/invariant -> authoritative publication intent -> stable event identity/schema/key -> queue or retained-log semantics -> publisher acknowledgement/replica requirement -> partition-local order -> current consumer generation and target-enforced fencing -> idempotent/atomic/reconcilable effect -> checkpoint -> bounded retry/quarantine/redrive -> backlog/drain/retention/replay -> user proof`. State every guarantee with owners and failure boundaries. Capacity-test the hottest partition and every downstream dependency; isolate replay output and effects.

**Consequences:** `LES-0060` remains quarantined until its Ubuntu lifecycle, representative multi-node broker/client/effect runtime, duplicate/gap/poison/backlog/hotspot/rebalance/replica/replay fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its sixteen-case model cannot prove product delivery, ordering, transactions, replication, throughput, durability or recovery. No canonical route, registry record or learner-state change is authorized.

### DEC-059 - Workflow reliability makes partial success an owned state

**Status:** `ACCEPTED`

**Context:** One local transaction, a prepared distributed transaction, a saga step, a broker acknowledgement, an external effect and a workflow checkpoint have different owners and failure behavior. A timeout can hide success; compensation can fail; a relay can duplicate; concurrent sagas lack automatic isolation; and new code can become incompatible with retained histories. Calling all of this rollback or exactly once hides the states that operators must recover.

**Decision:** Keep an invariant in one local ACID transaction whenever one authority can own it. When work crosses independent authorities, select 2PC, choreography or durable orchestration from actual participant support, duration, isolation, availability and ownership. Model `operation -> workflow/state version -> compensable steps -> pivot -> retryable steps -> local state plus outbox -> fenced relay -> stable event/effect identity -> checkpoint -> compensation/manual state -> reconciliation -> user proof`. Treat compensation as a new idempotent business effect, preserve deterministic/versioned history and schemas, enforce concurrency at the participant authority, authorize at the chosen durable effect boundary, and capacity-test the slowest required state including recovery traffic.

**Consequences:** `LES-0061` remains quarantined until its guarded Ubuntu lifecycle, representative workflow/database/relay/broker/effect runtime, state/publish, effect/checkpoint, compensation, stale-owner, replay-version, capacity and reconciliation fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its nineteen-case model cannot prove workflow-engine, database, CDC, broker, provider, transaction, compensation, replay, capacity or production behavior. No canonical route, registry record or learner-state change is authorized.

### DEC-060 - Data reliability connects execution to the consumer decision

**Status:** `ACCEPTED`

**Context:** A green batch or stream job proves only an execution state. The source can omit records, event-time policy can discard valid late data, a checkpoint can be unusable, recovery can repeat a non-idempotent sink, skew can hide behind aggregate capacity, quality can ignore the affected population, and an unisolated replay can overwrite live corrections or resurrect deleted data. Engine-level delivery language does not cover every source, connector, state store, sink, consumer or privacy boundary.

**Decision:** Design and troubleshoot data products as `consumer decision and SLI -> immutable source identity/position/schema -> event/ingestion/processing time contract -> deterministic versioned transform and distribution plan -> recoverable state plus durable compatible checkpoint -> transactional/versioned/idempotent sink -> quality population and owned quarantine -> run/job/dataset/code lineage -> isolated replay and reconciliation -> approved promotion`. Treat boundedness separately from execution style, watermarks as progress estimates rather than completeness proof, checkpoint existence separately from restore compatibility, and aggregate throughput separately from hottest-partition and slowest-required-stage capacity. Include every raw, state, checkpoint, quarantine and output copy in privacy, retention and deletion control.

**Consequences:** `LES-0062` remains quarantined until its guarded Ubuntu lifecycle, representative Spark/Flink/Beam and source/state/checkpoint/sink/quality/lineage runtime, checkpoint/upgrade/skew/backpressure/replay/privacy fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its eighteen-case offline model cannot prove engine, connector, storage, sink, checkpoint, quality, lineage, privacy, load, recovery or production behavior. No canonical route, registry record or learner-state change is authorized.

### DEC-061 - A lakehouse table is an authoritative metadata graph, not a directory

**Status:** `ACCEPTED`

**Context:** A distributed SQL engine, external catalog, table-format metadata, object storage, authorization policy and consumer contract have different authorities. Directory listings include current, historical, shared, staged and orphaned objects but cannot identify logical table state. A write timeout can hide a committed snapshot; compaction can preserve rows while changing files; expiration can destroy rollback; orphan cleanup can race a live writer; one new format feature can strand an older reader; and idle workers can coexist with coordinator/catalog/metadata planning failure.

**Decision:** Design and troubleshoot the lakehouse as `consumer decision -> query/session/policy identity -> coordinator plan -> stages/tasks/splits/exchanges -> connector -> catalog current-metadata authority -> snapshot -> manifest list -> manifests -> data/delete files -> result reconciliation`. Publish immutable candidates through validated optimistic concurrency and an atomic catalog pointer, then reconcile ambiguous acknowledgement. Preserve stable field identity, require a reader/writer/connector compatibility matrix for schema/spec/format evolution, and separate compaction, manifest rewrite, snapshot expiration and orphan deletion. Maintenance requires measured debt, positive spare capacity, workload isolation, logical equivalence, rollback retention, privacy/legal review and audited cleanup.

**Consequences:** `LES-0063` remains quarantined until its guarded Ubuntu lifecycle, representative Trino/Iceberg/catalog/object-store runtime, commit ambiguity/conflict, format upgrade, planning/pruning, file/delete amplification, maintenance/retention/privacy and recovery fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its twenty-case model cannot prove query-engine, connector, catalog, table-format, storage, commit, evolution, maintenance, authorization, performance, recovery or production behavior. No canonical route, registry record or learner-state change is authorized.

### DEC-062 - A workflow run, tracked model, registry alias, and serving revision are separate truths

**Status:** `ACCEPTED`

**Context:** A green DAG can hide a required failure through terminal trigger rules; a failed task may have committed an external effect before acknowledgement; a retry can duplicate it; a backfill can starve live work through workers, metadata connections or downstream capacity. An experiment record can omit mutable data or environment identity. A registered version can remain undeployed, an alias can move without traffic changing, offline evaluation can exclude an affected population, and the exact model can behave differently when online features have different time, freshness or missing-value semantics. Notebook kernels execute arbitrary code and can cross identity, secret, data and accelerator boundaries.

**Decision:** Design and troubleshoot the path as `consumer decision -> DAG/run/data interval/bundle -> task instance/attempt/idempotency key -> committed data or feature output -> experiment/code/environment/data/feature identity -> representative evaluation and thresholds -> immutable model version/digest -> audited mutable alias -> pinned deployment revision/routing -> prediction/model/feature identity -> delayed outcome`. Make required terminal outcomes explicit, reconcile unknown acknowledgement before retry, bound retries inside one deadline, and isolate backfill at the tightest shared dependency. Treat promotion as an evidence-bearing pointer change, prove point-in-time feature parity with paired samples, classify drift before retraining, preserve reversible serving capacity, and isolate notebook kernels as arbitrary-code workloads.

**Consequences:** `LES-0064` remains quarantined until its guarded Ubuntu lifecycle, representative Airflow/MLflow/Jupyter/feature-store/model-serving runtime, false-green/acknowledgement/backfill/component/promotion/skew/drift/failure-capacity/privacy fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its twenty-two-case model cannot prove scheduler, executor, metadata database, worker, registry, model, feature, notebook, serving, drift, security, capacity, recovery or production behavior. No canonical route, registry record or learner-state change is authorized.

### DEC-063 - Specialized stores are selected and operated by their actual correctness contract

**Status:** `ACCEPTED`

**Context:** Cassandra, vector-search services and metadata catalogs can all return successful responses while violating the consumer's intended result. A Cassandra cluster average can hide a hot partition; a timeout can hide an applied write; missed repair and early tombstone purge can resurrect deleted data. A vector endpoint can become faster while approximate recall falls or a new embedding space becomes incomparable. A catalog can show no lineage because ingestion, identity matching or search projection is stale, and metadata itself can disclose sensitive structure. Replication, index completion and green ingestion jobs do not independently prove recovery, relevance or freshness.

**Decision:** Select and troubleshoot each service from its consumer operation and owned state path. For Cassandra use `query -> partition key -> token -> replicas -> acknowledgement/reconciliation -> commit-log/memtable/SSTables -> repair/tombstone/compaction -> restore`. For vector retrieval use `source/chunk identity -> model/version/preprocessing -> dimensions/metric -> point/payload -> filter and ANN candidates -> rerank -> sliced exact/labeled recall -> restore`. For a catalog use `authoritative source/version -> connector checkpoint -> ingestion -> metadata store -> lineage provenance -> search watermark -> authorized consumer decision`. Treat deletion evidence, semantic identity and observation coverage as correctness boundaries; size live work together with maintenance/rebuild/migration headroom; and validate recovery through consumer invariants rather than artifact existence.

**Consequences:** `LES-0065` remains quarantined until its guarded Ubuntu lifecycle, representative Cassandra/vector/catalog runtime, hot-partition/timeout/repair/deletion/compaction/backup, vector recall/filter/index/transfer/migration/restore, catalog freshness/lineage/access/recovery fault matrix, selection ADR, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its twenty-three-case offline model cannot prove database, query, replication, repair, storage, ANN quality, vector index, catalog ingestion, authorization, recovery, load or production behavior. No canonical route, registry record or learner-state change is authorized.

### DEC-064 - AI model output is an untrusted proposal, never production authority

**Status:** `ACCEPTED`

**Context:** Generated text can be fluent, schema-valid, grounded-looking and still be wrong, unsafe or unauthorized. Context size does not prove evidence use; retrieval does not prove source authority or claim support; a model-authored citation can be false; a model judge can share the tested model's blind spots; and untrusted documents or tool output can inject instructions. A valid tool call proves shape, while execution success proves only that an effect was attempted or completed. Broad credentials, nested retries and ceremonial human approval can convert one probabilistic error into amplified production impact.

**Decision:** Design AI-assisted engineering as `defined user task, harm, abstention and non-AI baseline -> versioned representative data and evaluation -> bounded token/context/retrieval lineage -> model proposal -> deterministic schema and policy validation -> independently authenticated authorization or meaningful human veto -> least-privilege idempotent effect -> independently observed postcondition and user outcome`. Keep instructions, retrieved data and tool results explicitly separated by trust; verify claims against authoritative source spans; constrain agents as durable state machines with one end-to-end deadline and step/token/tool/retry/effect/cost budgets; reconcile external state before retry; and preserve exact model, prompt, data, corpus, index, policy, tool and approval lineage for rollback and audit.

**Consequences:** `LES-0066` remains quarantined until its guarded Ubuntu lifecycle, representative model/tokenizer/embedding/retrieval/agent/tool/evaluator runtime, injection/exfiltration/authority/privacy/evaluation/rollback fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its twenty-four-case offline model cannot prove model quality, grounding, injection resistance, fairness, privacy, human oversight, provider behavior, safe effects or production reliability. No canonical route, registry record, tool authority, external effect or learner-state change is authorized.

### DEC-065 - AIOps ranks operational evidence; it does not manufacture cause or authority

**Status:** `ACCEPTED`

**Context:** An unusual value may be normal seasonality, a telemetry gap, a legitimate change or a real incident. Event, observed and ingest time can disagree. Alert compression can hide distinct incidents. A stale topology graph and a nearby deployment can create a convincing but false cause ranking. Feature attribution explains a model output rather than the production mechanism. A statistically accurate forecast can arrive after the operational action deadline, and broad retrying automation can amplify one false positive into an outage.

**Decision:** Design AIOps as `user operation and action contract -> semantic telemetry identity plus source/observation clocks and quality -> transparent baseline -> time-ordered representative evaluation -> detector or forecast candidate -> stable fingerprint and bounded incident grouping -> versioned topology/change/mechanism evidence -> explicitly uncertain cause candidates -> governed human feedback -> external deterministic policy and authority -> least-privilege idempotent action -> independently observed system and user postconditions`. Preserve raw-to-derived lineage, compare simple/no-skill baselines, score incident-level delay and operational error cost, treat review capacity as a queue, require forecast uncertainty to leave actionable lead, and keep simple SLO and hard safety controls independent from the AIOps path.

**Consequences:** `LES-0067` remains quarantined until its guarded Ubuntu lifecycle, representative telemetry/parser/detector/forecast/topology/incident/automation runtime, missing/delayed/reordered data, seasonal/change/drift, grouping/correlation, forecast/action-lead and bounded-remediation fault matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its twenty-nine-case offline model cannot prove detector quality, forecast accuracy, grouping correctness, causality, explanation faithfulness, reviewer capacity, safe automation or production reliability. No canonical route, registry record, executor authority, production effect or learner-state change is authorized.

### DEC-066 - The deployable AI unit is an immutable release graph, not a model name

**Status:** `ACCEPTED`

**Context:** A registry alias, image tag, Kubernetes readiness condition or allocated GPU can all be true while a request uses incompatible, harmful, slow or uneconomical behavior. Data, feature, model, tokenizer, prompt, retrieval, policy, image, runtime and evaluator identities can change independently. Kubernetes schedules advertised devices while model runtimes admit variable-length requests into memory, queues, batches and caches. Aggregate evaluation and infrastructure health can hide critical cohorts, tail latency, tenant interference, delayed outcomes and cost. Mutable aliases, cold rollback targets and unclassified drift make forensic explanation and recovery unreliable.

**Decision:** Define the deployable unit as `user operation and fallback -> immutable release manifest joining source/data/features/model/tokenizer/prompt/retrieval/policy/image/runtime/evaluation -> authorized registry promotion -> observed replica/load identity -> authenticated tenant-aware gateway and one deadline -> queue/runtime/GPU memory admission -> attributed request and outcome -> conjunctive quality/safety/SLO/capacity/cost canary gates -> compatible rehearsed rollback -> classified drift through the normal release path`. Record mutable aliases as control decisions but resolve immutable versions and digests at approval, deployment and request time. Treat GPU allocation, utilization, cache hits and HTTP readiness as bounded evidence rather than user success.

**Consequences:** `LES-0068` remains quarantined until its guarded Ubuntu lifecycle, representative artifact/registry/evaluator/model-server/gateway/Kubernetes/GPU/telemetry runtime, compatibility/load/fairness/failure/canary/rollback/drift/cost matrix, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence pass. Its thirty-case offline model cannot prove reproducibility, model quality, serving correctness, GPU capacity, route fairness, tenant isolation, canary safety, drift cause, unit economics, recovery or production reliability. No canonical route, registry record, GPU/cluster action, model/API call, external effect or learner-state change is authorized.

### DEC-067 - Model text may propose; only deterministic boundaries may grant effect authority

**Status:** `ACCEPTED`

**Context:** User prompts, retrieved documents, tool results and model output can all be attacker-influenced text in one probabilistic context. A system prompt or detector can improve behavior but cannot authenticate a subject, constrain a credential, bind approval or prove downstream state. Valid JSON can carry an unsafe sink value. A valid signature does not establish expected signer, provenance, safe serialization or behavior. Queued work can continue after an in-band stop, and raw prompt logging can turn observability into a second disclosure path.

**Decision:** Design AI effects as `authenticated operation and harm contract -> origin-labeled untrusted content -> model proposal only -> strict parse plus sink-specific semantic validation -> minimal typed tool -> deterministic subject/tenant/action/target authorization -> downstream least privilege and complete mediation -> immutable expiring approval for high impact -> idempotent commit and authoritative effect receipt -> structured privacy-aware audit -> independent route deny/credential revocation/egress/queue containment -> complete reconciliation and evidence-led recovery`. Keep detector metrics separate from escaped-attack containment and downstream effects. Evaluate direct, indirect, poisoning, leakage, output and supply-chain paths against protected system invariants. Treat digest, signature, signer/issuer trust, provenance, inventories, safe format and behavioral evaluation as separate claims.

**Consequences:** `LES-0069` remains quarantined despite its passing Ubuntu 24.04 guarded lifecycle. Representative model/detector/retriever/tool-broker/policy/approval/sandbox/signature/audit/kill behavior, novel and sliced adversarial evaluation, formal review, reviewer-owned unseen transfer, delayed recall and learner evidence remain required. Its thirty-one-case offline model cannot prove prompt-injection resistance, poisoning detection, leakage prevention, authorization correctness, isolation, provenance trust, audit completeness, containment or production safety. No canonical route, registry record, credential, model/API call, external tool effect, production action or learner-state change is authorized.

### DEC-068 - Supply-chain evidence is a graph of distinct claims; the consumer owns acceptance

**Status:** `ACCEPTED`

**Context:** A tag can move after scanning; an SBOM can describe another artifact; a scanner can return no findings after skipping input; provenance can authenticate an unexpected build path; a signature can be cryptographically valid for an unauthorized signer; and CI can pass while admission or runtime uses different bytes. Collapsing inventory, time-bound vulnerability matching, production history, cryptographic identity and authorization into one “secure artifact” badge makes substitution and recovery unexplainable.

**Decision:** Design delivery as `reviewed source identity -> frozen dependency graph and allowed sources -> isolated least-privilege builder -> immutable artifact digest -> artifact-bound SBOM plus authenticated provenance and time-bound scan evidence -> signature authentication -> consumer policy for subject/source/builder/signer/findings/exceptions -> promotion of the same digest -> independent admission -> runtime digest/owner inventory -> advisory and revocation reconciliation -> trusted rebuild and user/old-digest recovery proof`. Treat every statement as a separate claim with producer, subject, authentication, coverage, time and limitation. A producer may emit evidence; only the consuming environment may authorize use.

**Consequences:** `LES-0070` remains quarantined despite direct schemas, model, Git Bash, Ubuntu and repository regressions passing. Its offline 34-case model proves no resolver, dependency safety, scanner coverage, SBOM completeness, builder isolation, signature/provenance trust, registry integrity, admission enforcement, runtime inventory, vulnerability response or production security. Representative integration, tamper/revocation/recovery exercises, formal review, reviewer-owned transfer, delayed recall and learner evidence remain required. No canonical route, registry entry, real credential, public artifact, cluster change or learner-state change is authorized.

### DEC-069 - Security starts with owned promises and evidence, not product inventory

**Decision:** `SEC-001` will reason from a bounded user/business operation through assets, owners, classification, actors, capabilities, entry points and trust boundaries into concrete threat scenarios, likelihood/impact/uncertainty, accountable treatment, testable requirements, independent controls, decision-quality evidence, containment, recovery and owned residual risk. CIA and STRIDE are lenses; authentication, authorization, encryption, segmentation, logging and compliance remain distinct claims. A control is credited only for its stated threat and exercised evidence boundary.

**Rationale:** Tool-first checklists allow strong authentication to hide broken object authorization, TLS to hide plaintext or overbroad data access, private networks to substitute for identity, logs to substitute for detection and green availability to hide confidentiality loss. Product-company judgment requires connecting the user promise to specific policy decisions, failure modes, response authority and recovery proof.

**Consequences:** `LES-0071` remains quarantined despite direct schemas, a guarded 36-case model and full repository regressions passing. The model proves no real identity, authorization, cryptography, segmentation, logging, detection, incident response, compliance or adversarial resistance. Representative controls and injected faults, formal security/instructional review, reviewer-owned transfer, delayed recall and learner evidence remain required. No canonical route, real credential, public target, production action or learner-state change is authorized.

### DEC-070 - Hardening is desired-to-effective-state change; vulnerability handling is an evidence join

**Decision:** `SEC-003` will treat hardening as a controlled transition across desired, declared, admitted and effective state, with versioned applicability, canary, stop gates, rollback and positive plus negative proof. Vulnerability priority will join exact component and affected-range identity to deployed population, exposure, exploitation evidence, privilege/data consequence, compensating controls, change risk, evidence health, owner and time. CVSS, KEV and EPSS remain distinct signals. Compliance statements must bind requirement, population, procedure, evidence, time and limitation; they cannot become a system-security claim.

**Rationale:** A benchmark can be correct but inapplicable, a manifest can be declared but not enforced, a successful package install can leave old running code, a scanner can report zero after failed extraction, and an audit can pass while important attack paths remain outside scope. Collapsing those states into “hardened,” “patched,” “clean” or “compliant” creates false confidence and unsafe fleet changes.

**Consequences:** `LES-0072` remains quarantined despite direct schemas, a guarded 41-case offline model, a complete normal-user refusal/cleanup lifecycle and full canonical regressions passing. The model changes no host, container runtime, Kubernetes cluster or security policy and proves no real scan, patch, enforcement, audit, compliance outcome or adversarial resistance. Representative canary/rollback and effective-state evidence, formal technical/security/compliance review, reviewer-owned transfer, delayed recall and learner evidence remain required. No canonical route, privileged mutation, public target, external effect, production action or learner-state change is authorized.

### DEC-071 - Performance tuning is an outcome-scoped reversible experiment, not a setting recommendation

**Decision:** `LNX-008` will start from a named user operation and comparable workload, locate lost time through utilization/saturation/errors plus task state at host, process, cgroup, device and dependency scopes, and escalate to the least invasive profiler that can discriminate the hypothesis. A tunable is eligible only after its exact running-version semantics, effective configuration owner, security boundary, numerical success/abort criteria, representative canary, exact rollback and soak are recorded.

**Rationale:** High utilization can be healthy, an idle host can contain a throttled cgroup, low free memory can be useful cache, iowait and device utilization are not universal saturation verdicts, and a wide flame-graph frame is not automatically waste. A copied sysctl or incomparable benchmark can improve a graph while harming tail latency, neighbors, security, recovery or cost.

**Consequences:** `LES-0073` remains quarantined despite direct schemas, a guarded 43-case offline model, complete normal-user refusal/cleanup lifecycle and canonical regressions passing. Its synthetic cases prove no representative workload, real profile, tuning effect, kernel/cgroup/device behavior, performance improvement, security acceptance or production safety. Reviewer-owned transfer, measured before/after evidence, formal review, delayed recall and learner evidence remain required. No canonical route, privileged mutation, external request, production action or learner-state change is authorized.

### DEC-072 - Recovery is a validated business-flow state transition, not backup creation

**Decision:** `DR-001` will begin with a named critical business flow, approved correctness/RPO/RTO contract, authoritative-state and dependency map, and explicit recovery authority. Backup or replication status cannot establish recoverability. A recovery claim requires a complete identity-bound chain, independently available keys and controls, isolated restore, engine plus business/security validation, measured actual loss and elapsed time, old-writer fencing before traffic, and a separately governed failback/reconciliation plan.

**Rationale:** A green backup can be incomplete, a current replica can copy corruption, a valid checksum can protect unusable bytes, a running database can leave the user flow broken, and a DNS change can create two writers. Collapsing these boundaries into "DR ready" hides shared control-plane failures, key loss, application inconsistency, capacity limits and unsafe authority transitions.

**Consequences:** `LES-0074` remains quarantined despite direct schemas, a guarded 45-case offline model, complete normal-user refusal/cleanup lifecycle and canonical regressions passing. The model performs no backup, restore, database operation, writer fencing, routing, failover or failback and proves no real recovery point, measured RPO/RTO, recovery-site readiness, business continuity or production safety. Representative reviewer-owned drills, data/application/security review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, external resource, production action or learner-state change is authorized.

### DEC-073 - Chaos engineering is a governed decision-changing experiment, not a fault count

**Decision:** `CHAOS-001` will begin with a decision-changing uncertainty about a named critical user flow. A defensible experiment requires measurable steady state, a comparable control when possible, a falsifiable condition-mechanism-outcome hypothesis, just-in-time immutable target inventory, multidimensional exposure bounds, least-privilege authority, continuous independent effect and user evidence, a rehearsed abort with bounded cessation, and separate rollback and correct-state recovery proof. Game days exercise people, systems, communications and authority; unexpected impact converts the exercise to incident command. Results remain supported within scope, contradicted, inconclusive or unsafe and must produce owned verified learning.

**Rationale:** A fault controller can report success when the wrong target was selected, no effect occurred, customers failed or state remained incorrect. Component health can hide user and data failure. Dynamic selectors, correlated stop paths, moving thresholds and green rollback jobs create false safety. Counting faults rewards activity and blast radius rather than reduced uncertainty. Binding the claim to exact versions, targets, workloads, evidence and limitations prevents a local exercise or one successful run from becoming a universal resilience claim.

**Consequences:** `LES-0075` remains quarantined despite direct schemas, a guarded 47-case no-fault decision model, complete Ubuntu 24.04 normal-user refusal/cleanup lifecycle and canonical regressions passing. The model performs no intervention and proves no real target resolution, steady state, control/treatment comparison, fault effect, abort path, recovery, game-day response or production resilience. A reviewer-owned disposable experiment, reliability/security/data review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, credential, external resource, public target, production action or learner-state change is authorized.

### DEC-074 - A VM is a layered machine, identity and service contract; Running is not recovery

**Decision:** `PRV-001` will reason through `hardware/firmware -> Linux KVM API and process access -> QEMU machine/device runtime -> libvirt desired and live domain state -> image/backing/NVRAM and instance identity -> guest boot and initialization -> virtual/physical network and storage paths -> application, user and data correctness`. Host capability, exact-domain compatibility and fleet operability remain separate claims. CPU flags cannot prove `/dev/kvm` access; domain `Running` cannot prove guest or service readiness; migration completion cannot prove correct destination recovery. Placement and HA must preserve an explicit CPU/machine/firmware/device contract, multidimensional failure reserve and one-writer authority through quorum and independent fencing.

**Rationale:** A host can expose virtualization flags while KVM is inaccessible. A valid definition can request unsupported target capabilities. A small qcow2 overlay can depend on a missing base. A clone can duplicate UUID, MAC, NVRAM, machine ID, SSH keys, cloud-init cache and application identity. A migration can complete while the guest reboots, the network path fails or data authority is ambiguous. Two compute hosts can share power, management and storage and lack enough survivor memory. Collapsing these boundaries into "hypervisor healthy," "VM running" or "HA cluster" hides the exact failure and can turn recovery into duplicate writers or corruption.

**Consequences:** `LES-0076` remains quarantined despite direct schemas, a guarded 49-case no-VM decision model, complete Ubuntu 24.04 UID-1000 refusal/cleanup lifecycle and canonical regressions passing. Its read-only WSL inventory proves visible x86_64 CPU flags, inaccessible `/dev/kvm`, absent QEMU/libvirt commands and present cloud-init command discovery only. The model performs no KVM, QEMU, libvirt, image, network, VM, migration or fencing action and proves no real boot, performance, isolation, availability or recovery. Reviewer-owned disposable virtualization, technical/security review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, privileged mutation, external resource, production action or learner-state change is authorized.

### DEC-075 - OpenStack status is service-local evidence; operations end at the user and data boundary

**Decision:** `PRV-002` will trace every operation through `caller -> Keystone authentication/scope -> catalog region/interface/endpoint -> service policy/microversion/quota -> global and cell-owned control state -> Placement and scheduler -> RPC/conductor/worker or agent -> Glance/Neutron/Cinder backend realization -> hypervisor -> guest -> application -> user/data -> reconciliation and cleanup`. Nova ACTIVE, Glance active, a Neutron binding, a Cinder attachment, broker delivery or a Placement allocation remains an owner-local claim. Recovery requires one authoritative state path, old-writer fencing when applicable, supported reconciliation, representative user/data validation and exact residue proof.

**Rationale:** A valid token can have the wrong scope; a catalog can advertise a stale endpoint; 202 acceptance can precede failure; aggregate free capacity can have no eligible candidate; a cell queue can stall behind green global APIs; an image record can outlive store bytes; a bound port can lack flows; an attachment can lack a backend connection; and an ACTIVE VM can contain an unready application. Direct database edits, blind retries, global restarts and unfenced evacuation can convert partial failure into duplicates, split brain or data loss.

**Consequences:** `LES-0077` remains quarantined despite direct schemas, a guarded 51-case no-service decision model, complete Ubuntu 24.04 UID-1000 refusal/cleanup lifecycle and canonical regressions passing. The model invokes no OpenStack client or endpoint and performs no identity, API, database, queue, agent/controller, hypervisor, image, network, volume, instance, HA, upgrade or recovery action. It proves no deployed-release behavior, production resilience, formal acceptance or learner mastery. Representative reviewer-owned disposable OpenStack operations, technical/security review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, credential, external request, privileged mutation, public target, production action or learner-state change is authorized.

### DEC-076 - Ceph health and raw capacity are local claims; durability depends on eligible placement and physical failure domains

**Decision:** `PRV-003` will trace every write through `client identity/config -> monitor quorum and maps -> pool protection contract -> PG mapping -> CRUSH rule and physical failure domains -> primary acting OSD -> BlueStore/device and replica or erasure-code acknowledgements -> scrub/integrity -> recovery/backfill -> representative read and application/data validation`. `HEALTH_OK`, `active+clean`, raw free bytes, nominal replica count, an RBD attachment or command success remains a bounded owner-local claim. Remediation must preserve one-writer authority, current maps, data-bearing evidence, eligible survivor capacity, user latency and independently verified recovery.

**Rationale:** A cluster can report healthy between checks while replicas share one rack or power feed. Raw free capacity can be unusable for a specific pool because CRUSH eligibility, imbalance, erasure-code geometry, reservations or fullness thresholds bind placement. A degraded PG can serve data with less protection; a clean PG can still contain latent corruption not yet discovered by deep scrub. Marking an OSD out, lowering full thresholds, forcing repair, breaking an RBD lock or accelerating recovery without bounded evidence can create a movement storm, admit writes without reserve, choose the wrong copy, reintroduce an old writer or collapse user latency.

**Consequences:** `LES-0078` remains quarantined despite direct schemas, a guarded 56-case/55-gate no-cluster decision model, complete Ubuntu 24.04 UID-1000 authority/root/unknown-artifact refusal and cleanup lifecycle and canonical regressions passing. The model invokes no Ceph command and performs no cluster, map, pool, object, PG, CRUSH, OSD, device, RBD, client I/O, repair, recovery or upgrade operation. It proves no deployed-release behavior, physical failure-domain independence, data durability, production resilience, formal acceptance or learner mastery. Representative reviewer-owned disposable Ceph placement/failure/recovery/data validation, technical/security review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, credential, keyring, external request, privileged mutation, public target, production action or learner-state change is authorized.

### DEC-077 - OVS/OVN recovery follows intent, compilation, realization, transport, delivery and reply

**Decision:** `PRV-004` will trace each operation through `CMS identity/revision -> OVN NB authority/progress -> northd compilation -> OVN SB logical flows and bindings -> chassis identity/encapsulation -> controller convergence -> local OVSDB interfaces -> OpenFlow policy -> datapath execution -> overlay/underlay transport -> destination delivery -> application reply -> reverse path -> reconciliation and cleanup`. ACTIVE, quorum, a Port_Binding, an installed flow, a trace or a transmitted frame remains an owner-local claim. Direct edits to derived SB/OpenFlow state, global conntrack flushes, fleet restarts and forced gateway placement are refused without a proven bounded owner and recovery plan.

**Rationale:** A database can have quorum without the relevant commit progressing; NB intent can exist while northd lags; a port can bind to an old chassis; a controller can connect without converging; an Interface row can have `ofport=-1`; a higher-priority flow can shadow expected policy; ovn-trace can succeed while an underlay MTU black-holes Geneve; stale membership or conntrack can differentiate old/new flows; gateway failover can lose NAT or reverse-path authority. Collapsing these into “network down” encourages broad mutations that destroy evidence and unrelated tenant state.

**Consequences:** `LES-0079` remains quarantined despite direct schemas, a guarded 58-case/57-gate no-runtime model, complete Ubuntu 24.04 UID-1000 authority/root/unknown-artifact refusal and cleanup lifecycle and canonical regressions passing. The model invokes no OVS, OVN or Linux network command and performs no database, bridge, port, interface, namespace, flow, tunnel, policy, packet or gateway action. It proves no deployed-release behavior, packet delivery, production resilience, formal acceptance or learner mastery. Representative reviewer-owned disposable OVS/OVN topology, technical/security review, formal instructional review, delayed recall and learner evidence remain required. No canonical route, credential, socket, external request, privileged mutation, public target, production action or learner-state change is authorized.

### DEC-078 - Bare-metal operations require immutable physical identity and cross-plane reconciliation

**Decision:** `PRV-005` owns the bare-metal lifecycle. Every action follows `request/owner -> asset and physical identity -> BMC trust/authorization -> task and observed power -> firmware/boot policy -> management/provisioning network -> DHCP/PXE/iPXE artifacts -> ephemeral agent -> reconciled inspection -> RAID/root device/image write -> first boot -> workload/user -> health/capacity -> maintenance or sanitization -> ownership/audit cleanup`. A friendly name, accepted task, power-on reading, DHCP lease, downloaded image, completed write, green BMC roll-up or erase receipt remains an owner-local claim.

**Rationale:** Physical actions can be destructive and difficult to reverse. Asset, controller, BMC, firmware, agent, OS and workload identities can drift. Asynchronous actions can complete after client timeout. Enumeration names can select the wrong disk. Corrected errors can trend toward failure. Firmware updates can partially progress. Sanitization completion can be inadequate for the media, data or disposition.

**Consequences:** `LES-0080` remains quarantined despite direct schemas, a guarded 63-case/62-gate no-hardware model, complete Ubuntu 24.04 UID-1000 authority/root/device/unknown-artifact refusal and cleanup lifecycle and canonical regressions passing. The model invokes no hardware/provisioning tool and performs no BMC, server, switch, PXE, disk, firmware, power, burn-in or sanitization action. Representative reviewer-owned disposable lifecycle/recovery/sanitization evidence, technical/security/instructional review, delayed recall and learner evidence remain required.
