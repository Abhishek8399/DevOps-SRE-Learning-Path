# ADR-001: use a small Git-bound reconciler for the local proof

Status: accepted for the teaching fixture; not a production controller recommendation.

## Context

CAP-002 must demonstrate declarative, versioned, automatically pulled and reconciled state without requiring a cloud account or external Git credential. Installing Flux would provide representative controllers but add several images, CRDs, credentials or local Git serving, and a larger failure surface before the learner understands the mechanism.

## Decision

Use `ops/reconcile.py`. It resolves a requested revision to a full commit, validates one allowlisted repository-relative YAML path, reads it through `git show`, performs server-side diff/apply as `atlas-reconciler` and writes an atomic receipt containing commit, source path, desired SHA and drift observation. Repeated executions model continuous observation. `verify-drift.sh` changes replicas through another field manager and proves the committed owner restores them.

## Consequences

The learner sees the essential desired/actual loop, immutable source identity and field ownership without provider credentials. The implementation is auditable and covered by bounded tests. It does not watch a remote repository, verify commit signatures, run in-cluster, maintain a work queue, expose controller metrics, implement health inventory/prune/dependency waves or achieve high availability. It is therefore “OpenGitOps-shaped evidence,” not Flux or Argo CD equivalence.

## Alternatives

- CI runs `kubectl apply`: simpler, but pushes only when CI runs and does not continuously correct drift.
- Flux: preferred representative next step after a local Git source, controller images and credential model are pinned.
- Argo CD: adds rich health/UI/application semantics but more components and product-specific surface.
- Custom production controller: rejected; building a reliable controller is not justified for this service contract.

Production adoption should use a maintained controller, least-privilege identity, protected source, signature/provenance policy, controller SLOs, notification, tested prune and disaster recovery.
