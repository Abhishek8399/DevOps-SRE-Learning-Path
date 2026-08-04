---
{
  "schemaVersion":1,"kind":"lesson","id":"LES-0044","slug":"kubernetes-storage-persistence-recovery","aliases":["V05-L08","kubernetes-storage-persistence-recovery"],"curriculumIds":["K8S-004"],"route":"/book/infrastructure/kubernetes-storage-persistence-recovery","order":8,"volume":"05-infrastructure-platforms",
  "title":"Kubernetes storage: bind, attach, mount, protect, and restore data safely","summary":"Trace persistent data through claims, classes, provisioning, topology, attachment, mount, filesystem permissions, snapshots, expansion, reclaim and restore verification.","domain":"infrastructure","level":{"from":"intermediate","to":"advanced"},"estimatedMinutes":600,
  "prerequisiteLessonIds":["LES-0006","LES-0011","LES-0023","LES-0041","LES-0042"],"prerequisiteCurriculumIds":["LNX-001","LNX-006","CTR-001","K8S-001","K8S-002"],
  "testedEnvironments":[{"platform":"Kubernetes documentation","version":"v1.36 current documentation","support":"supported","notes":"Official volume, PV/PVC, StorageClass, provisioning, snapshot, data-source, ephemeral, health, capacity and policy sources reviewed 2026-08-04."},{"platform":"CSI documentation","version":"current documentation","support":"supported","notes":"CSI sidecar and operation boundaries reviewed 2026-08-04."},{"platform":"Local Kubernetes cluster","version":"not available","support":"required","notes":"No Linux Docker engine or WSL access; no real storage runtime claim."},{"platform":"Cloud","version":"not used","support":"unsupported","notes":"No managed disk, snapshot, backup vault, credential or billable resource."}],
  "targetRoles":["devops-engineer","site-reliability-engineer","platform-engineer","kubernetes-engineer","storage-engineer","database-engineer","security-engineer","technical-lead"],
  "learningObjectives":["Separate application data semantics from Kubernetes volume lifecycle.","Trace PVC request through StorageClass, provisioner, PV binding, topology, attachment, mount and application I/O.","Explain access modes, volume modes, reclaim policy, binding mode, expansion and finalizers.","Diagnose Pending PVC, Pending Pod, attachment, mount, permission, capacity and filesystem failures by boundary.","Distinguish emptyDir, projected/config volumes, generic ephemeral, local and persistent volumes.","Reason about CSI controller/node responsibilities and sidecar ownership.","Design snapshot and backup workflows without calling crash-consistent snapshots application-consistent backups.","Verify restore through data integrity and the real application operation.","Protect data during deletion, retain/reclaim, expansion and topology changes.","Transfer the model to databases, stateful services, migrations and disaster recovery."],
  "productionSignals":["cluster namespace PVC/PV UID and StorageClass","request size accessModes volumeMode selector dataSource","PV capacity accessModes reclaimPolicy claimRef and node affinity","binding mode allowed topology selected node and scheduler events","CSI driver provision/attach/stage/publish/unpublish/unmap operation IDs and errors","VolumeAttachment object node and status","Pod nodeName volume mount path readOnly fsGroup and security context","node device filesystem mount options capacity inodes latency errors and saturation","PVC conditions capacity allocatedResources and resize status","snapshot/content UID source UID readyToUse restoreSize deletionPolicy and driver","application checkpoint/quiesce transaction/log position and integrity result","backup catalog retention encryption restore drill RPO and RTO evidence","deletion timestamp finalizers dependents reclaim outcome and external asset inventory","user operation after restore and served data version"],
  "diagrams":[
    {"id":"LES-0044-DIA-001","title":"PVC to application I/O path","direction":"left-to-right","boundaries":["PVC","StorageClass","provisioner","PV","scheduler topology","attach","stage/mount","Pod path","application"],"evidencePoints":["UID","class","handle","node","mount","write/read"],"textAlternative":"A claim selects policy and provisioning, binds a volume, constrains placement, attaches and mounts on a node, then the application performs I/O."},
    {"id":"LES-0044-DIA-002","title":"Storage object ownership","direction":"hierarchical","boundaries":["PVC","PV","VolumeAttachment","VolumeSnapshot","VolumeSnapshotContent","external asset"],"evidencePoints":["claimRef","volumeHandle","finalizer","deletionPolicy","source UID"],"textAlternative":"Kubernetes objects reference an external storage asset through driver handles and finalizers; deletion and reclaim do not mean the same thing."},
    {"id":"LES-0044-DIA-003","title":"CSI responsibility split","direction":"left-to-right","boundaries":["API/controller sidecars","CSI controller service","storage backend","CSI node service","kubelet","Pod"],"evidencePoints":["provision","attach","stage","publish","operation ID"],"textAlternative":"Controller-side operations provision and attach while node-side operations stage and publish; kubelet coordinates the Pod mount."},
    {"id":"LES-0044-DIA-004","title":"Binding and topology","direction":"left-to-right","boundaries":["PVC","immediate or wait-for-consumer","Pod constraints","scheduler","selected node/zone","PV affinity"],"evidencePoints":["bindingMode","selected-node","zone","FailedScheduling"],"textAlternative":"Delayed binding considers the consumer Pod before provisioning so volume topology and node placement can agree."},
    {"id":"LES-0044-DIA-005","title":"Snapshot to verified restore","direction":"left-to-right","boundaries":["quiesce/checkpoint","snapshot request","snapshot content","backend snapshot","restore PVC","Pod mount","integrity","user operation"],"evidencePoints":["source UID","ready","restoreSize","checksum","transaction","RTO"],"textAlternative":"A snapshot request becomes backend state, but protection is proven only after a new claim restores, mounts, passes integrity and serves the expected operation."},
    {"id":"LES-0044-DIA-006","title":"Storage failure localization","direction":"top-to-bottom","boundaries":["claim admission","provision","bind","schedule","attach","mount","permission","filesystem","application"],"evidencePoints":["condition","event","handle","node","errno","data check"],"textAlternative":"Each storage stage has different owners and evidence; the first failed stage determines the safe diagnostic branch."}
  ],
  "commands":[
    {"id":"LES-0044-CMD-001","question":"Which exact claim, volume and class own this data path?","risk":"read-only","command":"kubectl get pvc,pv,storageclass -o wide; kubectl get pvc DATA -n atlas-storage -o yaml","runFrom":"approved local context","expectedBranches":[{"when":"UID claimRef class and capacity align","meaning":"object chain bound","nextEvidence":"inspect Pod/node path"},{"when":"identity differs","meaning":"wrong or recreated claim","nextEvidence":"stop before mutation"}],"proves":"reported storage object identity","doesNotProve":"external asset or data correctness"},
    {"id":"LES-0044-CMD-002","question":"Why is the PVC Pending?","risk":"read-only","command":"kubectl describe pvc DATA -n atlas-storage; kubectl get events -n atlas-storage --sort-by=.metadata.creationTimestamp","runFrom":"approved namespace","expectedBranches":[{"when":"no provisioner/class/capacity error","meaning":"provisioning path blocked","nextEvidence":"inspect class/driver/controller"},{"when":"WaitForFirstConsumer","meaning":"binding awaits a schedulable consumer","nextEvidence":"inspect Pod constraints"}],"proves":"claim status and retained events","doesNotProve":"backend root cause"},
    {"id":"LES-0044-CMD-003","question":"Do Pod and volume topology intersect?","risk":"read-only","command":"kubectl get pod APP -n atlas-storage -o yaml; kubectl get pv PV -o yaml; kubectl get csistoragecapacity -A -o yaml","runFrom":"approved cluster","expectedBranches":[{"when":"node/zone satisfies PV affinity and capacity","meaning":"placement feasible","nextEvidence":"inspect binding/attach"},{"when":"no intersection","meaning":"unschedulable topology","nextEvidence":"correct policy or capacity"}],"proves":"declared topology/capacity","doesNotProve":"future backend capacity"},
    {"id":"LES-0044-CMD-004","question":"Did controller attachment succeed?","risk":"read-only","command":"kubectl get volumeattachment -o yaml; kubectl describe pod APP -n atlas-storage","runFrom":"approved operator context","expectedBranches":[{"when":"attached true to Pod node","meaning":"controller attach reported success","nextEvidence":"inspect node stage/mount"},{"when":"multi-attach or driver error","meaning":"attachment blocked","nextEvidence":"bind old/new node and driver operation"}],"proves":"attachment object/status","doesNotProve":"mount or filesystem"},
    {"id":"LES-0044-CMD-005","question":"Is volume mounted with expected identity and capacity inside the Pod?","risk":"read-only","command":"kubectl exec -n atlas-storage APP -- sh -c 'id; findmnt /data; df -hT /data; df -i /data'","runFrom":"approved Pod","expectedBranches":[{"when":"mount type source capacity and identity align","meaning":"Pod mount visible","nextEvidence":"controlled read/write"},{"when":"permission or absent mount","meaning":"publish/mount/security boundary","nextEvidence":"inspect events and security context"}],"proves":"one container namespace view","doesNotProve":"durability or backup"},
    {"id":"LES-0044-CMD-006","question":"Can a bounded write be read and synced without touching existing data?","risk":"mutating-bounded","command":"kubectl exec -n atlas-storage APP -- sh -c 'umask 077; printf atlas-storage-check > /data/.atlas-check.tmp; sync; grep -qx atlas-storage-check /data/.atlas-check.tmp; rm -f /data/.atlas-check.tmp'","runFrom":"reviewed disposable fixture volume only","expectedBranches":[{"when":"write read sync cleanup succeed","meaning":"one bounded filesystem operation passed","nextEvidence":"application transaction"},{"when":"read-only ENOSPC inode or I/O error","meaning":"filesystem/runtime boundary failed","nextEvidence":"preserve errno and capacity"}],"proves":"one bounded write/read/cleanup","doesNotProve":"crash durability or application consistency","cleanup":"command removes exact test file; inventory proves absence"},
    {"id":"LES-0044-CMD-007","question":"Is expansion requested, controller-complete, and filesystem-complete?","risk":"read-only","command":"kubectl get pvc DATA -n atlas-storage -o yaml; kubectl exec -n atlas-storage APP -- df -hT /data","runFrom":"approved namespace","expectedBranches":[{"when":"PVC capacity and filesystem size both increased","meaning":"reported expansion reached mount","nextEvidence":"verify application"},{"when":"FileSystemResizePending or old df size","meaning":"node/filesystem expansion remains","nextEvidence":"inspect driver/node conditions"}],"proves":"reported request/capacity/mount size","doesNotProve":"safe shrink or performance"},
    {"id":"LES-0044-CMD-008","question":"Is the snapshot bound to the intended source and ready?","risk":"read-only","command":"kubectl get volumesnapshot -n atlas-storage -o yaml; kubectl get volumesnapshotcontent -o yaml","runFrom":"approved operator context","expectedBranches":[{"when":"source UID content handle ready and restoreSize align","meaning":"snapshot control plane reports ready","nextEvidence":"restore to new PVC"},{"when":"error or wrong source","meaning":"snapshot invalid for restore claim","nextEvidence":"stop and inspect driver/class"}],"proves":"snapshot API status","doesNotProve":"application consistency or restore usability"},
    {"id":"LES-0044-CMD-009","question":"Will reclaim/delete remove external data?","risk":"read-only","command":"kubectl get pv PV -o yaml","runFrom":"approved operator context","expectedBranches":[{"when":"Retain","meaning":"PV release will not automatically delete asset","nextEvidence":"record manual ownership"},{"when":"Delete","meaning":"controller may delete external asset after claim lifecycle","nextEvidence":"require backup and approval"}],"proves":"declared reclaim/finalizer/handle","doesNotProve":"backend deletion result"},
    {"id":"LES-0044-CMD-010","question":"Does restored data pass integrity and application semantics?","risk":"read-only","command":"kubectl exec -n atlas-storage RESTORE_APP -- sh -c 'sha256sum -c /data/manifest.sha256'; kubectl logs -n atlas-storage RESTORE_APP","runFrom":"isolated restored PVC and app","expectedBranches":[{"when":"checksums and application transaction pass","meaning":"selected restored data is usable","nextEvidence":"record RPO/RTO"},{"when":"snapshot ready but validation fails","meaning":"protection objective failed","nextEvidence":"preserve restore and consistency evidence"}],"proves":"declared integrity/application checks","doesNotProve":"all business data"},
    {"id":"LES-0044-CMD-011","question":"What blocks a terminating PVC or PV?","risk":"read-only","command":"kubectl get pvc DATA -n atlas-storage -o yaml; kubectl get pv PV -o yaml; kubectl get pod -A -o yaml","runFrom":"approved operator context","expectedBranches":[{"when":"protection finalizer and live consumer exist","meaning":"deletion is intentionally retained","nextEvidence":"remove consumer through owner"},{"when":"driver finalizer with failed cleanup","meaning":"external cleanup loop stalled","nextEvidence":"repair driver/backend"}],"proves":"reported finalizers/references","doesNotProve":"safe force-removal"},
    {"id":"LES-0044-CMD-012","question":"Does the deterministic storage model localize eight stages and clean exactly?","risk":"mutating-bounded","command":"bash verify.sh","runFrom":"LES-0044 support/lab as normal Ubuntu user","expectedBranches":[{"when":"verification pass","meaning":"model/refusals/cleanup pass","nextEvidence":"retain model-only boundary"},{"when":"assertion fails","meaning":"candidate rejected","nextEvidence":"preserve first failure"}],"proves":"deterministic model","doesNotProve":"CSI volume snapshot or data runtime","cleanup":"verifier proves exact absence"}
  ],
  "labs":[{"id":"LES-0044-LAB-001","title":"Guided storage lifecycle model","mode":"guided","environment":"Ubuntu 24.04 normal user with Bash/Python; no cluster","timeMinutes":210,"privilege":"normal user; root refused","network":"none","changes":["one UID-scoped root","eight deterministic storage stages"],"abortConditions":["root","network","kubectl","device","mount","symlink","unknown artifact"],"recovery":"Preserve first failed stage and rerun clean.","cleanupProof":"Exact inventory/path/owner and absence.","path":"drafts/LES-0044-kubernetes-storage-persistence-recovery/support/lab"},{"id":"LES-0044-LAB-002","title":"Independent pinned local-cluster storage transfer","mode":"independent","environment":"Reviewer-owned disposable cluster with local CSI fixture and dedicated namespace","timeMinutes":240,"privilege":"namespace learner; reviewer owns storage backend","network":"local only","changes":["PVC/PV","topology/permission/capacity faults","snapshot and restore"],"abortConditions":["wrong context","cluster-admin","hostPath","raw host device","production data","force finalizer removal","cloud asset"],"recovery":"Preserve object/driver/data evidence and recover through owner.","cleanupProof":"Reviewer proves objects, handles, snapshots, files, credentials and cluster absent.","path":"drafts/LES-0044-kubernetes-storage-persistence-recovery/support/lab"}],
  "incidents":[{"id":"LES-0044-INC-001","signal":"PVC remains Pending.","firstThought":"Provisioning, class, capacity, selector or delayed binding is unresolved.","safePath":"Read class/provisioner/binding mode/events and consumer topology.","trap":"Create a random PV."},{"id":"LES-0044-INC-002","signal":"Pod Pending with unbound immediate PVC or topology conflict.","firstThought":"Storage binding and scheduler placement disagree.","safePath":"Correlate PVC/PV affinity, selected node, Pod constraints and capacity.","trap":"Set nodeName manually."},{"id":"LES-0044-INC-003","signal":"Volume attachment succeeds but mount fails.","firstThought":"Controller attach completed; node stage/publish, filesystem or permission failed.","safePath":"Inspect Pod events, node CSI operation, device/fs/mount/security context.","trap":"Detach repeatedly without evidence."},{"id":"LES-0044-INC-004","signal":"Snapshot ready but restored application data is inconsistent.","firstThought":"Infrastructure snapshot completion did not provide application consistency.","safePath":"Preserve log/checkpoint/transaction evidence, restore isolated, use app-native recovery.","trap":"Call snapshot ready a successful backup."},{"id":"LES-0044-INC-005","signal":"PVC/PV stuck Terminating.","firstThought":"Protection or driver finalizer still owns a live dependency/cleanup obligation.","safePath":"Map consumers/finalizers/handles and repair owner before deletion.","trap":"Strip finalizers blindly."}],
  "assessmentIds":["ASM-0115","ASM-0116","ASM-0117"],"referenceIds":["REF-0418","REF-0419","REF-0420","REF-0421","REF-0422","REF-0423","REF-0424","REF-0425","REF-0426","REF-0427","REF-0428","REF-0429","REF-0430","REF-0431","REF-0432"],"contentStatus":"substantive-draft","masteryBoundary":"publication-does-not-award-mastery","lastReviewed":"2026-08-04","reviewAfter":"2027-02-04","limitations":["No cluster/CSI/storage runtime executed.","Model is not volume or data evidence.","No host device, production data, cloud disk/snapshot or credential.","Formal review and learner evidence absent."]
}
---

