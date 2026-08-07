---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0079",
  "slug": "ovs-ovn-virtual-networking",
  "aliases": ["V09-L04", "ovs-ovn-virtual-networking"],
  "curriculumIds": ["PRV-004"],
  "route": "/book/privatecloud/ovs-ovn-virtual-networking",
  "order": 4,
  "volume": "09-private-cloud",
  "title": "OVS and OVN operations: trace intent, flows, tunnels, policy, and packet delivery",
  "summary": "Trace one virtual packet from workload identity and CMS intent through OVN northbound and southbound state, chassis binding, OVSDB, OpenFlow and datapath realization, overlay and underlay transport, policy, destination delivery and reply.",
  "domain": "private-cloud",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0012", "LES-0013", "LES-0014", "LES-0015", "LES-0016", "LES-0052", "LES-0077"],
  "prerequisiteCurriculumIds": ["NET-001", "NET-002", "NET-003", "NET-004", "NET-005", "NET-006", "NET-007", "PRV-002"],
  "testedEnvironments": [
    {"platform":"Official documentation","version":"Open vSwitch 3.7.1 stable and OVN development distribution manuals reviewed 2026-08-07","support":"concept-only","notes":"The source set establishes architecture and tool semantics but does not prove any deployed release."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 58 cases, exported runtime-authority refusal, root refusal, unknown-artifact refusal and exact cleanup pass with zero runtime calls."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic 58-case, 57-gate intent, realization, transport, delivery and recovery evidence model."},
    {"platform":"OVS/OVN runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No package, daemon, database, bridge, port, flow, tunnel, logical topology, ACL or packet mutation is authorized."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "private-cloud-engineer", "network-engineer", "openstack-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Trace a request from CMS or OpenStack intent through OVN northbound state, northd compilation, southbound bindings, chassis-local controller realization, OVSDB, OpenFlow and datapath actions.",
    "Separate Linux interface and namespace state, OVS bridge/port/interface configuration, OpenFlow policy, datapath caches and physical link evidence.",
    "Explain OpenFlow matches, masks, tables, priorities, cookies, registers, metadata, resubmit, groups, meters, connection tracking and actions.",
    "Explain OVN logical switches, routers, ports, ACLs, NAT, DHCP, load balancing, port groups, address sets and gateway scheduling.",
    "Bind workload port identity to chassis, ofport, logical port, tunnel key, encapsulation endpoint, VNI and destination locality.",
    "Distinguish desired, compiled, installed, cached, transmitted, received, delivered and replied state.",
    "Diagnose VLAN, MTU, overlay/underlay, tunnel, stale-binding, missing-flow, policy, conntrack, NAT, gateway and asymmetric-path failures.",
    "Use ovn-trace and ofproto/trace as bounded predictions and correlate them with databases, installed flows, counters and packet capture.",
    "Protect OVSDB, OpenFlow, OVN databases, chassis identities, certificates, control sockets and diagnostic output with least privilege.",
    "Design database, northd, controller, gateway and underlay availability without confusing quorum or process health with packet delivery.",
    "Plan release/schema/protocol-aware canary upgrades, rollback, reconciliation, capacity, performance and exact cleanup.",
    "Prove recovery using the original user operation, bidirectional packet path, policy result and application-level transaction."
  ],
  "productionSignals": [
    "user operation source and destination workload port network tenant protocol tuple direction and time",
    "CMS or OpenStack resource UUID revision request ID intended network policy and binding host",
    "OVN northbound database cluster identity leader term transaction index schema and desired rows",
    "ovn-northd process version input progress output progress backlog errors and logical-flow generation",
    "OVN southbound database cluster identity leader term transaction index schema and compiled rows",
    "chassis system ID hostname encapsulation IP type availability zone gateway role and heartbeat",
    "port binding logical port datapath tunnel key requested chassis bound chassis up state and external IDs",
    "logical flow datapath pipeline table priority match actions stage source and generation",
    "local ovn-controller version SB progress OVS progress binding status recompute and errors",
    "local OVSDB bridge port interface controller manager external IDs other config and transaction state",
    "interface name type ofport link state admin state error MTU statistics and namespace ownership",
    "OpenFlow bridge protocol table priority cookie match actions duration packets bytes and offload state",
    "datapath flow masks actions packets bytes recirculation and upcall or miss pressure",
    "overlay tunnel type local and remote endpoint VNI or key MTU checksum and packet counters",
    "underlay route neighbor link loss latency MTU fragmentation ECMP firewall and bidirectional reachability",
    "ACL or security-group direction priority match action log meter address set port group and conntrack zone",
    "gateway chassis binding route NAT load balancer neighbor MAC binding BFD and failover state",
    "destination interface receive application response reverse path cleanup residue and residual risk"
  ],
  "diagrams": [
    {"id":"LES-0079-DIA-001","title":"OVN intent-to-packet realization path","direction":"left-to-right","boundaries":["CMS or OpenStack","OVN northbound DB","ovn-northd","OVN southbound DB","ovn-controller","local OVSDB and OpenFlow","datapath","workload and user"],"evidencePoints":["request","NB transaction","compile","SB generation","binding","installed flow","packet","transaction"],"textAlternative":"Desired logical networking flows from the CMS into northbound state, compiles into southbound state, realizes on each chassis and must still deliver a packet and user result."},
    {"id":"LES-0079-DIA-002","title":"OVS state-owner stack","direction":"hierarchical","boundaries":["Linux host and namespaces","OVSDB desired configuration","ovs-vswitchd OpenFlow policy","userspace classifier","kernel or userspace datapath cache","NIC and physical network"],"evidencePoints":["link","row","flow","megaflow","datapath action","wire"],"textAlternative":"Linux, OVSDB, OpenFlow and datapath layers own different state; agreement at one layer cannot prove the next."},
    {"id":"LES-0079-DIA-003","title":"Logical east-west overlay packet","direction":"left-to-right","boundaries":["source VIF","integration bridge","logical ingress pipeline","logical egress pipeline","Geneve tunnel","underlay","remote integration bridge","destination VIF"],"evidencePoints":["ofport","logical port","ACL","output key","VNI","outer tuple","decapsulation","delivery"],"textAlternative":"A logical packet is classified and encoded on the source chassis, transported over the underlay, decoded on the destination chassis and delivered to the bound port."},
    {"id":"LES-0079-DIA-004","title":"Trace correlation ladder","direction":"top-to-bottom","boundaries":["ovn-trace prediction","southbound logical flow","ovn-controller translation","OpenFlow flow","ofproto trace","datapath flow","packet capture","application result"],"evidencePoints":["stage","UUID","cookie","table","action","counter","frame","reply"],"textAlternative":"Each trace answers a narrower question and must be correlated downward to observed packets and upward to user intent."},
    {"id":"LES-0079-DIA-005","title":"North-south gateway and policy path","direction":"left-to-right","boundaries":["workload","distributed logical router","ACL and conntrack","NAT or load balancer","gateway chassis","provider bridge","physical router","external service"],"evidencePoints":["route","zone","translation","binding","patch port","VLAN","next hop","response"],"textAlternative":"North-south traffic crosses distributed and centralized functions whose placement, state and reverse path must be proven independently."},
    {"id":"LES-0079-DIA-006","title":"Change, failure and recovery state machine","direction":"cyclic","boundaries":["desired change","database commit","compile","chassis convergence","canary packet","fleet rollout","failure containment","rollback or reconciliation"],"evidencePoints":["revision","index","generation","installed state","user SLI","scope","authority","residue"],"textAlternative":"A network change is complete only after bounded convergence, bidirectional user proof and exact reconciliation or rollback."}
  ],
  "commands": [
    {"id":"LES-0079-CMD-001","question":"Is this a guarded no-network-mutation shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0079 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"source and authority guards pass","nextEvidence":"inventory tools"},{"when":"lab=fail","meaning":"a named guard failed","nextEvidence":"correct without bypass"}],"proves":"planned local model prerequisites","doesNotProve":"OVS or OVN health"},
    {"id":"LES-0079-CMD-002","question":"Which networking tools are merely present?","risk":"read-only","command":"bash lab.sh inventory-tools","runFrom":"LES-0079 support/lab","expectedBranches":[{"when":"inventory=observed","meaning":"command presence is reported without invocation","nextEvidence":"retain no-runtime limit"}],"proves":"planned command discovery","doesNotProve":"bridge or database identity"},
    {"id":"LES-0079-CMD-003","question":"Can bounded synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0079 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture exists","nextEvidence":"status"},{"when":"refusal","meaning":"authority or state is unsafe","nextEvidence":"preserve first error"}],"proves":"planned bounded initialization","doesNotProve":"network creation","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0079-CMD-004","question":"Are all reviewed cases loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"expected case count","meaning":"intended fixture is active","nextEvidence":"show baseline"},{"when":"other count","meaning":"fixture drift","nextEvidence":"stop"}],"proves":"planned fixture identity","doesNotProve":"OVS or OVN coverage"},
    {"id":"LES-0079-CMD-005","question":"Which synthetic claims create the baseline?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"model inputs are inspectable","nextEvidence":"evaluate baseline"}],"proves":"planned synthetic inputs","doesNotProve":"host state"},
    {"id":"LES-0079-CMD-006","question":"Does the baseline cross every evidence gate?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=operable-within-model","meaning":"all encoded predicates pass","nextEvidence":"compare failures"}],"proves":"planned deterministic decision","doesNotProve":"packet delivery"},
    {"id":"LES-0079-CMD-007","question":"Can correct NB intent fail to compile?","risk":"read-only","command":"bash lab.sh evaluate northd-stalled","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=northd-compile","meaning":"desired state did not become current SB state","nextEvidence":"NB and SB progress plus northd errors"}],"proves":"planned compilation boundary","doesNotProve":"ovn-northd behavior"},
    {"id":"LES-0079-CMD-008","question":"Can SB binding exist without local realization?","risk":"read-only","command":"bash lab.sh evaluate controller-stale","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=controller-realization","meaning":"chassis-local installed state is stale","nextEvidence":"controller progress OVSDB and OpenFlow"}],"proves":"planned realization boundary","doesNotProve":"chassis state"},
    {"id":"LES-0079-CMD-009","question":"Can logical trace pass while the underlay fails?","risk":"read-only","command":"bash lab.sh evaluate underlay-mtu-failed","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=underlay-transport","meaning":"logical prediction cannot prove physical transport","nextEvidence":"outer packet route MTU and both endpoints"}],"proves":"planned overlay boundary","doesNotProve":"real tunnel transport"},
    {"id":"LES-0079-CMD-010","question":"Can installed flows still select the wrong policy result?","risk":"read-only","command":"bash lab.sh evaluate stale-address-set","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=policy-input","meaning":"compiled policy used stale membership","nextEvidence":"revision address set logical flow and conntrack"}],"proves":"planned policy boundary","doesNotProve":"security-group behavior"},
    {"id":"LES-0079-CMD-011","question":"Can forward delivery pass while the user operation fails?","risk":"read-only","command":"bash lab.sh evaluate reverse-path-failed","runFrom":"LES-0079 support/lab after setup","expectedBranches":[{"when":"boundary=reply-path","meaning":"one-way evidence is insufficient","nextEvidence":"reverse route policy NAT tunnel and application reply"}],"proves":"planned bidirectional boundary","doesNotProve":"application correctness"},
    {"id":"LES-0079-CMD-012","question":"Do all decisions and cleanup pass with zero networking calls?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0079 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"cases refusals and cleanup pass","nextEvidence":"retain model-only limit"},{"when":"failure","meaning":"candidate evidence rejected","nextEvidence":"preserve first failure"}],"proves":"planned offline lifecycle","doesNotProve":"OVS OVN Linux networking or packets","cleanup":"Verifier must prove exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0079-LAB-001","title":"Guided OVS and OVN intent-to-packet evidence model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no networking authority","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","OVS or OVN database or socket","network namespace or link authority","cloud cluster Docker or libvirt context","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0079-ovs-ovn-virtual-networking/support/lab"},
    {"id":"LES-0079-LAB-002","title":"Independent disposable OVS and OVN packet-path recovery","mode":"independent","environment":"Reviewer-owned disposable isolated OVS/OVN topology or faithful harness with synthetic traffic","timeMinutes":240,"privilege":"least privilege; reviewer owns hidden faults and stop authority","network":"isolated local only","changes":["one bounded synthetic topology and flow","reviewer-controlled intent compilation binding flow tunnel policy gateway or reply defect"],"abortConditions":["production","public target","external cloud","real credential","customer traffic","unbounded load","host-management interface","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore one authoritative disposable path and prove exact absence.","cleanupProof":"Reviewer proves every database row bridge port flow namespace link tunnel capture process and temporary artifact absent or reconciled.","path":"drafts/LES-0079-ovs-ovn-virtual-networking/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0079-INC-001","signal":"OVN northbound intent is correct but a workload port has no connectivity.","firstThought":"Desired, compiled, bound, installed and delivered are separate states.","safePath":"Bind resource revision, NB/SB progress, port binding, chassis controller, OVSDB, OpenFlow and packet path.","trap":"Restart every controller or recreate the port."},
    {"id":"LES-0079-INC-002","signal":"ovn-trace predicts output but no remote workload receives the packet.","firstThought":"Logical trace explicitly cannot prove physical tunnel or underlay delivery.","safePath":"Correlate tunnel keys, local/remote endpoints, route, MTU, outer capture, decapsulation and destination VIF.","trap":"Declare the dataplane healthy from the trace."},
    {"id":"LES-0079-INC-003","signal":"Security policy was changed but old traffic remains allowed or new traffic drops.","firstThought":"Policy revision, address membership, compiled flow and conntrack state can disagree.","safePath":"Bind direction, tuple, ACL priority, address set, logical flow generation, installed flow and connection zone.","trap":"Flush all conntrack or weaken the ACL globally."},
    {"id":"LES-0079-INC-004","signal":"North-south traffic fails only after gateway rescheduling.","firstThought":"Logical routing, gateway placement, NAT, provider bridge, physical adjacency and reverse path moved together.","safePath":"Trace gateway binding, patch ports, VLAN, route, neighbor, NAT tuple, BFD and both directions.","trap":"Force a chassis or duplicate gateway authority blindly."},
    {"id":"LES-0079-INC-005","signal":"Latency or CPU rises while flow counts and upcalls grow.","firstThought":"Policy size, masks, cache churn, recirculation, connection tracking and offload boundaries drive datapath cost.","safePath":"Measure classifier/datapath counters, misses, masks, revalidation, CPU, queue and user latency before tuning.","trap":"Raise caches or bypass policy without a controlled experiment."}
  ],
  "assessmentIds": ["ASM-0220", "ASM-0221", "ASM-0222"],
  "referenceIds": ["REF-0943", "REF-0944", "REF-0945", "REF-0946", "REF-0947", "REF-0948", "REF-0949", "REF-0950", "REF-0951", "REF-0952", "REF-0953", "REF-0954", "REF-0955", "REF-0956", "REF-0957"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The guarded offline lab passes within its declared model boundary, but assessment files and the substantive manuscript are not complete.",
    "No OVS/OVN package, daemon, database, bridge, port, namespace, interface, route, flow, tunnel, logical topology, ACL, packet or gateway change is authorized.",
    "Current OVN distribution manuals describe a development line; exact deployed schema, protocol, package and compatibility remain unproved.",
    "Behavior depends on release, Linux kernel and datapath, CMS integration, topology, underlay, MTU, hardware offload, policy and workload.",
    "Formal technical/security/instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# OVS and OVN operations: trace intent, flows, tunnels, policy, and packet delivery

## What you see and first thought

When a virtual workload cannot communicate, do not translate “the network is down” into a restart. That sentence is too wide to diagnose. Replace it with an operation:

> Workload A at logical port P-A tried to open TCP from source IP and port S to destination IP and port D at time T. The connection did not complete within the promised latency.

Now you have something an engineer can follow. Keep the original source and destination, tenant/network, protocol, ports, direction, timestamp and request ID. A ping from a controller is a different operation. A curl from another namespace is a different operation. If you silently change the experiment, you can get a green result while the user remains broken.

### First thought: ask which promise failed

OVS and OVN form a chain of promises:

```text
CMS intent
  -> northbound commit
  -> northd compilation
  -> southbound binding and logical flows
  -> chassis controller convergence
  -> local OVSDB configuration
  -> OpenFlow policy
  -> datapath execution
  -> tunnel and underlay transport
  -> destination delivery
  -> application reply
```

Each arrow is a boundary. A healthy component proves only its own bounded claim. An ACTIVE Neutron port says the control plane reached a defined state. It does not prove the destination interface has a usable ofport. NB quorum says a majority can agree on commits. It does not prove northd consumed the relevant commit. An installed OpenFlow rule says policy exists. It does not prove the packet matched it. `ovn-trace` predicts the logical decision for supplied fields. It explicitly cannot prove that two chassis can exchange physical packets.

Whenever you see a green status, complete this sentence:

> Green according to **which owner**, for **which identity**, at **which generation**, during **which time window**, and what later boundary is still unproved?

That question is senior-level operational discipline.

### Do not begin with daemon restarts

A restart changes evidence. It can reconnect a controller, rebuild flows, move a gateway, expire caches or briefly remove networking for unrelated tenants. If the fault disappears, you still may not know whether the cause was a stale SB generation, an invalid interface, a tunnel route, a policy input or connection state. Worse, fleet-wide restarts synchronize load and expand a one-chassis problem.

Begin with read-only evidence and one mutation queue. Freeze rollout expansion. Preserve current database terms/indexes, northd and controller progress, port bindings, interface errors, flow generations, counters and a bounded packet capture. Then identify the first boundary where expected and observed state differ. Repair that owner through its supported interface.

### A small example that should stay in memory

Suppose `ovn-trace` ends with output to the correct logical port, yet the application times out.

Do not say, “OVN is fine.” Say:

- The supplied microflow matched the expected logical pipeline in the SB snapshot.
- Chassis placement, installed OpenFlow, datapath execution and physical delivery remain unproved.
- I will bind the destination Port_Binding and chassis generation, correlate the logical flow with local OpenFlow, then observe source encapsulation, remote receipt, decapsulation, destination VIF delivery and the reply.

That phrasing is accurate, actionable and safe.

## Terms before commands

The same word can mean different objects at different layers. Learn the nouns before memorizing commands.

### OVS, bridge, port and interface

Open vSwitch, or OVS, is a programmable software-switch system. In OVS language, a **bridge** is a switch. A **Port** is a logical attachment on that bridge. An **Interface** describes the concrete network device or OVS-created endpoint used by a port. A simple port often contains one interface with the same name, but bonds and special interface types break that easy assumption.

The Linux kernel also has interfaces, namespaces, routes and neighbors. Those are not the same as OVSDB rows. An Interface row may exist while its `ofport` is `-1` because realization failed. A Linux link may be UP while no correct OpenFlow action selects it. Always join database identity to effective interface identity.

### OVSDB, ovs-vswitchd and the datapath

**OVSDB** is a transactional database protocol and data model. The local Open_vSwitch database holds desired configuration such as bridges, ports, interfaces, controllers and mappings. `ovs-vsctl` primarily speaks to that configuration database.

**ovs-vswitchd** reads configuration, implements switching policy and exposes OpenFlow behavior. The **datapath** performs packet execution. Depending on deployment, it may be the Linux kernel datapath, a userspace datapath or hardware offload. These implementations do not provide identical feature and evidence boundaries.

OVS has multiple useful meanings of “flow”:

- An **OpenFlow flow** has tables, priority, matches and actions. It expresses policy.
- A **hidden flow** is internal policy that normal OpenFlow dumps may omit.
- A **datapath flow** or **megaflow** is an implementation cache derived from packet classification. It is not the source-of-truth policy.

This is why `ovs-ofctl dump-flows`, `ovs-appctl bridge/dump-flows` and `ovs-appctl dpif/dump-flows` answer different questions.

### OpenFlow pipeline vocabulary

A packet lookup occurs in a **table**. Within that table, matching rules compete by **priority**; the highest-priority matching rule wins. A **match** constrains fields such as input port, Ethernet/IP addresses, protocol, connection state, registers or metadata. **Actions** drop, output, modify, encapsulate, recirculate, group or continue processing.

A **cookie** is controller-provided metadata used to identify flow ownership or purpose. It is not packet data and is not automatically unique unless the control system makes it so. **Registers** and **metadata** carry intermediate logical context through a pipeline. **resubmit** performs another lookup, often in another table. **recirculation** sends a packet through later classification with additional parsed or connection state.

Never dump “flows” without recording bridge, OpenFlow protocol, table scope, time and ownership. Otherwise you may compare different views and call the difference a failure.

### OVN, NB, SB, northd and chassis

Open Virtual Network, or OVN, adds logical switching, routing and policy across many OVS chassis.

- The **Northbound database (NB)** stores high-level desired networking: logical switches, routers, ports, ACLs, NAT, load balancers and related objects.
- **ovn-northd** compiles NB intent into lower-level logical flows and bindings.
- The **Southbound database (SB)** stores compiled logical datapaths, logical flows, chassis information and port bindings.
- **ovn-controller** runs per chassis. It consumes relevant SB state and programs local OVSDB/OpenFlow realization.
- A **chassis** is an OVN forwarding node with a stable system ID and advertised encapsulation endpoint.

Configuration generally moves north to south. Some status moves south to north. Quorum is about database authority. `nb_cfg`-style generations or transaction indexes help reason about progress. Neither is a packet counter.

### Logical topology and binding

A **logical switch** provides logical Layer 2 connectivity. A **logical router** connects logical networks at Layer 3. A **logical switch port** or **logical router port** is an attachment in that topology.

A **Port_Binding** connects a logical port/datapath identity to realization information such as tunnel keys and, when scheduled, a chassis. The row existing does not prove the named chassis consumed it. Binding, controller convergence and local interface readiness are separate gates.

### Overlay, underlay and Geneve

The **overlay** is the logical tenant topology. The **underlay** is the physical IP network between chassis. OVN commonly transports logical context in **Geneve** encapsulation. The outer packet needs routable tunnel endpoints and enough MTU for inner packet plus encapsulation headers.

A correct logical route cannot repair a broken underlay route. A tunnel interface can exist while return traffic is filtered. An inner MTU of 1500 cannot traverse a 1500-byte underlay after adding outer headers without fragmentation or a smaller effective payload. Diagnose inner and outer packets separately.

### Policy, connection tracking and NAT

An **ACL** is direction- and priority-aware logical policy. **Address sets** and **port groups** supply membership used by policy. If membership is stale, a correctly compiled ACL can make the wrong decision for current intent.

**Connection tracking** records flow state in a **zone**. Stateful policy and NAT depend on exact zone and tuple semantics. Existing connections can behave differently from new ones after a policy change. A global conntrack flush destroys unrelated state and is not a diagnostic shortcut.

**NAT** changes addresses or ports. A **load balancer** selects a backend and may use connection state. A **gateway chassis** realizes centralized functions such as some north-south paths. Gateway placement, provider bridge/VLAN, physical route and reverse NAT path must agree.

## Architecture map

The architecture runs from CMS intent to NB, through northd into SB, then through one controller into local OVSDB, ovs-vswitchd and the datapath on each participating chassis. Overlay transport still depends on the physical underlay.

### Control and realization map

```text
OpenStack / CMS
      |
      | desired networks, ports, policy, routers
      v
OVN Northbound DB  ---- authority, term/index, schema
      |
      | consumed and compiled by ovn-northd
      v
OVN Southbound DB  ---- logical flows, datapaths, bindings, chassis
      |
      +-------------------------+
      |                         |
      v                         v
ovn-controller A          ovn-controller B
      |                         |
 local OVSDB + OpenFlow     local OVSDB + OpenFlow
      |                         |
 datapath A -- Geneve / underlay -- datapath B
      |                         |
 source VIF                destination VIF
      +------ application request and reply ------+
```

The important lesson is not the boxes; it is the handoff evidence. For each arrow, record the upstream identity and generation, downstream observed generation, lag, error and time.

### Physical packet map

For cross-chassis east-west traffic, a useful simplified path is:

```text
source process
 -> source namespace/VIF
 -> source integration bridge ingress
 -> logical ingress policy
 -> logical switch/router decision
 -> logical egress policy
 -> local tunnel output
 -> outer underlay route/NIC
 -> remote NIC/tunnel input
 -> remote integration bridge
 -> destination VIF/namespace
 -> destination process
 -> reverse path
```

The actual OpenFlow tables are implementation- and release-specific. Preserve the conceptual stages, then discover exact tables and cookies from the deployed system. Copying table numbers from another release is not expertise.

### What high availability means here

NB/SB database HA protects database authority and availability. Multiple northd processes or an active/standby design protect compilation. Per-host controllers protect local realization only when each is current. Gateway redundancy protects centralized forwarding only when placement, detection, physical adjacency, NAT/connection state and reverse routing recover coherently.

Therefore “three databases and two gateways” is not a reliability proof. You need physical failure-domain independence, survivor capacity, bounded convergence, packet-path tests and application acceptance.

## Request or state path

One packet will be followed from a workload VIF through logical ingress tables, policy, routing or switching, logical egress, tunnel encapsulation, underlay transit, remote decapsulation, destination delivery and the reverse application path.

## Failure zoom

The failure atlas will isolate stale CMS revisions, database quorum without progress, northd backlog, stale port binding, controller lag, missing OpenFlow, cache churn, VLAN mismatch, tunnel-key error, underlay MTU failure, stale policy inputs, conntrack residue, gateway failure and asymmetric return.

## Internals and state ownership

Linux, OVSDB, OpenFlow, the datapath, OVN northbound, OVN southbound, northd, each chassis controller, the underlay and the workload own different facts. No single “up” field is permitted to speak for all of them.

## Evidence table

The completed evidence table will bind every claim to identity, scope, time, source, expected branch and next boundary. It will distinguish desired, compiled, installed, cached, transmitted, received, delivered and replied evidence.

## Command decoders

Each command card will explain the question, authority, output branches, proof limit and next evidence for OVSDB inspection, OpenFlow dumps, ofproto tracing, datapath inspection, OVN database views, port bindings, logical flows, ovn-trace, Linux links, routes and packet capture.

## Decision path

The decision tree begins with the failed user operation, proves both endpoint identities and locality, then descends through intent, compilation, binding, local realization, logical policy, overlay, underlay, destination and reply. Mutation waits until the first failed boundary is proven.

## Guided Ubuntu lab

The guided lab will be an offline deterministic evidence model. It will refuse root and all detected network, OVS, OVN, cloud, cluster, Docker and libvirt authority; it will make no networking command and will clean only a UID-scoped allowlisted fixture.

## Production transfer

A representative transfer requires a reviewer-owned disposable topology, synthetic traffic, bounded blast radius, known-good recovery and exact cleanup. The learner must correlate logical prediction with installed flows, wire evidence and the original application result.

## Reliability, security, observability, capacity, and cost

The completed chapter will connect database and controller availability, convergence budgets, gateway reserve, least-privilege control channels, flow and tunnel telemetry, MTU and bandwidth capacity, classifier/cache cost, connection tracking, hardware offload and operational complexity.

## Traps and prevention

Primary traps include treating a successful trace as delivery, treating northbound state as realization, reading only one flow layer, flushing state globally, weakening policy, forcing gateway placement, ignoring reverse traffic and changing the host management path during diagnosis.

## Memory card and retrieval

The memory card will compress the path into: intent, compile, bind, install, execute, transport, deliver, reply. Retrieval drills will require reconstructing both ownership and evidence rather than recalling isolated commands.

## Complete answers

The completed answer guide will show safe, evidence-led reasoning for definitions, command outputs, capacity math, incident containment, recovery proof and architecture trade-offs without relying on hidden assumptions.

## Product-company interview

Senior and staff scenarios will test packet-path explanation, ambiguous status, safe incident leadership, scale and failure-domain design, upgrade strategy, security boundaries, performance reasoning and concise communication.

## Independent transfer and rubric

The independent transfer will hide the fault and expected answer. It will score path reconstruction, evidence quality, safety, causal reasoning, recovery proof, cleanup and prevention rather than keyword recall.

## References and review

Fifteen official Open vSwitch and OVN sources are locked for this lesson. Version-specific behavior will remain a deployed-environment question, and formal technical, security and instructional review remain separate publication gates.
