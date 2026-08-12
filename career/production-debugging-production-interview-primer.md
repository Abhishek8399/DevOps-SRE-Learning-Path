# Production debugging interview: turn a symptom into a safe, testable explanation

Production debugging is not a contest to remember commands. It is a way to reduce uncertainty without turning an incident into a larger one.

```text
symptom -> scope -> timeline -> hypotheses -> discriminating evidence -> bounded change -> verification -> prevention
   |          |          |            |                 |                   |               |             |
 user       population   change      alternatives      proves/limits       reversible      journey       control
```

When an interviewer gives you incomplete evidence, do not fill the gaps with confidence. State what you know, what is unknown, and the safest observation that separates the competing explanations.

## Scenario 1: a dashboard is red, but customers report no problem

**Question:** An error-rate alert fires, but support and synthetic checks show normal customer behavior. Is it a false alert?

**Strong answer:** I do not call it false until I compare definitions. I identify the metric producer, operation, status classification, numerator, denominator, labels, time window, aggregation, data freshness, recent instrumentation/query/rule changes and the user journey it is intended to represent. An internal dependency error may be retried successfully; a 4xx may be a valid rejected request; a missing denominator may inflate a percentage; a stale or duplicated series may create a threshold crossing. Conversely, support and one synthetic path may miss a cohort. I inspect independent user-facing evidence and the raw bounded events behind the alert, then either correct the alert contract or investigate the unobserved affected population. I mute only through the approved process with an owner and expiry, and keep a record of why. Prevention is alert review using real incidents, explicit populations, low-traffic behavior, change testing, routing ownership and periodic removal of non-actionable pages.

**Weak answer:** “The dashboard is green elsewhere, so ignore the page.” That replaces one possibly incomplete signal with another and leaves a noisy pager to train people not to respond.

**Senior follow-up:** What makes an alert useful? It names a time-sensitive risk to an owned service objective and gives enough context for a safe next action. A threshold with no decision or owner is usually a graph, not a page.

## Scenario 2: a change and a failure happen at the same time

**Question:** Errors start minutes after deployment revision 51. Have you found the cause?

**Strong answer:** The timing makes revision 51 a strong hypothesis, not proof. I establish the last known good point, exact rollout cohort, resolved configuration/artifact identities, other concurrent changes, affected versions and regions, and whether the error pattern predicts a mechanism in the diff. I compare a controlled healthy cohort or perform the smallest authorized reversible change—such as pausing rollout or canarying the prior known-good artifact—while preserving evidence. I avoid broad restarts and unrelated configuration changes because they erase the experiment. If reversal restores the same bounded contract under comparable conditions, confidence rises; I still look for interacting conditions such as traffic shape, dependency saturation or a latent schema change. Recovery verification includes user behavior, internal mechanism and configuration identity over a declared window. Prevention is immutable deployment events, configuration diff visibility, progressive delivery, rollback compatibility and a change timeline in every incident view.

**Weak answer:** “The last deploy caused it.” The last visible event may be coincidence, a trigger for an older dependency limit, or only one contributor.

**Senior follow-up:** When is rollback unsafe? When schema/data changes are incompatible, an external side effect cannot be reversed, or the old version has a security/correctness defect. Then choose a compatible roll-forward or containment path.

## Scenario 3: logs show errors but no matching trace

**Question:** You find `payment_timeout` logs, but tracing shows no corresponding requests. Which is wrong?

**Strong answer:** Neither is automatically wrong. I map each signal’s creation, sampling/filtering, transport, storage, retention and query boundary. The log could include a different operation identity, a clock issue, query filter, async worker, alternate trace context, sampling decision, exporter loss or tracing instrumentation gap. The trace could exist but be delayed, retained elsewhere or detached by a proxy. I compare stable request/workflow identifiers where policy permits, revisions, timestamps adjusted for clock semantics, affected process/host and log/trace emission counters. I inspect the earliest boundary that can prove generation rather than starting at the backend UI. I repair the missing context/export/collection path only after locating it and verify coverage as a defined percentage/population, not a promise of universal causality. Prevention is context-contract tests across sync/async boundaries, telemetry self-observation, bounded structured fields and explicit sampling/loss policy.

**Weak answer:** “Tracing is broken; enable 100% sampling.” More volume can overload the pipeline, create cost/privacy risk and still fail to instrument the missing boundary.