# Kubernetes storage: bind, attach, mount, protect, and restore data safely

## What you see and first thought

A Pod says `ContainerCreating` and events say `FailedMount`. Do not conclude “the disk is down.” Ask which stage last succeeded: claim admission, provisioning, binding, scheduling topology, controller attachment, node staging, Pod publish/mount, filesystem access, or application I/O.

```text
PVC -> class/provision -> PV bind -> schedule -> attach -> stage/publish
    -> mount -> permission/filesystem -> application write -> protected restore
```

A mounted filesystem proves no backup. A ready snapshot proves no restore. A restored directory proves no application correctness. Keep every claim separate.

## Terms before commands

**Volume** exposes storage to containers in a Pod. Its lifetime and backing vary. `emptyDir` follows Pod lifetime; projected/config volumes expose API/config material; ephemeral volumes follow Pod lifecycle; persistent volumes decouple storage lifecycle from one Pod.

**PersistentVolume (PV)** is cluster-scoped storage capacity with access modes, capacity, volume mode, reclaim policy, class, claim reference, topology and backend identity. **PersistentVolumeClaim (PVC)** is a namespaced request consumed by Pods.

**StorageClass** names provisioning policy: provisioner/driver, parameters, reclaim policy, binding mode, expansion and allowed topology. It is not merely a disk type label.

