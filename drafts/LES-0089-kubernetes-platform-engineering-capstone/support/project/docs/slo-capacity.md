# Platform SLO and capacity model

## Separate platform, deployment and service indicators

A platform API SLI might measure valid service requests that produce accepted desired state within a latency bound. A deployment SLI might measure accepted changes that reach Available with the intended revision. A service SLI measures a user operation. Mixing them hides ownership: the platform can render successfully while the workload image fails, and the service can remain healthy while the portal is unavailable.

The local fixture measures 100 `/readyz` requests at concurrency five. Eligible means the verifier intentionally sent the request during the declared window. Good means HTTP 200. The evaluator reports availability, p95 latency, objective attainment and error-budget consumption. The latest full run observed 100/100 successes and p95 12.881 ms at a 200 ms objective. That is a regression receipt for one laptop run, not a capacity limit or SLO promise.

With 100 eligible events and a 99% objective, the mathematical budget is one failed event. A single additional failure would consume the whole small-window budget. That illustrates why tiny windows are noisy and why production SLOs need stable event definitions, representative volume and a longer policy window.

## Capacity path

Capacity is a chain:

```text
tenant demand -> quota -> Pod requests -> scheduler fit -> node allocatable
              -> runtime limits -> service concurrency -> user latency/errors
```

Quota constrains aggregate declared requests; it does not reserve physical CPU or prove performance. Requests influence scheduling and CPU share. Limits bound runtime use and can cause throttling or OOM termination. Replica count changes both capacity and failure exposure. A disruption budget protects availability only for voluntary evictions and only when spare capacity permits replacement Pods.

The kind workers share the laptop’s real CPU and memory. Their labels emulate two zones but do not add failure-domain capacity. Before production, model steady demand, peak factor, failover headroom, rollout surge, daemon overhead, control-plane/add-on load and fragmentation. Validate with representative traffic and failure, then compare user SLIs—not just Pod CPU.

## Alert policy

Page on sustained user impact or platform inability to reconcile critical services, not every Pod restart. Ticket on quota trend, approaching deprecation and template drift. Dashboard cold-start time, reconciliation latency, policy rejection by reason, rollout success, support demand and monitoring health. Every alert needs an owner, urgency, next evidence and failure mode for the monitoring system itself.
