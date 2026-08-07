---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0080",
  "slug": "bare-metal-fleet-lifecycle",
  "aliases": ["V09-L05", "bare-metal-fleet-lifecycle"],
  "curriculumIds": ["PRV-005"],
  "route": "/book/privatecloud/bare-metal-fleet-lifecycle",
  "order": 5,
  "volume": "09-private-cloud",
  "title": "Bare-metal fleet operations: prove identity, provisioning, hardware health, maintenance, and safe retirement",
  "summary": "Trace one physical server from asset identity and out-of-band control through trusted network boot, inspection, image deployment, first boot, workload readiness, hardware health, maintenance, recovery, sanitization and final inventory reconciliation.",
  "domain": "private-cloud",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0006", "LES-0007", "LES-0008", "LES-0010", "LES-0012", "LES-0016", "LES-0072", "LES-0073", "LES-0074", "LES-0076", "LES-0077"],
  "prerequisiteCurriculumIds": ["LNX-001", "LNX-005", "LNX-006", "LNX-008", "NET-001", "NET-002", "NET-006", "IAC-001", "CFG-001", "SEC-001", "PRV-001"],
  "testedEnvironments": [
    {"platform":"Official standards and documentation","version":"Redfish 1.23.1, Redfish data model 2025.4, UEFI 2.11, NIST SP 800-88 Rev. 2 and current project documentation reviewed 2026-08-07","support":"concept-only","notes":"The source set establishes standards and current documented contracts but does not prove any deployed controller, BMC, firmware, hardware or operating-system release."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 63 cases, exported credential and runtime-authority refusal, root refusal, unknown-artifact refusal and exact cleanup pass with zero hardware-runtime calls."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic 63-case, 62-gate physical lifecycle, provisioning, health, maintenance, sanitization and cleanup evidence model."},
    {"platform":"Bare-metal runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No BMC, physical server, IPMI device, Redfish endpoint, switch, DHCP/PXE service, disk, firmware, image, power or sanitization action is authorized."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "private-cloud-engineer", "bare-metal-engineer", "infrastructure-engineer", "data-center-engineer", "network-engineer", "security-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Bind asset tag, chassis serial, system UUID, BMC identity, rack location, switch edge, storage devices, owner and lifecycle request before any action.",
    "Separate controller desired state, BMC task state, observed power, firmware state, ephemeral-agent evidence, installed operating-system state and user outcome.",
    "Explain Redfish resources, authentication, authorization, TLS, asynchronous tasks, events, manager resets and proof limits.",
    "Trace UEFI, Secure Boot, boot order, DHCP, PXE/iPXE, boot artifacts, provisioning network, agent callback, image integrity and root-device selection.",
    "Distinguish out-of-band inspection from in-band inventory and reconcile CPU, memory, storage, NIC, firmware, RAID and physical location.",
    "Trace allocation, scheduling, deployment, disk write, bootloader, metadata, cloud-init, host network, workload readiness and the original user operation.",
    "Diagnose BMC reachability, power disagreement, boot loops, wrong image or disk, stale inventory, VLAN/MTU, agent callback, first-boot and workload failures.",
    "Interpret thermal, fan, power, corrected memory, fatal machine-check, PCIe AER and media-health evidence without declaring a server healthy from one plane.",
    "Design rack, power, cooling, management, provisioning, tenant-network, storage and controller failure domains with survivor capacity.",
    "Plan bounded burn-in, drain, maintenance isolation, firmware canaries, rollback or rebuild, and fleet-wide reconciliation.",
    "Select media sanitization from data sensitivity, media capability and disposition; separate completion, verification, validation and audit evidence.",
    "Prove recovery and retirement using exact identity, original user outcomes, zero stale ownership and independently reviewed cleanup."
  ],
  "productionSignals": [
    "user operation service workload host owner request ID expected result latency objective and timestamp",
    "asset tag chassis serial system UUID motherboard serial rack row rack unit and cable map",
    "controller node UUID resource class traits allocation owner lease provision state target state maintenance and last error",
    "BMC endpoint manager ID system ID chassis ID certificate identity role session task event and firmware inventory",
    "requested observed and last-confirmed power state with task generation and timestamps",
    "UEFI or legacy mode Secure Boot state key ownership boot order one-shot override and device path",
    "management and provisioning interface switch port VLAN bond MTU address route DHCP lease and architecture code",
    "PXE first-stage filename iPXE build script URL kernel initrd arguments digests and download result",
    "ephemeral-agent image digest boot ID callback endpoint heartbeat logs and controller correlation",
    "inspection source time CPU sockets cores flags memory DIMMs NUMA PCI devices and inventory generation",
    "physical disk serial WWN controller slot media type health RAID target current state and root-device decision",
    "NIC permanent MAC PCI address port firmware link speed errors switch neighbor and cabling identity",
    "deployment image URI immutable digest signature size target disk bytes written partition filesystem and bootloader",
    "metadata instance ID config-drive digest cloud-init stage result operating-system build and host network",
    "workload readiness service health representative transaction and user SLI after deployment or maintenance",
    "temperature fan power supply voltage current power cap corrected errors machine checks PCIe AER and media health",
    "rack power cooling port storage controller capacity headroom failure-domain placement and largest-failure reserve",
    "drain firmware burn-in sanitization cleanup audit CMDB and residual-risk records"
  ],
  "diagrams": [
    {"id":"LES-0080-DIA-001","title":"Physical server intent-to-user lifecycle","direction":"left-to-right","boundaries":["request and owner","inventory and scheduler","BMC and firmware","provisioning network","ephemeral agent","disk and boot chain","installed OS","workload and user"],"evidencePoints":["request ID","node identity","task","boot transaction","callback","image receipt","first boot","transaction"],"textAlternative":"A physical server becomes useful only when authorized intent crosses out-of-band control, trusted provisioning, installed-host readiness and a verified user result."},
    {"id":"LES-0080-DIA-002","title":"Identity and state-owner stack","direction":"hierarchical","boundaries":["asset and rack records","controller desired state","BMC observed state","firmware and boot manager","ephemeral agent","installed operating system","workload"],"evidencePoints":["serials","node UUID","Redfish resources","UEFI variables","boot ID","machine ID","service identity"],"textAlternative":"Each plane owns different identity and state; matching one name or seeing one healthy plane cannot prove the whole machine."},
    {"id":"LES-0080-DIA-003","title":"Network boot and image trust path","direction":"left-to-right","boundaries":["NIC firmware","DHCP","PXE first stage","iPXE script","HTTP image service","kernel and initrd","agent","target disk"],"evidencePoints":["client identity","lease","architecture file","script digest","TLS and digest","arguments","callback","write receipt"],"textAlternative":"Network boot is a chain of separately identified artifacts and services whose success must end at the intended physical disk."},
    {"id":"LES-0080-DIA-004","title":"Hardware health correlation ladder","direction":"top-to-bottom","boundaries":["user symptom","operating-system RAS","device driver","BMC event log","sensor and component","rack power and cooling"],"evidencePoints":["SLI","machine check","AER or media error","event","temperature or fan","upstream feed"],"textAlternative":"Hardware diagnosis correlates user impact with OS, device, BMC, component and facility evidence instead of trusting one green health summary."},
    {"id":"LES-0080-DIA-005","title":"Maintenance and firmware safety state machine","direction":"cyclic","boundaries":["eligible node","drained and fenced","canary update","reboot and rediscovery","health and workload validation","bounded rollout","failure containment","rollback or rebuild"],"evidencePoints":["allocation","drain proof","component digest","task result","inventory delta","SLI","stop threshold","reconciliation"],"textAlternative":"Maintenance is safe only when ownership is removed, one bounded change is canaried, the machine is rediscovered, user behavior is proven and rollback or rebuild remains credible."},
    {"id":"LES-0080-DIA-006","title":"Retirement and sanitization evidence chain","direction":"left-to-right","boundaries":["data and media classification","disposition decision","method selection","device command or destruction","verification","validation","inventory release","audit record"],"evidencePoints":["risk owner","destination","clear purge or destroy","serial-bound receipt","sample result","reviewer decision","ownership removal","certificate"],"textAlternative":"A completed erase command is only one step; safe retirement requires method fit, serial-bound verification, validation and removal of all logical and physical ownership."}
  ],
  "commands": [
    {"id":"LES-0080-CMD-001","question":"Is this a guarded no-hardware-mutation shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0080 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"source, identity and authority guards pass","nextEvidence":"inventory tool presence"},{"when":"lab=fail","meaning":"a named safety guard failed","nextEvidence":"correct the boundary without bypass"}],"proves":"planned local model prerequisites","doesNotProve":"BMC, provisioning or hardware health"},
    {"id":"LES-0080-CMD-002","question":"Which hardware and provisioning tools are merely present?","risk":"read-only","command":"bash lab.sh inventory-tools","runFrom":"LES-0080 support/lab","expectedBranches":[{"when":"inventory=observed","meaning":"command presence is reported without invocation","nextEvidence":"retain the no-runtime boundary"}],"proves":"planned command discovery","doesNotProve":"tool configuration, credentials or hardware access"},
    {"id":"LES-0080-CMD-003","question":"Can bounded synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0080 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture exists","nextEvidence":"inspect status"},{"when":"refusal","meaning":"authority or existing state is unsafe","nextEvidence":"preserve the first refusal"}],"proves":"planned bounded initialization","doesNotProve":"server enrollment or deployment","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0080-CMD-004","question":"Are all reviewed lifecycle cases loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"cases=63","meaning":"the intended fixture is active","nextEvidence":"show baseline"},{"when":"another count","meaning":"fixture or model drift exists","nextEvidence":"stop and validate sources"}],"proves":"planned fixture identity","doesNotProve":"physical lifecycle coverage"},
    {"id":"LES-0080-CMD-005","question":"Which synthetic claims form the defensible baseline?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"all model inputs are inspectable","nextEvidence":"evaluate baseline"}],"proves":"planned synthetic inputs","doesNotProve":"host or BMC state"},
    {"id":"LES-0080-CMD-006","question":"Can a reachable BMC still be untrusted?","risk":"read-only","command":"bash lab.sh evaluate bmc-certificate-or-trust-invalid","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=bmc-trust","meaning":"endpoint reachability does not establish server identity","nextEvidence":"bind certificate, manager, system and chassis resources"}],"proves":"planned trust boundary","doesNotProve":"Redfish TLS behavior"},
    {"id":"LES-0080-CMD-007","question":"Can DHCP succeed but the machine receive the wrong boot artifact?","risk":"read-only","command":"bash lab.sh evaluate architecture-or-bootfile-mismatch","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=network-bootstrap","meaning":"lease success did not prove architecture-correct network boot","nextEvidence":"bind client architecture, filename and stage"}],"proves":"planned bootstrap boundary","doesNotProve":"PXE traffic"},
    {"id":"LES-0080-CMD-008","question":"Can a downloaded image still be unsafe to deploy?","risk":"read-only","command":"bash lab.sh evaluate image-digest-or-signature-invalid","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=image-integrity","meaning":"availability did not prove immutable identity or trust","nextEvidence":"bind approved digest, signature and request"}],"proves":"planned image-integrity boundary","doesNotProve":"image content or disk write"},
    {"id":"LES-0080-CMD-009","question":"Can configured RAID differ from realized storage?","risk":"read-only","command":"bash lab.sh evaluate desired-and-current-raid-diverged","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=raid-realization","meaning":"desired layout did not become the controller or OS-visible layout","nextEvidence":"bind physical drives, logical volumes and root selection"}],"proves":"planned storage-realization boundary","doesNotProve":"RAID durability"},
    {"id":"LES-0080-CMD-010","question":"Can a running host carry disqualifying hardware evidence?","risk":"read-only","command":"bash lab.sh evaluate uncorrected-or-fatal-hardware-error","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=fatal-errors","meaning":"liveness cannot override fatal RAS evidence","nextEvidence":"drain, preserve, correlate and isolate"}],"proves":"planned hardware-health boundary","doesNotProve":"a physical component failure"},
    {"id":"LES-0080-CMD-011","question":"Can an erase report finish without proving safe reuse?","risk":"read-only","command":"bash lab.sh evaluate sanitization-verification-or-validation-failed","runFrom":"LES-0080 support/lab after setup","expectedBranches":[{"when":"boundary=sanitization-evidence","meaning":"method execution lacks verified and validated risk closure","nextEvidence":"bind serial, method, result, reviewer and disposition"}],"proves":"planned sanitization evidence boundary","doesNotProve":"media sanitization"},
    {"id":"LES-0080-CMD-012","question":"Do all decisions and cleanup pass with zero hardware calls?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0080 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"cases, refusals and cleanup pass","nextEvidence":"retain the model-only limitation"},{"when":"failure","meaning":"candidate evidence is rejected","nextEvidence":"preserve the first failed gate"}],"proves":"planned offline lifecycle","doesNotProve":"Redfish, IPMI, PXE, firmware, disk, power or sanitization behavior","cleanup":"Verifier must prove exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0080-LAB-001","title":"Guided bare-metal lifecycle evidence model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no hardware, provisioning or network authority","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","BMC Redfish IPMI Ironic MAAS PXE cloud cluster container or hypervisor authority","local IPMI control device","symlink","wrong owner","unknown artifact"],"recovery":"Preserve the first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0080-bare-metal-fleet-lifecycle/support/lab"},
    {"id":"LES-0080-LAB-002","title":"Independent disposable bare-metal provisioning and recovery","mode":"independent","environment":"Reviewer-owned isolated physical server lab or faithful emulator with synthetic workloads and no production reachability","timeMinutes":240,"privilege":"least privilege; reviewer owns credentials, faults, power, load and stop authority","network":"isolated management and provisioning networks only","changes":["one disposable node lifecycle and immutable test image","reviewer-controlled identity power boot inspection storage network firmware health maintenance or sanitization defect"],"abortConditions":["production","public target","external cloud","customer data","unreviewed firmware","unknown disk or switch","unbounded power or load","shared management plane","uncertain cleanup authority"],"recovery":"Stop, preserve evidence, restore or rebuild one authoritative disposable node and reconcile every plane.","cleanupProof":"Reviewer proves credentials revoked and every allocation, node record, lease, boot artifact, image, task, port, temporary workload, disk ownership and audit exception absent or intentionally retained.","path":"drafts/LES-0080-bare-metal-fleet-lifecycle/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0080-INC-001","signal":"The controller says a server is powered on, but it never appears on the network.","firstThought":"Requested power, BMC task completion, observed chassis power, firmware boot and host network are separate claims.","safePath":"Bind physical and BMC identity, task, current power, console, boot mode/order, PXE or disk selection and host link.","trap":"Send repeated power cycles or reset the entire management controller fleet."},
    {"id":"LES-0080-INC-002","signal":"A node loops during PXE or times out waiting for the provisioning agent.","firstThought":"DHCP, architecture-specific first stage, iPXE chain, boot artifacts, VLAN/MTU and callback each own a different boundary.","safePath":"Trace one MAC and request through lease, filename, downloads, digests, kernel arguments, boot ID, agent logs and callback route.","trap":"Reimage repeatedly or disable Secure Boot and network policy globally."},
    {"id":"LES-0080-INC-003","signal":"Deployment succeeds, but the node boots the wrong disk or first-boot configuration is stale.","firstThought":"Image receipt, physical disk identity, RAID realization, root selection, bootloader, instance ID and cloud-init frequency can disagree.","safePath":"Bind disk serial and WWN, current RAID, root hint, bytes and digest, partition/boot artifacts, metadata and installed OS identity.","trap":"Wipe every disk, edit generated state in place or rerun cloud-init without understanding instance identity."},
    {"id":"LES-0080-INC-004","signal":"A healthy-looking host develops latency, resets or intermittent workload loss.","firstThought":"Green BMC summary and host liveness do not cancel thermal, corrected-error trends, fatal RAS, PCIe AER, media or facility evidence.","safePath":"Drain if thresholds require it; correlate user SLI, OS RAS, device counters, BMC events, sensors, rack power/cooling and recent change.","trap":"Clear logs, reseat or replace hardware before preserving component and failure-domain evidence."},
    {"id":"LES-0080-INC-005","signal":"Firmware maintenance or retirement reports complete, but the node cannot safely return to service or inventory.","firstThought":"A terminal task does not prove compatible firmware, rediscovered inventory, workload recovery, sanitization adequacy or ownership cleanup.","safePath":"Bind component versions, task stages, reboot/rediscovery, health, canary transaction, data classification, serial-bound sanitization evidence and CMDB reconciliation.","trap":"Mark success from one API response, return the node to the pool, or trust an erase label without independent validation."}
  ],
  "assessmentIds": ["ASM-0223", "ASM-0224", "ASM-0225"],
  "referenceIds": ["REF-0958", "REF-0959", "REF-0960", "REF-0961", "REF-0962", "REF-0963", "REF-0964", "REF-0965", "REF-0966", "REF-0967", "REF-0968", "REF-0969", "REF-0970", "REF-0971", "REF-0972", "REF-0973", "REF-0974", "REF-0975"],
  "contentStatus": "seeded",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The guarded offline lab and three assessments pass direct validation, but the substantive teaching manuscript is not complete.",
    "No BMC, Redfish or IPMI endpoint, physical server, switch, DHCP/PXE service, disk, RAID set, image, firmware, power action, burn-in or sanitization action is authorized.",
    "Current Ironic pages describe development documentation; exact deployed controller, API, driver, firmware, BMC, platform and operating-system compatibility remain unproved.",
    "Behavior depends on hardware vendor and generation, firmware, BMC implementation, boot mode and keys, network services, storage controllers, media, facility design and workload.",
    "Formal technical, security and instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Bare-metal fleet operations: prove identity, provisioning, hardware health, maintenance, and safe retirement

