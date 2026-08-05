---
{"schemaVersion":1,"kind":"lesson","id":"LES-0054","slug":"azure-foundations-reliability","aliases":["V05-L18","azure-foundations-reliability"],"curriculumIds":["AZR-001"],"route":"/book/infrastructure/azure-foundations-reliability","order":18,"volume":"05-infrastructure-platforms","title":"Azure foundations and reliability: follow the scope, then the user","summary":"Operate Azure from tenant and subscription governance through identity, regional networking, compute, data, monitoring, quotas, recovery and cost without mistaking portal health for service reliability.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0035","LES-0036","LES-0050","LES-0051","LES-0052"],"prerequisiteCurriculumIds":["TFM-001","CLD-001","IAM-001","CLD-002"],"testedEnvironments":[{"platform":"Microsoft Learn Azure documentation","version":"current documentation reviewed 2026-08-05","support":"concept-only","notes":"Well-Architected, resource organization, Entra, RBAC, zones, VNet, VMSS, AKS, Storage, SQL, Functions, Monitor, Key Vault, quotas and Backup reviewed; no subscription used."},{"platform":"Ubuntu","version":"24.04 normal-user local model","support":"required","notes":"Deterministic readiness model only; not an Azure emulator."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions only; no Azure SDK."}],"targetRoles":["cloud-engineer","platform-engineer","site-reliability-engineer","devops-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Map an Azure workload across tenant, management group, subscription, resource group, Region, zone, VNet and resource scopes.","Separate Entra authentication, managed identity, Azure RBAC, Azure Policy, resource data-plane authorization and Key Vault access.","Trace a user request through DNS, frontend or load balancer, network controls, compute, data and Azure Monitor evidence.","Choose VM Scale Sets, AKS, App Service or Functions by responsibility and workload constraints.","Design zone-resilient compute and data with quota, address, dependency and surviving-capacity headroom.","Distinguish Storage redundancy, SQL availability, backup, restore and disaster recovery.","Use immutable delivery, private data paths, Key Vault and least privilege without long-lived application secrets.","Build user-centered SLIs and correlate them with Azure Monitor platform and application telemetry.","Model Azure cost through compute, storage, data movement, network appliances, telemetry and recovery capacity.","Diagnose governance, identity, artifact, exposure, zone, quota, recovery and observability failures."],"productionSignals":["user operation success latency correctness freshness tenant and region cohort","tenant management group subscription resource group resource ID owner and policy assignment","principal object ID tenant token audience managed identity role definition assignment scope deny assignment and condition","activity log operation correlation ID caller scope status and change record","Region zone VNet subnet route NSG private endpoint DNS frontend backend and return path","VMSS desired running provisioning health image version upgrade and zone distribution","AKS API node Pod controller network storage identity add-on version and capacity health","Functions invocation error throttle duration instance count trigger age retries and downstream saturation","Storage account service endpoint redundancy version retention replication and restore evidence","Azure SQL endpoint connection pool zone configuration failover event backup restore and transaction SLI","Key Vault URI RBAC or access-policy mode key/secret/certificate version state and audit event","Azure Monitor metric log trace change alert rule action group and user SLI correlation","quota scope applied limit usage forecast request lead time and non-quota stock/address/dependency risk","backup vault policy recovery point immutability soft delete restore time and business validation","cost management subscription tag meter quantity data transfer log ingestion retention and commitments"],"diagrams":[{"id":"LES-0054-DIA-001","title":"Tenant-to-resource authority","direction":"hierarchical","boundaries":["Entra tenant","management group","subscription","resource group","resource","data or Key Vault plane"],"evidencePoints":["policy","principal","role assignment","scope","deny","data authorization"],"textAlternative":"Tenant identity and inherited management scopes govern resources, while a principal, role, scope, policy and service data-plane controls decide one operation."},{"id":"LES-0054-DIA-002","title":"Regional Azure request path","direction":"left-to-right","boundaries":["client and DNS","frontend or load balancer","VNet policy","compute across zones","data service","Azure Monitor"],"evidencePoints":["answer","rule","backend health","correlation ID","transaction","user SLI"],"textAlternative":"A user request selects a regional entry point, crosses network policy, reaches zonal compute and data, and emits evidence tied to the user result."},{"id":"LES-0054-DIA-003","title":"Compute responsibility ladder","direction":"hierarchical","boundaries":["VMSS","AKS","App Service or Container Apps","Functions"],"evidencePoints":["OS ownership","orchestrator ownership","runtime contract","scaling unit","upgrade boundary"],"textAlternative":"More managed compute moves host and control-plane duties to Azure but leaves the customer responsible for code, identity, data, limits, delivery and user reliability."},{"id":"LES-0054-DIA-004","title":"Data protection chain","direction":"left-to-right","boundaries":["live state","redundancy or replica","version or backup","isolated recovery point","restore environment","business validation"],"evidencePoints":["consistency","fault scope","retention","integrity","elapsed time","RPO and RTO"],"textAlternative":"Availability copies and storage redundancy are not recovery proof; a protected point must be restored and validated against business objectives."},{"id":"LES-0054-DIA-005","title":"Monitor-to-response loop","direction":"left-to-right","boundaries":["user journey","application","Azure resource","Monitor telemetry","SLO alert","operator action","verified recovery"],"evidencePoints":["SLI","correlation","metric","log or trace","burn","change","transaction"],"textAlternative":"Azure resource telemetry helps diagnosis, but response starts and ends with the user operation."},{"id":"LES-0054-DIA-006","title":"Failure-domain ladder","direction":"hierarchical","boundaries":["process","instance or replica","zone","Region","subscription or tenant","external dependency"],"evidencePoints":["detection","replacement","surviving capacity","state","traffic action","tested objective"],"textAlternative":"Each wider Azure failure domain needs explicit detection, capacity, state, routing, identity and tested recovery behavior."}],"commands":[{"id":"LES-0054-CMD-001","question":"Is the offline Azure readiness fixture valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/cases.json >/dev/null","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"exit zero","meaning":"syntax valid","nextEvidence":"semantic validation"},{"when":"nonzero","meaning":"fixture unusable","nextEvidence":"fix first parse error"}],"proves":"JSON syntax","doesNotProve":"Azure correctness"},{"id":"LES-0054-CMD-002","question":"What controls does the baseline encode?","risk":"read-only","command":"python3 model.py show fixtures/cases.json baseline","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"fields print","meaning":"review scope explicit","nextEvidence":"evaluate"},{"when":"refusal","meaning":"case invalid","nextEvidence":"inspect reason"}],"proves":"local inputs","doesNotProve":"Azure state"},{"id":"LES-0054-CMD-003","question":"Is the baseline locally operable?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json baseline","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"decision=operable","meaning":"encoded controls pass","nextEvidence":"negative cases"},{"when":"not-operable","meaning":"first boundary fails","nextEvidence":"inspect boundary"}],"proves":"deterministic result","doesNotProve":"deployment"},{"id":"LES-0054-CMD-004","question":"Is governance separated by useful scopes?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json flat-subscription","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=governance","meaning":"scope and ownership are unsafe","nextEvidence":"management group subscription resource design"}],"proves":"encoded governance fault","doesNotProve":"policy evaluation"},{"id":"LES-0054-CMD-005","question":"Does the workload avoid a long-lived client secret?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json client-secret","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=identity","meaning":"managed or federated identity absent","nextEvidence":"principal role audience and scope"}],"proves":"encoded identity fault","doesNotProve":"token behavior"},{"id":"LES-0054-CMD-006","question":"Is deployment bound to an immutable artifact?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json mutable-image","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=artifact","meaning":"runtime identity can drift","nextEvidence":"image version digest and provenance"}],"proves":"encoded artifact fault","doesNotProve":"registry or VM state"},{"id":"LES-0054-CMD-007","question":"Is the data path private by design?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json public-data","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=network-exposure","meaning":"data exposure exceeds contract","nextEvidence":"private endpoint DNS route NSG and data auth"}],"proves":"encoded exposure fault","doesNotProve":"VNet traffic"},{"id":"LES-0054-CMD-008","question":"Can a zone fail without losing the operation?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json single-zone","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=failure-domain","meaning":"zone resilience absent","nextEvidence":"surviving compute data and dependencies"}],"proves":"encoded zone fault","doesNotProve":"Azure failover"},{"id":"LES-0054-CMD-009","question":"Do quotas and resources retain failure headroom?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json quota-no-headroom","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=capacity-quota","meaning":"scaling or recovery can block","nextEvidence":"usage quota stock IPs and dependencies"}],"proves":"encoded headroom fault","doesNotProve":"regional capacity"},{"id":"LES-0054-CMD-010","question":"Has recovery been proved through restore?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json restore-untested","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=recovery","meaning":"configured backup is insufficient","nextEvidence":"isolated restore and business validation"}],"proves":"encoded restore gap","doesNotProve":"backup integrity"},{"id":"LES-0054-CMD-011","question":"Can operators observe the user outcome?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json resource-only-monitoring","runFrom":"LES-0054 support/lab","expectedBranches":[{"when":"boundary=observability","meaning":"resource health is not service reliability","nextEvidence":"transaction SLI and correlation"}],"proves":"encoded SLI gap","doesNotProve":"Monitor ingestion"},{"id":"LES-0054-CMD-012","question":"Does the Ubuntu verifier cover every case and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0054 support/lab as normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"nine cases refusals and cleanup pass","nextEvidence":"retain model boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"local teaching model","doesNotProve":"Azure tenant network compute data monitoring recovery cost or production behavior","cleanup":"Verifier proves exact UID-scoped root absent."}],"labs":[{"id":"LES-0054-LAB-001","title":"Guided Azure architecture readiness model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no Azure subscription or CLI","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one baseline and eight synthetic cases"],"abortConditions":["root","Azure credential","cloud CLI or SDK","network","provider endpoint","symlink","unknown artifact"],"recovery":"Preserve first failing boundary and correct only the copied fixture.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0054-azure-foundations-reliability/support/lab"},{"id":"LES-0054-LAB-002","title":"Independent Azure production-readiness review","mode":"independent","environment":"Reviewer-owned offline architecture packet and sanitized Terraform plan; no apply","timeMinutes":240,"privilege":"normal user","network":"none","changes":["local diagrams","capacity and recovery tables","review notes"],"abortConditions":["credential","subscription","az CLI or SDK","terraform apply","portal change","public endpoint","production data","unapproved cost"],"recovery":"Discard reviewer-owned local artifacts after scored evidence is preserved.","cleanupProof":"Reviewer proves no credential state cache provider process or Azure resource exists.","path":"drafts/LES-0054-azure-foundations-reliability/support/lab"}],"incidents":[{"id":"LES-0054-INC-001","signal":"Entra sign-in succeeds but an Azure resource operation is forbidden.","firstThought":"Authentication worked; tenant, audience, principal, role assignment, scope, deny, Policy or data-plane authorization may differ.","safePath":"Bind token claims without secrets, principal, action, resource ID, scope and correlation ID; evaluate the full control and data-plane path; change the narrowest assignment.","trap":"Grant Owner at subscription scope."},{"id":"LES-0054-INC-002","signal":"A frontend reports healthy backends while one user journey returns 5xx.","firstThought":"Probe scope is narrower than the operation; rule, cohort, deployment or dependency differs.","safePath":"Correlate host path status zone backend version and dependency; mitigate the failing cohort and verify the user SLI.","trap":"Increase probe timeout and declare recovery."},{"id":"LES-0054-INC-003","signal":"A zone failure occurs and VMSS or AKS cannot restore capacity.","firstThought":"Desired replicas are not available capacity; quota, SKU stock, max size, subnet IPs or dependency limits may block.","safePath":"Measure surviving demand, inspect provisioning/scheduling failures, protect critical traffic, use preapproved alternatives and verify the operation.","trap":"Raise desired count repeatedly."},{"id":"LES-0054-INC-004","signal":"Azure SQL or Storage control-plane availability is green but writes fail.","firstThought":"Client path, identity, private DNS, connections, throttling, consistency or application retry behavior may still fail.","safePath":"Bind one write through DNS network identity service response and transaction evidence; mitigate the earliest confirmed boundary and validate correctness.","trap":"Make the data endpoint public."},{"id":"LES-0054-INC-005","signal":"Functions instances grow while trigger age and downstream errors rise.","firstThought":"Scale and retries amplify load beyond dependency capacity.","safePath":"Graph arrivals instances executions retries age and dependency saturation; bound concurrency/retries, preserve work, recover capacity and prove drain.","trap":"Remove every scale limit."}],"assessmentIds":["ASM-0145","ASM-0146","ASM-0147"],"referenceIds":["REF-0568","REF-0569","REF-0570","REF-0571","REF-0572","REF-0573","REF-0574","REF-0575","REF-0576","REF-0577","REF-0578","REF-0579","REF-0580","REF-0581","REF-0582"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["No Azure subscription, credential, CLI, PowerShell module, SDK, API, Terraform provider, deployment or paid resource is used.","The model is not an Azure emulator and produces no provider or production evidence.","Features, quotas, availability, pricing and regional support change and require current review.","No real Entra/RBAC, Policy, network, VM, AKS, Functions, Storage, SQL, Key Vault, Monitor, backup, failover or cost evidence exists.","Formal review, publication, reviewer transfer and learner evidence remain required."]}
---

