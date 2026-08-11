# CI/CD and release engineering: make change boring

CI/CD is a controlled path from source change to a verified, reversible user outcome. A green pipeline is evidence about the checks it ran—not proof that production is safe.

```text
commit -> validate -> build -> test -> artifact -> approve -> deploy -> verify -> promote/rollback
   |        |          |        |         |           |          |          |
 identity  policy    digest   evidence  immutable   authority   health     SLI
```

## Separate build from release

Build once and promote the same immutable artifact through environments. Rebuilding per environment makes it difficult to know whether production tested the same bytes. Pin dependencies where practical, record source revision and tool versions, and publish checksums or digests.

## Pipeline boundaries

Runners need least privilege, isolated workspaces, bounded caches, and explicit artifact paths. Secrets should enter only the step that needs them, never be printed, embedded in artifacts, or exposed to untrusted pull-request code. Treat cache hits and downloaded tools as inputs that require integrity and ownership.

## Gates and approvals

Fast checks provide feedback; slower integration, security, migration, and reliability checks protect promotion. An approval is a decision with an owner and evidence, not a button that hides uncertainty. Define what blocks, what may be waived, who can waive it, and how the waiver expires.

## Deployment strategies

Rolling changes reduce capacity gradually; blue-green keeps two environments but needs traffic and data compatibility; canaries reduce blast radius but require representative traffic and a trustworthy SLI. Rollback is not guaranteed to undo schema or external side effects, so design forward-compatible migrations and reconciliation.

## Safe local exercise

Create a local pipeline script that validates a small project, builds a deterministic archive, writes a checksum and manifest, runs a test, and verifies the artifact before a simulated promotion. Force a test failure and a checksum mismatch; prove promotion stops. Use no credentials, external service, or production deployment.

## Triage sequence

1. Identify commit, runner, artifact digest, environment, and promotion authority.
2. Find the first failing or skipped gate; distinguish code, runner, dependency, secret, and environment failures.
3. Preserve logs and artifact metadata; do not rerun blindly if the result could differ.
4. Stop promotion or roll back only within the documented scope and compatibility contract.
5. Verify the user journey and release telemetry, then record the causal gap.

## Interview defense

**Question:** “Why did the pipeline pass but production fail?”

**Strong answer:** “I compare the tested artifact digest with the deployed one, then check environment parity, missing integration coverage, configuration, migrations, telemetry freshness, and rollout exposure. I contain through the release contract, verify the user SLI, and improve the earliest gate that could have detected the failure.”

**Question:** “When is rollback unsafe?”

**Strong answer:** “When the new version changes an irreversible schema, emits external side effects, or the previous version cannot read current data. I use compatibility windows, forward fixes, reconciliation, and a verified recovery path rather than assuming a binary rollback reverses state.”

## Teach-back checkpoint

Explain why build-once/promote-many reduces uncertainty. Design a canary gate with artifact identity, user SLI, abort threshold, owner, and rollback limitation.
