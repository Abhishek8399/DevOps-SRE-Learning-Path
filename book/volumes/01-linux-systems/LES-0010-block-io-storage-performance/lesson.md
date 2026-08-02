---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0010",
  "aliases": ["V01-L07", "block-io-storage-performance"],
  "curriculumIds": ["LNX-006"],
  "slug": "block-io-storage-performance",
  "route": "/book/linux/block-io-storage-performance",
  "order": 7,
  "volume": "01-linux-systems",
  "title": "Block I/O and storage performance: follow the wait",
  "summary": "Trace reads, buffered writes, writeback, and durable commits from a path through Linux filesystems and block queues; decode storage metrics without confusing space, activity, latency, throughput, or saturation; and restore a slow path safely.",
  "domain": "linux",
  "level": {
    "from": "foundation",
    "to": "advanced"
  },
  "estimatedMinutes": 240,
  "prerequisiteLessonIds": ["LES-0001", "LES-0003"],
  "prerequisiteCurriculumIds": ["LNX-001", "LNX-003"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "The guided lab runs as a normal non-root user with Bash, Python 3.8 or newer, and base utilities. It creates only tiny guarded files in /tmp and uses deterministic virtual metrics rather than real I/O pressure. Read-only host observations use util-linux and procps tools already present; sysstat commands are optional and are never installed automatically."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "The deterministic lab is supported. Real device topology and timing visible inside WSL can represent virtualized or Windows-backed layers, so observations must not be presented as physical-device performance."
    },
    {
      "platform": "Docker or OCI container",
      "version": "Provider-neutral concepts",
      "support": "concept-only",
      "notes": "A container normally shares the host kernel and may see a namespaced filesystem while block-device and page-cache signals remain host- or node-scoped. No container is launched by this lesson."
    },
    {
      "platform": "Kubernetes, virtual machines, network block storage, and storage arrays",
      "version": "Provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production-transfer sections map identities and hidden layers but create no cluster, account, volume, loop device, mount, benchmark, or paid resource."
    }
  ],
  "targetRoles": [
    "site-reliability-engineer",
    "devops-engineer",
    "platform-engineer",
    "production-engineer",
    "cloud-infrastructure-engineer",
    "kubernetes-platform-engineer",
    "data-platform-engineer",
    "database-reliability-engineer"
  ],
  "learningObjectives": [
    "Separate filesystem capacity, page-cache state, block-device activity, IOPS, throughput, latency, concurrency, queueing, utilization, saturation, and durability instead of calling every symptom disk pressure.",
    "Map an exact application path through its mount, filesystem source, major:minor identity, logical-device layers, block queue, driver, virtualization or storage network, and durable-storage boundary.",
    "Explain buffered reads and writes, clean and dirty pages, background writeback, writer throttling, synchronous write, fsync, fdatasync, file metadata, directory metadata, and device-cache flush at the level required for safe operations.",
    "Decode `findmnt`, `lsblk`, `df`, `/proc/meminfo`, `vmstat`, `iostat`, `pidstat`, `sar`, and kernel disk-stat fields by source, interval, unit, aggregation, reset behavior, proof, and proof limit.",
    "Reason from latency, operation rate, request size, queue depth, percentiles, and Little's Law without comparing incompatible request definitions or claiming steady state when a queue is growing.",
    "Distinguish high activity from saturation and interpret `%util` according to device concurrency, logical-device layering, and virtualization rather than as a universal percent-of-maximum gauge.",
    "Investigate a slow-storage incident from the user operation toward the first observed abnormal boundary, rank competing mechanisms, preserve evidence, and avoid unsafe load generation or tuning.",
    "Choose bounded remediation that protects data semantics, verify the real operation and durable result, reconcile queued work, and design prevention across reliability, security, observability, capacity, and cost."
  ],
  "productionSignals": [
    "Request latency rises while CPU and filesystem space look normal, and time is concentrated in a database commit, file sync, image pull, checkpoint, or log flush.",
    "Write throughput stays nearly constant while write completion latency and outstanding requests rise sharply.",
    "Linux reports more dirty or writeback memory and tasks blocked on I/O while an application remains running but stops making useful progress.",
    "One logical device reports continuous activity, but the affected path maps through device mapper, a virtual disk, a network volume, or another hidden lower layer.",
    "A background backup, compaction, scan, image pull, checkpoint, or reporting job coincides with latency for a foreground workload that shares a lower failure domain.",
    "A container or pod appears to write modestly while node-level block latency rises, or several claims that look separate share one pool, node, or attachment path.",
    "A service recovers after restart or relocation, but queues, dirty pages, retry pressure, or unreconciled durable operations remain.",
    "A dashboard shows `%util=100`, high `wa`, or a large process I/O rate and the team treats the single field as root cause."
  ],
  "diagrams": [
    {
      "id": "LES-0010-DIA-001",
      "title": "Linux file-to-storage data path",
      "direction": "left-to-right",
      "boundaries": ["application operation", "system call and VFS", "page cache", "filesystem and journal", "block layer and blk-mq", "driver or virtual device", "storage transport or hypervisor", "durable media or managed service"],
      "evidencePoints": ["operation latency and result", "read/write/fsync return", "Cached Dirty Writeback", "mount and filesystem identity", "request rate await aqu-sz util", "major:minor and parent map", "provider or backend latency and throttle", "durability acknowledgement and errors"],
      "textAlternative": "An application read, write, or sync crosses the system-call and virtual-filesystem boundary, may use the page cache, passes through filesystem metadata or journaling, becomes block requests in Linux queues, reaches a driver or virtual device, may cross a hypervisor or storage network, and is acknowledged by the final durability owner; evidence at each handoff has a different scope."
    },
    {
      "id": "LES-0010-DIA-002",
      "title": "Buffered write, writeback, and durable commit",
      "direction": "top-to-bottom",
      "boundaries": ["application modifies bytes", "page becomes dirty", "write returns or waits", "background or caller writeback", "filesystem orders data and metadata", "block requests queue and complete", "cache flush or force-unit-access", "application receives sync result"],
      "evidencePoints": ["write and sync latency", "Dirty memory", "Writeback memory", "blocked tasks and writeback workers", "filesystem and journal events", "write await and outstanding work", "flush counters and lower telemetry", "real durable-operation verification"],
      "textAlternative": "A buffered write can return after memory is modified, while durability waits for later writeback, filesystem ordering, block completion, and required cache flushes; a successful sync result is a stronger boundary than a successful buffered write but still depends on correct filesystem and storage contracts."
    },
    {
      "id": "LES-0010-DIA-003",
      "title": "Queue growth and the performance decision loop",
      "direction": "cyclic",
      "boundaries": ["offered operations", "admission and concurrency", "filesystem and block requests", "device or service completions", "latency and queue feedback", "bounded control", "user-operation verification"],
      "evidencePoints": ["arrival and completion rates", "request mix and sync frequency", "aqu-sz and blocked work", "IOPS throughput and await", "p95 p99 and oldest work", "throttle pause failover or repair", "correct durable outcome and recurrence window"],
      "textAlternative": "Offered work becomes admitted concurrent requests, flows through filesystem and block queues, and completes at a device or service rate; when arrivals outrun useful completions, queued work and latency rise, so a bounded control must reduce demand or restore service and then verify the real operation rather than one device metric."
    }
  ],
  "commands": [
    {
      "id": "LES-0010-CMD-001",
      "question": "Which Ubuntu, kernel, identity, and storage tools does this exact shell expose before any interpretation?",
      "risk": "read-only",
      "command": "cat /etc/os-release; uname -r; id; command -v findmnt lsblk vmstat; command -v iostat pidstat sar || true",
      "runFrom": "The exact Ubuntu 24.04 or WSL 2 Ubuntu 24.04 shell being investigated, as the normal user",
      "expectedBranches": [
        {
          "when": "Ubuntu 24.04, a nonzero UID, and the base tools resolve",
          "meaning": "The shell matches the required base observation environment; optional sysstat tools may or may not be present.",
          "nextEvidence": "Record versions and virtualization boundary, then resolve the affected path before selecting a device."
        },
        {
          "when": "The release differs, UID is zero, or a base tool is absent",
          "meaning": "The tested contract does not match this shell.",
          "nextEvidence": "Stop the guided lab or document the changed environment; do not install, elevate, or guess field behavior inside the lesson."
        },
        {
          "when": "`iostat`, `pidstat`, or `sar` is absent",
          "meaning": "The optional sysstat package is not available on this environment's PATH.",
          "nextEvidence": "Use the deterministic lab and installed base tools. Package installation is a separate networked and privileged decision, not an automatic step."
        }
      ],
      "proves": "Displayed release metadata, kernel string, effective identity, and command resolution in this shell at that moment.",
      "doesNotProve": "That a command's fields match another version, the shell owns a physical device, optional collection is enabled, or storage is healthy."
    },
    {
      "id": "LES-0010-CMD-002",
      "question": "Which mounted filesystem contains this exact application path?",
      "risk": "read-only",
      "command": "( : \"${TARGET_PATH:?export TARGET_PATH as a reviewed existing path}\"; findmnt --target \"$TARGET_PATH\" --output TARGET,SOURCE,FSTYPE,OPTIONS,MAJ:MIN )",
      "runFrom": "The affected Ubuntu host or approved diagnostic shell after exporting `TARGET_PATH` as the exact reviewed existing path",
      "expectedBranches": [
        {
          "when": "One mount row is returned",
          "meaning": "The path resolves through that mount target, source, filesystem type, option set, and kernel major:minor identity.",
          "nextEvidence": "Trace the source and major:minor identity with explicit `lsblk` columns; record bind, overlay, network, or device-mapper layers rather than assuming a disk."
        },
        {
          "when": "The path is absent, access is denied, or no row is returned",
          "meaning": "The selected path cannot support the intended mapping claim from this shell.",
          "nextEvidence": "Verify path, mount namespace, identity, and authorization without creating the path merely to make the command succeed."
        }
      ],
      "proves": "The mount table entry selected for that path in the current mount namespace and the requested fields.",
      "doesNotProve": "A complete lower device chain, physical location, backend pool, performance, durability, free capacity, or another namespace's mapping."
    },
    {
      "id": "LES-0010-CMD-003",
      "question": "How are visible block devices layered, and which explicit properties describe them?",
      "risk": "read-only",
      "command": "lsblk --exclude 7 --output NAME,MAJ:MIN,TYPE,SIZE,ROTA,SCHED,FSTYPE,MOUNTPOINTS",
      "runFrom": "The same Ubuntu host or approved node shell; output can expose topology, labels, and mount names, so sanitize before sharing",
      "expectedBranches": [
        {
          "when": "A tree of disks, partitions, logical volumes, or virtual devices appears",
          "meaning": "util-linux resolved visible sysfs and udev properties into the requested topology.",
          "nextEvidence": "Match `MAJ:MIN` from `findmnt`, follow parent relationships, and mark any layer that disappears below the guest or managed-service boundary."
        },
        {
          "when": "The mapped source is absent or the topology looks incomplete",
          "meaning": "The current namespace or virtualization boundary hides or represents the source differently.",
          "nextEvidence": "Use the owning host, node, hypervisor, or provider telemetry through an authorized path; do not substitute a similarly named device."
        }
      ],
      "proves": "The requested visible block-device properties and relationships according to this command and namespace.",
      "doesNotProve": "That a tree edge is a unique physical device, ROTA predicts actual latency, SCHED is effective at every layer, or the backend is dedicated."
    },
    {
      "id": "LES-0010-CMD-004",
      "question": "Is filesystem block or inode capacity the immediate limit for this path?",
      "risk": "read-only",
      "command": "( : \"${TARGET_PATH:?export TARGET_PATH as the reviewed existing path}\"; df -hT -- \"$TARGET_PATH\" && df -i -- \"$TARGET_PATH\" )",
      "runFrom": "The exact affected mount namespace after exporting `TARGET_PATH` as the reviewed existing path",
      "expectedBranches": [
        {
          "when": "Block or inode availability is near zero",
          "meaning": "The mounted filesystem reports a capacity constraint at that accounting boundary.",
          "nextEvidence": "Follow the storage-capacity lesson's safe object, quota, deleted-open, and lower-pool investigation; do not call this a latency-only incident."
        },
        {
          "when": "Both have material headroom",
          "meaning": "Filesystem blocks and inode exhaustion are not supported by these two observations.",
          "nextEvidence": "Continue with operation latency, cache/writeback, device queues, errors, quotas, and lower layers; capacity headroom does not prove performance."
        }
      ],
      "proves": "Filesystem-reported block and inode allocation for the mount containing the selected path.",
      "doesNotProve": "Quota, thin-pool, snapshot, backend, reservation, IOPS, throughput, latency, queue, error, or durability health."
    },
    {
      "id": "LES-0010-CMD-005",
      "question": "How much file-backed cache is present, and how much modified memory is dirty or currently under writeback?",
      "risk": "read-only",
      "command": "grep -E '^(Cached|Buffers|Dirty|Writeback):' /proc/meminfo",
      "runFrom": "The affected Linux kernel namespace during the same interval as application and device observations",
      "expectedBranches": [
        {
          "when": "Dirty grows and remains high while Writeback is nonzero",
          "meaning": "More modified memory awaits completed writeback and some pages are being written during the observation.",
          "nextEvidence": "Align repeated samples with writer rate, blocked tasks, filesystem path, device completion, and writeback-worker evidence."
        },
        {
          "when": "Dirty and Writeback remain small",
          "meaning": "Large global dirty-page accumulation is not visible in these snapshots.",
          "nextEvidence": "Continue with synchronous/direct I/O, reads, cgroup or host scope, application locks, device latency, and lower-layer evidence."
        }
      ],
      "proves": "Global kernel memory-accounting values exposed in kibibytes for those fields at each read.",
      "doesNotProve": "Which file, mount, process, cgroup, or device owns the pages; whether cache is good or bad; or why writeback is slow."
    },
    {
      "id": "LES-0010-CMD-006",
      "question": "Do runnable work, tasks blocked for I/O, paging, block transfer, and CPU wait change together over several current intervals?",
      "risk": "sampled-read-only",
      "command": "vmstat -y 1 5",
      "runFrom": "The affected Ubuntu host for five one-second current samples; verify local vmstat supports `-y`",
      "expectedBranches": [
        {
          "when": "`b`, `wa`, or block I/O fields rise with the incident",
          "meaning": "System-wide blocked-task, CPU-accounting, or block-transfer context changes in those intervals.",
          "nextEvidence": "Map the device and process or cgroup, because vmstat is aggregate context rather than attribution."
        },
        {
          "when": "Those fields remain quiet",
          "meaning": "This host-wide sample does not show a large aggregate change.",
          "nextEvidence": "Check narrower scope, tail events, asynchronous I/O, hidden hosts, and the exact operation; averages can miss a small critical cohort."
        }
      ],
      "proves": "Five live aggregate samples using procps field semantics, with the since-boot first line omitted when supported.",
      "doesNotProve": "A particular device or process cause, that `wa` is device latency, or that zero aggregate wait means every operation is fast."
    },
    {
      "id": "LES-0010-CMD-007",
      "question": "Which visible block device has changed request rates, completion time, outstanding work, or busy time in current intervals?",
      "risk": "sampled-read-only",
      "command": "iostat -xz -y 1 3",
      "runFrom": "The affected Ubuntu host if the reviewed sysstat package is already installed; three one-second current reports",
      "expectedBranches": [
        {
          "when": "The mapped device's `await` and `aqu-sz` rise with user latency",
          "meaning": "Average represented request completion time and average outstanding work rose together for that device and interval.",
          "nextEvidence": "Split read/write fields, request size and mix; correlate filesystem, process or cgroup, errors, and lower-layer service telemetry."
        },
        {
          "when": "`%util` is high but `await`, queue, and user latency remain healthy",
          "meaning": "The device was continuously active but the sample does not establish harmful saturation.",
          "nextEvidence": "Compare with the device's known healthy workload and concurrency model before acting."
        },
        {
          "when": "The command is absent",
          "meaning": "Optional sysstat tooling is unavailable.",
          "nextEvidence": "Use the deterministic lab or approved existing telemetry; do not install automatically during diagnosis."
        }
      ],
      "proves": "Interval-derived CPU and visible device statistics computed by that installed iostat version from kernel counters.",
      "doesNotProve": "One process cause, physical media saturation, backend ownership, percentile latency, or that similar device names refer to the affected path."
    },
    {
      "id": "LES-0010-CMD-008",
      "question": "Which visible tasks are reading or writing during the current intervals?",
      "risk": "sampled-read-only",
      "command": "pidstat -d 1 3",
      "runFrom": "The affected Ubuntu host if sysstat is already installed and process visibility is authorized",
      "expectedBranches": [
        {
          "when": "One or more tasks show sustained read or write rates or increasing I/O delay",
          "meaning": "Those tasks have accounted storage activity during the sample.",
          "nextEvidence": "Map PID to service, cgroup/container, file path, original operations, request mix, and device; activity does not establish fault ownership."
        },
        {
          "when": "No task explains device activity",
          "meaning": "The sample, permissions, task lifetime, buffered-write timing, kernel work, or namespace may hide the producer.",
          "nextEvidence": "Check scope, cgroup/container and writeback ownership, longer approved sampling, and application telemetry."
        }
      ],
      "proves": "Task-level I/O accounting visible to the caller over the sampled intervals under the installed pidstat semantics.",
      "doesNotProve": "Which files were accessed, which device served them, that a writer caused latency, or that short-lived or inaccessible tasks are absent."
    },
    {
      "id": "LES-0010-CMD-009",
      "question": "Can historical or live sysstat device samples show when the device behavior changed?",
      "risk": "sampled-read-only",
      "command": "sar -d -p 1 3",
      "runFrom": "The affected Ubuntu host if sysstat is already installed; this form takes three live one-second samples rather than assuming historical collection is enabled",
      "expectedBranches": [
        {
          "when": "Three device samples and an average appear",
          "meaning": "sar collected live device activity and an aggregate over the shown interval.",
          "nextEvidence": "Use timestamps to align with application and incident events; do not confuse the Average row with a percentile."
        },
        {
          "when": "No devices or command-not-found appears",
          "meaning": "The tool or visible data is unavailable in this boundary.",
          "nextEvidence": "Use existing approved telemetry or the lab; enabling persistent collection is a separate storage, retention, and security decision."
        }
      ],
      "proves": "Live sysstat device samples and their arithmetic interval aggregate when the command succeeds.",
      "doesNotProve": "Historical collection existed before the command, an Average row is p95/p99, or a backend hidden below the device was healthy."
    },
    {
      "id": "LES-0010-CMD-010",
      "question": "What raw cumulative block counters does the kernel expose for one already-validated device?",
      "risk": "read-only",
      "command": "( : \"${DEVICE_NAME:?export DEVICE_NAME as the lsblk NAME value}\"; [[ \"$DEVICE_NAME\" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { printf \"refusal=invalid-device-name\\n\" >&2; exit 64; }; [[ -b \"/dev/$DEVICE_NAME\" ]] || { printf \"refusal=not-a-visible-block-device\\n\" >&2; exit 66; }; cat -- \"/sys/class/block/$DEVICE_NAME/stat\" )",
      "runFrom": "The affected Ubuntu host only after exporting `DEVICE_NAME` as the simple slash-free `lsblk` name resolved from the exact path; the command validates its character set and visible block-device node before constructing the sysfs path",
      "expectedBranches": [
        {
          "when": "A whitespace-separated counter row appears",
          "meaning": "The kernel exposes cumulative fields for that device; most reset at boot, reattach, reinitialization, or overflow, while in-progress I/O is a gauge.",
          "nextEvidence": "Use documented field order and two timestamps to calculate deltas; prefer a versioned tool unless raw-counter work is specifically required."
        },
        {
          "when": "The path is absent",
          "meaning": "That device name is not visible through this sysfs boundary.",
          "nextEvidence": "Return to the mount/device mapping; never substitute a guessed device."
        }
      ],
      "proves": "One raw cumulative kernel counter snapshot for the selected visible block device.",
      "doesNotProve": "Rates without a second timestamp, atomic perfection across CPU updates, application attribution, lower-layer performance, or field meaning without matching kernel documentation."
    },
    {
      "id": "LES-0010-CMD-011",
      "question": "Does the deterministic lab accept this normal-user environment before creating state?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0010-block-io-storage-performance/lab.sh check",
      "runFrom": "Repository root in Ubuntu 24.04 or WSL 2 Ubuntu 24.04 as a normal non-root user",
      "expectedBranches": [
        {
          "when": "`environment=ready state=absent candidates=none` appears",
          "meaning": "The implemented UID, /tmp, dependency, fixture, descriptor, and orphan-candidate checks accepted clean state.",
          "nextEvidence": "Run setup, then status; record that all later metrics are synthetic."
        },
        {
          "when": "The command refuses",
          "meaning": "A safety or environment invariant failed.",
          "nextEvidence": "Preserve the refusal and stop. Do not use sudo, manual deletion, or descriptor editing."
        }
      ],
      "proves": "Only that the lab's preflight and applicable point-in-time absence checks accepted this environment.",
      "doesNotProve": "Future lifecycle success, complete filesystem-race safety, real storage performance, or learner understanding."
    },
    {
      "id": "LES-0010-CMD-012",
      "question": "Can the lab create one guarded workspace and expose comparable virtual evidence at each storage boundary?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0010-block-io-storage-performance/lab.sh setup && bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe baseline && bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe incident",
      "runFrom": "Repository root after a successful clean check as the same normal user",
      "expectedBranches": [
        {
          "when": "Setup completes and baseline then incident summaries appear",
          "meaning": "One private guarded workspace exists and the model returned two stable virtual profiles in order.",
          "nextEvidence": "Write a prediction, map the path, then probe mount, system, device, and process views individually."
        },
        {
          "when": "Any command refuses",
          "meaning": "The `&&` chain stops and later commands did not run.",
          "nextEvidence": "Keep the first refusal, run status only if strict state remains valid, and never create manual state."
        }
      ],
      "proves": "The bounded workspace contract and deterministic summaries for the model profiles when all commands succeed.",
      "doesNotProve": "Host or production latency, physical device behavior, a final diagnosis, or mastery.",
      "cleanup": "Complete supported recovery and operation verification, then use the guarded cleanup command."
    },
    {
      "id": "LES-0010-CMD-013",
      "question": "Does the supported model recovery restore the user operation, and can guarded cleanup prove exact absent state?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0010-block-io-storage-performance/lab.sh recover && bash book/labs/LES-0010-block-io-storage-performance/lab.sh verify-operation && bash book/labs/LES-0010-block-io-storage-performance/lab.sh cleanup && bash book/labs/LES-0010-block-io-storage-performance/lab.sh check",
      "runFrom": "The same valid guided workspace after evidence has been recorded",
      "expectedBranches": [
        {
          "when": "Recovery and verification complete, cleanup proves absence, and the following check reports absent state",
          "meaning": "The supported virtual transition restored its fixed operation assertion and removed only the validated registered resources.",
          "nextEvidence": "Retain sanitized reasoning and the cleanup scope; do not present model output as measured storage evidence."
        },
        {
          "when": "Any stage refuses",
          "meaning": "The `&&` chain stops at the first failed safety, lifecycle, operation, or cleanup condition.",
          "nextEvidence": "Preserve the refusal and stop. Never bypass an unknown-entry, symlink, identity, mode, link-count, integrity, or path guard."
        }
      ],
      "proves": "Only the versioned model's recovered-operation assertion and the implemented point-in-time cleanup contract when the entire chain succeeds.",
      "doesNotProve": "Production durability, physical-device recovery, long-term stability, causal completeness, future absence, or learner mastery.",
      "cleanup": "Cleanup is included and followed by a separate read-only absence check."
    }
  ],
  "labs": [
    {
      "id": "LES-0010-LAB-001",
      "title": "Follow a slow durable-write path without loading a real disk",
      "mode": "guided",
      "environment": "Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS; normal non-root user; Bash, Python 3.8 or newer, and checked base utilities; root-owned sticky /tmp; deterministic foreground model; no package installation, sudo, network, port, container, background worker, sleep, benchmark, raw device, cache drop, mount, loop device, or real storage pressure",
      "timeMinutes": 45,
      "privilege": "Normal non-root user only; effective UID 0 is refused and the harness never invokes sudo",
      "network": "None; no socket, name resolution, download, provider request, telemetry export, or cloud operation",
      "changes": [
        "Creates one private random lesson-prefixed mode-0700 directory and one UID-scoped mode-0600 descriptor under /tmp after strict root and candidate checks.",
        "Copies one reviewed deterministic Python model, records its SHA-256 digest, and writes small mode-0600 sentinel, scenario, recovery, and verification records as the lifecycle advances.",
        "Runs foreground Bash and Python processes only; every performance value is a fixed virtual teaching value and no meaningful disk workload is generated."
      ],
      "abortConditions": [
        "Effective UID is zero; /tmp is not the canonical root-owned mode-1777 directory; a required command or fixture is missing; or the fixture cannot run.",
        "The descriptor, root, sentinel, copied model, digest, scenario, recovery, or verification identity, type, owner, mode, hard-link count, real path, content, or lifecycle differs from the exact contract.",
        "An unknown entry or symbolic link appears, the root escapes the UID-scoped lesson prefix, a duplicate transition is requested, any command returns nonzero, or output differs from the deterministic contract.",
        "The learner is about to use model values as host evidence, run a storage load generator, alter a mount/device/sysctl/scheduler, use sudo, or inspect production data without separate authorization."
      ],
      "recovery": "Use only `recover`, which records a deterministic virtual storage-service restoration after strict validation. Follow with `verify-operation`; status or lower device metrics alone are not recovery proof. If state validation or cleanup refuses, retain the diagnostic and stop rather than editing state or deleting recursively.",
      "cleanupProof": "Cleanup requires the exact mode-0600 current-UID regular single-link descriptor; canonical mode-0700 current-UID non-symlink root; exact sentinel identity; copied-model digest; strict lifecycle files; and a top-level allowlist. Unknown entries, symlinks, unsafe hard links, owner/mode mismatch, content mismatch, and out-of-prefix roots refuse. Known files are removed individually, then the empty root and descriptor are removed. Success proves those exact paths and matching current-UID directory candidates absent at that check; a following `check` independently reports absent state. This is not a guarantee against later path creation.",
      "path": "book/labs/LES-0010-block-io-storage-performance"
    }
  ],
  "incidents": [
    {
      "id": "LES-0010-INC-001",
      "signal": "A transaction API has normal CPU and 40 percent filesystem use, but p99 rises from 90 ms to 1.4 seconds. Commit p99 explains most of the increase; dirty memory, blocked tasks, logical-device write await, and average outstanding requests rise together while MiB/s stays almost flat.",
      "firstThought": "This is a completion-latency and queueing path until disproved, not a disk-full incident and not proof that one physical drive is broken. Map the exact path and align request definitions before interpreting the logical device.",
      "safePath": "Preserve one failed and healthy transaction timeline; resolve mount and major:minor identities; compare application commit, dirty/writeback, blocked task, read/write device, process or cgroup, error, throttle and lower-layer evidence; protect data semantics; if queue growth threatens the objective, use an approved reversible admission or background-work control with a prediction; verify the correct durable transaction, tail latency, queue drainage, retries and healthy cohorts.",
      "trap": "Deleting files, dropping caches, changing dirty ratios or an I/O scheduler, restarting every process, resizing a volume, or running fio from one dashboard field can destroy evidence, increase I/O, move the queue, or risk data without repairing the mechanism."
    },
    {
      "id": "LES-0010-INC-002",
      "signal": "A Kubernetes reporting job starts and payment API p99 triples. The workloads use different PVCs from one storage class; guest devices show high write wait, the reporting volume is below its throughput limit, and no filesystem capacity or error alert fires.",
      "firstThought": "Separate claim identity from node, attachment, transport, backend pool, cache, and device failure domains. In-limit bytes per second and distinct PVC names do not guarantee latency isolation.",
      "safePath": "Establish incident and financial-integrity roles; map both workloads end to end; compare same-pool and different-pool cohorts; rank shared contention, per-volume throttle, API sync-pattern change, writeback interaction, coincident backend degradation and wrong-device mapping; bound noncritical report concurrency only through an approved reversible control; verify exactly-once payment results, tail latency, retry pressure, queues, backend health and durable reconciliation before completing cause and prevention.",
      "trap": "Killing the report and relocating every API pod may restore service but confounds node, cache, attachment and backend placement, can amplify attach or warm-up traffic, and does not prove which isolation or capacity contract failed."
    }
  ],
  "assessmentIds": ["ASM-0013", "ASM-0014", "ASM-0015"],
  "referenceIds": ["REF-0033", "REF-0034", "REF-0035", "REF-0036", "REF-0037", "REF-0038", "REF-0039", "REF-0040"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2026-11-02",
  "limitations": [
    "The guided lab is a deterministic virtual model. Its device names, paths, rates, latency, queue, memory, process, recovery, and operation results are synthetic and must not be described as host or production measurements.",
    "No real slow-device, throttled loopback, filesystem, database, storage-array, cloud-volume, or Kubernetes fault is injected because those exercises require a separately reviewed disposable boundary, resource budget, and data-safety plan.",
    "The chapter covers Linux buffered file I/O and block-path diagnosis; direct I/O, memory-mapped I/O, network filesystems, RAID, LVM, device mapper, multipath, ZFS, Ceph, database engines, and provider-specific controls receive transfer context rather than complete administration coverage.",
    "Metric names and derivations vary by kernel, sysstat, procps, util-linux, device type, driver, and provider. Local manuals and versions are authoritative; examples are illustrative unless explicitly labeled deterministic lab output.",
    "Per-device averages can hide tail latency, request classes, partitions, cgroups, tenants, paths, and lower layers. A logical-device observation never proves physical-device cause by itself.",
    "A successful mitigation, restart, relocation, queue reduction, or model recovery does not establish root cause, durable correctness, long-term capacity, prevention effectiveness, or learner mastery.",
    "Production storage changes require the owning runbook, authorization, data-protection plan, backups or recovery assurance, blast-radius analysis, and rollback. This lesson authorizes none of them.",
    "No publication status, completed reading marker, revealed answer, lab verifier pass, or website behavior awards mastery; independently produced sanitized evidence and reviewer judgment remain required."
  ]
}
---

