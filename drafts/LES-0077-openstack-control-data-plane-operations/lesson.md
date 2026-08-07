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

## What you see and first thought

### The sentence that should slow you down

“The server is ACTIVE” sounds reassuring. Treat it as one service reporting one part of a much longer story.

Nova can report `ACTIVE` while the guest has no working route, cloud-init is failing, an attached volume is read-only, or the application cannot serve its user. A Neutron port can be bound while effective host flows are absent. A Glance image can have an active record while its bytes are unavailable. A Cinder attachment can exist while the storage session or guest device does not.

Your first thought should be:

> Which component made this claim, which state does it own, and what proves the user's operation across the remaining boundaries?

Do not restart every controller or directly edit a service database. Bind the report to a project, resource UUID, request lineage, cell, host and time window. Then find the first boundary where expected and observed state diverge.

### The ladder to remember

1. **User operation** — what did the person or workload attempt, and what would correct success look like?
2. **Identity and scope** — who is calling, for which project or system scope, with which roles and unexpired token?
3. **Discovery and transport** — which region, interface and endpoint did the catalog select; did DNS, TLS and connection establishment work?
4. **Service admission** — which microversion, policy, quota and validation decision applied?
5. **Control record** — which service database owns desired state and resource identity?
6. **Asynchronous coordination** — which scheduler, message, conductor, worker or agent should advance it?
7. **Backend realization** — did Placement, the hypervisor, image store, network dataplane or storage backend make intent real?
8. **Guest and application** — did the OS boot, initialize and make the application ready?
9. **User and data outcome** — can the intended user complete the operation, with correct data?
10. **Cleanup** — did retries or recovery leave duplicate allocations, ports, attachments or instances?

A green result at step 5 does not prove steps 6 through 10. A failed step 9 does not tell you which earlier boundary caused it.

### One concrete incident

A payment worker is rebuilt. The create call returns `202 Accepted`. Nova later reports `ACTIVE`. The load balancer check still fails.

A weak response is “Nova is healthy; reboot the VM.” A stronger investigation asks:

- Was the token scoped to the intended project?
- Did the client select the right region and endpoint interface?
- Which request ID and server UUID identify this attempt rather than a retry?
- Which cell and compute host own the server?
- Does Placement hold one valid allocation for its consumer?
- Did Glance serve the expected bytes and digest?
- Is the Neutron port bound to the actual host and realized in its dataplane?
- Did DHCP, metadata and cloud-init finish?
- Can the application reach dependencies and complete the real user operation?

That sequence converts “ACTIVE but broken” into a falsifiable investigation.

### The operating promise

OpenStack is cooperating services with separate authorities. Keystone owns identity assertions. Nova coordinates compute lifecycle. Placement owns provider inventory and allocations. Glance owns image metadata and store relationships. Neutron owns network intent and coordinates realization. Cinder owns block-storage lifecycle and attachment intent. Hypervisors, network controllers and storage backends own effective state.

The promise is not “every API is green.” It is: **an authorized user completes the intended operation on the intended resource, with correct data, within the agreed reliability boundary.**

### What this lesson proves

You will learn to trace an operation, assign state ownership, interpret evidence, diagnose partial completion, design availability and plan recovery. The guided lab is offline: it evaluates a finite synthetic path and makes no OpenStack call.

It does not prove that a real cloud is healthy. A production conclusion still requires the deployed release, topology, drivers, policy, backend behavior and observed user evidence. Reading completion is not operational mastery; representative reviewer-owned work remains required.

## Terms before commands

### Cloud, region, availability zone and failure domain

An OpenStack **cloud** is a collection of services under one operating and identity boundary. A **region** is a catalog-visible endpoint grouping, often a site or major partition. Choosing the wrong region can yield valid authentication against the wrong infrastructure.

An **availability zone** is a scheduling label. A **failure domain** is what really fails together: rack power, top-of-rack network, storage cluster, controller quorum or WAN path. Never assume the label proves the physical design.

### Control, data and management planes

The **control plane** accepts and coordinates intent: APIs, schedulers, databases, queues and controllers. The **data plane** carries useful workload traffic, storage I/O and guest execution. The **management plane** lets operators administer the cloud.

A responsive Neutron API is control-plane evidence; a bidirectional packet is dataplane evidence. Protect management authority from tenants and failed workloads.

### Project, domain, user, group and role

A **domain** namespaces projects, users and groups. A **project** is a resource and authorization boundary. A user or application credential identifies a caller. A group collects users. A role is an authorization attribute interpreted by each service policy.

“The token is valid” does not mean it is scoped to the intended project or permitted to perform a particular Nova, Neutron or Cinder action.

### Authentication, scope and authorization

**Authentication** establishes who presented acceptable credentials. **Scope** binds the token to a project, domain or system context. **Authorization** is the target service deciding whether that caller may perform the operation.

Debug in that order. A `401` commonly concerns authentication; `403` usually means the service understood but denied the caller. Preserve the response body, request ID and endpoint because exact behavior is policy and release dependent.

### Token, expiry, audit ID and service user

A Keystone **token** is an assertion with issue time, expiry, scope, roles and catalog context. An **audit ID** helps relate authentication chains. A **service user** lets one OpenStack service call another.

Never paste tokens into tickets or logs. Retain safe identifiers, expiry and scope—not the credential. A human call to Nova can work while Nova's service identity cannot use Neutron.

### Catalog, service type, endpoint, region and interface

The service catalog advertises endpoints selected by service type, region and interface such as public, internal or admin. Catalog success proves advertised discovery data, not DNS, certificate validation, routing or service readiness. A stale URL can be reachable yet lead to a retired control plane.

### Request ID, global request ID and retry lineage

A **request ID** identifies an API attempt. A **global request ID** can correlate service-to-service work. A resource UUID identifies an object; a request ID identifies an attempt.

Retries may create several attempts around one user action. Build lineage with timestamps, client retry behavior, request IDs and resulting resources. Do not assume the last visible UUID belongs to the first request.

### API microversion

A **microversion** selects behavior within an API family. It can alter fields or semantics without changing the endpoint URL. Record requested and negotiated versions. Two clients using different microversions are not equivalent tests.

### Acceptance, completion and reconciliation

Many operations return after admission, not useful completion. `202 Accepted` means work entered an asynchronous workflow. Later schedulers, queues, agents and backends must converge. **Reconciliation** compares desired and effective state and safely repairs divergence through supported service mechanisms.

### Desired, effective and user-observed state

**Desired state** is what the control record says should exist. **Effective state** is what a worker, host or backend realized. **User-observed state** is what the user can actually do.

For a port, desired state includes address, policy and binding. Effective state includes host interfaces and flows. User state is a bidirectional packet through the intended path.

### Nova cells v2, API DB, cell DB and cell0

Nova **cells v2** partitions compute workflow state. The **API database** contains global information and mappings. Each normal **cell database** contains cell-local instance state and uses cell-local messaging dependencies.

**cell0** records instances that could not be scheduled to a normal cell. It is not a compute host and does not run VMs.

### Nova API, scheduler, conductor and compute

**nova-api** applies API validation, policy and coordination. **nova-scheduler** selects eligible candidates. **nova-conductor** mediates database access and multi-step tasks. **nova-compute** manages instances on one compute host through a hypervisor driver.

A heartbeat shows a process reports alive. It does not prove that its dependencies or workload path work.

### Message broker, topic, queue and delivery

Services use RPC and notifications over a broker. Topics route work and queues hold it for consumers. Publish does not prove consumption; consumption does not prove backend success.

Useful evidence includes oldest-message age, depth, unacknowledged and redelivered messages, consumer count, RPC timeout and resource identity. Restarting every consumer destroys evidence and may replay harmful work.

### Placement provider, inventory, trait and aggregate

A Placement **resource provider** supplies resources. **Inventory** declares total, reserved and allocation-ratio values for resource classes. A **trait** describes a capability. An **aggregate** relates providers for shared capacity or policy.

Placement finds provider combinations satisfying requirements. It does not boot the guest.

### Candidate, allocation, consumer and generation

An **allocation candidate** is an eligible provider set. An **allocation** reserves resource accounting for a **consumer**, commonly a server UUID. Provider and consumer **generations** enable optimistic concurrency and detect stale writers.

An allocation proves admission accounting, not measured usage or successful spawn.

### Flavor, extra spec and request spec

A **flavor** describes requested compute shape. **Extra specs** add capability constraints. The **request spec** captures placement requirements including image properties, traits, aggregates and availability zone.

If no candidate exists, ask whether capacity is exhausted, reserved, fragmented, filtered or stale. Total free CPU is not proof that one provider satisfies the entire request.

### vm_state, task_state and power_state

Nova tracks broad lifecycle in **vm_state**, in-progress activity in **task_state**, and a hypervisor-facing view in **power_state**. These may temporarily disagree.

Treat their combination and transition history as evidence. Never directly edit database fields to make the display look consistent.

### Glance record, task, store and provenance

A Glance record owns image identity, owner, visibility, status and properties. Import/task state describes workflow. A **store** holds bytes. **Provenance** is trusted lineage: source, digest, signing, scanning and promotion.

An active record is insufficient. Prove access, store availability, size, digest and approved origin.

