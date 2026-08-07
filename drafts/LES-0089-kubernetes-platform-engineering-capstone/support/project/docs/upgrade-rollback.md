# Upgrade, migration and rollback strategy

## Workload change

The verified workload exercise changes the Deployment image to an unavailable version. Kubernetes creates a new ReplicaSet, cannot make the candidate ready, and keeps the previous replicas because `maxUnavailable: 0`. `rollout undo` restores the prior Pod template, rollout status succeeds and the loopback `/version` probe returns 1.0.0.

That proves one reversible image failure. It does not prove database-schema rollback, ConfigMap/Secret compatibility, CRD conversion, external API compatibility or traffic-shift safety. Stateful changes need expand/contract migration, backup, reconciliation and a roll-forward plan.

## Cluster change

kind documents a disposable lifecycle, not an in-place upgrade strategy. This project therefore pins kind v0.31.0 with Kubernetes 1.35.0 and teaches cluster replacement conceptually:

1. Inventory API versions, controllers, admission, CRDs, CSI/CNI and skew.
2. Read target release notes and removed/deprecated API evidence.
3. Render and server-validate every declaration against the target.
4. Create a separate candidate cluster with a nonconflicting name, ports and state.
5. Install pinned platform components in dependency order.
6. Reconcile a fixed Git revision and run policy, workload and user tests.
7. Restore and reconcile state according to its own RPO/RTO contract.
8. Shift bounded traffic with abort thresholds.
9. Observe before removing the old cluster.

The lab does not download a second Kubernetes version or claim an upgrade. A production kubeadm sequence has control-plane, kubelet and version-skew rules that cannot be replaced by deleting a kind cluster.

## Abort and rollback

Abort when APIs fail server validation, policy controllers are unhealthy, capacity cannot hold surge/failover, critical add-ons are incompatible, restore is unverified, user SLIs regress or rollback compatibility expires. Roll back traffic before destroying the candidate. If new writes use an incompatible data format, executable rollback may be unsafe; stop, reconcile state and choose a reviewed roll forward.

Keep version, source, image, configuration, schema, policy and backup identities in one release receipt. “Same YAML” is insufficient when controllers, defaults and APIs changed.
