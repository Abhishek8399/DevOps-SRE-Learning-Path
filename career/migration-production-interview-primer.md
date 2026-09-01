# Migration production interview: move authority deliberately, not just traffic

A migration is not complete when the new system answers a request. It is complete when the correct authority, data, identities, traffic, recovery path, and retirement decision are all proven.

```text
old authority <-> compatible coexistence <-> new authority
      |                  |                    |
   baseline           reconcile             cutover
      \_________________ evidence, owner, and rollback boundary _________________/
```

## Scenario 1: new service is live, but old and new systems disagree

**Question:** A migrated service accepts traffic, but balances differ between old and new systems. What do you do?

**Strong answer:** I stop expanding cutover and name the authority for each field/operation. During coexistence, two writable systems without a conflict contract create split-brain business state. I identify the exact divergence window, entity keys, source revisions, write paths, replication/CDC lag, transformation rules, idempotency keys, and customer impact. I preserve evidence and choose a bounded reconciliation owned by the data/business authority; I do not overwrite one side because it has a newer timestamp unless that ordering rule is actually valid.

I decide whether to route back, freeze selected writes, continue with a compensating workflow, or run a reviewed repair based on reversibility and user harm. Prevention is an explicit authority map, compatible schema/event contract, invariant checks, reconciliation job, exception queue, and a cutover gate based on agreement—not just request success.

**Weak answer:** "Make the new system the source of truth now." Naming an authority after divergence does not repair unknown or lost business effects.

**Senior follow-up:** What proves reconciliation? Every scoped record is classified as matching, safely repaired, deliberately excepted, or escalated; the aggregate totals and representative user operations also agree.

## Scenario 2: a database migration cannot roll back

**Question:** A release requires a destructive schema change. How do you make the deployment safe?

**Strong answer:** I state plainly that application rollback is not data rollback. I prefer expand/contract: introduce compatible schema first, deploy code that can read/write old and new forms, backfill idempotently with observability, verify adoption and reconciliation, then remove obsolete structures after the recovery window. If a destructive step is unavoidable, its cutoff is explicit, with a tested restore/forward-fix plan, data owner, RPO/RTO, maintenance/customer-impact decision, and verification of actual data usability.

I test mixed-version behavior because rollout can leave old and new workers active together. I do not promise one-click rollback after a non-compatible migration. The release gate checks the user journey and durable state before and after each irreversible boundary.

**Weak answer:** "The deployment tool can roll back the image." The image can be old while the database and events are new.

**Senior follow-up:** What is a safe backfill? It is partitioned/resumable, idempotent, capacity-bounded, lineage-recorded, observable, and reconciled against the authoritative input.

## Scenario 3: DNS cutover sends some users to the old endpoint

**Question:** DNS was changed, but a subset of users still reaches the old system. What is your triage?

**Strong answer:** I treat DNS as one routing layer with caches and multiple authorities. I establish hostname, record type, TTL, authoritative answer, resolver behavior, client/edge cache, load-balancer/CDN configuration, TLS/SNI, network path, and the actual endpoint observed by affected users. Lowering TTL before cutover reduces future caching behavior; it does not erase already cached records or non-DNS routing rules.

I keep both endpoints safe during the transition, use controlled routing/traffic evidence, and avoid shutting down the old system until the defined propagation and user-path conditions pass. If state is writable, I ensure the old path cannot accept conflicting writes. Prevention is a cutover runbook with preflight DNS/TLS/route checks, overlap period, observability by endpoint/version, rollback decision, and retirement gate.

**Weak answer:** "Flush DNS everywhere." You usually do not control every recursive resolver, client, CDN, or pinned endpoint.

**Senior follow-up:** What proves cutover? Scoped client-path observations, declining old-endpoint traffic within the TTL/overlap contract, correct TLS/identity, and successful user operations—not a single resolver query.

## Scenario 4: copy job completes, but privacy and access differ in the target

**Question:** Data has been copied to a new platform. How do you know it is safe to enable users?

