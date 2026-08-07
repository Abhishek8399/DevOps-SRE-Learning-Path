---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0076",
  "slug": "virtualization-kvm-libvirt-foundations",
  "aliases": ["V09-L01", "virtualization-kvm-libvirt-foundations"],
  "curriculumIds": ["PRV-001"],
  "route": "/book/privatecloud/virtualization-kvm-libvirt-foundations",
  "order": 1,
  "volume": "09-private-cloud",
  "title": "Virtualization foundations: operate KVM, QEMU, libvirt, images, and VM recovery",
  "summary": "Trace a virtual machine from hardware and KVM capability through QEMU, libvirt, domain identity, images, guest boot, networking, capacity, migration, fencing, recovery, and the user-visible service.",
  "domain": "private-cloud",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0003", "LES-0010", "LES-0012", "LES-0037"],
  "prerequisiteCurriculumIds": ["LNX-003", "LNX-006", "NET-002", "IAC-001"],
  "testedEnvironments": [
    {"platform":"Primary and official documentation","version":"Linux KVM, QEMU, libvirt, cloud-init and libguestfs sources reviewed 2026-08-07","support":"concept-only","notes":"Documentation defines interfaces and semantics; it does not prove a host or VM."},
    {"platform":"Ubuntu","version":"24.04 WSL normal-user read-only capability inventory","support":"required","notes":"x86_64 WSL exposes CPU virtualization flags, /dev/kvm is inaccessible, QEMU/libvirt tools are absent and cloud-init is present."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Guarded deterministic 49-case decision model; no VM or virtualization operation."},
    {"platform":"KVM/QEMU/libvirt runtime","version":"not available in the tested WSL boundary","support":"unsupported","notes":"No package installation, KVM access, QEMU/libvirt process, image, network or VM lifecycle was attempted."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "private-cloud-engineer", "virtualization-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Distinguish emulation, hardware-assisted virtualization, hypervisor, KVM, QEMU, libvirt, domain, guest and application.",
    "Prove host virtualization capability across hardware, firmware, kernel, /dev/kvm, permissions, emulator and domain capability layers.",
    "Trace a libvirt operation through connection, daemon, driver, QEMU, KVM, devices, guest and user evidence.",
    "Design stable domain identity and lifecycle across desired definition, effective runtime, guest initialization and service readiness.",
    "Select CPU model, vCPU topology, NUMA placement, memory backing and overcommit from compatibility and measured workload evidence.",
    "Manage raw and qcow2 images, backing chains, templates, cloud-init, NVRAM, snapshots, backups and restore without identity collision.",
    "Trace a VM packet through guest interface, virtual device, tap, bridge or virtual switch, forwarding, physical network and return path.",
    "Apply least privilege, secure management transport, QEMU confinement, device/storage boundaries, secret handling and protected audit.",
    "Calculate capacity, failure reserve, placement and noisy-neighbor policy across host, rack, power, network, storage and control domains.",
    "Preflight and observe migration across CPU, machine, firmware, device, memory, storage, network, security and downtime constraints.",
    "Separate restart, migration, snapshot, backup, fencing, high availability, disaster recovery and correct user recovery.",
    "Diagnose and recover failed boot, identity, storage, network, capacity, migration and HA cases without trusting one green status."
  ],
  "productionSignals": [
    "host asset identity rack power network storage failure domain firmware and maintenance state",
    "architecture CPU model microcode sockets cores threads NUMA and virtualization flags",
    "kernel release KVM modules API capabilities /dev/kvm owner mode and caller access",
    "QEMU binary package digest version accelerator machine type firmware and device model",
    "libvirt URI daemon driver API version authorization event and operation ID",
    "host and domain capabilities architecture machine CPU firmware device and migration features",
    "domain name UUID definition revision persistent live state reason and owner",
    "vCPU topology pinning time steal wait throttling run queue and per-NUMA locality",
    "guest memory current maximum resident allocation faults swap balloon hugepage and host pressure",
    "disk target source format virtual size allocation backing chain cache io mode errors latency and space",
    "template manifest sanitization instance ID machine ID SSH keys NVRAM and cloud-init stages",
    "interface model MAC tap bridge forwarding VLAN IP DHCP DNS policy drops and packet counters",
    "management principal permission transport peer certificate socket policy and audit result",
    "fleet admitted requested actual reserve overcommit contention evacuation and recovery capacity",
    "migration source destination compatibility dirty rate bandwidth progress downtime abort and authority",
    "guest boot console agent heartbeat filesystem network application SLI correctness and user verification",
    "HA detection fence decision destination start initialization recovery and old-path rejection",
    "backup artifact chain restore result recovery objective soak cleanup owner and finding"
  ],
  "diagrams": [
    {"id":"LES-0076-DIA-001","title":"Virtual-machine execution stack","direction":"hierarchical","boundaries":["hardware and firmware","Linux kernel and KVM","QEMU process and devices","libvirt management","guest kernel","application and user"],"evidencePoints":["CPU feature","KVM API","process and machine","domain event","boot evidence","user SLI"],"textAlternative":"A VM crosses hardware, kernel KVM, QEMU, libvirt, guest and application boundaries; success at one layer cannot prove the next."},
    {"id":"LES-0076-DIA-002","title":"Domain desired-to-user state path","direction":"left-to-right","boundaries":["versioned definition","capability validation","QEMU accepted","KVM running","guest booted","instance initialized","service ready","user verified"],"evidencePoints":["XML digest","domain capabilities","PID/QMP","vCPU","console","cloud-init","health","transaction"],"textAlternative":"A desired domain becomes useful only after capability admission, runtime creation, guest boot, per-instance initialization, application readiness and user verification."},
    {"id":"LES-0076-DIA-003","title":"Image and instance identity chain","direction":"hierarchical","boundaries":["sealed base image","backing-chain manifest","overlay and NVRAM","domain UUID and MAC","datasource instance ID","guest machine identity","application state"],"evidencePoints":["digest","format/path","owner","inventory","metadata","machine-id/key","invariant"],"textAlternative":"Cloning is safe only when immutable image lineage and every per-instance firmware, network, guest and application identity remain distinct."},
    {"id":"LES-0076-DIA-004","title":"Virtual packet path","direction":"left-to-right","boundaries":["guest socket","guest kernel","virtio NIC","QEMU or vhost","tap","bridge or switch","host route/filter","physical network","return path"],"evidencePoints":["connection","route","queue","process","link","FDB/VLAN","policy","packet","reply"],"textAlternative":"A VM packet crosses guest, emulated or paravirtual device, host interface, virtual switch, policy and physical network boundaries in both directions."},
    {"id":"LES-0076-DIA-005","title":"Capacity and failure-domain envelope","direction":"hierarchical","boundaries":["fleet demand","host usable capacity","hypervisor reserve","rack/power/network/storage domains","placement","one-domain loss","recovery workload"],"evidencePoints":["requests","measured supply","reserve","inventory","anti-affinity","survivor headroom","SLO"],"textAlternative":"Aggregate capacity is insufficient when admitted demand cannot fit on surviving independent failure domains with host and recovery reserve."},
    {"id":"LES-0076-DIA-006","title":"Migration and HA authority path","direction":"cyclic","boundaries":["preflight","source authority","state/storage transfer","destination activation","network convergence","source fencing","service recovery","cleanup and learning"],"evidencePoints":["compatibility","lease","progress","destination state","packet path","old-path denial","user SLI","inventory"],"textAlternative":"Migration or HA recovery is complete only after compatibility, one-writer authority, network convergence, user recovery and exact cleanup are proved."}
  ],
  "commands": [
    {"id":"LES-0076-CMD-001","question":"Is this a safe no-VM learning shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0076 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"local source and authority guards pass","nextEvidence":"capability"},{"when":"lab=fail","meaning":"a named guard failed","nextEvidence":"correct without bypass"}],"proves":"local model prerequisites","doesNotProve":"KVM or VM readiness"},
    {"id":"LES-0076-CMD-002","question":"What virtualization capability is actually visible here?","risk":"read-only","command":"bash lab.sh capability","runFrom":"LES-0076 support/lab","expectedBranches":[{"when":"capability=observed","meaning":"architecture, environment, CPU flag, /dev/kvm access and command presence are reported","nextEvidence":"interpret each field separately"}],"proves":"read-only local capability observations","doesNotProve":"a VM can run"},
    {"id":"LES-0076-CMD-003","question":"Can bounded synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0076 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture copy exists","nextEvidence":"status"},{"when":"refusal","meaning":"state identity is unsafe","nextEvidence":"preserve first error"}],"proves":"bounded lab initialization","doesNotProve":"domain creation","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0076-CMD-004","question":"Are all reviewed cases loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"cases=49","meaning":"expected model inventory is active","nextEvidence":"evaluate baseline"},{"when":"other count or refusal","meaning":"fixture drift","nextEvidence":"stop"}],"proves":"fixture identity and count","doesNotProve":"virtualization coverage"},
    {"id":"LES-0076-CMD-005","question":"What fields make the synthetic baseline admissible?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"all encoded claims are inspectable","nextEvidence":"evaluate"}],"proves":"synthetic values","doesNotProve":"their truth on a host"},
    {"id":"LES-0076-CMD-006","question":"Does the baseline cross every encoded gate?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=admissible-within-model","meaning":"all finite predicates pass","nextEvidence":"compare failures"}],"proves":"deterministic baseline decision","doesNotProve":"production readiness"},
    {"id":"LES-0076-CMD-007","question":"Do CPU flags make /dev/kvm usable?","risk":"read-only","command":"bash lab.sh evaluate dev-kvm-denied","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=kvm-device-access","meaning":"caller cannot use the kernel device","nextEvidence":"fix supported host exposure or permission"}],"proves":"encoded access boundary","doesNotProve":"real KVM permission"},
    {"id":"LES-0076-CMD-008","question":"Can an overlay run without its base?","risk":"read-only","command":"bash lab.sh evaluate qcow2-backing-file-missing","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=backing-chain","meaning":"image lineage is incomplete","nextEvidence":"preserve and resolve exact base identity"}],"proves":"encoded chain gate","doesNotProve":"qcow2 integrity"},
    {"id":"LES-0076-CMD-009","question":"Can a cloned instance reuse cloud-init identity?","risk":"read-only","command":"bash lab.sh evaluate cloud-init-instance-id-reused","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=datasource-identity","meaning":"first-boot behavior is ambiguous","nextEvidence":"sanitize and supply unique metadata"}],"proves":"encoded instance gate","doesNotProve":"cloud-init behavior"},
    {"id":"LES-0076-CMD-010","question":"Does Running prove the user service is ready?","risk":"read-only","command":"bash lab.sh evaluate running-means-ready","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=boot-observability","meaning":"guest/application readiness is unproved","nextEvidence":"console, boot, initialization and user probes"}],"proves":"encoded readiness boundary","doesNotProve":"guest state"},
    {"id":"LES-0076-CMD-011","question":"Can this source move to this destination?","risk":"read-only","command":"bash lab.sh evaluate destination-cpu-machine-incompatible","runFrom":"LES-0076 support/lab after setup","expectedBranches":[{"when":"boundary=migration-compatibility","meaning":"CPU/machine contract differs","nextEvidence":"compatible baseline or refuse"}],"proves":"encoded compatibility gate","doesNotProve":"migration behavior"},
    {"id":"LES-0076-CMD-012","question":"Do all cases, refusal and cleanup pass without VM action?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0076 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"49 decisions, refusal and cleanup pass","nextEvidence":"retain model-only limit"},{"when":"failure","meaning":"candidate evidence rejected","nextEvidence":"preserve first failure"}],"proves":"offline model lifecycle","doesNotProve":"KVM QEMU libvirt image network migration HA or VM behavior","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0076-LAB-001","title":"Guided virtualization capability and evidence-gate model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no KVM operation","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic 49-case fixture"],"abortConditions":["root","credential","cloud profile","cluster or Docker context","remote libvirt URI","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0076-virtualization-kvm-libvirt-foundations/support/lab"},
    {"id":"LES-0076-LAB-002","title":"Independent disposable VM lifecycle, movement and recovery","mode":"independent","environment":"Reviewer-owned disposable local virtualization host or faithful harness with synthetic data","timeMinutes":240,"privilege":"least privilege; reviewer owns hidden faults and stop authority","network":"isolated local only","changes":["one bounded synthetic VM or faithful harness","versioned image and per-instance state","isolated virtual network","reviewer-controlled migration or cold-move faults"],"abortConditions":["production","public target","external cloud","real credential","customer data","host-wide network change","unbounded load","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore authoritative disposable state and prove exact absence.","cleanupProof":"Reviewer proves every definition, process, socket, disk, overlay, NVRAM, metadata and network artifact absent.","path":"drafts/LES-0076-virtualization-kvm-libvirt-foundations/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0076-INC-001","signal":"CPU virtualization flags exist but VM creation fails at /dev/kvm.","firstThought":"Hardware visibility, firmware, kernel support and caller device access are separate gates.","safePath":"Bind environment, modules, device owner/mode and supported nested boundary; do not bypass blindly.","trap":"Install more VM tools or run everything as root."},
    {"id":"LES-0076-INC-002","signal":"A domain reports Running but the application never becomes ready.","firstThought":"QEMU process state does not prove guest boot, initialization, network, storage or service correctness.","safePath":"Trace console, boot stages, identity, filesystem, packet path and user operation.","trap":"Restart repeatedly from the same broken image."},
    {"id":"LES-0076-INC-003","signal":"An overlay cannot open after image files were moved.","firstThought":"qcow2 is a dependency graph; the backing path or identity may be missing or wrong.","safePath":"Stop writes, preserve files, inspect declared format and full chain, restore mapping or verified copy.","trap":"Rebase or convert the only copy without a preserved manifest."},
    {"id":"LES-0076-INC-004","signal":"Live migration completes but the VM reboots or loses service/network identity.","firstThought":"Compatibility, state/storage transfer, authority, guest identity and packet convergence are distinct.","safePath":"Stop expansion, establish one authority, preserve both hosts' evidence, restore service and reconcile artifacts.","trap":"Trust the migration job and delete the source immediately."},
    {"id":"LES-0076-INC-005","signal":"One host fails and remaining hosts cannot restart admitted VMs.","firstThought":"Aggregate capacity and host count hid failure reserve and correlated domains.","safePath":"Prioritize critical workloads, shed safely, restore capacity, fence the failed host and repair admission/placement.","trap":"Increase overcommit ratios during recovery."}
  ],
  "assessmentIds": ["ASM-0211", "ASM-0212", "ASM-0213"],
  "referenceIds": ["REF-0898", "REF-0899", "REF-0900", "REF-0901", "REF-0902", "REF-0903", "REF-0904", "REF-0905", "REF-0906", "REF-0907", "REF-0908", "REF-0909", "REF-0910", "REF-0911", "REF-0912"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a decision model and read-only capability inventory, not a hypervisor or VM.",
    "No package, KVM API, QEMU/libvirt process, image, bridge, tap, network policy, VM or migration is created or changed.",
    "The tested WSL boundary exposes CPU virtualization flags but not usable /dev/kvm; QEMU/libvirt runtime remains unproved.",
    "Virtualization behavior depends on hardware, firmware, kernel, QEMU/libvirt, machine, device, storage, network, guest and workload versions.",
    "Formal technical/security/instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Virtualization foundations: operate KVM, QEMU, libvirt, images, and VM recovery

## What you see and first thought

### The sentence that should slow you down

Someone says, "The VM is running, so the application is healthy."

Your first thought should be:

> Running is one layer's claim. Which layer produced it, what did that layer actually observe, and where is the first user-visible proof?

A virtualization platform is a chain of contracts. Hardware exposes capabilities. Firmware permits them. The Linux kernel exposes KVM. A process needs permission to open `/dev/kvm`. QEMU builds a virtual machine from a machine type, CPU model, memory map and devices. libvirt stores desired configuration and manages the QEMU process. Firmware and the guest kernel boot. Guest services initialize. The application starts. The network path reaches it. Only then can a user operation succeed.

One green link does not turn the entire chain green.

### The ladder you should remember

Read virtualization readiness as a ladder:

```text
CPU advertises vmx/svm
  -> firmware enables virtualization
  -> host kernel loads KVM modules
  -> /dev/kvm exists and is permitted
  -> QEMU supports the requested machine and devices
  -> libvirt can define and start the domain
  -> firmware finds a bootable image
  -> guest kernel and userspace become healthy
  -> network and storage paths work
  -> application becomes ready
  -> user operation succeeds
```

Every arrow is a boundary where evidence can stop. `grep vmx /proc/cpuinfo` proves only the first rung. `virsh domstate` reporting `running` proves that libvirt believes the QEMU process is active; it does not prove SSH, DNS, the application, data correctness or a customer transaction.

### A concrete incident

Imagine two KVM hosts. A maintenance script migrates a payment VM from host A to host B. The command returns success, and the domain is `running` on B. The incident channel declares recovery.

Five minutes later, checkout remains unavailable because:

- the target host selected a CPU model that the old guest kernel cannot use safely;
- the guest interface name changed after a duplicate MAC was repaired manually;
- the VM booted but cloud-init reran destructive first-boot logic because its instance identity changed;
- the application cannot reach its database through the target bridge and firewall path;
- the monitoring agent reports host and process health, but no probe exercises payment authorization;
- the source storage overlay was left behind and the target image now depends on a backing file nobody recorded.

The migration mechanism completed. The service recovery did not.

Whenever a VM operation reports success, ask:

1. What state changed in the hypervisor and libvirt?
2. What state changed inside the guest?
3. Which storage and network dependencies moved, and which did not?
4. What proves the user journey and data are correct now?

### Three questions hidden inside "Can this machine run VMs?"

That sentence usually mixes three questions:

1. **Capability:** Does the hardware, firmware, kernel and process boundary permit hardware-assisted virtualization?
2. **Compatibility:** Can this exact machine definition, CPU contract, firmware, device set and image run on this host?
3. **Operability:** Can the platform provision, observe, secure, migrate, recover and retire the workload predictably?

A laptop may pass capability and still be unsuitable for production. A host may run one VM and still fail compatibility for migration. A cluster may migrate VMs and still be inoperable because it lacks fencing, capacity reserve, image provenance or service-level probes.

### The outcome of this lesson

By the end, you should be able to trace a VM from physical CPU to user outcome; distinguish KVM, QEMU and libvirt; decode domain, image, network and migration evidence; design safe capacity and identity controls; and refuse a dangerous recovery claim.

The local lab is intentionally a guarded decision model. It does not install packages, create images, open `/dev/kvm`, start QEMU, define a domain, change networking or migrate a VM. That boundary matters because this workstation's observed WSL environment has CPU virtualization flags but no accessible KVM device or installed QEMU/libvirt runtime.

## Terms before commands

### Host, guest and virtual machine

The **host** is the physical or virtual computer providing CPU, memory, storage and networking to the virtualization layer. The **guest** is the operating system running inside the isolated machine environment. A **virtual machine**, or VM, is the configured virtual hardware plus its runtime and durable state.

Do not use "VM" to mean only a disk file. A useful inventory separates:

- definition: CPU, memory, devices, firmware and policies;
- identity: UUID, machine ID, host keys, MAC addresses and application identity;
- storage: base images, overlays, data volumes and snapshots;
- runtime: QEMU process, vCPU threads and allocated memory;
- placement: current host, eligible hosts and failure domain;
- service: guest health, application health and user promise.

Losing any one of those can make the others misleading.

### Hypervisor, KVM, QEMU and libvirt

A **hypervisor** provides the isolation and execution environment for VMs. Labels such as "type 1" and "type 2" are useful introductions, but Linux virtualization is a cooperating stack rather than one magic binary.

**KVM**, Kernel-based Virtual Machine, is the Linux kernel virtualization interface. With supported hardware and kernel modules, it lets a userspace virtual machine monitor create VMs and vCPUs and execute guest code using hardware virtualization. The KVM API is exposed through device and VM file descriptors and `ioctl` operations; access to that interface is a real permission boundary [REF-0898].

**QEMU** is the userspace virtual machine monitor and device model. It can emulate an entire machine, and with an accelerator such as KVM it can execute supported guest CPU code efficiently while still modeling memory and devices. QEMU's system documentation distinguishes the machine emulator from the accelerator [REF-0899].

**libvirt** is a management API, daemon/driver architecture and object model for virtualization resources. A libvirt **domain** is its representation of a VM or similar managed guest. libvirt does not replace QEMU or KVM; it defines and manages them through a stable control interface [REF-0902] [REF-0903].

Remember the responsibility split:

```text
libvirt says what should run and manages lifecycle
QEMU constructs the virtual computer and models devices
KVM lets guest CPU execution use Linux kernel + hardware acceleration
```

### Emulation, virtualization and paravirtualized I/O

**Emulation** reproduces another machine or device in software. It is flexible but can cost more CPU.

**Hardware-assisted virtualization** lets compatible guest instructions execute with CPU support while privileged transitions remain controlled. It does not remove the need for device models, memory management or security boundaries.

**Paravirtualized devices** expose an interface designed for virtual environments instead of imitating a particular physical device. The virtio family commonly provides block, network, balloon and other devices. The guest needs a compatible driver. Choosing virtio improves efficiency only when the entire driver, feature and migration compatibility contract is understood.

### Domain: persistent, transient, active and autostart

A **persistent domain** has a stored libvirt definition and can exist while shut off. A **transient domain** exists only for its active lifetime. **Active** means the domain is currently running or otherwise executing. **Autostart** is a policy asking libvirt to start a persistent domain during the relevant host lifecycle.

These states answer different questions:

- `defined` does not mean running;
- `running` does not mean boot completed;
- `autostart enabled` does not mean the last boot succeeded;
- an edited persistent definition may differ from the live definition until restart.

During an incident, compare live and inactive configuration deliberately. Otherwise you can fix the stored XML while the running VM continues with old devices, or hot-plug a live device that disappears at reboot.

### Domain XML and capability contracts

libvirt domain XML describes CPU, memory, firmware, controllers, disks, interfaces, host devices and policies. It is desired machine configuration, not proof the target host can realize it. The domain XML reference defines structure and device semantics [REF-0904].

**Host capabilities** describe what the virtualization connection and host expose. **Domain capabilities** answer a narrower question: for a chosen emulator, architecture, machine and virtualization type, which values are supported? The distinction matters because "this host supports virtualization" is much weaker than "this host supports this domain contract" [REF-0909] [REF-0910].

Treat a machine definition like an API contract. Pin or govern fields whose silent change could alter boot, compatibility, performance or migration.

### vCPU, topology, CPU model and compatibility

A **vCPU** is a virtual processor presented to the guest. QEMU typically maps vCPUs to host threads that the scheduler runs on physical CPUs. vCPU count is not reserved physical performance unless the platform enforces placement and reservation.

The guest can see sockets, cores and threads as a topology. Topology affects licensing, scheduler behavior and NUMA awareness. Do not increase vCPUs merely because a VM is slow; more runnable vCPU threads can increase scheduling delay and cross-NUMA traffic.

The **CPU model** is the feature contract visible to the guest:

- a named baseline model favors predictable compatibility;
- a host-model style tries to approximate the host while retaining a managed definition;
- host-passthrough exposes host CPU characteristics more directly and can improve feature access, but narrows safe migration compatibility.

The exact libvirt and QEMU behavior is version- and architecture-sensitive. The operational rule is stable: migration eligibility must be calculated from the guest-visible CPU contract and target capabilities, not from server model names.

### Memory, overcommit, ballooning, huge pages and NUMA

**Guest memory** is what firmware and the guest OS believe exists. **Host resident memory** is what the VM process currently occupies. They are related but not identical.

**Overcommit** means promising more virtual resources than are physically available, based on the assumption that not every workload peaks together. It raises utilization and failure coupling. A ratio alone is not a capacity policy; you also need workload distributions, headroom, reclaim behavior, latency limits and a host-failure scenario.

A **balloon driver** can cooperate with the guest to return memory pressure capacity to the host. Ballooning is not free memory: the guest must release pages, and application latency can degrade before a dashboard looks critical.

**Huge pages** reduce page-table overhead and translation pressure for some workloads but require explicit capacity planning and can reduce placement flexibility.

**NUMA**, non-uniform memory access, means memory latency depends on which CPU socket or node accesses it. A large VM spanning nodes can suffer remote memory access. vCPU pinning without matching memory placement can make performance less predictable, not more.

### Machine type, firmware and NVRAM

The **machine type** defines a virtual hardware platform: chipset model, buses, controllers and compatibility behavior. Upgrading QEMU without controlling machine types can change what newly defined VMs receive.

Guest firmware may be BIOS-like or UEFI. UEFI guests can have writable **NVRAM** state containing boot variables and secure-boot related data. Copying a disk without the required firmware configuration or NVRAM can produce a VM that looks intact but cannot boot. Copying writable NVRAM carelessly can also duplicate identity-like state.

### Raw, qcow2, backing file and overlay

A **raw** image is a direct byte representation of a disk. It is simple and predictable but does not itself provide qcow2 features.

**qcow2** is QEMU's copy-on-write image format. It can support sparse allocation, snapshots, compression and backing files. These features create operational dependencies that must be inventoried and validated [REF-0900].

A **backing file** contains base blocks. An **overlay** stores changes and reads unchanged blocks from its backing chain. The visible guest disk is therefore not necessarily one self-contained file:

```text
guest reads block
  -> overlay has changed block? use overlay
  -> otherwise follow backing reference
  -> repeat until data found or chain breaks
```

Deleting, renaming, moving or mutating an assumed "old" base image can corrupt every dependent VM. Apparent file size is not allocated storage, and allocated storage is not maximum future growth.

### Snapshot, backup, clone and template

A **snapshot** records a point-in-time relationship or state for convenient rollback or branching. It may be internal to an image or external in a chain. It often shares failure domains with the source.

A **backup** is an independently recoverable copy governed by retention, integrity checking and restore tests. A snapshot is not automatically a backup.

A **clone** creates a new VM or disk lineage. A full clone can copy blocks; a linked clone depends on a base.

A **template** is a deliberately prepared source for new instances. It should have provenance, patch state, agents, drivers and sanitization rules. `virt-sysprep` can remove or reset selected guest-specific state, but operators must choose operations and understand their effects [REF-0912].

### Identity: UUID, MAC, machine ID, host keys and cloud-init instance

One VM carries identities at several layers:

- libvirt domain UUID identifies the managed domain;
- storage identifiers identify disks and filesystems;
- virtual NIC MAC affects layer-2 identity and DHCP;
- `/etc/machine-id` identifies a Linux installation to system components;
- SSH host keys identify the server to clients;
- cloud-init instance identity determines whether initialization is first boot;
- application, cluster and certificate identities may be stored inside the guest.

Cloning bytes without regenerating the correct identities can cause DHCP collisions, rejected SSH fingerprints, duplicate monitoring nodes, replayed initialization or two members claiming the same distributed-system identity.

cloud-init uses datasource and instance information to decide initialization behavior; its boot stages and cache rules are part of the provisioning contract, not decoration [REF-0911].

### Virtual NIC, TAP, bridge, vhost and external network

A guest NIC is a virtual device. A **TAP** interface connects packet traffic between a userspace/virtualization boundary and the host networking stack. A Linux **bridge** can switch frames among interfaces. **vhost** mechanisms can accelerate virtio data paths in the kernel.

The complete path is larger:

```text
guest application
 -> guest socket and routing
 -> guest virtio NIC
 -> QEMU/vhost datapath
 -> host TAP
 -> bridge or virtual switch
 -> host NIC / VLAN / overlay
 -> firewall, router, load balancer
 -> dependency or user
```

`ip addr` inside the guest cannot prove the bridge VLAN, upstream route, firewall, load balancer or return path.

### Storage pool and volume

A libvirt **storage pool** is a managed view of a storage source; a **volume** is an allocatable object within it. Pools can be directory-backed or use other storage technologies. The XML records management configuration, but durability and failure behavior come from the underlying filesystem, block device, network and storage system [REF-0906].

Never infer redundancy from "managed by libvirt." Ask where bytes live, who flushes them, what fails together, how capacity is enforced and whether a restore was tested.

### Live migration, cold migration and storage movement

**Cold migration** moves or redefines a stopped workload. **Live migration** transfers an active VM while attempting to keep interruption bounded. Memory pages may be copied iteratively while the guest continues changing them; a final stop-and-copy phase transfers remaining state.

Migration can include or exclude storage depending on topology and procedure. Shared-storage migration and block migration have different network, capacity and consistency risks. libvirt documents multiple migration transports and security considerations; the right method depends on the connection and protection boundary [REF-0907] [REF-0908].

The **dirty rate** is how quickly the guest changes memory. If it approaches or exceeds effective migration throughput, pre-copy may not converge within the downtime budget.

### High availability, quorum and fencing

Virtualization high availability usually means detecting a failed host and restarting affected VMs elsewhere. It does not mean every application is continuously available.

**Quorum** helps participants decide which side may act. **Fencing** proves or forces that an unhealthy host cannot continue writing or serving before the same VM starts elsewhere. Without reliable fencing, automated restart can create two writers from one identity.

Capacity reserve is part of HA. A two-host cluster at 80 percent memory utilization cannot necessarily absorb one failed host. "N+1" is a workload-placement calculation, not a label.

## Architecture map

### View 1: the execution stack

```text
USER OPERATION
      |
application + dependencies
      |
guest userspace and kernel
      |
virtual devices + guest firmware
      |
QEMU process / device model
      |
KVM API in Linux kernel
      |
CPU virtualization + host memory + physical I/O

libvirt control plane ---> definition, lifecycle, policy, inventory
observability ----------> evidence from every layer
```

Read upward for service delivery. Read downward when proving prerequisites. Read sideways to see that libvirt manages the runtime but is not the runtime itself.

### View 2: desired state versus live state

```text
operator / automation
        |
        v
persistent domain XML -----> libvirt database/config
        |                           |
        | define/start              | lifecycle action
        v                           v
target capability check -------> live QEMU process
                                      |
                                      v
                            actual guest-visible machine

Drift questions:
  stored XML == live XML?
  live XML == intended policy?
  intended policy supported on every eligible host?
```

The platform needs all three comparisons. Version-controlled templates do not prove the live domain. Live XML does not prove compliance with current policy.

### View 3: image and identity lineage

```text
trusted source artifact
  [digest, owner, build evidence, patch date]
                 |
                 v
          sanitized template
                 |
          full clone / overlay
                 |
                 v
         instance-specific disk
                 |
        first-boot provisioning
                 |
                 v
  unique UUID + MAC + machine-id + SSH keys
                 |
                 v
      registered application identity
```

The image factory owns reproducibility; provisioning owns uniqueness. If both assume the other removed identity, clones collide. If both regenerate indiscriminately, stable identity and certificates break on every boot.

### View 4: storage dependency graph

```text
VM A overlay ----\
                  -> golden-base.qcow2 -> filesystem -> physical/storage backend
VM B overlay ----/

VM C data volume ---------------------> block/network storage backend

snapshot metadata -> points to chain; it is not an independent restore
backup repository -> separate failure boundary + verified restore procedure
```

Treat image chains as a directed graph, not a directory listing. Before deleting a node, prove it has no descendants and no restore dependency.

### View 5: packet path

```text
client
  -> DNS / load balancer
  -> physical switch / VLAN / overlay
  -> host NIC
  -> bridge / virtual switch + firewall
  -> TAP / vhost
  -> virtual NIC
  -> guest route + firewall
  -> application listener
  -> dependency return path
```

A VM can have a valid IP and still be unreachable at five later boundaries. Troubleshoot hop by hop, in both directions.

### View 6: migration and recovery control loop

```text
admit target
 [CPU + machine + firmware + devices + storage + network + capacity]
          |
          v
preflight source and target
          |
          v
copy memory/state ---- measure dirty rate and throughput
          |
          v
bounded switchover ---- observe downtime and destination
          |
          v
guest + app + user validation
          |
      +---+---+
      |       |
   accept   rollback/fail forward
      |       |
      +---+---+
          |
reconcile source, storage, identity and monitoring
```

The control loop ends after user and data validation, not after the migration API returns.

### Read all six views together

The execution stack explains layers. Desired/live state explains configuration drift. Image lineage explains provenance and identity. The storage graph explains hidden dependencies. The packet path explains reachability. The migration loop explains change safety.

If an incident analysis uses only one view, it will likely repair one layer and declare the service healthy too early.

## Request or state path

### 1. Admit the host

Inventory architecture, virtualization flags, firmware setting, KVM modules, `/dev/kvm` permissions, QEMU/libvirt versions, machine types, domain capabilities, storage connectivity, network fabric and failure-domain labels.

Admission is policy, not discovery alone. A capability can be present but forbidden because its version, security posture or failure domain is outside the supported fleet.

### 2. Admit the machine contract

Resolve an explicit domain definition against the target host:

- architecture and virtualization type;
- emulator and machine type;
- CPU model and required features;
- vCPU topology, memory and NUMA placement;
- firmware, NVRAM and secure-boot policy;
- controller and device models;
- image formats, backing graph and volume access;
- NIC model, MAC, bridge/network and filters;
- migration and recovery requirements.

Do this before scheduling. "Try to start and inspect the error" is not a placement strategy.

### 3. Resolve durable artifacts

Verify image digest, provenance, ownership, format and complete backing chain. Confirm every required target can access the relevant volumes with the expected consistency and latency.

For a clone, decide which state remains identical and which must become unique. Record that decision as an image/provisioning contract.

### 4. Define and start

libvirt accepts a definition and invokes the relevant driver. QEMU constructs guest memory and devices, opens storage and network resources, and uses KVM if configured and permitted. Failures here can come from syntax, unsupported capabilities, permissions, labels, missing files, locked volumes, unavailable interfaces or exhausted capacity.

The process starting is only a control-plane milestone.

### 5. Firmware and guest boot

Firmware initializes the virtual platform, reads boot configuration and selects a boot target. The guest kernel initializes CPUs, memory, drivers, root storage and networking. Userspace starts services.

Capture serial-console and guest boot evidence. A blank remote console can mean no output path, wrong firmware, a broken disk chain or a guest kernel failure; it does not automatically mean "QEMU is down."

### 6. Instance initialization

cloud-init or another provisioning agent discovers instance data, decides whether this is a new instance, applies configuration and records completion. The platform must know which readiness conditions depend on it.

A network service starting before cloud-init finalizes packages, certificates or routes can create a false-ready window.

### 7. Application readiness

The application binds its listener, establishes dependency pools, loads required state and passes a meaningful readiness check. Then an external probe performs the important user operation.

Separate:

- VM process availability;
- guest OS availability;
- application availability;
- user-operation success;
- data correctness.

### 8. Change, migrate or recover

Before change, recompute compatibility and capacity using current state. During change, observe control-plane progress and user/data signals. After change, validate destination placement, guest time, network, storage, application, monitoring and source cleanup.

For host failure, fence first according to the design, establish authority, then restart. Recovery without authority can turn an availability incident into corruption.

### 9. Retire safely

Disable traffic and schedules, preserve required evidence and backups, revoke identities, undefine the domain, remove only verified unreferenced volumes, update capacity and inventory, and test that no automation recreates the asset unexpectedly.

Deletion order is a dependency problem. Never delete a base image because its filename looks old.

## Failure zoom

### Failure 1: CPU flags exist, but KVM is unusable

`vmx` or `svm` in CPU information says the CPU view advertises a feature. Firmware may disable it, the kernel modules may be absent, nested virtualization may be unavailable, `/dev/kvm` may not exist, or the process may lack permission.

**Evidence order:** flags -> firmware/environment -> modules -> device -> permissions -> minimal supported runtime test.

### Failure 2: the host is capable, but the domain is incompatible

The target host runs other VMs, yet this domain requests an unsupported CPU feature, machine type, firmware, device, huge-page size or host device.

**Fix direction:** compare the exact domain contract with domain capabilities. Do not use a generic "hypervisor healthy" dashboard as compatibility evidence.

### Failure 3: stored and live XML disagree

An operator updates memory, disk source or network in persistent configuration, but the active domain retains old live state. The incident appears fixed until reboot, or appears unfixed because only the next-boot definition changed.

**Fix direction:** label every inspection and change as live, config or both; plan whether a reboot or supported hot-plug is required.

### Failure 4: a qcow2 backing file disappears

A cleanup job sees a large, old base image and deletes it. Multiple small overlays remain. Their metadata still references the missing backing file, so guests cannot read unchanged blocks.

**Fix direction:** stop destructive automation, inventory backing chains read-only, identify affected descendants and restore the exact expected artifact from a trusted source. Do not create an empty file with the same name.

### Failure 5: thin or sparse storage reports two truths

The guest sees free blocks. The qcow2 file's apparent size is large but host allocation is smaller. The thin pool or host filesystem is nearly full. New guest writes require allocation and fail.

**Fix direction:** observe guest filesystem, virtual disk, image allocation, pool/backend capacity and growth rate separately. Reserve emergency headroom and alert on the constraining layer.

### Failure 6: clone identity collides

Two clones share machine ID, SSH host keys, MAC, DHCP client identity, cloud-init cache or an application node ID. Symptoms appear in unrelated systems: monitoring alternates between hosts, DHCP leases flap, SSH warns about keys, or a cluster evicts a duplicate member.

**Fix direction:** quarantine duplicates, decide the authoritative instance, regenerate only identities intended to be unique, then re-enrol external systems. Repairing only the MAC leaves other collisions.

### Failure 7: domain running, guest not booted

QEMU is alive but firmware cannot find a boot device, the NVRAM path is wrong, the kernel cannot mount root, or an init service blocks boot.

**Evidence order:** libvirt/QEMU log -> console -> firmware/boot order -> block graph -> guest kernel -> userspace. Do not repeatedly reboot without preserving first-failure evidence.

### Failure 8: guest reachable, application unavailable

SSH works, yet the application is not listening, cannot initialize, lacks a certificate, cannot reach a dependency or is excluded from load-balancer membership.

**Fix direction:** move one layer above guest reachability. Validate process, socket, local request, dependency, external request and representative user journey.

### Failure 9: asymmetric virtual networking

Requests reach the guest, but replies use the wrong route; a bridge VLAN is missing; host firewall state differs; reverse-path filtering drops traffic; or the target host lacks a network definition used on the source.

**Evidence order:** capture or counters at guest NIC, TAP, bridge, host NIC and upstream boundary in both directions. Match one flow's addresses and ports.

### Failure 10: CPU overcommit becomes latency

Average host CPU looks acceptable, but a latency-sensitive VM waits for vCPU scheduling because many wide VMs compete. Adding vCPUs makes the guest wider and harder to schedule.

**Fix direction:** inspect runnable demand, steal/wait signals, per-vCPU utilization, host scheduling delay, topology and SLO latency. Right-size and place; do not treat vCPU count as free performance.

### Failure 11: memory reclaim causes a hidden brownout

The host reclaims through ballooning, swap or other pressure behavior. The VM stays running while application tail latency and timeouts rise.

**Fix direction:** correlate host pressure, QEMU resident memory, guest memory/reclaim and application latency. Put reclaim limits and user signals into capacity policy.

### Failure 12: live migration does not converge

The guest changes memory faster than the network effectively copies it. Migration duration grows, source and target consume resources, and operators increase downtime without an approved bound.

**Fix direction:** compare dirty rate with effective transfer rate, identify workload phases, apply an approved convergence method or abort. An open-ended migration is not safe maintenance.

### Failure 13: migration completes, service stays down

The domain moves but the destination lacks the correct network path, time synchronization, storage latency, host device, secrets access or load-balancer registration.

**Fix direction:** run destination and user-level validation before accepting. Migration success is a mechanism signal, not an SLO signal.

### Failure 14: shared storage is a shared failure domain

Two hosts provide compute redundancy but all VM disks, metadata and backups depend on one storage control plane or power boundary. A storage failure removes both "redundant" hosts' workloads.

**Fix direction:** draw power, network, storage and control dependencies. Availability is limited by the weakest shared dependency.

### Failure 15: HA restarts without fencing

The controller loses contact with host A and starts its VM on host B, while A still runs and writes. The service now has two machines with one identity and disk ownership assumption.

**Fix direction:** stop automation if authoritative exclusion cannot be proved. Establish fencing and quorum semantics before automatic restart.

### Failure 16: N+1 exists on paper only

Nominal CPU totals fit after one host failure, but memory, huge pages, storage IOPS, device locality, anti-affinity or network bandwidth prevent actual placement.

**Fix direction:** simulate the largest credible failure using every hard constraint and workload headroom. Capacity is multidimensional.

### Failure 17: management access is overprivileged

Automation connects to a root-equivalent libvirt endpoint over an inadequately protected channel. A stolen credential can define devices, attach host paths or control every domain.

**Fix direction:** use documented secure transports and least privilege, restrict network exposure, separate human and automation identities, log actions and protect host/device access [REF-0908].

### Failure 18: backup exists, recovery contract does not

Files are copied, but nobody recorded domain XML, firmware/NVRAM, backing dependencies, application consistency, encryption material or restore ordering. The backup job is green and the restore fails.

**Fix direction:** define the recoverable unit and prove it through timed restoration into an isolated environment.

## Internals and state ownership

### Hardware and firmware own the first permission

The physical CPU implements virtualization features. System firmware decides whether the host OS can use them. In a nested environment, an outer hypervisor decides what reaches the inner guest.

Owner questions:

- Which hardware generation and microcode are supported?
- Is virtualization enabled consistently in firmware?
- Is this bare metal or nested virtualization?
- Who controls firmware drift and reboot-required changes?

An application team cannot repair this boundary from inside a guest.

### The host kernel owns KVM mediation

KVM modules integrate virtualization with Linux scheduling, memory management and interrupt handling. The `/dev/kvm` device is the userspace entry point. File ownership, groups, ACLs, mandatory access controls, namespaces and device policy decide who may use it.

The KVM API documents a system file descriptor, VM file descriptors and vCPU/device interfaces [REF-0898]. That structure explains why "the module is loaded" and "this QEMU process can create the required VM" are separate claims.

### QEMU owns the live virtual computer

The QEMU process owns the live emulated machine: guest RAM mappings, vCPU threads, device state, block graph and network backends. Its command line and monitor state are valuable runtime evidence, but libvirt-managed environments should normally be changed through libvirt to avoid control-plane drift.

QEMU image operations also have distinct risk. An offline image inspection can be read-only; a rebase or commit can rewrite dependency relationships. Always distinguish information commands from graph-mutating commands.

### libvirt owns managed intent and lifecycle

libvirt stores or exposes domain, network, storage and secret objects and translates lifecycle requests to drivers. It owns management truth, not application truth.

For each domain record:

- desired persistent definition;
- current live definition;
- current lifecycle state and reason;
- host and failure-domain placement;
- owning service and data classification;
- maintenance, migration and recovery policy.

If an external script edits QEMU state behind libvirt, both systems can be internally correct while disagreeing with each other.

### The image pipeline owns provenance and sanitization

An image factory should record source, digest, build definition, package/agent versions, vulnerability policy, firmware/driver compatibility and test evidence. It should explicitly sanitize identities that must be generated per instance.

The output is not "golden" forever. It becomes stale. Rebuild rather than accumulating unknown manual changes, and retain rollback artifacts only with bounded retention and dependency knowledge.

### Provisioning owns uniqueness and convergence

Provisioning supplies instance metadata, network configuration, credentials or enrollment tokens and application parameters. It must distinguish first boot from subsequent boot and converge safely after retries.

Idempotence means rerunning an operation reaches the intended state without harmful duplication. It does not mean every initialization task should run on every boot. Key generation and destructive disk initialization need carefully scoped conditions.

### Storage owns persistence semantics

The storage backend determines durability, write ordering, allocation behavior, snapshot semantics, latency and failure domain. QEMU and libvirt can request operations but cannot manufacture guarantees the backend lacks.

The virtualization team and storage team need a shared contract for:

- flush and cache behavior;
- thin-provisioning exhaustion;
- snapshot consistency;
- multipath/failover;
- encryption and key recovery;
- backup isolation and restore performance;
- capacity signals and emergency thresholds.

### Network owners share one end-to-end path

Guest configuration, libvirt network definition, host bridge or switch, physical fabric, network policy, IPAM, DNS and load balancing may have different owners. A single VM incident can cross all of them.

Use one traceable flow tuple and timestamps. "Networking looks fine" is not evidence unless the speaker names the observed boundary.

### The guest owns boot and local service state

After virtual hardware is available, the guest kernel, init system, agents and applications own their state. Host-side guest agents can improve visibility, but agent absence may mean the guest is booting, hung, isolated, unconfigured or simply lacks the agent.

Preserve an out-of-band console path. If every diagnostic path depends on guest networking, a networking incident removes both service and evidence.

### The scheduler owns placement risk

Placement is a constraint problem, not merely "host with most free RAM." It should account for CPU compatibility, memory/NUMA, huge pages, devices, storage access, networks, anti-affinity, maintenance state, thermal/power boundaries and recovery reserve.

Placement decisions should be explainable after the fact: why was this host eligible, which constraints passed, and which capacity data was used?

### HA owns authority before restart

An HA controller interprets liveness, quorum and fencing state, then chooses whether and where to restart. It must fail safely when ownership is ambiguous.

If the controller cannot prove the old writer is excluded, the safe result may be continued outage while humans establish authority. Availability is valuable; preventing two writers is more fundamental.

### Service owners own the final truth

Platform telemetry cannot define every user promise. The service owner must provide meaningful readiness, transaction and reconciliation signals, plus recovery order for stateful components.

The platform can report "domain active for 99.99 percent." The business can still experience 95 percent success. Reliability is measured where the promise is made.

## Evidence table

| Question | Weak evidence | Stronger evidence | What stronger evidence still does not prove |
|---|---|---|---|
| Does the CPU view advertise virtualization? | server model supports it | `vmx`/`svm` visible in the relevant host context | firmware, KVM or permission |
| Can this process use KVM? | module name appears | expected identity can open `/dev/kvm` and a supported test succeeds | this domain's compatibility |
| Is the machine definition syntactically valid? | XML looks familiar | schema/`virt-xml-validate` passes | target capabilities or service health |
| Can this domain run here? | another VM runs | exact domain contract resolves against target domain capabilities | boot and application success |
| Is the domain active? | host is reachable | lifecycle state plus reason and QEMU process evidence | guest boot |
| Did the guest boot? | QEMU consumes CPU | serial/console, guest agent and init evidence agree | application readiness |
| Is the application ready? | SSH works | local application probe and dependency checks pass | external path or complete journey |
| Is the service recovered? | migration command succeeded | external user operation and correctness/reconciliation checks pass | future resilience |
| Is the disk self-contained? | one qcow2 file exists | complete read-only backing graph resolves to verified artifacts | filesystem/application consistency |
| Is there enough disk capacity? | guest `df` is low usage | guest, image allocation, pool/backend headroom and growth all fit policy | performance under peak writes |
| Is the clone unique? | domain name differs | UUID, MAC, machine ID, host keys, cloud-init and app identities follow contract | authorization correctness |
| Is migration compatible? | hosts are same vendor | CPU baseline, machine, firmware, devices, storage and network checks pass | convergence and user downtime |
| Will live migration converge? | link is fast | measured effective throughput exceeds dirty rate with approved margin | destination service correctness |
| Is HA safe? | controller can restart | quorum, independent fencing and ownership tests pass | enough placement capacity |
| Is the backup usable? | job uploaded bytes | isolated timed restore validates VM and application recoverable unit | every future restore |

### Build an evidence bundle, not a screenshot

For an incident or change, retain:

- timestamp and operator/automation identity;
- domain UUID and service owner;
- source and target host identity;
- persistent and live definitions;
- capabilities used for admission;
- image digests and backing graph;
- storage and network path observations;
- lifecycle events and reason codes;
- guest boot and application evidence;
- user-level validation;
- rollback/recovery decision and cleanup proof.

This bundle lets another engineer reconstruct the decision. A screenshot of a green console cannot.

## Command decoders

### Command 1: prove the learning shell is guarded

```bash
bash lab.sh doctor
```

Run this as a normal Ubuntu user from `support/lab`. It checks the local scripts, fixture and safety assumptions. `doctor=pass` means the no-VM model can run inside its bounded contract.

It does **not** inspect or enable KVM, install QEMU, connect to libvirt, create a VM or prove virtualization readiness. If a guard fails, fix the named prerequisite; do not use `sudo` to bypass it.

### Command 2: inventory the local capability boundary

```bash
bash lab.sh capability
```

This is the only host-observation command in the lesson, and it is read-only. Interpret every field independently:

- `architecture` identifies the execution architecture;
- `environment` distinguishes WSL from the script's generic Linux observation;
- `cpu_virtualization` reports whether a visible CPU flag was found;
- `kvm_device` reports whether the current user can access `/dev/kvm`;
- `qemu`, `virsh`, `host_validate` and `qemu_img` report command presence;
- `cloud_init` reports command presence, not successful provisioning.

The observed workstation output was:

```text
capability=observed architecture=x86_64 environment=wsl cpu_virtualization=present kvm_device=inaccessible qemu=no virsh=no host_validate=no qemu_img=no cloud_init=yes
```

The correct conclusion is narrow: CPU virtualization flags are visible, but a KVM/QEMU/libvirt VM runtime is unavailable and unproved in this boundary. Do not convert `cpu_virtualization=present` into "KVM works."

### Command 3: create only bounded synthetic state

```bash
bash lab.sh setup
```

Setup copies a deterministic fixture to a UID-scoped temporary location. It does not modify virtualization configuration. A safe setup reports success and tells you which synthetic state exists.

Cleanup is:

```bash
bash lab.sh cleanup
```

The scripts refuse root and unsafe state identity. This is an operational lesson: cleanup authority should be narrower than creation authority, and deletion must target an exact owned object.

### Command 4: check fixture identity and count

```bash
bash lab.sh status
```

The expected count is 49 cases: one admissible baseline plus one ordered failure for each encoded gate. A different count means lesson drift or incomplete state. Stop before interpreting results.

Count is only structural evidence. It does not show that 49 real VM experiments occurred.

### Command 5: inspect claims before accepting a result

```bash
bash lab.sh show baseline
```

The command prints the merged baseline JSON. Read it as a list of synthetic claims: hardware, KVM, machine, image, identity, boot, network, capacity, migration, fencing and service conditions.

This step prevents a common model-testing mistake: seeing `admissible` without knowing which inputs made it so. In production, the equivalent is retaining exact admission inputs and versions.

### Command 6: evaluate the all-pass baseline

```bash
bash lab.sh evaluate baseline
```

Expected boundary:

```text
boundary=admissible-within-model
```

That phrase is intentionally not "production-ready." It means all finite Boolean and value predicates encoded in this model passed. It does not model performance distributions, undocumented device behavior, human error or real recovery.

### Command 7: separate CPU flags from device access

```bash
bash lab.sh evaluate dev-kvm-denied
```

Expected first boundary is `kvm-device-access`. The case keeps earlier claims acceptable and changes the device-access claim, teaching ordered diagnosis:

```text
CPU capability present
  + KVM modules assumed ready
  + /dev/kvm not usable by caller
  = stop at the access boundary
```

In a real environment, investigate device existence, ownership, group membership, ACLs, mandatory access control, container device policy and nested-host exposure. Do not automatically chmod the device world-writable.

### Command 8: reject an incomplete image lineage

```bash
bash lab.sh evaluate qcow2-backing-file-missing
```

Expected boundary is `backing-chain`. The safe response is preservation and read-only graph discovery. Do not rebase, commit, rename or fabricate a base during triage.

If QEMU tools exist in an authorized disposable environment, `qemu-img info --backing-chain IMAGE` can help inspect metadata. It must be run with careful path handling and without simultaneous unsafe modification. That real command is explanatory here, not executed or required by the lab [REF-0900].

### Command 9: reject reused first-boot identity

```bash
bash lab.sh evaluate cloud-init-instance-id-reused
```

Expected boundary is `datasource-identity`. The case teaches that copying an image and changing its VM name does not create a clean instance.

Production correction belongs in the image and provisioning pipeline: sanitize the template deliberately, provide unique datasource identity, and verify generated OS/application identities. Deleting cloud-init state from a running production guest without understanding the datasource can replay configuration and is not a safe generic fix.

### Command 10: reject "Running means ready"

```bash
bash lab.sh evaluate running-means-ready
```

Expected boundary is `boot-observability`. Move through console, kernel, init, provisioning, socket, dependency and external journey evidence. Do not keep restarting a domain merely because the control plane lacks guest proof.

### Command 11: reject an incompatible migration target

```bash
bash lab.sh evaluate destination-cpu-machine-incompatible
```

Expected boundary is `migration-compatibility`. A target with spare CPU and memory is not eligible when the guest-visible CPU or machine contract cannot be preserved.

In a managed real environment, capability comparison, CPU baseline calculation and migration preflight should occur before moving state. Exact commands depend on libvirt/QEMU versions and architecture; do not copy an unversioned migration command into production.

### Command 12: verify every decision and cleanup guard

```bash
bash verify.sh
```

Expected result:

```text
verify=pass cases=49 refusal=true cleanup=true vm_actions=none
```

This proves all 49 deterministic cases, unsafe-artifact refusal and exact cleanup in the supported lab environment. `vm_actions=none` is a reminder of the proof boundary. The verifier does not touch KVM, QEMU, libvirt, disks, bridges, VMs or migration.

### Real-runtime commands: learn their questions before using them

The following are common read-oriented questions in an authorized KVM/libvirt environment. They are not executed by this lesson:

| Question | Typical command family | Main interpretation trap |
|---|---|---|
| What does this connection expose? | `virsh capabilities` | broad capability is not domain-specific compatibility |
| What can this domain type support? | `virsh domcapabilities` | result depends on emulator, architecture, machine and virt type |
| What is live versus next-boot XML? | `virsh dumpxml` with explicit live/inactive choice | default output may not answer the intended state question |
| Why did lifecycle state change? | `virsh domstate --reason` and logs | state reason still does not prove guest/app health |
| What is the image dependency graph? | `qemu-img info --backing-chain` | concurrent mutation and untrusted image handling require caution |
| Is host configuration suitable? | `virt-host-validate` | a passing generic check does not prove this workload |

Before any real command, confirm connection URI, host, domain UUID, privilege, live/config scope, mutation risk and rollback. A correct command against the wrong libvirt connection is still an incident.

## Decision path

### Start from the failed user promise

Write one sentence with scope and time:

> Since 14:05 IST, checkout requests served by VM UUID X after placement on host B fail at the application dependency step; other VMs on B remain healthy.

This is better than "VM down." It identifies the affected operation, object, placement and comparison group.

### Branch 1: is the management object the intended VM?

Confirm the libvirt connection, domain UUID, name-to-UUID mapping, current host and source of truth. Names are human labels and can be reused. If identity is uncertain, do not start, destroy, undefine, migrate or attach storage.

### Branch 2: is the domain active?

If inactive, preserve state reason and logs. Check definition, capabilities, permissions, image graph, firmware/NVRAM, networks and capacity in that order.

If active, do not stop. Move to guest boot evidence.

### Branch 3: did the guest boot?

Use the out-of-band console, guest-agent state if available, and boot timestamps. Classify the first failure:

- firmware/boot target;
- kernel and root device;
- init/userspace;
- instance initialization;
- local networking.

Preserve the earliest error. Later service failures may be consequences.

### Branch 4: is the application locally ready?

Inside the guest or through an approved agent, inspect service state, listener ownership, configuration load, certificates, local request and dependency initialization. "Process exists" is not readiness.

### Branch 5: does the external packet path work?

Choose one failed flow. Observe guest, TAP/bridge, host NIC, upstream policy/load balancer and return path. Compare with a working VM on the same and a different host. This separates guest-specific, host-specific and external failures.

### Branch 6: are storage and data correct?

Confirm the guest sees the intended disks, the block graph is complete, mounts and application data are correct, and writes reach the intended authoritative storage. If two instances may write the same identity or volume, stop and establish fencing/authority.

### Branch 7: can the target safely retain the VM?

Validate CPU/machine/firmware/device compatibility, capacity headroom, storage performance, network parity and failure-domain policy. If the destination violates the contract, rollback or fail forward through an approved plan; do not normalize unsafe placement because the process is running.

### The compact operator flow

```text
user promise failing?
  |
  +-- identify exact domain/connection/host
  |
  +-- inactive? -> reason -> capability -> definition -> artifacts -> resources
  |
  +-- active but guest absent? -> console -> firmware -> kernel -> init
  |
  +-- guest present but app absent? -> config -> socket -> dependencies
  |
  +-- app local but user fails? -> packet path -> LB/DNS -> return path
  |
  +-- stateful ambiguity? -> stop -> fence -> establish authority
  |
  +-- validate user + data -> reconcile source/destination -> close
```

At every branch, state what your evidence proves and what remains unproved.

## Guided Ubuntu lab

### Lab contract

This exercise is safe for the tested Ubuntu 24.04 WSL environment because it uses Python's standard library and UID-scoped temporary state. It makes one read-only capability inventory and evaluates synthetic records.

It will not:

- install or remove packages;
- use `sudo`;
- open `/dev/kvm`;
- execute QEMU or `virsh`;
- create, modify or inspect a real image;
- create a bridge, TAP or firewall rule;
- define, start, stop or migrate a VM;
- contact cloud, Kubernetes, Docker or libvirt endpoints.

### Lab 1: capability is a chain, not a Boolean

From the lesson's `support/lab` directory:

```bash
bash lab.sh doctor
bash lab.sh capability
```

Write down each capability field as one of:

- observed present;
- observed absent/inaccessible;
- not tested;
- unsupported in this environment.

For the verified WSL run:

| Layer | Result | Honest statement |
|---|---|---|
| architecture | `x86_64` | this process reports x86_64 |
| environment | `wsl` | this is not a bare-metal KVM host test |
| CPU flag | present | a virtualization flag is visible |
| `/dev/kvm` | inaccessible | current boundary cannot use the KVM device |
| QEMU/libvirt tools | absent | runtime operation was not possible or attempted |
| cloud-init command | present | command discovery only; no instance run |

Now say this aloud:

> I have evidence of CPU flags. I do not have evidence that this environment can create a KVM VM.

That sentence is the first mastery checkpoint.

### Lab 2: follow ordered failure boundaries

Initialize and inspect:

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

The baseline crosses all encoded gates. Compare four isolated failures:

```bash
bash lab.sh evaluate dev-kvm-denied
bash lab.sh evaluate qcow2-backing-file-missing
bash lab.sh evaluate cloud-init-instance-id-reused
bash lab.sh evaluate running-means-ready
bash lab.sh evaluate destination-cpu-machine-incompatible
```

For each output, complete this four-line incident note:

```text
First failed boundary:
Evidence that supports it:
What is still unknown:
Safest next evidence:
```

Suggested interpretation:

| Case | First boundary | Safest next evidence |
|---|---|---|
| `dev-kvm-denied` | caller cannot use kernel virtualization device | device existence, ownership, ACL/MAC policy and execution identity |
| `qcow2-backing-file-missing` | virtual disk lineage is incomplete | preserve files; inspect full chain and expected base identity read-only |
| `cloud-init-instance-id-reused` | cloned first-boot identity is ambiguous | datasource metadata, cache state and image sanitization contract |
| `running-means-ready` | control-plane state lacks guest/service proof | console, boot stages, app readiness and external journey |
| `destination-cpu-machine-incompatible` | target cannot preserve machine contract | exact source definition and target domain capabilities |

Do not memorize only the boundary names. Explain why later checks would be premature.

### Verify and remove bounded state

The verifier starts from an absent state, runs all 49 cases, tests unsafe-artifact refusal and proves cleanup:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected final line:

```text
verify=pass cases=49 refusal=true cleanup=true vm_actions=none
```

If verification fails, preserve the first failure and do not edit the expected output to make the test green.

### Optional paper exercise: design a real disposable lab

Do not execute this on the current unsupported boundary. Design it on paper for a future dedicated host:

1. Define hardware, firmware, KVM, QEMU and libvirt version prerequisites.
2. Choose an isolated network with no production route.
3. Choose a disposable, verified image and record its digest.
4. Define CPU, machine type, firmware, disk and NIC explicitly.
5. Set CPU, memory and disk quotas.
6. Define serial-console evidence and a tiny guest readiness probe.
7. Define exact teardown and unreferenced-volume checks.
8. Capture proof that the host returned to baseline.

The exercise is complete when another engineer can review the safety contract before any VM exists.

## Production transfer

### Build a supported host profile

A production private cloud needs a versioned host profile, not individually handcrafted servers. The profile should cover:

- hardware and firmware baseline;
- CPU compatibility group and microcode policy;
- operating system, kernel, KVM, QEMU and libvirt versions;
- enabled machine types, firmware and device models;
- time synchronization and logging;
- storage initiators, multipath and mount policy;
- bridges, bonds, VLANs and network filters;
- service identities, permissions and mandatory access controls;
- monitoring, console and fencing agents;
- patch, drain, rollback and re-admission procedure.

After maintenance, re-run admission. A host that was supported before a firmware or package change is not automatically supported after it.

### Treat VM definitions as reviewed code

Generate domain XML or equivalent machine definitions from a typed, validated source. Review changes for:

- live versus restart-required behavior;
- CPU and migration compatibility;
- memory and NUMA effects;
- boot and firmware changes;
- storage source and cache semantics;
- network attachment and security;
- host-device locality;
- recovery and rollback.

Store normalized definitions and policy decisions. Redact or reference secrets rather than embedding them. Validate syntax and domain capabilities before deployment. Use staged rollout and a disposable canary machine contract before broad fleet changes.

### Build an image factory, not a pet template

A trustworthy image pipeline should:

1. start from an authenticated source;
2. pin or record inputs;
3. patch packages and install compatible guest agents/drivers;
4. harden configuration without embedding reusable secrets;
5. remove the exact identities meant to be instance-specific;
6. run boot, initialization and shutdown tests;
7. scan according to security policy;
8. publish immutable artifacts with digest, provenance and expiry;
9. promote through environments;
10. retire old artifacts only after descendant and rollback analysis.

Do not repair drift by logging into the template and "making it golden." Rebuild so the procedure remains reproducible.

### Make provisioning a contract

For every instance, record:

- who allocated domain UUID, MAC, IP and hostname;
- how cloud-init datasource and instance ID are produced;
- which identities the guest generates;
- which secrets are delivered and how they rotate;
- when initialization is complete;
- which retries are safe;
- how failed provisioning is quarantined and cleaned.

Expose a readiness condition that includes required initialization. A VM should not enter a service pool simply because it answers ICMP or the guest agent connects.

### Design storage by recoverable unit

Map each service to its recoverable unit:

```text
machine definition
+ firmware/NVRAM state when required
+ boot/root disk lineage
+ application data volumes
+ application-consistent metadata
+ encryption/key recovery
+ network and identity reconstruction
= restorable service component
```

Choose raw, qcow2, thin volumes and snapshots based on operational needs, not feature count. Monitor both logical promises and physical allocation. Put hard controls around backing-chain depth and mutation. Prove backup through restore, including the time to transfer, boot, reconcile and validate data.

### Design network parity before migration

Every eligible host must implement the same intended network contract:

- bridge or virtual-switch definition;
- VLAN/overlay reachability;
- MTU;
- firewall and network filters;
- DHCP/IPAM behavior;
- routing and reverse path;
- load-balancer registration;
- observability points.

Continuously test parity. A destination should fail admission before migration if it cannot provide the required network.

### Make capacity failure-aware

Capacity planning must answer:

> After the largest supported failure and during recovery, can remaining hosts run the admitted workload inside CPU, memory, storage, network and latency limits?

Track:

- physical cores and scheduling contention, not only vCPU sum;
- memory committed, resident, reclaim and protected reserve;
- NUMA/huge-page pools;
- storage allocated, promised, growth, latency and IOPS;
- network throughput, packet loss and migration bandwidth;
- scarce devices and topology;
- evacuation time before maintenance deadline;
- placement constraints and anti-affinity.

Test the scheduler with host-removal simulations. A cluster-wide percentage can hide one saturated failure domain.

### Engineer migration as a change

Define an approved migration envelope:

- exact source and destination;
- compatible CPU/machine/firmware/device contract;
- storage mode and available space;
- protected transport;
- maximum duration and downtime;
- dirty-rate and bandwidth thresholds;
- application/user guardrails;
- abort and rollback authority;
- destination acceptance checks;
- source cleanup and audit.

QEMU's migration framework explains transferred VM state and migration mechanisms [REF-0901]. libvirt provides management workflows and transport choices [REF-0907]. Neither document can select the correct business downtime or data-consistency policy for your service.

### Separate maintenance mobility from disaster recovery

Live migration handles a planned movement while the source participates. It does not prove recovery from a dead host, lost storage, corrupt image or failed control plane.

Test distinct scenarios:

- planned host drain;
- abrupt host loss with fencing;
- storage path loss;
- management-plane loss;
- corrupted image or configuration;
- recovery from backup in a separate failure domain.

Each has different authority, evidence and time objectives.

### Build HA around fencing and service semantics

Before enabling automatic restart:

1. define membership and quorum;
2. implement independent fencing for every host;
3. prove fencing under management-network failure;
4. reserve placement capacity for supported failures;
5. identify workloads unsafe for blind restart;
6. encode start order and dependency rules;
7. validate application/data state after restart;
8. rehearse partial and ambiguous failures.

For stateless workers, restart may be straightforward. For a database writer, platform restart must coordinate with database authority. "VM HA" cannot replace application consistency design.

### Upgrade as a compatibility campaign

An upgrade can change kernel behavior, QEMU features, machine types, device models, firmware, libvirt defaults and migration compatibility.

Use:

```text
inventory
 -> compatibility matrix
 -> disposable boot tests
 -> mixed-version migration tests where supported
 -> canary host
 -> bounded workload cohort
 -> fleet rollout
 -> old-version retirement
```

Retain a rollback path until representative workloads have rebooted, migrated and passed user/data checks. A package installation success is not an upgrade success.

### Create service-level observability

Build correlated views for:

- host hardware/kernel pressure and errors;
- libvirt lifecycle events and reasons;
- QEMU process/vCPU/memory/block/network behavior;
- storage backend capacity, latency and errors;
- virtual network drops and path health;
- guest boot, clock, filesystem and agent state;
- application readiness, latency, errors and saturation;
- external user journey and data correctness.

Use stable domain UUID and service identity as correlation dimensions. Names and IPs can change.

### Write recovery runbooks with refusal points

A useful runbook says when **not** to proceed:

- identity is ambiguous;
- backing chain is unresolved;
- source fencing is unproved;
- target compatibility is unknown;
- capacity reserve is exhausted;
- data authority is uncertain;
- rollback artifact is missing;
- user/data validation is unavailable.

Refusal is an engineering control. In these states, extra automation can amplify damage.

## Reliability, security, observability, capacity, and cost

### Reliability

Define separate objectives for provisioning, domain availability, guest readiness, migration downtime, host evacuation, backup restoration and user operations. A single "VM uptime" objective hides the boundary that needs improvement.

Measure recovery time from detection through authoritative service restoration, not merely QEMU restart. Measure recovery point at the application/data layer.

### Security

KVM and QEMU process untrusted guest behavior near a privileged host boundary. Reduce attack surface:

- patch the host stack;
- expose only required devices and features;
- isolate QEMU processes with supported permissions and mandatory access controls;
- protect management APIs and migration channels;
- use least-privilege identities;
- restrict host path and device assignment;
- protect image provenance and scan inputs;
- remove embedded secrets from templates;
- audit lifecycle and configuration changes.

libvirt's secure usage guidance emphasizes protected connections and careful authentication/authorization choices [REF-0908]. Do not weaken isolation to make an unexplained permission error disappear.

### Observability

Every alert should name its layer and action:

- "host memory pressure threatens protected reserve" is actionable;
- "VM unhealthy" is not, unless the signal defines guest, app or user evidence.

Correlate monotonic event time where possible, synchronize clocks, and retain console/lifecycle evidence outside the guest. Alert on missing evidence too: no guest heartbeat may be a telemetry failure or a boot failure and should be classified.

### Capacity

Model capacity as constraints and distributions, not one average. Include:

- normal peak;
- maintenance evacuation;
- largest supported failure;
- migration overhead;
- image/snapshot growth;
- backup/restore traffic;
- recovery duration;
- workload co-tenancy and correlated peaks.

Admission control must preserve the promised recovery reserve. Otherwise every successful placement spends future recoverability.

### Cost

Private-cloud cost includes hardware, power, cooling, rack, network, storage, licenses, staff, spares, support, idle recovery reserve and incident risk. High utilization can lower apparent unit cost while increasing tail latency and making host failures unrecoverable.

Optimize total service economics:

- right-size oversized VMs;
- remove abandoned disks and snapshots only after dependency proof;
- standardize supported machine profiles;
- automate evidence and upgrades;
- tier storage by measured need;
- use energy-aware placement only within reliability constraints;
- quantify the cost of recovery reserve as insurance for the SLO.

The cheapest steady state can be the most expensive incident state.

## Traps and prevention

### Trap 1: calling everything the hypervisor

**Why it fails:** hardware, KVM, QEMU, libvirt and the guest have different state and owners. The phrase hides the failing boundary.

**Prevention:** name the component and evidence: "QEMU process active; guest boot unproved."

### Trap 2: treating a CPU flag as a readiness test

**Why it fails:** flags do not prove firmware, modules, `/dev/kvm` access, QEMU, libvirt or domain compatibility.

**Prevention:** use the full capability ladder and stop at the first unproved boundary.

### Trap 3: solving permission errors with broad privilege

**Why it fails:** world-writable devices, root automation or disabled mandatory access controls expand the management and host attack surface.

**Prevention:** determine the intended execution identity and grant the narrow supported access. Preserve isolation controls and audit the change.

### Trap 4: changing XML without naming live or config scope

**Why it fails:** runtime and next-boot state diverge.

**Prevention:** every change plan states `live`, `config` or both, plus restart behavior and post-reboot validation.

### Trap 5: accepting defaults for machine and CPU contract

**Why it fails:** software upgrades or heterogeneous hosts can make defaults differ, breaking reproducibility and migration.

**Prevention:** govern a compatibility baseline and test it across every eligible host/version combination.

### Trap 6: sizing from vCPU and guest memory totals alone

**Why it fails:** scheduling contention, NUMA, reclaim, huge pages, storage, network and failure reserve are ignored.

**Prevention:** use multidimensional admission with observed workload distributions and a simulated failure state.

### Trap 7: adding vCPUs to every slow VM

**Why it fails:** a wider VM can wait longer for scheduling and cross more NUMA boundaries.

**Prevention:** locate CPU demand, scheduling wait, guest bottleneck and application contention first; resize from evidence.

### Trap 8: treating sparse allocation as free capacity

**Why it fails:** promised bytes can exceed physical capacity; synchronized growth exhausts the backend.

**Prevention:** monitor virtual provisioned, physically allocated, reclaimable, growth rate and protected headroom.

### Trap 9: treating a snapshot as a backup

**Why it fails:** it may depend on the same base, metadata, storage and credentials as the original.

**Prevention:** define an independent recoverable copy and prove isolated restore.

### Trap 10: deleting images by age or filename

**Why it fails:** backing relationships are a graph and may not be visually obvious.

**Prevention:** inventory descendants and references read-only, require ownership and retention evidence, then delete exact unreferenced objects.

### Trap 11: cloning identity accidentally

**Why it fails:** multiple layers continue claiming the same machine or application identity.

**Prevention:** publish an identity matrix that assigns regeneration to either image sanitization or provisioning, then test two simultaneous clones.

### Trap 12: putting production secrets in templates

**Why it fails:** every clone receives reusable credentials, and image readers gain broad access.

**Prevention:** deliver short-lived instance-specific credentials at provisioning through an authorized secret path and verify rotation/revocation.

### Trap 13: checking only one side of virtual networking

**Why it fails:** return routes, filters, VLANs and upstream state can fail after the guest transmits successfully.

**Prevention:** trace one flow at every boundary in both directions and compare destination host parity.

### Trap 14: using host model name as migration proof

**Why it fails:** firmware, microcode, exposed CPU features, machine types and QEMU versions can differ within the same marketed server family.

**Prevention:** compare the guest-visible contract using supported capability mechanisms.

### Trap 15: increasing migration downtime until it finishes

**Why it fails:** an unconverged high-dirty-rate migration becomes an unbounded user outage.

**Prevention:** define duration, downtime, throughput and user guardrails before start; abort or use an approved alternative when crossed.

### Trap 16: declaring recovery at `running`

**Why it fails:** guest, network, application, dependencies and data remain unproved.

**Prevention:** require layered destination and external user validation before acceptance.

### Trap 17: automating restart without fencing

**Why it fails:** a partitioned old host can remain active, creating duplicate writers.

**Prevention:** prove independent fencing and quorum behavior, including failure of the normal management path.

### Trap 18: using the backup job as restore evidence

**Why it fails:** missing XML, NVRAM, backing files, keys or ordering appear only during recovery.

**Prevention:** run scheduled, timed, isolated restoration and verify application data.

### Trap 19: observing only from inside the guest

**Why it fails:** boot and networking failures remove the diagnostic channel.

**Prevention:** retain host lifecycle logs, QEMU/libvirt evidence and an out-of-band serial console.

### Trap 20: observing only from the platform

**Why it fails:** green host and domain signals can coexist with failed user operations.

**Prevention:** correlate platform signals with guest, application, external journey and correctness evidence.

### Trap 21: assuming two hosts equal high availability

**Why it fails:** hosts can share rack power, management, storage, network or insufficient recovery capacity.

**Prevention:** map failure domains and simulate the loss of each shared dependency.

### Trap 22: testing a runbook only when an incident happens

**Why it fails:** permissions, artifacts, contacts and commands decay.

**Prevention:** rehearse in disposable environments, timestamp validation and assign owners to every prerequisite.

## Memory card and retrieval

### The seven-word memory chain

When a VM problem arrives, remember:

> **FLAGS -> DEVICE -> MACHINE -> IMAGE -> GUEST -> SERVICE -> USER**

- **FLAGS:** does the CPU view advertise virtualization?
- **DEVICE:** can the intended process use KVM?
- **MACHINE:** can this host realize the exact CPU, firmware and device contract?
- **IMAGE:** is the complete storage lineage present and trusted?
- **GUEST:** did firmware, kernel, init and provisioning complete?
- **SERVICE:** is the application ready with dependencies and correct data?
- **USER:** does the important operation succeed through the external path?

Never skip from FLAGS to USER success, and never stop at MACHINE running.

### The migration memory chain

Use:

> **FIT -> MOVE -> PROVE -> RECONCILE**

- **FIT:** compatibility, capacity, network, storage and safety admission;
- **MOVE:** bounded transfer with dirty-rate, duration and downtime guardrails;
- **PROVE:** guest, application, user and data validation at destination;
- **RECONCILE:** source state, image graph, monitoring, inventory and capacity.

### The HA memory chain

Use:

> **DECIDE -> FENCE -> PLACE -> RESTORE -> VERIFY**

Authority comes before restart. If fencing is unproved, do not allow availability pressure to create two writers.

### Five-minute retrieval drill

Without looking back, answer:

1. What does `vmx` or `svm` prove?
2. What is the difference between KVM, QEMU and libvirt?
3. Why can a qcow2 overlay be small but operationally critical?
4. Which identities must a clone evaluate?
5. Why can `running` coexist with user outage?
6. Why might live migration fail to converge?
7. What must be proved before HA restarts a stateful VM?

Then draw the execution stack and packet path from memory. Retrieval strengthens operational recall more than rereading.

### One-day and one-week practice

After one day, explain a "running but unavailable" incident using the seven-word chain. After one week, solve the independent transfer without looking at the complete answers. Record which boundary you skipped; that is the topic to revisit.

## Complete answers

### 1. What exactly do KVM, QEMU and libvirt each do?

KVM is a Linux kernel interface for creating and running virtual CPUs and memory with hardware assistance. QEMU is the userspace virtual machine monitor that constructs the guest-visible computer, including device and block models, and can use KVM as an accelerator. libvirt is the management API and driver layer that represents domains, networks and storage and controls lifecycle.

A concise interview answer is: "KVM accelerates execution, QEMU builds the machine, and libvirt manages the machine." Then add the limit: an active QEMU process still does not prove guest or service readiness.

### 2. What does a visible `vmx` or `svm` flag prove?

It proves that the CPU interface visible to the current environment advertises a virtualization feature flag. It does not prove the host firmware enabled usable virtualization, the KVM modules are present, `/dev/kvm` exists, the caller has permission, nested virtualization is supported, QEMU/libvirt is installed or a particular domain is compatible.

The next evidence should be the next rung, not a conclusion: environment/firmware, modules, device/access, runtime and exact machine compatibility.

### 3. Why can a domain be `running` while the service is down?

`running` is a lifecycle observation about the managed VM execution. QEMU may be alive while:

- firmware cannot select a valid boot device;
- the guest kernel cannot mount root;
- init or cloud-init is blocked;
- networking is wrong;
- the application failed configuration or dependency initialization;
- the external load balancer or return path is wrong;
- the application is serving incorrect data.

Prove each layer independently: lifecycle -> console/boot -> guest -> application -> external journey -> correctness.

### 4. What is persistent versus live domain configuration?

Persistent configuration describes what a defined domain should use on a future start. Live configuration describes the currently active machine. A supported hot-plug may affect live state only, while an edit may affect next boot only.

Before changing anything, state the intended scope. After change, compare both views and verify behavior after the required reboot. Otherwise the fix can disappear or remain dormant.

### 5. Why do CPU model and machine type matter?

The CPU model controls which processor features the guest can rely on. The machine type controls the virtual chipset, buses and compatibility behavior. They are guest-facing interfaces.

Floating defaults can change after a host or QEMU upgrade. Host-passthrough can expose features unavailable on a migration target. A production pool therefore governs explicit compatible contracts, verifies domain capabilities across eligible hosts and upgrades those contracts deliberately.

### 6. Can adding vCPUs make a VM slower?

Yes. More vCPUs create more runnable threads and can make coordinated scheduling harder under contention. A wider topology may cross NUMA nodes, increasing remote memory access. The application may also be single-threaded or blocked on storage, locks or dependencies.

Inspect guest CPU demand, host scheduling delay/steal, per-vCPU use, NUMA placement and application profiles. Right-size from evidence. vCPU count is a promise of virtual processors, not a reservation of simultaneous physical execution.

### 7. Why are guest memory and host memory not the same?

The guest sees configured memory. The QEMU process has resident and virtual mappings. The host also needs memory for its kernel, device emulation, page cache, networking, migration and control services. Ballooning, huge pages, deduplication or swap can further change the relationship.

Capacity must protect host reserve and workload latency under normal peaks, maintenance and failure. Summing configured guest memory alone is necessary but insufficient.

### 8. Explain a qcow2 backing chain in simple terms

An overlay is a notebook of changes placed over a reference book. For a changed block, read the notebook. For an unchanged block, follow the backing reference to the book, possibly through more layers.

The small overlay is not a complete disk. Removing or changing its base can make many VMs unreadable. Inventory the full graph and exact artifact identities before moving or deleting anything. A chain inspection proves metadata relationships, not guest filesystem consistency.

### 9. Why is a snapshot not automatically a backup?

A snapshot often shares storage, control plane, credentials and backing data with the source. If that failure domain is lost or the chain is corrupted, both original and snapshot can disappear.

A backup has an independently retained recoverable unit, retention and integrity policy, and tested restoration. The only convincing backup evidence is a restore that boots the required machine state and validates application data within the recovery objective.

### 10. What must be unique after cloning a VM?

Start with domain UUID, virtual NIC MAC, IP/DHCP identity, writable NVRAM, Linux machine ID, SSH host keys, cloud-init instance identity, monitoring identity, certificates and application/cluster node identity. Disk/filesystem UUIDs need deliberate treatment based on how volumes are used.

Not every identifier must always change, but every one needs an owner and rule. The image pipeline sanitizes selected source state; provisioning generates instance-specific state; validation boots two clones simultaneously and proves no collision.

### 11. Why can cloud-init skip or replay configuration?

cloud-init uses datasource and instance identity plus cached state to decide whether it is seeing the same instance and which stages should run. A clone that retains cache and receives reused metadata can skip intended first-boot work. A running instance whose identity/cache is changed carelessly can replay initialization.

Fix the image/provisioning contract: sanitize before sealing, provide unique stable metadata per instance, make appropriate operations idempotent and use cloud-init stage evidence as part of readiness.

### 12. How do you troubleshoot a VM networking failure?

Choose one flow with source, destination, protocol, port and timestamp. Validate:

1. application listener and guest route/firewall;
2. virtual NIC counters;
3. QEMU/vhost and TAP;
4. host bridge or virtual switch, VLAN and filters;
5. host NIC and physical/overlay network;
6. router, firewall, load balancer or dependency;
7. the complete return path.

Observe both directions and compare a working VM on the same host and another host. This isolates guest, host and fabric scope. An assigned IP alone proves none of the later boundaries.

### 13. What must pass before live migration?

Preflight the exact source and destination:

- domain identity and authoritative source;
- CPU model/features, machine type, emulator, firmware and devices;
- destination memory, NUMA, huge pages and scarce devices;
- storage identity, access, allocation and free-space ceiling;
- network parity and policy;
- libvirt/QEMU compatibility and supported migration method;
- protected transport;
- effective bandwidth versus workload dirty rate;
- maximum duration and downtime;
- user/data guardrails, abort, rollback and cleanup.

After the mechanism completes, prove destination guest, application, user and data state. Migration completion alone is not recovery.

### 14. Why does dirty rate control migration convergence?

During pre-copy migration, memory is copied while the guest continues running. Pages changed after copying become dirty and need transfer again. If the guest dirties memory nearly as fast as effective throughput copies it, the remaining set does not shrink quickly enough.

Measure both rates under representative load. Define a time and downtime budget before starting. Options such as workload quiescence, controlled throttling, post-copy or cold migration have different availability and failure risks and require explicit support and approval. Never improvise an unlimited downtime increase.

### 15. What does N+1 capacity really mean?

It means the platform can lose one declared unit and still place and run admitted demand inside all required limits. The unit might be a host, rack, power domain or storage component. CPU totals alone are insufficient.

For the diagnostic fleet, twelve VMs request `12 x 4 = 48` vCPU and `12 x 16 = 192 GiB`. One surviving host has 32 logical CPUs and 128 GiB raw memory. The memory request already exceeds raw survivor capacity before host/QEMU/cache/recovery overhead. Therefore the two-host design is not N+1 for the admitted fleet.

### 16. Why is fencing required for HA?

After loss of communication, the controller may not know whether a host is dead or isolated. Starting the same stateful VM elsewhere while the old host still writes can corrupt shared state and duplicate network/application identity.

Fencing establishes authority by proving or forcing that the old member cannot continue the protected action. It should use an independent path and be tested under the same management failures it is meant to resolve. If fencing cannot be proved, safe automation refuses restart.

### 17. What makes a virtualization platform multi-tenant safe?

No single control is enough. Combine:

- authenticated, encrypted, least-privilege management;
- isolated QEMU processes and protected devices/files;
- controlled images and secret delivery;
- network segmentation and anti-spoofing;
- storage ownership and encryption;
- quotas and admission for CPU, memory, I/O and object counts;
- noisy-neighbor telemetry;
- immutable audit outside the change authority;
- tenant-aware backup, deletion and incident processes.

Then test escape, cross-tenant data exposure and resource-exhaustion assumptions in an authorized security program.

### 18. What evidence closes a VM incident?

Closure needs:

1. exact affected user promise and time window;
2. authoritative domain, host, definition and artifact identity;
3. first failed boundary and root cause;
4. safe containment and authority proof;
5. guest, application, external journey and data validation;
6. source/destination and temporary-artifact cleanup;
7. restored capacity/monitoring;
8. owned preventive action with retest;
9. explicit statement of what remains unproved.

"VM restarted" is an action. It is not an incident conclusion.

### 19. Solve the two-host diagnostic completely

The system has two compute nodes but a single rack, power, management-switch and writable-NFS failure domain. It cannot claim independence from any of those shared failures.

The admitted request is 48 vCPU and 192 GiB. One survivor provides 32 logical CPUs and 128 GiB before host reserve, so full one-host recovery is impossible on memory alone. Logical CPUs also do not guarantee the required workload throughput.

Floating CPU and machine defaults make compatibility depend on current host and software versions. Manually copied overlays can reference missing or incorrect backing files. Duplicate domain UUID, MAC, writable NVRAM, machine ID, SSH keys and cloud-init cache collapse identities across management, network, firmware and guest layers. Root over an unencrypted management channel creates excessive control-plane exposure. An incompatible CPU and nearly full destination thin pool should have rejected migration before state moved.

Immediate response:

1. stop further migrations, automated restart and duplicate guest activity;
2. preserve source/destination XML, capabilities, logs, image-chain metadata and audit events;
3. isolate the clone's network and prevent concurrent storage/NVRAM writes;
4. establish one authoritative domain and verified image chain;
5. choose a compatible host with proven capacity and network/storage access;
6. restore or start through an approved recovery path;
7. validate unique guest identity, cloud-init result, filesystems, network, application and user flow;
8. reconcile stale definitions, overlays, NVRAM, monitoring and capacity.

Redesign with real failure-domain placement; admission and reserve; explicit CPU/machine contracts; validated unique definitions; controlled qcow2 lineage; sanitized immutable templates; fresh per-instance identity; encrypted least-privilege control; migration compatibility/capacity/dirty-rate/downtime guardrails; independent fencing; restore tests; and service-level readiness.

HA may then mean a named service survives a named failure within measured recovery and correctness bounds. It can never mean "we own two hosts."

### 20. Design the platform in one senior-level answer

Start with workload contracts: user operations, correctness, availability, latency, RPO/RTO, isolation and lifecycle. Admit only hosts matching a versioned hardware, firmware, kernel, KVM, QEMU, libvirt and capability profile. Validate versioned domain definitions against schema and target domain capabilities, with explicit CPU/machine/firmware/devices and unique identity.

Build immutable images with provenance, declared format, controlled backing lineage, sanitized templates and per-instance cloud-init identity. Design storage as a recoverable unit and prove independent restoration. Trace and govern the entire guest-to-user network path. Protect management and migration with least privilege, encryption, confinement and audit.

Place by real failure domains and multidimensional capacity with protected recovery reserve. Bound overcommit and noisy neighbors through workload evidence. Treat migration as a guarded change with compatibility, storage, network, dirty-rate, downtime, abort, authority and user validation. Treat HA as detection plus fencing plus eligible capacity plus measured service recovery. Canary upgrades, preserve rollback compatibility, correlate every layer, and refuse ambiguous identity, unsupported capability, unsafe shared writes, insufficient reserve, insecure control or unproved recovery.

## Product-company interview

### Scenario 1: "A VM is running but the API is unavailable. Walk me through it."

**Strong answer:** I first define the failed user operation, scope and start time, then confirm the exact libvirt connection, domain UUID and host. Running proves only VM execution state. I check console and guest boot, provisioning completion, application process/listener, dependency initialization, local request, then trace one external flow through guest NIC, TAP/bridge, host fabric, load balancer and return path. I correlate storage and data correctness, compare a working peer and preserve the first error. I close only after a representative external request and invariants succeed.

**What the interviewer is testing:** whether you debug layers instead of restarting blindly.

### Scenario 2: "How would you migrate between different CPU generations?"

**Strong answer:** I define the intended migration pool, calculate or choose a supported guest-visible CPU baseline across it, and govern machine type, emulator, firmware and devices. I compare exact domain capabilities on source and destination, then test representative guests under mixed versions in a disposable environment. Host-passthrough is acceptable only if mobility is not required or the destination contract is proven compatible. Preflight also includes storage, network, memory/NUMA, bandwidth, dirty rate, security, downtime and rollback. Success requires service validation after movement.

**Red flag answer:** "They are the same vendor, so live migration will work."

### Scenario 3: "Would you use qcow2 or raw?"

**Strong answer:** I would ask about snapshot/clone workflow, storage backend, performance, portability, operational tooling and recovery. qcow2 provides useful copy-on-write features but introduces allocation and backing-chain management. Raw is simpler and may fit backends that already provide snapshots/thin provisioning. The decision is not a universal performance slogan. I benchmark the workload on the intended backend and design capacity, lineage, backup and restore controls for the chosen stack.

### Scenario 4: "A host is at 40 percent CPU. Why are VMs slow?"

**Strong answer:** aggregate average hides scheduling and locality. I inspect per-vCPU demand, host run queue/scheduling delay, steal inside guests, wide-VM topology, NUMA placement, memory pressure/reclaim, storage latency, network and application locks. One busy physical core or contended NUMA node can hurt a VM while host average remains low. I compare affected and unaffected VMs by placement and user latency, then right-size or move only after identifying the constraining resource.

### Scenario 5: "How would you make a two-host cluster highly available?"

**Strong answer:** I would first challenge whether two hosts can meet the declared failure. I map rack, power, switch, management and storage dependencies; calculate whether one survivor can carry workload plus overhead; and test every hard placement constraint. I define quorum and independent fencing so one host is authoritative before restart. I protect storage/network identity, encode workload recovery order, and validate guest, application, user and data state. If one host lacks capacity or shared storage/power is the dominant failure domain, the design cannot honestly meet that HA claim.

### Scenario 6: "What belongs in a golden image?"

**Strong answer:** A reproducibly built OS, patches, approved packages, compatible virtio/guest agents, baseline hardening and test evidence. It should carry provenance and digest but not production secrets or instance identities. Before sealing, I deliberately sanitize machine ID, SSH host keys, cloud-init cache, leases, logs and application identity according to the contract. Provisioning then creates unique stable identity, and a test launches two clones simultaneously to prove uniqueness and readiness.

### Scenario 7: "A live migration is taking too long. What do you do?"

**Strong answer:** I compare effective migration throughput with guest dirty rate and check the pre-agreed duration/downtime and user guardrails. I do not keep extending downtime without authority. Depending on supported design, I abort, reschedule for a lower-write phase, quiesce or throttle safely, or use an approved alternate migration mode. I preserve source/destination authority and validate service after any action. The prevention is preflight measurement and a documented non-convergence path.

### Scenario 8: "How do you secure libvirt?"

**Strong answer:** I inventory connection paths and trust boundaries; remove unnecessary remote exposure; require authenticated encrypted transport where remote management is needed; use separate least-privilege human and automation identities; protect sockets, disks, host devices and secrets; confine QEMU with supported OS controls; audit lifecycle/configuration operations outside the change authority; and rotate credentials. I also secure migration traffic and image provenance. I never solve access errors by making `/dev/kvm` or management sockets broadly writable.

### Scenario 9: "What would you monitor?"

**Strong answer:** I correlate host hardware/kernel pressure, libvirt lifecycle events/reasons, QEMU vCPU/memory/block/network behavior, storage backend capacity/latency, bridge/TAP/fabric drops, guest boot/time/filesystem state, application readiness/saturation and external user operations. Stable domain UUID and service identity join the layers. Alerts name the boundary and action. I separately measure provisioning, migration downtime, fencing, boot, initialization, recovery and restoration.

### Scenario 10: "How do you know a backup works?"

**Strong answer:** I restore the complete recoverable unit into an isolated environment using documented identities, XML, firmware/NVRAM when needed, image chain or volumes, keys and network reconstruction. I measure recovery time, boot, validate filesystems and application data, then run a user-level check. A green copy job or snapshot list is inventory evidence, not recoverability evidence.

### What excellent candidates do differently

They:

- make proof boundaries explicit;
- calculate capacity instead of using adjectives;
- identify authority and single-writer risk;
- connect platform health to user and data outcomes;
- discuss rollback, cleanup and retest;
- state the versions, topology and workload to which a claim applies;
- refuse operations when identity, compatibility or fencing is ambiguous.

That is the difference between someone who can operate a demo and someone trusted with a private cloud.

## Independent transfer and rubric

### Your reviewer-owned challenge

Open `ASM-0213` in the lesson assessment interface only when you are ready to work without model answers. It is intentionally answer-isolated: this manuscript, the lab and the other assessments do not contain its specific solution.

Produce an evidence packet that another senior engineer can review. At minimum include:

- the user/service contract and failure scope;
- a layer and ownership map;
- host and domain capability reasoning;
- CPU, machine, memory/NUMA and capacity decisions;
- image, identity, cloud-init and storage lineage;
- network path and tenant/security boundaries;
- migration, fencing, recovery and cleanup decisions;
- observability and proof limits;
- a short incident communication;
- explicit refusal conditions.

### Scoring boundary

The independent rubric totals 100 points. A high score requires observable reasoning, calculations and evidence, not a list of product names. Mastery still requires reviewer-owned evidence; reading this lesson or receiving `verify=pass` cannot award it.

Use this self-review before submission:

| Check | Pass condition |
|---|---|
| Outcome | names a user operation and correctness condition |
| Layers | separates hardware, KVM, QEMU, libvirt, guest, app and user |
| Identity | accounts for every copied or generated identity |
| Capacity | calculates declared failure reserve across hard constraints |
| Storage | draws complete lineage and independent recovery |
| Network | traces both directions across guest and host boundaries |
| Security | applies encrypted least privilege and isolation |
| Migration | includes compatibility, rate, downtime, authority and abort |
| HA | puts fencing before restart |
| Evidence | states proves/does-not-prove and retains artifacts |
| Cleanup | proves no stale domain, image, NVRAM or network state |
| Claim | bounds conclusion to versions, topology, load and time |

### When to ask for review

Ask after you can defend every design choice and show how you would falsify your own conclusion. If a key fact is unavailable, label it unknown and make it a refusal or next-evidence condition. Invented certainty scores worse than an honest boundary.

## References and review

### Primary source map

**[REF-0898] Linux kernel: KVM API**

Use this for the userspace/kernel interface: system, VM and vCPU file descriptors, ioctls and capability mechanics. It supports the statement that KVM is an execution interface and access boundary. It does not define a complete QEMU machine, libvirt policy, HA system or application readiness.

https://docs.kernel.org/virt/kvm/api.html

**[REF-0899] QEMU system emulation introduction**

Use this to understand QEMU system emulation, virtual hardware and accelerator relationships. It supports the KVM/QEMU boundary. It does not prove that a particular host, binary or guest is supported.

https://www.qemu.org/docs/master/system/introduction.html

**[REF-0900] QEMU disk image documentation**

Use this for image formats, qcow2 behavior, backing files and image-tool concepts. It supports the storage-graph model. It does not turn an image snapshot into an application-consistent backup.

https://www.qemu.org/docs/master/system/images.html

**[REF-0901] QEMU migration framework**

Use this for QEMU migration state and framework concepts. It supports dirty-state and migration-mechanism explanations. It does not select a safe business downtime, transport or recovery policy.

https://www.qemu.org/docs/master/devel/migration/main.html

**[REF-0902] libvirt project goals**

Use this for libvirt's management abstraction and design intent. It helps distinguish management from the underlying hypervisor/runtime. It does not prove any deployed control plane is secure or highly available.

https://libvirt.org/goals.html

**[REF-0903] libvirt API concepts**

Use this for connections, objects, domains and API-level lifecycle concepts. It supports the managed-object model. Exact driver and version behavior must still be verified.

https://libvirt.org/api.html

**[REF-0904] libvirt domain XML**

Use this as the authoritative field reference for domain definitions, including CPU, memory, firmware and devices. It supports treating XML as a machine contract. Syntax-valid XML still requires capability and runtime validation.

https://libvirt.org/formatdomain.html

**[REF-0905] libvirt network XML**

Use this for libvirt virtual-network definition fields and modes. It supports the managed network portion of the packet path. It does not document every host firewall, physical fabric or external load-balancer behavior.

https://libvirt.org/formatnetwork.html

**[REF-0906] libvirt storage pool and volume XML**

Use this for libvirt-managed storage object configuration. It supports the pool/volume terminology. Durability, allocation and recovery guarantees remain properties of the backing storage and procedure.

https://libvirt.org/formatstorage.html

**[REF-0907] libvirt migration**

Use this for libvirt migration models, connections and operational modes. It supports distinguishing transports and shared/non-shared storage workflows. Validate the exact version, driver and security boundary before use.

https://libvirt.org/migration.html

**[REF-0908] libvirt secure usage**

Use this for libvirt connection and access-security considerations. It supports encrypted, authenticated and least-privilege management. A secure transport alone does not make an overprivileged authorization model safe.

https://libvirt.org/kbase/secureusage.html

**[REF-0909] libvirt host capabilities XML**

Use this for the capabilities reported by a virtualization connection/host. It supports host admission inventory. A broad capability document does not prove a specific domain definition can run.

https://libvirt.org/formatcaps.html

**[REF-0910] libvirt domain capabilities XML**

Use this for support information scoped to an emulator, architecture, machine and virtualization type. It supports exact domain admission. It still does not prove workload performance or application recovery.

https://libvirt.org/formatdomaincaps.html

**[REF-0911] cloud-init boot stages**

Use this for cloud-init boot sequencing and initialization-stage concepts. It supports including instance initialization in readiness. Datasource behavior and configuration must be verified for the actual environment.

https://docs.cloud-init.io/en/latest/explanation/boot.html

**[REF-0912] libguestfs virt-sysprep manual**

Use this to understand guest-image preparation operations and their selectable effects. It supports deliberate template sanitization. Never run it against a live or unreviewed image; choose operations from the exact version's documentation.

https://libguestfs.org/virt-sysprep.1.html

### Source use and limitations

All references are primary project or kernel documentation reviewed on 2026-08-07. They ground interfaces and terminology, not the behavior of this workstation or a hypothetical private cloud.

This lesson has these explicit limits:

- the WSL observation found CPU flags but no accessible `/dev/kvm` and no QEMU/libvirt command set;
- no packages, images, domains, networks, storage pools, migrations or fencing systems were created or changed;
- the lab is a deterministic decision-order model;
- performance, security and migration behavior depends on exact hardware, firmware, kernel, QEMU, libvirt, image, guest and workload versions;
- formal technical, security and instructional review remains required;
- real mastery requires a representative disposable runtime and reviewer-owned evidence;
- delayed recall and production judgment are not proven by reading completion.

### Review cadence

Re-review this lesson by 2027-02-07 or sooner when:

- Linux KVM, QEMU, libvirt, cloud-init or libguestfs documentation changes materially;
- the supported host or guest architecture changes;
- machine, firmware, image or migration policy changes;
- a new failure mode appears in an incident or exercise;
- the lab schema, safety boundary or curriculum prerequisites change.

When reviewing, re-resolve every source, rerun schemas and lab verification, test representative supported runtime separately, and keep observed evidence distinct from documentation claims.
