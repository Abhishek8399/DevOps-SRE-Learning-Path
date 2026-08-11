# Security foundations: reduce the blast radius of trust

Security engineering begins with a promise: what must remain confidential, correct, available, and attributable? Then map assets, actors, boundaries, threats, controls, and recovery evidence.

```text
actor -> identity -> authorization -> action -> resource -> audit/detection -> response
   |        |             |             |          |             |              |
 trust    proof         scope        effect     data         signal         revoke
```

## Identity is not authorization

Authentication proves a subject or workload controls a credential. Authorization decides whether that subject may perform this action on this resource in this tenant and context. Validate server-side, deny by default, and check object ownership—not just route access.

## Secrets and keys

Keep secrets out of source, images, logs, traces, crash dumps, backups, and command history. Define storage, access, rotation, revocation, expiry, and recovery. Encryption at rest or in transit does not solve excessive access or an unprotected key.

## Threats and residual risk

Consider injection, confused deputy, privilege escalation, supply-chain compromise, data leakage, denial of service, and insider misuse. Record control strength and residual risk, including what the control cannot detect. A scanner finding without affected asset, exploitability, owner, and deadline is not a treatment plan.

## Runtime hardening and detection

Use least privilege, non-root execution, restricted capabilities, network segmentation, minimal images, validated inputs, and bounded resources. Audit authorization decisions and high-risk changes; alert on meaningful user or security outcomes, not every log line.

## Safe local exercise

Threat-model a disposable local API. Identify assets and trust boundaries, write two abuse cases, add input validation and an ownership check to a fixture, and test allowed/denied cases. Redact synthetic secrets and delete all fixture data afterward.

## Triage sequence

1. Confirm affected asset, actor, scope, time, and evidence quality.
2. Revoke or contain the smallest unsafe identity/path while preserving audit evidence.
3. Determine whether confidentiality, integrity, availability, or attribution changed.
4. Validate controls at source, transport, storage, export, and backup boundaries.
5. Rotate/recover, notify the right authority, and verify recurrence prevention.

## Interview defense

**Question:** “A service account can read every tenant. What do you do?”

**Strong answer:** “Treat it as excessive authorization. Identify the affected assets and usage, restrict scope with a reversible policy change, preserve audit evidence, review secret exposure, test tenant isolation, and add a prevention check so broad grants fail review.”

**Question:** “A vulnerability scanner reports a critical CVE. What is next?”

**Strong answer:** “Confirm artifact and runtime identity, exploitability and exposure, compensating controls, owner, and deadline. Patch or mitigate through a tested path, verify the running state, and document residual risk rather than blindly applying a disruptive update.”

## Teach-back checkpoint

Threat-model one local service. Name asset, actor, boundary, threat, authorization check, secret lifecycle, detection signal, containment action, and evidence proving the control works.
