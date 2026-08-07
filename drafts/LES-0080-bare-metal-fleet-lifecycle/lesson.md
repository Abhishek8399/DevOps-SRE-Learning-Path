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
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The substantive manuscript, guarded offline lab and three assessments pass direct validation, but representative runtime and formal acceptance remain incomplete.",
    "No BMC, Redfish or IPMI endpoint, physical server, switch, DHCP/PXE service, disk, RAID set, image, firmware, power action, burn-in or sanitization action is authorized.",
    "Current Ironic pages describe development documentation; exact deployed controller, API, driver, firmware, BMC, platform and operating-system compatibility remain unproved.",
    "Behavior depends on hardware vendor and generation, firmware, BMC implementation, boot mode and keys, network services, storage controllers, media, facility design and workload.",
    "Formal technical, security and instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Bare-metal fleet operations: prove identity, provisioning, hardware health, maintenance, and safe retirement

## What you see and first thought

A ticket says, “Server bm-042 is stuck. Please reboot it.”

Your first move is not the reboot button. On bare metal, the most dangerous failure is not always a failed command. It is a successful command sent to the wrong physical machine.

Think of a physical server as several people describing the same building:

- the asset database knows the purchase record and rack position;
- the provisioning controller knows a node UUID and desired lifecycle state;
- the BMC knows a computer system, chassis, sensors and power controls;
- firmware knows boot devices, Secure Boot policy and hardware initialization;
- the ephemeral agent sees hardware from a temporary operating system;
- the installed operating system sees devices, filesystems and services;
- the scheduler knows an allocation and workload owner;
- the user knows whether the promised service works.

They may all use different names. They may also disagree.

### The sentence to remember

> Never operate “a server.” Operate one proved physical identity, under one proved owner, for one stated request, and validate the original user outcome.

“Power on” is not “booted.” “Booted” is not “provisioned.” “Provisioned” is not “healthy.” “Healthy” is not “serving the user.” “Erase completed” is not “safe to reuse.”

### Turn the alert into an operation

Replace “bm-042 is broken” with:

> Request R asked the fleet controller to allocate physical asset A, at rack position L, to owner O, install immutable image digest D, and make workload W ready by time T. The original transaction U still fails.

That sentence gives you identities to join and a result to prove. Record:

- request, change and incident IDs;
- node UUID and allocation or lease;
- asset tag, chassis serial and system UUID;
- BMC endpoint and Redfish System, Chassis and Manager resource IDs;
- rack, rack unit, power feeds and switch ports;
- image, kernel, initrd and metadata digests;
- target disk serial or WWN;
- owner, workload and original user test;
- timestamps and time sources.

### First-thought decision

Use this quick rule:

```text
identity conflict? ----------> stop; prove the machine
authority unclear? ----------> stop; prove the owner and permission
task accepted only? ---------> follow it to terminal state
power on but no boot? -------> firmware, boot target and console
DHCP but no agent? ----------> architecture, chain, artifacts, VLAN/MTU, callback
agent but no install? -------> inventory, RAID, root disk, image write
OS up but service down? -----> first boot, network, workload and user path
health alarm? ---------------> correlate OS, device, BMC and facility
maintenance complete? ------> rediscover, canary, workload proof, reconcile
erase complete? ------------> verify, validate, dispose, remove ownership
```

### What you must not infer

A successful TCP connection to a BMC proves only that something answered at that endpoint. A `202 Accepted` response proves only that an asynchronous request was accepted. A BMC “OK” summary does not cancel an operating-system machine check. DHCP success does not prove the correct boot file. A downloaded image does not prove its digest. A disk model does not identify one disk. A green deployment state does not prove cloud-init or the workload. A corrected error does not mean “ignore forever.” A finished erase action does not prove the method matched the data risk.

This chapter teaches you to keep those claims separate until evidence joins them.

## Terms before commands

### Bare metal

**Bare metal** means the workload or platform controls a physical machine rather than receiving a virtual machine from a hypervisor. The server still has many control layers—BMC, firmware, boot services, agents and operating systems—but there is no hypervisor boundary hiding physical devices.

### Asset, system, chassis and manager

An **asset** is the organization’s inventory record. A **computer system** is the Redfish model of the host that runs an OS. A **chassis** represents the enclosure and physical components. A **manager** usually represents the BMC. These are related, not interchangeable.

Useful physical identifiers include asset tag, chassis/system/board serials, system UUID, BMC identity, NIC permanent MAC and PCI address, storage serial and WWN, controller slot, and rack position. Names such as `bm-042` are convenient aliases. They are not enough for destructive work.

### BMC and out-of-band management

A **baseboard management controller (BMC)** is a separate management computer embedded in or attached to a server. It can remain available when the host OS is stopped. It may expose power control, console, virtual media, inventory, sensors, event logs and firmware operations.

**Out-of-band** means the operation uses the management plane rather than the installed host OS. It does not mean infallible. BMC firmware can hang, return stale data, have a wrong certificate, map the wrong system resource or share a failed network.

### Redfish, IPMI and asynchronous tasks

**Redfish** is a DMTF HTTPS/JSON management standard. Its resource tree distinguishes Systems, Chassis, Managers, UpdateService, TaskService and EventService. Exact resources and actions depend on implementation and schema version.

**IPMI** is an older management protocol still present in many fleets. It often has weaker identity, cipher and audit properties than a well-operated Redfish deployment. Tool familiarity is not a security argument.

Many actions are asynchronous:

```text
request accepted -> task created -> component acts -> task finishes
                                      \-> component may reset or disappear
```

Follow the task and independently observe the resulting component state.

### Desired, target, transitional and observed state

**Desired state** is what the controller wants. **Target state** is the requested next stable state. A **transitional state** means work is in progress. **Observed state** is what one observer currently reports.

```text
controller target: active
controller state: deploying
BMC task: completed
BMC power: on
firmware console: no boot device
agent: absent
installed OS: not running
user: unavailable
```

All statements can be true at once.

### Firmware, UEFI and Secure Boot

**Firmware** is software embedded in the BMC, system, NIC, storage controller, SSD, GPU and other components. Modern system firmware normally implements **UEFI**, which defines firmware services, device paths, boot variables and the boot manager.

**Boot order** is an ordered set of boot options. A **one-shot boot override** changes one boot without permanently rewriting the normal order.

**Secure Boot** verifies signatures in the boot chain according to trusted and revoked key databases. Disabling it may make a test boot while removing a security property and hiding a signing or key-ownership failure. Fix the trust chain; do not globally weaken it.

### DHCP, PXE and iPXE

**DHCP** supplies network configuration and can supply boot information. A lease proves that a server answered a client identity. It does not prove the right VLAN, route, architecture-specific boot file or later download.

**PXE** is a firmware network-boot environment. **iPXE** is a richer network-boot firmware/client with scripting and more protocols. A classic failure is a chainload loop: firmware loads iPXE, iPXE sends DHCP again, and DHCP returns iPXE again instead of the real script or OS artifacts.

