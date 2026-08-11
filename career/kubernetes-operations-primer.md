# Kubernetes operations: reconcile intent safely

Kubernetes is a control loop system. You describe desired state; the API server stores it; controllers and the scheduler continually work toward it while kubelets report what actually happened.

```text
manifest -> API server -> stored desired state
                         |             |
                    controller      scheduler
                         |             |
                    Pod objects -> kubelet -> container/runtime
                         ^                    |
                         +---- status/events-+
```

## The operator mental model

When a workload is unhealthy, compare four things: desired object, admitted object, scheduled placement, and runtime status. A successful `kubectl apply` proves admission, not readiness. A Running pod proves a process exists, not that the user journey works.

## Requests, limits, and probes

Requests influence scheduling; limits constrain runtime consumption. CPU throttling, memory pressure, disk pressure, and eviction can appear as application latency or exit 137. Startup, readiness, and liveness probes answer different questions: can the process start, should it receive traffic, and should it be restarted? A liveness probe that depends on a slow database can turn dependency trouble into a restart storm.

## Services and identity

A Service selects pods by labels and provides a stable discovery boundary. Verify selector, endpoints, DNS, network policy, and the application listener separately. RBAC answers “who may call the API”; a service account is an identity; a Secret is data with a lifecycle. None of these automatically authorizes application-to-application traffic.

## Rollouts and rollback

Observe the rollout, replica availability, readiness failures, events, and user SLI. A rollback restores a previous desired version; it does not undo a database migration or repair data. Keep application and schema changes backward-compatible or provide an explicit recovery path.

## Safe local exercise

If a local Kubernetes runtime is available, create a disposable namespace and apply a tiny Deployment with explicit requests, a readiness probe, and a Service. Inspect the admitted object, ReplicaSet, endpoints, events, and pod logs. Make one image or probe change, observe the failed rollout, then roll back and delete the namespace. If Docker/WSL is unavailable, perform the same reasoning with the manifests and `kubectl explain` output; do not claim runtime evidence.

## Triage sequence

1. Confirm namespace, context, workload, and user symptom.
2. Inspect desired/admitted state, rollout condition, scheduling events, and pod status.
3. Check requests/limits, probes, endpoints, DNS, policy, logs, and dependency health.
4. Contain with a scoped rollback, traffic reduction, or replica/resource correction.
5. Verify readiness, endpoints, user journey, and old-pod cleanup.

## Interview defense

**Question:** “The Deployment says available, but users receive 503s. What do you check?”

**Strong answer:** “I test the user path, then compare Service selectors and endpoints, readiness semantics, pod listeners, network policy, DNS, ingress, and dependency responses. Deployment availability is only one boundary; I identify the first boundary where healthy evidence diverges.”

**Question:** “Why did a liveness probe cause an outage?”

**Strong answer:** “The probe encoded dependency health as process health, so a slow dependency caused restarts, removed capacity, and amplified load. I separate startup/readiness/liveness, use bounded local checks, and verify restart behavior under dependency failure.”

## Teach-back checkpoint

Draw the path from Deployment to user response. Explain what `apply`, `Running`, `Ready`, `Available`, and a successful HTTP response each prove—and what each does not prove.
