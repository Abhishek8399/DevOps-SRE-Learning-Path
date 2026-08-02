---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0012",
  "aliases": ["V02-L01", "ethernet-ip-cidr-routing-nat"],
  "curriculumIds": ["NET-001", "NET-002"],
  "slug": "ethernet-ip-cidr-routing-nat",
  "route": "/book/connectivity/ethernet-ip-cidr-routing-nat",
  "order": 1,
  "volume": "02-connectivity",
  "title": "Ethernet, IP, CIDR, routing, and NAT: follow the packet",
  "summary": "Build the packet path from a process to its local interface, selected route, exact next hop, neighbor mapping, routed and stateful boundaries, return path, and MTU; then use that map to replace 'the network is down' with the first evidenced failure.",
  "domain": "connectivity",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 300,
  "prerequisiteLessonIds": ["LES-0007"],
  "prerequisiteCurriculumIds": ["FND-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Read-only host observations use iproute2 and procfs as a normal user. The guided packet-path model uses Bash, Python 3.8 or newer, a guarded lesson-owned temporary directory, deterministic virtual evidence, no root, no host network mutation, and no external connection."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "WSL 2 adds a utility-VM and Windows-host boundary, so observed interfaces, routes, neighbor tables, NAT, and MTU may differ from a standalone VM. The offline model remains supported and must not be described as measuring the Windows or production path."
    },
    {
      "platform": "Containers, Kubernetes, cloud VPCs, private cloud, and hybrid networks",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Transfer sections map interfaces, namespaces, routes, neighbors, overlays, translation, policy, and return paths, but this lesson creates no container, cluster, cloud account, tunnel, firewall rule, or production route."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "network-reliability-engineer",
    "private-cloud-engineer",
    "data-platform-engineer"
  ],
  "learningObjectives": [
    "Explain why an application writes bytes to a socket while Linux builds transport data, an IP packet, and a link-local frame owned by different layers.",
    "Calculate IPv4 network membership from an address and prefix length, read IPv6 prefixes without relying on classful language, and distinguish an address, subnet, route prefix, and endpoint.",
    "Trace Linux policy and route selection through rules, tables, longest-prefix match, route type, metric, source choice, next hop, and egress interface.",
    "Explain why ARP or IPv6 Neighbor Discovery resolves the selected next hop rather than every remote destination, and interpret Linux neighbor-unreachability states with proof limits.",
    "Trace forward and return paths through routers, stateful firewalls, NAT, and overlays without treating a green forward path as bidirectional proof.",
    "Reason about TTL or hop limit, interface MTU, encapsulation overhead, IPv4 fragmentation, IPv6 source fragmentation, and Path MTU Discovery in selective large-packet failures.",
    "Use read-only Linux commands and a deterministic offline model to identify the first healthy-input and abnormal-output boundary before proposing a change.",
    "Design a bounded remediation, rollback, verification, observability, security, capacity, and cost plan for routed and stateful production paths."
  ],
  "productionSignals": [
    "An application reports timeout while the destination service and its global health dashboard look healthy.",
    "`ip route` contains a default route, yet one destination prefix is unreachable because a more-specific route wins.",
    "A route lookup selects an expected gateway, but the exact next-hop neighbor remains INCOMPLETE or FAILED.",
    "Traffic works from one source subnet, node, namespace, or availability zone but fails from another.",
    "Requests reach a destination while replies follow an incompatible route or bypass stateful translation or policy.",
    "Small requests succeed while large responses stall, retransmit, or time out across a tunnel or overlay.",
    "A translation or connection-tracking table approaches capacity, causing only new flows to fail while established flows continue.",
    "A control plane reports a route, security rule, or endpoint as programmed while data-plane evidence disagrees."
  ],
  "diagrams": [
    {
      "id": "LES-0012-DIA-001",
      "title": "One operation becomes segments, packets, and per-link frames",
      "direction": "left-to-right",
      "boundaries": ["application and socket", "transport payload", "IP packet", "source route decision", "next-hop neighbor", "per-link frame", "router and policy boundaries", "destination socket", "application result"],
      "evidencePoints": ["operation ID and tuple", "socket state", "source and destination IP", "rule and route result", "gateway and interface", "neighbor state and link counters", "TTL or hop limit and translation tuple", "listener and response", "user-visible outcome"],
      "textAlternative": "Application bytes pass through a socket into transport and IP state; the source selects a route and resolves only the local next hop, each router removes and rebuilds the link-layer frame, and the reverse path must carry the response back through compatible state before the user operation succeeds."
    },
    {
      "id": "LES-0012-DIA-002",
      "title": "Linux route choice is a decision tree, not a presence check",
      "direction": "top-to-bottom",
      "boundaries": ["network namespace", "policy rule priority", "selected routing table", "matching route prefixes", "longest prefix", "route type and metric", "source, next hop, and interface", "neighbor resolution or local delivery"],
      "evidencePoints": ["namespace identity", "ip rule output", "table ID", "all candidate prefixes", "winning prefix length", "unicast, local, unreachable, prohibit, blackhole", "ip route get result", "exact next-hop neighbor"],
      "textAlternative": "Linux evaluates route-policy rules in priority order, searches the selected table, chooses the most specific matching prefix, applies route type and tie-break information, selects source, next hop and interface, and only then attempts local delivery or neighbor resolution."
    },
    {
      "id": "LES-0012-DIA-003",
      "title": "Stateful translation makes the return path part of the design",
      "direction": "cyclic",
      "boundaries": ["original source tuple", "forward route", "stateful policy", "translated tuple", "destination service", "reply route", "reverse state lookup", "original destination process"],
      "evidencePoints": ["original five-tuple", "next hops", "rule decision", "mapping identity and age", "request result", "route to translated source", "reverse mapping and drop counters", "complete operation"],
      "textAlternative": "A source flow crosses a forward route and stateful translation to a service; the reply must route to the translated identity and cross compatible state so the mapping can be reversed and delivered to the original process."
    }
  ],
  "commands": [
    {
      "id": "LES-0012-CMD-001",
      "question": "What exact Ubuntu, kernel, identity, namespace context, and network tools define this observation?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -sr; id; readlink /proc/self/ns/net; command -v ip python3 bash",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu shell being investigated",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04, a nonzero effective UID, one network-namespace link, and all three commands are visible",
          "meaning": "The declared baseline and minimum read-only or modeled dependencies are present in this shell.",
          "nextEvidence": "Record whether WSL is involved, then inspect interfaces without changing them."
        },
        {
          "when": "The release differs, UID is zero, namespace context is unexpected, or a command is absent",
          "meaning": "The observation boundary differs from the required baseline or a dependency is missing.",
          "nextEvidence": "Stop the lab path, record the mismatch, and do not install or bypass a refusal automatically."
        }
      ],
      "proves": "The displayed release metadata, kernel release, effective identity, current process network-namespace link, and PATH resolution at that moment.",
      "doesNotProve": "Tool version compatibility, privilege safety, route correctness, external connectivity, packet delivery, or learner understanding."
    },
    {
      "id": "LES-0012-CMD-002",
      "question": "Which interfaces are administratively enabled, operationally up, and addressed in this namespace?",
      "risk": "read-only",
      "command": "ip -brief link show; ip -brief address show",
      "runFrom": "The investigated network namespace as a normal user",
      "expectedBranches": [
        {
          "when": "The intended interface is UP and has the expected address and prefix",
          "meaning": "The sampled namespace has an enabled interface and configured address matching the intended starting model.",
          "nextEvidence": "Inspect policy and route selection for one exact destination."
        },
        {
          "when": "The interface is DOWN, LOWERLAYERDOWN, UNKNOWN, missing, or addressed differently",
          "meaning": "The local attachment or namespace model already differs from the assumption.",
          "nextEvidence": "Preserve link and address evidence and resolve ownership before testing remote layers."
        }
      ],
      "proves": "The kernel's summarized link flags, operational state, MTU if requested separately, and assigned addresses for this namespace at lookup time.",
      "doesNotProve": "Correct VLAN, physical switch path, neighbor reachability, route choice, security policy, listener health, or bidirectional delivery."
    },
    {
      "id": "LES-0012-CMD-003",
      "question": "Which policy rules and route tables could own the decision?",
      "risk": "read-only",
      "command": "ip rule show; ip route show table all",
      "runFrom": "The same network namespace before using a route query",
      "expectedBranches": [
        {
          "when": "Rules and expected connected, specific, and default routes appear",
          "meaning": "Those policy and table entries exist in the current namespace.",
          "nextEvidence": "Use `ip route get` for the exact destination, source, and mark context when relevant; presence alone does not select a winner."
        },
        {
          "when": "A higher-priority rule, more-specific route, special route type, or unexpected table appears",
          "meaning": "The assumed main-table or default-route path may not own the packet.",
          "nextEvidence": "Decode rule priority and run an exact route query before any route change."
        }
      ],
      "proves": "The policy rules and table entries printed for the current namespace and visibility permissions.",
      "doesNotProve": "Which entry wins for a particular packet, that a next hop is reachable, that packets traverse the path, or that replies use a compatible table."
    },
    {
      "id": "LES-0012-CMD-004",
      "question": "What route would Linux select for one exact destination without sending a packet?",
      "risk": "read-only",
      "command": "ip route get 198.51.100.25",
      "runFrom": "The source namespace; 198.51.100.25 is a documentation address and the command performs only a local lookup",
      "expectedBranches": [
        {
          "when": "A route prints destination, optional via, dev, src, and optional metric or table context",
          "meaning": "Linux selected that local forwarding result for the query.",
          "nextEvidence": "Identify whether the next hop is the destination or a gateway, then inspect that exact neighbor boundary."
        },
        {
          "when": "The lookup reports unreachable, prohibit, blackhole, or no route",
          "meaning": "Route policy itself refuses or lacks a forwarding result before neighbor or transport work.",
          "nextEvidence": "Trace the owning rule and winning prefix; do not add a default route blindly."
        }
      ],
      "proves": "The current kernel route selection for the queried destination and implicit source context without external transmission.",
      "doesNotProve": "Neighbor resolution, frame emission, intermediate forwarding, NAT, security policy, listener state, return path, or application success."
    },
    {
      "id": "LES-0012-CMD-005",
      "question": "What does Linux currently know about link-layer neighbors in this namespace?",
      "risk": "read-only",
      "command": "ip neigh show",
      "runFrom": "The source namespace after identifying the selected next-hop address",
      "expectedBranches": [
        {
          "when": "The selected next hop has a link-layer address and REACHABLE, STALE, DELAY, or PROBE state",
          "meaning": "A mapping exists, with the named reachability confidence and state-machine meaning.",
          "nextEvidence": "Relate the state to the exact operation and interface; a cached row is not delivery proof."
        },
        {
          "when": "The selected next hop is INCOMPLETE, FAILED, absent, or tied to another interface",
          "meaning": "The route-to-link handoff is unresolved or the evidence context is mismatched.",
          "nextEvidence": "Compare the same link and gateway from a matched healthy source and inspect narrowly scoped neighbor traffic only with authorization."
        }
      ],
      "proves": "The neighbor-cache records and Neighbor Unreachability Detection states visible at that instant.",
      "doesNotProve": "The reason for failure, current end-to-end reachability, remote service health, permanent correctness of a MAC, or return-path state."
    },
    {
      "id": "LES-0012-CMD-006",
      "question": "Are link counters changing in a way that localizes drops or errors?",
      "risk": "sampled-read-only",
      "command": "ip -s link show",
      "runFrom": "The same namespace; compare two bounded snapshots around one authorized test rather than reading one lifetime total",
      "expectedBranches": [
        {
          "when": "RX or TX errors, drops, overruns, carrier events, or collisions increase during the exact test",
          "meaning": "The local interface accounts a correlated abnormal event in the sampled direction.",
          "nextEvidence": "Inspect interface, driver, virtual-device, queue, and adjacent-link ownership without assuming the counter names the root cause."
        },
        {
          "when": "Counters remain unchanged or only packets and bytes increase",
          "meaning": "No sampled local counter in this view recorded the suspected error, or the test did not cross this interface.",
          "nextEvidence": "Confirm namespace and route, then move to the next path boundary rather than declaring the network healthy."
        }
      ],
      "proves": "Kernel-maintained cumulative interface counters and their change between correctly scoped samples.",
      "doesNotProve": "Packet contents, downstream acceptance, exact drop reason on every driver, user success, or absence of errors outside the sample."
    },
    {
      "id": "LES-0012-CMD-007",
      "question": "Which interface type, master, peer, and MTU details could change the packet path?",
      "risk": "read-only",
      "command": "ip -details link show",
      "runFrom": "The investigated namespace",
      "expectedBranches": [
        {
          "when": "A physical, bridge, bond, VLAN, veth, tunnel, or overlay type and its MTU are visible",
          "meaning": "The local device model and configured link MTU are now explicit.",
          "nextEvidence": "Add encapsulation overhead and downstream MTUs before deciding whether a packet fits the effective path."
        },
        {
          "when": "The expected device, peer, master, or details are absent",
          "meaning": "The command is running in another namespace, visibility is limited, or the topology assumption is wrong.",
          "nextEvidence": "Identify the correct owner and context; do not create or reattach a device to force the picture."
        }
      ],
      "proves": "The link objects and detailed attributes exposed in the current namespace.",
      "doesNotProve": "End-to-end path MTU, tunnel health, remote link configuration, successful encapsulation, or packet delivery."
    },
    {
      "id": "LES-0012-CMD-008",
      "question": "Is this Linux namespace configured to forward IPv4 packets?",
      "risk": "read-only",
      "command": "cat /proc/sys/net/ipv4/ip_forward",
      "runFrom": "The exact network namespace whose router role is being evaluated",
      "expectedBranches": [
        {
          "when": "The value is 1",
          "meaning": "IPv4 forwarding is enabled for this namespace's current sysctl state.",
          "nextEvidence": "Inspect routes and policy; forwarding enabled does not mean this packet is accepted or translated."
        },
        {
          "when": "The value is 0",
          "meaning": "Generic IPv4 forwarding is disabled in this namespace.",
          "nextEvidence": "Confirm whether the host is intended to route; request a reviewed configuration change only if design ownership requires it."
        }
      ],
      "proves": "Only the displayed IPv4 forwarding sysctl value in the current namespace.",
      "doesNotProve": "Forwarding for IPv6, route availability, firewall acceptance, NAT rules, reverse-path compatibility, persistence, or authority to change it."
    },
    {
      "id": "LES-0012-CMD-009",
      "question": "Does the guarded packet-path lab accept this normal-user environment without mutation?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh check",
      "runFrom": "Repository root in Ubuntu 24.04 or supported WSL 2 Ubuntu",
      "expectedBranches": [
        {
          "when": "The check reports ready and absent or strictly valid state",
          "meaning": "The implemented dependency, identity, path, descriptor, sentinel, and state guards accept the environment.",
          "nextEvidence": "Write route and neighbor predictions before setup or continuing the recorded lifecycle."
        },
        {
          "when": "The check refuses",
          "meaning": "A required safety or state invariant is not met.",
          "nextEvidence": "Preserve the first refusal and stop; never repair descriptors or delete unknown paths manually."
        }
      ],
      "proves": "Only that the harness's current read-only safety checks accepted this environment and registered state.",
      "doesNotProve": "That later commands will succeed, the model represents a production network, or a refusal may be bypassed."
    },
    {
      "id": "LES-0012-CMD-010",
      "question": "Can the lab create one private, guarded offline workspace?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh setup",
      "runFrom": "Repository root after an accepted check as the same normal user",
      "expectedBranches": [
        {
          "when": "Setup reports ready or already present with one lesson-owned root",
          "meaning": "The guarded descriptor, sentinel, manifest, fixture, and initial state were created or recognized.",
          "nextEvidence": "Run status, reveal one input-only guided or independent scenario, then record calculations and predictions outside the lab root before any derived observation."
        },
        {
          "when": "Setup refuses ownership, type, link, mode, path, or state",
          "meaning": "The harness cannot prove that mutation is inside its declared boundary.",
          "nextEvidence": "Stop and retain the diagnostic; do not weaken a guard."
        }
      ],
      "proves": "The current setup implementation accepted and created or recognized only its declared workspace.",
      "doesNotProve": "That a case ran, a host route changed, the model is production telemetry, or cleanup may be skipped.",
      "cleanup": "Use only the guarded cleanup operation and confirm the following check reports absent state."
    },
    {
      "id": "LES-0012-CMD-011",
      "question": "What supplied case facts can be revealed without exposing derived route, neighbor, translation, return, MTU, or operation answers?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh scenario guided",
      "runFrom": "The guarded ready workspace immediately after setup and before baseline or incident observation",
      "expectedBranches": [
        {
          "when": "The command reports scenario_scope=input-only and prediction_record=external-required",
          "meaning": "The fixture stored one immutable case selection and emitted only supplied operation, topology, route-config, translation-config, return-config, and size inputs.",
          "nextEvidence": "Outside the lab root, calculate subnet, winning route, next hop, tuple path, emitted packet size, effective inner MTU, encapsulated size, signed headroom, and predicted result."
        },
        {
          "when": "The scenario is repeated, malformed, late, or conflicts with existing state",
          "meaning": "The prediction-before-observation lifecycle is not intact.",
          "nextEvidence": "Preserve the refusal and use only guarded cleanup or reset; do not edit the immutable scenario record."
        }
      ],
      "proves": "Only which deterministic supplied inputs were revealed and immutably selected before baseline.",
      "doesNotProve": "That the learner recorded a prediction, which route wins, whether a neighbor or mapping exists, what effective MTU is, whether traffic fits, or whether the operation succeeds.",
      "cleanup": "Complete or abort the attempt with guarded cleanup and confirm the following check reports absent state."
    },
    {
      "id": "LES-0012-CMD-012",
      "question": "What does the deterministic healthy packet path show after the case inputs and predictions are frozen?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh run baseline",
      "runFrom": "The guarded workspace after one scenario is recorded and predictions are preserved externally",
      "expectedBranches": [
        {
          "when": "Baseline records a winning route, reachable next hop, translation or direct path, compatible return route, MTU fit, and successful modeled operation",
          "meaning": "The fixture stored its immutable healthy comparison under the declared virtual contract.",
          "nextEvidence": "Decode every field, compare it with the frozen prediction, and rank at least three mechanisms before incident observation."
        },
        {
          "when": "Baseline already exists or order validation refuses",
          "meaning": "The immutable lifecycle or one-run ordering contract is not satisfied.",
          "nextEvidence": "Inspect status and use only guarded reset or cleanup if supported."
        }
      ],
      "proves": "The fixture's deterministic baseline output and lifecycle state, not any real network behavior.",
      "doesNotProve": "Host reachability, external routes, production latency, physical links, firewall policy, learner comprehension, or that an external prediction was actually written.",
      "cleanup": "Complete the case, supported recovery, operation verification, and guarded cleanup."
    },
    {
      "id": "LES-0012-CMD-013",
      "question": "Can the guided case be injected and observed without touching host networking?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh inject guided; bash book/labs/LES-0012-packet-path/lab.sh observe path",
      "runFrom": "The guarded workspace after a matching scenario, externally preserved predictions, and baseline",
      "expectedBranches": [
        {
          "when": "The case records changed virtual route, neighbor, return, translation, or MTU evidence and a failed modeled operation",
          "meaning": "The synthetic incident exists only inside the lesson model and is ready for boundary reasoning.",
          "nextEvidence": "Compare baseline and current path, rank mechanisms, and use only supported probes."
        },
        {
          "when": "Injection or observation refuses",
          "meaning": "Lifecycle, integrity, case, or state guards rejected the operation.",
          "nextEvidence": "Retain the refusal; do not edit immutable artifacts or inject a second case."
        }
      ],
      "proves": "The model's case and path evidence under a deterministic virtual contract.",
      "doesNotProve": "A real packet was sent, a host route or neighbor changed, the visible symptom names the cause, or production behaves identically.",
      "cleanup": "Use supported recover and verify-operation, then guarded cleanup and a final absent check."
    },
    {
      "id": "LES-0012-CMD-014",
      "question": "Did supported recovery restore the full modeled operation rather than one component state?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh recover; bash book/labs/LES-0012-packet-path/lab.sh verify-operation",
      "runFrom": "The diagnosed guided or independent case after preserving evidence",
      "expectedBranches": [
        {
          "when": "Recovery and verification report the intended route, next hop, forward and return outcomes, stateful mapping, explicit segmentation and packet arithmetic, MTU fit, and successful operation",
          "meaning": "The supported recovery restored the modeled end-to-end contract and emitted sizes are arithmetically consistent with the effective inner MTU.",
          "nextEvidence": "Record residual uncertainty and prevention, then clean up."
        },
        {
          "when": "Recovery or verification fails",
          "meaning": "The modeled operation is not restored or an integrity invariant failed.",
          "nextEvidence": "Stop, preserve state, and review the first failure; do not force success."
        }
      ],
      "proves": "Only the modeled case's supported restoration and operation verification.",
      "doesNotProve": "Root-cause completeness, future stability, production recovery, peak capacity, or mastery.",
      "cleanup": "Run guarded cleanup followed by check and retain absence proof."
    },
    {
      "id": "LES-0012-CMD-015",
      "question": "Can cleanup remove exactly the registered workspace and prove absence?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0012-packet-path/lab.sh cleanup; bash book/labs/LES-0012-packet-path/lab.sh check",
      "runFrom": "Repository root after completing or aborting the lab",
      "expectedBranches": [
        {
          "when": "Cleanup reports verified and the following check reports absent state",
          "meaning": "The harness removed its validated registered resources and found no remaining registered state.",
          "nextEvidence": "Retain sanitized evidence outside the lab root only when the exercise explicitly requests it."
        },
        {
          "when": "Cleanup refuses a path, owner, type, mode, link, sentinel, manifest, or allowlist mismatch",
          "meaning": "The harness cannot prove safe deletion.",
          "nextEvidence": "Stop and preserve the refusal for review; never substitute manual recursive deletion."
        }
      ],
      "proves": "The current guarded cleanup removed exactly what its validation allowed and its follow-up check sees absent registered state.",
      "doesNotProve": "That unrelated temporary files are absent, every deletion attack is impossible, or learner evidence has been accepted.",
      "cleanup": "Cleanup is complete only when the guarded cleanup succeeds and the following check reports absent registered state."
    }
  ],
  "labs": [
    {
      "id": "LES-0012-LAB-001",
      "title": "Offline packet-path, route, neighbor, translation, and MTU investigation",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS with Bash and Python 3.8 or newer",
      "timeMinutes": 90,
      "privilege": "Normal user only; root and sudo are refused",
      "network": "None; deterministic virtual network evidence only",
      "changes": [
        "Creates one UID-scoped descriptor and one randomly named lesson-prefixed private directory under the system temporary directory.",
        "Copies a lesson-owned Python model and writes only allowlisted immutable virtual evidence and lifecycle files under that directory.",
        "Models route, neighbor, stateful translation, return-path, and MTU behavior without calling host networking mutation commands or opening a socket."
      ],
      "abortConditions": [
        "Effective UID is zero, a required dependency is absent, or the platform and temporary root cannot be validated.",
        "The descriptor, root, sentinel, manifest, model, or result has unexpected ownership, type, mode, link count, link target, content, or realpath.",
        "A lifecycle transition, case name, artifact allowlist, immutable hash, or exact output grammar differs from the declared contract.",
        "Any command proposes host route, neighbor, interface, namespace, firewall, sysctl, external network, background-process, or package mutation."
      ],
      "recovery": "Use only the harness's recover operation for the active modeled case. If an integrity or safety guard refuses, stop and retain the first diagnostic for review rather than editing state.",
      "cleanupProof": "The guarded cleanup validates identity and every registered path before deletion, removes only allowlisted resources, proves the registered root and descriptor are absent, and a following check reports absent state.",
      "path": "book/labs/LES-0012-packet-path"
    }
  ],
  "incidents": [
    {
      "id": "LES-0012-INC-001",
      "signal": "Only 10.44.7.0/24 cannot reach a service; the default route and the service are healthy, but a recently added 10.44.0.0/16 blackhole route is present.",
      "firstThought": "Do not conclude that the service, default gateway, DNS, or firewall is broken. Calculate every matching prefix and ask which route wins.",
      "safePath": "Confirm namespace and source, query the exact destination, compare all matching prefixes, identify the more-specific blackhole as the first policy refusal, locate its configuration owner, remove or correct only that route through the approved path, and verify forward and return operations for affected and neighboring prefixes.",
      "trap": "Adding another default route, restarting networking, or opening a firewall does not outrank the more-specific blackhole and can create a second failure."
    },
    {
      "id": "LES-0012-INC-002",
      "signal": "Small requests cross an overlapping-CIDR translation boundary, but large responses time out and the forward-path dashboard remains green.",
      "firstThought": "Treat size sensitivity as evidence for an MTU or feedback mechanism, not proof, and draw the translated return path before changing a firewall.",
      "safePath": "Correlate one operation's original and translated tuples, verify both routes and state ownership, compare packet sizes and effective MTUs before and after encapsulation, inspect required ICMP feedback and drops, test a bounded prediction, repair the MTU or feedback contract, and verify the real large bidirectional operation plus state capacity.",
      "trap": "Lowering every interface MTU, allowing all traffic, or declaring NAT healthy because a mapping exists hides the failed boundary and expands blast radius."
    }
  ],
  "assessmentIds": ["ASM-0019", "ASM-0020", "ASM-0021"],
  "referenceIds": ["REF-0049", "REF-0050", "REF-0051", "REF-0052", "REF-0053", "REF-0054", "REF-0055", "REF-0056"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The guided lab is a deterministic offline model. It sends no packet and cannot measure a real host, switch, router, tunnel, firewall, NAT device, cloud network, latency, loss, throughput, or production capacity.",
    "Normal-user read-only commands may expose only the current namespace and permitted fields. WSL, containers, Kubernetes, and network appliances add owners and boundaries that must be observed in their actual environment.",
    "The lesson teaches IPv4 and IPv6 foundations but does not replace dedicated routing-protocol, DNS, transport, firewall, overlay, eBPF, cloud-provider, or packet-capture chapters.",
    "RFCs and Linux manuals define mechanisms, while an organization's intended topology, policy, address plan, translation ownership, and recovery authority require current local documentation and review.",
    "A correct answer, completed model, or finished-reading marker is project or study evidence only. Independent transfer, delayed recall, and reviewer acceptance remain required before any competency or mastery claim."
  ]
}
---