# Block I/O and storage performance: follow the wait

## What you see and first thought

When a service says **storage is slow**, do not begin with a storage command. Begin
with the operation that a user or workload is waiting for.

A useful first sentence sounds like this:

> Checkout p99 rose from 90 ms to 1.4 s for one revision and zone. Most of the
> added time appears inside the durable-commit stage. Filesystem capacity is
> healthy. The mechanism is not established.

That sentence is better than “the disk is at 100 percent” because it keeps four
things separate:

1. **Impact** — which real operation became slow, incorrect, or unavailable.
2. **Stage** — where the measured time accumulated.
3. **Observed resource state** — what Linux or another owner reported.
4. **Cause** — the mechanism, which still needs evidence.

Here are common screens and the thought that should follow them:

| What you see | Where your mind should go first |
|---|---|
| `df` shows 95 percent used | “This is filesystem allocation. Check blocks, inodes, quotas, deleted-open files, and lower pools. It says nothing yet about latency.” |
| `iostat` shows `%util=99.8` | “This logical device had work in progress for almost the whole interval. Is latency bad? Is a queue growing? What concurrency can this device serve?” |
| `await=400 ms` | “Represented requests completed slowly on average. Which read/write class, interval, device layer, and user operation align with it?” |
| `aqu-sz=80` | “A lot of work was queued or active on average. Is offered work above useful completions, or is a lower layer taking longer?” |
| `vmstat` shows `wa=40` | “Some CPU time was accounted as I/O wait while CPUs had no runnable task for that accounting path. This is context, not a disk-latency measurement.” |
| `pidstat` shows one writer at 200 MiB/s | “This task produced accounted I/O. Did it touch the affected device, and is it harmful or legitimate?” |
| Throughput is unchanged | “Bytes still move, but request size, concurrency, sync frequency, and tail latency may have changed.” |
| The process is `running` | “Lifecycle is not progress. What operation completed, with what correctness and latency?” |
| Two pods have different volumes | “Logical identities differ. Which node, attachment, network path, pool, controller, or media do they share?” |