### Neutron network, subnet, port and segment

A network is a logical connectivity domain. A subnet defines addressing. A port is an attachment point with addresses, security policy and binding state. A segment relates logical intent to physical or overlay transport.

Use the port UUID across Nova, Neutron and host evidence; an IP alone may be reused.

### Port binding, VIF and realization

Port binding selects how and where a port attaches. Binding host should match the compute host; VIF details guide integration. Agents or controllers translate intent into bridges, tunnels, routes, NAT and filtering.

A bound record still needs controller, host-flow and packet evidence.

### DHCP, metadata, security group, router and floating IP

DHCP supplies guest network configuration. Metadata supplies instance initialization data. Security groups express traffic policy. Routers connect logical networks and may perform NAT. Floating IPs map reachable addressing to ports.

DHCP success does not prove metadata. An ingress rule does not prove the return path. Trace both directions.

### Cinder volume, attachment, connector and backend

A volume is block storage. A snapshot's consistency depends on workload and backend semantics. An attachment coordinates connection to a consumer. A connector describes host initiator data. The Cinder service schedules work to a configured backend.

The database owns control records; the backend owns durable blocks. An attachment record does not prove an export, host session or guest device.

### Writer authority, fencing and split brain

**Writer authority** identifies who may safely modify a resource. **Fencing** proves an old actor cannot keep writing before replacement. **Split brain** means multiple actors believe they have authority.

If an old compute host or storage path cannot be proven inactive, pause recovery. Convenience never outranks data safety.

### Quota, capacity, reserve and fragmentation

Quota limits what a project may request. Capacity is what infrastructure can supply. Reserve is headroom for growth, failure and movement. Fragmentation means total free resource exists but no eligible provider has the required combination.

Raising quota cannot repair physical capacity; aggregate free capacity does not prove placement feasibility.

### Evacuation, migration, rebuild, rescue and shelve

Evacuation recovers an instance after host failure, subject to storage and fencing. Migration moves or reschedules it. Rebuild replaces its root image. Rescue supplies a recovery environment. Shelve releases some resources while preserving a restorable server.

They are not interchangeable. Choose by user objective, data location, state authority and rollback boundary.

### Expand, migrate and contract

Safe database evolution often expands a backward-compatible schema, runs supported mixed versions, migrates existing data, and only then contracts obsolete compatibility.

“All packages upgraded” is not completion. Record service versions, API/RPC/object compatibility, schema state, online migration progress and user validation.

## Architecture map

### View 1: request and state owners

```text
[caller]
   | credentials + intended project + operation
   v
[Keystone] -- token: subject, scope, roles, expiry
   |
   v
[catalog] -- region + interface + endpoint
   |
   v
[Nova / Neutron / Glance / Cinder API]
   | policy + quota + microversion + request ID
   v
[service DB] <-> [message bus] <-> [scheduler / conductor / worker / agent]
                                           |
                                           v
                           [hypervisor / network / storage / image store]
                                           |
                                           v
                                  [guest] -> [application] -> [user]
```

Read left to right as a proof chain. A token is a bounded identity assertion. An API record proves admitted intent. A consumed message proves work reached a worker. Backend state proves realization. Only the final transaction proves the user promise.

### View 2: Nova build through cells and Placement

```text
Nova API
  |-- API DB: global state and instance mapping
  |-- request spec: flavor, image, network, AZ, traits
  |-- target cell selection
  |-- Placement: candidates -> allocation for server consumer
  v
scheduler decision
  v
cell message bus -> conductor -> nova-compute -> hypervisor spawn -> guest

unscheduled failure -> cell0 record, not a running host
```

This separates global lookup, capacity accounting and cell-local execution. Missing mapping, stale inventory, lost RPC and failed hypervisor spawn require different evidence.

### View 3: image, network and volume realization

```text
                         [Nova coordinates]
                         /       |        \
                        v        v         v
                 [Glance]    [Neutron]   [Cinder]
                 record      port        volume
                 access      binding     attachment
                 store       flow        backend export
                 bytes       packet      host connector
                        \       |        /
                         v      v       v
                         [hypervisor devices]
                                  |
                                  v
                               [guest]
```

Nova does not own image bytes, network flows or storage blocks merely because a server refers to them. Follow each UUID into the owning service and then its backend.

### View 4: desired record versus effective dataplane

```text
API record -> scheduling/binding -> message -> agent/controller -> host state
                                                               |
                                                               v
                                                     physical/virtual backend
                                                               |
                                                               v
                                                    packet, I/O, transaction

revision       selected host       delivery    acknowledgement   user proof
```

This applies to ports, attachments and compute spawn. Find the first arrow without evidence instead of jumping from the record to the outcome.

### View 5: cells and failure domains

```text
                  global entry and APIs
                /          |             \
          Keystone      API DB        Placement
                            |
                 instance/cell mappings
                    /               \
              Cell A                 Cell B
         DB + MQ + services     DB + MQ + services
          /      |      \       /      |      \
      compute  network storage compute network storage

shared DNS, time, certificates, image stores and management may span both
```

Cells can limit compute blast radius only if databases, queues, capacity and operations are actually isolated. Global dependencies can still stop every cell.

### View 6: upgrade and recovery state machine

```text
[inventory versions/topology]
            |
            v
[compatibility + backup/restore proof]
            |
            v
[expand schema] -> [control canary] -> [cell/worker rollout]
       ^                                      |
       |                                      v
[rollback gate] <- [stop criteria] <- [mixed-version validation]
                                              |
                                              v
                          [online migrations + reconciliation]
                                              |
                                              v
                         [user/data validation + retirement]
```

Rollback is not automatically available after every schema or data transition. Define the last reversible point before work starts.

### Read all six views together

The first view gives the universal proof chain. The second explains compute placement. The third preserves service ownership. The fourth separates intent from realization. The fifth reveals shared failures. The sixth controls change.

If an incident room has only topology, add a state-owner map. If it has only dashboards, add a user journey. If it has only records, add effective backend and cleanup paths.

## Request or state path

### 1. Define the operation

Write an actor, action, object and correctness condition: “Project P creates server S from approved image I, attaches port N and volume V, boots application A, and completes transaction T within the SLO.”

Record time, region, interface, client identity, requested microversion and retry behavior. This prevents debugging the wrong attempt or declaring infrastructure healthy while the application remains unusable.

### 2. Authenticate and establish scope

Validate subject or application identity, intended project/domain/system scope, roles, issue and expiry times, audit lineage and clock correctness. Do not expose the token itself.

Authentication answers who. Scope answers where authority applies. The target service still authorizes the action.

### 3. Select and reach the endpoint

The client resolves service type, region and interface from the catalog or cloud profile. DNS, routing, TLS trust, hostname validation, load balancing and connection establishment then have to work.

Catalog URL proves discovery only. Capture the selected endpoint and the exact transport layer at which a failure occurs.

### 4. Admit the Nova request

Nova API validates input, policy and quota, interprets the microversion and coordinates API-visible records. Preserve response status/body, request IDs, server UUID, flavor/image/network/volume/AZ intent, and retry information.

`202 Accepted` means the build may proceed. It does not mean a host was chosen.

### 5. Resolve image, network and volume prerequisites

Glance must expose an authorized image and retrievable bytes. Neutron must create or resolve suitable ports, addresses and policy. Cinder must expose usable volumes. Calls may use service identities and different endpoints.

Correlate the global request lineage. The user's Nova access does not prove Nova's service user can use Neutron or Cinder.

### 6. Create the request spec and choose a cell

Nova records resources, traits, aggregates, availability zone, image properties and scheduler inputs. Instance mappings connect global server identity to a cell.

If normal scheduling fails, cell0 can preserve API-visible failure state. Do not search compute hosts for cell0; determine why no normal cell and candidate completed.

### 7. Ask Placement for candidates

Placement evaluates inventories, usage, reservations, ratios, traits, aggregates and provider relationships. The scheduler combines candidates with Nova constraints and weights.

“No valid host” is an outcome. Compare the request spec with each narrowing decision. Quota may pass while capacity is fragmented; capacity may exist without a required trait; stale inventory may hide a valid host.

### 8. Claim resources

Nova and Placement establish generation-aware allocations for the server consumer. Concurrency checks prevent a stale writer from silently spending the same view of capacity.

The claim proves accounting at that moment, not spawn success or acceptable performance. After failure, reconcile allocations using supported workflows.

### 9. Deliver work into the cell

The build crosses cell messaging to conductor and compute. Connect request/server/cell IDs, message destination and timing, RPC version, queue age/redelivery, conductor transition, compute service and host.

A backlog can mean unavailable consumers, slow dependencies, poison messages or insufficient workers. Queue depth alone is not root cause.

### 10. Prepare the host

nova-compute coordinates image, network and storage preparation and validates effective host capability. Scheduler knowledge now meets physical reality.

CPU mismatch, local disk exhaustion, missing network realization, image-store failure or storage-login failure can invalidate a reasonable scheduling choice.

### 11. Spawn through the hypervisor

The driver asks the hypervisor to define and start the VM. Preserve host, instance identity, hypervisor result and first meaningful exception. Do not stop at a generic Nova `ERROR` if storage, libvirt or network emitted the causal failure.