# Ethernet, IP, CIDR, routing, and NAT: follow the packet

## What you see and first thought

You open a ticket that says **the network is down**. Hold that sentence lightly. It is a symptom-shaped guess, not a failure boundary. A useful first sentence sounds more like this: **from process A in network namespace N, a TCP operation to address B and port P stopped succeeding at 14:07, while the same operation from source cohort C still works**. That sentence gives you something a route, neighbor entry, packet trace, policy decision, and application result can actually explain.

Here is the memory picture: an application does not throw a message directly across a data center. It asks a socket to carry bytes. Linux adds transport state, places that data in an IP packet, decides where that packet goes next, and places the packet inside a frame valid for one local link. A router removes that frame, makes another route decision, and builds another frame. The frame changes at every routed hop. The IP destination normally remains the intended endpoint until a deliberate translation boundary rewrites it.

When a request fails, do not jump from application to destination. Walk the boundaries in order:

```text
process -> socket -> source address -> policy rule -> route -> next hop
        -> neighbor mapping -> frame -> router/policy/NAT -> service
        -> reply route -> reverse state -> source process -> user result
```

At each arrow ask two questions: **who owns this transition?** and **what observation would prove its input and output?** A configured object proves that an object exists. It does not prove that the data plane used it, the next owner accepted it, or the reply returned.

