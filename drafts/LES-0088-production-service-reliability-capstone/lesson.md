---
{
  "schemaVersion":1,
  "kind":"lesson",
  "id":"LES-0088",
  "slug":"production-service-reliability-capstone",
  "aliases":["V11-L01","production-service-reliability-capstone"],
  "curriculumIds":["CAP-001"],
  "route":"/book/capstones/production-service-reliability-capstone",
  "order":1,
  "volume":"11-capstones",
  "title":"Production service reliability capstone: build, ship, observe, recover and defend one local service",
  "summary":"Integrate Linux, HTTP, TLS, Python, SQLite, containers, delivery, observability, SLOs, incident command, backup, restore, security and release engineering around one reproducible local service while preserving evidence and production boundaries.",
  "domain":"capstone-engineering",
  "level":{"from":"foundation","to":"expert"},
  "estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0087"],
  "prerequisiteCurriculumIds":["LNX-001","NET-005","AUT-002","BLD-001","CI-001","CTR-002","OBS-001","SRE-001","DR-001","SEC-001","REL-001"],
  "testedEnvironments":[
    {"platform":"Ubuntu","version":"24.04 WSL with Python 3.12.3","support":"required","notes":"Bash syntax, ShellCheck, Python compilation, seven tests and the guarded 40-healthy/20-latency-record verifier pass as a normal user."},
    {"platform":"Docker Desktop","version":"29.6.2 with Linux containers","support":"supported","notes":"Dockerfile static checks, pinned build, UID 10001/read-only runtime, health check, TLS proxy, internal Prometheus scrape, six alert rules and exact cleanup pass."},
    {"platform":"Local service fixture","version":"Atlas capstone revision reviewed 2026-08-07","support":"required","notes":"Dependency-free Python teaching service, SQLite state, NGINX TLS edge and Prometheus are local evidence fixtures, not production software."},
    {"platform":"Production, cloud or organizational environment","version":"not present in the tested boundary","support":"unsupported","notes":"No production endpoint, cloud account, credential, customer data, deployment authority, production RPO/RTO or learner mastery is accessed or claimed."}
  ],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","cloud-engineer","infrastructure-engineer","production-engineer","security-engineer","technical-lead","staff-engineer","solutions-architect"],
  "learningObjectives":[
    "Trace one user operation through TLS proxy, application, transaction, durable state and telemetry boundaries.",
    "Bind source, configuration, schema, dependency and image identities into a reproducible release receipt.",
    "Distinguish liveness, readiness, user correctness, availability, latency, saturation and monitoring health.",
    "Design idempotent write behavior that reconciles ambiguous timeouts without creating uncontrolled duplicates.",
    "Build and verify a least-privilege read-only container with explicit writable state and temporary paths.",
    "Calculate availability, latency objectives, error budgets and burn rates from declared eligible events.",
    "Choose among observation, mitigation, restart, rollback and restore using evidence, reversibility and data-loss boundaries.",
    "Create an online backup, restore it separately, verify integrity and reconcile business state before cutover.",
    "Run a production-shaped incident with roles, 5/15/30-minute communication, preservation and postmortem learning.",
    "Defend architecture, security, reliability, capacity, cost and delivery trade-offs without converting local evidence into production claims."
  ],
  "productionSignals":[
    "The pipeline is green but no one can connect the built image digest to the running service.",
    "Liveness succeeds while readiness and create-item operations fail.",
    "A timed-out write is retried with a new identity and creates a duplicate.",
    "Free filesystem blocks are used to dismiss permissions, inodes, locks, read-only mounts or I/O latency.",
    "CPU above a threshold pages the team while user-visible errors and latency have no objective.",
    "The proxy returns a status that is attributed to the application without correlated hop evidence.",
    "A live SQLite database file is copied blindly or a backup is restored over active state.",
    "A restart clears a symptom and is documented as root cause.",
    "A rollback is attempted after an incompatible schema change without a compatibility receipt.",
    "Metrics expose request IDs or other unbounded values as labels.",
    "The monitoring target is down, so an absent alert is treated as service health.",
    "A local restore duration is presented as a promised production RTO."
  ],
  "diagrams":[
    {"id":"LES-0088-DIA-001","title":"User request and evidence path","direction":"left-to-right","boundaries":["client","TLS edge","application listener","request handler","SQLite transaction","durable volume"],"evidencePoints":["HTTP status and request ID","TLS and proxy timing","structured event and trace context","validation and idempotency result","commit or rollback","database and WAL state"],"textAlternative":"A client request crosses a TLS edge, Python application, handler and SQLite transaction before durable state; each boundary owns distinct evidence and can fail independently."},
    {"id":"LES-0088-DIA-002","title":"Release evidence chain","direction":"left-to-right","boundaries":["source revision","tests and policy","image build","candidate runtime","bounded traffic","promotion or rollback"],"evidencePoints":["Git identity","test and validation receipt","OCI digest","version and security posture","SLI and correctness comparison","decision and observation record"],"textAlternative":"A source revision passes declared checks, becomes an immutable image, runs as a bounded candidate and receives comparable traffic before evidence permits promotion or rollback."},
    {"id":"LES-0088-DIA-003","title":"Health hierarchy","direction":"hierarchical","boundaries":["process liveness","dependency readiness","user operation correctness","service-level objective","business outcome"],"evidencePoints":["listener response","database/schema check","read and idempotent write","availability and latency window","user success and integrity"],"textAlternative":"Process liveness is the narrowest health claim; readiness adds dependencies, probes add operation correctness, SLOs add population and time, and business outcomes remain wider still."},
    {"id":"LES-0088-DIA-004","title":"State protection and recovery path","direction":"left-to-right","boundaries":["active database","online snapshot","manifest","separate restore","integrity and reconciliation","authorized cutover"],"evidencePoints":["transaction boundary","snapshot completion","hash and metadata","new target path","database and business checks","decision owner and observation"],"textAlternative":"Active state creates an online snapshot and manifest; recovery restores to a separate target, verifies integrity and business reconciliation, then requires authorized cutover rather than overwriting live state."},
    {"id":"LES-0088-DIA-005","title":"Incident control loop","direction":"cyclic","boundaries":["user impact","preserved evidence","hypothesis","safe test","decision","validation and communication"],"evidencePoints":["scope and time","correlated packet","predicted observation","bounded reversible action","owner and abort condition","user operation and remaining uncertainty"],"textAlternative":"An incident starts with user impact, preserves evidence, tests explicit hypotheses through bounded actions, makes owned decisions, validates user recovery and communicates uncertainty before looping."},
    {"id":"LES-0088-DIA-006","title":"Telemetry ownership","direction":"hierarchical","boundaries":["external user probe","proxy telemetry","application logs and metrics","database evidence","Prometheus health and rules"],"evidencePoints":["end-to-end result","edge status and latency","request outcome and trace context","transaction/storage result","scrape up and rule evaluation"],"textAlternative":"External probes observe the whole path while proxy, application and database evidence localize ownership; Prometheus health proves whether monitoring can currently see and evaluate those signals."}
  ],
  "commands":[
    {"id":"LES-0088-CMD-012","question":"Do Prometheus configuration and six alert rules parse?","risk":"mutating-bounded","command":"docker run --rm --entrypoint /bin/promtool -v $PWD/ops/prometheus.yml:/etc/prometheus/prometheus.yml:ro -v $PWD/ops/alerts.yml:/etc/prometheus/alerts.yml:ro prom/prometheus:v3.5.0@sha256:63805ebb8d2b3920190daf1cb14a60871b16fd38bed42b857a3182bc621f4996 check config /etc/prometheus/prometheus.yml","runFrom":"support/project with the pinned Prometheus image available","expectedBranches":[{"when":"SUCCESS and six rules are found","meaning":"declared files parse under this promtool version","nextEvidence":"verify runtime scrape and notification separately"},{"when":"failure","meaning":"configuration or rule syntax is rejected","nextEvidence":"fix the first reported file and line"}],"proves":"versioned promtool parsing","doesNotProve":"query meaning, alert delivery or monitoring availability","cleanup":"The --rm flag removes the validation container; verify no unexpected resource remains."},
    {"id":"LES-0088-CMD-011","question":"Does the snapshot reconstruct separately and reconcile?","risk":"mutating-bounded","command":"python3 ops/db_admin.py restore --database .state/backups/atlas.db --manifest .state/backups/atlas.db.manifest.json --target .state/restored/atlas.db --boundary .state","runFrom":"support/project after creating the bounded backup and an empty restored directory","expectedBranches":[{"when":"receipt reports hash, integrity and count checks","meaning":"the local snapshot reconstructed at a new path","nextEvidence":"perform representative business reads before cutover"},{"when":"a check fails","meaning":"the recovery candidate is rejected","nextEvidence":"preserve source and target and investigate"}],"proves":"bounded separate reconstruction and declared checks","doesNotProve":"accepted data loss, production cutover safety or complete semantic reconciliation","cleanup":"Remove the disposable restored path only after retaining evidence."},
    {"id":"LES-0088-CMD-010","question":"Can active SQLite state be snapshotted consistently?","risk":"mutating-bounded","command":"python3 ops/db_admin.py backup --database .state/atlas.db --output .state/backups/atlas.db --boundary .state","runFrom":"support/project against disposable state after creating .state/backups","expectedBranches":[{"when":"receipt includes snapshot and manifest","meaning":"SQLite online backup completed and bounded metadata plus hash were recorded","nextEvidence":"restore to a separate target and verify"},{"when":"failure","meaning":"snapshot completion or manifest creation failed","nextEvidence":"preserve active state and diagnose without overwriting it"}],"proves":"one completed local snapshot and manifest","doesNotProve":"remote durability, production RPO or application-level completeness","cleanup":"After validation, remove only disposable state created by the exercise."},
    {"id":"LES-0088-CMD-009","question":"Does the full topology protect edge and telemetry boundaries?","risk":"mutating-bounded","command":"docker compose up -d --build","runFrom":"support/project after generating disposable certificates","expectedBranches":[{"when":"app, proxy and Prometheus become healthy or ready","meaning":"the bounded topology started","nextEvidence":"probe HTTPS, reject edge metrics and query internal scrape health"},{"when":"a component fails","meaning":"its startup or dependency contract is unsatisfied","nextEvidence":"inspect only its logs, network and mount evidence"}],"proves":"local app, proxy and Prometheus composition","doesNotProve":"trusted PKI, high availability or production monitoring","cleanup":"Run docker compose down --volumes --remove-orphans, ops/cleanup.sh and prove project resources are absent."},
    {"id":"LES-0088-CMD-008","question":"Does the built container enforce the intended runtime boundary?","risk":"mutating-bounded","command":"docker compose up -d --build app","runFrom":"support/project after reviewing Compose resource names and ports","expectedBranches":[{"when":"app is healthy","meaning":"the image starts under the declared Compose health contract","nextEvidence":"inspect UID, read-only root, capabilities, mounts and API behavior"},{"when":"unhealthy or exited","meaning":"startup, health, permissions or state failed","nextEvidence":"inspect bounded logs and container state"}],"proves":"one local Compose runtime state","doesNotProve":"the complete TLS and monitoring topology or production hardening","cleanup":"Run docker compose down --volumes --remove-orphans and verify named project resources are absent."},
    {"id":"LES-0088-CMD-007","question":"Is the image definition structurally safe enough to test?","risk":"mutating-bounded","command":"docker build --check .","runFrom":"support/project with Docker available","expectedBranches":[{"when":"exit 0 with no warnings","meaning":"BuildKit static checks accept the Dockerfile","nextEvidence":"build the pinned image"},{"when":"warning or error","meaning":"the image definition has a rejected or suspicious construct","nextEvidence":"resolve it before runtime testing"}],"proves":"Dockerfile static-check results","doesNotProve":"image contents, vulnerabilities or runtime safety","cleanup":"No project runtime resource is created; inspect builder disk usage and leave shared cache unchanged unless a separately reviewed cache policy authorizes pruning."},
    {"id":"LES-0088-CMD-006","question":"Can metrics be scraped without exposing request identity as labels?","risk":"read-only","command":"curl -fsS http://127.0.0.1:8080/metrics","runFrom":"a local shell while the service runs","expectedBranches":[{"when":"request counters and duration buckets use bounded route, method and status labels","meaning":"the local exposition follows the declared low-cardinality contract","nextEvidence":"compare counters with generated operations"},{"when":"request IDs, item names or trace IDs appear as labels","meaning":"cardinality and disclosure boundaries are broken","nextEvidence":"stop promotion and redesign labels"}],"proves":"current text exposition and visible label set","doesNotProve":"Prometheus scrape health, retention or alert delivery"},
    {"id":"LES-0088-CMD-005","question":"Does one create intent remain idempotent?","risk":"mutating-bounded","command":"curl -sS -H 'Content-Type: application/json' -H 'Idempotency-Key: lab-create-001' -d @request.json http://127.0.0.1:8080/api/v1/items","runFrom":"a second Ubuntu shell against the disposable service","expectedBranches":[{"when":"first call is 201 and exact replay is 200 with the same item","meaning":"one operation identity maps to one committed outcome","nextEvidence":"send different content with the same key and expect conflict"},{"when":"timeout or transport failure","meaning":"outcome is ambiguous","nextEvidence":"reconcile with the same key; do not invent a new operation"},{"when":"409","meaning":"the key already belongs to different content","nextEvidence":"inspect the earlier intent rather than overwrite it"}],"proves":"bounded idempotency behavior for this key and payload","doesNotProve":"exactly-once execution across every distributed failure","cleanup":"Delete disposable state only after stopping the service and preserving evidence."},
    {"id":"LES-0088-CMD-001","question":"Does the bounded local service pass every guarded verification?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"support/project as a normal Ubuntu user","expectedBranches":[{"when":"verify=pass and cleanup=pass","meaning":"seven tests, four modes, API contracts, telemetry, backup, restore, two SLO calculations, three faults and exact cleanup passed","nextEvidence":"inspect which assertions produced the receipt"},{"when":"first assertion fails","meaning":"the candidate is rejected at that boundary","nextEvidence":"preserve the first error and associated evidence"}],"proves":"the declared local fixture lifecycle under tested inputs","doesNotProve":"production reliability, security review or learner mastery","cleanup":"The verifier performs exact allowlisted cleanup and reports state=absent."},
    {"id":"LES-0088-CMD-002","question":"Do focused Python behavior tests pass?","risk":"mutating-bounded","command":"python3 -m unittest discover -s tests -v","runFrom":"support/project","expectedBranches":[{"when":"Ran 7 tests and OK","meaning":"declared HTTP, storage and telemetry contracts pass","nextEvidence":"run the integrated verifier"},{"when":"failure or error","meaning":"a behavior or fixture contract failed","nextEvidence":"read the first failing assertion before changing code"}],"proves":"seven versioned test cases","doesNotProve":"unmodeled behavior, load capacity or production suitability","cleanup":"Tests use temporary directories and close their service processes."},
    {"id":"LES-0088-CMD-003","question":"Can the service start with an explicit local state path?","risk":"mutating-bounded","command":"ATLAS_HOST=127.0.0.1 ATLAS_PORT=8080 ATLAS_DB_PATH=$PWD/.state/atlas.db PYTHONPATH=service python3 -m atlas_service","runFrom":"support/project after creating .state","expectedBranches":[{"when":"startup event contains host, port, database and version","meaning":"configuration parsed and listener/storage initialized","nextEvidence":"probe version, liveness and readiness"},{"when":"startup fails","meaning":"configuration, path ownership, port or schema initialization failed","nextEvidence":"preserve stderr and inspect exact path/listener ownership"}],"proves":"one local process initialized with declared configuration","doesNotProve":"readiness, user correctness or external reachability","cleanup":"Stop with Ctrl+C, confirm the process exits, then remove only the project .state directory if it was created for this exercise."},
    {"id":"LES-0088-CMD-004","question":"Are process and dependency health distinct?","risk":"read-only","command":"curl -fsS http://127.0.0.1:8080/livez && curl -fsS http://127.0.0.1:8080/readyz","runFrom":"a second Ubuntu shell while the local service runs","expectedBranches":[{"when":"both return HTTP 200","meaning":"listener and the bounded database/schema readiness check pass now","nextEvidence":"exercise a user operation"},{"when":"live succeeds and ready fails","meaning":"the process can answer but a required serving invariant failed","nextEvidence":"remove it from traffic and inspect readiness evidence"},{"when":"both fail","meaning":"listener, process, address or path is unavailable","nextEvidence":"inspect process and socket before dependencies"}],"proves":"current responses from two distinct health contracts","doesNotProve":"all user operations or a time-window SLO"}
  ],
  "labs":[
    {"id":"LES-0088-LAB-001","title":"Guided build, release, observe, fault and recover lifecycle","mode":"guided","environment":"Ubuntu 24.04 normal user; Python 3.12; optional Docker Desktop 29.6.2","timeMinutes":240,"privilege":"normal user; no sudo, root, production, cloud or credential use","network":"loopback only after base images are present; build may require registry access when an image is absent","changes":["project-local state files","local Python process","project-scoped containers, networks and volumes","disposable self-signed certificate"],"abortConditions":["root execution","path outside project","symlink or unknown cleanup artifact","non-loopback published address","credential or real data","unexpected image digest","failed evidence conservation"],"recovery":"Stop only exercise processes, preserve the first failed evidence, restore only to a separate project-local target and use exact project-scoped cleanup.","cleanupProof":"Verifier reports cleanup pass and state absent; Docker exercise also proves named resources and generated certificates are absent.","path":"drafts/LES-0088-production-service-reliability-capstone/support/project"},
    {"id":"LES-0088-LAB-002","title":"Independent reviewer-owned release and hidden-fault game day","mode":"independent","environment":"Fresh clone plus reviewer-changed behavior and hidden proxy, application, state or telemetry fault","timeMinutes":240,"privilege":"normal user and reviewer; no answer key, elevated authority, external production endpoint or real credential","network":"loopback and project-scoped Docker networks only","changes":["local build and release receipts","bounded candidate state","reviewer-selected fault","backup and separate restore","incident timeline and postmortem"],"abortConditions":["answer disclosure","unsafe path","in-place restore","unbounded load","secret exposure","unknown cleanup artifact","unsupported production claim","lost rollback or recovery path"],"recovery":"Reviewer stops unsafe work; learner preserves evidence, returns to known local state and validates user operations before continuing.","cleanupProof":"Reviewer signs exact resource absence and confirms no secret, answer key, real data or external mutation remains.","path":"drafts/LES-0088-production-service-reliability-capstone/support/project"}
  ],
  "incidents":[
    {"id":"LES-0088-INC-001","signal":"Create requests time out after release while liveness remains 200 and readiness alternates.","firstThought":"The process exists, but the write path or required state is unhealthy; timeout leaves outcome ambiguous.","safePath":"Freeze release, preserve correlated evidence, remove the candidate from traffic, reconcile with the same idempotency key and inspect transaction or storage latency.","trap":"Retry with a new key or restart everything."},
    {"id":"LES-0088-INC-002","signal":"The exact database mount has free blocks but storage errors increase.","firstThought":"Free blocks eliminate only one capacity mechanism.","safePath":"Inspect inodes, mount flags, ownership, modes, locks, WAL, integrity and I/O latency for the exact path.","trap":"Declare disk healthy because block capacity is free."},
    {"id":"LES-0088-INC-003","signal":"The proxy returns 504 while application logs show some 201 responses.","firstThought":"The edge deadline and application commit may disagree about the same request outcome.","safePath":"Correlate request or trace identity and timing across hops, reconcile state and reuse the operation identity.","trap":"Attribute every 504 to application failure or blindly retry."},
    {"id":"LES-0088-INC-004","signal":"The release is unhealthy and an operator proposes restoring last night's database.","firstThought":"Executable rollback and data restore solve different problems; restore may discard valid writes.","safePath":"Test artifact and schema compatibility for rollback; reserve separate verified restore for proven damage with accepted RPO and authorized cutover.","trap":"Overwrite active state because backup succeeded."},
    {"id":"LES-0088-INC-005","signal":"No SLO alert fires during errors and Prometheus reports the target down.","firstThought":"Monitoring blindness makes silence meaningless.","safePath":"Treat scrape health as an incident signal, use independent user probes and repair telemetry without hiding service impact.","trap":"Conclude the service is healthy because there is no alert."}
  ],
  "assessmentIds":["ASM-0247","ASM-0248","ASM-0249"],
  "referenceIds":["REF-1100","REF-1101","REF-1102","REF-1103","REF-1104","REF-1105","REF-1106","REF-1107","REF-1108","REF-1109","REF-1110","REF-1111","REF-1112","REF-1113","REF-1114","REF-1115","REF-1116","REF-1117","REF-1118","REF-1119"],
  "contentStatus":"substantive-draft",
  "masteryBoundary":"publication-does-not-award-mastery",
  "lastReviewed":"2026-08-07",
  "reviewAfter":"2027-02-07",
  "limitations":[
    "The Python standard-library HTTP server is intentionally small teaching software and is not recommended as a production application server.",
    "SQLite makes transaction, backup and recovery behavior visible locally; it does not model replication, consensus, multi-region failover or every managed database control.",
    "The self-signed local TLS certificate proves encryption mechanics and edge termination, not public trust, automated rotation or organizational PKI governance.",
    "Pinned digests prevent silent input movement but do not prove provenance, vulnerability absence, license acceptability or policy approval.",
    "Local load, SLI, backup and restore measurements describe this machine and interval only; they are not production capacity, RPO, RTO or availability commitments.",
    "The CI workflow is quarantined below the repository root and remains inactive until publication approval moves it into an authorized workflow location.",
    "Formal technical, security, data, accessibility, instructional and assessment review plus reviewer-owned unfamiliar transfer and learner evidence remain required."
  ]
}
---

