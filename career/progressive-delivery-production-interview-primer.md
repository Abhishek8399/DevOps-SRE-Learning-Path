# Progressive delivery: use exposure as an experiment, not a slower full rollout

Canary, rolling, blue-green and feature-flag delivery are ways to control who sees a change and when. They do not automatically make a release safe. Safety comes from a compatible contract, clear evidence, reversible authority and a decision rule that protects the user journey.

```text
immutable artifact -> compatible data contract -> limited exposure -> user/technical evidence -> decision -> wider exposure or recovery
       |                    |                      |                      |                    |                    |
    provenance          migration path           cohort/traffic          SLI + guardrails       owner             rollback/roll-forward
```

Never ask only “did deployment succeed?” Ask “which population saw which behavior, what changed, and what decision does the evidence authorize?”

## Scenario 1: canary error rate is low but latency rises

**Question:** A canary has normal error rate, but p99 latency and database connection saturation rise. Do you promote?

**Strong answer:** I pause promotion. Error rate is one signal; a latency and saturation increase can predict a later outage or already harm a critical cohort. I verify the canary population, traffic weight, request count, latency distribution, connection-pool/queue behavior, dependency load, change identity, baseline and measurement freshness. I check whether the canary differs in query shape, retries, cache behavior, resource requests, feature state or data access. I contain the amplifier by holding exposure, reducing concurrency or disabling a compatible feature under the release authority. I choose rollback or roll-forward only after checking schema/data compatibility and side effects. I verify user journeys, tail latency, errors, saturation and data correctness over a declared window before a new decision. Prevention is multi-signal automated gates, representative cohorts, dependency-aware capacity limits and a policy that treats latency/saturation as promotion criteria rather than optional graphs.

**Weak answer:** “Errors are low, so promote.” A service can be accepting requests slowly while queues, timeouts and dependency resources approach collapse.

**Senior follow-up:** Why does canary size matter? A small or unrepresentative cohort may not exercise the load, tenants, data shapes or dependencies that reveal the failure. State what population the evidence covers.

## Scenario 2: blue-green switch exposes a hidden dependency

**Question:** The green environment is healthy in tests, but after traffic switching it cannot call a shared third-party payment service. What was missed?

**Strong answer:** Environment health proved only the tested dependencies and paths. I map production-only boundaries: egress identity/IP allowlist, DNS view, certificates, secrets, firewall/proxy, rate limits, callback endpoints, data permissions, feature flags and traffic source. I stop or reverse the traffic shift through the defined routing control, preserving evidence and avoiding a broad rebuild. I compare blue and green resolved configuration and connection path to the provider, correct the smallest missing contract, and revalidate with an approved nonfinancial or bounded transaction. I do not claim green is identical just because its application process and local checks are healthy. Prevention is dependency-contract inventory, pre-switch production-like probes, egress/identity parity tests, explicit third-party ownership and a switchback runbook with session/data implications.

**Weak answer:** “The third party is down.” The timing may expose a green-specific network, identity or certificate difference; prove it before escalating blame.

**Senior follow-up:** What makes blue-green rollback difficult? Stateful writes, session affinity, cache/data divergence, irreversible side effects, DNS/cache propagation and shared dependencies can make a traffic reversal only part of the recovery.

## Scenario 3: feature flag causes a partial outage

**Question:** A feature flag was enabled for ten percent of users and only one tenant reports failed checkout. Is the flag safe to leave on?

**Strong answer:** I identify flag identity/version, evaluation location, targeting rule, affected tenant/cohort, fallback behavior, configuration propagation delay, request path and data state. A single report may be an early signal of a cohort-specific contract mismatch: tenant configuration, data volume, permission, browser/client version, region or cached state. I hold expansion and either disable the flag for the affected scope or revert it globally based on safety and blast radius. I inspect a healthy and failing evaluation with privacy-minimized evidence, then correct the mechanism and verify the tenant’s real journey plus a representative eligible cohort. Feature flags require ownership, expiry, audit, test matrix, safe default, exposure metric and removal plan; otherwise they become invisible configuration debt.

**Weak answer:** “Only ten percent are affected, so it is acceptable.” The affected ten percent may include a high-value or legally important population, and the flag may expand automatically or share a hidden dependency.

