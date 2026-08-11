# Kubernetes upgrades and capacity: change the control plane deliberately

Cluster reliability depends on version compatibility, disruption budgets, resource economics, control-plane capacity, and recoverability—not only whether Pods eventually restart.

```text
version plan -> preflight -> canary/drain -> workload SLO -> control-plane health -> rollback/recovery
      |           |             |                |                  |                  |
   skew/API    capacity       PDB/evict        errors/latency       etcd/API            evidence
```

## Version and API compatibility

Inventory node, control-plane, client, admission, CRD, and API versions. Read deprecation and skew rules for the exact release. A successful binary upgrade can still break an API consumer, webhook, storage plugin, or policy controller.

## Disruption and capacity

Drain only within a planned budget. PodDisruptionBudgets limit voluntary disruption, not every failure. Check requests/limits, quotas, headroom, scheduling constraints, eviction pressure, and downstream capacity before adding replicas or draining nodes.

## Autoscaling and control-plane load

HPA/VPA/cluster autoscaling signals have lag, stabilization, limits, and cost. Control-plane overload can come from API clients, watch churn, events, admission, or large objects even when workloads look healthy. Measure queue/latency, API errors, scheduler/controller health, and user SLO.

## Recovery

Back up and verify etcd/control-plane state according to the cluster design, test restore in isolation, and document identity, certificates, storage, and DNS dependencies. A rollback of binaries does not automatically restore state or undo workload changes.

## Safe local exercise

If a disposable cluster is available, inspect versions, APIs, requests/limits, PDBs, and rollout conditions; perform only a documented dry-run or canary manifest change. If unavailable, review manifests and a synthetic upgrade matrix without claiming cluster evidence.

## Triage sequence

1. Identify versions, API objects, node/control-plane state, and user symptom.
2. Check skew/deprecation, capacity/headroom, disruption, admission, and API latency.
3. Pause drains or autoscaling changes when workload or control-plane SLOs degrade.
4. Restore through the approved checkpoint; preserve state and evidence.
5. Verify workloads, storage, networking, APIs, and user journey after recovery.

## Interview defense

**Question:** “How do you upgrade a production cluster safely?”

**Strong answer:** “Inventory versions and APIs, read skew/deprecation rules, verify capacity and backups, canary the control plane/node pool, respect disruption budgets, monitor workload and control-plane SLOs, and keep a tested restore/recovery path. I do not equate a green version command with a safe upgrade.”

**Question:** “Why did adding nodes not fix scheduling?”

**Strong answer:** “I check requests/limits, taints/affinity, quotas, IP/storage capacity, disruption, scheduler/API health, and downstream limits. More nodes cannot solve an incompatible placement constraint or control-plane bottleneck.”

## Teach-back checkpoint

Design an upgrade wave. State skew inventory, capacity/headroom, disruption budget, canary, SLO abort threshold, state backup, rollback limitation, and recovery proof.
