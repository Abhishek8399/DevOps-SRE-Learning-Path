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
