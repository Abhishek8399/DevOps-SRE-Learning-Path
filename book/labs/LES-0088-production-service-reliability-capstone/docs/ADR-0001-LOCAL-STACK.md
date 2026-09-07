# ADR-0001: Dependency-free local baseline with staged production boundaries

Status: accepted for quarantined teaching fixture; not a production technology approval.

## Context

The capstone must be reproducible on Ubuntu 24.04 without cloud credentials, yet expose real HTTP, concurrency, transactions, retry semantics, telemetry, recovery and delivery decisions. A large framework stack would hide mechanisms and make the first run depend on package networks. A toy memory-only service would avoid the important state and recovery problems.

## Decision

Use Python 3.12 standard-library HTTP handling and SQLite for the baseline. Add NGINX TLS and Prometheus as optional pinned Compose stages. Keep durable and telemetry state in separate volumes. Validate the actual listener, transaction, backup and fault paths. Label the Python server as non-production everywhere.

## Consequences

Benefits: fresh Ubuntu runs need no Python package install; code paths are inspectable; SQLite supplies real transactions, locks, WAL and online backup; container and observability concerns remain separable.

Costs: the server lacks production hardening and ecosystem middleware; SQLite is a single-file local state model; metrics reset with the process; Compose is not an orchestrator; the optional stack still downloads images. Migration to a production framework or network database would require compatibility, load, security and recovery evidence rather than a filename change.

## Alternatives rejected

- Memory-only state: rejected because it cannot teach durable idempotency, backup or restore.
- Immediate Kubernetes deployment: rejected because it adds scheduler and cluster variables before service invariants exist.
- Full application framework first: deferred because package resolution would obscure the dependency-free baseline; appropriate in a later representative transfer.
- Embedded “production-ready” claim: rejected because no local fixture can establish organization-specific production suitability.
