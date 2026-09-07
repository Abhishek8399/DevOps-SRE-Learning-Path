# Golden path and developer contract

A golden path is the easiest supported route to a safe outcome, not a mandatory maze and not a claim that all services are identical. This capstone asks for name, tenant namespace, owner, versioned image, replicas, port, resource requests and limits, and local exposure. It generates the repetitive controls that teams should not rediscover: labels, non-root identity, no token mount, probes, requests/limits, rolling strategy, topology spread, Service, NetworkPolicy and disruption budget.

Unknown fields fail closed. That matters because silently ignoring `privileged: true` would teach the caller that a control exists while producing a different system. The contract also rejects `kube-system` and any tenant not in the allowlist, caps replicas at five, forbids `latest` and writes outputs atomically.

The platform returns errors at the earliest knowledgeable boundary:

- Contract syntax errors name the exact field before any cluster mutation.
- CEL messages say which workload requirement is missing.
- RBAC denies cross-tenant or secret access without pretending the resource is absent.
- Quota says the tenant budget, current use and requested excess.
- Rollout status reports whether accepted desired state became available.

An escape hatch requires an owner, reason, risk, expiry, narrower alternative and review. It must not be an undocumented manual edit to generated YAML. If the platform cannot support a legitimate need, that is product feedback: either extend the contract safely, publish a supported advanced path, or document why the platform will not own that workload.

## Change workflow

1. Edit the request, not the generated file.
2. Run `platformctl.py check` and unit tests.
3. Generate to temporary outputs and review the semantic diff.
4. Review ownership, capacity, security and rollout consequences.
5. Commit request, generator and generated state together.
6. Reconcile that full commit identity.
7. Validate rollout and a user operation.
8. Observe before promoting the pattern to more teams.

The catalog record is deliberately small. It provides ownership, lifecycle, system, runbook and SLO discovery. A real portal would add repository identity, APIs, dependencies, scorecards, audit, template versions and deprecation status. A portal is useful only when those records remain accurate; a beautiful stale catalog increases operational search time.
