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

## What you see and first thought

### The sentence that should slow you down

“Ceph is HEALTH_OK” is useful, but it is not the finish line.

It means the health-check system found no currently reported condition severe enough to change that summary. It does not prove that your client is connected to the intended cluster, that its map is current, that the chosen pool protects data across real failure domains, that every object is readable, that latency meets the user SLO, that an RBD volume has only one writer, or that you can restore after disaster.

Likewise, `active+clean` is a placement-group claim. It is stronger than a green dashboard tile, but it still does not prove application semantics. Your first thought should be:

> Which client operation failed, which cluster and object does it concern, which map epoch and placement group own it, where should its replicas or shards be, and what evidence proves the user's data?

### The ladder to remember

Keep this sequence:

1. **User and data promise** — which read, write, attach, snapshot or restore must work, with what latency and correctness?
2. **Cluster and client identity** — exact FSID, release, configuration source, cephx entity and capabilities.
3. **Map authority** — monitor quorum, clock, current map epochs and the client's copy.
4. **Pool contract** — application, replicated or erasure-coded policy, `size`/`min_size` or K+M, CRUSH rule and PG behavior.
5. **Placement** — object identity to PG, CRUSH hierarchy/rule to up set, peering to acting set and primary.
6. **OSD realization** — daemon up/down, in/out, host/device, BlueStore block/DB/WAL and network.
7. **Write or read result** — primary queue, media operation, replica/shard acknowledgement and object version.
8. **Protection and integrity** — active versus clean, scrub evidence, recovery/backfill and unfound/inconsistent state.
9. **Capacity and performance** — eligible MAX AVAIL, fullest OSD, ratios, reserve and foreground/recovery contention.
10. **Consumer outcome** — RBD/OpenStack linkage, single writer, application I/O, data invariant and cleanup.

If you skip from cluster status to step 10, you are guessing.

### One incident to keep in your head

An OpenStack database volume begins timing out. `ceph -s` would show monitor quorum, some active+degraded PGs, recovery activity and one near-full OSD. Aggregate raw capacity is 28 percent free. The Cinder attachment says attached.

A weak operator increases recovery speed, lowers a fullness threshold, marks the OSD in and breaks the RBD lock. Those actions change data placement and authority before the failed path is understood.

A stronger operator binds:

- OpenStack volume UUID to Ceph pool and RBD image;
- client host and cephx entity to the intended cluster FSID;
- affected object or image range to PGs and map epochs;
- PG up/acting sets to OSD hosts and physical failure domains;
- OSD state to devices, BlueStore and network queues;
- RBD watchers and exclusive lock to one proven writer;
- recovery traffic to the database latency SLO;
- final client writes to a safe data invariant.

The difference is not command knowledge. It is knowing which claim belongs to which authority.

### The promise Ceph actually makes

Ceph distributes objects without a central data-path lookup service. Clients obtain maps, compute placement, contact the appropriate OSD, and the PG primary coordinates other replicas or erasure shards according to the pool contract. This removes a central data-path bottleneck, but it makes identity, current maps, placement policy and failure-domain accuracy essential.

The useful promise is:

> The authorized client can read or durably write the intended data through the intended pool, within the agreed latency and failure assumptions, and recovery does not violate data or writer authority.

### What this lesson can prove

This lesson can teach architecture, evidence order, calculations, safe refusal and incident reasoning. Its Ubuntu lab makes no Ceph call; it evaluates 56 synthetic cases and rejects cluster authority.

It cannot prove real durability, performance, recovery or compatibility. Those require the exact deployed release, topology, devices, workload and a reviewer-owned disposable cluster. Reading cannot award mastery.

## Terms before commands

### RADOS, object and object identifier

**RADOS** is Ceph's distributed object-storage foundation. Higher interfaces such as RBD, CephFS and RGW store their data and metadata as RADOS objects.

An **object** has an identifier, bytes and metadata. A file or block image is generally divided into many objects. “The volume exists” therefore does not mean every underlying object is available or consistent.

### FSID and cluster identity

The **FSID** uniquely identifies a Ceph cluster. Configuration and monitor addresses determine which cluster a client attempts to use. Always bind FSID before interpreting health or changing state; two healthy lab and production clusters can otherwise look dangerously similar.

### Client, daemon and cephx entity

A **client** is software using Ceph, such as QEMU through librbd, an RBD kernel client, RGW or CephFS. A **daemon** is a Ceph service process such as a monitor, manager, OSD or MDS.

A **cephx entity** has a name and capabilities. Authentication proves possession of secret material; capabilities authorize operations against monitor, OSD or manager services. `client.admin` is not a normal application identity.

### Keyring and capability

A **keyring** stores Ceph authentication material. A **capability** limits which service and resources an entity can access. Protect keyrings as secrets, distribute them narrowly and never include key values in tickets or lesson evidence.

Least privilege might constrain a service identity to selected pools and operations. Exact capability syntax is release and application dependent; validate it against the deployed release.

### Monitor and quorum

A **monitor** maintains authoritative cluster maps and participates in consensus. **Quorum** is the voting group able to advance authoritative state.

Quorum availability is essential, but monitors are not the ordinary bulk-data proxy. A healthy quorum does not prove a client has a current map or can reach an OSD.

### Manager

The **manager** collects and exposes operational state and hosts modules such as dashboards, metrics, balancing or orchestration integrations. There is normally an active manager and standbys.

A stale manager view can mislead operators while monitor and OSD state differ. Manager failure and data unavailability are not synonyms.

### OSD, device and BlueStore

An **OSD** is a daemon responsible for objects on storage devices and for replication, recovery, peering participation and client I/O. OSD identity is not the same as a disk path.

**BlueStore** is the storage backend commonly used by OSDs. It uses a main block device and may use separate DB/WAL devices for metadata and write-ahead behavior. An OSD process can run while its device or metadata path is failing.

### up/down and in/out

`up` or `down` describes whether an OSD daemon is currently considered available. `in` or `out` describes whether CRUSH should place data on it.

An OSD can be up/out during maintenance or drain, down/in after unexpected failure, down/out during replacement, or up/in in normal service. Never collapse the two axes.

### Cluster map and epoch

The “cluster map” is a family of epoch-versioned maps including monitor, OSD, PG and CRUSH information. An **epoch** identifies a particular map version.

Clients and OSDs act on map copies. When membership or placement changes, compare epochs. A stale client can make a different placement decision or fail until it receives current state.

### Pool and application tag

A **pool** is a logical object collection with protection and placement settings. Its application association tells Ceph and operators whether it is intended for RBD, CephFS, RGW or another use.

Pool creation is not enough. Protection mode, CRUSH rule, PG strategy, quotas and client capabilities belong to the contract.

### Replicated pool, size and min_size

A **replicated pool** stores multiple complete object copies. `size` is the configured replica count. `min_size` is the minimum number of available replicas required for I/O under relevant degraded conditions.

Lowering `min_size` increases availability only by accepting greater data-risk exposure. It is not a harmless incident switch. With `size=3` and `min_size=1`, a write may be accepted with protection far below the intended three copies.

### Erasure coding, K and M

An **erasure-coded pool** divides an object into K data chunks and M coding chunks. The acting set contains K+M shards. In the ideal code model, data can be reconstructed while enough chunks remain, but actual safety depends on failure independence, plugin/profile, min-size behavior, correlated loss and successful recovery.

Erasure coding reduces raw-capacity overhead compared with multiple full replicas at the cost of CPU, network, read-modify-write or small-I/O behavior, operational constraints and often more expensive recovery.

### CRUSH

**CRUSH** computes placement using a map, hierarchy, rules, weights and object/PG inputs. It avoids a central table containing every object's location.

CRUSH can only honor the topology you describe. If two “rack” buckets share one power source, the logical failure-domain claim is false.

### Device class, weight, reweight and bucket

A **device class** distinguishes media categories such as HDD, SSD or NVMe for placement rules. A CRUSH **weight** represents relative capacity in the hierarchy. Operational **reweight** mechanisms can alter placement preference.

A **bucket** groups devices or other buckets by host, chassis, rack, room or custom topology. Weight changes can move substantial data; never use them as random performance knobs.

### CRUSH rule and failure domain

A **CRUSH rule** tells the algorithm which root/class to select and across which bucket type to distribute replicas or shards. The selected bucket type is the logical **failure domain**.