**Strong answer:** Row counts are not enough. I compare classification, tenancy, ownership, row/column policy, encryption/key boundary, retention, masking/tokenization, audit, backup/restore, network exposure, service identities, and administrative access. A correct record in a less protected target is a security regression.

I perform least-privilege preflight with representative user/service identities, verify that denied access remains denied, and preserve an access-control mapping/review. I do not enable broad access to "test quickly." The migration plan includes authoritative owner approval for data handling, privacy/security review where required, audit evidence, and a retirement plan for target copies that are not accepted.

**Weak answer:** "The copy checksum matches, so production is ready." Integrity is one property; confidentiality, authorization, retention, and recoverability are separate properties.

**Senior follow-up:** What is the proof limit of an ACL export comparison? It can show declared mappings; it may not prove inherited policy, runtime identities, application-side authorization, historical access, or effective network reachability.

## Scenario 5: cutover needs a rollback, but writes already crossed systems

**Question:** An issue appears after traffic moves to the new system. Can you roll back safely?

**Strong answer:** I first determine whether rollback means routing only or authority reversal. I identify writes/effects accepted after cutover, replication/reconciliation status, compatibility of old readers/writers, external notifications, queues, feature flags, and customer impact. A route reversal without write handling can lose or duplicate state.

I choose the smallest safe response: contain the broken feature, hold or queue selected writes, route only compatible reads, forward-fix, reconcile back, or execute a formally designed reverse migration. The decision has an owner and explicit proof conditions. I do not revert traffic merely because it is familiar. A migration plan must define the rollback window, point of no return, data/effect strategy, and user communication before cutover.

**Weak answer:** "Switch the load balancer back." That is safe only if both systems and all intervening effects remain compatible and authoritative state is handled.

**Senior follow-up:** What makes a migration reversible? Compatible interfaces/state, tracked writes/effects, a reconciliation method, retained old capacity, clear authority, and a tested bounded reversal—not an assumption.

## Scenario 6: the old system stays online forever "just in case"

**Question:** The new system has run for months, but no one will retire the old one. How do you finish safely?

**Strong answer:** I treat retirement as a deliberate lifecycle stage. I identify residual traffic, jobs, identities, certificates, DNS/routes, backups, legal retention, data ownership, cost, security exposure, support contracts, and recovery dependencies. An old system can still serve hidden clients or become an unpatched privileged path.

I create a staged retirement: block new writes, observe/route remaining dependencies, archive or retain data according to policy, revoke identities and secrets, remove traffic, verify expected absence, preserve required audit/recovery artifacts, and decommission with an owner and rollback/restore boundary where appropriate. Success includes absence evidence and cost/security ownership transfer, not merely turning off a VM.

**Weak answer:** "Leave it running; it costs little." Hidden systems accumulate credentials, vulnerabilities, operational confusion, and indefinite ownership cost.

**Senior follow-up:** What proves retirement is safe? Required consumers are migrated or intentionally ended, authority/retention obligations are satisfied, identities/routes are removed, monitoring confirms expected absence, and the recovery/archive decision is owned.

## Fast decision map

| Signal | Remember | First safe move |
|---|---|---|
| old/new disagreement | Coexistence needs authority | Stop expansion and classify/reconcile with an owner |
| destructive migration | Image rollback is not data rollback | Define compatibility, point of no return, and restore/forward plan |
| partial DNS cutover | DNS is one cached routing layer | Trace client-to-endpoint path and protect overlap |
| copied data | Integrity is not authorization | Validate effective identity, policy, retention, and recovery |
| post-cutover failure | Route rollback can lose writes | Map crossed effects and decide authority/reconciliation first |
| old system remains | Retirement is a technical change | Remove traffic/identity safely and prove expected absence |

## Practice

For every migration, draw the authority map before the topology diagram. Then state: coexistence contract, cutover gate, rollback boundary, reconciliation proof, and retirement owner. Those five things make a migration operable.
