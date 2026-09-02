---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0001",
  "aliases": ["V01-L01", "storage"],
  "curriculumIds": ["LNX-001"],
  "slug": "storage",
  "route": "/book/linux/storage",
  "order": 1,
  "volume": "01-linux-systems",
  "title": "Linux storage: paths, mounts, blocks, inodes, and ENOSPC",
  "summary": "Trace an exact failing path to its filesystem and independent allocation limits, distinguish blocks from inodes and quotas, locate the responsible population, recover without deleting by guesswork, and verify the real user operation.",
  "domain": "linux",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 260,
  "prerequisiteLessonIds": [],
  "prerequisiteCurriculumIds": ["FND-001", "DBG-001"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The primary walkthrough is read-only and runs as a normal user with coreutils, util-linux, findutils, and procps."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04", "support": "supported", "notes": "Linux-native and Windows-backed mounts can differ; always record the filesystem type."},
    {"platform": "Docker container", "version": "Linux container", "support": "concept-only", "notes": "Paths can resolve to overlay writable layers, bind mounts, volumes, or tmpfs while limits can belong to another layer."},
    {"platform": "Kubernetes", "version": "Version-dependent", "support": "concept-only", "notes": "Pod filesystems, emptyDir, PVCs, ephemeral-storage accounting, quotas, and node filesystems are separate boundaries."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "kubernetes-platform-engineer", "data-platform-engineer"],
  "learningObjectives": [
    "Explain directory entries, inodes, data and metadata blocks, links, allocation, deletion, and open-file lifetime without calling an inode a cache.",
    "Map an exact application path to its mount, filesystem type, source, namespace, and relevant capacity owner before reading percentages.",
    "Decode df block and inode fields, du allocation estimates, stat metadata, find counts, lsof deleted-open evidence, and quota output with units and proof limits.",
    "Distinguish block, inode, quota, reservation, backend, container, and application limits from look-alike errors.",
    "Find the population responsible for growth while bounding traversal cost and avoiding cross-filesystem or unsafe deletion.",
    "Design reversible recovery with authorization, retained-data protection, positive write verification, cleanup, monitoring, and prevention."
  ],
  "productionSignals": [
    "An application reports No space left on device while df -h shows free capacity.",
    "df -i reports zero available inodes for the filesystem containing the failing path.",
    "A log, cache, upload, mail, CI workspace, or container layer produces millions of small objects.",
    "A large file was removed but filesystem usage did not fall because a process still holds it open.",
    "The host root filesystem is healthy while a container volume, tmpfs, PVC, quota, or writable layer is exhausted.",
    "A cleanup freed capacity briefly, but the producer immediately recreates the population.",
    "A filesystem remounts read-only or returns I/O errors and the symptom is treated as capacity pressure.",
    "A recursive delete is proposed without owner, retention rule, preview, abort condition, or recovery proof."
  ],
  "diagrams": [
    {"id": "LES-0001-DIA-001", "title": "Name, inode, and content relationship", "direction": "left-to-right", "boundaries": ["directory entry and filename", "inode number and metadata", "data and metadata blocks", "filesystem allocator"], "evidencePoints": ["find or ls name", "stat inode/link/type/size", "stat allocated blocks and du", "df blocks and df inodes"], "textAlternative": "A directory entry maps a name to an inode; the inode holds object metadata and references allocated content blocks; the filesystem independently accounts for block and inode capacity."},
    {"id": "LES-0001-DIA-002", "title": "Exact-path storage ownership", "direction": "top-to-bottom", "boundaries": ["application operation", "process root and mount namespace", "resolved path", "mount target and filesystem", "block/inode/quota/backend limits", "user-visible result"], "evidencePoints": ["syscall and errno", "PID and namespace", "application path", "findmnt target/source/type", "df, quota, platform evidence", "controlled write or request"], "textAlternative": "Start from the failed operation, resolve its path and mount in the same filesystem view, test each independent allocation limit, then verify recovery through the original operation."},
    {"id": "LES-0001-DIA-003", "title": "Safe ENOSPC recovery loop", "direction": "cyclic", "boundaries": ["capture", "map", "classify", "locate", "authorize", "change", "verify", "prevent"], "evidencePoints": ["operation and errno", "exact mount", "blocks/inodes/quota", "bounded population count", "owner/retention/backup", "previewed narrow action", "headroom and user journey", "producer control and alert"], "textAlternative": "Capture the failure, map the path, classify the resource, locate and authorize a population, apply one bounded change, verify the real operation, and prevent recurrence."}
  ],
  "commands": [
    {"id": "LES-0001-CMD-001", "question": "Which filesystem contains the exact failing path?", "risk": "read-only", "command": "findmnt -T PATH -o TARGET,SOURCE,FSTYPE,OPTIONS,MAJ:MIN", "runFrom": "The failing process mount namespace when possible, using the exact existing path.", "expectedBranches": [{"when": "tmpfs, overlay, bind, network storage, or another mount appears", "meaning": "The path is not governed by the familiar host root filesystem.", "nextEvidence": "Keep capacity commands scoped to this path and identify its owner."}, {"when": "the path is absent or resolves differently", "meaning": "The observation context does not match the failing process.", "nextEvidence": "Check container or Pod namespace, chroot, symlinks, and runtime path."}], "proves": "The selected mount record visible to this process for this path.", "doesNotProve": "Free blocks, inodes, quota headroom, backend health, or another namespace's mount."},
    {"id": "LES-0001-CMD-002", "question": "Does the filesystem have allocatable block capacity for this caller?", "risk": "read-only", "command": "df -hT -- PATH; df -B1 --output=source,fstype,size,used,avail,pcent,target -- PATH", "runFrom": "The same namespace and exact path used for mapping.", "expectedBranches": [{"when": "Avail is near zero", "meaning": "Filesystem block capacity is a supported hypothesis.", "nextEvidence": "Find allocation owners, reservations, snapshots, deleted-open files, and growth rate."}, {"when": "substantial Avail remains", "meaning": "Ordinary visible filesystem blocks are not exhausted.", "nextEvidence": "Check inodes, quota, runtime/backend limits, reservations, and exact errno."}], "proves": "Filesystem-level total, used, caller-visible available allocation, type, and mount.", "doesNotProve": "Inode or quota headroom, physical health, thin/backend capacity, permission, or application success."},
    {"id": "LES-0001-CMD-003", "question": "Can the filesystem allocate another inode or object?", "risk": "read-only", "command": "df -i -- PATH", "runFrom": "The same namespace and exact path.", "expectedBranches": [{"when": "IFree is zero", "meaning": "A new object can fail while data blocks remain.", "nextEvidence": "Locate high-object-count populations with bounded same-filesystem traversal."}, {"when": "inode headroom is healthy", "meaning": "Visible inode exhaustion is not supported.", "nextEvidence": "Investigate blocks, quota, runtime, backend, directory, or application limits."}], "proves": "Reported filesystem inode totals, used, free, and percentage.", "doesNotProve": "Which directory owns inodes, deletion authorization, quota, or universal allocation behavior."},
    {"id": "LES-0001-CMD-004", "question": "Which bounded subtree contains many objects?", "risk": "sampled-read-only", "command": "du --inodes -x -d 1 -- START_PATH | sort -n", "runFrom": "A narrow approved starting directory on the affected filesystem.", "expectedBranches": [{"when": "one subtree dominates", "meaning": "It is a candidate population, not automatic deletion scope.", "nextEvidence": "Identify producer, types, names, ages, open state, retention, backup, and owner."}, {"when": "scan cost rises", "meaning": "Recursive traversal can worsen pressure.", "nextEvidence": "Stop, narrow by service boundary, and prefer indexed or platform telemetry."}], "proves": "Counts from the traversal that completed under the specified path.", "doesNotProve": "An atomic snapshot, causality, disposability, hidden metadata, or open-unlinked allocation."},
    {"id": "LES-0001-CMD-005", "question": "Did deleted files remain allocated because a process still has them open?", "risk": "sampled-read-only", "command": "lsof +L1", "runFrom": "An authorized host or container namespace with bounded output; elevation is a separate approval.", "expectedBranches": [{"when": "a large deleted entry matches the filesystem", "meaning": "Its name is gone but storage remains until the final open description closes.", "nextEvidence": "Coordinate safe reopen, reload, or restart based on durability and availability."}, {"when": "nothing appears", "meaning": "No visible matching entry was found under current privileges.", "nextEvidence": "Record visibility limits and continue other hypotheses."}], "proves": "Visible open file descriptions with link count below one.", "doesNotProve": "Complete visibility, safe restart, inode exhaustion, or immediately reclaimable space."},
    {"id": "LES-0001-CMD-006", "question": "What metadata and allocation belong to one suspicious object?", "risk": "read-only", "command": "stat -c 'dev=%D inode=%i links=%h type=%F bytes=%s blocks512=%b owner=%u:%g mode=%a name=%n' -- PATH", "runFrom": "The exact authorized object in the relevant namespace.", "expectedBranches": [{"when": "bytes is large but blocks512 is small", "meaning": "The file may be sparse.", "nextEvidence": "Use du and filesystem evidence without filling holes."}, {"when": "links exceeds one", "meaning": "Multiple names reference the same inode.", "nextEvidence": "Do not sum names as independent storage or expect one unlink to reclaim it."}], "proves": "Returned device/inode identity, links, type, logical bytes, allocated units, owner, and mode.", "doesNotProve": "Exclusive ownership, retention, future stability, or safe removal."}
  ],
  "labs": [
    {"id": "LES-0001-LAB-001", "title": "Read the storage boundary for one Ubuntu path", "mode": "guided", "environment": "Ubuntu 24.04, normal user, one authorized non-sensitive existing path", "timeMinutes": 25, "privilege": "No sudo or root; read-only observation.", "network": "No network access.", "changes": ["No filesystem mutation; commands only observe the chosen path and current process."], "abortConditions": ["The shell is root.", "The target is sensitive or unauthorized.", "The target does not exist.", "A required command is missing.", "Any step would recursively scan a large filesystem."], "recovery": "No recovery is required because the walkthrough is read-only.", "cleanupProof": "bash lab.sh cleanup reports cleanup=not-required, mutation=none, and cleanup_proven=true.", "path": "book/labs/LES-0001-storage-observation"}
  ],
  "incidents": [
    {"id": "LES-0001-INC-001", "signal": "Upload creation returns ENOSPC; df -h reports 48% used and df -i reports 100% used.", "firstThought": "The exact filesystem has block headroom but no visible inode headroom.", "safePath": "Map the mount, locate a bounded same-filesystem population, authorize retention, then verify inode headroom and the upload journey.", "trap": "Delete the largest file or run a broad wildcard cleanup."},
    {"id": "LES-0001-INC-002", "signal": "A 40 GiB log was removed but df usage did not fall.", "firstThought": "An open file description may retain the unlinked inode and blocks.", "safePath": "Match deleted-open evidence to device/inode and process, then coordinate a safe reopen or service action.", "trap": "Keep deleting unrelated files or kill the process without understanding state."},
    {"id": "LES-0001-INC-003", "signal": "A Pod reports ENOSPC although node root and PVC dashboards appear healthy.", "firstThought": "The path may be overlay, emptyDir/tmpfs, ephemeral-storage, quota, or another boundary.", "safePath": "Observe inside the container, map source/type, inspect Pod/node and backend limits, then verify the original write.", "trap": "Resize the PVC before proving the path resides on it."}
  ],
  "assessmentIds": ["ASM-0271", "ASM-0272", "ASM-0273"],
  "referenceIds": ["REF-1215", "REF-1216", "REF-1217", "REF-1218", "REF-1219", "REF-1220"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-09-02",
  "reviewAfter": "2027-03-02",
  "limitations": [
    "The Ubuntu walkthrough is read-only and does not exhaust storage, create thousands of files, change quotas, mount filesystems, or delete data.",
    "Allocation differs across ext4, XFS, Btrfs, overlayfs, tmpfs, network storage, thin provisioning, snapshots, containers, and managed backends.",
    "Some evidence needs elevated or platform-specific access; absence under limited visibility is not proof a mechanism is absent.",
    "Formal review, browser QA, representative failure injection, independently reviewed transfer, delayed recall, and mastery remain unproved."
  ]
}
---

