# Reliability Atlas — Book Specification

Version: 1.0
Status: Binding content and product contract
Last updated: 2026-08-02

## Purpose

This repository will become a durable, local-first field manual for DevOps, Site Reliability Engineering (SRE), platform engineering, infrastructure, cloud, data-platform operations, security, and production engineering.

The manual must help a committed reader move from first principles to production judgment. It must explain why systems behave as they do, provide safe ways to observe and change them, and require evidence before claiming skill. It is not complete because a table of contents exists, a page renders, or a learner has read a chapter.

The current canonical worktree is an early implementation. Twenty-six routed lesson identities are available across Volumes 00 through 04: five established typed lessons and twenty-one schema-backed `substantive-draft` lessons (`LES-0006` through `LES-0026`). The structured corpus contains 63 assessments—forty-two complete-answer records and twenty-one answer-isolated independent transfers—and 172 references. `LES-0026` / `V04-L01` / `OBS-001` is assigned to `/book/reliability/observability-foundations`. Its deterministic local five-signal fixture demonstrates only its encoded metrics, logs, synthetic traces, events, Python `cProfile` counts, ordering, loss, cardinality, sampling, retention, privacy, and cleanup behavior. It is not a production service, an OpenTelemetry SDK or Collector, Prometheus, Grafana, a continuous profiler, or a vendor backend, and it does not establish production-provider behavior. The `LES-0025` CI engines retain the same provider-proof boundary for GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines. These are project artifacts, not accepted chapters or learner evidence. The LES-0026 canonical promotion is uncommitted until its final integrated gates, feature commit, push, and remote parity are recorded. Formal technical and instructional acceptance, manual browser QA, independently reviewed learner transfer and delayed recall, representative real-environment exercises, and provider-specific evidence remain open. Most curriculum domains remain planned or not started. `CONTENT_MATRIX.md` is the authoritative coverage audit; `progress/ledger.md` remains the authoritative learner-evidence record.

## Sources of truth

Use these sources in this order when they address different concerns:

1. The external `DevOps-SRE-Prompt.txt` governs teaching, safety, assessment, and mastery.
2. `BOOK_SPEC.md` defines what the complete book and website must deliver.
3. `CONTENT_MATRIX.md` records coverage, current evidence, gaps, and acceptance evidence by stable domain ID.
4. `book/LESSON-STANDARD.md` and `book/CONTRIBUTING.md` define the detailed chapter and contribution workflow.
5. `progress/ledger.md` records learner competency; content publication never overrides it.

When documents conflict, preserve safety and evidence requirements, record the conflict, and correct the lower-level document. Never silently weaken a standard to mark work complete.

## Target audiences

| Audience | Starting point | What the manual must provide |
|---|---|---|
| New learner | Basic computer use; little Linux or infrastructure knowledge | Term-first explanations, safe Ubuntu setup, small diagrams, guided commands, expected output, and bounded labs |
| Junior engineer | Familiar with commands but limited production ownership | Internals, failure boundaries, verification, troubleshooting paths, and independent practice |
| Mid-level DevOps or infrastructure engineer | Can build familiar systems | Cross-domain incidents, automation, CI/CD, infrastructure as code, Kubernetes operations, security, and trade-offs |
| Senior SRE or platform engineer | Operates production and makes design decisions | Ambiguous incidents, capacity and reliability analysis, migrations, failure-mode analysis, organizational interfaces, and design reviews |
| Lead, staff, or architect | Owns multi-team technical direction | Requirements discovery, alternatives, economics, governance, platform product decisions, executive communication, and novel constraints |
| Interview candidate | Preparing for junior through staff-level roles | Differentiated conceptual, operational, coding, incident, architecture, and behavioral practice with model answers and scoring guidance |
| Mentor or contributor | Extends or reviews the manual | Stable schemas, prerequisites, acceptance evidence, version records, runnable validation, and explicit incomplete states |

The same chapter may serve several audiences through progressive depth. It must not make a beginner read staff-level material before the foundation, and it must not force an experienced reader through repeated elementary prose to reach operational depth.

