---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0091",
  "slug":"private-cloud-reliability-capstone",
  "aliases":["V11-L04","private-cloud-reliability-capstone"],
  "curriculumIds":["CAP-004"],
  "route":"/book/capstones/private-cloud-reliability-capstone",
  "order":4,
  "volume":"11-capstones",
  "title":"Private-cloud reliability capstone: one VM, every authority, honest failure domains",
  "summary":"Connect physical racks, KVM/libvirt, OpenStack control state, OVN networking, Ceph storage, capacity, security, upgrades and recovery through one protected workload.",
  "domain":"capstone-engineering",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0090"],
  "prerequisiteCurriculumIds":["PRV-001","PRV-002","PRV-003","PRV-004","PRV-005","SRE-002","DR-001","SEC-001","ARC-001"],
  "testedEnvironments":[
    {"platform":"Windows and Ubuntu","version":"Windows 11 host, Ubuntu 24.04 WSL and Python 3.12","support":"required","notes":"Seventeen tests and the twelve-scenario absent-to-absent simulator verifier pass as a normal user."},
    {"platform":"Private-cloud components","version":"OpenStack 2026.1 concepts with current KVM/libvirt/QEMU/OVN/Ceph/Redfish references","support":"concept-only","notes":"The project invokes no virtualization, OpenStack, Ceph, OVN, BMC, SSH, socket or subprocess client."},
    {"platform":"Production private cloud","version":"not executed","support":"concept-only","notes":"No real packet, VM, object, PG, quorum, migration, upgrade, restore, capacity, SLO or mastery claim exists."}
  ],
  "targetRoles":["site-reliability-engineer","platform-engineer","private-cloud-engineer","infrastructure-engineer","production-engineer","staff-engineer"],
  "learningObjectives":[
    "Trace one protected VM operation through identity, allocation, compute, network, storage, hardware and user validation.",
    "Separate logical labels and component status from physical failure-domain and end-to-end evidence.",
    "Choose restart, migration, evacuation, rebuild, restore or reconciliation from the failed state authority.",
    "Calculate quorum, compatible compute reserve, protected storage capacity and recovery headroom.",
    "Design staged security, maintenance and upgrade gates without converting simulation into production claims."
  ],
  "productionSignals":[
    "Nova says ACTIVE while the user operation or large-packet path fails.",
    "Placement inventory exists but generations, allocations or compatible spare capacity disagree.",
    "Ceph accepts writes while redundancy, client latency or recovery headroom is unsafe.",
    "OVN northbound intent exists while chassis, gateway or underlay realization is broken.",
    "A backup or BMC request exists but restore or asynchronous task outcome was never reconciled."
  ],
  "diagrams":[
    {"id":"LES-0091-DIA-001","title":"One protected VM across private-cloud authorities","direction":"left-to-right","boundaries":["identity and policy","Placement","Nova cell","KVM/libvirt","Ceph","Neutron/OVN","gateway and underlay","user operation"],"evidencePoints":["request identity","allocation generation","server/host identity","domain state","volume/object identity","port/chassis/flow","packet path","application result"],"textAlternative":"A protected workload crosses policy, capacity, lifecycle, runtime, storage and network authorities before the user operation can be called successful."},
    {"id":"LES-0091-DIA-002","title":"Physical failure domains beneath logical labels","direction":"hierarchical","boundaries":["site","rack and PDU","leaf network","controllers","computes and gateways","Ceph hosts and OSDs"],"evidencePoints":["inventory identity","power domain","network domain","quorum member","allocation","CRUSH location"],"textAlternative":"Logical cells, aggregates, availability zones and CRUSH rules protect nothing unless their members map truthfully to independent physical domains."},
    {"id":"LES-0091-DIA-003","title":"Intent to packet realization","direction":"left-to-right","boundaries":["Neutron API","OVN northbound","northd","OVN southbound","chassis controller","Open vSwitch","Geneve underlay","gateway"],"evidencePoints":["port/router intent","revision","logical flow","chassis binding","local flow","tunnel/MTU","route/neighbor","user probe"],"textAlternative":"Network API success proves intent acceptance; each controller and physical hop still needs evidence before the application path is proven."},
    {"id":"LES-0091-DIA-004","title":"Recovery is state-class reconciliation","direction":"left-to-right","boundaries":["failure scope","writer fencing","isolated recovery","authority comparison","user validation","promotion"],"evidencePoints":["host/task identity","server/allocation/port/volume","backup digest","guest/application result","residual risk","approval"],"textAlternative":"Recovery preserves evidence, fences ambiguous writers, restores each authority separately, reconciles identities and promotes only after the user operation passes."}
  ],
  "commands":[
    {"id":"LES-0091-CMD-001","question":"Are the topology and workload contracts internally safe?","risk":"read-only","command":"python cloudctl.py check","runFrom":"support/project as a normal user","expectedBranches":[{"when":"check=pass authority=local-simulation-only","meaning":"strict inputs and deterministic baseline satisfy implemented invariants","nextEvidence":"initialize the disposable runtime"},{"when":"status=refused","meaning":"identity, schema, path, quota, MTU, protection or capacity validation failed","nextEvidence":"preserve the first message and repair the declared input"}],"proves":"bounded contract validity","doesNotProve":"real infrastructure state or production readiness","cleanup":"No runtime is created."},
    {"id":"LES-0091-CMD-002","question":"Can the bounded baseline be created?","risk":"mutating-bounded","command":"python cloudctl.py initialize","runFrom":"support/project with .runtime absent","expectedBranches":[{"when":"initialize=pass","meaning":"an owned descriptor and receipt directory were created","nextEvidence":"run python cloudctl.py baseline"},{"when":"status=refused","meaning":"authority, ownership or input guard stopped mutation","nextEvidence":"do not bypass the guard"}],"proves":"one owned local runtime","doesNotProve":"Nova, libvirt or infrastructure creation","cleanup":"Run python cloudctl.py cleanup after evidence capture."},
    {"id":"LES-0091-CMD-003","question":"What is the safe decision for a rack failure?","risk":"mutating-bounded","command":"python cloudctl.py scenario rack-loss","runFrom":"support/project after baseline","expectedBranches":[{"when":"result=degraded","meaning":"minimum modeled paths survive with reduced margin","nextEvidence":"inspect quorum, replicas, gateway and recovery requirements"},{"when":"status=refused","meaning":"baseline or runtime ownership is unproved","nextEvidence":"stop and inspect"}],"proves":"implemented rack-loss decision logic","doesNotProve":"real rack-loss behavior or recovery time","cleanup":"Scenario receipt is removed by exact cleanup."},
    {"id":"LES-0091-CMD-004","question":"Does the full local decision matrix pass?","risk":"mutating-bounded","command":"python verify.py","runFrom":"support/project with .runtime absent","expectedBranches":[{"when":"verify=pass scenarios=12 cleanup=absent","meaning":"tests, decisions, dossier and cleanup matched the contract","nextEvidence":"review outcomes and proof limits"},{"when":"verify=refused or exception","meaning":"a safety or evidence invariant changed","nextEvidence":"preserve first failure and use only guarded cleanup"}],"proves":"one absent-to-absent simulator lifecycle","doesNotProve":"real component behavior, scale or mastery","cleanup":"Verifier performs exact owned cleanup."},
    {"id":"LES-0091-CMD-005","question":"Can cleanup prove ownership?","risk":"destructive-disposable","command":"python cloudctl.py cleanup","runFrom":"support/project with a matching descriptor","expectedBranches":[{"when":"cleanup=pass runtime=absent","meaning":"only allowlisted generated artifacts were removed","nextEvidence":"independently confirm .runtime is absent"},{"when":"unknown file or descriptor mismatch","meaning":"ownership is unproved","nextEvidence":"stop and never broaden deletion"}],"proves":"exact project cleanup","doesNotProve":"general host or infrastructure hygiene","cleanup":"Terminal cleanup refuses broad deletion."}
  ],
  "labs":[
    {"id":"LES-0091-LAB-001","title":"Guided private-cloud state and failure-domain decision lab","mode":"guided","environment":"Ubuntu 24.04 WSL or Windows Python 3.12","timeMinutes":240,"privilege":"normal user; no sudo, infrastructure endpoint, credential or real identifier","network":"no network client or external call","changes":["project-local .runtime","baseline receipt","twelve scenario receipts","generated design dossier"],"abortConditions":["root","unsafe path","identity mismatch","unknown file","descriptor tampering","real endpoint or credential","attempted infrastructure command"],"recovery":"Preserve the first failure and use only descriptor-gated cleanup.","cleanupProof":"Verifier ends with .runtime absent and adversarial tests prove unknown artifacts block deletion.","path":"drafts/LES-0091-private-cloud-reliability-capstone/support/project"},
    {"id":"LES-0091-LAB-002","title":"Independent private-cloud architecture and hidden-fault transfer","mode":"independent","environment":"Fresh clone and reviewer-selected synthetic topology, operation and hidden faults","timeMinutes":240,"privilege":"normal user and independent reviewer; no answer key or real infrastructure","network":"offline deterministic inputs only","changes":["new synthetic contracts","reviewer fault sheet","learner dossier","bounded evidence"],"abortConditions":["guided-copy topology","known fault sheet","real address or credential","unsafe cleanup","unsupported production claim","unfenced ambiguous writer"],"recovery":"Reviewer stops unsafe work and learner restores only named disposable state.","cleanupProof":"Reviewer confirms exact absence and no external or infrastructure call.","path":"drafts/LES-0091-private-cloud-reliability-capstone/support/project"}
  ],
  "incidents":[
    {"id":"LES-0091-INC-001","signal":"Server is ACTIVE but representative traffic fails.","firstThought":"Lifecycle state and user-path state disagree.","safePath":"Trace port, chassis, flow, tunnel, gateway and application evidence.","trap":"Reboot the VM until status changes."},
    {"id":"LES-0091-INC-002","signal":"One rack is lost and quorum survives.","firstThought":"Minimum control paths may remain while redundancy and capacity are degraded.","safePath":"Freeze new risk, validate the user path and restore one domain at a time.","trap":"Call the platform healthy because two members remain."},
    {"id":"LES-0091-INC-003","signal":"Placement rejects a stale generation.","firstThought":"Another allocation changed the provider; capacity must be recalculated.","safePath":"Reload inventory and retry bounded selection.","trap":"Edit the database or ignore generation."},
    {"id":"LES-0091-INC-004","signal":"Ceph is writable but degraded and near full.","firstThought":"Availability, durability margin, recovery load and capacity are separate risks.","safePath":"Protect client SLO and recovery space before new demand or maintenance.","trap":"Lower min_size or maximize recovery blindly."},
    {"id":"LES-0091-INC-005","signal":"Live migration cannot converge or target compatibility differs.","firstThought":"Maintenance path violates bandwidth, dirty-rate or machine/device contract.","safePath":"Abort safely and choose compatible migration or reviewed cold recovery.","trap":"Force completion without application and failure-risk review."},
    {"id":"LES-0091-INC-006","signal":"BMC power request times out after returning a task.","firstThought":"Outcome is ambiguous, so repeating the action can be harmful.","safePath":"Poll task and re-read exact system power and boot identity before another action.","trap":"Send power-cycle again."}
  ],
  "assessmentIds":["ASM-0256","ASM-0257","ASM-0258"],
  "referenceIds":["REF-1160","REF-1161","REF-1162","REF-1163","REF-1164","REF-1165","REF-1166","REF-1167","REF-1168","REF-1169","REF-1170","REF-1171","REF-1172","REF-1173","REF-1174","REF-1175","REF-1176","REF-1177","REF-1178","REF-1179"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "The project is a deterministic decision simulator and invokes no virtualization, OpenStack, Ceph, OVN, BMC, SSH, socket or subprocess client.",
    "Logical three-rack outcomes do not model real quorum timing, packets, objects, PGs, guests, firmware, hardware or correlated environmental failure.",
    "OpenStack, OVN, Ceph and Redfish documentation changes; release-specific designs require current compatibility and security review.",
    "Local tests, scenario results and dossier output are not production availability, capacity, RPO, RTO, experience or mastery evidence."
  ]
}
---