> Memory sentence: route to an IP destination, resolve the local next hop, verify both directions, and call the operation healthy only when the user-visible result succeeds.

## Terms before commands

### Endpoint, socket, tuple, packet, and frame

An **endpoint** is one side of a communication contract, usually described by address, protocol, and port plus the process or service that owns it. A Linux **socket** is the kernel object an application uses to send or receive. For TCP and UDP, engineers often identify a flow by a five-tuple: source IP, source port, destination IP, destination port, and transport protocol.

An **IP packet** contains an IP header and an upper-layer payload. It is intended to be routed across networks. An Ethernet **frame** contains link-layer source and destination addresses and is valid on one broadcast domain or link. Do not say "the MAC address of the remote database" when the database is off-link. The source usually needs the MAC address of its gateway; the router will build the next frame for the next link.

### Interface, link, network namespace, and loopback

An **interface** is the kernel's attachment point to a link. It may represent physical hardware or a virtual device such as a bridge, bond, VLAN, veth, tunnel, or loopback. Administrative `UP` says the interface is enabled. Operational state describes what the kernel or driver currently knows about the lower layer. Neither alone proves an application exchange.

A **network namespace** owns its own interfaces, routes, policy rules, neighbor tables, firewall view, sockets, and several network sysctls. The same command in a host, container, pod, or WSL namespace may show a different world. Always record the namespace boundary before comparing output. **Loopback** is an interface local to that namespace; `127.0.0.1` or `::1` in a container is not the host's loopback.

