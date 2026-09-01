# Incident-command production interview: lead the recovery without pretending certainty

Incident command is how a team turns many partial observations into a safe, coordinated recovery. It is not a title for the fastest debugger. The incident commander (IC) owns the operating frame: impact, priority, authority, roles, decision cadence, communications, and the definition of recovery. The technical lead owns the investigation. One person may hold both roles in a small event, but the responsibilities must still be explicit.

```text
user harm -> declare + assign roles -> stabilize -> investigate -> recover -> verify -> learn
                  |                    |              |             |
             scope / cadence       stop spread    ranked facts    user journey
                  |                    |              |             |
              decision log       preserve data   reversible moves  recurrence watch
```

When the page arrives, remember this: **your job is not to sound certain. Your job is to make the next safe decision easier, keep customers and responders safe, and prove that the promised user outcome returned.**

## The operating model interviewers want to hear

Start from the customer operation, not the alert name. State what is known, unknown, and assumed. Set a short update cadence. Separate facts from hypotheses and decisions. Make one bounded change at a time where possible. Preserve the evidence required to understand what happened. Restore the priority outcome first, then verify it from the user boundary and watch long enough to catch recurrence.

```text
Fact:       checkout 5xx rose from 0.4% to 17% at 14:05 UTC.
Hypothesis: the payment dependency pool is exhausted after release R-184.
Decision:   disable optional fraud enrichment for 15 minutes; owner: payments lead.
Evidence:   pool wait time, payment success, checkout p99, rollback status.
```

Those labels are not bureaucracy. They stop a plausible story from becoming an unsafe production action.

## Scenario 1: many alerts, unclear impact, and a senior leader asks whether to declare

**Question:** Three alerts fire within two minutes: API latency, queue depth, and database connections. The on-call engineer says, “It may settle down.” Do you declare an incident?

**Strong answer:** I do not declare from alert count alone, but I also do not wait for perfect diagnosis. I immediately establish whether a defined user journey is affected: which operation, which customers/regions, when it began, its current error/latency/success distribution, and whether there is a material trend from baseline. I check for a common dependency or recent change, then choose an appropriate coordination level under the team’s incident policy. If impact, uncertainty, or responder coordination is already material, I declare a lightweight incident early and can downgrade later. The cost of a small, well-run declaration is usually lower than delayed ownership during a growing outage.

I name an IC, technical lead, communications lead, and scribe if staffing permits. I open one timeline and decision log, state the next update time, and protect the highest-priority journey. I do not say “the database is the cause” because connections and queue depth might be effects of a slow downstream dependency, retry amplification, traffic growth, lock contention, or a bad release. I ask the smallest differentiating questions first: Are errors customer-visible? Did traffic mix change? Which dependency is slow? Are workers making progress? Is the queue growing faster than it drains? Has a safe rollback or feature reduction already been evaluated?

**Weak answer:** “Wait until the database alert turns red.” A threshold is one signal. Waiting for a dashboard to become more alarming can waste the time needed to coordinate, contain amplification, and preserve evidence.

**Senior follow-up:** What does declaration change technically? It should not magically grant unrestricted production authority. It creates a clear operating cadence, escalation and communication path, named decision ownership, and an auditable record. Existing change, security, and emergency-access controls still apply.

## Scenario 2: a rollback might restore service, but the cause is not proven

**Question:** Checkout errors began shortly after a deployment. The technical lead proposes an immediate rollback, but a second team says the database is slow. What do you do?

**Strong answer:** I treat timing as a useful hypothesis, not proof. I establish whether the release changed the failing path, whether the rollout cohort overlaps the impact cohort, whether the prior version is still healthy under comparable traffic, and whether rollback is compatible with state/schema/messages produced since deployment. I ask for the rollback’s expected effect, abort condition, blast radius, owner, and verification signals. A rollback is often the right containment when it is reversible and safe, but it can make a state mismatch worse or hide an independent dependency failure.