# Private-cloud reliability capstone: one VM, every authority, honest failure domains

## What you see and first thought

You open the cloud console and see a virtual machine marked **ACTIVE**. That word feels reassuring. It is also a dangerous place to stop thinking.

ACTIVE answers a narrow question: “What lifecycle state does Nova currently record?” It does not answer whether the guest booted the intended image, the volume is correct, a 1500-byte packet survives the overlay, the service can reach its dependencies, or the user can complete an operation.

Whenever a component is green, translate it into a bounded sentence: “Nova recorded this server ACTIVE at 10:14,” “three monitors formed quorum,” or “OVN northbound contains this router.” Then ask what remains unproved.

> A private cloud is several state authorities cooperating across physical failure domains.

Your first questions are:

1. Which exact user operation is failing?
2. Which host, rack, power, network or storage domain changed?
3. Which authority owns the disputed state?
4. Is the outcome failed or ambiguous?
5. What evidence permits action without creating a second failure?

Placement owns allocations; Nova owns lifecycle; OVN owns logical network intent; the chassis owns local realization; Ceph owns protected data; the application owns business correctness. “Cloud issue” is not a diagnosis.

## Terms before commands

### KVM, QEMU and libvirt

**KVM** is the Linux-kernel virtualization facility. **QEMU** is the userspace virtual-machine process that models memory and devices and can use KVM acceleration. **libvirt** is a management API and daemon layer that defines domains and coordinates lifecycle, storage, networking and migration.

```text
Nova lifecycle intent
  -> libvirt domain operation
     -> QEMU virtual-machine process
        -> KVM guest CPU execution
```

If QEMU exits, the guest stops before Nova necessarily updates. If Nova says ERROR, a QEMU process may remain. Reconciliation and fencing exist because control records and runtime can disagree.

### Host, guest, domain, CPU model and machine type

The **host** runs the VM. The **guest** is the operating system inside it. A libvirt **domain** is the managed VM definition and runtime.

The **CPU model** is the processor-feature contract exposed to the guest. The **machine type** is the versioned virtual hardware platform. Migration requires compatible source and destination contracts. A newer physical CPU is not automatically a compatible target.

**NUMA** describes non-uniform distance between CPUs and memory. **CPU pinning** constrains vCPU threads. **Huge pages** reduce translation overhead. **Device passthrough** assigns physical hardware through an IOMMU boundary. These can improve performance while reducing placement and migration flexibility.

### OpenStack control plane, data plane and cells

The **control plane** accepts intent, authorizes it, records state and coordinates work. The **data plane** carries guest packets and storage I/O.

A Nova **cell** is a scale and failure-containment boundary with cell-local database and messaging state. It is not automatically an availability zone. Some moves cannot cross cells; choose cells from operational requirements, not diagram symmetry.

### Placement vocabulary

A **resource provider** supplies capacity. **Inventory** says what it can supply. **Traits** describe capabilities. **Allocations** bind consumer demand to providers. A provider **generation** changes with state and protects concurrent updates.

If an allocation using generation 7 loses to another writer that produced generation 8, reload and recalculate. Do not bypass the conflict by editing a database.

### Aggregates and availability zones

A **host aggregate** groups compute hosts for scheduler metadata. An **availability zone** is user-visible placement language. Neither creates physical independence. Two zones sharing one PDU are two labels and one power failure.

### Neutron, OVN, OVS and Geneve

Neutron accepts networks, ports, routers and policy. OVN northbound stores logical intent. `ovn-northd` compiles it into southbound state. `ovn-controller` programs relevant Open vSwitch behavior on each chassis.

**Geneve** wraps a tenant packet in an outer packet:

```text
required underlay MTU >= tenant MTU + encapsulation overhead
```

An ACTIVE port can coexist with a missing chassis binding, wrong flow, dead tunnel, bad route or insufficient MTU.

### Ceph vocabulary

A **monitor** participates in quorum and distributes cluster maps. An **OSD** stores objects and participates in peering, recovery and scrub. Objects map to **placement groups**, and **CRUSH** maps PGs to OSDs using a hierarchy and rule.

For a replicated pool, `size=3` requests three copies. `min_size=2` permits writes only with at least two copies under policy. Two copies mean minimum write availability, not clean redundancy or safety for another failure.

### Recovery actions