### The five-minute picture

A file is not a little box placed directly on a disk. An application usually
asks the kernel to read or change bytes in a file. Linux resolves the file
through a mounted filesystem. Reads may be satisfied from memory. Buffered
writes usually dirty memory first. Later, the kernel and filesystem turn work
into block requests, order data and metadata, and pass requests through one or
more logical and physical layers. A virtual machine or managed volume can add
layers Linux cannot see.

Think of storage performance as a delivery system:

```text
customer operation
      |
      v
application -> file/path -> page cache -> filesystem -> block queue
                                                      |
                                                      v
                                  logical device -> driver -> hidden backend
                                                      |
                                                      v
                                            completion / durability result
```

The fastest useful question is not “Which disk command do I run?” It is:

> At which boundary did a healthy input first produce an abnormal wait,
> queue, error, or result?

### Space and speed are different axes

The earlier storage-capacity lesson taught blocks and inodes. Keep that model,
but add a second axis:

```text
capacity axis:  Can another object or byte be allocated?
performance axis: How quickly and predictably does an operation complete?
durability axis: At what boundary is acknowledged state expected to survive?
```

A filesystem can have terabytes free and still serve 800 ms commits. A nearly
full filesystem can still have low request latency until an allocation path,
fragmentation pattern, cleanup job, or lower pool changes it. The axes interact,
but one does not stand in for another.

### What to do before changing anything

Write down:

- the exact user or workload operation;
- expected and observed result;
- p50, p95, or p99 and the measurement window;
- affected and healthy cohorts;
- the exact path, mount namespace, host or node, and time interval;
- the correctness or durability invariant you must preserve;
- current arrivals, useful completions, retries, queue age, and errors;
- who owns application, host, filesystem, virtualization, and backend changes;
- what evidence would disappear after restart, relocation, cache change, or
  failover.

Then observe from the operation downward. Never create heavy I/O on an already
unhealthy system merely to prove that storage is unhealthy.

## Terms before commands

These terms form one connected model. Learn the distinction, not just the
definition.

| Term | Everyday meaning | Precise meaning here | Why an operator cares |
|---|---|---|---|
| Persistent storage | State meant to outlive a process | A storage boundary whose contract retains acknowledged data across stated failures | “Written” and “durable” are not synonyms; know the promised failure boundary |
| Block device | Byte storage addressed in chunks | A Linux device that accepts block I/O to numbered sectors through the block layer | `iostat` normally reports this boundary, not files or business operations |
| Sector | Addressable device unit | A logical or physical storage unit; kernel statistics commonly count sectors with documented units | Do not assume every device's physical write unit from a displayed sector count |
| Filesystem block | Filesystem allocation unit | The unit a filesystem uses to allocate and organize data, distinct from a disk sector and memory page | Capacity, fragmentation, and metadata behavior live here |
| Page | Memory-management unit | A fixed-size region of virtual/physical memory; Linux page cache stores file-backed pages | Buffered I/O can complete from memory before a device completes work |
| Virtual File System (VFS) | Common file interface | Kernel abstraction that routes file operations to a concrete filesystem implementation | System calls first cross a common kernel boundary, then filesystem-specific logic |
| Filesystem | File and directory organizer | Code and on-storage structures that map names, metadata, extents/blocks, permissions, and consistency rules | It owns allocation, metadata ordering, journaling or copy-on-write semantics |
| Mount | Attach a filesystem into a path tree | A namespace-specific association between a target path and filesystem source/options | The same path text in another container or namespace may map elsewhere |
| Page cache | Recently used file data in RAM | Kernel-managed cache of file-backed pages used by ordinary buffered I/O | A read can be fast without reaching a device; a write can return before durability |
| Cache hit | Requested data already available in cache | A read satisfied from an applicable cache layer rather than a lower request | It changes both latency and lower-layer load; cache scope matters |
| Cache miss | Data not available in the queried cache | A request must obtain data from a lower layer | Read throughput does not by itself count misses; use appropriate cache evidence |
| Clean page | Cached data matches backing state | A file-backed page with no unpersisted modification at that boundary | It can usually be reclaimed without first writing its contents |
| Dirty page | Modified cached data | A page whose in-memory contents differ from the backing storage state expected by the kernel | Dirty growth can separate fast write acceptance from slow completion |
| Writeback | Move dirty state toward backing storage | Kernel/filesystem work that submits dirty pages and metadata toward their backing device | High Dirty plus slow completions can lead to throttling and bursty latency |
| Buffered I/O | File I/O mediated by cache | Ordinary reads/writes that normally interact with the page cache | Application `write()` latency may exclude later storage completion |
| Direct I/O | I/O designed to bypass page-cache data copying | An interface such as `O_DIRECT` with filesystem/device alignment and support constraints | Cache assumptions and measurement behavior differ; direct does not mean automatically durable |
| Synchronous I/O | Caller waits for a stronger completion boundary | An operation whose flags or explicit sync require work to reach a documented state before return | It exposes storage latency to the application more directly |
| `fsync` | Ask to persist a file's state | A system call that waits for modified file data and required file metadata to reach the storage contract | Commit latency often concentrates here; directory-entry durability can require syncing the directory too |
| `fdatasync` | Persist data with less metadata | A system call like `fsync` but may omit metadata not required for later data retrieval | Can reduce metadata work, but the application must use the correct durability contract |
| Flush | Push volatile cached writes lower | A command or operation that asks a cache/device to make prior writes durable according to its contract | Flush latency and correctness depend on every layer honoring the request |
| Input/output operation (I/O) | One storage request | A request at a named boundary; an application operation may create zero, one, or many block requests | Never compare application requests/s and device IOPS as if they count the same object |
| IOPS | Operations per second | Completed I/O requests per second at a stated layer and interval | Small random operations can exhaust operation capacity with low MiB/s |
| Throughput | Bytes completed per time | Data volume divided by interval, commonly KiB/s or MiB/s | Large sequential I/O can consume bandwidth with modest IOPS |
| Latency | Time to complete one operation | Elapsed time from a defined start to end boundary, commonly milliseconds | The boundary determines meaning: app, syscall, block request, transport, or device |
| Average | Sum divided by count | Arithmetic mean over a population and window | A small slow tail can be hidden by many fast operations |
| Percentile | Distribution threshold | p99 is a value at or below which 99 percent of observations fall in the stated population/window | Tail objectives require histograms or samples; device `await` is not p99 |
| Concurrency | Work in progress together | Number of operations admitted and not yet complete | Parallel devices need concurrency for throughput, but too much creates queues |
| Queue depth | Waiting or active work count | Number of outstanding requests at a precisely named layer and instant/average | “Queue” may include submitted and active work; define source before comparing |
| Service time | Time an owner actively serves work | A model-specific duration at one service boundary | Common Linux device statistics may not expose a clean physical service-time value |
| `await` | Average request completion time | In sysstat, average elapsed time for represented I/O requests including applicable queue and service time | High await says requests completed slowly at that layer, not why |
| `aqu-sz` | Average outstanding requests | Time-weighted average number of represented requests queued or active during the interval | It connects latency and completion rate when definitions and steady-state assumptions align |
| Utilization | Fraction of an observed resource/time busy | For common disk stats, `%util` derives from time with at least one I/O in progress | It is not filesystem space and not a universal fraction of maximum parallel capacity |
| Saturation | More demand than useful service can handle within objective | Persistent queueing, throttling, rejection, or latency caused by a constrained service boundary | Prove it with demand, completions, queue/age, latency, and objective—not one high field |
| I/O wait (`wa`) | CPU accounting category | Time an idle CPU is accounted waiting for outstanding I/O under kernel rules | It is not the percentage of requests waiting or a direct device-latency measure |
| Major:minor | Kernel device identity numbers | Pair identifying a device type/instance used by mount and block subsystems | Names can change; matching `MAJ:MIN` helps join path and device evidence |
| Device mapper | Logical block-device framework | Kernel layer used by logical volumes, encryption and other mappings over lower devices | One visible device can fan into or stack on parent devices with separate queues |
| Logical volume | Block address space assembled by a manager | A device-mapper target commonly backed by one or more physical volumes | Capacity expansion and performance isolation are separate questions |
| Rotational flag (`ROTA`) | Device says rotating or not | A reported queue topology property visible to util-linux | It is a hint, especially through virtualization; it is not a latency measurement |
| I/O scheduler | Block request ordering policy | Linux policy between software staging and hardware dispatch where applicable | Changing it is a production mutation and rarely justified by one snapshot |
| Multi-queue block layer (`blk-mq`) | Parallel request dispatch | Linux block architecture with software staging queues and hardware dispatch queues | Modern devices complete concurrently; single-queue intuitions can misread busy time |
| Throttle | Enforced rate or operation constraint | A device, cgroup, provider, pool, credit, or policy limits admitted/completed work | Similar latency can come from explicit policy rather than failing media |
| Backpressure | Slow down producers | A control that prevents unbounded accepted work when completion falls behind | Protects queues and recovery, but must match durability and rejection semantics |
| Noisy neighbor | Another workload shares a constrained boundary | A workload whose demand affects yours through a shared queue, cache, link, controller, or pool | Different VM, pod, or volume names do not prove isolation below that layer |