# Azure foundations and reliability: follow the scope, then the user

## What you see and first thought

The Azure portal can show a running Virtual Machine Scale Set (VMSS), healthy backend probes and an available SQL database while customers still receive errors. Remember: **the resource is not the service; the user operation is the service**.

When someone says “Azure is down,” narrow it immediately: which tenant, subscription, Region, user operation, endpoint, client cohort, time and correlation ID? A failed order can cross Microsoft Entra ID, Azure DNS, a frontend or load balancer, Virtual Network (VNet) policy, VMSS or Azure Kubernetes Service (AKS), Azure SQL, Key Vault and an external dependency. One green control-plane object proves only its own bounded state.

Use this opening map:

```text
user outcome
  -> tenant and management scope
  -> identity and authorization
  -> name, route and network policy
  -> entry point and compute
  -> data, keys and dependencies
  -> quota, failure capacity, evidence, recovery and cost
```

This is not a portal tour. It teaches the mechanisms and operating questions behind Entra ID, Azure role-based access control (RBAC), Policy, VNet, VMSS, AKS, managed application runtimes, Functions, Storage, Azure SQL, Monitor, Key Vault, quotas and Backup.

## Terms before commands

**Microsoft Entra tenant** is the identity and directory boundary that contains principals and authentication policy. A tenant is not an Azure subscription.

