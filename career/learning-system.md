# Local Learning Field Manual

## Recommendation

Build a lightweight documentation website backed by this Git repository. It should feel like an engineer's field manual: fast to scan, rich in small diagrams, and able to switch from explanation to lab, recall, incident, and interview modes without loading a graphics-heavy course.

## Source-of-truth model

```text
Git repository (durable)
|-- lessons and diagrams
|-- runnable local labs
|-- role requirement matrix
|-- reviewed learner evidence
|-- competency ledger and review dates
`-- website source
          |
          v
local website (teaching interface)
|-- read and navigate
|-- quiz and rehearse
|-- draft a teach-back in localStorage
`-- show the next due practice
```

The repository is durable because it can be cloned, reviewed, and understood by a future mentor or AI. The browser is an interface, not the authoritative record.

Career study artifacts:

- [Target-role requirements matrix](target-role-matrix.md) — shared capabilities across the supplied job profiles.
- [Interview mastery playbook](interview-playbook.md) — spoken scenarios, proof boundaries, weak-answer warnings, and senior follow-ups.
- [Incident communication playbook](incident-communication-playbook.md) — incident updates, handoffs, stakeholder translation, and post-incident language.
- [Platform engineering primer](platform-engineering-primer.md) — internal platforms, golden paths, reliability, tenancy, and cost trade-offs.
- [Cloud architecture primer](cloud-architecture-primer.md) — provider-neutral identity, networking, resilience, recovery, and cost reasoning.
- [DevSecOps and supply-chain primer](devsecops-supply-chain-primer.md) — provenance, SBOMs, signing, scanning, runtime policy, and response.
- [Distributed-systems primer](distributed-systems-primer.md) — partial failure, consistency, time, retries, queues, and reconciliation.
- [Data-systems primer](data-systems-primer.md) — transactions, indexes, replicas, queues, idempotency, backups, and recovery.
- [Hybrid-connectivity primer](hybrid-connectivity-primer.md) — private links, VPNs, routing, zero trust, MTU, and boundary evidence.
- [Observability primer](observability-primer.md) — metrics, logs, traces, profiles, cardinality, correlation, alerts, and cost.
- [SLO primer](slo-primer.md) — user journeys, indicators, objectives, error budgets, burn, and policy.
- [Resilience primer](resilience-primer.md) — capacity, deadlines, retries, bulkheads, backpressure, shedding, and degradation.
- [Incident-command primer](incident-command-primer.md) — coordination, evidence, containment, handoffs, recovery, and learning.
- [Kubernetes-operations primer](kubernetes-operations-primer.md) — reconciliation, scheduling, probes, services, identity, rollouts, and safe triage.
- [Terraform primer](terraform-primer.md) — state, plans, modules, identity, drift, recovery, and safe change.
- [Ansible primer](ansible-primer.md) — inventory, idempotency, variables, handlers, secrets, drift, and rollout safety.
- [CI/CD and release primer](cicd-release-primer.md) — pipeline boundaries, immutable artifacts, gates, deployment strategies, and rollback.
- [Progressive delivery primer](progressive-delivery-primer.md) — canary, blue/green, shadow, feature flags, measurable gates, and state-aware recovery.
- [Local lab engineering primer](local-lab-engineering-primer.md) — boundaries, reproducibility, fault injection, evidence, recovery, and teardown.
- [Operational readiness primer](operational-readiness-primer.md) — service ownership, launch gates, SLOs, dependencies, recovery, security, cost, and runbooks.
- [AWS and EKS reliability primer](aws-eks-reliability-primer.md) — AWS boundaries, IAM, VPC, EKS operations, failure domains, recovery, observability, and cost without cloud spend.
- [Private cloud and virtualization primer](private-cloud-virtualization-primer.md) — hypervisor layers, overcommit, NUMA, storage/network paths, HA, migration, and local failure models.
- [MLOps and LLMOps reliability primer](mlops-llmops-reliability-primer.md) — lineage, evaluation, serving, gateways, GPU economics, drift, safety, canaries, and rollback.
- [Data-platform operations primer](data-platform-operations-primer.md) — ingestion, lakehouse, batch/stream compute, serving, orchestration, freshness, replay, lineage, and cost.
- [CI runner platform primer](ci-runner-platform-primer.md) — runner trust, isolation, queues, caches, autoscaling, artifacts, provenance, and failure response.
- [Policy as code primer](policy-as-code-primer.md) — decision boundaries, input contracts, staged enforcement, exceptions, audit reasons, and safe rollback.
- [Platform product primer](platform-product-primer.md) — golden paths, contracts, tenancy, platform SLOs, adoption, and developer experience.
- [Senior ownership primer](senior-ownership-primer.md) — outcomes, authority, trade-offs, communication, capacity, and decision records.
- [GitOps and supply-chain primer](gitops-supply-chain-primer.md) — desired state, provenance, signatures, policy, reconciliation, and recovery.
- [Chaos and game-day primer](chaos-game-day-primer.md) — hypotheses, blast radius, independent safety, aborts, recovery, and learning.
- [Backup and recovery primer](backup-recovery-primer.md) — RPO, RTO, layered protection, fencing, restore, and user validation.
- [Python automation primer](python-automation-primer.md) — validation, subprocess/API safety, dry runs, idempotency, testing, and verification.
- [Go infrastructure primer](go-infrastructure-primer.md) — cancellation, bounded concurrency, errors, API clients, and repeatable tooling.
- [PowerShell operations primer](powershell-operations-primer.md) — object pipelines, error semantics, remoting, WhatIf, and safe evidence.
- [Network troubleshooting primer](network-troubleshooting-primer.md) — DNS, routing, TCP, TLS, HTTP, proxies, selective failure, and safe evidence.
- [TLS and PKI primer](tls-pki-primer.md) — certificates, SANs, trust stores, termination, mTLS, rotation, and safe debugging.
- [API contract primer](api-contract-primer.md) — HTTP semantics, compatibility, idempotency, limits, security, and contract testing.
- [FinOps primer](finops-primer.md) — cost semantics, allocation, unit economics, commitments, safe optimization, and verification.
- [Consensus and replication primer](consensus-replication-primer.md) — failure models, quorums, leaders, fencing, consistency, and repair.
- [Git recovery primer](git-recovery-primer.md) — objects, refs, collaboration, recovery, rollback, and secret response.
- [Performance engineering primer](performance-engineering-primer.md) — workload contracts, profiling, capacity knees, tuning, canaries, and proof.
- [Data pipeline reliability primer](data-pipeline-reliability-primer.md) — schemas, lineage, checkpoints, replay, quality, quarantine, and backfill.
- [Security threat primer](security-threat-primer.md) — identity, authorization, secrets, threat modeling, runtime hardening, and response.
- [Containers and OCI primer](containers-oci-primer.md) — images, layers, runtimes, namespaces, cgroups, non-root, and safe isolation.
- [Migration engineering primer](migration-primer.md) — authority, compatibility, coexistence, cutover, reconciliation, rollback, and retirement.
- [OpenTelemetry primer](opentelemetry-primer.md) — context propagation, signal semantics, collectors, sampling, redaction, and cost.
- [Queue and stream primer](queue-stream-primer.md) — delivery semantics, partitions, consumer groups, backlog, poison work, and replay.
- [Cache and Redis primer](cache-redis-primer.md) — freshness, invalidation, stampedes, hot keys, eviction, and rebuilds.
- [System design primer](system-design-primer.md) — user journeys, authorities, capacity, failure domains, trade-offs, security, cost, and recovery.
- [SQL and PostgreSQL primer](sql-postgresql-primer.md) — plans, indexes, transactions, locks, pools, replication, and restore.
- [SRE toil and on-call primer](sre-toil-oncall-primer.md) — toil, paging, ownership, capacity, error budgets, readiness, and learning.
- [Testing and debugging primer](testing-debugging-primer.md) — test boundaries, reproduction, dependency integrity, packaging, and diagnosis.
- [Cloud operations primer](cloud-operations-primer.md) — provider-neutral primitives, IAM, networking, quotas, failure domains, recovery, and cost.
- [Service discovery and mesh primer](service-discovery-mesh-primer.md) — registration, health, TTL, identity, mTLS, routing, retries, and convergence.
- [Kubernetes network/security primer](kubernetes-network-security-primer.md) — Services, Ingress, storage claims, RBAC, Secrets, policy, and tenant isolation.
- [Kubernetes upgrades/capacity primer](kubernetes-upgrades-capacity-primer.md) — version skew, disruption, autoscaling, quotas, control-plane load, and recovery.

