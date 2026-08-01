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
| `DEC-014` | 2026-08-02 | `PROVISIONAL` | Keep current lessons in typed TypeScript, migrate future content toward MDX |
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

**Decision:** Publish coherent groups of approximately five lessons in prerequisite order. Batch availability never auto-advances skills or phases.

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

### DEC-014 - Typed now, MDX later

**Context:** The first five lessons use TypeScript structures, which provided fast type feedback while the lesson schema evolved. Those files are becoming large and mix content with application code.

**Decision:** Keep the current typed data model while stabilizing the standard. New volumes move toward validated Markdown/MDX under `book/volumes/...`; migrate existing lessons only after parity tests exist.

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
