# Master Plan

Last updated: 2026-08-02

This is the durable delivery plan for the Systems Reliability Field Manual and its evidence-driven DevOps, SRE, platform, cloud, data, security, and architecture learning program. It describes project delivery, not learner mastery. Reviewed competency remains in `progress/ledger.md`.

## Control rules

- Work IDs in this file are permanent. Never reuse or silently rename an ID; supersede it and link the replacement.
- A lesson being readable is not the same as its lab being validated, and neither condition proves learner mastery.
- `progress/ledger.md` is the only competency authority. `PROGRESS.md` tracks project delivery.
- Prefer local, Ubuntu-first teaching. Use the least powerful boundary that safely demonstrates the mechanism.
- No cloud account, production system, credential, employer data, or externally hosted learning service is required.
- Every substantive change must update the applicable work item, acceptance evidence, and `VERIFICATION.md`.

## Status and priority vocabulary

| Value | Meaning |
|---|---|
| `COMMITTED` | Acceptance criteria are met for the stated scope and the artifact is on `main`. |
| `WORKTREE` | Implemented or substantially drafted locally, but not yet accepted or committed. |
| `PARTIAL` | Some durable capability exists, but the acceptance criteria are incomplete. |
| `PLANNED` | Scope is defined; implementation has not started. |
| `BLOCKED` | Progress requires a named dependency, decision, authority, or safety correction. |
| `DEFERRED` | Intentionally outside the current milestone. |

Priority `P0` protects safety or the source of truth. `P1` is required for the shared core. `P2` deepens specialist or product-company readiness. `P3` is an optional enhancement.

## Milestone sequence

| ID | Milestone | Exit condition | Current status |
|---|---|---|---|
| `PLAN-MS-00` | Stabilize the field-manual foundation | Current routed reader, lesson-depth content, Ubuntu labs, safety corrections, documentation, and validation are reviewed and committed | `WORKTREE` |
| `PLAN-MS-01` | Publish Volume 00 and complete Linux core | Safe-start material plus the complete Linux foundation has validated labs, answers, transfers, and audits | `PARTIAL` |
| `PLAN-MS-02` | Publish connectivity and engineering delivery | Volumes 02 and 03 pass content, lab, interview, and quality gates | `PLANNED` |
| `PLAN-MS-03` | Publish reliability, infrastructure, and platform core | Volumes 04 and 05 include a locally operable service platform and incident program | `PLANNED` |
| `PLAN-MS-04` | Publish state and distributed-systems core | Volume 06 includes observable data, queue, consistency, and recovery exercises | `PLANNED` |
| `PLAN-MS-05` | Publish specialist tracks and portfolio systems | Target-role tracks have defensible, locally reproducible projects and interview evidence | `PLANNED` |
| `PLAN-MS-06` | Public-quality release audit | Fresh-clone, safety, accessibility, security, completeness, and maintainability audits pass | `PLANNED` |

