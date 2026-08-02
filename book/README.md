# Reliability Atlas

This directory defines the durable knowledge architecture behind the local website. The book is intended to remain useful to a beginner, an experienced operator, a future contributor, or another AI without relying on chat history.

New chapters follow the [lesson and Ubuntu lab standard](LESSON-STANDARD.md) and the [contribution workflow](CONTRIBUTING.md).

The website is the reading interface. Git is the source of truth. A lesson being published means it is available to study; it does not mean a learner has demonstrated mastery.

## Design promise

A reader with Ubuntu 24.04 should normally be able to:

1. identify what a chapter teaches and why it matters in production;
2. verify required commands before installing anything;
3. reproduce the core mechanism with read-only observation or bounded non-root resources;
4. understand what each command proves and cannot prove;
5. clean up and verify cleanup;
6. see how the mechanism changes in containers, Kubernetes, cloud, private cloud, and distributed systems;
7. continue into deeper production and architecture material without changing books.

Docker is used when safe isolation is the lesson or when reproducing a failure directly on the host would be unsafe. Kubernetes is used only for Kubernetes-specific reconciliation, scheduling, networking, storage, security, and failure behavior.

## Reading depth

Every chapter uses progressive disclosure:

```text
5-minute system picture
        |
        v
Foundation explanation
        |
        v
Guided Ubuntu lab
        |
        v
Production operations
        |
        v
Scale and staff-level trade-offs
        |
        v
Independent mastery challenge
```

Readers may stop after the layer appropriate to their goal. The deeper layers remain available without obscuring the foundation.

## Core volumes

### Volume 00 - Start safely

Systems thinking, Ubuntu setup, shell survival, Git workflow, command risk labels, evidence handling, cleanup, secrets, FRAME incidents, OPERATES reviews, and SCALE design decisions.

The current routed Volume 00 path contains:

- `LES-0007` / `V00-L01` - systems thinking, state, queues, dependencies, and failure domains; and
- `LES-0008` / `V00-L02` - evidence-driven troubleshooting with the reusable [`FRAME` incident worksheet](frameworks/FRAME.md).

Both are `substantive-draft` lessons with guarded practice and answer-isolated transfer. Passing project gates makes the artifacts available to study; formal acceptance, learner execution, reviewed transfer, delayed recall, and mastery remain separate.

### Volume 01 - Linux systems

Filesystems, processes, descriptors, signals, systemd, CPU scheduling, memory, swap, OOM, identity, permissions, boot, logs, libraries, time, block I/O, namespaces, cgroups, performance, and hardening.

The routed Linux path contains five established typed lessons plus schema-backed boot/journal, block-I/O, and namespaces/cgroups chapters. The new storage-performance chapter follows an application operation through page cache, filesystem, block queues, virtualization, and durability. The isolation chapter separates namespace views, cgroup resource policy, and adjacent container security controls instead of treating a container as a small virtual machine.

### Volume 02 - Connectivity

Ethernet, ARP, IP, CIDR, routing, NAT, UDP, TCP, sockets, retransmission, MTU, port exhaustion, DNS, HTTP, proxies, caching, load balancing, TLS, PKI, mTLS, and private or hybrid connectivity.

The five routed connectivity chapters build one continuous request path. `LES-0012` follows addressing, route selection, neighbors, translation, return routing, and MTU. `LES-0013` develops TCP/UDP sockets, queues, retransmission, ports, TIME_WAIT, and stateful-boundary exhaustion. `LES-0014` traces DNS recursion, delegation, caching, negative answers, split views, and service discovery. `LES-0015` follows HTTP through proxies, caches, health checks, pools, and load-balancing decisions. `LES-0016` completes the path with TLS handshakes, certificate identity, trust chains, mTLS, termination, and rotation. Each chapter includes decoded Ubuntu evidence, incidents, complete-answer assessments, an answer-isolated transfer, primary references, and a bounded offline lab.

### Volume 03 - Engineering and delivery

Git internals, Bash, Python, Go foundations, APIs, serialization, tests, packaging, dependencies, artifacts, release engineering, OCI containers, CI/CD, deployment strategies, GitOps, and software supply-chain security.