**CSI** is a storage plugin interface. Controller-side operations provision, delete, attach and snapshot where supported; node-side operations stage and publish. Sidecars watch Kubernetes objects and call driver services. Exact support is driver/version dependent.

**Access mode** describes intended attachment/access capabilities such as ReadWriteOnce, ReadOnlyMany, ReadWriteMany or ReadWriteOncePod. It is not filesystem user authorization. **VolumeMode** selects Filesystem or Block.

**Reclaim policy** governs what happens to dynamically managed storage after claim release: commonly Delete or Retain. It is data-destruction policy, not cleanup decoration.

**Snapshot** is a point-in-time storage representation through snapshot APIs/driver. Crash consistency is not application consistency. **Backup** additionally needs catalog, retention, independence, security and verified restore aligned to RPO/RTO.

## Architecture map

```text
PVC -> StorageClass -> external provisioner -> PV/volumeHandle
 |                              |
 Pod constraints -> scheduler topology -> node
                                     |
                           attach -> stage -> publish
                                     |
                               /data mount -> app
```

Kubernetes objects coordinate external assets. UIDs, claimRef, volumeHandle, finalizers and driver operation IDs are the identity chain. Names alone are unsafe after delete/recreate.

## Request or state path

A PVC is admitted with size, access modes, volume mode, class and optional data source. Immediate binding may provision now; WaitForFirstConsumer delays provisioning/binding until Pod scheduling supplies topology. The external provisioner creates an asset and PV. Binding connects PVC/PV. Scheduler ensures Pod constraints and PV node affinity agree. An attachment controller/CSI controller attaches where needed. Kubelet and CSI node service stage/publish to the Pod. The application finally performs I/O.