## Governance and source-of-truth work

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-GOV-001` | P0 | Persistent project controls | None | `WORKTREE` | Root plan, progress, decisions, and verification files exist; use stable IDs; distinguish delivered work from mastery | Cross-link review; `git diff --check`; confirm only evidence changes competency |
| `PLAN-GOV-002` | P0 | Teaching and diagram standard | None | `COMMITTED` | Engineer-to-engineer voice, progressive depth, meaningful diagrams, command evidence, and limited checkpointing are mandatory | Review new lessons against `TEACHING-STYLE.md` |
| `PLAN-GOV-003` | P0 | Public lesson and lab standard | `PLAN-GOV-002` | `WORKTREE` | Metadata, glossary, diagrams, decoders, Ubuntu lab, production transfer, complete answers, references, and review schedule are required | Schema/content audit against `book/LESSON-STANDARD.md` |
| `PLAN-GOV-004` | P0 | Contribution and review workflow | `PLAN-GOV-003` | `WORKTREE` | A future human or AI can add content without chat history; safety and definition-of-done checks are explicit | Dry-run one new lesson through `book/CONTRIBUTING.md` |
| `PLAN-GOV-005` | P0 | Evidence and competency governance | `PLAN-GOV-002` | `PARTIAL` | Evidence files, hint use, confidence, scoring, transfer, and delayed recall update the ledger without inferring mastery from reading | Audit a complete skill lifecycle from submission through review |
| `PLAN-GOV-006` | P1 | Reference freshness policy | `PLAN-GOV-003` | `PLANNED` | Version-sensitive claims identify primary sources, tested versions, review dates, and expiration/recheck rules | Stale-reference report; sample source audit |
| `PLAN-GOV-007` | P1 | Release and Git workflow | `PLAN-GOV-001` | `PARTIAL` | Logical changes are validated, committed to `main`, pushed without secrets, and recoverable from a fresh clone | Clean-tree check; remote parity; clone smoke test |

## Content architecture

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-ARC-001` | P0 | Durable knowledge map | `PLAN-GOV-003` | `WORKTREE` | Volumes, specialist tracks, prerequisites, mastery states, and planned repository shape are explicit | Human dependency review; orphan-topic scan |
| `PLAN-ARC-002` | P0 | Stable content identifiers | `PLAN-ARC-001` | `PARTIAL` | Every volume, lesson, lab, incident, transfer, question, and project receives a unique immutable ID | Duplicate-ID validator |
| `PLAN-ARC-003` | P0 | Typed current lesson model | `PLAN-GOV-003` | `PARTIAL` | Existing Linux content remains strongly typed and renders without a giant monolithic page; all current fields are validated | Type/build check; lesson field coverage test |
| `PLAN-ARC-004` | P1 | Markdown/MDX content schema | `PLAN-ARC-002`, `PLAN-ARC-003` | `PLANNED` | New content lives under `book/volumes/...`; front matter covers metadata; diagrams, command cards, answers, and lab links have validated structures | Schema validation fixtures; invalid-content tests |
| `PLAN-ARC-005` | P1 | Typed-to-MDX migration | `PLAN-ARC-004` | `PLANNED` | Existing five lessons migrate without URL, ID, text, diagram, answer, or lab regression | Before/after route snapshots; content parity test |
| `PLAN-ARC-006` | P1 | Glossary and cross-link graph | `PLAN-ARC-004` | `PARTIAL` | Terms are defined before use, acronyms expand once, duplicates link to canonical definitions, and prerequisites are navigable | Undefined-term and broken-link reports |
| `PLAN-ARC-007` | P1 | Reference registry | `PLAN-GOV-006`, `PLAN-ARC-004` | `PLANNED` | Primary references record title, URL, version/date, lesson IDs, and last review; copyrighted material is paraphrased | Reference schema and link checker |
| `PLAN-ARC-008` | P2 | Content search index | `PLAN-ARC-004`, `PLAN-WEB-005` | `PLANNED` | Local search finds terms, symptoms, commands, tools, and lesson IDs without an external service | Search relevance fixtures and offline test |