- **Fencing** proves a failed or ambiguous host cannot keep writing.
- **Restart** starts the same guest, usually on the same host.
- **Live migration** moves running state from a reachable source.
- **Cold migration** moves with downtime.
- **Evacuation** recreates a server after a failed source is fenced.
- **Rebuild** recreates guest state from image/configuration and reattaches durable state.

Choose from the location of state and writer authority, not from habit.

### Capacity words

**Raw** is hardware total. **Usable protected** subtracts replication or erasure overhead. **Allocatable** subtracts system and policy reserve. **Recoverable** also leaves enough headroom for the declared failure and rebuild.

A 12 TB raw pool with three replicas has a simple protection ceiling near 4 TB before metadata, uneven placement, fullness thresholds and recovery reserve. Advertising 12 TB is wrong.

## Architecture map

### One protected workload

```text
actor -> Keystone/policy -> Nova API -> Placement candidate/allocation
                                      -> cell/conductor/compute
                                      -> libvirt -> QEMU -> KVM
                                      -> Cinder/Ceph volume

Neutron -> OVN NB -> northd -> OVN SB -> chassis OVS
                                           -> Geneve underlay
                                           -> HA gateway
                                           -> exact user operation
```

Read this as a sequence of claims. Authentication does not allocate capacity. Allocation does not create a guest. QEMU running does not prove networking. A logical port does not prove underlay reachability. An attached volume does not prove application correctness.

### Physical failure domains

```text
site
├── rack-a: pdu-a, leaf-a
│   ├── controller-a, compute-a, gateway-a
│   └── osd-a1, osd-a2
├── rack-b: pdu-b, leaf-b
│   ├── controller-b, compute-b, gateway-b
│   └── osd-b1, osd-b2
└── rack-c: pdu-c, leaf-c
    ├── controller-c, compute-c, gateway-c
    └── osd-c1, osd-c2
```

This is a teaching model, not a recommendation to combine roles. It makes correlation visible. A real design must consider controller, storage and gateway load, cabling, maintenance and blast radius.

### Evidence by authority

| Question | First authority | Corroboration |
|---|---|---|
| Was intent authorized? | identity and policy | actor, project, role, request ID |
| Was capacity claimed? | Placement | provider generation, consumer, inventory |
| What lifecycle is intended? | Nova API/cell state | task state, events, compute report |
| Is a guest process running? | libvirt/QEMU | domain identity, PID, guest/application |
| Is network intent present? | Neutron/OVN NB | object revision and identity |
| Is the packet path realized? | OVN SB/chassis/OVS | binding, flow, tunnel, route, probe |
| Is data protected? | Ceph maps/PGs | CRUSH location, acting set, health, scrub |
| Did hardware action finish? | Redfish task/system | exact system ID, task and power state |

## Request or state path

### 1. Authenticate and authorize intent

Preserve actor, project, request ID, sanitized workload identity, policy decision and time. Do not log tokens. Authentication proves a credential; authorization proves permission; quota proves allowed consumption. They are different gates.

### 2. Turn image and flavor into constraints

A trusted image needs immutable identity and approved provenance/signature policy. A flavor expresses vCPU, memory and disk, but scheduling may also require CPU model, huge pages, NUMA, accelerator traits, aggregate/AZ placement, affinity and compatible recovery destinations.

### 3. Claim capacity through Placement

Placement calculates candidates from inventories, allocations, traits and aggregates. Nova writes an allocation against a generation. A conflict means the observation became stale; repeat candidate calculation within a bound.

### 4. Coordinate the Nova cell and compute

The request enters a cell. Conductor and compute coordinate lifecycle. libvirt defines the domain; QEMU creates the virtual platform; KVM executes guest CPU.

Preserve server, request, cell, host, image, flavor, allocation, domain, port and volume identities. These join evidence later.

### 5. Attach durable state

Cinder control state, a Ceph RBD image, client authorization, attachment and guest block device must describe the same intended volume. Local ephemeral disk can disappear with the host. Ceph-backed state may support evacuation, but only after fencing and storage validation.

### 6. Compile network intent

Neutron intent flows through OVN northbound, northd, southbound, chassis controller and OVS, then crosses Geneve, the underlay and gateway.

Use this proof ladder:

```text
API object
  < revision-consistent intent
  < chassis binding
  < local flow and interface
  < tunnel/underlay path
  < route, neighbor and gateway
  < representative packet
  < TCP/TLS/application operation
```

### 7. Validate the user operation

A console login proves console access. Ping proves limited packet exchange. HTTP 200 can come from the wrong version or stale state. The strongest closure check is the predefined operation from the correct trust/network boundary with representative payload and durable-state semantics.

## Failure zoom

### Compute-host loss

Memory and CPU execution were local. Ephemeral disk may be local. Ceph volume state is remote. Network intent remains in control state. Placement may retain allocations until reconciliation.

Fence before evacuation. Otherwise a returning host can create a second writer, duplicate address or stale attachment.

### Rack loss

Three controllers may become two. Ceph `size=3/min_size=2` may become two copies. Two application replicas may become one.

The service can still operate while the system is degraded and another failure is more dangerous. Freeze nonessential maintenance and growth until margin returns.

### MTU mismatch

Tenant MTU 1500 plus 50 bytes of overlay needs at least 1550 underlay. A 1520-byte hop can pass small probes and fail real traffic.

Inspect guest NIC, tap, OVS, tunnel, physical NIC/bond, switch path, routed underlay and gateway. Repair the owned contract; do not randomly lower values.

### Ceph degradation

Ask four separate questions:

1. Can I/O complete?
2. How much independent-copy margin remains?
3. Are objects consistent and scrubs current?
4. Can client and recovery load coexist without crossing latency or fullness limits?

Lowering min_size buys writes with durability risk. Raising recovery concurrency shortens degraded time while potentially harming client latency. Both require explicit abort gates.

### Migration incompatibility or non-convergence

Pre-copy repeatedly transfers dirty memory. If dirty rate exceeds available transfer rate, migration may not converge. Auto-convergence, pause and post-copy change application behavior and failure risk. Post-copy can make a later network failure fatal because missing pages remain on the source.

Check CPU, machine type, firmware, devices, storage and network compatibility before starting.

### Restore divergence

A restored control database can contain servers without domains, allocations without consumers, ports without bindings or attachments without guest devices. Restore in isolation, compare identities and choose authority by state class. Never guess-delete “orphans” to make a dashboard green.

## Internals and state ownership

### Nova state is distributed for a reason

API database, cell database, messaging, conductor, scheduler, Placement and compute solve different problems. API availability can coexist with one unavailable cell. A cell is an explicit recovery unit; adding cells creates operational boundaries as well as scale.

### Generations are optimistic concurrency

Suppose generation 7 exposes 16 free vCPUs. Scheduler A allocates 8 and writes generation 8. Scheduler B tries to allocate 12 using generation 7. Rejecting B prevents claims for 20 against 16. Reload and retry; do not destroy the contract with direct edits.

### OVN compiles intent into local behavior

```text
Neutron object -> OVN NB -> northd -> OVN SB -> chassis -> OVS
```

Stale revision, database loss, missing chassis, absent local flow or broken underlay are different failure stages. Observe the stage instead of saying “OVN is broken.”

### Ceph clients use maps

Monitors distribute maps; clients use CRUSH to calculate placement and communicate with OSDs. There is no central data proxy to inspect as the whole path. The physical hierarchy must be truthful. Different hosts on one PDU satisfy a host rule but fail a rack-loss promise.

### Recovery ownership

| Failure | Unsafe reflex | Owned decision |
|---|---|---|
| QEMU crash, host healthy | evacuate | inspect and restart if state allows |
| host failed, durable storage | start duplicate | fence, verify storage, evacuate/rebuild |
| host failed, ephemeral state | promise recovery | declare loss boundary and rebuild |
| stale provider generation | edit database | reload candidates and bounded retry |
| intent exists, packets fail | recreate network | trace revision, binding, flow, tunnel, MTU |
| Ceph degraded | lower min_size | locate copies and protect client/recovery margin |
| migration stalls | force complete | assess dirty rate, compatibility and abort |
| BMC timeout | repeat power | poll task and current system state |
| restore differs | delete orphan | isolate, reconcile and approve correction |

