# Platform as a product

## Problem and users

The product is not “Kubernetes access.” Its first user is an application team that needs a small HTTP service deployed safely without learning every policy object. Its second user is the platform operator who needs consistent ownership, capacity and recovery evidence. Security and reliability reviewers are stakeholders because unsafe defaults become fleet-wide risk.

The user job is: create or update a service, understand rejection, discover ownership and operate it during failure. The platform job is: make the supported path faster than bespoke YAML while keeping evidence visible. Success is therefore measured by time to first safe deployment, successful self-service rate, actionable rejection rate, change failure rate, rollback time, support demand, adoption and user trust—not by the number of templates or clusters.

## Service promise

The local prototype promises deterministic rendering for its versioned request schema, tenant allowlisting, secure workload defaults, a committed desired-state identity, observable policy errors and a reproducible cleanup path. It does not promise databases, secrets, ingress certificates, asynchronous jobs, GPUs, stateful recovery or arbitrary Kubernetes objects.

The support model has three tiers:

1. Golden path: fields in `ServiceRequest`, documented response and platform ownership.
2. Supported extension: reviewed Kustomize or controller integration with a named owner and compatibility policy.
3. Self-managed exception: application team owns the additional control surface under a time-bounded exception; the platform still protects cluster invariants.

## Roadmap discipline

Prioritize repeated user pain with measurable risk or toil. A portal is not the next step merely because it looks complete. More valuable next capabilities are versioned schema migration, signed image identity, an enforcing CNI, secret delivery, workload telemetry, policy test fixtures, asynchronous operation status and a real pull controller such as Flux. A portal becomes useful when those capabilities have stable APIs and accurate catalog data.

Avoid platform monopolies. Publish the generated Kubernetes contract, ownership boundaries and escape-hatch process. Teams should be able to understand what the platform created and migrate away without reverse engineering hidden automation.
