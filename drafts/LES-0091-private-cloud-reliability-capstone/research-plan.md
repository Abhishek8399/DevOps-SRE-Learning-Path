# LES-0091 research and implementation plan

## Identity and purpose

- Lesson: `LES-0091`
- Public alias: `V11-L04`
- Curriculum: `CAP-004`
- Route: `/book/capstones/private-cloud-reliability-capstone`
- Prerequisite: `LES-0090`
- Assessments: reserve `ASM-0256` through `ASM-0258`
- References: reserve `REF-1160` through `REF-1179`

This specialist capstone must connect physical failure domains, KVM/libvirt compute, OpenStack control services, OVN networking, Ceph storage, capacity, security, upgrades and recovery into one operator-defensible private-cloud design. It is not permission to pretend that a laptop simulator is an OpenStack or Ceph deployment.

## User operation

```text
request a protected virtual machine
  -> authenticate and authorize project intent
  -> validate quota, image, flavor and policy
  -> ask Placement for compatible capacity
  -> schedule to a compute host and create durable allocation
  -> attach Ceph-backed root/data state
  -> compile Neutron intent through OVN
  -> realize guest CPU, memory, disk and network on KVM/libvirt
  -> prove the guest operation through the external path
  -> preserve recoverability across host, rack and control-service failures
```

The success claim is not “the VM is ACTIVE.” It is: the intended workload is reachable and correct, its compute/network/storage dependencies and failure domains are explicit, capacity and security policy remain intact, and the operator can maintain or recover it without unsafe state edits.

## State and ownership model

| State | Intended authority | Loss or recovery path |
|---|---|---|
| identity, projects, roles and tokens | Keystone identity and policy stores | protected database/config/keys plus audited identity recovery |
| image metadata and bits | Glance catalog plus image backend | signature/digest verification and separate metadata/object recovery |
| resource inventory and allocations | Placement resource-provider generations | reconcile providers and consumers; never invent free capacity |
| server desired/observed lifecycle | Nova API database plus cell database and compute state | service recovery, host evacuation or controlled rebuild by failure class |
| logical network intent | Neutron database and OVN northbound state | reconcile to OVN southbound/chassis and validate the actual packet path |
| local forwarding realization | OVS/OVN controller and host interfaces | controller reconciliation, chassis/gateway recovery and path validation |
| block/object durability | Ceph monitors, maps, PGs and OSD data | quorum-safe recovery, CRUSH placement, scrub and backup/restore by data class |
| guest runtime | QEMU process, libvirt domain and host kernel/KVM | restart, migrate, evacuate or rebuild according to state and storage boundary |
| hardware lifecycle | BMC/Redfish task and inventory state | bounded power/update workflow with task polling, fencing and rollback plan |
| operational evidence | metrics, logs, traces, events, inventories and run receipts | retained evidence with time, identity and proof-limit metadata |

## Planned local boundary

Build a dependency-free Python control-plane simulator that runs as a normal user on Ubuntu 24.04 or Windows Python 3.12. It will load strict JSON topology and workload contracts and produce deterministic evidence for:

- three racks with separate power/network failure domains;
- controller quorum members, compute hosts, gateway chassis and Ceph monitor/OSD roles;
- Nova-like resource providers, inventories, allocations, traits and generations;
- KVM/libvirt-compatible CPU model, NUMA, hugepage and migration constraints;
- Neutron/OVN logical switches, routers, security policy, chassis binding and gateway HA;
- Ceph pool size/min_size, CRUSH rack diversity, PG health, fullness and recovery throttling;
- workload placement, quota, headroom and N+1/rack-loss admission;
- maintenance drain, live-migration compatibility, evacuation and workload validation;
- rolling control/data-plane upgrades with compatibility windows and abort gates;
- isolated restore/rebuild decisions for databases, OVN intent, Ceph data and guest state.

The simulator must never invoke libvirt, OpenStack, Ceph, OVS, OVN, a BMC, a cloud API or a production endpoint. Real commands appear only as decoded observation examples or reviewer-approved transfer work.

