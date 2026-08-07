# Payments API local runbook

Owner: payments-team  
Lifecycle: experimental teaching fixture  
User operation: GET `http://127.0.0.1:18080/version`  
Desired state: `desired/team-a/payments-api.yaml` from the reconciled Git commit

## Health hierarchy

`/livez` means the Python listener can respond. `/readyz` means this stateless fixture declares itself ready. Deployment Available means Kubernetes observed enough ready replicas. The NodePort `/version` probe crosses the host mapping, Service, EndpointSlice, Pod network and handler. None of these checks proves a real payment transaction; the name is illustrative only.

## Diagnose

1. Confirm the intended Git commit and `.state/reconcile-receipt.json`.
2. Run `kubectl --kubeconfig .state/kubeconfig get deploy,rs,pod,svc,endpointslice -n team-a -o wide`.
3. Read namespace events in creation order.
4. If Pods are Pending, inspect scheduler reason, quota and image presence.
5. If Pods are not Ready, inspect probe status and `kubectl logs` for the exact Pod.
6. If endpoints exist but the host probe fails, test the Service from a same-namespace debug client before changing selectors.
7. If a bad image rollout is active, use `kubectl rollout history`, validate compatibility and run the bounded rollback procedure.

## Recovery

For committed-state drift, run the reconciler. For a failed stateless image candidate, `kubectl rollout undo deployment/payments-api -n team-a` is valid only while the earlier ReplicaSet and configuration remain compatible. After either action, wait for rollout and verify `/version`. Namespace reconstruction restores declarations, not data.

Escalate when API access is lost, policy blocks the known-good revision, node capacity cannot run two replicas, the user probe fails after bounded endpoint convergence, or rollback cannot restore the prior image. Preserve events and managed-field ownership before deleting Pods.