# Production service reliability capstone: build, ship, observe, recover and defend one local service

## What you see and first thought

You release a small API. Ten minutes later, users say that creating an item sometimes hangs. The process answers `/livez`. The database directory still has free gigabytes. CPU is only 35 percent. A dashboard looks mostly green. One person says, “Restart the containers.” Another says, “Restore last night’s backup.” A third says, “The pipeline passed, so the release cannot be wrong.”

Whenever you see this situation, slow the room down for thirty seconds:

> We do not yet have a container problem, a disk problem or a database problem. We have a user operation that is slow or uncertain. First name that operation, preserve one correlated example and find the boundary that stopped honoring its contract.

That is the center of this capstone. An advanced engineer does not begin with a favorite command. They begin with the **user operation**, the **state it can change**, the **boundaries it crosses**, and the **evidence each boundary owns**.

Atlas is deliberately small: a client reads and creates items; NGINX terminates disposable local TLS; a Python service owns API behavior; SQLite owns durable item and idempotency state; logs, trace context and Prometheus metrics expose different evidence; scripts build, test, load, calculate, back up, restore and clean the fixture.

Small does not mean shallow. The same reasoning scales:

```text
user intent
  -> network and identity boundary
  -> serving process
  -> application contract
  -> durable transaction
  -> response deadline
  -> telemetry
  -> release and recovery decision
```

Ask five questions before proposing a fix:

1. **Which user operation failed?** “Service down” is vague. “Create item exceeded the client deadline between 10:04 and 10:11 UTC” is useful.
2. **What is the correctness risk?** An ambiguously committed write can duplicate or lose business intent if retried badly.
3. **What changed?** Record source revision, image digest, configuration and schema. “The deployment” is not an identity.
4. **Where is the first disagreement?** The client, proxy, application and database may report different truths about one request.
5. **Which action is safest and most reversible?** Observation is safer than mutation. Removing a candidate is safer than rewinding data.

This capstone does not assess memorization of `docker compose up`. It asks whether you can explain the system, reproduce change, prove what was tested, distinguish health layers, preserve ambiguous-write safety, calculate reliability, recover state without destroying the original, communicate uncertainty and install a better control after failure.

For every command, use this contract:

```text
question -> expected branches -> evidence -> proof limit -> next decision
```

If a command cannot answer a specific question, do not run it for appearance. If an action changes state, state its blast radius, rollback and abort condition first.

The repository’s verified run proves the fixture passed declared checks on the recorded environment. It does not prove that a reader can reproduce, diagnose or defend it. Those claims require learner-owned execution and reviewer-observed unfamiliar transfer.

## Terms before commands

A **service** is a capability delivered through an interface over time. A process is one component, not the service. A **user operation** is one meaningful intent such as “create item.” An **invariant** is a condition that must stay true: one accepted idempotency key and payload map to one item; committed items remain readable; an instance is not ready when its required state is unusable.

**Source identity** is the exact Git revision. **Configuration identity** is the version or hash of behavior-changing inputs. **Schema identity** describes the database structure expected by code. An **artifact** is the built output; an OCI digest identifies its content. A tag such as `latest` is a movable name.

```text
release identity =
  source revision + build inputs + configuration + schema + artifact digest
```

A **build** transforms source and dependencies into an artifact. A **release** is an artifact and evidence considered eligible for an environment. A **deployment** changes what runs. **Delivery** is the feedback, safety, policy and recovery system around those actions. A pipeline that copies bytes is automation, not automatically reliable delivery.

**Liveness** asks whether a process can make enough progress that restart might help. **Readiness** asks whether this instance should receive new traffic. **Correctness** asks whether the user operation produced the intended valid result. Keep the claims nested:

```text
live process < ready instance < correct operation < healthy window < successful user outcome
```

An operation is **idempotent** when repeating the same operation identity has the intended single effect. A timeout means the client did not receive a result before its deadline; it does not prove the transaction failed. The server may commit after the client stops waiting.

```text
same intent + same key -> reconcile the same outcome
new key               -> declare a new intent
```

A **transaction** groups state changes so all become visible or none do. **Commit** makes the transaction durable under the database’s configured guarantee. Database **rollback** cancels an uncommitted transaction; release **rollback** runs a previous compatible artifact. Do not confuse either with restoring older data.

SQLite can use a **write-ahead log**, or WAL, where changes are appended before being checkpointed into the main file. Copying only an active main database file can miss journal state. Use the database’s online backup mechanism. A **lock** coordinates concurrent access; free disk space says nothing about lock contention.

Filesystem **blocks** hold content. `df -hT EXACT_PATH` shows block capacity and filesystem type for the filesystem backing that path. **Inodes** represent filesystem objects and metadata on common Linux filesystems; `df -i EXACT_PATH` shows inode capacity. Free blocks do not rule out exhausted inodes, wrong ownership, missing directory traversal, a read-only mount, lock waits, integrity failure or I/O latency.

A **timeout** limits one wait. A **deadline** is the latest acceptable completion time for the whole operation. A **retry** repeats an attempt and adds load. **Backoff** spaces attempts; **jitter** prevents synchronized clients. None of those makes an unidentified write retry safe. Stable operation identity comes first.

An **SLI** is a measured behavior. An **SLO** is a target for that indicator over a window. An **SLA** is a business or legal commitment with consequences. The **error budget** is the permitted bad fraction:

```text
error budget fraction = 1 - objective
allowed bad events     = eligible events * error budget fraction
burn rate              = observed bad fraction / allowed bad fraction
```

At a 99 percent objective, the budget is 1 percent. One million eligible events permit 10,000 bad events. If a short window observes 5 percent bad, burn rate is 5. Eligibility rules matter: health probes, invalid client requests and internal retries should not silently enter or leave the denominator.

A **log** records a discrete event. A **metric** aggregates numeric observations. A **trace** connects work across boundaries. **Cardinality** is the number of distinct label combinations. Request IDs and item names belong in logs or traces, not metric labels, because each value can create a new series.

A **backup** is a recoverable copy plus enough metadata and control to use it. A **restore** reconstructs state. **RPO** is the maximum acceptable data-loss interval. **RTO** is the maximum acceptable restoration interval. A five-second local restore proves neither a five-second production RTO nor an accepted production RPO.

Choose the right recovery lever:

- **restart** replaces process state with the same code and data;
- **rollback** changes executable or configuration state;
- **restore** changes data from a recovery copy;
- **failover** moves service to another ready failure domain;
- **failback** returns it after safety and synchronization are proven.

**Incident command** assigns coordination authority. A **postmortem** is evidence-based learning, not blame and not a story that calls “restart” the root cause.

**Capacity** is serviceable work under declared conditions. **Saturation** is queued or rejected demand when a constrained resource cannot keep up. CPU utilization alone is incomplete: 35 percent CPU can coexist with serialized lock waits.

The **data plane** serves user operations. The **control plane** changes or observes how it runs: CI, deployment, configuration and monitoring. A green control plane does not prove a healthy data plane.

## Architecture map

Start with the user path, then overlay control and observation.

### Diagram 1 — request, state and evidence

```text
                         DATA PLANE

[client]
   | HTTPS + idempotency key + trace context
   v
[NGINX TLS edge] -------- edge status and timing
   | HTTP on project network
   v
[Python listener] ------- structured event and metrics
   |
   v
[validation + route + idempotency decision]
   |
   v
[SQLite transaction] ---- item + key, commit or rollback
   |
   v
[durable volume: database + journal state]

                      OBSERVATION PLANE

[Prometheus] <- private /metrics <- [application]

                        CONTROL PLANE

[Git] -> [tests] -> [image digest] -> [candidate] -> [decision]
```

The client owns intent and deadline. NGINX owns TLS termination and edge timeouts. Python owns validation, API status and operation semantics. SQLite owns atomic durable state. Prometheus owns scraping and rule evaluation—not user success.

### Diagram 2 — release evidence chain

```text
[source revision]
      |
[compile + tests + verifier + policy]
      |
[image from pinned base digest]
      |
[record candidate digest]
      |
[UID 10001 + read-only root + state volume]
      |
[health + correctness + telemetry admission]
      |
[bounded comparable traffic]
   /                            \
fail                             pass
 |                                |
[preserve -> rollback/repair]    [promote -> observe]
```

Every arrow is a gate. A gate names its question, evidence, pass/fail/inconclusive branches, override authority and next action. Tests can omit behavior. A digest can identify vulnerable bytes. A healthy low-traffic candidate can still lack capacity evidence. Evidence narrows uncertainty; it does not create certainty.

### Diagram 3 — health hierarchy

```text
business outcome: valuable work completes correctly
    ^
service window: availability + latency + correctness
    ^
operation: read/create semantics are correct
    ^
readiness: database and schema are usable
    ^
liveness: process can answer
```

If liveness is 200 and create fails, liveness is not lying; you asked it a narrower question. If readiness is 200 but replay duplicates state, readiness misses correctness. If probes pass once but five percent of requests fail for an hour, point checks miss population and time.

### Diagram 4 — recovery without destroying evidence

```text
[active DB + journal]
        | online backup
        v
[snapshot] -> [manifest: hash, time, source, count]
        | restore to NEW path
        v
[candidate] -> hash -> integrity -> schema -> count -> business reads
                                                       |
                                                       v
                                              authorized cutover
```

The separate path preserves the original and allows comparison. A restore tool completing means the file was reconstructed under its checks. It does not mean the business accepts the snapshot age or that every relationship is correct.

### Diagram 5 — incident control loop

```text
[scope impact] -> [freeze + preserve] -> [hypothesis]
      ^                                      |
      |                                      v
[communicate + observe] <- [validate] <- [safe test]
      ^                                      |
      +--------- [mitigate or recover] <------+
```

Write hypotheses with predicted observations. “Maybe database” is weak. “If lock wait exceeds the proxy deadline, the same trace will show proxy 504, application completion after the edge deadline and higher transaction duration without block or inode exhaustion” is testable.

### Diagram 6 — network and trust boundaries

```text
host client
    | 127.0.0.1:8443
    v
[NGINX] -- backend internal network --> [app] --> [state volume]
    |                                      |
 edge network                              +--> internal scrape --> [Prometheus]
                                                                      |
                                                              127.0.0.1 UI
```

The application has no host port in the full topology. Metrics are not routed through the external proxy. Docker Desktop needs an edge network for loopback-published ports in addition to the internal backend network. That is a real platform constraint, not decoration.

Before release, point to the diagram and answer: Where does TLS end? Who creates a 504? Who decides replay versus conflict? What survives restart? Which path stays writable? Can a user reach metrics? Who owns schema compatibility? What proves monitoring itself is alive?

## Request or state path

Follow one create operation. Never jump directly from curl to “the database.”

### 1. The client declares intent

The body describes desired content. The idempotency key describes operation identity. Trace context describes observation identity. The database item ID describes resource identity. They are different:

```http
POST /api/v1/items HTTP/1.1
Content-Type: application/json
Idempotency-Key: create-lab-001
traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01

{"name":"first item"}
```

Retries of the same intent keep the idempotency key. Attempts can have distinct spans within one trace. None of those unique values belongs in a metric label.

### 2. The edge establishes transport and a deadline

NGINX accepts TLS, validates protocol mechanics and forwards selected headers. In production, the client must also verify a trusted chain, hostname and validity. The disposable certificate proves only local termination.

If the upstream exceeds the proxy read timeout, NGINX can return 504 while the application continues. Record client deadline, proxy timeouts, application duration and transaction duration. Otherwise “the request took ten seconds” hides which clock stopped waiting.

### 3. The application creates bounded context

The handler parses trace context, records a monotonic start time and maps the raw path to a bounded route label. It validates method, content type, size, JSON shape, name and idempotency key before touching durable state. Boundary validation is both security and reliability: it rejects ambiguous input and limits resource use.

### 4. The transaction binds intent to outcome

Conceptually:

```text
BEGIN
  find idempotency key
  if same key + same fingerprint:
      return recorded item
  if same key + different fingerprint:
      return conflict
  else:
      insert item
      insert key -> fingerprint -> item outcome
COMMIT
```

The item and key must commit atomically. Item-without-key allows duplication. Key-without-item records an outcome that does not exist. A database uniqueness constraint provides a second line of defense, but application behavior must still translate the conflict safely.

### 5. Commit and response can disagree in time

After commit, the handler serializes the item, records metrics and returns 201. Exact replay returns the same item with 200; changed payload under the key returns 409.

Suppose the transaction commits at 900 ms, the proxy deadline is 800 ms and the client receives 504. The client experienced failure, while durable state contains success. Both observations are true at their boundary. The next attempt with the same key reconciles them. A new key can create a duplicate.

### 6. Telemetry observes; state remains authoritative

The application emits a structured event and updates a counter and duration histogram. Telemetry may fail independently: logs can be delayed, scraping can fail, or a process can exit before a buffer flushes. The database and API contract own the outcome; telemetry helps find it.

The verifier contains a useful lesson from its own development. The load generator originally defined `main()` but never invoked it. The command exited zero and created no records—a false green. The verifier was strengthened to assert exact conservation: forty healthy records and twenty latency records must exist. “Exit zero” became one signal, not the acceptance condition.

### 7. Release control reconciles intended and actual state

The release receipt connects the Git revision to the built digest. The running `/version` response must match that intention. Health and idempotent user probes establish admission evidence. Prometheus `up` establishes scrape visibility. Only after these separate contracts pass should bounded candidate traffic begin.

For any unfamiliar service, build the same path:

| Stage | Owned state | Success evidence | Dangerous assumption |
|---|---|---|---|
| Client | intent and deadline | stable operation ID | timeout means failure |
| Edge | TLS and hop deadline | edge status and timing | proxy status came from app |
| App | validation and semantics | structured outcome | live means correct |
| Database | atomic durable state | commit/reconciliation | free blocks mean healthy |
| Telemetry | observations | correlated signals and scrape health | silence means success |
| Delivery | version transition | immutable receipt and gates | green pipeline means production |

## Failure zoom

Failures rarely respect tool boundaries. Zoom into mechanisms, not product names.

### Incident A — live, not ready

Signal: `/livez` returns 200; `/readyz` alternates between 200 and 503; create latency rises.

Meaning: the process and listener can answer, while a required dependency invariant is unstable. Removing the instance from new traffic is appropriate. Restart may temporarily reset a connection or lock, but it also destroys volatile evidence.

Preserve a correlated request, current image/config/schema identity, readiness reason, database path, lock/transaction duration and mount evidence. Then test a predicted mechanism.

### Incident B — ENOSPC with free blocks

Signal: SQLite reports a storage error. `df -hT` shows capacity.

The phrase “no space left” is an allocation failure, not a diagnosis. Ask what could not be allocated:

- data block;
- inode for a new object;
- quota allowance;
- journal/WAL growth;
- container writable layer;
- volume capacity;
- descriptor or another bounded object reported differently.

Run both block and inode checks against the exact database path. Then inspect effective UID/GID, directory traversal, file mode, ACL/policy, mount read-only state, open handles, database integrity and I/O latency. Deleting random files is unsafe. Identify the object class and largest safe reclaim source; preserve logs and current database evidence first.

### Incident C — proxy 504, application 201

This is not contradictory. The proxy owns its deadline; the database owns commit. Correlate:

```text
trace/request ID
  edge start -> edge timeout -> client 504
  app start  -> transaction wait -> commit -> app 201
```

The user operation is ambiguous. Reconcile with the same idempotency key. Then align deadlines and investigate the slow stage. Blind retries can convert latency into duplication and extra load.

### Incident D — restore proposed for a bad release

Restoring data because code is unhealthy can discard every valid write after the snapshot. Ask two independent questions:

1. Is the current artifact or configuration faulty, and can a schema-compatible previous digest serve current state?
2. Is current data damaged or missing, and which verified snapshot meets an authorized loss boundary?

If the first is true, test bounded rollback. If the second is true, stop writers, preserve current state, restore separately, reconcile, obtain cutover authority and observe. Both can be true, but the evidence and risks remain separate.

### Incident E — no alert because monitoring is blind

Prometheus `up == 0` means the scrape failed. An absent service alert during that interval is not reassuring. Use an independent user probe, inspect target discovery/network/authentication, and treat monitoring health as part of the incident.