## Website capabilities

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-WEB-001` | P0 | Loopback-only local launcher | None | `COMMITTED` | Windows launcher installs locked dependencies when needed, binds locally, opens the reader, and documents stop behavior | Fresh-clone Windows/WSL launch smoke test |
| `PLAN-WEB-002` | P0 | Routed book reader | `PLAN-ARC-001` | `WORKTREE` | Separate library, volume, lesson, and practice routes; breadcrumbs; valid static params; invalid lessons return 404 | Route matrix and internal-link crawl |
| `PLAN-WEB-003` | P1 | Persistent book navigation | `PLAN-WEB-002` | `WORKTREE` | Desktop sidebar and mobile contents expose current lessons and clearly label planned volumes | Keyboard/mobile/manual navigation test |
| `PLAN-WEB-004` | P1 | Reader appearance controls | `PLAN-WEB-002` | `WORKTREE` | Paper/night modes, three text sizes, reading progress, print view, reduced motion, and stored preferences remain readable | Contrast, keyboard, responsive, print, and storage-disabled tests |
| `PLAN-WEB-005` | P1 | Find and resume | `PLAN-ARC-008`, `PLAN-WEB-003` | `PLANNED` | Search, stable deep links, recent location, and bookmarks work locally; no convenience state becomes mastery evidence | Browser restart test; offline search test |
| `PLAN-WEB-006` | P1 | Multi-format learning modes | `PLAN-WEB-002` | `PARTIAL` | Read, diagram, incident, recall, teach-back, interview, and transfer modes are separate and navigable | Interaction tests; answer-reveal and state-reset tests |
| `PLAN-WEB-007` | P1 | Evidence handoff | `PLAN-GOV-005`, `PLAN-WEB-006` | `PLANNED` | Learner can export sanitized Markdown/JSON evidence for review; website cannot silently write Git or raise mastery | Malformed-input, path, redaction, and no-auto-advance tests |
| `PLAN-WEB-008` | P2 | Accessible diagrams | `PLAN-ARC-004` | `PARTIAL` | Every diagram has direction, boundary labels, evidence points, and a useful text equivalent; diagrams remain legible in print/night/mobile | Screen-reader text review and viewport snapshots |
| `PLAN-WEB-009` | P1 | Fast, local, privacy-preserving operation | `PLAN-WEB-002` | `PARTIAL` | No analytics, external font, account, database, or application API; normal reading stays lightweight and loopback-only | Network-request audit; bundle/performance budget |
| `PLAN-WEB-010` | P2 | Offline distribution | `PLAN-WEB-009`, `PLAN-QUA-007` | `PLANNED` | Documented install/start path works after clone; an optional prebuilt local package is reproducible and does not require hosting | Disconnected start test after dependency bootstrap |
| `PLAN-WEB-011` | P1 | Error, empty, and unsupported-state UX | `PLAN-WEB-002` | `PLANNED` | Missing lessons, missing browser storage, failed dependency install, unavailable port, and unsupported runtime show actionable recovery | Failure-injection UI tests |

## Complete core curriculum

The tables below reserve the complete shared-core knowledge architecture. A status describes content delivery only.

| ID | Pri | Volume/module | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-CUR-000` | P0 | Volume 00: start safely | `PLAN-GOV-003`, `PLAN-LAB-001` | `PLANNED` | Ubuntu setup, shell behavior, WSL boundaries, Git workflow, command risk, secrets, evidence, FRAME incidents, OPERATES reviews, SCALE decisions, rollback, and cleanup | Fresh learner follows setup without hidden prerequisites; safe-start assessment |
| `PLAN-CUR-101` | P0 | Linux: filesystems, blocks, inodes, mounts, quotas, ENOSPC | `PLAN-CUR-000` | `WORKTREE` | Self-contained lesson, output decoders, Ubuntu observation lab, isolated ENOSPC incident, remediation, transfer, answers, and references | Content audit; host-lab and Docker-lab success/cleanup; unfamiliar transfer |
| `PLAN-CUR-102` | P0 | Linux: processes, descriptors, signals, services, systemd | `PLAN-CUR-000` | `WORKTREE` | Process tree, states, FDs, signals, exit reasons, unit lifecycle, logs, restart policy, safe PID lab, and incident transfer | Non-root PID identity/cleanup test; systemd environment variants |
| `PLAN-CUR-103` | P0 | Linux: CPU, scheduling, load, memory, swap, pressure, OOM | `PLAN-CUR-102` | `WORKTREE` | CPU/run queue and memory mechanisms, `vmstat` first-row semantics, cgroup distinction, read-only lab, and exit-137 transfer | Sample-output assertions; Ubuntu observation; scenario scoring |
| `PLAN-CUR-104` | P0 | Linux bridge: DNS-to-HTTP request path and sockets | `PLAN-CUR-102` | `WORKTREE` | DNS, routes, TCP, TLS, HTTP, namespace boundary, loopback lab, errors, and one-pod transfer are explained | Loopback listener/PID/response/cleanup proof; namespace scenario |
| `PLAN-CUR-105` | P0 | Linux: identity, modes, traversal, ACLs, capabilities, MAC | `PLAN-CUR-101`, `PLAN-CUR-102` | `WORKTREE` | Effective identity, directory semantics, ACL/capability/mount/MAC layers, non-root lab, container UID transfer | Path/type/owner/sentinel safety audit; permission scenario |
| `PLAN-CUR-106` | P1 | Linux: boot, kernel, logs, time, libraries, packages | `PLAN-CUR-102`, `PLAN-CUR-103` | `PLANNED` | Boot chain, kernel/userspace, journal, clock drift, dynamic linking, packages, updates, and recovery | Disposable-VM or read-only labs; boot/log incident exercise |
| `PLAN-CUR-107` | P1 | Linux: block I/O, devices, filesystems, performance | `PLAN-CUR-101`, `PLAN-CUR-103` | `PLANNED` | Page cache, block layer, latency/throughput/IOPS, queues, devices, LVM, filesystem repair boundaries | Read-only host observation plus disposable-VM failure lab |
| `PLAN-CUR-108` | P1 | Linux: namespaces, cgroups, limits, isolation, hardening | `PLAN-CUR-102`, `PLAN-CUR-103`, `PLAN-CUR-105` | `PLANNED` | Container primitives, cgroup v2, limits, seccomp, capabilities, LSMs, and escape boundaries | Hardened container labs and security review |
| `PLAN-CUR-200` | P0 | Volume 02: Ethernet, ARP/ND, IP, CIDR, routing, NAT | `PLAN-CUR-101`, `PLAN-CUR-104` | `PLANNED` | Packet path, route choice, neighbors, MTU, fragmentation, NAT/state, firewall evidence | Namespace topology lab; packet-capture interpretation |
| `PLAN-CUR-201` | P0 | Connectivity: UDP, TCP, sockets, retransmission, exhaustion | `PLAN-CUR-200` | `PLANNED` | Handshake/state machine, congestion, retransmission, queues, backlog, TIME_WAIT, ephemeral ports | Loopback/network-namespace failure matrix |
| `PLAN-CUR-202` | P0 | Connectivity: DNS and service discovery | `PLAN-CUR-200`, `PLAN-CUR-201` | `PLANNED` | Resolution path, caching, TTL, search domains, authoritative/recursive roles, split DNS, discovery | Local DNS lab with cache/record failures |
| `PLAN-CUR-203` | P0 | Connectivity: HTTP, proxies, caching, load balancing | `PLAN-CUR-201`, `PLAN-CUR-202` | `PLANNED` | HTTP semantics, L4/L7 boundaries, reverse proxies, health, retries, affinity, cache correctness | Local proxy/app topology and user-journey checks |
| `PLAN-CUR-204` | P0 | Connectivity: TLS, PKI, mTLS, trust, rotation | `PLAN-CUR-202`, `PLAN-CUR-203` | `PLANNED` | Handshake, identity, chains, SAN, trust stores, clocks, termination, mTLS, renewal | Local CA/certificate lab with expiry/name/trust failures |
| `PLAN-CUR-205` | P1 | Connectivity: hybrid/private connectivity and zero trust | `PLAN-CUR-200`, `PLAN-CUR-204` | `PLANNED` | VPN/private-link/transit patterns, segmentation, policy, identity-aware access, failure ownership | Architecture exercise and locally modeled routes/policies |
| `PLAN-CUR-300` | P0 | Volume 03: Git internals and collaborative delivery | `PLAN-CUR-000` | `PLANNED` | Objects, refs, merge/rebase, recovery, signing, branching, reviews, release history | Disposable repository labs and recovery exercise |
| `PLAN-CUR-301` | P0 | Engineering: Bash, Python, Go, APIs, serialization | `PLAN-CUR-102`, `PLAN-CUR-300` | `PLANNED` | Safe shell, typed Python, Go foundations, error handling, HTTP APIs, JSON/YAML, concurrency boundaries | Tested operational tools and malformed-input cases |
| `PLAN-CUR-302` | P0 | Engineering: tests, debugging, packaging, dependencies | `PLAN-CUR-301` | `PLANNED` | Unit/integration/system tests, logging, profiling, packaging, pinning, SBOM concepts, debugging unfamiliar code | CI-executed tool with failure-injection tests |
| `PLAN-CUR-303` | P0 | Delivery: OCI images, containers, registries, runtime security | `PLAN-CUR-108`, `PLAN-CUR-302` | `PLANNED` | Image/layer/build/cache/runtime internals, rootless/non-root, scanning, provenance, registry flows | Reproducible hardened image and runtime incident labs |
| `PLAN-CUR-304` | P0 | Delivery: CI/CD, artifacts, environments, deployment strategies | `PLAN-CUR-300`, `PLAN-CUR-302`, `PLAN-CUR-303` | `PLANNED` | Runner isolation, caches, artifacts, approvals, secrets, rolling/blue-green/canary, rollback | Local CI platform and failed-deployment drill |
| `PLAN-CUR-305` | P1 | Delivery: GitOps and software supply chain | `PLAN-CUR-304`, `PLAN-CUR-500` | `PLANNED` | Reconciliation, signed provenance, SBOM, policy, dependency risk, promotion, audit trail | Local signed-artifact/policy workflow |
| `PLAN-CUR-400` | P0 | Volume 04: metrics, logs, traces, events, profiles, OpenTelemetry | `PLAN-CUR-301`, `PLAN-CUR-203` | `PLANNED` | Telemetry semantics, cardinality, context, sampling, correlation, retention, cost | Instrumented local service and query exercises |
| `PLAN-CUR-401` | P0 | Reliability: SLIs, SLOs, error budgets, alerts | `PLAN-CUR-400` | `PLANNED` | User journeys, indicators, objectives, burn rates, paging quality, ownership | SLO calculations, alert replay, noise/coverage review |
| `PLAN-CUR-402` | P0 | Reliability: capacity, overload, queues, retries, backpressure | `PLAN-CUR-103`, `PLAN-CUR-201`, `PLAN-CUR-401` | `PLANNED` | Queueing, saturation, timeouts, retry budgets, jitter, shedding, degradation, scaling | Load/failure lab with capacity model |
| `PLAN-CUR-403` | P0 | Reliability: incident command, runbooks, RCA/PIR, toil | `PLAN-CUR-401`, `PLAN-CUR-402` | `PLANNED` | Detection-to-recovery workflow, roles, comms, timelines, causal analysis, actions, automation | Timed incident simulation and reviewed post-incident report |
| `PLAN-CUR-404` | P0 | Reliability: backup, restore, RTO/RPO, DR, chaos | `PLAN-CUR-403`, `PLAN-CUR-600` | `PLANNED` | Backup integrity, restore proof, recovery objectives, failover, dependency maps, experiments | Restore drill and disaster-recovery game day |
| `PLAN-CUR-500` | P0 | Volume 05: Terraform/OpenTofu, state, modules, drift, policy | `PLAN-CUR-301`, `PLAN-CUR-304` | `PLANNED` | HCL, providers, state/locking, modules, plans, imports, drift, tests, policy, safe workflow | `fmt`, validate, tests, plan review; no unreviewed apply |
| `PLAN-CUR-501` | P0 | Infrastructure: Ansible and configuration management | `PLAN-CUR-301`, `PLAN-CUR-500` | `PLANNED` | Inventory, idempotency, handlers, secrets boundaries, testing, mutable/immutable trade-offs | Local target convergence and idempotency tests |
| `PLAN-CUR-502` | P0 | Kubernetes: API, reconciliation, scheduling, workloads | `PLAN-CUR-303`, `PLAN-CUR-304`, `PLAN-CUR-500` | `PLANNED` | Control-plane flow, desired/current state, controllers, scheduler, probes, resources, rollout | Local cluster labs and controller-state diagnosis |
| `PLAN-CUR-503` | P0 | Kubernetes: networking, storage, security, multi-tenancy | `PLAN-CUR-200`, `PLAN-CUR-204`, `PLAN-CUR-502` | `PLANNED` | CNI/Services/Ingress/DNS, CSI/PV, RBAC, service accounts, policy, admission, pod security | Namespace-scoped local-cluster failure labs |
| `PLAN-CUR-504` | P1 | Kubernetes: upgrades, capacity, observability, reliability | `PLAN-CUR-401`, `PLAN-CUR-402`, `PLAN-CUR-503` | `PLANNED` | Version skew, disruption, autoscaling, quotas, control-plane/workload SLOs, backup | Upgrade/rollback and capacity simulations |
| `PLAN-CUR-505` | P1 | Platform engineering: golden paths, self-service, platform APIs | `PLAN-CUR-304`, `PLAN-CUR-500`, `PLAN-CUR-504` | `PLANNED` | Product thinking, paved roads, templates, tenancy, policy, scorecards, platform SLOs | Local developer-platform project and user test |
| `PLAN-CUR-600` | P0 | Volume 06: SQL, indexes, transactions, locks, pools | `PLAN-CUR-103`, `PLAN-CUR-301` | `PLANNED` | Query plans, indexes, ACID, isolation, locks, deadlocks, connection pools, backup/restore | Local database performance and failure labs |
| `PLAN-CUR-601` | P0 | State: NoSQL, caches, queues, streams | `PLAN-CUR-600`, `PLAN-CUR-402` | `PLANNED` | Data models, eviction, invalidation, broker semantics, partitions, consumer groups, backpressure | Local cache/broker pipeline with failures |
| `PLAN-CUR-602` | P0 | Distributed systems: replication, partitioning, consistency, consensus | `PLAN-CUR-200`, `PLAN-CUR-600`, `PLAN-CUR-601` | `PLANNED` | Failure models, quorums, CAP trade-offs, leader election, split brain, repair | Simulation and architecture trade-off exercises |
| `PLAN-CUR-603` | P0 | Distributed workflows: clocks, idempotency, sagas, outbox, delivery | `PLAN-CUR-602` | `PLANNED` | Time/order, duplicate work, exactly-once claims, compensation, schema evolution | Fault-injected workflow project |
| `PLAN-CUR-604` | P1 | Data reliability: batch, stream, lineage, quality, governance | `PLAN-CUR-601`, `PLAN-CUR-603` | `PLANNED` | Pipeline contracts, checkpoints, replay, lineage, validation, privacy, retention | Observable local data pipeline and recovery drill |

