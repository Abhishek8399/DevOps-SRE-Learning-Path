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

Follow one packet and one configuration revision together. The state path explains why the packet should be forwarded; the packet path proves whether it was.

### Stage 1: define the user operation

Record source workload and logical port, destination name/IP and logical port, tenant or project, logical network, protocol and ports, direction, timestamp and expected result. For TCP, “SYN sent but no SYN-ACK returned” is more useful than “connection failed.” For DNS or UDP, define the query and response you expect.

### Stage 2: bind CMS intent

In OpenStack, correlate the server, Neutron port, network, subnet, router, security groups and revision numbers. A resource name is not enough; UUIDs and revisions prevent you from following a similarly named or replaced object.

Ask:

- Does the source port belong to the expected host and network?
- Does the destination IP belong to the expected port?
- Which security groups and address memberships should apply?
- Is routing, NAT, load balancing or provider access involved?

This proves the intended control-plane object graph, not OVN realization.

### Stage 3: prove the northbound transaction

Bind the NB database cluster identity and schema. Record leader, term, commit progress and the exact logical rows/revisions representing the operation. Quorum is necessary for authoritative progress but insufficient: a client can read an older view, a transaction can be absent, or the desired row can be internally inconsistent.

### Stage 4: prove northd compilation

ovn-northd converts high-level intent into logical datapaths, logical flows and related SB state. Compare its observed NB input progress with its SB output progress. A live process can be stalled on an error, overloaded by churn or behind the relevant transaction.

The key question is:

> Did the exact desired revision become the expected compiled generation?

### Stage 5: prove southbound state

Bind the SB database identity, schema, authority and progress. Locate the logical datapath, logical flows, chassis records, datapath/tunnel keys and Port_Binding records relevant to both endpoints.

Check requested placement and actual binding separately. A port can retain a stale chassis after migration or fail to bind because the destination chassis has not claimed it.

### Stage 6: prove chassis identity and encapsulation

Every chassis needs a stable system ID and correct encapsulation advertisement. Bind:

- chassis/system ID and host identity;
- encapsulation type;
- local tunnel endpoint IP;
- availability-zone or gateway role;
- heartbeat/freshness;
- exact source and destination Port_Binding.

A duplicate system ID or wrong encap IP can direct correct logical output to the wrong physical endpoint.

### Stage 7: prove controller convergence

On each involved chassis, determine whether ovn-controller is connected to the intended SB and local OVSDB and has consumed the relevant generation. Do not infer convergence from process state alone.

Separate:

- SB connection;
- local OVSDB connection;
- expected versus observed configuration generation;
- binding activation;
- incremental-engine backlog or full recompute;
- errors programming local state.

### Stage 8: prove local OVSDB realization

Bind the actual integration bridge, ports and interfaces. Join logical identity through external IDs or the deployment’s authoritative mapping. Record interface type, ofport, admin/link state, error, MTU and statistics.

An Interface row with `ofport=-1` is a failed realization, not a usable port. A positive ofport can still refer to a link that is down or a replaced interface if identity is not bound.

### Stage 9: prove logical-flow to OpenFlow translation

Start with the logical stage that should decide the packet. Then identify the corresponding local OpenFlow rule or rules. Capture:

- bridge and negotiated OpenFlow protocol;
- table and priority;
- cookie or other ownership correlation;
- complete match, including registers/metadata and connection state;
- actions and next table;
- duration, packet and byte counters;
- time of observation.

More than one OpenFlow rule can represent a logical flow, and some local plumbing flows do not correspond directly to an OVN logical flow. Correlation must be explicit.

### Stage 10: simulate, then observe

Use `ovn-trace` to test logical intent and `ofproto/trace` to test local OVS pipeline behavior for exact packet fields. These are what-if engines. They help find the rule and action that would apply to the supplied state.

Then observe reality:

- Did the real packet enter the expected ofport?
- Did relevant counters change?
- Did the datapath choose the expected action?
- Did an outer tunnel packet leave?

Never convert simulated output into packet evidence.

### Stage 11: prove source encapsulation

For a remote logical destination, bind the logical tunnel key, destination chassis and local/remote tunnel endpoints. Check the selected tunnel type and effective MTU.

The inner packet plus Geneve, UDP, IP and Ethernet overhead must fit the underlay path. Offloads can make host captures look larger than wire frames; interpret capture point and NIC offload state before declaring malformed traffic.

### Stage 12: prove underlay transport

The underlay needs:

- a route to the remote tunnel endpoint;
- correct source address and next hop;
- neighbor resolution;
- bidirectional firewall/security policy;
- sufficient MTU;
- loss, latency and ECMP behavior within limits;
- working physical links and NIC queues.

Observe the outer packet leaving the source and arriving at the remote endpoint. If it leaves but never arrives, the logical pipeline is no longer the first failed boundary.

### Stage 13: prove remote decapsulation and delivery

At the remote chassis, prove outer receipt, successful decapsulation, local logical processing and output to the exact destination ofport. Then prove the inner packet reaches the destination namespace or workload.

A remote tunnel counter can increase while output is dropped by egress policy, invalid binding, link state or connection tracking.

### Stage 14: prove the application reply

The destination process must accept the request and generate the expected reply. Bind listener/process health and application logs without exposing sensitive payload. Then trace the reverse packet through policy, routing/NAT, tunnel and underlay.

One-way delivery is not a successful transaction.

### Stage 15: reconcile outcome and residue

After recovery, validate:

- the original user operation;
- a new connection and, where relevant, an existing connection;
- both directions;
- expected allow and deny policy;
- latency/error SLI;
- current generations and stable counters;
- absence of temporary captures, flows, rows, state entries and elevated authority.

Only then is recovery proven within the stated scope.

## Failure zoom

Most incidents are disagreements between adjacent owners. Use these zoomed cases to recognize the boundary without jumping to a cure.

### Failure 1: ACTIVE port, missing effective interface

The CMS record is healthy, but the destination Interface has `ofport=-1` or an error. Intent passed; local realization failed. Preserve controller/OVSDB errors and repair the interface owner. Recreating unrelated ports hides the defect.

### Failure 2: quorum without forward progress

NB or SB reports quorum, but commit/index progress stalls or clients observe old state. Quorum answers “can a majority agree?” Progress answers “did the needed state advance?” Diagnose leader health, storage latency, connectivity and transaction load without rewriting database files.

### Failure 3: NB current, northd behind

The desired ACL or port revision exists in NB, but northd has not produced corresponding SB state. Check input/output progress, logs, CPU, memory, database latency and churn. Restarting every chassis cannot compile missing SB state.

### Failure 4: stale Port_Binding after migration

The workload moved, but SB still binds the logical port to the old chassis or no chassis. Prove source-of-truth placement and controller claims before supported reconciliation. Never manually edit a production binding merely to make the row look right.

### Failure 5: controller connected but unconverged

ovn-controller has live sockets but has not installed the relevant generation. Connection health is not convergence. Inspect generation lag, incremental-engine status, recompute, local OVSDB/OpenFlow errors and resource pressure.

### Failure 6: wrong OpenFlow view

An operator dumps the wrong bridge or negotiates an older protocol that hides fields/tables. The output appears to show “no flow.” Record bridge, protocol and table scope, and correlate ownership before concluding absence.

### Failure 7: higher-priority shadow rule

