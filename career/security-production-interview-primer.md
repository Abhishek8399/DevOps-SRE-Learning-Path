# Security and DevSecOps production interview: reduce unsafe authority while preserving evidence

Security questions often tempt people into dramatic answers: delete logs, rotate everything, turn off a control, or grant admin access. Strong answers first name the asset, actor, authority path, scope, evidence and recovery boundary.

```text
actor -> identity -> authorization -> action -> asset -> audit/evidence -> containment -> recovery
  |         |             |            |         |             |                |              |
trust     proof       least scope    effect   CIA + audit   retention         revoke        verify
```

Contain the smallest unsafe path first. Preserve the evidence needed to understand whether confidentiality, integrity, availability or attribution changed.

## Scenario 1: a production token appears in logs

**Question:** A log query shows a bearer token and customer identifier. The team wants to delete the index immediately. What do you do?

**Strong answer:** I treat it as a potential security incident, not a cleanup task. I restrict access to the affected log path while preserving audit evidence, identify the token issuer/scope/lifetime, the data population, producers, destinations, retention/backups/exports and evidence of use. I revoke or rotate the credential through the owning authority, stop further emission with a tested redaction/schema/configuration correction, and verify source, transport, index, export and backup boundaries. I coordinate disclosure/legal/compliance decisions with the appropriate authority; deleting one index can destroy evidence while leaving copies elsewhere. Recovery means the credential is unusable, the producer no longer leaks, authorized consumers work with the replacement and audit records support the investigation. Prevention is secret-safe logging design, review/tests, least retention/access and detector ownership.

**Weak answer:** "Delete the log line." The value may already exist in aggregates, exports, backups, caches or a recipient’s tools.

**Senior follow-up:** What does a successful rotation not prove? That no one used the old token before revocation, that all historical copies are gone, or that another credential/path was not exposed.

## Scenario 2: a scanner reports a critical CVE in a deployed image

**Question:** A vulnerability scanner marks a library critical. Do you stop all deployments and patch immediately?

**Strong answer:** I establish deployed artifact digest, runtime exposure, reachable code path, affected environment/tenant, exploit preconditions, compensating controls, fix availability, owner and customer risk. Severity is useful prioritization evidence; it is not a complete exploitability decision. I follow the defined policy: block or gate new promotion where required, contain exposed workloads if necessary, rebuild from trusted pinned inputs, test the patch and verify the running digest—not only the registry tag. If immediate remediation is not possible, I document a time-bounded approved exception with compensating controls and recheck trigger. I do not dismiss a finding because it is hard, nor create an avoidable outage with an untested upgrade. Prevention is inventory/provenance, timely dependency updates, exposure-aware policy and measurable exception lifecycle.

**Weak answer:** "Critical means restart every container." Restarting does not remove the vulnerable bytes or prove an exploit path is closed.

**Senior follow-up:** What does an SBOM help answer? Which declared components are associated with an artifact. It does not by itself prove the artifact is running, the component is exploitable, or the build/registry trust path was safe.

## Scenario 3: a signed artifact is suspected of compromise

**Question:** An image signature verifies, but threat intelligence says its build pipeline may have been compromised. What does the signature prove and what do you do?

**Strong answer:** A signature proves that a trusted verification policy accepted a statement from a signer over specific bytes; it does not prove the signer, builder, source or dependencies were uncompromised. I identify artifact digest, signer identity/key policy, build provenance, source revision, runner/workspace, dependency resolution, affected deployments and time window. I contain promotion of suspect artifacts and restrict the compromised identity/path while retaining forensic evidence. I rotate/revoke signing or CI credentials according to the incident plan, rebuild from independently trusted inputs in an isolated path, verify provenance and runtime behavior, and reconcile deployment state. Prevention includes isolated untrusted builds, protected signing, immutable identities, provenance retention, least-privilege runners and an exercised compromise response.

**Weak answer:** "The signature is valid, so it is safe." Cryptographic validity depends on what authority and process the policy actually trusts.

