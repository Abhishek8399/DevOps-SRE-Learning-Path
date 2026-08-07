---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0077",
  "slug": "openstack-control-data-plane-operations",
  "aliases": ["V09-L02", "openstack-control-data-plane-operations"],
  "curriculumIds": ["PRV-002"],
  "route": "/book/privatecloud/openstack-control-data-plane-operations",
  "order": 2,
  "volume": "09-private-cloud",
  "title": "OpenStack operations: trace identity, compute, network, image, volume, and recovery paths",
  "summary": "Trace one OpenStack operation through Keystone, service discovery, Nova cells and RPC, Placement, Glance, Neutron, Cinder, the hypervisor, guest, user outcome, high availability, upgrades, reconciliation, and recovery.",
  "domain": "private-cloud",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0012", "LES-0051", "LES-0058", "LES-0076"],
  "prerequisiteCurriculumIds": ["NET-002", "IAM-001", "DST-005", "PRV-001"],
  "testedEnvironments": [
    {"platform":"Official documentation","version":"OpenStack Security Guide and latest Keystone, Nova, Placement, Neutron, Glance and Cinder pages reviewed 2026-08-07","support":"concept-only","notes":"Latest pages can represent development branches; documentation does not prove a deployed release."},
    {"platform":"Ubuntu","version":"24.04 WSL normal-user guarded lifecycle","support":"required","notes":"No OpenStack authority was exported and no service or endpoint was called."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic 51-case request-path model; no OpenStack operation."},
    {"platform":"OpenStack runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No package, API, database, queue, agent, hypervisor, image, network, volume or instance action was attempted."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "private-cloud-engineer", "openstack-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Trace a request from caller identity and service discovery through every control and data-plane boundary to a user outcome.",
    "Separate Keystone authentication and scope, catalog discovery and each service authorization decision.",
    "Explain Nova API/global state, cell mappings, cell0, cell-local databases and queues, scheduler, conductor and compute roles.",
    "Reason about Placement resource providers, inventories, traits, candidates, allocations, claims and reconciliation.",
    "Prove Glance image record, task, store bytes, provenance, access and lifecycle separately.",
    "Trace Neutron desired network state through port binding, agents or controllers, effective flows, DHCP, metadata and packet return path.",
    "Trace Cinder volume, attachment, service, backend, connector and writer-authority state.",
    "Distinguish API acceptance, resource status, backend realization, guest readiness, application readiness and user correctness.",
    "Design database, messaging and service high availability across real failure domains with capacity reserve and fencing.",
    "Diagnose BUILD, ERROR, ACTIVE, orphaned and partially completed operations using correlated request and resource evidence.",
    "Plan migrations, evacuation, backup, recovery, reconciliation and cleanup without direct unsupported database mutation.",
    "Execute release-aware rolling upgrades with compatibility, migrations, canary, stop, rollback and user/data validation."
  ],
  "productionSignals": [
    "caller subject project domain system scope roles token audit ID and expiry",
    "region interface service type catalog endpoint DNS TLS and connection result",
    "request ID resource UUID API microversion response status and idempotency key or retry lineage",
    "Nova API database cell mapping cell0 cell database and instance vm task power state",
    "RPC exchange topic queue delivery age retry timeout conductor and compute service version",
    "request spec aggregate availability zone flavor extra specs and scheduler decision",
    "Placement provider generation inventory usage reserved ratio trait candidate allocation and consumer generation",
    "compute host service state admission capability resource tracker generation and hypervisor result",
    "Glance image UUID owner visibility status task store location bytes digest and provenance",
    "Neutron network subnet port binding host segment VIF status agent or controller realization",
    "DHCP lease metadata path router NAT security policy flow drop and bidirectional packet evidence",
    "Cinder volume snapshot attachment connector host service backend device writer and error state",
    "database quorum replication lag lock connection pool schema and backup restore evidence",
    "message cluster quorum partition queue depth unacked redelivery age and poison-message evidence",
    "service process heartbeat version worker saturation dependency latency and health reason",
    "failure domain power rack network storage management dependency and survivor capacity",
    "upgrade release versions RPC/object/API pins schema migration online migration canary and stop gate",
    "guest boot cloud-init application SLI data invariant external user result cleanup and residual risk"
  ],
  "diagrams": [
    {"id":"LES-0077-DIA-001","title":"OpenStack request and state-owner map","direction":"left-to-right","boundaries":["caller","Keystone","service catalog","service API","database and messaging","worker or agent","backend or hypervisor","guest and user"],"evidencePoints":["scope","endpoint","request ID","record","RPC","effective state","runtime","user SLI"],"textAlternative":"A request crosses identity, discovery, service control, asynchronous work, backend realization and user boundaries; no single status proves the full result."},
    {"id":"LES-0077-DIA-002","title":"Nova server-build path through cells and Placement","direction":"left-to-right","boundaries":["Nova API","API database","cell mapping","request spec","Placement","scheduler claim","cell RPC and conductor","nova-compute","hypervisor"],"evidencePoints":["request ID","server UUID","cell UUID","requirements","allocation","host","message","spawn"],"textAlternative":"A server build coordinates global API state, a selected cell, Placement capacity, scheduler claim, cell-local messaging and compute execution."},
    {"id":"LES-0077-DIA-003","title":"Image network and volume realization","direction":"hierarchical","boundaries":["Nova coordination","Glance record and stores","Neutron port and dataplane","Cinder attachment and backend","hypervisor devices","guest"],"evidencePoints":["image UUID","store bytes","binding","flow","attachment","device","boot"],"textAlternative":"Nova coordinates resources whose records and effective backend state remain owned by Glance, Neutron and Cinder."},
    {"id":"LES-0077-DIA-004","title":"Desired record versus effective dataplane","direction":"left-to-right","boundaries":["API record","scheduler or binding","message","agent or controller","host state","physical backend","user flow"],"evidencePoints":["revision","host","delivery","ack","flow/device","packet or I/O","transaction"],"textAlternative":"An API record becomes useful only after asynchronous realization on the selected host and validation through the real data path."},
    {"id":"LES-0077-DIA-005","title":"Cell and control-plane failure domains","direction":"hierarchical","boundaries":["global APIs","API database","cell mappings","per-cell database and queue","service replicas","compute and network/storage backends"],"evidencePoints":["health","quorum","reachability","isolation","reserve","recovery"],"textAlternative":"Cells isolate some compute state and work, but global services and each cell dependency need separate availability, capacity and recovery design."},
    {"id":"LES-0077-DIA-006","title":"Rolling upgrade and recovery state machine","direction":"cyclic","boundaries":["inventory and compatibility","backup and rollback proof","schema expansion","control canary","cell or worker rollout","online migrations","user validation","retirement and reconciliation"],"evidencePoints":["versions","restore","migration","canary","mixed state","completion","SLI","cleanup"],"textAlternative":"An upgrade is complete only after supported mixed-version operation, required migrations, user validation, cleanup and proven recovery boundaries."}
  ],
  "commands": [
    {"id":"LES-0077-CMD-001","question":"Is this a guarded no-service shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0077 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"source and authority guards pass","nextEvidence":"inventory-tools"},{"when":"lab=fail","meaning":"a named guard failed","nextEvidence":"correct without bypass"}],"proves":"local model prerequisites","doesNotProve":"OpenStack availability"},
    {"id":"LES-0077-CMD-002","question":"Which local tools are merely present?","risk":"read-only","command":"bash lab.sh inventory-tools","runFrom":"LES-0077 support/lab","expectedBranches":[{"when":"inventory=observed","meaning":"architecture environment and command presence are reported without invocation","nextEvidence":"retain no-service limit"}],"proves":"local command discovery","doesNotProve":"authentication endpoint or service readiness"},
    {"id":"LES-0077-CMD-003","question":"Can bounded synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0077 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture copy exists","nextEvidence":"status"},{"when":"refusal","meaning":"authority or state is unsafe","nextEvidence":"preserve first error"}],"proves":"bounded model initialization","doesNotProve":"resource creation","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0077-CMD-004","question":"Are all reviewed cases loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"cases=51","meaning":"expected fixture is active","nextEvidence":"show baseline"},{"when":"other count or refusal","meaning":"fixture drift","nextEvidence":"stop"}],"proves":"fixture identity and count","doesNotProve":"OpenStack coverage"},
    {"id":"LES-0077-CMD-005","question":"Which synthetic claims create the baseline?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"all model inputs are inspectable","nextEvidence":"evaluate baseline"}],"proves":"synthetic inputs","doesNotProve":"host or service truth"},
    {"id":"LES-0077-CMD-006","question":"Does the finite baseline cross every gate?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=operable-within-model","meaning":"all encoded predicates pass","nextEvidence":"compare isolated failures"}],"proves":"deterministic baseline result","doesNotProve":"production operability"},
    {"id":"LES-0077-CMD-007","question":"Can a valid token use the wrong project?","risk":"read-only","command":"bash lab.sh evaluate token-wrong-project","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=token-scope","meaning":"authentication did not establish intended project authority","nextEvidence":"scope roles and service policy"}],"proves":"encoded scope boundary","doesNotProve":"Keystone behavior"},
    {"id":"LES-0077-CMD-008","question":"Can Nova find the correct cell state?","risk":"read-only","command":"bash lab.sh evaluate instance-cell-mapping-missing","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=cell-mapping","meaning":"global-to-cell ownership is unresolved","nextEvidence":"server UUID cell mapping and cell records"}],"proves":"encoded cell boundary","doesNotProve":"Nova state"},
    {"id":"LES-0077-CMD-009","question":"Does a bound port prove packets flow?","risk":"read-only","command":"bash lab.sh evaluate bound-port-no-dataplane","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=dataplane-realization","meaning":"binding exists without effective network state","nextEvidence":"host flows agents controllers and packets"}],"proves":"encoded desired/effective boundary","doesNotProve":"Neutron behavior"},
    {"id":"LES-0077-CMD-010","question":"Does a volume record prove backend health?","risk":"read-only","command":"bash lab.sh evaluate cinder-backend-down","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=volume-backend","meaning":"control record lacks backend realization","nextEvidence":"service backend connector and writer authority"}],"proves":"encoded storage boundary","doesNotProve":"Cinder behavior"},
    {"id":"LES-0077-CMD-011","question":"Does guest reachability prove the application?","risk":"read-only","command":"bash lab.sh evaluate guest-up-application-down","runFrom":"LES-0077 support/lab after setup","expectedBranches":[{"when":"boundary=application-readiness","meaning":"infrastructure is insufficient user evidence","nextEvidence":"application dependency user and data checks"}],"proves":"encoded readiness boundary","doesNotProve":"guest or application state"},
    {"id":"LES-0077-CMD-012","question":"Do all decisions and cleanup pass with zero service calls?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0077 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"51 cases refusal and cleanup pass","nextEvidence":"retain model-only limit"},{"when":"failure","meaning":"candidate evidence rejected","nextEvidence":"preserve first failure"}],"proves":"offline model lifecycle","doesNotProve":"OpenStack APIs services backends instances or recovery","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0077-LAB-001","title":"Guided OpenStack request-path evidence model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no OpenStack authority","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic 51-case fixture"],"abortConditions":["root","credential","OpenStack or cloud endpoint","cluster Docker or libvirt context","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0077-openstack-control-data-plane-operations/support/lab"},
    {"id":"LES-0077-LAB-002","title":"Independent disposable OpenStack request recovery","mode":"independent","environment":"Reviewer-owned disposable OpenStack deployment or faithful local harness with synthetic data","timeMinutes":240,"privilege":"least privilege; reviewer owns hidden faults and stop authority","network":"isolated local only","changes":["one bounded synthetic request and resources","reviewer-controlled identity cell placement image network volume HA or upgrade defects"],"abortConditions":["production","public target","external cloud","real credential","customer data","unbounded load","unsafe database mutation","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore one authoritative disposable path and prove exact absence.","cleanupProof":"Reviewer proves every request record allocation image port attachment instance and temporary artifact absent or reconciled.","path":"drafts/LES-0077-openstack-control-data-plane-operations/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0077-INC-001","signal":"Server remains BUILD or appears in cell0.","firstThought":"API acceptance, cell ownership, scheduling, Placement and cell-local execution are separate.","safePath":"Bind request/server/cell identity and trace the first divergent state.","trap":"Reset state or delete records directly."},
    {"id":"LES-0077-INC-002","signal":"Server is ACTIVE but packets do not flow.","firstThought":"Nova status and Neutron binding do not prove effective dataplane or return path.","safePath":"Trace port binding, agent/controller, host flows, DHCP/metadata, policy and packets.","trap":"Reboot the guest repeatedly."},
    {"id":"LES-0077-INC-003","signal":"Volume attachment exists but the guest has no correct device.","firstThought":"Nova/Cinder records, backend connection, connector and guest device are distinct.","safePath":"Establish writer authority and reconcile supported service/backend state.","trap":"Force detach or edit databases while ownership is ambiguous."},
    {"id":"LES-0077-INC-004","signal":"One cell or controller dependency fails despite green API load balancers.","firstThought":"API availability can hide database, queue, scheduler, conductor, agent and capacity failure.","safePath":"Scope dependency failure, stop new work, preserve quorum and recover by service semantics.","trap":"Restart every controller simultaneously."},
    {"id":"LES-0077-INC-005","signal":"Mixed-version upgrade leaves duplicate or orphaned resources.","firstThought":"API RPC object schema online-migration and retry compatibility may have diverged.","safePath":"Stop rollout and retries, establish authority, recover user flow and reconcile through supported tools.","trap":"Finish the upgrade faster or delete unknown records."}
  ],
  "assessmentIds": ["ASM-0214", "ASM-0215", "ASM-0216"],
  "referenceIds": ["REF-0913", "REF-0914", "REF-0915", "REF-0916", "REF-0917", "REF-0918", "REF-0919", "REF-0920", "REF-0921", "REF-0922", "REF-0923", "REF-0924", "REF-0925", "REF-0926", "REF-0927"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a deterministic request-path model and local command inventory, not an OpenStack deployment.",
    "No package, credential, API, database, queue, agent, hypervisor, image, network, volume or instance action is performed.",
    "Latest OpenStack documentation can represent a development branch; exact deployed releases and compatibility remain unproved.",
    "OpenStack behavior depends on release, deployment tooling, drivers, plugins, backends, topology, policy and workload.",
    "Formal technical/security/instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# OpenStack operations: trace identity, compute, network, image, volume, and recovery paths