The routed volume begins with `LES-0009` / `V03-L01`, a safe local Ubuntu/WSL workbench for shell evaluation, Git state, secret handling, rollback, and exact cleanup. `LES-0017` then turns Bash into a deliberate automation interface: quoting, records, statuses, traps, validation, idempotency, deadlines, locks, tests, and failure-safe cleanup. `LES-0018` builds the same operational discipline in Python through typed boundaries, subprocess safety, exception taxonomy, durable publication, reconciliation, bounded concurrency, packaging, tests, and observability. `LES-0019` through `LES-0023` continue through PowerShell, Go, API contracts, reproducible builds, and OCI/Docker foundations. `LES-0024` explains CI/CD architecture; `LES-0025` / `V03-L10` / `CI-002` continues at `/book/engineering/ci-platform-operations` with GitHub Actions, GitLab CI/CD, Jenkins, and Azure Pipelines operations. Its two local CI engines demonstrate bounded scheduling and contract ideas only; they do not execute or certify any provider. These `SCM`, `AUT`, and `CI` identities remain in the canonical engineering-and-delivery home while Volume 00 and Linux remain prerequisite foundations.

### Volume 04 - Reliability and operations

Metrics, logs, traces, events, profiling, OpenTelemetry, SLIs, SLOs, error budgets, alert design, capacity, overload, retries, backpressure, degradation, incident command, runbooks, post-incident reviews, toil, backup, restore, RTO/RPO, chaos, and disaster recovery.

### Volume 05 - Infrastructure and platforms

Terraform/OpenTofu, state, drift, policy, Ansible, image construction, Kubernetes architecture, reconciliation, scheduling, networking, storage, security, upgrades, multi-tenancy, platform engineering, golden paths, self-service, and platform SLOs.

### Volume 06 - State and distributed systems

SQL, indexes, transactions, locks, connection pools, NoSQL, caches, queues, streams, replication, consistency, partitioning, consensus, clocks, idempotency, sagas, outbox patterns, delivery guarantees, and schema evolution.

## Specialist tracks

- AWS, EKS, and cloud reliability.
- Private cloud: KVM, libvirt, OpenStack, Ceph, OVS, and OVN.
- Data and ML platforms: Spark, Flink, Trino, Iceberg, Airflow, MLflow, Cassandra, catalogs, notebooks, and vector systems.
- Developer platforms and CI compute.
- Security and DevSecOps specialization.
- Architecture, leadership, FinOps, and migration.
- AI-assisted operations, AIOps, MLOps, LLMOps, and AI security.

Security, reliability, observability, economics, and safe change are also evaluated inside every core chapter rather than being isolated to specialist volumes.

## Prerequisite graph

```text
Safe lab setup
  -> systems thinking
  -> evidence-driven troubleshooting
  -> Linux ---------> containers ------> CI/CD
       |                  |                 |
       +-> networking ---+----------------> Kubernetes
       |                                    |
       +-> scripting -> IaC ----------------+
       |
       +-> observability -> SRE operations
       |
       +-> data fundamentals -> distributed systems

Linux + networking + storage -----------> private cloud
Kubernetes + IaC + SRE -----------------> platform engineering
Data + distributed systems + SRE ------> data/ML platforms
All core branches ----------------------> architecture leadership
```

Five-lesson releases are an editorial cadence, not a prerequisite or mastery gate. The `LES-0009` through `LES-0013` and `LES-0014` through `LES-0018` batches extend the safe-start, Linux, connectivity, and engineering paths in dependency order. The current canonical sequence continues through `LES-0025`; future content begins with `LES-0026` and must preserve all published lesson, route, state, assessment, reference, and curriculum ownership.

The local reader exposes twenty-five lessons across Volumes 00 through 03: five established typed lessons plus twenty schema-backed `substantive-draft` lessons. The structured corpus contains 60 assessments—forty complete-answer records and twenty answer-isolated independent transfers—and 163 references. Resolved prerequisite IDs appear as advisory navigation only. They help a reader revisit context but never lock a route, mark work complete, or award mastery.

## Planned repository shape

```text
book/
|-- frameworks/
|-- glossary/
|-- volumes/
|   `-- <volume>/
|       `-- <LES-id>-<slug>/lesson.md
|-- assessments/<domain>/<ASM-id>.json
|-- references/<REF-id>.json
|-- tracks/
`-- schema/

book/labs/        executable local labs
projects/         portfolio systems
incidents/        simulations and reviews
evidence/         learner submissions
progress/         reviewed competency state
learning-cockpit/ website renderer
```

New lesson prose lives in validated, versioned content files. The five established typed lessons retain pinned legacy identities until each receives a separately verified structured migration. Stable IDs must never be reused.

## Learning state

```text
Available -> Read -> Guided practice -> Submitted
          -> Independently verified
          -> Unfamiliar transfer passed
          -> Delayed recall passed
          -> Durable mastery
```

Browser reading position, bookmarks, and display preferences are conveniences. Only the reviewed repository ledger, backed by real evidence, changes competency levels.
