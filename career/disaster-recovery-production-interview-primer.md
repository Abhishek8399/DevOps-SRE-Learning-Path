# Disaster recovery production interview: a backup is a promise only after a safe restore proves it

Disaster recovery is not the moment when a team opens a runbook. It is a set of decisions made before failure: what outcome matters, which data/state must survive, how much loss and delay are acceptable, who has authority, and how recovery is proven without creating a second outage.

```text
business outcome -> RPO / RTO decision -> backup + replication + runbook -> isolated restore
       |                    |                       |                       |
customer harm          accepted loss/time       recovery capability      evidence of outcome
                                                                       
failure -> detect -> contain/fence -> select recovery point -> restore/fail over -> validate -> reconcile -> learn
```

The durable rule is: **replication, successful backup jobs, and a failover button are mechanisms. Recovery is the verified return of the required user and data outcome within an agreed boundary.**

## Scenario 1: leadership asks for “zero data loss and instant recovery”

**Question:** A product leader asks for zero data loss and instant recovery for a new service. How do you turn that request into an engineering decision?

**Strong answer:** I translate the phrase into specific business operations and failure cases. Which writes are irreversible or regulated? Which reads can be stale? What failure domains matter—process, node, zone, region, account, identity, corruption or operator error? Recovery point objective (RPO) is the maximum acceptable data loss measured in time or transactions; recovery time objective (RTO) is the maximum acceptable time to restore the required outcome. Neither is automatically zero. I quantify the cost, complexity, latency, consistency and operational authority required for candidate designs: synchronous replication, asynchronous replicas, durable queues/outbox, point-in-time recovery, immutable backups, manual fallback or active-active conflict handling. I document assumptions, owner, measurement method, test frequency, exception path and residual risks. If “zero” is truly required, I explain the available failure boundaries it still does not cover and obtain accountable approval for the design and its cost. I do not promise an objective that no tested system can prove.

**Weak answer:** "Enable multi-zone and call it zero RPO." A topology label does not define write acknowledgment, replication lag, corruption behavior, regional scope, restore capability or customer outcome.

**Senior follow-up:** Why can RPO be expressed in transactions rather than minutes? A high-value operation may matter more than elapsed time. The objective must match the business loss the system is designed to limit.

## Scenario 2: backup jobs are green, but no one has restored recently

**Question:** All backup dashboards are green. Is the service recoverable?

**Strong answer:** Green jobs prove that a configured process reported success; they do not prove the right data was captured, retained, readable, decryptable, complete, authorized or restorable in time. I inspect backup scope, artifact identity, checksums, encryption/key availability, retention/lifecycle, account/region separation, restore permissions, dependencies, schema/application compatibility and evidence of previous restore tests. I perform a bounded isolated restore using a representative recovery point and a documented normal-user/approved environment. I verify integrity and the actual required operations: data consistency checks, application start, migrations/configuration, identities/secrets references, dependencies and a synthetic user transaction where safe. I measure elapsed time from the recovery decision to user-ready outcome and compare it to RTO; I measure data age/transaction boundary against RPO. I record failures and update runbooks, ownership and test cadence. A restore that produces files but cannot serve the intended operation is not recovery.

**Weak answer:** "The backup provider says successful." Provider status is evidence about one transfer/job, not a complete recovery of your application, keys, access or dependent state.

**Senior follow-up:** What should a restore test avoid? It must not overwrite production, reuse unsafe production credentials, leak customer data into an unapproved environment or silently skip cleanup/retention controls.

## Scenario 3: a regional database outage requires failover

**Question:** The primary region is unavailable. The replica region has lag. Do you promote it immediately?

**Strong answer:** I first establish user impact, primary/replica state, replication lag measured against the required data boundary, health of the candidate region, DNS/traffic control, dependency readiness, writer identity and the business objective. Promotion can create data loss, split brain or an apparently healthy service with broken dependencies. I follow the authorized failover plan: stop or fence writes in the old authority where possible, establish one clear writer, preserve evidence of the selected recovery point, promote only the intended target, and control traffic gradually. If the primary might return, fencing is critical; otherwise two writers can diverge. I communicate the known loss/uncertainty boundary rather than claiming zero loss. After failover, I validate read/write behavior, consistency, authentication, background jobs, queues, monitoring/alerting and the priority user journeys. Failback is a separate reconciliation/migration decision, not an automatic reversal. I retain the incident timeline and data-reconciliation plan for missed or ambiguous operations.

**Weak answer:** "Switch DNS to the replica." DNS alone does not establish database writer authority, replica suitability, dependency readiness, cache/session behavior or data correctness.

**Senior follow-up:** What does writer fencing mean? Independently preventing the old writer from accepting commits before or while a new writer is active. It reduces split-brain risk; it must be designed and tested for the actual storage/control plane.