### The four numbers that people mix up

Suppose a storage path completes 1,000 operations each second and each operation
averages 4 KiB. That is about 1,000 IOPS and 4,000 KiB/s. If average latency is
2 ms, a steady system needs roughly two operations in flight to sustain that
rate:

```text
average in-flight = completion rate x average time
                  = 1000 operations/s x 0.002 s
                  = 2 operations
```

This is Little's Law, `L = λW`. It is powerful only when:

- `L`, `λ`, and `W` describe the same work and boundary;
- rates and averages cover a compatible interval;
- the population is reasonably stable over that interval;
- accepted and completed work are reconciled;
- units are converted correctly.

If arrivals are 1,200/s and completions are 1,000/s, the queue grows by about
200 operations every second. That is not steady state. Using completion rate
and average latency to claim an exact stable queue would hide the growth.

### Latency distribution, not one average

Imagine 99 file syncs finish in 5 ms and one finishes in 1,005 ms. The average
is 15 ms, but the unlucky request experiences more than a second. User-facing
systems care about the distribution. Store histograms or request samples at the
application boundary, and compare p50, p95, p99, maximum, and timeouts with the
device averages. Never rename `await` to “disk p99.”

## Architecture map

### One write crosses several owners

```text
[application / database]
        | write(), pwrite(), fsync()
        | evidence: operation ID, syscall result, commit histogram
        v
[VFS + concrete filesystem]
        | owns names, permissions, extents, metadata consistency
        | evidence: mount, filesystem type/options, errors, journal events
        v
[page cache + writeback]
        | owns clean/dirty/writeback page state
        | evidence: Cached, Dirty, Writeback, task wait, writeback workers
        v
[block layer / blk-mq]
        | bio -> request -> software queue -> hardware dispatch queue
        | evidence: request counts, sectors, await, aqu-sz, busy/weighted time
        v
[logical device / driver]
        | dm-crypt, LVM, virtual disk, NVMe, SCSI, network block client
        | evidence: MAJ:MIN, parent chain, errors, timeouts, retries
        v
------------- visibility / ownership boundary -------------
[hypervisor / storage network / controller / backend pool]
        | evidence: provider volume latency, throttle, path, pool, rebuild
        v
[durability boundary]
        | media plus acknowledged cache/replication contract
        | evidence: successful sync semantics, backend acknowledgement, recovery test
```

Text equivalent: the application asks the kernel to write or sync. The VFS and
filesystem resolve file state and consistency. The page cache holds clean and
dirty memory. Writeback turns dirty state into block work. The block layer
builds, may merge or schedule, dispatches, and completes requests. Logical
devices and drivers can add mappings. A VM or managed service hides further
transport, controller, pool, replication, and media layers. Each owner produces
evidence with a narrower truth boundary.

### Control path and data path

Storage has a control path and a data path.

The **control path** discovers or provisions devices, attaches a volume, builds
a logical mapping, creates a filesystem, mounts it, applies policy, and reports
desired state. Kubernetes controllers, cloud APIs, LVM metadata, `/etc/fstab`,
systemd mount units, and udev participate at different layers.

The **data path** serves actual reads, writes, syncs, discards, and flushes.

A control-plane message saying “volume attached” does not prove:

- the filesystem is mounted in the application's namespace;
- the correct path maps to it;
- reads and writes complete within objective;
- sync acknowledgements meet the durability contract;
- the backend has no throttle, failure, or shared queue;
- a real application operation succeeds.

### Path identity before performance

If the application writes `/srv/ledger/data.db`, begin with the path. Do not
begin by guessing `sda`, `vda`, or `nvme0n1`.

```text
/srv/ledger/data.db
   -> mount target /srv/ledger
   -> source /dev/mapper/vgdata-ledger
   -> MAJ:MIN 253:2
   -> dm-2
   -> parent vda2
   -> parent vda
   -> hypervisor volume identity (outside guest)
   -> backend pool/device (outside guest)
```

`findmnt` owns the first association; `lsblk` helps show visible parent-child
relationships. Neither can show a backend pool hidden behind a virtual disk.
Mark that as unknown and join telemetry from the owning layer. An unknown is
better engineering than a guessed physical device.

### Read path

```text
application read
   -> page already cached? ---- yes ---> copy bytes -> return
            |
            no
            v
      filesystem maps file offset
            -> block request(s)
            -> lower completion
            -> page becomes cached
            -> copy bytes -> return
```

This is why a warm-cache test and cold-cache test answer different questions.
Do not drop production caches to manufacture a cold test. It changes global
state and can create an outage-shaped wave of misses.

### Buffered write path

```text
application write
   -> kernel copies/modifies page-cache page
   -> page marked dirty
   -> write may return
   -> later background or caller writeback
   -> filesystem maps/allocates/orders data + metadata
   -> block requests complete
   -> page becomes clean
```

The initial `write()` can be fast while later `fsync()` or writeback stalls.
That is not dishonesty by Linux; it is the buffered-I/O contract. The operator
must know which boundary the application calls “success.”

### Synchronous durability path

```text
application changes file
   -> fsync(file)
   -> dirty file data submitted and completed
   -> required file metadata submitted and completed
   -> volatile lower caches flushed as required
   -> fsync returns success or error

new file name durability may also require:
   -> fsync(containing directory)
```

The exact contract depends on system call, filesystem, mount mode, storage stack,
and application protocol. `fsync` is not “make the whole machine safe.” It is a
specific file-descriptor operation with documented limitations. Databases often
build transaction semantics on top of these primitives; do not replace their
recovery protocol with ad hoc file commands.

## Request or state path

Follow state, not just function calls. A single logical transaction may produce
several file operations, metadata changes, journal records, flushes, and block
requests.

### State table for one buffered commit

| Stage | State owner | Input | Output or transition | Success evidence | Failure or wait |
|---|---|---|---|---|---|
| Business operation | Application | Request and current durable state | Accepted, rejected, or committed outcome | Operation ID, correct result, duration | Timeout, duplicate, uncertain outcome |
| Write call | Process + kernel syscall boundary | User buffer and file descriptor | Modified cache page or submitted direct I/O | Return value and errno | Short write, error, blocked caller |
| Page cache | Kernel memory | File offset and new bytes | Dirty page associated with file mapping | Dirty accounting, file state | Dirty accumulation, reclaim interaction |
| Filesystem | Filesystem code and metadata | Dirty data/metadata | Ordered extents, journal/COW state, block I/O | Filesystem trace/log/error state | Allocation, journal, lock, metadata or consistency wait |
| Block layer | Kernel block subsystem | Bios and requests | Queued, dispatched, completed requests | Disk counters, completion status | Queueing, timeout, retry, scheduler or tag wait |
| Driver/transport | Driver, hypervisor, network client | Submitted request | Lower-layer command and completion | Driver/provider counters | Path loss, timeout, reset, throttle |
| Backend durability | Device or managed service | Writes and flush/order commands | Acknowledged durable state per contract | Sync success plus backend contract/recovery evidence | Volatile cache, failed replica, media/controller fault |
| Final response | Application | Commit result | User-visible success/failure | End-to-end transaction and durable record | Returned too early, uncertain retry semantics |

### Reads have two very different branches

For a cache hit, the block layer may see no new request. For a miss, filesystem
mapping and block I/O matter. Therefore:

- high application read rate plus low device read rate can be healthy cache
  behavior;
- low device read rate does not prove the application is idle;
- high device read rate can be readahead or another workload;
- a cache-warm comparison cannot predict cold start;
- a cold-cache incident cannot be safely recreated by dropping shared caches.

A responsible experiment creates a disposable dataset and an explicit cache
state boundary, or uses existing production cache telemetry. It never writes
`3` to `drop_caches` on a shared host because a tutorial suggested it.

### Dirty state has thresholds and time

Dirty pages cannot grow without control forever. Linux has background writeback
and thresholds at which writers participate or are throttled. The relevant VM
sysctls can be byte- or ratio-based and are calculated against documented
available-memory concepts, not simply the number printed as total RAM.

Operational lesson:

- reading the values can explain policy;
- changing them changes system-wide behavior;
- a larger dirty allowance can make bursts look fast while increasing later
  flush size, memory exposure, and tail latency;
- a smaller allowance can increase steady writer throttling;
- neither fixes a slow device, bad access pattern, shared throttle, or broken
  durability design.

Do not tune writeback during an incident without a tested workload, kernel and
filesystem version, safety envelope, rollback, and durability analysis.

### Queueing: where latency comes from

One useful decomposition is:

```text
operation latency
  = application wait before I/O
  + filesystem/cache work
  + block-layer queue and completion
  + hidden lower-layer time
  + application work after I/O
```

This is a reasoning model, not an instruction to subtract unrelated dashboard
averages. Metrics may count different requests and intervals. Measure spans at
the application, use block statistics at their boundary, and join them by time,
host/device identity, workload, and cohort.

When mean completion time rises while completion rate stays roughly flat,
average in-flight work tends to rise if the same operation definition and a
stable interval apply. That is why `await` and `aqu-sz` often move together.
But a queue can exist in many places:

- application worker or connection pool;
- filesystem locks or journal;
- dirty-page throttling;
- blk-mq software staging;
- hardware dispatch/tag availability;
- virtual-device host queue;
- storage network;
- array controller, pool, cache, or media;
- provider throttle or service queue.

A guest `aqu-sz` cannot name which hidden lower queue created the delay.

### Completion ordering and correctness

Modern block devices can process requests concurrently and may complete them in
an order different from submission. Filesystems and applications use barriers,
flushes, force-unit-access semantics, journals, copy-on-write rules, checksums,
and recovery protocols to preserve required ordering. Do not infer transaction
durability from “the write counter increased.” Verify the application protocol
and recovery behavior.

### Errors may arrive late

Buffered writes can return before lower I/O completes. A later sync or close path
may surface an error. Kernel and filesystem versions define how writeback errors
are reported. Operationally:

- preserve the first error and affected file/device identities;
- distinguish original business operation from retries;
- do not assume a successful earlier `write()` means durable success;
- do not retry non-idempotent work blindly;
- reconcile outcomes after recovery.

## Failure zoom

### Failure 1: same throughput, much worse latency

Baseline:

```text
120 commits/s x 4 KiB records
commit p95 = 7 ms
write await = 5 ms
average outstanding requests = 0.8
```

Incident:

```text
119 commits/s x 4 KiB records
commit p95 = 844 ms
write await = 612 ms
average outstanding requests = 84.9
```

Bytes per second barely changed. The experience changed completely. More work
is outstanding because each request remains incomplete longer. Possible
mechanisms include lower service slowdown, a throttle, lost parallel path,
filesystem ordering change, sync-frequency change, or shared contention.
Throughput alone cannot choose between them.

### Failure 2: buffered success hides a writeback cliff

A log pipeline accepts bursts into page cache. Application write latency looks
healthy. Dirty memory grows for minutes. A checkpoint calls `fsync`; writers
suddenly block, device queues rise, and request p99 crosses its deadline.

The immediate symptom is the checkpoint, but the causal chain may be:

```text
burst accepted faster than durable completion
   -> dirty backlog grows
   -> background writeback cannot catch up
   -> checkpoint requires completion
   -> caller and other writers wait
   -> queue/retry amplification
```