The real failure domain includes shared power, network, cooling, chassis and operational change. Prove the mapping physically.

### Placement group

A **placement group**, or **PG**, groups objects for placement and recovery. Object identity hashes into a PG; CRUSH maps that PG to OSDs. This indirection lets membership change without tracking a central row for every object.

Too few PGs can create imbalance and limited parallelism. Too many increase memory, peering and management cost. Use release-current autoscaler guidance and workload evidence.

### pg_num, pgp_num and autoscaler

`pg_num` represents the number of PGs in a pool. Placement behavior historically also involved `pgp_num`; modern releases can step placement changes automatically. The **PG autoscaler** recommends or applies PG counts using pool demand and policy.

Changing PG counts can split, merge or remap work and consume resources. “Automatic” does not mean consequence-free.

### Up Set, Acting Set and primary

The **Up Set** is the OSD set CRUSH currently maps for the PG. The **Acting Set** is the OSD set currently responsible for it after peering and temporary history are considered.

The first OSD in the acting set is normally the **primary**. Clients send operations to the primary, which coordinates peers. Up and acting differences are valuable incident evidence.

### Peering

**Peering** is the process by which OSDs responsible for a PG agree on its authoritative history and current state. Peering establishes which copies or shards can safely serve.

A PG stuck peering is an authority/history problem, not simply “a disk is slow.” Preserve map and acting-history evidence.

### PG state components

PG state is composed of words. Common examples:

- `active`: requests may be served;
- `clean`: configured placement is complete;
- `degraded`: some objects lack intended replicas or shards;
- `undersized`: the acting set is smaller than configured;
- `peering`: authority agreement is in progress;
- `remapped`: placement differs from the normal CRUSH result;
- `recovering` or `backfilling`: data movement is occurring;
- `inconsistent`: scrub found disagreement;
- `stale`: expected PG reporting is missing.

Interpret the complete state and exact release documentation.

### Recovery and backfill

**Recovery** reconstructs missing or stale object replicas/shards between relevant OSDs. **Backfill** moves larger PG data sets when placement changes or a destination needs substantial synchronization.

Both protect data but compete with foreground I/O for CPU, network and media. Disabling them indefinitely trades visible latency for growing durability risk.

### Scrub and deep scrub

**Scrub** compares object metadata and replica consistency. **Deep scrub** also checks data content against checksums. They detect classes of latent inconsistency; they do not automatically know which copy matches application truth.

Repair is a data-authority decision. Preserve evidence, backups and acting history before changing inconsistent objects.

### Unfound object

An **unfound** object is required by PG history but no currently known copy is available. “Mark lost” operations explicitly accept data loss or rollback semantics. They are last-resort, data-owner-approved decisions, never routine cleanup.

### nearfull, backfillfull and full

Ceph uses fullness thresholds to protect OSDs and control placement or writes. **nearfull** warns; **backfillfull** can block backfill to a destination; **full** can block writes.

The exact fullest eligible OSD matters. Aggregate cluster free space can remain large while one placement path crosses a threshold.

### Raw capacity, stored data, overhead and MAX AVAIL

**Raw capacity** is device total. User-stored data consumes more raw bytes according to replication or erasure-code amplification plus metadata and operational overhead.

Per-pool **MAX AVAIL** estimates how much more user data can fit under that pool's placement and protection, often limited by the fullest eligible part of the topology. It is more useful than raw free but remains an estimate, not a failure-reserve plan.

### RBD image, object, snapshot and clone

An **RBD image** presents block semantics while storing data across RADOS objects. A snapshot records image state according to RBD semantics; application consistency still needs guest/workload coordination. A clone can depend on a parent until flattened.

Deletion and backup must account for snapshots, clones, parentage and trash/lifecycle state.

### Exclusive lock and watcher

An RBD **watcher** shows a client relationship to an image. **Exclusive lock** coordinates features and write ownership for supporting clients. A stale-looking watcher or lock is evidence, not permission to break it.

Prove the old client is fenced before assigning a new writer.

### Public and cluster networks

The **public network** carries client and monitor/daemon communication. A separate **cluster network**, when deployed, commonly carries OSD replication, heartbeat or recovery traffic.

Separation can reduce contention but adds paths and failure modes. Exact behavior is configuration and release dependent; trace both directions and MTU.

### Acknowledgement, commit and application durability

A successful client acknowledgement follows the pool and implementation's completed operation semantics. It is stronger than “the primary received the request,” but it does not by itself prove application-level consistency, backup or survival beyond configured failures.

State the durability assumption precisely: which replicas/shards, media and failure domains were involved?

### RBD and OpenStack ownership

Glance may store images in RBD, Cinder may own volume lifecycle, and Nova/QEMU/librbd may use guest disks. OpenStack owns resource intent; Ceph owns storage objects and client authorization; the guest/application owns higher-level data correctness.

Join OpenStack UUIDs to Ceph pool/image, cephx client, watchers/lock, PGs and OSD evidence.

### Rolling upgrade and minimum compatibility

A rolling upgrade mixes daemon versions for a supported interval. Minimum client or OSD release settings can prevent older participants after a compatibility boundary advances.

An upgrade is not finished when images or packages are new. It requires health, compatible maps/protocols, completed daemon rollout, user I/O, recovery/cleanup and a known rollback boundary.

## Architecture map

### View 1: client write and acknowledgement

```text
[application / OpenStack]
          |
          v
[Ceph client + cephx] -> [monitor quorum: maps]
          |
          v
[pool + object] -> [PG] -> [CRUSH/up set]
                              |
                         [acting primary]
                          /    |    \
                         v     v     v
                      OSD A  OSD B  OSD C
                         \ media/shard /
                              |
                     acknowledgement
                              |
                       [user + data]
```

The monitor supplies authoritative maps, not the ordinary object payload. The client computes placement and sends to the acting primary. The primary coordinates required peers. The exact acknowledgement semantics belong to the pool, release and operation.

### View 2: maps, epochs and owners

```text
                 [monitor quorum]
                  /   |   |   \
                 v    v   v    v
              monmap osdmap pgmap crushmap
                         |
                  epoch-versioned copies
                  /         |          \
             [clients]    [OSDs]    [manager]
             placement    peering    operational view
```

Monitor quorum owns map authority. Clients and OSDs use copies at particular epochs. Manager views are operationally valuable but do not replace quorum or direct daemon/client evidence.

### View 3: object to PG to OSD

```text
pool ID + object ID
        |
       hash
        v
      PG ID
        |
  CRUSH rule + map epoch
        |
 root -> class -> rack -> host -> OSD
        |
      Up Set
        |
 peering/history
        |
 Acting Set -> Primary
```

The PG is the indirection layer. When topology changes, CRUSH remaps a bounded portion of PG placement rather than maintaining a central object-location database.

### View 4: failure and recovery loop

```text
OSD/network/device failure
          |
      new map epoch
          |
        peering
          |
 active+degraded or inactive
          |
 recovery / backfill
          |
 active+clean
          |
 scrub + user/data validation
```

`active` answers availability. `clean` answers configured placement completeness. Scrub addresses consistency evidence. User/data validation is still separate.

### View 5: usable capacity

```text
raw device bytes
   - unavailable/ineligible devices
   / replication or K+M amplification
   - metadata and operational overhead
   limited by uneven/fullest eligible OSD
   - largest declared failure
   - recovery/backfill and growth reserve
   = safely admissible client data
```

Raw total is the top of the calculation, never the answer. Pool-specific MAX AVAIL helps, but a safe design further reserves failure, movement and growth.

### View 6: RBD and OpenStack

```text
[OpenStack request + resource UUID]
                  |
       Glance / Cinder / Nova
                  |
       QEMU / librbd client identity
                  |
 RBD pool/image/snapshot/clone/lock/watcher
                  |
        RADOS objects -> PGs -> OSD media
                  |
       guest filesystem/application/user
```

The chain crosses several state owners. A Cinder attachment cannot prove an RBD writer, an OSD commit, a guest filesystem or application correctness.

### Use the six views together

View 1 is the normal write. View 2 explains authority. View 3 explains computed placement. View 4 explains transient and recovered states. View 5 prevents capacity mistakes. View 6 connects infrastructure to the consuming platform.

During an incident, annotate every arrow with identity, time and evidence. The first arrow without expected evidence is your best current boundary, not automatically the root cause.