## Prerequisite policy

### Reading prerequisites

Volume 00 assumes only basic ability to use a computer, open a terminal, and edit a text file. Every later lesson declares stable prerequisite lesson IDs and links to the exact concepts it uses.

The reader exposes resolved prerequisites as advisory navigation. A prerequisite link helps a reader repair context; it never hides or locks a lesson, marks the prerequisite complete, or changes learner competency. Missing or invalid prerequisite identities fail closed rather than creating a guessed route.

No lesson may rely on an unexplained acronym, command, protocol, operating-system mechanism, mathematical concept, or cloud abstraction. A short prerequisite recap is acceptable; duplicating an entire earlier lesson is not.

### Default lab environment

- Ubuntu 24.04, including Ubuntu 24.04 under Windows Subsystem for Linux (WSL 2), is the default workbench.
- Labs run as a normal non-root user unless privilege is the mechanism being taught.
- Docker is used for resource exhaustion, namespace, cgroup, mount, or other failures that are unsafe on the host.
- A disposable virtual machine is used for boot, kernel, firewall, logical-volume, host-mount, or destructive systemd changes.
- A local Kubernetes cluster is used only when Kubernetes reconciliation or cluster behavior is the lesson.
- Online cloud accounts are not required for the core path. Cloud behavior is taught with diagrams, local models, plan output, policy exercises, and optional separately approved sandboxes.
- Every lab declares its own CPU, RAM, disk, ports, packages, network use, versions, and supported environments; the defaults are not a substitute for an environment card.

### Dependency rule

Check for a command before installing its package. Installation is always a separate, labeled, networked and mutating step. No lesson may run automatic `sudo`, download and execute remote code, request real credentials, or create paid resources without explicit scope and approval.

## Learning outcomes

A reader who completes the required evidence—not merely the reading—should be able to:

1. derive system behavior from operating-system, network, application, and distributed-system mechanisms;
2. map a request, data flow, control flow, trust boundary, state owner, and failure domain;
3. distinguish signals from conclusions and state what evidence proves or cannot prove;
4. diagnose unfamiliar incidents with the FRAME loop: Frame, Retrieve, Analyze, Make a safe move, Evaluate and encode;
5. evaluate tools and systems with OPERATES: outcomes, path, execution, reliability, access, telemetry, economics, and safe change;
6. design systems with SCALE: scope, calculate, architect, locate risks, and explain trade-offs;
7. automate repeatable work using tested Bash and a primary programming language while handling errors explicitly;
8. build reproducible artifacts and safe delivery pipelines with security, rollback, and observability;
9. provision, configure, and review infrastructure through validated, least-privilege code;
10. operate containers and Kubernetes from their Linux and reconciliation models rather than memorized commands;
11. define meaningful service-level indicators (SLIs), service-level objectives (SLOs), alerts, capacity models, recovery objectives, and runbooks;
12. lead incidents, communicate uncertainty, restore service safely, produce useful post-incident reviews, and verify prevention;
13. reason about data stores, queues, caching, consistency, replication, backpressure, and partial failure;
14. design internal platforms that solve measured developer problems and expose safe self-service interfaces;
15. compare cloud, private-cloud, managed, self-hosted, and hybrid options across reliability, security, operability, capacity, and cost;
16. use artificial intelligence as an accelerator while independently validating commands, code, configuration, claims, and production actions;
17. explain and defend decisions at junior, senior, staff, management, and executive levels without fabricating experience or metrics.

## Curriculum scope

### Core volumes