# Linux storage: paths, mounts, blocks, inodes, and ENOSPC

## What you see and first thought

An application says `No space left on device`. Your first instinct may be “the disk is full.” That sentence is too early and too vague.

Linux returned an allocation failure for one operation on one path in one filesystem view. The unavailable resource may be data blocks, metadata blocks, inodes, a user/group/project quota, a reserved pool, a tmpfs limit, a container writable layer, Kubernetes ephemeral storage, a thin pool, or a remote storage limit. An application may also hide the original errno behind a generic message.

Keep this operator sentence: **map the path, name the resource, find its owner, authorize the change, and retest the real operation.** Do not begin with deletion. `df` diagnoses a boundary; it does not grant permission to remove data.

## Terms before commands

**Filesystem:** The structure that maps names to objects and manages metadata and allocation. It is not identical to a physical disk: it can live on a partition, logical volume, tmpfs, network service, container layer, or virtual device.

**Path:** A name used to reach an object. The same text can resolve to different mounts inside a host, container, chroot, or Pod.

**Mount:** The attachment of a filesystem into a process-visible directory tree. The most specific matching mountpoint governs a path.

**Directory entry:** A mapping from one name in a directory to an inode number. The filename is not the inode.

**Inode:** A filesystem object record containing type, numeric owner, mode, timestamps, link count, size, and references to data or metadata. It is not a cache and does not normally contain the filename.