## Scenario 4: production data is corrupted but replication is healthy

**Question:** A bad deployment corrupts records. Replicas are healthy and current. What recovery path do you take?

**Strong answer:** Replication has faithfully spread the bad state, so I stop further harmful writes and preserve the evidence needed to identify the corruption window and scope. I identify data ownership, affected entities, schema/version, deployment/change, audit/outbox logs, backup/PITR points, legal retention and the acceptable recovery objective. I decide between logical repair, point-in-time restore to an isolated environment, selective data extraction/reconciliation, full restore with a controlled cutover or a business-approved compensating workflow. I do not restore a whole production system blindly if only a subset is damaged, and I do not run a repair script without dry-run/peer review, backups and idempotent/reversible behavior. For a chosen recovery point, I validate data integrity and application compatibility before any production cutover. I reconcile operations after the recovery point using durable evidence, communicate uncertainty to owners, and verify both data correctness and user workflow. Prevention includes migration/change guardrails, invariants, audit trails, least-privilege writes, tested PITR and drills for logical—not only infrastructure—failure.

**Weak answer:** "Fail over to the replica." A current replica likely contains the same corruption and can make the recovery window harder to preserve.

**Senior follow-up:** Why restore first into isolation? It lets the team inspect completeness, test application compatibility, estimate recovery time and design reconciliation without turning an uncertain artifact into the new production truth.

## Scenario 5: the recovery runbook uses credentials held by one engineer

**Question:** During a drill, the team learns that the only account able to decrypt backups belongs to a former engineer. What do you fix?

**Strong answer:** I treat this as a recovery and security control failure, not merely an access ticket. I contain any unsafe credential exposure, identify the key/secret authority, backup artifacts/envelopes, access policy, break-glass process, audit records, rotation/revocation implications and the actual authorized recovery roles. I design least-privilege, multi-person/approved access that remains usable under the assumed disaster boundaries. That can include documented role-based recovery access, time-bounded elevation, separated key custody, tested break-glass controls, offline/independent escrow where policy permits and audit/alerting for use. I verify the new path in a drill without exposing secrets in a runbook or chat. I remove single-person dependencies from tooling, contacts, ownership and runbook assumptions, then test departure/disabled-account scenarios. “Someone knows the password” is not resilience.

**Weak answer:** "Share the old credentials with the team." That widens compromise risk, loses attribution, may violate key policy and still fails to establish a governed recovery path.

**Senior follow-up:** What must a break-glass process balance? Timely recovery under real emergency conditions with least privilege, strong authentication, approval where feasible, audit, expiry, rotation and post-use review.

## Scenario 6: a recovery drill meets time but users still cannot use the product

**Question:** The team restored the database in 40 minutes—inside the RTO—but customers cannot log in or complete purchases. Did the drill pass?

**Strong answer:** No. The database restore is a component milestone, not the recovery objective unless the objective was specifically a database artifact. I trace the required journey through identity/authentication, DNS/ingress, certificates, application configuration, secrets, queues/jobs, cache/session state, payment or notification dependencies, network policy, observability and operational ownership. I determine whether the RTO clock was incorrectly defined or whether the dependency map/runbook omitted required recovery work. I restore/repair the earliest blocking boundary under the change and incident controls, then verify the end-to-end synthetic and, where appropriate, real user outcome. I revise the service recovery plan to include dependency tiers, sequence/parallelism, owners, decision gates, data consistency checks, traffic validation, communications, fallback and cleanup. I record component times separately so bottlenecks are visible. A fast restore with an unusable service is useful drill evidence precisely because it prevents a false claim before a real disaster.

**Weak answer:** "Yes, because the restore command finished within RTO." That measures a tool action, not availability of the promised user operation.

**Senior follow-up:** How do you keep drills realistic without creating unacceptable risk? Use an approved isolated environment, bounded synthetic data/identities, declared failure assumptions, abort criteria, independent observers, tested cleanup and an explicit statement of what the drill cannot prove about production-scale failure.

## Disaster-recovery answer map

1. Convert vague availability language into owned RPO/RTO, failure domains and tested user outcomes.
2. Treat backup, replication, failover and restore as different mechanisms with different failure coverage.
3. Restore in isolation and verify integrity, access, dependencies and journeys—not just artifact existence.
4. Fence writers and reconcile uncertainty before/after failover; failback is a separate operation.
5. Plan recovery for corruption, identity/key loss and human ownership failure as well as infrastructure loss.
6. Let drills expose gaps; an honest failed drill is better than an untested recovery promise.

The sentence worth remembering is: **"I do not measure recovery by the first component that comes back; I measure it by the customer operation we promised to restore."**