### IPv4 address, IPv6 address, prefix, and subnet

An IP **address** identifies an interface or logical endpoint within an addressing plan. A **prefix length** says how many leading address bits identify the network portion. `10.42.1.17/24` means the first 24 IPv4 bits form the prefix. The network is `10.42.1.0/24`; the remaining eight bits select addresses inside that block.

CIDR is classless. Avoid "Class A, B, or C" reasoning; explicit prefixes such as `/20`, `/27`, and `/31` are the real contract. IPv6 uses the same prefix idea over 128 bits, commonly with `/64` subnets, but its addressing, discovery, and fragmentation behavior are not merely IPv4 with more digits.

For IPv4, calculate network membership by applying the mask to the address. A `/24` mask is `255.255.255.0`; `10.42.1.17 AND 255.255.255.0` yields `10.42.1.0`. `10.42.1.90` is on that subnet, while `10.42.8.25` is not. Modern point-to-point and platform networks can use special prefix conventions, so do not blindly subtract network and broadcast addresses from every product design.

### On-link, off-link, next hop, and gateway

A destination is **on-link** when the routing decision says it can be reached directly through a local interface. An **off-link** destination is reached through a **next hop**, commonly called a gateway. "Directly" still requires a link-layer mapping when the link uses one. For an off-link IPv4 destination, ARP resolves the gateway's IPv4 address, not the final remote address.

A gateway is a role for this packet, not a magical universal router. A host can have several gateways selected by destination, source, policy, metric, or namespace. Write "selected next hop 10.42.1.1 on eth0" instead of "the gateway" when precision matters.

### ARP, Neighbor Discovery, and the neighbor table

IPv4 Ethernet commonly uses **ARP** to map a local next-hop IPv4 address to a link-layer address. IPv6 uses **Neighbor Discovery**, carried in ICMPv6, for address resolution, router discovery, reachability, and other local-link functions. Blocking required ICMPv6 can therefore break fundamental IPv6 behavior.

Linux exposes both mappings through the neighbor table. Its Neighbor Unreachability Detection states are evidence about the cache and reachability process:

| State | Practical meaning | Do not conclude |
|---|---|---|
| `REACHABLE` | Recent positive reachability confirmation exists | The remote application is healthy |
| `STALE` | A mapping exists but confirmation is old | The neighbor is broken; Linux may still use it |
| `DELAY` | Linux is waiting briefly before active probing | The packet is already lost |
| `PROBE` | Active reachability probes are in progress | The final cause is the neighbor device |
| `INCOMPLETE` | Resolution started but no usable mapping exists yet | The destination service or firewall rejected traffic |
| `FAILED` | Resolution did not produce a usable neighbor in the current attempt | Whether link, VLAN, gateway, filtering, or duplication caused it |
| `PERMANENT` or `NOARP` | Configuration suppresses normal dynamic aging or resolution | The configured mapping is correct |

### Route, routing table, policy rule, and longest-prefix match

A **route** is a forwarding decision for a destination prefix and possibly a source or other context. A **routing table** contains routes. Linux **policy rules** decide which table is searched and can consider source, destination, packet mark, interface, and other selectors. The familiar `main` table is not the only possible owner.

Within the applicable table, the most specific matching prefix wins: the route with the longest matching prefix length. For `10.44.7.9`, a `10.44.7.0/24` route beats `10.44.0.0/16`, which beats `0.0.0.0/0`. Metric helps select between comparable candidates; it does not make a default route override a more-specific blackhole.

Route **type** matters. A unicast route forwards. A local route delivers locally. Blackhole discards silently. Unreachable and prohibit reject with different local errors. A route object's presence is not equivalent to reachability.

### Forward path, return path, symmetry, and state

The **forward path** carries the request toward the destination. The **return path** carries the response back. They need not use identical routers, but they must remain compatible with routing, source validation, stateful firewalls, NAT, load balancers, and application expectations.

**Asymmetric routing** is not automatically broken. It becomes a problem when one direction bypasses state, violates policy, reaches a translator without the mapping, uses an unexpected source, or is invisible to required observability. A green forward-path counter does not verify the return path.

### NAT, SNAT, DNAT, port translation, and conntrack

Network Address Translation rewrites address fields; Network Address and Port Translation can also rewrite ports. **SNAT** changes the source seen downstream. **DNAT** changes the destination used for delivery. A common outbound translator records an original tuple and a translated tuple, then reverses that mapping for replies.

On stateful implementations, the first packet creates or selects state and later packets use it. That makes table capacity, timeouts, failover replication, and path symmetry production concerns. NAT does not itself create reachability; both sides still need routes, permitted policy, healthy neighbors, and a listening application.

### TTL, hop limit, MTU, fragmentation, and PMTUD

IPv4 **TTL** and IPv6 **Hop Limit** are decremented by routers so forwarding loops terminate. Their values are hop budgets, not seconds. Interface **MTU** is the largest network-layer packet the link can carry under its contract. Tunnels and overlays add headers, reducing the effective payload that can cross an underlay MTU.

IPv4 routers may fragment in some conditions, though designs should not depend casually on it. In IPv6, routers do not fragment packets; the source uses fragmentation behavior based on Path MTU Discovery. **PMTUD** relies on network feedback such as IPv4 fragmentation-needed or IPv6 Packet Too Big messages. If oversized packets are dropped and the necessary feedback disappears, small exchanges may work while larger ones stall: an MTU black hole.

## Architecture map

The first diagram is the path your mind should draw before your fingers reach for `ping` or a firewall console:

```text
APPLICATION NAMESPACE                         ROUTED / STATEFUL PATH

process
  | bytes + destination intent
  v
socket ---- local bind/listener evidence
  | transport header: ports and protocol
  v
IP packet: src 10.42.1.17 -> dst 10.42.8.25
  | policy rule -> table -> longest-prefix route
  v
next hop 10.42.1.1 dev eth0
  | ARP resolves 10.42.1.1 to a local-link MAC
  v
Ethernet frame [dst=gateway MAC | payload=IP packet]
  |
  +--> router --> stateful policy/NAT --> router --> service
                                                |
                                                v
                                     destination socket/process

REPLY: service -> route to source or translated source -> reverse state
       -> source next hop -> source socket -> operation result
```

Notice three identities: the user operation, the transport tuple, and the per-link frame. They correlate, but they are not interchangeable. A proxy, load balancer, or NAT boundary may create a new downstream tuple. Each routed hop builds a new frame. Your diagram should preserve where identity changes and who can observe it.

The second diagram explains why `ip route` is not enough:

```text
packet context
  |
  v
which network namespace?
  |
  v
policy rules by priority ------> table selection
  |
  v
all matching prefixes
  |
  +--> /32 host route
  +--> /24 subnet route       choose longest prefix
  +--> /16 aggregate
  +--> /0 default
  |
  v
route type + next hop + dev + source
  |
  v
local delivery OR exact-next-hop neighbor resolution
```

The third diagram makes a stateful boundary explicit:

```text
original: 10.20.4.17:41000 -> 10.80.16.25:443
                       |
                       v
               translation owner
               original tuple <-> reply tuple
                       |
translated: 172.31.40.17:51000 -> 10.80.16.25:443
                       |
                       v
                 service response
10.80.16.25:443 -> 172.31.40.17:51000
                       |
            return route must reach same state
                       v
reverse mapping -> 10.20.4.17:41000 -> application
```

If replies bypass the state owner, "the request left successfully" becomes irrelevant to the user. The operation is incomplete.

## Request or state path

Use this path when a connection, health check, package download, API call, database query, or service-to-service request fails.

### 1. Define the operation before the network

Record source process, namespace, source identity, destination name and resolved address, protocol, port, request shape, expected result, time, affected cohort, and a matched healthy cohort. If the name has not been resolved, name resolution is a separate earlier boundary. This chapter begins with an address so route reasoning stays clear.

### 2. Establish the source namespace and interface model

Host, WSL distribution, container, pod, service mesh proxy, and virtual router may each have a different namespace. Record `/proc/self/ns/net`, interface names, addresses, prefixes, operational states, and device types. A route found on the Windows host does not prove the WSL namespace uses it directly; a node route does not prove a pod namespace sees the same table.

### 3. Decide local versus remote using the actual prefix

Calculate whether the destination is inside a directly connected prefix. Do not use visual similarity such as "both begin with 10." `10.20.4.17/24` and `10.20.5.8/24` are off-link to one another even though their first two octets match. Conversely, `10.20.4.17/20` and `10.20.5.8/20` are in the same `/20` block.

### 4. Follow policy and select the winning route

List the applicable policy rules, selected table, every matching route, longest prefix, route type, next hop, interface, source, and meaningful metric. `ip route get` is valuable because it asks the kernel for the result rather than asking you to infer from a long table. It remains a lookup, not a probe.

### 5. Resolve the exact next hop on the local link

If the route is connected, the next hop can be the destination. If it uses `via`, the next hop is that gateway. Inspect that exact address on the selected interface. An empty neighbor table before traffic can be normal. A correlated transition to INCOMPLETE and FAILED is stronger evidence. A STALE entry is not automatically a fault.

### 6. Cross each routed, policy, tunnel, and translation boundary

At each boundary capture input tuple, output tuple, route choice, TTL or hop-limit change, policy result, packet and byte counts, drops, translation mapping, and effective MTU. Compare a healthy and failed operation at the same boundary. Control-plane desired state is context; data-plane input and output are stronger path evidence.

### 7. Trace the return path separately

Start at the destination's actual reply source. Which route reaches the source or translated source? Which neighbor is selected? Which stateful device must reverse a mapping? Does source validation accept that direction? Does a load balancer or proxy expect the response? If you cannot draw the reply, you have explained only half the system.

### 8. Verify the real outcome

Neighbor REACHABLE, a route lookup, NAT entry, accepted firewall counter, TCP handshake, HTTP status, and process `active` each prove one boundary. The operation succeeds only when the intended consumer receives the correct, timely result. Then check backlog, retries, state occupancy, neighboring cohorts, and recurrence.

## Failure zoom

### Incident A: the default route is innocent

A service in `10.44.7.0/24` fails. The node has a default route and other internet destinations work. Someone proposes restarting networking. The route table also contains:

```text
blackhole 10.44.0.0/16 metric 20
default via 10.10.0.1 dev eth0
```

For destination `10.44.7.25`, both prefixes match. `/16` is longer than `/0`, so the blackhole route wins and discards before neighbor resolution. The default route's health is irrelevant to this destination. The first abnormal boundary is route policy, not the interface, gateway, TCP, or service.

The safe path is to establish who installed the blackhole and why. It may be an intentional anti-loop or withdrawal guard whose scope is wrong because a more-specific unicast route disappeared. Blind deletion can reveal a loop or send traffic to the wrong tenant. Restore the intended specific route or correct the owning configuration, verify affected and adjacent prefixes, and retain the causal timeline.

### Incident B: the forward path is only half green

A workload in an overlapping address domain is translated to `172.31.40.17` before reaching a private service. Small calls work. Large responses time out. The edge shows accepted request packets and a translation entry. That does not prove the service response returns through compatible state.

Rank mechanisms:

1. reduced effective MTU after encapsulation with missing control feedback;
2. reply route bypassing the translation owner;
3. translation state or port capacity affecting new flows;
4. a size-dependent proxy or application limit;
5. transport loss or timeout behavior, covered deeply in the next lesson.

Correlate one operation at both sides of the boundary. If a large packet appears before the tunnel and not after it, while smaller packets cross and Packet Too Big or fragmentation-needed feedback is missing, MTU black hole becomes strong. If the reply takes another device, state asymmetry becomes strong. Do not lower every MTU, allow every ICMP type without policy, or expand a firewall as an experiment. Write a bounded prediction and repair the exact contract.

## Internals and state ownership

### CIDR math you must be able to do without a tool

For IPv4 `/n`, the first `n` bits are the prefix. A `/26` leaves six host bits, so the block size is `2^6 = 64` addresses. In the final octet, blocks begin at 0, 64, 128, and 192.

Address `192.0.2.130/26` falls in the 128-191 block:

```text
address last octet: 130 = 10000010
/26 mask last octet:      11000000 = 192
bitwise AND:              10000000 = 128
network: 192.0.2.128/26
```

Classic IPv4 subnet exercises call `.128` network and `.191` broadcast, with `.129` through `.190` usable. Platform, anycast, point-to-point, and provider contracts can reserve or interpret addresses differently, so use this math as foundation and the real environment contract as authority.

For IPv6, group the address into hexadecimal nibbles. Each hex digit represents four bits. A `/64` aligns after four 16-bit groups. `2001:db8:42:7::1234/64` belongs to `2001:db8:42:7::/64`. Prefixes that are not multiples of four require bit reasoning inside a hex digit. IPv6 has no broadcast; multicast and Neighbor Discovery serve different roles.

### Linux policy routing order

Linux rules normally include local-table lookup, main-table lookup, and default-table lookup, but systems can add source-based, mark-based, interface-based, or tenant rules. Lower numeric priority is consulted earlier. A successful result can stop lookup. A special route type can reject without consulting a later default.

Within a table, longest-prefix match dominates. Route type decides action. Metrics compare suitable candidates, commonly routes to the same prefix. Multipath routes can select among next hops based on a flow hash. Cached decisions and per-route attributes can affect observed output. That is why `ip route get` with the real source and context is better than pointing to one visually familiar line.

### Neighbor state belongs to one namespace, interface, and next hop

Neighbor keys are not just IP addresses. Interface and namespace matter. The same gateway IP can exist on isolated tenant links with different MAC addresses. A stale permanent entry can override dynamic discovery. Proxy ARP or NDP can make another node answer. Duplicate addressing can produce intermittent identity changes.

When resolution fails, separate these questions:

- Did the route choose the intended interface and next-hop IP?
- Did Linux issue a request on that link?
- Did an answer return?
- Did the answer contain the intended identity?
- Did policy or driver state accept and store it?
- Did a frame using that identity leave, and did the next owner receive it?

Each question has a different owner. "ARP failed" is still too broad until you locate the transition.

### Routers replace frames and decrement hop budgets

A router receives a frame addressed to its local link identity, removes the link header, validates and processes the IP packet, decrements TTL or Hop Limit, selects another route, resolves another next hop, and builds another frame. It does not carry the original Ethernet header across routed domains.