## What you see and first thought

A physical server is not one state. Begin with the exact user or fleet operation, exact asset identity and exact owner. A controller label, a reachable BMC or a lit power LED is one observation, not proof that the intended machine is correctly provisioned and useful.

## Terms before commands

The manuscript will define every physical, firmware, management, provisioning, operating-system, workload and retirement term before asking the learner to interpret production commands.

## Architecture map

The six declared diagrams separate state owners and evidence handoffs from request intake through trusted boot, deployed workload, maintenance and retirement.

## Request or state path

The canonical path follows one request through identity, authorization, BMC tasks, observed power, boot, agent inspection, image write, first boot, workload readiness, user result and reconciliation.

## Failure zoom

The five incident families isolate power, network boot, disk and first-boot, hardware-health, firmware and retirement failures without collapsing them into “the server is down.”

## Internals and state ownership

Asset systems, schedulers, controllers, BMCs, firmware, agents, storage controllers, the installed OS and workloads own different state and must be correlated by immutable identity and time.

## Evidence table

Each evidence item will state what it proves, what it cannot prove, its owner, freshness, authority and next discriminating observation.

## Command decoders

The twelve declared commands begin with the safe offline model. Production decoders will be taught as read-only evidence patterns and will never be presented as authorization to query or mutate a real fleet.

