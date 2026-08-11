# Service discovery and meshes: separate reachability from trust

Service discovery answers where a service can be reached; a mesh may add traffic policy, identity, telemetry, and retries. Neither removes application ownership or makes every retry safe.

```text
caller -> resolver/registry -> endpoint -> proxy/sidecar -> service
   |           |                |             |              |
 identity    TTL/health       route        mTLS/policy     outcome
```

## Registration and health

Register only instances that can serve the intended traffic. Distinguish process alive, ready for traffic, dependency healthy, and draining. DNS/registry TTLs and caches create staleness; removal must tolerate propagation delay.

## Mesh boundaries

A sidecar or gateway can enforce mTLS, retries, timeouts, routing, and telemetry, but it adds CPU, memory, configuration, and another failure boundary. Define which layer owns policy, how identity maps to authorization, and what happens when the proxy or control plane is unavailable.

## Retries and traffic policy

Retries can amplify overload and duplicate effects. Use deadlines, bounded attempts, jitter, retry budgets, and method-aware safety. Canary or weighted routing needs a representative SLI and a clear rollback owner.

## Safe local exercise

Run two disposable local HTTP processes with a tiny file-backed registry. Register one as ready, remove it, observe TTL/stale behavior, and route to the other. Add a bounded retry client and demonstrate that a slow target does not create unbounded requests. Clean up fixtures.

## Triage sequence

1. Identify caller, name/registry, endpoint set, TTL, readiness, route, proxy, and identity.
2. Compare resolver/registry state with actual listener and application health.
3. Check policy/mTLS separately from reachability and endpoint selection.
4. Stop unsafe retries or drain unhealthy endpoints; preserve timing and IDs.
5. Verify the full user path and control-plane convergence.

## Interview defense

**Question:** “Service discovery returns a healthy endpoint but calls fail.”

**Strong answer:** “I compare registry freshness and readiness with listener, route, TLS identity, policy, proxy, and application evidence. Health registration is one boundary; I find the first divergent hop and account for TTL/cache staleness.”

**Question:** “Why not put retries in every sidecar?”

**Strong answer:** “Layered retries multiply traffic and can duplicate non-idempotent effects. I define one owner, propagate deadlines, bound attempts, use retry budgets, and verify the user SLO and dependency capacity.”

## Teach-back checkpoint

Draw discovery from caller to endpoint. State registration health, TTL, identity, policy, retry owner, stale behavior, and the evidence that proves a removed endpoint is no longer serving traffic.
