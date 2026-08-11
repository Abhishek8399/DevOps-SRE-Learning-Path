# Identity and secrets operations: give workloads authority without handing them the keys

Identity answers **who is making this request**. Authorization answers **what that identity may do**. A secret is only one possible credential; it is not an access-control design.

```text
human / workload
      |
  authenticate -> identity -> policy -> short-lived credential -> target service
      |              |          |               |                    |
   proof of       subject    least privilege   rotation           audit decision
   identity
```

## Start with the authority path

For every sensitive operation, name the caller, the identity issuer, credential lifetime, target resource, authorization policy, audit record, and revocation path. If you cannot draw that path, you cannot safely rotate or investigate access.

Prefer workload identity and short-lived credentials over static keys. Static keys accumulate in files, CI logs, laptops, images, shell history, and backups. Encryption helps protect a stored secret but does not decide whether a caller should receive it.

## Rotation is a service change

Safe rotation needs overlap: create a new credential, distribute it through the approved channel, verify each consumer uses it, revoke the old credential, and retain audit evidence. Rotating a key without identifying every consumer is a planned outage disguised as security work.

```text
inventory -> issue new -> distribute -> observe use -> revoke old -> verify access + audit
```

Emergency access must be narrow, time-bound, approved, logged, and tested. A permanent administrator exception is not break-glass; it is an undocumented standing privilege.

## Safe local exercise

Create two local service accounts or files with deliberately different permissions. Use a non-secret placeholder value and a short expiry timestamp. Write a rotation runbook: inventory consumers, create replacement, verify one consumer at a time, revoke the original, and prove denied access after revocation. Never paste real employer, cloud, Git, registry, SSH, or API credentials into a lab, note, or exported evidence file.

## Triage sequence

1. Identify the failed or suspicious operation, caller, target, time window, and exact authorization decision.
2. Separate authentication failure, expired credential, policy denial, network/TLS failure, and application-level permission error.
3. Inspect only approved audit metadata; do not print or copy secret values into tickets or chat.
4. Contain leaked or overprivileged credentials by revoking/limiting them according to the incident process.
5. Rotate affected credentials, verify every consumer, review access paths, and document the root mechanism.

## Interview defense

**Question:** “How do you rotate production credentials safely?”

**Strong answer:** “I inventory every consumer and authority path, issue a replacement with least privilege and a short lifetime, distribute it through the approved mechanism, observe successful use, revoke the old credential, and verify audit and user outcomes. I avoid logging secret material and keep a rollback/recovery plan for consumers that cannot overlap credentials.”

**Question:** “Why is a Kubernetes Secret not automatically secure?”

**Strong answer:** “It is an object carrying sensitive data, not an authorization model. I still need RBAC, workload identity, encryption and key management, namespace/tenant boundaries, audit, rotation, and protection from logs, images, mounts, and broad read access.”

## Teach-back checkpoint

Design access for a local CI job to deploy one workload. Name the issuer, subject, policy, credential lifetime, target scope, audit source, rotation path, break-glass authority, and evidence that revocation actually worked.