The expected rule exists, but another rule in the same table matches with higher priority. A text search for the expected rule misses selection semantics. Use exact microflow tracing and inspect the winner plus its actions.

### Failure 8: logical policy current, membership stale

The ACL is correct, but an address set or port group does not contain the current endpoint. The compiled policy faithfully enforces stale input. Compare CMS membership revision, NB membership, SB generation and local installed match.

### Failure 9: existing connection survives policy change

A new ACL should deny traffic, but an established conntrack entry continues according to designed stateful semantics—or the reverse. Bind the exact zone, tuple, direction and state. Do not flush every zone; determine whether existing-flow behavior matches the approved policy contract.

### Failure 10: NAT or load-balancer state disagrees

The logical rule exists, but a connection is pinned to an old translation/backend or the reverse path lacks matching state. Compare new and established connections, gateway ownership, conntrack/NAT tuple and backend health.

### Failure 11: logical trace passes, tunnel key is wrong

The logical pipeline outputs to a port, but source and destination disagree on datapath/port tunnel keys because of stale generations or mixed versions. Bind exact SB rows and both controllers before changing flows.

### Failure 12: wrong encapsulation endpoint

The destination chassis advertises an unreachable or management-only IP. Logical placement is valid; physical destination selection is not. Correct the authoritative chassis configuration and prove underlay reachability in both directions.

### Failure 13: underlay MTU is too small

Small pings work, larger TCP stalls and source captures show outer packets without remote receipt. Calculate encapsulation overhead, test bounded sizes and observe ICMP/fragmentation behavior. Randomly lowering every tenant MTU treats the symptom and can create inconsistent networks.

### Failure 14: native/access/trunk VLAN mismatch

Provider traffic leaves the expected bridge but the physical switch interprets tags differently. Bind OVS Port tag/trunk/native semantics and physical switch configuration. The same VLAN number can still have incompatible tagging behavior.

### Failure 15: asymmetric underlay ECMP or firewall

Forward outer packets arrive; replies disappear on another ECMP path or are blocked. Prove both endpoint routes, source selection and each direction. “Tunnel ping works from one host” is not bidirectional workload proof.

### Failure 16: gateway placement changed without complete adjacency

Gateway failover moves logical authority, but provider bridge mapping, VLAN, route, neighbor or NAT state is incomplete on the new chassis. Preserve singular gateway ownership; verify every physical dependency before sending traffic.

### Failure 17: datapath miss and revalidation storm

User CPU and latency rise while upcalls, revalidation and cache churn grow. High-level flow count alone is insufficient. Measure masks, megaflows, recirculation, policy churn, classifier cost, controller recompute and user SLI before tuning.

### Failure 18: hardware offload differs from software

Installed software flows look correct, but offloaded packets behave differently or counters split across layers. Compare offload status, hardware counters and a controlled software-path canary. Do not disable offload fleet-wide without capacity and rollback evidence.

### Failure 19: destination received, application did not reply

The packet reaches the VIF, but no listener, local firewall, namespace route or application response exists. The virtual network delivered its part. Continue to the application boundary instead of changing tunnels.

### Failure 20: recovery left stale state

The user journey works, but temporary flows, captures, debug logging, connection entries or elevated certificates remain. Residue changes future behavior and leaks data/authority. Inventory and remove only exact owned artifacts, then retest.

## Internals and state ownership

Linux, OVSDB, OpenFlow, the datapath, OVN databases, daemons, the underlay and workloads own different facts.

| Owner | Authoritative or useful state | It does not own |
|---|---|---|
| CMS/OpenStack | User-facing resource intent, placement request and revision | OVN compilation, host flows or packet delivery |
| OVN NB | Desired logical topology and policy | Chassis-local realization |
| ovn-northd | Translation from NB concepts to SB logical state | Local datapath execution |
| OVN SB | Compiled logical flows, datapaths, bindings and chassis declarations/status | Physical underlay truth |
| ovn-controller | Chassis-local translation and convergence | Other chassis or application correctness |
| local OVSDB | Desired local bridges, ports, interfaces and controller settings | Packet match outcome |
| ovs-vswitchd/OpenFlow | Switch policy and pipeline decision | Physical remote receipt |
| datapath | Cached packet actions and counters | Source-of-truth logical intent |
| Linux/NIC | Interfaces, routes, neighbors, queues and outer packets | Tenant policy intent |
| physical network | Underlay forwarding, MTU and loss | Inner logical correctness |
| workload/application | Listener, request handling and reply | Control-plane convergence |

### Desired, observed and effective state

For every layer, separate three forms:

- **Desired:** what an owner asked for.
- **Observed:** what a database, daemon or command reports.
- **Effective:** what the next boundary actually used.

An OVSDB Interface row is desired/observed configuration. A valid ofport and installed flow are later effective-state evidence. A flow counter is evidence that some matching packets used the rule, not necessarily the packet you care about unless time and tuple correlate.

### Generations are causal join keys

Distributed systems converge asynchronously. Use revision numbers, database indexes, NB/SB configuration generations, binding identities and flow ownership to join evidence. Wall-clock timestamps help but clocks and buffering make them weaker alone.

A useful incident timeline says:

1. CMS revision R committed.
2. NB index N contained R.
3. northd generated SB configuration S.
4. destination controller acknowledged/observed S.
5. local OpenFlow cookie/table set F represented S.
6. packet P incremented F and outer capture C.
7. destination and application observed P.

This is much stronger than six screenshots saying “up.”

### Flow caches are derived state

Datapath flows accelerate execution. They can be evicted and regenerated. Treat them as runtime evidence, not configuration to manage directly under ordinary operations. If cache behavior is wrong, find the policy, classifier, revalidation or offload cause. Deleting caches without a hypothesis may briefly hide a defect and cause an upcall storm.

### Stateful networking adds time

ACL, NAT and load-balancer decisions may depend on connection history. Two packets with the same addresses and ports can behave differently if one begins a new connection and another belongs to established state. Record connection zone, direction, flags, NAT state and whether the test is new or existing.

### Cleanup is an ownership transition

Temporary diagnostic state has an owner and expiry:

- captures have path, permissions, retention and sensitive-data rules;
- debug logging has component, level and automatic rollback;
- test flows have controller/cookie and exact deletion selector;
- test ports/namespaces have creator and inventory;
- connection-state changes have zone/tuple scope;
- temporary certificates/tokens have revocation proof.

“We will clean later” is not a control.

## Evidence table

Use the table as a ladder. Stop at the first failed boundary; do not collect impressive evidence from unrelated layers.

