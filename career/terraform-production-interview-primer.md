# Terraform and OpenTofu production interview: treat the plan as a change proposal, not permission

Infrastructure-as-code interviews are testing whether you can protect real state while making change repeatable. The important distinction is simple:

```text
configuration describes intent
state binds addresses to real objects
provider reads and changes remote systems
plan predicts one proposed transition
apply performs a time-bound operation against changing reality
```

Never collapse those into “the code is truth.” Configuration can be wrong, state can be stale, the provider can observe an unexpected remote object, and a plan becomes less trustworthy after the environment changes.

## Scenario 1: a small diff wants to replace a database

**Question:** A pull request changes one Terraform variable. The plan shows replacement of a stateful database. The author says the variable is harmless. What do you do?

**Strong answer:** I stop before apply and name the blast radius. A small configuration diff can change an immutable provider argument, resource address, module identity, provider version behavior or state interpretation. I inspect the plan’s exact address, destroy/create actions, forcing attribute, lifecycle rules, provider/version lock, state binding and remote object. I compare the desired change with the service’s data ownership, backup/restore evidence, RPO/RTO and migration plan. I do not use `-auto-approve` or assume a backup exists because a plan is green. If replacement is unintended, I correct the configuration, identity or migration path and rerun a targeted plan. If it is intended, I require explicit ownership, maintenance/customer-impact plan, tested restore or replication path, rollback decision and post-change verification.

**Weak answer:** "Terraform knows the dependency graph, so apply it." The graph orders declared actions; it does not authorize data loss or prove business recovery.

**Senior follow-up:** What proves a backup is useful? A recent isolated restore that meets the declared data and time objectives. An object called “backup” proves neither recoverability nor application consistency.

## Scenario 2: the state lock will not release

**Question:** A pipeline failed and the remote state backend is locked. Engineers ask you to force-unlock it so delivery can continue.

**Strong answer:** A lock protects the binding between configuration addresses and remote objects from concurrent writers. I first identify the lock record, backend, workspace, operation identity, start time and whether the original operation is still running or has a delayed retry. I inspect pipeline/job status and remote activity before changing the lock. Force-unlocking a live operation can allow two applies to race and leave partial, un-reconciled state. If the owner is conclusively absent and the runbook authorizes it, I record the evidence, use the exact lock identity with the approved backend procedure, refresh/plan again, and obtain review before a new apply. Prevention is short-lived authenticated runners, cancellation/reconciliation behavior, clear backend ownership, lock monitoring and no shared human credentials.

**Weak answer:** "Locks are annoying; remove it and rerun." A lock is often the only visible warning that another writer may exist.

**Senior follow-up:** Why plan again after unlock? Remote reality may have changed during the failed/unknown operation. The earlier plan was a snapshot, not a permanent contract.

## Scenario 3: console change and state drift

**Question:** Someone changed a security setting in a cloud console during an incident. The next plan wants to undo it. What is the safe response?

**Strong answer:** I separate the emergency action from the long-term desired state. I establish who changed what, why, which users were protected, whether the action is still required, and the actual remote configuration. Then I determine whether the configuration should adopt, replace or explicitly retire that change. A blind apply can reintroduce customer harm or remove a necessary containment control. I update code and policy through review if the emergency state becomes desired, or stage a bounded rollback if it should end. I document the incident decision and verify the real protected operation, not merely a zero-diff plan. Prevention is break-glass process, audit evidence, incident-to-IaC reconciliation and ownership for emergency changes.

**Weak answer:** "Terraform drift is always bad; make state match the code immediately." Drift is evidence of a change boundary. It may be unauthorized, or it may be a legitimate emergency action that code has not caught up with.

**Senior follow-up:** What does `terraform refresh` or a refresh-capable plan change? It updates Terraform’s observed model according to provider reads; it does not decide whether the remote behavior is safe or desired.

## Scenario 4: module refactor changes addresses

**Question:** A team reorganizes a module and the plan shows deletes and creates for objects that should remain. How do you preserve identity?