Use a timeline across Nova and hypervisor state rather than forcing database fields to agree.

### 12. Boot and initialize the guest

Firmware and bootloader load the OS. The guest needs correct disks/NICs, addressing, metadata or config-drive access, DNS and time. Initialization may finish long after power-on.

Console, kernel boot, metadata reachability and cloud-init status answer different questions. Ping proves neither initialization nor application readiness.

### 13. Make the application useful

The application must start, bind the correct address, load configuration/secrets, reach dependencies and perform its business operation. Validate from the user's routing and trust position.

A TCP connection is not enough. Prefer a safe synthetic transaction that checks response semantics and a data invariant.

### 14. Change or recover

Resize, rebuild, migrate, evacuate, attach and detach reuse these boundaries with new authority risks. Record each request lineage and intended transition.

Before replacement after failure, prove the old writer is fenced. Afterward reconcile Placement allocations, Neutron bindings, Cinder attachments and backend artifacts.

### 15. Retire and prove absence

Deletion is asynchronous. API disappearance can coexist with an allocation, port, attachment, hypervisor domain or backend object.

Define what should be deleted, retained or detached. Prove authoritative records and effective artifacts absent or deliberately owned. Unknown residue consumes capacity and can expose data.

## Failure zoom

### Failure 1: valid token, wrong project

The token passes validation but is scoped elsewhere. A list can return a plausible empty set; a create may be denied or land in the wrong tenant. Compare intended project ID with token scope and resource owner. Never infer scope from the prompt.

### Failure 2: stale catalog endpoint

The advertised URL resolves and accepts TLS but belongs to an old region or control plane. Record service type, region, interface, URL and certificate identity. Correct catalog authority before retrying writes.

### Failure 3: duplicate create after timeout

The client times out after admission and retries without a safe idempotency strategy. Two server UUIDs appear. Stop retries, correlate request IDs and parameters, confirm user intent, then remove only the proven duplicate.

### Failure 4: cross-service policy denial

Nova permits an operation but Neutron, Glance or Cinder denies the delegated call. Preserve the global request lineage and exact denial. Do not grant broad roles globally to make one workflow pass.

### Failure 5: quota passes but no candidate exists

Entitlement is sufficient, but no provider satisfies the whole request. Compare flavor, traits and locality constraints with inventory and fragmentation. Raising quota cannot repair this.

### Failure 6: stale Placement inventory

A compute resource tracker is unhealthy or generation updates conflict. Placement no longer reflects the host. Check service freshness, provider generation, inventory and allocations; use supported audit or heal workflows.

### Failure 7: orphaned allocation

A server failed or disappeared while an allocation remains. First prove no in-progress operation owns it. Reconcile through Nova/Placement semantics and validate provider usage and server state together.

### Failure 8: missing instance mapping

An API-visible UUID cannot be mapped to a cell. This is global ownership failure, not initially a compute problem. Preserve API DB and cell evidence and use release-supported discovery or reconciliation.

### Failure 9: server in cell0

Cell0 records an unscheduled instance. Inspect request spec, candidates, service availability and scheduler decisions. There is no cell0 compute host to reboot.

### Failure 10: cell queue stalls

Global APIs remain green while one cell accumulates old work. Scope the cell and operation class. Inspect quorum, consumers, oldest age, redelivery and dependency latency. Stop admission if it worsens recovery.

### Failure 11: RPC incompatibility during upgrade

A new caller sends an object/RPC version an older worker cannot consume. Capture versions, pins and first serialization error. Stop at the rollout gate; upgrading everything faster is not diagnosis.

### Failure 12: active image without bytes

Metadata lookup works but the selected store cannot return the object. Verify store identity, authorization, object presence, size and digest. Restore through an approved image workflow rather than replacing unknown bytes in place.

### Failure 13: available but untrusted image

The digest, owner, signer or promotion evidence is wrong. Quarantine use, retain audit evidence and promote a known artifact under controlled provenance. Availability cannot overrule integrity.

### Failure 14: bound port without dataplane

Neutron records a host binding while agent/controller or host flows are absent. Compare binding host, mechanism, revision, controller delivery, host state and packets. Guest reboot does not program a missing host dataplane.

### Failure 15: DHCP works, metadata fails

The guest receives an address but cannot obtain instance metadata, so initialization fails. Trace proxy/controller, namespace or route, policy and metadata service. DHCP proves only one initialization dependency.

### Failure 16: one-way security or routing

The SYN reaches the guest, but reply routing, egress policy, conntrack or NAT fails. Capture both directions at consecutive boundaries. One ingress rule does not prove a session.

### Failure 17: floating IP without reachability

The mapping exists while router scheduling, NAT realization, gateway or upstream return routing is absent. Trace external client to floating address to fixed port and back.

### Failure 18: attachment without backend connection

Cinder records an attachment but target export, host login, multipath device or guest device is absent. Bind volume and attachment UUIDs to service host, backend, connector and compute host.

### Failure 19: two possible volume writers

Evacuation starts while the old host is unreachable but unfenced. A replacement risks corruption. Pause, fence at power/fabric/storage authority, then recover and validate filesystem and application consistency.

### Failure 20: ACTIVE server, unready guest

Hypervisor spawn completed, but boot, filesystem, networking or cloud-init failed. Use console and initialization evidence. Nova status is not the guest contract.

### Failure 21: ready guest, failed application

SSH and init work while configuration, secret, dependency or data migration fails. Hand off with the infrastructure timeline intact and validate the real user journey after repair.

### Failure 22: green API, broken dependency

One API replica answers while database quorum, queue delivery, worker capacity or downstream service is degraded. Health checks must include critical dependencies without creating cascades.

### Failure 23: failed cell, no survivor capacity

Isolation contains failure, but remaining cells cannot accept priority workload. Reserve capacity under hard constraints and declare admission/degradation policy before failure.

### Failure 24: incomplete online migrations

New binaries run, but old-format records trigger fallback or fail after compatibility retirement. Migration counts and errors are upgrade gates, not housekeeping.

### Failure 25: recovered user, orphaned resources

The user path returns while duplicate port, allocation, attachment or backend object remains. Run service-owned reconciliation and exact cleanup proof. Unfinished cleanup becomes capacity or security debt.

## Internals and state ownership

### Keystone owns assertions; services own policy

Keystone validates credentials, issues scoped tokens and publishes catalog data. Each target service interprets roles under its own policy. Keystone success cannot prove a Nova or Cinder action is allowed.

### The catalog owns advertised discovery

Catalog records own advertised region/interface URLs. DNS, TLS, load balancers and service processes own reachability. Keep discovery evidence separate from transport evidence.

### Nova API state owns global compute intent

API-visible records and mappings identify the server and cell. They do not own every cell transition or hypervisor object. Missing mapping breaks the route to the actual owner.

### A cell owns local compute workflow

Cell database and messaging contain much instance lifecycle state. A cell can fail while global APIs answer. Track health, backlog, capacity and recovery per cell.

### The request spec owns placement intent

Flavor, image properties, traits, aggregates and zone constraints form scheduler input. Retain this evidence so “no valid host” becomes explainable candidate elimination.

### Placement owns declared inventory and allocation

Placement is authoritative for provider inventory and consumer allocation. The host owns physical reality. Resource tracking reconciles them. Neither view alone is full capacity truth.

### Scheduler owns its decision

The scheduler chooses among candidates using its current evidence. It cannot guarantee the host remains healthy or that an unmodeled dependency works. Preserve selection reasons and validate spawn separately.

### Conductor owns coordinated transitions

Conductor mediates database access and multi-step orchestration, reducing compute privilege. Its task trail identifies failed steps; it does not own external backends.

### nova-compute owns host coordination

Compute connects Nova intent to hypervisor, network and storage integration. A heartbeat proves reporting, not successful spawn, packets or I/O.

### The hypervisor owns machine execution

The hypervisor knows whether the VM process/domain exists and its power state. It does not know whether the guest booted or the application works.

### Glance owns image identity

Glance owns metadata, access and lifecycle; the store owns bytes and durability; the image pipeline owns trusted provenance. Bind all three by UUID and digest.

### Neutron owns intent; mechanisms own flows

Neutron owns networks, ports, routers, addresses and policy. Agents/controllers and host/network infrastructure realize them. Packet truth belongs to the actual path.

### Cinder owns lifecycle; backend owns blocks

Cinder coordinates volume and attachment records. The backend owns blocks and durability; the connector and guest own later visibility. Recovery must respect all authorities.

### The broker owns delivery state

The broker can prove queued, delivered, unacknowledged or redelivered work. It cannot prove backend success. Correlate broker timing with task and backend state.

### Databases own durable control records

Direct mutation bypasses invariants, notifications, generations and cleanup. SQL access is privileged and release-specific. Repair with supported APIs and administrative tooling.

### HA owns failover authority

Database/broker quorum, cluster managers, load balancers and fencing determine which replicas serve or write. A running process is insufficient when quorum is lost.

### Guest and application own readiness

The guest owns boot and local initialization. The application owns configuration, dependencies and business semantics. Hypervisor power and ping cannot replace their evidence.

### User journey owns the verdict

A representative safe operation measured against the SLI is final evidence. It should validate response meaning and, where relevant, data invariants.