## Evidence table

Use evidence as a contract: every signal has a meaning and a limit.

| Signal | It can prove | It cannot prove |
|---|---|---|
| Keystone token accepted | authentication succeeded for that request | least privilege or correct business authorization |
| Nova server ACTIVE | recorded lifecycle state | guest readiness, packet path, storage or user correctness |
| Placement allocation | capacity is claimed in Placement | host can start the guest or capacity exists after a failure |
| libvirt domain running | QEMU/domain exists on that host | application health or control-state agreement |
| Neutron port ACTIVE | control-plane status reached ACTIVE | end-to-end packet delivery |
| OVN NB object | logical intent exists | southbound compilation, binding or local flow |
| OVS flow/tunnel | local realization exists | remote route, MTU, gateway or application |
| Ceph HEALTH_OK | no unmuted current health condition | workload correctness, future capacity or tested restore |
| PG active+clean | that PG is available and fully placed | application data semantics or all-PG integrity |
| backup file plus digest | bytes exist unchanged since digest | restorable, complete, consistent or promotable state |
| Redfish HTTP 202 | task was accepted | terminal power/update outcome |
| simulator PASS | fixture invariants held | production behavior, SLO or human competence |

### Evidence order during an incident

Start from the user and move inward only far enough to isolate the first broken boundary:

```text
user operation
 -> DNS/TCP/TLS/application
 -> gateway/underlay/tunnel
 -> chassis/port/logical intent
 -> guest/domain/host
 -> volume/PG/OSD
 -> allocation/cell/control dependencies
```

Collect identity and time with each sample. “Port was ACTIVE” without port ID, revision, chassis, server and observation time is weak evidence.

### Example contradiction table

| Observation | Strong next question |
|---|---|
| ACTIVE server, failed checkout | Where does the exact path first fail? |
| clean Ceph, missing database row | Is this application/transaction truth rather than storage availability? |
| available inventory, no candidate | Which trait, aggregate, affinity or compatibility filter removed hosts? |
| OVN intent correct, one rack unreachable | Are chassis, underlay and gateway in that physical domain healthy? |
| backup restored, guest wrong | Which later event or external authority is missing? |

## Command decoders

The commands in this lab are deliberately Python-only and offline. They teach decision contracts without asking you to install an entire private cloud.

### `python cloudctl.py check`

- `python` runs the interpreter.
- `cloudctl.py` is the local simulator, not an infrastructure CLI.
- `check` loads strict JSON, rejects duplicate/unknown/forbidden fields, validates physical domains, quorum, MTU, storage policy, workloads, quota and deterministic placement.

Expected summary:

```json
{"check":"pass","racks":3,"controllers":3,"computes":3,"gateways":3,"osds":6,"workloads":2,"allocations":3,"authority":"local-simulation-only"}
```

This proves input/model consistency. It does not create a VM or inspect a host.

### `python cloudctl.py initialize`

This creates only `.runtime`, `receipts` and a descriptor containing the project identity and SHA-256 digests of the two inputs. A changed input makes the descriptor stale and future mutation refuses.

If runtime already exists, initialization refuses rather than merging state. That is an idempotency and ownership lesson: ambiguous leftovers deserve inspection.

### `python cloudctl.py baseline`

The baseline:

- checks trusted image and quota;
- filters hosts by trait, CPU model and machine type;
- maintains rack anti-affinity;
- writes generation-bearing allocations;
- calculates compute and storage reserve;
- records quorum, storage and network assumptions;
- marks only synthetic user operations as passing.

The fixture places two checkout replicas on compatible rack-a and rack-b hosts. It places the rebuildable worker on the older compatible rack-c host. This is why capacity is not one cluster-wide vCPU number.

### `python cloudctl.py scenario NAME`

Each named scenario writes a receipt with:

- result: safe, degraded, blocked or unavailable;
- signal;
- decision;
- evidence;
- recovery;
- what the receipt proves and does not prove.

An expected blocked result is success for the safety contract. The lab would be wrong if it made every incident “green.”

### `python verify.py`

The verifier runs 17 tests, checks inputs, initializes, builds the baseline, evaluates all 12 scenarios, generates a dossier, asserts result categories, cleans up and independently checks absence.

The final line reports 4 degraded, 7 blocked and 1 unavailable outcome. Those numbers are part of the fixture contract, not a health score.

### `python cloudctl.py cleanup`

Cleanup first validates the descriptor and scans every runtime entry. It accepts only known files. An unknown file or modified descriptor blocks deletion and preserves evidence. There is no wildcard or recursive prune.

Memory rule:

> A cleanup command is safe only when it can prove exactly what it owns.

## Decision path

Use **FRAME** for the incident and **SCALE** for the design.

### FRAME

1. **Find** the exact failed operation and time.
2. **Restrict** scope by project, server, host, cell, rack, network and pool.
3. **Acquire** evidence from each relevant authority.
4. **Model** competing causes and dangerous ambiguity.
5. **Execute** the smallest reversible containment/recovery with abort.

### SCALE

1. **Scenario:** What demand and failure must the system support?
2. **Constraints:** State, latency, compliance, physical topology, skills and budget.
3. **Alternatives:** Restart, move, rebuild, restore; shared/dedicated; replication/erasure.
4. **Limits:** Quorum, capacity, compatibility, bandwidth, fullness, time and people.
5. **Evidence:** What test would falsify the design?

### Worked decision: one compute disappears

Ask:

1. Is the host definitely fenced?
2. Does the server have local ephemeral state?
3. Is durable storage reachable and healthy?
4. Are ports/volumes attached elsewhere?
5. Is compatible capacity available outside the failed domain?
6. Can the workload tolerate restart and identity change?

Then choose:

- restart only if host/runtime is trustworthy;
- live migrate only from reachable source with compatibility and convergence;
- evacuate after failed source is fenced and durable state is valid;
- rebuild when image/configuration are authoritative;
- declare data loss if the only state was destroyed;
- do nothing destructive while writer state is ambiguous.

### Worked decision: Ceph degraded and 82% used

With near-full at 85%, only 3 percentage points remain. Recovery can increase temporary placement and foreground writes continue. Before accelerating:

```text
time_to_near_full =
  remaining_usable_bytes / net_growth_bytes_per_second
```

Observe skew, client latency, recovery rate, device/network saturation and affected PGs. Stop new growth, add capacity or reclaim safely. Do not lower protection merely to silence a health code.

### Closure gate

Close only when:

- exact user operation succeeds;
- failed writer is fenced or reconciled;
- server, allocation, port, volume and guest identities agree;
- required redundancy and capacity reserve are restored or residual risk is accepted;
- alert/monitoring state matches reality;
- recovery actions and follow-ups have owners.

## Guided Ubuntu lab

### Safety preview

This lab creates JSON/Markdown receipts only. It does not need Docker, sudo or network. Do not run as root. Do not insert real hostnames, addresses, credentials or endpoints into the fixture.

From the project directory:

```bash
pwd
python --version
python -m unittest discover -s tests -v
python cloudctl.py check
```

Expected: 17 tests pass; check reports 3 racks, 3 controllers, 3 computes, 3 gateways, 6 OSDs, 2 workloads and 3 allocations.

### Read the topology before mutation

```bash
python -m json.tool topology.json
python -m json.tool workloads.json
```

Answer:

- Which rack, PDU and leaf owns each controller?
- Which computes can host the x86-64-v3/Q35-9.2 checkout workload?
- Why can compute-c host the worker but not safely receive checkout by live migration?
- What do size 3, min_size 2 and rack failure domain mean?
- How much underlay MTU is required?

### Create the bounded baseline

```bash
python cloudctl.py initialize
python cloudctl.py baseline
python -m json.tool .runtime/baseline.json
```

Notice that a descriptor binds runtime state to input digests. Inspect allocations and reserve. The baseline’s operation PASS is synthetic model state only.

### Walk four representative failures

```bash
python cloudctl.py scenario compute-host-loss
python cloudctl.py scenario mtu-mismatch
python cloudctl.py scenario ceph-near-full
python cloudctl.py scenario restore-divergence
```

Read receipts:

```bash
python -m json.tool .runtime/receipts/compute-host-loss.json
python -m json.tool .runtime/receipts/mtu-mismatch.json
python -m json.tool .runtime/receipts/ceph-near-full.json
python -m json.tool .runtime/receipts/restore-divergence.json
```

Do not ask “which passed?” Ask why results differ:

- host loss is degraded because one app replica survives but anti-affinity cannot be restored with compatible spare capacity;
- MTU mismatch is unavailable because the user path fails;
- near-full is blocked because admission would consume recovery margin;
- restore divergence is blocked because promotion would join inconsistent authorities.

### Complete and inspect the matrix

The easiest safe route is to clean the partial runtime, then let the verifier own a full lifecycle:

```bash
python cloudctl.py cleanup
python verify.py
```

The verifier deletes its dossier during cleanup. To study the dossier, create a new baseline, run all named scenarios, then run:

```bash
python cloudctl.py dossier
```

Use the scenario names printed by `python cloudctl.py scenario --help`. After reading:

```bash
python cloudctl.py cleanup
test ! -e .runtime && echo "runtime_absent=true"
```

On PowerShell use `Test-Path .runtime` and expect `False`.

### Adversarial lesson

The tests create an unknown runtime file and modify the descriptor. Cleanup refuses both. This matters more than convenience: if a tool cannot distinguish its state from someone else’s, deletion is not recovery.

## Production transfer

The simulator teaches reasoning, but production requires real evidence. Transfer in stages.

### Stage 1: read-only inventory

Build an authorized source of truth for:

- server, rack, PDU, leaf, BMC and firmware identity;
- controller, cell, compute, gateway and storage roles;
- CPU/machine/device compatibility;
- provider inventories, allocations, aggregates and traits;
- OVN databases, chassis and gateway candidates;
- Ceph monitors, OSDs, CRUSH hierarchy, pools and capacity;
- workload owners, tiers, state classes and maintenance constraints.

Do not assume CMDB labels are true. Reconcile them with physical and runtime evidence.

### Stage 2: one noncritical workload

Trace one permitted synthetic/noncritical operation through identity, Placement, Nova, libvirt, storage and networking. Record IDs and timings. Establish the normal packet and I/O path before injecting failure.

### Stage 3: component-local failure

In a disposable environment:

- stop one rebuildable guest or compute service;
- fail one gateway candidate;
- create a bounded MTU mismatch;
- mark one synthetic storage device unavailable;
- create a stale allocation generation.

Each experiment needs hypothesis, steady-state metric, blast radius, abort, rollback, evidence and cleanup.

### Stage 4: stateful recovery

Rehearse backups and isolated restores for each authority. A Nova database restore is not a Ceph restore. An OVN database backup is not underlay recovery. Keys and identity material have separate ownership.

Reconcile before promotion:

```text
server -> allocation -> domain -> port -> chassis -> volume -> guest -> operation
```

### Stage 5: maintenance and upgrade

Use compatibility matrices and release notes. Canary stateless services first where supported. Preserve quorum. Gate database migrations, messaging, API, cell/compute, network and storage health separately. Stop on user-path or capacity regression.

Real production work requires change approval, monitoring, rollback ownership, vendor/project-specific review and stakeholder communication. Copying the simulator result into a change ticket would be false evidence.

### The production dossier you should demand

A serious private-cloud design should be reconstructible by someone who did not attend the design meetings. Keep these artifacts versioned and connected by stable names:

**Workload contract**

- user operations and owners;
- traffic, latency, state, data-classification and maintenance needs;
- scale, growth and burst assumptions;
- availability, RPO/RTO candidates and dependency expectations;
- non-migratable or hardware-specific constraints.

**Physical topology**

- site, room, row, rack, PDU, leaf/spine and management boundaries;
- server, NIC, disk, HBA, accelerator, BMC and firmware identity;
- controller, compute, gateway and storage role placement;
- cable/link redundancy and oversubscription;
- capacity and spare ownership.

**Logical topology**

- regions, cells, aggregates, availability zones and projects;
- Placement provider trees, traits and inventories;
- Neutron networks, routers, address scopes, gateways and MTU;
- OVN NB/SB and chassis/gateway responsibility;
- Ceph clusters, pools, CRUSH roots/rules, device classes and client boundaries.

**State catalogue**

For every state, record authority, writer, readers, backup, encryption/key dependency, retention, recovery order and reconciliation key. Include identity, configuration, database, queue where durable, OVN, images, volumes, Ceph maps/data, guest-local state, DNS and external systems.

**Failure-mode table**

For host, rack, PDU, leaf, controller, cell, gateway, OSD, monitor, full device, certificate, key, DNS and management-plane failure, record:

- user effect;
- detection and first evidence;
- containment and fencing;
- remaining quorum/redundancy/capacity;
- safe recovery and abort;
- closure validation;
- residual risk.

**Capacity workbook**

Keep formulas and units, not screenshots. Show compatible compute pools, allocations, system reserve, maintenance reserve, largest-failure reserve, overcommit assumptions, tail-latency evidence, protected storage, maximum-device fullness, recovery headroom, network contention, growth and procurement lead time. Add sensitivity for demand and failure changes.

**Security model**

Name trust boundaries, identities, privileges, service credentials, certificate/key owners, image provenance, tenant segmentation, management access, BMC isolation, logging/redaction, break-glass workflow, vulnerability response and evidence retention.

**Runbooks**

Separate:

- API/control degradation;
- compute host loss and fencing;
- migration and evacuation;
- OVN binding, MTU and gateway failure;
- Ceph slow/down/full/inconsistent state;
- certificate/key/identity incident;
- backup, isolated restore and reconciliation;
- upgrade abort and recovery.

Every runbook must state prerequisites, exact target identity, non-goals, decision authority, commands with branches, expected evidence, abort, rollback/recovery and cleanup.

**Architecture decisions**

Record why cells exist, how AZ/aggregates map to physical topology, what CPU/machine baseline is supported, how gateway HA works, why the chosen Ceph protection/failure domain is correct, what capacity reserve is funded and which recovery claims remain unproved. Include rejected alternatives and conditions that would reverse the decision.

**Acceptance report**

List test revision, environment, authorized participants, fault, measurements, outputs, cleanup, failures, exceptions and signatures. A pass applies only to that scope. Preserve failed tests because they show the real boundary better than a polished final screenshot.

### How to audit the dossier

Pick one workload and ask:

1. Can I trace its user operation to every state and physical dependency?
2. Do logical failure domains match inventory?
3. Can compatible surviving capacity satisfy declared loss?
4. Can storage recover without crossing fullness or user latency?
5. Can I reconstruct network intent and actual packet path?
6. Is every administrative action attributable?
7. Has each backup restored in isolation?
8. Does every upgrade step have a supported next and stopped branch?
9. Can a new operator execute the runbook without tribal knowledge?
10. Which claim still rests on assumption?

If a claim has no owner, evidence or falsification test, write it as a hypothesis—not architecture fact.

## Reliability, security, observability, capacity, and cost

### Reliability

Define availability from a user operation:

```text
availability =
  successful eligible operations / total eligible operations
```

Then declare window, exclusions and correctness. “Nova API up” is a control-plane SLI. “Protected checkout succeeds” is a user SLI. Both matter; they are not substitutes.

Map dependency budgets. If checkout needs DNS, gateway, application, database and storage, end-to-end success cannot exceed the combined behavior of those dependencies. Redundancy helps only when instances do not share the same failure and enough compatible capacity survives.

RPO and RTO are decisions:

- **RPO** bounds acceptable lost committed history.
- **RTO** bounds time to restore the defined operation.

A backup interval is not RPO proof, and a restore command duration is not end-to-end RTO.

### Security

Private does not mean trusted. Essential boundaries include:

- individual identity instead of shared administrator accounts;
- least-privilege project/system roles;
- short-lived service/user credentials where supported;
- mTLS or protected service communication appropriate to design;
- trusted image provenance, digest and visibility;
- default-deny tenant segmentation with narrow policy;
- secret/key inventory, rotation, revocation and recovery;
- hypervisor, firmware and management-plane hardening;
- protected audit logs and break-glass accountability;
- isolated management, storage and tenant/external traffic according to threat model.

Do not place a BMC on a tenant-reachable network. Do not log tokens. Do not weaken global policy to admit one workload.