### Kernel, initrd and ephemeral agent

The **kernel** initializes the operating-system core. The **initrd/initramfs** is early userspace used to load drivers and prepare the real root.

An **ephemeral agent** boots temporarily—normally into RAM—to inspect hardware, clean disks, configure RAID or write an image. It is not the installed OS. Bind its image digest, boot ID, callback destination and logs.

### Inspection and reconciliation

**Out-of-band inspection** obtains inventory from a BMC or vendor interface. **In-band inspection** boots an agent and queries devices through OS drivers.

```text
asset record <-> BMC inventory <-> agent inventory <-> installed OS
```

They observe different things. A disagreement is evidence, not something to overwrite automatically.

### Physical disk, logical disk, RAID and root device

A **physical disk** is media identified by serial, WWN, controller and slot. A **logical disk** is a volume presented by hardware RAID or another layer.

**RAID** combines devices for performance, availability or both. RAID is not backup, and desired layout is not current layout.

The **root device** contains the target OS. `/dev/sda` is an enumeration name and can change. Use persistent identity for destructive selection.

### Image, immutable identity and first boot

An **image** is the OS artifact written to storage. A URL or tag is a locator, not immutable identity. Bind an approved digest and, where applicable, a signature and provenance.

Metadata, user data, vendor data and network configuration customize the machine. cloud-init uses an **instance ID** to decide first-boot behavior. Reusing an old ID can make new configuration appear ignored; changing it casually can rerun once-per-instance actions.

### RAS, corrected and fatal errors

**RAS** means reliability, availability and serviceability mechanisms. Linux can report memory-controller errors, machine checks and PCIe Advanced Error Reporting events.

A **corrected error** was corrected for that event. Track rate, concentration and trend. An accelerating count on one DIMM or PCIe link can be early failure evidence.

An **uncorrected** or **fatal** error can corrupt an operation, isolate a device, reset a bus or stop the host. Preserve it before rebooting.

### Sensors and health summaries

Temperature, fan, voltage, current and power readings have units, labels, timestamps and platform-specific support. A “health OK” roll-up is a vendor policy result, not the raw evidence. Confirm which sensors exist, whether readings are fresh and who owns thresholds.

### Drain, fence, quarantine and maintenance

**Drain** moves or stops workload safely. **Fence** prevents new workload or conflicting control. **Quarantine** keeps a suspect node out of the eligible pool. **Maintenance mode** communicates and enforces an operational boundary; exact behavior depends on the controller.

Prove allocation removed, workload stopped or migrated, data safe, automation fenced and return-to-service criteria defined.

### Burn-in

**Burn-in** applies controlled CPU, memory, disk, network or accelerator load to expose early failures. It consumes power, cooling, bandwidth and device life. Define duration, intensity, expected signals, abort thresholds and cleanup first.

### Sanitization: clear, purge and destroy

Media sanitization renders access to target data infeasible for a stated effort and context.

- **Clear** uses logical techniques against ordinary access.
- **Purge** targets more capable recovery while preserving possible reuse.
- **Destroy** makes media unusable when reuse is not required or risk demands it.

Method selection depends on data sensitivity, media type/capability and disposition. **Verification** checks that the process executed as intended. **Validation** decides whether the result adequately addresses risk. Keep both tied to the exact media serial and reviewer.

## Architecture map

### Diagram 1: intent to useful machine

```text
[request/owner]
      |
      v
[inventory + scheduler] -> [BMC/Redfish] -> [UEFI/Secure Boot]
                                  |                  |
                                  v                  v
                           [power/task]       [DHCP/PXE/iPXE]
                                                     |
                                                     v
                                             [ephemeral agent]
                                              /      |      \
                                      inspection   RAID    image write
                                                     |
                                                     v
                                             [installed OS]
                                                     |
                                                     v
                                           [workload -> user]
```

The control path is complete only when the original user or fleet operation succeeds. Every arrow needs an identity and a receipt.

### Diagram 2: identity join

```text
Asset system       Controller         Redfish             OS/workload
------------       ----------         -------             -----------
asset tag          node UUID          System resource     machine-id
chassis serial <-> driver info <----> serial / UUID <----> DMI identity
rack / RU       <-> conductor owner    Chassis resource    NIC PCI/MAC
switch ports   <-> port records    <-> NIC inventory   <-> interface
disk serial    <-> root hint       <-> storage resource <-> by-id path
```

Join on multiple independent fields. If serial, UUID and location disagree, stop. A later system can be internally consistent about the wrong machine.

### Diagram 3: trusted boot chain

```text
NIC firmware
  -> DHCP lease + architecture
  -> architecture-correct PXE binary
  -> iPXE script identity
  -> HTTPS/TLS service identity
  -> kernel digest
  -> initrd digest
  -> kernel arguments
  -> agent boot ID
  -> authorized callback
  -> approved image digest
  -> exact target disk serial
```

Availability is not integrity. Seeing bytes arrive does not prove the correct bytes, and correct bytes do not prove the correct destination.

### Diagram 4: hardware-health correlation

```text
user latency / resets
          |
          v
process + kernel logs ---- machine check / EDAC / AER / media
          |                             |
          v                             v
driver/device counters <---------- component identity
          |                             |
          v                             v
BMC events + sensors <----------- rack power / cooling
```

Use time, component identity and recent change to correlate. Do not average away one failing DIMM, device or overheated rack.

### Diagram 5: maintenance loop

```text
eligible -> drain -> fence -> baseline -> one canary change
   ^                                         |
   |                                         v
return <- workload proof <- rediscover <- reboot/task
   |
   +---- failure -> contain -> rollback / rebuild / replace
```

Return to service is a controlled admission decision. “Command completed” is too early.

### Diagram 6: retirement chain

```text
data class + media + disposition
              |
              v
      choose clear/purge/destroy
              |
              v
     execute on exact serial/WWN
              |
              v
          verify result
              |
              v
       reviewer validates risk
              |
              v
revoke ownership + reconcile inventory + retain audit
```

If the serial in the disposition record does not match the media removed from the server, the paperwork proves the wrong object.

## Request or state path

### Stage 1: define the promise

State whether the operation is allocate, inspect, provision, rebuild, maintain, recover, release or retire. Record the owner, deadline, hardware class, image, data sensitivity and original validation.

### Stage 2: bind physical identity

Join asset tag, chassis serial, system UUID, board serial, BMC resources, rack/RU, switch ports, disks and controller node UUID. Hands-on verification may be appropriate in a controlled data-center workflow, but store only approved, non-sensitive evidence.

### Stage 3: bind authority

Prove who owns the node, who approved the change, which identity calls the BMC/controller and exact allowed actions. Shared administrator credentials make attribution and least privilege weak. Never put BMC passwords in commands, shell history, URLs or evidence.

### Stage 4: bind release and schema

Record controller, driver, BMC, Redfish schema, system firmware and relevant component versions. A procedure copied from another model or release is a hypothesis until compatibility is proven.

