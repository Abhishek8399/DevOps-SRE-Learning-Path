# CI/CD production interview: prove what is being promoted, who may promote it, and how you recover

A delivery pipeline is not just a sequence of jobs. It is a trust and evidence path from a source revision to a user-visible change.

```text
source revision -> build inputs -> test evidence -> immutable artifact -> approval/policy -> deployment -> user verification
      |                |                |                  |                 |             |
   identity         provenance        scope              promotion          rollback      audit
```

When a pipeline fails or deploys the wrong thing, begin with the artifact identity, environment, authority, and user impact—not the color of the last job.

## Scenario 1: a deployment succeeds but users still see the old version

**Question:** The deployment job is green, the platform reports the new revision, but customers still see old behavior. How do you investigate?

**Strong answer:** I define the user operation, affected population, time and healthy comparison. “Deployment succeeded” may only mean an API accepted desired state; it does not prove traffic reached the intended artifact or that the new behavior is enabled. I trace source commit, build provenance, immutable artifact digest, deployment revision, environment/namespace/account, traffic route, cache/CDN/proxy behavior, feature flag/configuration, readiness and the user request. I compare an affected request’s version/header/trace with the intended artifact and a known-good control. I contain using the smallest reversible traffic, flag or revision change after proving the mismatch. Recovery is a successful user operation on the intended behavior, with old capacity and caches handled deliberately. Prevention is artifact-to-request observability, immutable promotion, route/config verification and a release checklist that distinguishes deployment acknowledgement from customer exposure.

**Weak answer:** "Run the pipeline again." Repeating a green control-plane action does not discover a routing, cache, flag or wrong-environment error.

**Senior follow-up:** Why is an image tag weak evidence? A mutable tag can resolve differently over time or across environments. A digest or equivalent immutable artifact identity is the stronger binding.

## Scenario 2: a pipeline uses shared credentials and mutable build inputs

**Question:** A fast pipeline pulls `latest` dependencies, runs with one long-lived deployment secret, and publishes artifacts by branch name. What is your first design correction?

**Strong answer:** I draw the trust path and find where an untrusted or mutable input can become a production effect. I pin source/dependency/artifact identities, preserve lockfiles and build metadata, isolate build and deployment roles, replace shared long-lived secrets with short-lived least-privilege identity where supported, protect environments/approvals, and make the promotion artifact immutable. I add controls in stages with failure tests so the team can still deliver. I do not claim that one scanner or a signed commit solves runtime authorization. Prevention includes provenance/SBOM where appropriate, secret scanning, protected runners, reviewed reusable pipeline components, audit retention and a tested rollback path.

**Weak answer:** "Add a vulnerability scanner." Scanning is useful evidence, but it does not fix mutable inputs, broad deployment authority, artifact substitution or approval bypass.

**Senior follow-up:** What is the difference between build trust and deploy trust? Build trust concerns what produced an artifact and under which controlled inputs; deploy trust concerns who may promote that exact artifact into a specific environment under current policy.

## Scenario 3: rollback after a database migration

**Question:** A release introduces an application bug after a schema migration. The team wants an immediate application rollback. What do you challenge?

**Strong answer:** I map compatibility in both directions. Rolling application code back may be safe only if the schema/data change remains compatible with the old version. I inspect migration type, write behavior, data backfill, feature flags, migration ownership, backup/restore point, lock duration and customer impact. I prefer expand/contract changes: add compatible schema, deploy code that handles both forms, migrate/backfill under observation, then remove old fields later. If a rollback is needed, I choose a scoped action that preserves data and verify write/read paths, error/latency objectives and data integrity. I do not treat database restore as a normal rollback because it can erase valid writes made after the change.

**Weak answer:** "Just redeploy the previous image." That assumes the old image understands the new schema and all effects are reversible.

**Senior follow-up:** What should a release plan say before the migration? Compatibility window, data owner, backup/restore boundary, rollback decision tree, verification queries, customer-impact plan, and who can authorize destructive recovery.

## Scenario 4: failed canary shows mixed signals

**Question:** A canary has low error rate but rising p99 latency and database connection saturation. Should you promote or roll back?

