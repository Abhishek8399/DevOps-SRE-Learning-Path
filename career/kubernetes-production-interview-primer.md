# Kubernetes production interview: follow desired state all the way to the user

Kubernetes interview questions are rarely testing whether you can recite `kubectl` commands. They test whether you understand that an accepted manifest, a Running Pod, a Ready endpoint, and a successful customer request are different pieces of evidence.

Use this path before you name a command:

```text
user symptom -> route -> Service/Gateway -> endpoint -> Pod -> container -> dependency/state
     ^               desired/admitted object -> scheduler -> kubelet -> status/events
```

Start with the exact cluster context, namespace, workload revision, client path, time window, recent change and healthy comparison. A mistake in any of those can turn a safe diagnosis into a change against the wrong tenant or cluster.

## Scenario 1: the Deployment is Available but customers get 503

**Question:** The Deployment condition is `Available=True`, but the public endpoint returns 503. What do you investigate?

**Strong answer:** `Available` is controller evidence about a Deployment’s available-replica condition; it is not end-to-end customer proof. I first reproduce the user path from the affected boundary and trace Gateway/Ingress route, TLS host/path rules, Service selector, EndpointSlice membership, readiness semantics, target port, container listener, NetworkPolicy and dependency behavior. I compare a known-good route or revision and inspect events and rollout history. I do not change replicas just because the Deployment is available. If a recently changed selector, port or route is proven wrong, I make the smallest rollback or scoped configuration correction and verify endpoint membership plus a real request. Prevention is a route-level probe, deployment contract test, owner and runbook.

**Weak answer:** "Scale it up." More replicas with the wrong selector, readiness endpoint or route create more healthy-looking non-working Pods.

**Senior follow-up:** What can a Ready Pod prove? Only that its configured readiness probe succeeded from the kubelet’s perspective. It does not prove external DNS, TLS, ingress routing, policy, dependency health or a customer transaction.

## Scenario 2: Pods remain Pending after a release

**Question:** A release created Pods, but they stay Pending. The team wants to delete and recreate the Deployment.

**Strong answer:** I inspect Pod conditions and events first because Pending is a scheduler/lifecycle observation, not one root cause. I establish whether the issue is unschedulable placement, image pull, PVC binding, quota, admission policy, node selector/affinity, taint/toleration, requests that do not fit, or an unavailable dependency. I compare the admitted Pod spec with the prior revision and namespace quotas/limits. Deleting and recreating loses useful history and repeats the same desired state. I correct only the proven constraint—such as a request, selector, quota or binding—and then verify scheduling, readiness, endpoint membership and the user operation. Prevention means capacity/placement contracts, quota visibility and pre-deployment validation.

**Weak answer:** "There are nodes, so Kubernetes is broken." Node count says little about allocatable resources, constraints, taints, storage topology, admission or quotas.

**Senior follow-up:** Why can `kubectl get nodes` look healthy during this incident? Node `Ready` is a broad node status. It does not prove the node matches a Pod’s scheduling constraints or has the requested allocatable CPU, memory, ports, storage topology or tenant permission.

## Scenario 3: CrashLoopBackOff after a config change

**Question:** Pods enter CrashLoopBackOff immediately after a ConfigMap update. How do you prevent an unsafe rollback?

**Strong answer:** I identify the exact Pod revision, configuration object version or checksum, container command, exit code, previous logs, events and rollout timeline. I distinguish an application parsing error from an invalid mount path, missing key, permission/security-context mismatch, bad environment variable, liveness restart or dependency failure. A ConfigMap update does not always update a process’s in-memory configuration; the delivery mechanism matters. I compare the previous known-good object and workload template, then choose a reversible change: restore a verified compatible configuration or roll back a bounded workload revision. I verify the container remains healthy across the probe window and that the user path works. Prevention is schema/config validation, immutable/versioned configuration reference, controlled reload behavior, rollout guard and an owner for compatibility.

**Weak answer:** "Delete all Pods so they reread the ConfigMap." That may create a full outage, hide the malformed config, and assumes the process reload model without proving it.

**Senior follow-up:** What is the data risk? A rollback of compute configuration can be safe while a simultaneous schema or feature-flag change may not be backward compatible. Separate application, configuration and data migration contracts.

## Scenario 4: an autoscaler adds Pods but latency rises

**Question:** Horizontal Pod Autoscaler (HPA) increases replicas, yet p99 latency and errors get worse. Explain the system rather than blaming HPA.

