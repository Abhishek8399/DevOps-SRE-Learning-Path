# Target Role Requirements Matrix

Last updated: 2026-08-01

This matrix is derived from the job descriptions supplied by the learner for Apple, Experian, Mastercard, Cisco, Visa, GitLab, NVIDIA, Arm, and ADP. It is a planning input, not competency evidence and not a claim that the postings remain open or unchanged.

Use the companion [interview playbook](interview-playbook.md) after each relevant lesson. It turns the shared hiring bar below into spoken practice, evidence boundaries, weak-answer warnings, and senior follow-ups.

## The shared hiring bar

The companies use different product names, but the engineering loop is remarkably consistent:

```text
customer signal
    -> map the request through the system
    -> collect evidence at the failing boundary
    -> restore service with the smallest safe change
    -> find and remove the failure mechanism
    -> automate detection, prevention, and recovery
    -> explain the trade-off and leave a usable runbook
```

Here is the part to remember: a tool name may get you through a resume filter. The loop above is what makes an experienced engineer trusted during a real incident.

## Requirement heat map

Legend: **Core** = explicit or central to the role; **Useful** = mentioned or strongly adjacent; `-` = not emphasized in the supplied description.

| Capability | Apple | Experian | Mastercard | Cisco | Visa | GitLab | NVIDIA | Arm | ADP |
|---|---|---|---|---|---|---|---|---|---|
| Linux and systems troubleshooting | Core | Core | Core | Core | Core | Useful | Core | Core | Core |
| Networking, load balancing, and transport | Core | Useful | Core | Core | Useful | Core | Core | Useful | Core |
| Programming and automation | Core | Core | Core | Core | Core | Core | Core | Useful | Core |
| Containers and Kubernetes | Core | Useful | Core | Useful | Core | Useful | Core | Core | Core |
| Terraform and configuration management | Core | Core | Core | Core | Core | Core | Useful | Core | Core |
| CI/CD and zero-downtime delivery | Core | Core | Core | Core | Core | Core | Core | Core | Core |
| Observability and SLOs | Core | Core | Core | Core | Core | Core | Core | Useful | Useful |
| Incidents, RCA, and prevention | Core | Core | Core | Core | Core | Core | Core | Useful | Core |
| AWS and public-cloud architecture | Core | Core | Core | Useful | Useful | Core | Useful | Core | Core |
| Private cloud and virtualization | Useful | - | - | Core | - | - | Core | Core | Useful |
| Databases, queues, or data platforms | Core | Core | Useful | Useful | Core | Useful | Core | Useful | Core |
| Security, governance, and cost | Core | Core | Core | Core | Core | Core | Useful | Core | Core |
| Leadership and written communication | Core | Core | Core | Core | Core | Core | Core | Core | Core |
| AI/ML-enabled operations | Core | Useful | - | Useful | Core | Core | Core | - | - |

## What we will build first

The order is based on dependency, not trendiness.

1. **Systems foundation:** Linux process, memory, filesystems, permissions, systemd, signals, and evidence-first troubleshooting.
2. **Connectivity foundation:** DNS, TCP, TLS, HTTP, routing, NAT, firewalls, proxies, and load balancers.
3. **Engineering foundation:** Git, Bash, Python, tests, APIs, data structures, error handling, packaging, and debugging unfamiliar code.
4. **Delivery foundation:** containers, image construction, registries, CI execution, artifacts, deployment strategies, rollback, and supply-chain controls.
5. **Reliability foundation:** telemetry, SLIs/SLOs, alert design, capacity, queues, overload, incidents, post-incident reviews, and toil reduction.
6. **Platform foundation:** Kubernetes internals, scheduling, networking, storage, security, upgrades, multi-tenancy, and self-service interfaces.
7. **Infrastructure foundation:** Terraform modules, state, drift, policy, Ansible, immutable versus mutable infrastructure, and safe change workflows.
8. **Distributed-data foundation:** SQL/NoSQL trade-offs, replication, consistency, caching, messaging, stream/batch processing, and failure recovery.

Only after those foundations have evidence will specialist tracks deepen:

- **AWS/EKS and cloud reliability:** [AWS/EKS reliability primer](aws-eks-reliability-primer.md) covers EC2, ASG, VPC, IAM, ECR, EKS/ECS, RDS, S3, Lambda, CloudWatch, cost, backup, and disaster recovery. Local labs model behavior without creating cloud resources.
- **Private cloud and compute:** [Private-cloud and virtualization primer](private-cloud-virtualization-primer.md) covers KVM, libvirt, OpenStack, bare metal, Ceph, OVS/OVN, high availability, and lifecycle operations through bounded local models.
- **Data and ML platforms:** [Data-platform operations primer](data-platform-operations-primer.md) and [MLOps/LLMOps reliability primer](mlops-llmops-reliability-primer.md) cover Spark, Flink, Trino/Pinot, Iceberg, Airflow, MLflow, catalogs, notebooks, vector databases, Cassandra, serving, evaluation, and recovery through local models.
- **Developer platforms and CI compute:** [CI runner platform primer](ci-runner-platform-primer.md) and the [platform product primer](platform-product-primer.md) cover GitLab Runner, Jenkins, GitHub workflows, autoscaling workers, ephemeral environments, golden paths, and platform APIs.
- **AI-assisted operations:** safe use of models for classification, correlation, runbook retrieval, and automation with deterministic validation and bounded authority.

## Portfolio evidence expected

Reading is not the deliverable. The repository will eventually contain evidence that can be defended in an interview:

- incident timelines, command evidence, RCAs, and prevention changes;
- tested Python or Go operational tooling with clear failure behavior;
- Terraform and Ansible validated before any apply-like action;
- container and Kubernetes services with SLOs, dashboards, alerts, capacity tests, upgrades, and rollback drills;
- a local CI runner platform that demonstrates queueing, isolation, autoscaling logic, and zero-downtime deployment reasoning;
- a private-cloud design and locally simulated virtualization/storage/network failure exercises;
- a distributed data pipeline with observable failure handling and recovery;
- architecture decision records and concise operational runbooks.

## The durable advantage

No curriculum can guarantee that AI will never replace a role, and a healthy company should not depend on one person. The stronger goal is to become the engineer trusted with ambiguous, high-impact systems because you can:

- form and test hypotheses instead of accepting generated answers;
- connect application symptoms to operating-system and network mechanisms;
- judge blast radius, security, recovery, and business impact before acting;
- design simple systems that other engineers can operate;
- lead incidents and communicate clearly under pressure;
- use AI to accelerate work while independently validating its output.

The program will therefore reward judgment, transfer, safe execution, and clear communication rather than command memorization.