### Stage 5: prove management-plane trust

Resolve endpoint identity, TLS certificate, System/Chassis/Manager mappings, role and session. A valid certificate for the wrong hostname or a trusted endpoint mapped to the wrong chassis is still unsafe.

### Stage 6: follow task and power state

For an asynchronous action, record request ID, task URI, state changes, messages and terminal result. Then re-read observed power and, when safe, console/host evidence. If a BMC resets during firmware update, planned temporary unavailability is different from an unknown outcome.

### Stage 7: prove firmware and boot policy

Capture component inventory, boot mode, Secure Boot state and key ownership, normal boot order and one-shot override. Avoid permanent boot-order drift. Never remove trust controls merely to make the next stage run.

### Stage 8: trace management and provisioning networks

Bind NIC MAC/PCI identity to switch port, VLAN, bond, MTU, address, route and firewall in both directions. Management, provisioning and tenant networks are different security and availability domains even when they share hardware.

### Stage 9: trace DHCP and bootstrap

Follow one MAC through DHCP discovery, offer, request and acknowledgment, including architecture option, next server and boot filename. Distinguish firmware PXE from chainloaded iPXE so the second DHCP exchange receives the real target rather than iPXE again.

### Stage 10: bind boot artifacts and agent

Record script, kernel, initrd and command-line digests. Bind agent boot ID, controller callback URL, TLS/authorization and heartbeat. A callback at the wrong controller can make two control planes believe they own one node.

### Stage 11: reconcile inspection

Compare out-of-band and in-band inventory for CPU topology, memory DIMMs, NUMA, PCI devices, NICs, storage and firmware. Record collection time and source. Resolve missing or replaced devices; do not silently accept a new generation.

### Stage 12: realize storage safely

Bind target RAID and current RAID, every physical serial/WWN/controller/slot, logical volumes and root-device selection. Before a destructive write, repeat identity proof at the action boundary. Confirm image size, target capacity and boot-mode requirements.

### Stage 13: prove image write and boot artifacts

Bind approved image source and immutable digest. Record bytes written, completion receipt, target identity, partitions, filesystems, EFI System Partition or bootloader and next boot target. A successful copy can still write the wrong disk.

### Stage 14: prove first boot

Bind metadata/config-drive digest, instance ID, hostname, users/keys, network configuration and cloud-init stage results. Record installed OS build, kernel, machine identity and persistent network interfaces.

### Stage 15: prove workload and user outcome

Do not stop at SSH. Validate workload admission, service readiness, dependencies, telemetry and the original transaction. Compare with baseline and observe long enough to catch resets, thermal throttling or first-boot drift.

### Stage 16: prove health and capacity admission

Review sensors, power supplies, fan state, corrected-error rate, uncorrected/fatal errors, PCIe AER, media health, link errors and rack/facility state. Confirm survivor capacity if this node or its largest correlated failure domain is lost.

### Stage 17: reconcile ownership and cleanup

The final state must match the operation:

- active: one valid owner, allocation and workload;
- available: no tenant data or stale allocation, with fresh health evidence;
- maintenance: fenced, drained and owned by the change;
- retired: sanitized or destroyed, credentials revoked, and port/IP/DNS/DHCP/CMDB state reconciled.

Cleanup is part of correctness, not housekeeping.

## Failure zoom

### Power requested but not observed

Possible boundaries include rejected authorization, accepted-but-running task, BMC reset, stale controller cache, chassis power fault, failed PSU/feed or firmware hang. Preserve the task URI and messages. Compare controller target, BMC current state, chassis sensors and console. Repeated power cycling converts one diagnosis into several unknown outcomes and can worsen storage state.

### BMC reachable but unsafe

Reachability can coexist with an expired/wrong certificate, shared administrator account, wrong System resource, stale DNS or a replacement BMC at an old address. Stop before action. Bind TLS name and chain, Redfish resource IDs, serial/UUID and role. Treat certificate bypass as loss of identity, not a connectivity fix.

### DHCP succeeds but PXE fails

DHCP success narrows only the early path. Check client MAC, architecture option, VLAN, lease, next-server and filename. If iPXE appears repeatedly, distinguish the firmware request from iPXE’s second request or user class. A UEFI client given a BIOS artifact may download bytes and still fail to execute.

### Boot artifacts download but the agent never calls back

Separate kernel start, initrd unpack, driver discovery, network configuration, DNS/route, callback TLS and controller ownership. Serial console and provisioning-service access logs give different evidence. A bad kernel argument can send a healthy agent to the wrong endpoint.

### Inspection says a device disappeared

First establish freshness and source. BMC inventory may omit devices only visible in-band; an agent may lack a driver; a PCIe link may fail training; a part may have been replaced without inventory reconciliation. Do not automatically delete the old record or admit the new inventory. Bind physical change and component identity.

### RAID configuration is “successful,” but the root disk is wrong

Desired configuration, controller task, current logical drives, agent-visible devices and boot firmware can disagree. Match physical serial/WWN/controller/slot, logical volume identity and root hint. Never select by capacity and model when two disks look alike.

### Image write completed, but the host does not boot

Prove target disk, image digest and bytes written, then inspect partition table, EFI System Partition or bootloader, boot mode, Secure Boot trust and boot order. A valid UEFI image will not boot in an inconsistent legacy configuration, and a custom bootloader can break the signing chain.

### Host boots, but cloud-init configuration is missing

Check datasource detection, instance ID, metadata source, network availability, stage status and logs. cloud-init may correctly treat reused instance identity as not-first-boot. Rerunning every stage can repeat account, package, filesystem or command mutations. Understand frequency before retry.

### Network is wrong after provisioning

Bind NIC permanent MAC and PCI identity to generated configuration and switch port. Interface names can differ from expectation. Check bond membership, VLAN, MTU, address, route and return path. A provisioning-network success does not prove the tenant/workload network.

### Corrected errors rise but the server stays online

Plot rate per component and time, not only total. Correlate DIMM/channel, CPU/socket, PCIe requester ID, media serial, temperature, power and workload. Corrected events preserve service now; acceleration can predict loss of margin. Follow policy for drain, diagnostics and replacement.

### BMC health is green while Linux reports fatal AER

The BMC roll-up may not include OS-owned PCIe AER, or firmware and OS may divide error ownership. Preserve kernel logs and device identity. Determine whether the link, transaction or device became unreliable. A green summary cannot overrule a fatal event in another owner.

### Firmware update partially completes

Multiple components may update sequentially and reboot independently. Record each component, old/new digest, task and reset. Do not replay the whole bundle blindly: already-updated components and schema changes can make the second attempt different. Use vendor recovery, rollback or rebuild guidance and a known-good canary.

### Node is drained but not fenced

A scheduler, autoscaler or operator can reassign work during maintenance. Prove no workload and no allocation, then prevent new admission through the authoritative owner. Fencing must not make recovery impossible; record who can remove it and under what evidence.

### Burn-in creates fleet impact