| Question | Evidence | Proves | Does not prove | Next boundary |
|---|---|---|---|---|
| What failed? | User operation, tuple, endpoints, direction, time, SLI | Exact diagnostic target | Any cause | CMS identity |
| Is intent current? | Resource UUIDs/revisions and NB rows | Desired topology/policy recorded | Compilation | northd progress |
| Did compilation occur? | NB input and SB output generations, logical rows | Relevant intent became compiled state | Local install | binding/controller |
| Is placement current? | Port_Binding, requested/actual chassis, encap | Compiled destination and tunnel identity | Controller convergence | chassis state |
| Did controller converge? | Controller connections, generations and errors | Local translator consumed relevant state | Successful interface/flow | OVSDB/OpenFlow |
| Is local attachment usable? | Bridge/Port/Interface UUID, ofport, link, error, MTU | Concrete local port realization | Correct policy selection | OpenFlow |
| Which policy wins? | Protocol, table, priority, cookie, match, actions | Selected installed rule for exact microflow | Real packet execution | counters/datapath |
| What would OVS/OVN do? | ovn-trace or ofproto/trace with exact fields | Modelled decision in observed state | Physical packet movement | actual observation |
| Did datapath act? | Datapath action/counter correlated by tuple/time | Cached execution evidence | Remote receipt | source outer packet |
| Did source transmit? | Outer capture/counters and tunnel endpoint/key | Encapsulation left source boundary | Underlay delivery | remote outer capture |
| Did underlay deliver? | Route/neighbor/MTU plus remote outer receipt | Physical transport to remote chassis | Decapsulation/VIF delivery | inner remote packet |
| Did destination receive? | Inner capture/counter at exact VIF/namespace | Packet reached workload boundary | Application accepted/replied | listener/application |
| Did application reply? | Listener log, response and reverse packet | Destination application acted | Full return to caller | reverse path |
| Did user recover? | Original transaction and SLI | Observed outcome in window | Future resilience | soak/retest |
| Is work closed? | Current generations, artifact inventory and absence | Exact reconciliation/cleanup | Learner mastery | review and delayed recall |

### Evidence quality rules

Good evidence is:

- identity-bound rather than name-only;
- time-bounded rather than “current sometime”;
- generation-aware rather than process-only;
- collected at both sides of a boundary;
- minimally privileged and privacy-aware;
- reproducible by another reviewer;
- explicit about what remains unknown.

Weak evidence often has no command context, no timestamp, truncated matches/actions, missing direction, unbound UUIDs, copied output from another host or a conclusion broader than its source.

## Command decoders

These are production-reading patterns, not commands to paste blindly. Run them only against an authorized environment, from a host and identity approved for that control plane. Record exact versions and consult the matching manpage because schemas, fields and flow pipelines change.

### Decoder 1: show local OVS topology

```bash
ovs-vsctl show
```

**Question:** Which local OVS instance, bridges, ports, interfaces and controllers does OVSDB currently describe?

`ovs-vsctl` talks to OVSDB. `show` renders a summary rather than every column. Look for the integration bridge, provider bridges, patch/tunnel ports, interface types and controller endpoints.

**Branches:**

- Expected bridge/port absent: local desired configuration is missing or you queried the wrong OVSDB.
- Row present but later interface/flow evidence fails: desired configuration exists; continue downward.
- Duplicate or unexpected bridge: stop and bind deployment ownership before changing anything.

**Does not prove:** interface readiness, controller convergence, selected OpenFlow or packet delivery.

### Decoder 2: inspect interface realization

```bash
ovs-vsctl --columns=_uuid,name,type,ofport,error,link_state,admin_state,mtu,status,statistics list Interface
```

**Question:** Did each declared Interface become a usable effective port?

`--columns` limits output to fields needed for identity and health. `_uuid` distinguishes replacement rows with the same name. `ofport` connects the interface to OpenFlow. `error` explains failed creation when populated. `link_state` and `admin_state` are separate.

**Branches:**

- `ofport=-1` or an error: local realization failed; inspect controller/vswitchd logs and device prerequisites.
- Positive ofport but link down: follow the concrete interface/link owner.
- All fields expected: continue to installed policy; do not declare the path healthy.

Some columns or meanings are release/interface-type dependent. Confirm them against the deployed schema.

### Decoder 3: dump OpenFlow with an explicit protocol

```bash
ovs-ofctl -O OpenFlow13 dump-flows br-int
```

**Question:** What OpenFlow policy is visible on this bridge through the selected protocol?

`-O OpenFlow13` chooses a protocol; it is an example, not a universal required version. Select a protocol supported by the deployed OVS/OVN contract. `dump-flows` is read-only; `br-int` must be replaced by the verified bridge.

Capture table, priority, cookie, match, actions, duration and counters. A grep match without the winning priority and prerequisite metadata is weak evidence.

**Branches:**

- Protocol negotiation fails: prove supported protocol/version before interpreting absence.
- Expected cookie/table absent: verify controller generation and correlation method.
- Expected flow present but counters do not change: packet may not enter with assumed fields or another rule wins.
- Counters change: some matching packets used it; correlate tuple/time and continue to datapath/wire.

**Warning:** `ovs-ofctl add-flow`, `mod-flows` and `del-flows` mutate policy and are not diagnostic substitutes.

### Decoder 4: include hidden bridge flows

```bash
ovs-appctl bridge/dump-flows br-int
```

**Question:** Does ovs-vswitchd have hidden/internal OpenFlow policy that a normal OpenFlow dump omits?

`ovs-appctl` sends a control command to a local daemon socket. This requires local authority even when the subcommand is read-only. Use it only on an authorized chassis.

Use this view when in-band control or internal flows might explain a surprising result. Do not compare it line-for-line with `ovs-ofctl dump-flows` and call differences corruption; the views intentionally differ.

### Decoder 5: simulate the local OVS pipeline

```bash
ovs-appctl ofproto/trace br-int 'in_port=5,ip,nw_src=192.0.2.10,nw_dst=198.51.100.20'
```

**Question:** Given these exact fields and current switch state, which local rules and actions would ovs-vswitchd select?

The bridge and microflow are inputs. Unspecified fields may receive defaults that do not match the real packet. For stateful paths, include the required protocol and connection context supported by the exact release.

Read:

- initial normalized flow;
- every table and winning rule;
- field/register changes;
- resubmits/recirculation;
- final flow, megaflow and datapath actions.

**Does not prove:** that the actual packet arrived, that conntrack has the assumed history, that the remote host is reachable or that the action succeeded.

### Decoder 6: inspect datapath flows

```bash
ovs-appctl dpif/dump-flows
```

**Question:** What derived datapath cache entries and counters exist now?

Datapath flows are implementation state. Match masks show how traffic is aggregated; actions show cached execution; packet/byte counters show use. Exact formatting and available filters vary by version and datapath.

**Branches:**

- No relevant entry: it may be uncached, recently evicted, offloaded elsewhere or never received.
- Entry/action unexpected: correlate back to OpenFlow and trace before clearing anything.
- Very high churn/miss/upcall evidence: measure revalidation and CPU with user SLI.

**Trap:** deleting caches can cause new misses and hides the evidence. Fix the source policy or invalidation cause.

### Decoder 7: inspect OVN northbound intent

```bash
ovn-nbctl show
```

**Question:** What logical switches, routers and ports does the selected NB database describe?

First bind the remote database endpoint, cluster identity, schema and credentials without exposing secrets. `show` is a summary; use schema-aware `list` or `find` queries for exact UUIDs, ACLs, address sets, port groups, NAT and load balancers.

**Branches:**

- Desired object absent/wrong: stay at CMS-to-NB ownership.
- Object and revision correct: prove northd consumed it.
- Duplicate/stale-looking object: establish CMS ownership before any cleanup.

**Does not prove:** SB compilation, binding, local flows or packets.

### Decoder 8: inspect southbound chassis and bindings

```bash
ovn-sbctl show
```

**Question:** Which chassis, encapsulations, datapaths and logical-port bindings are visible in the selected SB?

Correlate logical port names/UUIDs with the CMS and inspect exact Port_Binding columns through schema-aware queries when needed. Record requested chassis, actual chassis, tunnel key, datapath and up/status fields available in that release.

**Branches:**