### Observability

Observe four layers:

1. **User:** success, latency, correctness, saturation and representative payload.
2. **Control:** API errors/latency, queue depth, DB health, scheduler outcomes, allocation conflicts.
3. **Data:** guest readiness, OVN bindings/flows/tunnels/gateways, storage I/O/PG/OSD health.
4. **Physical:** power, thermal, link, device, firmware, BMC tasks and failure-domain inventory.

Use stable IDs for correlation. Avoid labels such as raw tenant URL, token, VM name from untrusted input or high-cardinality request payload.

Alerts need action. “Ceph HEALTH_WARN” is context; page on user risk, protection loss, time to full, slow operations or failed recovery with an owned runbook.

### Compute capacity

For a compatibility pool:

```text
surviving_allocatable =
  compatible_physical_capacity
  - system_reserve
  - current_allocations
  - maintenance_reserve
  - largest_declared_failure
```

Overcommit applies after understanding workload demand. Eight idle vCPUs are not equivalent to eight latency-sensitive busy vCPUs. Track requested, allocated and measured demand plus contention and tail latency.

For the fixture, total vCPU is 176 and baseline uses 28, leaving 84.1% numerically; the recorded reserve is lower after workload/host constraints and the implementation reports its exact calculation. More importantly, checkout can run only on two compatible hosts. Losing either leaves no other rack-compatible target even while cluster-wide vCPU looks abundant.

### Storage capacity

For simple replication:

```text
protected_ceiling ≈ raw_bytes / replica_size

admission_ceiling =
  protected_ceiling
  - metadata_and_imbalance
  - near_full_margin
  - recovery_reserve
  - forecast_growth_during_lead_time
```

Monitor maximum OSD/PG pressure, not only cluster average. CRUSH cannot place the next copy on theoretical free space that violates the failure-domain rule.

### Network capacity

Model east-west tenant traffic, storage replication/recovery, migration, control messaging and north-south traffic. They may share links. A rack recovery plus live migrations can saturate the same underlay needed by the user.

Measure packet rate, bandwidth, drops, queueing, retransmission and tail latency. Validate MTU and ECMP asymmetry. Capacity needs failure-state measurements, not healthy-state averages.

### Cost

Private-cloud cost includes servers, storage, switches, optics, power, cooling, racks, facilities, licenses/support, spares and engineer time. A design with no recovery reserve may look utilized and create expensive outages.

Use unit economics:

```text
cost_per_protected_vcpu_hour =
  allocated_cost_of_compatible_compute_pool
  / delivered_protected_vcpu_hours
```

“Protected” matters: raw capacity that cannot survive maintenance or the declared failure is not the same product.

### Worked compute-reserve case

Suppose three compatible racks each have 64 physical vCPUs. The workload pool has 120 allocated vCPUs, and policy reserves 8 vCPUs per host for the operating system and platform agents.

```text
physical = 3 * 64 = 192
system_reserve = 3 * 8 = 24
normal_allocatable = 192 - 24 = 168
normal_spare = 168 - 120 = 48
```

That looks comfortable until the requirement says “survive loss of the largest rack.” After losing one rack:

```text
surviving_physical = 2 * 64 = 128
surviving_system_reserve = 2 * 8 = 16
surviving_allocatable = 112
required_allocations = 120
deficit = 8 vCPUs
```

The pool is healthy in normal state and cannot meet its rack-loss promise. Overcommit may help only if the service contract permits it and representative demand/latency evidence supports it. The honest actions are reduce protected demand, add compatible capacity, weaken the declared failure objective through an authorized product decision, or design controlled degradation.

Now add CPU compatibility. If rack-c has 64 free vCPUs but the workload requires a feature unavailable there, those vCPUs are not part of the protection pool. Capacity dashboards must group by workload-relevant compatibility, not only by resource class.

### Worked storage-reserve case

Six 2 TB OSDs provide 12 TB raw. A three-replica pool has a simple protected ceiling near 4 TB. Suppose application data is 3.1 TB protected and expected to grow 30 GB per day. The team wants 15% recovery/free-space reserve below its admission ceiling.

```text
simple_protected_ceiling = 12 TB / 3 = 4 TB
policy_reserve = 4 TB * 0.15 = 0.6 TB
admission_ceiling_before_other_overhead = 3.4 TB
remaining_to_admission = 3.4 - 3.1 = 0.3 TB
days_to_admission_at_30_GB_per_day ≈ 10 days
```

This is still optimistic because OSD imbalance, metadata, snapshots, backfill and the maximum-full device can dominate before the average. Report both cluster-level and maximum-device/PG pressure. Lead time matters: if new capacity takes 21 days, the platform is already outside a safe procurement window.

During a rack loss, copies are remapped and recovery may consume extra headroom. Do not schedule storage maintenance using steady-state free space. Model the largest expected movement and foreground growth during recovery.

### Worked quorum case

For three voting members, majority is two. For five, majority is three:

```text
majority = floor(member_count / 2) + 1
```

Quorum math assumes independent and communicating members. Three controller VMs on one hypervisor are three processes and one host failure. Three physical hosts on one PDU are three hosts and one power failure.

More members are not automatically better. They add coordination, network and operational cost. Place the smallest supported odd quorum that meets failure scenarios, latency and maintenance needs. Separate voter health from service dependencies such as load balancer, database, message bus, DNS and certificates.

### Worked migration-convergence case

A VM has 64 GiB RAM. After an initial transfer, it dirties memory at 2.0 GiB/s while effective migration bandwidth is 1.5 GiB/s.

```text
net_remaining_change = dirty_rate - transfer_rate
                     = 2.0 - 1.5
                     = +0.5 GiB/s
```

The remaining dirty set grows; ordinary pre-copy cannot converge. Adding theoretical link bandwidth helps only if source CPU, memory copy, destination, encryption and network path deliver it.

Choices have consequences:

- reduce workload dirty rate or drain traffic;
- enable bounded auto-convergence and accept guest slowdown;
- pause/force-complete within downtime and clock/application tolerance;
- use post-copy only with explicit source/network failure risk;
- abort and choose cold maintenance.

Track total transfer, remaining bytes, dirty rate, iteration time, downtime and user latency. A migration task “running” is not progress.

### Upgrade runbook skeleton

Before change:

1. Pin source and target versions and read supported paths.
2. Inventory API, database, message, cell, compute, OVN, OVS, Ceph and client compatibility.
3. Verify capacity for maintenance plus the declared failure.
4. Create protected backups and complete isolated restore/reconciliation.
5. Define user/control/storage SLIs, abort thresholds and decision authority.
6. Confirm out-of-band access, fencing and rollback/recovery ownership.

During change:

1. Canary the smallest supported boundary.
2. Preserve quorum and one known-good management path.
3. Validate database/schema and service registration.
4. Validate Placement, cell/compute, OVN and Ceph state separately.
5. Execute representative create, attach, network, reboot/move and delete operations where authorized.
6. Stop expansion on incompatibility, unexplained error, capacity loss or user regression.

After change:

1. Reconcile versions, inventories, allocations and topology.
2. Remove temporary flags and verify they did not become permanent risk.
3. Soak through representative load and background recovery.
4. Revalidate backup/restore compatibility.
5. Record observed results, failures, residual risks and follow-up owners.

Rollback may be impossible after an irreversible database or on-disk format change. In that case the recovery plan is forward repair or restore, not a fictional “downgrade.” Use the project’s exact release documentation.

### Recovery runbook skeleton

**Trigger:** user operation fails or state authorities disagree.

**Scope:** exact projects, servers, hosts, cells, ports, volumes, PGs, racks and time.

**Safety:**

- freeze high-risk changes;
- preserve logs/events/maps/inventories;
- fence ambiguous physical writers;
- do not lower protection or edit databases without named authority;
- never overwrite the only backup or active state.

**Recover:**

1. restore each authority to an isolated or explicitly bounded target;
2. verify digest, schema, time and count;
3. reconcile stable identities and ownership;
4. rebuild derived/runtime state through supported APIs;
5. validate the exact user operation;
6. promote through a separate decision.

**Close:** margin restored, state reconciled, alert cleared for the right reason, residual risk accepted and prevention work owned.

## Traps and prevention

### Trap: logical labels equal physical resilience