## Request or state path

### 1. Define the user operation

State an actor, action, object and correctness condition: “The database VM writes transaction X to volume V, receives success within 20 ms, and the committed row remains readable after the declared host failure.”

Record latency percentile, durability assumption, consistency, RPO/RTO and whether retries are safe. A generic “storage slow” alert cannot guide a safe trade-off.

### 2. Bind the cluster and client

Record FSID, exact release, deployment method, configuration source, client library/kernel version, cephx entity and non-secret capabilities. In OpenStack, add service, request UUID, project and volume/image/server UUID.

If FSID or authority is ambiguous, stop. Never allow the convenience of a familiar hostname to select a storage cluster.

### 3. Obtain authoritative maps

The client reaches monitors, authenticates and obtains map state. Prove monitor quorum and clock separately, then compare current authoritative epochs with client/OSD observations.

Quorum can be healthy while the client cannot reach monitors, holds stale maps, lacks capabilities or cannot connect to OSDs.

### 4. Resolve the pool contract

Bind pool name and numeric ID, application tag, replicated or erasure-coded mode, size/min_size or K+M/profile, CRUSH rule, PG autoscale mode and quotas.

This contract defines expected placement and availability/durability behavior. Do not interpret a PG state without it.

### 5. Map the object to a PG

Object identity and pool determine the PG. RBD adds striping and object naming, so a single guest request may touch several objects and PGs.

For an incident, identify a representative affected object/PG without exposing tenant data. A cluster-wide summary can hide one unavailable PG.

### 6. Compute the Up Set

CRUSH uses the current map, rule, device class, hierarchy and weights to select OSDs. Compare logical buckets with physical host/rack/power/network evidence.

Three OSD IDs are not three independent copies when they share the failure being tested.

### 7. Peer and establish the Acting Set

OSDs use PG history and map epochs to determine authoritative copies/shards. The acting set may differ from the current CRUSH up set during recovery or remapping.

Peering must avoid serving divergent history. Preserve past intervals and blocked-by evidence before forcing change.

### 8. Reach the primary

The client contacts the acting primary across the public/client network. Validate address family, route, MTU, loss, latency, connection and authentication.

OSD `up` is a cluster membership observation, not proof that this client path reaches the primary.

### 9. Queue and process the operation

The primary admits the operation into its queues, reads or changes object state, and coordinates peers. CPU, memory, BlueStore/RocksDB, media and network all contribute latency.

Measure queue age and phase-specific latency rather than assuming the disk is slow from total request time.

### 10. Persist replicas or shards

For a replicated write, complete copies must be stored according to current semantics. For erasure coding, data/coding chunks are computed and distributed. The primary coordinates completion.

Bind participating OSDs and devices, not just the primary. A slow or failed peer can dominate acknowledgement latency.

### 11. Acknowledge the client

The client receives success or an error/timeout. A timeout may follow partial completion; blind retry can duplicate higher-level effects even when object writes are individually safe.

Record request identity and application retry semantics. Storage idempotency does not automatically make a transaction idempotent.

### 12. Observe PG protection

After failure, a PG may stay active while degraded. This can preserve service but narrows protection. Recovery/backfill should restore the pool contract using new placement.

Track objects/bytes remaining, rate, ETA uncertainty and which failure reserve remains.

### 13. Validate integrity

Scrub and deep scrub compare replicas/shards and checksums. Inconsistency requires evidence about authoritative history and application consequences.

Do not click “repair” merely because the word sounds safe. Determine which copy or reconstruction should win and what recovery source exists.

### 14. Validate the consumer

For RBD/OpenStack, verify image identity, lock/watchers, client host, guest device, filesystem/application and representative I/O. Check a semantic data invariant after repair.

`active+clean` and a successful block read do not prove a database transaction is correct.

### 15. Reconcile and clean up

Remove only proven stale watchers, mappings, temporary keys, test objects and failed operation residue through supported owners. Confirm OSD membership/weights and PG states match intent.

Recovery is incomplete while hidden data movement, an ambiguous writer or an unexplained orphan remains.

## Failure zoom

### Failure 1: correct command, wrong cluster

The client configuration selects another FSID. Output can look perfectly healthy. Bind FSID and configuration source before every conclusion or mutation.

### Failure 2: cephx authenticates with excessive capabilities

The workload succeeds using broad authority, hiding a least-privilege defect. Correct the service-specific capabilities and rotate exposed material rather than standardizing admin access.

### Failure 3: monitor quorum exists, client map is stale

Authoritative state advances but the client cannot refresh. Compare monitor/client epochs, network and authentication. Restarting OSDs cannot fix a blocked client-to-monitor path.

### Failure 4: manager dashboard is stale

The dashboard shows an older map or missing module data. Cross-check monitor and direct daemon evidence. A manager problem is not automatically a data-path outage.

### Failure 5: replica count masks correlated placement

Three replicas occupy three hosts powered by one rack PDU. CRUSH honors the declared topology; the physical model is false. Redesign buckets/rules and move data only with capacity and risk controls.

### Failure 6: min_size accepts dangerous writes

`size=3` but `min_size=1` permits service with sharply reduced protection under some failures. Raising it during incident can stop I/O; lowering it can accept data risk. Treat it as a reviewed availability/durability policy.

### Failure 7: erasure code tolerates devices, not the actual failure

K+M arithmetic suggests M shard loss, but shards share a host/rack/network or the remaining fragments cannot be read fast enough. Simulate CRUSH placement under real correlated failures.

### Failure 8: PG is active but degraded

Clients may continue while copies/shards are missing. Quantify affected objects, current acting set, another-failure exposure and recovery progress. “Active” is not “fully protected.”

### Failure 9: PG is clean but application is slow

No placement recovery is pending, yet primary queues, media, network, RBD client or application behavior violates latency. Move from cluster-state evidence to the specific I/O path.

### Failure 10: OSD is down and in

The daemon is unavailable but placement still expects it, producing degradation until remapping/recovery policy advances. Determine host/device/network cause and whether temporary recovery or replacement is safer.

### Failure 11: OSD is up and unexpectedly out

The daemon runs, but CRUSH excludes it. This may be deliberate drain, automated behavior or incomplete replacement. Establish change ownership before marking it in.

### Failure 12: BlueStore DB/WAL device fails

The main data device may look healthy while metadata latency/errors destabilize the OSD. Bind block, DB and WAL devices and preserve failure evidence; do not treat OSD ID as a single disk.

### Failure 13: public network works, cluster network fails

Clients reach primaries but replication, heartbeat or recovery is impaired on the deployed topology. Trace both networks, routes, MTU and loss. Exact traffic separation depends on configuration.

### Failure 14: one OSD crosses full ratio

Aggregate raw free remains large, but the fullest eligible OSD blocks writes. Inspect per-pool eligibility, CRUSH distribution, utilization and thresholds. Lowering the threshold number does not create bytes.

### Failure 15: backfill cannot find a destination

Destinations are above backfillfull or lack CRUSH-eligible space. Restore safe headroom or topology; repeatedly marking members out can amplify movement and make the condition worse.

### Failure 16: recovery fixes protection but destroys latency

Recovery consumes media/network/CPU and the user SLO collapses. Bound concurrency using deployed-release semantics, observe both progress and foreground latency, and retain a maximum time-at-risk.

### Failure 17: recovery is disabled indefinitely

Foreground latency looks better while degraded exposure remains. Use a time-bounded, approved pause only when necessary, with explicit restart and escalation.

### Failure 18: PG is stuck peering

Participants cannot agree on authoritative history due to unavailable OSDs, incomplete maps or divergent intervals. Preserve acting history and blocked-by evidence. Forcing creation or loss can destroy the only current copy.

### Failure 19: scrub reports inconsistency

Metadata or data copies disagree. Identify affected objects, PG history, device errors and possible application truth. Repair chooses/reconstructs state and requires consequence review.

### Failure 20: objects are unfound

History says objects should exist but no known current location has them. Search missing OSD/history and recovery sources. Marking them lost is explicit data-loss acceptance.

### Failure 21: PG count change causes movement storm

Autoscaler or manual change splits/merges/remaps PGs, increasing backfill and peering cost. Stage changes, model target ratios and protect headroom/user SLO.

### Failure 22: RBD lock appears stale