### Incident command owns coordination

The incident commander maintains scope, decisions, communication and stop conditions. State owners supply technical evidence. This prevents the loudest hypothesis from becoming an unsupported repair.

## Evidence table

### Build an evidence bundle, not a screenshot

| Claim | Weak evidence | Stronger evidence | Still does not prove |
|---|---|---|---|
| Caller is authorized | login succeeded | token subject, intended scope, roles, expiry plus service policy decision | endpoint or backend readiness |
| Correct service was called | catalog contains Nova | selected region/interface URL, DNS/TLS result, request ID | downstream work |
| Create was accepted | CLI printed a UUID | response, microversion, request/global IDs, retry lineage and server UUID | scheduling or spawn |
| Server belongs to a cell | server appears in list | instance mapping, cell UUID and matching cell record | queue or compute health |
| Capacity exists | aggregate dashboard has free vCPU | request spec plus eligible Placement candidates, current generations and reserve | spawn performance |
| Capacity is claimed | allocation exists | consumer/provider allocations match selected host and request | running VM |
| RPC advanced | queue is short | correlated publish, delivery, consumer and conductor/compute transition | backend success |
| Image is usable | status is active | access, store object, expected size/digest and provenance | guest boot |
| Port is ready | port says active/bound | correct host binding, controller/agent acknowledgement, host flows | end-to-end packets |
| Network works | guest responds to ping | bidirectional trace through intended route/security/NAT path | application transaction |
| Volume is attached | attachment record exists | backend export, connector, host device, guest device and writer authority | filesystem/app consistency |
| Server is running | vm_state is ACTIVE | matching hypervisor instance and expected power state | guest readiness |
| Guest is ready | SSH works | boot/init evidence, local service and dependency checks | external user success |
| Service is healthy | API health returns 200 | replica, DB, MQ, worker, downstream and saturation evidence | all user journeys |
| Upgrade is complete | packages are new | supported versions, schema and online migration completion, reconciliation, user/data validation | delayed failure absence |
| Recovery is safe | replacement started | old writer fenced, authoritative state recovered, data verified, residue absent | future resilience |

### Evidence identity

Every artifact should carry a safe join key: request/global request ID, project ID, server/image/port/volume/attachment UUID, cell UUID, host, service and timestamp. Without join keys, logs from simultaneous operations can form a convincing but false story.

### Evidence timing

Record clocks and time sources before aligning distributed events. Use a window wide enough for skew and queue delay, but narrow enough to avoid unrelated traffic. State when an observation was taken; OpenStack is asynchronous and a screenshot ages immediately.

### Evidence limitations

For each command or dashboard, write **proves** and **does not prove**. This discipline blocks accidental leaps from component status to user success. Redact credentials and sensitive tenant content while preserving identifiers needed for correlation.

## Command decoders

The guided commands below operate only on synthetic local state. They are intentionally not a recipe for touching a cloud.

### Command 1: prove the shell is guarded

Run `bash lab.sh doctor` as a normal Ubuntu user from the lab directory. It checks the lab source and rejects root, cloud credentials, endpoint authority, Docker/libvirt/Kubernetes context, unsafe paths and foreign state.

`doctor=pass` proves the local guard preconditions. It does not authenticate to OpenStack. If a named guard fails, remove the unsafe context; never bypass it.

### Command 2: inventory local tools without invoking them

Run `bash lab.sh inventory-tools`. It reports OS architecture and whether relevant command names are present, but does not execute discovered clients.

Presence of `openstack` or another binary proves only command discovery. It says nothing about configuration, credentials, endpoints or service health.

### Command 3: initialize bounded synthetic state

Run `bash lab.sh setup`. It copies one reviewed fixture into a UID-scoped directory beneath `/tmp` after owner, symlink, sentinel and inventory checks.

`setup=pass` proves fixture initialization. It creates no project, image, network, volume or server. Cleanup is `bash lab.sh cleanup`.

### Command 4: confirm fixture identity

Run `bash lab.sh status` after setup. Expected output reports 51 cases. A different count means drift; stop instead of accepting an unknown exercise.

Count proves only that the intended finite fixture is active. It is not a coverage claim about every OpenStack failure.

### Command 5: inspect the baseline claims

Run `bash lab.sh show baseline`. Read the merged JSON before evaluating it. Identify the caller, token, catalog, API, cell, Placement, compute, image, network, volume, guest, application and cleanup assertions.

Inspectable input prevents a green model result from becoming magic. Synthetic claims are not observations of this workstation or a cloud.

### Command 6: evaluate the all-pass baseline

Run `bash lab.sh evaluate baseline`. Expected final classification is `boundary=operable-within-model`.

That phrase is deliberately bounded. It means all fifty encoded gates accepted the provided fixture. It does not say OpenStack is operable.

### Command 7: valid token, wrong project

Run `bash lab.sh evaluate token-wrong-project`. Expected classification is `boundary=token-scope`.

The lesson is memorable: validity is not intended authority. Next evidence in a real incident would be safe token scope, intended project ID, roles and service policy—not the token secret.

### Command 8: missing cell mapping

Run `bash lab.sh evaluate instance-cell-mapping-missing`. Expected classification is `boundary=cell-mapping`.

This teaches that global API identity must resolve to cell ownership before host troubleshooting makes sense.

### Command 9: bound port, absent dataplane

Run `bash lab.sh evaluate bound-port-no-dataplane`. Expected result is `boundary=dataplane-realization`.

Port binding is desired/coordinated state. Next evidence is mechanism-specific controller/agent, host interface/flow and bidirectional packet state.

### Command 10: Cinder backend unavailable

Run `bash lab.sh evaluate cinder-backend-down`. Expected result is `boundary=volume-backend`.

The volume record and attachment intent cannot overrule the backend. Next establish service host, backend object, connector and writer authority.

### Command 11: guest up, application down

Run `bash lab.sh evaluate guest-up-application-down`. Expected result is `boundary=application-readiness`.

Guest reachability is infrastructure evidence, not business success. Next inspect process, config, secrets, dependencies, data and external user operation.

### Command 12: verify decisions and cleanup

From absent state run `bash verify.sh`. Expected summary is `verify=pass cases=51 refusal=true cleanup=true service_calls=none`.

The verifier checks every finite case, refusal behavior and exact cleanup. It cannot prove a package, API, database, queue, agent, hypervisor or recovery procedure.

### Real-runtime commands require an authority plan

In a real disposable cloud, the OpenStack client can inspect token, catalog, server, hypervisor-facing status, port, volume, allocation and service data. Exact subcommands and fields vary by client and release. Before running anything:

1. identify cloud profile, region, interface and project;
2. classify the operation as read-only, bounded mutation or dangerous;
3. ensure output will not expose tokens, secrets, image locations or tenant data;
4. record request/resource IDs and time;
5. prefer supported APIs and administrative tools;
6. define abort, rollback and cleanup;
7. validate syntax against the deployed client's help and release documentation.

Never copy a production database repair from a generic lesson. Database schemas and invariants are service- and release-specific.

## Decision path

### Start with the failed user promise

Write the failed operation and correctness condition. Ask whether the failure affects one attempt, one resource, one project, one cell, one region or the whole cloud. Freeze uncontrolled retries if they can create duplicates.

### Branch 1: identity or discovery

If authentication failed, verify credential mechanism, clock, token expiry and identity service reachability without exposing secrets. If authentication succeeded, compare intended and actual scope, roles and target-service policy.

If the endpoint is wrong or unreachable, separate catalog selection, DNS, TCP, TLS, load balancer and service response. Do not diagnose Nova scheduling before the request reaches Nova.

### Branch 2: admission

Bind response, microversion, request ID and resource UUID. A synchronous denial belongs to validation, policy or quota evidence. `202` moves the investigation into asynchronous state; it is not resolution.

### Branch 3: global-to-cell ownership

Resolve server UUID to instance mapping and cell. Cell0 points to unscheduled failure. Missing mapping means global ownership must be restored through supported release procedures before ordinary cell/host diagnosis.

### Branch 4: placement

Compare request spec with candidates, inventories, traits, aggregates, generation and allocation. Distinguish quota, capacity, fragmentation, constraints and stale resource tracking.

### Branch 5: cell execution

Trace publish, queue, conductor, compute and task transitions. If backlog grows, scope impact and stop admissions when appropriate. Preserve the first exception rather than restarting every service.

### Branch 6: service-owned resources

For image, network and storage, leave Nova's summary and inspect the owning service:

- image record, access, task, store bytes, digest and provenance;
- port revision, binding, controller/agent, host flows and packet path;
- volume, attachment, service/backend, connector, device and writer authority.

### Branch 7: hypervisor, guest and app

Match server to the actual hypervisor object. Then move separately through guest boot, initialization, local application, dependencies and external user transaction.

### Branch 8: safe recovery

Establish authoritative state and writer authority. Define whether to wait, retry, reconcile, rebuild, migrate, evacuate or restore. Fence before replacement when the old actor might write.

### Branch 9: close and prevent

Prove user/data recovery, absence of duplicates and monitoring normalization. Record cause, contributing conditions, detection gap, safe corrective actions and owners. A workaround without reconciliation leaves the incident open.

### Compact operator flow