**Why it fails:** aggregates, AZs, cells and CRUSH rules operate on declared membership. Wrong inventory makes correct algorithms produce unsafe placement.

**Prevention:** version the physical topology, detect drift and periodically compare logical membership with rack/PDU/leaf identity.

### Trap: ACTIVE means healthy

**Why it fails:** lifecycle, runtime, network, storage and application correctness have different owners.

**Prevention:** define a user-journey SLI and retain cross-authority IDs.

### Trap: cluster-wide free capacity means recoverability

**Why it fails:** spare vCPU may have wrong CPU model, device, rack, aggregate, NUMA or storage/network capability.

**Prevention:** calculate reserve per compatibility and failure-domain pool.

### Trap: lower protection to restore availability

**Why it fails:** lowering min_size or policy can accept writes with too little durability during an active failure.

**Prevention:** exhaust safer capacity and recovery actions; require explicit risk authority and rollback for protection changes.

### Trap: maximize recovery speed

**Why it fails:** recovery competes with client I/O and may accelerate fullness.

**Prevention:** gate on client SLO, device/network saturation, space and time-to-clean.

### Trap: force migration

**Why it fails:** incompatible machine/device state or non-converging memory can increase downtime or lose the guest.

**Prevention:** precheck compatibility; model dirty rate and bandwidth; define abort, pause/post-copy risk and cold alternative.

### Trap: repeat an ambiguous action

**Why it fails:** the first request may have succeeded. A second power action or volume operation can reverse or duplicate it.

**Prevention:** stable operation ID, task polling, current-state read and fencing.

### Trap: restore every database and start services

**Why it fails:** snapshots have different times and external realities. Starting all writers can amplify divergence.

**Prevention:** isolated restore, manifests, dependency order, identity reconciliation and separate promotion.

### Trap: silence health warnings

**Why it fails:** muting changes presentation, not state.

**Prevention:** preserve reason, owner, expiry and residual risk; alert on underlying user/protection/capacity condition.

### Trap: simulator success becomes experience

**Why it fails:** deterministic logic has no real timing, software defects, packets, devices or human coordination.

**Prevention:** label proof limits and require independent authorized transfer before making a competency claim.

## Memory card and retrieval

### Ten memory lines

1. ACTIVE is lifecycle evidence, not user evidence.
2. Logical labels protect only when physical membership is true.
3. Placement generations prevent stale capacity writes.
4. Fence before creating a replacement writer.
5. Intent, binding, flow, tunnel and user path are separate.
6. Ceph writable is not Ceph clean, safe or fast.
7. Compatible spare capacity matters more than total free capacity.
8. Migration moves runtime; evacuation rebuilds after failure.
9. Restore each authority separately and reconcile before promotion.
10. Local simulation proves only its model.

### Retrieval prompts

Answer aloud before reading the next section:

1. What exactly does Nova ACTIVE prove?
2. Why can three hosts still have one rack failure domain?
3. What does a Placement generation protect?
4. Why fence before evacuation?
5. What is the OVN intent-to-packet chain?
6. Why can small packets pass while applications fail?
7. What is the difference between Ceph size and min_size?
8. Why is HEALTH_OK not restore evidence?
9. Which compatibility fields matter for migration?
10. Why can cluster-wide free vCPU be useless?
11. How do raw, usable, allocatable and recoverable capacity differ?
12. Why can faster recovery harm users?
13. What does HTTP 202 from Redfish mean?
14. Why restore to isolation?
15. What closes a private-cloud incident?
16. When should cells and availability zones differ?
17. What must a real failure experiment define?
18. Which evidence may support an RPO/RTO claim?
19. What does the simulator’s blocked result mean?
20. What remains before mastery?

## Complete answers

### 1. What does ACTIVE prove?

It proves Nova recorded the server in ACTIVE lifecycle state for the observed record/time. It does not prove QEMU identity, guest readiness, packet delivery, volume correctness, application version or user success. Join server ID to host/domain, port, volume and a representative operation.

### 2. Why can three hosts have one failure domain?

They can share a rack, PDU, leaf switch, upstream circuit, cooling zone or management dependency. Host diversity is not physical independence. Model the correlated event you promise to survive.

### 3. What does provider generation protect?

It is optimistic concurrency for resource-provider state. A writer proves it acted on the current generation. If another allocation changes state, a stale update is rejected so capacity is not silently double-claimed.

### 4. Why fence before evacuation?

Because an unreachable host may still run. Starting a replacement can create two writers to the same volume or network identity. Fencing converts “not observed” into “cannot act,” then recovery can establish one writer.

### 5. What is the OVN chain?

Neutron accepts intent; OVN northbound stores logical objects; northd compiles them; southbound holds flows/bindings; chassis controllers program OVS; tunnels/underlay and gateways carry packets. Validate the stage where evidence first diverges.

### 6. Why can small packets pass?

Overlay encapsulation increases frame size. A path with inconsistent MTU can carry small ICMP and drop larger frames. TCP/TLS/application traffic may stall. Test required payload sizes and inspect PMTUD/ICMP behavior.

### 7. size versus min_size?

Size is desired copy count. min_size is the minimum copy availability under which writes are allowed. Operating at min_size preserves a policy-defined minimum but has reduced durability margin and may be one failure from unavailability or loss.

### 8. Why is HEALTH_OK not restore evidence?

It says no current unmuted Ceph health checks are active. It does not prove backup completeness, historical point, application consistency, key availability, isolated restore, reconciliation or achievable recovery time.

### 9. Migration compatibility?

CPU model/features, machine type, firmware, device models, passthrough devices, memory/page/NUMA constraints, storage reachability, network realization and source/destination software compatibility. Convergence also needs transfer rate relative to dirty-memory rate.

### 10. Why can free vCPU be useless?

Free vCPU may be on the wrong CPU model, architecture, rack, aggregate or device pool, or violate affinity and maintenance reserve. Capacity must be filtered through the workload contract.

### 11. Four capacity levels?

Raw is hardware. Usable protected subtracts protection overhead. Allocatable subtracts system/policy reserve and existing claims. Recoverable subtracts the declared failure and rebuild/maintenance headroom.

### 12. Why can recovery harm users?

Ceph backfill, VM migration and rebuild consume disk, CPU and network used by foreground work. Aggressive recovery can increase tail latency, timeouts and fullness. Balance reduced-risk duration against immediate user impact with abort gates.

### 13. What does Redfish 202 mean?

The service accepted an asynchronous action and returned or referenced a task. The final outcome is unknown until the task reaches a terminal state and the exact system’s current state is reread.

### 14. Why isolated restore?

It prevents overwriting the only active copy and prevents restored writers from conflicting with live systems. It permits digest, schema, count, identity and user-path comparison before promotion.

### 15. What closes an incident?

The exact user operation succeeds; writer identity is safe; applicable server/allocation/domain/port/volume/guest state reconciles; redundancy and capacity margin are restored or risk is accepted; monitoring agrees; actions have owners.

### 16. Cells versus AZs?

Cells are Nova scale and containment boundaries with separate data/message dependencies and move limitations. AZs express user-visible placement intent. They may align, but only when product and operational semantics justify it.

### 17. What must an experiment define?

Hypothesis, steady state, blast radius, authority, exact target, abort threshold, rollback/recovery, evidence, duration, cleanup and proof limits. Without them, fault injection is uncontrolled outage creation.

### 18. What supports RPO/RTO?

A defined operation/state boundary, versioned backup/replication design, representative fault, isolated restore or failover, integrity and identity reconciliation, user validation, measured timing and reviewed residual risk across repeated tests.

### 19. What does blocked mean in the simulator?

The safety contract intentionally refused an unsafe admission/change such as stale generation, near-full growth, incompatible migration, unsupported upgrade, divergent restore, ambiguous hardware retry or policy violation. It is a successful refusal, not a healthy service.

### 20. What remains before mastery?

Learner-owned work on an unfamiliar reviewer-controlled topology, hidden faults, safe operation, evidence, corrections and delayed transfer. Reading, model answers and mentor-run tests cannot award mastery or production experience.

## Product-company interview

### Scenario 1: ACTIVE VM, failed service

**Prompt:** The console is green but customers time out. What do you do?