The prior client may be partitioned but still writing. Bind watchers, addresses, OpenStack host and hypervisor state; fence before lock removal.

### Failure 23: Cinder attached, Ceph writer ambiguous

OpenStack control state and RBD effective state disagree. Stop attachment changes, establish one server/host/image authority, fence the old path and reconcile through supported Cinder/RBD workflows.

### Failure 24: upgrade health checks are green but clients fail

Mixed daemon/client versions or advanced compatibility settings reject an older consumer. Record all versions and minimum-release settings; stop at the canary boundary.

### Failure 25: cluster returns clean after recovery but residue remains

Stale keys, RBD mappings, watchers, test images, drained weights or unreviewed flags remain. Exact cleanup and configuration reconciliation are part of closure.

## Internals and state ownership

### Monitors own authoritative maps

Monitor quorum agrees on cluster state and publishes maps. It does not own object bytes or client application truth.

### Managers own operational modules and views

The active manager exposes collected state and modules. A dashboard is a view with freshness and module dependencies, not an authority above monitors or OSDs.

### CRUSH owns deterministic placement policy

CRUSH calculates expected placement from maps and rules. Operators own whether the topology accurately represents physical risk.

### Pools own data-protection contracts

Pool settings define protection, minimum availability, placement and application association. A client cannot override a bad failure-domain design by retrying.

### PGs own placement and recovery units

PG state and acting history organize authority, availability, recovery and scrub at a scalable granularity. One PG's state need not represent the whole pool.

### The acting primary owns operation coordination

The primary orders/co-ordinates client operations for its PG and peers. It does not make a single-device write equivalent to application durability.

### OSDs and BlueStore own object/shard persistence

OSDs perform client, replication and recovery work; BlueStore and devices persist the state. Daemon, metadata device and media health require separate evidence.

### The network owns delivery, loss and delay

Public/client and cluster paths carry different traffic according to configuration. A healthy interface cannot prove end-to-end MTU, routing or congestion.

### cephx owns Ceph authentication and capabilities

cephx proves entity/key possession and authorizes Ceph service operations within capabilities. It does not encrypt all data or extend security beyond the client boundary by itself.

### Scrub owns comparison evidence

Scrub finds certain disagreements. The data owner and recovery procedure decide which state is authoritative and how application correctness is restored.

### Capacity thresholds own admission guardrails

Fullness logic protects OSD operation. Operators own forecasts, balance, reserve and timely remediation before thresholds become outages.

### RBD owns block-image state and coordination

RBD owns image metadata, snapshots/clones and supported locks/watchers. OpenStack owns service resource lifecycle; the guest/application owns filesystem and business state.

### Fencing owns writer transfer

Power, fabric, storage or platform fencing proves an old client cannot keep writing. A timeout or missing heartbeat is not fencing.

### The user journey owns the final verdict

Representative client/application I/O and data invariants determine whether the promised service is restored. Component green states are supporting evidence.

## Evidence table

### Evidence bundles beat screenshots

| Claim | Weak evidence | Stronger evidence | Still does not prove |
|---|---|---|---|
| Correct cluster | familiar monitor name | FSID, config source, release and endpoint set | client authorization or data |
| Client authorized | command returned | cephx entity, safe capability summary and covered operation | correct pool/object |
| Maps available | monitors are running | quorum plus authoritative and client epochs | OSD reachability |
| Pool is safe | size is three | size/min_size or K+M, CRUSH rule and physical-domain simulation | future media integrity |
| Object placement known | OSD tree screenshot | pool/object to PG, epoch, up/acting sets and primary | durable acknowledgement |
| OSD is healthy | up/in | host/device/BlueStore/network/queue/media evidence | every object |
| PG is available | active | exact state components, acting history and client I/O | configured protection |
| PG is protected | clean | pool policy, full acting set and physical independence | application correctness |
| Data is consistent | no current warning | scrub/deep-scrub evidence plus application invariant | every unsampled object |
| Capacity exists | raw free | per-pool eligible MAX AVAIL, distribution, thresholds and failure reserve | future growth |
| Recovery works | objects moving | progress, no stalls, remaining exposure and user-SLI guardrails | final integrity |
| RBD is attached | Cinder says attached | image/lock/watcher/client/host plus fenced writer | guest data correctness |
| Upgrade completed | new packages | all daemon/client versions, compatibility gates, user/data and cleanup | future release behavior |
| Incident recovered | HEALTH_OK | representative I/O, data invariant, protection, cleanup and residual risk | universal resilience |

### Bind identity and time

An evidence packet should safely join FSID, release, client entity, map epoch, pool ID, object or RBD image, PG ID, up/acting sets, primary, OSD/host/device and timestamp. For OpenStack add project, request and volume/image/server UUIDs.

Do not include secret keys or sensitive object content. Use identifiers and redacted capability summaries.

### Proves and does-not-prove

Every command output needs both statements. `ceph -s` might prove the cluster's reported summary at one time. It cannot prove a specific database write or restore. This habit prevents a local green state from becoming an unsupported global claim.

## Command decoders

These commands operate only on local synthetic JSON. They are not a Ceph administration recipe.

### Command 1: doctor

Run `bash lab.sh doctor` as a normal Ubuntu user. It refuses root, Ceph/OpenStack/cloud authority, Docker/Kubernetes/libvirt context, unsafe state and missing Python.

`doctor=pass` proves only the no-cluster lab boundary and model validity.

### Command 2: inventory tools

Run `bash lab.sh inventory-tools`. It reports whether `ceph`, `rados` and `rbd` names are present without invoking them.

Tool presence proves installation discovery, not an FSID, keyring, release or cluster health.

### Command 3: setup

Run `bash lab.sh setup`. It creates one UID-scoped temporary directory with sentinel and fixture.

It creates no pool, object, OSD or RBD image. Use `bash lab.sh cleanup`.

### Command 4: status

Run `bash lab.sh status`. Expected count is 56. Any other count indicates fixture drift and should stop the exercise.

### Command 5: inspect baseline

Run `bash lab.sh show baseline`. Identify the 55 claims before accepting a classification. Each Boolean represents evidence that a real investigation would have to obtain.

### Command 6: evaluate baseline

Run `bash lab.sh evaluate baseline`. Expected boundary is `operable-within-model`.

It proves only all finite predicates are true in the fixture. It proves no storage or data behavior.

### Command 7: stale client map

Run `bash lab.sh evaluate stale-client-map`. Expected boundary is `client-map`.

The lesson is that quorum and authoritative maps can exist while the client cannot use current placement. Next evidence is FSID, client/monitor epochs, connectivity and authentication.

### Command 8: correlated CRUSH domain

Run `bash lab.sh evaluate crush-correlated-domain`. Expected boundary is `crush-failure-domain`.

Nominal copy count is insufficient when physical failures are shared. Next compare hierarchy/rule with rack, power and network topology and simulate placement.

### Command 9: active and degraded

Run `bash lab.sh evaluate active-degraded`. Expected boundary is `pg-cleanliness`.

The model has already passed availability. The failure now concerns restored protection. Next inspect missing replicas/shards, acting set and recovery.

### Command 10: fullest OSD at full ratio

Run `bash lab.sh evaluate fullest-osd-at-full-ratio`. Expected boundary is `fullness-admission`.

Next evidence is pool eligibility, per-OSD distribution, MAX AVAIL and reserve—not aggregate free space.

### Command 11: clean cluster, failed user SLO

Run `bash lab.sh evaluate clean-user-slo-failed`. Expected boundary is `user-io`.

All earlier storage predicates pass. The remaining failure is representative client/application latency, errors or data semantics.

### Command 12: full verifier

From absent state run `bash verify.sh`. Expected output ends:

```text
verify=pass cases=56 refusal=true cleanup=true cluster_calls=none
```

This validates finite decisions and cleanup. It does not invoke a discovered Ceph binary or endpoint.

### About real Ceph commands

Real commands such as status, health detail, quorum, OSD tree/df, pool detail, PG query/map and RBD status can answer useful questions, but exact syntax, fields and risks depend on release and authority. Before use:

1. bind FSID, release, client and configuration;
2. inspect command help for that release;
3. classify read, write, movement, repair or destructive risk;
4. protect keys and tenant data;
5. record time and identities;
6. define abort, rollback and cleanup;
7. prefer read-only evidence first.