Deletion reverses responsibilities but is not symmetric magic. Pod unmount/unpublish, detach, object finalizers, reclaim policy and backend deletion can fail independently. Retain preserves the asset for explicit handling; Delete can destroy it. Confirm protection before any claim deletion.

## Failure zoom

Pending PVC with no consumer can be correct under delayed binding. Pending PVC with provisioner errors points to class/driver/backend/capacity. Pending Pod plus unbound claim can reflect immediate-binding or topology conflict. Multi-Attach can mean old-node attachment, workload strategy or access-mode mismatch. FailedMount after attachment points to node staging, filesystem, mount options, permissions or secrets.

Mounted but read-only, ENOSPC or inode exhaustion is a filesystem/application boundary. `df -hT` and `df -i` must target the actual mount. Permission denied needs container identity, fsGroup/security context, ownership and mode evidence—not chmod 777.

Snapshot ready but bad restored data means infrastructure completion exceeded application consistency. Preserve database WAL/transaction/checkpoint evidence and use application-native recovery.

## Internals and state ownership

PV/PVC binding is exclusive identity through claimRef and UIDs. Static provisioning and dynamic provisioning reach similar binding state through different owners. StorageClass `volumeBindingMode: WaitForFirstConsumer` helps avoid provisioning in a zone incompatible with the eventual Pod.