**Data block:** A filesystem allocation unit used for content and sometimes metadata. `df` reports filesystem allocation, not a simple sum of visible file sizes.

**Hard link:** Another directory entry referencing the same inode. Removing one name does not free the inode while another link or open description remains.

**Symbolic link:** A separate inode whose content names another path. It consumes an object and can cross mount or ownership boundaries.

**Sparse file:** A file whose logical size contains holes without ordinary content blocks. `ls -l` size and `du` allocation can differ legitimately.

**ENOSPC:** The errno commonly rendered “No space left on device.” It says allocation failed, not which layer or resource failed.

**EDQUOT:** A quota boundary was exceeded. Preserve the original syscall and errno because applications can obscure this difference.

**Deleted-open file:** A name was unlinked while a process still holds the file open. Its inode and blocks remain until the final reference closes.

**Headroom:** Capacity held for bursts, recovery, compaction, failover, rollback, and investigation. For many systems, 100% is already beyond safe recovery.

## Architecture map

```text role=diagram lines=off
application create/write /var/lib/api/uploads/7f9c.tmp
                         |
PID root + mount namespace + resolved path
                         |
findmnt -> mount target / source / filesystem type
                         |
filesystem allocator
      | blocks | inodes | metadata | reservation | quota |
                         |
device / thin pool / snapshot / remote backend / node limit
                         |
errno -> application message -> user-visible result
```