### A disciplined hypothesis record

Use this format:

| Field | Example |
|---|---|
| Observation | 12 of 200 candidate creates exceeded 800 ms; baseline had 0 |
| Hypothesis | candidate holds the write transaction longer than the edge deadline |
| Predicted evidence | transaction duration rises; edge 504 precedes app completion for same trace |
| Safe test | one bounded same-key replay plus correlated timing |
| Falsifier | edge rejects before app receives request, or transaction duration remains normal |
| Action if supported | remove candidate, preserve state, test compatible rollback |
| Proof limit | association in this interval; other contributors may remain |

### Five-minute, fifteen-minute and thirty-minute thinking

At five minutes, communicate impact, start time, affected operation, change correlation, roles and what is frozen. Do not announce root cause.

At fifteen minutes, state confirmed facts, leading hypothesis, rejected hypotheses, mitigation, reversibility, current user state and next decision.

At thirty minutes, state recovery progress, correctness and SLI validation, monitoring health, remaining risk, observation window, follow-up owner and whether leadership authority is needed.

A useful update is short:

> Create-item is affected; reads remain healthy. The candidate is removed from new traffic. We have preserved two request traces and current database/WAL state. One timed-out request committed, so clients must reuse their idempotency key. We are testing schema-compatible rollback. Data restore is not authorized because corruption is not established. Next update in fifteen minutes.

### Root cause is not the last action

“Restart fixed it” describes temporal association. A stronger causal statement is: “The candidate opened a write transaction before a 700 ms injected wait. The edge deadline was 500 ms, so clients received 504 after the transaction began. Same-trace logs show commits after the edge response. Removing the candidate restored latency; a regression test now asserts transaction placement and timeout behavior.”

That statement includes mechanism, evidence, mitigation and prevention. It still avoids claiming that one mechanism was the only contributor unless evidence supports that.

## Internals and state ownership

Production safety improves when every state has one declared owner and lifecycle.

### Configuration

`config.py` reads host, port, database path, service version and fault mode. Configuration is validated at startup rather than accepted until the first request. The service binds to loopback in the direct-process lab. In the container topology, the application listens on its private network while only the proxy publishes a loopback host port.

Configuration is state. Record it in the release receipt, avoid secrets in defaults, and distinguish static boot configuration from dynamic control. A configuration rollback can be as consequential as a binary rollback.

### Listener and concurrency

The standard-library server is deliberately transparent teaching code, not a production server recommendation. A listener accepts sockets; a handler executes a request; concurrent handlers can contend for database access and CPU. A process can accept a connection while the requested operation cannot complete.

The shutdown path matters. Calling server shutdown from the same serving thread can deadlock. Atlas uses a separate shutdown thread when handling a signal. This illustrates a broader rule: lifecycle controls have their own concurrency contracts.

### SQLite schema and atomicity

The database owns two related records:

```text
items(id, name, created_at)
idempotency_keys(key, request_hash, item_id, response, created_at)
```

The exact implementation may encode fields differently, but the invariant is stable: the key, request fingerprint and outcome are committed with the item. A unique key rejects races. Foreign-key or application checks preserve linkage. Transactions are short because holding a write transaction during slow external work serializes other writers.

SQLite is embedded: the application process opens a file rather than contacting a separate database server. That removes network failure but concentrates filesystem, locking and process concerns. It is suitable for this local model; it is not a claim that every production service should use SQLite.

### Readiness ownership

Readiness checks the ability to use the required database and expected schema. It should be cheap, bounded and meaningful. It should not perform a destructive write or depend on optional analytics. If readiness fails, the traffic system removes the instance while the process remains available for diagnosis.

Liveness is intentionally narrower. Making it depend on the database would restart every process during a shared storage event and could worsen recovery.

### Fault injection

Atlas has bounded modes:

- `none`: expected operation;
- `readiness-failure`: process remains live but not ready;
- `write-failure`: write path returns a controlled failure;
- `latency`: requests are delayed to expose deadline and SLI behavior.

A fault mode is useful only when it has a boundary, expected signal, recovery and cleanup. It must never accidentally point to a real endpoint or state path.

### Metrics and histogram state

Counters accumulate events and do not decrease during one process lifetime. A latency histogram counts observations into cumulative buckets and exposes a total count and sum. Quantiles derived from aggregated histogram buckets can combine instances; a client-side summary has different aggregation behavior.

Route labels use templates such as `/api/v1/items` rather than raw paths. Status classes or bounded codes are safe dimensions; item names and request IDs are not.

Process restart resets in-memory counters. Prometheus time series can preserve pre-restart samples, but queries must handle counter resets. The database does not derive truth from metric counters.

### Container boundaries

The image uses a non-root UID. Compose sets:

- read-only root filesystem;
- dropped Linux capabilities;
- no-new-privileges;
- explicit writable state volume;
- temporary writable paths backed by controlled tmpfs where required;
- health check;
- bounded networks and loopback host exposure.

Non-root is not a complete sandbox. The application can still corrupt any state it is allowed to write. Least privilege reduces blast radius; validation, backups, authorization and isolation remain necessary.

### Proxy boundaries

NGINX owns TLS termination, external routing, selected forwarded headers and upstream deadlines. With a read-only root, NGINX temporary and PID paths must point to writable temporary locations. A proxy can be healthy while its upstream is not; its status and upstream status must not be conflated.

### Backup and manifest ownership

`db_admin.py backup` uses Python’s SQLite backup interface to create a consistent snapshot. A manifest records the source, snapshot, creation time, size, hash and bounded counts. Hash matching detects unintended byte change; it does not prove semantic correctness.

Restore refuses unsafe targets, verifies the selected snapshot against its manifest, writes to a new path and runs integrity/count checks. Business reconciliation remains a separate responsibility.

### Cleanup ownership

Cleanup is production engineering in miniature. The scripts know exact project prefixes and refuse root, symlinks, wrong ownership and unknown artifacts. They do not recursively delete a guessed directory. Verification ends by proving expected state is absent.

The principle is simple: creation and cleanup should share the same identity model. If you cannot enumerate what the exercise created, you cannot safely automate deletion.

## Evidence table

Use evidence to remove branches from the decision tree. Never let one signal claim more than it observed.

| Signal | What it supports | What it cannot prove | Next evidence |
|---|---|---|---|
| `/livez` is 200 | listener and narrow process path answer now | dependency, correctness or SLO health | readiness and a user operation |
| `/readyz` is 503 | required serving invariant failed | exact mechanism | readiness reason, database/schema/path evidence |
| first create is 201 | one request returned created | durability after restart or replay safety | read, restart and same-key replay |
| exact replay returns same item | bounded idempotency path worked | every race or distributed failure | concurrent/timeout transfer test |
| changed payload returns 409 | one key cannot silently change intent | client uses keys correctly | client telemetry and contract tests |
| proxy 504 | upstream response missed edge contract | app did not commit | same-trace app and state reconciliation |
| app 201 after edge 504 | app reports completion after edge deadline | client received success | database lookup and same-key replay |
| `df -hT PATH` has capacity | blocks are available on that mount | inode, quota, permission, lock or latency health | `df -i`, identity, mount, database and I/O |
| `df -i PATH` is 100 percent | no free inode allocation on that filesystem | which objects are safe to remove | object counts, owners, retention and open files |
| database integrity check passes | structural checks passed for that file | business completeness or latest state | manifest, counts and representative reads |
| snapshot hash matches | bytes match recorded snapshot | snapshot was correct or meets RPO | integrity, schema, counts, business reconciliation |
| container UID is 10001 | process is not root | least privilege is complete | capabilities, mounts, seccomp/policy and write tests |
| root filesystem is read-only | undeclared root writes are blocked | state volume cannot be corrupted | mount inventory and negative authorization tests |
| external `/metrics` is 404 | proxy route does not expose it | network path is inaccessible to all attackers | network policy, bind addresses and auth review |
| Prometheus `up == 1` | target scrape succeeded recently | user operation is healthy | user SLI and correctness probes |
| Prometheus `up == 0` | monitoring cannot scrape target | application is down | independent probe and target/network evidence |
| p95 rises | at least five percent exceed the estimated threshold region | cause or individual request story | histogram distribution, traces and resource evidence |
| CPU rises | compute demand or accounting rose | CPU caused user failure | run queue, throttling, profiles and SLI correlation |
| pipeline green | declared jobs passed for their inputs | running production artifact or behavior | digest reconciliation and runtime admission |
| rollback restores SLI | candidate change is materially associated in the tested interval | it was the only contributor | regression test, state and environmental review |

### Evidence packet for one incident

Collect a bounded packet before mutation:

1. incident ID, UTC window and user operation;
2. current and previous source, image, configuration and schema identities;
3. two representative request or trace IDs;
4. client and proxy status/timing;
5. application structured events;
6. exact state-path block, inode, ownership and mount evidence;
7. database transaction, integrity and journal evidence;
8. SLI numerator, denominator, latency distribution and scrape health;
9. actions already taken and their results;
10. explicit unknowns and prohibited data.

Do not dump every log. A useful packet is small enough for another engineer to reason from and rich enough to preserve the first meaningful failure.

### Fact, calculation, hypothesis and decision

Label records:

- **fact**: directly observed with source and time;
- **calculation**: formula plus recorded inputs;
- **hypothesis**: mechanism and predicted observation;
- **decision**: selected action, alternatives, owner, risk and abort condition;
- **unknown**: material information not yet supported.

“The database caused it” is an unlabeled conclusion. “Transaction-duration p95 increased from the comparable baseline while block/inode capacity remained; lock placement is the leading hypothesis” is reviewable.

### Negative evidence

Absence can be useful only when observation was capable of seeing the event. No app log is weak if logging is broken. No alert is weak if Prometheus is down. No duplicate in ten requests is weak evidence about a one-in-ten-thousand race.

Always ask: **If the failure happened, would this instrument have recorded it?**

## Command decoders

Run commands from `drafts/LES-0088-production-service-reliability-capstone/support/project` inside Ubuntu. Read `README.md` first. Never paste an incident command before naming its question.

### `bash ops/verify.sh`

`bash` runs the guarded lifecycle. The script checks normal-user authority and bounded paths, compiles Python, executes seven tests, starts local service modes, exercises HTTP and idempotency, asserts record conservation, checks telemetry, performs backup and separate restore, evaluates SLO calculations, validates three injected faults and proves cleanup.

Expected final lines include:

```text
verify=pass tests=7 modes=4 api=true idempotency=true trace=true metrics=true backup=true restore=true slo_calculations=2 faults=3 external_calls=none production_actions=none
cleanup=pass state=absent
```

If it fails, the first failed assertion is the lesson. Do not run a later command to hide it.

### `python3 -m unittest discover -s tests -v`

`-m unittest` runs Python’s test module. `discover` searches, `-s tests` selects the start directory and `-v` names each case. “Ran 7 tests” matters: zero discovered tests can exit successfully in poorly guarded systems. Tests prove only their declared inputs.

### Service startup

```bash
mkdir -p .state
ATLAS_HOST=127.0.0.1 \
ATLAS_PORT=8080 \
ATLAS_DB_PATH=$PWD/.state/atlas.db \
PYTHONPATH=service \
python3 -m atlas_service
```

Environment assignments apply only to this process. `$PWD` expands to the current project path. `PYTHONPATH=service` makes the local package importable without installation. Keep this foreground terminal open so startup and request events remain visible.

### Health with HTTP status

`curl -fsS` combines failure on HTTP 4xx/5xx (`-f`), quiet progress (`-s`) and useful errors (`-S`). For diagnosis, use:

```bash
curl -sS -o /tmp/ready.body -w 'status=%{http_code} time=%{time_total}\n' \
  http://127.0.0.1:8080/readyz
```

`-o` separates body; `-w` prints status and total client-observed duration. One successful probe is a point observation, not availability.

### Idempotent creation

Avoid complex shell quoting by creating a project-local request file:

```bash
printf '%s\n' '{"name":"first item"}' > request.json
curl -i -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: lab-create-001' \
  --data-binary @request.json \
  http://127.0.0.1:8080/api/v1/items
```

`-i` shows response headers, and `--data-binary @request.json` sends exact file bytes. Repeat exactly and compare item identity. Change the name while retaining the key and expect 409. Remove `request.json` during cleanup.

### Exact-path storage

```bash
df -hT .state/atlas.db
df -i .state/atlas.db
namei -l .state/atlas.db
stat .state/atlas.db
```

`df` maps the path to its backing filesystem. `-hT` prints human-readable blocks and type; `-i` switches to inode counts. `namei -l` explains traversal permissions for every path component. `stat` shows owner, mode, size and timestamps. None measures lock waits or device latency.

### Metric exposition