TTL expiry normally produces ICMP Time Exceeded feedback. Traceroute-like tools exploit that behavior, but a missing response does not prove the router is absent; policy can rate-limit or filter control messages, and return paths can differ. Use hop evidence as one part of the path, not a magical topology oracle.

### NAT and stateful policy own mappings, capacity, and time

A translator can record:

```text
original direction:
  10.20.4.17:41000 -> 10.80.16.25:443 TCP
reply direction expected:
  10.80.16.25:443 -> 172.31.40.17:51000 TCP
mapping:
  original source 10.20.4.17:41000 <-> translated source 172.31.40.17:51000
```

An entry proves that this device created or observed state. It does not prove the destination received application data or that the reply returned. Tables have maximum sizes and timeouts. Port translation has a finite address-and-port pool. Failover may or may not replicate state. A route change can move replies away from the owner. Treat mapping identity, creation failures, occupancy, expiration, drops, and both directions as one operational contract.

### MTU is a path property once headers are added

Suppose an application produces a payload that becomes a 1500-byte IP packet. A tunnel adds 50 bytes while the underlay MTU is 1500. The encapsulated packet no longer fits. Depending on protocol, configuration, and feedback, the source must send smaller packets or perform appropriate fragmentation. If the packet is silently dropped and feedback never reaches the source, retries do not repair the size contract.

Do not equate interface MTU with end-to-end PMTU. The minimum effective limit across the selected path wins, and alternate/failover paths can differ. Observe packet sizes, encapsulation overhead, control feedback, retransmission, and boundary drops for the exact route.

## Evidence table

| Question | First evidence | Proves | Does not prove | Safe next step |
|---|---|---|---|---|
| Which network view am I in? | `readlink /proc/self/ns/net` plus workload identity | Current process namespace link and correlation context | Which namespace was intended or what another namespace sees | Compare the owning process and matched healthy workload |
| Does the source have an interface and prefix? | `ip -brief link`; `ip -brief address` | Configured link state and addresses in this namespace | VLAN, neighbor, route, remote reachability | Calculate on-link status and inspect route policy |
| Which route wins? | `ip rule`; tables; exact `ip route get` | Kernel's selected local route result | That a packet left or a reply returns | Inspect the selected next hop and interface |
| Is the next hop resolved? | Exact `ip neigh` row | Mapping and current NUD state | Root cause or end-to-end reachability | Compare same gateway on a matched source; inspect bounded link evidence |
| Did this interface account an error? | Two scoped `ip -s link` snapshots | Counter delta at this interface | Exact packet or downstream result | Correlate with one operation and adjacent boundary |
| Is forwarding enabled? | Relevant procfs sysctl | Current forwarding flag in this namespace | Routes, policy, NAT, persistence, or permission to change | Verify intended router role and policy |
| Did stateful translation occur? | Correlated original/reply tuple on state owner | Mapping existed for that flow on that device | Destination receipt or return traversal | Observe both sides and the reply path |
| Is MTU the mechanism? | Size threshold, paired boundary evidence, feedback and drops | A correlated size-dependent break at a boundary | Why the contract is wrong or every path is affected | Test one bounded prediction; repair feedback or MTU ownership |
| Is the service restored? | Real user operation plus reverse evidence | Tested operation succeeded in declared scope | Long-term stability, all cohorts, or mastery | Reconcile retries/state and verify prevention |

The strongest evidence usually compares boundaries or cohorts. A single output is a snapshot. A before/after delta around one correlated operation tells you which owner saw change. A failed and healthy source using the same gateway narrows the local attachment. A packet observed before but not after a boundary locates a transition, provided clocks, identity, sampling, and capture scope are trustworthy.

## Command decoders

### `ip -brief link show`

Typical shape:

```text
lo        UNKNOWN        <LOOPBACK,UP,LOWER_UP>
eth0      UP             <BROADCAST,MULTICAST,UP,LOWER_UP>
```

- First field: interface name in this namespace.
- Second field: summarized operational state. `UNKNOWN` on loopback or some virtual links is not automatically unhealthy.
- Angle-bracket flags: capabilities and state. `UP` is administrative; `LOWER_UP` says the driver reports lower-layer readiness; `LOOPBACK`, `BROADCAST`, and `MULTICAST` describe link behavior.

This command does not show the full device ancestry or prove a frame can cross the next link.

### `ip -brief address show`

Typical shape:

```text
eth0      UP     10.42.1.17/24 fe80::215:5dff:fe42:1701/64
```

- Interface and state identify the local owner.
- `10.42.1.17/24` is an IPv4 address plus prefix, not the gateway.
- `fe80::.../64` is IPv6 link-local scope; it is meaningful on that link and often requires an interface scope when used.
- Additional addresses may represent privacy, secondary, virtual IP, or platform behavior. Source selection matters.

### `ip rule show`

Typical shape:

```text
0:      from all lookup local
100:    from 10.42.1.0/24 lookup tenant-a
32766:  from all lookup main
32767:  from all lookup default
```

- The number before the colon is priority; lower values run first.
- `from` is a selector, not a route.
- `lookup` names the table to search.
- Rules can include destination, mark, input/output interface, UID range, and other context.

A main-table route can be irrelevant if an earlier matching rule returns another decision.

### `ip route show table all`

Common route shapes:

```text
10.42.1.0/24 dev eth0 proto kernel scope link src 10.42.1.17
10.42.8.0/24 via 10.42.1.1 dev eth0 metric 100
blackhole 10.44.0.0/16 metric 20
default via 10.42.1.1 dev eth0
local 10.42.1.17 dev eth0 table local proto kernel scope host
```

- Destination prefix is what the route matches; `default` is IPv4 `/0` or IPv6 `::/0`.
- `via` is the next-hop IP on a reachable link.
- `dev` is the egress interface.
- `proto` says how the route was installed, not the transport protocol.
- `scope link` says the next hop is directly reachable on that link under the route model.
- `src` is a preferred source hint.
- `metric` helps choose among comparable routes.
- `blackhole`, `unreachable`, `prohibit`, and `local` are actions or special types, not decorative labels.
- `table` identifies ownership when shown.

### `ip route get DESTINATION`

Typical result:

```text
10.42.8.25 via 10.42.1.1 dev eth0 src 10.42.1.17 uid 1000
    cache
```

- First address is the queried destination.
- `via` is the selected next hop; when absent on a connected route, the destination can itself be the neighbor target.
- `dev` is egress.
- `src` is selected source.
- `uid` shows user context considered by the lookup on supporting versions.
- `cache` is output context, not proof that an old route cache caused an incident.

Add `from SOURCE`, `mark VALUE`, or other supported selectors when they are part of the real packet. Do not send a probe merely to answer a local decision question.

### `ip neigh show`

Typical shapes:

```text
10.42.1.1 dev eth0 lladdr 00:11:22:33:44:55 REACHABLE
10.42.1.90 dev eth0 INCOMPLETE
fe80::1 dev eth0 lladdr 00:11:22:33:44:66 router STALE
```

- First field is neighbor network address.
- `dev` scopes the link.
- `lladdr` is link-layer address when known.
- `router` is an IPv6 neighbor flag when applicable.
- Final state is NUD state, which must be interpreted over time and against the selected next hop.

An empty row can mean no recent resolution attempt. Do not manufacture traffic on a sensitive network simply to fill the cache without authorization.

### `ip -s link show`

The RX and TX blocks contain bytes, packets, errors, dropped, missed, carrier, collisions, and driver-dependent fields. These are cumulative since device creation or reset. Read two timestamps and calculate deltas. `dropped` can mean different internal points across devices; inspect driver and platform definitions before making a causal claim. Packet counters increasing only prove accounting at this interface.

### `/proc/sys/net/ipv4/ip_forward`

`0` means generic IPv4 forwarding is disabled in that namespace; `1` means enabled. Changing it can reset or affect network behavior and requires design ownership. Reading it is safe. Its value does not describe firewall chains, route existence, reverse-path filtering, NAT, persistence, IPv6 forwarding, or application health.

## Decision path

Use this sequence under incident pressure:

1. **Name the operation.** Source process and namespace, destination address, transport, port, size, expected result, time, and cohorts.
2. **Classify supplied facts.** "Default route exists" and "service healthy" have scope; neither is end-to-end proof.
3. **Calculate prefix membership.** Decide whether the destination is on-link using bits, not visual similarity.
4. **Query route policy.** Identify rule, table, every match, longest prefix, route type, next hop, interface, and source.
5. **Inspect the exact neighbor.** Resolve the selected gateway or connected destination on the selected interface.
6. **Compare one adjacent boundary at a time.** Interface output, next-hop input, router output, policy/NAT input and output, destination input.
7. **Draw the reply independently.** Route to original or translated source, state owner, policy, and final socket.
8. **Consider size and time.** Effective MTU, encapsulation, feedback, state timeout, and capacity can make failure selective.
9. **Rank at least three mechanisms.** Each gets predicted support and rejection evidence.
10. **Choose the least risky discriminating observation.** Prefer local lookup and existing telemetry before capture or mutation.
11. **If change is justified, write the envelope.** Owner, approval, exact scope, prediction, success, abort, rollback, and preserved evidence.
12. **Verify the operation and neighbors.** Real result, return path, state capacity, backlog, retries, and unaffected cohorts.

