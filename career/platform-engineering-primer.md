# Platform Engineering Primer

Platform engineering is not “put every tool behind a portal.” It is the deliberate design of a paved path that removes repeated cognitive and operational toil from product teams while preserving ownership, safety, and choice. This primer is study material; it does not prove that a platform is reliable or that a learner can operate one.

## The mental model

Think of the platform as a product with an internal customer:

```text
developer intent
      |
      v
golden-path API/template  ---> policy and security checks
      |                                  |
      v                                  v
deployment/workload ----> runtime infrastructure ----> telemetry and support
      ^                                  |
      +-------- feedback, cost, SLO -----+
```

The platform owns the paved path and its contracts. The application team owns its service behavior and product outcome. The boundary must be explicit or the platform becomes an unowned shared operations queue.

## Start with a painful journey

Before building a portal, measure one journey such as “create a safe service,” “request a database,” or “promote a release.” Record:

- lead time from request to usable environment;
- failed changes and manual handoffs;
- time spent finding ownership, credentials, logs, and rollback steps;
- support volume and repeated questions;
- reliability, security, and cost outcomes after self-service.

If the platform cannot improve a measurable journey, it is collecting tools rather than delivering a product.

## Golden paths are defaults, not prisons

A golden path should provide a working baseline: repository structure, build, tests, artifact identity, deployment, observability, access policy, ownership, rollback, and documentation. It should expose versioned interfaces and an escape hatch for justified exceptions.

The trade-off is important:

| Choice | Benefit | Cost or risk |
|---|---|---|
| One opinionated template | Low cognitive load and easy support | Can block legitimate workloads |
| Many options | Local flexibility | Higher toil, drift, and support burden |
| Self-service mutation | Fast delivery | Needs authorization, audit, quotas, and rollback |
| Central platform control | Consistency | Platform becomes a bottleneck and single failure domain |

Prefer a small number of well-supported paths, measurable exceptions, and migration tooling rather than universal enforcement by undocumented convention.

## Reliability contract

The platform needs its own user-facing indicators and objectives. Examples include template generation success, deployment completion time, artifact availability, control-plane availability, and recovery time for a failed platform dependency. A green platform dashboard does not prove that every product team can deploy; measure the journey from the developer’s point of view.

Design for failure:

- existing workloads should keep serving when a control-plane dependency is unavailable;
- desired state, accepted state, and observed runtime state must be distinguishable;
- retries need deadlines, jitter, idempotency, and a budget;
- upgrades need compatibility windows, rollback, and a tested recovery path;
- every self-service action needs an audit record and an owner.

## Security and tenancy

Self-service is an authorization boundary, not a convenience button. Validate identity, tenant, environment, resource limits, allowed images, secret references, network policy, and separation of duties before creating resources. Keep credentials out of templates and logs. Prefer short-lived identity and workload-scoped permissions over shared administrator tokens.

Multi-tenant platform questions:

1. What can one team discover about another team?
2. Which resources, queues, namespaces, networks, and budgets are isolated?
3. Can a template or plugin execute arbitrary code?
4. Who approves exceptions and who can revoke them?
5. Can an incident be investigated without exposing another tenant’s secrets?

## Cost and developer experience

Cost is a product feature. Attribute compute, storage, network, observability, and idle environments to a team or workload. Make expensive choices visible at request time, enforce budgets with safe failure modes, and provide cleanup or expiration for temporary resources.

Developer experience is not only a survey score. Combine qualitative feedback with time-to-first-success, failed-change rate, support contacts, and the percentage of services using a maintained path. A platform that is pleasant but unsafe is not successful; a safe platform nobody can use is also not successful.

## Interview prompts

- Design a golden path for a new service without forcing every workload onto one runtime.
- A platform outage blocks new deployments but existing services are healthy. Explain control-plane/data-plane isolation and the safest response.
- Teams bypass the platform after a slow database-provisioning workflow. What evidence do you gather before adding another tool?
- How would you prove that a developer portal reduced toil rather than moving it to the platform team?

Strong answers name the user journey, contract, owner, evidence, failure mode, security boundary, cost model, and escape hatch. “Use Kubernetes and Backstage” is a tool list, not a platform design.