`curl -fsS http://127.0.0.1:8080/metrics` shows Prometheus text. Confirm counter names include base units where appropriate, histogram buckets are cumulative, labels are bounded, and the count changes by the expected number of requests. Never accept merely “text appeared.”

### Docker checks

`docker build --check .` asks BuildKit to evaluate Dockerfile checks; it may create or update builder cache, so the lesson classifies it as bounded mutation. `docker compose config` renders the merged model without starting services and is a useful next check.

`docker compose up -d --build` builds and starts project services in the background. `-d` detaches; `--build` refreshes the application image. Inspect `docker compose ps`, then verify effective user and mounts. Always pair it with:

```bash
docker compose down --volumes --remove-orphans
```

`--volumes` deletes the disposable named state volume. That is destructive and acceptable only for this lab’s generated state.

### Backup and restore

Run backup, then select the exact printed snapshot and manifest paths. Do not use an uncontrolled wildcard in an operational restore. The restore target must not exist and must be separate from active state. Treat any hash, integrity or count failure as rejection, not a warning.

### Prometheus validation

`promtool check config` proves parser acceptance under a version. It does not send an alert. Runtime evidence also requires target `up`, rule evaluation and—where configured—a tested notification receiver.

## Decision path

Use this path when a release or service becomes unhealthy.

### Step 1 — protect people and state

Declare the affected operation, impact, time window and correctness risk. Assign incident command, operations, communication and scribe roles. Freeze concurrent releases. If credentials or personal data may be exposed, follow the security escalation path instead of copying evidence into ordinary chat.

### Step 2 — decide whether serving should continue

```text
Is correctness at risk?
  yes -> stop or isolate writes; preserve state
  no  -> is readiness failing?
          yes -> remove unhealthy instance from new traffic
          no  -> use SLI and capacity evidence to bound exposure
```

Correctness outranks latency. A fast duplicate is not success.

### Step 3 — identify the failing boundary

Start outside and move inward:

1. client DNS, connection, TLS, deadline and response;
2. proxy route, status, upstream status and timing;
3. process identity, listener, liveness and readiness;
4. validation, route and version;
5. transaction, lock, schema and state;
6. exact filesystem and device path;
7. telemetry collection and query.

Stop when the first contract disagreement appears, then gather adjacent evidence. Do not dump every system metric before locating the request.

### Step 4 — handle ambiguous writes

If the client timed out after a write began, classify outcome as unknown. Query by stable operation identity or replay the exact request with the same idempotency key. Never generate a new key merely to “try again.”

### Step 5 — choose the smallest recovery lever

| Evidence | Preferred first lever | Why |
|---|---|---|
| transient process corruption, same artifact/state safe | bounded restart | replaces volatile process state |
| candidate artifact/config causes regression; schema compatible | rollback | reverses executable state |
| current failure domain unavailable; replica is ready and consistent | failover | changes serving location |
| data lost or corrupted; verified recovery point accepted | separate restore then cutover | reconstructs state |
| overload without defect | shed/degrade/scale within policy | protects essential work |
| unknown mechanism and stable impact | observe or reduce exposure | preserves evidence and reversibility |

Restart is not harmless: it changes process state and can destroy evidence. Restore is not rollback: it can discard valid writes. Failover is not recovery if the replica shares the same corruption.

### Step 6 — write action conditions

Before mutation:

```text
action:
expected mechanism:
blast radius:
success signal:
abort signal:
rollback:
owner:
evidence to preserve:
```

For a candidate rollback: success may require create/read correctness, readiness, p95 recovery and error-rate recovery. Abort if the previous artifact cannot read current schema or causes reconciliation drift.

### Step 7 — validate recovery in layers

Recovery is not “command exited zero.” Validate:

- running identity;
- liveness and readiness;
- representative read;
- first create, exact replay and conflicting replay;
- no state divergence;
- availability and latency over a declared observation window;
- Prometheus scrape and rule health;
- queue, saturation and resource reserve;
- logs free of new severe errors;
- customer or stakeholder impact.

State what remains untested.

### Step 8 — decide when the incident ends

End active incident response when user operations are restored and stable enough for normal ownership, not when every causal detail is known. Preserve unresolved questions in the postmortem. Assign owners and due dates to prevention work.

### Release decision table

| Candidate result | Decision |
|---|---|
| test or policy gate fails | do not build or release |
| image identity differs from receipt | reject candidate |
| readiness or correctness fails before traffic | reject candidate |
| telemetry blind | pause; do not promote without alternate evidence and authority |
| small traffic slice consumes fast budget | abort and preserve |
| healthy but sample too small | extend bounded observation; do not claim safety |
| all declared gates pass | eligible for next bounded stage, not guaranteed safe |

The senior habit is not caution without action. It is making the next action **bounded, observable, reversible and owned**.

## Guided Ubuntu lab

This lab is local, bounded and disposable. It uses no cloud account and sends no application request outside loopback. Run as a normal Ubuntu 24.04 user. Stop if the resolved project path is not the expected clone, if you are root, or if the directory contains real data.

### Phase 0 — orient and record the boundary

```bash
cd /path/to/DevOps-SRE-Learning-Path/drafts/LES-0088-production-service-reliability-capstone/support/project
pwd
id
git rev-parse HEAD
python3 --version
```

The path is an example for this checkout; use the actual fresh-clone path. `id -u` must not be zero. Record the Git revision and tool version in your evidence receipt.

Read `README.md`, `ARCHITECTURE.md`, `SLO.md`, `RUNBOOK.md` and `THREAT-MODEL.md`. Before running anything, draw the client, proxy, app, database, metrics and release boundaries from memory. Mark every writable path.

### Phase 1 — run the complete guarded verifier

```bash
bash verify.sh
```

Expected summary:

```text
verify=pass tests=7 modes=4 api=true idempotency=true trace=true metrics=true backup=true restore=true slo_calculations=2 faults=3 external_calls=none production_actions=none
cleanup=pass state=absent
```

Do not treat the summary as magic. Find where the verifier asserts 40 healthy and 20 latency records. Explain why checking only exit zero would have missed the earlier load-generator defect.

### Phase 2 — start the baseline by hand

Terminal A:

```bash
export PYTHONPATH=service
export ATLAS_DB_PATH="$PWD/var/atlas.db"
python3 -m atlas_service
```

Terminal B:

```bash
curl -sS -o /tmp/atlas-live.json -w 'live status=%{http_code} time=%{time_total}\n' \
  http://127.0.0.1:8080/livez
curl -sS -o /tmp/atlas-ready.json -w 'ready status=%{http_code} time=%{time_total}\n' \
  http://127.0.0.1:8080/readyz
cat /tmp/atlas-live.json
cat /tmp/atlas-ready.json
```

Expected: both HTTP statuses are 200. Explain the narrower claim each response supports.

Create and replay one intent:

```bash
printf '%s\n' '{"name":"first item"}' > request.json
curl -i -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: manual-example-0001' \
  --data-binary @request.json \
  http://127.0.0.1:8080/api/v1/items
curl -i -H 'Content-Type: application/json' \
  -H 'Idempotency-Key: manual-example-0001' \
  --data-binary @request.json \
  http://127.0.0.1:8080/api/v1/items
```

Expected: first creation is 201; exact replay is 200 and identifies the same item. Change the name in `request.json` but retain the key; expect 409. This proves one bounded contract. It does not prove global exactly-once behavior.

Inspect the exact state path:

```bash
df -hT "$ATLAS_DB_PATH"
df -i "$ATLAS_DB_PATH"
namei -l "$ATLAS_DB_PATH"
stat "$ATLAS_DB_PATH"
```

Explain blocks, inodes, traversal and effective ownership. Then fetch `/metrics` and locate the request counter and latency histogram. Confirm unique request IDs are absent from labels.

### Phase 3 — observe fault separation

Stop Terminal A with Ctrl+C and confirm the process exits. Start readiness failure:

```bash
ATLAS_FAULT_MODE=readiness-failure python3 -m atlas_service
```

Probe liveness and readiness. Expected: liveness 200, readiness 503. Write the traffic decision and explain why automatic process restart is not the first diagnostic action.

Repeat with `ATLAS_FAULT_MODE=write-failure`. Reads and health retain their declared behavior while create returns a bounded 503. Then use:

```bash
ATLAS_FAULT_MODE=latency ATLAS_FAULT_DELAY_MS=700 python3 -m atlas_service
```

Measure client time. State what would happen if an edge deadline were 500 ms. Stop each process before changing mode.

### Phase 4 — build the application container

Return to no running manual process, then:

```bash
docker build --check .
docker compose config --quiet
docker compose up -d app
docker compose ps
curl --fail http://127.0.0.1:18080/readyz
```

Inspect the effective boundary:

```bash
docker compose exec app id
docker inspect atlas-capstone-app-1 \
  --format 'readonly={{.HostConfig.ReadonlyRootfs}} user={{.Config.User}}'
```

Compose may choose a container name variant; use the exact name from `docker compose ps`. Expect UID/GID 10001 and a read-only root. Verify the explicit state volume is writable by exercising create, not by writing elsewhere.

Cleanup:

```bash
docker compose down --volumes --remove-orphans
```

The volume contains only disposable lab state. Never add `--volumes` to an unrelated project.

### Phase 5 — run TLS edge and monitoring

```bash
bash ops/generate-certs.sh
docker compose --profile full up -d
docker compose --profile full ps
curl --cacert certs/localhost.crt https://127.0.0.1:18443/readyz
curl -sS -o /tmp/edge-metrics.body -w 'edge_metrics_status=%{http_code}\n' \
  --cacert certs/localhost.crt https://127.0.0.1:18443/metrics
curl --fail http://127.0.0.1:19090/-/ready
```

Expected: TLS readiness succeeds; edge metrics returns 404; Prometheus readiness succeeds. Query the Prometheus HTTP API or UI for `up{job="atlas-capstone"}` and expect 1. Explain why this proves scrape health but not alert notification or user correctness.

Inspect certificate scope:

```bash
openssl x509 -in certs/localhost.crt -noout -subject -issuer -dates -ext subjectAltName
```

The certificate is self-signed, local and seven-day. It must not be described as trusted production PKI.

### Phase 6 — backup, verify and restore separately

For the manual database created earlier, stop its writer first for a simple exercise and set one bounded root:

```bash
mkdir -p "$PWD/var/backups" "$PWD/var/restored"
python3 ops/db_admin.py backup \
  --database "$PWD/var/atlas.db" \
  --output "$PWD/var/backups/atlas.db" \
  --boundary "$PWD/var"
python3 ops/db_admin.py verify \
  --database "$PWD/var/backups/atlas.db" \
  --manifest "$PWD/var/backups/atlas.db.manifest.json"
python3 ops/db_admin.py restore \
  --database "$PWD/var/backups/atlas.db" \
  --manifest "$PWD/var/backups/atlas.db.manifest.json" \
  --target "$PWD/var/restored/atlas.db" \
  --boundary "$PWD/var"
```

Expected receipts report completed backup, verification and separate restore. Compare item counts and read representative items from the restored service. Do not overwrite `var/atlas.db`. Record snapshot time; calculate potential data loss if writes continued afterward. That calculation is an exercise, not an accepted RPO.

### Phase 7 — calculate service evidence

The full verifier generates 40 healthy records and 20 delayed records. To explore manually, start the normal service and run a bounded sample:

```bash
python3 ops/load.py \
  --url http://127.0.0.1:8080/api/v1/items \
  --requests 40 \
  --concurrency 4 > "$PWD/var/healthy.ndjson"
test "$(wc -l < "$PWD/var/healthy.ndjson")" -eq 40
python3 ops/slo.py \
  --input "$PWD/var/healthy.ndjson" \
  --availability-target 0.99 \
  --latency-target-seconds 0.25
```

The line-count assertion is an evidence-conservation gate. Read the output fields and recompute availability, allowed bad fraction and percentile from recorded events. Small local samples are educational, not capacity tests.

### Phase 8 — cleanup and absence proof

```bash
docker compose --profile full down --volumes --remove-orphans
bash ops/cleanup.sh
rm -f request.json /tmp/atlas-live.json /tmp/atlas-ready.json /tmp/edge-metrics.body
test ! -e certs/localhost.key
docker compose --profile full ps --all
git status --short
```

`ops/cleanup.sh` removes only allowlisted generated project state and refuses unsafe ownership/symlink conditions. Review `git status`: generated state should not appear as an unintended tracked change. Do not use broad recursive deletion.

### Lab acceptance

Your evidence packet must contain:

- diagram and release tuple;
- verifier summary and first-gate explanation;
- live/ready distinction;
- idempotent create, replay and conflict;
- exact-path block/inode/ownership interpretation;
- bounded metric-label review;
- one fault with predicted and observed evidence;
- non-root/read-only container receipt;
- TLS scope, external metrics denial and internal scrape health;
- backup manifest, separate restore and reconciliation;
- SLI calculation and proof limit;
- exact cleanup receipt.

