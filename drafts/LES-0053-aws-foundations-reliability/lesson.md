---
{"schemaVersion":1,"kind":"lesson","id":"LES-0053","slug":"aws-foundations-reliability","aliases":["V05-L17","aws-foundations-reliability"],"curriculumIds":["AWS-001"],"route":"/book/infrastructure/aws-foundations-reliability","order":17,"volume":"05-infrastructure-platforms","title":"AWS foundations and reliability: operate the workload, not the logo","summary":"Design and review an AWS workload from organization and identity through regional networking, compute, data, observability, quotas, recovery and cost without confusing managed services with managed reliability.","domain":"infrastructure","level":{"from":"intermediate","to":"expert"},"estimatedMinutes":600,"prerequisiteLessonIds":["LES-0035","LES-0036","LES-0050","LES-0051","LES-0052"],"prerequisiteCurriculumIds":["TFM-001","CLD-001","IAM-001","CLD-002"],"testedEnvironments":[{"platform":"AWS official documentation","version":"current documentation reviewed 2026-08-05","support":"concept-only","notes":"Organizations, IAM, Regions/AZs, VPC, EC2 Auto Scaling, ALB, ECS, EKS, S3, RDS, Lambda, CloudWatch, KMS and Service Quotas reviewed; no account used."},{"platform":"Ubuntu","version":"24.04 normal-user local model","support":"required","notes":"Deterministic architecture-readiness model only; not an AWS emulator."},{"platform":"Python","version":"3 standard library","support":"required","notes":"JSON validation and deterministic local decisions; no SDK."}],"targetRoles":["cloud-engineer","platform-engineer","site-reliability-engineer","devops-engineer","security-engineer","solutions-architect","technical-lead"],"learningObjectives":["Map an AWS workload across organization, account, Region, Availability Zone, VPC, subnet, service and resource boundaries.","Separate identity authentication, authorization, organization guardrails, resource policies and KMS key policy.","Trace a user request through DNS, load balancing, network controls, compute, data and observability.","Choose EC2 Auto Scaling, ECS, EKS or Lambda by operating responsibility and workload constraints rather than fashion.","Design private data access, immutable delivery, encryption, backup, restore and tested recovery.","Distinguish high availability, fault tolerance, backup and disaster recovery using RPO and RTO.","Plan service quotas, provider capacity, application headroom and dependency limits before failure.","Build user-centered SLIs and correlate them with CloudWatch resource and application telemetry.","Explain AWS cost through measurable units, retention, data movement and idle or duplicated capacity.","Diagnose identity, artifact, network, zone, quota, recovery, observability and retry-amplification failures."],"productionSignals":["user operation success latency correctness freshness and availability by region or tenant","organization account OU service control policy resource control policy and exception owner","principal session source MFA role trust identity policy resource policy permission boundary session policy and explicit deny","CloudTrail management and relevant data event identity request ID source and change record","Region Availability Zone VPC subnet route security group network ACL endpoint and load balancer path","ALB listener rule target group health status code latency and rejected connection","EC2 Auto Scaling desired in-service pending unhealthy launch activity capacity and subnet IP headroom","ECS desired/running/pending tasks deployment events capacity provider and task health","EKS API/node/Pod/controller/scheduler/network/storage version and add-on health","Lambda invocation error throttle duration concurrency iterator age queue age and downstream saturation","S3 bucket/account owner key version encryption replication lifecycle access and restore evidence","RDS writer/reader endpoint connection pool replication/failover event backup restore and transaction SLI","KMS key ARN policy grant state rotation and decrypt failure without plaintext logging","service quota applied value usage utilization forecast increase lead time and non-quota capacity risk","backup age integrity immutability restore test RPO RTO dependency order and business validation","cost allocation account tag service usage unit data transfer NAT log ingestion retention and commitments"],"diagrams":[{"id":"LES-0053-DIA-001","title":"Organization-to-workload authority","direction":"hierarchical","boundaries":["organization","organizational unit","account","federated role","service resource","KMS key"],"evidencePoints":["guardrail","session","allow","explicit deny","resource policy","key policy"],"textAlternative":"Organization policies bound maximum permission, while a federated role session plus identity, resource and key policies determine whether one request is authorized."},{"id":"LES-0053-DIA-002","title":"Regional user request path","direction":"left-to-right","boundaries":["user and DNS","load balancer","VPC policy","compute across zones","data service","telemetry"],"evidencePoints":["answer","listener rule","target health","request ID","transaction","user SLI"],"textAlternative":"A request resolves to a regional entry point, crosses routing and policy, reaches healthy compute and data, and emits evidence tied to the user outcome."},{"id":"LES-0053-DIA-003","title":"Compute responsibility ladder","direction":"hierarchical","boundaries":["EC2 and Auto Scaling","ECS on EC2 or managed capacity","EKS worker and cluster operations","Lambda execution environment"],"evidencePoints":["host ownership","scheduler ownership","runtime contract","scaling boundary","patch boundary"],"textAlternative":"Moving from EC2 toward managed orchestration or functions changes which control planes AWS operates, but the customer still owns code, identity, data, limits and user reliability."},{"id":"LES-0053-DIA-004","title":"Data protection and recovery chain","direction":"left-to-right","boundaries":["live data","version or replica","backup","immutable copy","restore environment","business validation"],"evidencePoints":["consistency","recovery point","integrity","isolation","restore time","user correctness"],"textAlternative":"A backup is useful only when a protected recovery point can be restored in dependency order and the recovered business operation is validated inside the target RPO and RTO."},{"id":"LES-0053-DIA-005","title":"Observability and response loop","direction":"left-to-right","boundaries":["user journey","application","AWS resource","CloudWatch telemetry","SLO alert","operator decision","verified recovery"],"evidencePoints":["SLI","correlation ID","metric","log or trace","burn rate","change","transaction"],"textAlternative":"Resource signals support diagnosis, but alerting begins with a user-centered SLI and ends only when the user operation is verified."},{"id":"LES-0053-DIA-006","title":"Failure-domain and recovery choices","direction":"hierarchical","boundaries":["process","instance or task","Availability Zone","Region","account","external dependency"],"evidencePoints":["detection","automatic replacement","capacity","data state","traffic shift","tested objective"],"textAlternative":"Each failure domain needs an explicit detection, surviving capacity, state strategy, traffic action and tested recovery objective; Multi-AZ alone does not cover Region, account or dependency failure."}],"commands":[{"id":"LES-0053-CMD-001","question":"Is the offline AWS readiness case file valid JSON?","risk":"read-only","command":"python3 -m json.tool fixtures/cases.json >/dev/null","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"exit zero","meaning":"JSON syntax is valid","nextEvidence":"semantic validation"},{"when":"nonzero","meaning":"fixture cannot be trusted","nextEvidence":"fix first parse error"}],"proves":"JSON syntax","doesNotProve":"AWS architecture correctness"},{"id":"LES-0053-CMD-002","question":"What exact workload controls are encoded?","risk":"read-only","command":"python3 model.py show fixtures/cases.json baseline","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"normalized fields print","meaning":"review scope is explicit","nextEvidence":"evaluate baseline"},{"when":"refusal","meaning":"case is incomplete or unknown","nextEvidence":"inspect validation reason"}],"proves":"local model input","doesNotProve":"AWS resource state"},{"id":"LES-0053-CMD-003","question":"Is the baseline locally operable?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json baseline","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"decision=operable","meaning":"all encoded readiness controls pass","nextEvidence":"negative cases"},{"when":"decision=not-operable","meaning":"first encoded boundary fails","nextEvidence":"inspect that boundary"}],"proves":"deterministic baseline result","doesNotProve":"a deployed workload"},{"id":"LES-0053-CMD-004","question":"Are human and workload credentials bounded?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json long-lived-admin","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=identity","meaning":"temporary least-privilege identity is absent","nextEvidence":"federation role and policy path"}],"proves":"encoded identity fault","doesNotProve":"IAM effective permission"},{"id":"LES-0053-CMD-005","question":"Is deployment tied to an immutable artifact?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json mutable-artifact","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=artifact","meaning":"runtime identity can drift","nextEvidence":"digest version and provenance"}],"proves":"encoded artifact fault","doesNotProve":"registry or instance state"},{"id":"LES-0053-CMD-006","question":"Is the data tier private by design?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json public-database","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=network-exposure","meaning":"data exposure exceeds the intended path","nextEvidence":"endpoint route policy and authentication"}],"proves":"encoded exposure fault","doesNotProve":"VPC reachability"},{"id":"LES-0053-CMD-007","question":"Can one Availability Zone fail without losing the operation?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json single-az","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=failure-domain","meaning":"zonal redundancy is absent","nextEvidence":"surviving compute data and dependencies"}],"proves":"encoded zone fault","doesNotProve":"AWS failover"},{"id":"LES-0053-CMD-008","question":"Do quotas and capacity leave tested headroom?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json quota-no-headroom","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=capacity-quota","meaning":"recovery or scaling can be blocked","nextEvidence":"usage forecast quotas stock subnet and dependency limits"}],"proves":"encoded headroom fault","doesNotProve":"provider capacity"},{"id":"LES-0053-CMD-009","question":"Has recovery been proved by restore?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json restore-untested","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=recovery","meaning":"backup existence is not enough","nextEvidence":"isolated restore and business validation"}],"proves":"encoded restore gap","doesNotProve":"backup integrity"},{"id":"LES-0053-CMD-010","question":"Can operators see the user outcome?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json no-user-sli","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=observability","meaning":"resource health cannot establish service reliability","nextEvidence":"transaction SLI and correlation"}],"proves":"encoded SLI gap","doesNotProve":"CloudWatch collection"},{"id":"LES-0053-CMD-011","question":"Are retries bounded against dependency failure?","risk":"read-only","command":"python3 model.py evaluate fixtures/cases.json unbounded-retries","runFrom":"LES-0053 support/lab","expectedBranches":[{"when":"boundary=resilience","meaning":"retry amplification can worsen overload","nextEvidence":"timeout budget backoff jitter cap and idempotency"}],"proves":"encoded retry gap","doesNotProve":"runtime retry behavior"},{"id":"LES-0053-CMD-012","question":"Does the Ubuntu verifier cover all cases and cleanup?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0053 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"passes","meaning":"baseline eight failures refusals and cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic local teaching model","doesNotProve":"AWS identity network compute data monitoring quota recovery cost or production behavior","cleanup":"Verifier proves the exact UID-scoped temporary root is absent."}],"labs":[{"id":"LES-0053-LAB-001","title":"Guided AWS architecture readiness model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python; no AWS account or CLI","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one baseline and eight synthetic readiness cases"],"abortConditions":["root","AWS credential","cloud CLI or SDK","network","provider endpoint","symlink","unknown artifact"],"recovery":"Preserve the first failing boundary, correct only the copied synthetic fixture and rerun.","cleanupProof":"Exact inventory and temporary-root absence.","path":"drafts/LES-0053-aws-foundations-reliability/support/lab"},{"id":"LES-0053-LAB-002","title":"Independent AWS production-readiness and failure review","mode":"independent","environment":"Reviewer-owned offline architecture packet and sanitized Terraform plan; no apply","timeMinutes":240,"privilege":"normal user","network":"none","changes":["local diagrams","readiness table","failure and cost models","review notes"],"abortConditions":["credential","real account","AWS CLI or SDK call","terraform apply","console action","public endpoint","production data","unapproved cost"],"recovery":"Discard only reviewer-owned local artifacts after preserving the scored evidence.","cleanupProof":"Reviewer proves no credentials, state, cache, provider process or cloud resource exists.","path":"drafts/LES-0053-aws-foundations-reliability/support/lab"}],"incidents":[{"id":"LES-0053-INC-001","signal":"A federated operator signs in successfully but an API call returns AccessDenied.","firstThought":"Authentication succeeded; authorization may be blocked by identity, session, boundary, organization, resource or KMS policy, including an explicit deny.","safePath":"Bind principal session, action, resource, context and request ID; evaluate every policy layer and CloudTrail evidence; correct the narrowest owner-controlled statement and retest.","trap":"Attach AdministratorAccess or remove the organization guardrail."},{"id":"LES-0053-INC-002","signal":"All ALB targets are healthy while users receive intermittent 5xx responses.","firstThought":"The health-check operation is narrower than the user journey; listener rules, target behavior, dependencies, zone distribution or timeout/retry paths may differ.","safePath":"Bind host/path/status/request ID and zone, compare ALB and target logs, trace one transaction to dependencies, mitigate the failing cohort and verify the user SLI.","trap":"Increase the health-check timeout and declare recovery."},{"id":"LES-0053-INC-003","signal":"After one Availability Zone fails, Auto Scaling cannot restore the SLO.","firstThought":"Replacement intent is not replacement capacity; max size, quota, subnet IPs, launch template, instance stock or downstream capacity may block recovery.","safePath":"Measure surviving capacity and demand, inspect scaling activity and launch errors, protect critical traffic, use preapproved alternate capacity and verify zone-independent service.","trap":"Keep raising desired capacity without reading launch failures."},{"id":"LES-0053-INC-004","signal":"RDS reports a successful failover but application errors continue.","firstThought":"Database control-plane success does not prove application recovery; DNS caching, stale connections, transaction retry safety, dependency order or exhausted pools may remain.","safePath":"Correlate failover events with endpoint resolution, pool behavior and transaction SLIs; drain or refresh safely, protect idempotency and verify reads and writes.","trap":"Reboot the new writer repeatedly."},{"id":"LES-0053-INC-005","signal":"Lambda throttles, queue age and downstream errors rise together.","firstThought":"Concurrency and retries may amplify demand beyond downstream or account capacity; the function can scale faster than its dependency.","safePath":"Graph arrivals, concurrency, throttles, duration, queue age and dependency saturation; bound concurrency and retries, preserve messages, restore dependency headroom and verify backlog drain.","trap":"Add unbounded retries or immediately raise concurrency."}],"assessmentIds":["ASM-0142","ASM-0143","ASM-0144"],"referenceIds":["REF-0553","REF-0554","REF-0555","REF-0556","REF-0557","REF-0558","REF-0559","REF-0560","REF-0561","REF-0562","REF-0563","REF-0564","REF-0565","REF-0566","REF-0567"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-05","reviewAfter":"2027-02-05","limitations":["No AWS account, credential, CLI, SDK, API, Terraform provider, deployment or paid resource is used.","The local model is not an AWS emulator and does not establish provider or production behavior.","Service availability, quotas, features, pricing and regional support change and require current review before design or operation.","No real IAM evaluation, packet, instance, container, cluster, function, object, database, key, metric, backup, failover or cost evidence is produced.","Formal review, canonical publication, reviewer-owned transfer and learner evidence remain required."]}
---

# AWS foundations and reliability: operate the workload, not the logo

## What you see and first thought

An AWS console can show green checks everywhere while the customer still cannot pay, sign in, or retrieve a file. That is the first habit to remember: **an AWS resource is not the product; the user operation is the product**.

When an incident says “AWS is down,” refuse the sentence gently. Ask: which operation, from which client, in which account and Region, through which endpoint, at what time, with which request ID, and what changed? A failed checkout may cross Domain Name System (DNS), an Application Load Balancer (ALB), network policy, an Amazon Elastic Compute Cloud (EC2) instance or container, an Amazon Relational Database Service (RDS) database, an AWS Key Management Service (KMS) key and an external payment provider. “The EC2 instance is healthy” proves only one small piece.

Your mental opening should be:

```text
user outcome
  -> identity and account boundary
  -> name, route and policy
  -> entry point and compute
  -> data and dependencies
  -> quotas and failure domains
  -> evidence, recovery and cost
```

This lesson is not a console tour. It gives you a reusable operating model for Organizations, Identity and Access Management (IAM), Virtual Private Cloud (VPC), EC2 Auto Scaling, Elastic Container Service (ECS), Elastic Kubernetes Service (EKS), Lambda, Simple Storage Service (S3), RDS, CloudWatch, KMS and recovery. The service names matter, but the boundary each service owns matters more.

Learning objectives are encoded in the lesson metadata. By the end, you should be able to map a workload, choose compute deliberately, detect missing reliability controls and explain why “managed” never means “nobody needs to operate it.”

## Terms before commands

**Organization** means a collection of AWS accounts governed together. It is the top administrative structure, not one large runtime account.

**Organizational unit (OU)** means a grouping of accounts that should receive similar controls. Group by workload purpose and control needs, not by the company reporting chart.

**AWS account** is a strong resource, access, billing and many-quota boundary. Separate production from non-production and use dedicated security, logging and infrastructure accounts where justified. An account is not merely a folder.

**Service control policy (SCP)** and **resource control policy (RCP)** are organization guardrails. A guardrail limits the maximum available permission. It does not grant a principal permission by itself. Think “ceiling,” not “access badge.”

**Principal** is the identity making a request: a role session, user, federated identity or AWS service principal. A human should normally federate and assume a role with temporary credentials; a workload should normally receive temporary role credentials.

**Authentication** proves who or what is making the request. **Authorization** decides whether that authenticated principal may perform one action on one resource under the current context. Successful sign-in plus `AccessDenied` is therefore not contradictory.

**Region** is an AWS geographic area containing multiple Availability Zones. **Availability Zone (AZ)** is an isolated location inside a Region. A VPC is Region-scoped; each subnet belongs to exactly one AZ. A resource can be global, Region-scoped or AZ-scoped, so always name its scope.

**Control plane** accepts desired-state operations such as creating an Auto Scaling group or changing a policy. **Data plane** serves workload operations such as an HTTP request, S3 object read or database transaction. Control-plane success does not prove the data plane works.

**EC2 Auto Scaling group (ASG)** maintains desired instance capacity and can adjust it. It expresses replacement and scaling intent; it cannot manufacture instance stock, subnet addresses, quota, a valid image or a healthy application.

**ALB listener** accepts a protocol and port. A listener **rule** matches request properties and chooses an action. A **target group** holds registered destinations and a health-check contract. Healthy target status proves the health check, not every customer path.

**ECS** is AWS-native container orchestration. A task definition describes a workload; a task is one running or completed copy; a service maintains long-running desired task count. Capacity may be EC2-based or AWS Fargate.

**EKS** is managed Kubernetes. AWS operates important managed control-plane parts, while you still own Kubernetes workload design, identity, networking, nodes or selected compute mode, add-ons, upgrades, policy, data and application reliability.

**Lambda** runs functions in managed execution environments. You own event contracts, code, idempotency, timeouts, concurrency, downstream protection, identity and observability. “Serverless” removes server administration from your task list; it does not remove capacity or failure.

**S3 object** is data plus metadata addressed by bucket, key and optional version. S3 is object storage, not a POSIX filesystem. Versioning, lifecycle, replication, Object Lock and access policy are separate controls with separate cost and recovery effects.

**RDS Multi-AZ** provides a managed standby or cluster arrangement for failover. It is high-availability machinery, not a substitute for backup, point-in-time recovery, cross-Region strategy or application reconnect correctness.

**KMS key** is a managed cryptographic key with its own policy and lifecycle. Encryption does not repair overbroad authorization; a key policy can independently block an otherwise allowed data request.

**Service quota** is a maximum resource or operation value at a documented scope. **Headroom** is the safe unused capacity before the limit. A quota increase is a request, not guaranteed stock. Also watch non-quota constraints: subnet IPs, instance availability, downstream throughput and human response time.

**Recovery point objective (RPO)** is the maximum tolerable data-loss window measured backward from disruption. **Recovery time objective (RTO)** is the maximum tolerable restoration time. They are business requirements, not values discovered after a failure.

## Architecture map

Start above the VPC. A serious AWS design usually needs an organization and account model before a subnet diagram.

```text
AWS Organization
├─ Security OU/account       -> findings, response, delegated administration
├─ Infrastructure OU/account -> shared network, delivery, DNS where chosen
├─ Logging account           -> protected audit destinations
├─ Production OU
│  ├─ payments-prod account
│  └─ identity-prod account
└─ Non-production OU
   ├─ payments-test account
   └─ sandbox accounts

SCP/RCP guardrail -> role session -> identity/resource/key policy -> API decision
```

Text equivalent for `LES-0053-DIA-001`: the organization and OU apply limits to accounts. A federated user assumes a role in one account. The request then meets identity, session, permissions-boundary, resource and possibly KMS key policy. An applicable explicit deny wins. No single “IAM policy” screen is necessarily the whole decision.

Inside one workload account and Region, place public entry components only where required. Application compute normally runs in private subnets across at least two AZs. Data services should not be internet-reachable merely because security groups exist. Use VPC endpoints where their security, availability, operational and cost trade-offs fit; private networking still requires IAM and application authorization.

```text
client
  -> DNS name
  -> regional ALB across AZ-a/AZ-b
       -> listener and ordered rule
       -> healthy targets in private subnets
            -> EC2/ECS/EKS/Lambda integration
                 -> RDS/S3/queue/external dependency
  -> logs + metrics + traces + events + CloudTrail
  -> user SLI and SLO response
```

Text equivalent for `LES-0053-DIA-002`: DNS selects an entry point. The ALB evaluates a listener rule and chooses a healthy target. Network and identity controls permit the exact path. Compute performs a data operation. Telemetry must preserve a request or correlation identity so operators can connect the user result to each boundary.

One architecture diagram must label four things people often omit: state owner, failure domain, trust boundary and operating owner. If “AWS managed” appears without the customer responsibilities beside it, the diagram is incomplete.

## Request or state path

Trace one concrete operation: `POST /orders` for a signed-in customer.

1. The client resolves the service name. Record resolver view, answer, time to live (TTL) and Region-routing policy. DNS success proves only name-to-endpoint selection.
2. The connection reaches the ALB listener. Transport Layer Security (TLS) certificate, protocol, port and security-group policy must fit.
3. The listener evaluates rules in priority order. Bind the actual host, path, headers and chosen target group.
4. The target group selects a healthy target. Record AZ, target identity and health-check path. The customer request may exercise authentication and dependencies that the health check avoids.
5. EC2, ECS, EKS or Lambda executes code from an identified version or digest. A mutable tag such as `latest` is not a trustworthy runtime identity.
6. The workload receives temporary credentials from its role and calls a data service. Record principal ARN, action, resource ARN, request context and request ID. Never log secret values.
7. RDS performs a transaction, or S3 stores an object identified by bucket, key and version. Encryption may invoke KMS authorization. “Encrypted” and “authorized correctly” are different claims.
8. Application telemetry records outcome, latency and correlation. CloudWatch resource metrics support the story but do not replace the user transaction SLI.
9. The caller receives a response. Only this point can establish whether that sampled user operation succeeded.

Desired state follows another path:

```text
reviewed source -> immutable artifact -> IaC plan -> approved deployment
  -> AWS control plane -> converging controllers -> data-plane health
  -> user SLI -> rollback or continue
```

An infrastructure-as-code plan proves proposed changes under the plan inputs and provider view at that time. It does not prove provider capacity, a safe application migration, successful convergence or the customer outcome. Store the plan with source revision, variables, provider versions and approval; re-plan if those inputs change.

## Failure zoom

Zoom into partial failure because “the Region is up” is not useful enough.

```text
process fault -> target health removes one copy
instance fault -> ASG or service replaces capacity
AZ fault      -> surviving AZs need compute + data + subnet IP + dependency headroom
Region fault  -> separate data, control, traffic and identity recovery plan
account fault -> break-glass and cross-account recovery boundaries
dependency    -> timeout, bounded retry, degradation and business decision
```

Text equivalent for `LES-0053-DIA-006`: every wider failure domain needs independent detection and enough surviving capacity. Replacement automation covers only the failures and resources it can observe and create. An AZ-resilient frontend with a single-AZ database, NAT path or external dependency is still single-domain at the user-operation level.

The classic hidden failure is **capacity needed during failure but unavailable during failure**. If normal traffic consumes 70 percent of two equal AZ pools, losing one AZ asks the survivor to carry 140 percent. Auto Scaling may want more instances, yet `max_size`, an EC2 quota, unavailable instance type, subnet address exhaustion or a database connection limit can reject them. Reliability capacity is not idle waste; it is purchased recovery capability. Make the cost visible and defend it against the SLO.

Another hidden failure is retry multiplication. Suppose a client retries three times, the ALB target library retries twice and the function event source retries again. One original operation can become many dependency calls precisely while the dependency is weakest. Use an end-to-end timeout budget, exponential backoff with jitter, a retry cap, idempotency and a single clearly owned retry layer where possible.

## Internals and state ownership

AWS services expose desired state through APIs, then distributed controllers reconcile it. Expect propagation, eventual convergence and partial completion. A successful create or update response means the control plane accepted or completed a documented operation; it does not mean every downstream data path is healthy.

Organization state includes accounts, OU membership, delegated administrators and policies. Treat management-account access as exceptionally sensitive. Organization guardrails should be versioned, reviewed and tested against representative workloads. Because an SCP limits rather than grants permissions, debugging must include the role’s actual permissions and every applicable deny layer.

IAM authorization is an intersection and union problem with explicit-deny precedence. Identity policies can allow; resource policies can allow in supported contexts; permissions boundaries, session policies and organization guardrails restrict; KMS key policies and grants add a resource-specific authorization plane. Capture the full request: principal, action, ARN, source, tags, conditions, session and request ID. Do not “fix IAM” by making the evidence disappear under administrator access.

VPC state belongs to multiple objects: VPC address ranges, AZ-scoped subnets, route-table associations, security groups, network ACLs, endpoints, gateways and DNS settings. The network chapter taught forward and return paths; AWS does not remove that requirement. Security groups are stateful controls attached to supported resources, while network ACLs are stateless subnet-level controls. Know which tuple and direction each boundary evaluates.

ALB owns listener evaluation and target selection, not application correctness. Health-check status is based on the configured health operation. A shallow `/health` that returns 200 without checking critical dependencies is useful for process liveness but cannot represent checkout availability. A deep check that takes dependencies out of service during a shared dependency incident can remove every target. Separate liveness, readiness and user SLI.

Compute changes operating responsibility:

```text
EC2/ASG: customer owns OS image, patching, agent, process and scaling policy
ECS EC2: add task/service contract; customer still owns cluster instances
ECS managed capacity/Fargate: AWS owns more host capacity; customer owns task and limits
EKS: AWS manages selected control-plane parts; customer owns Kubernetes operations and workloads
Lambda: AWS manages execution fleet; customer owns function/event/concurrency/dependency contract
```

Text equivalent for `LES-0053-DIA-003`: managed services move a boundary; they do not delete the responsibility column. Choose the simplest model that satisfies scheduling, portability, isolation, runtime, ecosystem and team-skill requirements. EKS is justified when Kubernetes capabilities and organizational consistency repay its control-plane, add-on, upgrade, networking, security and debugging cost. Lambda is strong for event-driven, bounded execution when concurrency and downstream behavior are explicitly controlled. ECS often fits teams wanting containers without the full Kubernetes API surface. EC2 remains appropriate for host-level control, legacy software or specialized hardware when the team can operate it.

S3 owns durable object storage behavior under the selected bucket type and storage class. You own namespace, access, versioning, lifecycle, retention, replication choices, data classification and recovery process. Versioning helps recover overwrites or deletes; it also retains billable versions and does not automatically protect against every authorized destructive action. Object Lock, independent accounts and restricted deletion paths address different threats.

RDS manages selected database infrastructure operations, but the application owns connection behavior, schema and transaction safety. Multi-AZ failover can change the serving instance behind an endpoint. Clients with stale DNS, indefinitely pooled connections or unsafe automatic transaction retries can stay broken after RDS declares failover complete. Backups protect recovery points; replicas serve availability or scale goals depending on the specific service design. Neither is valuable until restore and application correctness are tested.

CloudWatch owns telemetry ingestion and query capabilities you configure. You own instrumentation, dimensions, retention, access, correlation, SLI math and alerts. CloudTrail answers many API-change questions; it is not a complete application request log by default. KMS protects key material and performs cryptographic operations under policy; you own who can use the key, dependency behavior during denial or throttling and recovery from disabled or scheduled-deletion states.

## Evidence table

| Claim | Minimum evidence | What it still does not prove | Safest next evidence |
|---|---|---|---|
| the operator is authenticated | federated session identity, account and expiry | the requested action is authorized | evaluate exact action/resource/context across all policy layers |
| IAM allows the request | policy evaluation plus successful request ID | correct business authorization or future requests | application authorization and repeated least-privilege test |
| an SCP is attached | organization policy and target ancestry | any principal has an allow | role, session, boundary and resource-policy evidence |
| the VPC path exists | exact source, destination, routes and policy | listener, identity or return/application success | connection plus application transaction from failing context |
| ALB targets are healthy | target state and health-check response | real user path or dependencies | correlate failing host/path/request ID to target and dependency |
| Auto Scaling is active | desired/current capacity and policy state | launches can succeed during a zone failure | launch activities, quota, subnet IP, stock and dependency headroom |
| an ECS service is stable | desired/running counts and deployment events | tasks serve correct results | target health, task logs/traces and user SLI |
| an EKS control plane is available | Kubernetes API reachability | nodes, Pods, CNI, storage, DNS or application are healthy | controller, node, workload and user-path evidence |
| a Lambda function succeeds | invocation success sample | event backlog, duplicates or downstream health | arrival rate, age, concurrency, dependency and business outcome |
| an S3 object is encrypted | object encryption metadata and key identity | caller should access it or it is recoverable | authorization path, version/retention and restore/read validation |
| RDS failover completed | RDS event and new writer identity | application connections and transactions recovered | endpoint resolution, pool turnover and read/write transaction SLI |
| backups exist | protected recovery points and job result | integrity, isolation, RPO or RTO | isolated restore plus application and business validation |
| CloudWatch alarm is OK | one metric expression is below threshold | the user journey is healthy | user-centered SLI, missing-data behavior and dependency evidence |
| quota utilization is safe | applied value, usage, forecast and alarm | provider stock or downstream capacity | failure-scale launch and dependency capacity exercise |
| the service is recovered | fresh user transaction, error/latency SLI and stable backlog | prevention or every cohort | sustained observation, reconciliation and follow-up action owner |

Evidence should name scope and time. “CPU was fine” is almost useless. “For `POST /orders` in account X, Region Y, between 10:04 and 10:09 UTC, p99 latency rose to 8.2 seconds while database connection acquisition exhausted” is a testable statement. In real work, preserve exact IDs without exposing credentials or customer data.

## Command decoders

The guided lab uses Python only to evaluate a small JSON architecture contract. It deliberately has no AWS CLI, Software Development Kit (SDK), network connection, Terraform provider or credential path.

First ask whether the input is syntactically parseable:

```bash
python3 -m json.tool fixtures/cases.json >/dev/null
```

`python3 -m json.tool` invokes Python’s standard-library JSON formatter/parser. The filename is the input. `>/dev/null` discards formatted output so the exit status is the evidence. Exit zero proves JSON syntax only; it says nothing about field meaning or AWS.

After `bash lab.sh setup`, inspect the exact baseline:

```bash
python3 model.py show fixtures/cases.json baseline
```

`model.py` is lesson code, not an AWS command. `show` selects a read-only rendering operation. The file is the case set; `baseline` is one case key. The output is synthetic and sorted for review:

```json
{
  "bounded_retries": true,
  "identity_bounded": true,
  "immutable_artifact": true,
  "multi_az": true,
  "private_data": true,
  "quota_headroom": true,
  "restore_tested": true,
  "user_sli": true
}
```

Now evaluate it:

```bash
python3 model.py evaluate fixtures/cases.json baseline
```

Expected synthetic branch:

```json
{"boundary": "user-outcome", "case": "baseline", "decision": "operable"}
```

“Operable” means only that eight booleans in a teaching fixture are true. It does not mean the architecture is complete or deployed. The model returns the first failed boundary in dependency order so you learn to stop making broad changes:

```bash
python3 model.py evaluate fixtures/cases.json long-lived-admin
# boundary=identity
python3 model.py evaluate fixtures/cases.json mutable-artifact
# boundary=artifact
python3 model.py evaluate fixtures/cases.json public-database
# boundary=network-exposure
python3 model.py evaluate fixtures/cases.json single-az
# boundary=failure-domain
python3 model.py evaluate fixtures/cases.json quota-no-headroom
# boundary=capacity-quota
python3 model.py evaluate fixtures/cases.json restore-untested
# boundary=recovery
python3 model.py evaluate fixtures/cases.json no-user-sli
# boundary=observability
python3 model.py evaluate fixtures/cases.json unbounded-retries
# boundary=resilience
```

In an authorized AWS environment, commands such as identity inspection, policy simulation, effective-route review or service describe APIs answer narrower questions. This lesson does not print copy-paste cloud commands because running them against an unknown account could expose metadata or create false confidence. Before any future provider command, bind profile/session, account, Region, action risk, output sensitivity and expected API charge. Prefer read-only APIs, redact identifiers in shared evidence and never paste credentials into a lesson terminal.

## Decision path

Use this sequence for a new architecture review or incident. It keeps service names behind the workload contract.

1. **Name the business operation.** State caller, input, expected result, latency/correctness/freshness objective, traffic shape, data class and regulatory boundary.
2. **Draw scope.** Mark organization, OU, account, Region, AZ, VPC, subnet, service, resource and external dependency. Label state and operating owner.
3. **Map identity.** Human federation, workload roles, trust, actions, resources, conditions, guardrails, resource policy, KMS policy and break-glass path.
4. **Trace ingress and egress.** DNS, entry point, certificate, listener/rule, routes, security groups, network ACLs, endpoints, NAT and return path.
5. **Choose compute from constraints.** Runtime duration, scheduling, host control, portability, scaling unit, cold/startup behavior, team skill and upgrade burden.
6. **Bind artifacts and changes.** Immutable version or digest, provenance, IaC plan, approval, rollout health, rollback trigger and database compatibility.
7. **Design data.** Consistency, transaction, object/version, encryption, key ownership, retention, backup, restore order and deletion threat.
8. **Calculate failure capacity.** Normal and peak load, N+1/AZ-loss capacity, quota, subnet IPs, instance stock alternatives, connection limits and backlog drain rate.
9. **Define user evidence.** Success, latency, correctness and freshness SLIs; resource metrics; logs/traces/events; request correlation; alert burn and owner.
10. **Set recovery objectives.** RPO, RTO, backup isolation, restore test, failover/failback, DNS/traffic action and business validation.
11. **Model cost units.** Compute time, requests, storage and versions, I/O, provisioned capacity, NAT/endpoint/load-balancer processing, inter-AZ/Region transfer, telemetry ingestion/retention and idle recovery capacity.
12. **Exercise one failure before launch.** Denied permission, bad artifact, target/dependency error, AZ loss, quota block, restore and retry overload are better tests than a perfect happy-path screenshot.

Choose AWS services by a decision record, not by a memorized “three-tier architecture.”

| Need | EC2/ASG | ECS | EKS | Lambda |
|---|---|---|---|---|
| host/kernel control | strongest | EC2 capacity option can retain it | worker ownership can retain some | none |
| orchestration surface | customer process/system tooling | AWS-native task/service | Kubernetes API/ecosystem | event/function contract |
| operational burden | OS through app | task plus chosen capacity | cluster, ecosystem and workload | event, code and dependency |
| scaling unit | instance | task and capacity | Pod/node/controller | concurrent invocation |
| common fit | legacy/special host needs | container apps seeking simpler AWS orchestration | Kubernetes-standard platform needs | bounded event/request handlers |
| common trap | snowflake instances | ignoring task capacity/deployments | buying Kubernetes complexity without need | overwhelming dependencies with concurrency/retries |

This table is a starting lens, not a universal answer. Security isolation, latency, runtime limits, compliance, specialized hardware, tenancy, portability and staff capability can change the decision.

## Guided Ubuntu lab

The lab is intentionally small because its purpose is to teach review order and safe evidence boundaries. It does not pretend to emulate AWS.

| Item | Requirement |
|---|---|
| operating system | Ubuntu 24.04 |
| user | normal user; UID 0 is refused |
| tools | Bash, Python 3 and standard core utilities |
| network | none |
| cloud | no account, credential, CLI, SDK or provider |
| disk/CPU | less than 1 MB; negligible CPU |
| mutation | one exact `/tmp/reliability-atlas-les0053-model-UID` directory |
| abort | root, credential variables, symlink, unknown state or unexpected artifact |

From `drafts/LES-0053-aws-foundations-reliability/support/lab`:

```bash
bash lab.sh doctor
bash lab.sh setup
bash lab.sh list
bash lab.sh show baseline
bash lab.sh evaluate baseline
bash lab.sh status
```

Expected branch names are illustrative but deterministic for this fixture:

```text
doctor=pass runtime=aws-readiness-model-only
initialize=pass cases=9
case=baseline
decision=operable boundary=user-outcome
status=pass cases=9
```

Evaluate every failure and say the next real evidence aloud:

```bash
for case_name in long-lived-admin mutable-artifact public-database single-az \
  quota-no-headroom restore-untested no-user-sli unbounded-retries
do
  bash lab.sh evaluate "$case_name"
done
```

Do not merely recite the boundary. For `quota-no-headroom`, say: “I need the applied quota and usage at its actual scope, the AZ-loss demand, ASG maximum, subnet addresses, launch errors, acceptable instance alternatives and downstream limits. A quota increase alone does not prove capacity.” That sentence is operational reasoning.

The verifier injects one unknown artifact to prove fail-closed behavior, removes it through an exact guarded operation, evaluates all cases, performs cleanup and proves absence:

```bash
bash verify.sh
# verify=pass cases=9 cleanup=true runtime=model-only
```

If a step fails, stop at the first error. Do not use `sudo`, do not run `rm -rf` yourself and do not change the fixed `/tmp` path. `lab.sh cleanup` accepts only the exact normal-user-owned directory, sentinel and allow-listed files. If it refuses, preserve `ls -la` and `stat` output for review rather than forcing deletion.

Success means the model behaves deterministically and cleanup is proved. It does not award AWS skill. The stronger evidence is your explanation and independent architecture transfer.

## Production transfer

### Incident 1: sign-in succeeds, API is denied

Frame one request: principal session ARN, account, Region, action, resource ARN, context keys, timestamp and request ID. Authentication worked. Now examine role trust, identity policy, session policy, permissions boundary, SCP/RCP ancestry, resource policy and KMS key policy when encryption is involved. Look for explicit deny and condition mismatch before missing allow. Mitigate with the narrowest reviewed statement; do not attach administrator access. Verify the exact operation, an intended denied operation and CloudTrail change evidence. Prevent recurrence with policy tests, Access Analyzer where appropriate, temporary credentials and an owned exception lifecycle.

### Incident 2: ALB healthy, users see intermittent 5xx

Split by hostname, path, status, AZ, target, deployment version and request ID. `HealthyHostCount` can remain green when one authenticated route fails against RDS. Compare ALB access evidence with application logs/traces and dependency signals. Check rule priority, target registration, deployment cohort, connection timeout and zone distribution. Mitigate the bad cohort or route while preserving capacity. Recovery requires the real user transaction and SLI, not just target health. Prevention is a representative synthetic journey, dependency-aware telemetry and a rollout gate tied to user impact.

### Incident 3: AZ loss defeats Auto Scaling

First calculate surviving capacity versus demand. Read scaling activities rather than repeatedly changing desired count. Launch failures may point to `max_size`, quotas, capacity stock, invalid launch template, subnet IP exhaustion or a blocked dependency. Shed optional work, prioritize critical operations and use preapproved alternate instance types or capacity pools. Do not improvise a new public subnet during the incident. After recovery, perform an AZ evacuation exercise, set quota/headroom alarms and keep enough alternate capacity to meet the SLO.

### Incident 4: RDS failover succeeds, application remains broken

Bind the database event timeline to client DNS resolution, connection creation, pool lifetime, transaction errors and read/write SLI. Existing connections can fail; caches can retain an old address; retrying a non-idempotent transaction can duplicate business actions. Mitigate by safely recycling affected pools and controlling retries. Verify new writes, reads of those writes, business invariants and backlog. Prevention includes bounded connection lifetimes, failover testing, idempotency, explicit timeout budgets and an application runbook.

### Incident 5: Lambda throttling and retry storm

Plot event arrival rate, concurrent executions, throttles, duration, errors, queue or iterator age, dead-letter behavior and downstream saturation on one timeline. The safest move may be *lower* reserved concurrency to protect the database while preserving messages in a queue. Make handlers idempotent, align queue visibility timeout with processing behavior, cap retries and use jitter. Recovery is not “throttles dropped”; prove backlog drains within objective, age returns to normal and downstream or user outcomes recover without duplicates.

Production evidence must come from an authorized, sanitized environment. A local lesson result cannot be promoted into resume experience or a production claim.

## Reliability, security, observability, capacity, and cost

### Reliability

High availability handles expected component failure while service continues. Fault tolerance aims to continue with little or no interruption for defined faults. Backup creates recoverable data copies. Disaster recovery reconstructs an acceptable business service after a wider disaster. These overlap, but none substitutes for another.

```text
live write -> protected state -> backup/version -> isolated copy -> restore
  -> dependencies in order -> application validation -> business validation
```

Text equivalent for `LES-0053-DIA-004`: replicas and versions can improve availability or recovery options, yet corruption or authorized deletion may replicate. A separately controlled recovery copy plus tested restoration provides a different boundary. Record achieved RPO and RTO from exercises, not the configured schedule alone.

Design Multi-AZ at the whole-operation level. Compute in two AZs is weak if all egress uses one zonal appliance, the database is single-AZ, only one AZ has sufficient IPs, or a dependency has one endpoint. For Region recovery, decide active/passive or active/active behavior, replication lag, conflict semantics, traffic control, identity, secrets, quotas, infrastructure bootstrap and failback. A second Region that has never been started is a hypothesis.

### Security

Use federation and temporary credentials for humans; roles and temporary credentials for workloads. Protect root access and management-account operations. Apply least privilege to actions, resources and conditions, then validate both intended allows and intended denies. Keep production in separate accounts, centralize protected logs, and give security services delegated administration rather than routine work in the management account where supported.

Keep data private unless a documented user path requires public access. S3 Block Public Access, bucket policy, VPC endpoint policy, IAM and KMS answer different questions. Encryption at rest and in transit is necessary for many data classes, but encryption is not authorization, classification, retention or deletion protection.

Immutable artifacts reduce drift. Pin an Amazon Machine Image (AMI), container digest, function version and infrastructure source revision. Generate a software bill of materials and provenance in the delivery track. A signed artifact still needs vulnerability, configuration and runtime review.

### Observability

Start with a service-level indicator (SLI): for example, the proportion of valid checkout attempts completing correctly under a latency threshold. Then attach resource telemetry that helps explain it. CPU, target health and function error counts are supporting signals.

```text
user transaction -> correlation/request ID -> application span/log
  -> ALB/compute/data signals -> SLI/error budget alert
  -> hypothesis -> safe change -> fresh transaction
```

Text equivalent for `LES-0053-DIA-005`: the operator moves from customer symptom through correlated evidence to a bounded decision and returns to the customer outcome. CloudWatch can hold metrics, alarms, dashboards, logs and application signals, but you must manage dimension cardinality, retention, missing data, access and cost. CloudTrail supports API audit; enable and govern the event classes required by the threat and investigation model.

### Capacity

Capacity has at least five layers:

1. business demand: requests, transactions, bytes, jobs and growth;
2. application capacity: concurrency, workers, queues, pools and cache;
3. resource capacity: CPU, memory, network, storage I/O and addresses;
4. AWS quotas: account, Region or resource maximums and API rates;
5. provider stock and dependencies: launch availability and managed-service throughput.

For each, record current use, safe limit, forecast horizon, failure demand, scaling lead time and owner. Alert before the recovery margin is consumed. Do not run steady state at the exact maximum if rebalancing or replacement must temporarily exceed it.

### Cost

Cost is architecture telemetry. Build the bill from units rather than saying “serverless is cheap” or “managed services are expensive.” Measure instance or task time, function requests and duration, storage class and retained versions, database instance/storage/I/O, load-balancer capacity, NAT processing and hours, public IPv4, endpoints, inter-AZ or inter-Region transfer, backup copies, log/metric/trace ingestion and retention, and recovery capacity.

Tagging and account boundaries help allocation, but allocation is not optimization. First remove waste and accidental transfer, then right-size from demand and SLOs, then evaluate commitments against stable usage. Never save money by silently deleting recovery headroom, logs needed for incident response or backups needed for RPO. State the reliability or security trade explicitly and obtain the correct owner’s decision.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| one account for everything | weak isolation, shared quotas, unclear ownership and large blast radius | workload-oriented accounts, production separation and controlled shared services |
| SCP means permission | guardrails only bound available permission | document grant path and restriction path separately |
| long-lived access keys in CI | difficult rotation and high theft value | workload identity federation and short-lived role sessions |
| public database plus a restrictive security group | unnecessary internet exposure remains a design dependency | private subnets/path, exact security controls and separate application authorization |
| Multi-AZ means DR | it may cover a zonal database failure, not Region/account/corruption or restore | explicit failure matrix, protected backups and tested recovery |
| green health check means good service | check may not exercise auth, dependencies or business correctness | liveness/readiness plus user-journey SLI |
| Auto Scaling guarantees capacity | quota, max, stock, IPs, template or dependency can block launch | failure headroom, alternatives, alarms and launch exercises |
| EKS is automatically the mature choice | Kubernetes adds APIs, controllers, upgrades and operational paths | select from requirements and team operating capacity |
| Lambda scales infinitely | concurrency, event source, account and downstream limits remain | reserved concurrency where useful, queueing, backpressure and idempotency |
| encryption means secure | overbroad callers can still decrypt or read | least privilege, key policy, data policy, audit and threat review |
| replicas are backups | deletion or corruption may replicate and replicas may share control | isolated recovery copies, retention and restore tests |
| retry on every layer | multiplicative traffic appears during dependency failure | one owned retry budget, backoff, jitter, caps and idempotency |
| alert on every AWS metric | noisy pages lack user priority and exhaust responders | SLO/user alerts with diagnostic resource signals |
| raise every quota | higher blast radius and cost can hide bad lifecycle | forecast only required limits, preserve headroom and govern unused resources |
| optimize transfer cost by collapsing AZs | savings silently remove failure tolerance | price the SLO trade and decide with service owner |
| click a console fix without recording it | drift and unreviewed state recur | emergency record, reconciliation into IaC and drift verification |

One more subtle trap: copying a reference architecture without its workload assumptions. A design for a public stateless API may be wrong for a regulated payment write path. Always write the operation, data class, consistency, load, RPO/RTO, ownership and cost constraints above the diagram.

## Memory card and retrieval

When you hear **AWS incident**, retrieve:

```text
operation -> scope -> identity -> path -> compute -> data
          -> quota/capacity -> user evidence -> recovery -> cost
```

When you hear **AccessDenied**, retrieve:

```text
authenticated is not authorized
principal + action + resource + context + request ID
identity/resource allow intersected with session/boundary/organization/key restrictions
explicit deny first
```

When you hear **Multi-AZ**, retrieve:

```text
which component?
what survives?
is there capacity?
where is state?
how does the client reconnect?
what user operation proves recovery?
```

When you hear **backup**, retrieve:

```text
recovery point + isolation + integrity + restore + dependency order
  + business validation + achieved RPO/RTO
```

When you hear **scaling**, retrieve:

```text
demand -> scaling signal -> control delay -> launch/scheduling
  -> quota/stock/IP -> dependency -> backlog -> cost
```

Review schedule:

- after one day, draw the request path and policy layers without looking;
- after one week, explain why ALB healthy, RDS failover complete and CloudWatch alarm OK can all coexist with a broken customer operation;
- after one month, review an unseen architecture and produce a failure-capacity plus recovery table;
- after three months, repeat with changed compliance, Region and cost constraints.

If you cannot name evidence and an abort or rollback condition, recall is incomplete even if the service definitions sound fluent.

## Complete answers

### 1. Why does successful federation not guarantee an AWS API call?

Federation authenticates a person and establishes a role session. Authorization evaluates the requested action, resource and context. The effective decision can include identity policy, resource policy, session policy, permissions boundary, SCP/RCP and service-specific policy such as a KMS key policy. An applicable explicit deny wins. Therefore the correct response to `AccessDenied` is to bind the exact session, action, ARN, conditions and request ID, then inspect each layer. Attaching a broad administrator policy is both unsafe and diagnostically weak because another deny may still apply.

### 2. Why can an ALB show healthy targets while customers receive errors?

Target health means the configured health request passed recently. The customer may use another hostname, listener rule, path, method, identity flow, payload or dependency. Intermittency can also follow one AZ, target or deployment cohort. Correlate the actual ALB request with target and dependency evidence, split by those dimensions and verify a representative transaction. Health checks should answer a bounded routing question; user SLIs answer service reliability.

### 3. What is the difference between quota and capacity?

A quota is an administrative maximum at a documented account, Region, resource or other scope. Capacity is the amount of useful work the whole system can perform. Raising an EC2 quota does not create instance stock, subnet IPs, database connections or dependency throughput. Capacity planning combines demand, per-unit capability, failure demand, scaling delay, quotas, provider availability and downstream limits. Keep headroom where replacement or rebalancing needs it.

### 4. Does RDS Multi-AZ eliminate the need for backup and disaster recovery?

No. Multi-AZ can provide failover within its documented deployment model, improving availability for certain infrastructure failures. It does not by itself recover a desired historical point after corruption or authorized deletion, prove application reconnect behavior, or provide a complete cross-Region/account disaster plan. Backups, isolation, restore tests, RPO/RTO and application validation remain separate requirements.

### 5. How do you choose between EC2, ECS, EKS and Lambda?

Start with constraints: host control, runtime shape, scheduling, portability, scaling unit, isolation, latency/startup, ecosystem, compliance and team skill. EC2 exposes host control and host responsibility. ECS gives an AWS-native task/service model with selectable capacity. EKS provides Kubernetes APIs and ecosystem with corresponding operational complexity. Lambda fits bounded event/request execution when concurrency, idempotency and dependencies are controlled. Choose the least complex model that meets the real contract, then write what AWS owns and what the team owns.

### 6. Why is a backup job marked successful not recovery evidence?

The job proves a tool created or copied something under its own checks. Recovery needs the correct point, integrity, access from a recovery identity, isolation from the original failure, restoration of dependent services in order and a valid business transaction. Measure achieved data loss and elapsed restoration against RPO/RTO. A restore test can still be incomplete if it never validates application semantics.

### 7. What should an SRE monitor in CloudWatch?

Begin with user outcomes: valid operation success, latency, correctness and freshness. Add application metrics, logs and traces with correlation identifiers. Then add resource signals for ALB, compute, queues, Lambda, RDS, S3 and network paths that help diagnose the SLI. Configure missing-data behavior, dimensions, retention and access deliberately. Page on actionable user risk or error-budget consumption; use resource metrics for diagnosis or lower-urgency action unless they directly predict imminent user harm.

## Product-company interview

### Question 1: design a payment API on AWS for one-AZ and instance failure

**What the interviewer evaluates:** requirements discovery, failure domains, consistency, security, scaling, recovery and evidence.

**Strong answer:** I first define payment semantics: idempotency key, authorization or capture workflow, correctness SLI, latency target, peak load, data classification, RPO and RTO. I separate production into a workload account with federated human access and workload roles. A regional entry point and ALB span multiple AZs; stateless compute runs across those AZs with immutable artifacts and enough surviving capacity. I choose ECS, EKS, Lambda or EC2 from runtime and team constraints rather than assuming one. The transaction store uses an appropriate Multi-AZ design, encryption and bounded connections. Requests use timeouts, idempotency and limited retries; external payment-provider failure creates a deliberate pending or degraded state rather than a duplicate charge. I monitor the end-to-end payment outcome, correlate request IDs, protect audit data, test AZ evacuation and database failover, and maintain separately protected backups with restore exercises. I model quotas, subnet IPs, downstream rate limits and failure capacity. Rollouts are progressive with a rollback trigger tied to correctness and latency.

**Weak-answer warning:** listing Route 53, ALB, EKS and RDS without payment state, idempotency, capacity math, recovery or operating ownership.

**Senior follow-ups:** What happens if the payment provider times out after charging? How do you reconcile unknown outcomes? How much capacity survives an AZ? Which operation is safe to retry? How do you fail back the database? Which evidence can auditors trust?

### Question 2: diagnose AccessDenied after an organization migration

**What the interviewer evaluates:** disciplined IAM reasoning and safe debugging.

**Strong answer:** I avoid broad permission changes. I bind the role session, target account, action, resource, Region, request context and request ID. I confirm the intended role trust and session policy. Then I inspect identity and resource allows, permissions boundary, OU ancestry and attached SCP/RCP, and KMS key policy if the operation decrypts or uses an encrypted resource. I look for explicit deny, tag, organization or source-endpoint conditions and policy variables. CloudTrail helps bind the failed call and recent organization changes. I test the narrow correction in a non-production or policy-test boundary, verify an intended allow and deny, record the exception owner and reconcile code.

**Weak-answer warning:** “Add AdministratorAccess to see if it works.”

**Senior follow-ups:** Why may a simulator disagree with runtime? How do resource policies interact? How do you recover if an organization guardrail blocks the normal operator? How do you prevent exception sprawl?

### Question 3: users see 5xx but every AWS dashboard is green

**What the interviewer evaluates:** user-centered observability and incident method.

**Strong answer:** Green is a property of selected thresholds. I define the failing user cohort and operation, then pull a request ID from client, edge or ALB evidence. I split status and latency by route, AZ, target and version, follow the request through application and dependency telemetry, and compare deploy or configuration events. I check whether health probes bypass authentication or data. I mitigate the smallest confirmed cohort, verify a fresh transaction and SLI, then repair the detection gap. I do not change every timeout because that can hide saturation and worsen queueing.

**Weak-answer warning:** “Restart all instances because CloudWatch is delayed.”

**Senior follow-ups:** What if logs are sampled? What if one tenant fails? Which metric dimensions become too expensive? When do you roll back versus degrade a feature?

### Question 4: compare ECS, EKS and Lambda for a bursty API plus background jobs

**What the interviewer evaluates:** trade-offs, not product loyalty.

**Strong answer:** I separate synchronous API and background-job requirements. I quantify duration, concurrency, startup latency, memory and CPU, specialized libraries, event semantics, portability and downstream capacity. Lambda may fit short event handlers if idempotency, concurrency and timeout limits work; a queue decouples bursts. ECS can run long-lived services and workers with a simpler AWS-native orchestration surface. EKS is valuable if Kubernetes APIs, policies, multi-workload platform conventions or portability are requirements the organization can operate. A mixed design can be correct, but every extra runtime adds delivery, identity, telemetry and on-call paths. I compare total operating cost and failure behavior, not compute price alone.

**Weak-answer warning:** “EKS is enterprise, Lambda is infinite scaling.”

**Senior follow-ups:** How do you protect RDS from 20x event arrivals? How do you drain work during deployment? What is the dead-letter and replay contract? Who upgrades the EKS ecosystem?

### Question 5: prove disaster recovery meets a 15-minute RPO and 60-minute RTO

**What the interviewer evaluates:** measurable recovery rather than architecture claims.

**Strong answer:** I map every stateful dependency and define the authoritative data point. I verify backup or replication frequency and lag can meet 15 minutes under failure, including keys, configuration and external records. Recovery infrastructure, identity, quotas, DNS and traffic controls are preplanned. In an isolated exercise, a reviewer declares a failure time; we choose the allowed recovery point, restore in dependency order, deploy the bound artifact and configuration, validate security and perform business transactions. We measure actual lost writes and elapsed time, record manual steps and bottlenecks, then test failback. A successful database restore alone is not the RTO if the service remains unusable.

**Weak-answer warning:** “Cross-Region backups are enabled, so DR is complete.”

**Senior follow-ups:** How do you protect backups from account compromise? What if KMS access is lost? How do you handle DNS cache and data reconciliation? Which costs buy lower RTO?

## Independent transfer and rubric

Your reviewer supplies a fictional regulated order platform and changes at least one constraint after your first design: Region availability, RPO/RTO, traffic peak, data residency, team Kubernetes skill or budget. You receive sanitized requirements and a pre-generated Terraform plan text. You must not use an AWS account, credential, CLI, SDK, provider download, `terraform apply` or public endpoint.

Deliver:

1. user-operation and data-class contract;
2. organization, OU and account design with exception and break-glass ownership;
3. authentication and authorization map including guardrail, resource and KMS policy boundaries;
4. Region, AZ, VPC and subnet request-path and failure-domain diagrams;
5. EC2/ASG, ECS, EKS and Lambda comparison with one selected compute model;
6. S3 and RDS state, consistency, encryption, retention, backup and recovery design;
7. demand, AZ-loss capacity, quotas, subnet IPs, dependency and backlog calculations;
8. user SLI, diagnostic telemetry, alert and incident-response design;
9. progressive deployment, rollback and immutable-artifact contract;
10. cost-unit model plus one rejected cheaper design and its reliability consequence;
11. three incident runbooks covering IAM denial, AZ capacity failure and restore;
12. exact local cleanup evidence and a list of claims requiring provider validation.

Scoring is ten points per category:

| Category | Full-score evidence |
|---|---|
| workload contract | operations, cohorts, correctness, latency, data class and objectives are explicit |
| governance and identity | accounts, roles, policy layers, audit, break-glass and least privilege are coherent |
| network and path | scope, DNS, ingress/egress, private data and return/dependency paths are traceable |
| compute and change | justified compute choice, immutable artifact, rollout and rollback are operable |
| data and security | consistency, encryption, key ownership, retention and deletion threats are addressed |
| reliability and recovery | failure matrix, Multi-AZ limits, backup, restore, RPO/RTO and failback are tested designs |
| capacity and quotas | math includes failure demand, headroom, lead time, IPs, stock alternatives and dependencies |
| observability and incident | user SLI, correlation, alerts, mitigations and recovery proof are precise |
| cost and trade-offs | units, allocation, transfer, telemetry and reliability capacity are reasoned |
| transfer and evidence | changed constraint is handled, weak options rejected, uncertainties labeled and cleanup proved |

Scores mean: below 70, foundation gaps remain; 70 to 84, useful but unsafe omissions remain; 85 to 94, strong production review with bounded gaps; 95 to 100, reviewer observes coherent senior transfer. A score is not mastery until an independent reviewer witnesses the work, challenges assumptions and repeats it after delay.

## References and review

Primary AWS documentation reviewed on 2026-08-05:

1. `REF-0553` — AWS Well-Architected Framework, used for explicit architecture trade-offs.
2. `REF-0554` — AWS Organizations multi-account best practices, used for workload-oriented accounts and boundaries.
3. `REF-0555` — IAM security best practices, used for federation, temporary credentials and least privilege.
4. `REF-0556` — EC2 Regions and Availability Zones, used for scope and failure domains.
5. `REF-0557` — Amazon VPC overview, used for VPC, subnet, routing, endpoint and connectivity boundaries.
6. `REF-0558` — EC2 Auto Scaling architecture benefits, used for replacement, distribution, rebalancing and headroom.
7. `REF-0559` — Application Load Balancer introduction, used for listeners, ordered rules, target groups and health.
8. `REF-0560` — EKS Best Practices Guide, used for the day-two operational boundary.
9. `REF-0561` — ECS Developer Guide introduction, used for capacity, controller, task and service concepts.
10. `REF-0562` — S3 User Guide introduction, used for objects, access, versions, lifecycle and storage choices.
11. `REF-0563` — RDS Multi-AZ documentation, used to distinguish standby and failover designs.
12. `REF-0564` — Lambda best practices, used for idempotency, concurrency, quotas, timeouts and downstream limits.
13. `REF-0565` — CloudWatch overview, used for metrics, alarms, logs, traces, SLOs and cross-account observability.
14. `REF-0566` — KMS Developer Guide overview, used for managed keys and key policy.
15. `REF-0567` — Service Quotas User Guide, used for quota scope, applied values and increase boundaries.

Service behavior, availability, quota, pricing and Region support are version-dependent. Before a real design, re-check the exact service documentation, quotas and pricing for the selected account and Region. This lesson deliberately states no fixed price, default quota or guaranteed failover time.

Related learning: provider-neutral cloud architecture (`LES-0050`), identity and security foundations (`LES-0051`), cloud networking and hybrid connectivity (`LES-0052`), Terraform foundations (`LES-0035`) and Terraform state and modules (`LES-0036`). Continue later with Azure and Google Cloud by translating mechanisms and operating boundaries rather than renaming boxes.

Final summary: AWS reliability is the disciplined ownership of a user operation across scope, identity, path, compute, data, capacity, evidence, recovery and cost. Managed services can reduce undifferentiated work, but you still decide the contract, protect the boundaries, observe the outcome and prove recovery.