## Chapter pattern

Every topic should use the same compact sequence:

1. **Mental model:** one memorable explanation and one system diagram.
2. **Signals:** what the engineer sees and what each signal does or does not prove.
3. **Safe commands:** exact-path, read-only evidence before mutation.
4. **Lab:** a disposable failure with scope, success evidence, rollback, and cleanup.
5. **Teach-back:** explain the mechanism in plain technical language.
6. **Interview defense:** handle ambiguity, safety, and production trade-offs.
7. **Transfer:** solve a changed version without copying the original steps.
8. **Review:** revisit after increasing delays.

## Persistence boundaries

| Information | Storage | Durable after fresh clone? | Counts as mastery evidence? |
|---|---|---:|---:|
| Lessons, diagrams, labs, rubrics | Git | Yes | No |
| Browser draft or flashcard state | `localStorage` | No | No |
| Submitted command output and written response | Repository evidence file | Yes | After review |
| Competency level and next review | `progress/ledger.md` | Yes | Yes, when evidence-supported |

## Five-lesson delivery cadence

Learning content is released in coherent groups of five lessons. Each group should follow prerequisite order and contain enough explanation to study independently from the website.

The learner reads at their own pace and asks whenever a section is unclear. The mentor answers the gap, adds durable clarification to the book, and avoids repetitive conversational quizzes. Optional self-checks remain available inside each lesson.

Competency gates remain smaller than content batches. Reading five lessons does not unlock five skills. Practical evidence, safe decisions, transfer, and delayed recall are reviewed at the point where they matter.

A static browser page cannot safely commit and push on the learner's behalf. A later localhost-only companion service may export or write a narrowly scoped evidence file, but it must require an explicit action, validate paths, avoid secrets, and never raise mastery automatically.

## Performance constraints

- Prefer text, CSS, and small inline diagrams.
- Avoid video backgrounds, large image bundles, animation frameworks, analytics, and external fonts.
- Keep normal learning available without cloud accounts or external APIs.
- Bind the development server to loopback.
- Treat a dependency audit as unresolved until registry-backed evidence is available.

## Teaching control

The site may recommend the next topic from the ledger and due reviews. It must not unlock a new phase merely because a button was clicked. Advancement still requires reviewed explanation, implementation, verification, diagnosis, safety reasoning, transfer, and delayed recall.
