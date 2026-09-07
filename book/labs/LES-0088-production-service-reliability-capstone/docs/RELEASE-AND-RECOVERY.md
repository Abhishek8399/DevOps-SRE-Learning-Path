# Release, rollback and recovery plan

## Candidate pipeline

```text
source revision
  -> compile and seven focused tests
  -> guarded local verifier
  -> Dockerfile checks and Compose render
  -> pinned image build
  -> non-root/read-only container smoke
  -> TLS/proxy/Prometheus topology smoke
  -> digest + evidence receipt
  -> reviewer approval
  -> bounded release
  -> user-SLI observation
  -> promote or rollback
```

The nested GitHub workflow is a reviewable template because this lesson remains quarantined; GitHub executes workflows only from the repository-root `.github/workflows` directory. Moving it there is a publication decision, not a formatting change.

## Pre-release gate

- Source revision, image digest and configuration version are immutable and linked.
- Tests and verifier pass from absent state.
- Schema compatibility is stated in both directions.
- A current verified backup exists and has been restored separately.
- Expected user-SLI change, blast radius, owner, approver, observation window and abort threshold are written.
- Rollback artifact is available and does not require a destructive data downgrade.
- New alerts and dashboards are queryable before traffic changes.

## Release sequence

1. Freeze the candidate digest and evidence receipt.
2. Verify current version, readiness, error budget and change overlap.
3. Start the candidate without replacing the known-good state.
4. Exercise liveness, readiness, one read, one idempotent write and telemetry.
5. Send only the bounded local test traffic.
6. Compare availability, correctness and latency with the baseline.
7. Promote only after the observation window; otherwise stop and roll back.
8. Preserve the decision, evidence, exact versions and remaining unknowns.

## Rollback and restore are different

Rollback changes executable/configuration state to a compatible earlier version. Restore changes data state to a verified snapshot and can discard later writes. Never use restore merely because an application release is unhealthy. If restore is required, stop writers, preserve current evidence, calculate data loss against the RPO, restore to a separate target, reconcile critical records, authorize cutover and observe.

## Recovery objectives

This fixture measures only local exercise time. It has no accepted business RPO or RTO. A measured five-second local restore cannot be advertised as a production five-second RTO because dataset size, detection, approvals, transfer, dependencies, reconciliation and traffic cutover are absent.