1. **Volume 00 — Start safely.** Systems thinking, Ubuntu setup, shell survival, safe Git workflow, command-risk labels, evidence handling, cleanup, secrets, and the FRAME, OPERATES, and SCALE reasoning models.
2. **Volume 01 — Linux systems.** Filesystems, processes, descriptors, signals, systemd, CPU and memory, identity, permissions, boot, logs, libraries, time, block I/O, namespaces, cgroups, performance, and hardening.
3. **Volume 02 — Connectivity.** Ethernet, ARP, IP, CIDR, routing, NAT, UDP, TCP, sockets, MTU, DNS, HTTP, proxies, caching, load balancing, TLS, PKI, mTLS, and private or hybrid connectivity.
4. **Volume 03 — Engineering and delivery.** Git internals, Bash, Python, Go foundations, APIs, tests, packaging, dependencies, artifacts, release engineering, OCI containers, CI/CD, deployment strategies, GitOps, and software supply-chain foundations.
5. **Volume 04 — Reliability and operations.** Observability, SLIs and SLOs, error budgets, alerting, capacity, overload, resilience, incident command, runbooks, toil, backup, restore, disaster recovery, and chaos engineering.
6. **Volume 05 — Infrastructure and platforms.** Terraform/OpenTofu, state, drift, policy, configuration management, image construction, Kubernetes, platform engineering, golden paths, self-service, upgrades, multi-tenancy, and platform SLOs.
7. **Volume 06 — State and distributed systems.** SQL and NoSQL stores, indexes, transactions, locks, caches, queues, streams, replication, consistency, partitioning, consensus, clocks, idempotency, sagas, outbox patterns, delivery guarantees, and schema evolution.

### Specialist tracks

- **Clouds.** AWS/EKS, Azure/AKS, GCP/GKE, cloud reliability, identity, governance, hybrid connectivity, and FinOps.
- **Private cloud.** KVM, libvirt, OpenStack, Ceph, OVS, OVN, virtualization capacity, and failure operations.
- **Data and machine-learning platforms.** Spark, Flink, Trino, Iceberg, Airflow, MLflow, catalogs, Cassandra, notebooks, vector systems, and platform operations.
- **Security and DevSecOps.** Trust, secrets, certificates, software supply chain, vulnerability management, runtime hardening, compliance evidence, and policy enforcement.
- **Architecture, leadership, career, and interviews.** System design, capacity and migration, technical strategy, communication, truthful experience evidence, role roadmaps, and calibrated interview practice.
- **Artificial intelligence.** Validated AI-assisted engineering, AIOps, MLOps, LLMOps, AI-platform operations, evaluation, and AI security.

### Capstones

Capstones integrate the core volumes and specialist tracks into production-style service, platform, data, private-cloud, and secured-AI systems. They are evidence gates, not additional numbered volumes.

### Canonical volume and domain crosswalk

Every stable domain ID has one canonical home. Prerequisite links and cross-cutting treatment do not create another volume number or move that home.

| Canonical home | Stable domain IDs |
|---|---|
| Volume 00 — Start safely | `FND-001`, `DBG-001..002`, `DOC-001` |
| Volume 01 — Linux systems | `LNX-001..008` |
| Volume 02 — Connectivity | `NET-001..007` |
| Volume 03 — Engineering and delivery | `SCM-001`, `AUT-001..005`, `BLD-001`, `REL-001`, `CI-001..002`, `GITOPS-001`, `CTR-001..002` |
| Volume 04 — Reliability and operations | `OBS-001..005`, `SRE-001..004`, `PERF-001`, `RES-001`, `DR-001`, `CHAOS-001` |
| Volume 05 — Infrastructure and platforms | `IAC-001`, `TFM-001..002`, `CFG-001`, `K8S-001..008`, `PLT-001..004` |
| Volume 06 — State and distributed systems | `DST-001..006` |
| Clouds specialist track | `CLD-001..002`, `AWS-001`, `AZR-001`, `GCP-001`, `IAM-001`, `FIN-001` |
| Private-cloud specialist track | `PRV-001..004` |
| Data and ML specialist track | `DMP-001..004` |
| Security specialist track | `SEC-001..003` |
| Architecture, leadership, career, and interviews specialist track | `ARC-001..002`, `LDR-001`, `INT-001..002`, `CAR-001` |
| AI specialist track | `AIO-001..004` |
| Capstones | `CAP-001..005` |
| Website and publishing workstream (not a book volume) | `WEB-001..007` |

Security, reliability, observability, performance, economics, accessibility, and safe change are cross-cutting requirements in every relevant domain, not end-of-book add-ons.

### Out of scope and honest boundaries