Mitigation is not “disable fsync.” That can trade latency for data loss. Protect
the durability requirement, reduce or defer nonessential offered work through
an approved control, restore lower completion capacity, and verify backlog and
durable outcomes.

### Failure 3: the wrong device looks busy

An engineer runs `iostat`, selects the only `nvme` name, and restarts the
database. The database path actually sits on `dm-3`, backed by two devices; the
busy NVMe holds a container image cache. The restart creates more reads and
makes the host worse.

Prevention is boring and powerful: start with `findmnt -T <path>`, join
`MAJ:MIN`, then follow `lsblk` parents. A familiar name is not evidence.

### Failure 4: `%util=100` on a parallel device

Kernel busy time grows while at least one request is active. On a single-spindle
disk, continuous activity plus rising latency and queue often indicates a
constrained device. On NVMe or a virtual array, many requests can complete in
parallel while the device is continuously active. `%util` can sit near 100
during a healthy workload.

Ask:

- Did user latency cross objective?
- Did `await` or tail completion change from baseline?
- Did outstanding work or oldest work grow?
- Did useful completion rate flatten while offered work grew?
- Did errors, throttles, retries, credits, paths, or backend latency change?
- Is this logical device the affected path?

High utilization is a clue. Saturation is a system claim.

### Failure 5: virtualization hides the owner

Inside a VM, `/dev/vda` is a guest-visible contract. The actual path could be:

```text
guest vda -> hypervisor queue -> host file or volume -> network -> controller
          -> storage pool -> cache -> replicas or media
```

Guest await can prove slow guest-visible completions. It cannot distinguish host
CPU scheduling, virtual queue limits, network loss, provider throttling, pool
rebuild, controller cache, or media latency. Join hypervisor/provider evidence
with guest identity and time. Do not tell a storage team “the SAN is broken”
from guest `iostat` alone.

### Failure 6: one background job changes the workload shape

A reporting scan is below its byte-throughput limit but issues many small random
reads. A payment workload performs synchronous writes. Both logical volumes
share a lower pool. The report does not exceed MiB/s policy, yet it can increase
queueing or cache churn for latency-sensitive commits.

Capacity must model at least:

- request size;
- read/write mix;
- random/sequential pattern;
- sync/flush frequency;
- concurrency and burst duration;
- cache state;
- tail-latency objective;
- lower topology and failure state;
- recovery/rebuild headroom.

“Within throughput limit” answers only one policy question.

## Internals and state ownership

### VFS and filesystem responsibilities

The VFS gives applications a common interface: open, read, write, sync, rename,
and so on. A concrete filesystem implements how names map to inodes, file
offsets map to extents or blocks, metadata is protected, free space is tracked,
and crash consistency is maintained.

A slow file operation can wait before block I/O because of:

- directory or inode locks;
- allocation or extent work;
- journal transaction boundaries;
- copy-on-write metadata;
- checksum work;
- quota enforcement;
- memory reclaim;
- writeback throttling;
- filesystem freeze or error state.

This is why high application latency with quiet device metrics does not clear
the storage path. It moves attention upward toward cache, filesystem, locks,
mapping, or the wrong device.

### Page cache state

The page cache is shared kernel state, not memory “wasted” by Linux. Cached clean
pages can accelerate reads and usually be reclaimed. Dirty pages represent work
that must reach backing storage or be discarded only by losing changes.

`/proc/meminfo` fields in this lesson:

- `Cached` — memory used for cached files, with kernel-accounting details that
  make it unsuitable as a simple per-file cache-hit counter;
- `Buffers` — relatively raw block-device buffer metadata/data accounting; on
  modern systems it is often much smaller than `Cached`;
- `Dirty` — memory waiting to be written back;
- `Writeback` — memory actively being written back.

All four are point-in-time global values in kibibytes. Repeated samples show a
trend; none attributes bytes to one process or device.

### Writeback workers and writer throttling

Background flusher work submits pages that meet policy. When dirty state crosses
higher thresholds, a writer can be forced to help or wait so memory does not
become an unbounded durability queue. Bursty systems can therefore show:

```text
fast buffered writes -> rising Dirty -> sustained Writeback
                     -> writer throttling -> sudden application latency
```

The correct response depends on why durable completion is below demand. If a
backend path failed, tuning memory only moves the waiting place. If an
application produces unbounded writes, more device capacity without admission
control may move the failure to another shared boundary.

### From bio to request in blk-mq

At a simplified level, filesystems submit block I/O descriptions. The block
layer forms requests, may merge adjacent work, applies an I/O scheduler where
configured, and dispatches through hardware contexts to the driver. Modern
multi-queue design reduces a single shared lock bottleneck and allows hardware
parallelism.

Important consequences:

- several application operations can merge into fewer block requests;
- one application operation can split into many requests;
- software and hardware queues are not the same thing;
- devices can have multiple dispatch queues and many requests in flight;
- completion order is not generally submission order;
- a logical device can add another mapping and queue;
- counters are intentionally cheap and can contain small inconsistencies.

Do not calculate business-operation loss from disk request counts. Reconcile at
the application's durable-operation boundary.

### Kernel disk statistics

Linux exposes cumulative device counters through `/proc/diskstats` and sysfs.
The documented set includes completed and merged reads/writes, sectors,
milliseconds spent, I/O in progress, busy time, weighted busy/queue time, and
newer discard and flush counters. Most counters are cumulative from boot or
device initialization; in-progress I/O is a gauge that returns toward zero.

Tools sample two points and derive rates and averages. That creates four rules:

1. Keep start/end timestamps and interval duration.
2. Detect boot, reattach, reset, wrap, or device-identity change.
3. Never compare a since-boot first report with a one-second incident report as
   if both represent the same window.
4. Record tool and kernel version because derived names and formulas can change.

### Why `await` is not pure media service time

At the device-stat boundary, elapsed request time includes applicable waiting
and service between request accounting points. A high value means requests took
longer to complete there. It does not reveal how much time was:

- waiting in an application queue;
- waiting on a filesystem lock before submission;
- staged or scheduled in the block layer;
- active in a device;
- delayed in a hypervisor or storage network;
- queued inside a provider or array.

Some historical tools expose a field named `svctm`; do not treat it as a clean
physical service-time oracle. Prefer documented current fields and lower-layer
telemetry.

### Utilization and parallelism

Kernel busy time increases while requests are in progress. A tool turns its
delta into a percentage of sample time. If at least one request remains active
for the whole second, that can approach 100 percent whether one or many requests
complete.

For a serial device, continuous busy time often means little idle headroom. For
a parallel device, it may mean normal utilization. Saturation needs an objective
and response curve:

```text
increase offered concurrency gradually in a disposable test
   -> does useful throughput still rise?
   -> when does latency bend upward?
   -> when do queues persist?
   -> when do errors/throttles/rejections appear?
```

That is a controlled benchmark design, not a production incident command.

### Filesystem versus block-device latency

An application can wait in the filesystem without issuing new block work, and a
block device can be busy for unrelated paths. Strong evidence joins:

- operation spans or histograms;
- syscall or engine stage timing;
- exact mount/device mapping;
- cache and writeback state;
- block-device interval metrics;
- process/cgroup/container activity;
- filesystem and kernel errors;
- lower-layer latency, throttle, queue, and topology.

The first divergence is the first observed boundary where a healthy input
produces an abnormal output. It is not automatically final root cause, but it
tells you which owner and test come next.

### Durability is a contract chain

A durability promise is only as strong as its chain. The application must call
the right primitive and handle errors. The filesystem must order data and
metadata correctly. The block stack must transmit ordering/flush requirements.
The device or managed service must honor them. Replication may acknowledge at a
defined quorum or region boundary.

Questions for a senior review:

- What failure must acknowledged data survive: process, kernel panic, host loss,
  power loss, zone loss, or region loss?
- Which system call or database commit represents that acknowledgement?
- Is directory metadata part of the operation?
- Are volatile caches protected or correctly flushed?
- What happens when a writeback error arrives after buffered acceptance?
- How are retries made idempotent?
- How is recovery tested rather than assumed?

Performance tuning that weakens one answer is a correctness change, not an
optimization.

## Evidence table

Use this table as a guard against single-metric diagnosis.

| Evidence | Scope and unit | What it proves | What it does not prove | Safest next evidence |
|---|---|---|---|---|
| Application p99 increased | Named operation/cohort/window; milliseconds | Tail latency crossed the observed value/objective | Which internal stage or resource caused it | Span/stage timing and healthy cohort |
| Commit span explains most added time | Application commit boundary; milliseconds | Wait is concentrated around the commit contract | Filesystem versus block versus backend cause | Sync/syscall, cache/writeback, exact device and lower telemetry |
| `df` blocks 62 percent used | Mounted filesystem; allocation percent | Reported block capacity has headroom | Inodes, quotas, thin pool, performance, durability | `df -i`, quota/lower pool, then performance path |
| `Dirty` climbs across samples | Host/global memory; KiB | Modified file-backed memory awaits writeback | Which file/process/device, or why completion is slow | Writeback, task, mount/device and writer evidence |
| `Writeback` remains high | Host/global memory; KiB | Pages are actively accounted under writeback | Healthy progress versus stuck/slow completion | Device completions, errors, dirty trend, workload rate |
| `vmstat b` rises | Host aggregate; task count | More tasks are in uninterruptible sleep in samples | All wait is storage or affects this service | Task stack/owner where authorized, device and app correlation |
| `vmstat wa` rises | CPU accounting; percentage | More idle CPU time is accounted as I/O wait | Percent of requests waiting, one device cause, or total lost capacity | Runnable/blocked work, per-device and app latency |
| `iostat r/s`, `w/s` | Device interval; completed requests/s | Represented completion rate by read/write class | Application operations/s or offered requests | Request size, application rate, queue and lower demand |
| `rkB/s`, `wkB/s` | Device interval; KiB/s | Completed data rate | Latency, IOPS headroom, sync semantics, cache misses | Request sizes, await, queue, application stage |
| `r_await`, `w_await` | Device interval; average ms/request | Average represented completion time | p95/p99, physical service time, cause | Queue, workload mix, errors and lower latency |
| `aqu-sz` rises | Device interval; average requests | More requests were outstanding on average | Exact instant queue, location below device, harmfulness | Arrival/completion, oldest work, latency and baseline |
| `%util` near 100 | Device interval; busy-time percent | At least one request was active for nearly all sample time | Space use or universal maximum capacity | Device concurrency, await, queue, throughput, objective |
| `pidstat kB_wr/s` high | Visible task interval; KiB/s | Task has accounted write activity | File/device mapping or causal blame | Service/cgroup/path mapping and controlled comparison |
| `pidstat iodelay` rises | Task accounting; clock ticks | Kernel task I/O delay accounting increased | Milliseconds without clock conversion or complete syscall latency | Tool manual/version and app/device spans |
| Kernel I/O error | Kernel/filesystem/device log boundary | A named operation/layer reported an error | Full data impact, root hardware part, safe repair | Preserve exact error, map device, freeze unsafe mutation, owner runbook |
| Provider throttle counter rises | Provider volume/account boundary | Provider applied or observed named throttling | Application pattern cause or only bottleneck | Volume identity, demand, credits/limits, pool and user path |
| Queue falls after admission control | Bounded experiment interval | Offered load influenced queue under that control | Why service capacity fell or permanent fix | Lower fault evidence and sustained recovery verification |

### Evidence must share identities

A useful correlation key set might be:

```text
operation_id + timestamp
service_revision + pod_or_process + cgroup
host_or_node + mount_namespace
path + mount_target + MAJ:MIN
logical_device + parent_device + backend_volume
zone + pool + storage_class
```

Sanitize before sharing. Paths, volume labels, command lines, tenant names,
device serials, topology, and request IDs may be sensitive. Evidence collection
is an access decision, not a reason to grant everyone root.

### Negative evidence is bounded

“No errors in 100 log lines” means no accessible matching error appeared in that
query. It does not prove no error occurred. “No process in three pidstat samples”
does not prove no short-lived writer existed. “Low device await” does not prove
a read hit no filesystem lock. State the window, source, filter, retention,
sampling, visibility, and missing layer.

## Command decoders

Every command below answers one question. Replace placeholders only after
review. Examples are **illustrative** except the guided lab's explicitly
deterministic output.

### `findmnt`: map the exact path

```bash
findmnt --target /srv/ledger/data.db \
  --output TARGET,SOURCE,FSTYPE,OPTIONS,MAJ:MIN
```

Flags:

- `--target` / `-T` asks which filesystem contains the path. The path must be
  interpreted in the current mount namespace.
- `--output` / `-o` requests explicit columns. Explicit fields make automation
  and teaching safer than a changing default layout.

Illustrative output:

```text
TARGET      SOURCE                     FSTYPE OPTIONS      MAJ:MIN
/srv/ledger /dev/mapper/vgdata-ledger  ext4   rw,relatime 253:2
```

Fields:

- `TARGET` — mount point selected for the path.
- `SOURCE` — filesystem source as represented by the mount table/tool. It can be
  a device, network export, overlay, label, UUID, or another form.
