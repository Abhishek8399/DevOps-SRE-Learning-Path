# Learning review: immediate probe reset after reconstruction

Status: local exercise review; no production incident or customer impact.

## What happened

The first namespace-reconstruction run deleted and recreated `team-a`, reconciled the workload and received a successful Deployment rollout result. The immediate host NodePort `/version` request then failed with “connection reset by peer.” The verifier stopped and its recovery trap reapplied state.

## Mechanism

Deployment Available is necessary but does not guarantee that every node-level forwarding and endpoint path has converged at the same instant. Namespace deletion removed Service and EndpointSlice state; reconstruction created new Pod IPs and endpoints. The first host request raced that data-plane change.

## Response and validation

The exercise did not weaken the user check or treat rollout as enough. It added a bounded user-probe loop: at most thirty attempts, two-second request timeout and one-second interval. Recovery also waits for rollout. The second complete run passed its baseline probe on attempt one and post-reconstruction probe on attempt two.

## Learning

The root cause is not “Kubernetes is slow.” The observed mechanism is a convergence window between controller readiness and the particular host-to-NodePort path. Retries are safe here because GET `/version` is read-only, bounded and has a deadline. The same retry policy would be unsafe for an ambiguous non-idempotent write.

## Follow-up

Keep the external user-path assertion, record attempt count, and add EndpointSlice observation if recurrence grows. A production platform would compare ingress, Service and endpoint propagation distributions and alert only when the bounded convergence objective is breached.
