# AWS and EKS production interview: map the AWS boundary before changing the cluster

EKS is Kubernetes operated across several ownership boundaries: your workload and configuration, AWS-managed control-plane responsibilities, VPC networking, IAM, node capacity, load balancers, storage and external services. “The cluster is healthy” is not a diagnosis.

```text
user -> Route 53/DNS -> load balancer -> VPC policy -> EKS workload -> node/CNI -> AWS dependency -> data
                         |                 |                |               |                 |             |
                      listener          security group     scheduler      IP/capacity      IAM/KMS      recovery
```

For every incident, name the account, Region, cluster, namespace, workload revision, node group, subnet/AZ and IAM identity before treating an AWS console view as complete evidence.

## Scenario 1: Pods are Pending after a traffic increase

**Question:** An EKS deployment cannot schedule new replicas. Should you immediately increase node count?

**Strong answer:** I inspect the scheduler event and Pod requirements first: requests/limits, selectors/affinity, taints/tolerations, topology constraints, PVC binding, image/identity constraints and namespace quota. Then I inspect actual allocatable capacity and node readiness, node-group/Auto Scaling limits, EC2 quota, subnet address capacity, CNI pod-IP allocation, instance-type availability and any cluster-autoscaler/Karpenter-like controller decision. More nodes cannot fix a restrictive selector, unavailable volume zone, insufficient subnet IPs, quota, node bootstrap failure or a requested resource no node can supply. I contain demand where safe, then make the smallest capacity/configuration correction. I verify that Pods schedule, become ready, receive traffic and that the downstream path has capacity; scheduling success alone may overload a database or load balancer. Prevention is a capacity model covering pods, CPU/memory, IPs, storage topology, quotas and bootstrap time, plus alerts on pending age and allocator limits.

**Weak answer:** “CPU is low, so add bigger nodes.” CPU use says little about unsatisfied pod constraints, IP exhaustion, storage placement or quota.

**Senior follow-up:** Why can a node have CPU remaining but reject a Pod? The scheduler considers requested resources and constraints, not observed CPU alone. Memory, ephemeral storage, pod count/IPs, taints, affinity, volume topology and policy can all block placement.

## Scenario 2: a Service has endpoints but users receive 503s

**Question:** An AWS load balancer returns 503 while Kubernetes shows ready Pods and Service endpoints. Where is the gap?

**Strong answer:** I separate Kubernetes readiness from load-balancer target health and the actual user request. I identify ingress/load-balancer type, listener/rule, target group, target mode, health-check path/port/protocol/success codes, security groups, subnets, target registration, cross-zone behavior, TLS configuration, DNS and recent controller annotations/revisions. A ready Pod may be ready for a Kubernetes probe yet fail the load balancer’s different health contract, be unreachable through security policy, be registered on a wrong port or return an unexpected response. I compare one healthy and one unhealthy target, inspect controller events and target-health reason codes, then correct the narrowest contract mismatch. I verify an external or authorized client journey through DNS, TLS, listener and application response. Prevention is aligned readiness/health semantics, explicit ingress ownership, versioned annotations, target-health monitoring and a test that proves the exact traffic path.

**Weak answer:** “Restart the Pods until targets turn healthy.” That can remove the only useful evidence and worsens availability if the mismatch is policy, port or health endpoint behavior.

**Senior follow-up:** What does a Kubernetes endpoint prove? The control plane selected a ready endpoint according to its Service/EndpointSlice rules. It does not prove an AWS target group can reach it or that a user request succeeds.

## Scenario 3: an application gets AccessDenied after a rollout

**Question:** A workload previously read an S3 object but now receives AccessDenied. Is the IAM policy missing?

**Strong answer:** I identify the exact AWS API/action, resource ARN, caller identity visible to the service, error context, workload revision, ServiceAccount, projected-token/role association, trust policy conditions, session/region and explicit deny sources. With EKS workload identity patterns, the Pod’s service identity must map to an AWS role through a configured trusted mechanism; a policy can allow an action yet the workload may assume a different role or fail trust conditions. I also check object/bucket policy, KMS permissions, VPC endpoint policy and organization/service control policies where applicable. I do not attach broad administrator permissions to prove a theory. I correct the smallest identity/trust/resource-policy boundary and verify the required action with audit evidence. Prevention is least-privilege policy tests, immutable role/service-account mappings, deployment checks for identity changes, CloudTrail-style audit ownership and break-glass that does not replace normal workload identity.

**Weak answer:** “Add `s3:*` to the role.” That can mask the wrong identity, bypass resource/KMS policy reasoning and create a far larger data exposure.

**Senior follow-up:** What can a successful `aws sts get-caller-identity`-style check prove? It can show the currently used identity at that execution boundary; it does not prove permission for a specific action/resource or that every Pod uses the same identity.

