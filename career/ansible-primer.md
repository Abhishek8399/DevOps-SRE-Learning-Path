# Ansible: converge configuration without hiding change

Ansible describes the state a host should have and executes tasks through an inventory, connection, variables, modules, handlers, and a playbook. Its strength is readable convergence; its danger is making broad mutations look harmless.

```text
inventory -> playbook -> module/check -> host state -> changed/ok/failed
     |          |             |             |
  scope      intent       prediction     evidence
```

## Idempotency and fixed points

An idempotent task reaches the desired state once and reports no further change when run again. `state: present`, managed templates, explicit ownership, and handlers help; shell commands with hidden side effects do not. Run in check mode, inspect the predicted diff, then run again and prove the second pass converges.

## Scope before mutation

Inventory is a safety boundary. Confirm group membership, host identity, environment, privilege mode, and excluded hosts before a play. A typo in `hosts:` or an unbounded pattern can turn a lab command into a fleet incident. Use a disposable localhost inventory for learning.

## Variables and secrets

Variable precedence can surprise reviewers. Keep defaults, environment overrides, and secrets explicit. Do not place passwords in plaintext vars, logs, gathered facts, or command output. Use a secret manager or encrypted value in a real environment, and test that redaction survives failure paths.

## Handlers and rollout safety

Handlers run after notifying tasks and are useful for controlled service reloads. They can also delay a necessary action or restart too many hosts. Batch changes, use serial limits, health gates, and a rollback path. Configuration management cannot repair an incompatible application or data migration by itself.

## Safe local exercise

Create a disposable localhost inventory and playbook that manages one directory, one text file, and its mode. Run syntax check, check mode, normal mode, and a second normal run. Capture `changed` versus `ok`, alter the fixture manually to simulate drift, converge it, and remove only the fixture path. Do not use `become`, SSH, or production inventory.

## Triage sequence

1. Confirm inventory, host facts, play limit, user, and privilege boundary.
2. Run syntax/check mode and inspect the predicted changes.
3. Identify the first failed task, module inputs, permissions, and prior changed tasks.
4. Stop broad rollout; preserve output and affected-host scope.
5. Repair or roll back one bounded change, then prove convergence and service health.

## Interview defense

**Question:** “Why did an Ansible play report changed every run?”

**Strong answer:** “I inspect the task’s desired-state semantics, shell command, template whitespace, timestamps, generated content, and check-mode prediction. I replace hidden side effects with a module or explicit change condition and prove a second run is `ok`.”

**Question:** “Would you use Ansible or an immutable image?”

**Strong answer:** “It depends on lifecycle and drift tolerance. Immutable images reduce per-host variance and simplify rollback; Ansible is useful for controlled convergence and existing fleets. I choose based on update frequency, blast radius, secrets, auditability, and recovery time.”

## Teach-back checkpoint

Explain inventory as a safety boundary, idempotency as a fixed point, and why check mode is prediction rather than proof. Then design a two-host rolling change with a health gate and rollback condition.