CPU/GPU load consumes rack power and cooling; disk tests consume endurance and I/O; network tests consume links. A node-local timeout is insufficient. Bound concurrent nodes by rack and failure domain, monitor facility and service signals, and stop on thresholds.

### Sanitization reports success for the wrong media

This is an identity failure. Bind the media serial/WWN before action and in the resulting receipt. For self-encrypting media, cryptographic erase depends on implementation, key scope and validation. For failed devices, purge may be unavailable and destruction may be required. Do not relabel an unsupported method as equivalent.

## Internals and state ownership

### Ownership table

| Owner | Authoritative for | Not authoritative for |
|---|---|---|
| asset/CMDB system | procurement, location, lifecycle/disposition record | current power or workload |
| scheduler/allocation service | current logical reservation | chassis serial unless reconciled |
| provisioning controller | node lifecycle intent, workflow, last error | direct proof of hardware/user state |
| BMC/Redfish | its resource model, tasks, sensors and controls | OS service health |
| UEFI/firmware | device initialization and boot selection | workload readiness |
| DHCP/PXE/image services | served lease and artifact transaction | agent execution or disk target |
| ephemeral agent | in-band inventory and performed agent steps | long-term installed OS state |
| RAID/storage controller | its physical/logical-drive configuration | backup or application durability |
| installed OS | kernel/device/filesystem/service observations | BMC task history or facility health |
| workload platform | workload placement and readiness | physical identity unless joined |
| user probe | one observed user result | root cause or universal health |

### Redfish resources are a graph

Do not assume `/redfish/v1/Systems/1` means “server 1” everywhere. Discover from the service root and follow links. A chassis can contain multiple systems; a manager can manage multiple resources. Record `@odata.id` values, schema/version, serial/UUID and ETags where relevant.

### Tasks and unknown outcomes

If a client times out after submitting a power or firmware action, the effect may have happened. Retrying unchanged can duplicate or conflict. Reconcile using the task, component state and operation identity. If no stable idempotency contract exists, stop and use the controller’s supported recovery workflow.

### Firmware has coupled compatibility

System firmware, BMC, NIC, storage, GPU and drivers form a compatibility set. “Latest” on each component is not automatically a tested bundle. Maintain approved baselines by hardware model/revision and OS/workload class. Record downgrade support and state migration limits before rollout.

### Boot identity crosses protocols

The same NIC may be represented by firmware handle, MAC, DHCP client identifier, switch port, agent PCI address and OS interface. Architecture codes select boot artifacts. Secure Boot validates signatures, while TLS/digests validate transport and artifact identity at other stages. No single check covers the chain.

### Inventory is versioned evidence

Inventory needs source, collection time, tool/agent version and node boot ID. A replacement disk with the same capacity is a new object. A DIMM moved between slots changes failure localization. Treat hardware change as a lifecycle event that invalidates relevant baselines.

### RAID has three realities

Keep separate:

1. **target** configuration requested by policy;
2. **current controller** configuration after the operation;
3. **OS-visible** block devices and boot behavior.

Then verify data-protection and failure behavior separately. RAID level labels do not prove rebuild time, write-cache protection, firmware correctness or backup.

### Health is a time series

A point-in-time sensor value needs unit and threshold. Hardware errors need rate and component. Use:

```text
rate = (new counter - old counter) / elapsed time
```

Counter resets, rollover, reboot and replaced components break naive subtraction. Annotate changes and boot identity.

### Facility state participates in the service

Dual PSUs connected to one PDU are not independent. Two NICs on one top-of-rack switch are not independent. Spare servers in a rack with no remaining power or cooling are unusable reserve. Model feeds, PDUs, cooling zones, network devices and human repair paths.

### Sanitization is a program

The method is only one control. The program needs media/data classification, authorization, chain of custody, exact device identity, execution, verification, validation, exception handling, disposal/reuse decision, records and periodic testing. Failed media often follows a different path from healthy media.

## Evidence table

| Evidence | Proves | Does not prove | Next question |
|---|---|---|---|
| asset tag + serial + rack | inventory claims about one object/location | current controller/BMC mapping | do system UUID and Redfish resources match? |
| BMC HTTPS response | endpoint transport answered | correct machine or trusted identity | certificate, resource graph and serial? |
| Redfish task accepted | request admitted | action completed | terminal task and observed component state? |
| power state On | BMC’s current power observation | firmware boot or OS health | console, boot progress and host evidence? |
| DHCP ACK | lease transaction succeeded | right artifact or callback | architecture, filename and second-stage path? |
| HTTP 200/image bytes | server returned content | approved immutable image | digest/signature and target disk? |
| agent heartbeat | one agent reached controller | correct node or successful step | boot ID, hardware identity and step receipt? |
| inspection inventory | one source observed devices at time T | current physical truth forever | reconcile BMC, asset and installed OS? |
| RAID task success | controller reports step success | intended current/OS-visible layout | physical/logical identity and boot test? |
| image-write completion | agent reports write finished | correct disk, bootability or user service | serial, digest, partitions, boot and first boot? |
| cloud-init status done | configured stages reached terminal state | desired config or workload success | logs, effective state and user transaction? |
| BMC health OK | vendor roll-up is OK | absence of OS/device/facility errors | RAS, media, link and sensor trends? |
| corrected error | hardware corrected one event | stable future health | rate, component, temperature and policy? |
| drain complete | current selected workloads removed | future scheduling fenced | allocation and admission control? |
| firmware task completed | reported component operation finished | compatibility or workload recovery | inventory delta, health and canary? |
| sanitization command success | command reports execution | risk-adequate sanitization | serial-bound verification and validation? |
| cleanup script success | script reports cleanup | every external owner reconciled | independent inventories across systems? |

### Evidence labels

Label every statement:

- **observation** — directly read at a named place/time;
- **documented contract** — official behavior for a bound version;
- **calculation** — arithmetic with inputs and units;
- **inference** — conclusion from observations;
- **hypothesis** — testable possible cause;
- **unknown** — missing evidence.

This prevents “the server is healthy” from hiding a chain of assumptions.

## Command decoders

### Safe local commands

Run from `drafts/LES-0080-bare-metal-fleet-lifecycle/support/lab` in Ubuntu as a normal user.

#### `bash lab.sh doctor`

- `bash` selects the shell.
- `lab.sh` is the local guarded controller.
- `doctor` validates source shape and refuses root, exported credentials/runtime authority, IPMI devices, unsafe state ownership and symlinks.

`doctor=pass` proves only that the offline model can run inside its declared boundary.

#### `bash lab.sh inventory-tools`

It uses `command -v` to report whether tools are present. “yes” means executable resolution found a name. It does not invoke Redfish, IPMI, Ironic, MAAS, disk, firmware or network tools.

#### `bash lab.sh setup` and `status`

`setup` creates one UID-scoped directory under `/tmp` with mode restricted by `umask 077` and copies the synthetic fixture. `status` validates ownership and exact allowed artifacts before counting cases. Run `bash lab.sh cleanup` when finished.