Never copy `mark_unfound_lost`, PG repair, OSD purge, pool delete, ratio, CRUSH weight or compatibility-setting changes from a lesson into production.

## Decision path

### Start from the user and data

Name the failed read/write and whether data is unavailable, slow, inconsistent or at risk. Scope cluster, client, pool, image/object, PGs and time. Stop retries or writer changes when outcomes are ambiguous.

### Branch 1: identity and maps

Verify FSID, release, configuration, cephx entity/capabilities, quorum, clock and client map epochs. If these fail, do not interpret placement output from the wrong or stale context.

### Branch 2: pool and protection

Inspect application, replicated/EC policy, size/min_size or K+M, CRUSH rule and PG strategy. Compare policy with required failure survival.

### Branch 3: object and PG

Map the exact object/image to PG. Read complete PG state, up/acting sets, primary, epochs and acting history. Active, clean, inconsistent and unfound answer different questions.

### Branch 4: OSD and path

For participating OSDs, separate up/down, in/out, host/device/BlueStore and public/cluster networks. Locate queue, media or peer acknowledgement latency.

### Branch 5: capacity

Compare raw with CRUSH-eligible capacity, protection amplification, per-pool MAX AVAIL, fullest OSD and nearfull/backfillfull/full. Add declared failure and movement reserve.

### Branch 6: recovery and integrity

Measure recovery/backfill progress and foreground SLI. For inconsistency/unfound state, preserve histories and data-owner authority. Destructive decisions require explicit loss acceptance.

### Branch 7: RBD/OpenStack authority

Join service UUIDs to pool/image, lock/watchers and clients. Fence an old writer before breaking locks or moving attachment authority.

### Branch 8: change and close

Stop incompatible upgrades, restore supported version order, validate client/application I/O and data, then reconcile temporary flags, weights, mappings, keys and objects.

### Compact flow

```text
user/data failure
 -> correct FSID/release/client/caps?
 -> quorum and current maps?
 -> pool/protection/CRUSH physically safe?
 -> object -> PG -> up/acting/primary?
 -> OSD/device/network/queue/media/shard?
 -> eligible capacity and thresholds?
 -> recovery/integrity safe?
 -> RBD/OpenStack single writer?
 -> user I/O and data correct?
 -> exact cleanup and bounded claim?
```

## Guided Ubuntu lab

### Contract and boundary

Use Ubuntu 24.04, Bash and Python 3 as a normal user from the LES-0078 `support/lab` directory. No network or Ceph installation is needed.

Root, Ceph authority, keyring/config variables, external cloud/control contexts, symlinks, wrong ownership and unknown artifacts are refused. Only a UID-scoped `/tmp` fixture is created.

### Step 1: inspect before running

Read `README.md`, `lab.sh`, `verify.sh`, `model.py` and `fixtures/cases.json`. Explain why cases are synthesized from the ordered gate table and why the fixture contains only the all-true baseline.

Confirm cleanup removes exact allowlisted files rather than recursively deleting an uncertain path.

### Step 2: prove the shell boundary

```bash
bash lab.sh doctor
bash lab.sh inventory-tools
```

Expected results report valid 56 cases/55 gates, normal user and zero cluster calls. Abort on any guard failure; do not bypass it.

