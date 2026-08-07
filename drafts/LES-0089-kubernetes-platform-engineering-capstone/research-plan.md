# CAP-002 source and proof plan

Reviewed: 2026-08-07

## Questions the sources must settle

1. Which kind binary and node-image digest form a published pair?
2. Which statements are Kubernetes API contracts, and which are local-lab choices?
3. What do namespaces, RBAC, quotas, Pod Security, NetworkPolicy and admission each enforce—and not enforce?
4. What evidence distinguishes declared, admitted, scheduled, ready, reachable and user-correct state?
5. When is a workflow GitOps rather than “kubectl from CI”?
6. How should a platform expose a golden path without hiding ownership, policy errors or escape hatches?
7. What can a disposable cluster reconstruction prove about upgrades, rollback and disaster recovery?

## Source policy

Use Kubernetes, kind, OpenGitOps, Flux, Backstage and other project-owner documentation. Record version/date and review horizon. Paraphrase mechanisms. Do not treat product guidance as independent assurance, a local run as production capacity, policy objects as runtime enforcement without negative tests, or repository history as continuous reconciliation without an agent.

## Implementation evidence ladder

1. Static schema, shell, Python and YAML checks.
2. Render golden-path intent without a cluster.
3. Create a loopback-only digest-pinned kind cluster.
4. Apply platform controls and prove allowed plus denied requests.
5. Reconcile Git-owned desired state and prove drift correction.
6. Exercise rollout, rollback, tenant pressure and disaster reconstruction.
7. Prove exact project-scoped cleanup.

Every stage stops on the first failed invariant and preserves evidence. No production, cloud, credential, privileged host mutation or broad Docker cleanup is authorized.
