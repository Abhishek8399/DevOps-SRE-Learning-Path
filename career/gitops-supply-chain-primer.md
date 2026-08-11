# GitOps and supply-chain trust: reconcile only what you can verify

GitOps treats versioned desired state as an auditable input to a reconciler. Supply-chain security asks whether the source, build, artifact, and deploy decision are trustworthy enough for the requested environment.

```text
source -> build -> digest/SBOM/provenance -> policy -> registry -> reconciler -> runtime
   |        |             |                    |          |            |
 review   isolation    who/what/how          admit      immutable   drift/status
```

## Desired state is not authority by itself

A repository commit can be changed, a credential can be stolen, or a manifest can reference an untrusted image. Define who may approve, which branch or tag is authoritative, what signatures or provenance are required, and how revocation works. The reconciler should report drift and failure rather than silently “fixing” an ambiguous state.

## Provenance and identity

Bind the deployed digest to source revision, builder identity, dependency inputs, build configuration, and test evidence. An SBOM describes components; it does not prove they were built from reviewed source. A signature authenticates a signer; policy must still authorize that signer for this artifact and environment.

## Promotion and rollback

Promote the same immutable artifact through environments. Separate artifact admission from runtime health. A rollback changes desired version but may not undo schema changes or external side effects; preserve a forward recovery and reconciliation path.

## Safe local exercise

Create a local Git repository with a deployment manifest, a fake digest-bound artifact record, and a policy file requiring an owner, approved environment, and provenance field. Change the digest and provenance, run a dependency-free verifier, and prove admission fails. Restore the known record and verify deterministic acceptance. Do not contact a registry or cluster.

## Triage sequence

1. Identify commit, manifest, digest, signer, policy revision, reconciler, and runtime version.
2. Compare desired state, admitted state, and observed state.
3. Stop promotion on missing or ambiguous provenance; preserve evidence.
4. Revoke or quarantine compromised identities/artifacts and choose a scoped recovery.
5. Verify runtime health and audit trail, then repair the earliest trust gap.

## Interview defense

**Question:** “Why is a signed container not automatically safe?”

**Strong answer:** “The signature proves a key signed bytes. I still need to authorize that signer for the repository and environment, verify digest-bound provenance and vulnerability policy, inspect runtime identity, and retain revocation and recovery evidence.”

**Question:** “What does GitOps add beyond CI?”

**Strong answer:** “It makes desired runtime state versioned and continuously reconciled with visible drift and status. CI builds and verifies artifacts; GitOps controls deployment intent. Neither removes the need for runtime health, policy, and recovery design.”

## Teach-back checkpoint

Trace one artifact from commit to runtime. Name every trust transition, the evidence required at each gate, who owns the decision, and what happens when the artifact is revoked after deployment.