Do not advance to the independent game day merely because the commands ran. Explain every boundary without reading the answer.

## Production transfer

Do not copy this Compose file into production and call the capstone complete. Transfer the **controls and questions**, then select production technology for the real constraints.

### Local fixture to production control

| Local mechanism | Production question | Typical stronger control |
|---|---|---|
| Git revision | which reviewed source produced the artifact? | protected branch, signed provenance, immutable build record |
| pinned base digest | can an input move silently? | reviewed update automation, SBOM, vulnerability and policy gates |
| seven unit tests | which contracts and failures are covered? | layered unit, integration, contract, migration, performance and security tests |
| inactive CI template | who may build and release? | approved workflow, least-privilege identity, protected environments and audit |
| Compose candidate | how is blast radius bounded? | canary, blue-green or ring deployment with traffic control |
| self-signed TLS | who authenticates whom and rotates trust? | organizational PKI, automated issuance/rotation, revocation and mTLS where justified |
| SQLite volume | who owns durability and concurrency? | managed or operated database with backup, replication, encryption and recovery contracts |
| local Prometheus | will telemetry survive service/domain failure? | redundant collection, durable remote storage, metamonitoring and tested notification |
| online snapshot | where are copies isolated and immutable? | retention, remote copies, access separation, recovery vault and scheduled restore tests |
| shell cleanup | what is the resource lifecycle? | IaC destroy plan, ownership tags, policy, approval and drift evidence |

### Release packet

A production candidate should carry:

1. source revision and review;
2. dependency lock and update status;
3. artifact digest, SBOM and provenance;
4. configuration and schema versions;
5. test, scan and policy results;
6. known vulnerabilities and accepted exceptions;
7. capacity comparison and cost change;
8. SLOs, dashboards, alerts and monitoring-health check;
9. migration, rollback, backup and restore evidence;
10. owner, rollout stages, abort thresholds and communication plan.

A digest is identity, not trust. A scanner is detection, not authorization. An approval is governance, not technical correctness. Combine them.

### Schema-compatible delivery

Stateful releases should prefer:

```text
expand schema -> deploy compatible writers/readers -> migrate data
-> verify -> stop old behavior -> contract schema later
```

Test old and new artifacts against intermediate schema states. If the new code writes a representation the old code cannot read, executable rollback is not safe even when the old image exists.

### Progressive delivery

Start with the smallest slice that produces useful evidence. Candidate and baseline traffic must be comparable by request type, region, tenant class and time. Correctness failures abort immediately. Availability or latency thresholds should connect to error-budget policy. Low traffic may require synthetic operations and a longer window.

Avoid these canary lies:

- candidate receives only easy requests;
- sample is too small to detect the expected failure rate;
- client retries hide errors while multiplying load;
- monitoring is blind;
- database is shared, so candidate corrupts state for baseline;
- promotion changes configuration not tested in canary;
- success threshold is chosen after seeing results.

### Production recovery design

Define RPO and RTO with business owners before selecting backup schedules. Include detection and decision time. Test restoration in an isolated environment. Reconcile users, permissions, referential relationships and downstream side effects, not only row count.

Backups need independent access controls. If the same compromised identity can delete production and every backup, copies do not create meaningful recovery isolation.

### Multi-instance and distributed transfer

Atlas uses local durable deduplication. With multiple instances, every writer must observe the same idempotency decision or use a partitioning strategy that guarantees one owner. A shared relational database with a unique constraint may work; distributed stores introduce consistency and availability trade-offs.

Timeouts multiply across service chains. Retry policy needs a budget and one responsible layer. Otherwise three retries at each of three layers can amplify one request into many attempts.

### Operational readiness review

Ask:

- Who owns user operations at 03:00?
- Which pages require human action?
- Can the team identify the running artifact?
- Can a bad instance leave traffic without restart loops?
- Is rollback schema-compatible?
- Has restore been exercised by someone other than the author?
- What happens if telemetry is unavailable?
- Which secret can read or delete backups?
- What capacity reserve exists during one failure domain loss?
- Which manual step is unaudited toil?
- What does success cost per useful operation?
- Which evidence is still local, synthetic or unreviewed?

The honest last question prevents a polished local demo from becoming a false production claim.

## Reliability, security, observability, capacity, and cost

These are not separate review checklists. One design decision often changes all five.

### Reliability

Define two user operations: read items and create item. For each, define eligible events, good events, latency threshold and correctness invariant. Do not combine them blindly: reads can remain healthy while writes fail.

Example availability:

```text
eligible creates = 100,000
good creates     = 99,300
availability     = 99,300 / 100,000 = 99.3%
99% objective budget = 1,000 bad
observed bad          = 700
budget consumed       = 70%
```

An average latency hides the tail. If four requests take 50 ms and one takes 2 seconds, average is 440 ms while most users were fast and one was extremely slow. Use a distribution and a percentile aligned with user tolerance.

Error-budget alerts should be actionable. A fast burn detects urgent consumption; a slower window detects persistent degradation. Page on symptoms that require immediate human action. Use CPU, memory, locks and queue depth for diagnosis and capacity planning.

### Security

Start with assets: request data, item state, idempotency history, image, configuration, certificate private key, telemetry and backups. Identify actors: client, operator, CI identity, runtime process, monitoring and backup operator.

Controls in the fixture:

- loopback exposure;
- TLS edge;
- strict input shape and size;
- non-root runtime;
- read-only root;
- dropped capabilities and no-new-privileges;
- explicit writable state;
- private metrics route;
- pinned base identities;
- guarded path and cleanup refusal;
- no embedded credential.

Limits:

- self-signed local trust;
- no end-user authentication or authorization model;
- no production secret manager;
- no image signing or verified provenance gate;
- no kernel-policy proof;
- no vulnerability guarantee;
- no encrypted remote backup;
- no multi-tenant isolation.

Threat example: an attacker submits many unique idempotency keys. Even valid requests can grow durable state. Add authentication, per-principal quotas, rate limiting, retention policy and capacity alerts. Never expire keys before the business retry window without understanding duplicate risk.

### Observability

Instrument the user path:

- request count by bounded method, route and status;
- duration histogram in seconds;
- storage error counter by bounded operation class;
- readiness state;
- build/version information;
- structured event with request and trace correlation;
- Prometheus target health and rule evaluation.

Logs should avoid secrets, raw authentication headers and unnecessarily complete bodies. Traces should cross the proxy/application boundary. Metrics should avoid IDs. Dashboards should follow the user journey from external result to edge, application, transaction and monitoring health.

Always monitor the monitor. If scrape, rule evaluation or notification is broken, declare the blind spot and use an independent probe.

### Capacity and performance

Build a demand model:

```text
arrival rate      = operations per second
service time      = seconds of constrained work
concurrency need  ~= arrival rate * service time
utilization       = demand / service capacity
```

This is a starting model, not a guarantee. SQLite has a serialized write boundary. Longer transactions increase queueing even when total CPU is low. Measure read/write mix, payload sizes, latency distribution, concurrent writers, database growth, WAL/checkpoint behavior and backup interference.

Capacity tests need warm-up, steady interval, representative data and explicit saturation signals. A laptop result cannot size production. State hardware, runtime, sample, error rate and confidence.

### Cost

Track:

- compute and reserved headroom;
- memory;
- primary state and journal growth;
- backup frequency, retention and restore environment;
- metric series, scrape interval and retention;
- logs and traces by volume and cardinality;
- image/artifact storage;
- network transfer;
- engineering/on-call toil.

Optimizing cost without the user denominator misleads. Useful measures include cost per successful operation, per retained recovery point or per team served. Reducing telemetry retention may save storage but increase incident duration. Increasing backup isolation costs money but can determine whether ransomware recovery exists.

### Trade-off worksheet

| Decision | Reliability | Security | Observability | Capacity | Cost |
|---|---|---|---|---|---|
| shorter proxy timeout | faster failure, more ambiguity | limits held resources | more timeout evidence needed | can shed slow work | may reduce resource time |
| more retries | masks transient error | can amplify abuse | complicates attempt/user metrics | increases load | increases compute |
| longer idempotency retention | safer delayed retry | stores more client-linked state | aids reconciliation | grows database | increases storage |
| more histogram labels | better segmentation | disclosure risk | cardinality explosion risk | monitoring load | telemetry cost |
| remote immutable backups | stronger recovery | separation needed | recovery evidence | transfer/storage load | higher direct cost |

There is no globally best setting. There is a defensible setting connected to user objectives, threats, failure modes and budget.

## Traps and prevention

### “The container is healthy”

Trap: a health status becomes proof of service correctness.

Prevention: name the probe contract. Require liveness, readiness, representative user operations, time-window SLIs and monitoring health as separate gates.

### “Disk has space”

Trap: `df -h` on the wrong path ends storage diagnosis.

Prevention: inspect blocks and inodes on the exact state path, then quota, identity, traversal, mode, mount, locks, integrity and latency. Reclaim only objects with known ownership and retention.

### “Retry fixed it”

Trap: a write timeout is replayed under a new identity.

Prevention: require stable idempotency identity, atomic deduplication and outcome reconciliation. Bound retry count, deadline and load.

### “Restart fixed the root cause”

Trap: clearing process state becomes a causal explanation.

Prevention: preserve evidence before restart, record the predicted mechanism, compare after restart and create a reproduction/regression test.

### “The backup succeeded”

Trap: snapshot creation becomes recovery proof.

Prevention: manifest, hash, separate restore, database integrity, schema validation, counts, business reads, access separation and scheduled reviewer-owned exercises.

### “Restore is rollback”

Trap: unhealthy code triggers data rewind.

Prevention: maintain separate artifact rollback and data recovery plans. Test schema direction. Require explicit accepted data-loss boundary and cutover owner for restore.

### “A digest is secure”

Trap: immutability becomes provenance or vulnerability proof.

Prevention: pin identity, then review source, build provenance, SBOM, signatures/attestations, vulnerability findings, licenses and policy exceptions.

### “The pipeline is green”

Trap: declared checks are treated as exhaustive and the running artifact is assumed to match.

Prevention: assert discovered test count and record conservation, reconcile digest at runtime, exercise admission probes, deploy progressively and observe.

### “No alert means no incident”

Trap: monitoring blindness becomes negative evidence.

Prevention: monitor scrape, rule and notification health; use independent user probes; represent telemetry gaps on the incident timeline.

### “CPU is above 70 percent”

Trap: a cause signal pages without a user symptom or action.

Prevention: page on SLO/correctness symptoms. Use CPU with run queue, throttling, profiles and capacity reserve for diagnosis.

### “More labels help debugging”

Trap: request, user or item identity enters metrics.

Prevention: bound metric dimensions during design. Keep unique identity in logs/traces and link through exemplars or correlation where supported.

### “Canary passed”

Trap: tiny, biased or unobservable traffic is treated as fleet evidence.

Prevention: predeclare sample, workload comparability, duration, success and abort thresholds. State confidence limits and extend observation when evidence is inconclusive.

### “Read-only container means safe”

Trap: one hardening control becomes complete security.

Prevention: inspect writable mounts, effective identity, capabilities, network access, secrets, syscall/kernel controls, application authorization and data integrity.

### “Cleanup is just rm”

Trap: broad recursive deletion follows unresolved paths.

Prevention: derive exact resource identities at creation, refuse root/symlink/wrong-owner/unknown state, delete only allowlisted artifacts, then prove absence.

### Prevention hierarchy

Prefer controls in this order:

1. remove the unsafe design;
2. make unsafe state unrepresentable;
3. enforce a boundary automatically;
4. detect violation quickly;
5. provide a reversible runbook;
6. train and review;
7. rely on memory last.

For example, telling operators “do not restore in place” is weak. A restore tool that refuses an existing active target and enforces a boundary is stronger. A separate recovery account and isolated environment are stronger again.

### Review after success

Success can hide luck. After a clean release, ask what would have happened if:

- the schema changed midway;
- traffic were ten times higher;
- Prometheus were unavailable;
- the backup identity lacked access;
- the client timed out after commit;
- one availability zone failed;
- the rollback artifact were vulnerable;
- the responder did not author the service.

Convert material answers into tests, alerts, policies, runbooks or game-day scenarios.

## Memory card and retrieval

### The one-minute memory card

```text
START WITH
  user operation + correctness risk + time window

TRACE
  client -> TLS/proxy -> app -> transaction -> exact state path

SEPARATE
  live | ready | correct | SLI | business outcome
  restart | rollback | failover | restore
  artifact identity | artifact trust
  backup created | recovery proven

PRESERVE
  request/trace + release tuple + state/journal + monitoring health

DECIDE
  smallest bounded reversible action
  success + abort + rollback + owner

VALIDATE
  version + read + create/replay/conflict + SLI + monitor + observe

LEARN
  mechanism + conditions + detection + owned prevention
```