#### `bash lab.sh show baseline`

`show` prints merged synthetic booleans. It is not a snapshot of the laptop, WSL, BMC or server. Use it to learn which claims a defensible baseline needs.

#### `bash lab.sh evaluate CASE`

The model scans gates in order and returns the first failed boundary. That is a teaching discipline: fix or explain the earliest unproved handoff before jumping to a later symptom.

#### `bash verify.sh`

The verifier proves all 63 decisions, authority refusal, unknown-artifact refusal and exact cleanup. It deliberately makes no hardware-runtime call.

### Production evidence patterns—not commands to run blindly

The following examples explain common tools. Use exact vendor/controller documentation, read-only roles, approved targets and redaction.

#### Redfish inventory request

```bash
curl --fail --silent --show-error \
  --cacert approved-ca.pem \
  --header 'Authorization: Bearer <redacted-session-token>' \
  'https://bmc.example.invalid/redfish/v1/Systems'
```

- `--fail` makes HTTP error status fail the command.
- `--silent --show-error` removes progress but retains errors.
- `--cacert` pins an approved trust source instead of `--insecure`.
- the authorization value must be injected securely and never published.
- the collection response identifies links, not automatically the target server.

Do not use this book’s reserved address as a real target. Never put a password in the URL or command history.

#### Ironic node fields

```bash
baremetal node show NODE_UUID \
  --fields uuid name provision_state target_provision_state \
  power_state maintenance last_error properties instance_info
```

This asks the client for selected fields. It can prove what the controller reports. It cannot prove fresh BMC power, physical identity, disk contents or user service. Bind cloud, endpoint, API microversion, node UUID and timestamp.

#### Linux persistent hardware identity

```bash
find -L /dev/disk/by-id -maxdepth 1 -type l -printf '%f -> %l\n'
```

This example still requires review: `-L` changes symlink traversal semantics, and device access belongs on an authorized disposable node. Persistent links are stronger than `/dev/sdX` but still need controller/slot/serial reconciliation before mutation.

#### Hardware error evidence

```bash
journalctl --dmesg --since '2026-08-07 08:00:00 UTC' \
  --grep='EDAC|MCE|AER|I/O error'
```

- `--dmesg` limits to kernel messages.
- `--since` defines the time boundary.
- `--grep` narrows matching messages.

Absence can mean no event, wrong time, missing persistence, different wording or a collection failure. It is not proof of healthy hardware.

### Redaction rule

Operational evidence can expose BMC addresses, serials, asset tags, rack positions, certificate subjects, tenant IDs and tokens. Keep full evidence only in approved systems. For learning artifacts, replace identifying strings consistently while preserving relationships, time order, numeric counts, state names and proof limits.

## Decision path

### Gate 1: identity

Do asset, chassis, system, manager, rack, switch, storage and controller records describe one machine? If not, stop.

### Gate 2: authority

Is the current owner known, is the action approved, and is the identity least privileged for this exact target? If not, stop.

### Gate 3: control-plane contract

Are controller, API, driver, BMC and schema versions bound? Is management TLS trusted? If not, evidence may be misread.

### Gate 4: task and observed power

Did the exact task reach a terminal result, and does a fresh independent observation match? If not, reconcile; do not repeat blindly.

### Gate 5: boot policy

Are firmware inventory, boot mode, Secure Boot and one-shot target correct? If not, fix the owned policy without weakening the fleet.

### Gate 6: network bootstrap

Does one MAC traverse the intended switch/VLAN, DHCP architecture, PXE/iPXE chain and immutable artifacts? If not, stop at the first missing receipt.

### Gate 7: agent and inspection

Did the correct agent boot, authenticate and call the correct controller? Is inventory fresh and reconciled? If not, do not write disks.

### Gate 8: storage and image

Are physical media, current RAID, root device, image digest and target write unambiguous? If not, destructive action is refused.

### Gate 9: first boot and user

Do metadata identity, cloud-init, OS/network, workload readiness and original user transaction pass? If not, deployment is not complete.

### Gate 10: health and capacity

Do hardware/facility signals meet admission policy, and can the fleet survive loss/maintenance? If not, quarantine or reduce demand.

### Gate 11: maintenance recovery

Was the node drained and fenced? Did a bounded canary pass rediscovery, health and workload gates? If not, contain and rollback, rebuild or replace.

### Gate 12: retirement

Does sanitization fit data/media/disposition, with serial-bound verification, reviewer validation, ownership removal and audit? If not, retirement is incomplete.

The decision tree intentionally refuses “restart everything,” “disable verification,” “wipe all disks,” and “mark healthy” shortcuts. Those are actions without proved boundaries.

## Guided Ubuntu lab

### Purpose and boundary

This lab builds diagnostic order without touching hardware. It creates only one private temporary directory for your numeric UID. It refuses root, BMC/controller/PXE/cloud authority variables, local IPMI control devices, symlinks, wrong ownership and unknown artifacts.

### Step 1: enter the lab

```bash
cd drafts/LES-0080-bare-metal-fleet-lifecycle/support/lab
id
bash lab.sh doctor
```

Expected shape:

```text
uid=1000(...)
model=valid cases=63 gates=62
doctor=pass network=none user=1000 hardware_runtime_calls=none
```

Your UID may differ. Do not run as root. `doctor` proves only model readiness.

### Step 2: observe tools without using them

```bash
bash lab.sh inventory-tools
```

Read each `name=yes/no` as command presence only. A tool can exist with no configuration, incompatible version or no authority. The final field must say `hardware_runtime_calls=none`.

### Step 3: create bounded state

```bash
bash lab.sh setup
bash lab.sh status
```

Expected:

```text
model=valid cases=63 gates=62
setup=pass state=/tmp/reliability-atlas-les0080-bare-metal-<uid>
status=ready cases=63 ... hardware_runtime_calls=none
```

If state already exists, inspect ownership and use the lab’s cleanup command. Never broadly delete `/tmp`.

### Step 4: inspect the baseline

```bash
bash lab.sh show baseline
bash lab.sh evaluate baseline
```

All fields are synthetic booleans. The result `operable-within-model` means every encoded claim is true. It does not mean a server exists.

### Step 5: compare early and late failures

```bash
bash lab.sh evaluate bmc-certificate-or-trust-invalid
bash lab.sh evaluate requested-and-observed-power-diverged
bash lab.sh evaluate architecture-or-bootfile-mismatch
bash lab.sh evaluate image-digest-or-signature-invalid
bash lab.sh evaluate desired-and-current-raid-diverged
bash lab.sh evaluate cloud-init-or-first-boot-failed
bash lab.sh evaluate original-user-operation-failed
bash lab.sh evaluate uncorrected-or-fatal-hardware-error
bash lab.sh evaluate sanitization-verification-or-validation-failed
```

Notice that each output names the first failing boundary. The model stops early because later success cannot repair an earlier unproved handoff.