Start at the failed operation and walk down. Starting at a dashboard named “disk” can send you to an unrelated filesystem.

## Request or state path

Suppose an upload service creates `/var/lib/api/uploads/7f9c.tmp`:

1. the process resolves the path in its root and mount namespace;
2. directory entries lead toward the filesystem mounted over the longest matching prefix;
3. the filesystem must create or update a directory entry and inode;
4. content growth may allocate data blocks, extent metadata, journal space, or copy-on-write extents;
5. quota and reservation rules can reject allocation while global counters look healthy;
6. lower storage can impose a separate capacity or health boundary;
7. only a successful application operation establishes user recovery.

Creating an empty file needs an inode and directory metadata even though it holds almost no content. Extending one existing large file consumes blocks without creating another inode. That is why `df -hT` and `df -i` answer independent questions.

## Failure zoom

### Free blocks, no inodes

Millions of small cache fragments, mail messages, sessions, extracted dependencies, or CI artifacts can exhaust object records while many GiB remain. Deleting one 10 GiB file typically releases one inode; it is the wrong shape of remedy for an object-count problem.

### Blocks full, inode headroom healthy

Large logs, uploads, databases, layers, snapshots, or deleted-open files can consume allocation. “Delete old files” is still not a plan: identify the exact mount, producer, retention contract, open state, backup, and safe population.

### Both counters look healthy

Check exact errno and context. Candidate limits include user/group/project quota, reserved space, tmpfs size, Kubernetes ephemeral storage, PVC/backend allocation, overlay writable-layer constraints, thin pools, directory limits, and application ceilings.

### Deleted file, no reclaimed capacity

`unlink` removes a name. An object remains while another hard link or open file description exists. A controlled reopen can release it; an uncontrolled kill may create a larger outage or lose buffered state.

### Read-only or I/O failure

`EROFS`, `EIO`, and `EACCES` are not ordinary capacity failures. A filesystem may remount read-only after errors. Preserve kernel/storage evidence and protect data rather than forcing writes.

## Internals and state ownership

A directory contains name-to-inode mappings. An inode represents one object and holds metadata plus references needed to locate data. Hard links share that inode; symlinks do not. The inode becomes reclaimable only when link and open-reference lifetime permits it.

