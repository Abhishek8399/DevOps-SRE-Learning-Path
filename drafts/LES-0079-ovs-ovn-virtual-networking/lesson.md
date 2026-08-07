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
    {"platform":"Ubuntu","version":"24.04 WSL guarded lifecycle planned","support":"unsupported","notes":"The offline model is not implemented; it must refuse host-network and control-plane authority and make zero OVS/OVN calls."},
    {"platform":"Python","version":"3 standard library model planned","support":"unsupported","notes":"The deterministic intent-to-packet evidence model is not implemented."},
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
    "The guarded offline lab and assessment files are not implemented yet; the current body is a schema-ready teaching scaffold rather than a completed lesson.",
    "No OVS/OVN package, daemon, database, bridge, port, namespace, interface, route, flow, tunnel, logical topology, ACL, packet or gateway change is authorized.",
    "Current OVN distribution manuals describe a development line; exact deployed schema, protocol, package and compatibility remain unproved.",
    "Behavior depends on release, Linux kernel and datapath, CMS integration, topology, underlay, MTU, hardware offload, policy and workload.",
    "Formal technical/security/instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# OVS and OVN operations: trace intent, flows, tunnels, policy, and packet delivery

## What you see and first thought

When a virtual workload cannot communicate, do not translate “the network is down” into a restart. Name the exact source, destination, protocol, direction and user operation, then ask which owner last proved its part: intent, compilation, binding, installed policy, physical transport, delivery or reply.

## Terms before commands

The final lesson will define every OVS, OpenFlow and OVN term before using its command. The central distinction is simple: a database row is desired or compiled state, a flow is forwarding policy, a datapath entry is cached execution, and a received application reply is outcome evidence.

## Architecture map

The architecture runs from CMS intent to the OVN northbound database, through ovn-northd into the southbound database, then through one ovn-controller into local OVSDB, ovs-vswitchd and the datapath on each chassis. Overlay transport still depends on the physical underlay.

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