- `FSTYPE` — filesystem type such as ext4, xfs, overlay, tmpfs, or nfs.
- `OPTIONS` — effective mount options shown by the tool; `rw` means the mount is
  writable, not that every identity can write or that storage is healthy.
- `MAJ:MIN` — kernel major and minor numbers for the mounted device identity.

This proves the current namespace's path mapping. It does not prove the backend
or performance.

### `lsblk`: trace visible topology

```bash
lsblk --exclude 7 \
  --output NAME,MAJ:MIN,TYPE,SIZE,ROTA,SCHED,FSTYPE,MOUNTPOINTS
```

Flags:

- `--exclude 7` omits devices with major number 7, commonly loop devices. It is
  a display filter, not a safety boundary and not appropriate if the target is
  intentionally a loop device.
- `--output` fixes the requested columns.

Illustrative output:

```text
NAME              MAJ:MIN TYPE  SIZE ROTA SCHED FSTYPE MOUNTPOINTS
vda               252:0   disk  200G    0 none
└─vda2            252:2   part  180G    0 none   LVM2_member
  └─vgdata-ledger 253:2   lvm    80G    0 none   ext4   /srv/ledger
```

Fields:

- `NAME` — visible kernel/tool device name. It is not a stable backend identity.
- `MAJ:MIN` — join key to mount and sysfs evidence.
- `TYPE` — topology type such as disk, partition, LVM, crypt, RAID, or ROM as
  recognized by util-linux.
- `SIZE` — exposed address-space size, not free filesystem space.
- `ROTA` — rotational-property flag reported through sysfs. `0` does not promise
  NVMe latency through a hypervisor.
- `SCHED` — selected I/O scheduler visible at that layer; `none` still uses the
  block layer and does not mean “no queue.”
- `FSTYPE` — detected filesystem/signature; blank can be valid for a parent.
- `MOUNTPOINTS` — associated mount targets visible to the tool; there may be
  multiple lines/targets.

Do not parse the tree's drawing characters. For automation, use explicit JSON
output and version-aware fields, but validate the consumer before relying on it.

### `df`: capacity, not speed

```bash
df -hT /srv/ledger/data.db
df -i /srv/ledger/data.db
```

`-h` chooses human-readable powers for display; `-T` adds filesystem type; `-i`
switches from block allocation to inode counts. Key fields:

- `Filesystem` — source chosen for the path;
- `Type` — filesystem type in the first command;
- `Size`, `Used`, `Avail`, `Use%` — filesystem block allocation, including
  filesystem reservation/accounting behavior;
- `Inodes`, `IUsed`, `IFree`, `IUse%` — inode allocation.

Neither command reports IOPS, await, p99, queue depth, or durability.

### `/proc/meminfo`: cache and writeback snapshot

```bash
grep -E '^(Cached|Buffers|Dirty|Writeback):' /proc/meminfo
```

Illustrative output:

```text
Buffers:          32768 kB
Cached:          786432 kB
Dirty:           262144 kB
Writeback:        65536 kB
```

Every value is a point-in-time global amount in kibibytes (`kB` in this proc
interface). Do not call it decimal kilobytes, a per-process value, or an I/O
rate. Sample over time and align the timestamps.

### `vmstat`: system context over intervals

```bash
vmstat -y 1 5
```

Arguments:

- `-y` asks supported procps versions to omit the first since-boot report.
- `1` is the sample interval in seconds.
- `5` is the number of reports.

Columns used here:

- `r` — runnable tasks, including running or waiting for CPU.
- `b` — tasks blocked in uninterruptible sleep.
- `swpd` — used virtual memory/swap, in the selected display unit.
- `free`, `buff`, `cache` — memory categories in the selected unit.
- `si`, `so` — swap read-in and write-out rates per second.
- `bi`, `bo` — blocks received from or sent to block devices per second; confirm
  the installed version and unit option before converting.
- `in` — interrupts per second.
- `cs` — context switches per second.
- `us`, `sy`, `id`, `wa`, `st` — CPU time percentages for user, system, idle,
  I/O wait, and virtual-machine stolen time.

Important: `wa=40` is not “the disk is 40 percent slow.” It is CPU accounting.
A busy CPU can reduce apparent wait even while requests are slow, and a single
critical task can suffer while host-wide `wa` stays small.

### `iostat -xz`: device interval

```bash
iostat -xz -y 1 3
```

Flags:

- `-x` requests extended device statistics.
- `-z` suppresses devices with no activity in the sample.
- `-y` omits the first since-boot report when an interval is supplied.
- `1 3` means three reports at one-second intervals.

Field names vary by sysstat version. Record `iostat -V` and use its local manual.
Common fields in this lesson:

- `Device` — visible device name; join it to the validated mapping.
- `r/s`, `w/s` — completed read and write requests per second.
- `rkB/s`, `wkB/s` — kibibytes read and written per second.
- `rrqm/s`, `wrqm/s` — read and write requests merged per second.
- `r_await`, `w_await` — average read/write request completion time in
  milliseconds at this accounting boundary.
- `rareq-sz`, `wareq-sz` on versions that expose them — average read/write
  request size, commonly KiB; verify the header.
- `aqu-sz` — average number of outstanding requests.
- `%util` — percentage of interval during which at least one request was in
  progress according to underlying busy-time counters.

Illustrative comparison:

```text
Device r/s  rkB/s r_await w/s   wkB/s w_await aqu-sz %util
vda    38.0 1216  2.1     142.0 4544  4.8     0.72   31.0
vda    41.0 1312  8.2     139.0 4448  612.0   84.90  99.2
```

The write byte rate is similar. Write completion time and outstanding work are
not. This supports a slow queued write path for `vda` in the second interval.
It does not prove that `vda` is physical, that a writer caused the slowdown, or
that every write took 612 ms.

### `pidstat -d`: task activity

```bash
pidstat -d 1 3
```

Common fields:

- `UID` — effective/reporting user identity associated with the task.
- `PID` — process identifier; it can be reused after a process exits.
- `kB_rd/s`, `kB_wr/s` — task storage read/write rates in KiB/s under sysstat's
  accounting rules.
- `kB_ccwr/s` — writes cancelled by the task, which is not the same as durable
  bytes undone.
- `iodelay` — task block-I/O delay accounting in clock ticks, not milliseconds;
  kernel support/accounting applies.
- `Command` — command name, potentially sensitive and not a service identity.

Buffered writes may be submitted later by kernel writeback, short-lived tasks
may disappear between samples, and permissions/namespaces can hide processes.
Map PID to service and cgroup, but do not assign blame from a byte rate.

### `sar -d`: live or historical shape

```bash
sar -d -p 1 3
```

- `-d` selects block-device activity.
- `-p` requests easier-to-read persistent device names where supported.
- `1 3` performs three live one-second samples.

The final `Average` row is an arithmetic aggregate over reports, not a latency
percentile. Historical `sar` requires prior collection and retention; the
command cannot recover a period that was never collected. Persistent collection
also consumes disk and may retain sensitive topology, so configure it as a
reviewed observability feature rather than during the incident.

### Raw `/sys/class/block/<device>/stat`

The raw row is compact and positional. Its meaning depends on current kernel
documentation. The core lesson is not to memorize seventeen positions. It is:

```text
snapshot A + monotonic timestamp
snapshot B + monotonic timestamp
validated same device identity
counter deltas / elapsed time
reset and overflow handling
documented field units
```

Use `iostat` or another versioned collector for routine work. Read raw counters
when validating a collector, investigating missing telemetry, or implementing a
well-tested agent—not as a faster way to guess.

## Decision path

### FRAME the incident

**Frame**

- Operation: what read, commit, checkpoint, pull, restore, or sync is slow?
- Impact: which customers, jobs, zones, revisions, tenants, or priorities?
- Objective: what latency, correctness, durability, and recovery target?
- Constraints: what must not be lost, duplicated, reordered, exposed, or
  restarted?
- Authority: who can control load, application, node, filesystem, volume, and
  backend?

**Retrieve**

1. Preserve a failed and healthy operation with aligned monotonic time.
2. Resolve exact path, mount namespace, source, filesystem, and `MAJ:MIN`.
3. Trace logical and parent device layers; name hidden layers as unknown.
4. Compare capacity separately: blocks, inodes, quota, lower pool.
5. Collect application stage latency and original-operation accounting.
6. Sample Dirty, Writeback, `vmstat`, mapped `iostat`, process/cgroup, errors,
   throttles, and lower service telemetry over compatible intervals.
7. Record commands, versions, units, filters, resets, and visibility.

**Analyze**

Rank mechanisms, for example:

- application lock or worker queue before storage;
- cache-state/access-pattern change;
- filesystem metadata, journal, allocation, or error behavior;
- dirty-page accumulation and writer throttling;
- device queue from increased IOPS, request size, sync frequency, or concurrency;
- explicit cgroup/provider throttle or exhausted burst credits;
- degraded/missing path, backend rebuild, transport loss, or device fault;
- noisy neighbor on a hidden shared boundary;
- wrong path/device/interval attribution.

For each, write support, contradiction, falsifier, and next safe observation.

**Make a safe move**

Start read-only. If service restoration requires mutation, select the smallest
approved action supported by evidence:

- pause or limit nonessential background work;
- bound admitted concurrency or retry amplification;
- shift only through a pretested failover or placement path;
- restore a failed lower path through the owner's runbook;
- roll back an application I/O-pattern change with compatibility checks;
- expand a capacity or policy limit only when that exact limit is evidenced and
  the change is safe.

Before execution, declare prediction, cohort, duration, maximum resource scope,
success, rejection, abort, rollback, data-integrity check, and evidence already
preserved.

**Evaluate and encode**

Verify the real operation, correct durable outcome, p95/p99, errors/timeouts,
original requests versus retries, queue drainage, dirty/writeback recovery,
device and lower-layer signals, healthy controls, and recurrence window. Then
identify trigger, first abnormal mechanism, propagation/amplification, failed
containment, detection gap, and testable prevention.

### Quick branch table

| Observation combination | Likely next boundary, not conclusion |
|---|---|
| App latency high; commit normal; device normal | Application queue, dependency, CPU scheduling, lock, or another stage |
| Commit high; Dirty/Writeback low; mapped await high | Synchronous/direct path or lower completion; inspect request mix and backend |
| Buffered writes fast; Dirty grows; later sync stalls | Writeback capacity/policy and durable completion path |
| Device busy high; await/queue/user latency normal | Healthy activity may be using available parallelism; compare headroom and objective |
| Device await high; app operation normal | Another workload/path or hidden buffering; check mapping and cohorts |
| App slow; guessed device normal | Mapping may be wrong, wait may precede block submission, or hidden service differs |
| Errors/timeouts/resets appear | Preserve evidence and follow device/filesystem/backend incident runbook before load tests |
| Queue grows; arrival exceeds useful completion | Control admission/retry amplification and restore service capacity |
| Queue falls after restart only | Service restored perhaps; cause and data reconciliation remain open |

### Actions this lesson does not authorize

Do not run these on a shared or production system from this chapter:

- `fio`, `dd`, `hdparm`, destructive `badblocks`, raw-device reads/writes;
- `echo 3 > /proc/sys/vm/drop_caches`;
- system-wide `sync` as an experiment;
- writeback sysctl changes;
- I/O scheduler or queue-depth changes;
- filesystem repair, remount, freeze, trim, resize, or format;
- LVM, RAID, multipath, attachment, or cloud-volume mutation;
- broad process kills, node drain, pod deletion, or failover;
- storage firmware/controller changes.

Some are valid tools in a reviewed disposable or production runbook. None is a
safe consequence of one metric.

## Guided Ubuntu lab

The guided lab teaches evidence joining without touching a real storage path.
Every reported performance value is deterministic and synthetic.

### 1. Read the safety card

Open:

```text
book/labs/LES-0010-block-io-storage-performance/README.md
```

The lab runs as a normal user, uses no network, does not install packages, opens
no ports, launches no background process, and creates only tiny guarded files
under `/tmp`. It refuses root. It does not run `dd`, `fio`, or any benchmark.

### 2. Check clean state

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh check
```

Expected clean branch:

```text
environment=ready state=absent candidates=none
```

This is preflight evidence, not permission to use the model as a benchmark.
Any refusal is a stop condition.

### 3. Set up one guarded workspace

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh setup
bash book/labs/LES-0010-block-io-storage-performance/lab.sh status
```

Expected status fields:

```text
state=ready scenario=slow-commit recovered=false operation_verified=false synthetic=true
```

- `state=ready` — strict workspace validation passed.
- `scenario=slow-commit` — the fixed guided profile is selected; it is not a
  diagnosis of a host.
- `recovered=false` — the virtual recovery transition has not run.
- `operation_verified=false` — no post-recovery operation proof exists.
- `synthetic=true` — every performance value is model data.

### 4. Compare the operation first

Before running the commands, predict:

> If durable completion is the affected stage, `commit_p95_ms` should explain
> most of the end-to-end increase while `requests_s` remains similar. Device
> completion time and outstanding work should change in the same profile.

Then run:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe baseline
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe incident
```

Deterministic key values:

| Profile | requests/s | app p95 | commit p95 | result |
|---|---:|---:|---:|---|
| Baseline | 120 | 42 ms | 7 ms | `ok` |
| Incident | 119 | 918 ms | 844 ms | `timeout` |

What this proves inside the model: accepted operation rate is nearly unchanged,
the p95 increase is concentrated in commit, and the modeled operation times out.
It does not prove where inside the commit path the wait begins.

### 5. Draw and inspect the path

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe path
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe mount
```