**Strong answer:** Autoscaling adds demand on shared boundaries: scheduler capacity, image pulls, connection pools, downstream databases, queues, caches and load-balancer targets. I validate the HPA metric source, target, stabilization behavior, current/desired replicas, readiness delay and whether new Pods actually become endpoints. Then I compare queue depth, downstream saturation, retries, connection limits, CPU throttling, memory pressure and error distribution before/after scaling. I may temporarily cap concurrency, shed noncritical work or stop a release only with a defined blast radius. More replicas are not a recovery if the constrained dependency or retry amplification is the bottleneck. Prevention is a capacity model, dependency-aware load test, a bounded autoscaling policy and admission/backpressure controls.

**Weak answer:** "Set a higher maximum replica count." That can accelerate database overload and cluster contention.

**Senior follow-up:** What does CPU-based HPA miss? Queueing delay, external dependency capacity, connection-pool exhaustion, I/O wait, memory pressure, request cost variance and an unhealthy metric pipeline.

## Scenario 5: a StatefulSet PVC is stuck or a node fails

**Question:** A StatefulSet replica cannot start after a node failure, and someone proposes deleting the PersistentVolumeClaim (PVC). What do you say?

**Strong answer:** I stop before destructive storage action. A PVC is a claim to state; deleting it can trigger reclaim behavior and data loss depending on StorageClass/PersistentVolume policy. I establish the application’s writer ownership, replication/fencing model, access mode, current binding, attach/mount events, node condition, storage backend health, backup/restore point and recovery objective. I determine whether the issue is scheduling topology, attach/detach, stale attachment, filesystem permission, capacity, a stuck finalizer, or application-level consistency. I follow the storage/provider runbook with explicit ownership and a rollback/data-recovery plan, then validate not only Pod readiness but data integrity and the application’s write/read behavior. Prevention is tested restore, documented RPO/RTO, topology-aware placement and clear writer fencing.

**Weak answer:** "PVCs are just Kubernetes objects; recreate it." The object is a control-plane reference to potentially irreplaceable data.

**Senior follow-up:** Why is a snapshot not automatically a safe restore? It may not be application-consistent, may omit related state, may be in another failure domain, and has no value until restoration is tested under the required RPO/RTO.

## Scenario 6: a platform team sees a tenant bypass policy

**Question:** A team bypasses the platform because admission policies and templates make delivery difficult. How do you respond without weakening isolation?

**Strong answer:** I treat bypass as product evidence, not permission to remove controls. I map the developer journey, identify the specific friction and the security/reliability reason for each control, then distinguish a mandatory guardrail from accidental complexity. I inspect who can bypass, what trust boundary that crosses and whether the unofficial path is observable/auditable. I improve the golden path through versioned templates, actionable policy messages, preflight validation, documented exceptions with expiry/owner, and measured lead-time/failed-change outcomes. I do not grant broad cluster-admin or disable admission just to make a metric look better. Success is adoption of a safe path and fewer unsafe exceptions, not simply fewer support tickets.

**Weak answer:** "Policies are blocking delivery, so turn them off." A policy’s inconvenience may be revealing an unsafe workload or missing supported path.

**Senior follow-up:** What must an exception record contain? Requester and decision authority, exact scope, rationale, risk, compensating controls, expiry, review date, audit trail and a plan to remove the exception.

## Fast evidence map

| Question | First useful evidence | Proof limit |
|---|---|---|
| Did the API accept the desired object? | admitted manifest, API response/event | not scheduling, readiness or user success |
| Can the scheduler place it? | Pod conditions/events, requests, quotas, constraints | not runtime correctness |
| Can the runtime start it? | prior termination, logs, image/config/mount events | not Service/Gateway reachability |
| Can Service select a usable endpoint? | selector, EndpointSlice, readiness, ports | not external route/TLS/dependency success |
| Can the user complete the journey? | scoped real request/probe and outcome | not universal population health |
| Is state safe to change? | writer, binding, reclaim, backup/restore, owner | not data consistency until tested |

## Practice method

Pick one scenario and answer in three minutes without revealing the model. Force yourself to say one sentence beginning with each phrase:

1. "For the user, the failed operation is..."
2. "The next evidence I need is..., and it can/cannot prove..."
3. "The competing mechanism I have not ruled out is..."
4. "The smallest reversible containment is..."
5. "Recovery is proved when..."

Then change one constraint: cross-namespace traffic, a multi-region dependency, a data migration, a policy exception, a node drain or an unreliable metric. The commands may change. The evidence-first reasoning must not.
