# SRE operating loop: make reliability work sustainable

SRE is a way of managing risk with software, evidence, and shared ownership. On-call is a feedback channel, not a substitute for engineering capacity or product decisions.

```text
user SLO -> signal/page -> incident -> recovery -> learning -> toil removal -> better SLO evidence
    |          |            |            |             |             |
  outcome    action       owner       verify        action        capacity
```

## Toil and work taxonomy

Toil is repetitive, manual, automatable work that scales with the service and provides little lasting value. Separate it from feature work, incident response, reliability engineering, and planned maintenance. Measure frequency, duration, interruption, and risk; then remove the source rather than celebrating a faster manual step.

## On-call sustainability

Define service ownership, escalation, runbooks, paging hours, backup coverage, handoffs, and learning time. A page must be actionable, urgent, and tied to user impact or imminent risk. Track noise, repeats, unowned alerts, time-to-acknowledge, recovery, and after-hours load.

## Capacity and error budgets

Reliability work competes for finite engineering capacity. Use SLO/error-budget policy to make delivery risk visible, but allow emergency fixes and unrelated safe work with explicit review. A team that is always paged cannot safely absorb more commitments.

## Readiness and shared ownership

A service is ready when ownership, dependencies, SLOs, dashboards, alerts, runbooks, rollback, capacity, security, backup, and recovery are understood and tested. The application team owns behavior; platform and dependency teams own their contracts. Shared ownership means clear boundaries, not everyone owns everything.

## Safe local exercise

Review a synthetic alert list. Classify each as page, ticket, dashboard, or delete; estimate toil and user impact; rewrite one noisy alert with an SLO and runbook; and record the automation that removes its source. Use no real on-call data.

## Triage sequence

1. Confirm user impact, SLO, owner, alert freshness, and escalation path.
2. Restore service with the incident process; do not optimize the alert mid-outage unless unsafe.
3. Measure recurrence, toil, responder load, and missing evidence.
4. Assign a source-removal action with owner, capacity, acceptance, and review date.
5. Verify the alert and service behavior after the change.

## Interview defense

**Question:** “How do you reduce toil?”

**Strong answer:** “I measure recurring work and its risk, classify it, identify the source, automate or redesign the path with guardrails, and verify that volume and incidents decrease. I do not hide toil by moving it to another team.”

**Question:** “What makes a good page?”

**Strong answer:** “It represents user impact or imminent SLO risk, is urgent and actionable, has an owner and runbook, includes enough evidence to choose the first safe move, and is reviewed for noise and recurrence.”

## Teach-back checkpoint

Design an on-call contract for one service. State SLO, page condition, owner/escalation, runbook, backup coverage, toil measure, capacity policy, and evidence proving the loop is sustainable.