### Retrieval questions

Answer aloud without looking back. Draw the path for questions 1, 8 and 15.

1. Why can liveness succeed while the service remains unusable?
2. What is the difference among source, configuration, schema and artifact identity?
3. Why is a mutable image tag insufficient for rollback?
4. A create request times out. Why is a new idempotency key dangerous?
5. Which state must commit atomically for Atlas idempotency?
6. What does `df -hT` prove, and what must `df -i` add?
7. Name four non-capacity reasons a database write can fail despite free blocks and inodes.
8. How can the client receive 504 while the database contains a committed item?
9. Why should liveness not usually depend on every downstream dependency?
10. What is the difference between an SLI, SLO and SLA?
11. Calculate allowed bad events for 99.9 percent over two million eligible events.
12. If the allowed bad fraction is 0.1 percent and observed bad is 2 percent, what is burn rate?
13. Why should request IDs not be Prometheus labels?
14. What does `up == 0` change about the meaning of absent alerts?
15. Draw the safe backup-to-cutover path.
16. Why is an online backup better than blindly copying an active SQLite main file?
17. When is rollback safer than restore?
18. Name five controls beyond running a container as non-root.
19. What must a canary prove before promotion, and what can it never guarantee?
20. What belongs in a five-minute incident update?

### Applied retrieval

For each scenario, write fact, hypothesis, safe test, recovery lever and proof limit:

- liveness 200, readiness 503 after a config-only release;
- free blocks, zero inodes on the exact state filesystem;
- edge 504, app 201 and same trace ID;
- p95 healthy but two duplicate items appear;
- service alerts absent while scrape target is down;
- backup hash matches but restored business count is lower;
- rollback image exists but cannot read the new schema;
- canary has no errors across only three requests.

### Delayed retrieval

Repeat after 24 hours and seven days with no manuscript access. A reviewer should change at least two conditions: deadline, fault layer, schema compatibility, monitoring availability or backup age. Immediate repetition measures rehearsal; delayed changed-context reasoning provides stronger evidence of transfer.

### Teach-back test

Explain to a first-year engineer:

- why free gigabytes do not close an ENOSPC investigation;
- why timeout does not equal rollback;
- why backup is not recovery;
- why a green pipeline is not a healthy release;
- why local proof must not be described as production experience.

If your explanation requires unexplained words, return to the terms section and rebuild it.

## Complete answers

### 1. Why liveness can succeed while service is unusable

Liveness asks whether the process can answer a narrow internal path and make progress. Readiness adds required serving dependencies. User correctness adds operation semantics. A process can accept HTTP while its database is locked, schema is incompatible or writes are deliberately disabled. Use liveness for restart decisions, readiness for traffic admission and user probes/SLIs for service health.

### 2. Four release identities

Source identity names reviewed code, usually a Git commit. Configuration identity names runtime behavior inputs. Schema identity names durable-state structure/migration. Artifact identity names built bytes, such as an OCI digest. A defensible release binds all four because the same source can produce different artifacts, the same artifact can run under different configuration, and either can be incompatible with state.

### 3. Mutable tag and rollback

A tag is a reference that can point to different content later. “Roll back to v1” is unsafe if v1 was overwritten or resolved differently across nodes. Record the digest and verify runtime identity. The digest still does not prove the artifact is secure or schema-compatible.

### 4. Timeout and new idempotency key

The original transaction may have committed after the client deadline. A new key declares a new operation and can create another item. Reuse the original key so durable deduplication returns the earlier outcome or safely completes the same intent. If the service lacks reconciliation, stop blind retry and investigate state.

### 5. Atomic idempotency state

The business item and the mapping from key to request fingerprint and outcome must commit together. Otherwise an item can exist without deduplication, or a key can claim a nonexistent result. Uniqueness handles races; the transaction preserves all-or-none visibility.

### 6. Blocks and inodes

`df -hT EXACT_PATH` maps the path to its filesystem and reports block capacity plus type. It cannot report inode availability, so `df -i EXACT_PATH` adds object-slot capacity. Both are point-in-time filesystem summaries; they do not prove quota, identity, mount, database or device-latency health.

### 7. Write failure with free blocks and inodes

Examples include wrong effective ownership/mode, missing execute permission on a parent directory, read-only mount, database lock/contention, filesystem or database integrity error, exhausted project/user quota, file-descriptor exhaustion, security-policy denial, I/O error and latency beyond deadline. Use exact-path and owner-specific evidence instead of deleting files.

### 8. Edge 504 and committed item

The edge deadline can expire while the application is still processing. NGINX sends 504 to the client; later the transaction commits and the app records 201 that no client receives. Correlate the same request across hops and reconcile with the idempotency key. Align deadlines and repair the slow stage.

### 9. Narrow liveness

If every process fails liveness when one shared dependency fails, the orchestrator restarts the whole fleet. That destroys evidence, adds startup load and cannot repair the dependency. Liveness should represent process deadlock or inability to progress; readiness removes an unusable instance from traffic while keeping it diagnosable.

### 10. SLI, SLO and SLA

An SLI is measured behavior with an explicit population, such as good eligible creates divided by eligible creates. An SLO is the desired range over a window, such as at least 99.9 percent over 30 days. An SLA is a business/legal promise and consequence. Internal targets are not automatically agreements.

### 11. Allowed events at 99.9 percent

The bad fraction is `1 - 0.999 = 0.001`, or 0.1 percent. For 2,000,000 eligible events:

```text
2,000,000 * 0.001 = 2,000 allowed bad events
```

This arithmetic is valid only after defining eligible and good events. Rounding and low-volume windows need explicit policy.

### 12. Burn rate

Convert both percentages to the same unit:

```text
burn rate = 2% / 0.1% = 20
```

The current window consumes budget twenty times faster than evenly sustainable. Action still depends on window length, remaining budget, correctness and alert policy.

### 13. Unique values and metrics

Every distinct label combination creates a time series. Request IDs can grow without practical bound, consuming memory, storage and query resources. Put them in structured logs or traces. Use bounded metric dimensions such as route template, method and status, then correlate using time or exemplars where available.

### 14. Meaning of `up == 0`

The monitoring system cannot scrape the target. Service alert silence becomes inconclusive because the observer is blind. Use independent user probes and component evidence, repair or fail over monitoring, and include the blind interval in incident communication.

### 15. Safe backup-to-cutover path

Active database uses the supported online backup method to produce an immutable snapshot. Record manifest, time, source, size, hash and counts. Verify it, restore to a new path, run database integrity/schema checks, reconcile counts and representative business reads, calculate data-loss boundary, obtain authorized cutover, stop or coordinate writers, switch traffic and observe. Preserve the original until recovery is accepted.

### 16. Why online SQLite backup

An active database can have locks and journal/WAL state not represented by a naive main-file copy at one instant. SQLite’s backup interface coordinates a consistent snapshot while the source can remain active. Completion still requires manifest, restore and semantic verification.

### 17. Rollback versus restore

Rollback is safer when the candidate executable/configuration caused failure, current data is valid and the previous artifact can read/write the active schema. It preserves recent data. Restore is for damaged or lost state and may intentionally discard writes after its recovery point. Never use data rewind as the default response to a bad binary.

### 18. Controls beyond non-root

Examples: read-only root filesystem; only necessary writable mounts; dropped capabilities; no-new-privileges; syscall/kernel policy; resource limits; loopback/private network exposure; authenticated/authorized APIs; secret manager; signed/provenanced image policy; input validation; backup isolation; audit logs; patch/vulnerability process. Non-root is one blast-radius reduction.

### 19. Canary evidence and limits

A canary should prove intended artifact/config/schema identity, health, user correctness, telemetry visibility and acceptable SLI/budget behavior under a predeclared comparable slice. It should preserve rollback and recovery. It cannot guarantee fleet capacity, rare-failure absence, future behavior or safety under untested state. If sample confidence is weak, extend the bounded stage.

### 20. Five-minute update

State incident ID, affected user operation, start time, scope, correctness/data risk, current release identity, roles, change freeze, first preserved evidence, mitigation underway, explicit unknowns and next update time. Avoid a premature root-cause story.

Example:

> Create-item latency and errors began at 10:04 UTC after the candidate release; reads remain healthy. We have paused promotion and removed the candidate from new traffic. One timeout may have committed, so retries must preserve idempotency identity. Two correlated requests and current state are preserved. Cause remains unconfirmed. We are testing release/schema compatibility for rollback; next update at 10:20.

### Applied scenario answer pattern

For “backup hash matches but restored business count is lower,” the matching hash proves the restored bytes match the recorded snapshot. It does not prove the snapshot contains current or complete business state. Hypotheses include a snapshot before recent writes, wrong source database, missing logical data outside SQLite or flawed count definition. Preserve both states, compare manifest time/source, schema and operation ledger, and do not cut over until the authorized loss boundary and reconciliation pass.

For “canary has no errors across three requests,” the fact is three successes. The hypothesis “candidate is reliable” is unsupported because the sample is too small. Continue bounded synthetic/real comparable traffic, extend time and state the detectable failure limit. Absence of observed error is not evidence of zero error.

## Product-company interview

Use this structure: clarify user operation and scale; draw boundaries and state; name invariants; identify failure and recovery; define evidence; discuss security/capacity/cost; state limits.

### 1. Design a reliable create API

**Evaluates:** API semantics, state and failure reasoning.

**Strong answer:** Require authenticated intent, strict validation and stable idempotency identity. Atomically store request fingerprint and business outcome under a unique constraint. Return the existing outcome for exact replay and conflict for changed intent. Set coherent deadlines, bound retries, instrument user outcomes and test timeout-after-commit. Define retention from business retry windows and capacity.

**Weak warning:** “Use POST and retry three times.” This ignores ambiguous commit and duplication.

**Follow-up:** How does the design change across regions? Discuss one consistency owner, routing/partitioning, replication lag, conflict policy and availability trade-off.

### 2. Liveness is green but customers fail. What next?

**Evaluates:** health hierarchy and debugging.

**Strong answer:** Name the failed operation, compare readiness and user probe, trace one request across edge/app/state, preserve release identity and quantify SLI. Liveness only rules out a narrow process failure. Remove not-ready instances and avoid restarting the fleet before evidence.

**Follow-up:** When should liveness fail? When the process is deadlocked or cannot make local progress and restart is a useful bounded recovery.

### 3. Explain a 504 with a committed write

**Evaluates:** timeout semantics.

**Strong answer:** The proxy deadline can end before the server transaction. Correlate one trace, reconcile state with the same idempotency key, prevent blind retry and align hop deadlines. Mitigate the slow stage or remove the candidate.

**Weak warning:** “504 means backend never processed it.”

### 4. How do you release a stateful service?

**Evaluates:** delivery and schema design.

**Strong answer:** Bind source/config/schema/artifact; test migration and old/new compatibility; prefer expand-migrate-verify-contract; create recovery evidence; deploy a bounded candidate; validate readiness and correctness; compare SLI; predeclare abort; roll back only while schema-compatible; observe.

**Follow-up:** What if rollback cannot read the schema? Stop promotion, use forward repair or a tested compatibility bridge; do not assume data restore is safe.

### 5. Design the SLO

**Evaluates:** reliability mathematics.

**Strong answer:** Separate read and create operations. Define eligible requests, good status/correctness, latency threshold, source of truth and window. Calculate budget, select multi-window burn alerts and exclude invalid client traffic only by written policy. Monitor correctness separately where status cannot express it.

**Follow-up:** Why not CPU SLO? CPU is a resource signal, not a user outcome.

### 6. A database host has free disk. Can storage be ruled out?

**Evaluates:** Linux/storage depth.

**Strong answer:** No. Map the exact path; inspect blocks, inodes, quota, effective identity, traversal, mounts, locks, journal, integrity, descriptors and I/O latency. Container layers and volumes may differ from the host path. Each signal has a proof limit.

**Weak warning:** “Delete logs and restart.”

### 7. Design backup and recovery

**Evaluates:** data protection.

**Strong answer:** Begin with business RPO/RTO and dependency map. Use database-consistent snapshots, immutable/isolated copies, encryption, least privilege, retention and manifest identity. Restore regularly to an isolated target; verify integrity, schema, counts and business reads; rehearse cutover/failback and measure the full recovery timeline.

**Follow-up:** Why is a successful backup job insufficient? It does not prove access, reconstructability, correctness or accepted loss.

### 8. Secure this container

**Evaluates:** layered security.