- Chassis absent/stale: verify controller registration and identity.
- Binding absent: compilation or scheduling failed.
- Bound to old/wrong chassis: freeze movement and prove authoritative placement.
- Binding correct: prove controller generation and local realization.

### Decoder 9: list logical flows

```bash
ovn-sbctl lflow-list
```

**Question:** Which logical datapath flows did northd compile?

Output can be large. Narrow it using version-supported datapath or logical-flow identifiers rather than losing context with an arbitrary text match. Capture pipeline, table/stage, priority, match, actions and UUID/source correlation where available.

**Does not prove:** that the relevant chassis installed corresponding OpenFlow. Some flows are not needed on every chassis, and one logical flow can translate into multiple physical flows.

### Decoder 10: simulate the OVN logical path

```bash
ovn-trace --minimal logical-switch-name \
  'inport == "source-port" && eth.src == 00:00:5e:00:53:01 && ip4.src == 192.0.2.10 && ip4.dst == 198.51.100.20'
```

**Question:** What would the current logical pipeline do with this microflow?

`--minimal` shows a concise result. Use detailed output when you need each logical stage and matched flow. Provide unambiguous Ethernet/IP/protocol fields; contradictory or incomplete expressions can be rejected or model the wrong packet.

**Critical limit:** ovn-trace reads logical state. It does not simulate physical chassis distribution or reachability. A successful logical output is the beginning of chassis/tunnel validation, not the end.

### Decoder 11: prove underlay route selection

```bash
ip route get 203.0.113.20 from 203.0.113.10
```

**Question:** Which local route, source address, device and next hop would Linux select between tunnel endpoints?

Replace addresses with verified local and remote encap endpoints. `from` matters on multihomed hosts because source-specific policy can select another table/path.

**Branches:**

- Unreachable or wrong device/source: underlay routing is the first failed boundary.
- Expected route: prove neighbor/link, effective MTU and actual outer packets.

This is route selection on one host, not end-to-end reachability or return-path proof.

### Decoder 12: capture a bounded Geneve sample

```bash
sudo tcpdump -ni UNDERLAY_IFACE -s 0 -c 50 \
  'udp port 6081 and host 203.0.113.20'
```

**Question:** Did bounded outer Geneve traffic cross this capture point?

`-n` avoids name-resolution traffic and delay. `-i` selects the verified interface. `-s 0` captures full packets and increases privacy/storage exposure. `-c 50` bounds packet count. The filter narrows protocol and peer; confirm the deployment’s actual tunnel port.

This command usually needs capture privilege. Obtain authorization, minimize payload, use a protected lesson/incident-specific path if writing a file, define retention and remove it exactly.

**Branches:**

- Source sees outer transmit, remote does not: focus on underlay path.
- Both see outer packet, no inner delivery: focus on decapsulation/remote policy/binding.
- No source packet: return to local flow/datapath selection.
- Reply missing: repeat with endpoints reversed and trace reverse logical/NAT state.

Offloads can change how packet sizes/checksums appear at a host capture. Correlate NIC settings and a remote/wire observation before concluding corruption.

## Decision path

Use this decision path during an incident. Do not skip ahead because a command is familiar.

### Gate 0: safety

Stop if the target, authority or blast radius is unclear. Confirm this is the intended environment, identify production/management interfaces, protect credentials and capture data, and assign one mutation owner.

### Gate 1: operation

Can you state the exact user operation and both directions?

- **No:** define endpoints, logical ports, tuple, tenant, time and outcome.
- **Yes:** preserve it as the invariant test.

### Gate 2: intent

Do CMS revision and NB state match the expected topology/policy?

- **No:** remain at CMS/NB ownership. Do not edit SB or host flows.
- **Yes:** record NB progress and continue.

### Gate 3: compilation

Did northd consume that NB state and produce current SB logical state?

- **No:** diagnose northd/database progress and capacity.
- **Yes:** bind logical flows and Port_Binding.

### Gate 4: placement and convergence

Are source/destination bound to the correct chassis, with correct encap endpoints, and are both controllers current?

- **No:** contain migrations/failover and use supported binding/controller reconciliation.
- **Yes:** continue to local realization.

### Gate 5: local attachment

Do integration bridge, interface UUID/name, ofport, link and MTU match the workload?

- **No:** repair the local interface/device owner.
- **Yes:** continue to policy.

### Gate 6: logical and physical policy

Does the exact packet match the intended logical flow, OpenFlow winner and stateful policy?

- **No:** resolve revision, membership, priority, metadata/register or conntrack/NAT cause.
- **Yes:** continue to actual execution.

### Gate 7: source execution

Did the actual inner packet enter, counters/actions correlate and the expected outer packet leave?

- **No:** investigate source namespace, OpenFlow, datapath, cache or offload.
- **Yes:** record tunnel key/endpoints and continue.

### Gate 8: underlay

Does the outer packet arrive at the remote chassis with valid route, MTU and bidirectional transport?

- **No:** diagnose the physical route, neighbor, firewall, ECMP, link, MTU or loss.
- **Yes:** continue to remote processing.

### Gate 9: delivery and reply

Did remote decapsulation and VIF delivery occur, did the application reply, and did the reverse path succeed?

- **No inner delivery:** inspect remote binding, flow and link.
- **Delivered/no reply:** inspect workload listener, local firewall and application.
- **Reply generated/not returned:** trace reverse policy, NAT, gateway, tunnel and underlay independently.
- **Success:** proceed to recovery acceptance.

### Gate 10: closure

Require stable generations, correct allow/deny behavior, existing/new connection tests, latency/error SLI, soak, exact cleanup, residual risk and an owned prevention action. A single successful ping is not closure.

## Guided Ubuntu lab

This lab teaches diagnostic order without touching networking. It never runs OVS, OVN, `ip`, `tc` or packet-capture tools. It creates only a UID-scoped directory under `/tmp`, copies one JSON fixture, evaluates deterministic Boolean evidence and removes only its sentinel and fixture.

### Why the lab is a model

A realistic OVS/OVN topology requires privileged network operations and can disrupt host or corporate connectivity if pointed at the wrong runtime. The guided exercise therefore isolates reasoning first. It proves that you can recognize the first failed boundary. It does not prove OVS/OVN skill on a live topology; that belongs to the reviewer-owned independent transfer.

### Step 1: enter the lab safely

From the repository root in Ubuntu 24.04, as a normal user:

```bash
cd drafts/LES-0079-ovs-ovn-virtual-networking/support/lab
bash lab.sh doctor
```

Expected:

```text
model=valid cases=58 gates=57
doctor=pass network=none user=1000 runtime_calls=none
```

Your UID may differ. `runtime_calls=none` is the important boundary. Root, configured runtime authority or detected OVS/OVN control sockets cause refusal.

### Step 2: inventory tools without invoking them

```bash
bash lab.sh inventory-tools
```

The output reports whether commands such as `ovs-vsctl`, `ovn-trace`, `ip` and `tcpdump` are discoverable. It uses `command -v` only. “yes” proves a command name resolves in this shell; it proves no daemon, database, privilege, release compatibility or network state.

### Step 3: create the bounded fixture

```bash
bash lab.sh setup
bash lab.sh status
```

Expected branches:

- `setup=pass`: one sentinel and one copied fixture exist.
- `state-exists`: a previous run remains; inspect and use the exact cleanup command rather than deleting a broad path.
- `credential-or-runtime-authority`: remove the exported lesson-irrelevant authority from this shell; never bypass the guard.
- `runtime-socket-detected`: use an isolated Ubuntu environment without active OVS/OVN control sockets.