**Management group** is an inherited governance scope above subscriptions. **Subscription** is a policy, management, billing and quota boundary. **Resource group** is a lifecycle and authorization scope inside a subscription; it is not a network or failure boundary. A **resource ID** names an Azure Resource Manager object through this hierarchy.

**Azure Resource Manager (ARM)** is the control plane for creating and managing Azure resources. A successful ARM deployment does not prove the application data plane.

**Azure Policy** evaluates resource configuration and governance rules. Policy can audit, deny or modify according to its definition and assignment; it is not a grant of user permission. **Azure RBAC** authorizes a security principal through a role definition at a scope. Principal, role and scope are the three essential parts of a role assignment.

**Managed identity** gives an Azure resource an Entra-backed workload identity without your application storing a client secret. It does not grant access until the identity receives the required role or service authorization.

**Region** is an Azure geographic deployment location. **Availability Zone** is a separated datacenter group within a supported Region. Zone availability and service behavior vary by Region and service. A regional service is not automatically zone resilient.

**VNet** is a regional private network boundary. A **subnet** is an address range inside it. A **network security group (NSG)** filters supported traffic. A **private endpoint** places a private interface for a supported service into a VNet, but private Domain Name System (DNS), routing and service authorization remain separate.

**VMSS** manages a group of virtual machines from a common model and scaling policy. Desired instance count is intent, not proof that a SKU, quota, subnet address, image or healthy application is available.

