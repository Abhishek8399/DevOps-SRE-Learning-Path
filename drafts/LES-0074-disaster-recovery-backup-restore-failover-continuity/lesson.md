---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0074",
  "slug": "disaster-recovery-backup-restore-failover-continuity",
  "aliases": ["V04-L12", "disaster-recovery-backup-restore-failover-continuity"],
  "curriculumIds": ["DR-001"],
  "route": "/book/reliability/disaster-recovery-backup-restore-failover-continuity",
  "order": 12,
  "volume": "04-reliability-operations",
  "title": "Disaster recovery engineering: prove restore, RPO, RTO, failover, and continuity",
  "summary": "Turn business impact and critical flows into tested recovery objectives, independent backup chains, isolated restore validation, safe failover and controlled failback with honest evidence.",
  "domain": "reliability",
  "level": {"from": "intermediate", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0032", "LES-0050", "LES-0058"],
  "prerequisiteCurriculumIds": ["SRE-002", "CLD-001", "DST-005"],
  "testedEnvironments": [
    {"platform": "Government, standards and official product documentation", "version": "NIST, CISA, AWS, Microsoft, Google Cloud, PostgreSQL, Kubernetes and etcd sources reviewed 2026-08-07", "support": "concept-only", "notes": "Sources define objectives, mechanisms and controls; they do not prove a specific workload can recover."},
    {"platform": "Ubuntu", "version": "24.04 normal-user offline model", "support": "required", "notes": "Guarded deterministic 45-case decision model; it performs no backup, restore, failover, route, service or host mutation."},
    {"platform": "Python", "version": "3 standard library", "support": "required", "notes": "Local JSON evaluation only; no database, cloud, Kubernetes, container, socket or external process."},
    {"platform": "Representative production recovery environment", "version": "not available", "support": "unsupported", "notes": "No real recovery point, restore, measured RPO/RTO, failover, failback, continuity or production claim."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "cloud-engineer", "database-reliability-engineer", "kubernetes-engineer", "security-engineer", "infrastructure-engineer", "technical-lead"],
  "learningObjectives": [
    "Distinguish business continuity, high availability, resilience, replication, backup, restore, failover, failback and disaster recovery.",
    "Derive flow-level RTO, RPO, correctness and degraded-mode requirements from business impact rather than product defaults.",
    "Inventory authoritative, derived, ephemeral and external state plus every identity, key, configuration, route and dependency needed for recovery.",
    "Select redundancy, replication, logical backup, physical backup, snapshot, PITR and rebuild mechanisms by failure coverage and objective.",
    "Bind full, incremental and log or WAL recovery objects into authenticated complete chains with retention and version compatibility.",
    "Protect recovery assets with independent failure domains, least privilege, encryption, tested key access, immutability or offline copies.",
    "Restore into isolation and validate bytes, engine consistency, business invariants, authorization, prohibited behavior and complete user journeys.",
    "Measure actual RPO from newest validated business state and actual RTO across detection, decision, restore, validation and routing.",
    "Keep recovery capacity, quota, artifacts, identity, certificates, runbooks, communication and observability available and drift-controlled.",
    "Activate and execute failover with named authority, abort criteria, stale-writer fencing, staged routing and evidence-led communication.",
    "Treat failback as a separate reconciliation and migration with authoritative-state decision, validation, fencing and rollback.",
    "Run bounded scenario drills, preserve evidence and uncertainty, own gaps, verify remediation and review security, capacity and cost."
  ],
  "productionSignals": [
    "critical flow owner business impact tier disaster threshold maximum tolerable disruption and degraded operation",
    "RTO RPO correctness target approval version review date and exception",
    "state owner authority class source of truth schema version size change rate and reconciliation method",
    "dependency identity failure domain recovery order alternate path and third-party continuity contract",
    "backup job source scope start completion status bytes object count and producer version",
    "backup set manifest full incremental log ancestry timestamp checksum retention location and immutability",
    "replication source destination mode lag replay position error and logical-corruption exposure",
    "encryption key certificate break-glass principal policy location expiry access test and audit",
    "restore exercise ID scenario target isolation software versions start stages completion and cleanup",
    "database recovery timeline consistency check application invariant reconciliation and security result",
    "newest validated recoverable business event disaster boundary actual data loss and measured RPO",
    "declaration detection decision capacity data application validation routing and complete-flow recovery timestamps",
    "recovery environment desired and effective config image artifact quota capacity route DNS certificate and drift",
    "incident commander recovery lead data owner security approver communicator and stop authority",
    "writer generation fencing result traffic percentage errors latency backlog correctness and security guardrails",
    "failback authority divergence reverse sync conflict reconciliation cutover rollback soak and residual risk"
  ],
  "diagrams": [
    {"id":"LES-0074-DIA-001","title":"Business promise to recovery proof","direction":"left-to-right","boundaries":["business impact","critical flow","RTO RPO correctness","recovery design","isolated exercise","user-flow proof"],"evidencePoints":["owner","operation","targets","mechanisms","timeline","accepted outcome"],"textAlternative":"A recovery claim begins with business impact and ends only after the named flow is correctly restored and measured."},
    {"id":"LES-0074-DIA-002","title":"Availability, replication and recovery layers","direction":"top-to-bottom","boundaries":["high availability","replication","historical recovery points","rebuild assets","disaster recovery","business continuity"],"evidencePoints":["failover","lag","retention","IaC artifacts","RTO RPO","workaround"],"textAlternative":"Redundancy, replicas, backups, rebuild and continuity cover different failure classes and must not be collapsed into one green status."},
    {"id":"LES-0074-DIA-003","title":"Backup chain and trust envelope","direction":"left-to-right","boundaries":["authoritative source","base or full","incremental or WAL","manifest and hashes","protected storage","key and identity","isolated restore"],"evidencePoints":["source ID","ancestry","completeness","immutability","decryption","audit"],"textAlternative":"A usable recovery point binds source, complete ancestry, integrity, retention, access and decryption to an isolated restore."},
    {"id":"LES-0074-DIA-004","title":"End-to-end recovery clock","direction":"left-to-right","boundaries":["disaster begins","detect","declare and authorize","prepare capacity","restore data","start applications","validate flow","route users"],"evidencePoints":["T0","alert","decision","readiness","recoverable point","health","correctness","T recovered"],"textAlternative":"Measured RTO includes detection, decision, infrastructure, data, application, validation and routing until the critical flow is correct."},
    {"id":"LES-0074-DIA-005","title":"Safe failover authority path","direction":"cyclic","boundaries":["declare","fence old writers","verify recovery state","enable new writer","shift traffic","observe","continue or rollback"],"evidencePoints":["approver","generation","integrity","authority","percentage","guardrails","decision"],"textAlternative":"Failover changes write authority only after old writers are fenced and proceeds through observable stages with abort and rollback."},
    {"id":"LES-0074-DIA-006","title":"Failback reconciliation loop","direction":"cyclic","boundaries":["choose authority","measure divergence","rebuild former primary","reverse synchronize","validate","fence current writer","cut over","soak"],"evidencePoints":["source of truth","conflicts","clean target","checkpoint","invariants","generation","routing","residual risk"],"textAlternative":"Failback is a new migration that reconciles state and authority before another fenced and validated cutover."}
  ],
  "commands": [
    {"id":"LES-0074-CMD-001","question":"Is this an approved local offline teaching boundary?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0074 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"normal-user, source and credential guards pass","nextEvidence":"setup"},{"when":"lab=fail","meaning":"a named prerequisite or authority guard failed","nextEvidence":"correct without bypass"}],"proves":"local model prerequisites","doesNotProve":"backup or recovery capability"},
    {"id":"LES-0074-CMD-002","question":"Can the synthetic recovery model initialize with exact ownership?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0074 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped state copy exists","nextEvidence":"status"},{"when":"refusal","meaning":"state identity or ownership is unsafe","nextEvidence":"preserve first error"}],"proves":"bounded local initialization","doesNotProve":"recovery-site readiness","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0074-CMD-003","question":"How many reviewed recovery gates are loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"cases=45","meaning":"expected fixture set is active","nextEvidence":"list and evaluate"},{"when":"another count or refusal","meaning":"fixture or inventory drift exists","nextEvidence":"stop"}],"proves":"local fixture count and state identity","doesNotProve":"gate completeness for a real system"},
    {"id":"LES-0074-CMD-004","question":"What synthetic recovery cases are available?","risk":"read-only","command":"bash lab.sh list","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"45 unique names print","meaning":"reviewer can select a scenario","nextEvidence":"show one case"}],"proves":"local case inventory","doesNotProve":"real failure coverage"},
    {"id":"LES-0074-CMD-005","question":"What exact fields make the baseline defensible in this model?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"candidate evidence is inspectable","nextEvidence":"evaluate baseline"}],"proves":"synthetic input values","doesNotProve":"their truth in any environment"},
    {"id":"LES-0074-CMD-006","question":"Does the baseline cross every encoded gate?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=defensible","meaning":"all encoded predicates pass","nextEvidence":"compare negative cases"}],"proves":"deterministic baseline decision","doesNotProve":"recoverability"},
    {"id":"LES-0074-CMD-007","question":"Why is a healthy replica not automatically a backup?","risk":"read-only","command":"bash lab.sh evaluate replica-called-backup","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=replication-is-not-backup","meaning":"availability and historical recovery are separated","nextEvidence":"independent retained point"}],"proves":"encoded claim separation","doesNotProve":"replica behavior"},
    {"id":"LES-0074-CMD-008","question":"Can an incomplete incremental or WAL chain recover?","risk":"read-only","command":"bash lab.sh evaluate wal-or-incremental-chain-gap","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=backup-chain","meaning":"required ancestry is incomplete","nextEvidence":"restore lineage and retention"}],"proves":"encoded chain gate","doesNotProve":"database engine behavior"},
    {"id":"LES-0074-CMD-009","question":"Are restored bytes enough to call the application recovered?","risk":"read-only","command":"bash lab.sh evaluate application-correctness-unchecked","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=application-correctness","meaning":"business invariants remain unproved","nextEvidence":"flow and reconciliation tests"}],"proves":"encoded correctness boundary","doesNotProve":"specific business invariants"},
    {"id":"LES-0074-CMD-010","question":"Does measured data loss meet the declared RPO?","risk":"read-only","command":"bash lab.sh evaluate measured-data-loss-exceeds-rpo","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=measured-rpo","meaning":"newest validated state is too old","nextEvidence":"improve recovery points or target"}],"proves":"modelled RPO comparison","doesNotProve":"real recoverable timestamp"},
    {"id":"LES-0074-CMD-011","question":"Can failover proceed while an old primary can write?","risk":"read-only","command":"bash lab.sh evaluate old-primary-can-still-write","runFrom":"LES-0074 support/lab after setup","expectedBranches":[{"when":"boundary=single-writer-safety","meaning":"dual-authority risk blocks cutover","nextEvidence":"fencing and negative write proof"}],"proves":"encoded authority gate","doesNotProve":"real fencing"},
    {"id":"LES-0074-CMD-012","question":"Do all cases, refusal and cleanup pass?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0074 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"45 decisions, unknown-artifact refusal and cleanup pass","nextEvidence":"retain model-only limitation"},{"when":"failure","meaning":"candidate evidence is rejected","nextEvidence":"preserve first failure"}],"proves":"offline model lifecycle","doesNotProve":"backup restore failover failback RPO RTO or continuity","cleanup":"Verifier proves exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0074-LAB-001","title":"Guided recovery evidence-gate model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no recovery operation","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic 45-case fixture"],"abortConditions":["root","credential","cloud profile","cluster context","Docker endpoint","public target","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0074-disaster-recovery-backup-restore-failover-continuity/support/lab"},
    {"id":"LES-0074-LAB-002","title":"Independent unfamiliar end-to-end recovery exercise","mode":"independent","environment":"Reviewer-owned disposable local infrastructure with synthetic data","timeMinutes":240,"privilege":"normal user where possible; reviewer owns hidden faults and recovery authority","network":"loopback or isolated local only","changes":["synthetic recovery objects","isolated restore target","five hidden recovery defects","fenced failover and planned failback"],"abortConditions":["production","public target","real credential","customer data","external cloud resource","uncontrolled fault","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore the disposable baseline and prove exact absence.","cleanupProof":"Reviewer proves every process, port, file, volume, route, credential and target absent.","path":"drafts/LES-0074-disaster-recovery-backup-restore-failover-continuity/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0074-INC-001","signal":"Backup jobs are green, but the first restore cannot find a required incremental or WAL object.","firstThought":"Producer success is not chain completeness or recoverability.","safePath":"Freeze retention, bind manifest and ancestry, identify latest complete point and restore in isolation.","trap":"Retry random objects until the engine starts."},
    {"id":"LES-0074-INC-002","signal":"A replica is healthy but contains the same deletion or corruption as primary.","firstThought":"Replication improved availability while propagating the logical fault.","safePath":"Fence bad writers, find an independent pre-corruption point and reconcile later legitimate operations.","trap":"Promote the replica because lag is zero."},
    {"id":"LES-0074-INC-003","signal":"Data restore completes within target, but login, payments or authorization are broken.","firstThought":"Component recovery was confused with critical-flow recovery.","safePath":"Continue the RTO clock, restore dependencies/config/keys, test business and security invariants, then decide cutover.","trap":"Declare recovery when storage reports healthy."},
    {"id":"LES-0074-INC-004","signal":"Both primary and recovery regions accept writes after failover.","firstThought":"Writer authority was moved without fencing the prior generation.","safePath":"Stop traffic, fence stale authority, preserve divergent histories, reconcile and revalidate before one writer resumes.","trap":"Use latest wall-clock timestamp to merge automatically."},
    {"id":"LES-0074-INC-005","signal":"Failover works, but failback overwrites writes accepted during recovery.","firstThought":"Failback was treated as DNS reversal rather than state reconciliation.","safePath":"Choose authoritative state, rebuild, reverse-sync, detect conflicts, validate, fence and cut over with rollback.","trap":"Point traffic back as soon as the old region is reachable."}
  ],
  "assessmentIds": ["ASM-0205", "ASM-0206", "ASM-0207"],
  "referenceIds": ["REF-0868", "REF-0869", "REF-0870", "REF-0871", "REF-0872", "REF-0873", "REF-0874", "REF-0875", "REF-0876", "REF-0877", "REF-0878", "REF-0879", "REF-0880", "REF-0881", "REF-0882"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a decision model, not a backup, replication, restore, database, failover, failback or continuity system.",
    "No host, service, route, DNS record, database, credential, container, Kubernetes cluster, cloud resource or production system is inspected or changed.",
    "Recovery mechanisms and guarantees are product, version, configuration, topology, workload and failure-scenario dependent.",
    "No real recovery point, integrity result, application correctness, measured RPO/RTO, production safety or continuity claim is made.",
    "Formal reliability, data, security and instructional review, representative drills, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Disaster recovery engineering: prove restore, RPO, RTO, failover, and continuity

## What you see and first thought

### The green backup that cannot recover

Imagine it is 02:10. The order database is corrupt, the primary region is unstable, and somebody points to a dashboard:

> Backup status: successful. Replica status: healthy.

That feels reassuring. It is not yet recovery evidence.

A backup job can complete while omitting a table, object bucket, key, certificate or configuration file. A replica can be perfectly healthy while copying the same deletion, malicious encryption or bad transaction as the primary. A snapshot can have a valid checksum but require a missing key. A database can restore cleanly while the application cannot log in, reconcile payments or prevent an unauthorized user from reading data.

The first thought of a strong SRE is:

> Green creation status proves that one step reported success. Recovery exists only when the required business flow is restored from a known point, validated for correctness and security, measured against RPO and RTO, and operable under the actual failure boundary.

### Start with the business operation

"Restore the database" is an implementation task. "Customers can safely place, retrieve and pay for orders, with no more than 15 minutes of accepted work lost, within 60 minutes" is a recovery requirement.

The second sentence tells you:

- which flow matters;
- what correct means;
- how much data loss is tolerable;
- how long interruption is tolerable;
- which application and dependency checks finish the recovery;
- what evidence an incident commander can accept.

Different flows can need different objectives. During a regional outage, accepting new orders might need a 15-minute RTO while historical analytics can wait a day. A single "system RTO" hides these priorities and leads teams to recover low-value components before a critical user path.

### Recovery is a chain, not a file

For a stateful service, the recoverable unit can include:

```text
application release + schema + configuration + authoritative data
        + incremental or WAL chain + encryption keys
        + identity and certificates + network/routing
        + dependency order + capacity/quota + observability
        + runbook and authorized people
```

If one required link is unavailable inside the failed domain, the recovery can stop. A cross-region database copy is useless if its encryption key, container image, DNS control or break-glass identity exists only in the primary region.

### A human conversation to remember

When somebody says, "We have backups," answer:

> Good. Which exact business state can we restore, where was it last restored, what did the application tests prove, what data-loss age did we measure, how long did the full user journey take to return, and can we still do it if the primary identity and control planes are unavailable?

This is not pessimism. It is how you turn storage objects into an operational promise.

### The three clocks

Keep three times separate:

1. **Failure time:** when service or data first became unacceptable.
2. **Recoverable-point time:** the newest business state you can actually validate.
3. **Flow-recovered time:** when the named user operation is correct, secure and reachable.

Actual data loss is approximately failure time minus recoverable-point time. Actual recovery time is flow-recovered time minus the business-agreed failure boundary. Starting the RTO clock when an engineer finally clicks "restore" hides detection, decision, access and readiness delays.

### What this lesson will make you able to do

You will learn to:

- reject false equivalence between replicas and backups;
- derive objectives from business impact;
- identify all state and dependency owners;
- choose recovery mechanisms by failure coverage;
- prove chain, key and version integrity;
- restore safely in isolation;
- test business and security correctness;
- measure RPO and RTO honestly;
- change write authority without split brain;
- fail back without overwriting recovery-region writes;
- build a drill and evidence system that improves after every test.

The goal is not to memorize a vendor DR menu. It is to know what must remain true when the normal system, its people or its control plane are unavailable.

## Terms before commands

### Business continuity

Business continuity is the organization's ability to keep priority outcomes operating at an acceptable level during and after disruption. Technology recovery is one part. Manual workflows, alternative suppliers, communications, facilities, people and legal obligations can also matter.

A payment service might temporarily accept fewer methods, queue requests safely or use a reviewed manual reconciliation process. That degraded mode is continuity only if its correctness, capacity, security and exit path are explicit.

### High availability

High availability, or HA, reduces interruption for expected failures by using redundancy, health detection, traffic movement and automated repair. Examples include multiple processes, nodes or zones.

HA does not guarantee a historical recovery point. If a valid API call deletes data, an HA replica may faithfully apply it everywhere. HA is usually about staying available; backup and DR are about recovering acceptable state after larger or different failures.

### Resilience

Resilience is the ability to withstand, adapt to and recover from disruption while preserving required outcomes. HA, graceful degradation, backups, DR, incident response and learning are resilience mechanisms. The word is broad; always attach it to a failure model and an outcome.

### Disaster

A disaster is a disruption whose impact or recovery needs exceed normal self-healing and routine incident procedures. It can be a regional outage, destructive software defect, ransomware, lost quorum, widespread credential compromise, corrupted storage, operator error or unavailable critical dependency.

Define activation criteria before the event. Otherwise teams lose time debating whether the word "disaster" is emotionally justified.

### Disaster recovery

Disaster recovery, or DR, is the planned restoration of acceptable technology-supported operations after a disaster. It includes declaration, authority, infrastructure, data, application, dependency, routing, security, validation, communication, observation and later failback.

DR is not synonymous with "copy data to another region."

### Business impact analysis

A business impact analysis, or BIA, identifies important functions, consequences of interruption, dependencies, priorities and tolerable disruption. It supplies the why behind technical recovery targets.

Engineers advise what architectures can achieve and cost. Business owners decide what loss and downtime are acceptable. Neither side should invent the other side's commitment.

### Critical flow

A critical flow is an end-to-end business or user operation selected for explicit recovery. "Checkout payment authorization" is stronger than "database." It crosses services, state, identity, network and external providers and gives recovery a meaningful finish line.

### Maximum tolerable disruption

Maximum tolerable disruption is the longest overall interruption the business can accept before consequences become unacceptable. It can include alternate manual operations and is broader than a technical RTO.

### Recovery time objective

RTO is the maximum acceptable time to restore a defined operation after the agreed disruption boundary. It is an objective, not a measurement and not a provider button.

If the objective is 60 minutes but a drill takes 95 minutes, the actual recovery time is 95 and the objective was missed. Do not redefine the clock after seeing the result.

### Recovery point objective

RPO is the maximum acceptable amount of data loss expressed as time. RPO 15 minutes means the recovered business state cannot be more than 15 minutes older than the relevant incident boundary.

RPO does not mean "back up every 15 minutes" automatically. Job scheduling, duration, transfer lag, chain gaps and validation determine the newest usable point.

### Actual recovery point and actual recovery time

Actual RPO evidence comes from the newest validated recoverable business event, not a filename or dashboard timestamp. Actual RTO evidence ends when the critical flow is correct, secure, reachable and supportable.

Objectives drive design. Actuals from exercises and incidents test whether the design works.

### Recovery time capability

A repeated drill distribution is more useful than one best result. Record stage durations, variability and failure conditions. A single 42-minute restore does not guarantee a 60-minute RTO when dataset size, rate, staff or provider capacity changes.

### Backup

A backup is a retained recovery copy or representation from which required state can be restored. Its useful properties include:

- exact source and scope;
- consistent point or recovery semantics;
- immutable identity and integrity;
- retention and ancestry;
- failure-domain and administrative independence;
- protected but available decryption;
- version/tool compatibility;
- demonstrated restore.

A copied file without these facts is merely an object.

### Full, incremental and differential backup

A full backup contains the entire selected backup scope at one point. An incremental contains changes since a prior backup in its chain. A differential commonly contains changes since a full backup.

Incrementals reduce creation/storage cost but add restore dependencies. Deleting an older parent can make newer children unusable. The manifest must preserve the graph, not just a directory of similarly named files.

### Logical and physical backup

A logical backup exports database objects and data through database semantics. It can be portable across some versions but can be slower and may omit server-level state unless explicitly included.

A physical backup captures database storage representation and normally requires engine-specific consistency and version rules. It can restore large systems efficiently but is not simply a live directory copy.

Choose from recovery needs, not familiarity with one command.

### Snapshot

A snapshot records a storage or system point using platform-specific copy-on-write or volume mechanisms. Snapshot creation can be fast, but application consistency, dependency alignment, encryption, location and restore validation remain separate.

Crash-consistent is not automatically transaction-consistent across several systems.

### Continuous archiving and point-in-time recovery

Point-in-time recovery, or PITR, combines a base with a continuous change log such as PostgreSQL WAL so recovery can stop near a chosen time. It needs an unbroken chain and a valid target after the base backup boundary.

PITR is essential for recovering to before a bad change, but only if retention, manifests, timelines and restore procedures work.

### Replication

Replication copies state between members or locations. Synchronous replication may reduce acknowledged data loss but increases latency/coupling. Asynchronous replication usually improves geographic tolerance at the cost of lag.

Replication is not a backup because it often copies logical mistakes and compromise and usually represents current rather than historical state.

### Recovery site

A recovery site is the environment used to restore service. It can be cold, pilot light, warm standby or active. Readiness includes data, capacity, quota, config, artifacts, identity, keys, certificates, network, routes, observability and people.

### Cold, pilot-light, warm-standby and active-active

- **Backup and restore/cold:** little running recovery capacity; lower steady cost, longer recovery.
- **Pilot light:** critical state/services stay ready at small scale; remaining infrastructure starts during recovery.
- **Warm standby:** a reduced but functional copy runs and scales for failover.
- **Active-active:** multiple locations serve normally, requiring complex state consistency, routing and fault isolation.

More active is not automatically better. Complexity can create correlated failure and unsafe authority.

### Failover

Failover moves service or write authority from an impaired location to a recovery location. It can be automated or manual. Safe failover requires a trustworthy health/decision model, capacity, valid state, dependency readiness, old-writer fencing, routing and observation.

### Fencing

Fencing prevents stale or isolated actors from mutating protected state after authority moves. Turning off a process is useful but may not be sufficient if it can return. A monotonic generation checked by the data owner is stronger.

Without fencing, failover can create two writers and divergent histories.

### Failback

Failback moves operations from recovery to the preferred environment. It is not reversing DNS. The recovery environment may now own new writes. Failback needs authority choice, divergence measurement, reverse synchronization, conflict handling, rebuild, validation, fencing, cutover and rollback.

### Restore validation

Validation is layered:

1. object identity and checksum;
2. decryption and format;
3. engine consistency and recovery logs;
4. schema/config/version compatibility;
5. business invariants and reconciliation;
6. authorization and prohibited behavior;
7. dependencies, capacity and observability;
8. complete critical flow.

Passing an earlier layer does not imply later layers.

### Drill, exercise and game day

A drill executes selected recovery procedures to measure behavior. A tabletop walks decisions and communications without performing full technical recovery. A game day tests a broader scenario with controlled fault and response.

Every exercise needs scope, authority, safety, expected evidence, abort, cleanup and learning ownership.

### Immutability, offline and air gap

An immutable recovery object cannot be modified during a retention period by the relevant authority. Offline means not normally connected or writable. An air gap is stronger separation, but operational implementations vary.

Ask which compromised identity or path can delete, encrypt or corrupt the copy. Marketing labels are not threat models.

## Architecture map

### Diagram 1: business promise to recovery proof

```text
business impact
      |
      v
named critical flow ---> approved RTO / RPO / correctness
      |                              |
      v                              v
state + dependency map ------> recovery strategy
                                      |
                                      v
                    isolated representative exercise
                                      |
                     +----------------+----------------+
                     |                |                |
                  integrity      business/security   elapsed time
                     +----------------+----------------+
                                      |
                                      v
                         bounded recovery evidence
```

The diagram begins with business impact because technical mechanisms cannot choose acceptable loss. It ends with bounded evidence, not a permanent guarantee.

### Diagram 2: layers that solve different failures

```text
continuity: business outcome and alternate operation
   DR: restore acceptable technology after severe disruption
      rebuild: code, configuration, images, infrastructure, identity
         backup/PITR: historical independent recovery points
            replication: copies current state, possibly with lag
               HA: redundant serving and automatic repair
```

Each lower layer can support the layer above, but none replaces it. HA can protect against one node loss while leaving region, corruption and identity failure uncovered.

### Diagram 3: backup trust envelope

```text
authoritative source
   -> consistent base/full
      -> required incrementals/log/WAL
         -> manifest + ancestry + hashes
            -> independent protected storage
               -> available protected key + approved identity
                  -> compatible isolated restore
```

The recovery point exists only if the entire required path is available. A missing middle WAL segment can make every later segment useless for the intended target.

### Diagram 4: end-to-end RTO clock

```text
T0 unacceptable service/data
 | detection | declaration | access | capacity | data | app | validation | route |
                                                                    T-recovered
```

Measure every stage. This shows whether automation, access, data volume, dependency order or validation dominates recovery time.

### Diagram 5: failover authority

```text
declare -> fence old generation -> validate recovery state
   -> grant new generation -> stage traffic -> observe guardrails
      -> continue, pause, or rollback
```

Routing before authority can send users to a writer that should not write. Authority before state validation can promote corruption. The order is part of correctness.

### Diagram 6: failback is another migration

```text
recovery site is authoritative
     |
measure divergence
     |
rebuild preferred site <- clean declarations and artifacts
     |
reverse sync + reconcile conflicts
     |
validate -> fence recovery writer -> staged cutover -> soak
```

If the preferred site still contains the original fault, failback can repeat the disaster. Rebuild and validate rather than trusting familiarity.

### System boundary map

For each critical flow, draw:

- client and traffic entry;
- identity provider and authorization;
- application services and queues;
- every authoritative and derived data store;
- object/file/configuration state;
- container/VM images and package sources;
- keys, secrets and certificates;
- DNS, routes and load balancers;
- observability and incident communication;
- external providers and manual workarounds;
- the control plane needed to change each layer.

Mark each boundary as primary-only, replicated, independently backed up, reproducible, external or currently uncovered. That final category is where honest engineering begins.

## Request or state path

### Normal write path

Consider an order placement:

```text
client -> edge -> identity -> order API -> database commit
                         \-> payment provider
                         \-> queue/event -> fulfillment
                         \-> audit/analytics
```

What does "accepted" mean? If the API returns success before payment or event durability, recovery needs reconciliation. If the database and event log cannot be restored to a compatible point, you can duplicate charges or lose fulfillment.

### Recovery-object creation path

```text
source identity and consistency boundary
  -> producer reads/captures
  -> full/base/snapshot object
  -> incremental/log stream
  -> manifest and checksums
  -> encryption
  -> protected independent storage
  -> retention and deletion control
  -> monitoring and audit
```

At every arrow ask:

- Which identity performed the action?
- Which exact source and point were captured?
- Can the object be incomplete while the job says success?
- Can the primary administrator delete the recovery copy?
- Is the key independent and recoverable?
- Which counter proves freshness and chain continuity?

### Recovery-selection path

When corruption begins at time C, newest is not automatically best:

```text
disaster boundary
   -> identify last known-good business event
   -> enumerate candidate base + chain combinations
   -> reject post-corruption or incomplete candidates
   -> verify key, version and target compatibility
   -> choose safest point with stated data-loss estimate
```

A backup completed after C may contain the bad state. A point before C may be correct but lose later legitimate work. Preserve both the recovery decision and reconciliation plan.

### Isolated restore path

```text
approved exercise identity
  -> empty isolated target
  -> restore infrastructure/config
  -> decrypt and materialize data
  -> engine recovery and consistency
  -> start application with external effects disabled
  -> business invariants and security tests
  -> capacity/dependency/observability checks
  -> user-flow evidence
```

Do not restore over the only remaining primary copy. Keep the original failure evidence. Isolation also prevents a restored queue consumer from sending emails, charging cards or mutating production.

### Failover path

```text
incident evidence -> DR declaration -> named authority
  -> stop/fence unsafe writers
  -> establish recovery state and capacity
  -> validate dependencies and credentials
  -> grant new write authority
  -> shift traffic gradually
  -> observe correctness and guardrails
  -> communicate recovery state
```

If traffic shift is all-or-nothing, make the abort and rollback decision explicit. If DNS is involved, cached answers and TTL behavior mean the fleet can be split during transition.

### Failback path

```text
recovery writes -> authoritative checkpoint -> rebuild old site
  -> reverse replication or transfer -> conflict/reconciliation
  -> validation -> new fencing generation
  -> staged routing -> soak -> retire temporary recovery state
```

Failback can have a different RTO and risk tolerance from failover. Recovery urgency is lower, so use that time to remove ambiguity.

### Kubernetes and etcd state path

Kubernetes desired state lives in etcd, but application data often lives elsewhere. An etcd snapshot can recover API objects; it does not recover a PostgreSQL volume, external object store or third-party payment state.

Restoring an older etcd revision can confuse watch-based clients with cached newer revisions. Current etcd guidance includes revision-bump and compaction considerations, and Kubernetes guidance requires coordinated control-plane handling. Follow the exact product/version documentation; do not copy commands from an older cluster guide.

### The final user path

Recovery finishes through the same user path that defines the objective:

```text
realistic synthetic user -> correct route -> authenticated operation
  -> authoritative data -> required dependency -> durable effect
  -> readable result -> audit and observability
```

Infrastructure health is supporting evidence. The user operation is the acceptance boundary.

## Failure zoom

### Failure 1: the successful job

The backup scheduler says success. During restore, one tenant partition is absent.

The first bad assumption was that producer completion represented content completeness. The correct evidence chain includes configured scope, discovered resources, captured counts, exclusions, object manifest, hashes and restore queries.

Recovery response:

1. freeze deletion/retention for related objects;
2. preserve job config and logs;
3. compare intended inventory with manifest;
4. select the newest complete eligible point;
5. restore in isolation and validate every required population;
6. fix discovery and add negative coverage for omitted state.

### Failure 2: the perfectly current replica

An operator drops a table or a defect deletes valid orders. The replica reaches zero lag because it applied the same change.

Zero lag proves freshness relative to the primary stream, not correctness. The replica is useful for node/zone failures but did not create historical independence.

Stop the destructive writer, preserve logs, identify the corruption boundary, choose a pre-corruption recovery point, restore and reconcile legitimate later operations. Promoting the replica can accelerate the wrong outcome.

### Failure 3: broken incremental ancestry

Full F0 exists. Incrementals I1, I2 and I3 appear in storage, but I2 expired or a WAL segment is missing. I3 is not a self-contained recovery point.

The chain is a graph:

```text
F0 -> I1 -> I2 -> I3
```

If I2 is required, F0+I1+I3 is incomplete. Inventory systems must understand ancestry before deletion. Validate retention against every dependent child and run actual restore, not merely object-existence checks.

### Failure 4: the key inside the disaster

Backups are encrypted correctly, but the only key service, operator credential or certificate chain is in the failed region or compromised identity domain.

Security and availability were designed separately. Do not bypass encryption or copy a private key into an uncontrolled channel. Use a predesigned independently protected recovery identity and key path with audit, quorum/approval and periodic testing.

The opposite is also dangerous: a globally powerful backup identity can let one compromise delete every recovery point. Separate create, delete, restore and approval where risk requires it.

### Failure 5: a technically clean but wrong restore

Database recovery logs show consistency and checksums pass. Yet customers see wrong balances because the database and external payment ledger were restored to different logical points.

Engine consistency proves the database can operate. Business correctness requires cross-system invariants and reconciliation. Record acknowledgements, idempotency keys, external receipts, queue offsets and audit events so uncertain operations can be resolved.

### Failure 6: RPO mathematics hidden by a schedule

Target RPO is 15 minutes. A job begins every 15 minutes, takes 12 minutes and another 8 minutes to reach independent storage. At failure, the newest complete protected point can be 35 minutes old depending on timing.

Frequency is not actual RPO. Measure:

```text
actual loss age =
    incident boundary - newest validated recoverable business timestamp
```

Include capture, completion, copy, lag, chain and validation. Alert on recoverability age, not only last job start.

### Failure 7: RTO stops at the wrong milestone

The database restores in 28 minutes, so a 30-minute RTO dashboard turns green. Application images are unavailable, certificates expired, DNS access is blocked and validation takes another 70 minutes.

The database restore time is one stage. Keep the critical-flow RTO clock running. Record stage timestamps so the team invests in the actual bottleneck.

### Failure 8: standby drift

The recovery region was built six months ago. Policies, schema, images, quotas and certificates drifted. It exists but cannot safely serve.

Continuously compare desired declarations and effective recovery state. Exercise the exact deployment/recovery pipeline. A stopped resource that cannot scale under available quota is not capacity.

### Failure 9: the dead control plane

Recovery automation needs an API, identity provider, artifact registry or source repository located in the failed environment. The data plane could serve, but the team cannot create, route or authenticate recovery resources.

Identify control-plane dependencies before the incident. Pre-provision or replicate the minimum recovery capabilities and keep runbooks/credentials accessible through independent paths.

### Failure 10: two primaries

Network isolation makes the old primary look dead. Recovery is promoted. The network heals and the old primary resumes scheduled writes.

Health is not authority. Fence the old generation at the storage or effect owner. Preserve both histories, stop unsafe writes and reconcile using business rules. Never choose winners from wall-clock timestamps alone.

### Failure 11: unsafe failback

The preferred region returns, and a team reverses DNS. Writes accepted during recovery are absent there.

Failback needs source-of-truth declaration, reverse synchronization, conflict handling, validation, new fencing and staged cutover. It is a planned migration, not the closing step of an incident checklist.

### Failure 12: ransomware reaches the backups

The production identity can enumerate and delete every backup. Malware or a compromised administrator removes recovery points before encrypting primary state.

Use failure- and administration-domain separation, retention enforcement, immutability/offline copies, least privilege, alerting and tested recovery. Verify clean state before restore so persistence is not reintroduced.

## Internals and state ownership

### State classes

Classify each item:

| Class | Meaning | Recovery treatment |
|---|---|---|
| Authoritative | accepted business truth | protect, restore, reconcile |
| Derived | reproducible from authoritative inputs | rebuild and validate |
| Ephemeral | safe to lose by contract | recreate or discard |
| External | owned by another system | query, reconcile, contract |
| Configuration | declares intended behavior | version, protect, reapply |
| Credential/key | enables access or decryption | independently protect and test |

Do not back up a cache merely because it occupies space. Do not omit a tiny signing key because it contains few bytes.

### Consistency boundary

A backup is taken while writes happen. The mechanism must define the consistency point. Database-native backup protocols, filesystem snapshots and application quiescing solve different boundaries.

For multiple stores, one timestamp does not create a distributed transaction. You may need an application checkpoint, event log, idempotent replay or business reconciliation. Document what can be uncertain.

### PostgreSQL recovery ownership

PostgreSQL logical dumps, physical backups and continuous archiving have distinct scope and compatibility. PITR combines a base backup with every required WAL segment through the target. Recovery timelines represent branched histories after recovery.

Important ownership questions:

- Which cluster/version produced the base?
- Which WAL range is required?
- Who owns archive retention and failure alerts?
- Which timeline/target is intended?
- How is restored data validated?
- What is the reconciliation plan for operations after target time?

Do not delete WAL based only on filename age when a retained base or incremental depends on it.

### Kubernetes and etcd ownership

etcd holds Kubernetes API state, not every workload's external or volume data. Snapshot status exposes revision, hash and size, while restore creates new data directories and cluster identity considerations.

Kubernetes components and watch caches can observe revision rollback. Follow current etcd/Kubernetes procedures, including revision handling and component coordination. Restoring etcd without application data coordination can produce a control plane describing state that no longer matches external reality.

### Identity and key ownership

Recovery needs identities that can:

- read protected objects;
- use recovery keys;
- provision or activate infrastructure;
- configure routes;
- inspect logs and metrics;
- approve high-impact authority changes.

Those identities must be accessible during the modeled disaster but must not create one permanent superuser. Use scoped roles, separation of duties, strong authentication, offline procedures where justified, audit and expiry.

### Recovery environment ownership

Every readiness item needs an owner:

| Item | Typical evidence |
|---|---|
| Capacity | allocatable units, startup time, load test |
| Quota | limit, usage, headroom, approval lead time |
| Configuration | desired digest versus effective state |
| Artifact | immutable digest, location, signature/provenance |
| Network | routes, address ranges, firewall and DNS behavior |
| Certificate | issuer, names, validity, renewal path |
| Observability | independent collection, dashboards and alerts |
| Runbook | version, reviewer, last drill and offline access |

An architecture diagram without owners becomes an archaeology exercise during failure.

### Authority state machine

Model write authority explicitly:

```text
PRIMARY_ACTIVE
  -> DECLARED_RECOVERY
  -> PRIMARY_FENCED
  -> RECOVERY_VALIDATED
  -> RECOVERY_WRITER_ACTIVE
  -> TRAFFIC_MIGRATED
```

Transitions require evidence and authorization. A rollback may return to a prior safe state only if data authority remains clear.

### Communication ownership

Technical recovery can fail because decision makers lack a shared timeline. Preassign:

- incident commander;
- recovery executor;
- data owner;
- security reviewer;
- business approver;
- internal/external communicator;
- scribe and evidence owner;
- stop authority.

Status messages should state impact, known facts, uncertainty, recovery stage, data-loss estimate, next decision and next update time.

## Evidence table

| Evidence | Strong interpretation | Does not prove |
|---|---|---|
| Job status success | producer completed its configured path | correct scope or usable restore |
| Backup object exists | named bytes exist at a location | completeness, integrity or ancestry |
| Object checksum matches | bytes match expected digest | semantic or application correctness |
| Replica healthy | replica process responds under its health rules | independent history or correct data |
| Replication lag zero | replica applied through observed source position | absence of propagated corruption |
| Manifest and chain graph | required object ancestry is enumerated | objects are readable or compatible |
| Independent retention lock | covered principal cannot alter object during term | every privileged path is controlled |
| Key access test | approved recovery identity can decrypt test material | production dataset/application recovery |
| Database consistency check | engine structures pass covered checks | business invariants or external reconciliation |
| Application invariant tests | named rules pass in isolated restore | every record or production capacity |
| Negative authorization tests | selected forbidden operations are denied | complete security or no persistence |
| Newest valid business timestamp | a recoverable state point is evidenced | RPO met until compared with incident time |
| Stage timestamps | observed duration of each recovery phase | future guaranteed RTO |
| Recovery-site config diff | declared/effective drift is measured | absence of runtime/provider drift |
| Quota and capacity test | covered recovery demand fits observed envelope | capacity during a different disaster |
| Fencing negative test | tested stale generation cannot write | all unknown writers are fenced |
| Staged user traffic | selected real path works at current share | full-load safety or long-term correctness |
| Reconciliation report | known divergence was classified/resolved | no undiscovered external effect |
| Cleanup inventory | expected exercise assets are absent | no artifact outside inventoried boundary |

### Evidence quality questions

For every artifact ask:

1. Who produced it?
2. What exact source, scope and time does it describe?
3. Is it authenticated and integrity-bound?
4. Which failure domain stores it?
5. Which identity can alter or delete it?
6. Which version can consume it?
7. When was it last exercised?
8. What conclusion is outside its coverage?

Evidence without limitations becomes a slogan.

## Command decoders

These commands operate only the synthetic lab. They teach decision order without pretending to recover a real service.

### 1. `bash lab.sh doctor`

Doctor checks normal-user execution, Python availability, local source files and absence of cloud, cluster or Docker authority variables. It does not contact any endpoint.

Pass means the bounded model may run. Refusal tells you which authority or prerequisite violates the lab contract. Never bypass a guard to make a lesson pass.

### 2. `bash lab.sh setup`

Setup creates one UID-scoped directory under `/tmp` with mode restricted by `umask 077`, writes an ownership sentinel and copies one synthetic JSON fixture.

It refuses existing state to avoid overwriting. Cleanup is required because bounded mutation includes ownership of removal.

### 3. `bash lab.sh status`

Status revalidates ownership and exact inventory, then counts case names through the model. Expected output includes `cases=45`.

It proves the local fixture identity. It says nothing about real backups or infrastructure.

### 4. `bash lab.sh list`

List prints the 45 case names. Use names to select one evidence boundary. The cases are teaching coverage, not a universal DR checklist.

### 5. `bash lab.sh show baseline`

Show merges baseline values and case overrides, then prints normalized JSON. Read it before accepting the model decision. A decision system must expose the facts on which it operates.

### 6. `bash lab.sh evaluate baseline`

Evaluate walks gates in safety order and reports the first failure. Baseline reports `boundary=defensible` because every encoded predicate passes.

"Defensible" means only that the synthetic record contains all modeled claims. It does not mean a system is recoverable.

### 7. `bash lab.sh evaluate replica-called-backup`

This case sets the false claim that replication is the backup strategy. The model stops at `replication-is-not-backup`.

The remediation is an independently retained and tested recovery point, not an unhealthy replica.

### 8. `bash lab.sh evaluate wal-or-incremental-chain-gap`

This case makes chain completeness false. The model refuses later recovery claims because restore cannot be trusted without required ancestry.

In a real product, identify required objects using exact versioned documentation and manifests before deletion or recovery.

### 9. `bash lab.sh evaluate application-correctness-unchecked`

The synthetic storage restore passes but business validation is absent. The model stops at `application-correctness`.

Define invariants before the drill: counts alone are weak when relationships, state transitions or external effects matter.

### 10. `bash lab.sh evaluate measured-data-loss-exceeds-rpo`

The candidate's actual data loss is greater than the approved objective. The correct result is a miss, even when restore succeeds.

Respond by improving mechanism or renegotiating the business target transparently. Do not change the incident timestamp.

### 11. `bash lab.sh evaluate old-primary-can-still-write`

This case blocks at `single-writer-safety`. A reachable recovery site cannot become authoritative while stale writers remain able to mutate protected state.

Use fencing whose generation is enforced at the state owner and prove old writes fail.

### 12. `bash verify.sh`

The verifier starts from absent state, checks doctor/setup/status, evaluates all 45 cases, asserts important boundaries, injects an unknown artifact, proves the guard refuses to proceed, clears only that test artifact, cleans allowlisted state and proves absence.

Expected final line:

```text
verify=pass cases=45 refusal=true cleanup=true
```

Passing proves deterministic model behavior and cleanup only. It cannot award DR competence or production acceptance.

## Decision path

### The recovery decision algorithm

Use this sequence during design, drills and incidents:

1. **Name the flow and impact.** What user/business outcome is unacceptable?
2. **Set the time boundary.** When did service or data become unacceptable?
3. **Stop continuing harm.** Fence corrupting writers, compromised identities or destructive automation.
4. **Declare authority.** Who may activate recovery, approve data loss, stop or communicate?
5. **Inventory recovery scope.** State, dependencies, keys, configuration, artifacts, network and people.
6. **Choose a valid point.** Bind source, consistency, chain, integrity, key, version and last known-good business event.
7. **Restore in isolation.** Never risk the only surviving copy or trigger external effects.
8. **Validate in layers.** Bytes, engine, application invariants, security, dependencies, capacity and user flow.
9. **Measure actuals.** Calculate newest valid business point and complete-flow elapsed time.
10. **Fence and fail over.** Move write authority before traffic under staged guardrails.
11. **Soak and reconcile.** Resolve uncertain/deferred effects and monitor correctness.
12. **Plan failback separately.** Rebuild, reverse-sync, validate, fence and migrate.

If the flow is unknown, return to BIA. If the point is unproved, do not restore it. If correctness is unproved, do not route users. If writer authority is ambiguous, do not enable writes.

### Selecting the mechanism

| Failure to tolerate | Candidate mechanism | Crucial limitation |
|---|---|---|
| process or node loss | redundant instances and health-based failover | shared state/dependency can still fail |
| zone loss | cross-zone placement and capacity | region/control-plane correlation remains |
| region loss | standby or active second region | data, quota, identity and routing readiness |
| accidental deletion | historical backup or PITR | point must predate deletion |
| database corruption | independent validated recovery point | replicas may contain corruption |
| ransomware/admin compromise | access-separated immutable/offline copies | clean identity/key/rebuild also required |
| deployment/config defect | rollback plus data compatibility | rollback cannot undo every data change |
| total provider/control-plane loss | independent continuity/alternate provider where justified | high complexity and cost |

Choose the cheapest design that meets approved outcomes under stated failure assumptions. A complicated active-active system can be less recoverable than a well-tested warm standby.

### Recovery-point gate

A candidate recovery point is eligible only when:

- exact source, scope and consistency are known;
- base/parent/log ancestry is complete;
- hashes and manifest identity match;
- retention has not expired required objects;
- the point precedes known corruption when necessary;
- decryption identity and key are available through approved paths;
- restore tool and target versions are compatible;
- isolated validation is possible;
- expected data-loss age is stated.

If several points qualify, prefer the newest point that is demonstrably correct, not simply newest by filename.

### Failover gate

Failover requires:

- declared incident and named decision authority;
- validated recovery state and critical flow;
- capacity, quota, dependency, certificate and monitoring readiness;
- old-writer fencing or proven inability to mutate;
- explicit new writer generation/authority;
- routing plan with propagation behavior;
- numerical correctness, error, latency, backlog, security and capacity aborts;
- stakeholder communication and rollback.

Failover automation may execute this state machine, but automation does not remove the need for evidence and authority.

### RPO and RTO calculation

```text
actual_data_loss =
  incident_boundary_time - newest_valid_recoverable_business_time

actual_recovery_time =
  complete_critical_flow_recovered_time - incident_boundary_time
```

Record clock source, timezone and event provenance. If the incident boundary is uncertain, report a range. Do not create false precision.

### Failure during recovery

If restore integrity fails, stop and preserve artifacts. Select an earlier complete point or correct the recovery toolchain; do not repair evidence in place without traceability.

If RTO will miss, communicate early and activate approved degraded operations. If RPO will miss, the business/data owner must understand and accept the actual loss; engineers cannot silently approve it.

If failover creates dual writers, stop both write paths if needed, preserve histories, establish authority and reconcile before resuming.

## Guided Ubuntu lab

### What this lab teaches

The lab is a safe reasoning simulator. It cannot touch a database or create a backup. Its value is the order of refusal: a candidate cannot claim restore correctness before chain, key and isolation gates, and cannot claim failover before measured objectives, capacity and writer authority.

### Start safely

From a normal-user Ubuntu 24.04 shell:

```bash
cd /home/your-user/work/DevOps-SRE-Learning-Path/drafts/LES-0074-disaster-recovery-backup-restore-failover-continuity/support/lab
pwd
bash lab.sh doctor
bash lab.sh setup
bash lab.sh status
```

Expected status includes `cases=45`. If doctor refuses because an authority variable is present, use a clean learning shell; do not unset a production context casually while other work depends on it.

### Compare claims

```bash
bash lab.sh evaluate baseline
bash lab.sh evaluate replica-called-backup
bash lab.sh evaluate backup-older-than-rpo
bash lab.sh evaluate wal-or-incremental-chain-gap
bash lab.sh evaluate recovery-key-unavailable
bash lab.sh evaluate restore-targets-production
bash lab.sh evaluate application-correctness-unchecked
bash lab.sh evaluate measured-recovery-exceeds-rto
bash lab.sh evaluate old-primary-can-still-write
bash lab.sh evaluate failback-unplanned
```

For each output write:

- the claim that was tempting;
- the first failed evidence boundary;
- what the available evidence proves;
- what it cannot prove;
- the next safe evidence;
- who must authorize a real action.

### Inspect the baseline

```bash
bash lab.sh show baseline
```

Notice that the baseline is defensible only because every boolean and numerical field is pre-filled. In production, each field needs provenance. "backup_chain_complete=true" is not evidence; the manifest, object inventory and successful isolated restore are evidence.

### Run the full verifier

First clean the guided state, then run:

```bash
bash lab.sh cleanup
bash verify.sh
```

Expected:

```text
verify=pass cases=45 refusal=true cleanup=true
```

The verifier deliberately injects an unknown file. Status must refuse rather than delete it. Cleanup owns only allowlisted artifacts. This teaches the same production rule: a DR script must never broaden deletion because a directory "looks temporary."

### Build a recovery worksheet

Create a local note with:

| Field | Your evidence |
|---|---|
| Critical flow | named user/business operation |
| Disaster boundary | timestamp and definition |
| RTO/RPO | approved values and owner |
| Newest eligible point | source, chain, key, timestamp |
| Isolation | why restore cannot affect production |
| Correctness | engine, business and security tests |
| Failover | authority, fencing, routing and aborts |
| Actuals | measured loss and elapsed time |
| Failback | authority, synchronization and rollback |
| Limitations | what remains unproved |

Do not fill unknown fields with guesses. "Unknown; next evidence is..." is an expert answer.

### Cleanup

```bash
bash lab.sh cleanup
```

Cleanup should report absence. Passing this guided lab shows familiarity with the decision order. The independent transfer requires reviewer-owned faults and evidence and is scored separately.

## Production transfer

### Begin with a recoverable business flow

A production recovery design starts with a sentence a business owner recognizes: "A customer can authenticate, submit one order, receive a durable confirmation, and retrieve that same order." That is stronger than "restore PostgreSQL." The user flow may also need identity, DNS, secrets, queues, object storage, fraud decisions and an external payment provider. One healthy database does not make the service recovered.

For every critical flow, record:

| Field | Required decision |
|---|---|
| owner | Who decides criticality and acceptable degradation? |
| entry point | Where does the operation enter systems you operate? |
| authoritative state | Which writes establish business truth? |
| derived state | Which caches or indexes can be rebuilt? |
| external dependencies | What can you observe but not restore? |
| correctness invariant | What must never be duplicated, omitted, reordered or exposed? |
| approved RPO and RTO | Who approved loss and time limits? |
| degraded mode | What smaller safe service may operate? |
| evidence owner | Who declares the recovered flow correct? |

Classify each dependency as authoritative, replayable, rebuildable, ephemeral, external or control-plane state. That classification drives protection. A ledger needs recoverable history and reconciliation. A cache usually needs warm-up capacity, not backup. A queue needs ordering, deduplication and in-flight-message rules. Kubernetes manifests may live in Git, but cluster identity, secrets, persistent volumes, DNS and managed services still require recovery.

Draw dependency order. An application cannot validate its restored database if the recovery environment cannot obtain the encryption key; the key path may require identity and networking first. Restore sequencing must follow those edges.

```text
client
  |
DNS -> edge -> application -> identity / keys
                    |
                    +-> authoritative database -> replica
                    |             |
                    |             +-> backup objects + log archive
                    |
                    +-> queue -> worker -> external provider
                    +-> object store
                    +-> rebuildable cache / search
```

### Engineer the backup control

A defensible backup has six properties:

1. **Coverage** includes all authoritative state and recovery metadata.
2. **Consistency** represents a recoverable boundary across related data.
3. **Independence** prevents one production compromise from erasing every copy.
4. **Integrity** exposes missing or changed artifacts.
5. **Recoverability** includes the full chain, keys, tooling and configuration.
6. **Evidence** comes from a successful isolated restore, not job status alone.

Keep a machine-readable manifest containing source identity, start and completion time, logical recovery boundary, base/full identifier, every incremental or log range, checksums, encryption-key reference, format version, retention class and verification result. Protect the manifest from unauthorized alteration.

Retention is a policy: define recovery points from business, regulatory and threat requirements; keep protected copies across an independent security boundary; test expiry and legal holds. Separate create, restore, retention-administration and destruction privileges. The backup writer should not be able to erase every backup. Alert on retention reduction, protected-copy deletion, chain gaps, quota exhaustion and key failures.

### Build an isolated restore pipeline

The restore environment must be unable to overwrite production:

```text
approved manifest
      |
      v
isolated account / network
      |
      +-> constrained restore identity
      +-> separately authorized key path
      +-> pinned recovery tooling
      |
      v
artifact -> engine -> business -> security -> capacity checks
      |
      v
evidence package -> controlled cleanup
```

Create it from reviewed infrastructure as code. Permit reading only the selected backup and writing only the isolated target. Block routes and credentials that could call production write APIs or external providers.

Validation is layered:

- **artifact**: objects exist, checksums match and the chain has no gap;
- **engine**: the storage engine opens without recovery errors;
- **schema/configuration**: versions, migrations and extensions are compatible;
- **business**: balances, relationships, uniqueness and critical flows satisfy invariants;
- **security**: encryption, authorization and audit controls remain valid;
- **operability**: monitoring, scaling, backup and support access work;
- **performance**: the alternate meets required load or an approved degraded capacity.

A smoke query is not business proof. A payment system may require every accepted authorization to have one durable identifier, no settlement item to occur twice, and ledger entries to balance under domain rules. Application and business/data owners must jointly own these checks.

### Measure readiness continuously

Recovery readiness decays as data grows, keys rotate, permissions drift and people leave. Observe:

| Signal | Meaning |
|---|---|
| age of newest complete eligible point | whether the service can satisfy RPO now |
| chain continuity and archive lag | whether point-in-time recovery is possible |
| protected copies by failure boundary | whether independence still exists |
| age of last isolated restore | how recent the recovery proof is |
| restore duration by stage | where RTO is being consumed |
| business-invariant result | whether recovered state is usable |
| recovery-key test | whether encrypted copies can be opened |
| configuration drift and quota | whether the recovery path still fits |
| overdue drill actions | whether known gaps remain untreated |

Avoid a dashboard tile called only "DR healthy." Prefer: "newest valid point age 11 minutes; approved RPO 15 minutes; last isolated restore 6 days ago; restore p95 42 minutes; approved RTO 60 minutes." Page when an objective is already violated; ticket slower erosion.

### Establish authority before the incident

Name an incident commander, operations lead, data authority, application validator, security lead, communications lead and recorder. The data authority chooses the recovery point and accepts explicit data loss; engineers do not silently accept it. Use two-person confirmation for selecting an older point, fencing a primary, changing global routing, breaking replication or changing recovery-key access.

Define activation conditions. Failover is justified when the primary cannot meet the critical flow within the remaining objective and the alternate is demonstrably safer. It may be wrong when the alternate is stale, undersized, missing keys or has another unresolved fault. A regional alert by itself is not a decision rule.

### Fence before traffic

The core write-safety invariant is:

```text
at most one authoritative writer for a non-conflict-safe record
```

A controlled failover normally:

1. freezes unnecessary changes and declares the incident boundary;
2. confirms objectives, candidate evidence and authority;
3. stops or fences the old writer using an independent mechanism;
4. verifies from outside that old-path writes fail;
5. establishes the selected data boundary and promotes or restores the alternate;
6. validates engine, business, security, observability and capacity gates;
7. moves a small observable fraction of traffic where possible;
8. compares errors, latency, saturation, backlog and invariants;
9. proceeds or aborts using predeclared thresholds;
10. records measured loss and recovery time.

Fencing cannot rely only on asking the unhealthy primary to stop. Revoke its lease or write credential, remove it from quorum, isolate its network or detach the writable resource, then prove a write from the old path is rejected.

DNS and load balancers move requests; they do not select data authority. TTL caches and long-lived connections converge differently. Measure actual client paths and writer rejection.

### Treat failback as another migration

The recovered service is now production. Do not fail back because the old site merely responds to health checks. Rebuild it from current authority, repair the root cause, synchronize state, validate correctness/security/capacity, establish a new fenced boundary, shift traffic gradually and refresh backup protection.

Automatic failback can revive stale state or create repeated movement. Prefer an approved, observable migration unless the data protocol formally guarantees and has repeatedly proven safe return.

### Drill the organization, not only the command

Progress from tabletop to artifact inspection, isolated restore, multi-dependency restore, controlled traffic rehearsal and an approved production game day. Vary faults: missing incremental, expired credential, incompatible binary, slow retrieval, absent expert, stale runbook or insufficient capacity.

Every drill produces scope, hypothesis, approvals, timeline, manifest, tool versions, automation records, invariant results, measured RPO/RTO, abort decisions, cleanup proof, limitations, action owners and due dates. Treat corrections like production work. A lesson without an owner and deadline is only a memory.

## Reliability, security, observability, capacity, and cost

### Match controls to failure boundaries

Availability replicas survive some process, host or zone failures. Independent historical copies survive different events such as deletion, corruption or compromise. One mechanism rarely covers everything.

| Failure | Primary control | Remaining risk |
|---|---|---|
| process/host loss | restart or replica | shared defect or control plane |
| zone/region loss | alternate placement | correlated identity and data risk |
| deletion/corruption | historical point plus validation | identifying last known-good time |
| ransomware | immutable independent copy | clean identity and keys |
| bad schema release | rollback/forward repair plus recoverable state | irreversible transformation |
| provider loss | alternate or degraded mode | consistency and backlog |

"Multi-region" describes placement, not proven survivability.

### Protect the recovery system

Backups are concentrated production data and may retain records already deleted from the application. Use least privilege, encryption, independently governed keys, immutability, access logging, anomaly detection and tested break-glass recovery. Do not create a shared static rescue credential.

In cyber recovery, a fast but infected restore is failure. Build a trusted recovery environment, choose a point before known compromise, validate images and state, rotate affected identities, restrict connectivity and preserve forensic evidence. Security defines "clean"; domain owners define "correct."

The production delete identity must not delete every protected copy. Production network compromise must not grant access to the restore network. Encryption must have a separately governed recovery-key path: encrypted bytes with a permanently lost key are not recoverable.

### Observe before, during and after

Before an event, measure point freshness, chain continuity, restore-test age, drift and capacity. During recovery, measure stage duration, errors, saturation, replay lag, backlog, routing convergence and invariants. Afterward, record actual RPO/RTO, residual inconsistency, user impact, failback readiness and action closure.

Correlate infrastructure with the critical flow. A database CPU graph can be green while every order fails because identity or message signing is unavailable. Keep recovery evidence in a boundary the failed environment cannot erase, synchronize clocks, add a recovery correlation identifier, and never copy secrets or sensitive restored records into incident chat.

### Calculate capacity honestly

Model data size, growth, retrieval/decompression throughput, replay rate, bandwidth, API quotas, compute, memory, IOPS, cache warming, backlog drain and downstream limits.

```text
transfer lower bound = recoverable bytes / effective end-to-end rate
replay lower bound   = queued work / measured replay rate
```

Twelve TiB through a sustained 250 MiB/s path needs roughly 14.6 hours for transfer alone. Provisioning, replay and validation come afterward. A runbook cannot turn that architecture into a one-hour RTO.

Backlog is another capacity gate. If arrivals are 5,000 events/s and recovered processing is 4,000 events/s, the queue never drains. Add capacity, reduce arrivals or activate approved shedding/deferment. Decide ahead of time which flows or tenants receive scarce recovery capacity.

### Pay deliberately for the objective

| Strategy | Standing cost | Recovery behavior | Limitation |
|---|---:|---|---|
| backup and rebuild | low | provision, restore, validate | longest RTO |
| pilot light | low-medium | scale a small core | dependencies can drift |
| warm standby | medium-high | scale a complete smaller service | scale-up must be proven |
| active/active | high | multiple sites serve | hardest consistency and operations |

Include retention storage, protected-copy controls, transfer, licenses, reserved capacity, drills and staff. Use business impact to tier services. A settlement ledger and an internal dashboard need not have identical objectives. Cheap copies that miss RTO are poor insurance; permanently idle capacity for a noncritical flow may be waste.

## Traps and prevention

### Green backup job

It may be partial, have a broken chain, use an unavailable key or never have been restored. Require an isolated restore and layered correctness proof with a freshness limit.

### Replica called a backup

Replication copies deletion, corruption and malicious writes and often shares credentials and control plane. Use replicas for availability and independently retained history for recovery.

### Checksum called recoverability

A checksum proves observed bytes match expected bytes. It cannot prove chain completeness, usable keys, compatible tooling or correct business state. Keep it as one artifact gate.

### Backup frequency called RPO

A frequent job can be late, incomplete or based on older state. Measure the age of the newest complete valid business point.

### Database startup called RTO

RTO includes declaration, provisioning, key access, replay, applications, dependencies, correctness, capacity and routing. Time the complete critical flow.

### Always choosing the newest point

The newest point can contain compromise, corruption or a destructive migration. Preserve history, find the last known-good boundary and obtain data-owner acceptance of loss.

### Restoring over production

A wrong context can destroy good state. Enforce separate accounts/networks, target allowlists, least privilege and explicit production refusal.

### Recovery keys kept in the failed boundary

Artifacts become unreadable. Build a separately governed key and identity path and exercise it without exposing secret values.

### Active/active called automatic safety

Conflicts, shared control planes and correlated releases remain. Define conflict semantics, isolate failure domains and test writer authority.

### DNS called failover

DNS cannot fence a writer or guarantee client convergence. Measure actual request paths, connections and old-path write rejection.

### Automatic failback

A returning site may be stale or partly repaired. Treat return as a reviewed migration with synchronization, fencing and aborts.

### Third parties omitted

Recovered applications may still depend on identity, payment, certificates or SaaS. Observe and contract each dependency and define a degraded mode.

### Objectives redefined after failure

Changing the target hides the miss. Report approved target, actual, uncertainty and impact separately. Revise future objectives only through governance.

### Runbook trusted without execution

Commands, packages and permissions drift. Pin tools, rehearse procedures, automate deterministic gates and retain human approval for judgment.

### Drill closed when traffic returns

Reconciliation, protection, exhausted capacity and actions may remain. Exit only when ownership, evidence, protection, cleanup and follow-ups are explicit.

## Memory card and retrieval

### Remember FLOW - POINT - PROVE - FENCE - RETURN

- **FLOW**: name the business operation and every required dependency.
- **POINT**: select a complete valid boundary and quantify loss.
- **PROVE**: restore in isolation and validate technical and business correctness.
- **FENCE**: establish exactly one writer before production traffic.
- **RETURN**: protect the new authority and treat failback as another migration.

This order prevents the worst shortcuts: restoring the wrong thing, trusting an artifact that never worked, or creating two authorities.

### Two objectives and one proof ladder

```text
RPO asks how much business history may be lost.
RTO asks how long until the critical flow is usable.

artifact exists
 -> integrity matches
  -> chain complete
   -> keys and tooling work
    -> engine opens
     -> business invariants pass
      -> dependencies and capacity pass
       -> controlled traffic succeeds
```

Lower evidence cannot prove a higher claim.

### Four questions before failover

1. Which system is authoritative now?
2. What independent evidence proves the old writer cannot write?
3. What exact data boundary will the new writer represent?
4. Which abort signal stops traffic movement?

If an answer is vague, traffic movement is premature.

### Thirty-second response

When told "DR is green; fail over now," say:

> Green job status does not prove the critical flow is recoverable. I will confirm RPO and RTO, identify the newest complete valid point, prove chain and key access, validate the alternate in isolation, fence the old writer, and move traffic using business and technical abort signals. I will report actual data loss and recovery time separately from targets.

### Retrieval practice

Without looking back, write the five memory words; the difference between a replica and a backup; the proof ladder; four fencing mechanisms; the timestamp pair for actual RPO and RTO; and three reasons a successful engine restore may still be wrong. Check, then repeat after one day, one week and one month. Retrieval creates incident memory; rereading mostly creates familiarity.

## Complete answers

### 1. What is the practical difference between high availability and disaster recovery?

High availability keeps a selected service path operating through failures the running design expects: a process dies, a host disappears or a zone becomes unreachable. It usually uses redundancy, health detection and fast traffic or leadership movement. Disaster recovery restores acceptable business operation after damage exceeds normal self-healing: regional loss, widespread corruption, destructive administration, identity compromise or loss of shared control state.

The boundary is not the number of minutes. It is the failure model and recovery mechanism. A database replica can provide HA because it is current and promotable. It is weak protection against an accidental table deletion because replication can copy that deletion immediately. Historical protected points cover that different failure. Mature services use both and state which scenario each control addresses.

### 2. Why is a replica not automatically a backup?

A replica optimizes currency and availability. It intentionally receives source changes, including unwanted ones. It often shares software, schema, credentials, administrators, network, account and control plane with the primary. That produces correlated failure.

A backup optimizes recoverable history. It preserves identifiable points for a retention period and can be restored independently. The strongest copies are protected from production deletion and compromise. A delayed or immutable replica-like technology can contribute to a backup strategy only if it supplies retained, independently restorable history with proven recovery. Judge properties, not product labels.

### 3. Explain RPO and RTO without definitions that hide the user

RPO is the approved maximum gap between the incident boundary and the newest correct business state you can recover. If disaster is declared at 14:00 and the newest validated order is from 13:52, measured data loss is eight minutes, even if a backup job completed at 13:59.

RTO is the approved maximum time from the agreed incident boundary until the named critical flow is usable at its required level. If a database opens after 20 minutes but authentication, queue processing and order retrieval work after 75 minutes, the flow-level actual is 75 minutes.

Both are objectives approved from business impact. They are not guarantees created by entering a number in a product.

### 4. How do you calculate actual RPO when timestamps disagree?

First normalize timestamps to a trusted clock and timezone. Preserve their source: database commit time, log-sequence boundary, backup manifest time, incident declaration and validation time. Find the newest recovered business transaction that passes domain validation, not merely the newest file timestamp.

Then calculate incident boundary minus that business-state time. If the incident began between 13:58 and 14:02 and the newest validated transaction is 13:50, report an 8-to-12-minute range and explain the uncertain boundary. Do not select whichever timestamp makes the result look compliant.

### 5. What does point-in-time recovery actually require?

PITR normally requires a consistent base backup plus an unbroken ordered archive of changes—such as PostgreSQL WAL—through the target point. It also requires compatible engine software, configuration, extensions, usable encryption keys, storage, time/sequence interpretation and a safe target.

You must verify archive continuity and recovery behavior. Keeping log files is insufficient if a segment is missing, named for the wrong source, expired before its base, encrypted under a lost key or incompatible with the target engine. After replay, validate application invariants because a technically valid target time may already include the harmful event.

### 6. How do full, incremental and transaction-log chains fail?

An incremental depends on an earlier full or incremental ancestor. A transaction log depends on the correct base and every required range in sequence. One missing or misidentified object breaks later recovery even when all later files have valid checksums.

Use a manifest graph with source/system identity, parent identifier, sequence range, timestamps, checksums, size, format, retention and key reference. Verify ancestry and continuity automatically. Retention must preserve the whole chain for every promised recovery point; retaining a final incremental while expiring its base retains unusable bytes.

### 7. What do immutable and offline copies protect against?

They reduce the chance that compromised production credentials, malicious automation or ransomware can alter or delete every copy. Immutability blocks change for a governed retention window. Offline or logically isolated copies remove normal online access paths. Separate administrative ownership adds another boundary.

They do not prove coverage, consistency, correctness, confidentiality, key availability or restore time. An immutable incomplete backup remains incomplete. Test protected copies through an authorized restore path and test emergency access without weakening their normal protection.

### 8. Why restore in isolation?

Isolation protects existing production and third parties from an unvalidated recovery. Restored workers could send emails, charge cards, publish messages, update DNS or call partner APIs using historical state. A wrong target could overwrite current data. A cyber incident could spread from restored compromise.

Use a separate account/project or equivalent local boundary, restricted network, synthetic endpoints, constrained identities, production-host refusal and explicit target allowlists. Isolation also permits destructive consistency tests and security inspection before anything receives user traffic.

### 9. What proves a restore beyond "the database started"?

Use a ladder:

1. expected artifacts and complete lineage;
2. integrity/hash verification;
3. successful engine recovery;
4. schema, extension and configuration compatibility;
5. business invariants and reconciliation;
6. authentication, authorization and prohibited-action checks;
7. dependent services and complete user journeys;
8. capacity, monitoring, backup and operator readiness.

Each step supports a larger claim. A database start proves the engine could open the restored state. It does not prove a customer can safely complete an order once.

### 10. Why do encryption keys, identities and certificates belong in DR?

Encrypted copies require keys; automation requires identities; TLS and signed messages require certificates. These are control-plane dependencies. If they exist only inside the failed or compromised boundary, the data and infrastructure may be present but unusable.

Maintain a separately governed recovery path with least privilege, auditing, rotation compatibility and break-glass approval. Test access by decrypting a bounded synthetic artifact or using an equivalent non-secret proof. Never print key material into logs or embed a universal recovery credential in a runbook.

### 11. How should Kubernetes and etcd recovery be approached?

Treat Git-managed workload definitions, cluster control state, persistent application data, cloud/load-balancer state, identity and secrets as separate assets. etcd holds Kubernetes control-plane state; its snapshots require correct revision and cluster recovery procedures. Restoring etcd does not restore external databases or object stores, and reapplying Git does not reconstruct every dynamically created stateful object.

Inventory what is authoritative. Back up etcd according to the distribution's supported process, retain required certificates and configuration, and rehearse in an isolated cluster with compatible versions. Validate API objects, controllers, storage attachments, networking, DNS, secrets and application flows. Never experiment with control-plane restore against a live production cluster.

### 12. What is writer fencing and how do you prove it?

Fencing removes an old writer's authority before another writer is promoted. Mechanisms include revoking a lease or credential, removing the member from quorum, isolating its network, detaching writable storage or enforcing an epoch/token that rejects stale writers.

Proof must be independent of the unhealthy node's own statement. Attempt a harmless synthetic write through the old path and observe rejection at the authority boundary; inspect lease/quorum/token state from a healthy control point; then record timestamp and evidence. Process shutdown alone is weak because a partitioned process can return.

### 13. Why is DNS change not the same as failover?

DNS changes name-to-address guidance. Resolvers cache values, TTL behavior varies, long-lived connections remain, and some clients retry old addresses. DNS neither chooses the correct recovery point nor fences old writes.

A safe failover separately establishes data authority, validates the alternate, blocks the old writer and then moves traffic. Observe requests at both sites, connection counts, errors and business writes until convergence. Maintain a rollback or stop strategy that does not recreate two writers.

### 14. Why must failback be designed and tested?

After recovery, the alternate may contain new authoritative writes while the original contains stale or divergent state. Returning without reconciliation can lose, duplicate or reorder business actions and can reintroduce the original defect.

Treat failback as a fresh migration: decide why return is valuable, rebuild from current truth, reconcile external/deferred effects, validate, fence at a new boundary, stage traffic and preserve rollback. Re-establish backups immediately for whichever site is authoritative.

### 15. How do you select a DR strategy?

Begin with business impact, critical flow, RPO/RTO, consistency, threat model, failure boundaries and cost. Map every state and dependency. Then choose mechanisms by role: local/multi-zone redundancy for ordinary availability; independently retained backups and PITR for historical recovery; infrastructure as code for reproducible compute/network configuration; pilot light or warm standby for tighter time; active/active only when conflict and authority semantics justify its complexity.

Estimate transfer, replay, provisioning, validation and traffic time from measurements. Test the complete flow. If the design misses the objective, change architecture, capacity or the honestly approved objective—never the measurement.

### 16. What should a disaster-recovery evidence package contain?

Include scope and critical flow, approved objectives, incident boundary, architecture/state map, chosen manifest and lineage, approvals, identities and tool versions, timestamped actions, integrity and invariant results, key/credential checks, fencing proof, traffic observations, actual RPO/RTO calculation, communications, aborts, reconciliation, residual uncertainty, cleanup and corrective actions with owners and dates.

Evidence must let a reviewer reconstruct what happened without trusting memory. Redact secrets and sensitive records, retain evidence outside the failed boundary, and distinguish direct observation from inference.

## Product-company interview

### Scenario 1: every backup dashboard is green, but no restore has run for a year

**Weak answer:** Check storage usage and perform a restore when time permits.

**Senior answer:** Green producer status proves only that jobs reported success. I first identify critical flows and approved RPO/RTO, then inspect scope, manifests, chain continuity, protected-copy boundary, key access and retention. I schedule a bounded isolated restore using the exact production procedure, validate engine and business/security invariants, measure end-to-end recovery and record limitations. Until that passes, I report backup creation as observed but recoverability as unproved. I also add restore-test age and newest-valid-point age as monitored controls.

### Scenario 2: a primary region is unavailable and leadership demands immediate DNS change

**Senior answer:** I separate traffic routing from data authority. I confirm the incident boundary, critical-flow objective, alternate freshness, capacity, key/config readiness and dependency health. Before promotion, I fence the old writer through an independent control and prove old-path writes fail. I validate the alternate, then stage routing with error, latency, saturation, backlog and business-invariant aborts. DNS may be one routing mechanism, but I measure actual convergence. I communicate expected and actual loss rather than claiming zero loss without evidence.

### Scenario 3: ransomware may have compromised production and backups

**Senior answer:** I involve security and preserve forensic evidence. I avoid restoring into the compromised trust boundary. We establish clean identities, network and tooling; determine the earliest known compromise and select an older candidate; verify immutability, manifest lineage and keys; scan and restore in isolation; rotate affected credentials; and validate business and security behavior. A clean recovery can take longer than ordinary DR, so I communicate objective risk and approved degraded operations. We do not reconnect until security says clean and domain owners say correct.

### Scenario 4: the service has a 15-minute RPO and 60-minute RTO, but the drill loses 22 minutes and takes 94

**Senior answer:** I report both misses exactly; I do not redefine the boundary. I decompose time into detection/decision, provisioning, transfer, replay, validation and traffic, and identify why the newest valid point was 22 minutes old. Immediate risk handling may include more frequent/log-based capture, fixed chain alerts, pre-positioned capacity or a degraded flow. Long-term choices are architecture/capacity changes or formally revisiting objectives with business impact and cost. The drill succeeded at finding a gap; the system did not meet its objective.

### Scenario 5: after failover, both regions appear to have accepted writes

**Senior answer:** This is a possible split-brain correctness incident. I stop or restrict writes to prevent further divergence, preserve both histories, establish authority using the system's consistency protocol and involve the data/domain owner. We identify common boundary and conflicting operations, reconcile with domain-specific rules, test invariants and communicate uncertainty. We do not merge by timestamp blindly. Prevention is independent fencing, epochs/leases or quorum, old-path negative-write tests and staged traffic.

### Scenario 6: design DR for a Kubernetes platform with a database, queue and object store

**Senior answer:** I start from the critical user flow and map cluster control state, workload definitions, database authority, object data, queued/in-flight work, identities, certificates, DNS, observability and third parties. I assign HA, independent backup/PITR, replay or rebuild mechanisms to each. Git rebuilds declared configuration but not every state. Recovery infrastructure and keys sit outside the primary failure boundary. Scheduled isolated exercises restore components in dependency order, prove message idempotency and object/database invariants, measure complete-flow RPO/RTO, fence writers before traffic and test failback. Strategy and cost are tiered by business impact.

### What interviewers are evaluating

Strong answers:

- begin with users, objectives and failure boundaries;
- distinguish availability, replication, backup, restore and continuity;
- make state authority and writer safety explicit;
- demand evidence and state its limits;
- include security, identity, dependencies, capacity and cost;
- quantify actual outcomes without hiding misses;
- show communication, stop authority, reconciliation and learning.

Naming many vendor services without these decisions is tool familiarity, not recovery engineering.

## Independent transfer and rubric

### Reviewer-owned challenge

On reviewer-owned disposable local infrastructure with synthetic identities and data, design and execute an unfamiliar end-to-end recovery exercise for a multi-component service. The reviewer secretly injects:

- one backup-chain defect;
- one shared failure-domain or credential dependency;
- one misleading green status;
- one application-correctness failure;
- one unsafe failover or failback condition.

Do not use production, public targets, real credentials, customer data, external cloud resources or uncontrolled faults. The reviewer owns fault details, expected boundaries, stop authority and cleanup confirmation. The learner owns investigation and evidence. No solution is provided here.

### Required evidence

Submit:

1. business impact, critical flow, disaster threshold, approved RTO/RPO and correctness contract;
2. architecture, state-owner, dependency, failure-domain and recovery-authority map;
3. versioned strategy separating HA, replication, backup/PITR, rebuild and degraded operation;
4. inventory binding every recovery object to source, time, manifest, hash, retention, ancestry, protection and key dependency;
5. safety plan covering isolation, synthetic data, blast radius, abort, rollback, communication and cleanup;
6. recovery readiness for capacity, quota, configuration, artifact, identity, certificate, route, monitoring and third parties;
7. timestamped execution from disaster boundary through complete-flow validation;
8. evidence detecting and safely handling all injected conditions;
9. engine, business, authorization and prohibited-behavior results;
10. actual RPO and RTO calculated from preserved timestamps;
11. authorized failover with fencing, staged routing, stops and communication;
12. failback/reconciliation covering divergence, authority, rebuild, validation and rollback;
13. soak, residual risk, finding owner, retest and exact cleanup proof.

Unknown artifacts, ambiguous ownership or unsafe cleanup must cause refusal. Targets are defined before the run and remain unchanged after a miss. Residual uncertainty stays visible.

### Scoring rubric

| Criterion | Points | Observable evidence |
|---|---:|---|
| business contract and scope | 10 | flow, impact, threshold, objectives, correctness and safety |
| architecture and ownership | 10 | state, dependencies, failures, authority and shared boundaries |
| recovery strategy | 10 | distinct HA, replication, backup/PITR, rebuild and degraded roles |
| backup chain and security | 10 | identity, lineage, freshness, retention, isolation, encryption and keys |
| restore execution | 10 | isolated reproducible recovery and safe defect handling |
| correctness validation | 10 | engine, business, authorization, negative-security and flow behavior |
| RPO and RTO evidence | 10 | honest loss and duration calculated from timestamps |
| failover safety | 10 | authority, fencing, routing stages, aborts and communication |
| failback and continuity | 10 | divergence, reconciliation, third parties and rollback |
| soak, learning and cleanup | 10 | observation, owned gaps, retest and proven absence |

Mastery requires reviewer-observed evidence, 80/100 or higher, no safety-gate failure, and no zero in business contract, backup security, correctness, failover safety or cleanup. A written claim without its artifact receives no evidence credit.

## References and review

### Primary sources

- **REF-0868** — [NIST SP 800-34 Rev. 1: Contingency Planning Guide for Federal Information Systems](https://csrc.nist.gov/pubs/sp/800/34/r1/upd1/final). Used for contingency-policy, business-impact, recovery-strategy, testing and maintenance structure.
- **REF-0869** — [NIST SP 800-184: Guide for Cybersecurity Event Recovery](https://csrc.nist.gov/pubs/sp/800/184/final). Used for recovery planning, playbooks, improvement and cyber-event context.
- **REF-0870** — [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework). Used for governance and Recover-function framing.
- **REF-0871** — [CISA StopRansomware Guide](https://www.cisa.gov/resources-tools/resources/stopransomware-guide). Used for protected/offline backups and ransomware-response cautions.
- **REF-0872** — [AWS Well-Architected Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html). Used for reliability principles, recovery design and testing context.
- **REF-0873** — [AWS: Back up data](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/back-up-data.html). Used for backup scope, automation and restoration-testing guidance.
- **REF-0874** — [AWS REL 13: How do you plan for disaster recovery?](https://docs.aws.amazon.com/wellarchitected/latest/framework/rel-13.html). Used for DR strategy and recovery-objective considerations.
- **REF-0875** — [Azure Well-Architected reliability metrics](https://learn.microsoft.com/en-us/azure/well-architected/reliability/metrics). Used for RTO/RPO and reliability measurement context.
- **REF-0876** — [Azure Well-Architected disaster recovery](https://learn.microsoft.com/en-us/azure/well-architected/reliability/disaster-recovery). Used for business-aligned recovery, drills and failover/failback considerations.
- **REF-0877** — [Google Cloud disaster recovery planning guide](https://docs.cloud.google.com/architecture/dr-scenarios-planning-guide). Used for strategy tiers, dependencies and cost/complexity trade-offs.
- **REF-0878** — [Google Cloud: test recovery from failures](https://docs.cloud.google.com/architecture/framework/reliability/perform-testing-for-recovery-from-failures). Used for exercises and recovery validation.
- **REF-0879** — [PostgreSQL backup and restore](https://www.postgresql.org/docs/current/backup.html). Used for logical, file-system and continuous-archiving distinctions.
- **REF-0880** — [PostgreSQL continuous archiving and PITR](https://www.postgresql.org/docs/current/continuous-archiving.html). Used for base-backup, WAL-chain and point-in-time mechanics.
- **REF-0881** — [Kubernetes: operating etcd clusters](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/). Used for etcd backup and cluster-administration context.
- **REF-0882** — [etcd disaster recovery](https://etcd.io/docs/v3.7/op-guide/recovery/). Used for snapshot integrity and recovery behavior.

### Review method and limitations

All 15 references are first-party government, project or provider documentation and were locked for this lesson on 2026-08-07. Claims were triangulated where the concept is provider-neutral; PostgreSQL, Kubernetes and etcd details remain scoped to those technologies.

Provider terminology, product behavior and documentation can change. Review after 2027-02-07 or earlier when tooling, architecture or cited guidance changes. This lesson explains engineering decisions; it does not replace an organization's legal, regulatory, security, data-retention or business-continuity authority.

The local lab is deliberately a reasoning model. It proves refusal order, deterministic classification and cleanup boundaries for its fixtures. It does not prove real storage performance, a real backup chain, production capacity, organizational readiness or mastery. Only reviewed evidence from a separate bounded exercise can support those claims.
