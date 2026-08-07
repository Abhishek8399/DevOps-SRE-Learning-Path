---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0078",
  "slug": "ceph-storage-reliability-operations",
  "aliases": ["V09-L03", "ceph-storage-reliability-operations"],
  "curriculumIds": ["PRV-003"],
  "route": "/book/privatecloud/ceph-storage-reliability-operations",
  "order": 3,
  "volume": "09-private-cloud",
  "title": "Ceph operations: prove placement, durability, recovery, and client I/O",
  "summary": "Trace one client object through maps, pools, placement groups, CRUSH, primary and replica or erasure shards, BlueStore, acknowledgement, degradation, peering, recovery, scrub, capacity, upgrade, OpenStack RBD integration and user/data proof.",
  "domain": "private-cloud",
  "level": {"from": "advanced", "to": "expert"},
  "estimatedMinutes": 600,
  "prerequisiteLessonIds": ["LES-0010", "LES-0058", "LES-0074", "LES-0077"],
  "prerequisiteCurriculumIds": ["LNX-006", "NET-007", "DST-005", "PRV-002"],
  "testedEnvironments": [
    {"platform":"Official documentation","version":"Ceph latest development documentation reviewed 2026-08-07","support":"concept-only","notes":"Latest pages explicitly describe a development branch and do not prove a deployed release."},
    {"platform":"Ubuntu","version":"24.04 WSL UID-1000 guarded lifecycle","support":"required","notes":"All 56 cases, exported-authority refusal, root refusal, unknown-artifact refusal and exact cleanup pass with zero cluster calls."},
    {"platform":"Python","version":"3 standard library","support":"required","notes":"Deterministic 56-case, 55-gate request, placement, durability and recovery evidence model."},
    {"platform":"Ceph runtime","version":"not present in the tested boundary","support":"unsupported","notes":"No package, daemon, cluster, keyring, pool, object, PG, OSD, RBD image, I/O, fault, recovery or upgrade is authorized."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "private-cloud-engineer", "storage-engineer", "openstack-engineer", "infrastructure-engineer", "cloud-engineer", "security-engineer", "technical-lead", "architect"],
  "learningObjectives": [
    "Trace a client read or write from identity and cluster-map epoch through pool, object, placement group, CRUSH rule, acting primary, replica or erasure shards, BlueStore and acknowledgement.",
    "Separate monitor quorum and map authority, manager visibility, OSD liveness/membership, PG availability/cleanliness and client correctness.",
    "Explain object-to-PG and PG-to-OSD indirection, up and acting sets, primary authority, peering, epochs and recovery.",
    "Design CRUSH topology and rules that match physical power, network, host, rack and site failure domains.",
    "Compare replicated and erasure-coded pools using raw-capacity, write-amplification, failure-tolerance, recovery and workload constraints.",
    "Diagnose degraded, undersized, inactive, stale, inconsistent, recovery, backfill, remapped and unfound PG states without guessing from one health string.",
    "Distinguish OSD up/down from in/out and remove or replace an OSD only after safety, reserve and data-movement proof.",
    "Reason about nearfull, backfillfull and full ratios, uneven placement, PG autoscaling, headroom and failure reserve.",
    "Locate slow client I/O across map acquisition, network, primary queue, media, replication, recovery contention and client integration.",
    "Protect cephx identities, keyrings, capabilities, management authority, data in transit/at rest and tenant boundaries.",
    "Operate RBD with Nova, Glance and Cinder while preserving image, volume, lock, watcher, writer and data ownership.",
    "Plan release-aware canary upgrades, scrubbing, repair, backup of control identity, disaster recovery and exact cleanup."
  ],
  "productionSignals": [
    "user operation client identity cephx entity capabilities cluster FSID release and configuration source",
    "monitor quorum members leader election epoch clock skew map availability and store health",
    "manager active standby modules telemetry freshness orchestrator state and dashboard limitation",
    "OSD ID host device class up down in out weight reweight utilization latency heartbeat and release",
    "pool ID application type replicated or erasure profile size min_size CRUSH rule PG autoscale mode and quota",
    "object namespace ID size version digest and client request identity without exposing tenant data",
    "PG ID epoch state components up set acting set primary last acting interval and blocked-by evidence",
    "CRUSH root hierarchy bucket type physical failure domain rule device class choose result and map epoch",
    "replica or K+M shard location acknowledgement version and durable-media evidence",
    "BlueStore block DB WAL RocksDB device health space fragmentation and commit latency",
    "client map age connection primary op queue commit/apply latency timeout retry and final result",
    "network public/cluster path loss latency MTU congestion and bidirectional flow",
    "recovery/backfill objects bytes rate reservations priority queue age and client-SLI contention",
    "scrub/deep-scrub schedule backlog inconsistency object repair decision and post-repair proof",
    "raw used available MAX AVAIL per-pool amplification nearfull backfillfull full ratio and failure reserve",
    "RBD pool image snapshot clone parent lock watcher client host OpenStack resource and writer authority",
    "upgrade daemon versions minimum client/OSD release health warnings canary pause and rollback boundary",
    "user I/O latency error data invariant recovery point cleanup orphan and residual risk"
  ],
  "diagrams": [
    {"id":"LES-0078-DIA-001","title":"Ceph client write and acknowledgement path","direction":"left-to-right","boundaries":["client and cephx","monitor and map","pool and object","PG and CRUSH","primary OSD","replica or erasure shards","BlueStore media","client and user"],"evidencePoints":["identity","epoch","pool/object","PG","acting set","commit","durability","user result"],"textAlternative":"The client gets maps, computes a PG and acting set, sends to the primary, and receives success only through pool-specific replica or shard acknowledgement semantics."},
    {"id":"LES-0078-DIA-002","title":"Maps, epochs and state ownership","direction":"hierarchical","boundaries":["monitor quorum","monitor map","OSD map","PG map","CRUSH map","manager view","clients and OSDs"],"evidencePoints":["quorum","epoch","membership","PG state","topology","freshness","map age"],"textAlternative":"Monitor quorum owns authoritative maps while managers expose operational views and clients or OSDs act on epoch-bound copies."},
    {"id":"LES-0078-DIA-003","title":"Object to PG to OSD placement","direction":"left-to-right","boundaries":["pool and object ID","object hash","PG ID","CRUSH rule","failure-domain buckets","up set","acting set and primary"],"evidencePoints":["pool ID","hash","PG","rule","bucket","up","acting"],"textAlternative":"Object identity maps to a placement group, then the CRUSH rule and topology compute an OSD set with an acting primary."},
    {"id":"LES-0078-DIA-004","title":"Degradation, peering and recovery state machine","direction":"cyclic","boundaries":["failure detected","new map epoch","peering","active degraded","recovery or backfill","clean","scrub and validation"],"evidencePoints":["heartbeat","epoch","acting history","availability","progress","cleanliness","integrity"],"textAlternative":"Failure changes membership and epochs; PGs peer before serving, recover or backfill missing data, then require clean and integrity evidence."},
    {"id":"LES-0078-DIA-005","title":"Capacity and failure-domain reserve","direction":"hierarchical","boundaries":["raw devices","CRUSH-eligible raw","replication or K+M amplification","uneven OSD fullness","full thresholds","largest failure","movement reserve","usable client capacity"],"evidencePoints":["raw","eligible","rate","MAX AVAIL","ratio","survivors","headroom","admission"],"textAlternative":"Usable capacity is bounded by eligible topology, protection overhead, the fullest OSD, thresholds, declared failure and movement reserve rather than raw total."},
    {"id":"LES-0078-DIA-006","title":"RBD and OpenStack ownership path","direction":"left-to-right","boundaries":["OpenStack request","Glance Nova or Cinder","librbd or QEMU","RBD image and lock","RADOS objects and PGs","OSDs and media","guest application and user"],"evidencePoints":["request UUID","service identity","client","image","object","commit","guest I/O","data invariant"],"textAlternative":"OpenStack owns resource intent while Ceph client, RBD, RADOS and OSD layers own storage realization; guest and user correctness remain later boundaries."}
  ],
  "commands": [
    {"id":"LES-0078-CMD-001","question":"Is this a guarded no-cluster shell?","risk":"read-only","command":"bash lab.sh doctor","runFrom":"LES-0078 support/lab as a normal Ubuntu user","expectedBranches":[{"when":"doctor=pass","meaning":"source and authority guards pass","nextEvidence":"inventory-tools"},{"when":"lab=fail","meaning":"a named guard failed","nextEvidence":"correct without bypass"}],"proves":"planned local model prerequisites","doesNotProve":"Ceph availability"},
    {"id":"LES-0078-CMD-002","question":"Which storage tools are merely present?","risk":"read-only","command":"bash lab.sh inventory-tools","runFrom":"LES-0078 support/lab","expectedBranches":[{"when":"inventory=observed","meaning":"environment and command presence are reported without invocation","nextEvidence":"retain no-cluster limit"}],"proves":"planned command discovery","doesNotProve":"cluster identity or health"},
    {"id":"LES-0078-CMD-003","question":"Can bounded synthetic state initialize?","risk":"mutating-bounded","command":"bash lab.sh setup","runFrom":"LES-0078 support/lab","expectedBranches":[{"when":"setup=pass","meaning":"one UID-scoped fixture exists","nextEvidence":"status"},{"when":"refusal","meaning":"authority or state is unsafe","nextEvidence":"preserve first error"}],"proves":"planned bounded initialization","doesNotProve":"pool or object creation","cleanup":"Run bash lab.sh cleanup."},
    {"id":"LES-0078-CMD-004","question":"Are all reviewed cases loaded?","risk":"read-only","command":"bash lab.sh status","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"expected case count","meaning":"intended fixture is active","nextEvidence":"show baseline"},{"when":"other count","meaning":"fixture drift","nextEvidence":"stop"}],"proves":"planned fixture identity","doesNotProve":"Ceph coverage"},
    {"id":"LES-0078-CMD-005","question":"Which synthetic claims create the baseline?","risk":"read-only","command":"bash lab.sh show baseline","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"merged JSON prints","meaning":"model inputs are inspectable","nextEvidence":"evaluate baseline"}],"proves":"planned synthetic inputs","doesNotProve":"daemon or media truth"},
    {"id":"LES-0078-CMD-006","question":"Does the baseline cross every evidence gate?","risk":"read-only","command":"bash lab.sh evaluate baseline","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=operable-within-model","meaning":"all encoded predicates pass","nextEvidence":"compare failures"}],"proves":"planned deterministic decision","doesNotProve":"client I/O"},
    {"id":"LES-0078-CMD-007","question":"Can quorum exist with stale client maps?","risk":"read-only","command":"bash lab.sh evaluate stale-client-map","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=client-map","meaning":"authority exists but client placement knowledge is stale","nextEvidence":"FSID epoch and map acquisition"}],"proves":"planned map boundary","doesNotProve":"monitor behavior"},
    {"id":"LES-0078-CMD-008","question":"Can replicas share one rack failure?","risk":"read-only","command":"bash lab.sh evaluate crush-correlated-domain","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=crush-failure-domain","meaning":"nominal copies do not survive the declared failure","nextEvidence":"physical topology rule and simulated placement"}],"proves":"planned topology boundary","doesNotProve":"real durability"},
    {"id":"LES-0078-CMD-009","question":"Can a PG be active but not clean?","risk":"read-only","command":"bash lab.sh evaluate active-degraded","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=pg-cleanliness","meaning":"I/O availability and redundancy restoration differ","nextEvidence":"acting set missing objects recovery progress"}],"proves":"planned PG-state boundary","doesNotProve":"object safety"},
    {"id":"LES-0078-CMD-010","question":"Can raw free space still block writes?","risk":"read-only","command":"bash lab.sh evaluate fullest-osd-at-full-ratio","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=fullness-admission","meaning":"the limiting eligible OSD and threshold govern admission","nextEvidence":"MAX AVAIL distribution and reserve"}],"proves":"planned fullness boundary","doesNotProve":"cluster capacity"},
    {"id":"LES-0078-CMD-011","question":"Can recovery finish while user latency fails?","risk":"read-only","command":"bash lab.sh evaluate clean-user-slo-failed","runFrom":"LES-0078 support/lab after setup","expectedBranches":[{"when":"boundary=user-io","meaning":"clean PG state is insufficient user evidence","nextEvidence":"client latency errors and data invariant"}],"proves":"planned outcome boundary","doesNotProve":"workload correctness"},
    {"id":"LES-0078-CMD-012","question":"Do all decisions and cleanup pass with zero cluster calls?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0078 support/lab from absent state","expectedBranches":[{"when":"verify=pass","meaning":"cases refusal and cleanup pass","nextEvidence":"retain model-only limit"},{"when":"failure","meaning":"candidate evidence rejected","nextEvidence":"preserve first failure"}],"proves":"planned offline lifecycle","doesNotProve":"Ceph daemons storage data or recovery","cleanup":"Verifier must prove exact UID-scoped state absence."}
  ],
  "labs": [
    {"id":"LES-0078-LAB-001","title":"Guided Ceph placement and recovery evidence model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash and Python 3; no Ceph authority","timeMinutes":240,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped temporary root","one copied synthetic fixture"],"abortConditions":["root","Ceph keyring or configuration authority","cluster endpoint","cloud cluster Docker or libvirt context","symlink","wrong owner","unknown artifact"],"recovery":"Preserve first failure and remove only exact allowlisted state.","cleanupProof":"Exact inventory followed by state-root absence.","path":"drafts/LES-0078-ceph-storage-reliability-operations/support/lab"},
    {"id":"LES-0078-LAB-002","title":"Independent disposable Ceph degradation and recovery","mode":"independent","environment":"Reviewer-owned disposable Ceph deployment or faithful isolated harness with synthetic data","timeMinutes":240,"privilege":"least privilege; reviewer owns hidden faults and stop authority","network":"isolated local only","changes":["one bounded synthetic client dataset","reviewer-controlled map pool PG OSD capacity network recovery scrub RBD or upgrade defect"],"abortConditions":["production","public target","external cloud","real credential","customer data","unbounded I/O","destructive repair","unknown authority or cleanup"],"recovery":"Stop, preserve evidence, restore one authoritative disposable path and prove exact absence.","cleanupProof":"Reviewer proves every object pool image client mapping key and temporary artifact absent or intentionally retained.","path":"drafts/LES-0078-ceph-storage-reliability-operations/support/lab"}
  ],
  "incidents": [
    {"id":"LES-0078-INC-001","signal":"Cluster reports HEALTH_WARN with degraded or undersized PGs.","firstThought":"Client availability, redundancy, recovery progress and data integrity are distinct.","safePath":"Bind affected pool/PG/object, epoch, up/acting set and failure domain before action.","trap":"Mark OSDs out or force repair blindly."},
    {"id":"LES-0078-INC-002","signal":"Writes stop although aggregate raw capacity appears available.","firstThought":"The fullest eligible OSD, pool amplification and full thresholds govern admission.","safePath":"Trace pool CRUSH eligibility, MAX AVAIL, OSD distribution, ratios and failure reserve.","trap":"Lower full ratios or reweight randomly."},
    {"id":"LES-0078-INC-003","signal":"Client latency spikes during recovery or backfill.","firstThought":"Correctness work and foreground I/O compete for media, CPU and network.","safePath":"Measure queues, recovery progress and user SLI, then apply bounded release-specific controls.","trap":"Disable recovery indefinitely or tune copied values."},
    {"id":"LES-0078-INC-004","signal":"PG remains inactive, stale, peering, inconsistent or has unfound objects.","firstThought":"The PG state components describe different authority, history and data-risk boundaries.","safePath":"Preserve maps/logs, identify authoritative acting history and use supported diagnosis with data-owner approval.","trap":"Use lost-revert, mark-unfound-lost or repair without consequence review."},
    {"id":"LES-0078-INC-005","signal":"OpenStack volume or image exists but guest I/O fails after change.","firstThought":"OpenStack record, RBD identity/lock/watcher, RADOS placement, OSD commit and guest data are separate.","safePath":"Correlate OpenStack UUID, Ceph client/entity, pool/image/object/PG, writer authority and user data.","trap":"Break locks, flatten/delete images or restart every service."}
  ],
  "assessmentIds": ["ASM-0217", "ASM-0218", "ASM-0219"],
  "referenceIds": ["REF-0928", "REF-0929", "REF-0930", "REF-0931", "REF-0932", "REF-0933", "REF-0934", "REF-0935", "REF-0936", "REF-0937", "REF-0938", "REF-0939", "REF-0940", "REF-0941", "REF-0942"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-07",
  "reviewAfter": "2027-02-07",
  "limitations": [
    "The offline lab is a deterministic evidence model, not a Ceph deployment; assessments and manuscript remain pending.",
    "No Ceph package, daemon, cluster, keyring, pool, object, PG, CRUSH change, OSD, RBD image, I/O, fault, recovery or upgrade is authorized.",
    "Latest Ceph documentation explicitly describes a development branch; exact deployed release and compatibility remain unproved.",
    "Ceph behavior depends on release, deployment tooling, hardware, network, CRUSH topology, pool policy, clients and workload.",
    "Formal technical/security/instructional review, representative disposable runtime, reviewer-owned transfer, delayed recall, publication and learner evidence remain required."
  ]
}
---

# Ceph operations: prove placement, durability, recovery, and client I/O