If the evidence is sufficient and the release plan supports it, I authorize a bounded rollback or traffic shift while preserving release metadata, traces, logs, configuration diff, and before/after metrics. I avoid stacking unrelated changes: rolling back, scaling all workers, restarting databases, and changing timeouts together destroys causal evidence and expands risk. If rollback is unsafe, I consider a narrower feature flag, cohort reduction, rate limit, or optional-path disablement.

After the action, I verify the real checkout journey for affected cohorts, error rate and tail latency, dependency health, backlog drain, and rollback completion. A green deployment controller is not enough. If recovery follows rollback, I record “release correlated and mitigation effective” rather than declaring root cause before review. The investigation continues with a reproducible hypothesis and prevention work.

**Weak answer:** “Always roll back the most recent release.” Recent changes are statistically relevant, but rollbacks can be incompatible with data migrations, protocol changes, security fixes, or an independent fault.

**Senior follow-up:** How do you distinguish mitigation from root cause? Mitigation changes the current outcome. Root cause is the causal condition that, together with trigger and contributing conditions, explains why the failure occurred. A rollback can be strong evidence, but it is not automatically a complete causal explanation.

## Scenario 3: two teams make conflicting changes during the incident

**Question:** One engineer is scaling the service while another is changing connection-pool limits. Both say their change is urgent. How do you handle it?

**Strong answer:** I pause uncoordinated changes long enough to regain a safe decision boundary. I acknowledge urgency, then ask each owner to state: the hypothesis, target, expected user outcome, dependencies, risk, rollback, and evidence that would confirm or refute it. I record the proposals and choose the smallest reversible action that protects the user journey without preventing diagnosis. If both actions are necessary, I sequence them and assign explicit ownership, timestamps, and verification windows. Changes to a shared dependency or global capacity need an especially clear authority check.

Scaling might reduce local queueing, but it can also multiply database connections, retry load, cache misses, or external API traffic. Increasing pool size might increase throughput only if the database has spare capacity; otherwise it can lengthen lock contention and overload the store. I inspect saturation, queueing, request concurrency, connection wait, dependency latency, error classification, and rate of work completion before assuming either remedy. I preserve before/after evidence and communicate the decision so responders do not repeat or undo it accidentally.

**Weak answer:** “Let both teams move fast; we can sort it out later.” Concurrent, untracked mutations create confounded evidence and can turn a contained incident into an uncontrolled experiment.

**Senior follow-up:** Is an IC a bottleneck? They should not personally approve every observation or low-risk investigation. They own high-impact decision coordination, priorities, authority boundaries, and cadence; technical work remains delegated with clear reporting paths.

## Scenario 4: service metrics recover, but support reports customers are still failing

**Question:** Error rate is back to normal. Customer support says a subset of customers cannot complete payment. Can you resolve the incident?

**Strong answer:** Not yet. I define recovery at the user boundary before closing: which representative operations, customer cohorts, regions, identities, payment methods, and dependencies must work? Aggregate metrics can hide a broken cohort, cached route, feature-flag path, asynchronous backlog, session issue, or external dependency. I compare the support reports to request IDs/times under approved privacy controls, inspect cohort-specific success and latency, trace the complete path, and verify a safe synthetic transaction or authorized real workflow where appropriate.

I separate “platform metric recovered” from “customer outcome recovered.” If the incident has shifted to a narrower scope, I communicate that accurately, retain the incident or transfer it under explicit ownership, and keep update cadence until the remaining impact is understood. I watch delayed effects: queue drain, retries, reconciliation jobs, webhook delivery, duplicate-safe processing, payment settlement, and alert behavior. Closure requires a named owner for any residual harm and an agreed follow-up; it is not a way to make a dashboard look clean.

**Weak answer:** “The alert is green, so close it.” Alerts measure their configured population and window. They may not include the affected journey, cohort, or delayed side effect.

**Senior follow-up:** What should a recovery verification contain? The explicit customer operation, time window, success/error/latency criteria, representative cohort/location, required dependency state, observer/owner, and a recurrence watch period. State what it does not prove.

## Scenario 5: an executive asks for an ETA while the team has only hypotheses

**Question:** Fifteen minutes into a severe incident, a business leader asks, “When will it be fixed?” How do you answer?