**Strong path:** Name the operation and time. Join server to domain, port, binding, gateway, volume and application. Trace DNS, route, TCP/TLS and representative payload. Avoid restart until the first failed boundary and writer/state risk are known.

**What the interviewer tests:** Whether you distinguish orchestration status from user reliability.

### Scenario 2: no valid host despite 40% free vCPU

**Prompt:** Why did scheduling fail?

**Strong path:** Inspect requested traits, CPU/machine/device, aggregate/AZ, affinity, NUMA/hugepage, disk, allocation and generation constraints. Calculate free capacity within the compatible pool. Do not answer “scheduler bug” from aggregate utilization.

### Scenario 3: rack failure and controller quorum

**Prompt:** Two of three controllers remain. Is the cloud highly available?

**Strong path:** Majority is one necessary control condition. Validate database/message/API behavior, cell reachability, gateways, storage copies, compatible workload capacity and exact user operations. Call reduced redundancy degraded.

### Scenario 4: stale Placement generation

**Prompt:** Would you update the allocation in SQL?

**Strong path:** No. The generation conflict prevents a stale write. Reload inventory/allocations, recalculate candidates, retry within a bound and investigate repeated contention. Direct SQL bypasses ownership and audit.

### Scenario 5: OVN router exists, traffic fails

**Prompt:** Where do you look?

**Strong path:** Compare Neutron revision to OVN NB, northd/SB state, port binding, chassis liveness, local OVS flows/interfaces, Geneve tunnel, underlay route/neighbor/MTU, HA gateway and exact application path.

### Scenario 6: Ceph degraded and near full

**Prompt:** Choose availability or durability.

**Strong path:** Reject the false binary. Preserve current protection, quantify affected objects/PGs and failure domains, client SLO, recovery throughput, maximum device fullness and time to full. Stop growth, add/rebalance capacity and tune recovery inside an abort envelope.

### Scenario 7: live migration stalls

**Prompt:** Force complete?

**Strong path:** Determine dirty-memory rate, transfer bandwidth, downtime budget and compatibility. Abort may be safest. Auto-convergence slows the guest; pause affects time/application; post-copy increases dependency on source connectivity. Choose with explicit user and failure risk.

### Scenario 8: failed host with local ephemeral disk

**Prompt:** Evacuate and recover data?

**Strong path:** Evacuation can recreate compute state but cannot invent lost local data. Fence, identify authoritative backup or upstream source, rebuild, restore if proven and state the data-loss/RPO boundary honestly.

### Scenario 9: design rack-aware OpenStack and Ceph

**Prompt:** Which labels do you create?

**Strong path:** Begin with verified physical rack/PDU/leaf hierarchy. Place quorum members independently. Map aggregates/AZs/OVN gateway hints/CRUSH rules to owned intent, add drift detection and test rack loss. Labels follow reality.

### Scenario 10: upgrade the private cloud

**Prompt:** One weekend, all components?

**Strong path:** Build dependency/version graph. Verify backups and isolated restore. Preserve quorum. Stage API/control, cells/computes, networking and storage in supported order with canaries, compatibility, user-path/capacity gates, abort and rollback/recovery. One blast-radius change is not speed.

### Scenario 11: restored databases disagree

**Prompt:** Delete orphan records?

**Strong path:** Keep restore isolated. Inventory server/allocation/domain/port/volume/image/guest identities and snapshot times. Determine authority for each class, fence writers, apply reviewed reconciliation, validate operation and promote separately. “Orphan” is a hypothesis.

### Scenario 12: BMC task timed out

**Prompt:** Retry power-cycle?

**Strong path:** No. Validate exact hardware identity, poll asynchronous task, read current power/boot state and decide whether fencing is achieved. Retrying an ambiguous non-idempotent action can undo or duplicate the first.

### Architecture defense in five minutes

Use this order:

1. operation and objectives;
2. physical and logical boundaries;
3. state authorities and acknowledgement;
4. declared failures and capacity;
5. security and observability;
6. recovery/upgrade;
7. evidence, limitations and next test.

Name trade-offs. A senior answer is not the most complicated architecture; it is the smallest design that satisfies measurable scenarios with recoverable failure.

## Independent transfer and rubric

`ASM-0258` is intentionally answer-isolated. A reviewer supplies a materially different synthetic operation, topology, workload mix and at least four hidden faults. The learner may reuse frameworks, not the fixture’s answers.

### Required differences

The reviewer changes at least:

- one physical layout or correlated domain;
- one workload state model;
- one capacity constraint;
- one networking or storage choice;
- one ambiguous cross-authority failure.

Examples include two sites with stretched-control constraints, erasure-coded object storage, SR-IOV non-migratable workloads, a cell isolation, uneven Ceph device classes or an image/key recovery problem. These are examples, not the hidden sheet.

### Deliverable sequence

1. Define user operation and evidence contract.
2. Map physical and logical topology.
3. Assign state authority and recovery action.
4. Calculate compatible compute and protected storage reserve.
5. Establish identity, image, tenant and management security.
6. Implement or adapt strict offline modeling.
7. Diagnose reviewer faults without seeing answers.
8. Build migration, upgrade, backup/restore and runbook decisions.
9. Validate the synthetic user operation and cleanup.
10. Defend evidence, unknowns and residual risk.

### Rubric interpretation

The ten criteria are each worth ten points. A numeric score is not mastery by itself.

- **Unsafe action:** repeating ambiguous power, force-migrating incompatibility, silently lowering protection, overwriting the only state or broad deletion is an automatic review stop.
- **Unsupported claim:** calling simulation production proof, inventing experience or promising zero loss without evidence is corrected and rescored.
- **Transfer:** the learner must adapt when the reviewer changes demand, failure or topology.
- **Evidence:** commands and diagrams matter only when identities, outputs, limits and decisions are explained.
- **Communication:** the learner states uncertainty, asks for authority where needed and gives an executable safe next step.

Publication never auto-completes this assessment. Only reviewer-owned evidence can update learner records.

## References and review

The source lock uses primary or official material and should be reread when the named software or release changes.

### Virtualization

- `REF-1160`: Linux KVM documentation defines the kernel VM/vCPU boundary.
- `REF-1161`: libvirt domain XML defines CPU, NUMA, device, storage and network contracts.
- `REF-1162`: libvirt migration defines data/control paths and security modes.
- `REF-1163`: QEMU migration explains iterative state transfer and compatibility.

### OpenStack compute and placement

- `REF-1164`: Nova Cells v2 explains global/cell state, scale and move caveats.
- `REF-1165`: Placement defines providers, inventories, traits and allocations.
- `REF-1166`: Nova 2026.1 live-migration guidance covers timeout, abort, auto-convergence and post-copy.
- `REF-1167`: Nova upgrade guidance supplies release-specific change boundaries.

### Network intent and realization

- `REF-1168`: Neutron OVN availability-zone guidance explains chassis metadata and HA placement.
- `REF-1169`: OVN architecture connects northbound intent, southbound state and chassis realization.
- `REF-1170`: OVN gateway HA explains external-path failure responsibility.

### Storage

- `REF-1171`: Ceph architecture defines monitors, maps, clients and OSD data paths.
- `REF-1172`: CRUSH maps define topology-aware placement.
- `REF-1173`: health checks distinguish quorum, PG, fullness, slow-op and scrub conditions.
- `REF-1174`: pools define protection, quota and CRUSH rules.
- `REF-1175`: monitoring guidance describes quorum, OSD, PG and capacity evidence.
- `REF-1176`: upgrade guidance defines health-gated daemon order and pause behavior.

### Security, image and hardware

- `REF-1177`: OpenStack Security Guide frames identity, network, instance and audit controls.
- `REF-1178`: Glance documentation defines image metadata/data and trust/recovery boundaries.
- `REF-1179`: DMTF Redfish 1.23.0 defines task, power, inventory and update semantics.

### Review boundary

The OpenStack, OVN and Ceph “latest” pages may describe development behavior. A real design must pin the deployed versions and use their supported upgrade/security documentation. Redfish implementations vary by vendor and schema profile.

This manuscript is a substantive quarantined draft. The local verifier proves deterministic model behavior only. Publication still requires formal multidisciplinary review, canonical gates and reviewer-owned independent transfer; learner mastery remains separate.