## Specialist tracks and portfolio systems

| ID | Pri | Track/project | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-TRK-701` | P2 | AWS and EKS reliability | `PLAN-CUR-504`, `PLAN-CUR-500`, `PLAN-CUR-404` | `PLANNED` | EC2/ASG, VPC, IAM, ECR, EKS/ECS, RDS, S3, Lambda, CloudWatch, cost, backup, and DR are taught through local models and reviewed designs | Local emulation/plan tests; architecture and failure scenarios; no cloud spend |
| `PLAN-TRK-702` | P2 | Private cloud and compute | `PLAN-CUR-107`, `PLAN-CUR-200`, `PLAN-CUR-504`, `PLAN-CUR-602` | `PLANNED` | KVM/libvirt, bare metal, OpenStack, Ceph, OVS/OVN, HA, capacity, upgrades, and lifecycle operations | Disposable virtualization labs where supported plus design simulations |
| `PLAN-TRK-703` | P2 | Data and ML platforms | `PLAN-CUR-604`, `PLAN-CUR-504`, `PLAN-CUR-400` | `PLANNED` | Spark, Flink, Trino/Pinot, Iceberg, Airflow, MLflow, catalogs, notebooks, vectors, and Cassandra are connected to reliability mechanisms | Small local data platform with replay, observability, and recovery |
| `PLAN-TRK-704` | P2 | Developer platforms and CI compute | `PLAN-CUR-304`, `PLAN-CUR-505` | `PLANNED` | GitLab Runner, Jenkins, GitHub workflows, ephemeral workers, queues, autoscaling logic, golden paths, and platform APIs | Local runner platform with isolation, queueing, rollback, and SLO evidence |
| `PLAN-TRK-705` | P2 | Security and DevSecOps | `PLAN-CUR-204`, `PLAN-CUR-305`, `PLAN-CUR-503` | `PLANNED` | Threat modeling, IAM, secrets, TLS, policy, vulnerability handling, runtime controls, audit, and incident response | Threat model, policy tests, signed artifacts, and security incident drill |
| `PLAN-TRK-706` | P2 | Architecture, leadership, migration, and FinOps | All core volumes | `PLANNED` | Requirements, trade-offs, capacity, cost, migration, risk, stakeholder communication, ADRs, and operating models | SCALE design reviews and executive/engineering presentations |
| `PLAN-TRK-707` | P2 | AI-assisted operations and AI platforms | `PLAN-CUR-403`, `PLAN-TRK-705`, `PLAN-CUR-604` | `PLANNED` | Model-assisted classification, correlation, retrieval, automation, MLOps/LLMOps, evaluation, security, and bounded authority | Adversarial evaluation, deterministic guardrails, rollback, and audit log |
| `PLAN-PRJ-001` | P1 | Observable local service platform | `PLAN-CUR-304`, `PLAN-CUR-401`, `PLAN-CUR-504`, `PLAN-CUR-500` | `PLANNED` | Application, delivery, IaC, cluster, telemetry, SLOs, alerts, runbooks, capacity, security, and rollback form one reproducible portfolio system | Fresh-clone deployment and game day |
| `PLAN-PRJ-002` | P2 | Distributed data reliability platform | `PLAN-CUR-604`, `PLAN-TRK-703` | `PLANNED` | Batch/stream ingestion, durable state, quality, lineage, replay, dashboards, and recovery are integrated | Fault-injection and recovery evidence |
| `PLAN-PRJ-003` | P2 | Private-cloud/platform design dossier | `PLAN-TRK-702`, `PLAN-TRK-706` | `PLANNED` | Topology, capacity, failure domains, upgrades, storage/network design, cost, security, and runbooks are defensible | Architecture review and failure-tabletop scoring |

## Lab program

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-LAB-001` | P0 | Lab safety and lifecycle contract | `PLAN-GOV-003` | `WORKTREE` | Preflight, scope, risk, prediction, experiment, recovery, cleanup, and cleanup proof; no implicit install/sudo/download | Static safety checklist and destructive-command audit |
| `PLAN-LAB-002` | P0 | Ubuntu host-lab harness | `PLAN-LAB-001` | `PLANNED` | Non-root temp paths, exact state, sentinels, PID/socket identity, `check/setup/status/cleanup/reset`, fresh-shell recovery | ShellCheck, Bats, failure-path and cleanup tests |
| `PLAN-LAB-003` | P0 | Hardened container-lab harness | `PLAN-LAB-001`, `PLAN-CUR-303` | `PARTIAL` | Pinned image, no host mounts/secrets, non-root, no network, read-only root, dropped capabilities, resource ceilings, descriptor-gated cleanup, and narrowly scoped retirement of known legacy fixtures | Inspect assertions, fixture verifier, full runtime-boundary descriptor tests, tampered-container refusal |
| `PLAN-LAB-004` | P1 | Disposable VM harness | `PLAN-LAB-001`, `PLAN-CUR-106` | `PLANNED` | Host-sensitive kernel/systemd/firewall/LVM lessons run only in resettable VMs with snapshots and recovery | Create/destroy/reset and failed-boot recovery tests |
| `PLAN-LAB-005` | P1 | Local Kubernetes harness | `PLAN-LAB-001`, `PLAN-CUR-502` | `PLANNED` | Pinned local cluster, namespace scoping, resource budgets, diffs, rollback, and deterministic teardown | Cluster lifecycle and namespace-escape tests |
| `PLAN-LAB-101` | P0 | Storage and inode Ubuntu lab | `PLAN-CUR-101`, `PLAN-LAB-001` | `WORKTREE` | Bounded non-root object creation demonstrates inode use without exhausting host; exact cleanup is retryable | Ubuntu 24.04 happy/failure/cleanup runs |
| `PLAN-LAB-102` | P0 | ENOSPC isolated incident | `PLAN-CUR-101`, `PLAN-LAB-003` | `PARTIAL` | Real kernel ENOSPC, block/inode distinction, retained data, authorized deletion, user-operation retry, descriptor-gated cleanup | Fixture verification, counterfeit-boundary refusal, and learner-operated remediation |
| `PLAN-LAB-103` | P0 | Process and signal lab | `PLAN-CUR-102`, `PLAN-LAB-001` | `WORKTREE` | Unique token and UID protect PID signaling; graceful exit and absence are proven | Ubuntu run plus PID-reuse/refusal tests |
| `PLAN-LAB-104` | P0 | CPU and memory observation lab | `PLAN-CUR-103` | `WORKTREE` | No synthetic host pressure; sampling semantics and limitations are explicit | Ubuntu samples and interpretation fixture review |
| `PLAN-LAB-105` | P0 | Loopback request-path lab | `PLAN-CUR-104`, `PLAN-LAB-001` | `WORKTREE` | Non-root, loopback-only, checked port, unique response, PID/command/path proof, retryable exact cleanup | Occupied-port, dead-PID, unexpected-file, and cleanup tests |
| `PLAN-LAB-106` | P0 | Identity and permission lab | `PLAN-CUR-105`, `PLAN-LAB-001` | `WORKTREE` | Path/type/owner/sentinel validation prevents cleanup from following a replaced child symlink outside the lab | Symlink-escape regression plus normal cleanup test |
| `PLAN-LAB-900` | P1 | Lab verification matrix | `PLAN-LAB-002`, `PLAN-LAB-003`, `PLAN-LAB-004`, `PLAN-LAB-005` | `PLANNED` | Supported environment/version/action/result/cleanup evidence is generated for every lab | Automated matrix report with retained failure logs |