**Strong answer:** Minimal reviewed base pinned by digest, update process, non-root UID, read-only root, explicit volumes/tmpfs, dropped capabilities, no-new-privileges, resource limits, private networks, secret injection, authentication/authorization, input limits, provenance/SBOM/scans, policy enforcement, audit and backup isolation. State what the local fixture lacks.

**Follow-up:** Does pinning a digest improve security? It prevents silent movement and aids rollback; it can also freeze vulnerabilities, so reviewed updates remain necessary.

### 9. Monitoring shows nothing during an outage

**Evaluates:** observability reliability.

**Strong answer:** Treat monitoring blindness as a parallel incident. Use independent external probes and direct bounded evidence. Check discovery, network, authentication, scrape and rule evaluation. Restore telemetry without delaying user mitigation, record the blind interval and add metamonitoring plus tested notification.

### 10. Design canary promotion

**Evaluates:** experimental reasoning.

**Strong answer:** Predeclare eligible traffic, candidate/baseline comparability, sample/duration, correctness gates, SLI thresholds, fast/slow burn, security checks, monitoring-health requirement, owner and rollback. Start small, preserve immutable identity and widen only while gates pass.

**Follow-up:** What if traffic is low? Use bounded synthetic user operations, extend duration and report confidence limits.

### 11. How do you prevent retry storms?

**Evaluates:** distributed resilience.

**Strong answer:** End-to-end deadline, retry at one responsible layer, idempotency, small attempt budget, exponential backoff with jitter, retryable-status policy, load shedding, circuit breaking and observability that separates user operations from attempts. Test dependency recovery to avoid synchronized reconnect.

### 12. Capacity-plan Atlas

**Evaluates:** performance and state modeling.

**Strong answer:** Forecast read/write arrival, service-time distributions, concurrent writers, database/journal growth, backup overhead and failure reserve. Load representative data with warm-up and steady intervals. Watch latency, error, lock wait, queue and resource saturation. Identify the serialized write boundary and scaling threshold; never extrapolate a laptop benchmark without assumptions.

### 13. Lead the first thirty minutes

**Evaluates:** incident leadership.

**Strong answer:** Assign command/operations/comms/scribe, scope user impact and correctness, freeze change, preserve evidence, establish update rhythm, test explicit hypotheses with reversible actions, communicate facts and unknowns, validate mitigation with user SLIs and protect responders from parallel uncoordinated change.

**Weak warning:** personally run every command while communication and decision ownership remain unclear.

### 14. Write the postmortem

**Evaluates:** systems learning.

**Strong answer:** Use a UTC timeline, impact, detection, response, recovery and evidence-backed mechanism. Include contributing technical and organizational conditions, what worked, counterfactual limits and prioritized actions with owners, dates and verification. Avoid blame and “human error” as an endpoint.

### 15. Build versus buy the database

**Evaluates:** architecture trade-offs.

**Strong answer:** Compare workload, consistency, scale, latency, availability, recovery, compliance, expertise, lock-in and total operational cost. Embedded SQLite minimizes moving parts for a single-node local fixture. A managed relational service can provide replication and automation but does not remove schema, query, capacity, backup verification, identity or incident ownership.

### 16. Defend this capstone on a résumé

**Evaluates:** technical honesty and communication.

**Strong answer:** “Built and verified a local production-shaped Python/SQLite service with idempotent writes, non-root read-only container, local TLS proxy, Prometheus SLO rules, deterministic faults and separate restore. The seven-test and integrated verifier passed on Ubuntu/ Docker Desktop. It did not operate production traffic, multi-node HA or organizational change controls.” Then explain one defect found and control added.

**Weak warning:** “Operated a production-grade highly available platform.” The fixture does not support that claim.

### Interview synthesis exercise

In five minutes, draw Atlas and answer:

1. What happens after timeout?
2. Which state is durable?
3. How do you know what runs?
4. How does the instance leave traffic?
5. How do you recover code versus data?
6. Which user SLI controls promotion?
7. How can monitoring lie?
8. What breaks at ten times scale?
9. Which trust boundary is weakest?
10. What evidence would make your claim stronger?

A staff-level answer connects technical mechanisms to decision systems: compatibility policy, rollout standards, recovery governance, observability conventions and learning loops. It still begins with one real request.

## Independent transfer and rubric

The independent capstone is `ASM-0249`. It intentionally contains no model answer. A reviewer selects a changed service behavior and one hidden fault after the learner begins. The learner works from a fresh clone and may use official documentation, but not this answer section or a disclosed fault key.

### Reviewer setup

Choose one behavior change:

- new required field with backward-compatible schema;
- changed edge deadline;
- different idempotency retention rule;
- separate read and write SLO;
- authentication stub with a denied path;
- different state location or runtime UID.

Choose at least one hidden fault:

- proxy deadline shorter than transaction latency;
- readiness reports the wrong dependency;
- database path has inode, permission or read-only failure;
- old artifact cannot read the new schema;
- metrics use an unbounded label;
- Prometheus cannot scrape;
- backup manifest points to the wrong source;
- load tool exits successfully without conserving records.

The reviewer must preserve the answer key, safety boundary and recovery path. The exercise must never target a production endpoint or real credential.

### Learner mission

From a fresh clone:

1. establish source, config, schema, dependency and image identities;
2. run and explain tests, verifier and policy gates;
3. produce a least-privilege candidate;
4. validate health and read/create/replay/conflict;
5. calculate SLI and budget from recorded events;
6. identify the hidden fault through evidence;
7. give 5-, 15- and 30-minute updates;
8. choose a reversible mitigation and recovery;
9. create and independently verify backup/restore;
10. validate recovery and monitoring;
11. write postmortem and prevention actions;
12. prove exact cleanup.

Every command record needs timestamp, environment and exit status. Every causal claim needs two reinforcing signals or the label “hypothesis.” At least one plausible hypothesis must be rejected with falsifying evidence.

### Automatic failure conditions

The exercise stops without a passing result if the learner:

- uses root or escapes the bounded project;
- exposes a non-loopback port without reviewer authorization;
- reveals or uses a real secret/data set;
- restores over active state;
- retries an ambiguous write under a new operation identity;
- runs unbounded load;
- deletes unknown resources;
- hides evidence or claims production/mastery from local completion;
- continues after losing both rollback and recovery paths.

Stopping safely is better evidence than completing unsafely.

### One-hundred-point rubric

| Area | Points | Passing evidence |
|---|---:|---|
| Reproducibility and identity | 10 | fresh clone, exact tuple, same validated candidate |
| Architecture and state | 10 | accurate request/state/telemetry/trust map |
| Release engineering | 10 | bounded stages, declared gates, abort and rollback |
| Reliability mathematics | 10 | correct eligibility, SLI, budget and burn |
| Incident investigation | 10 | scope, preservation, hypotheses and falsification |
| State safety and recovery | 10 | same-key reconciliation and separate verified restore |
| Security and supply chain | 10 | least privilege, secret hygiene, pinned/reviewed inputs |
| Observability | 10 | correlated signals, bounded labels, monitor health |
| Communication and leadership | 10 | precise timed updates, ownership and uncertainty |
| Learning and prevention | 10 | mechanism-based postmortem and verified actions |

The assessment schema records the same rubric. A suggested threshold does not award mastery. The reviewer must record evidence anchors and critical safety failures. Repeat an unfamiliar variant after delay.

### Portfolio evidence

Permitted claim:

> Implemented and independently exercised a local service reliability capstone covering immutable release identity, idempotent writes, container hardening, TLS proxy, Prometheus SLOs, deterministic incidents and verified separate restore. Evidence includes test/verifier output, architecture, runbook, recovery receipt and reviewer rubric.

Add exact environment, result and limitations. Never claim production scale, on-call ownership, cloud experience or organizational impact unless separately true and permitted.

### Completion boundary

Reading is exposure. Guided execution is reproduction. Independent hidden-fault work is stronger transfer evidence. Representative authorized operations and repeated outcomes are stronger again. This book publishes the system; it does not award a person mastery.

## References and review

The reference records beside this lesson preserve version/date, relevance, topic tags and review dates. Use primary and official sources; the chapter paraphrases rather than substituting for their exact contracts.

1. **REF-1100 — Docker, Building best practices.** Multi-stage construction, base-image choice, cache and image hygiene.
2. **REF-1101 — Docker, Control startup and shutdown order in Compose.** Dependency conditions and readiness-aware startup limits.
3. **REF-1102 — GitHub, Continuous integration with GitHub Actions.** Workflow and CI concepts used by the quarantined template.
4. **REF-1103 — Python, `http.server`.** Exact module behavior and the explicit warning that it is not recommended for production.
5. **REF-1104 — Python, `sqlite3`.** Transactions, backup API exposure and database interface behavior.
6. **REF-1105 — SQLite Backup API.** Consistent online snapshot behavior.
7. **REF-1106 — SQLite, How To Corrupt An SQLite Database File.** Journal, locking and unsafe file-handling mechanisms.
8. **REF-1107 — NGINX, `ngx_http_proxy_module`.** Forwarded headers, upstream proxying and timeout ownership.
9. **REF-1108 — RFC 8446, TLS 1.3.** Transport confidentiality, integrity and authentication protocol.
10. **REF-1109 — OpenTelemetry Signals.** Distinct roles of traces, metrics, logs and profiles.
11. **REF-1110 — OpenTelemetry Metrics.** Instruments, aggregation, temporality and cardinality.
12. **REF-1111 — Prometheus Instrumentation.** Online-service metric and label design.
13. **REF-1112 — Prometheus Metric and label naming.** Units, names and dimensional conventions.
14. **REF-1113 — Prometheus Alerting.** Actionable symptom alerting and metamonitoring.
15. **REF-1114 — Google SRE, Service Level Objectives.** User-oriented indicators, objectives and error budgets.
16. **REF-1115 — Google SRE Workbook, Alerting on SLOs.** Multi-window burn-rate detection trade-offs.
17. **REF-1116 — Google SRE, Postmortem Culture.** Blameless learning and owned corrective actions.
18. **REF-1117 — NIST Secure Software Development Framework publications.** Secure development, protection, verification and vulnerability response.
19. **REF-1118 — DORA, Continuous delivery.** Keeping software releasable through automation and fast feedback.
20. **REF-1119 — RFC 9110, HTTP Semantics.** Methods, status, representations and idempotency reasoning.

### What was directly verified

- Ubuntu 24.04 WSL, Python 3.12.3, normal-user execution;
- Bash syntax and ShellCheck;
- Python compilation and seven unit tests;
- integrated verifier with 40 healthy and 20 latency records;
- four listener modes, API, idempotency, trace and metric contracts;
- online backup, manifest, verification and separate restore;
- two SLO calculations and three fault behaviors;
- Docker 29.6.2 Dockerfile static checks and pinned build;
- container UID/GID 10001, read-only root and healthy loopback API;
- full NGINX TLS edge and Prometheus topology;
- external metrics rejection and internal `up == 1`;
- Prometheus configuration and six rule validations;
- exact container, volume, network, certificate and temporary-state cleanup.

### What remains unverified

- Internet-facing security and trusted PKI;
- representative production traffic and capacity;
- multi-instance database coordination and high availability;
- production RPO/RTO and business cutover authority;
- real alert-notification delivery;
- organization-specific CI/CD permissions, approval and audit;
- vulnerability, license, SBOM, signing and provenance acceptance;
- learner reproduction, delayed recall and unfamiliar independent game day;
- formal technical, security, accessibility, instructional and assessment review.

### Manuscript review checklist

Technical reviewer:

- validate HTTP/idempotency semantics;
- inspect transaction atomicity and timeout wording;
- reproduce backup/restore and fault evidence;
- confirm container, proxy and Prometheus claims against pinned versions;
- check calculations and eligibility definitions.

Security reviewer:

- threat-model assets, actors and trust boundaries;
- check secret/log/certificate treatment;
- verify least privilege and network exposure;
- review supply-chain and recovery access limits.

Instructional reviewer:

- ensure every term precedes first consequential use;
- execute every lab command from a fresh clone;
- verify expected branches and cleanup;
- confirm questions have complete explanations;
- keep independent answers isolated.

Accessibility reviewer:

- verify diagrams have equivalent text;
- check heading order, tables and code-block readability;
- test keyboard and screen-reader behavior after publication.

### Final lesson summary

Reliable service operation is one connected discipline:

```text
immutable change
  + explicit state ownership
  + user-visible objectives
  + correlated evidence
  + reversible release
  + verified recovery
  + truthful communication
  + learned prevention
```

When the system says “no space,” “timeout,” “healthy,” “green” or “backup complete,” never stop at the word. Ask which boundary emitted it, what state it observed, what it proves, what it cannot prove and which safe evidence comes next.

The next capstone should deepen a different failure and ownership model. This candidate remains quarantined until formal review and independent learner evidence; publication itself awards no mastery.
