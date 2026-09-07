# Architecture and responsibility map

## Three control loops, not one magic platform

The developer loop starts with a `ServiceRequest`. `platformctl.py` rejects unknown fields, unsafe namespaces, floating images and invalid bounds before generating anything. Its output is reviewable Kubernetes YAML and a catalog record. This loop improves developer experience; it does not authorize deployment.

The platform loop starts at the Kubernetes API. Authentication identifies the caller. RBAC decides whether that identity may perform a verb on a resource in a scope. Mutating admission and built-in defaults may change the object. Pod Security, the CEL validating policy and ResourceQuota can reject it. Only an accepted object reaches storage. Controllers then compare stored desired state with actual resources. The scheduler chooses a node, and the kubelet asks the container runtime to start the image.

The service loop begins only after a Pod starts. Readiness controls whether Service endpoints should receive traffic. The NodePort maps host loopback port 18080 to the cluster. A successful `/version` request crosses more of the path than a Running Pod, but it does not test every business operation.

```text
Git commit                     Kubernetes control plane                 nodes
desired YAML
    |
    v
reconciler -> API request -> authn -> RBAC -> admission -> etcd
                                                   |          |
                                                   |          v
                                                   +--- controllers -> scheduler
                                                                      |
                                                                      v
                                                         kubelet -> containerd -> Pod
                                                                              |
client 127.0.0.1:18080 <- kind port map <- NodePort <- Service <- EndpointSlice+
```

## Failure ownership

- Request rejected by `platformctl`: platform API or caller input. Kubernetes has no evidence because it was never contacted.
- HTTP 403 from the API: inspect identity and RBAC before editing workload YAML.
- HTTP 422 with the owner message: CEL policy rejected a permitted request.
- Pod Security violation: namespace posture rejected the Pod security shape.
- Exceeded quota: the request may be individually safe but exceeds aggregate tenant policy.
- Pending Pod: inspect scheduler events, requests, taints, topology and image availability.
- Running but not Ready: inspect probe ownership and application dependency evidence.
- Ready endpoints but failed user request: trace Service selection, port mapping, network path and handler behavior.
- Object keeps returning after deletion: find the owning controller or reconciler before deleting it again.

## Local topology limits

Three kind nodes are three privileged Docker containers sharing one laptop kernel, power supply, disk, Docker daemon and failure domain. Two workers let us observe placement and rolling behavior, not availability-zone survival. The single control-plane node is not highly available. kind’s default CNI provides Pod networking but this project does not prove NetworkPolicy enforcement. The NetworkPolicy object is design intent until a compatible enforcing CNI and negative packet test are added.

The project kubeconfig is deliberately outside the user’s default kubeconfig. Every reusable script binds it explicitly. This prevents a stale cloud context from receiving local lab commands and makes the target part of the evidence.