Stop escalation at the first abnormal boundary. If route selection returns blackhole, remote packet capture is waste. If neighbor resolution fails, destination firewall work is premature. If the request reaches the service but no reply returns, the source link is no longer your first suspect.

## Guided Ubuntu lab

This lab teaches reasoning without touching host network state. Its Python model represents virtual interfaces, prefixes, routes, neighbors, a stateful boundary, forward and return paths, and MTU. Every time-like value in model output is virtual. Shell runtime is only lab execution time. Neither measures a real network.

### Safety card

| Boundary | Contract |
|---|---|
| Platform | Ubuntu 24.04 or WSL 2 Ubuntu 24.04 |
| Identity | Normal user; UID 0 refused |
| Network | None; no socket or external request |
| Host changes | No interface, address, route, neighbor, firewall, namespace, sysctl, or package changes |
| Written state | One guarded UID-scoped descriptor and one private random lesson root under the temporary directory |
| Stop | Any guard refusal, unexpected path or artifact, root identity, dependency mismatch, or proposed host-network mutation |
| Recovery | Supported `recover` only |
| Cleanup | Supported `cleanup`, then `check` must report absent |

### Learning sequence

From repository root:

```bash
bash book/labs/LES-0012-packet-path/lab.sh check
bash book/labs/LES-0012-packet-path/lab.sh setup
bash book/labs/LES-0012-packet-path/lab.sh status
```

Reveal supplied facts for the guided case before baseline or any derived observation:

```bash
bash book/labs/LES-0012-packet-path/lab.sh scenario guided
```

`scenario guided` stores one immutable case selection and prints raw inputs: source CIDR, destination, policy rules, route entries, translation and return configuration, application response bytes, planned largest TCP payload, IP and TCP header sizes, underlay MTU, and encapsulation overhead. It does not print the winning route, next hop, neighbor result, created mapping, translated tuple, effective MTU, fit result, or operation result. The harness reports `prediction_record=external-required` because it cannot honestly verify notes stored outside its guarded directory.

Before baseline, write and preserve externally:

- source address and prefix;
- destination and whether it is on-link;
- all expected matching routes and winner;
- selected next hop and whose link identity is needed;
- forward and return tuple;
- application response bytes versus the planned largest TCP segment payload;
- `largest emitted IP packet = TCP payload + TCP header + IP header`;
- `effective inner IP MTU = underlay link MTU - encapsulation overhead`;
- `largest encapsulated packet = largest emitted IP packet + overhead`;
- `signed headroom = underlay link MTU - largest encapsulated packet`;
- predicted route, neighbor, translation, return, MTU, and operation results.

Only after that external prediction exists, run baseline and inspect the declared views:

```bash
bash book/labs/LES-0012-packet-path/lab.sh run baseline
bash book/labs/LES-0012-packet-path/lab.sh observe addresses
bash book/labs/LES-0012-packet-path/lab.sh observe routes
bash book/labs/LES-0012-packet-path/lab.sh observe path
```

Decode every field. `route_result` is `selected` when the winner is usable and `rejected` when the winning route rejects; `ok` is not model vocabulary. Explain which rule and prefix won, why the gateway rather than remote destination needed a neighbor mapping, where translation changed identity, how the reply found reverse state, and why the emitted packet fit or exceeded the effective inner MTU.

Write three guided-case hypotheses and predictions, then:

```bash
bash book/labs/LES-0012-packet-path/lab.sh inject guided
bash book/labs/LES-0012-packet-path/lab.sh observe routes
bash book/labs/LES-0012-packet-path/lab.sh observe path
```

Locate the first baseline/current divergence. Use only documented probes. A route object may exist but have a rejecting type. A neighbor row may exist but be unresolved. A mapping may exist but lack a compatible return. A packet may have a valid route but exceed effective MTU.

After preserving evidence:

```bash
Recovery output separates application response bytes from segment and packet sizes. Prove `inner packet = largest TCP payload + TCP header + IP header`, `effective inner MTU = underlay MTU - encapsulation overhead`, `encapsulated packet = inner packet + overhead`, and `signed headroom = underlay MTU - encapsulated packet`. A segmentation repair can preserve one application response while emitting several smaller packets. Exact independent recovery values appear only after the supported recovery command.

The verifier recomputes all four equations from emitted numeric fields for baseline, independent failure, both recoveries, both verifications, and MTU probes. A printed `mtu_result=fits` cannot pass verification if those numbers disagree.

bash book/labs/LES-0012-packet-path/lab.sh recover
bash book/labs/LES-0012-packet-path/lab.sh verify-operation
bash book/labs/LES-0012-packet-path/lab.sh cleanup
bash book/labs/LES-0012-packet-path/lab.sh check
```

Success means the modeled operation and cleanup contract pass. It does not mean the learner has mastered networking or that a production route should be changed.

### What a strong lab explanation sounds like

"The source and destination were off-link under `/24`. Baseline policy selected the main virtual table; both `/16` and `/24` matched, and `/24` won. That route used gateway G on interface E, so G (not the remote service) was the local neighbor target. In the incident, the first changed boundary was X. Evidence Y rejected neighbor failure and return-state failure. Supported recovery restored X, and the identical forward-and-return operation succeeded. The model never sent a packet, so production transfer still requires live namespace, data-plane, policy, MTU, and state evidence."

## Production transfer

### WSL 2

Your Ubuntu distribution runs inside a utility VM. Windows, the WSL virtual switch, the distribution, a VPN client, and an enterprise proxy can each own addresses, routes, NAT, DNS, policy, and MTU. A Windows route and a Linux route are different boundaries. First identify where the failing socket lives, then trace outward. Do not "fix WSL networking" by resetting every adapter when one VPN prefix or MTU boundary is the first divergence.

### Docker and OCI containers

A container normally has its own network namespace with a veth, connected prefix, default route toward a bridge or CNI device, and a separate loopback. Published ports can introduce destination translation or proxy behavior. Container egress may use source NAT. Inspect container, host, bridge, and translator as separate owners. `curl localhost` inside the container tests that namespace, not the host listener.

### Kubernetes

A pod IP, node route or overlay, Service virtual IP, EndpointSlice, kube-proxy or eBPF program, NetworkPolicy, load balancer, and application socket form a longer path. A Service object proves desired control-plane state. It does not prove endpoints are selected, data-plane rules are programmed, the pod route works, or replies return. Trace one tuple through pod namespace, node data plane, service translation, destination pod, and return path. Account for overlay MTU.

### Cloud VPC or VNet

Provider route tables, subnet associations, security groups, network ACLs, managed NAT, load balancers, peering, transit, private endpoints, quotas, and flow logs are abstractions over the same decisions. A configured route is not necessarily associated with the source subnet. Security rules can be stateful while ACLs are stateless. Managed components may expose only summarized telemetry. Map provider names to prefix, next hop, policy owner, translation state, failure domain, and return path.

### Private cloud and virtualization

A VM packet can cross guest interface and route, tap device, Linux bridge or Open vSwitch, overlay tunnel, physical NIC, top-of-rack switch, routed fabric, and distributed firewall. Each layer can have a different MTU and control plane. Trace the guest's selected next hop first. Then pair input/output evidence across virtual-switch and tunnel boundaries. Do not blame the physical network when a logical flow or missing return tunnel is first abnormal.

### Hybrid connectivity

VPNs, private circuits, transit gateways, overlapping prefixes, route advertisements, NAT, and identity-aware proxies add ownership. Write both routing domains and both directions. Decide whether prefixes are advertised, accepted, associated, and preferred. Include failover route specificity, tunnel overhead, stateful inspection, and observability gaps. "Tunnel up" is a control-plane state, not a successful application journey.

## Reliability, security, observability, capacity, and cost

### Reliability

Design for explicit failure domains. Redundant gateways are useful only if hosts can select them and state survives or drains safely. Route failover can change MTU, latency, policy, NAT identity, and return symmetry. Test the user journey on the failover path, not just protocol adjacency. Bound blast radius with staged route changes, canaries, maximum-prefix controls, withdrawal behavior, and quick rollback.

### Security

Address and route are not identity proofs. Prevent source spoofing at trust boundaries, use least-privilege policy for required tuples, protect neighbor mechanisms against unauthorized changes, restrict forwarding, and audit route/NAT/firewall configuration. Do not log payloads or sensitive tenant addresses unnecessarily. NAT is not a security boundary by itself; explicit policy and trust ownership remain necessary.