- The book cannot contain literally all future knowledge. It must provide complete stated coverage, strong first principles, extension paths, and dated version boundaries.
- Reading alone does not guarantee mastery, certification, employment, or production readiness.
- The default path does not operate employer production systems or create online cloud resources.
- Vendor screenshots and memorized console tours are not substitutes for mechanisms, APIs, infrastructure code, and evidence.
- A lesson may describe high-risk operations but may not invite the reader to perform them without a disposable boundary, recovery path, and explicit authorization.
- Experience, incident results, cost savings, performance numbers, and portfolio metrics must never be invented.

## Difficulty levels

| Level | Reader expectation | Required content and evidence |
|---|---|---|
| Foundation | No prior concept knowledge | Terms, purpose, system picture, basic mechanism, safe observation, and simple recall |
| Beginner | Can follow a guided path | Common operations, explained commands, expected outputs, bounded guided lab, and validation |
| Intermediate | Can work independently in familiar cases | Independent lab, configuration, common failures, troubleshooting decisions, tests, and cleanup |
| Advanced | Can handle interacting components | Internals, partial failure, security, performance, reliability, cost, alternatives, and failure injection |
| Senior | Can operate and design under ambiguity | Incident leadership, blast radius, migration, capacity, observability, rollback, trade-offs, and cross-domain transfer |
| Expert / Architect | Can derive, review, and teach novel systems | Multi-option design, organizational constraints, economics, governance, unfamiliar transfer, critique, and teaching evidence |

A page labeled “advanced” must contain advanced decisions and consequences. More commands or more vendor features do not by themselves increase difficulty.

## Required lesson contract

Every substantive public lesson must include, where applicable:

1. stable lesson ID, domain ID, difficulty, estimated time, target roles, last-reviewed date, tested versions, prerequisites, and known limitations;
2. learning objectives and a concrete explanation of production relevance;
3. “what you see” and “where your mind goes first” guidance;
4. a term-first glossary with everyday meaning, precise meaning, and operational relevance;
5. a compact mental model plus big-picture, request/state path, and failure-zoom diagrams with text equivalents;
6. internals, state ownership, concurrency or consistency assumptions, and boundary behavior;
7. commands or code introduced by the exact question they answer;
8. flag-by-flag and field-by-field decoding, realistic sample output, units, sampling behavior, combinations, traps, what is not proved, and safest next evidence;
9. configuration or code examples that follow current project conventions and are validated where practical;
10. real production use cases and a decision path rather than a command dump;
11. an Ubuntu-first guided exercise or a documented reason that another safe environment is required;
12. expected observations, success and abort criteria, verification, recovery, cleanup, and cleanup proof;
13. common mistakes and explicit security, reliability, observability, performance, capacity, and cost consequences;
14. at least one failure scenario with a methodical debugging path;
15. a realistic incident scenario with investigation, mitigation, recovery verification, root cause, and prevention guidance;
16. three to seven useful knowledge checks, followed by complete explanations available only after an attempt or explicit reveal;
17. interview questions with model answers, weak-answer warning signs, evidence, deeper follow-ups, and level expectations;
18. a separate independent or changed-constraint transfer exercise with deliverable and scoring rubric;
19. further exploration, related lessons, memory card, summary, and spaced-review suggestions;
20. primary references and explicit markers for claims that still require verification.

Not every small reference page needs a lab or incident. Any omission must be appropriate to the page type and stated in its metadata. A domain cannot be complete if its primary operational lessons avoid hands-on and failure evidence.

## Depth and self-contained explanation standard

Use progressive disclosure:

```text
five-minute picture
  -> foundation explanation
  -> precise mechanism
  -> visible evidence and interpretation
  -> guided practice
  -> failure and recovery
  -> production transfer
  -> senior trade-offs
  -> independent mastery challenge
```

Define a term before using it to carry an explanation. Expand acronyms on first use. Explain the boundary a component owns, where state lives, what changes over time, and how the reader could observe it.

Depth is a causal chain, not repetition:

```text
symptom -> mechanism -> signal -> hypothesis -> safe decision -> verification -> prevention
```