**Senior follow-up:** What does a flag evaluation log need to avoid? Unbounded personal identifiers, secret values and unbounded cardinality. Record only the minimum bounded context needed to explain a decision under approved privacy controls.

## Scenario 4: a rollback follows a database migration

**Question:** A release includes an application change and a schema migration. The new application has a defect. Can you roll back immediately?

**Strong answer:** I map backward compatibility before touching traffic. I identify migration type, old/new read/write behavior, data backfill, defaults, constraints, locks, feature flags, irreversible transformations, backup/restore point and valid writes since migration. Expand/contract designs allow old and new code to coexist while data changes progress; destructive contraction before rollback removes that safety. I may disable the feature, route traffic to a compatible version, or roll forward a small corrective release instead of restoring data. A full database restore is not normal release rollback because it can erase legitimate customer writes. I verify application transactions, schema/data invariants, lock/latency effects and the user journey. Prevention is migration review, compatibility tests, phased backfill, versioned contracts, deploy gates and a documented decision tree for rollback versus roll-forward.

**Weak answer:** “Revert the code and migration.” Data transformations may be irreversible or have already accepted new writes; a naive reverse migration can make correctness worse.

**Senior follow-up:** When should a migration block deployment? When it cannot be proven compatible with the previous/next application state, has unsafe lock/duration behavior, lacks recovery evidence, or its business authority has not accepted its risk.

## Scenario 5: release metrics disagree by cohort

**Question:** Global metrics are healthy, but mobile users in one country have a sharp error increase after release. What does the release system need to do?

**Strong answer:** Global aggregation is hiding a population boundary. I pause expansion and define the cohort precisely: client version/platform, geography, network, language/currency, tenant, route, release/flag state and denominator. I compare pre/post and exposed/unexposed users while checking telemetry coverage and privacy limits. I look for protocol compatibility, certificate/DNS/edge behavior, feature targeting, payload/MTU thresholds, localization/data contract and regional dependency differences. I choose a scoped rollback, flag disable or traffic hold that protects the cohort without unnecessarily disrupting unaffected users, then verify the real mobile journey. Prevention is cohort-aware release gates, representative test coverage, version/client compatibility policy, regional synthetic journeys, accessible rollback controls and an alert that preserves denominators instead of averaging away a critical minority.

**Weak answer:** “The average is green, continue rollout.” Reliability is a contract for a defined population, not a single average that can conceal severe harm.

**Senior follow-up:** Why can percent error alone mislead? A percentage without denominator, population, classification and time window can magnify tiny samples or hide high-volume/critical-user impact.

## Scenario 6: release automation bypasses an approval during an outage

**Question:** During an incident, someone asks to bypass the normal deployment approval to ship a fix. What is a safe answer?

**Strong answer:** I distinguish emergency delivery from uncontrolled delivery. I identify the customer risk, proposed artifact/source identity, change scope, test evidence, rollback/kill path, environment, approver and audit record. If policy allows, I use a predesigned break-glass route with time-bound authority, least privilege, immutable audit and mandatory post-incident reconciliation—rather than editing pipeline code, reusing shared credentials or disabling gates globally. I still require the minimum safety checks appropriate to the urgency and choose a small reversible exposure. I verify the release through the user journey, record the exception, and restore normal controls after recovery. Prevention is an exercised emergency-release procedure, fast but trustworthy artifact promotion, clear authority and delivery metrics that reveal whether normal gates are too slow or merely being bypassed for convenience.

**Weak answer:** “Skip everything; production is broken.” That can turn an outage into a supply-chain, security or data-integrity event and makes later reconstruction impossible.

**Senior follow-up:** What must the audit capture? Who authorized and executed the action, exact source/artifact/configuration identities, environment, time, scope, approvals, observed outcome, rollback/reconciliation and any temporary access or policy exception.

## Progressive-delivery answer map

1. Name the immutable change, exposed cohort and user contract.
2. Compare exposure with a meaningful baseline and unexposed/healthy control.
3. Require user, dependency, saturation and data-correctness evidence—not one green metric.
4. Keep traffic, flag and migration actions compatible and reversible where possible.
5. Use exception/break-glass authority that is scoped, temporary and auditable.
6. Verify the recovery or promotion decision over the stated population and window.

Remember: **progressive delivery reduces blast radius only when the system can tell you which blast you are measuring.**
