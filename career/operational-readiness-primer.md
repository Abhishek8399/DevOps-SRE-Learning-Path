# Operational readiness: earn the right to own a service

Readiness is not a meeting where people say “looks good.” It is evidence that a service can be operated by someone who did not build it, under ordinary load and predictable failure, with a safe path to recover.

```text
user journey -> SLO/alerts -> dependencies -> capacity
       |             |             |             |
       v             v             v             v
  test evidence -> runbook -> failure drills -> change/recovery proof
                         |
                         v
                 owner accepts residual risk
```

## Start with the user and the owner

Name the critical user journeys, their acceptable latency/correctness, the service owner, escalation path, and hours of support. An internal component can be healthy while the user journey is broken. “The dashboard is green” is not an ownership model.

## The readiness record

Capture these decisions in a reviewable record:

1. **Contract:** API behavior, compatibility, data classification, and supported clients.
2. **Reliability:** SLIs, SLOs, error-budget policy, alert thresholds, and dependency assumptions.
3. **Operations:** deploy, rollback, feature-flag, maintenance, and emergency procedures.
4. **Observability:** logs, metrics, traces, correlation IDs, dashboards, and cardinality/cost limits.
5. **Capacity:** workload model, saturation signals, quotas, headroom, scaling limits, and the next bottleneck.
6. **Resilience:** timeout/retry policy, degradation, backup/restore, regional or zone failure behavior, and tested RTO/RPO.
7. **Security:** identity, least privilege, secret rotation, encryption, audit events, threat-model decisions, and data retention.
8. **Economics:** unit cost, noisy-neighbor controls, budget owner, and what is intentionally not optimized.
9. **People:** on-call ownership, handoff quality, training, runbook freshness, and decision authority during an incident.

Every item needs an evidence pointer or an explicit gap with an owner and due date. A blank field is a risk, not a pass.

## Readiness gates

Use gates that can stop launch:

```text
critical journey unmeasured      -> no safe SLO decision
restore untested                 -> recovery claim is unproven
alert has no owner/action         -> page is noise
capacity limit is unknown         -> scaling is guesswork
rollback is incompatible          -> design roll-forward/reconciliation
secret or data boundary unclear   -> security review required
```

Separate “must be true before launch” from “improvement after launch.” This prevents a long checklist from hiding one fatal unknown.

## Safe local exercise

Choose a small local service from this repository or a simple HTTP process. Write a one-page readiness record with a user journey, one SLI/SLO, dependency map, alert action, capacity assumption, rollback command, backup/restore boundary, threat decision, cost proxy, and owner. Break one assumption deliberately—stop a dependency or exhaust a bounded resource—then update the record with observed evidence and the recovery result. Mark simulations honestly when the real runtime is unavailable.

## Triage after launch

1. Identify the affected journey and whether the signal is user-impacting.
2. Check recent change, dependency health, saturation, and cohort/region scope.
3. Use the runbook to contain first; do not improvise risky changes under pressure.
4. If the runbook is wrong or missing, record that as an operational defect after recovery.
5. Update the readiness record, alert, test, or architecture—not only the incident ticket.

## Interview defense

**Question:** “What does production readiness mean to you?”

**Strong answer:** “A named owner can show the user journey, SLO and alert action, dependency and capacity assumptions, safe change and rollback path, observability, security controls, backup/restore evidence, and on-call runbook. Unknowns are explicit risks with owners; a green deployment is not readiness.”

**Question:** “What if the team cannot test disaster recovery before launch?”

**Strong answer:** “I separate the claim from the aspiration: state the unproven RTO/RPO, reduce exposure or scope, add compensating controls and an owner/date, and avoid promising recovery that has not been demonstrated. Then I run the smallest safe restore test.”

## Teach-back checkpoint

Review a service as if you were the incoming on-call engineer. Identify the critical journey, SLO, top dependency, first alert action, bottleneck, rollback limitation, recovery evidence, security boundary, cost owner, and one launch-blocking gap. Explain why each answer is operationally useful.