Each advanced section must add at least one of: changed scale, partial failure, ambiguity, security boundary, performance limit, cost driver, migration constraint, competing option, organizational ownership, or novel transfer.

## Technical accuracy standard

- Prefer operating-system manuals, standards, upstream project documentation, specifications, source code, release notes, and other primary sources.
- Record product and tool versions when behavior is version-sensitive.
- Distinguish documented fact, observed local behavior, inference, assumption, hypothesis, and unverified claim.
- Test commands and configurations in the stated environment when practical; never imply execution that did not occur.
- Do not invent commands, flags, APIs, fields, URLs, benchmark results, limitations, or product capabilities.
- Do not treat example output as guaranteed output. Label it as synthetic, illustrative, or observed and explain variability.
- Check deprecations, default changes, compatibility, licensing, and support boundaries before publication.
- Mark unresolved claims `VERIFY` with the exact source or experiment required; unverified critical instructions cannot be accepted.
- Paraphrase sources and preserve attribution. Do not copy large copyrighted passages.
- Review changed technical claims and dependencies before updating the last-reviewed date.

## Writing standard

- Write engineer to engineer in plain, precise language.
- Use the pattern: “When you see this signal, think about this boundary first.”
- Keep necessary technical terms and translate them immediately.
- Prefer short sections, descriptive headings, decision tables, causal diagrams, and worked evidence over walls of prose.
- Avoid generic motivation, empty superlatives, artificial dialogue, unexplained jargon, and content added only to increase size.
- Separate observation from interpretation and immediate cause from root cause.
- State uncertainty and trade-offs honestly.
- Use consistent terminology across lessons; add durable terms to the glossary rather than redefining them inconsistently.
- Provide text equivalents for diagrams and never rely on color alone.
- Write examples with neutral synthetic names; never include employer data, credentials, private URLs, tenant IDs, or production identifiers.

## Diagram standard

A meaningful diagram answers who initiates work, direction of data or control, protocol and port when relevant, state location, trust or namespace boundaries, failure points, and evidence locations.

Use three levels when they add value:

1. big-picture topology;
2. request, data, state, or control path;
3. failure zoom at the exact rejected operation or exhausted resource.

Diagrams must have a defined reading direction, labels, and a text explanation. Decorative diagrams do not satisfy the standard.

## Command, code, and configuration standard

Before a command or change, state:

- the question it answers;
- `[READ-ONLY]`, `[MUTATING]`, `[DESTRUCTIVE]`, or `[COST-INCURRING]`, adding network and privilege notes when relevant;
- exact target and namespace;
- prerequisites and important flags;
- expected branches and their meaning;
- what the result cannot prove;
- success and abort criteria;
- rollback or recovery for a change.

Placeholders must be visibly distinct from executable values. Code must validate inputs at boundaries, handle errors explicitly, avoid secrets, and include relevant tests. Infrastructure examples must use format, lint, validate, test, security scan, plan or diff, review, bounded apply, verification, and rollback readiness.

## Lab standard

Every substantial lab declares:

- objective and relationship to the lesson;
- prerequisites, environment, exact relevant versions, estimated time, CPU, RAM, disk, and ports;
- privilege, network, cost, security, and blast-radius boundaries;
- initial architecture and state;
- preflight and dependency checks;
- prediction before mutation;
- setup, execution, observation, validation, failure injection, recovery, cleanup, and cleanup proof;
- expected output with allowed variation;
- success and abort criteria;
- troubleshooting guide;
- concrete evidence artifact and scoring rubric.

Prefer read-only host observation, then bounded non-root temporary resources, then hardened containers, disposable virtual machines, or local Kubernetes according to risk. Guided labs and mastery labs are separate. A mastery lab must not expose its complete solution before the attempt.

Executable shell labs must follow `book/LESSON-STANDARD.md`, including strict mode, private umask, lesson-specific temporary paths, sentinels, ownership validation, process re-identification, loopback binding, and proven cleanup.

## Quiz and assessment standard