Status should report 58 cases: one valid baseline and one isolated failure per gate.

### Step 4: inspect the baseline

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

Every field is `true`. That does not mean “the network is healthy.” It means the synthetic candidate has crossed every evidence predicate encoded by this model.

Expected:

```text
case=baseline boundary=operable-within-model expected=operable-within-model
```

### Step 5: diagnose compilation lag

```bash
bash lab.sh show northd-stalled
bash lab.sh evaluate northd-stalled
```

Only `northd_compilation_current` changes to false. The result is:

```text
case=northd-stalled boundary=northd-compilation expected=northd-compilation
```

Your operational conclusion should be: NB authority and progress passed earlier gates, but relevant intent did not become current SB compiled state. Chassis restarts are downstream and unjustified.

### Step 6: separate logical prediction from transport

```bash
bash lab.sh evaluate underlay-mtu-failed
```

Expected boundary: `underlay-mtu`. All earlier logical, binding, controller, OVSDB, OpenFlow and route gates pass. This models the classic case where logical traces look correct but encapsulated frames cannot cross the physical path.

Explain aloud:

> I would calculate inner plus encapsulation overhead, bind the actual tunnel endpoints and capture points, then prove source transmit and remote receipt. I would not claim OVN failure or lower every tenant MTU.

### Step 7: prove the reverse path is independent

```bash
bash lab.sh evaluate reverse-path-failed
```

The model passes destination delivery, application reply generation and reverse logical processing before failing reverse transport. Forward success cannot prove a completed transaction.

### Step 8: compare policy and state

```bash
bash lab.sh evaluate stale-address-set
bash lab.sh evaluate conntrack-zone-or-state-wrong
```

These stop at different gates. Stale membership means compiled policy input is wrong. Wrong conntrack state means the intended policy may exist, but stateful execution for the exact zone/tuple is wrong. The remediation and blast radius differ.

### Step 9: run every case and refusal

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=58 refusal=true cleanup=true runtime_calls=none
```

The verifier also injects an unknown artifact. While that artifact exists, ordinary status and cleanup refuse. This is deliberate: cleanup may not delete a file it does not own.

### Step 10: confirm absence

The verifier cleans automatically. You can safely request idempotent cleanup:

```bash
bash lab.sh cleanup
```

Expected: `cleanup=pass absent=true`. This proves only lesson-state absence for your UID.

### Guided retrieval questions

1. Why does NB quorum appear before northd compilation?
2. Why does controller connectivity appear before controller convergence?
3. Why does OpenFlow installation appear before datapath and packet observation?
4. Why are source transmit, remote receive and destination delivery separate?
5. Why is the user transaction before observability/capacity/upgrade/cleanup gates?

Answers: authority must precede translation; a socket is not current state; policy is not execution; each physical boundary can independently drop; outcome validates the immediate incident while later gates decide whether recovery is operable, sustainable and closed.

## Production transfer

A representative transfer requires a reviewer-owned disposable topology or a faithful isolated harness with synthetic traffic. Do not use an employer network, public target, management interface, real tenant credential or customer payload.

### Required topology

Use at least:

- two isolated chassis or network namespaces that faithfully represent separate forwarding nodes;
- one logical switch with endpoints on different chassis;
- one logical router connecting a second logical network;
- one stateful ACL using an address set or port group;
- one Geneve overlay over a distinct underlay;
- one provider or gateway path if the environment safely supports it;
- bounded synthetic TCP and UDP transactions;
- independent stop and cleanup authority.

If real OVS/OVN cannot be safely installed, use a reviewed sandbox/build-tree dummy datapath. Record exactly which physical behaviors it cannot represent.

### Reviewer fault families

The reviewer hides at least one defect from each group:

1. intent/compilation: stale revision, northd lag or missing logical flow;
2. binding/realization: wrong chassis, bad ofport or stale controller generation;
3. policy/state: wrong address membership, priority shadow or stale connection state;
4. transport/gateway: wrong encap endpoint, MTU, provider mapping, route or gateway;
5. outcome/closure: reverse failure, missing application reply, stale telemetry or residue.

The learner must discover the first failed boundary without an answer key.

### Stop conditions

Stop and convert the exercise to incident handling if:

- any packet reaches an unapproved interface or address;
- host management connectivity changes;
- real credentials, tenant data or external services appear;
- CPU, memory, disk, packet rate or flow count exceeds the approved limit;
- the cleanup inventory differs from the preapproved manifest;
- authority or topology identity becomes ambiguous.

### Acceptance evidence

The reviewer scores the independent `ASM-0222` rubric. A passing demonstration needs:

- exact state and packet identities;
- generation-aware CMS/NB/northd/SB/controller evidence;
- local OVSDB/OpenFlow/datapath correlation;
- bounded trace and packet evidence;
- both directions and an application transaction;
- safe owner-specific correction;
- expected deny as well as allow behavior;
- stable SLI during a soak window;
- exact cleanup and independent residue check;
- bounded claims and residual risk.

Reading this chapter cannot satisfy that evidence.

## Reliability, security, observability, capacity, and cost

Treat these as one operating design. A highly available system that leaks control authority is unsafe. A secure design that cannot converge within the user objective is unreliable. An observable platform with no capacity reserve only explains its failure well.

### Reliability: availability is a path

Define objectives for:

- NB/SB authoritative read/write availability;
- commit and client-observed progress;
- northd compilation latency;
- chassis-controller convergence;
- port-binding activation;
- logical-policy installation;
- east-west and north-south user journeys;
- gateway failover and reverse-path recovery;
- stale-state and cleanup duration.

Avoid a single “network uptime” number. A control plane can be writable while existing packets continue, or forwarding can work while new ports never bind. Each mode has a different user impact and response.

Place database members across real power/rack failures. Ensure quorum latency remains acceptable. Treat northd capacity and failure separately from database capacity. Gateways need singular authority, independent placement and enough survivor throughput. Underlay redundancy must preserve MTU, policy and symmetry, not merely link count.

### Security: control channels are production authority

Protect:

- NB/SB and local OVSDB endpoints;
- OpenFlow and daemon control sockets;
- certificates, private keys and trust roots;
- chassis system IDs and encapsulation configuration;
- CMS plugin credentials;
- host privileges and network namespaces;
- diagnostic logs, flow matches and packet captures.

Use authenticated encrypted remote connections where the deployed design supports them, least-privilege RBAC, short-lived operator access, protected local sockets and auditable change paths. Do not expose database or OpenFlow listeners broadly for convenience.

Flow and capture output can reveal tenant addresses, topology, policy and payload. Minimize fields and packets, encrypt storage, restrict readers, define retention and prove deletion. Redact secrets, not evidence needed for causality.

### Observability: measure handoffs

Useful dashboards answer:

- Are NB/SB authoritative, progressing and within storage/latency limits?
- What is northd input-to-output lag?
- Which chassis/controllers are stale or recomputing?
- How long do ports take from CMS creation to binding and usable ofport?
- Are logical-flow and OpenFlow counts/churn changing unexpectedly?
- Are upcalls, revalidation, cache misses or recirculation increasing?
- Which tunnels lose packets or approach MTU/bandwidth limits?
- Are gateways imbalanced or out of survivor capacity?
- Do representative user journeys succeed in both directions?

Use bounded-cardinality labels. Per-flow or per-tenant labels at full scale can overload the monitoring system and expose tenancy. Preserve high-detail evidence on demand with strict retention.

Alert primarily on user symptoms and sustained failure risks: fast convergence breach, widespread unbound ports, database progress stall, gateway exhaustion or tunnel loss. A process restart or leader change without user/risk impact is often an event, not a page.

### Capacity: count work, not components

Capacity dimensions include:

- NB/SB rows, transactions per second, database disk latency and compaction;
- logical flows, address-set/port-group membership and policy churn;
- northd compilation CPU/memory and worst-case recompute time;
- per-controller relevant state, incremental changes and full recompute;
- OpenFlow rules, tables, masks and revalidation;
- datapath megaflows, misses, upcalls, recirculation and connection entries;
- tunnel count, packets/bytes, NIC queues and underlay bandwidth;
- gateway packets/bytes/connections, NAT/load-balancer state and failover reserve;
- observability volume and capture/debug overhead.

Plan for the largest declared failure. If one gateway fails, can survivors accept its new connections and state without breaching latency? If a controller restarts, can it converge while ordinary churn continues? If an address set changes widely, can northd/controllers process the fan-out inside the objective?

### Performance: protect the user while explaining the pipeline

Measure latency at the application and packet boundaries. Break it into source scheduling, local switching, tunnel/underlay, remote switching and application response where possible.

High CPU can originate from policy churn, too many masks, cache misses, revalidation, connection tracking, logging, encapsulation, NIC IRQ imbalance or offload failure. Change one hypothesis at a time. A flow-table optimization can weaken isolation; an offload change can move load back to CPUs. Use canary, workload equivalence, security checks and rollback.

### Cost: optimize total operational economics

Costs include compute cores reserved for forwarding, gateway headroom, database storage/IOPS, high-bandwidth NICs, hardware offload, telemetry retention, cross-zone/rack traffic and engineer time.

Consolidating gateways may lower instance count but enlarge failure and bandwidth concentration. Retaining every flow/capture improves forensic depth but raises storage and privacy risk. Hardware offload can improve packet economics but adds compatibility and diagnostic complexity. Make the trade explicit:

```text
total cost =
  steady infrastructure
  + failure reserve
  + telemetry and retention
  + operational complexity
  + expected incident and change risk