**Strong answer:** I treat resource address continuity as a migration, not formatting. I inspect the old and new addresses, state bindings, stable `for_each` keys versus positional `count` indexes, module boundaries and provider IDs. If the remote object should remain the same, I use the tool’s reviewed move/refactor mechanism or a carefully tested state migration according to the supported version and runbook; I do not apply a destroy/create plan and hope the provider preserves data. I validate in an isolated/provider-safe environment where possible, preserve a state backup, review the plan for move-only behavior, and run a final plan after the refactor. Prevention is stable natural keys, explicit module contracts, refactor tests and code review that treats addresses as operational API.

**Weak answer:** "The object name is unchanged, so Terraform will know." Terraform tracks addresses and provider IDs, not human intent inferred from a similar name.

**Senior follow-up:** Why is `count` fragile for long-lived objects? Inserting or removing an earlier list element can shift indexes and make existing object addresses appear to belong to different instances.

## Scenario 5: secrets appear in a plan or state artifact

**Question:** A reviewer discovers a credential in a plan file and remote state. What is your incident response?

**Strong answer:** I assume the secret may have been exposed to everyone and every system allowed to read those artifacts. I restrict access and preserve the audit trail, identify the secret type, state backend, plan/artifact retention, logs, caches and downstream copies, then rotate/revoke through the owning identity system. Marking a variable `sensitive` changes display behavior; it does not guarantee the value is absent from state or every artifact. I redesign the interface to pass references, use an approved secret manager or short-lived identity where appropriate, reduce state/artifact access by least privilege, and test redaction/retention boundaries. I coordinate notification and compliance decisions with security rather than deleting evidence blindly.

**Weak answer:** "Add `sensitive = true` and the secret is fixed." Masking is not lifecycle, rotation, access control or historical cleanup.

**Senior follow-up:** What is the proof limit of a state scan? It proves what the scanner could read and recognize at that time; it does not prove absence from historical backups, logs, developer machines or third-party systems.

## Scenario 6: an apply fails halfway through

**Question:** A production apply fails after some resources changed. How do you recover without making it worse?

**Strong answer:** I stop automatic retries and establish the exact operation, workspace, source revision, plan identity, provider errors, already-completed actions and remote object state. “Failed apply” is not a single state: some changes may have succeeded, some may be pending, and state may or may not reflect the provider result. I use provider/backend evidence and a fresh reviewed plan to reconcile, rather than manually editing state or issuing broad destroy commands. I choose between completing, rolling back, or containing based on user impact, reversibility, data/identity risk and ownership. Recovery includes the real user operation and a clean subsequent plan under the approved workflow. Prevention is smaller change sets, dependency-aware rollout, timeouts/retries with reconciliation, protected state, observability and an explicit partial-failure runbook.

**Weak answer:** "Run apply again until it passes." Retrying can repeat side effects, overlap a delayed operation, or convert a partial change into a wider incident.

**Senior follow-up:** When is manual state editing acceptable? Only as an exceptional, reviewed recovery procedure with an exact backup, authoritative remote evidence, tool/version understanding, approval and post-edit plan; it is never the first response to uncertainty.

## A safe interview command sequence

| Question you are answering | Example evidence | Why it comes before apply |
|---|---|---|
| Is the configuration well-formed? | `terraform fmt -check`, `terraform validate` | catches local syntax/structural issues, not remote correctness |
| What action is proposed? | reviewed `terraform plan` with exact workspace and variables | makes creates/updates/replacements/deletes visible |
| Is the plan still current? | fresh plan after relevant remote/pipeline change | plans age as remote state and credentials change |
| Who owns state and the lock? | backend/workspace/lock/job identity | prevents concurrent or wrong-environment writes |
| What changed for users? | scoped application, security and data verification | infrastructure success is not user success |

## Practice: defend the stop decision

Take each scenario and practise one sentence that begins, “I would stop here because…”. Then state:

1. the object or user operation at risk;
2. the next evidence and its proof limit;
3. the smallest reversible or approved action;
4. the recovery verification; and
5. the prevention change in code, policy, process or test.

If you can explain why not to apply, unlock, destroy or edit state yet, you are showing the judgment production teams actually need. The goal is safe progress, not being the fastest person to type `apply`.