**AKS** is managed Kubernetes. Azure manages selected control-plane responsibilities; the customer still owns workloads, Kubernetes policy, identity, networking, node or chosen compute capacity, add-ons, upgrades, data and user reliability.

**Functions** executes event-driven code on managed infrastructure. You own triggers, idempotency, concurrency, retries, timeouts, dependencies and telemetry. Scaling a function faster than a database can accept work creates an outage efficiently.

**Storage redundancy** describes where Azure Storage maintains copies under a selected option. It is an availability and durability mechanism, not a complete backup or application recovery plan.

**Azure SQL zone redundancy** changes database replica placement for supported tiers and Regions. It does not prove client reconnection, safe transaction retry, backup recovery or cross-Region disaster recovery.

**Azure Monitor** collects and analyzes platform and application telemetry through metrics, logs, traces, alerts and related services. Resource availability is diagnostic evidence; a user-centered service-level indicator (SLI) describes service reliability.

**Key Vault** stores and controls access to secrets, keys and certificates. It moves secret material out of application configuration, but you still own identity, authorization, rotation, recovery and dependency behavior.

**Quota** is a provider maximum at a documented scope. **Capacity headroom** includes quota plus SKU stock, addresses, connections, throughput and surviving failure capacity.

**Recovery point objective (RPO)** is tolerated data loss measured backward. **Recovery time objective (RTO)** is tolerated restoration time. A configured backup schedule does not prove either.

## Architecture map

Design scopes before resources:

```text
Entra tenant
└─ tenant root management group
   ├─ platform management group
   │  ├─ identity subscription
   │  ├─ connectivity subscription
   │  └─ management subscription
   ├─ production workload management group
   │  └─ order-prod subscription
   └─ non-production management group
      └─ order-test subscription

Policy assignment -> principal + role + scope -> resource/data authorization
```

Text equivalent for `LES-0054-DIA-001`: management groups and subscriptions carry inherited governance. A human or managed identity receives role assignments at explicit scopes. ARM authorization, Policy, deny assignments and service-specific data permissions can affect one request. Never treat “Contributor” as universal data access.

A regional workload then follows:

```text
client -> DNS -> Front Door/Application Gateway/load balancer as required
  -> VNet route + NSG + private endpoint/DNS
  -> VMSS, AKS, App Service or Functions across zones
  -> Storage, Azure SQL, queue or external dependency
  -> Azure Monitor + activity/resource logs + user SLI
```

Text equivalent for `LES-0054-DIA-002`: an entry service selects a backend, network and identity controls permit the exact request, compute performs data work, and correlated evidence returns to the user outcome. The exact frontend choice depends on global versus regional, layer 4 versus layer 7, web-application firewall, TLS and routing requirements.

Every diagram must label scope, state owner, failure domain, trust boundary and operating owner. “Microsoft managed” without the customer responsibility beside it is incomplete.

## Request or state path

Trace `POST /orders`:

1. Resolve the customer name and record answer, routing policy, time to live and selected frontend.
2. Terminate or pass Transport Layer Security (TLS) at the intended boundary. Bind host, path, protocol, certificate and rule.
3. Evaluate route and network policy at the tuple actually present. Private endpoints require the correct private DNS answer; an NSG allow does not grant SQL or Storage access.
4. Select a backend in a known zone and deployment version. Probe health may avoid authentication and data dependencies.
5. Execute on VMSS, AKS, App Service or Functions from an immutable artifact identity.
6. Acquire a managed-identity token for the correct audience. Apply RBAC and service data-plane authorization at the narrowest useful scope.
7. Write to Azure SQL or Storage. Record service request or correlation identity, result, throttling and application transaction state without logging secrets or regulated payload.
8. Emit application latency, correctness and correlation evidence into the monitoring path.
9. Return the user result. Only this sampled operation proves its outcome.

