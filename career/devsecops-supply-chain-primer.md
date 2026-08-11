# DevSecOps and Software Supply-Chain Primer

Security is a property of the delivery path, not a scan added at the end. This primer is study material; a green local check does not prove a secure organization, artifact, cluster, or production release.

## The chain to defend

```text
source -> dependency resolution -> build -> artifact -> registry -> deploy -> runtime -> evidence
   |             |                  |         |          |          |         |
 access       lock/provenance    isolation  SBOM/sign  policy    identity   detection
```

Every arrow is a trust transition. Ask who can change the input, how the output is identified, what evidence is retained, and what happens when a check or dependency becomes unavailable.

## Threat model before tools

Name the assets: source, credentials, build workers, artifacts, deployment identity, runtime data, and audit records. Name actors: malicious contributor, compromised dependency, untrusted pull request, stolen token, registry attacker, or compromised runner. Then define controls and residual risk. A tool list without an asset and threat does not explain what is protected.

## Reproducible and attributable builds

Pin dependencies and record the lockfile, compiler/toolchain, base image digest, build configuration, source revision, and builder identity. Isolate untrusted builds from signing credentials and production networks. Make artifacts immutable or at least content-addressable where the registry supports it.

Reproducibility means the same declared inputs produce equivalent output under a defined process. A matching digest proves equal bytes; it does not prove that the source was reviewed, the builder was trustworthy, or the dependency was safe.

## SBOMs, provenance, and signatures

- An **SBOM** inventories components and versions in an artifact.
- **Provenance** records how and from which inputs an artifact was produced.
- A **signature** binds an identity to bytes or a statement, subject to key custody and verification policy.

Use them together. An SBOM without a trustworthy artifact binding can describe the wrong bytes; a signature without an understandable identity policy can validate an untrusted signer; provenance without retention and query access cannot support incident response.

Verification should answer: what bytes are deployed, who built them, which source and dependencies entered, which policy approved them, and can the decision be reconstructed later?

## Scanning and policy

Run dependency, secret, license, image, configuration, and infrastructure scans at useful boundaries. Classify results by exploitability, reachability, runtime exposure, fix availability, and business impact. Define expiration and ownership for exceptions. A vulnerability count alone creates noise; a policy should state what blocks release, what is deferred, who accepts risk, and when it is rechecked.

Secret scanning detects patterns, not every secret. A “no findings” result does not prove historical logs, binary blobs, encrypted configuration, or external systems are clean. If a credential may have leaked, revoke or rotate it and investigate use; deleting the matching line is not remediation.

## Runtime and Kubernetes controls

Use least-privilege workload identities, non-root where compatible, read-only filesystems where practical, dropped capabilities, network policy, resource limits, admission policy, signed-image verification, and audit logging. Separate build, deploy, and runtime identities. Treat cluster-admin access as an exceptional break-glass path with review and expiry.

Controls can conflict: a read-only filesystem may break an application that writes a cache; a strict network policy may block telemetry; an admission rule may prevent emergency recovery. Design the failure and exception path before enforcing the policy, and test both deny and approved cases.

## Incident response for the supply chain

When a dependency or artifact is compromised:

1. identify affected versions and deployed digests;
2. preserve evidence and restrict the compromised identity or source;
3. revoke or rotate credentials and signing material as appropriate;
4. block new promotion without destroying useful forensic records;
5. identify reachable workloads and customer impact;
6. rebuild from trusted inputs and verify provenance and runtime behavior;
7. document detection gaps, ownership, and a tested prevention control.

Do not trust a clean rebuild until the builder, dependency source, signing path, and deployment identity are independently checked.

## Interview prompts

- Design a release pipeline that proves which source and dependencies produced a deployed image.
- A signed image contains a critical vulnerable library. What does the signature prove, and what does it not prove?
- A secret scanner reports zero findings after a token appears in logs. What is your next response?
- How would you introduce admission policy without making incident recovery impossible?

Strong answers name trust transitions, identity, evidence, policy, exception handling, blast radius, rollback, and proof limits. “Add a scanner” is not a supply-chain strategy.