**Senior follow-up:** Does a shared trace ID prove causation? No. It makes a correlation/join possible. Timing, control flow and counterfactual evidence are still needed before claiming one event caused another.

## Scenario 4: partial regional failure

**Question:** Only one region has elevated latency, but service CPU is low everywhere. What is your next move?

**Strong answer:** I scope by region, zone, network path, dependency endpoint, tenant/cohort, version, request operation and time. Low CPU does not exclude saturation of a connection pool, queue, storage path, DNS resolver, load balancer, network policy, external dependency, rate limit or control-plane service. I compare the unhealthy region with a healthy one through the request path: ingress, routing, DNS, TLS, service instances, dependency connections, queues, storage and identity. I use the smallest discriminating measurement at each boundary and check for recent regional changes. I may shift only safe, capacity-validated traffic under authority; blind failover can overload the healthy region or violate data consistency. I declare recovery when the affected user journey, tail latency/error distribution and dependency health recover for the stated population—not when regional average CPU changes. Prevention includes per-region user SLIs, dependency maps, capacity headroom, failure-domain drills and routing controls with ownership.

**Weak answer:** “Scale all regions.” That ignores the asymmetric boundary and may amplify a shared dependency or make costs and diagnosis worse.

**Senior follow-up:** Why compare a healthy region? It gives a contemporaneous control for traffic and application version, helping distinguish global workload changes from an environment-specific difference.

## Scenario 5: an operator proposes a destructive fix

**Question:** Disk is full and a teammate wants to delete `/var/log/*` immediately. What do you say?

**Strong answer:** I stop the broad deletion and establish the filesystem/mount, block and inode use, top consumers, deleted-but-open files, retention/rotation policy, application ownership, audit requirements and available recovery space. “No space left” can mean blocks, inodes, quota or a filesystem-specific limit. I use bounded read-only evidence first, then choose an authorized, targeted reversible action: rotate/truncate only an understood active log through its owner, remove a known safe temporary artifact, release an approved cache, or restart a process only if that safely releases a deleted open descriptor and the service contract permits it. I protect forensic/audit evidence and record the action. I verify the real user operation can write, not just that `df` changed. Prevention is capacity thresholds with growth rate, log retention/rotation ownership, inode monitoring where relevant, quota policy, deployment artifact cleanup and tested runbooks.

**Weak answer:** “Delete the biggest directory.” Size alone does not establish ownership, retention obligation, open-file behavior, inode use, rollback ability or customer impact.

**Senior follow-up:** Why can `df -h` look healthy while writes fail? Inodes can be exhausted even with free blocks, or the relevant path can be on a different mount/quota/overlay boundary than the one being checked.

## Scenario 6: conclude an incident responsibly

**Question:** How do you know you have found root cause and can close an incident?

**Strong answer:** I separate recovery, contributing mechanisms and causal confidence. I build a timeline with source/clock limitations; state the user impact and population; label observations, documented contracts, calculations, hypotheses and unknowns; and describe the mechanism that best explains the evidence. I test counterfactuals where safe: if a bounded reversal/reproduction changes the predicted outcome, confidence grows. I do not require metaphysical certainty before restoring customers, but I do refuse a story that lacks evidence or alternatives. Closure requires sustained recovery evidence, ownership for follow-up actions, action acceptance criteria and a review of whether those actions actually reduce recurrence. A post-incident review looks at system conditions and decision context, not a search for a person to blame. Prevention actions must be specific: owner, scope, due date, test, metric, rollback and evidence of effect.

**Weak answer:** “Root cause was human error.” That explains nothing about why the system allowed one normal human action to create or prolong customer impact.

**Senior follow-up:** What is a contributing factor? A condition that made the incident more likely, harder to detect or harder to recover from, but is not necessarily the direct mechanism. Naming it helps build layered prevention.

## Debugging answer map

1. Start with the user operation and a bounded affected population.
2. Draw a timeline; distinguish events from inferred causes.
3. Keep multiple mechanisms plausible until evidence separates them.
4. Prefer a small, safe, reversible observation or change that predicts an outcome.
5. State what every signal proves and what it cannot prove.
6. Verify recovery at the user, mechanism and configuration boundaries.
7. Convert the finding into a control, test, monitor and owner.

The memorable rule: **do not ask “what command fixes this?” Ask “what evidence makes the next action safe?”**
