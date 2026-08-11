# Terraform: make infrastructure changes reviewable

Terraform is a change-planning system, not a magic “create cloud” button. Configuration, provider behavior, state, and real infrastructure must agree before a mutation is safe.

```text
configuration + provider + state -> plan -> human review -> apply -> refreshed state
       |                           |                         |
    desired                    predicted diff             observed reality
```

## The state boundary

State maps configuration addresses to real objects and records identity, dependencies, and provider data. Losing, exposing, or concurrently writing state can cause duplicate creation, accidental replacement, or secret leakage. State locking prevents concurrent writers; it does not make an unsafe plan safe.

## Plan before apply

Use `terraform fmt`, `terraform validate`, and a saved plan before any apply-like action. Read every create, update, destroy, replacement, unknown value, and provider warning. A replacement of a database, node pool, or certificate is a risk decision—not a line-count decision. Stop when ownership, backup, maintenance window, or rollback is unclear.

## Modules and identity

A module is an interface: typed inputs, outputs, validation, ownership, and stable resource addresses. Refactoring a resource address can look like destroy/create unless `moved` history or an explicit import preserves identity. Treat module changes as API changes and test the plan in a disposable fixture.

## Drift and recovery

Drift means reality differs from the declared contract or recorded state. Refresh evidence first; do not automatically overwrite a manually applied security or availability fix. Decide whether to adopt, revert, or quarantine the drift, then document the authority. Back up state, restrict access, and test restore/convergence before a real recovery event.

## Safe local exercise

Use provider-free Terraform or OpenTofu configuration that creates only local data objects. Format, validate, generate a saved plan, inspect JSON plan changes, rename a resource with a `moved` block, and prove the plan preserves identity. Corrupt only a copied state fixture, verify the tool refuses it, restore the copy, and clean up. Never point the exercise at a real backend or cloud account.

## Triage sequence

1. Identify the workspace, state authority, lock owner, provider versions, and exact target.
2. Run formatting and validation before reading the plan.
3. Classify each change: create, update, replace, destroy, unknown, or drift.
4. Check dependencies, data protection, permissions, cost, and rollback evidence.
5. Apply only from the reviewed saved plan in the approved scope.
6. Reconcile outputs and state, then retain the plan and result for review.

## Interview defense

**Question:** “Terraform wants to replace a database after a harmless refactor. What do you do?”

**Strong answer:** “I stop. I inspect the address, state identity, provider replacement reason, lifecycle settings, and module change. I compare a saved plan against a disposable copy, preserve identity with moved/import history when correct, and require backup, owner, maintenance, and rollback evidence before any apply.”

**Question:** “Why is remote state not just a file share?”

**Strong answer:** “It is an authority boundary with locking, access control, encryption, versioning, recovery, and audit requirements. A shared location without those controls can corrupt identity or expose sensitive values.”

## Teach-back checkpoint

Explain the difference between configuration, state, plan, and reality. Then classify a hypothetical replacement of a stateful service: what evidence do you need before approving, and what would make you refuse the change?
