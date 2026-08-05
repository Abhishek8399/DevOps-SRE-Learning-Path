---
{"schemaVersion":1,"kind":"lesson","id":"LES-0055","slug":"gcp-foundations-reliability","aliases":["V05-L19","gcp-foundations-reliability"],"curriculumIds":["GCP-001"],"route":"/book/infrastructure/gcp-foundations-reliability","order":19,"volume":"05-infrastructure-platforms","title":"Google Cloud foundations and reliability: follow the project, then the request","summary":"Operate Google Cloud from organization and project governance through identity, global networking, regional compute, data, monitoring, quotas, recovery and cost without mistaking resource health for user reliability.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0035","LES-0036","LES-0050","LES-0051","LES-0052"],"prerequisiteCurriculumIds":["TFM-001","CLD-001","IAM-001","CLD-002"],"testedEnvironments":[{"platform":"Google Cloud documentation","version":"current primary documentation reviewed 2026-08-05","support":"concept-only","notes":"Reliability, resource hierarchy, IAM, workload identity, VPC, regional MIG, GKE, Cloud Storage, Cloud SQL, Cloud Run, functions, Monitoring, KMS, quotas and DR documentation reviewed; no project used."},{"platform":"Ubuntu","version":"24.04 normal-user local model","support":"required","notes":"Deterministic readiness model only; not a Google Cloud emulator."},{"platform":"Python","version":"3 standard library","support":"required","notes":"Local JSON decisions only; no Google Cloud SDK."}],"targetRoles":["cloud-engineer","platform-engineer","site-reliability-engineer","devops-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Map a Google Cloud workload across organization, folder, project, billing, global, regional, zonal and resource scopes.","Separate authentication, federation, service accounts, IAM allow and deny policies, organization policy and service data authorization.","Trace a user request through DNS, a chosen load balancer, global VPC, regional subnet, policy, compute, data and telemetry.","Choose regional managed instance groups, GKE or Cloud Run by workload contract, responsibility and team constraints.","Design zone-resilient compute and data with quota, stock, address, dependency and surviving-capacity headroom.","Distinguish Cloud Storage location, Cloud SQL availability, replication, backup, restore and disaster recovery.","Use immutable delivery, private data paths, federation and Cloud KMS without long-lived service-account keys.","Build user-centered SLIs and correlate them with Monitoring, Logging, Trace, audit and change evidence.","Model Google Cloud cost through compute, storage, operations, data movement, networking, telemetry, keys and recovery capacity.","Diagnose governance, identity, artifact, exposure, zone, quota, recovery and observability failures."],"productionSignals":["user operation success latency correctness freshness project region and cohort","organization folder project number project ID billing account labels owner and lifecycle","principal subject audience service account workload identity pool provider role permission condition deny and resource","Cloud Audit Logs method caller resource project status request ID and change record","DNS answer load-balancer scope VPC subnet route firewall NAT private access endpoint and return path","MIG target running healthy template version update action zone distribution and autoscaler recommendation","GKE mode control-plane scope node pool Pod controller network storage identity add-on version and capacity health","Cloud Run revision digest traffic concurrency instance count cold start request timeout and downstream saturation","Cloud Storage bucket location access mode version retention replication and restore evidence","Cloud SQL endpoint connections HA state failover event replica lag backup restore and transaction SLI","Cloud KMS location key ring key version state rotation IAM use and audit event","Monitoring metric log trace synthetic check SLO alert incident and user correlation","quota metric scope limit usage forecast adjustment lead time and non-quota stock/address/dependency risk","recovery point isolation retention restore order elapsed time data reconciliation achieved RPO and RTO","billing export project label SKU usage amount data transfer logging retention commitments and unit owner"],"diagrams":[{"id":"LES-0055-DIA-001","title":"Organization-to-resource authority","direction":"hierarchical","boundaries":["organization","folder","project","service resource","data plane"],"evidencePoints":["policy","principal","role","permission","condition or deny","audit"],"textAlternative":"Organization, folder and project ancestry carries policy while a principal, role, permission and service control decide one resource operation."},{"id":"LES-0055-DIA-002","title":"Global-to-regional request path","direction":"left-to-right","boundaries":["client and DNS","load balancer","global VPC and regional subnet","zonal compute","managed data","Cloud Operations"],"evidencePoints":["answer","frontend","route and firewall","backend","transaction","user SLI"],"textAlternative":"A request reaches a global or regional frontend, crosses a global VPC and regional subnet to zone-spread compute and data, then emits evidence tied to the user result."},{"id":"LES-0055-DIA-003","title":"Compute responsibility ladder","direction":"hierarchical","boundaries":["Compute Engine regional MIG","GKE Standard or Autopilot","Cloud Run service job or worker","Cloud Run function"],"evidencePoints":["host ownership","orchestrator ownership","runtime contract","scaling unit","upgrade boundary"],"textAlternative":"Managed compute removes selected host and control-plane work, but the customer keeps responsibility for code, identity, data, limits, delivery and user reliability."},{"id":"LES-0055-DIA-004","title":"Data protection chain","direction":"left-to-right","boundaries":["live state","availability replica","version or backup","isolated recovery point","restore environment","business validation"],"evidencePoints":["consistency","fault scope","retention","integrity","elapsed time","RPO and RTO"],"textAlternative":"Regional or multi-region placement and database standby improve availability but recovery is proved only by restoring protected state and validating the business operation."},{"id":"LES-0055-DIA-005","title":"Telemetry-to-response loop","direction":"left-to-right","boundaries":["user journey","application","Google Cloud resource","Monitoring Logging Trace","SLO alert","operator action","verified recovery"],"evidencePoints":["SLI","correlation","metric","log or trace","burn","change","transaction"],"textAlternative":"Resource telemetry explains components, while response begins and ends with a user operation and a verified recovery."},{"id":"LES-0055-DIA-006","title":"Failure-domain ladder","direction":"hierarchical","boundaries":["process","instance or Pod","zone","region","project or organization policy","external dependency"],"evidencePoints":["detection","replacement","surviving capacity","state","traffic action","tested objective"],"textAlternative":"Each wider failure domain needs explicit detection, spare capacity, state protection, routing, identity and tested recovery behavior."}],"commands":[{"id":"LES-0055-CMD-001","question":"Is the offline GCP readiness fixture valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/cases.json >/dev/null","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"exit zero","meaning":"syntax valid","nextEvidence":"semantic validation"},{"when":"nonzero","meaning":"fixture unusable","nextEvidence":"fix first parse error"}],"proves":"JSON syntax","doesNotProve":"Google Cloud correctness"},{"id":"LES-0055-CMD-002","question":"What controls does the baseline encode?","risk":"read-only","command":"python3 model.py show fixtures/cases.json baseline","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"fields print","meaning":"review scope explicit","nextEvidence":"evaluate"},{"when":"refusal","meaning":"case invalid","nextEvidence":"inspect reason"}],"proves":"local inputs","doesNotProve":"provider state"},{"id":"LES-0055-CMD-003","question":"Is the baseline locally operable?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json baseline","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"decision=operable","meaning":"encoded controls pass","nextEvidence":"negative cases"},{"when":"not-operable","meaning":"first boundary fails","nextEvidence":"inspect boundary"}],"proves":"deterministic result","doesNotProve":"deployment"},{"id":"LES-0055-CMD-004","question":"Are projects governed by useful ownership and policy scopes?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json project-sprawl","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=governance","meaning":"hierarchy and ownership are unsafe","nextEvidence":"organization folder project and billing design"}],"proves":"encoded governance fault","doesNotProve":"organization policy"},{"id":"LES-0055-CMD-005","question":"Does the workload avoid a long-lived service-account key?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json service-account-key","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=identity","meaning":"federated or attached identity absent","nextEvidence":"principal audience role and resource"}],"proves":"encoded identity fault","doesNotProve":"token exchange"},{"id":"LES-0055-CMD-006","question":"Is deployment bound to an immutable artifact?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json mutable-image","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=artifact","meaning":"runtime identity can drift","nextEvidence":"image digest provenance template and revision"}],"proves":"encoded artifact fault","doesNotProve":"Artifact Registry or runtime state"},{"id":"LES-0055-CMD-007","question":"Is the data path private by design?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json public-data","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=network-exposure","meaning":"exposure exceeds contract","nextEvidence":"private path DNS route firewall perimeter and data authorization"}],"proves":"encoded exposure fault","doesNotProve":"VPC traffic"},{"id":"LES-0055-CMD-008","question":"Can a zone fail without losing the operation?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json single-zone","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=failure-domain","meaning":"zone resilience absent","nextEvidence":"surviving compute data and dependencies"}],"proves":"encoded zone fault","doesNotProve":"provider failover"},{"id":"LES-0055-CMD-009","question":"Do quotas and resources retain failure headroom?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json quota-no-headroom","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=capacity-quota","meaning":"scaling or recovery can block","nextEvidence":"usage limit stock reservations IPs and dependencies"}],"proves":"encoded headroom fault","doesNotProve":"regional capacity"},{"id":"LES-0055-CMD-010","question":"Has recovery been proved through restore?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json restore-untested","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=recovery","meaning":"configured protection is insufficient","nextEvidence":"isolated restore reconciliation and business validation"}],"proves":"encoded restore gap","doesNotProve":"backup integrity"},{"id":"LES-0055-CMD-011","question":"Can operators observe the user outcome?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json resource-only-monitoring","runFrom":"LES-0055 support/lab","expectedBranches":[{"when":"boundary=observability","meaning":"resource health is not service reliability","nextEvidence":"transaction SLI and correlation"}],"proves":"encoded SLI gap","doesNotProve":"telemetry ingestion"},{"id":"LES-0055-CMD-012","question":"Does the Ubuntu verifier cover every case and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0055 support/lab as normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"nine cases refusals and cleanup pass","nextEvidence":"retain model boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"local teaching model","doesNotProve":"Google Cloud organization identity network compute data monitoring recovery cost or production behavior","cleanup":"Verifier proves exact UID-scoped root absent."}],"labs":[{"id":"LES-0055-LAB-001","title":"Guided Google Cloud architecture readiness model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no Google Cloud account or CLI","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one baseline and eight synthetic cases"],"abortConditions":["root","Google Cloud credential","cloud CLI or SDK","network","provider endpoint","symlink","unknown artifact"],"recovery":"Preserve first failing boundary and correct only the copied fixture.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0055-gcp-foundations-reliability/support/lab"},{"id":"LES-0055-LAB-002","title":"Independent Google Cloud production-readiness review","mode":"independent","environment":"Reviewer-owned offline architecture packet and sanitized Terraform plan; no apply","timeMinutes":240,"privilege":"normal user","network":"none","changes":["local diagrams","capacity and recovery tables","review notes"],"abortConditions":["credential","billing account or project","gcloud or SDK","terraform apply","console change","public endpoint","production data","unapproved cost"],"recovery":"Discard reviewer-owned local artifacts after scored evidence is preserved.","cleanupProof":"Reviewer proves no credential state cache provider process or Google Cloud resource exists.","path":"drafts/LES-0055-gcp-foundations-reliability/support/lab"}],"incidents":[{"id":"LES-0055-INC-001","signal":"Federated authentication succeeds but a Google Cloud resource operation is denied.","firstThought":"Authentication worked; principal, audience, permission, role, ancestry, condition, deny, organization policy, perimeter or data authorization may differ.","safePath":"Bind claims without secrets, principal, permission, resource, project and audit request; evaluate every applicable policy layer; change the narrowest approved control.","trap":"Grant project Owner or create a service-account key."},{"id":"LES-0055-INC-002","signal":"A load balancer reports healthy backends while one user journey returns 5xx.","firstThought":"Health-check scope is narrower than the operation; host, path, cohort, revision or dependency differs.","safePath":"Correlate request ID, host, path, status, region, zone, backend version and dependency; mitigate the failing cohort and verify the SLI.","trap":"Relax the health check and declare recovery."},{"id":"LES-0055-INC-003","signal":"A zone fails and a regional MIG or GKE cluster cannot restore useful capacity.","firstThought":"Desired replicas are not available capacity; quota, stock, reservation, maximum size, addresses, scheduling or dependencies may block.","safePath":"Measure surviving demand, inspect create and schedule failures, protect critical traffic, use preapproved alternatives and verify the operation.","trap":"Raise target size repeatedly."},{"id":"LES-0055-INC-004","signal":"Cloud SQL or Cloud Storage resource state is available but writes fail.","firstThought":"Client path, IAM, private DNS, perimeter, connections, throttling, consistency or retry behavior may still fail.","safePath":"Bind one write through name, route, identity, service response and transaction evidence; mitigate the earliest confirmed boundary and validate correctness.","trap":"Expose the data service publicly."},{"id":"LES-0055-INC-005","signal":"Cloud Run instances grow while queue age and downstream errors rise.","firstThought":"Autoscaling and retries are amplifying arrivals beyond dependency capacity.","safePath":"Graph arrivals, instances, concurrency, executions, retries, age and dependency saturation; bound concurrency and retries, preserve work, recover capacity and prove drain.","trap":"Remove every scale and concurrency limit."}],"assessmentIds":["ASM-0148","ASM-0149","ASM-0150"],"referenceIds":["REF-0583","REF-0584","REF-0585","REF-0586","REF-0587","REF-0588","REF-0589","REF-0590","REF-0591","REF-0592","REF-0593","REF-0594","REF-0595","REF-0596","REF-0597"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["No Google Cloud organization, billing account, project, credential, CLI, SDK, API, Terraform provider, deployment or paid resource is used.","The model is not a provider emulator and produces no Google Cloud or production evidence.","Features, quotas, availability, pricing and regional support change and require current review.","No real IAM, VPC, load balancer, MIG, GKE, Cloud Run, Storage, SQL, KMS, Monitoring, backup, failover or cost evidence exists.","Formal review, publication, reviewer transfer and learner evidence remain required."]}
---

# Google Cloud foundations and reliability: follow the project, then the request

## What you see and first thought

The console can show a green regional managed instance group, an available Cloud SQL instance and passing backend health checks while customers still cannot place an order. Keep this sentence close: **a healthy resource is evidence about one component; a successful user operation is evidence about the service**.

When someone says “GCP is down,” do not open random dashboards. Narrow the statement:

- Which user operation failed?
- Which project number, region, client cohort, endpoint and time window?
- Was the failure an authorization denial, name-resolution error, network path break, capacity refusal, dependency error or bad result?
- What request, trace or audit identifier joins the evidence?

A single order can cross Cloud DNS, a global or regional load balancer, a global Virtual Private Cloud (VPC) network, a regional subnet, firewall policy, a managed instance group (MIG), Google Kubernetes Engine (GKE) or Cloud Run, Cloud SQL, Cloud Storage, Cloud Key Management Service (KMS), and an external payment service. The resource hierarchy and Identity and Access Management (IAM) decide who may change or call parts of that path.

Read the service in this order:

```text
user outcome
  -> organization, folder and project ownership
  -> identity, role, permission and policy
  -> DNS, frontend, route and firewall
  -> regional and zonal compute
  -> state, keys and dependencies
  -> quota, failure capacity, telemetry, recovery and cost
```

This chapter is not a console tour. It teaches the questions that remain useful when product names or user interfaces change.

## Terms before commands

**Organization resource** is the root of a managed Google Cloud resource hierarchy. **Folders** group projects and provide inherited policy attachment points. A **project** is the main resource, API, IAM, quota and billing-association boundary for workloads. A project is not a network packet boundary and is not automatically a failure boundary.

Each project has a human-readable name, a globally unique project ID and an immutable project number. During incidents, prefer immutable identifiers in evidence. Similar names such as `orders-prod` and `orders-production` are too easy to confuse.

A **billing account** pays for linked projects. Linking a project to billing does not grant workload access, design cost controls or prove that every service is enabled. A **service API** must be enabled in the relevant project before its resources can be used.

**IAM** answers “which principal may use which permissions on which resource?” A **principal** can represent a human, group, service account or federated identity. A **permission** names an allowed operation. A **role** is a collection of permissions. An **allow policy** binds principals to roles on a resource and can be inherited from ancestors.

IAM also has controls that do not behave like allow bindings. **Deny policies** can block permissions that an allow policy otherwise grants. A **principal access boundary** constrains the resources a principal is eligible to access. **Organization Policy** constrains resource configuration; it is governance, not an IAM grant. **VPC Service Controls**, where adopted, reduce data-exfiltration paths around supported services; they do not replace IAM or firewall policy.

A **service account** is a Google Cloud workload identity. A downloadable service-account key is a long-lived private credential and creates a rotation and leak problem. Prefer an attached service identity or Workload Identity Federation when the platform and workload support it. Federation replaces stored private keys with short-lived credential exchange, but you must still validate issuer, audience, subject mapping and authorization.

A Google Cloud **VPC network is global**, while its subnets are regional. This differs from providers whose virtual network itself is regional. Routes and firewall controls determine reachability; a subnet entry alone does not. **Shared VPC** lets centrally governed host-project networks serve workloads in attached service projects, separating network administration from workload ownership.

A **zone** is a failure and placement domain inside a region. A **regional MIG** spreads VM instances across multiple zones and manages them from an instance template. Target size is desired state, not a promise that quota, stock, addresses, image access and dependencies can supply healthy application capacity.

**GKE Standard** leaves more node and cluster choices with the customer. **GKE Autopilot** moves more node management to Google under an opinionated operating model. Autopilot clusters are regional in the documentation reviewed for this lesson. Neither mode owns your application correctness, Kubernetes policies, dependencies, data or SLO.

**Cloud Run** runs containers as services, jobs or worker pools. A service handles requests; a job runs to completion; a worker pool handles continuous pull-based work. A function is a source-oriented event or HTTP entry that runs on the managed Cloud Run platform. Managed scaling does not make a handler idempotent or a database infinitely elastic.

**Cloud Storage location** chooses regional, dual-region or multi-region placement. Availability, durability, data residency, performance, replication timing and price differ. Redundancy is not the same as an independent backup.

**Cloud SQL high availability** is engine- and configuration-specific. In the MySQL HA model reviewed here, a regional instance has a primary and standby across zones with synchronous persistence. That reduces selected failures; it does not prove client reconnection, transaction replay safety, backup restoration or cross-region DR.

**Cloud KMS** organizes location-bound key rings, keys and versions. Customer-managed encryption keys (CMEK) increase control and also add IAM, location, rotation, availability and deletion dependencies. “We use KMS” is not a lifecycle.

**Quota** is an enforced usage ceiling, often scoped by project, region or API. A **system limit** is fixed. Neither guarantees that the requested machine type or resource stock is available at incident time.

## Architecture map

Begin with authority and ownership, not a service catalog:

```text
organization
├─ folder: platform
│  ├─ project: shared-vpc-host
│  ├─ project: security-and-keys
│  └─ project: central-observability
├─ folder: production
│  ├─ project: orders-prod
│  └─ project: payments-prod
└─ folder: non-production
   └─ project: orders-test

ancestor policy
  -> principal + role + permission + resource
  -> service-specific data authorization and audit
```

Text equivalent for `LES-0055-DIA-001`: organization, folder and project ancestry supplies lifecycle ownership and inherited policy. An authenticated principal still needs the relevant permission on the intended resource. Conditions, deny policy, access boundaries, organization policy, service perimeters and service-specific controls can narrow the result.

Projects should make operating boundaries clear. Separate a workload because it needs independent ownership, lifecycle, policy, quota, blast radius or cost accountability—not because every microservice deserves a project. Too few projects create one enormous failure and permission domain; too many create policy drift, quota fragmentation and operational overhead.

Network architecture can cross projects without abandoning ownership:

```text
internet client
  -> Cloud DNS answer
  -> chosen global or regional load balancer
  -> backend service and health policy
  -> global Shared VPC
  -> regional subnet + route + firewall
  -> zone A/B/C compute
  -> private managed-data path
  -> response through a valid return path
```

Text equivalent for `LES-0055-DIA-002`: the frontend’s scope, VPC’s global scope, subnet’s regional scope, backend’s zone placement and data service’s location are distinct. Draw every boundary. “Same project” does not prove reachability, and “same VPC” does not prove authorization.

## Request or state path

Trace one request with evidence at each hop.

1. The client resolves the intended name. Record resolver context, answer, record type and time-to-live.
2. The selected frontend accepts the protocol, host and path. Identify whether it is global or regional and where TLS terminates.
3. The load-balancer routing rule selects a backend service. A health check usually exercises a smaller path than a real order.
4. The packet crosses VPC routes and firewall controls into a regional subnet. For Shared VPC, record host and service project ownership.
5. A MIG instance, GKE Pod or Cloud Run revision processes the request. Record immutable artifact or revision identity.
6. The workload obtains short-lived identity and calls Cloud SQL, Cloud Storage, KMS or another service through the intended private or restricted path.
7. The dependency returns a result. The application handles timeout, retry, partial success and idempotency.
8. The service returns a correct response and emits a request or trace identifier that joins application, platform and audit evidence.

Production read-only command patterns might include:

```bash
gcloud projects describe PROJECT_ID --format=json
gcloud projects get-iam-policy PROJECT_ID --format=json
gcloud compute networks describe NETWORK --project=HOST_PROJECT --format=json
gcloud compute instance-groups managed list-instances MIG --region=REGION --project=PROJECT_ID
```

Do not run these from the local lab. They require explicit authorization, a configured identity and verified project context. Before any command, display the active account and project without exposing credentials. Prefer `--format=json` for preserved evidence, and sanitize principal or resource data before sharing it.

For state, trace writes rather than merely reading “available”:

```text
client intent
  -> authenticated request
  -> application validation
  -> transaction or object write
  -> commit acknowledgement
  -> replication or standby state
  -> backup/recovery point
  -> restore
  -> business reconciliation
```

Availability copies protect selected infrastructure failures. Versions can protect selected overwrites. Backups protect selected loss modes. Only a restored and reconciled business operation proves recovery.

## Failure zoom

Suppose checkout success falls from 99.95% to 81% after a deployment. Backend health remains green, a regional MIG target size is met, and Cloud SQL reports available.

Zoom in by boundary:

```text
symptom: checkout 5xx in one region
├─ identity: new revision uses the wrong principal or audience
├─ routing: one host/path reaches the new backend
├─ artifact: mutable tag resolved to different bytes
├─ compute: health endpoint passes but checkout dependency fails
├─ data: connection pool or IAM database authentication fails
├─ capacity: retries consume connections and quota
└─ evidence: resource dashboards omit the checkout cohort
```

Text equivalent for `LES-0055-DIA-006`: process, instance, zone, region, project policy and external dependency failures widen progressively. Recovery at one level does not cover the next. A MIG can replace a VM but cannot repair a bad template. A regional cluster can preserve the API while all application replicas sit in one zone. A multi-zone database can remain available while clients exhaust connections.

The safe investigation loop is:

1. bind the user-visible symptom and window;
2. find the first boundary whose evidence differs between success and failure;
3. identify the most recent correlated change;
4. mitigate with the smallest reversible action;
5. verify the exact user operation;
6. preserve evidence and only then continue the root-cause analysis.

Rollback is not automatically correct. If the new revision changed data incompatibly, replayed events or rotated a required key, blindly shifting traffic can deepen the incident. Ask what state crossed the rollback boundary.

## Internals and state ownership

Google operates physical facilities, backbone infrastructure and managed-service control planes according to each product contract. You still own workload intent, configuration, identity, data use, dependency behavior, objectives and verification.

Use this compute responsibility ladder:

```text
regional MIG
  customer: image, OS, agents, instance template, rollout, health, capacity, app

GKE Standard
  Google: managed control plane
  customer: node strategy, workloads, policy, add-ons, upgrades, data, SLO

GKE Autopilot
  Google: more node provisioning and constraints
  customer: workloads, requests/limits, policy, identity, data, dependencies, SLO

Cloud Run / functions
  Google: host and platform scaling
  customer: image or source, runtime contract, concurrency, timeout, retry,
            identity, data, dependency pressure, release and user outcome
```

Text equivalent for `LES-0055-DIA-003`: management changes the mechanism of toil; it never transfers product accountability. Choose the highest-level service whose constraints fit the workload and whose failure behavior the team can operate.

MIG internals matter because an instance template is the replacement source of truth. Autohealing recreates unhealthy instances from that model. Load-balancer health should usually remove bad traffic quickly, while autohealing should be conservative enough to avoid destructive replacement loops. A regional MIG improves zonal resilience only when:

- instances actually span intended zones;
- application state is not trapped on one disposable VM;
- the backend can lose a zone and retain useful capacity;
- quota and stock permit replacement;
- update policy avoids taking too much capacity at once;
- health checks exercise meaningful readiness.

GKE adds a Kubernetes control plane and scheduler. A regional control plane does not distribute every workload automatically. Node pools, topology spread, disruption budgets, storage class, regional disk behavior, Pod and Service address ranges, admission policy and add-on capacity remain design inputs.

Cloud Run revisions are immutable deployment versions and traffic can be divided between them. That is useful for canaries and rollback, but concurrency and autoscaling can multiply database or API pressure. Minimum instances trade cost for startup readiness; maximum instances protect spend and dependencies but can turn excess demand into queueing or errors. Treat those as an explicit load-shedding contract.

## Evidence table

| Question | First evidence | What it proves | What it does not prove |
|---|---|---|---|
| Which workload is this? | organization/folder ancestry, project number, resource name | immutable scope | business ownership |
| Who called it? | principal, audience, audit event | observed caller context | entitlement |
| Why allowed or denied? | role permissions, bindings, conditions, deny and perimeter evidence | policy inputs | policy correctness |
| Where did traffic go? | DNS answer, frontend, route, firewall, backend and trace | sampled path | every cohort |
| What code ran? | image digest, template version or Cloud Run revision | artifact identity | source review quality |
| Is compute useful? | target/running/healthy plus application result | selected capacity state | end-to-end success |
| Is data safe? | location, HA state, versions, backups and restore record | configured mechanisms | recoverability |
| Can a zone fail? | placement plus surviving-capacity calculation | design headroom | real failover |
| Can it scale? | demand, quota, stock assumption, IPs and dependency limits | quantified plan | future availability |
| Are users healthy? | success, latency, correctness and freshness SLI | service outcome sample | root cause |
| Can we recover? | isolated restore and reconciliation | sampled RPO/RTO result | every scenario |
| What costs money? | billing export grouped by project, label and SKU | measured usage cost | future demand |

Cloud Audit Logs are vital change and access evidence, but log categories and service coverage differ. Data Access logs may require deliberate enablement and can add volume and cost. Never enable broad high-volume logging without retention, access and cost decisions.

Cloud Monitoring stores time series and can use a scoping project and metrics scope across projects. That helps central operations, but centralization introduces access, cardinality, retention and ownership questions. A platform team should provide safe defaults while workload owners retain responsibility for meaningful SLIs.

## Command decoders

The local commands are intentionally small. Their purpose is to teach evidence boundaries.

`python3 -m json.tool fixtures/cases.json >/dev/null` answers only: “Can a JSON parser read this fixture?” It does not validate the meaning of `zone_resilient` or contact Google Cloud.

`python3 model.py show fixtures/cases.json baseline` prints eight declared controls. It is an architecture-review prompt, not a provider inventory.

`python3 model.py evaluate fixtures/cases.json baseline` evaluates the first failing boundary in a fixed order:

```text
governance -> identity -> artifact -> network exposure
-> failure domain -> capacity/quota -> recovery -> observability
```

This ordering prevents a common incident mistake: staring at CPU graphs while the request is denied by identity or sent to the wrong path.

The negative cases each change exactly one decision:

| Case | Expected boundary | Remember this |
|---|---|---|
| `project-sprawl` | governance | projects need ownership, hierarchy and policy |
| `service-account-key` | identity | a stored private key is avoidable standing risk |
| `mutable-image` | artifact | a tag or family name alone cannot prove bytes |
| `public-data` | network-exposure | public reachability is not a troubleshooting shortcut |
| `single-zone` | failure-domain | replicas in one zone share the same outage |
| `quota-no-headroom` | capacity-quota | autoscaling is a request, not capacity |
| `restore-untested` | recovery | backup configuration is not restored data |
| `resource-only-monitoring` | observability | green resources can serve broken journeys |

`bash verify.sh` creates only `/tmp/reliability-atlas-les0055-model-UID`, refuses root, credentials, symlinks and unknown artifacts, checks nine decisions, and proves cleanup. If it passes, say “the local decision model passed.” Never say “GCP passed.”

## Decision path

Use this path before choosing products:

```text
1. What user operation and data semantics matter?
2. Which SLI, SLO, RPO and RTO express success?
3. Who owns organization, project, network, identity, service and response?
4. Which geographic, trust and policy boundaries are required?
5. Which compute contract fits the workload and team?
6. What fails at process, instance, zone, region and dependency scope?
7. What capacity survives each required failure?
8. How is state protected, restored and reconciled?
9. Which evidence detects and explains failure?
10. What are the unit costs and exit conditions?
```

Choose a regional MIG when VM or OS control is required and the team can operate images, patching, rollout and instance health. Choose GKE when Kubernetes APIs, portability, scheduling, policy or ecosystem value repays cluster complexity. Choose Cloud Run when a supported stateless request, job or worker contract fits and minimizing platform operations matters. “Serverless” is not a synonym for “no limits.”

Choose region and data location together. Co-locating compute and data usually improves latency and reduces data-transfer cost, but residency, failure-domain and user-location requirements can override it. A multi-region product label does not mean every dependent service, key, identity path and client is multi-region.

Text equivalent for `LES-0055-DIA-004`:

```text
live state
  -> service availability copies
  -> versions / point-in-time recovery / backup
  -> isolated protected recovery point
  -> clean restore environment
  -> schema, count, checksum and business reconciliation
  -> measured RPO, RTO and failback decision
```

## Guided Ubuntu lab

This lab builds no cloud resource. From the lesson’s `support/lab` directory on Ubuntu 24.04:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh evaluate service-account-key
bash lab.sh evaluate single-zone
bash lab.sh evaluate quota-no-headroom
bash lab.sh evaluate restore-untested
bash lab.sh status
bash lab.sh cleanup
```

Expected observations:

- `doctor` refuses root, a non-Ubuntu-24.04 environment, missing Python or known Google Cloud credential variables.
- `setup` creates one private UID-scoped directory only after checking it does not exist.
- `baseline` returns `decision=operable` and `boundary=user-outcome`.
- each negative case returns `not-operable` at its first encoded boundary;
- `cleanup` removes only the exact guarded root and proves absence.

Then run:

```bash
bash verify.sh
```

Expected final line:

```text
verify=pass cases=9 cleanup=true runtime=model-only
```

Stop if the lab detects a credential, unknown file, symlink, unexpected owner or root execution. Do not “fix” the guard to make a test pass. The refusal is part of the lesson.

## Production transfer

The independent lab uses an unseen, sanitized architecture packet. The reviewer provides requirements only after the learner begins, then changes one major constraint: region, residency, ten-times demand, RPO, team size or budget.

The learner must produce:

- operation, data, demand, SLI/SLO, RPO and RTO contracts;
- organization, folder, project, billing and owner map;
- human and workload identity map, including federation and inherited policy;
- DNS, frontend, VPC, subnet, firewall, compute, data and return path;
- MIG, GKE and Cloud Run comparison with a rejected option;
- immutable artifact, rollout and rollback contract;
- zone-loss and burst capacity math;
- Cloud Storage, Cloud SQL and KMS protection and recovery design;
- user-led telemetry and incident path;
- cost units, uncertainty register and cleanup proof.

A pre-generated Terraform plan may be reviewed after secrets and identifiers are sanitized. It proves intended changes, not deployed state. No `terraform apply`, console mutation, project creation, credential, provider API or paid resource is permitted in this exercise.

The reviewer should challenge one hidden assumption. Examples: the chosen region lacks a required feature, the team cannot operate GKE, a service-account key is prohibited, dual-region storage exceeds budget, a zone-loss event consumes the remaining database connections, or the recovery project inherits a deny policy.

## Reliability, security, observability, capacity, and cost

**Reliability.** Define it with user success, latency, correctness and freshness. Spread stateless capacity across required zones, but compute surviving capacity after losing the largest zone. Protect dependency capacity with queues, deadlines, retry budgets, circuit breakers and load shedding. Test degradation: can read-only browsing remain available when order creation is paused?

**Security.** Use group-based human access and short-lived federation. Avoid basic roles and downloadable service-account keys for routine operation. Separate network administration, security/key administration, workload deployment and audit review. Keep private data private, but remember that private connectivity does not authorize a principal. For CMEK, plan key location, permissions, rotation, disable/destroy protection, audit and recovery dependencies.

**Observability.** Begin with the transaction SLI, then correlate application metrics, structured logs, traces, load-balancer evidence, MIG/GKE/Cloud Run state, Cloud SQL/Storage signals and audit changes. Control label cardinality and log volume. Alert on actionable user impact or fast error-budget burn, not every resource fluctuation.

Text equivalent for `LES-0055-DIA-005`:

```text
user SLI -> SLO burn -> alert -> incident owner
    |                         |
    +-> trace/request ID -----+
          -> app evidence
          -> platform evidence
          -> audit/change evidence
          -> mitigation
          -> verified user recovery
```

**Capacity.** Compute more than average CPU:

```text
required serving capacity
  = peak useful demand
  × safety factor
  + queue drain requirement
  + largest required failure loss

available useful capacity
  = min(compute, quota, stock/reservation, subnet addresses,
        scheduler, database connections, downstream throughput)
```

If any term is unknown, mark it unknown. Do not convert optimism into a number. Quota increases can require lead time and do not reserve physical stock. Regional MIGs and regional GKE configurations can consume more quota than zonal designs.

**Cost.** Track unit economics: cost per successful request, order, GiB processed or build—not only monthly total. Include idle and failure capacity, VM and GKE management cost, Cloud Run CPU/memory and minimum instances, Cloud Storage class and operations, Cloud SQL HA and backups, data transfer, load balancing, NAT, external IPs, log ingestion/retention, Monitoring, KMS versions/operations and DR copies. Reliability capacity is not waste when it is tied to an approved objective; unlabeled idle resources with no owner are waste.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| “The project is the environment.” | Projects mix many scopes but do not express every trust or failure boundary. | Document organization, folder, project, network, region, zone and data scopes separately. |
| Grant Owner to fix a denial. | It expands blast radius and can hide deny or perimeter causes. | Bind the request and correct the narrowest policy. |
| Store a service-account JSON key. | The private key can be copied and outlive the workload. | Use attached or federated short-lived identity. |
| Assume same VPC means reachable. | Routes, firewall, address, DNS and return path still decide packets. | Trace forward and return paths. |
| Use a mutable image tag. | Replacement instances may run different bytes. | Pin digest, provenance and template/revision identity. |
| Count regional control plane as workload HA. | Pods, nodes, data or dependencies may remain zonal. | Verify placement and surviving capacity end to end. |
| Let serverless scale without bounds. | It can exhaust connections, quota and downstream services. | Bound concurrency, retries and maximum instances; buffer work. |
| Call multi-region storage a backup. | Replication can propagate deletion or corruption. | Use protected versions/backups and restore tests. |
| Monitor only CPU and resource state. | Users can fail while resources look normal. | Measure transaction SLIs and correlate component evidence. |
| Treat quota as capacity. | Quota is a ceiling, not a reservation or stock guarantee. | Forecast early and design approved alternatives. |
| Delete a KMS key to test recovery. | Destruction can make protected data unrecoverable. | Use isolated test keys and lifecycle safeguards. |
| Trust cost estimates without usage units. | Traffic, logs, retries and data movement change the bill. | Reconcile estimates with billing export and unit owners. |

The strongest prevention is a production-readiness review that asks for evidence, not product names.

## Memory card and retrieval

When you see a Google Cloud incident, remember:

```text
PROJECT tells you scope, not success.
IAM tells you permission, not entitlement.
VPC tells you network membership, not reachability.
REGIONAL tells you placement, not surviving capacity.
AUTOSCALING tells you intent, not available resources.
REPLICATION tells you copies, not recovery.
MONITORING tells you signals, not the user outcome.
```

The five-minute recall:

1. **Name the operation.**
2. **Bind immutable scope:** organization, project number, region, resource.
3. **Bind identity:** principal, audience, permission, policy.
4. **Trace the path:** DNS, frontend, route, firewall, backend, data, return.
5. **Bind the artifact and change.**
6. **Measure surviving capacity and dependencies.**
7. **Verify restore and user outcome.**

Tomorrow, redraw `LES-0055-DIA-002` and explain why the VPC is global while a subnet and most workload capacity are regional or zonal. A week later, diagnose `service-account-key` and `quota-no-headroom` without opening the answer.

## Complete answers

**Why can a project have quota available while a scale-out still fails?**  
Quota is only an allowed ceiling. The requested region or zone might lack stock; a reservation might not cover that resource; the MIG maximum, instance template, image permission, service account, subnet address space, GKE scheduler or downstream connection pool can block useful capacity. Inspect the first rejected create or schedule event, not merely the autoscaler recommendation.

**Why is a regional MIG not automatically highly available?**  
It improves placement across zones, but availability still depends on application health, update policy, state placement, load-balancer routing, surviving capacity and dependencies. If the database, KMS key dependency, NAT path or all application state remains in one failure domain, the user operation can still fail.

**How do IAM and Organization Policy differ?**  
IAM generally authorizes principals to use permissions on resources. Organization Policy constrains allowed resource configuration across hierarchy scopes. A principal can have permission to create a resource while an organization policy forbids the requested configuration. Deny policies and access boundaries add other authorization constraints; do not flatten all denials into “IAM.”

**Why prefer Workload Identity Federation?**  
It exchanges trusted external workload identity for short-lived Google credentials and avoids distributing long-lived service-account private keys. It still needs strict issuer, audience, subject and attribute mapping plus narrow IAM. Federation reduces credential inventory; it does not eliminate authorization or token-theft risk.

**When would you choose Cloud Run instead of GKE?**  
Choose Cloud Run when the service, job or worker contract fits, the application can honor the runtime and scaling constraints, and the team benefits from delegating cluster and node operations. Choose GKE when Kubernetes APIs, custom scheduling, ecosystem integration, portability or platform controls justify cluster complexity. The decision must include team capacity, dependency pressure, networking, observability and cost.

**Does Cloud Storage dual-region remove the need for DR?**  
No. Geographic redundancy improves selected availability and durability outcomes, but asynchronous replication windows, deletion, corruption, credentials, application metadata and dependent services still matter. Define RPO/RTO, retain protected recovery points where required, and restore into an isolated environment.

**What makes a Cloud SQL failover successful?**  
Not merely a provider state transition. Clients must reconnect within their deadline, transaction retry must be safe, connection pools must recover, dependent DNS or private paths must work, and the business operation must be correct. Measure interruption and data state against the declared objectives.

**What does a green backend health check prove?**  
Only that the configured probe succeeded from its probe context. It may not exercise authentication, the real host/path, a write, KMS, database, external dependency or the affected cohort. Compare the probe with the failed user path.

**What is the safe first action for an access denial?**  
Preserve one denied request, bind principal, permission, resource ancestry, project, time and audit record, then evaluate effective allow, conditions, deny, access boundaries, organization policy, perimeters and service controls. Do not broaden access before identifying the deciding boundary.

**How do you prove backup readiness?**  
Restore a selected recovery point into an isolated, authorized environment; measure elapsed time; validate schema, counts, integrity and business invariants; quantify achieved RPO/RTO; test application reconnection and record cleanup. A successful backup job alone proves only that the job reported success.

## Product-company interview

**Question: Design a zone-resilient order API on Google Cloud.**  
A strong answer starts with order semantics, demand, SLI/SLO, RPO/RTO and team constraints. It defines organization/project ownership and federated identity; traces DNS, frontend, VPC and private data paths; compares regional MIG, GKE and Cloud Run; calculates capacity after the largest zone loss; protects Cloud SQL and Storage state; binds immutable rollout; correlates user SLIs; and proves restore. Product names come after contracts.

**Senior follow-up: The regional MIG target is 300 and only 190 instances run during a zone outage. What next?**  
Calculate useful capacity versus critical demand. Inspect per-zone distribution and instance creation failures for quota, stock, reservation, image, identity and addresses. Reduce noncritical load, use preapproved alternate shapes or zones, preserve data dependencies and verify the transaction. Repeatedly increasing target size can amplify API noise without adding capacity.

**Question: A developer asks for project Owner because Workload Identity Federation returns permission denied.**  
Separate token exchange from resource authorization. Validate issuer, audience, subject and attribute mapping; identify the resulting principal; inspect the exact permission and resource ancestry; then grant the narrowest role or correct the mapping. Owner is neither a diagnostic method nor a safe default.

**Question: Cloud Run scales up but latency worsens. Why?**  
Instances are only one capacity layer. Cold starts, high concurrency, database connections, NAT ports, queue retries, KMS calls and downstream quotas can saturate. Graph arrivals, queue age, instance count, concurrency, retries and dependency latency together; then bound pressure and protect the critical operation.

Interviewers are evaluating whether you reason across ownership and failure boundaries, not whether you can list services.

## Independent transfer and rubric

Complete `ASM-0150` without reading a model answer. The reviewer owns the scenario and changes one constraint after the first design. A passing document is not enough: the learner must defend the trade-offs, update the design under the new constraint, recall the reasoning later and prove local cleanup.

The 100-point rubric gives equal weight to:

1. operation and objectives;
2. hierarchy and governance;
3. identity and authorization;
4. request and return path;
5. compute and delivery trade-offs;
6. data and key protection;
7. recovery;
8. capacity;
9. observability and incident response;
10. cost, constraint transfer and cleanup.

Automatic scoring is intentionally absent. The strongest evidence is reviewer-observed reasoning on an unseen case. Publishing this lesson, running the model or memorizing service names does not award mastery.

## References and review

The fifteen records `REF-0583` through `REF-0597` point to primary Google Cloud documentation reviewed on 2026-08-05. They cover the reliability pillar, resource hierarchy, IAM, workload identity, VPC, regional MIGs, GKE configuration, Cloud Storage, Cloud SQL HA, Cloud Run, functions, Monitoring, KMS, quotas and DR planning.

Provider behavior changes. Before production work, recheck:

- product availability and failure semantics in the chosen region;
- quota and system-limit scope;
- GKE mode and version behavior;
- Cloud Run runtime, concurrency and networking contracts;
- storage and database replication or recovery behavior;
- IAM, federation, organization policy and KMS lifecycle;
- current pricing and data-transfer rules.

This lesson deliberately creates no organization, project, credential, network, compute, data, key, telemetry or billable resource. Its local model is a reasoning fixture, not a provider emulator. Formal review, an authorized provider-current design review, an isolated restore exercise, reviewer-owned transfer and learner evidence remain mandatory before publication or competency claims.