### Step 6: run every case and refusal test

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=63 refusal=true cleanup=true hardware_runtime_calls=none
```

The verifier creates an unknown artifact deliberately, proves the lab refuses to operate, removes exactly that artifact, and proves cleanup.

### Step 7: retrieval exercise

Without looking back, explain:

1. why BMC reachability is not identity;
2. why accepted is not completed;
3. why DHCP is not boot;
4. why image download is not integrity;
5. why `/dev/sda` is not a safe disk identity;
6. why OS liveness is not hardware health;
7. why erase completion is not validation.

Then check your answers against the relevant sections.

## Production transfer

### Before touching a real fleet

Require a named environment owner, approved target set, exact controller/BMC/hardware versions, least-privilege identity, maintenance window, stop thresholds, rollback/rebuild path and independently observable user test.

The lab’s booleans become real evidence queries. For example, `asset_identity_bound=true` becomes a reviewed join of serial, UUID, BMC resource, rack and controller node. Never copy a synthetic “true” into production records.

### Safe investigation sequence

1. Freeze rollout and repeated retries.
2. Define the failed operation and target set.
3. Bind physical identity and current allocation.
4. Preserve controller task/history, BMC events and console.
5. Bind releases, schemas, firmware and recent changes.
6. Read state from each owner without mutation.
7. Trace bootstrap or workload path only where relevant.
8. Rank hypotheses against observations.
9. Change the smallest authoritative boundary.
10. Validate with a canary and original transaction.
11. Observe soak and capacity.
12. Reconcile every owner and remove temporary authority.

### Representative disposable exercise

A useful advanced lab needs either isolated physical hardware or a faithful emulator. The reviewer injects faults unknown to the learner. Management/provisioning networks cannot route to production. Credentials are lab-only. Images contain synthetic data. Power and load are bounded.

Evidence should include:

- identity graph before action;
- exact artifact and release manifest;
- BMC task/power and console timeline;
- DHCP/PXE/iPXE and agent timeline;
- inspection comparison;
- storage and root-device proof;
- installed OS/workload proof;
- injected health or capacity signal;
- recovery and exact cleanup.

### Incident handoff

A strong update sounds like:

> Deployment R for physical identity A is contained. No further power, firmware or disk actions are running. Evidence proves the BMC task finished, but observed boot stops before the ephemeral agent because UEFI receives the wrong architecture artifact on provisioning VLAN V. No production workloads are on the node. The owner is correcting one DHCP policy under rollback; next update follows one canary boot and artifact-digest proof.

It separates facts, scope, hypothesis, action and next evidence.

### What the local model cannot transfer

It does not measure BMC behavior, network latency, firmware duration, disk bandwidth, power draw, thermal response, error injection, driver compatibility or sanitization effectiveness. Those require explicit representative evidence and review.

## Reliability, security, observability, capacity, and cost

### Reliability

Design for component and correlated failures:

- controller/API/database failure;
- management switch or network failure;
- provisioning DHCP/image-service failure;
- rack/PDU/feed/cooling-zone failure;
- firmware defect across one hardware batch;
- storage/NIC model defect;
- insufficient compatible spares;
- human error acting on the wrong target set.

Availability requires a recovery path. If a BMC is unreachable, can hands-on recovery occur within objective? If a failed node contains local state, can data recover elsewhere? If firmware rollback is unsupported, is immutable rebuild or parts replacement rehearsed?

### Security

The management plane can power off machines, mount media and alter firmware. Isolate it from tenant/user networks. Use TLS validation, individual/workload identities, least privilege, short sessions, rotation, audit and break-glass review. Restrict outbound firmware/image retrieval. Protect consoles and diagnostic bundles because they may expose secrets or user data.

Secure Boot is one link. Also protect DHCP authority, iPXE scripts, kernel/initrd, image digests, metadata, callback authentication and target-disk selection.

### Observability

Monitor both workflow and truth:

- requests by operation/state/age;
- tasks pending, failed and unknown;
- requested versus observed power;
- provisioning stage latency and failure;
- artifact digest/version and agent heartbeat;
- inventory age and reconciliation drift;
- first-boot and workload readiness;
- temperatures, fans, PSU/feed, power and throttling;
- corrected errors as rate by component;
- uncorrected/fatal errors, AER and media health;
- maintenance duration, spare consumption and cleanup exceptions;
- user SLI by hardware/failure domain.

Alert on symptoms or sustained risk, not every transient state. A deployment in progress is normal until its age or user impact violates an objective.

### Capacity

Capacity is multidimensional:

```text
usable fleet = eligible hardware
             intersect required traits
             intersect failure-domain policy
             intersect healthy and non-maintenance nodes
```

Budget CPU/RAM/GPU/storage, rack units, power, cooling, switch ports, IP/DHCP space, provisioning bandwidth, controller concurrency, image-service throughput, spare parts, repair staff and lead time.

If demand is 80 eligible nodes, one rack loss removes 12, maintenance removes 5 and growth reserve is 8, owning 90 is insufficient:

```text
required = demand 80 + rack loss 12 + maintenance 5 + growth 8 = 105
```

Then repeat per hardware class. A spare CPU node cannot replace a GPU node.

### Performance

Provisioning time can be decomposed:

```text
T_total = T_queue + T_power + T_boot + T_inspect
        + T_clean + T_image + T_reboot + T_first_boot + T_workload
