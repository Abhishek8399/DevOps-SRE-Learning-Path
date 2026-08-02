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

The current routed Volume 00 path begins with `LES-0007` / `V00-L01` systems thinking, followed by `LES-0008` / `V00-L02` evidence-driven troubleshooting. The latter adds the reusable [`FRAME` incident worksheet](frameworks/FRAME.md), an answer-isolated independent transfer, and a bounded virtual Ubuntu incident lab. Both remain `substantive-draft`; LES-0008 project gates and the mentor-operated Ubuntu verifier pass, but formal acceptance, learner execution, transfer review, and mastery remain open.

### Volume 01 - Linux systems

Filesystems, processes, descriptors, signals, systemd, CPU scheduling, memory, swap, OOM, identity, permissions, boot, logs, libraries, time, block I/O, namespaces, cgroups, performance, and hardening.

### Volume 02 - Connectivity

Ethernet, ARP, IP, CIDR, routing, NAT, UDP, TCP, sockets, retransmission, MTU, port exhaustion, DNS, HTTP, proxies, caching, load balancing, TLS, PKI, mTLS, and private or hybrid connectivity.

### Volume 03 - Engineering and delivery

Git internals, Bash, Python, Go foundations, APIs, serialization, tests, packaging, dependencies, artifacts, release engineering, OCI containers, CI/CD, deployment strategies, GitOps, and software supply-chain security.

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

Five-lesson releases are an editorial cadence, not a prerequisite or mastery gate. The next content-first batch reserves `LES-0009` through `LES-0013`, beginning with the next unused ID `LES-0009`. Every lesson will eventually declare stable prerequisite IDs.

The local reader currently exposes eight lessons across Volumes 00 and 01: five established typed lessons plus three schema-backed structured lessons, with nine structured assessments and 24 references. Resolved prerequisite IDs appear as advisory navigation only. They help a reader revisit context but never lock a route, mark work complete, or award mastery.

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

labs/             executable local labs
projects/         portfolio systems
incidents/        simulations and reviews
evidence/         learner submissions
progress/         reviewed competency state
learning-cockpit/ website renderer
```

Lesson prose will move out of React code into validated, versioned content files as the routed book structure is introduced. Stable IDs must never be reused.

## Learning state

```text
Available -> Read -> Guided practice -> Submitted
          -> Independently verified
          -> Unfamiliar transfer passed
          -> Delayed recall passed
          -> Durable mastery
```

Browser reading position, bookmarks, and display preferences are conveniences. Only the reviewed repository ledger, backed by real evidence, changes competency levels.
