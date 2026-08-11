# Cloud Architecture Primer

AWS, Azure, and GCP use different product names, but reliable cloud reasoning starts below the names. This primer is provider-neutral study material. It does not claim a provider account, deployment, certification, or production runtime.

## Translate product names into primitives

```text
identity -> network boundary -> compute -> data -> observability -> policy -> cost
```

Ask what primitive a service supplies:

| Primitive | Questions to answer |
|---|---|
| Identity | Who can act, on which resource, under what condition, for how long? |
| Network | Which path, address space, route, firewall, NAT, and private endpoint are involved? |
| Compute | What is scheduled, where is it isolated, and how is capacity replaced? |
| Data | What consistency, durability, backup, encryption, and restore contract exists? |
| Observability | Which user journey is measured, and what is missing from the signal? |
| Policy | What is denied by default, audited, and prevented before deployment? |
| Cost | Who owns spend, what drives it, and what happens at the budget boundary? |

If a design cannot answer these questions, naming a managed service does not make it complete.

## Identity first

Use workload identity and short-lived credentials where possible. Separate human administration, deployment automation, and runtime permissions. Apply least privilege to actions and resources, require explicit environment boundaries, log sensitive actions, and test revocation. Do not put long-lived keys in source, images, user data, or logs.

An authorization success proves that one request was allowed under one policy and context. It does not prove that every path is private, that a compromised workload cannot pivot, or that the policy will remain correct after resource changes.

## Network path and failure domains

Map the real path before selecting a service:

```text
client -> DNS -> edge/load balancer -> private route -> workload
                                      |              |
                                  firewall       identity
                                      |              |
                                  data/API dependency
```

For each hop record address family, route table, security policy, MTU, health check, timeout, retry behavior, and logging. Distinguish availability zones, regions, accounts/subscriptions/projects, and control-plane versus data-plane failure domains. “Multi-zone” is not automatically resilient if the database, identity provider, deployment controller, or network path remains single-region.

## Resilience and recovery

Start from user objectives, not infrastructure slogans:

- **RTO:** maximum acceptable time to restore service.
- **RPO:** maximum acceptable data loss measured in time.
- **Availability target:** the valid population, window, and user operation.

Choose redundancy, replication, backups, queueing, and failover behavior to satisfy those objectives. A backup object is not restore evidence. A standby is not recovery until a controlled test proves promotion, data correctness, application reconnection, DNS/route behavior, permissions, and measured RTO.

Prefer explicit failure drills: zone loss, dependency denial, expired certificate, quota exhaustion, route withdrawal, credential revocation, and deployment rollback. Keep drills scoped, observable, reversible, and approved.

## Cost is an architecture constraint

Model fixed and variable cost: compute duration, storage size and operations, egress, managed-control-plane fees, observability ingestion/retention, replicas, idle environments, and recovery capacity. Tag or otherwise attribute spend to a team and workload. Optimize after measuring user objectives; the cheapest architecture that misses recovery or latency targets is not cost-efficient.

Common traps:

- cross-region traffic quietly dominates a “cheap” design;
- high-cardinality telemetry multiplies ingestion and query cost;
- autoscaling reacts to a noisy signal and creates a cost/reliability loop;
- snapshots are retained forever without a restore or deletion policy;
- private connectivity removes public exposure but adds DNS, route, and endpoint failure modes.

## Provider translation exercise

For any cloud service, write a small table with: primitive, trust boundary, region/zone scope, state ownership, quota, failure mode, backup/restore contract, observability, cost driver, and exit strategy. Then map the provider-specific name to the table. This keeps knowledge portable across AWS, Azure, GCP, and private cloud.

## Interview prompts

- Design a private API path from a workload to a managed database and explain every trust boundary.
- A regional failover succeeds technically but customers still receive errors. What evidence do you inspect next?
- How do you compare managed service convenience with portability and operational control?
- A cloud bill doubles after a telemetry rollout. Which dimensions do you measure before cutting data?

Strong answers connect identity, network, state, failure domain, recovery proof, observability, and cost. A list of service names is not an architecture.
