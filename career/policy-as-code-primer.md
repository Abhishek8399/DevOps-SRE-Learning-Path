# Policy as code: turn safety intent into reviewable, reversible decisions

Policy is an engineering control only when it has a clear subject, input, decision, owner, exception path, test, rollout, and evidence. A rule that merely blocks a deployment without explaining why creates bypass pressure.

```text
request + identity + context -> policy bundle/version -> allow / deny / warn
       |                              |                    |
   schema/claims                 tests/review          reason/audit
                                      |
                             staged rollout -> observe -> revise
```

## Define the decision boundary

State what the policy can see and decide: image digest, source/provenance, namespace, identity, data classification, network path, resource request, environment, or change window. Keep policy separate from mechanism where possible; an admission rule should explain the invariant, while the platform enforces it.

Do not confuse authentication with authorization, validation with mutation, or a warning with a guarantee. A policy can be technically correct and still unsafe if its input is stale, its exception is permanent, or its enforcement point can be bypassed.

## Lifecycle and exceptions

Version policies and bundles, test representative allow/deny cases, review blast radius, stage from audit to warn to enforce, and keep an independent break-glass path with expiry and an audit owner. Every exception needs scope, reason, approver, expiration, and a removal plan. “Temporary” without a date is a hidden permanent bypass.

## Safe local exercise

Write a small JSON policy model for a workload: require a pinned image digest, non-root execution, resource requests, owner label, and approved environment. Create valid, invalid, and exception cases. Run the same cases before and after a policy change, record decision reasons, and verify that an expired exception is denied. This is a local decision model; do not claim OPA, Kyverno, Terraform Cloud, or Kubernetes admission behavior unless those runtimes are exercised.

## Triage sequence

1. Capture the exact request, identity, policy bundle/version, input source, and decision reason.
2. Check whether the decision is correct, stale, bypassed, or caused by a schema/default change.
3. Contain unsafe admission without disabling all policy; use the narrowest approved exception.
4. Preserve audit evidence, repair the rule/input/exception, and stage the change.
5. Re-evaluate affected resources and verify the user/service outcome after enforcement.

## Interview defense

**Question:** “How do you roll out a new admission policy safely?”

**Strong answer:** “Define the invariant and input contract, test allow/deny/exception cases, run audit or warn mode, measure would-block impact, review owners and blast radius, then enforce for a bounded scope with an expiring break-glass path. I version the bundle and preserve decision reasons so rollback is a policy change, not a blind disable.”

**Question:** “Why did a valid deployment get denied?”

**Strong answer:** “I inspect the exact input and policy version, identity/context, schema/defaults, stale cache, and exception status. I reproduce the decision, correct the contract or narrowly approve a time-bound exception, and do not turn off enforcement globally.”

## Teach-back checkpoint

Design a policy that protects a multi-tenant deployment. Name its input contract, invariant, enforcement point, rollout stages, decision reason, break-glass authority, expiry, test cases, and evidence that proves the policy is actually effective.