## Decision path

The decision path stops at the first unproved gate: identity, authority, control, boot, inspection, deployment, outcome, health, maintenance, sanitization or cleanup.

## Guided Ubuntu lab

The guided lab runs as a normal user, uses no network, refuses hardware authority and evaluates one passing baseline plus one isolated failure at every gate.

## Production transfer

Production transfer requires exact release, hardware, firmware, driver, network, storage and ownership binding. The deterministic model is not representative runtime evidence.

## Reliability, security, observability, capacity, and cost

The chapter will connect rack and facility failure domains, BMC isolation, trusted boot, telemetry freshness, survivor capacity, energy, spares, lifecycle toil and risk-adjusted cost.

## Traps and prevention

The central traps are wrong-machine action, repeated power cycling, global boot-policy weakening, unverified images, ambiguous disks, lost hardware evidence, unsafe firmware expansion and unvalidated sanitization.

## Memory card and retrieval

The durable memory chain is: identity, authority, task, observed state, boot, inspection, write, first boot, workload, user, health, maintenance, sanitization and cleanup.

## Complete answers

Every knowledge check will include a direct answer, foundation, reasoning path, senior interpretation, weak-answer critique, evidence limits and follow-up questions.

## Product-company interview

Scenarios will require live diagnosis, system design, capacity, security, change leadership, incident communication and trade-offs across mixed physical fleets.

## Independent transfer and rubric

The independent task will remain answer-isolated and reviewer owned. Passing requires unfamiliar evidence, bounded authority, observed recovery, exact cleanup and a scored explanation; reading the chapter awards no mastery.

## References and review

The source lock contains eighteen primary or official records. Version-specific runtime behavior must be rechecked against the exact deployed hardware and software before operational use.