## Required failure matrix

1. A compute host fails while local ephemeral state exists; the operator distinguishes restart, evacuation and data loss.
2. A rack fails; placement and Ceph replicas reveal whether the workload actually spans the declared failure domain.
3. A Placement generation conflicts; capacity cannot be double-allocated or repaired by direct database edits.
4. An OVN gateway chassis fails; northbound intent remains but external reachability requires HA binding and dataplane proof.
5. MTU or underlay reachability is wrong; Neutron `ACTIVE` state must not be treated as packet-path success.
6. One Ceph OSD becomes slow or down; recovery traffic, client latency, `min_size` and headroom interact.
7. A pool approaches full; recovery safety and write availability must be evaluated before adding workload.
8. A live migration cannot converge or hosts have incompatible CPU/machine types; abort and cold alternatives remain explicit.
9. A controller upgrade crosses an unsupported compatibility boundary; rollout stops before losing quorum or API correctness.
10. A control database restores but OVN, Placement, Ceph and guest state disagree; reconciliation gates any return to service.
11. A BMC power action is ambiguous; the operator polls the task and verifies host identity before another action.
12. A tenant request violates quota, affinity, image-trust or network policy; fail closed without weakening the global platform.

## Design dossier

The capstone must generate or include:

- context, logical, physical and failure-domain diagrams;
- component/state ownership and dependency maps;
- workload and service-tier contracts;
- resource, quota, reserve and oversubscription model;
- compute/network/storage/control-plane SLOs and user-journey SLIs;
- threat model, identity boundaries and secret/key handling;
- failure-mode table with detection, containment, recovery and proof;
- maintenance, upgrade, rollback, backup and restore runbooks;
- capacity forecast and N+1/rack-loss admission decision;
- architecture decisions for cells, aggregates/AZs, gateway HA, Ceph protection and migration baseline;
- known limitations, residual risks and a reviewer defense packet.

## Safety gates

- refuse root, live OpenStack credentials, libvirt system URI, BMC addresses, cloud endpoints and production-like hostnames;
- accept only schema-valid project-local JSON with narrow identifiers and bounded integer capacities;
- never execute `virsh`, `openstack`, `ceph`, `ovs-*`, `ovn-*`, `ipmitool`, Redfish or SSH commands;
- write only under a descriptor-gated `.runtime` directory and refuse symlinks, unknown files or ownership mismatch;
- use deterministic synthetic identities and no real tenant, image, network, address, serial number or credential;
- preserve the first failure, never auto-edit authoritative state to make a check green, and never broaden cleanup;
- distinguish simulation, observation, design inference and production evidence in every receipt.

## Source plan

Lock twenty primary or official records across:

- Linux KVM, libvirt domain/migration and QEMU migration compatibility;
- OpenStack Nova cells, Placement, live migration and service upgrades;
- Neutron/OVN architecture, gateway availability and packet realization;
- Ceph architecture, CRUSH, health/fullness, recovery and upgrades;
- OpenStack identity/security, image trust and state/database recovery;
- DMTF Redfish task/power/update semantics.

Fast-moving project documentation receives a three-month review window. Stable specifications receive no more than six months. The manuscript must state when a page documents `latest` development behavior rather than the supported release.

## Acceptance boundary

The repository candidate may be called substantive only after:

1. direct lesson, assessment and reference schemas pass with exact relationships;
2. strict input and ownership tests pass;
3. all declared simulator scenarios run absent-to-absent as a normal user;
4. unsafe authority, topology, capacity, upgrade and cleanup paths fail closed;
5. generated dossier artifacts reconcile to the same topology and workload identities;
6. the exact eighteen-section manuscript, complete answers and independent transfer exist;
7. canonical content/schema/reader/lint/type/build and hygiene gates pass.

It remains quarantined until formal multidisciplinary review and reviewer-owned hidden-fault transfer. No simulator score awards private-cloud experience, production readiness or mastery.
