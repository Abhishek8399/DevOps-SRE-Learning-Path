---
{"schemaVersion":1,"kind":"lesson","id":"LES-0050","slug":"cloud-architecture-provider-neutral-foundations","aliases":["V05-L14","cloud-architecture-provider-neutral-foundations"],"curriculumIds":["CLD-001"],"route":"/book/infrastructure/cloud-architecture-provider-neutral-foundations","order":14,"volume":"05-infrastructure-platforms","title":"Cloud architecture: provider-neutral foundations and failure boundaries","summary":"Reason from workload requirements to cloud ownership, hierarchy, failure domains, service models, quotas, elasticity, governance, cost, and recovery before translating the design to AWS, Azure, or Google Cloud.","domain":"infrastructure","level":{"from":"foundation","to":"expert"},"estimatedMinutes":540,"prerequisiteLessonIds":["LES-0007","LES-0010","LES-0015","LES-0037","LES-0035"],"prerequisiteCurriculumIds":["FND-001","NET-002","NET-007","IAC-001","PERF-001"],"testedEnvironments":[{"platform":"NIST SP 800-145","version":"final September 2011","support":"supported","notes":"Essential characteristics, service models and deployment models reviewed 2026-08-04."},{"platform":"AWS documentation","version":"current official documentation","support":"concept-only","notes":"Regions/zones, quotas, shared responsibility and reliability guidance reviewed 2026-08-04; no account used."},{"platform":"Microsoft Azure documentation","version":"current official documentation","support":"concept-only","notes":"Availability zones, resource hierarchy, quotas, shared responsibility and reliability guidance reviewed 2026-08-04; no subscription used."},{"platform":"Google Cloud documentation","version":"current official documentation","support":"concept-only","notes":"Locations, resource hierarchy, quotas, shared fate and reliability guidance reviewed 2026-08-04; no project used."},{"platform":"Ubuntu","version":"24.04 local normal-user model","support":"required","notes":"Deterministic architecture decision model; not a cloud emulator."}],"targetRoles":["cloud-engineer","platform-engineer","site-reliability-engineer","devops-engineer","infrastructure-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Distinguish cloud characteristics, deployment models and service models from vendor product names.","Translate workload requirements into identity, governance, network, compute, data, availability and recovery decisions.","Draw organization, account or subscription, project, region, zone, control-plane and data-plane boundaries.","Separate scalability, elasticity, availability, durability, backup and disaster recovery.","Classify global, regional, zonal and resource-scoped state and expose hidden single points of failure.","Treat quotas, API rate limits, capacity availability and provider control planes as design constraints.","Apply shared-responsibility reasoning separately to IaaS, managed platforms, serverless and SaaS.","Compare AWS, Azure and Google Cloud mechanisms without claiming false service equivalence.","Choose managed versus self-managed services from ownership, portability, expertise, SLO, recovery and cost evidence.","Create a local architecture decision record, failure table, capacity envelope and recovery proof without cloud spend."],"productionSignals":["tenant organization management hierarchy account subscription folder project and policy inheritance","human and workload identity federation roles effective permissions and break-glass audit","resource identity region zone scope lifecycle owner tags and immutable deployment revision","control-plane API availability latency throttling errors audit and reconciliation backlog","compute desired actual ready capacity placement class reservations and interruption","network routes DNS load-balancer health firewall policy NAT ports and flow evidence","data location replication lag durability class backup age restore verification RPO and RTO","quota limit usage headroom scope adjustability request lead time and allocation failure","service and dependency SLIs saturation queues retries deadlines and user journey","cost by owner environment service region unit and anomaly with pricing timestamp","provider status plus independent workload evidence and tested degraded behavior","change plan policy result rollout health rollback trigger and recovery timeline"],"diagrams":[{"id":"LES-0050-DIA-001","title":"Cloud workload evidence path","direction":"left-to-right","boundaries":["user","edge","network","compute","managed data","dependencies","provider control plane"],"evidencePoints":["SLI","route","capacity","replication","quota","API status"],"textAlternative":"A user request crosses customer-configured and provider-operated layers; each boundary has separate evidence and ownership."},{"id":"LES-0050-DIA-002","title":"Governance hierarchy comparison","direction":"hierarchical","boundaries":["enterprise identity","AWS organization/account","Azure tenant/management group/subscription/resource group","Google organization/folder/project","resource"],"evidencePoints":["policy inheritance","billing","quota scope","audit"],"textAlternative":"The providers use different governance containers, so compare policy, billing, identity and quota scope rather than matching names."},{"id":"LES-0050-DIA-003","title":"Failure-domain ladder","direction":"hierarchical","boundaries":["process","instance","rack or host","zone","region","provider","external dependency"],"evidencePoints":["blast radius","correlation","failover","data consistency","RTO"],"textAlternative":"Resilience grows only when replicas cross the failure boundary being tolerated and recovery dependencies do not share that boundary."},{"id":"LES-0050-DIA-004","title":"Shared-responsibility stack","direction":"top-to-bottom","boundaries":["data and business correctness","identity and configuration","application","runtime and operating system","virtualization","hardware and facility"],"evidencePoints":["service model","customer control","provider control","joint verification"],"textAlternative":"Moving from IaaS toward managed services transfers lower-layer operations while the customer retains data, access, configuration and outcome responsibilities."},{"id":"LES-0050-DIA-005","title":"Elasticity and quota control loop","direction":"cyclic","boundaries":["demand","signal","scaler","provider API","quota and capacity","ready supply","user SLI"],"evidencePoints":["queue","decision","throttle","allocation","readiness","cost"],"textAlternative":"Scaling succeeds only when observed demand becomes ready supply within quota, capacity, startup-time and cost constraints."},{"id":"LES-0050-DIA-006","title":"Architecture recovery loop","direction":"cyclic","boundaries":["requirements","design","failure hypothesis","local model","deployment evidence","fault exercise","ADR update"],"evidencePoints":["RPO","RTO","rollback","restore","user verification"],"textAlternative":"A cloud design is a testable hypothesis refined by bounded failure exercises and observed recovery, not a finished diagram."}],"commands":[{"id":"LES-0050-CMD-001","question":"Is the local architecture input valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/architecture.json >/dev/null","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"exit zero","meaning":"JSON is syntactically valid","nextEvidence":"schema and decision checks"},{"when":"nonzero","meaning":"input cannot be trusted","nextEvidence":"fix the first parse error"}],"proves":"JSON syntax","doesNotProve":"safe architecture"},{"id":"LES-0050-CMD-002","question":"What exact local model inputs will be evaluated?","risk":"read-only","command":"python3 model.py show fixtures/architecture.json","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"normalized fields print","meaning":"reviewer can bind the candidate inputs","nextEvidence":"evaluate cases"},{"when":"refusal","meaning":"shape or values violate model contract","nextEvidence":"inspect named reason"}],"proves":"normalized local input identity","doesNotProve":"provider state"},{"id":"LES-0050-CMD-003","question":"Which locations and replica scopes are declared?","risk":"read-only","command":"jq '{regions,zones,replicas,data_scope}' fixtures/architecture.json","runFrom":"LES-0050 support/lab with jq available","expectedBranches":[{"when":"explicit arrays and scopes","meaning":"failure-domain hypothesis is visible","nextEvidence":"correlation analysis"},{"when":"null or ambiguous","meaning":"resilience claim is unbound","nextEvidence":"repair input"}],"proves":"declared topology","doesNotProve":"actual placement"},{"id":"LES-0050-CMD-004","question":"What quota and demand headroom is declared?","risk":"read-only","command":"jq '{steady_units,peak_units,quota_units,scale_rate_per_minute,startup_minutes}' fixtures/architecture.json","runFrom":"LES-0050 support/lab with jq available","expectedBranches":[{"when":"quota exceeds required peak plus safety margin","meaning":"declared headroom exists","nextEvidence":"capacity and ramp simulation"},{"when":"quota is tight","meaning":"scale-out can fail before money or hosts run out","nextEvidence":"reduce demand or raise/partition quota"}],"proves":"declared capacity envelope","doesNotProve":"available provider capacity"},{"id":"LES-0050-CMD-005","question":"What checksum binds the reviewed architecture input?","risk":"read-only","command":"sha256sum fixtures/architecture.json","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"checksum recorded","meaning":"review and evidence can reference one input","nextEvidence":"bind outputs"}],"proves":"file-byte identity","doesNotProve":"authorship or approval"},{"id":"LES-0050-CMD-006","question":"What does the model conclude for the baseline?","risk":"read-only","command":"python3 model.py evaluate fixtures/architecture.json","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"decision=pass","meaning":"all encoded constraints pass","nextEvidence":"inject changed cases"},{"when":"decision=fail","meaning":"one or more architecture constraints fail","nextEvidence":"start with earliest named boundary"}],"proves":"deterministic model result","doesNotProve":"real cloud reliability"},{"id":"LES-0050-CMD-007","question":"Does the candidate tolerate loss of one zone?","risk":"read-only","command":"python3 model.py scenario fixtures/architecture.json zone-loss","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"survives=true","meaning":"encoded ready replicas and data cross zones","nextEvidence":"regional and dependency failures"},{"when":"survives=false","meaning":"a zonal dependency remains","nextEvidence":"identify exact state or capacity boundary"}],"proves":"modelled zone-loss outcome","doesNotProve":"real failover"},{"id":"LES-0050-CMD-008","question":"Can quota satisfy peak demand and recovery replacement?","risk":"read-only","command":"python3 model.py scenario fixtures/architecture.json quota-exhaustion","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"headroom is positive","meaning":"encoded quota permits replacement","nextEvidence":"provider capacity and startup delay"},{"when":"headroom is nonpositive","meaning":"quota blocks elasticity or recovery","nextEvidence":"redesign scope/request lead time"}],"proves":"arithmetic quota headroom","doesNotProve":"quota approval or stock"},{"id":"LES-0050-CMD-009","question":"What fails when the provider control plane is throttled?","risk":"read-only","command":"python3 model.py scenario fixtures/architecture.json api-throttle","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"serving remains bounded","meaning":"data plane can continue temporarily","nextEvidence":"backlog and recovery deadline"},{"when":"serving depends on synchronous API","meaning":"control/data plane coupling exists","nextEvidence":"remove request-path dependency"}],"proves":"encoded coupling decision","doesNotProve":"provider API behavior"},{"id":"LES-0050-CMD-010","question":"Is the managed service regional outage recoverable within objectives?","risk":"read-only","command":"python3 model.py scenario fixtures/architecture.json managed-region-outage","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"RPO and RTO pass","meaning":"encoded alternate and restore meet targets","nextEvidence":"perform real restore later"},{"when":"objective fails","meaning":"service selection or recovery design is insufficient","nextEvidence":"change objective or mechanism"}],"proves":"modelled recovery arithmetic","doesNotProve":"backup integrity"},{"id":"LES-0050-CMD-011","question":"Can inherited policy deny the proposed placement?","risk":"read-only","command":"python3 model.py scenario fixtures/architecture.json policy-denial","runFrom":"LES-0050 support/lab","expectedBranches":[{"when":"denial is predicted","meaning":"governance boundary is represented","nextEvidence":"correct design or request governed exception"},{"when":"unexpected allow","meaning":"policy inheritance may be missing","nextEvidence":"inspect hierarchy"}],"proves":"modelled policy outcome","doesNotProve":"provider effective policy"},{"id":"LES-0050-CMD-012","question":"Does the guarded Ubuntu lab cover all eight cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0050 support/lab as normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"model cases, refusals and cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate evidence is rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic local teaching model","doesNotProve":"AWS Azure Google Cloud or production behavior","cleanup":"Verifier proves exact UID-scoped temporary root absent."}],"labs":[{"id":"LES-0050-LAB-001","title":"Guided cloud architecture failure-boundary model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no cloud account","timeMinutes":180,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","eight deterministic architecture scenarios"],"abortConditions":["root","network","credential","cloud CLI session","external resource","symlink","unknown artifact"],"recovery":"Preserve the first failed constraint, correct only the copied fixture and rerun.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0050-cloud-architecture-provider-neutral-foundations/support/lab"},{"id":"LES-0050-LAB-002","title":"Independent three-provider architecture translation","mode":"independent","environment":"Local workstation, official documentation snapshots and reviewer-supplied unseen requirements","timeMinutes":240,"privilege":"normal user; no cloud credentials","network":"documentation review only when approved; exercise remains offline","changes":["architecture decision record","three-provider mechanism map","failure and recovery table","capacity and cost envelope"],"abortConditions":["cloud account creation","paid resource","credential","real customer data","unverified pricing","claim of runtime proof"],"recovery":"Keep all proposals local, version inputs, mark time-sensitive values and revise the ADR from reviewer evidence.","cleanupProof":"Reviewer verifies no cloud resources, credentials, cached tokens or external state exist.","path":"drafts/LES-0050-cloud-architecture-provider-neutral-foundations/support/lab"}],"incidents":[{"id":"LES-0050-INC-001","signal":"A zonal outage removes every application instance despite a multi-instance deployment.","firstThought":"Replica count is not failure-domain diversity; all replicas or a required data/network dependency may share one zone.","safePath":"Bind actual placement and dependency scopes, fail traffic away, preserve capacity, then redesign and test cross-zone recovery.","trap":"Increase replicas in the same zone."},{"id":"LES-0050-INC-002","signal":"Autoscaling requests fail while utilization and budget appear healthy.","firstThought":"Quota, API rate limit, regional stock, policy or instance-class availability can block requested supply.","safePath":"Bind error code, scope, quota usage, allocation class and API throttling; shed load and use pre-approved alternatives.","trap":"Raise the autoscaler maximum only."},{"id":"LES-0050-INC-003","signal":"The provider management API is throttled while current instances still serve.","firstThought":"Control-plane degradation and data-plane availability have separated; repeated automation can amplify throttling.","safePath":"Freeze nonessential changes, bound retries with jitter, monitor reconciliation age and protect existing serving capacity.","trap":"Launch many concurrent retries from every pipeline."},{"id":"LES-0050-INC-004","signal":"A regional managed database is unavailable and the application has no usable alternate.","firstThought":"Managed did not mean multi-region or restored; data location, replica mode, backup and application failover are customer design decisions.","safePath":"Invoke tested recovery, protect consistency, measure RPO/RTO, validate data and users, then repair the missing failure-domain design.","trap":"Assume the provider automatically moves all state cross-region."},{"id":"LES-0050-INC-005","signal":"A valid deployment is denied in one environment but allowed in another.","firstThought":"Inherited organization, folder, management-group, account, subscription or project policy and identity context may differ.","safePath":"Bind principal, hierarchy path, effective policy, region, quota and audit denial; correct the proposal or request a governed exception.","trap":"Grant broad administrator access until deployment succeeds."}],"assessmentIds":["ASM-0133","ASM-0134","ASM-0135"],"referenceIds":["REF-0508","REF-0509","REF-0510","REF-0511","REF-0512","REF-0513","REF-0514","REF-0515","REF-0516","REF-0517","REF-0518","REF-0519","REF-0520","REF-0521","REF-0522"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No cloud account, credentials, provider CLI session or paid resource used.","The local model is not an AWS, Azure or Google Cloud emulator.","No real quota, zone, regional outage, failover, backup or restore evidence.","Pricing, service availability, quotas and product behavior are time- and location-dependent.","Formal review, canonical publication and unseen learner evidence remain required."]}
---

# Cloud architecture: provider-neutral foundations and failure boundaries

## What you see and first thought

When someone says, “Move it to cloud and make it highly available,” do not begin with a product name. Begin with the user operation, the state that operation needs, the failure it must survive, and the evidence that will prove recovery. A cloud provider supplies programmable capacity and managed capabilities. It does not automatically supply a correct architecture.

NIST describes cloud computing through on-demand self-service, broad network access, resource pooling, rapid elasticity, and measured service. Those characteristics explain the operating model: resources can be requested through APIs, shared infrastructure is abstracted, capacity can change quickly, and consumption is measured. They do not promise unlimited stock, zero failure, automatic backups, or good security.

Your first mental sentence should be: **“Which boundary owns this state, and which failure boundary must the design cross?”** That prevents the common mistake of seeing three virtual machines and assuming resilience while all three share one zone, subnet dependency, quota, identity, database, or deployment controller.

## Terms before commands

**IaaS** gives you virtualized compute, storage, and network primitives; you usually own the guest OS, application, configuration, identity use, data, and recovery. **PaaS** or a managed service transfers more runtime and platform operation to the provider, but you still own service configuration, access, data classification, application correctness, capacity choices, recovery design, and user outcomes. **SaaS** gives a finished application surface, yet tenant configuration, identities, data handling, integration, and business continuity still need owners.

A **region** is a provider location abstraction made of one or more failure domains. A **zone** is a more isolated deployment area inside a region. The exact physical and logical behavior differs by provider and service. “Regional” can mean a resource is addressable throughout a region, not necessarily that your data and serving replicas are automatically redundant across zones.

**Scalability** is the system’s ability to handle more work by adding or enlarging resources. **Elasticity** is the controlled adjustment of supply as demand changes. **Availability** is the proportion of intended operation that succeeds. **Durability** is the probability that committed data remains intact. A replica is not a backup; synchronous replication can copy corruption, and a backup is useful only after a verified restore.

A **quota** is an enforced maximum for a resource or operation at a defined scope. A **rate limit** constrains activity over time. **Capacity availability** is whether the requested hardware or service stock actually exists. A quota of 100 does not guarantee that 100 units can be allocated now.

## Architecture map

```text
human/workload identity
          |
organization / tenant / enterprise policy
          |
account | subscription | project  ---> billing, quota, audit
          |
region ---> zone A ---> compute A ----+
       \-> zone B ---> compute B ----+--> regional service --> user
                         |             |
                    zonal state    replicated data
          |
provider control plane: APIs, schedulers, managed-service automation
```

The hierarchy answers “who may create what, where, under which bill and inherited policy?” The location topology answers “which failures are correlated?” The request path answers “what must work for a user now?” The control path answers “what must work to change or repair the system?” Keep these maps separate and connect them with evidence.

AWS commonly organizes resources through an organization and accounts. Azure uses an identity tenant plus management groups, subscriptions, resource groups, and resources. Google Cloud uses an organization, optional folders, projects, and resources. These are not line-by-line equivalents. An AWS account, Azure subscription, and Google Cloud project are all useful governance and billing boundaries, but policy inheritance, identity attachment, networking scope, quotas, and resource lifecycles differ.

| Concern | AWS lens | Azure lens | Google Cloud lens | Question that survives translation |
|---|---|---|---|---|
| top governance | Organization/OUs | tenant/root management group/management groups | organization/folders | where does policy inherit from? |
| workload boundary | account | subscription/resource group | project | what isolates billing, quota, IAM and lifecycle? |
| location | Region/AZ | region/availability zone | region/zone | what exact failure can remove all replicas? |
| identity | IAM principal/role | Entra identity/RBAC role | principal/IAM role | who is authenticated and what effective permission applies? |
| change | service APIs/CloudTrail evidence | Resource Manager/activity evidence | service APIs/audit evidence | which control plane accepted or denied the mutation? |

## Request or state path

Trace two paths. The **data path** might be client → DNS → edge/load balancer → network policy → compute → cache/database → response. The **control path** might be engineer or controller → identity federation → policy evaluation → provider API → regional scheduler → desired resource → health reporting. A control-plane outage can block deployments and scaling while existing data-plane instances continue serving. Conversely, a bad customer route or application release can break users while every provider API is green.

For each state item, record scope and owner:

| State | Typical scope | Primary operator | Recovery question |
|---|---|---|---|
| image/artifact | global or replicated registry | customer and provider service | can every recovery region pull the exact digest? |
| VM/container instance | zonal | customer scheduler plus provider | can ready replacements land elsewhere? |
| load-balancer configuration | regional or global, service-specific | shared | is health based on the real user dependency? |
| block disk | often zonal; regional options vary | shared | can it attach where replacement compute runs? |
| object data | regional, multi-region, or explicit class | shared | what are replication, consistency, delete and restore semantics? |
| managed database | service/tier-specific | shared | is failover zonal, regional, manual, automatic, and tested? |
| IAM and policy | hierarchy/global scope varies | customer controls, provider evaluates | can recovery identities act during isolation? |

The word **managed** tells you who operates some machinery. It does not tell you its scope, topology, backup policy, recovery behavior, maintenance contract, capacity, or compatibility with your application.

## Failure zoom

Start at the smallest plausible boundary, then widen only with evidence. One process can crash while its VM is healthy. One host can fail while the zone is healthy. A zone can lose power or network while the region remains usable. A regional managed service can fail while compute elsewhere remains healthy. An identity, DNS, CI/CD, quota, or third-party dependency can create a cross-region correlated failure.

Replicas protect only against failures they do not share. Two processes on one VM protect against a process crash, not a host failure. Three VMs in one zone may protect against one VM, not the zone. Three zones using one regional database may survive compute loss but not database-region loss. Two regions controlled by one broken global policy or one expired certificate can fail together.

Use a failure table before selecting products:

| Failure | Expected behavior | Required independence | Recovery evidence |
|---|---|---|---|
| instance loss | capacity replaced without user breach | separate host placement | ready capacity and user SLI |
| zone loss | traffic drains to healthy zones | compute, data and network cross zones | fault exercise plus state consistency |
| region loss | degraded or restored service within RTO | second region and independent recovery dependencies | measured failover/restore |
| API throttle | current serving continues; changes queue safely | no synchronous request-path control API | backlog, bounded retry, user SLI |
| identity-policy error | unauthorized change denied; recovery remains possible | tested break-glass and audit | negative test and approved recovery |
| quota/capacity exhaustion | shed, queue, or use approved alternate | reserved headroom and alternatives | allocation test and capacity envelope |

## Internals and state ownership

The provider control plane authenticates a request, evaluates policy and quota, validates configuration, schedules or configures underlying capacity, and records desired and observed status. It is a distributed system: acceptance can be asynchronous, retries can duplicate unsafe client behavior, status can lag, and an API success can precede resource readiness. Infrastructure automation must bind request identity, idempotency behavior, final resource identity, and observed readiness.

The data plane carries application traffic and state. Avoid synchronous calls to management APIs in the user request path. Cache stable configuration carefully, degrade when optional dependencies fail, and make serving capacity survive temporary loss of deployment/scaling control.

Shared responsibility changes by service model and by service. With a VM, the provider owns facilities, hardware and virtualization while you normally patch and configure the guest. With a managed database, the provider may patch the engine and automate replicas, but you choose topology/tier, network exposure, identities, schema, query behavior, backup retention and recovery use. With serverless, you no longer manage hosts, but concurrency, timeouts, retries, permissions, dependencies, data correctness, observability and cost remain yours.

Write a responsibility matrix using four values: **provider**, **customer**, **shared**, and **verify contract**. “Shared” must name two concrete actions; otherwise each side can assume the other owns the gap.

## Evidence table

| Claim | Minimum evidence | What it still does not prove |
|---|---|---|
| multi-zone | actual resource placement plus every required dependency scope | region survival |
| elastic | signal, scaling decision, API acceptance, ready time and user SLI | capacity during a different market event |
| within quota | current limit, usage, scope and replacement headroom | stock or increase approval |
| managed database HA | exact tier/topology, replica health and tested failover | backup restore or region recovery |
| backup works | immutable backup identity, age and successful isolated restore validation | application-wide consistency unless tested |
| least privilege | effective-policy and negative tests for named principal | absence of every escalation path |
| cost controlled | timestamped price inputs, usage units, owner and unit cost | future price or demand |
| provider healthy | status plus account/workload-specific API and data-path evidence | your configuration correctness |
| incident recovered | user SLI, data validation, restored capacity and reconciled control state | prevention until action is verified |

Evidence must be scoped. “CPU is fine” says nothing about quota, database connections, NAT ports, queue age, regional stock, or user success. “The console shows available” may be a delayed control-plane view. Tie evidence to account/subscription/project, region, zone, resource ID, timestamp, revision, principal and user operation.

## Command decoders

This lesson deliberately avoids cloud CLI commands because no account is needed. The commands inspect a local, versioned architecture contract. `python3 -m json.tool` proves syntax only. `jq` selects the fields a reviewer must discuss; it does not validate provider semantics. `sha256sum` binds the exact input used for evidence.

`model.py evaluate` checks encoded invariants: multiple zones, sufficient surviving replicas, data scope, quota headroom, scaling time, control/data-plane separation, recovery objectives, governance and cost ownership. A pass proves only that this small deterministic model agrees with its rules. It cannot discover a provider service default, account policy, hidden dependency, price change, or real capacity shortage.

Scenario commands change no cloud state. `zone-loss` removes one encoded zone; `quota-exhaustion` calculates peak and recovery headroom; `api-throttle` tests whether user serving synchronously needs the management API; `managed-region-outage` compares encoded backup/failover recovery to RPO/RTO; `policy-denial` proves that valid syntax can still be rejected by inherited governance.

When you later use a real cloud CLI, begin with identity and scope commands, then read-only inventory, effective policy, quota and plans. Never paste a deployment command from a lesson into an unknown subscription, account, project or production environment.

## Decision path

1. Define the user operation, traffic, data sensitivity, latency, availability, durability, RPO, RTO and compliance constraints.
2. Inventory dependencies and classify every state item by global, regional, zonal or resource scope.
3. Choose governance boundaries for isolation, policy inheritance, identity, billing, quota and lifecycle.
4. Select a primary region from users, data residency, service availability, latency, cost and operational support—not fashion.
5. Choose zone topology and calculate useful capacity after one-zone loss. N+1 instances are useless if the database or egress path remains zonal.
6. Map compute, network and data choices to explicit service contracts; label customer, provider and shared actions.
7. Calculate steady, peak, failure-replacement and deployment-surge demand against quota, rate, startup time and stock alternatives.
8. Design observability across user, application, dependency, provider API, quota and cost boundaries.
9. Define backups, restore, failover authority, consistency checks, rollback and communication.
10. Compare at least two provider mechanisms using the same requirements. Record why the chosen trade-off wins.
11. Model failures locally, then test in a disposable environment before production.
12. Revisit the ADR after real evidence; architecture is a maintained decision, not a one-time diagram.

## Guided Ubuntu lab

Run `bash lab.sh doctor`, then `bash lab.sh setup`. The setup creates only `/tmp/reliability-atlas-les0050-model-<uid>`, copies one JSON fixture, records a sentinel, and initializes evidence. It refuses root, non-Ubuntu 24.04, symlinks, credentials and unknown state.

Use `bash lab.sh show`, then `bash lab.sh evaluate`. Run each scenario with `bash lab.sh scenario zone-loss`, replacing the name with `quota-exhaustion`, `api-throttle`, `managed-region-outage`, `policy-denial`, `capacity-shortage`, `cost-anomaly`, and `shared-dependency`. For each, say aloud:

1. What is the earliest failing boundary?
2. Which evidence distinguishes it from the next hypothesis?
3. What action restores service without making the blast radius larger?
4. What design change would be verified later?

Finish with `bash lab.sh status` and `bash lab.sh cleanup`. The model never contacts a provider. If you cannot state what it does **not** prove, the lab is incomplete even when it prints pass.

## Production transfer

The independent exercise gives an unseen payment API with two availability objectives, regulated data, variable demand, a batch dependency, a regional managed database, and a strict recovery budget. Produce one provider-neutral design and translate it to AWS, Azure, and Google Cloud.

For each translation, identify hierarchy, identity, network, compute, load balancing, state, backup, observability, quota and audit mechanisms. Do not say that two named services are “the same.” State the exact capability required and verify each provider’s current service contract, regional availability, quota scope and pricing date.

Your deliverable includes a request path, control path, failure-domain map, shared-responsibility matrix, quota/capacity envelope, recovery sequence, cost model, risk register and ADR. The reviewer changes one requirement after submission—for example data residency, RTO, traffic, or team expertise. Revise the design without hiding the resulting trade-off.

No account creation or cloud deployment is part of this lesson. Later provider-specific chapters can turn approved designs into read-only plans and disposable runtime evidence.

## Reliability, security, observability, capacity, and cost

**Reliability:** size healthy capacity after the chosen failure, not before it. If three zones each hold one-third of load, the remaining two must absorb the failed third without crossing the latency knee. Design retries, timeouts, idempotency and load shedding so failover does not overload survivors. Multi-region adds data consistency, DNS/routing, dependency and operator complexity; use it only when objectives justify it.

**Security:** centralize human federation, prefer short-lived workload identity, deny broad standing privilege, separate production boundaries, log control-plane actions, and test explicit denials. Encryption is not complete without key ownership, rotation, recovery and authorization. Public endpoints are not automatically wrong, and private endpoints are not automatically safe; trace the reachable path and identity.

**Observability:** combine provider signals with independent user journeys. Monitor quota headroom, allocation errors, API throttling, scaling lag, health-check quality, replication lag, backup age, restore results, identity denials, cost anomalies and dependency SLIs. Provider status pages are useful context, not workload proof.

**Capacity:** calculate `required = peak + failed-domain replacement + deployment surge + uncertainty`. Separate quota from capacity availability. Record instance or service class alternatives, reservation decisions, startup time, image/data transfer time, and manual approval lead time.

**Cost:** measure cost per useful unit—request, transaction, tenant, build minute, or stored durable unit—not only monthly total. Include data transfer, idle redundancy, logs, backups, support, licensing, operations labor and recovery capacity. Timestamp prices and show uncertainty. The cheapest steady state can be the most expensive incident design.

## Traps and prevention

- **Trap:** Cloud means infinite capacity. **Prevention:** model quota, API rate, regional stock, startup time and reservation options.
- **Trap:** Three instances mean HA. **Prevention:** prove placement and every required dependency across the intended failure domain.
- **Trap:** Regional means zone redundant. **Prevention:** verify each service’s exact topology and configured tier.
- **Trap:** Managed means no operations. **Prevention:** write the customer/provider action matrix and test recovery.
- **Trap:** Autoscaling is instant. **Prevention:** measure signal delay, decision delay, API delay, provisioning, boot, warm-up and readiness.
- **Trap:** Multi-region is always better. **Prevention:** justify it from objectives, consistency, complexity, cost and tested authority.
- **Trap:** Quota equals capacity. **Prevention:** maintain approved alternatives and observe allocation failures.
- **Trap:** Provider status is truth. **Prevention:** pair it with scoped APIs and user evidence.
- **Trap:** Service-name mapping is architecture. **Prevention:** compare required mechanisms and contracts.
- **Trap:** Replication is backup. **Prevention:** keep independent recovery copies and prove restore plus data validation.

## Memory card and retrieval

Remember **SCOPE → OWNER → FAILURE → HEADROOM → RECOVERY → USER**.

- Scope: where do identity, policy, quota, resource and data live?
- Owner: which customer and provider actions are explicit?
- Failure: what correlated boundary can remove the service?
- Headroom: can survivors, quota and stock carry failure plus surge?
- Recovery: what restore/failover is authorized, measured and reversible?
- User: which operation proves the system is useful again?

Tomorrow, answer without notes: Why is a regional resource not automatically zone resilient? Why is quota different from stock? What remains your responsibility in serverless? Why can control-plane failure leave users unaffected temporarily? When is multi-region unjustified?

## Complete answers

**Is cloud just somebody else’s computer?** That phrase reminds you the hardware exists, but it hides the important operating model: on-demand APIs, pooled resources, rapid elasticity, measured consumption, managed services, global location choices and a shared responsibility boundary. Treat cloud as a programmable distributed system with commercial and governance contracts.

**How do I choose IaaS versus managed service?** Compare the undifferentiated operations transferred against loss of control, portability, service constraints, data behavior, team expertise, observability, failure modes, recovery, security integration, quotas and total cost. Managed is often the right default when the service contract meets the workload, but not when a critical requirement is absent or exit/recovery risk is unacceptable.

**Does multi-zone guarantee high availability?** No. Compute may span zones while storage, database, NAT, load balancer configuration, secrets, identity, DNS, quota or deployment capacity remains a shared dependency. Prove actual topology and run the failure.

**Does multi-region guarantee disaster recovery?** No. Regions can share global identity, policy, DNS, artifact supply, certificates, operators and software defects. Data replication can also make failover unsafe. DR requires objectives, independent prerequisites, authority, validated data and measured exercises.

**What should I do on quota failure?** Bind the exact resource, scope, requested amount, current usage, limit, adjustability and allocation error. Protect users through load shedding, queues or an approved alternate. A quota increase is a capacity-planning workflow with lead time, not an incident-time certainty.

**Who secures a managed service?** The provider secures and operates defined underlying layers; you secure identities, authorization, network/configuration choices, application use, data, monitoring and recovery responsibilities described by the contract. “Shared” must be decomposed into named controls and evidence.

## Product-company interview

**Question:** Design a highly available payment API in public cloud with a 99.95% monthly availability objective, traffic that can triple in ten minutes, regulated data that must remain in one country, and an RTO of two hours for regional loss.

**Strong answer:** I first clarify the user operation, durability, maximum tolerable data loss, consistency and dependency objectives. I separate organization and production boundaries, federate humans, use workload identity and record effective policy. The request path spans at least two zones with independent compute placement, zonally resilient load balancing and a data tier whose documented configuration tolerates zone loss. I size survivors for peak after one-zone loss and include deployment surge, quota, startup time, provider stock alternatives and load shedding. The regional objective needs a second compliant region or a tested restore path; I bind artifact, configuration, keys, networking, DNS/routing, backups and operator authority and measure RPO/RTO. I monitor user success, tail latency, saturation, allocation failures, quota, replication, backup/restore, API throttling and cost per transaction. I compare provider mechanisms only after this contract and record any service-specific limitation in an ADR.

**Weak answer:** Put three servers behind a load balancer, enable autoscaling, and use a managed database because the cloud handles failures.

The weak answer has no location proof, data topology, quota, scaling delay, shared responsibility, security, recovery, cost or user evidence.

## Independent transfer and rubric

`ASM-0135` contains the reviewer-only assessment. The reviewer changes traffic, residency or recovery requirements and injects an unseen combination of zonal placement, tight quota, inherited policy, control-plane throttling, regional data failure and misleading green provider status.

The learner must produce provider-neutral reasoning first, then three accurate translations. Evidence must bind source dates, assumptions, scope, identities, failure domains, capacity arithmetic, recovery sequence, data validation, user SLI and absence of cloud resources. A polished diagram without failure and recovery proof does not pass.

Reading this chapter, passing the deterministic model, or naming services does not award mastery. Independent evidence needs reviewer observation, an unseen changed case, defensible trade-offs, delayed retrieval and later runtime work in a disposable environment.

## References and review

Fifteen primary sources cover the NIST cloud definition and current AWS, Microsoft Azure and Google Cloud documentation for failure domains, hierarchy, quotas, shared responsibility and reliability. They were reviewed on 2026-08-04 and require review by 2027-02-04.

Provider services, location availability, quotas, defaults, pricing and contracts change. Before implementing a design, bind the provider, account boundary, region, service, tier, API version, documentation revision and price date. The next chapters deepen identity, cloud networking and provider-specific architecture; this lesson remains the reasoning spine that prevents logo-driven design.
