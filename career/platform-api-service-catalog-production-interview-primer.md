# Platform APIs and service catalogs: make ownership and intent queryable without pretending they are reality

A service catalog is useful when it helps a responder answer: who owns this service, what does it do, how is it operated, which dependencies matter, and which path is allowed to change it? A platform API is useful when it turns a supported request into a versioned, validated, auditable capability.

```text
team intent -> catalog/API contract -> validation/policy -> asynchronous provisioner -> realized resources -> operational evidence
     |                 |                    |                    |                         |                   |
  ownership          versioned schema      admission             status/receipt            lifecycle           user outcome
```

Neither a catalog entry nor a successful API response proves a service is healthy. They are ownership and intent evidence that must be reconciled with runtime behavior.

## Scenario 1: the service catalog says the wrong team owns an outage

**Question:** During an incident, the catalog lists a team that says it no longer owns the service. Do you update the page and move on?

**Strong answer:** I treat the catalog as a control-plane record that may be stale. For the active incident, I establish the current operational owner through on-call routing, repository/deployment identity, service account, change history and management authority; I do not leave the user journey unowned while debating metadata. I record the discrepancy and safely correct the catalog with an accountable owner, review date and escalation path. I inspect why drift occurred: manual entry, missing repository integration, organizational change, unversioned ownership transfer or no validation. Prevention is a clear ownership contract, lifecycle events for create/transfer/retire, freshness indicators, review reminders and a fallback incident command path. A catalog should accelerate routing, not become a single point of truth that blocks recovery.

**Weak answer:** “The catalog is authoritative, so page that team until they accept it.” Documentation can be stale; forcing a wrong team does not restore service and hides the real ownership failure.

**Senior follow-up:** What must an ownership record include beyond a team name? Service identity, lifecycle state, operational/on-call owner, business owner where relevant, escalation path, source/repository, deployment environment, review date and transfer/retirement process.

## Scenario 2: design a platform API for a new service

**Question:** A developer submits `createService`. What makes this a safe platform API rather than an admin wrapper?

**Strong answer:** I define caller identity, authorization scope, versioned input schema, idempotency key, validation/policy behavior, defaults, asynchronous status model, output/receipt, audit record, error taxonomy, retry/deadline, ownership assignment, lifecycle and deletion semantics. The API creates an intent record first; a reconciler/provisioner performs controlled side effects and publishes bounded status. Repeating the same idempotency key with the same request returns the same outcome; a different payload is a contract error. I avoid synchronous success claims for long-running infrastructure work and do not expose raw provider administrator actions as the API. The contract declares what the platform owns versus what the team must supply, including data classification, SLO and cost inputs. I test malformed, unauthorized, duplicate, partial-failure, rollback and version-upgrade paths.

**Weak answer:** “Call Terraform or Kubernetes directly from the endpoint.” That leaves request identity, concurrency, retries, audit, policy, asynchronous status, rollback and lifecycle ambiguous.

**Senior follow-up:** Why is an idempotency key not enough by itself? The platform must define identity scope/lifetime, durable storage, request fingerprint behavior, side-effect boundaries and recovery/reconciliation when a worker crashes.

## Scenario 3: an API says provisioning succeeded, but nothing works

**Question:** `createService` returns success, yet the team cannot deploy or reach its service. What contract failed?

**Strong answer:** I separate accepted intent, reconciler progress, resource realization and user outcome. I retrieve the stable request/service IDs, API version, desired spec, status conditions, worker/reconciliation events, policy decisions, resource references and generated configuration. “Success” might mean accepted request, not completed provisioning; ambiguous status language causes incidents. I trace deployment identity, namespace/project, role bindings, network route/policy, registry access, secrets/configuration and workload readiness. I correct the earliest failed boundary and update the status contract so it is explicit: accepted, progressing, ready, degraded, failed or unknown—with reason, timestamp, observed generation and next owner action. I verify a representative deploy and user request, not merely resource existence. Prevention is condition semantics, correlation IDs, reconciliation lag/error telemetry, contract tests and a readiness definition connected to the consumer’s job.

**Weak answer:** “The API returned 200, so the platform is fine.” HTTP success can report receipt, not the asynchronous resource or workload state the developer needed.

**Senior follow-up:** What does `observedGeneration`-style status solve? It lets a reader distinguish status calculated for the current desired spec from stale status produced for an earlier generation. It still does not prove external side effects are healthy.