The mount view maps synthetic `/srv/ledger` to a device-mapper source with
`MAJ:MIN=253:2` and a `vda2>dm-2` chain. Write your own diagram with these
owners: API, filesystem, writeback, block layer, device, result. Circle the
first boundary whose output differs from a healthy comparison; do not circle a
component simply because its name sounds like the incident.

### 6. Compare system context

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe system
```

The incident model reports:

```text
Dirty_kib=262144 Writeback_kib=65536 interval_s=1 synthetic=true
```

It also prints a `vmstat`-shaped row with 17 blocked tasks and 37 percent
synthetic I/O-wait accounting. These fields support accumulated modified state
and blocked-work context. They do not identify a file, process, filesystem, or
device cause.

### 7. Inspect the mapped device

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe device
```

Compare with the baseline values documented in the lab guide:

| Field | Baseline | Incident | Interpretation |
|---|---:|---:|---|
| `w/s` | 142 | 139 | Completion rate is similar |
| `wkB/s` | 4544 | 4448 | Byte throughput is similar |
| `w_await` | 4.8 ms | 612.0 ms | Average write completion is far slower |
| `aqu-sz` | 0.72 | 84.90 | Much more work is outstanding on average |
| `%util` | 31.0 | 99.2 | The model device has work active for nearly the full incident interval |

A good statement is:

> In the model, commit wait, write completion time, outstanding work,
> dirty/writeback state, and blocked tasks rise together while write throughput
> stays similar. This supports a slow queued write-completion path. The model
> still does not identify a physical cause.

### 8. Inspect task activity without assigning blame

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe process
```

`ledger-api` has write activity and a larger `iodelay` value in the incident.
That connects the modeled service to storage activity. It does not prove the
service caused the slowdown. The task might be a victim of a shared lower
constraint.

### 9. Rank competing mechanisms

Complete this before recovery:

| Rank | Mechanism | Support | Contradiction | Falsifier |
|---:|---|---|---|---|
| 1 | Lower write completion slowed | Commit, write await, queue, blocked state align | No lower backend field exists | Healthy lower completion while guest wait remains high |
| 2 | Application CPU saturation | Could increase app latency | CPU path is not the first changed modeled boundary | Application stage trace shows CPU wait before commit |
| 3 | Filesystem full | Writes can fail or stall near capacity | No capacity signal is supplied; the incident is latency-shaped | Exact path capacity/quota evidence shows exhaustion |
| 4 | More write bytes caused queue | Queue could grow with demand | `w/s` and `wkB/s` are nearly unchanged | Offered bytes/operations increase in a comparable interval |

The fixture intentionally cannot reveal a real physical root cause. The right
answer keeps the hidden lower owner as unknown.

### 10. Recover and verify the operation

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh recover
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe recovered
bash book/labs/LES-0010-block-io-storage-performance/lab.sh verify-operation
bash book/labs/LES-0010-block-io-storage-performance/lab.sh status
```

Recovered key values are 51 ms application p95, 9 ms commit p95, 6.1 ms write
await, `aqu-sz=0.91`, and an `ok` operation. The recovery command models a
storage-service restoration; it does not teach an unsafe host change.

Verification proves the fixed post-recovery model operation. It does not prove
root cause, durability on hardware, long-term capacity, or production recovery.

### 11. Cleanup and prove absence

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh cleanup
bash book/labs/LES-0010-block-io-storage-performance/lab.sh check
```

Successful cleanup includes:

```text
cleanup=complete state=absent cleanup_scope=registered-root-and-owned-candidates-at-check cleanup_proven=true
```

The following check independently reports absent state. If cleanup refuses an
unknown file, symlink, owner, mode, hard-link, content, or path condition, stop.
Do not replace a guarded refusal with `rm -rf`.

### What you should retain

Retain a sanitized worksheet containing:

- prediction before evidence;
- operation and path diagram;
- field/units/proof table;
- baseline/incident/recovered comparison;
- four hypotheses and two rejected alternatives;
- recovery-versus-causality distinction;
- cleanup proof scope;
- one production transfer with explicit non-transferable fixture facts.

Completing the commands records practice. It does not award mastery.

## Production transfer

### Containers: namespace names, host storage

A container usually shares the host kernel. Its root filesystem might use an
overlay layer; a bind mount or named volume may map elsewhere. Inside-container
`df` and paths can differ from the node. Block-device statistics may be hidden,
aggregated at the node, or include other containers.

Transfer method:

```text
container operation
 -> container path and mount namespace
 -> overlay/bind/volume source
 -> cgroup I/O accounting and limits
 -> node filesystem/device
 -> lower backend
```

Do not grant a container privileged host-device access just to run `iostat`.
Use node observability and cgroup/container identity with least privilege.

### Virtual machines: guest evidence stops at the virtual device

Guest `await` and queue data describe guest-visible request completion. Add:

- VM identity and host placement;
- virtual controller/queue configuration;
- hypervisor host CPU and storage queue;
- image/volume format and caching mode;
- network-storage path;
- backend pool, throttle, credit, replication, and rebuild;
- neighbor workload and failure domain.

A VM move changes several variables. It can be a safe mitigation if pretested,
but recovery after migration does not prove the old host alone was faulty.

### Kubernetes: PVC is an API object, not a performance boundary

Map:

```text
request -> pod/container -> mount -> PVC -> PV -> StorageClass
        -> CSI publish/attach -> node device or network mount
        -> backend volume -> pool/topology/durability boundary