`st_size` is logical bytes. `st_blocks` is allocated space expressed in 512-byte units by `stat`. `du` walks named objects and estimates allocation visible through that traversal. `df` asks the filesystem allocator about the whole filesystem. They can disagree without either being broken:

- sparse files contain logical holes;
- compression, reflinks, snapshots, and shared extents complicate ownership;
- metadata, journals, reservations, and deleted-open files are not a sum of visible names;
- concurrent writers change state during measurement;
- namespace and permission boundaries change visibility.

On ext4, inode availability is largely selected when the filesystem is created. Other filesystems allocate or report object capacity differently. Never make one filesystem's implementation a universal rule.

Capacity ownership crosses teams. An application team owns the producer, a platform team may own node ephemeral storage, and a storage team may own the backend. Good incident command connects these boundaries and names decision authority.

## Evidence table

| Question | Evidence | What it supports | What remains open |
|---|---|---|---|
| What failed? | syscall/errno, operation, path, PID, time | Exact symptom and caller | Cause and recovery |
| Which filesystem? | `findmnt -T PATH` in matching namespace | Visible mount/source/type/options | Hidden backend and limits |
| Blocks exhausted? | `df -hT PATH`, byte-form `df` | Filesystem allocator counters | Quota, inodes, lower layer |
| Inodes exhausted? | `df -i PATH` | Reported object-record headroom | Responsible population |
| Which population is large? | bounded `du --inodes` or `find` count | Traversed object distribution | Causality and deletion authority |
| Why did deletion not reclaim? | `lsof +L1`, device/inode/process | Visible open-unlinked candidates | Safe close/restart action |
| Is quota involved? | filesystem/platform quota evidence | Subject/project limit and use | Correct owner and resize policy |
| Is recovery complete? | headroom plus controlled real request | Capacity and user operation recovered | Recurrence and prevention |

Always attach scope, time, unit, identity, and visibility. A percentage without its mount and resource name is weak evidence.

## Command decoders

### `findmnt -T PATH -o TARGET,SOURCE,FSTYPE,OPTIONS,MAJ:MIN`

`-T` asks which mounted filesystem contains the path. `TARGET` is the mountpoint, `SOURCE` the visible source, `FSTYPE` the implementation such as ext4, tmpfs, overlay, or NFS, `OPTIONS` includes state such as `ro`, and `MAJ:MIN` can join a block-backed mount to device views. Scripts should request explicit columns because defaults can change.

### `df -hT -- PATH`

`df` reports filesystem allocation, not directory size. `-h` uses powers-of-1024 display units; `-T` includes type. `Size` is the reported total, `Used` allocated space, `Avail` caller-visible available allocation, and `Use%` a rounded ratio. Reserved space can make arithmetic surprising. The path selects the filesystem.

### `df -i -- PATH`

`Inodes` is reported object-record capacity, `IUsed` allocated records, `IFree` available records, and `IUse%` rounded utilization. Zero `IFree` supports inode exhaustion; it does not identify which directory is disposable.

### `du --inodes -x -d 1 START_PATH`

`--inodes` counts encountered objects rather than content bytes. `-x` stays on one filesystem and `-d 1` limits reported depth, although traversal can still be expensive. Concurrent change means the result is not atomic.

### `stat`

Device plus inode identifies an object within the visible filesystem; link count explains hard-link lifetime; bytes is logical size; `blocks512` is allocated 512-byte units; type separates regular file, directory, link, and special objects. One object never explains a whole filesystem.

### `lsof +L1`

`+L1` selects visible open files with link count below one, commonly deleted-open objects. Match process, mount/device, inode, size, and application safety. Missing results under limited privilege are an evidence gap, not proof.

## Decision path

Use this sequence under pressure:

1. **Capture:** exact operation, path, syscall/errno, process/container/Pod, first/last failure, and recent change.
2. **Map:** observe in the failing namespace and run `findmnt -T` on the exact existing path.
3. **Classify:** compare blocks and inodes, then quota, reservation, runtime/backend, and look-alike errors.
4. **Locate:** start at the smallest service-owned directory; bound filesystem and depth; stop if scanning adds dangerous load.
5. **Authorize:** name producer, purpose, retention, legal/security constraints, backup, approver, rollback, and protected data.
6. **Preview:** count and sample the exact match set. A name such as `cache` is not authorization.
7. **Change:** use one narrow action and reduce the producer before it refills capacity.
8. **Verify:** re-read the constrained resource and retry a controlled original operation. Prove retained data survives.
9. **Prevent:** bound retention/object count, add owned quotas/headroom, forecast exhaustion, and test cleanup.