```

The cheapest steady-state design is rarely the cheapest reliable service.

## Traps and prevention

### Trap: “The port is ACTIVE”

**Failure:** a CMS status is treated as local interface and packet proof.

**Prevention:** correlate resource revision through NB, SB binding, controller generation, ofport, flow, packet and application.

### Trap: “The databases have quorum”

**Failure:** majority authority is treated as transaction and compilation progress.

**Prevention:** record leader/term, commit progress, client view, northd input/output and SB generation.

### Trap: “ovn-trace passes”

**Failure:** logical simulation is treated as physical delivery.

**Prevention:** continue through local OpenFlow/datapath, source outer packet, remote receipt, decapsulation, VIF delivery and reply.

### Trap: grep one flow dump

**Failure:** wrong bridge/protocol/table or a higher-priority match remains invisible.

**Prevention:** bind protocol and ownership, preserve full matches/actions, and trace the exact microflow.

### Trap: edit SB or install a hand-written flow

**Failure:** derived/controller-owned state is bypassed, creating drift that reconciliation may overwrite.

**Prevention:** correct the authoritative CMS/NB/controller input through supported ownership. Use temporary diagnostic flows only in approved disposable exercises with exact cookies and cleanup.

### Trap: flush all connection tracking

**Failure:** unrelated tenant connections and NAT state are destroyed.

**Prevention:** bind exact zone, tuple, direction, policy revision and consequence; use the narrowest supported action only after proving stale state.

### Trap: lower MTU everywhere

**Failure:** a local underlay inconsistency becomes fleet-wide tenant change.

**Prevention:** calculate encapsulation overhead, prove the failing segment and standardize a reviewed end-to-end MTU contract.

### Trap: restart every network agent

**Failure:** evidence disappears and synchronized recompute/upcall load expands impact.

**Prevention:** preserve generations/errors, isolate the first unconverged owner and canary the smallest safe restart or reconciliation.

### Trap: force gateway placement

**Failure:** duplicate or physically incomplete gateway authority can create asymmetric NAT or blackholes.

**Prevention:** prove singular binding, provider mapping, VLAN, route, neighbor, state and survivor capacity before movement.

### Trap: trust only forward traffic

**Failure:** request delivery is confused with transaction completion.

**Prevention:** trace reply generation plus reverse logical, NAT, gateway, tunnel and underlay paths.

### Trap: compare flow counts across layers

**Failure:** logical, OpenFlow and datapath flows are treated as one-to-one objects.

**Prevention:** compare causal identities and behavior, not raw counts; one logical flow may compile into many local rules and many packets may share a megaflow.

### Trap: leave debug residue

**Failure:** verbose logs, captures, temporary rules, credentials or stale state alter future behavior and expose data.

**Prevention:** declare owner, expiry and exact inventory before enabling; verify absence and retest at closure.

## Memory card and retrieval

### Ten lines to remember

1. Start with the exact user operation and both directions.
2. ACTIVE is intent status, not packet delivery.
3. Quorum is authority, not progress.
4. NB intent must compile into current SB state.
5. SB binding must converge into local OVSDB/OpenFlow.
6. OpenFlow policy must become datapath execution.
7. A trace predicts; a capture observes.
8. Overlay correctness still depends on underlay route and MTU.
9. Stateful policy/NAT requires exact zone, tuple and time.
10. Recovery ends at application proof and exact cleanup.

### One mnemonic: I-C-B-I-E-T-D-R

**Intent → Compile → Bind → Install → Execute → Transport → Deliver → Reply.**

If you cannot name evidence for the next word, you have found the boundary to investigate.

### Retrieval drill

Close the lesson and answer:

- What does NB own that SB does not?
- Why can a controller be connected but stale?
- Which command views OpenFlow policy and which views datapath cache?
- What does ovn-trace explicitly not model?
- Where do you account for Geneve overhead?
- Why can new and established connections differ after an ACL change?
- What three observations separate source, underlay and destination?
- What proves incident closure?

Then draw the architecture from memory. Reopen the lesson only after attempting it. Retrieval, not rereading, builds durable recall.

## Complete answers

### 1. Is OVS a Linux bridge?

OVS is a programmable multilayer software-switch system with OVSDB management, OpenFlow policy and multiple datapath options. In networking language an OVS Bridge is a switch, but it is not the Linux bridge implementation. Both can connect interfaces; their management, policy and internals differ.

### 2. What is the difference between Port and Interface?

An OVS Port is a logical bridge attachment. It contains one or more Interfaces. A simple port usually has one same-named interface; a bond has multiple interfaces. The Interface carries type, ofport, link/error and statistics needed to prove realization.

### 3. What does ofport -1 mean?

The Interface row exists but OVS could not assign a usable OpenFlow port. Treat it as a local realization failure. Inspect its error, type/device prerequisites and ovs-vswitchd/controller evidence; do not use the mere row as connectivity proof.

### 4. What is the difference between OVSDB and OpenFlow?

OVSDB represents configuration/state through transactional tables: bridges, ports, interfaces and control settings. OpenFlow represents packet-processing policy through tables, matches, priorities and actions. Configuration can exist while forwarding policy is absent or stale.

### 5. Why are there several kinds of flows?

OpenFlow flows express switch policy. Hidden flows support internal behavior. Datapath/megaflows cache derived execution for performance. They serve different owners and diagnostic questions, so commands that dump them legitimately differ.

### 6. What is the highest-priority rule?

Within the selected table, among rules whose complete matches fit the packet, the highest priority wins. First ensure the packet actually reaches that table and that prerequisite registers/metadata/connection state match. Looking only at destination IP is insufficient.

### 7. What are registers and metadata?

They are pipeline fields used to carry intermediate context such as logical datapath, port or policy decisions across tables. Their exact allocation is implementation-specific. They explain why a visually simple packet may require a detailed trace to match the installed rule.

### 8. What does northd do?

ovn-northd reads high-level NB logical topology/policy and produces lower-level SB logical state for controllers. Its process being alive does not prove it consumed the relevant NB transaction or emitted current SB output; compare progress/generations.

### 9. What is a chassis?

A chassis is an OVN forwarding node represented by a stable system ID and encapsulation information, usually running ovn-controller and OVS. Hostname alone is weak identity. Duplicate or stale system IDs can misplace bindings and tunnels.

### 10. What does Port_Binding prove?

It associates a logical port/datapath with tunnel and placement information in SB. A populated chassis column proves compiled/observed binding state in that SB snapshot. It does not prove the controller consumed it, local interface exists or a packet was delivered.

### 11. Why is ovn-trace not enough?

It simulates logical processing from SB for a supplied microflow. It does not simulate physical chassis reachability. Tunnel endpoints, underlay routing/MTU, local installation, actual conntrack history, NICs, destination interface and application reply need separate evidence.

### 12. What is ofproto/trace for?

It simulates how the current local OVS bridge pipeline would process supplied fields. It shows matching rules, resubmits and actions. It does not inject a packet or prove remote delivery, and unspecified fields may model a different packet.

### 13. Why can small packets work while TCP stalls?

Encapsulation adds outer headers. Small packets fit; larger inner packets may exceed the underlay path MTU. Missing or filtered fragmentation-needed feedback produces a black-hole pattern. Calculate overhead and observe both tunnel endpoints.

### 14. How do VLAN and Geneve differ?

A VLAN tag identifies a Layer 2 segment on a shared link/trunk. Geneve encapsulates an inner packet inside an outer UDP/IP packet between tunnel endpoints and can carry logical metadata. Provider VLAN and overlay Geneve can both appear in one end-to-end path at different boundaries.

### 15. Why can old and new connections behave differently?

Stateful ACL/NAT/load-balancing decisions use connection tracking. Established entries preserve state or translation while a new flow evaluates current policy. Bind the zone/tuple/direction and test both populations before declaring inconsistency.

### 16. What does database quorum prove?

It proves enough members can participate in authoritative consensus under that database’s rules. It does not prove a specific transaction exists, clients see it, northd compiled it, controllers converged or packets flow.

### 17. How should an east-west failure be debugged?

Bind operation and endpoints; prove CMS/NB intent, northd/SB compilation, port bindings/chassis, controller convergence, local interfaces, logical/OpenFlow selection, source execution, tunnel/underlay, remote delivery, application reply and reverse path. Stop at the first failed handoff.

### 18. How should a north-south failure differ?

Add logical routing, gateway placement, NAT/load-balancer state, provider bridge mapping, VLAN, physical route/neighbor and external reverse path. A distributed east-west test bypasses several of these and cannot clear them.

### 19. What makes a safe fix?

It targets the proven first failed owner through a supported interface, has bounded blast radius, one change owner, stop conditions, rollback/recovery, before/after evidence and user validation. It does not overwrite derived state or destroy broad connection evidence.

### 20. What proves recovery?

Current authoritative generations; correct binding/interface/flow state; actual bidirectional delivery; original application transaction and SLI; expected allow and deny behavior for old/new connections; stable soak; reconciled state; exact diagnostic/authority cleanup; owned prevention and residual risk.

## Product-company interview

### Scenario 1: explain OVS and OVN in two minutes

**Evaluating:** architecture clarity.

**Strong answer:** OVS is the per-node programmable switch: OVSDB describes local configuration, ovs-vswitchd implements OpenFlow policy and a datapath executes cached actions. OVN supplies multi-node logical networking. A CMS writes high-level logical topology/policy to NB; northd compiles it into SB logical flows and bindings; each chassis controller programs relevant local OVS state. Overlay packets still depend on Linux/NIC and an IP underlay. I would emphasize that desired, compiled, installed and delivered are separate states.

**Follow-up:** Where would you look if NB is correct but a migrated VM cannot receive?
**Answer:** northd/SB progress, Port_Binding requested/actual chassis, destination controller generation, local interface/ofport, OpenFlow and then tunnel delivery.

### Scenario 2: trace passes, traffic fails

**Evaluating:** proof boundaries.

**Strong answer:** I would confirm whether it is ovn-trace or ofproto/trace and preserve the exact microflow. Passing ovn-trace proves the SB logical model selected an output, not local installation or physical reachability. I would correlate the logical flow to source OpenFlow/datapath, observe outer transmission, prove underlay route/MTU and remote receipt, then decapsulation, destination VIF, application reply and reverse path.

**Weak warning:** “Restart ovn-controller because trace says OVN is fine.”

### Scenario 3: policy change affects new connections only

**Evaluating:** stateful reasoning.

**Strong answer:** Separate intended existing-flow semantics from a fault. Bind ACL direction/priority, address-set or port-group revision, compiled/installed generation, and exact conntrack zone/tuple/state. Test one established and one new connection. If the old entry is invalid, retire only the reviewed scope through a supported action; a global flush is unacceptable because it destroys unrelated tenant/NAT state.

**Follow-up:** What if new flows also disagree?
**Answer:** return to membership revision, logical flow selection and installed OpenFlow rather than blaming retained state.

### Scenario 4: design for 100,000 logical ports

**Evaluating:** scale and capacity.

**Strong answer:** I would demand workload/update distributions, not size alone. Model NB/SB row and transaction rates, database IOPS/compaction, policy membership fan-out, northd incremental and full-recompute latency, per-controller relevant state/convergence, OpenFlow rules/masks/revalidation, datapath misses/upcalls, conntrack entries, tunnel/gateway bandwidth and observability cardinality. Define failure reserve: convergence and user SLI must hold when a database member, chassis or gateway fails during ordinary churn.

**Weak warning:** sizing only by VM count or CPU average.

### Scenario 5: one rack loses underlay connectivity

**Evaluating:** incident command and failure domains.

**Strong answer:** Freeze changes and identify affected journeys/chassis/tunnel endpoints. Separate database/control reachability from data underlay. Prove routes, neighbors, link state, loss and both directions at rack boundaries. Prevent uncontrolled gateway/port movement until destination capacity and singular authority are known. Mitigate through the predesigned alternate path or bounded placement policy, validate application journeys and reconcile stale bindings after physical recovery.

**Follow-up:** Why not evacuate everything immediately?
**Answer:** movement increases database/controller churn and can overload surviving compute, tunnels and gateways while storage/writer authority may also be uncertain.

### Scenario 6: rolling OVS/OVN upgrade

**Evaluating:** compatibility and rollback.

**Strong answer:** Inventory exact OVS/OVN/kernel/datapath/CMS versions and schema/OpenFlow compatibility. Back up and test database restoration in isolation. Upgrade a representative canary failure domain, preserve supported ordering and version pinning/compatibility behavior, and measure NB/SB progress, northd/controller convergence, flow/offload behavior and bidirectional user journeys. Stop on schema, generation, security, performance or SLI regression. Rollback is credible only if schema/state compatibility and exact reconciliation are proven.

### Scenario 7: secure the control plane

**Evaluating:** security architecture.

**Strong answer:** Minimize and authenticate NB/SB/OVSDB/OpenFlow exposure; protect local sockets; use managed certificates and trust-root rotation; apply RBAC/least privilege for CMS, daemons and operators; protect chassis identity; restrict host privileges; audit changes; and treat flows/logs/captures as tenant-sensitive. Design certificate expiry/rotation monitoring and a break-glass path that is time-bound, recorded and independently reviewed.

**Weak warning:** “It is on the management network, so TLS is unnecessary.”

### Scenario 8: high CPU with low packet rate

**Evaluating:** performance diagnosis.

**Strong answer:** Compare user latency with northd/controller CPU and datapath/vswitchd CPU. Look for policy churn, address-set fan-out, full recomputes, revalidation, many masks, cache misses/upcalls, recirculation, conntrack pressure, debug logging and failed offload. Establish a stable workload and change rate, then canary one hypothesis. Packet rate alone does not capture control/reclassification work.

**Follow-up:** What would you not do?
**Answer:** disable policy/offload globally or enlarge caches without memory, security, workload-equivalence and rollback evidence.

### Scenario 9: gateway failover causes asymmetric NAT

**Evaluating:** north-south ownership.

**Strong answer:** Bind gateway chassis authority before and after failover, NAT/load-balancer tuple and conntrack state, provider bridge mapping/VLAN, physical route/neighbor and reverse path. Ensure only one intended owner forwards at a time and that the new gateway has capacity and adjacency. Validate new and established flows according to the design; do not force a second gateway or flush all state to make a test pass.

### Scenario 10: staff-level prevention proposal

**Evaluating:** systemic learning and communication.

**Strong answer:** I would standardize an intent-to-outcome correlation contract: resource revision, NB/SB progress, chassis/binding, controller generation, flow ownership and bounded journey ID. Add SLOs for port convergence and critical packet journeys, automated MTU/bridge-mapping preflight, versioned compatibility gates, canary upgrades, gateway survivor tests and privacy-bounded on-demand captures. Run failure exercises for stale binding, northd lag, policy membership, MTU and reverse path. Track actions by measurable recurrence prevention, not document creation.

**Weak warning:** proposing more dashboards without changing detection, ownership or safe recovery.

## Independent transfer and rubric

`ASM-0222` is reviewer-only and contains no direct answer, reasoning guide or follow-up answer. The reviewer supplies a disposable topology and hides five materially different fault classes.

### Before starting

The learner submits:

- target/topology identity and diagram;
- approved traffic and resource limits;
- protected management interfaces;
- stop conditions and incident conversion;
- preexisting inventory;
- recovery/rollback owner;
- cleanup manifest;
- evidence retention/privacy plan.

### During diagnosis

The learner must state a hypothesis before each evidence request, preserve causal IDs/generations and maintain one mutation queue. Evidence must distinguish intent, compilation, binding, installation, execution, transport, delivery and reply.

### Scoring interpretation

Each of ten criteria is worth ten points:

- **90–100:** expert transfer within this scenario; no mastery claim without delayed varied evidence.
- **75–89:** strong but with named gaps requiring retest.
- **60–74:** coached transfer; safety and reasoning gaps remain.
- **Below 60:** insufficient evidence; repeat after remediation.
- **Automatic stop/review:** unauthorized target, broad destructive state change, leaked sensitive material, unbounded traffic or unproved cleanup.

### Delayed recall

After a separated interval, present a different topology and fault combination. The learner must recreate the ownership map and safe path without this lesson. Delayed success is new evidence; the mentor-operated model is not.

## References and review

Fifteen official sources were resolved on 2026-08-07. The Open vSwitch stable pages identify 3.7.1. The current OVN distribution manpages identify a development line. Therefore, these sources support concepts and current documented interfaces but cannot certify a deployed environment. Always use the matching installed-release manuals and schemas for operations.

### REF-0943 — What Is Open vSwitch?

Component overview for ovs-vswitchd, ovsdb-server, management utilities, OpenFlow and datapath options. Use it for architecture, not deployment-specific feature proof.

### REF-0944 — Open vSwitch Advanced Features

Official multi-table/VLAN-learning tutorial and dummy `ovs-sandbox` model. Its sandbox procedure can delete a directory named `sandbox` in its current location; use only a reviewed lesson-owned build directory.

### REF-0945 — Tracing packets inside Open vSwitch

Official `ofproto/trace` explanation. Supports trace interpretation and the distinction among rule traversal, megaflow and datapath actions.

### REF-0946 — Implementation Details

Official explanation of OpenFlow, hidden and datapath flows and why their dump commands differ. Datapath internals can change and are not universal across hardware implementations.

### REF-0947 — Using OpenFlow

Official protocol and hop-by-hop troubleshooting guidance. Supports explicit OpenFlow-version selection and tracing packets across virtual and physical boundaries.

### REF-0948 — VLANs

Official access/trunk/native VLAN and host-stack guidance. Use the exact deployed OVS and physical-switch semantics for configuration.

### REF-0949 — VXLANs

Official overlay configuration concepts. This lesson primarily uses Geneve for OVN reasoning, but VXLAN reinforces VNI, tunnel endpoint and underlay separation.

### REF-0950 — ovs-vsctl(8)

Authoritative local OVSDB query/transaction interface. Read the deployed manpage before using column/table/transaction syntax. Mutating commands require change authority and rollback.

### REF-0951 — ovs-ofctl(8)

Authoritative OpenFlow inspection/mutation interface. Supports explicit protocol, flow/table/group/meter concepts. This lesson does not authorize production flow mutation.

### REF-0952 — ovn-architecture(7)

Official NB-to-SB-to-chassis information flow and logical/physical packet lifecycle. Development documentation is concept evidence, not release compatibility proof.

### REF-0953 — ovn-nb(5)

Northbound schema for logical switches, routers, ports, ACLs, NAT, load balancing and related intent. Inspect the deployed schema because columns and semantics evolve.

### REF-0954 — ovn-sb(5)

Southbound schema for chassis, Port_Binding, logical flows, datapath bindings and related compiled state. Rows remain control-state evidence rather than packets.

### REF-0955 — ovn-northd(8)

Official compiler-daemon contract between NB and SB. Supports separating process availability from translation progress.

### REF-0956 — ovn-controller(8)

Official chassis-local controller contract between SB, local OVSDB and ovs-vswitchd/OpenFlow. Supports local convergence and identity reasoning.

### REF-0957 — ovn-trace(8)

Official logical-network what-if tracer. Its documented physical-simulation limitation is central: logical trace success cannot prove chassis reachability or packet delivery.

### Review gates

Before publication, require:

1. technical review against an exact stable OVS/OVN release;
2. network/security review of authority, captures and tenant isolation;
3. instructional review for beginner-readable definitions and command explanations;
4. reviewer-owned disposable runtime exercise;
5. independent transfer and delayed recall;
6. canonical registry/navigation/build/browser checks;
7. explicit resolution of every remaining limitation.
