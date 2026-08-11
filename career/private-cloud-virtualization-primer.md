# Private cloud and virtualization: operate the layers beneath the workload

Virtualization changes the failure surface; it does not remove it. A VM can look healthy while the host is oversubscribed, the storage path is stalled, the virtual switch is dropping packets, or the control plane cannot place or recover it.

```text
application -> guest OS -> virtual NIC/disk -> hypervisor -> host
      |             |             |              |           |
    SLO         processes       queues/IOPS     vCPU/RAM    NUMA/storage
                                      |
                          fabric/control plane -> peer hosts
```

## The boundaries that matter

* **CPU:** vCPU scheduling, steal time, ready time, pinning, and overcommit. More vCPUs can increase wait and NUMA penalties.
* **Memory:** guest allocation, ballooning, swapping, huge pages, NUMA locality, and host reclamation. Guest “free” memory does not prove host headroom.
* **Storage:** virtual queue, datastore, network path, device latency, IOPS and throughput limits, cache, replication, and failure domain. Capacity and latency are separate budgets.
* **Network:** guest interface, virtual switch/bridge, overlay, physical NIC, MTU, ACL/security policy, and return path. A VM route table cannot explain a dropped packet in the fabric.
* **Control plane:** inventory, scheduling, images, identity, certificates, quotas, lifecycle, and reconciliation. A running VM is not proof that management is healthy.

## Overcommit is a policy, not free capacity

Overcommit can improve utilization when workload peaks differ, but it converts spare capacity into queueing and contention. Define admission limits, reservations, priority, noisy-neighbor protection, evacuation headroom, and the signal that stops placement. HA needs surviving capacity; a cluster at 95% full may be “healthy” until one host fails.

## Safe local exercise

Without touching a production hypervisor, model two hosts and three VMs in a table. Record vCPU, memory, storage latency/IOPS, network rate, failure-domain placement, and recovery capacity. Remove one host and calculate which workloads can restart within the stated SLO. Then use a local process/container to simulate CPU contention or a bounded I/O queue; label the result as a model, not hypervisor telemetry.

If a disposable KVM/libvirt environment is available, inspect only read-only inventory, guest state, vCPU/memory allocation, storage pools, bridge/overlay paths, and host pressure before attempting a controlled migration. Keep a reset plan and never use an unknown libvirt URI.

## Triage sequence

1. Identify the user symptom, guest, host, cluster, storage object, network segment, and recent lifecycle change.
2. Compare guest metrics with host scheduler/NUMA, memory pressure, storage latency/queue, and network drop evidence.
3. Determine whether the control plane, data plane, or guest is failing; do not reboot blindly.
4. Protect surviving capacity and state: stop placement, evacuate only within headroom, and preserve evidence.
5. Recover or migrate using the approved path, then verify the user journey and rebalance noisy neighbors.

## Interview defense

**Question:** “Why is a VM slow when its guest CPU is low?”

**Strong answer:** “Guest CPU measures work inside the VM, not time waiting for a vCPU, memory locality, storage completion, or network queue. I compare guest wait/steal with host scheduler and NUMA signals, storage latency/queue, and dependency behavior before changing allocation.”

**Question:** “How do you design HA for a private cloud?”

**Strong answer:** “Define the user SLO and failure domains, reserve surviving CPU/memory/storage/network capacity, spread workloads and control-plane components, verify fencing and split-brain behavior, protect shared storage and identity, test evacuation/restore, and measure recovery—not just host count.”

**Question:** “When is live migration unsafe?”

**Strong answer:** “When compatibility, storage/network state, workload pause tolerance, encryption, device passthrough, or destination headroom is uncertain. I preflight versions and dependencies, canary a low-risk guest, set an abort threshold, and retain a recovery path.”

## Teach-back checkpoint

Explain a slow-VM incident across guest, hypervisor, host, storage, network, and control-plane layers. Name one observation per layer, the first safe containment action, the capacity needed for host loss, and the evidence that would prove recovery.