```

Use distributions, not averages. Image deployment may saturate the source, rack uplink or target storage. Burn-in may interfere with production power/cooling. Firmware waves may serialize on controllers.

### Cost

Include purchase, rack space, power, cooling, network ports, support, spares, firmware qualification, provisioning services, repair travel, inventory accuracy, secure disposal and engineer toil. Cheap hardware with long repair time or inconsistent firmware can cost more in reliability work.

Cost optimization must preserve failure reserve, security and recovery. Reducing spares below repair lead-time needs or sharing the management plane without compensating controls creates deferred outage risk.

### SLO and error budget

Useful fleet SLOs might cover allocation success, provisioning completion, time to ready, hardware-induced workload interruption, maintenance return-to-service and sanitization/audit completion. Define what counts, exclusions, measurement source and ownership. Do not use a controller-success metric as the user SLI.

## Traps and prevention

### Trap 1: trust the friendly name

**Prevention:** require multi-field physical identity and current owner before destructive work.

### Trap 2: use `--insecure` to “fix” Redfish

**Prevention:** repair certificate, name and trust distribution; preserve endpoint identity.

### Trap 3: retry after timeout

**Prevention:** reconcile task/operation state first; treat possible commit as unknown outcome.

### Trap 4: power cycle to collect evidence

**Prevention:** preserve tasks, events, console, OS logs and device state before reset.

### Trap 5: disable Secure Boot globally

**Prevention:** validate signed artifacts and key ownership in one bounded canary.

### Trap 6: treat DHCP as PXE success

**Prevention:** follow architecture, first/second-stage identity, downloads and callback.

### Trap 7: deploy mutable tags

**Prevention:** approve and record immutable digests and signatures.

### Trap 8: choose disks by `/dev/sdX`, model or size

**Prevention:** bind serial, WWN, controller and slot immediately before mutation.

### Trap 9: overwrite inventory drift

**Prevention:** reconcile source, freshness and physical change; quarantine unexplained drift.

### Trap 10: ignore corrected errors

**Prevention:** monitor rate and concentration; define drain/replacement thresholds.

### Trap 11: update every component in one wave

**Prevention:** use approved bundles, hardware-class canaries, per-component receipts and abort thresholds.

### Trap 12: call drain “maintenance”

**Prevention:** prove fencing, ownership, data safety, rollback/rebuild and admission criteria.

### Trap 13: run unbounded burn-in

**Prevention:** budget rack power/cooling/network, device endurance, duration and concurrent nodes.

### Trap 14: accept erase success as sanitization

**Prevention:** bind data/media/disposition, method, exact serial, verification and validation.

### Trap 15: remove only the controller record

**Prevention:** reconcile credentials, allocations, DNS, DHCP, IPAM, switch config, images, monitoring, CMDB and audit.

### Trap 16: declare mastery from a green lab

**Prevention:** require reviewer-owned unfamiliar transfer, delayed recall and representative evidence. Repository tests validate artifacts, not a person.

## Memory card and retrieval

### One-line memory card

> Prove the metal, prove the owner, follow the task, observe the state, trust the boot chain, reconcile inventory, identify the disk, prove the user, protect the fleet, and close the ownership.

### The fourteen-word chain

```text
identity -> authority -> task -> power -> boot -> agent -> inspection
-> storage -> image -> first boot -> workload -> health -> retirement -> cleanup
```

### Fast retrieval

- BMC reachable? **Who answered, for which chassis, under which trust?**
- Task accepted? **Where is terminal state and independent observation?**
- DHCP works? **Which architecture, stage, artifact and callback?**
- Disk ready? **Which serial/WWN, RAID reality and root selection?**
- Host running? **Which OS, workload, user result and health trend?**
- Maintenance done? **Was it rediscovered, canaried and readmitted?**
- Erase done? **Was method fit verified and risk validated?**

Recall this before opening a runbook. It protects you when the interface is unfamiliar.

## Complete answers

### 1. Why is a hostname insufficient before a power or disk action?

Names are reusable aliases maintained by one system. Bind chassis serial, system UUID, BMC resources, rack and controller node, plus current owner. The cost of stopping to resolve a mismatch is small; the cost of a correct destructive action on the wrong server is high.

### 2. What does a valid BMC TLS certificate prove?

It proves the endpoint presented a certificate valid under the client’s configured trust and name checks. It does not prove the Redfish System maps to the intended chassis, the caller is least privileged, sensor data is fresh or the host is healthy.

### 3. Why is HTTP 202 not operation success?

It normally means a request was accepted for asynchronous processing. Follow the task/monitor identity, terminal state and messages, then independently observe the affected component. If the client timed out, reconcile before retry because the effect may already have occurred.

### 4. Why separate requested power from observed power?

Requested power is intent; observed power is one controller/BMC reading. A task can fail, remain pending, complete while firmware hangs, or be reported from cache. Add console, agent or OS evidence to determine how far the machine progressed.

### 5. Why prefer a one-shot boot override?

It limits change to one boot and preserves the normal boot policy. Permanently moving PXE first can create boot loops, unexpected reprovisioning or dependency on a failed provisioning service. Still verify the override actually cleared afterward.

### 6. Why can DHCP work while network boot fails?

DHCP covers address and selected options. The wrong client architecture, filename, next server, TFTP/HTTP path, VLAN/MTU, TLS, artifact or iPXE second-stage policy can fail later. Trace one client identity through every stage.

### 7. What causes an iPXE chainload loop?

Firmware receives iPXE as its boot file. After iPXE starts and requests DHCP again, policy returns iPXE again rather than the real script/artifact. Differentiate firmware versus iPXE using architecture/user-class policy or an embedded script, then prove the corrected chain.

### 8. Why bind kernel and initrd digests separately from the OS image?

They execute before or outside the target image and may be served independently. A correct target image cannot protect against an altered inspection/deploy agent or wrong kernel arguments. Bind each executable artifact and its approval.

### 9. What is the difference between out-of-band and in-band inspection?

Out-of-band inspection asks the BMC/vendor model without booting the host OS. In-band inspection boots an agent and sees devices through drivers. Each can see or omit different details; reconcile both with asset records and physical changes.

### 10. Why not use `/dev/sda` as root-device identity?

It is an enumeration name influenced by discovery order and drivers. Reboots or topology changes can rename devices. Use serial, WWN, controller and slot, then confirm the resulting persistent path and boot firmware selection.

### 11. Does RAID-1 mean the server’s data is safe?

It may tolerate one member failure under stated conditions. It does not protect against deletion, corruption, controller/firmware defects, shared failure domains, rebuild failure, theft or site loss. Verify backups/restores and monitor members, cache protection and rebuild.

### 12. Why can cloud-init ignore changed user data?

Once-per-instance behavior depends on datasource and instance ID. Reusing an identity can correctly suppress modules. Inspect datasource, instance identity, stage status and logs. Do not broadly clean state or rerun modules whose actions are not safe to repeat.

### 13. Are corrected memory errors harmless?

One corrected event may have no user-visible effect, but rate and concentration matter. An accelerating count tied to one DIMM/channel, heat or workload indicates deteriorating margin. Apply policy: preserve, drain if required, test, replace and validate.

### 14. Why may BMC and Linux disagree about PCIe health?

Firmware and OS can divide AER ownership, and vendor health roll-ups may not include OS events. Bind requester/device identity and severity, preserve kernel and BMC logs, and determine whether only one transaction or the link/device became unreliable.

### 15. What makes burn-in safe?

A disposable or drained target, exact workload, duration/intensity, component and fleet baselines, rack power/cooling/network budgets, abort thresholds, maximum concurrency, evidence capture and cleanup. “Only a test node” does not prevent facility impact.

### 16. What is fencing in maintenance?

Fencing prevents new allocation or conflicting action through the authoritative control plane. It complements draining. Record who owns the fence, which operations it blocks, how emergency recovery works and the evidence required to remove it.

### 17. When is rebuild preferable to rollback?

When firmware, disk layout or configuration crossed an irreversible/ambiguous boundary and a known-good immutable rebuild provides clearer state. Rebuild is not automatically safe: prove data recovery, artifact identity, target disk, first boot and user outcome.

### 18. What is the difference between sanitization verification and validation?

Verification checks execution and results for the exact media and chosen technique. Validation is a risk decision: was the technique, evidence and result sufficient for data sensitivity, media capability and disposition? Separate roles improve challenge and auditability.

### 19. What proves a node is ready to return to service?

Exact identity and ownership, expected component/firmware inventory, no disqualifying health signals, intended boot/storage/network state, representative workload and original user checks, stable observation, capacity compliance, removed maintenance artifacts and approved admission.

### 20. What is the best first command during an unfamiliar incident?

There is no universal command. First write the failed operation, target identity, owner, time and expected result. Then choose a read-only query against the earliest uncertain owner. Commands are useful only after the question and boundary are clear.

## Product-company interview

### Scenario 1: 5,000 servers, “No valid host”

**Strong answer:** define requested resource class/traits and project; compute eligible nodes rather than total nodes; separate available/maintenance/allocation state, inventory freshness and scheduler propagation; inspect why the eligible intersection is empty. Restore one known-good eligible node or correct one proven predicate, then show backlog/queue-age recovery. Do not weaken traits globally.

**Follow-up:** What dashboard? Queue age and eligible free nodes by hardware class, owner/trust class and failure domain, with reasons candidates were excluded.

### Scenario 2: firmware rollout causes 3% boot failures

**Strong answer:** stop expansion, preserve successful/failed component/task histories, group by hardware revision and old/new bundle, drain and quarantine affected nodes, prove whether failure occurs at Secure Boot, device discovery or OS start, and use supported rollback/recovery or immutable rebuild. Resume only through a narrower canary with explicit abort thresholds.

**Follow-up:** Why not retry? Partial component progress means the second attempt does not have the same starting state.

### Scenario 3: design the BMC security plane

**Strong answer:** dedicated routed/filtered management network; no tenant reachability; per-workload/individual identities; Redfish TLS with lifecycle-managed certificates; least privilege; session expiry; secrets vault; outbound allowlist; audited console/virtual-media access; break-glass dual control; BMC baseline and patch canaries; monitoring for auth, certificate, task and inventory drift.

### Scenario 4: PXE storm after power restoration

**Strong answer:** apply admission and jitter rather than allow simultaneous boot; capacity-model DHCP, TFTP/HTTP, image storage, controller callbacks and top-of-rack links; prioritize control-plane nodes; cache immutable artifacts safely; monitor stage latency and failure; ensure normal local boot does not depend unnecessarily on PXE. Test cold-start waves.

### Scenario 5: corrected errors on a database host

**Strong answer:** bind component and rate, correlate application latency/errors, EDAC/MCE, BMC event/sensors and facility state, check redundancy and replica safety, then drain before risk crosses policy. Preserve evidence and replace/reseat only under a reviewed hardware procedure. Validate replica/user behavior afterward.

### Scenario 6: reduce provisioning from 45 to 15 minutes

**Strong answer:** decompose queue, power, boot, inspection, cleaning, image, reboot, first boot and workload times at percentiles. Optimize the dominant safe stage: concurrency, local immutable caching, image size/layout, parallel non-conflicting work or prequalified inventory. Do not skip sanitization, integrity or health gates without a risk decision.

### Scenario 7: a drive cannot execute purge

**Strong answer:** bind data classification, media type, device failure and disposition. If supported purge is unavailable or unverifiable, prevent reuse and route to approved destruction/chain of custody. Record serial, exception, method, verification and validation. Do not report a weaker clear technique as purge.

### Scenario 8: active-active provisioning controllers

**Strong answer:** controller availability is not enough. Define authoritative database/lease ownership, conductor locking/fencing, DHCP and callback routing, image consistency, task reconciliation, duplicate-action prevention and recovery from timeout after possible commit. Test controller loss during power, cleaning and image write.

### Scenario 9: mixed GPU fleet capacity

**Strong answer:** model eligible capacity per GPU model/count/memory, CPU/NUMA, NIC fabric, firmware/driver/CUDA contract, rack power/cooling and failure domain. Include maintenance and repair lead time. A general server spare cannot replace a topology-specific GPU node.

### Scenario 10: executive incident update

**Strong answer:** state user impact and scope first; then containment; what is known versus inferred; exact failed boundary; risk of action; recovery evidence; next update time. Avoid raw logs and avoid “hardware issue” until component and cause are proved.

## Independent transfer and rubric

Use `ASM-0225` only on a reviewer-owned isolated physical lab or faithful emulator. The reviewer selects hidden defects and retains stop authority. Do not rehearse using the guided case names as answers.

Before action, submit identity/ownership and refusal proof. During diagnosis, maintain a timestamped evidence table and competing hypotheses. Every mutation requires owner, target digest, blast radius, precondition, stop threshold, expected observation and rollback/rebuild boundary.

Passing requires at least 85/100 with no zero in operation/identity, safety/security, or sanitization/cleanup. A reviewer must observe recovery and cleanup. Repeating a memorized procedure without explaining evidence limits fails independence even if the node becomes green.

Repeat with a changed hardware class or failure family after delay. The book records no mastery automatically.

## References and review

All sources are paraphrased. Recheck current versions before production use.

- **REF-0958 — Redfish Specification 1.23.1:** protocol, security, sessions, tasks, events and errors.
- **REF-0959 — Redfish Data Model 2025.4:** System, Chassis, Manager, power, thermal, storage and firmware resource meanings.
- **REF-0960 — UEFI 2.11:** boot manager, device paths, network boot and Secure Boot contracts.
- **REF-0961 — iPXE chainloading:** first/second-stage boot and chainload-loop prevention.
- **REF-0962 — cloud-init NoCloud 26.2:** instance identity, seed sources, metadata and network configuration.
- **REF-0963 — Ironic installation architecture:** API, conductor, drivers, PXE/DHCP, agent and target boundaries.
- **REF-0964 — Ironic states:** stable, transitional, target, power, maintenance and failure vocabulary.
- **REF-0965 — Ironic inspection:** in-band/out-of-band inventory, prerequisites and port discovery.
- **REF-0966 — Ironic deployment:** allocation, image identity, config drive, root hints and boot mode.
- **REF-0967 — Ironic cleaning:** automated/manual steps, runbooks, traits and sanitization warning.
- **REF-0968 — Ironic RAID:** target/current layouts, physical hints, cleaning and boot limitations.
- **REF-0969 — Ironic firmware updates:** ordered components, resets, partial failure and timeouts.
- **REF-0970 — Ironic burn-in:** bounded CPU, memory, disk, network and GPU test controls.
- **REF-0971 — Ironic troubleshooting:** eligibility, maintenance, Placement, logs and recovery evidence.
- **REF-0972 — Linux RAS:** memory errors, machine checks and reliability evidence.
- **REF-0973 — Linux PCIe AER:** correctable/nonfatal/fatal semantics and firmware/OS ownership.
- **REF-0974 — Linux hwmon:** sensor interfaces, units, labels and platform-specific drivers.
- **REF-0975 — NIST SP 800-88 Rev. 2:** risk-based sanitization, verification, validation and disposition.

### Review checklist

Technical review must challenge hardware and release assumptions. Security review must challenge BMC authority, boot/image trust and evidence handling. Reliability review must challenge failure domains, spare math and recovery. Instructional review must confirm that terms precede commands, diagrams match text, answers explain why and independent work remains answer-isolated.

Representative runtime, formal acceptance, delayed recall and learner evidence remain open even when repository validation passes.
