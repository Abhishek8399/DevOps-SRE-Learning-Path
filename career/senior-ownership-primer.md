# Senior ownership: make good decisions legible

Senior engineering is not knowing every command. It is turning ambiguous impact into an explicit decision, aligning people around evidence, and leaving the system safer and easier to operate.

```text
outcome -> options -> constraints -> decision -> execution -> evidence -> learning
   |         |           |             |           |            |
 customer  trade-offs  risk/cost    owner      checkpoint    next action
```

## Start with outcome and authority

Name the user or business outcome, the decision owner, the time horizon, and what authority is missing. Separate facts, assumptions, risks, and unknowns. A senior engineer can say “we do not know yet” while still proposing the next safe evidence-gathering move.

## Make trade-offs visible

Write the options, constraints, failure modes, security and cost effects, reversibility, and capacity impact. An ADR is useful when it records why an option was chosen, what would change the decision, and how to detect that condition. Consensus is not the same as clarity; name a decider.

## Communicate at the listener’s altitude

Executives need impact, duration, customer exposure, decision, and next update. Engineers need boundaries, evidence, hypotheses, commands, and rollback. Partners need ownership, dependency, and ask. The facts must remain consistent even when the vocabulary changes.

## Protect sustainable execution

Track operational toil, interrupt load, on-call health, skill concentration, and unfinished risk. A roadmap that exceeds available capacity is not ambitious; it is a reliability defect. Sequence work by user impact, dependency, reversibility, and evidence—not by the loudest request.

## Safe local exercise

Take a fictional migration with a fixed deadline and three options. Write a one-page decision record with outcome, constraints, alternatives, risks, owner, capacity, rollback, and review trigger. Draft an executive update and an engineering update that preserve the same facts. No employer or confidential material is needed.

## Interview defense

**Question:** “Tell me about a difficult reliability decision.”

**Strong answer:** “I start with user impact and authority, state what was known and unknown, compare options and failure modes, choose a reversible checkpointed action, communicate at the right altitude, and show the evidence and learning afterward. I do not claim ownership for work I did not perform.”

**Question:** “How do you handle disagreement with a strong engineer?”

**Strong answer:** “I make the decision criteria explicit, ask what evidence would change each view, test the smallest useful assumption, and name a decider and review point. I preserve dissent in the decision record without making disagreement personal.”

## Teach-back checkpoint

Write one decision record for a reliability-versus-delivery trade-off. Include the customer outcome, authority, two alternatives, risks, capacity, rollback, communication plan, and evidence that would cause revision.