Access modes are driver/backend capabilities and scheduling/attachment intent. They do not automatically prevent every misuse or implement POSIX permissions. ReadWriteOnce can allow access from multiple Pods on one node depending on backend; ReadWriteOncePod targets single-Pod access where supported.

Expansion has layers: PVC request, controller/backend resize, PV/PVC capacity status and node/filesystem resize. Shrink is generally not the inverse. Verify filesystem-visible size and application behavior. VolumeAttributesClass may separate mutable volume attributes where supported; never assume driver support.

Finalizers protect objects while dependencies or external cleanup remain. Removing one manually can orphan or destroy ownership information. Repair the responsible controller/backend unless an approved data-recovery procedure proves force is safe.

## Evidence table

| Claim | Minimum evidence | Still not proved |
|---|---|---|
| claim bound | matching PVC/PV UIDs and claimRef | attachment |
| attached | VolumeAttachment/driver success to correct node | mounted |
| mounted | namespace mount/source/fs/capacity | writable/durable |
| bounded write works | exact write/read/sync/cleanup | crash durability |
| snapshot ready | source UID/content/handle/ready/size | consistency |
| restore usable | isolated restore, integrity and app transaction | complete DR |
| backup meets objective | independent catalog plus timed restore/RPO/RTO | future success |

## Command decoders

