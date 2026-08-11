# Cloud operations: reason in provider-neutral primitives

Cloud services differ in names, but reliable operation depends on the same primitives: identity, network path, compute, state, observability, quota, failure domain, recovery, and cost.

```text
caller -> identity/policy -> network -> managed service -> data/recovery
   |           |              |            |                  |
principal    scope          route       quota/SLO          RPO/RTO/cost
```

## Shared responsibility

The provider operates some hardware and service layers; the customer still owns configuration, identity, data classification, access, workload behavior, and recovery choices according to the service model. Verify the exact boundary instead of assuming “managed” means “reliable by default.”

## Identity and network

Use least-privilege roles, short-lived credentials, explicit resource scope, and auditable policy. Map DNS, routes, security groups/firewalls, NAT, private endpoints, load balancing, and return paths before declaring a service reachable. Reachability is not authorization.

## Quotas and failure domains

Capacity includes account/project quotas, API rate limits, regional resources, IP space, connections, and service-specific ceilings. Zones and regions are failure domains only when the workload, data, control plane, and dependencies are actually distributed and tested.

## Recovery and cost

Define backup/restore, failover authority, RPO/RTO, key access, and data transfer behavior. Cost follows resource, usage, retention, request, transfer, and commitment choices. Keep portability and exit evidence visible when selecting managed services.

## Safe local exercise

Build a provider-neutral design table for a local service: identity, network, compute, state, quota, failure domain, SLO, backup, recovery, observability, cost, and exit path. Map each primitive to one hypothetical AWS, Azure, and Google Cloud service without creating resources.

## Triage sequence

1. Identify account/project/tenant, region, identity, resource, and user symptom.
2. Check policy, quota, route, dependency health, and service status at the first divergent boundary.
3. Contain by reducing load, changing a scoped route/policy, or using a documented failover.
4. Preserve audit, cost, and recovery evidence.
5. Verify user SLI, data correctness, and cleanup of temporary resources.

## Interview defense

**Question:** “How do you troubleshoot an unavailable managed database?”

**Strong answer:** “I confirm identity and scope, service/region status, quota, network/DNS/private path, security policy, connection limits, client behavior, and data/recovery state. I distinguish provider control-plane failure from customer configuration and verify the user journey after containment.”

**Question:** “How do you avoid cloud lock-in?”

**Strong answer:** “I make the workload contract and data ownership explicit, isolate provider-specific adapters, document exit and export paths, measure migration cost, and choose managed features only when their reliability, security, cost, and recovery value justify the coupling.”

## Teach-back checkpoint

Design one service using provider-neutral primitives. State identity, route, quota, failure domain, shared-responsibility boundary, SLO, RPO/RTO, cost driver, and exit path.
