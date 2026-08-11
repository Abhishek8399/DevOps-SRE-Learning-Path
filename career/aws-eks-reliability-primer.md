# AWS and EKS reliability: reason from boundaries, not service names

AWS gives you building blocks; it does not automatically give you a reliable system. Start with the user journey, failure domains, identity boundaries, and recovery evidence, then choose services.

```text
user -> edge/load balancer -> VPC/subnets -> EKS nodes/pods -> data service
  |          |                  |               |                 |
 SLO      health/target      routes/SG/NACL   scheduler/IAM    backup/replica
                                      |
                               CloudWatch/logs/traces
```

## Translate the primitives

* **VPC and subnets:** routing and isolation boundaries. A subnet being private does not prove that every path is private; inspect route tables, endpoints, NAT, security groups, and return paths.
* **IAM:** the authorization graph. Prefer workload identity and least privilege; distinguish who can call an API from which network path can reach it.
* **EC2 and Auto Scaling:** compute capacity and replacement policy. Scaling does not help if quotas, IPs, disks, bootstrap, or downstream databases are the bottleneck.
* **ECR:** an artifact boundary. Pin image digests, control promotion, scan according to risk, and know who can pull or mutate tags.
* **EKS:** a control plane plus nodes, admission, scheduling, networking, storage, and workload controllers. “The cluster is up” says little about a user journey.
* **RDS/S3/Lambda:** different state, concurrency, durability, and failure semantics. Backups and replicas are not the same as a tested restore or a defined recovery point.

## EKS operating model

For a workload, trace identity, image, scheduling, network policy, service discovery, ingress, storage, probes, autoscaling, and observability. Check both control-plane and data-plane health. A pending Pod may be a request/limit, taint, affinity, quota, IP, storage, admission, or image problem—not simply “the cluster needs nodes.”

Use namespaces and scoped credentials for local models. In a real account, review cluster access, node roles, pod identity, security groups, network policies, admission policy, audit logs, and secret boundaries before accepting a design.

## Safe local exercise

Without an AWS account, draw a request path and failure matrix for an EKS workload. Map each AWS primitive to a local analogue: loopback listener, Linux namespace, container network, local registry, process supervisor, filesystem backup, and structured logs. Then model three failures—lost node, unavailable dependency, and expired identity—and state the user SLI, containment, recovery evidence, and cost implication. Label it as a design model, not AWS execution.

If a disposable Kubernetes runtime exists, deploy only a namespace-scoped workload and inspect requests/limits, probes, service endpoints, events, and logs. Do not use a production kubeconfig or cloud credentials for this exercise.

## Triage sequence

1. Identify the journey, region/AZ, account, cluster, namespace, workload, and recent change.
2. Check DNS/load balancer target health, routes and security boundaries, then identity and admission.
3. Check EKS control-plane signals, node conditions, scheduling, image pulls, probes, service endpoints, and dependency saturation.
4. Contain by stopping exposure or scaling only within quota and downstream capacity.
5. Recover from the approved artifact/state checkpoint and verify the journey, not just resource status.

## Interview defense

**Question:** “How do you make an EKS service highly available?”

**Strong answer:** “I define the user SLO, spread capacity and replicas across failure domains, keep requests/limits and disruption budgets honest, use health-aware load balancing and probes, protect dependencies with deadlines and backpressure, apply least-privilege workload identity, observe control and data planes, and test backup/restore and node-loss recovery. I verify the journey rather than equating multiple Pods with availability.”

**Question:** “Why did autoscaling fail to restore service?”

**Strong answer:** “I check the signal delay and limits, quota and IP capacity, scheduling constraints, image/bootstrap time, control-plane health, and downstream saturation. More nodes cannot fix an IAM, network, placement, or database bottleneck.”

**Question:** “How do you control AWS cost without harming reliability?”

**Strong answer:** “I measure unit economics per journey, allocate ownership, identify idle and overprovisioned capacity, use commitments only after a stable baseline, and preserve required headroom, redundancy, observability, and recovery. Cost changes get the same canary, SLO, and rollback discipline as code.”

## Teach-back checkpoint

Design an EKS-backed API across two failure domains. Name the request path, identities, network boundaries, capacity limits, SLO signals, backup/recovery proof, top cost driver, and the first five triage commands or observations. State which parts are design knowledge and which require live-account evidence.