**Strong answer:** I first validate the canary population, metrics window, telemetry completeness and comparison baseline. Low errors may be temporary or may exclude queued/slow requests; rising p99 and downstream saturation can be leading indicators of an amplification failure. I check traffic share, request cost, queue depth, retry rate, connection pool behavior, dependency headroom and user experience. The decision follows the defined promotion policy and error/performance budget, not one convenient green metric. I pause or roll back the canary with a bounded scope if the risk threshold is crossed, preserve evidence, and verify both user and dependency recovery. Prevention is an explicit multi-signal guard, representative canary traffic, analysis-window design, automatic/approved rollback and a test for the failure mode.

**Weak answer:** "Errors are low, so continue." Reliability is not a single error counter; latency, saturation and queueing can signal an outage forming.

**Senior follow-up:** Why can automatic rollback be unsafe? It may trigger on bad telemetry, reverse an irreversible migration, create flapping, or remove a necessary containment change. Automation needs scope, policy, ownership and an escape hatch.

## Scenario 5: a self-hosted runner fleet has growing queue time

**Question:** CI jobs wait thirty minutes before starting. Teams want to add permanent runners quickly. How do you reason about it?

**Strong answer:** I measure arrival rate, service time distribution, queue age, concurrency, runner labels/capabilities, blocked dependency stages, cache behavior, executor capacity, image pulls, storage/network bottlenecks, trust isolation and failed-job retries. More permanent runners can increase cost, credential exposure and shared-resource contention while leaving a serial stage or wrong label constraint untouched. I identify the narrowest bottleneck, then use a bounded capacity/queue policy, ephemeral isolated workers where appropriate, cache and artifact improvements, concurrency controls and cancellation/retry discipline. I verify lead time, queue age, failure rate, resource saturation and security posture after the change. Prevention is capacity forecasting, per-class SLOs, trusted runner pools, fair scheduling and an upgrade/runbook path.

**Weak answer:** "Add ten runners." That is a capacity action without a queueing model, security boundary or proof that runners are the bottleneck.

**Senior follow-up:** What must never be shared casually across trust boundaries? Credentials, workspace artifacts, caches, Docker sockets/privileged execution, network reachability and reusable runner state.

## Scenario 6: production deployment needs an emergency fix

**Question:** An incident is active, and someone asks to bypass the pipeline and run a manual production command. What do you do?

**Strong answer:** I prioritize customer safety and preserve controlled authority. I establish impact, urgency, proposed action, exact target, owner, approval path, reversibility, audit trail and rollback. If the normal pipeline cannot meet the incident need, I use the approved break-glass procedure with short-lived scoped access, peer/incident authorization, recorded command/artifact/configuration identity, verification and expiry. I do not normalize an undocumented manual path or paste credentials into chat. After recovery, I reconcile the emergency state into version control and pipeline policy so the next deployment does not overwrite it. Prevention is a fast but safe emergency lane, tested access controls, incident runbooks and regular game days.

**Weak answer:** "Production is down, so process does not matter." Emergency authority is still authority; untracked changes can extend the incident or create a security breach.

**Senior follow-up:** What does a good break-glass record contain? Incident link, decision authority, target/scope, exact action or artifact identity, reason, start/expiry, verification result, rollback/reconciliation owner and follow-up review.

## A release answer checklist

| Boundary | Question to say aloud |
|---|---|
| Source | Which reviewed revision and inputs produced this? |
| Artifact | What immutable identity is actually promoted? |
| Authority | Who/what can deploy it to this environment, and why? |
| Scope | Which traffic, tenant, region, version and data boundary are affected? |
| Observability | Which user, platform and dependency signals decide promotion or rollback? |
| Recovery | What is reversible, what is not, and how is recovery verified? |
| Reconciliation | How will an emergency/manual change return to declared state? |

## Practice transfer

Answer each scenario once for GitHub Actions, GitLab CI/CD, Jenkins or Azure Pipelines. Do not pretend provider syntax is the mechanism. Explain where that system stores identity, runner trust, immutable artifacts, approvals, environments, logs and rollback evidence. The correct answer changes with the implementation; the security and recovery questions do not.