### Observability

Collect interface/link state, route and policy identity, selected next-hop reachability, per-boundary packets/bytes/drops, stateful rule outcomes, original and translated tuple correlation where permitted, table occupancy and allocation failures, MTU feedback, packet-size distributions, and real operation success. Control cardinality and data sensitivity. A dashboard average across zones or source subnets can hide the precise failure domain.

### Capacity

Routes consume forwarding state. Neighbors consume cache state. NAT and conntrack consume entries, ports, memory, and CPU. Interfaces and virtual devices have queues. Tunnels add per-packet work and bytes. Capacity planning needs new-flow rate, concurrent state, expiration rate, port pool, packet rate, byte rate, packet sizes, queue/drop behavior, failover headroom, and user latency - not link utilization alone.

### Cost

Network cost includes cross-zone or cross-region bytes, NAT processing, load balancer hours and capacity units, private links, VPN or circuit capacity, public addresses, flow-log volume, packet capture storage, and engineer time. A cheaper centralized translator can create a failure domain and hairpin traffic. A more redundant design can raise fixed cost while reducing recovery risk. Tie cost to the packet path and SLO, not to a service name.

## Traps and prevention

| Trap | Why it fails | Better habit |
|---|---|---|
| "The network is down" | No source, destination, direction, layer, or boundary | State the exact operation and first observed divergence |
| "The default route exists" | A more-specific or policy route may win | Query the exact destination and list every matching prefix |
| ARP for a remote IP | Off-link traffic resolves its gateway | Identify the selected next hop before reading neighbor state |
| Treat STALE as broken | STALE can be a usable cached mapping | Follow NUD transitions and correlate the operation |
| Ping equals service health | ICMP is a different exchange and policy | Verify the real protocol, port, and application result |
| Forward path equals connectivity | Replies can route differently or bypass state | Draw and observe both directions |
| NAT entry equals success | State creation precedes destination and response proof | Correlate original/reply tuples and final operation |
| Lower every MTU | High blast radius and hides missing feedback | Locate the size boundary and repair the exact contract |
| Flush every cache | Destroys evidence and disrupts healthy traffic | Change only the proven object through managed ownership |
| Change firewall first | Policy may not be reached and exposure expands | Prove packet arrival and exact policy decision |
| Trust control-plane green | Desired/programmed state may differ from data plane | Pair control state with boundary input/output evidence |
| Ignore namespace | Correct command in wrong view produces a false story | Record the socket-owning namespace first |

Prevent repeat incidents with reviewed address plans, non-overlap checks, route-policy tests, maximum-prefix and blackhole safeguards, matched source-subnet probes, neighbor-failure alerts, bidirectional synthetic journeys, NAT/conntrack capacity alerts, MTU probes for real path sizes, configuration provenance, staged rollout, and rollback drills.

## Memory card and retrieval

### The packet-path card

```text
WHO:     process + namespace + source identity
WHERE:   destination address + protocol + port + operation
PREFIX:  on-link or off-link? show the calculation
ROUTE:   rule -> table -> all matches -> longest prefix -> type
NEXT:    gateway/direct target -> interface -> exact neighbor state
PATH:    frame per link -> router/policy/tunnel/NAT boundaries
RETURN:  route to original/translated source -> compatible state
SIZE:    packet + encapsulation <= effective MTU? feedback visible?
RESULT:  real operation + retries/state/capacity + healthy cohorts
```

### Five retrieval questions

1. Why can a healthy default route be irrelevant to one destination?
2. For an off-link IPv4 destination, whose MAC address does the source need?
3. What does `ip route get` prove, and what remains untested?
4. Why must a stateful translator see a compatible return path?
5. Why does small-success/large-failure raise MTU without proving it?

Answer without looking. Then draw a source `/24`, one gateway, two candidate routes, a translator, and a lower-MTU tunnel. If you cannot explain the winning prefix and reply tuple, reread those mechanisms before running more commands.

### One-minute explanation

"An application gives bytes to a socket. Linux chooses source and route for an IP destination, then resolves only the selected next hop on the local link and puts the packet into a frame. Routers rebuild frames and choose routes at every hop. Policy and NAT can accept, reject, or rewrite the tuple and require compatible return state. MTU can make failures size-dependent. I diagnose by naming the namespace and operation, calculating the prefix, querying the exact route, checking the exact neighbor, observing paired boundaries in both directions, and verifying the real result."

## Complete answers

The diagnostic below is designed to remove a dangerous reflex: a visible route does not move a frame. Read the scenario once, answer from the packet-path card, and only then reveal the complete teaching answer.

Your answer must identify the first abnormal transition and preserve proof limits. A strong response says why database-firewall work is premature, why a healthy host from another subnet is a weak comparison, what INCOMPLETE, FAILED, STALE, and REACHABLE mean, and how recovery is verified beyond the neighbor table.

Before revealing:

1. Calculate whether the destination is on-link.
2. Decode destination, `via`, `dev`, and `src`.
3. Name the exact neighbor target.
4. Rank at least three mechanisms beneath FAILED.
5. Propose one read-only comparison and one narrowly authorized observation.
6. State the smallest possible remediation envelope.

The answer panel is teaching material, not learner evidence. Reading it cannot complete the independent transfer.

## Product-company interview

Senior interviews test whether you can hold the whole path and still act safely. The architecture scenario combines overlapping address space, stateful translation, asymmetric risk, and selective large-response failure. Do not answer with a list of tools. Begin with a diagram and explicit ownership.

A strong interview structure is:

- **Clarify:** source, destination, tuple, address plans, overlap, request sizes, failure cohorts, and success.
- **Draw:** namespace, prefixes, rules, routes, next hops, translation, service, and reply.
- **Predict:** which prefix wins, what identity each policy sees, which state owner must see replies, and where MTU shrinks.
- **Observe:** route query, exact neighbor, paired-boundary tuple and packet-size evidence, translation state, feedback, drops, and user result.
- **Control:** no global route, firewall, ICMP, or MTU change; use an approved canary with abort and rollback.
- **Design:** failure domains, HA/state behavior, segmentation, capacity, telemetry, and cost.
- **Verify:** real large bidirectional operation plus unaffected cohorts and residual uncertainty.

If the interviewer changes one constraint (IPv6-only, two translators, ECMP, an overlay, a stateless ACL, or a return path in another region), redraw the owner of each decision. Do not force the old answer into a new system.

## Independent transfer and rubric

The independent assessment uses a changed modeled topology and stores no model answer. Its purpose is to test whether you can derive a path rather than recognize the guided incident.

Start from clean guarded state, reveal only the independent inputs, and freeze your response before baseline:

```bash
bash book/labs/LES-0012-packet-path/lab.sh setup
bash book/labs/LES-0012-packet-path/lab.sh scenario independent
```

Do not inspect fixture source or another submission before finishing. Record prefix, route, tuple, segmentation, packet, encapsulation, effective-MTU, and signed-headroom predictions externally before `run baseline`. Then use only supported observation. Your deliverable must show every route match, why one wins, which next-hop identity is required, where any translation occurs, how the reply returns, and whether each emitted packet fits the effective inner MTU.

Independence is part of the evidence. Disclose hints, collaboration, or accidental exposure. A reviewer can accept, request correction, or require a new changed constraint. A perfect lab transcript without your own explanation is not evidence of transfer.

The observable rubric scores safety, CIDR and route reasoning, complete bidirectional path, hypothesis and recovery quality, and production transfer. It does not score confidence, speed alone, or vocabulary copied from this page.

## References and review

The reference cards below anchor the mechanisms in protocol standards and Linux command manuals. Use them to verify a claim, not to replace a path explanation.

- RFC 826 defines the original IPv4-over-Ethernet address-resolution mechanism.
- RFC 4861 defines IPv6 Neighbor Discovery and reachability behavior.
- RFC 8200 defines the IPv6 base header, hop limit, and fragmentation model.
- RFC 4632 explains classless prefixes, aggregation, and longest-match forwarding.
- RFC 1812 records IPv4 router requirements and forwarding behavior.
- RFC 3022 describes traditional NAT and its stateful architectural implications.
- `ip-route(8)` is the command authority for Linux route objects and lookup syntax.
- `ip-neighbour(8)` is the command authority for neighbor table operations and states.

Before the review date, check RFC status and errata, current iproute2 output, Ubuntu 24.04 behavior, WSL differences, lab lifecycle integrity, every external URL, and whether production-transfer statements remain provider-neutral and accurate. Keep quotations short and attributed; teach in original language.

Publication status is **substantive draft**. The chapter, lab, answers, and successful project checks make it available to study. They do not prove formal content acceptance, learner execution, delayed recall, independent transfer, production authority, or mastery.
