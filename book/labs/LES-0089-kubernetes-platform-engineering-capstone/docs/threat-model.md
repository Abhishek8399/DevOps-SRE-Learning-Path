# Threat model

## Assets and trust boundaries

Assets are the Git desired-state history, generator code, kind and image artifacts, project kubeconfig, API authorization policy, admission controls, tenant resources, workload identity, catalog ownership and evidence receipts. Trust crosses developer input → generator, Git commit → reconciler, reconciler → API server, API server → nodes and loopback client → NodePort.

## Material threats and controls

- A malicious request tries another namespace or hidden field. The strict schema allowlists tenants and rejects unknown fields.
- A compromised developer identity reads secrets or changes another tenant. Namespace RBAC denies both tested operations. Namespace scope alone is not isolation.
- An unsafe workload requests privilege, writable root or omitted resources. Pod Security and CEL reject independent fixtures.
- A tenant consumes shared capacity. Quota bounds declared aggregate requests, but it cannot prevent every control-plane, network or storage denial-of-service path.
- A floating or substituted artifact runs. The node and base image use digests; the demo workload tag is loaded locally and tied to a build receipt, but it is not signed or admitted by digest.
- An attacker edits the working tree while claiming a reviewed revision. The reconciler resolves a commit and reads desired state with `git show`.
- A second field manager fights the reconciler. Managed-field conflict is made visible; force ownership is limited to generated fields in this disposable lab.
- Kubeconfig data leaks. State is gitignored, permissioned 0600 and deleted at cleanup. Scripts never print credential fields.
- A broad cleanup destroys unrelated work. Cleanup names one cluster, one state directory and one image tag, rejects a state symlink and retains shared caches.
- A policy object exists but is ineffective. Three negative server-side tests require the expected mechanism-specific rejection.

## Residual risk

The local admin kubeconfig has cluster-wide authority. Docker-backed kind nodes are privileged containers. The default CNI’s NetworkPolicy enforcement is not proven. No secret store, OIDC identity, audit-log pipeline, image signature, SBOM admission, vulnerability gate, runtime detection or production network boundary exists. The Python HTTP server is a teaching fixture. A compromised host or Docker daemon owns the entire lab.

Production promotion requires federated short-lived identity, least-privilege controller credentials, protected branches and review, signed provenance, secret delivery, audit retention, enforcing network policy, egress design, node hardening, policy exception governance, dependency update service, backup protection and an incident response exercise.
