# LES-0091 draft status

Status: **source-locked and implementation-verified quarantined capstone; assessment, manuscript, review and publication pending**

This quarantined directory reserves `LES-0091` / `V11-L04` / `CAP-004` for the private-cloud reliability capstone at `/book/capstones/private-cloud-reliability-capstone`, volume `11-capstones`, order 4 and domain `capstone-engineering`.

The capstone connects a protected VM request to identity, Placement, Nova cells, KVM/libvirt, Neutron/OVN, Ceph, hardware operations, capacity, upgrades, failure recovery and user-path validation. Its local implementation is an explicitly non-production Python simulator: it does not invoke OpenStack, libvirt, Ceph, OVN, a BMC, SSH, a subprocess, a socket or any cloud API.

Twenty primary or official records (`REF-1160` through `REF-1179`) pass the direct reference schema, exact range and LES-0091 ownership checks. They cover KVM, libvirt, QEMU, Nova, Placement, Neutron/OVN, Ceph, OpenStack security/image boundaries and Redfish.

The strict fixture models three distinct rack/power/network domains, three controller quorum members, three compute hosts with explicit CPU/machine compatibility, three gateway candidates, six Ceph OSDs, size/min_size and rack-aware protection, quota/reserve policy and two workload contracts. A deterministic baseline places three replicas, preserves checkout rack anti-affinity, retains 77.3% compute reserve and 55% storage reserve, validates controller/storage/network state and reports both synthetic user operations as passing.

Seventeen contract and adversarial tests pass. They cover JSON/input strictness, failure-domain uniqueness, MTU, storage policy, image trust, quota, deterministic placement, all scenario outcomes, generation conflict, migration compatibility, recovery promotion, prohibited infrastructure/process clients, endpoint/credential-shaped fields, unknown runtime files and descriptor tampering.

The full verifier runs twelve decisions: compute-host loss, rack loss, stale Placement generation, gateway failure, MTU mismatch, OSD loss, near-full storage, incompatible migration, unsupported upgrade jump, restore divergence, ambiguous BMC task and tenant policy violation. It records four `degraded`, seven `blocked` and one `unavailable` outcome, generates the design dossier and returns to an absent runtime. Expected refusal is treated as evidence rather than hidden as success.

Three assessments (`ASM-0256` through `ASM-0258`), the exact eighteen-section manuscript, formal multidisciplinary review and reviewer-owned transfer remain pending.

No real infrastructure, credential, tenant, customer data, production action, accepted capacity/availability/recovery objective, learner result or mastery is claimed.
