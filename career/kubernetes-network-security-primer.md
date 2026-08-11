# Kubernetes networking, storage, and security: name every boundary

Kubernetes combines network identity, service discovery, persistent state, and API authorization. A healthy Pod is not proof that its Service, storage, or tenant policy is correct.

```text
client -> Ingress/Gateway -> Service -> Pod -> PVC/CSI -> storage
   |           |              |         |        |           |
 TLS/policy  route         selector   readiness  identity   durability
```

## Services and ingress

A Service selects endpoints by labels; verify selectors, readiness, endpoints, DNS, and policy separately. Ingress/Gateway adds routing, TLS, host/path rules, and another ownership boundary. NetworkPolicy controls allowed traffic only when a compatible dataplane enforces it.

## Storage and data safety

PVC/PV/CSI abstractions describe claims, bindings, access modes, and lifecycle; they do not automatically prove backup, durability, or application consistency. Understand reclaim policy, mount identity, writer ownership, snapshots, and restore before deleting or migrating storage.

## RBAC, Secrets, and tenant isolation

RBAC governs Kubernetes API actions; service accounts provide workload identity; Secrets are data with access and rotation requirements. Namespace boundaries, quotas, Pod Security, network policy, admission, and node isolation must work together. A namespace is not a complete security boundary by itself.

## Safe local exercise

If a local cluster is available, create a disposable namespace with a Deployment, Service, PVC, ServiceAccount, Role, and NetworkPolicy. Inspect selectors, endpoints, mounted identity, RBAC permissions, and events; test an allowed and denied fixture path, then delete the namespace. If runtime is unavailable, inspect manifests with schema/tool explanations and do not claim enforcement.

## Triage sequence

1. Confirm context/namespace, source/destination, labels, identity, and user symptom.
2. Walk route, Service selector/endpoints, DNS, policy, Pod readiness, and application listener.
3. For data, inspect PVC/PV binding, mount, access mode, writer, events, and backup contract.
4. For access, inspect RBAC/ServiceAccount, Secret scope, admission, and security context.
5. Verify user outcome, data integrity, and tenant isolation after the smallest fix.

## Interview defense

**Question:** “The Pod is Ready but the Service returns 503.”

**Strong answer:** “I check selector/endpoints, readiness semantics, port/listener, DNS, network policy, ingress route, and dependency behavior. Readiness is one boundary, not proof of end-to-end service.”

**Question:** “Can you delete and recreate a PVC to fix a stuck workload?”

**Strong answer:** “Not without ownership, reclaim, backup, writer fencing, and data-loss evidence. I inspect binding/events and recovery first; deletion is a scoped destructive action only with explicit approval and rollback.”

## Teach-back checkpoint

Draw a request and a write path through Kubernetes. State selector, identity, policy, storage claim, writer, backup, tenant boundary, and evidence proving the user operation is safe.