```

CSI means Container Storage Interface. It standardizes interactions between
Kubernetes and storage plugins; it does not standardize every backend
performance guarantee. Compare:

- pod, node, zone and revision;
- PVC/PV/attachment identity;
- node mount and major:minor;
- container/cgroup demand and limits;
- provider volume IOPS, throughput, latency, throttle and errors;
- backend placement and shared failure domain;
- application commit/read/checkpoint spans.

Pod restart can relocate cache and attachments, trigger image pulls, and erase
volatile evidence. Preserve before replacement.

### Databases: one transaction creates many storage events

A database transaction may update data pages, indexes, a write-ahead log, and
metadata; buffer pools can hide reads; group commit can combine durability;
checkpoints and compaction can create bursts. Start with database-native waits
and transaction latency, then join Linux and backend evidence.

Never infer data correctness from low device latency. Verify committed records,
replication state, recovery logs, and exactly-once or idempotency requirements.
Database recovery and filesystem repair require engine-specific runbooks.

### Network filesystems are not local block devices

NFS, SMB/CIFS, object-backed filesystem layers, and distributed filesystems can
have client cache, network, server, metadata, lock, and backend paths. A local
block tool may show only client cache or unrelated devices. Map protocol,
endpoint, mount options, DNS/routing, server and backend evidence. Later network
and distributed-system lessons deepen those layers.

### Cloud volumes: capacity, IOPS, throughput, credits, and latency

Managed volumes can expose separate limits and burst mechanisms. Scaling GiB
may change some limits for some products, but never assume it. A responsible
decision records the exact service, volume type/version, provisioned IOPS and
throughput, burst/credit state, queue/latency, attachment constraints, cost,
resize semantics, rollback limits, and data-protection plan. This core lesson
uses no cloud account and makes no provider-specific promise.

## Reliability, security, observability, capacity, and cost

### Reliability

A reliable storage path meets correctness, durability, latency, availability,
and recovery objectives under normal load and stated failures. Design for:

- explicit durability boundary;
- idempotent retries and uncertain-outcome reconciliation;
- bounded queues and backpressure;
- priority isolation between foreground and background work;
- failure-domain-aware replicas and placement;
- repair/rebuild headroom;
- tested backup and restore independent of availability replicas;
- rollout and configuration guards for I/O-pattern changes;
- degraded modes that preserve correctness.

Replication is not backup. Fast writes are not durable writes. A successful
failover is not proof all accepted work survived.

### Security

Storage diagnostics can expose file names, mount paths, database names, device
serials, volume IDs, tenant names, command lines, encryption topology, and data.
Use least privilege:

- prefer counters and metadata over file contents;
- restrict raw-device and debug interfaces;
- sanitize evidence before tickets or external tools;
- protect keys and never paste credentials;
- retain artifacts only as long as policy requires;
- audit production mutations;
- preserve encryption and access controls during failover/recovery;
- treat unexplained integrity errors as a possible security and data incident.

Running diagnostics as root because normal process visibility is incomplete is
not automatically justified. Use an approved support path.

### Observability

A useful storage dashboard joins layers but keeps them distinct:

| Layer | Signals |
|---|---|
| User operation | success, correctness, p50/p95/p99, deadline, retries |
| Application/engine | stage/wait histograms, queue age, commit/checkpoint/cache metrics |
| Filesystem/memory | mount identity, errors, Dirty, Writeback, writeback/reclaim pressure |
| Device | reads/writes, bytes, request size, await, outstanding work, busy time, errors |
| Workload owner | process/cgroup/container I/O, limits, original operations, background jobs |
| Platform/backend | attachment, path, IOPS/throughput policy, throttle, latency, queue, pool/rebuild |
| Recovery | backlog reconciliation, durable verification, healthy cohort, recurrence |

Alert on user impact or a credible early indicator, not `%util` alone. A queue-age
or commit-latency alert tied to objective is usually more actionable than a busy
device with healthy completions. Every alert should name scope, owner, first
questions, and safe runbook.

### Capacity

Storage capacity planning has at least three dimensions:

1. **Space** — live data, metadata, snapshots, logs, temporary files, growth,
   reservations, deletion lag, and recovery copies.
2. **Work** — IOPS, bytes/s, request size, read/write mix, sync frequency,
   concurrency, burst duration, and cache hit behavior.
3. **Objective and failure** — p95/p99, deadlines, rebuild, path loss, failover,
   backup/restore, maintenance, and growth headroom.

Measure representative mixed workloads in a disposable environment. A single
sequential benchmark does not represent random database commits, image pulls,
and backup streams together. Preserve enough headroom to recover while serving,
not only to survive a normal average.

### Cost

Cost includes more than GiB-month:

- provisioned IOPS and throughput;
- request or transaction charges;
- replicas, snapshots, backup, retention, and cross-zone/region transfer;
- idle recovery headroom;
- observability retention;
- engineer time and incident loss;
- performance tests and migration overlap;
- data egress and restore time.

The cheapest volume that misses latency or recovery objectives is not cheap. The
largest volume that masks an unbounded queue is not engineering. Tie spending to
measured workload and service objectives.

### Performance trade-off table

| Choice | Possible benefit | Risk / hidden cost | Required proof |
|---|---|---|---|
| More application concurrency | Higher throughput while device has parallel headroom | Longer queues, tail latency, retries, memory | Response curve and bounded queue under representative load |
| Larger write cache/buffer | Absorbs bursts | Larger durability backlog and flush cliff | Failure semantics, dirty trend, sync latency, recovery test |
| Batch/group commit | Fewer syncs, higher throughput | Added waiting and larger failure unit | Correctness protocol and latency distribution |
| Separate background pool | Isolation | Cost, imbalance, operational complexity | Topology and mixed-workload test prove isolation |
| Faster/provisioned volume | More service capacity | Cost and provider coupling | Same workload mix meets objective, including failure state |
| Reduce sync guarantees | Lower latency | Data loss or consistency failure | Usually a product correctness decision, never an incident shortcut |
| Compression/deduplication | Less data movement/capacity | CPU, memory, metadata and tail variability | End-to-end profile and failure/recovery test |

## Traps and prevention

### Trap: `%util` means percent full

It is busy time, not space. Name fields with units on dashboards:
`filesystem_block_use_percent` versus `device_busy_time_percent`.

### Trap: high `%util` proves saturation

Continuous activity is not the same as no useful headroom on a parallel device.
Prevent with baseline response curves and combined latency, queue, demand,
completion, error, throttle, and objective views.

### Trap: `wa` is disk utilization

`wa` is CPU accounting. Prevent with field tooltips that state owner and proof
limit, plus device and application latency next to CPU state.

### Trap: `await` is physical disk service time or p99

It is a device-boundary average under tool semantics. Prevent by naming it
`mean_device_request_completion_ms` and storing application histograms plus
lower-layer service telemetry.

### Trap: throughput is performance

Bytes/s ignores operation size, latency, queueing and sync. Prevent capacity
reviews from approving a path on MiB/s alone.

### Trap: the busiest process is guilty

A legitimate writer can be a victim of slow service. Kernel writeback can also
separate process issue time from device submission. Prevent with path/cgroup
mapping, original-operation accounting, healthy cohorts, and bounded controls.

### Trap: restarting clears I/O

Restarting can flush, discard cache, replay logs, relocate work, or amplify
reads/attachments. It can restore service and still hide cause or threaten
capacity. Preserve evidence and verify data before and after.

### Trap: drop caches to test the disk

Dropping caches changes shared state and creates a burst of lower-layer work.
Use a disposable controlled dataset or existing cache telemetry. Never use it as
a production diagnostic shortcut.

### Trap: run `dd` because it is installed

`dd` copies bytes; it does not automatically control cache, durability, queue
depth, request mix, alignment, safety, or verification. Use a reviewed benchmark
design in a disposable target with a strict path, size, duration and cleanup.

### Trap: make dirty ratios larger

This can delay visible pressure while increasing the backlog and later tail.
Prevent with workload-level admission and durable-completion capacity, not blind
global tuning.

### Trap: two volumes mean two devices

Logical separation may share a pool, link, controller, host, cache or failure
domain. Prevent by making backend placement and isolation guarantees observable.

### Trap: scale storage before mapping the limit

More GiB may not change the constrained IOPS, throughput, credit, queue, path, or
application access pattern. Prevent with an explicit limit identity and change
prediction.

### Trap: recovery metric equals recovery

A lower queue or healthy pod does not prove a correct durable operation. Prevent
with synthetic/user-journey checks, transaction reconciliation, tail windows,
and healthy-control comparison.

## Memory card and retrieval

### The memory card

When you see slow storage, remember:

```text
PATH -> CACHE -> FILESYSTEM -> QUEUE -> DEVICE -> HIDDEN BACKEND -> RESULT
```

And ask seven questions:

1. Which real operation and objective failed?
2. Is this capacity, performance, durability, correctness, or a combination?
3. What exact path, mount namespace, filesystem, and major:minor identity?
4. Where did latency first appear relative to a healthy comparison?
5. Are arrivals, useful completions, outstanding work, and oldest work stable?
6. Which logical or hidden layers and workloads share the failure domain?
7. What bounded action preserves data, and how will the real operation prove
   recovery?

### Retrieval questions

Try these before revealing the next section.

1. A filesystem is 35 percent used, but writes take 900 ms. Why is that not a
   contradiction, and which path do you inspect?
2. `iostat` shows 100 MiB/s in both healthy and incident intervals, while
   `w_await` rises from 4 ms to 400 ms and `aqu-sz` rises from 1 to 80. Explain
   without saying “throughput is fine.”
3. What exactly does `%util=100` prove, and why can an NVMe or virtual device
   still have headroom?
4. Why can `write()` be fast while `fsync()` is slow? Include Dirty and
   Writeback state.
5. Compare `vmstat wa`, `iostat await`, application p99, and `pidstat iodelay`.
6. Why do you run `findmnt -T` before choosing a row in `iostat`?
7. A restart restores latency. What do you verify before declaring recovery,
   and what causal questions remain?

### Spaced review

- **Tomorrow:** draw the write path and decode IOPS, throughput, latency,
  outstanding work, `%util`, Dirty and Writeback without notes.
- **In three days:** inspect a safe existing path with `findmnt`, `lsblk`, `df`,
  `/proc/meminfo`, and `vmstat`; record proof limits. Do not generate load.
- **In one week:** repeat the deterministic lab from clean state and explain the
  first abnormal boundary aloud.
- **In two weeks:** attempt `ASM-0015` with a reviewer-supplied unfamiliar read
  package. Do not use a model answer.
- **In one month:** design, but do not execute, a disposable benchmark plan with
  workload mix, safety budget, durability, baseline, abort, cleanup and cost.

## Complete answers

### 1. Free space with slow writes

There is no contradiction because capacity and completion performance are
different state axes. Thirty-five percent filesystem allocation says the mount
can likely allocate more filesystem blocks under that accounting boundary. It
does not measure cache state, filesystem locks/journal, block queue, device
latency, provider throttle, hidden pool, or sync duration.

Start with the slow application operation and exact path. Resolve the mount and
major:minor identity, trace logical parents, compare a healthy interval, locate
whether time is before write, inside sync, or after commit, then align Dirty,
Writeback, blocked tasks, mapped device read/write await and queue, process or
cgroup demand, errors and lower-layer evidence. Keep quota and lower capacity as
separate checks.

### 2. Same throughput, worse await and queue

The path completes the same byte rate, but represented writes remain outstanding
much longer. With compatible definitions, stable completion rate multiplied by
larger average time implies more average in-flight work, which agrees with the
`aqu-sz` increase. Possible explanations include smaller/more synchronous
requests, loss of service capacity, throttle, degraded path, backend contention,
or queue policy. Throughput is not fine if the user deadline is missed.

Verify request size/mix, sync frequency, arrival versus completion, exact device
mapping, application stage latency, read/write split, errors/throttles and lower
service telemetry. Do not derive p99 from average await.

### 3. Meaning of `%util=100`

Under common disk-stat derivation, the represented device had at least one
request in progress for nearly the entire interval. It does not mean filesystem
space is full. It also does not universally mean every hardware queue, channel,
or backend resource reached maximum useful throughput.

An NVMe or virtual device can serve many requests concurrently. Continuous
activity can be normal. Saturation is supported when additional demand no longer
produces useful completions within objective and persistent queue, latency,
throttle, errors or rejection appear. Compare a known healthy workload and
device-specific concurrency model.

### 4. Fast write, slow fsync

A buffered `write()` commonly copies or modifies page-cache pages and marks them
dirty; it can return before backing storage completes. `Dirty` counts modified
memory awaiting completed writeback. `Writeback` counts memory currently under
writeback. `fsync()` asks for the file's modified data and required metadata to
reach the documented storage boundary and waits for completion, so an existing
backlog or slow lower layer becomes visible in its latency.

Do not remove `fsync` to make graphs green unless the product intentionally
changes its data-loss contract. Investigate why durable completion is slow and
verify crash/recovery semantics.

### 5. Four different wait signals

- Application p99 is a tail threshold for a named user or service operation in
  a stated population and window.
- `iostat await` is an average completion time for represented block requests at
  a visible device boundary during a sample.
- `vmstat wa` is a percentage of CPU time accounted as idle while waiting for
  I/O, not request latency.
- `pidstat iodelay` is task I/O-delay accounting commonly reported in clock
  ticks, not automatically milliseconds or complete operation latency.

They can correlate but cannot be substituted or arithmetically combined without
matching definitions. Use them to locate boundaries.

### 6. Why path mapping comes first

`iostat` rows are device identities. The application uses a path in a mount
namespace. `findmnt -T` connects that exact path to mount target, source,
filesystem and major:minor. `lsblk` then shows visible layering. Without that
join, the busiest familiar-looking disk may be unrelated, and device-mapper,
overlay, network, container or VM boundaries may be missed.

The mapping is necessary but not sufficient: a virtual or managed backend can
remain hidden.

### 7. Restart recovery and remaining cause

Verify the real operation and correct durable result, not only process health.
Check p95/p99 over a representative window, errors/timeouts, original requests
versus retries, queues and oldest work, Dirty/Writeback, device/lower latency,
backlog reconciliation, replica/recovery state, healthy cohorts, and no duplicate
or lost effects.

A restart changes process state, cache, descriptors, connections, concurrency,
and possibly placement. Cause remains open: memory leak, lock, bad I/O pattern,
stale mapping, backend contention, throttle, failed path, cache state, or retry
amplification may all have changed together. Preserve pre-restart evidence and
test prevention separately.

### Assessment mapping

`ASM-0013` contains a complete diagnostic answer with proof limits and follow-up
questions. Attempt it first, then compare your reasoning. A strong answer names
the operation, maps the path, explains units and averages, ranks mechanisms,
chooses safe evidence, and verifies durable recovery.

## Product-company interview

`ASM-0014` presents a payments API and reporting job on separate Kubernetes
claims backed by one storage class. The interviewer is testing whether you can
reason across abstractions, not whether you memorize `iostat`.

### Strong answer shape

A strong senior answer begins:

> Payment authorization tail latency is degraded. Correctness is the protected
> invariant. The reporting start and logical-device wait are correlated; shared
> backend contention is not yet proven. Different PVCs and an in-limit byte rate
> do not establish latency isolation.

Then it covers:

1. **Command:** establish incident, operations, application, storage and
   communications ownership; freeze unsafe expansion; preserve failed and
   healthy evidence.
2. **Map:** operation → pod/container → mount → PVC/PV/StorageClass → CSI
   attachment → node device/network mount → backend volume/pool.
3. **Measure:** align commit p99, Dirty/Writeback, blocked tasks, guest device
   wait/queue, process/cgroup demand, provider throttle and backend latency.
4. **Compare:** same/different pool, node, zone, revision, old/new workload,
   report-on/report-bounded, read/write class.
5. **Hypotheses:** shared contention, throttle/credits, application sync change,
   writeback interaction, backend degradation, wrong mapping.
6. **Move:** one authorized reversible control with prediction, cohort, maximum
   duration, data-integrity abort and rollback.
7. **Verify:** exactly-once payment result, tail latency, retries, queues,
   backend recovery, backlog reconciliation and healthy controls.
8. **Prevent:** explicit mixed-workload performance contract, topology and
   isolation visibility, report admission/scheduling, capacity headroom,
   user-level SLI and tested runbook.

### Weak-answer warning signs

Watch for:

- “Kill the noisy neighbor” before mapping the shared boundary;
- “Restart all pods” without financial correctness or evidence preservation;
- “Bigger PVC” with no identified capacity/performance limit;
- treating `%util`, `wa`, throughput, or one provider metric as root cause;
- no interval, unit, device identity, baseline, or healthy cohort;
- no prediction, authorization, abort, rollback or durable verification;
- claiming rollback or relocation proves final root cause;
- ignoring security and sensitive topology in evidence.

### Level expectations

| Level | Expected response |
|---|---|
| Junior | Separates space from speed, checks exact path, reads basic latency/queue fields safely |
| Mid-level | Aligns application, cache/writeback, device and process evidence; proposes bounded mitigation |
| Senior | Leads incident, protects correctness, maps Kubernetes/VM/backend layers, handles ambiguity and recovery |
| Staff | Defines isolation/SLO/capacity contracts, cross-team ownership, economics, migration and prevention verification |

Read the full direct answer, foundation, evidence cards, weak-answer critique,
reasoning steps and answered follow-ups in `ASM-0014` only after attempting the
scenario aloud.

## Independent transfer and rubric

`ASM-0015` is deliberately answer-isolated. It changes from a guided write/commit
path to an unfamiliar read path with layered devices, differing cache state, and
a high-looking red herring. No model solution is stored or rendered.

Use:

```text
book/assessments/linux/ASM-0015.json
book/assessments/linux/ASM-0015-response-template.md
```

The Markdown file is a blank submission structure, not an answer key. Submit:

- safety and provenance card;
- path/state-owner diagram;
- normalized baseline/incident evidence with units and proof limits;
- at least four hypotheses and three evidence-based rejections;
- a valid Little's Law calculation or explicit reason it is invalid;
- at most one bounded experiment, or a reasoned refusal;
- recovery and correctness verification;
- production transfer that separates method from fixture facts.

The reviewer scores five 4-point dimensions: safety/provenance, path/metric
model, independent diagnosis, experiment/recovery judgment, and production
transfer/independence. Reading another diagnosis or receiving a model-generated
solution before submission invalidates independence and must be disclosed.

If you need help, return to guided practice and later attempt a fresh evidence
package. That is honest calibration, not failure.

## References and review

### Primary references

- `REF-0033` — Linux kernel I/O statistics fields: raw counter meanings, reset
  behavior, outstanding work, busy time, weighted time, discard and flush.
- `REF-0034` — Linux blk-mq: software staging queues, hardware dispatch queues,
  schedulers, tags, concurrency and completion ordering boundary.
- `REF-0035` — Linux VM sysctls: dirty thresholds, background writeback,
  expiration and writer throttling controls. Reference for explanation, not
  permission to tune production.
- `REF-0036` — Linux `fsync(2)`: file-data/metadata durability and containing
  directory limitation.
- `REF-0037` — sysstat upstream project: `iostat`, `pidstat`, `sar`, collection
  and version boundary.
- `REF-0038` — procps-ng `vmstat` upstream manual source.
- `REF-0039` — util-linux `lsblk` upstream manual source and explicit-column
  requirement.
- `REF-0040` — util-linux `findmnt` upstream manual source and exact target-path
  resolution.

All source claims are paraphrased. Local Ubuntu manuals and installed versions
remain authoritative for exact fields. Never copy an example from this lesson
into a production conclusion without re-observing identity, interval, unit and
scope.

### Review status

This lesson is `substantive-draft`, last reviewed 2026-08-02, with a scheduled
technical review by 2026-11-02. The deterministic lab's Ubuntu lifecycle and
negative safety tests are separately verifiable; that does not constitute
formal chapter acceptance.

Open acceptance work includes:

- independent technical review of kernel/sysstat wording across Ubuntu 24.04
  host, WSL 2, NVMe and device-mapper variants;
- ShellCheck and adversarial concurrency/race review of the lab harness;
- a separately designed disposable real-I/O experiment with strict resource,
  duration, durability and cleanup boundaries;
- reviewed learner evidence for `ASM-0015`;
- delayed retrieval and production-style transfer evidence;
- accessibility and browser review after reader integration.

### Final boundary

Reading this chapter can improve your model. Running the fixture can practice
the evidence loop. Passing automated schema, build, or lab checks can validate
artifacts. None of those proves that a learner can diagnose an unfamiliar
storage incident safely. Mastery requires original evidence, correct reasoning,
safe decisions, durable recovery verification, and explicit reviewer judgment.
