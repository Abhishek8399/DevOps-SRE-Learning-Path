# System design: begin with the journey and failure contract

Good system design is a chain of explicit decisions. Start with the user operation and its contract, then draw data/control paths, failure domains, capacity, security, cost, and recovery.

```text
user -> edge -> service -> state/dependency -> response
  |      |        |             |                |
 SLO   trust    scale        authority         evidence
```

## Requirements before components

Ask what must be correct, how fast, how available, how much data can be lost, who may act, and what growth is expected. Separate functional requirements from quality scenarios. “Highly scalable” is incomplete until rate, payload, latency percentile, failure domain, and recovery target are named.

## Boundaries and authority

Draw synchronous and asynchronous paths, authoritative writers, caches, queues, and external dependencies. For each state transition, define ownership, idempotency, consistency, and reconciliation. A component diagram without authority and failure boundaries is a product catalog, not an operable design.

## Capacity and trade-offs

Estimate arrival rate, concurrency, storage growth, bandwidth, replication, and headroom. Identify the first bottleneck and the cost driver. Compare alternatives by reliability, security, operational complexity, portability, and reversibility—not only throughput.

## Failure and recovery

For every dependency, ask what happens when it is slow, unavailable, stale, partitioned, or corrupt. Define timeout/deadline, retry, backpressure, degradation, rollback, backup, restore, and user-visible recovery. Include observability and operator actions in the design.

## Safe local exercise

Design a local order service on one page. Include request path, state authority, outbox/queue, cache, SLO, capacity assumptions, threat boundary, cost driver, backup/restore, and one failure table. Review it against an unfamiliar scenario without deploying anything.

## Interview defense

**Question:** “Design a highly available checkout system.”

**Strong answer:** “I clarify success, latency, consistency, duplicate-charge, RPO/RTO, and traffic assumptions. I draw authority and payment boundaries, use idempotency and durable workflow state, protect dependencies with deadlines and backpressure, define regional failure behavior, and verify user SLOs, reconciliation, security, and cost.”

**Question:** “How do you choose between two architectures?”

**Strong answer:** “I compare them against explicit quality scenarios, failure modes, capacity, cost, security, operational burden, migration path, and reversibility. I record the decision and the evidence that would cause revision.”

## Teach-back checkpoint

Design one user journey and state its requirements, path, authorities, bottleneck, failure modes, SLO, security controls, cost driver, recovery, and evidence plan.