- Questions must test an objective, misconception, evidence interpretation, or decision—not trivia.
- Use open-ended recall before multiple choice for important concepts.
- Every question has a direct answer, foundation explanation, causal reasoning, production interpretation, common weak answer, and useful follow-ups where appropriate.
- Immediate feedback explains why each option is safe, unsafe, sufficient, or incomplete.
- Assessment challenges remain separate from fully revealed guided answers.
- Store browser completion as convenience only; record mastery only after reviewed repository evidence.
- Major exercises use the 0–4 rubric for mental model, requirements, evidence, hypotheses, implementation, validation, reliability, security, rollback, performance, cost, trade-offs, communication, documentation, and independence.

## Incident standard

Incidents begin with incomplete evidence and reveal information through relevant investigation. Each substantive domain must eventually include at least one incident appropriate to its risks.

An incident package contains:

- user impact, scope, start time, expected behavior, recent change, and constraints;
- synthetic telemetry, logs, configuration, and red herrings with a coherent ground truth;
- ranked hypotheses and evidence gates;
- safe mitigation, authorization, abort, rollback, and communication decisions;
- system and user-visible recovery checks;
- immediate cause, root cause, trigger, contributing factors, and detection gaps;
- prevention work with owner, verification, and measurable completion criteria;
- facilitator guide and scoring rubric separate from the learner prompt.

Prioritize people and data, stabilize service, communicate, preserve evidence, diagnose, recover, verify, learn, and prevent recurrence.

## Interview-preparation standard

Significant interview items record:

- stable question ID, topic, difficulty, target role and level;
- what the interviewer evaluates;
- concise answer and deeper model answer;
- assumptions and clarifying questions;
- weak-answer warning signs and why they matter;
- evidence, commands, code, or diagram when useful;
- realistic follow-ups with answers and changed constraints;
- scoring dimensions and expected depth by level.

The bank must include conceptual, command-line, coding, troubleshooting, incident, architecture, design-review, behavioral, leadership, and project-defense formats. Prefer differentiated questions over numerous paraphrases. Never fabricate a learner's experience; behavioral preparation uses truthful STAR-L evidence only.

## Capstone standard

Capstones integrate domains rather than repeat isolated tutorials. The program must ultimately contain at least three independently reproducible production-style capstones, including:

1. a service operated from Linux through tested build, delivery, telemetry, SLO, incident, backup, and recovery;
2. an infrastructure and Kubernetes platform with policy, GitOps, safe rollout, multi-tenancy, and a developer golden path;
3. a distributed data or event system with measurable reliability, backpressure, failure recovery, and capacity behavior.

Specialist capstones should add private cloud, data/ML platform operations, and a secured AI incident assistant.

Each capstone includes requirements, assumptions, source, tests, reproducible environment, architecture and trust diagrams, decision records, threat model, infrastructure code, pipeline, telemetry, SLO, alerts, runbooks, load and failure tests, backup and restore, rollback, cost model, post-incident review, known limitations, demo evidence, and 5-, 15-, and 30-minute defense formats.

## Website product requirements

The local website is the reading and practice interface; Git remains the durable source of truth.

### Required experience

- routed curriculum, volumes, chapters, breadcrumb, table of contents, and correct previous/next links;
- local full-text search across titles, terms, commands, symptoms, and interview questions;
- topic, role, and difficulty filters;
- estimated time, prerequisites, related topics, and status labels on each lesson;
- expandable depth sections without hiding required foundation content;
- syntax-highlighted code blocks with accessible copy feedback;
- interactive quizzes with answer explanations;
- interview practice with deliberate reveal and level guidance;
- troubleshooting scenarios and lab checklists;
- glossary, command reference, memory cards, and cheat sheets;
- device-local reading position, display preference, bookmarks, and completion markers;
- explicit distinction between “read,” “practiced,” “submitted,” and “verified mastery”;
- useful empty, not-found, loading, invalid-data, and unavailable-lab states;
- paper and night themes, print view, responsive layout, and keyboard navigation.

### Accessibility, performance, and security

