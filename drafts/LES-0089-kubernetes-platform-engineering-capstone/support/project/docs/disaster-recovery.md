# Disaster recovery boundary

Git and backup solve different losses. Git can reconstruct declared objects. It cannot reconstruct database rows, dynamically allocated credentials, uncommitted controller state or external resources. An etcd snapshot can reconstruct Kubernetes API state, but it does not guarantee application-volume consistency or external-system reconciliation.

The verified exercise deletes `team-a`, waits for finalization, reapplies tenant controls, reconciles the committed workload, waits for rollout and retries the actual user path within a fixed window. Its receipt states `data_restore=not-exercised`. This proves namespaced desired-state reconstruction on one disposable cluster.

## Production recovery plan

Classify state by owner and recovery mechanism:

- Git: cluster add-ons, policy and workload declarations.
- etcd snapshot: API objects that cannot be recreated safely from another source.
- volume/database backup: application durable data with application-consistent procedure.
- external provider inventory: load balancers, DNS, keys and identities requiring reconciliation.
- artifact registry: immutable images, charts, SBOMs and signatures.

For each, define RPO, RTO, retention, encryption, access, geographic/failure-domain separation, integrity verification, restore order and decision authority. Test restore into an isolated target. Validate hashes and engine integrity, then business invariants and cross-system references. Cut over only after data-loss acceptance and rollback/abort criteria are explicit.

## Typical restore order

1. Recover identity, keys and network prerequisites.
2. Recover control-plane/API state or bootstrap a clean control plane.
3. Install compatible CNI, CSI, DNS, policy and observability components.
4. Restore data services and volumes without starting uncontrolled writers.
5. Reconcile workload declarations at a known revision.
6. Validate ownership, policy, endpoints and representative user operations.
7. Shift traffic gradually and observe.

Never overwrite live state merely because a Deployment is unhealthy. Rollback changes executable/configuration state; restore changes data and may discard valid writes.
