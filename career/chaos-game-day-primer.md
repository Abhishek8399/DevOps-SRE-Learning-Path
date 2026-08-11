# Chaos engineering: test a recovery claim safely

Chaos engineering is a controlled experiment: introduce a bounded failure, observe a defined steady state, and learn whether the system keeps its user contract and recovers.

```text
hypothesis -> scope/guard -> fault -> observe -> abort or continue -> recover -> learn
     |          |            |          |             |                |
  user SLO   authority     target     evidence      stop rule        proof
```

## Experiment before intervention

Write the steady-state user outcome, hypothesis, target identity, blast radius, duration, prerequisites, abort condition, independent observer, and recovery plan. “Break the cluster” is not a hypothesis. “One disposable worker loses network for 60 seconds while checkout success remains above its SLO and backlog drains within five minutes” is testable.

## Safety is independent

The person or automation applying the fault must not be the only stop mechanism. Use immutable target selectors, least privilege, time limits, kill switches, traffic caps, and a watcher that can abort. Never test on an ambiguous target, with production credentials, or without owner approval.

## Failure versus recovery

Creating a fault is not success. Capture user impact, saturation, alerts, fallback behavior, data integrity, and time to recovery. Restore the fixture, reconcile state, and prove the original journey. If recovery depends on an untested manual step, record that as a finding.

## Game-day roles

Assign a facilitator, experiment operator, observer, incident commander, communications lead, and safety authority. The game day should exercise coordination and decision-making, not just a command. Pause when evidence is ambiguous or the blast radius changes.

## Safe local exercise

Run a disposable local process with a health endpoint and a supervisor. Inject a bounded delay or terminate only the fixture process, using an independent timer and stop file. Observe health, latency, restart, and recovery; abort early once the defined user contract fails; clean up every fixture. Do not modify host services, firewall rules, cloud resources, or production data.

## Interview defense

**Question:** “What makes a chaos experiment safe?”

**Strong answer:** “A measurable hypothesis, immutable target, least privilege, bounded duration, independent abort, owner approval, observable user steady state, and a tested recovery path. I start in a disposable environment and expand only when evidence supports it.”

**Question:** “The experiment caused an outage. Was it still successful?”

**Strong answer:** “The result is a safety failure first, not a success to celebrate. I stop the fault, restore service, preserve evidence, notify the incident owner, and review why guardrails and detection failed before repeating any experiment.”

## Teach-back checkpoint

Design a game day for a slow dependency. State the user hypothesis, target, blast radius, independent abort, observer signals, recovery proof, and the exact condition that makes you stop.