- Use semantic HTML, labeled controls, visible focus, skip links, logical heading order, sufficient contrast, and text alternatives.
- Do not rely on hover, color, pointer input, or animation for meaning; respect reduced-motion and text-size preferences.
- Keep normal reading lightweight: text, CSS, small diagrams, local assets, and route-level loading rather than one enormous page.
- Avoid analytics, external fonts, unnecessary client state, and speculative dependencies.
- Bind the development server to loopback by default.
- Store only non-sensitive preferences in browser storage. Never accept secrets or employer production evidence.
- Validate content schemas and internal links during the build.
- Maintain useful error boundaries and do not suppress build, type, lint, accessibility, or security failures to obtain a green result.

### Persistence boundary

Browser state is not durable mastery evidence. Reviewed submissions, assessment results, review dates, and competency changes live in Git. A future localhost companion may write only narrowly validated evidence files after explicit user action; it may never assign mastery or push credentials automatically.

## Content architecture and maintainability

- Each domain, lesson, lab, quiz, incident, interview item, and capstone receives a stable ID.
- IDs are never reused. Renames preserve aliases or redirects.
- Structured Markdown or MDX under `book/` becomes the canonical content source; React components render it and must not become the long-term prose database.
- Executable labs live in dedicated directories with verification.
- Content metadata is validated against a versioned schema.
- Generated navigation, search indexes, and progress views derive from canonical metadata rather than duplicated arrays.
- Contributor changes include source review, link validation, content-schema validation, focused tests, build, secret scan, and recorded limitations.
- Duplicated material is replaced with a canonical explanation and contextual links unless repetition is necessary for a safe standalone procedure.

## Mastery and progression

Content state and learner state are independent:

```text
content: planned -> seeded -> substantive draft -> verified chapter -> complete domain
learner: available -> read -> guided practice -> submitted -> independently verified
         -> unfamiliar transfer -> delayed recall -> durable mastery
```

Capability levels remain L0 through L5 as defined by the governing program. Durable mastery requires successful performance on at least two separated occasions, including an unfamiliar transfer problem. Lesson completion, confidence, certification, or copied output cannot raise mastery by itself.

## Honest completion criteria

### Chapter complete

A chapter is complete only when all applicable lesson-contract sections are substantive, examples are accurate, answers exist, the guided and independent practice boundaries are clear, runnable work succeeds in the stated environment, cleanup is proven, references and versions are recorded, internal links work, and content plus website validation passes. A prose-only overview is not a complete operational chapter.

### Domain complete

A domain is complete only when every planned foundational through target-level chapter is accepted, prerequisites and related topics are connected, at least one meaningful practical exercise and one failure or design transfer are verified, quiz and interview coverage meet the domain objectives, duplication and terminology are reviewed, and `CONTENT_MATRIX.md` contains evidence rather than a claim.

### Website complete

The website is complete only when all accepted content is reachable and searchable; filtering, progress, bookmarks, quizzes, answers, interview practice, code-copy behavior, error states, themes, responsive views, print, and keyboard use work; build, lint, type, content-schema, and link checks pass; accessibility and security reviews have recorded evidence; and no known critical defect remains.

### Program complete

The program is complete only when:

- every required and expanded domain in `CONTENT_MATRIX.md` is `Complete`, not merely planned, seeded, or drafted;
- required labs, quizzes, incidents, interview items, architecture exercises, and capstones have accepted evidence;
- all persistent project tasks contain no pending, in-progress, blocked, or review-required work;
- duplicate and contradictory material has been audited;
- the site and all supported labs pass their validation contracts;
- known limitations are explicit and no critical safety, correctness, security, accessibility, or data-loss risk remains;
- running, testing, building, extending, recovering, and contributing instructions are current.

At version 1.0 of this specification, the repository does **not** meet program completion criteria. That statement must remain true until the evidence in the matrix and verification records supports changing it.

## Change control

Changes to this specification require a documented reason, affected matrix IDs, migration impact, and review of whether the change weakens safety or acceptance criteria. Expanding scope is allowed when it closes a genuine engineering gap. Reducing scope requires explicit approval and must not be used to relabel incomplete work as complete.