**Senior follow-up:** Why separate build and deploy identities? A compromise of one boundary should not automatically allow both artifact creation and production promotion.

## Scenario 4: a team asks for an exception to a security policy

**Question:** A workload cannot start under a non-root/read-only policy, and a deadline is near. The team asks for privileged mode.

**Strong answer:** I identify the exact failure, workload behavior, user impact, required capability/path and whether the policy is blocking a legitimate supported use or exposing an unsafe design. Privileged mode is a broad security boundary change, not a generic compatibility switch. I investigate narrower fixes: writable empty directory, explicit filesystem path, dropped/added minimal capability, ownership/security-context correction, image change or a bounded approved exception. If an exception is necessary, it has scope, owner, rationale, compensating controls, audit, expiry, review and removal plan. I verify the workload and that unrelated forbidden behavior remains blocked. Prevention is a documented golden path, actionable policy messages, compatibility tests and product ownership of the platform control.

**Weak answer:** "Turn policy off until after the release." Temporary exceptions without authority/expiry tend to become standing production exposure.

**Senior follow-up:** What makes an exception reviewable? Exact identity/resource/namespace/environment, threat/risk, compensating controls, approver, start/expiry, evidence, review date and closure condition.

## Scenario 5: a workload has excessive runtime authority

**Question:** A container runs as root, has broad capabilities and mounts a sensitive host path. It works today. How do you improve it without breaking production?

**Strong answer:** I map why each privilege exists, which process uses it, which host/resource boundary it crosses, and how compromise would expand blast radius. I compare the running spec, image, service identity, mounts, capabilities, network access, resources and audit trails with the declared contract. I reduce authority incrementally in a disposable/canary boundary: non-root identity, read-only filesystem with explicit writable paths, capability drop/add only when proven, host-path removal, scoped service account/RBAC, network segmentation and resource limits. I test allow and deny behavior plus rollback. I do not claim a non-root flag alone is hardening; the whole authority path matters. Prevention is admission/policy-as-code, image/build standards, continuous inventory and owned exception expiry.

**Weak answer:** "Root is fine inside a container." Container isolation is not an absolute security boundary, especially with host mounts, privileges, kernel exposure or broad credentials.

**Senior follow-up:** Why can a read-only filesystem improve security but hurt reliability? Applications may require safe writable state for caches, temp files or certificates; an untested policy can cause startup failure/restart loops. Design the approved writable boundary.

## Scenario 6: incident responder needs emergency access

**Question:** A production outage requires emergency access, but the normal identity path is unavailable. How do you avoid turning reliability recovery into an access incident?

**Strong answer:** I use the approved break-glass path, not an improvised shared credential. I establish incident authority, exact target/scope, reason, time-bound access, required actions, audit channel, peer observation where policy requires, rollback and expiry. I grant the smallest capability for the stated recovery and avoid copying secrets into tickets/chat. I record what was done, verify the user outcome and system state, revoke emergency access, reconcile any manual change into declared configuration and review the access/control failure afterward. Break-glass must be tested before a crisis; a permanent administrator account is not a contingency plan.

**Weak answer:** "Give everyone admin until it is fixed." That destroys attribution and expands the compromise/accident boundary during the most stressful period.

**Senior follow-up:** What should you communicate during the incident? Customer impact, access decision authority, scope, known/unknown security implications, the next verification point and when temporary access will expire—without exposing secret material.

## Security answer checklist

| Start with | Then decide | Prove before closing |
|---|---|---|
| asset, actor, identity, scope, time | smallest containment/revoke/policy change | unsafe authority/path is closed and intended use still works |
| evidence retention and audit | rotation/patch/rebuild/exception path | source, transport, storage, runtime and backup boundaries as relevant |
| confidentiality, integrity, availability, attribution | named authority and expiry | recovery plus prevention ownership |

## Practice transfer

Re-answer one scenario in a CI runner, Kubernetes workload, cloud IAM role and local Linux service context. Keep the logic the same: who is the actor, what authority is excessive, which evidence is retained, what is the smallest safe containment, and what proves recovery? Product syntax changes; trust boundaries do not.