Do not automatically run `find /`. Recursive metadata walks can worsen an unhealthy filesystem. Prefer service boundaries, indexed inventory, or platform telemetry when available.

## Guided Ubuntu lab

The lab is intentionally simple: a read-only worksheet, not a manufactured outage. From the repository root:

```bash role=command file=book/labs/LES-0001-storage-observation/lab.sh lines=on
bash book/labs/LES-0001-storage-observation/lab.sh check
bash book/labs/LES-0001-storage-observation/lab.sh observe "$HOME"
bash book/labs/LES-0001-storage-observation/lab.sh cleanup
```

Choose an existing non-sensitive path you own. Read the output in order: environment, exact mount, block capacity, inode capacity, and target metadata. Explain each field with the decoders. The script never recursively scans or mutates the target.

Success sounds like: “This path resolves to this mount and filesystem; it has these separate block and inode counters; this target has this inode/link/logical/allocation metadata; none of that authorizes deletion.”

## Production transfer

### Container

Map from inside the failing container. `/var/lib/app` might be overlay, bind mount, named volume, or tmpfs. Host `/` capacity is not evidence for that path. Join container evidence to runtime/host ownership without assuming the container sees the backing device.

### Kubernetes

Classify the path: writable layer, logs, `emptyDir`, memory-backed `emptyDir`, projected data, hostPath, or PVC. Treat Pod requests/limits, node ephemeral storage, kubelet garbage collection, PVC/backend quota, and CSI behavior as separate. Resizing a PVC does nothing for a full writable layer.

### VM and cloud volume

Separate guest filesystem, partition or logical volume, virtual disk, snapshot, thin layer, and provider volume. Increasing a provider disk does not automatically grow every inner layer. Plan each boundary and rollback.

### Data platform

Databases and streams can reserve, preallocate, compact, spill, retain WAL/log segments, or hold snapshots. Out-of-band file deletion can corrupt state. Use product-supported retention and verify replication, checkpoints, and restore requirements.

## Reliability, security, observability, capacity, and cost

**Reliability:** Protect recovery headroom, not merely “some free bytes.” Compaction, failover, log rotation, rollback, and repair need blocks and objects.

**Security:** Paths can reveal customer, tenant, or token data. Sanitize evidence. Cleanup needs an exact auditable population and least privilege; never paste broad destructive commands into incident chat.

**Observability:** Monitor blocks and inodes by stable mount identity, growth rate, time-to-exhaustion, quota, cleanup success, producer rate, and user operation. A universal 80% alert ignores growth and recovery needs.

**Capacity:** Forecast bytes and objects separately. Include metadata, snapshots, rebuild/compaction amplification, retention, bursts, failure-domain loss, and time required to clean safely.

**Cost:** Count capacity, IOPS/throughput tiers, snapshots, requests, replication, transfer, observability, recovery time, and toil. More storage buys response time but can hide an unbounded producer.

## Traps and prevention

### `ENOSPC` always means full disk

Prevent this with exact path, mount, blocks, inodes, quota, runtime/backend, and exact-errno checks.

### Inode means metadata cache

An inode is a filesystem object record. Kernel caches may hold inode and dentry structures in memory, but filesystem inode exhaustion is not “cache full.”

### Delete the largest file for inode pressure

One large regular file normally consumes one inode. Find the authorized high-object-count population.

### `du` must equal `df`

They use different accounting boundaries. Consider open-unlinked files, metadata, reservations, snapshots/shared extents, visibility, sparse allocation, and concurrency.

### “Cache” means disposable

Names are clues, not policy. Require producer, age, retention, backup, owner, preview, and protected exclusions.

### Recovery means a green `df`

Capacity is internal state. Recovery requires the original user operation, correct retained data, stable headroom, controlled producer, and recurrence watch.

## Memory card and retrieval

```text role=diagram lines=off
BLOCKS = how much allocated storage remains?
INODES = how many filesystem objects can still be represented?

PATH -> MOUNT -> LIMIT -> POPULATION -> AUTHORITY -> ACTION -> USER JOURNEY
```

Answer aloud:

1. Why can 10 GiB be free while creation returns ENOSPC?
2. Why must both `df` commands receive the failing path?
3. Why does deleting one large file barely help inode exhaustion?
4. Why can `du` be smaller than `df`?
5. What must be known before deleting a cache population?
6. What proves recovery beyond a percentage?
7. How does a container mount namespace change where you observe?

Review tomorrow, in three days, one week, and one month. Redraw and explain; do not merely reread.

## Complete answers

### 1. Free bytes but ENOSPC

Creating a file requires an inode and directory metadata. If `df -i` for the exact mount reports no free inodes, allocation can fail while `df -hT` shows free blocks. Quota, tmpfs, overlay, and backend limits remain alternatives until checked.

### 2. Exact path

Capacity belongs to a filesystem, not a directory spelling. The path selects the governing mount in the observer's namespace. Checking `/` while the application writes to a separate volume measures the wrong system.

### 3. Large-file deletion

One file normally occupies one inode regardless of content size. Removing it may release many blocks but only one object record. Inode recovery needs an authorized high-object-count population.

### 4. `du` smaller than `df`

`du` walks reachable names; `df` reports allocator state. Open-unlinked files, metadata, reservations, snapshots/reflinks, inaccessible names, sparse allocation, and concurrent writes can create a gap.

### 5. Deletion authority

Know the mount, exact match set, producer, type, age, purpose, retention and legal policy, active/open state, backup/restore, exclusions, approver, preview, maximum scope, abort, rollback, and verification. A directory name proves none of these.

### 6. Recovery proof

Re-read the constrained counter, execute a controlled failed user operation, and verify the correct result. Confirm retained data, errors/retries, producer rate, cleanup outcome, and stable headroom.

### 7. Namespace

A container or Pod sees its own mount tree. Map where failure occurs, then join that identity to node/runtime/storage evidence. Host root capacity cannot prove a volume, tmpfs, overlay, or PVC has space.

## Product-company interview

Scenario: a payments upload API in Kubernetes returns ENOSPC. Node `/` is 52% used, the PVC dashboard is 61%, and restarting the Pod moves the symptom temporarily.

A strong answer:

1. protects the user/payment invariant and captures operation, errno, container, Pod, node, path, and timeline;
2. maps the exact path from the failing container;
3. classifies writable layer, `emptyDir`, tmpfs, log, hostPath, or PVC;
4. compares blocks, inodes, quota, Pod/node ephemeral storage, PVC/backend, and read-only/I/O look-alikes;
5. identifies producer and bounded population while preserving open/deleted and retention evidence;
6. chooses one authorized reversible mitigation with prediction, scope, abort, and rollback;
7. verifies upload response and durable object, retained data, retries, headroom, and recurrence;
8. prevents with lifecycle, rate/headroom telemetry, tested cleanup, and capacity ownership.

Restart relocation suggests Pod/node-local state may matter; it does not prove it. Compare old and new placement. Weak answers include “increase disk,” “delete `/tmp`,” and “PVC is 61%, so storage is fine.”

## Independent transfer and rubric

`ASM-0273` asks you to diagnose an unfamiliar storage evidence package without destructive commands or a model answer. Submit:

- operation/path/namespace/environment card;
- path-to-mount-to-limit diagram;
- normalized block, inode, quota, object-count, and deleted-open evidence with proof limits;
- four ranked hypotheses and rejection criteria;
- one bounded recovery with owner, prediction, abort, rollback, retained-data protection, and user verification;
- prevention and assistance disclosure.

The reviewer scores safety/provenance, model, evidence reasoning, remediation judgment, and transfer. Automated output cannot award mastery. Guided help invalidates this attempt; learn, then use a fresh evidence package.

## References and review

- `REF-1215`: GNU `df` manual for filesystem allocation and exact-path selection.
- `REF-1216`: util-linux `findmnt` manual for target-path mount resolution.
- `REF-1217`: Linux `inode(7)` manual for inode metadata and object semantics.
- `REF-1218`: Linux `unlink(2)` manual for link and open-file lifetime.
- `REF-1219`: Linux ext4 documentation for blocks and inode structures.
- `REF-1220`: GNU `du` manual for allocation and inode-count traversal.

Claims are paraphrased. Installed manuals govern exact local fields; filesystem/provider documentation governs the observed type. Formal technical/instructional review, representative transfer, browser QA, and independently reviewed learner evidence remain open.

The final boundary is simple: reading creates a model; commands create observations; a reviewer evaluates original reasoning. None alone proves production mastery.