## Scenario 4: catalog integration leaks sensitive details

**Question:** Teams want every environment variable, endpoint and dashboard link automatically published in the catalog. What do you allow?

**Strong answer:** I classify the data and apply least disclosure. Useful operational metadata—service identity, owner, approved runbook, bounded dependency names, SLO link, deployment/repository reference and non-sensitive dashboard link—may be cataloged with access control. Secrets, tokens, private connection strings, customer data, internal topology details that increase attack surface and unrestricted production endpoints do not belong in broadly readable catalog metadata. I define trusted producers, validation, RBAC/ABAC, audit, retention, revocation and source-of-truth ownership for every field. A link is not harmless if it grants access or leaks identifiers. I test access from the intended personas and make the UI distinguish unavailable/restricted metadata from absent metadata. Prevention is schema classification, secret scanning at ingestion, restricted references rather than values, periodic access review and incident response for catalog leakage.

**Weak answer:** “It is internal, so publish everything.” Internal systems have contractors, compromised accounts, exports and least-privilege requirements; a catalog can become a high-value discovery target.

**Senior follow-up:** How do you let responders find restricted data safely? Catalog a policy-controlled reference and owner/runbook, then require the normal just-in-time authorization path to retrieve the sensitive value or view.

## Scenario 5: teams create resources outside the golden path

**Question:** Teams bypass your catalog/API and manually create cloud resources. Do you block them?

**Strong answer:** I first learn whether the supported path lacks capability, is too slow, has unclear documentation, rejects a valid workload, or imposes migration cost. I distinguish non-negotiable controls—identity, audit, data/security policy, cost ownership—from optional implementation detail. I offer an explicit import/adoption path that can reconcile an existing resource into catalog ownership without pretending it was originally created by the platform. The import validates identity, permissions, tags/labels, dependencies, lifecycle and risk; exceptions have owner, scope, expiry and review. I do not force a bulk takeover that can destroy resource state or break existing automation. Prevention is credible golden paths, visible support boundaries, API versioning, migration tooling, drift reports and outcome measures such as time to compliant capability—not mere platform request volume.

**Weak answer:** “Deny all manual access tomorrow.” That can break urgent work and create shadow automation, while leaving the platform’s missing capability unexplained.

**Senior follow-up:** What is catalog drift? The difference between recorded intent/metadata and actual ownership/resource/runtime state. Detect it, but do not auto-remediate destructive changes without authority and a safe reconciliation contract.

## Scenario 6: retire a service safely

**Question:** A team marks a service as retired. Which checks prevent a hidden dependency outage?

**Strong answer:** Retirement is a lifecycle workflow, not a status toggle. I map callers, data ownership/retention, queues/jobs, DNS/ingress, certificates/secrets, scheduled work, dashboards/alerts, backups, cost commitments, access grants, catalog links and legal/compliance obligations. I deprecate first, communicate a deadline, measure remaining traffic/dependencies, and use a reversible traffic/data transition where possible. I prevent new consumers through API/catalog policy, then remove runtime capability only after evidence shows the intended population has migrated. Data deletion follows its retention and approval policy, not the application retirement date. I verify no unexpected request, alert or dependency remains, clean up least-privilege access and preserve the audited lifecycle record. Prevention is dependency-aware catalogs, deprecation metadata, usage evidence, owner acknowledgements and a retirement runbook.

**Weak answer:** “Delete the repository and namespace.” Callers, DNS, jobs, data, credentials, backup obligations and external integrations can outlive a code repository.

**Senior follow-up:** Why retain a retired catalog record? It preserves historical ownership, intent, lifecycle and evidence references needed for audit, incident reconstruction and prevention of accidental identity reuse, subject to retention policy.

## Platform API and catalog answer map

1. Make ownership, identity, lifecycle and version explicit.
2. Treat API acceptance, reconciliation, realized resource and user outcome as different states.
3. Make policy, idempotency, asynchronous status and audit part of the public contract.
4. Publish useful operational metadata but classify/restrict sensitive details.
5. Support imports, exceptions and retirement as first-class workflows.
6. Reconcile catalog intent with runtime evidence; neither replaces the other.

The durable rule: **a platform catalog should reduce the time to a safe decision, never persuade you that an unverified record is reality.**