**Strong answer:** I give an honest operational update, not invented precision. I state the known customer impact and scope, start time, current mitigation or investigation stage, what has changed, what remains uncertain, the next decision/evidence gate, and the next update time. For example: “Checkout failures began at 14:05 UTC for EU card transactions. We have reduced failure rate from 17% to 5% by bypassing optional enrichment; the payment path remains degraded. We are validating whether dependency pool saturation is the remaining constraint. We do not yet have a reliable restoration time. Next update at 14:35 UTC.”

If a bounded restoration path exists, I describe conditions rather than a promise: “If rollback verification succeeds and backlog drains as expected, we expect a decision in ten minutes.” I do not expose sensitive customer data, blame a person/team, or report a root cause before evidence supports it. The communication lead adapts detail for customers, leadership, support, and engineers while the IC keeps one factual source of truth.

**Weak answer:** “It will be fixed in ten minutes” without a tested plan or evidence. False certainty damages trust and causes teams to optimize for the announced time rather than a safe recovery.

**Senior follow-up:** Why include a next update time even when nothing changes? It reduces duplicate escalation and rumor, gives stakeholders a predictable cadence, and forces the incident team to reassess evidence and decisions deliberately.

## Scenario 6: the service is restored; how do you run a useful post-incident review?

**Question:** Service is back. What makes a post-incident review useful rather than a blame document?

**Strong answer:** I start with the purpose: learn how the system and our controls allowed impact, then create owned improvements that reduce recurrence or improve detection/recovery. I preserve the distinction between system time (what actually happened) and knowledge time (what responders could reasonably know at each moment). The review reconstructs user impact, timeline, changes, telemetry, decisions, communications, mitigations, recovery verification, and unresolved uncertainty. It distinguishes trigger, immediate cause, contributing conditions, detection gaps, and organizational/control gaps; these are not interchangeable.

I use evidence to test competing explanations and avoid “human error” as a stopping point. If an action was reasonable with the evidence available then, the question becomes what system design, automation, review, ownership, runbook, alert, capacity, or access control would make the safe action easier next time. Every prevention action has an owner, priority, due date, acceptance criterion, measured effectiveness check, and dependency. For example, “Improve alerts” is weak; “Owner: Payments; add a journey SLI that separates provider timeout from client cancellation; validate against the next two release rehearsals; success: page fires within five minutes of 2% provider failure and has no known cancellation false positives” is reviewable.

I share appropriate learnings, protect sensitive evidence, and track actions through closure. The review is not complete when the meeting ends; it is complete when the agreed controls are implemented and their effect is checked.

**Weak answer:** “Find the person who deployed the bug.” Blame discourages reporting and overlooks the guardrails, rollout, observability, authorization, and recovery design that should make one mistake less harmful.

**Senior follow-up:** Can a post-incident review identify accountability? Yes. Ownership of systems and actions must be clear. Fair accountability asks what authority, information, incentives, constraints, and controls existed; it does not substitute public blame for causal analysis.

## Incident-command answer map

1. Declare based on customer impact, uncertainty, coordination need, and policy, not alert count or ego.
2. Separate facts, hypotheses, and decisions; preserve a timeline and decision log.
3. Prefer small, authorized, reversible containment over simultaneous unrelated changes.
4. Treat recovery as a verified customer journey, including cohorts and delayed work, not a green component metric.
5. Communicate current evidence, uncertainty, mitigation, and next update time without fictional ETAs.
6. Turn the review into measurable, owned control improvements and check whether they work.

## Practice without a production system

Use the existing [incident command primer](/career/incident-command-primer) with a local scripted fixture. Before touching any environment, write a one-page incident record containing impact, facts, three ranked hypotheses, one reversible containment, explicit abort/rollback conditions, two stakeholder updates, and user-journey recovery checks. Then compare it to the scenario answers above. This is guided practice, not independent mastery or production evidence.

The sentence worth remembering is: **“During an incident, I make uncertainty visible, authorize the safest useful next move, and close only when the user outcome—not merely a component—has recovered.”**