`describe pvc` joins conditions and events; YAML preserves exact class, mode, data source and status. `VolumeAttachment` is cluster-scoped and may expose backend identifiers—sanitize evidence. Pod events place attach/mount failures but can expire.

Inside the Pod, `findmnt`, `df -hT`, `df -i` and `id` answer different questions. `df` on the wrong path inspects the wrong filesystem. A test write must use a disposable approved volume, unique file, strict permissions and exact cleanup.

Snapshot status is control-plane evidence. Restore to a new PVC, mount it in isolation and run integrity plus application verification. Never test restore over the only copy.

## Decision path

1. Bind cluster, namespace, PVC/PV UIDs, class, volumeHandle and data criticality.
2. State user/data impact and stop destructive deletion/retry loops.
3. Locate first incomplete stage: provision, bind, schedule, attach, mount, permission, filesystem or app.
4. Correlate events with driver/controller/node operation evidence.
5. Preserve transaction/checkpoint and backend identity evidence.
6. Recover through the owning controller or application procedure.
7. Verify mount, bounded I/O, application semantics and user operation.
8. For protection, perform isolated restore and record RPO/RTO.
9. Clean only exact disposable objects/assets after finalizer/reclaim review.

## Guided Ubuntu lab

The deterministic model covers eight states: class missing, delayed binding, topology conflict, attach conflict, mount permission, filesystem ENOSPC, snapshot without quiesce, and successful isolated restore. It uses no device, mount, network, kubectl or cluster.

Run `bash lab.sh doctor`, `setup`, `list`, `diagnose CASE`, `verify-cases`, and `cleanup` from the support lab. Wrong-stage diagnosis and unknown-file cleanup must refuse. Passing proves only model assertions.

## Production transfer