Desired-state changes follow another chain:

```text
reviewed source -> immutable artifact -> validated IaC plan -> approval
  -> ARM control plane -> provider/controller convergence
  -> data-plane health -> user SLI -> continue or rollback
```

A Terraform plan is evidence of proposed change under exact inputs and provider state. It is not deployment, regional stock, database migration safety or customer success.

## Failure zoom

Widen the failure domain carefully:

```text
process -> instance/Pod/function instance -> zone -> Region
        -> subscription/tenant control -> external dependency
```

Text equivalent for `LES-0054-DIA-006`: each domain needs detection, surviving capacity, state behavior, traffic action, identity access and recovery validation. Multiple replicas in one zone are not zone resilience. Zone-spread compute with zone-coupled data, egress or subnet capacity is not user-operation resilience.

If two equal zones each run at 70 percent and one fails, the survivor would need 140 percent of its former capacity. Autoscale cannot fix a maximum instance count, exhausted vCPU quota, unavailable VM SKU, subnet IP shortage, node scheduling constraint or SQL connection ceiling. Buy and test failure headroom deliberately.

Control-plane and data-plane failure also separate. ARM can report a resource provisioned while DNS, private endpoint approval, application startup or data authorization remains broken. During an identity or management-plane incident, already-running data paths may behave differently from new deployments or token acquisition. Runbooks must say which path is failing.

## Internals and state ownership

Azure resources are distributed desired-state objects. ARM accepts operations and resource providers reconcile them. Expect asynchronous operations, propagation and partial failure. Bind deployments to operation IDs, resource IDs, API versions and final provisioning state, then test the data plane.

Scope inheritance matters. Policy and RBAC assignments at management group or subscription scope affect descendants. RBAC is normally additive across assignments, but deny assignments, conditions and service-specific authorization complicate the effective result. Separate management actions from data actions. A user who can configure a Storage account is not automatically entitled to read every blob.

Entra authenticates principals and issues tokens for audiences. The application must request and validate the intended audience. Managed identity eliminates stored client-secret handling for supported Azure-hosted workloads, but role assignment propagation, token caching and dependency outages remain. Never print tokens during debugging.

VNet state lives in address spaces, subnet delegation, route tables, NSGs, private endpoints and DNS zones/links. A private endpoint can exist while the client resolves a public address. Trace both directions and the service authorization layer.

Compute responsibility changes:

```text
VMSS: customer owns image, guest OS, agents, process, upgrade and scaling policy
AKS: Azure manages selected control-plane parts; customer owns Kubernetes operations
managed app/container runtime: Azure owns more host/runtime mechanics
Functions: Azure owns execution fleet; customer owns event and dependency contract
```

Text equivalent for `LES-0054-DIA-003`: moving right reduces host work but does not remove artifact, identity, data, capacity, observability or incident ownership. Choose from workload and team constraints, not prestige.

Storage redundancy has a failure scope and replication behavior. Geographic redundancy can have replication lag and failover semantics; application consistency and recovery-point selection remain your work. Versioning, soft delete, immutability, backup and account isolation protect different threats and create different retention cost.

Azure SQL availability machinery owns service replicas according to tier and configuration. The application owns connection pools, DNS behavior, transaction idempotency and retry boundaries. A provider failover is not application recovery until a correct read/write operation succeeds.

Monitor owns configured collection and query systems. You own instrumentation, data collection rules, diagnostic settings, workspaces, dimensions, retention, alert semantics, action groups and access. The Azure activity log covers control-plane events; it is not a complete application audit trail.

Key Vault owns protected key, secret and certificate storage/operations. You own authorization mode, object versions, rotation consumers, deletion protection and application behavior during deny, throttle or outage. Backup owns recovery points under documented workloads and vault controls; you own isolation, restore order and business validation.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| principal authenticated | tenant, object ID, audience, session and expiry | requested action authorized |
| RBAC permits management action | principal, role, assignment, scope and successful operation ID | data-plane entitlement |
| Policy is compliant | definition, assignment, exemption and evaluation state | application correctness |
| private endpoint works | private DNS answer, interface, route and policy | service authorization |
| backend is healthy | exact probe contract and backend state | user path or dependency |
| VMSS or AKS can recover | provisioning/scheduling success plus quota, IP and SKU headroom | every zone or load |
| Functions invocation succeeds | invocation result | trigger backlog, duplicates or downstream health |
| Storage is redundant | selected redundancy and service state | recoverable desired version |
| SQL failover completed | service event and serving endpoint | application transaction recovered |
| Key Vault secret exists | URI, version, state and authorization | consumer rotated safely |
| Monitor alert is resolved | alert expression below threshold | user operation recovered |
| backups exist | protected recovery points and job result | integrity, isolation, RPO or RTO |
| service recovered | fresh user transaction and stable SLI/backlog | prevention or all cohorts |

