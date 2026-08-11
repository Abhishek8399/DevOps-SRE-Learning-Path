# Incident Communication Playbook

Technical recovery and communication are one job during an incident. A correct diagnosis that nobody can act on is operationally weak; a confident update without evidence creates risk. This playbook is a practice aid, not evidence of incident-command readiness.

## The first five minutes

Use this short sequence and say what is known versus suspected:

```text
IMPACT -> SCOPE -> OWNER -> NEXT EVIDENCE -> SAFE CONTAINMENT -> NEXT UPDATE
```

Example:

> Checkout failures are elevated for customers routed through region B since 09:20 UTC. We have confirmed the failed TLS handshake at the regional edge; application success metrics do not include these requests. The edge team owns certificate inspection, SRE is comparing the last-known-good chain, and product is preparing a status update. No certificate rollback has happened yet. We will update in ten minutes or sooner if customer impact changes.

The useful properties are precise time, user impact, boundary, evidence, owner, action status, and a promised next update. Avoid “we are looking into it” because it gives no decision-maker a way to help.

## Update templates

### Executive or customer-facing

> **Impact:** [user operation] is [failing/degraded] for [population/region] since [time].  
> **Current evidence:** [one confirmed fact], while [important limitation].  
> **Action:** We are [bounded containment] with [owner].  
> **Risk:** [what could worsen or what is not yet known].  
> **Next update:** [time or trigger].

Translate mechanisms into consequence. Say “some customers cannot complete checkout,” not “the Envoy listener has an unexpected chain fingerprint,” unless the audience needs the latter to make a decision.

### Engineering channel

> **Hypothesis:** [mechanism] explains [observed symptom].  
> **Evidence for:** [query/log/metric/packet and timestamp].  
> **Evidence against or missing:** [specific proof limit].  
> **Next test:** [smallest safe observation or reversible change].  
> **Rollback/stop condition:** [explicit boundary].

This prevents a noisy channel from turning an untested theory into “the root cause.”

### Handoff

A handoff is complete only when the next engineer can act without reconstructing the incident:

- customer impact, start time, and current trend;
- incident commander, technical lead, communications owner, and decision authority;
- confirmed facts and ranked hypotheses, each with evidence and proof limits;
- commands or changes already made, including result and rollback state;
- next test, stop condition, and the next update deadline;
- links to the timeline, dashboard, logs, and approved change record.

The receiving engineer repeats the impact and next action back. That read-back catches misunderstandings faster than another paragraph.

## Communication failure modes

| Failure | Why it hurts | Better move |
|---|---|---|
| “Root cause identified” after one correlated graph | Correlation can be coincidence | Say “leading hypothesis” and name the disproof test |
| Every team posts raw logs | Signal and sensitive data are mixed | One evidence owner publishes redacted, decision-oriented facts |
| Silence while engineers investigate | Stakeholders invent their own status | Send a short update with the next deadline even when unknowns remain |
| “Rollback complete” | A control-plane acknowledgement may precede user recovery | Verify the user journey and state the observed result |
| Handoff by chat mention only | Ownership and stop conditions disappear | Use a structured handoff and read-back |
| Postmortem blames a person | It suppresses useful evidence | Describe conditions, decisions, controls, and system incentives |

## Post-incident language

A useful post-incident record separates:

1. **What happened:** a timestamped system and customer narrative.
2. **What we knew then:** evidence available at each decision point.
3. **Why the decision was locally reasonable:** constraints, signals, and trade-offs.
4. **What mechanism failed:** causal chain, alternatives considered, and proof limits.
5. **What changes:** owner, due date, acceptance test, rollback, and effectiveness measure.

Avoid “human error” as a stopping point. If a person typed the wrong command, ask why the system allowed an ambiguous target, lacked a guard, or made the unsafe path easier than the safe path.

## Practice prompts

- Give a 60-second update when a regional SLO is burning but global availability is green.
- Handoff a retry storm to a new incident commander without calling retries the root cause.
- Explain to a product leader why a rollback acknowledgement is not recovery proof.
- Write a post-incident action that has an owner, test, deadline, and measurable reduction in recurrence risk.

Score yourself on impact clarity, evidence boundaries, ownership, safety, audience translation, and update discipline. A reviewer should score the spoken attempt; reading this page is not a score.