### Step 3: initialize and inspect

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh show baseline
```

Status must show 56 cases. Assign an owner and real evidence source to every group: identity/maps, pool/CRUSH/PG, OSD/media/network, recovery/capacity, RBD/OpenStack and user outcome.

### Step 4: evaluate the proof boundary

```bash
bash lab.sh evaluate baseline
```

Write:

- “All encoded predicates pass.”
- “No Ceph cluster, media, I/O, durability or recovery was tested.”

Both are required.

### Step 5: compare distinct failures

```bash
bash lab.sh evaluate stale-client-map
bash lab.sh evaluate crush-correlated-domain
bash lab.sh evaluate active-degraded
bash lab.sh evaluate fullest-osd-at-full-ratio
bash lab.sh evaluate clean-user-slo-failed
```

For each, record symptom, state owner, next evidence, unsafe shortcut and user/data risk.

### Step 6: explore six more cases

Choose at least one from each group:

- identity/quorum;
- pool/protection;
- OSD/BlueStore/network;
- scrub/integrity;
- recovery/capacity;
- RBD/writer/upgrade.

Predict the first boundary before evaluation. Correct your mental path when the result differs.

### Step 7: verify and clean

Return to absent state and run:

```bash
bash verify.sh
```

The verifier runs all 56 decisions, tests unknown-artifact refusal, removes its artifact and proves the state root absent. Preserve the first failure if it does not pass.

### Independent runtime boundary

The independent lab requires a reviewer-owned disposable cluster or faithful isolated harness with synthetic data. The reviewer owns hidden faults, keys, stop authority and final cleanup.

Production, public targets, real credentials, customer data, unbounded I/O and destructive repair are prohibited. The learner must prove exact object/PG/OSD and user/data recovery without receiving the answer key.

## Production transfer

### Build a versioned cluster dossier

Maintain FSID, release, deployment method, monitor/manager/OSD inventory, client versions, networks, device/BlueStore layout, pools, CRUSH map/rules, cephx owners, compatibility boundaries and support lifecycle. Generate it from controlled sources and review drift.

### Design monitor quorum physically

Use an odd voting set distributed across independent failure domains with appropriate latency. Protect clock, disk and network. Document quorum-loss behavior and recovery authority. Adding voters across an unreliable WAN can reduce availability rather than improve it.

### Separate manager visibility from storage truth

Run manager redundancy and module ownership, but ensure incident procedures can obtain authoritative monitor/OSD/PG evidence if dashboards fail. Alert on stale collection as well as reported values.

### Standardize OSD hardware contracts

Record host, chassis/rack, device model/firmware, class, capacity, endurance, BlueStore block/DB/WAL layout, network links and replacement procedure. Avoid mixing dramatically different devices in one performance expectation without deliberate classes/rules.

### Make CRUSH a reviewed topology model

Generate or review the hierarchy against power, rack, network and maintenance domains. Test representative PG placements under host/rack loss before changing rules. Estimate data movement, capacity and time before applying.

### Design pools from applications

Give each pool an owner, application, client identities, protection, size/min_size or EC profile, CRUSH rule, PG autoscale policy, quota, performance expectation, backup/recovery and retirement.

Do not create many pools casually: each adds PG and operational overhead.

### Choose replication or erasure coding honestly

Replication is simple and often suits mutable/small-latency-sensitive data but uses more raw capacity. Erasure coding can improve usable ratio for suitable workloads but adds shards, computation, network and recovery complexity and may impose operation restrictions.

Benchmark representative objects and failure recovery, not just sequential throughput.

### Plan PG scaling

Use the current autoscaler and target-size guidance, but review recommendations against metadata-heavy pools, expected growth and recovery cost. Stage changes and watch peering/backfill and user latency.

### Operate capacity before nearfull

Forecast per device class, pool and failure domain. Track MAX AVAIL, utilization skew, time to thresholds and post-failure capacity. Procurement lead time belongs in the alert horizon.

Never build a plan whose only response to full is lowering protection guardrails.

### Reserve for failure and movement

After the largest declared failure, survivors must host protected data, recovery replicas/shards, foreground growth and planned maintenance. Include network and IOPS reserve, not only bytes.

### Engineer public and cluster networks

Measure loss, latency, bandwidth, congestion, MTU and redundancy end to end. Model recovery traffic and failure convergence. Separate networks only when the extra design is operated and tested.

### Balance foreground and recovery

Establish user latency/error SLOs plus maximum degraded duration. Tune only the exact release after measuring primary queues, devices and networks. A control must have an owner, expiry and rollback.

### Build integrity operations

Monitor scrub/deep-scrub age, backlog, errors and maintenance windows. Define triage for inconsistency, authoritative history, data-owner notification, recovery sources and validation. Never automate destructive lost-object decisions.

### Operate OSD lifecycle safely

For add/drain/remove/replace, identify OSD/device, confirm failure scope, calculate movement and reserve, use supported safe-to-stop/destroy evidence where available, canary, watch user SLI and prove the old identity/device is retired.

### Integrate RBD and OpenStack by identity

Maintain separate scoped identities and pools where design requires. Map Glance images, Cinder volumes/backups and Nova ephemeral/guest disks to RBD resources. Control raw image formats, cloning relationships, locks/watchers and client compatibility.

Every attachment recovery must preserve one writer.

### Build observability around a request path

Correlate client, FSID, epochs, pool, PG, OSD/host/device, operation latency, recovery and user SLI. Use logs for high-cardinality identities and metrics for bounded dimensions. Protect tenant names and object content.

### Back up the control needed to recover

Protect monitor/control identity, configs, CRUSH/pool intent, authentication material and deployment inventory using supported procedures. Application data recovery may require RBD snapshots, replication or application backups with separate consistency semantics.

Test isolated recovery and measure actual RPO/RTO. Replica availability is not backup.

### Upgrade as a storage change

Read the exact release path and deployment-tool procedure. Inventory clients and daemons, resolve health warnings, prove recovery headroom, back up control state, canary, monitor user I/O and pause on unexplained warning or compatibility error.

Advance minimum compatibility only after every old participant is removed and rollback consequences are understood.

### Close incidents with data and residue

Validate representative reads/writes and application invariants. Confirm protection and scrub state, restore temporary controls, remove stale keys/mappings/watchers and document remaining risk. HEALTH_OK alone cannot close a data incident.

## Reliability, security, observability, capacity, and cost

### Reliability: define failure assumptions

State tolerated device, host, rack and site failures and the required service during degradation. Match CRUSH and protection to those physical assumptions. Test placement and recovery in disposable environments.

### Reliability: separate availability, protection and integrity

`active`, `clean` and consistent application data are three gates. Alert and communicate them separately so continuing service does not hide shrinking safety.

### Reliability: time at risk

Recovery speed determines how long a second failure can cause worse outcomes. Balance it with foreground SLOs; track both rather than maximizing either blindly.

### Security: identity and key material

Give OpenStack services and applications separate scoped cephx entities. Restrict keyring files and transport, rotate safely, audit capability drift and remove temporary access.

### Security: encryption and isolation

cephx authentication does not automatically satisfy every encryption requirement. Design network encryption, RBD/application encryption and at-rest controls according to threat model and release capabilities. Validate tenant separation at pool/capability and higher interfaces.

### Security: destructive controls

Pool deletion, OSD purge, PG repair/loss and compatibility changes need privileged, audited, dual-reviewed workflows. Break glass must expire.

### Observability: user to media

Measure client errors/latency, monitor/map freshness, PG states, OSD queues/device latency, network, recovery, scrub and capacity. Correlation matters more than one enormous dashboard.

### Observability: actionable alerts

Page on user/data risk, inactive PGs, full admission, quorum loss, widespread device failure or stalled critical recovery. Ticket capacity trend and scrub debt early. Include safe first evidence and refusal conditions.

### Capacity: amplification

For three replicas, ideal raw protection rate is roughly three times user bytes before metadata and reserve. For K+M EC, ideal data-to-raw rate is (K+M)/K before overhead. Real usable capacity is lower due to distribution, thresholds and failure reserve.

Use exact observed tools for planning; do not promise the ideal ratio.

### Capacity: the fullest eligible member

One OSD or failure-domain subtree can bind the pool. Investigate skew, PG distribution, device size/class and CRUSH policy. Random reweighting trades one unexplained state for another.

### Cost: total operated storage

Include raw devices, servers, networks, power/cooling, spares, metadata media, failure reserve, replication/EC overhead, recovery bandwidth, monitoring, backups and operator time. A higher usable ratio can cost more latency and operational risk.

### Performance: queue and media model

Separate client connections, primary queue, BlueStore/RocksDB, device latency, peer acknowledgements and recovery. Benchmark representative object sizes, concurrency, read/write mix, snapshots/clones and failure modes.

### Balanced review questions

- Which user/data promise does this pool serve?
- What exact failure does CRUSH survive physically?
- Which acknowledgement semantics support the durability claim?
- How much eligible capacity remains after failure and movement?
- How long can protection stay degraded?
- Which client holds writer authority?
- Which signals prove integrity and user success?
- Where is the upgrade rollback boundary?
- What residue and temporary authority must be removed?

## Traps and prevention

### Trap: HEALTH_OK means data is safe

**Failure:** health checks are bounded and time-local.
**Prevention:** combine protection, integrity, representative I/O, backups and recovery evidence.

### Trap: three replicas means three failure domains

**Failure:** CRUSH topology may not match shared physical power/network.
**Prevention:** verify physical buckets and simulate declared failures.

### Trap: quorum means storage works

**Failure:** maps can be authoritative while clients, OSDs or PGs fail.
**Prevention:** walk map, placement, OSD and user paths separately.

### Trap: active means clean

**Failure:** degraded PGs may serve with reduced protection.
**Prevention:** track availability, cleanliness and integrity as separate objectives.

### Trap: raw free means writable

**Failure:** the fullest eligible OSD and thresholds bind admission.
**Prevention:** use pool-specific MAX AVAIL, distribution and reserve.

### Trap: mark an OSD out immediately

**Failure:** it can trigger large movement and exhaust destinations.
**Prevention:** diagnose duration, reserve, failure scope and recovery policy first.

### Trap: lower full ratios to restore writes

**Failure:** changing a number does not create capacity and can remove safety margin.
**Prevention:** restore eligible space/distribution with reviewed data movement and admission controls.

### Trap: maximize recovery speed

**Failure:** recovery can collapse user latency or overload devices.
**Prevention:** gate both recovery progress and user SLI with a maximum degraded duration.

### Trap: stop recovery forever

**Failure:** another failure can cause unavailability or loss.
**Prevention:** make pauses bounded, owned, observable and automatically escalated.

### Trap: repair every inconsistent PG

**Failure:** repair may choose/reconstruct the wrong state.
**Prevention:** preserve acting history, device evidence, backups and data-owner decision.

### Trap: break an RBD lock

**Failure:** a partitioned client may still write.
**Prevention:** identify and fence the old writer first.

### Trap: finish mixed-version rollout faster

**Failure:** incompatibility can spread to every daemon/client.
**Prevention:** stop at canary, compare supported versions and recover the bounded slice.

### Trap: leave temporary flags and keys

**Failure:** future behavior and authority silently differ.
**Prevention:** make exact configuration/security cleanup part of incident closure.

## Memory card and retrieval

### Ten lines

1. Bind user/data promise and FSID first.
2. Quorum owns maps, not user I/O.
3. Client maps have epochs and can be stale.
4. Object maps to PG; CRUSH maps PG to an up set.
5. Peering establishes acting set and primary.
6. Active is availability; clean is restored placement.
7. Replica/shard count is only as safe as physical failure domains.
8. Fullest eligible OSD beats aggregate raw free.
9. Fence before moving RBD writer authority.
10. Close with data, protection and cleanup proof.

### Join keys

Remember: **FSID, release, client, epoch, pool, object/image, PG, acting primary, OSD/device, time, user result**.

### Ninety-second incident opening

State the user I/O and data risk; affected FSID/pool/images/PGs; first and last event; protection/fullness state; whether writes/recovery/upgrades are paused; current writer authority; and the next safe evidence owner.

### Retrieval drill

Without looking, explain:

- monitor versus manager;
- up/down versus in/out;
- pool versus PG;
- Up Set versus Acting Set;
- active versus clean;
- recovery versus backfill;
- scrub versus application correctness;
- raw free versus MAX AVAIL;
- watcher versus fenced writer;
- replica versus backup.

Redraw the six architecture views from memory, then correct them against the lesson.

## Complete answers

### Question 1: Why are monitors essential if clients talk to OSDs?

Monitors maintain authoritative epoch-versioned maps and authentication state. Clients need current maps to calculate placement and OSDs need them to agree on membership/history.

Monitors are not the normal bulk-data proxy. Healthy quorum proves state authority, not client-to-OSD reachability, PG availability or application success.

### Question 2: What is the difference between manager and monitor?

Monitors participate in consensus and own authoritative maps. The manager collects operational data and hosts modules such as dashboards, metrics or orchestration integrations.

A manager can be unavailable or stale while data I/O continues; a lost monitor quorum prevents safe map evolution and can block operations. Do not use dashboard freshness as map authority.

### Question 3: Explain up/down and in/out.

Up/down is daemon liveness/availability from cluster perspective. In/out is placement membership. Down/in means placement still expects an unavailable OSD. Up/out can be a drained but running OSD.

Diagnosis needs both axes, the reason/timeline and the PGs affected. Marking in/out changes placement and can trigger major movement.

### Question 4: How does an object find an OSD?

The pool and object identifier hash to a PG. The current CRUSH map and rule compute an Up Set across the declared hierarchy. Peering and history establish the Acting Set and primary. The client contacts the primary.

Record the map epoch because membership and placement can change.

### Question 5: Why have placement groups?

PGs provide scalable indirection between potentially billions of objects and OSD placement. Ceph manages placement, peering, recovery and scrub at PG granularity rather than a central per-object location table.

PG count trades distribution/parallelism against memory, peering and management overhead.

### Question 6: Up Set versus Acting Set?

The Up Set is CRUSH's current expected set. The Acting Set currently owns the PG after peering and temporary/history decisions. Differences commonly occur during remapping or recovery.

The acting primary coordinates client operations. Compare both sets and past intervals when diagnosing authority.

### Question 7: Active versus clean?

Active means the PG can serve requests. Clean means configured placement is complete. An active+degraded PG may keep users online while missing protection.

Neither proves application data semantics or backup recoverability. Add scrub/integrity and representative user checks.

### Question 8: What do size and min_size mean?

For replicated pools, size is intended copies and min_size controls the minimum available copies under which I/O can proceed according to current semantics. Lower min_size can favor availability at the cost of greater data risk.

Choose it through the workload's durability/availability contract and physical failure model, not incident pressure.

### Question 9: How does erasure coding change operations?

Objects become K data plus M coding chunks distributed across K+M OSD placements. Ideal raw amplification is (K+M)/K, but CPU, network, small-write behavior, operation support, recovery fan-out and failure-domain placement matter.

Test the exact profile, release and workload. “Can lose M drives” is unsafe when losses are correlated or remaining shards are inaccessible.

### Question 10: Why can raw space be free while writes stop?

Placement must fit protected data on eligible OSDs. One eligible OSD can cross full while other classes/roots have unused capacity. Replication/EC amplification, imbalance and thresholds further reduce usable space.

Use pool-specific MAX AVAIL, OSD distribution, CRUSH eligibility and failure reserve.

### Question 11: What is recovery versus backfill?

Recovery synchronizes missing/stale object versions among relevant PG participants. Backfill commonly transfers larger PG contents when placement changes or a destination needs broad synchronization.

Both consume shared resources. Track progress, remaining exposure, destination space and foreground SLO.

### Question 12: Why not disable recovery to fix latency?

It may reduce contention but extends degraded time and second-failure risk. A pause must be time-bounded, owned and connected to restart/escalation criteria.

A balanced policy sets maximum user impact and maximum durability exposure, then measures both.

### Question 13: What does scrub prove?

Scrub compares object metadata/copies; deep scrub additionally checks data against checksums. It can reveal inconsistencies for covered objects and time.

It does not identify application truth automatically. Repair requires acting history, device evidence, backup and data-owner authority.

### Question 14: What is an unfound object?

PG history requires an object, but no known current location supplies it. Missing OSDs or histories may still contain the only copy.

Search and preserve evidence. Marking lost explicitly accepts loss or rollback behavior and requires data-owner approval.

### Question 15: How do you investigate slow Ceph I/O?

Bind client, FSID, pool/image/object/PG and time. Split map acquisition/connection, public network, primary queue, BlueStore/RocksDB/media, peer acknowledgements, cluster network, recovery contention and client/application.

Compare latency percentiles and queue age, not averages alone. Change one bounded control only after finding the limiting stage.

### Question 16: What makes CRUSH failure-domain design valid?

The hierarchy and rule must correspond to independent physical power, network, chassis/rack/site and operational domains. Simulated placements under declared failures must retain the required replicas/shards with capacity.

Logical names and different host IDs do not prove independence.

### Question 17: When is it safe to remove an OSD?

After exact identity and purpose are known, adequate eligible capacity/movement reserve exists, relevant PG data can be placed safely, supported safe-to-stop/destroy evidence passes where available, and user SLO guardrails/rollback are defined.

Afterward prove data movement complete, device identity retired and no stale CRUSH/auth/orchestrator state remains.

### Question 18: How do RBD and OpenStack relate?

Glance, Cinder and Nova own image/volume/server intent. QEMU/librbd or another client accesses an RBD image in a Ceph pool. RBD maps blocks to RADOS objects and coordinates snapshots, clones, locks and watchers.

Correlate OpenStack UUIDs to pool/image/client/PG/OSD and guest/application data. An attachment is not writer proof.

### Question 19: What makes a Ceph upgrade safe?

Exact supported release adjacency/deployment procedure, complete daemon/client inventory, healthy and capacious baseline, protected control state, canary, user/data SLI, pause/abort and a known rollback/recovery boundary.

Minimum-client/OSD compatibility advances only after old participants are gone. Completion includes all versions, recovery, user I/O and cleanup.

### Question 20: What is “recovered”?

The representative user I/O works within SLO, data invariants pass, required placement/protection is restored or accepted risk is explicit, integrity evidence is adequate, one writer owns every RBD image, and temporary flags/weights/keys/mappings/artifacts are removed.

HEALTH_OK is supporting evidence, not the definition.

## Product-company interview

### Scenario 1: HEALTH_OK but database writes are slow

**Level:** senior. **Evaluates:** path decomposition.

**Strong answer:** bind database operation, RBD image, client, FSID, pool/object/PG and time; verify current maps; split client network, primary queue, BlueStore/media, peer acknowledgement, recovery and application latency. Compare user SLI and exact participants. HEALTH_OK only says no reported health condition.

**Weak signs:** restart all OSDs or blame disks from average latency.

**Follow-up:** explain why one slow secondary can delay writes coordinated by the primary.

### Scenario 2: 30 percent raw free but cluster is full

**Level:** senior. **Evaluates:** capacity semantics.

**Strong answer:** inspect pool CRUSH eligibility, protection amplification, per-pool MAX AVAIL, fullest OSD, device-class/root skew and thresholds. Stop unsafe admission, restore eligible headroom with planned movement/capacity and protect failure reserve.

**Weak signs:** lower full ratio or add unrelated storage.

**Follow-up:** calculate post-host-failure capacity rather than current free.

### Scenario 3: active+degraded after host loss

**Level:** senior. **Evaluates:** availability versus durability.

**Strong answer:** active means covered PGs may serve; degraded means protection is missing. Identify pool policy, affected objects/PGs, acting sets, physical domain, remaining failure tolerance and recovery progress. Balance recovery with user SLO and maximum time at risk.

**Weak signs:** declare healthy because clients work.

**Follow-up:** what changes if min_size is one?

### Scenario 4: PG stuck peering

**Level:** senior. **Evaluates:** history and authority.

**Strong answer:** capture PG query/state, epochs, up/acting and past intervals, blocked-by OSDs, maps and relevant logs. Restore missing authoritative participants or follow release-supported recovery. Refuse force/lost actions until data consequences are understood.

**Weak signs:** force-create the PG.

**Follow-up:** why can the current CRUSH set differ from authoritative history?

### Scenario 5: inconsistent PG

**Level:** lead. **Evaluates:** data integrity judgment.

**Strong answer:** identify exact objects and replicas/shards, scrub type/result, device errors, versions and acting history; preserve backups and engage data owner. Determine authoritative state before supported repair, then validate object and application data.

**Weak signs:** repair immediately because Ceph is self-healing.

**Follow-up:** when might repair propagate a bad copy?

### Scenario 6: RBD lock blocks evacuation

**Level:** senior. **Evaluates:** writer authority.

**Strong answer:** join OpenStack server/volume to RBD pool/image, watchers, lock owner, client addresses and old compute state. Stop new attachment attempts, independently fence old writer, then use supported recovery and validate guest/application data.

**Weak signs:** break lock and retry.

**Follow-up:** why is host unreachable not fencing?

### Scenario 7: choose replication versus EC

**Level:** staff. **Evaluates:** trade-offs.

**Strong answer:** start with object size/mutation pattern, latency/throughput, supported operations, durability/failure domains, CPU/network, recovery time and cost. Compare ideal/raw ratios but benchmark representative normal/failure workloads and preserve metadata/omap constraints.

**Weak signs:** EC is always cheaper.

**Follow-up:** discuss a small-random-write RBD workload.

### Scenario 8: design rack-aware Ceph

**Level:** staff. **Evaluates:** physical architecture.

**Strong answer:** map power/network/rack/maintenance domains, choose CRUSH root/class/rule and pool protection, simulate placements and rack loss, calculate survivor bytes/IOPS/network and recovery reserve, place monitor quorum independently and test failure.

**Weak signs:** label hosts with rack names and assume success.

**Follow-up:** which shared dependencies can invalidate racks?

### Scenario 9: recovery traffic breaks SLO

**Level:** lead. **Evaluates:** risk balancing.

**Strong answer:** quantify affected protection and maximum time at risk, user latency/errors and bottleneck. Apply release-validated bounded recovery controls as a canary, track both progress and SLO, and automatically restore/escalate. Add capacity/network/media reserve.

**Weak signs:** disable recovery or maximize it.

**Follow-up:** define stop gates for both directions.

### Scenario 10: plan a rolling upgrade

**Level:** staff. **Evaluates:** change safety.

**Strong answer:** confirm supported adjacency and cephadm/deployment method, inventory clients/daemons, resolve health/capacity/integrity risks, protect control state, canary, track versions/maps/PGs/user I/O, pause on unexplained state, advance compatibility last, and prove cleanup.

**Weak signs:** automated orchestrator means rollback is automatic.

**Follow-up:** when does a minimum-release change constrain rollback?

### Answer pattern

Begin with user/data, bind FSID/release/identity, trace maps and object placement, distinguish availability/protection/integrity, protect capacity and writer authority, choose a reversible supported action, validate the user/data, then clean residue and state proof limits.

## Independent transfer and rubric

### Reviewer-owned challenge

Open `ASM-0219` only when ready to work without model answers. Use a reviewer-owned disposable Ceph deployment or faithful isolated harness with synthetic data. The reviewer controls hidden faults, credentials, destructive boundaries, stop authority and cleanup.

Production, public targets, real keyrings, customer data, uncontrolled load and destructive lost-object or repair actions are prohibited.

### Evidence packet

Submit:

- user I/O, data invariant, SLO, durability/consistency and RPO/RTO;
- exact FSID, release, deployment/client/OpenStack versions and configuration source;
- cephx entity/capability evidence without keys;
- monitor/manager/OSD/device/network and physical-failure topology;
- pool policy and CRUSH rule/failure simulation;
- object or RBD image to PG, epochs, up/acting sets, primary and OSDs;
- complete PG state, acting history, scrub and integrity evidence;
- raw/eligible/MAX AVAIL/fullness/failure/movement capacity calculations;
- recovery progress versus user SLI;
- RBD/OpenStack locks/watchers/client/writer authority and fencing;
- supported containment/recovery/change sequence with abort/rollback;
- representative user I/O and data proof;
- exact cleanup, residual risk and owned prevention.

### Self-review

| Check | Pass condition |
|---|---|
| Outcome | names semantic user and data success |
| Identity | binds FSID, release, config, client and cephx |
| Maps | distinguishes quorum authority and client epochs |
| Placement | joins object, PG, up/acting, primary and OSD |
| Protection | explains pool policy and physical CRUSH domains |
| Capacity | calculates eligible, amplified and failure-reserved capacity |
| Integrity | treats scrub/repair/unfound as data decisions |
| Performance | locates queues and balances recovery/user SLI |
| Authority | fences before RBD writer transfer |
| Change | uses supported version, canary, stop and rollback |
| Recovery | proves user I/O and data invariants |
| Cleanup | proves temporary authority and artifacts absent |
| Limits | bounds conclusions to tested scope |

### Scoring boundary

The independent rubric totals 100. Commands and screenshots without correlated identities and reasoning do not pass. An explicit unknown with a safe refusal is stronger than an invented claim.

The offline verifier, reading state and publication do not award mastery. Reviewer acceptance and later unfamiliar retrieval remain required.

## References and review

### Primary source map

**[REF-0928] Ceph Architecture**

Use for RADOS, daemon roles, maps, client-to-OSD I/O, CRUSH, peering, replication, recovery and cephx. It is development documentation and does not prove a deployed cluster.

https://docs.ceph.com/en/latest/architecture/

**[REF-0929] Monitor Configuration Reference**

Use for monitor quorum, elections, map authority and monitor configuration concepts. Exact defaults and recovery must match the deployed release.

https://docs.ceph.com/en/latest/rados/configuration/mon-config-ref/

**[REF-0930] Ceph Manager Daemon**

Use for active/standby manager and module roles. Manager visibility is not monitor quorum or data durability.

https://docs.ceph.com/en/latest/mgr/

**[REF-0931] BlueStore Configuration Reference**

Use for block, DB/WAL, RocksDB/cache and device behavior. Tuning requires representative hardware/workload evidence.

https://docs.ceph.com/en/latest/rados/configuration/bluestore-config-ref/

**[REF-0932] CRUSH Maps**

Use for hierarchy, buckets, rules, device classes, weights and failure-domain placement. Logical topology still needs physical verification.

https://docs.ceph.com/en/latest/rados/operations/crush-map/

**[REF-0933] Pools**

Use for pool lifecycle and replicated/EC properties including protection and CRUSH association. Creation, value changes and deletion are operational changes, not examples to copy blindly.

https://docs.ceph.com/en/latest/rados/operations/pools/

**[REF-0934] Placement Groups**

Use for object/PG indirection, autoscaling and PG-count trade-offs. Changing counts can produce peering and data movement.

https://docs.ceph.com/en/latest/rados/operations/placement-groups/

**[REF-0935] Placement Group States**

Use to decode active, clean, degraded, peering, remapped, recovery, stale and related state components. Interpret full combinations and release.

https://docs.ceph.com/en/latest/rados/operations/pg-states/

**[REF-0936] Erasure Code**

Use for K+M profiles, pool creation concepts and recovery trade-offs. Actual durability/performance requires physical topology and workload evidence.

https://docs.ceph.com/en/latest/rados/operations/erasure-code/

**[REF-0937] Health Checks**

Use for named health conditions including full, slow, scrub and daemon warnings. A summary cannot prove client or application correctness.

https://docs.ceph.com/en/latest/rados/operations/health-checks/

**[REF-0938] Monitoring a Cluster**

Use for status, quorum, OSD, PG and capacity observation concepts. Protect sensitive output and record time/FSID.

https://docs.ceph.com/en/latest/rados/operations/monitoring/

**[REF-0939] Monitoring OSDs and PGs**

Use for up/down, in/out and PG-to-OSD diagnosis. State must be joined to affected objects and users.

https://docs.ceph.com/en/latest/rados/operations/monitoring-osd-pg/

**[REF-0940] Adding and Removing OSDs**

Use for supported OSD lifecycle concepts. Real removal/replacement requires reserve, movement, safety and cleanup review.

https://docs.ceph.com/en/latest/rados/operations/add-or-rm-osds/

**[REF-0941] Block Devices and OpenStack**

Use for RBD integration with Glance, Cinder, Nova, QEMU/libvirt and service identities. Exact settings depend on both deployed products.

https://docs.ceph.com/en/latest/rbd/rbd-openstack/

**[REF-0942] Upgrading Ceph**

Use for cephadm upgrade workflow, monitoring, pause and health concepts only when cephadm and the documented release path apply.

https://docs.ceph.com/en/latest/cephadm/upgrade/

### Source and runtime limits

All fifteen URLs resolved on 2026-08-07 and identify themselves as development documentation where `latest` applies. They support concepts, not a deployed release, configuration, hardware, performance or recovery claim.

No Ceph package, daemon, keyring, cluster, pool, object, PG, OSD, RBD image, I/O, fault, repair, recovery or upgrade was used. The Ubuntu lab is deterministic and calls no cluster.

### Review cadence

Re-review by 2027-02-07 or sooner when:

- Ceph release or deployment tooling changes;
- clients, OpenStack, hardware, BlueStore layout or networks change;
- pool/CRUSH/protection/capacity policy changes;
- a new PG, integrity, recovery or writer-authority incident occurs;
- lab safety, schemas or prerequisites change.

Resolve every source, pin release-specific behavior, rerun schemas/lab/build, test representative disposable I/O and recovery, and keep documentation claims separate from observed evidence.