Always state scope and time. “Azure is healthy” is not evidence. “Order creation in subscription X, Region Y, from 10:10 to 10:17 UTC failed for zone-2 backends after deployment Z” is a testable statement.

## Command decoders

The local lab contains only JSON and Python. It has no `az` command, Azure PowerShell, SDK, provider, token or network path.

```bash
python3 -m json.tool fixtures/cases.json >/dev/null
```

This proves JSON syntax by exit status. It does not validate field meaning.

After `bash lab.sh setup`:

```bash
python3 model.py show fixtures/cases.json baseline
python3 model.py evaluate fixtures/cases.json baseline
```

The synthetic baseline returns:

```json
{"boundary":"user-outcome","case":"baseline","decision":"operable"}
```

“Operable” means eight fixture booleans pass. It is not an Azure claim. Run each negative case:

```bash
python3 model.py evaluate fixtures/cases.json flat-subscription
python3 model.py evaluate fixtures/cases.json client-secret
python3 model.py evaluate fixtures/cases.json mutable-image
python3 model.py evaluate fixtures/cases.json public-data
python3 model.py evaluate fixtures/cases.json single-zone
python3 model.py evaluate fixtures/cases.json quota-no-headroom
python3 model.py evaluate fixtures/cases.json restore-untested
python3 model.py evaluate fixtures/cases.json resource-only-monitoring
```

The first boundaries are governance, identity, artifact, network-exposure, failure-domain, capacity-quota, recovery and observability.

In an authorized environment, provider read APIs can inspect account, role, effective route, provisioning, quota and service state. Before any command, bind tenant, subscription, identity, cloud environment, Region, risk and output sensitivity. Do not paste tokens. A resource `show` operation proves only that resource’s returned state.

## Decision path

1. Define the user operation, correctness, latency, demand, data class, SLO, RPO and RTO.
2. Map tenant, management group, subscription, resource group, Region, zone, VNet and resource ownership.
3. Map human and workload identities, token audience, role assignments, Policy and data-plane authorization.
4. Trace DNS, frontend, routes, NSGs, private endpoints and return behavior.
5. Select VMSS, AKS, managed application runtime or Functions from runtime and team constraints.
6. Bind image, container or function artifact immutably; review IaC plan, rollout and rollback.
7. Define SQL or Storage consistency, redundancy, encryption, Key Vault, retention and deletion threats.
8. Calculate peak plus zone-loss capacity, quota, SKU alternatives, subnet IPs, connections and queue drain.
9. Define user SLIs, application correlation, platform evidence, alerts and action groups.
10. Design protected backup, restore order, RPO/RTO exercise, traffic change and failback.
11. Model compute, storage, transactions, data transfer, networking, telemetry and recovery cost units.
12. Exercise identity denial, bad artifact, zone capacity and restore before production.

| Need | VMSS | AKS | managed app runtime | Functions |
|---|---|---|---|---|
| host control | high | node ownership varies | low | none |
| scheduler/API | VM model and autoscale | Kubernetes | platform application model | event/function |
| customer burden | OS through app | cluster ecosystem and app | app/runtime contract | event, code and dependency |
| scaling unit | VM | Pod/node | instance/replica | invocation instance |
| common trap | mutable guests | unjustified Kubernetes complexity | hidden runtime limits | downstream overload |

Choose the least complex option that satisfies isolation, runtime, portability, latency, compliance, hardware and team requirements.

## Guided Ubuntu lab

Environment: Ubuntu 24.04 normal user, Bash and Python 3, no network, Azure tool or credential. Mutation is one exact `/tmp/reliability-atlas-les0054-model-UID` directory. Root, credential variables, symlinks and unknown state are refused.

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh status
```

For each failed case, state the next real evidence. For `single-zone`, ask whether the user operation has compute, data, egress, IP and dependency capacity in surviving zones. For `client-secret`, do not say “rotate it” only; design managed or federated identity, narrow role scope and negative authorization tests.

```bash
bash verify.sh
# verify=pass cases=9 cleanup=true runtime=model-only
```

The verifier tests all decisions, injects an unknown artifact, proves refusal, clears only that exact artifact, cleans up and proves absence. If cleanup refuses, preserve `ls -la` and `stat` evidence; do not use `sudo` or manual recursive deletion.

## Production transfer

**Sign-in succeeds, operation forbidden.** Bind tenant, token audience, object ID, action, resource ID, role assignments and scope, deny assignments, Policy and service data authorization. Fix the narrowest owner-controlled assignment and test intended allow and deny. Granting Owner at subscription scope destroys least privilege.

**Healthy backend, intermittent 5xx.** Split by host, path, zone, backend and version. Correlate frontend, application and dependency evidence. A probe can succeed while authenticated SQL-backed requests fail. Mitigate the smallest cohort and verify the real journey.

**Zone loss, capacity does not recover.** Calculate surviving demand, then read VM provisioning or Kubernetes scheduling evidence. Inspect quota, SKU availability, maximum replicas, subnet IPs and downstream capacity. Shed optional traffic and use preapproved alternatives; repeated desired-count changes are not diagnosis.

**SQL or Storage reports available, writes fail.** Trace private DNS, route, NSG, managed identity, data role, service response, throttling and transaction behavior. Never make the endpoint public merely to bypass a misunderstood private path.

**Functions scale while backlog grows.** Put arrivals, executions, instances, retries, trigger age and dependency saturation on one timeline. Bound concurrency and retries, preserve queued work, make processing idempotent and verify backlog drain plus user outcome.

## Reliability, security, observability, capacity, and cost

Reliability is layered. Zone redundancy covers only documented zonal failure behavior. Region recovery needs replicated state, target infrastructure, identity, quota, DNS/traffic action and failback. Storage redundancy is not a chosen historical recovery point; SQL high availability is not application reconnect proof.

```text
live data -> replica/redundancy -> protected version/backup
  -> isolated restore -> dependencies -> business validation