## Scenario 4: a node group scales but Pods still cannot start

**Question:** New EC2 nodes join EKS, but application Pods remain Pending or crash quickly. What do you inspect next?

**Strong answer:** I confirm node registration/version/labels/taints and then differentiate scheduler failure from runtime failure. For Pending Pods I inspect events, requested resources, pod-count/IP capacity, CNI health, DaemonSet readiness and volume/policy constraints. For quickly failing Pods I inspect image pull, runtime exit, probes, config/secret availability, service identity, kernel/resource limits and application dependency errors. New instances can join while critical DaemonSets cannot obtain pod IPs, ECR access, DNS, credentials or required permissions. I also check subnet routes/NAT or VPC endpoints for image/dependency paths rather than assuming the public internet is available. I correct the named failure boundary and validate a new Pod from scheduling through readiness and user traffic. Prevention is node bootstrap/DaemonSet readiness gates, private-network dependency design, capacity tests for pod IPs, image access and observability that distinguishes node join from workload readiness.

**Weak answer:** “EKS added nodes, so Kubernetes is broken.” Node lifecycle and workload lifecycle are different contracts with different prerequisites.

**Senior follow-up:** Why can private nodes fail to pull an image even when the cluster control plane is healthy? The node still needs a permitted route/private endpoint/DNS/authentication path to the registry and any required token service; control-plane reachability does not create that path.

## Scenario 5: a Region-wide dependency failure is suspected

**Question:** A managed database dependency is unavailable in one Region. Do you fail traffic to another Region immediately?

**Strong answer:** I first define the user impact, data/write consistency requirement, declared RPO/RTO, healthy-region capacity, traffic authority, replication/failover state, DNS/load-balancing behavior, identity/secrets/key access, queues and third-party dependencies. Regional failover is not an on/off switch: writes may conflict or be lost, a standby may lag, dependencies may share a Region, and the healthy Region may not have capacity. I contain unsafe writes or shed noncritical work according to the product contract while the recovery authority evaluates promotion/fencing. I use the tested regional recovery runbook, not an improvised console sequence. I verify representative user journeys, data authority, routing, error/latency and recovery objectives after movement. Prevention is explicit regional dependency maps, recovery exercises, capacity headroom, immutable deployment artifacts, cross-Region identity/key assumptions reviewed, and regular restore/failover evidence.

**Weak answer:** “Point DNS to the other Region.” DNS is only one routing boundary and cannot resolve writer authority, replication lag, capacity, session behavior or dependency readiness.

**Senior follow-up:** What is fencing in a failover? Preventing the old writer from accepting writes after a new writer becomes authoritative, so a partition or delayed recovery does not create split-brain data.

## Scenario 6: AWS cost rises after autoscaling

**Question:** Costs double after an autoscaling change, but user latency improved. Is this automatically acceptable?

**Strong answer:** I make the trade-off visible rather than calling either outcome success by default. I map workload demand, desired SLO, scaling metric/target/cooldown, node/pod requests versus actual use, instance mix, reserved/spot interruption exposure, IP/storage/load-balancer/NAT/data-transfer costs, idle capacity, retry traffic and downstream costs. A latency improvement may be worth the spend, or it may reveal oversized requests, a scaling feedback loop, poor bin packing or an avoidable retry amplifier. I compare before/after across the same population and time window, retain a safe rollback, and avoid shrinking below reliability headroom. I optimize in an order that preserves the service contract: remove waste, correct requests/limits and policy, choose suitable capacity types, then evaluate commitments with evidence. Prevention is unit-cost and SLO-aware dashboards, scaling-change review, budget/forecast alerts, cost allocation and regular capacity experiments.

**Weak answer:** “Use the cheapest instance type.” The cheapest unit can have insufficient availability, network/storage performance, interruption behavior or operational complexity for the workload.

**Senior follow-up:** Why do Kubernetes requests matter to cloud cost? Schedulers reserve based on requests. Inflated requests can force additional nodes even when measured use is low; under-requesting can create contention and outages. Tune against observed workload and reliability headroom.

## AWS/EKS answer map

1. Name account, Region, cluster, namespace, revision, identity and failure domain.
2. Separate Kubernetes intent, AWS control surfaces and the data-plane request path.
3. Inspect the first specific scheduler, target-health, IAM, CNI, route or dependency error.
4. Change one bounded owner-controlled boundary; avoid broad roles, routes or restarts.
5. Verify an authorized end-to-end user operation and its cost/reliability effect.
6. Convert the incident into a quota, capacity, identity, path or recovery test.

The lasting lesson: **EKS reliability is not knowing every AWS service. It is proving which ownership boundary failed before you widen access, capacity or traffic.**