```text
user failure
  -> intended identity/scope?
  -> correct endpoint and transport?
  -> API admitted with which request/resource IDs?
  -> mapped to which cell?
  -> eligible candidate and valid allocation?
  -> message, conductor and compute advanced?
  -> Glance/Neutron/Cinder effective state?
  -> hypervisor then guest then app?
  -> user and data correct?
  -> authority safe and residue absent?
```

## Guided Ubuntu lab

### Lab contract

This lab teaches decision order, not OpenStack administration. Run it in Ubuntu 24.04 as a normal user from:

```text
drafts/LES-0077-openstack-control-data-plane-operations/support/lab
```

Requirements are Bash and Python 3. Network is unnecessary. Root, exported cloud authority, Docker/Kubernetes/libvirt control context, symlinks, wrong ownership and unknown state are refused. The only mutation is a UID-scoped temporary fixture directory.

### Step 1: read safety and model files

Read `README.md`, `lab.sh`, `verify.sh`, `model.py` and `fixtures/cases.json`. Confirm the script uses a sentinel and exact allowlist. Do not execute a lab whose cleanup target you cannot explain.

Expected understanding: the fixture contains one baseline and fifty isolated failures ordered along the request path. The Python program evaluates predicates; it does not emulate OpenStack services.

### Step 2: prove the boundary

Run:

```bash
bash lab.sh doctor
bash lab.sh inventory-tools
```

Expected branches include `doctor=pass` and `inventory=observed`. Explain aloud: “The first result proves guard prerequisites. The second reports command presence without invocation. Neither proves cloud access.”

Abort if a guard reports credentials, endpoint, root or unsafe state. Clear the context rather than weakening the script.

### Step 3: create and inspect the fixture

