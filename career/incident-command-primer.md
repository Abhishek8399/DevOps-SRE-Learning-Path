# Incident command: create clarity while the system is changing

An incident is a time-boxed coordination problem under uncertainty. The incident commander does not need to know every technical detail; they make ownership, priorities, evidence, and decisions visible.

```text
signal -> declare -> stabilize -> recover -> verify -> learn
            |          |           |          |         |
         roles      scope      rollback    user test  actions
```

## First five minutes

State the user impact, start time, current confidence, and next update time. Assign an incident commander, technical lead, communications lead, and scribe. Open one timeline and one decision log. Prefer a reversible containment that protects the most important journey while preserving evidence.

## Facts, hypotheses, decisions

Label each statement. **Fact:** checkout 5xx rose from 1% to 18% after 14:05 UTC. **Hypothesis:** a dependency connection pool is exhausted. **Decision:** pause the optional enrichment path while the technical lead checks pool waiters. This prevents a plausible story from becoming an unsafe command.

## Restore before perfect diagnosis

Rollback, traffic shift, feature reduction, rate limiting, or dependency isolation may restore service before root cause is certain. Record why the action is safe, its stop condition, expected evidence, and rollback. Do not delete logs, restart every component, or apply several unrelated changes at once.

## Handoffs and escalation

A handoff includes impact, timeline, current state, actions already taken, hypotheses with evidence, risks, owners, and the next decision. Escalate when blast radius, authority, customer communication, safety, or time-to-recovery exceeds the current team’s boundary.

## Post-incident learning

A post-incident review reconstructs system time and knowledge time: what happened, what was visible then, what decisions were reasonable with that evidence, and which controls failed. Avoid blame and avoid vague actions. Each action needs an owner, due date, measurable acceptance, and a follow-up check for effectiveness.

## Safe local exercise

Use a scripted local service that returns success, latency, and error fixtures. Run a ten-minute game day with one commander, one investigator, one communicator, and one scribe. Inject one known failure, issue a reversible containment, publish two updates, hand off once, and verify the user path. Do not touch host services or production data.

## Triage sequence

1. Declare only when impact and ownership are clear enough to coordinate.
2. Protect the user journey and stop amplification.
3. Preserve logs, IDs, timelines, and command output.
4. Test the smallest hypothesis that can distinguish competing causes.
5. Verify recovery from the user boundary and monitor for recurrence.
6. Convert learning into accepted, measurable actions.

## Interview defense

**Question:** “What does an incident commander do?”

**Strong answer:** “They establish impact and priority, assign roles, control the decision cadence, protect responders from duplicate work, authorize reversible containment, communicate uncertainty honestly, and verify recovery. They do not become the sole debugger.”

**Question:** “How do you write a useful postmortem?”

**Strong answer:** “Reconstruct facts and available knowledge over time, distinguish causes from contributing conditions and detection gaps, explain why actions made sense then, and assign measurable prevention and detection work with owners and effectiveness checks.”

## Teach-back checkpoint

Write a first update for a regional checkout failure, label three facts and two hypotheses, choose one reversible containment, and describe the evidence that would let you declare recovery.