Use a reviewer-owned disposable pinned cluster with a local CSI fixture and synthetic data. Baseline driver/sidecars/classes/topology. Prove dynamic claim, Pod mount, bounded write, Pod replacement persistence, delayed-binding topology, permission failure, bounded capacity failure, expansion, snapshot, isolated restore and integrity/application validation.

No hostPath, raw host device, production data, cloud disk, force-finalizer removal or destructive reclaim experiment. Reviewer owns backend lifecycle and proves no handles/snapshots/files/credentials remain.

## Reliability, security, observability, capacity, and cost

Reliability needs redundancy outside one volume, application consistency, restore drills and topology capacity. A highly available control plane does not make a single-zone volume available after zone loss. Stateful failover needs fencing and ownership so two writers do not corrupt data.

Security includes encryption, key access, node trust, mount permissions, secret delivery, snapshot/backup access and tenant isolation. PV/snapshot handles and restored data are sensitive. Least privilege should separate namespace use from cluster/backend administration.

Observe provision/bind/attach/mount latency and errors, capacity/inodes, IOPS/throughput/latency, queue depth, filesystem errors, snapshot age/result, backup age, restore duration and application data checks. Cost includes provisioned capacity/performance, snapshots, backup retention, replication, cross-zone transfer and orphaned retained assets.

## Traps and prevention

Do not create random PVs for Pending claims. Do not set `nodeName` to bypass topology. Do not detach repeatedly after attach success. Do not chmod 777 for permissions. Do not call snapshot Ready a backup. Do not delete a PVC to “reset” storage. Do not strip finalizers blindly. Do not assume access mode is application locking.

Prevent with class policy, delayed binding where appropriate, quota/capacity alerts, admission constraints, synthetic provisioning, snapshot-age alarms, independent backup catalogs, scheduled restores and data-integrity/user verification.

## Memory card and retrieval

Remember **CLAIM-DATA**: Claim identity; Lifecycle policy; Affinity/topology; Interface/CSI stage; Mount/filesystem; Data semantics; Archive/snapshot; Tested restore and application.

Explain bound versus attached, attached versus mounted, mounted versus writable, writable versus durable, snapshot versus backup, restored files versus recovered application, access mode versus filesystem permission, Retain versus Delete.

## Complete answers

**Why can PVC be Pending without failure?** WaitForFirstConsumer intentionally delays binding/provisioning until a Pod supplies placement topology. Inspect binding mode and consumer scheduling evidence.

**Why can attach succeed while mount fails?** Controller attachment makes the asset available to a node; node staging/publishing, device/filesystem, mount options, credentials and security context occur afterward.

**Is a ready snapshot a backup?** No. It proves driver/API snapshot completion. Backup requires application consistency expectations, independent retention/security/catalog and verified restore meeting RPO/RTO.

**Why not remove a finalizer?** It records an owning cleanup/protection obligation. Removal can orphan an asset, lose deletion coordination or expose data loss. Repair the owner first.

## Product-company interview

Scenario: after node failure, a stateful Pod is Pending with Multi-Attach; the old node is unreachable and users demand an immediate force detach. A strong answer declares data/availability risk, binds Pod/PVC/PV/handle/old-new nodes, confirms access mode and application fencing, inspects attachment/driver/backend state, checks whether the old writer can still access storage, follows approved fencing/failover rather than timing guess, then verifies mount, data integrity, application recovery and user operations. It records RTO and prevents recurrence through fencing/runbook/alert testing.

## Independent transfer and rubric

Unseen case: delayed-binding claim, conflicting zone affinity, an old attachment, misleading filesystem permission error and a snapshot taken without application checkpoint. Produce identity/topology/operation evidence, first-failure ordering, safe recovery, isolated restore/integrity test, user verification and cleanup.

Rubric: 15 identity/criticality, 15 lifecycle localization, 15 topology/binding, 10 attach/mount, 10 permission/filesystem, 15 consistency/restore, 10 recovery safety, 10 user/cleanup evidence. Reviewer-observed unseen reasoning only.

## References and review

`REF-0418` through `REF-0432` contain current official Kubernetes and CSI sources. Storage behavior is driver, backend, filesystem, topology and version dependent. Before publication, pin every component, run all faults and restore, measure RPO/RTO, prove backend cleanup and review sources. Model output is never data-protection evidence.