Run:

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
```

Expected state reports 51 cases. In the JSON, locate claims for identity, catalog, request, mapping, Placement, queue, compute, image, network, volume, guest, application, user/data and cleanup.

Before continuing, predict which owner supplies each claim. This turns field names into an architecture map.

### Step 4: prove the baseline is finite

Run:

```bash
bash lab.sh evaluate baseline
```

Expected classification: `boundary=operable-within-model`. Write two sentences:

- It proves all encoded predicates accept this synthetic input.
- It does not prove any OpenStack endpoint, service, backend or user operation.

If you cannot state both, the lab has taught false confidence.

### Step 5: change one boundary at a time

Run the four required comparisons:

```bash
bash lab.sh evaluate token-wrong-project
bash lab.sh evaluate instance-cell-mapping-missing
bash lab.sh evaluate bound-port-no-dataplane
bash lab.sh evaluate cinder-backend-down
```

Expected boundaries are token scope, cell mapping, dataplane realization and volume backend. For each, write:

1. the user-visible symptom that might result;
2. the state owner;
3. the next safe evidence;
4. one tempting action that would be unsafe or irrelevant.

Example: for bound port/no dataplane, a guest reboot is irrelevant because host/controller realization is the first failed gate.

### Step 6: cross the infrastructure-to-application boundary

Run:

```bash
bash lab.sh evaluate guest-up-application-down
```

Expected result is `boundary=application-readiness`. Draw a short path from external client through network, guest listener, application dependencies and data result. Mark which earlier checks can be green while the transaction fails.

### Step 7: explore without creating a command dump

Use `bash lab.sh list` if the script documents it, or inspect the fixture directly. Select at least six additional failures spanning:

- identity/catalog;
- Placement/cell;
- image;
- network;
- volume/writer authority;
- HA or upgrade.

Predict the first failing boundary before evaluation. If your prediction is wrong, update the mental model rather than memorizing the answer.

### Step 8: verify all cases and cleanup

Return to absent state as documented, then run:

```bash
bash verify.sh
```

Expected summary:

```text
verify=pass cases=51 refusal=true cleanup=true service_calls=none
```

The verifier should leave no UID-scoped lab root. If it fails, preserve the first error. Do not manually delete unknown paths; use the exact documented cleanup after identifying ownership.

### Independent lab boundary

`LES-0077-LAB-002` belongs only in a reviewer-owned disposable OpenStack deployment or faithful isolated harness. The reviewer controls hidden faults, credentials, stop authority and cleanup verification. Production, public clouds, customer data, unsafe database mutation and ambiguous writer authority are prohibited.

The learner must recover one synthetic request across identity, cell/Placement, image, network, storage and user outcome, then prove no residual records or backends. The reviewer—not this manuscript—decides the hidden failure.

## Production transfer

### Build an identity operating model

Inventory human, automation and service identities; supported credential methods; project/domain/system scopes; role mappings; token lifetime; break-glass process and audit retention. Separate authentication failures from policy denials.

Rotate secrets without simultaneous outage. Avoid long-lived user passwords in scripts. Test service-to-service authorization because an interactive administrator path can hide broken service identities.

### Treat the catalog as production configuration

Catalog entries require change review, region/interface ownership, DNS and certificate dependencies, synthetic reachability and rollback. A duplicate or stale endpoint can misroute only certain clients, making incidents appear random.

### Operate cells as explicit units

For every cell maintain DB/MQ endpoints, service versions, capacity, failure domain, owner, health, backup/restore and isolation procedure. Monitor mapping failures and cell0 growth. Know how to disable new scheduling into a damaged cell without losing read visibility.

### Engineer database availability by semantics

API DB and each cell DB need quorum/writer design, replication-lag objectives, connection-pool limits, backups and restore tests. A load balancer cannot repair split brain or schema incompatibility.

Back up control databases consistently with required secrets/config and document cross-service consistency limits. Restoration success is demonstrated by rebuilding a disposable control path and validating users and data.

### Engineer messaging for delivery, not merely uptime

Track quorum, partition state, queue depth, oldest age, unacknowledged work, redelivery, poison messages and consumer saturation. Protect broker capacity from notification storms. Define whether a message can safely replay and how duplicate effects are detected.

### Keep Placement reconcilable

Monitor provider freshness, generation conflicts, inventory changes, allocation ratios and orphan allocations. Review ratios as risk decisions, not free capacity. Periodically compare allocations with authoritative Nova consumers using supported tools.

### Make scheduling explainable

Capture request specs and exclusion reasons with bounded retention. Maintain a small vocabulary for no-candidate causes: entitlement, constraint, fragmentation, stale inventory, service availability and policy. Capacity dashboards should answer “can the next important shape fit after a declared failure?”

### Build an image supply chain

Images need source ownership, reproducible build, package provenance, vulnerability handling, signing or digest controls, promotion, access policy, store replication and retirement. Test boot and initialization before promotion.

Do not mutate a trusted image identity with unrelated bytes. Create a new immutable version and retain lineage.

### Validate network intent and effective state

Monitor Neutron API and DB, controller/agent health, revision lag, binding failure, DHCP/metadata, routing/NAT, security policy and real packet journeys. Tag every view with network/port/router UUID and host.

Choose probes that cross representative tenant paths without bypassing security controls. Prevent high-cardinality labels from overwhelming observability systems.

### Operate block storage around writer authority

Track Cinder service health, backend capacity/latency/errors, attachments, connector failures, multipath state and orphan backend objects. Document driver-specific failover and replication semantics.

Recovery runbooks must say who owns the volume, how an old writer is fenced, how a new connection is established, and how application consistency is verified.

### Design capacity for failure and movement

Capacity is multidimensional: CPU, RAM, local/remote disk, IOPS, bandwidth, IPs, ports, image-cache pressure, DB/MQ connections and operator throughput. Include hard traits and locality.

For each failure domain calculate survivor capacity after the largest declared failure plus maintenance and workload growth. Reserve movement headroom for evacuation and upgrades. If the reserve is unaffordable, define priority admission and graceful degradation.

### Make incidents correlation-first

Standardize a safe evidence bundle: user operation, scope, region, request IDs, resource UUIDs, cell/host, state timeline, first exception, dependency health, action log, user/data validation and cleanup.

Incident communication should state facts, hypotheses and decisions separately. “Nova is down” is not a scope statement; “new builds in Cell B fail after scheduling, existing guests continue, Cell A is unaffected” is.

### Plan evacuation before host failure

Classify root disk and volume locations, network dependencies, shared-storage failure, fencing mechanism and eligible destinations. Test evacuation in a disposable failure domain. Never start a possible second writer because a deadline feels urgent.

### Run upgrades as controlled experiments

Inventory release and deployment-tool compatibility. Prove backups and restore. Expand schemas according to supported procedure, canary a small control/worker slice, validate mixed-version RPC/object/API behavior, roll cells in bounded batches, complete online migrations and reconcile.

Stop on unexplained duplicate resources, serialization errors, migration backlog growth, user SLI regression or loss of rollback confidence. Completion includes user/data validation and retirement of obsolete compatibility.

### Recover through service semantics

Prefer supported APIs, service administrative commands and documented reconciliation. Direct DB edits can bypass generations, notifications, allocations and cleanup. When vendor/project support requires a database action, treat it as a reviewed, release-specific exception with backups, exact scope, dual control and validation.

### Close with cleanup and learning

After restoration, prove no duplicate server, image, port, allocation, attachment, backend export or credential remains. Convert detection, design and runbook gaps into owned work with deadlines. Test the prevention, not just the workaround.

## Reliability, security, observability, capacity, and cost

### Reliability: define user journeys and SLOs

Separate read/list, create, attach, boot, network-connect, migrate and delete journeys. Availability of one API does not imply success of asynchronous operations. Measure completion latency and correctness from admission to user outcome.

Use error budgets to decide change pace and reliability investment. Do not hide failed creates by counting only API responses.

### Reliability: isolate and degrade deliberately

Cells, regions and backend clusters can constrain blast radius, but shared identity, catalog, DNS, time, images or management may defeat isolation. Draw dependency failure domains and test loss.

Define which operations stop first under pressure. Preserving existing guest data may outrank accepting new builds.

### Security: least privilege and credential hygiene

Use scoped service identities, short-lived credentials where supported, protected secret distribution and audited break glass. Restrict management/API networks and administrative database/broker access. Redact tokens, image locations and tenant data from ordinary evidence.

### Security: images, metadata and tenant isolation

Treat images as supply-chain artifacts. Protect metadata because it can expose instance configuration or credentials. Validate Neutron isolation, anti-spoofing and policy behavior for the deployed backend. Sanitize storage before reuse according to backend guarantees.

### Security: recovery is an attack surface

Emergency role grants, disabled policy, unfenced restart and hand-edited records can turn an outage into a breach. Recovery actions need identity, scope, approval, logging and expiry. Remove temporary access during closure.

### Observability: correlate, then aggregate

Carry request/global request IDs and resource UUIDs across service logs where supported. Centralize with time synchronization and retention appropriate to incident and privacy requirements. Dashboards should link user symptoms to cells, queues, providers and backends.

Avoid unbounded project/resource labels in metrics. Keep high-cardinality identity in logs/traces or carefully controlled exemplars.

### Observability: alert on action

Useful alerts identify a user promise, scope and safe first evidence. Examples include cell0 growth, oldest RPC age, provider update staleness, port binding failure, image-store error, attachment failure and synthetic transaction breach.

Page on conditions requiring human action. Ticket sustained capacity risk; dashboard diagnostic detail. Test routing and runbooks.

### Capacity: calculate eligibility, not totals

Model common and critical flavors, traits, NUMA/PCI/huge-page constraints, storage/network limits and failure domains. Report how many additional instances of each shape fit before and after a declared failure.

Overcommit ratios trade utilization for contention risk. Tie them to measured workloads, saturation signals and SLOs.

### Cost: follow cost per useful outcome

Cost includes idle failure reserve, duplicate/orphan resources, image copies, storage snapshots, egress, observability volume, licenses, power and operator time. Cheap capacity that cannot satisfy constraints has little value.

Remove proven orphans and stale images under policy. Do not sacrifice restore tests, headroom or telemetry merely to lower a dashboard number.

### Performance: find the queue

Latency often accumulates in DB connection pools, broker queues, scheduler candidate evaluation, image transfer, storage attach, network programming, guest initialization or application dependency. Measure each stage with a common request lineage.

Load tests must be bounded and representative. A create storm can exhaust control-plane workers or backends and is never appropriate against production without explicit authority and safeguards.

### The balanced design review

For every major design, ask:

- What user operation and SLO does it support?
- Which identity and state owner crosses each boundary?
- What fails together and what capacity survives?
- How is effective state observed?
- How is writer authority protected?
- What is the upgrade and rollback point?
- How is recovery tested and residue removed?
- Which cost grows with tenants, resources and telemetry?

## Traps and prevention

### Trap: treating ACTIVE as end-to-end success

**Why it fails:** Nova reports compute lifecycle, not network, initialization, application or data correctness.
**Prevention:** require guest, application and user-journey gates after infrastructure state.

### Trap: treating a valid token as correct authority

**Why it fails:** scope, roles and target-service policy can differ from intent.
**Prevention:** bind caller, project/domain/system scope, roles and policy decision to the request.

### Trap: assuming the catalog endpoint works

**Why it fails:** discovery can be stale while DNS, TLS or service routing fails.
**Prevention:** record selected region/interface URL and validate each transport layer.

### Trap: blind retries after timeout

**Why it fails:** the original request may have been admitted, creating duplicates.
**Prevention:** define client retry/idempotency behavior and search by request lineage before another mutation.

### Trap: increasing quota for no-valid-host

**Why it fails:** quota is entitlement; Placement candidates depend on eligible capacity and constraints.
**Prevention:** compare request spec with provider inventory, traits, aggregates and fragmentation.

### Trap: searching hosts for cell0

**Why it fails:** cell0 represents unscheduled instances.
**Prevention:** inspect scheduler/Placement and the failure that prevented selection of a normal cell.

### Trap: deleting allocations by hand

**Why it fails:** an in-progress operation may own them, and direct mutation bypasses generations and service invariants.
**Prevention:** establish consumer authority and use supported reconciliation.

### Trap: believing a bound port proves connectivity

**Why it fails:** controller delivery, host realization, routing, policy or return traffic can fail.
**Prevention:** trace revision to controller/agent to host flows to bidirectional packets.

### Trap: believing attachment means guest device

**Why it fails:** backend export, connector, host session and guest presentation are separate.
**Prevention:** trace the volume/attachment UUID through every owner and establish writer authority.

### Trap: restarting all controllers

**Why it fails:** simultaneous restart increases blast radius, destroys evidence and may replay work.
**Prevention:** isolate the failed dependency, canary one safe change and retain rollback.

### Trap: recovering before fencing

**Why it fails:** an unreachable old host can still write.
**Prevention:** prove power, fabric or storage fencing before replacement.

### Trap: calling package rollout an upgrade

**Why it fails:** schemas, online migrations, RPC/object compatibility and orphan state may remain.
**Prevention:** use explicit mixed-version, migration, reconciliation and user gates.

### Trap: declaring restoration before cleanup

**Why it fails:** residual ports, allocations, attachments and backend objects consume capacity or expose data.
**Prevention:** make exact absence part of the recovery definition.

### Trap: copying generic administrative commands

**Why it fails:** releases, drivers, policies and deployment tooling differ.
**Prevention:** verify deployed versions and command help; test in a disposable representative environment.

## Memory card and retrieval

### The ten-line card

1. Start with the user's operation, not the loudest service.
2. Token validity is not intended scope or authorization.
3. Catalog discovery is not endpoint reachability.
4. API acceptance is not asynchronous completion.
5. API DB, cell DB, Placement and hypervisor own different truths.
6. An allocation is accounting; a VM is execution.
7. A bound port is not a packet; an attachment is not a device.
8. ACTIVE is not guest, application or user readiness.
9. Fence before moving writer authority.
10. Recovery ends after user/data proof and exact cleanup.

### The resource join keys

Remember: **project, request, server, cell, host, image, port, volume, attachment, time**. Add provider/consumer generation and global request ID when available.

### The ninety-second incident opening

State:

- failed user operation and correctness condition;
- affected project/cell/region and start time;
- request/resource identities;
- last proven boundary and first divergent boundary;
- current user/data risk;
- actions stopped, especially retries or writers;
- next safe evidence and owner.

### Retrieval drill

Close the lesson and redraw the request path. Explain why these pairs differ:

- authentication versus authorization;
- quota versus capacity;
- API DB versus cell DB;
- candidate versus allocation;
- image record versus bytes;
- port binding versus packet;
- attachment versus device;
- power state versus application readiness;
- replication versus recovery;
- restart versus fencing.

Reopen only after attempting. Retrieval builds durable memory better than rereading.

## Complete answers

### Question 1: Why can a server be ACTIVE while unavailable?

Nova `ACTIVE` is a compute-lifecycle claim: spawn progressed and Nova believes the instance is running. It does not prove guest boot completion, DHCP/metadata, Neutron dataplane, volume correctness, application dependencies or external routing.

A strong investigation binds server UUID to cell and host, checks matching hypervisor state, then walks guest console/init, port realization and packets, storage devices, application readiness and a user transaction. It stops at the first divergent boundary rather than rebooting blindly.

### Question 2: What is the practical difference between authentication and authorization?

Authentication establishes caller identity using acceptable credentials. Keystone scope binds the token to a project, domain or system context. Authorization is the target service applying policy to the requested action.

A token can be valid and still be wrong for the intended project or denied by Cinder. Evidence must include safe token identity/scope/roles plus the target service's policy outcome. Giving a broad admin role is not diagnosis and violates least privilege.

### Question 3: What does the service catalog prove?

It proves which endpoint records Keystone advertised for a service type, region and interface at that time. It does not prove DNS, routing, TLS validity, load-balancer backend health, service identity or correct deployment version.

Record the selected URL and test the transport layers with an authorized safe request. If an endpoint is stale, correct catalog configuration through controlled change and verify affected client interfaces.

### Question 4: Why is 202 Accepted not success?

It says the API admitted asynchronous work. Scheduling, messaging, host preparation, backend realization, guest boot and application readiness remain.

Preserve request/resource IDs, observe state transitions and define a terminal correctness condition. Clients need bounded polling, timeout and retry semantics that avoid duplicate creates.

### Question 5: Explain API DB, cell DB and cell0.

The API DB carries global/request-visible information and mappings used to locate cell-owned compute state. A normal cell DB carries instance workflow state for its cell and is coupled with cell-local messaging/services. Cell0 holds instances that failed before scheduling to a normal cell.

Missing mapping means Nova cannot locate ownership. Cell0 means investigate scheduling/Placement, not a fictional host.

### Question 6: Why can free cluster CPU still produce no valid host?

Scheduling requires one eligible provider combination satisfying all constraints: vCPU, RAM, disk, traits, NUMA, huge pages, PCI devices, aggregates, AZ, reservations and ratios. Capacity may be fragmented or stale.

Use the request spec and Placement candidates/inventory/generations. Aggregate totals erase the exact combination and failure-domain placement needed by the request.

### Question 7: What does a Placement allocation prove?

It proves capacity accounting was reserved for a consumer on specified provider(s), subject to generation-aware state. It does not prove hypervisor spawn, real utilization, performance, guest boot or user success.

After failures, compare allocations with authoritative Nova lifecycle. Use supported reconciliation only after excluding in-progress ownership.

### Question 8: How do you diagnose a server in BUILD?

First bind the correct request/server and timeline. Resolve cell mapping. Inspect task state and request spec, Placement candidates/allocation, scheduler outcome, cell queue/conductor/compute transition, then image/network/storage preparation and hypervisor spawn.

BUILD is a symptom spanning many boundaries. The fix follows the first missing transition. Repeated reboot or forced state reset destroys evidence and can create orphans.

### Question 9: Why is a Glance active image not enough?

Active is metadata/workflow state. Boot also requires caller/service access, selected store availability, object bytes, correct size/digest, compatible format and trusted provenance.

Correlate image UUID and store, verify bytes against the promoted artifact, and retain supply-chain lineage. Never silently replace bytes under trusted identity.

### Question 10: Why can a bound Neutron port fail?

Binding records the chosen host/integration contract. Realization still depends on mechanism driver, controller/agent delivery, host interfaces/flows, overlays or physical fabric, security policy, routing/NAT and return traffic.

Trace port UUID and revision from API state through controller and host to packet captures on both directions. Guest reboot is not the first fix when host state is missing.

### Question 11: What does a Cinder attachment prove?

It proves Cinder/Nova coordinated an attachment record or phase. It does not prove backend export, initiator login, multipath health, host device, hypervisor presentation, guest device or filesystem consistency.

Trace volume and attachment UUIDs through Cinder service/backend and connector to host and guest. Before force-detach or failover, prove writer authority and fence an old path if necessary.

### Question 12: Why are direct database edits dangerous?

Service workflows enforce policy, state transitions, generations, notifications, allocations and cleanup across several systems. Editing one row can create a display that looks fixed while backends and related services remain inconsistent. Schemas also vary by release.

Prefer supported APIs and administrative reconciliation. If project support requires an exceptional DB action, use the exact deployed release procedure, backups, narrow scope, dual review and post-action consistency proof.

### Question 13: How should a cell failure be handled?

Scope which operations and existing workloads are affected. Determine cell DB and MQ quorum, service reachability, backlog and compute/network/storage impact. Stop new scheduling into the cell if continued admission worsens the queue.

Preserve global API access where safe, recover dependencies by their semantics, and validate both existing guests and new operations. Survivor capacity and customer communication must follow a predeclared plan.

### Question 14: Why is fencing required before evacuation?

Unreachable does not mean powered off or unable to write. If the old host resumes while a replacement mounts the same storage, two writers can corrupt data.

Fencing uses an independent authority—power controller, fabric, storage access or equivalent—to prove the old writer cannot continue. Only then assign replacement authority and validate data.

### Question 15: What makes an OpenStack upgrade complete?

Completion includes supported component versions; compatible API microversions, RPC and objects; required schema expansion/contraction; completed online data migrations; reconciled resources; stable user SLIs; and cleaned temporary compatibility.

Package deployment is only one step. Record canary results, stop/rollback gates and the last reversible boundary. Test restore before change, not during failure.

### Question 16: How do you distinguish quota from capacity?

Quota answers whether a tenant may request an amount. Capacity answers whether eligible infrastructure can supply it. Placement also cares about traits, fragmentation, reserved resources and provider relationships.

Inspect quota only for entitlement errors. For no-candidate failures, inspect request spec and eligible providers. Raising one without evidence can increase demand while capacity remains unchanged.

### Question 17: What should an OpenStack incident timeline contain?

Include user symptom, time source, region/project, request/global IDs, resource UUIDs, cell/host, API result, state transitions, first exception, queue and dependency events, every operator action, user/data recovery, and cleanup.

Separate fact, hypothesis and decision. Redact credentials and tenant-sensitive content but retain correlation identifiers.

### Question 18: How do you design useful OpenStack health checks?

Layer them. Process checks show liveness. Dependency checks cover DB, MQ and downstream calls. Synthetic control operations measure API-to-completion. Dataplane probes validate packets or I/O. User journeys validate business correctness.

Make probes bounded, tenant-isolated and low impact. Alert on actionable SLO risk; avoid a single endpoint that hides partial cell or backend failure.

### Question 19: How do you plan capacity for cell loss?

Model critical workload shapes and hard constraints, then subtract the largest declared failure domain, maintenance reserve and growth. Calculate how many priority instances fit on survivors—not just remaining totals.

Include control-plane workers, DB/MQ connections, network ports/bandwidth, storage IOPS/capacity, image transfer and operator throughput. When reserve is insufficient, define admission priority and degradation.

### Question 20: What is the correct definition of recovered?

The intended user operation works within its SLO, data invariants are correct, state owners agree, writer authority is singular, monitoring is stable, and every unintended allocation, port, attachment, instance, backend artifact and temporary credential is absent or assigned.

Document residual risk and prevention work. A green dashboard without data and cleanup evidence is restoration in progress, not closure.

## Product-company interview

### Scenario 1: ACTIVE VM, payment endpoint unavailable

**Level:** senior. **Evaluates:** layered troubleshooting and user focus.

**Strong answer:** “I would identify the exact user operation and bind request/server/project/cell/host/time. ACTIVE proves Nova lifecycle only. I would validate matching hypervisor state, guest boot/cloud-init, port binding and host dataplane in both directions, volume/device if relevant, application listener/dependencies and a safe payment synthetic. I would stop at the first divergence, recover through its owner, then verify data and cleanup.”

**Weak warning signs:** immediate reboot, blaming Neutron without packet evidence, or declaring Nova healthy as closure.

**Follow-up:** If packets reach the guest but no reply leaves, inspect guest routing/firewall/application and host egress/conntrack with captures on successive boundaries.

### Scenario 2: intermittent 403 during server builds

**Level:** senior. **Evaluates:** identity versus cross-service policy.

**Strong answer:** “I would compare successful and failed request/global IDs, caller scope, selected region/interface, Nova policy, and service identities used toward Glance/Neutron/Cinder. A human token success does not prove delegated service authorization. I would avoid broad role grants, correct the narrow role/policy or endpoint cause, then retest all affected paths.”

**Weak warning signs:** rotate every password or grant admin.

**Follow-up:** Explain how token expiry, clock skew and a mixed controller fleet could make failures intermittent.

### Scenario 3: no valid host with 40 percent free CPU

**Level:** senior. **Evaluates:** Placement and multidimensional capacity.

**Strong answer:** “Aggregate CPU is not candidate capacity. I would inspect the request spec—RAM, disk, traits, NUMA/huge pages, PCI, aggregates and AZ—then Placement candidates, provider generations, inventory, reservations, allocations and compute freshness. Fragmentation or a hard trait can eliminate all hosts. I would fix the false/stale constraint or capacity issue, not raise quota blindly.”

**Weak warning signs:** add vCPU ratio immediately.

**Follow-up:** Describe survivor capacity for one-rack loss using representative flavors.

### Scenario 4: one cell backlog grows after broker maintenance

**Level:** lead. **Evaluates:** blast-radius control.

**Strong answer:** “I would scope queues, oldest age, redelivery, consumers, broker quorum and dependency latency for that cell. I would consider disabling new scheduling into it, preserve existing guest operations, canary one consumer recovery and watch poison-message behavior. Global API green is not proof. Closure requires backlog drain without duplicates and successful cell/user operations.”

**Weak warning signs:** restart all controllers and brokers simultaneously.

**Follow-up:** How would you distinguish slow consumers from undeliverable poison work?

### Scenario 5: port bound but no traffic

**Level:** senior. **Evaluates:** desired versus effective network state.

**Strong answer:** “I would bind port UUID/revision to the actual compute host and mechanism driver, then trace controller/agent acknowledgement, host interface/bridge/flow, overlay/physical path, security policy, routing/NAT and bidirectional packets. I would compare forward and reply paths. A bound record is not a dataplane.”

**Weak warning signs:** recreate the port before preserving evidence.

**Follow-up:** DHCP succeeds but metadata fails; identify the separate path and owners.

### Scenario 6: attached volume missing from guest

**Level:** senior. **Evaluates:** storage authority and data safety.

**Strong answer:** “I would correlate volume and attachment IDs, Cinder service/backend, export state, connector, host session/multipath device, hypervisor device and guest discovery. Before force-detach or failover I would establish whether another host can write and fence it. After repair I would validate application consistency and remove stale exports/attachments.”

**Weak warning signs:** force-detach because the UI says attached.

**Follow-up:** Explain why control-plane consistency cannot prove backend writer uniqueness.

### Scenario 7: duplicate servers after API timeout

**Level:** lead. **Evaluates:** idempotency and reconciliation.

**Strong answer:** “I would halt client retries, construct lineage from timestamps, request IDs, parameters and resource UUIDs, and ask which resource the user recognizes as authoritative. I would inspect allocations, ports and volumes for each attempt. Cleanup follows service semantics only after no in-progress work or data ownership remains. Prevention is bounded retry plus request reconciliation.”

**Weak warning signs:** delete the newest server by timestamp alone.

**Follow-up:** What client/API design reduces ambiguous create outcomes?

### Scenario 8: rolling upgrade creates serialization errors

**Level:** staff. **Evaluates:** compatibility and stop decisions.

**Strong answer:** “I would stop rollout and uncontrolled retries, capture caller/worker versions, RPC/object pins, schema and online migration state, and the first serialization error. I would use the predeclared supported mixed-version matrix and rollback boundary, recover the canary slice, reconcile partial resources and validate user/data paths before proceeding.”

**Weak warning signs:** rush remaining hosts to the newest version.

**Follow-up:** When can schema contraction make rollback impossible?

### Scenario 9: design OpenStack across two failure domains

**Level:** staff/architect. **Evaluates:** dependency and capacity design.

**Strong answer:** “I would start with user journeys and failure objectives, then map Keystone/catalog/API DB/Placement global dependencies and per-cell DB/MQ/services. I would place quorum members across independent domains with a third decision location where needed, define fencing, verify image/network/storage dependencies, and calculate survivor capacity for hard workload constraints. I would test loss and restore, not rely on replicas.”

**Weak warning signs:** “three controllers means HA.”

**Follow-up:** Which supposedly global dependencies could defeat cell isolation?

### Scenario 10: prove recovery after controller disaster

**Level:** staff. **Evaluates:** recovery completeness.

**Strong answer:** “I would restore documented service configuration, secrets and databases in dependency order to a disposable environment, establish quorum and writer authority, reconcile mappings/allocations/ports/attachments with actual backends, and exercise representative user journeys. I would validate data invariants and exact residue. RPO/RTO come from timed restore evidence, not backup success.”

**Weak warning signs:** database restored, therefore cloud recovered.

**Follow-up:** How do you handle cross-service backup consistency when operations were in flight?

### Interview answer pattern

For any OpenStack scenario, lead with user outcome and scope; bind identities; draw state owners; identify the first divergence; choose a reversible safe action; protect writer authority; validate user/data; clean residue; and name the prevention. Product names without that reasoning are a weak answer.

## Independent transfer and rubric

### Reviewer-owned challenge

Open `ASM-0216` only when ready to work without model answers. Its deliverables and scoring criteria are reviewer-owned and intentionally answer-isolated. This manuscript does not disclose the hidden fault or a matching solution.

Use only a disposable isolated OpenStack environment or faithful local harness with synthetic identities and data. The reviewer owns credentials, fault injection, stop authority and cleanup verification. Never use production, a public target, customer data, unbounded load or unsupported database mutation.

### Required evidence packet

Your packet should let another senior engineer reproduce the reasoning:

- user operation, correctness condition, SLI and scope;
- release, topology, region, endpoint interface and policy boundary;
- caller/service identities without secrets;
- request/global IDs and every resource UUID;
- state-owner and failure-domain diagrams;
- API, cell, Placement, image, network, storage, guest and application timeline;
- first divergent boundary and alternatives rejected;
- authority, fencing, rollback and abort decisions;
- user and data validation;
- exact reconciliation and cleanup proof;
- communication update and prevention proposal;
- explicit limits on every conclusion.

### Self-review

| Dimension | Pass condition |
|---|---|
| User outcome | defines an operation and semantic success |
| Identity | separates authentication, scope and each service policy |
| Discovery | records region/interface/endpoint and transport |
| Correlation | joins attempt, resource, cell, host and time |
| Placement | explains request, candidates, generations and allocations |
| Ownership | distinguishes service records from backends |
| Networking | proves desired and bidirectional effective path |
| Storage | proves connector, backend and single writer |
| Reliability | maps failure domains and survivor capacity |
| Change | has compatibility, canary, stop and rollback gates |
| Recovery | validates user/data and supported reconciliation |
| Cleanup | proves every temporary or orphan resource absent |
| Security | protects credentials, tenant data and management authority |
| Limits | states what evidence cannot prove |

### Scoring boundary

The rubric totals 100 points. High scores require observable evidence, calculations and defensible trade-offs. A list of commands or service names is insufficient. A truthful unknown with a safe stop condition is stronger than invented certainty.

Publication, reading progress and the offline verifier do not award mastery. Mastery requires the reviewer to accept representative evidence and later retrieval under a different scenario.

## References and review

### Primary source map

**[REF-0913] OpenStack Security Guide**

Use it to ground security architecture, management-plane protection and operational controls. It does not prove that a particular deployment follows the guidance or that every page matches its release.

https://docs.openstack.org/security-guide/

**[REF-0914] Keystone identity concepts**

Use it for domains, projects, users, groups, roles and identity relationships. It supports the identity vocabulary, not a deployed policy decision.

https://docs.openstack.org/keystone/latest/admin/identity-concepts.html

**[REF-0915] Keystone tokens**

Use it for token concepts, scope, expiry and validation context. Never treat documentation as a reason to expose a real token in evidence.

https://docs.openstack.org/keystone/latest/admin/tokens.html

**[REF-0916] Keystone service catalog**

Use it for service and endpoint discovery concepts. A catalog record does not prove DNS, TLS, routing or backend health.

https://docs.openstack.org/keystone/latest/contributor/service-catalog.html

**[REF-0917] Nova architecture**

Use it for Nova component roles and high-level interactions. Actual process layout, messaging topology and deployment tooling remain environment specific.

https://docs.openstack.org/nova/latest/admin/architecture.html

**[REF-0918] Compute API server concepts**

Use it for server API concepts and lifecycle context. Exact fields and behavior depend on microversion and deployed release.

https://docs.openstack.org/api-guide/compute/server_concepts.html

**[REF-0919] Nova cells v2**

Use it for cell architecture, API/cell databases, mappings and cell0 concepts. It does not replace the release-specific operating procedure for repairing mappings or cells.

https://docs.openstack.org/nova/latest/admin/cells.html

**[REF-0920] Nova scheduling**

Use it for scheduler behavior and configuration concepts. It supports explaining candidate selection, not a claim that one production scheduler made a particular choice without logs and request evidence.

https://docs.openstack.org/nova/latest/admin/scheduling.html

**[REF-0921] Placement usage**

Use it for resource providers, inventories, traits, aggregates, candidates, allocations and generations. An allocation remains accounting rather than proof of guest execution.

https://docs.openstack.org/placement/latest/user/index.html

**[REF-0922] Neutron OpenStack Networking**

Use it for networking concepts and architecture. Mechanism drivers and dataplane implementation differ, so validate the deployed backend.

https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html

**[REF-0923] Neutron agents and services**

Use it for agent/service operating concepts where relevant. Controller-based deployments may realize state differently; a listed agent is not universal proof.

https://docs.openstack.org/neutron/latest/admin/config-services-agent.html

**[REF-0924] Glance interoperable image import**

Use it for supported image-import workflow concepts. It does not by itself prove store durability, artifact trust or successful boot.

https://docs.openstack.org/glance/latest/admin/interoperable-image-import.html

**[REF-0925] Cinder as a Glance backend**

Use it to understand one volume-backed image relationship and its deployment considerations. It does not make all image and volume paths identical.

https://docs.openstack.org/cinder/latest/admin/volume-backed-image.html

**[REF-0926] Cinder high availability**

Use it for Cinder HA considerations and the need to reason about service/backend behavior. Validate driver, clustering and fencing against the exact deployment.

https://docs.openstack.org/cinder/latest/contributor/high_availability.html

**[REF-0927] Nova upgrades**

Use it for Nova upgrade and migration guidance. The exact supported sequence depends on release, deployment tooling and compatibility matrix.

https://docs.openstack.org/nova/latest/admin/upgrades.html

### Source limitations

These are primary OpenStack project documents resolved on 2026-08-07. Pages under `latest` may describe a development branch. They support concepts and interfaces; they do not prove a deployed release, configuration, driver, policy or workload behavior.

No package, credential, API, database, queue, agent, hypervisor, image, network, volume or instance operation was performed for this lesson. The Ubuntu lab is a deterministic model only. Real operational evidence requires a representative disposable deployment and formal technical/security review.

### Review cadence

Re-review by 2027-02-07 or sooner when:

- the deployed OpenStack release or deployment tooling changes;
- Keystone scope/policy or catalog topology changes;
- Nova cells, Placement or upgrade procedures change;
- Neutron mechanism, Glance stores or Cinder backends change;
- a new incident reveals a missing failure boundary;
- lab safety, schemas or prerequisites change.

At review, resolve every source, confirm version-specific claims, rerun schemas and lab verification, test a disposable representative runtime, inspect broken links and keep documentation claims distinct from observed results.