## Interview and assessment system

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-INT-001` | P0 | Question and answer schema | `PLAN-GOV-003` | `WORKTREE` | Stable ID, level, prompt, direct answer, foundation, reasoning, senior answer, weak answer, evidence, follow-ups, rubric | Schema coverage and missing-answer test |
| `PLAN-INT-002` | P0 | Linux question bank | `PLAN-CUR-101` through `PLAN-CUR-108` | `PARTIAL` | Every Linux lesson has recall, diagnostic, production, and transfer questions with model answers | Coverage report by lesson and difficulty |
| `PLAN-INT-003` | P1 | Role requirement mapping | None | `COMMITTED` | Apple, Experian, Mastercard, Cisco, Visa, GitLab, NVIDIA, Arm, and ADP requirements map to mechanisms and tracks | Trace each supplied requirement to planned IDs |
| `PLAN-INT-004` | P1 | Company-style scenario banks | Core volumes | `PLANNED` | Ambiguous incidents, system design, coding, behavioral ownership, security, cost, and leadership scenarios exist without pretending to reproduce confidential interviews | Independent review and scoring calibration |
| `PLAN-INT-005` | P1 | Timed mock interview runner | `PLAN-INT-001`, `PLAN-WEB-006` | `PLANNED` | Selects by role/gap, hides answers, captures confidence and timing, supports follow-ups, exports evidence | Deterministic selection and answer-isolation tests |
| `PLAN-INT-006` | P0 | Rubrics and mastery separation | `PLAN-GOV-005`, `PLAN-INT-001` | `PARTIAL` | Scores reasoning, evidence, safety, trade-offs, communication, and independence; website score never auto-promotes competency | Rubric fixtures and ledger authorization audit |
| `PLAN-INT-007` | P2 | Portfolio/resume defense | `PLAN-PRJ-001` through `PLAN-PRJ-003` | `PLANNED` | Every claimed project metric, decision, incident, and result is backed by repository evidence | Claim-to-evidence audit and adversarial follow-up review |

## Quality automation and final audits

| ID | Pri | Deliverable | Depends on | Status | Acceptance criteria | Verification |
|---|---:|---|---|---|---|---|
| `PLAN-QUA-001` | P0 | Lint, type, and production build | `PLAN-WEB-002` | `WORKTREE` | Reproducible scripts fail on lint/type/build errors; generated artifacts do not dirty Git | `npm ci`, lint, type check, build, clean-tree comparison |
| `PLAN-QUA-002` | P0 | Content/schema validation | `PLAN-ARC-004` | `PARTIAL` | IDs, prerequisites, metadata, required sections, answers, references, and command labels validate in CI | Valid/invalid content fixtures |
| `PLAN-QUA-003` | P0 | Shell and lab tests | `PLAN-LAB-002` | `PLANNED` | ShellCheck plus lifecycle, abort, stale-state, symlink, PID, port, root, and cleanup tests run automatically | Bats/integration report on Ubuntu 24.04 |
| `PLAN-QUA-004` | P1 | Route, link, and 404 tests | `PLAN-WEB-002`, `PLAN-ARC-004` | `PARTIAL` | All declared routes return expected status; links and anchors resolve; invalid IDs return 404 | Automated route matrix and link crawler |
| `PLAN-QUA-005` | P1 | Accessibility, responsive, and print tests | `PLAN-WEB-004`, `PLAN-WEB-008` | `PARTIAL` | WCAG AA contrast, semantic headings, landmarks, focus, keyboard, reduced motion, mobile/tablet/desktop, and print are usable | axe/manual keyboard/contrast/screenshot matrix |
| `PLAN-QUA-006` | P1 | Security and privacy checks | `PLAN-WEB-009`, `PLAN-LAB-001` | `PARTIAL` | Secret scan, dependency review, no telemetry/external calls, loopback binding, safe examples, no employer data | Secret scanner, registry audit, request capture, code review |
| `PLAN-QUA-007` | P1 | Performance and dependency budget | `PLAN-WEB-009` | `PLANNED` | Route and asset budgets are explicit; no unnecessary framework or graphics weight; advisories are dispositioned | Bundle report, local performance run, registry-backed audit |
| `PLAN-QUA-008` | P1 | Fresh-clone reproducibility | `PLAN-GOV-007`, `PLAN-QUA-001`, `PLAN-LAB-900` | `PLANNED` | A clean Ubuntu/Windows-supported clone can install, launch, read, run selected labs, clean up, and reproduce validation | Isolated clone transcript |
| `PLAN-AUD-001` | P0 | Current worktree release audit | `PLAN-MS-00`, `PLAN-QUA-001`, `PLAN-QUA-003`, `PLAN-QUA-004`, `PLAN-QUA-005`, `PLAN-QUA-006` | `BLOCKED` | No open lab-safety blocker; all current checks rerun after final edit; diff reviewed; generated files handled; commit/push complete | Signed-off checklist in `VERIFICATION.md` |
| `PLAN-AUD-002` | P1 | Per-volume editorial audit | Each volume | `PLANNED` | Prerequisites, depth, diagrams, outputs, labs, answers, transfers, references, and role coverage meet the lesson standard | Volume coverage report and expert review |
| `PLAN-AUD-003` | P1 | Curriculum completeness audit | All core volumes | `PLANNED` | No critical mechanism or target-role requirement is orphaned; redundancy is intentional; dependency order is valid | Requirement-to-content and graph reports |
| `PLAN-AUD-004` | P0 | Public safety and security audit | All labs, `PLAN-QUA-006` | `PLANNED` | Copy-paste commands cannot escape documented scope under tested misuse cases; dependencies and licenses are reviewed | Adversarial lab suite, dependency/license/secret reports |
| `PLAN-AUD-005` | P0 | Mastery-integrity audit | `PLAN-GOV-005`, `PLAN-INT-006` | `PLANNED` | Reading, button clicks, localStorage, model answers, and mentor-generated output cannot be mistaken for learner evidence | State-transition and evidence-lineage review |
| `PLAN-AUD-006` | P1 | Product-company readiness audit | Core curriculum, tracks, projects, interviews | `PLANNED` | Learner can diagnose, build, operate, explain, and transfer across target-role scenarios with defensible artifacts | Independent mock loop and portfolio defense |
| `PLAN-AUD-007` | P0 | Final public release audit | `PLAN-AUD-002` through `PLAN-AUD-006`, `PLAN-QUA-008` | `PLANNED` | Fresh clone, documentation, safety, accessibility, security, performance, licensing, links, labs, and maintainership all pass with no critical finding | Versioned release report and reproducible tag |

## Immediate execution order

1. Restore Docker integration in Ubuntu, then run the full-envelope v2 lifecycle, one-field counterfeit refusals, check/reset paths, and exact legacy-v1 retirement.
2. Complete the remaining host-lab root, wrong-owner/sentinel, unexpected-entry, stale-state, and cleanup-retry cases; retain the passed permissions symlink regression.
3. Run the remaining link/anchor, contrast, keyboard, print, secret, and privacy checks; retain the current lint, typecheck, build, route/404, asset, answer-reveal, shell-syntax, dependency-audit, and generated-file evidence.
4. Inspect the full dependency tree and generated-file state during final diff review; do not treat historical warnings as current findings without reproducing them.
5. Complete `PLAN-AUD-001`, review the full diff, commit the logical release, and push `main`.
6. Keep the learner on `PLAN-CUR-101`/`PLAN-LAB-102` until learner-operated remediation evidence is reviewed; content availability must not bypass that gate.