```

Text equivalent for `LES-0054-DIA-004`: copies used for availability can share corruption or authorization risk. Recovery requires an allowed point, protected control, restore and measured RPO/RTO.

Security begins with Entra groups and privileged access governance for humans, managed or federated identity for workloads, narrow RBAC scopes, Policy as governance and private data paths. Key Vault is a dependency: monitor access, versions, rotation and deletion protection. Encryption does not replace authorization.

Observability begins with a user SLI, not VM CPU. Correlate application telemetry with Azure resource, activity and service logs. Configure diagnostic settings, collection, workspaces, retention, dimensions and action groups deliberately. Alert on actionable user risk; resource alerts aid diagnosis.

```text
user journey -> correlation ID -> app signal -> Azure resource evidence
  -> SLO alert -> bounded action -> fresh user verification
```

Text equivalent for `LES-0054-DIA-005`: Monitor supports the response loop but cannot decide what the customer operation means.

Capacity combines workload demand, VM/Pod/function throughput, scaling delay, regional quota, SKU stock, subnet IPs, data connections and dependency limits. Track current use, safe limit, zone-loss need, forecast, lead time and owner.

Cost comes from meters: compute time, requests, storage tier and retained copies, SQL service tier and I/O, public IPs, gateways/firewalls/frontends, private endpoints, inter-zone/Region egress, Monitor ingestion/retention and recovery capacity. Optimize after SLO and threat requirements are explicit. Do not silently remove failure headroom, audit logs or recoverable copies.

## Traps and prevention

| Trap | Prevention |
|---|---|
| one subscription for every workload | workload-oriented subscriptions and separated production/platform scopes |
| Policy means permission | document governance restrictions separately from RBAC grants |
| Contributor means blob or SQL data access | evaluate management actions and data actions independently |
| client secret inside CI or app settings | workload federation or managed identity and narrow RBAC |
| private endpoint means private access works | verify private DNS, route, NSG and service authorization |
| healthy probe means user success | representative user SLI plus correlated dependency evidence |
| VMSS/AKS replicas guarantee recovery | test quota, SKU, IP, zone and dependency headroom |
| geo-redundant Storage is backup | protected versions/backups and restore validation |
| zone-redundant SQL is DR | explicit Region, recovery-point, client and failback design |
| Functions scale infinitely | concurrency, queueing, idempotency and downstream protection |
| Key Vault means rotation is complete | prove consumers use new version and old access is revoked |
| every Azure metric should page | SLO-led paging and diagnostic resource alerts |
| emergency portal change is finished work | record, review and reconcile into IaC |
| cheapest single-zone design is optimization | price the SLO consequence and obtain owner decision |

## Memory card and retrieval

For any Azure workload, retrieve:

```text
tenant -> management group -> subscription -> resource group -> resource
principal + role + scope; Policy is governance, not a grant
DNS -> frontend -> VNet/NSG -> compute -> data -> user result
quota + stock + IP + dependency = useful capacity
backup + restore + business validation = recovery evidence
```

After one day, redraw the scope and request path. After one week, explain why ARM provisioning, backend health and SQL availability can all be green while a user fails. After one month, review an unseen zone-loss and restore plan. After three months, repeat after the reviewer changes Region, data residency or budget.

## Complete answers

### Why are tenant, subscription and resource group not interchangeable?

The tenant is the identity directory boundary. Management groups organize inherited governance. Subscriptions are management, billing, policy and many-quota boundaries. Resource groups collect resources for lifecycle and authorization scope. None automatically defines an application network or failure domain. A sound design chooses each boundary from ownership, isolation, policy, billing and lifecycle needs.

### Why can sign-in succeed while Azure returns forbidden?

Authentication issued a token; authorization still evaluates tenant, audience, principal, role definition, assignment scope, conditions or deny, and service-specific data access. Bind the exact principal, action, resource ID and correlation ID. Check RBAC inheritance and data-plane roles instead of granting Owner broadly.

### Why is a private endpoint not enough?

The client must resolve the service name to the private endpoint, route to it, pass network controls and authenticate/authorize to the service. Private routing does not replace TLS identity, RBAC or data authorization. Prove the name and endpoint from the failing context.

### How do you choose VMSS, AKS, a managed app runtime or Functions?

Start with host control, runtime duration, scheduling, portability, scale unit, startup latency, compliance and team skill. VMSS exposes guest control and burden. AKS provides Kubernetes capability and operational complexity. Managed app runtimes remove more host work. Functions fits bounded event-driven execution when triggers, concurrency and dependencies are controlled. Choose the simplest mechanism satisfying the contract.

### Why are redundancy and backup different?

Redundancy maintains service copies for a defined failure model. It can replicate corruption or authorized deletion. Backup or version retention provides selectable recovery points under different controls. Recovery is proved only when the chosen point restores, dependencies start in order and the business operation validates within RPO/RTO.

### What should Azure Monitor page on?

Page on actionable risk to user-centered SLOs: operation success, latency, correctness or freshness. Correlate those alerts with application and Azure platform telemetry. CPU, provisioning and quota signals can be urgent when they predict imminent user harm, but a generic resource threshold without response ownership creates noise.

## Product-company interview

**Design a regulated order API.** A strong answer defines semantics, idempotency, SLI/SLO, demand, data class, RPO/RTO, scopes, identity and private request path before naming services. It chooses compute deliberately, uses immutable delivery, zone/failure capacity, SQL or Storage protection, Monitor correlation, restore exercises and cost units. A weak answer lists Front Door, AKS and SQL without ownership or math. Follow-ups: unknown payment outcome, zone evacuation, subscription compromise, failback and audit evidence.

**Diagnose forbidden after subscription migration.** Bind tenant, object ID, audience, action, resource ID, role assignment, scope, deny and Policy/data plane. Use activity/service correlation evidence; correct the narrow assignment and test intended denial. “Grant Owner” is a weak answer. Follow-ups: propagation delay, group inheritance, managed identity token caching and break-glass.

**Healthy backends but users fail.** Define cohort and operation; split by route, zone, backend and version; correlate frontend, app and dependency evidence; mitigate the smallest cohort; verify user SLI. Restarting everything is weak. Follow-ups: sampling, one tenant, high-cardinality cost and rollout decision.

**AKS versus Functions for bursty work.** Separate synchronous and asynchronous requirements. Compare runtime, concurrency, scheduling, portability, ecosystem and team burden. Queue bursts and protect data dependencies. “AKS is enterprise” and “Functions is unlimited” are weak. Follow-ups: replay, dead-letter ownership, SQL connections and upgrade duty.

**Prove 15-minute RPO and 60-minute RTO.** Map all state, identity, keys, quota, DNS and infrastructure. In an isolated exercise choose the recovery point, restore in dependency order, deploy bound artifacts, validate security and business transactions, measure lost writes and elapsed time, then test failback. “Geo-redundancy enabled” is weak. Follow-ups: vault compromise, Key Vault loss, DNS caching and cost of faster recovery.

## Independent transfer and rubric

A reviewer supplies an unseen Azure workload and changes Region support, recovery objective, traffic, residency, Kubernetes skill or budget after the first design. Use sanitized requirements and a pre-generated plan only. No tenant credential, subscription, `az`, Azure PowerShell, SDK, provider, `terraform apply`, portal change or public endpoint.

Deliver the operation/data contract; scope and governance map; identity/RBAC/Policy/data authorization; regional request path; compute comparison; immutable rollout; data/key/backup design; zone-loss capacity and quota math; SLI/alerts/incidents; cost model; three runbooks; cleanup and provider-validation list.

| Category | Points |
|---|---:|
| workload contract | 10 |
| scope and governance | 10 |
| identity and authorization | 10 |
| network and request path | 10 |
| compute and delivery | 10 |
| data and security | 10 |
| reliability and recovery | 10 |
| capacity and quotas | 10 |
| observability and incident response | 10 |
| cost, transfer and evidence | 10 |

Below 70 means foundation gaps; 70–84 has unsafe omissions; 85–94 is a strong bounded review; 95–100 requires coherent changed-constraint reasoning. A score is not mastery without independent observation and delayed repetition.

## References and review

The fifteen Microsoft Learn records `REF-0568` through `REF-0582` cover Well-Architected design, resource organization, Entra, RBAC, zones, VNet, VMSS, AKS, Storage redundancy, Azure SQL availability, Functions, Monitor, Key Vault, quotas and Backup. All were reviewed on 2026-08-05.

Azure features, API behavior, availability zones, quotas, pricing and Region support change. Recheck the exact service, SKU, Region, subscription and billing meter before a real design. This lesson states no fixed price, quota or failover duration.

Related lessons: provider-neutral cloud architecture (`LES-0050`), identity (`LES-0051`), cloud networking (`LES-0052`), AWS reliability (`LES-0053`) and Terraform (`LES-0035`/`LES-0036`). Translate mechanisms between providers; do not rename boxes and assume equivalence.

Final summary: operate the user outcome across Azure scope, identity, path, compute, data, capacity, evidence, recovery and cost. Managed services move responsibility boundaries. They do not remove engineering ownership.
