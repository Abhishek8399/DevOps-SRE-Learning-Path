export type CommandDecoderLessonId =
  | "storage"
  | "processes-signals-systemd"
  | "cpu-memory-pressure"
  | "network-request-path"
  | "identity-permissions";

export type CommandDecoderField = Readonly<{
  token: string;
  plainMeaning: string;
  operationalUse: string;
  trap: string;
}>;

export type CommandInterpretationPattern = Readonly<{
  signalCombination: string;
  likelyHypothesis: string;
  safestNextEvidence: string;
}>;

export type CommandDecoder = Readonly<{
  title: string;
  command: string;
  questionAnswered: string;
  prerequisiteExplanation: string;
  sampleOutput: string;
  fields: readonly CommandDecoderField[];
  interpretationPatterns: readonly CommandInterpretationPattern[];
  advancedNote: string;
}>;

export type CommandDecoderCatalog = Readonly<
  Record<CommandDecoderLessonId, readonly CommandDecoder[]>
>;

export const commandDecoders = {
  storage: [
    {
      title: "Map an exact path to its mounted filesystem",
      command: "findmnt -T /tmp -o TARGET,SOURCE,FSTYPE,OPTIONS",
      questionAnswered:
        "Which mount owns /tmp, what backs that mount, what filesystem type is it, and which mount options are active?",
      prerequisiteExplanation:
        "Run this on Ubuntu with util-linux installed. The path must exist. Using -T asks about the filesystem containing that exact path; it does not scan the contents of /tmp and does not change the mount.",
      sampleOutput: `TARGET SOURCE                                    FSTYPE OPTIONS
/      /dev/mapper/ubuntu--vg-ubuntu--lv          ext4   rw,relatime`,
      fields: [
        {
          token: "TARGET",
          plainMeaning: "The mount point whose filesystem contains the requested path.",
          operationalUse: "Establishes the boundary on which block, inode, quota, and read-only evidence must be collected.",
          trap: "It is not the original path and it is not a directory-size result. /tmp can be owned by /, a separate tmpfs, or another mount.",
        },
        {
          token: "SOURCE",
          plainMeaning: "The device, logical volume, network export, pseudo-filesystem, or layered source behind the mount.",
          operationalUse: "Distinguishes a local block device from tmpfs, NFS, overlay, a bind source, or a logical volume before remediation.",
          trap: "A device-looking name does not by itself prove the physical disk, storage array, or container host has the same capacity or failure domain.",
        },
        {
          token: "FSTYPE",
          plainMeaning: "The filesystem implementation, such as ext4, xfs, tmpfs, nfs4, or overlay.",
          operationalUse: "Determines which limits, repair tools, inode behavior, and mount semantics are relevant.",
          trap: "Filesystem type is mechanism, not health. Seeing ext4 does not prove that ext4 is corrupt or full.",
        },
        {
          token: "OPTIONS",
          plainMeaning: "Active mount behavior such as rw, ro, relatime, nosuid, nodev, or noexec.",
          operationalUse: "Quickly identifies a read-only mount or security option that can explain a failed operation even when capacity is healthy.",
          trap: "The abbreviated list is not every policy boundary. ACLs, Linux Security Modules, container settings, and application identity still matter.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "TARGET=/, FSTYPE=ext4, OPTIONS includes rw",
          likelyHypothesis: "The path uses the root filesystem and is writable at the mount layer; storage capacity or a deeper permission/policy limit still needs evidence.",
          safestNextEvidence: "Run df -hT /tmp and df -i /tmp, then inspect the exact failing operation and identity.",
        },
        {
          signalCombination: "FSTYPE=tmpfs",
          likelyHypothesis: "Capacity is memory-backed and can have a configured size or inode limit independent of the host disk's free bytes.",
          safestNextEvidence: "Run df -hT /tmp and df -i /tmp and inspect the tmpfs size/inode mount options without changing them.",
        },
        {
          signalCombination: "OPTIONS includes ro",
          likelyHypothesis: "Writes can fail because the mount is read-only, not because blocks or inodes are exhausted.",
          safestNextEvidence: "Read recent kernel and service logs to learn why it became read-only; do not remount until the cause and recovery plan are known.",
        },
      ],
      advancedNote:
        "In containers, findmnt runs inside the caller's mount namespace. An overlay source may represent the container writable layer while a bind mount or volume maps only a subpath elsewhere. Collect the command from the same namespace in which the application fails.",
    },
    {
      title: "Read data-block capacity for the exact filesystem",
      command: "df -hT /tmp",
      questionAnswered:
        "How much data-block capacity is used and available on the filesystem that contains /tmp?",
      prerequisiteExplanation:
        "Run as a normal user. GNU df is provided by coreutils. -h uses human-readable units, -T adds filesystem type, and the path argument prevents accidental inspection of an unrelated mount.",
      sampleOutput: `Filesystem                             Type  Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv      ext4   98G   41G   52G  45% /`,
      fields: [
        {
          token: "Filesystem",
          plainMeaning: "The source name reported for the mounted filesystem.",
          operationalUse: "Correlates this capacity row with findmnt, storage devices, logical volumes, and monitoring labels.",
          trap: "It can be an overlay, pseudo-filesystem, or network source rather than a physical disk.",
        },
        {
          token: "Type",
          plainMeaning: "The filesystem type.",
          operationalUse: "Provides context for reserved space, inode allocation, snapshots, quotas, and recovery behavior.",
          trap: "Type does not diagnose why space was consumed.",
        },
        {
          token: "Size",
          plainMeaning: "Total reportable data-block capacity in human-readable units.",
          operationalUse: "Defines the scale of the filesystem and lets you evaluate headroom in absolute units.",
          trap: "It is filesystem capacity, not necessarily the raw device size, thin-pool headroom, cloud-volume quota, or application quota.",
        },
        {
          token: "Used",
          plainMeaning: "Data blocks currently accounted as used by the filesystem.",
          operationalUse: "Shows block pressure and supports a trend or growth-rate investigation.",
          trap: "It does not name the producer. Deleted-but-open files, snapshots, reserved blocks, and filesystem accounting can make directory totals differ.",
        },
        {
          token: "Avail",
          plainMeaning: "Data-block capacity available to an unprivileged process.",
          operationalUse: "This is usually more relevant than Size minus Used when predicting whether the application can allocate more content.",
          trap: "Reserved blocks and quotas mean Size - Used may not equal Avail. A healthy Avail value does not imply free inodes.",
        },
        {
          token: "Use%",
          plainMeaning: "The filesystem's percentage of reportable data blocks in use.",
          operationalUse: "Provides a fast pressure signal and a useful alerting dimension when combined with absolute headroom and growth rate.",
          trap: "A percentage alone hides scale: 5% free on a 10 TiB filesystem differs greatly from 5% free on a 1 GiB filesystem.",
        },
        {
          token: "Mounted on",
          plainMeaning: "The mount point represented by this row.",
          operationalUse: "Confirms that df evaluated the filesystem owning the supplied path.",
          trap: "It is not the amount used by that directory; df reports the entire filesystem.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "Use% high and Avail close to zero",
          likelyHypothesis: "Data-block exhaustion is a credible immediate cause of failed writes.",
          safestNextEvidence: "Confirm the failing path maps to this mount, inspect growth and deleted-open files, and identify an authorized producer before changing data.",
        },
        {
          signalCombination: "Use% moderate with substantial Avail, but an application reports ENOSPC",
          likelyHypothesis: "A different allocation limit may be exhausted: inodes, quota, tmpfs/container limit, thin pool, or a different mount namespace.",
          safestNextEvidence: "Run df -i /tmp, findmnt -T /tmp, and the equivalent commands on the application's exact path and namespace.",
        },
      ],
      advancedNote:
        "df reads filesystem accounting rather than walking directory trees. That makes it fast, but it also means df and du answer different questions. If df is high while du is unexpectedly low, investigate deleted-but-open files, hidden mount boundaries, snapshots, and filesystem-reserved space.",
    },
    {
      title: "Read inode capacity independently of data blocks",
      command: "df -i /tmp",
      questionAnswered:
        "How many filesystem-object records are used and available on the filesystem that contains /tmp?",
      prerequisiteExplanation:
        "Run as a normal user. The path must exist. -i switches df from data-block accounting to inode accounting; it does not count files under /tmp.",
      sampleOutput: `Filesystem                              Inodes   IUsed    IFree IUse% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv       6553600  418221  6135379    7% /`,
      fields: [
        {
          token: "Inodes",
          plainMeaning: "Total inode records available in this filesystem's current accounting model.",
          operationalUse: "Defines the maximum object-record capacity against which file-count pressure is evaluated.",
          trap: "Some filesystems allocate inode structures dynamically or report unusual values; do not assume every filesystem behaves exactly like ext4.",
        },
        {
          token: "IUsed",
          plainMeaning: "Inode records currently allocated to filesystem objects.",
          operationalUse: "Shows object-count consumption even when those objects contain almost no data.",
          trap: "It is filesystem-wide and does not identify the directory, workload, or retention policy responsible.",
        },
        {
          token: "IFree",
          plainMeaning: "Inode records currently available for new filesystem objects.",
          operationalUse: "Zero or near-zero IFree directly threatens file and directory creation.",
          trap: "Freeing blocks by truncating a file does not free its inode. Deleting one huge file usually frees only one inode.",
        },
        {
          token: "IUse%",
          plainMeaning: "Percentage of inode capacity currently allocated.",
          operationalUse: "Provides a quick saturation signal and supports inode-headroom alerting.",
          trap: "Rounding can display 100% before the literal free count reaches zero; read IFree as well.",
        },
        {
          token: "Mounted on",
          plainMeaning: "The mount point whose inode pool is reported.",
          operationalUse: "Keeps the conclusion tied to the filesystem containing the tested path.",
          trap: "Another mount, container layer, or volume can have a completely different inode pool.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "IFree=0 while df -hT shows substantial Avail",
          likelyHypothesis: "Inode exhaustion is the immediate allocation failure behind ENOSPC.",
          safestNextEvidence: "Locate high-object-count directories with a narrowly scoped, read-only inode/file-count scan, then identify producer and retention policy before deleting anything.",
        },
        {
          signalCombination: "IFree healthy and block Avail healthy",
          likelyHypothesis: "The failure is probably outside basic filesystem-wide block and inode capacity.",
          safestNextEvidence: "Check exact mount namespace, user/project quota, read-only state, permissions, application limits, and the original error context.",
        },
      ],
      advancedNote:
        "Inode exhaustion is usually an object-lifecycle problem: uncontrolled temporary files, cache fragments, queue spools, or missing retention. Recovery frees only an approved population; prevention fixes the producer, lifecycle policy, alert, and capacity model.",
    },
  ],

  "processes-signals-systemd": [
    {
      title: "Read process identity, ancestry, state, and sampled pressure",
      command: "ps -eo pid,ppid,user,stat,%cpu,%mem,etime,cmd --sort=-%cpu | head",
      questionAnswered:
        "Which processes currently exist, who owns them, how are they related, what state are they in, and which appear highest by ps CPU percentage?",
      prerequisiteExplanation:
        "Run as a normal user with procps installed. This is a point-in-time process-table view. head limits output, so absence from the list does not mean a process is absent from the system.",
      sampleOutput: `    PID    PPID USER     STAT %CPU %MEM     ELAPSED CMD
   2410       1 api      Ssl   8.4  2.1       18:42 /usr/local/bin/api --config /etc/api.yml
   2418    2410 api      Sl    3.2  1.0       18:41 /usr/local/bin/api-worker
   1127       1 root     Ssl   0.6  0.4    02:11:08 /usr/bin/containerd`,
      fields: [
        {
          token: "PID",
          plainMeaning: "The process identifier for this running instance.",
          operationalUse: "Anchors safe follow-up inspection in /proc, logs, sockets, and signal targeting.",
          trap: "PIDs are reused. Reconfirm command, owner, and start/elapsed time before acting on a PID captured earlier.",
        },
        {
          token: "PPID",
          plainMeaning: "The parent process identifier.",
          operationalUse: "Reveals whether systemd, a shell, container runtime, supervisor, or application spawned the process.",
          trap: "Reparenting can make PID 1 appear as parent after the original parent exits; ancestry alone is not complete lifecycle history.",
        },
        {
          token: "USER",
          plainMeaning: "The effective account under which the process runs.",
          operationalUse: "Connects runtime identity to file access, socket ownership, limits, and least-privilege expectations.",
          trap: "A username does not show capabilities, namespaces, supplementary groups, SELinux/AppArmor policy, or container user mapping.",
        },
        {
          token: "STAT",
          plainMeaning: "Primary process state plus flags, such as S sleeping, R runnable, D uninterruptible sleep, Z zombie, s session leader, and l multithreaded.",
          operationalUse: "Separates a runnable process from one sleeping, blocked in kernel I/O, stopped, or awaiting parent reaping.",
          trap: "One sample can catch a healthy process sleeping. D state is a clue to inspect the wait, not proof that storage hardware is broken.",
        },
        {
          token: "%CPU",
          plainMeaning: "ps's CPU-time percentage for the process, generally normalized over the process lifetime rather than a fresh interval sample.",
          operationalUse: "Quickly ranks candidates for deeper interval-based CPU observation.",
          trap: "It is not a reliable one-second utilization reading. A short spike, multithreading, and process age can make the number easy to misread.",
        },
        {
          token: "%MEM",
          plainMeaning: "Resident memory as a percentage of the machine memory visible to ps.",
          operationalUse: "Ranks processes by approximate resident-memory share.",
          trap: "It does not represent a container cgroup limit, private-only memory, leak rate, or reclaimability.",
        },
        {
          token: "ELAPSED",
          plainMeaning: "Wall-clock time since the process started.",
          operationalUse: "Detects recent restarts and helps correlate runtime age with an incident timeline.",
          trap: "Long uptime does not prove health, and a new process does not reveal whether a human, supervisor, deployment, or crash loop started it.",
        },
        {
          token: "CMD",
          plainMeaning: "The command and arguments visible to ps.",
          operationalUse: "Confirms process identity and often reveals mode, config path, or worker role.",
          trap: "Arguments can be truncated or intentionally changed, and secrets must never be placed on a command line because process listings can expose them.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "ELAPSED is short, PPID=1, and several similar processes appear repeatedly",
          likelyHypothesis: "The service may be restarting or crash-looping under systemd or another supervisor.",
          safestNextEvidence: "Inspect the owning unit's status, restart counters, and journal around the first failure before manually restarting it.",
        },
        {
          signalCombination: "STAT contains D across repeated samples",
          likelyHypothesis: "The process is waiting in an uninterruptible kernel path, often involving I/O or a kernel resource.",
          safestNextEvidence: "Read /proc/PID/wchan, kernel/service logs, mount health, and device/network-storage evidence; avoid assuming SIGKILL can interrupt the wait.",
        },
        {
          signalCombination: "High %CPU in ps but users still report latency",
          likelyHypothesis: "This process is a CPU candidate, but lifetime-average ps data cannot establish present saturation or causality.",
          safestNextEvidence: "Use interval evidence such as vmstat, pidstat, top, or perf, and correlate with request rate and latency.",
        },
      ],
      advancedNote:
        "A process is only one namespace view of a workload. In containers, host and container PIDs can differ; systemd may manage the container runtime rather than the application; and cgroup CPU/memory limits can be tighter than host-wide percentages suggest.",
    },
    {
      title: "Decode a systemd unit's current lifecycle state",
      command: "systemctl status systemd-journald.service --no-pager --full",
      questionAnswered:
        "Is the journald unit loaded and active, what process does systemd track, what lifecycle result is known, and what recent log context is shown?",
      prerequisiteExplanation:
        "Run on Ubuntu where systemd is PID 1. The exact service is normally present on systemd-based Ubuntu. --no-pager keeps output in the terminal and --full avoids ellipsizing long fields; the command does not restart or modify the service.",
      sampleOutput: `● systemd-journald.service - Journal Service
     Loaded: loaded (/usr/lib/systemd/system/systemd-journald.service; static)
     Active: active (running) since Sat 2026-08-02 09:14:31 IST; 2h 18min ago
TriggeredBy: ● systemd-journald.socket
       Docs: man:systemd-journald.service(8)
   Main PID: 392 (systemd-journal)
     Status: "Processing requests..."
      Tasks: 1 (limit: 18950)
     Memory: 18.7M
        CPU: 2.431s
     CGroup: /system.slice/systemd-journald.service
             └─392 /usr/lib/systemd/systemd-journald`,
      fields: [
        {
          token: "Loaded",
          plainMeaning: "Whether systemd loaded the unit definition, its source path, and its enablement style.",
          operationalUse: "Detects missing, masked, or invalid unit configuration and points to the unit file systemd is using.",
          trap: "static is not the same as failed or disabled; static units are commonly activated by dependencies or sockets.",
        },
        {
          token: "Active",
          plainMeaning: "High-level active state, lower-level substate, and time since the current transition.",
          operationalUse: "Distinguishes active/running, inactive/dead, activating, deactivating, and failed lifecycle states.",
          trap: "active (running) proves a tracked process exists, not that the service is ready, correct, reachable, or meeting its SLO.",
        },
        {
          token: "TriggeredBy",
          plainMeaning: "Another unit, such as a socket, that can activate this service.",
          operationalUse: "Explains why a static or inactive-looking unit may start on demand.",
          trap: "Not every unit has this field, and activation relationship is not proof of successful request handling.",
        },
        {
          token: "Main PID",
          plainMeaning: "The principal process systemd currently associates with the service.",
          operationalUse: "Connects unit-level state to ps, /proc, sockets, resource usage, and signals.",
          trap: "Workers or child processes may do the real work, and forking/notify services can have lifecycle semantics beyond one PID.",
        },
        {
          token: "Status",
          plainMeaning: "Optional status text emitted by a service through systemd's notification interface.",
          operationalUse: "Provides service-specific progress or readiness context when implemented.",
          trap: "It is application-provided text, can be stale, and is not an independent health check.",
        },
        {
          token: "Tasks / Memory / CPU",
          plainMeaning: "Current cgroup task count and summarized resource accounting for the unit.",
          operationalUse: "Provides a bounded view of the service's process group rather than only its main PID.",
          trap: "A single snapshot does not show rate, limit proximity, throttling, or the cause of resource consumption.",
        },
        {
          token: "CGroup",
          plainMeaning: "The control-group path and processes that systemd displays for this unit.",
          operationalUse: "Defines the resource-accounting and lifecycle boundary systemd manages.",
          trap: "Escaped processes, delegated sub-cgroups, containers, or permissions can make the visible tree incomplete.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "Loaded=loaded and Active=failed",
          likelyHypothesis: "The definition exists, but the most recent start or runtime transition failed.",
          safestNextEvidence: "Read Result/ExecMainStatus with systemctl show and the unit journal around the first failure before retrying.",
        },
        {
          signalCombination: "Active=active (running), but users report outage",
          likelyHypothesis: "Process lifecycle is healthy from systemd's view while readiness, listener, dependency, or end-to-end behavior is not.",
          safestNextEvidence: "Check the expected socket, a bounded local health request, dependency state, and complete recent logs.",
        },
        {
          signalCombination: "Active timestamp is recent without an approved deployment",
          likelyHypothesis: "A crash, watchdog, dependency action, operator action, or automatic restart may have replaced the process.",
          safestNextEvidence: "Inspect journal history, NRestarts, ExecMainCode/Status, and change/audit records before another restart destroys evidence.",
        },
      ],
      advancedNote:
        "systemctl status intentionally shows only a small recent log tail and returns a non-zero status for some non-active states. For automation, query explicit properties with systemctl show; for diagnosis, use a bounded journalctl time window and verify the user journey separately.",
    },
  ],

  "cpu-memory-pressure": [
    {
      title: "Separate machine uptime from scheduler demand",
      command: "uptime",
      questionAnswered:
        "How long has the machine been running, how many sessions are counted, and what are the 1-, 5-, and 15-minute load averages?",
      prerequisiteExplanation:
        "Run as a normal user. uptime is a low-cost summary. Interpret load relative to the number of logical CPUs and alongside vmstat; load is not CPU utilization percentage.",
      sampleOutput:
        " 11:32:08 up 2 days,  3:17,  2 users,  load average: 6.42, 4.18, 2.07",
      fields: [
        {
          token: "11:32:08",
          plainMeaning: "Current system-local clock time.",
          operationalUse: "Helps align the observation with logs, alerts, and the incident timeline.",
          trap: "Clock skew or timezone differences can break correlation; this field does not prove time synchronization.",
        },
        {
          token: "up 2 days, 3:17",
          plainMeaning: "Elapsed time since the system booted.",
          operationalUse: "Reveals recent reboots and defines the period summarized by the first vmstat row's rate and CPU-percentage fields.",
          trap: "Host uptime is not service uptime. A process, container, or pod may have restarted many times since boot.",
        },
        {
          token: "2 users",
          plainMeaning: "Count of login sessions recorded in the utmp session database.",
          operationalUse: "Provides weak context for interactive activity during an incident.",
          trap: "It is not a count of unique humans and does not include every SSH multiplexed session, process, container, or automation identity.",
        },
        {
          token: "load average: 6.42",
          plainMeaning: "Exponentially damped average scheduler/load demand over roughly 1 minute.",
          operationalUse: "Shows the most recent direction of runnable and uninterruptible demand.",
          trap: "It is not 642% CPU. Linux load includes tasks runnable for CPU and tasks in uninterruptible sleep, commonly waiting in kernel I/O.",
        },
        {
          token: "4.18",
          plainMeaning: "The corresponding load average over roughly 5 minutes.",
          operationalUse: "Compares current demand with a medium window to see whether pressure is rising or falling.",
          trap: "Averages smooth bursts and do not identify which task or resource created the demand.",
        },
        {
          token: "2.07",
          plainMeaning: "The corresponding load average over roughly 15 minutes.",
          operationalUse: "Provides a longer baseline for the recent load trend.",
          trap: "A low 15-minute value cannot rule out a severe new spike, and a high value can remain after recovery.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "1-minute > 5-minute > 15-minute, and current load exceeds logical CPU count",
          likelyHypothesis: "Demand is rising and work may be queueing, but uptime cannot distinguish CPU contention from uninterruptible waits.",
          safestNextEvidence: "Run nproc and vmstat 1 5; use r/us/sy/id to test CPU pressure and b/wa/bi/bo to test blocked I/O.",
        },
        {
          signalCombination: "1-minute < 5-minute < 15-minute",
          likelyHypothesis: "A previously higher load is easing, although user impact or backlogs may still remain.",
          safestNextEvidence: "Check current vmstat intervals, latency/error telemetry, queue depth, and whether recovery is visible to users.",
        },
        {
          signalCombination: "Load is numerically high but CPU idle remains high in interval data",
          likelyHypothesis: "Uninterruptible waits or workload placement may contribute more than CPU execution demand.",
          safestNextEvidence: "Inspect vmstat b and wa, process states, wait channels, and storage/network-filesystem evidence.",
        },
      ],
      advancedNote:
        "A load of 8 has different meaning on 2 and 32 logical CPUs. Even after normalizing by CPU count, workload latency objectives, cgroup quotas, CPU affinity, run-queue distribution, and uninterruptible tasks determine whether the system is actually constrained.",
    },
    {
      title: "Decode runnable work, memory movement, I/O, and CPU time together",
      command: "vmstat 1 5",
      questionAnswered:
        "Across repeated one-second intervals, are tasks queueing for CPU, blocking, swapping, driving block I/O, or losing CPU time to kernel, I/O wait, or virtualization contention?",
      prerequisiteExplanation:
        "Run as a normal user with procps installed. vmstat prints five reports one second apart. In the first row, r, b, swpd, free, buff, and cache are current snapshots, while the rate and CPU-percentage fields summarize time since boot. Rows two through five use each requested one-second interval and should drive current-rate interpretation. Values are system-wide, not per process or per cgroup.",
      sampleOutput: `procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd      free   buff    cache   si   so    bi    bo    in    cs us sy id wa st
 1  0 131072   1435520 212480  8388608    0    0    18    42   310   620  3  1 95  1  0
 6  0 131072   1418232 212480  8397400    0    0     0    16  1180  2480 72 12 16  0  0
 8  0 131072   1411140 212480  8401120    0    0     0     8  1260  2710 78 11 11  0  0
 7  1 131072   1409812 212480  8402200    0    0  4096   640  1390  2890 61 10 18 11  0
 3  0 131072   1413200 212480  8399800    0    0    12    24   980  2010 30  6 64  0  0`,
      fields: [
        {
          token: "r",
          plainMeaning: "Number of tasks runnable: running on CPU or waiting for CPU time.",
          operationalUse: "Compare sustained interval values with logical CPU count to detect scheduler queueing.",
          trap: "One high sample can be a harmless burst. r does not include every blocked task and does not identify the responsible process.",
        },
        {
          token: "b",
          plainMeaning: "Number of tasks in uninterruptible sleep, commonly blocked in a kernel I/O path.",
          operationalUse: "Repeated non-zero values direct investigation toward waits rather than assuming CPU saturation.",
          trap: "b does not prove a disk hardware problem; network filesystems, devices, drivers, and other kernel waits can contribute.",
        },
        {
          token: "swpd",
          plainMeaning: "Amount of virtual memory currently placed in swap, normally reported in KiB by default.",
          operationalUse: "Shows that swap contains pages and supplies context for si/so activity.",
          trap: "Non-zero swpd alone is not active memory pressure. Cold pages can remain swapped out while the system is healthy.",
        },
        {
          token: "free",
          plainMeaning: "Completely unused physical memory, normally in KiB by default.",
          operationalUse: "Provides one component of memory state and helps explain immediate allocation headroom.",
          trap: "Linux intentionally uses otherwise-free memory for cache. Low free alone is not a memory incident; check free -h available and pressure/activity signals.",
        },
        {
          token: "buff",
          plainMeaning: "Memory used for kernel block-device buffers, normally in KiB.",
          operationalUse: "Separates buffer accounting from completely unused memory.",
          trap: "It is not the total filesystem cache and is rarely a standalone incident signal.",
        },
        {
          token: "cache",
          plainMeaning: "Memory used as page cache and related reclaimable cache accounting, normally in KiB.",
          operationalUse: "Explains why free memory can be low while reusable memory remains available.",
          trap: "Not all cache is instantly or equally reclaimable, and this column does not show cgroup-specific reclaim pressure.",
        },
        {
          token: "si",
          plainMeaning: "Swap-in rate: memory read from swap into RAM per second, normally KiB/s.",
          operationalUse: "Sustained activity can show that needed pages are being faulted back from swap.",
          trap: "A brief non-zero sample is not automatically thrashing; correlate with so, available memory, latency, and pressure over time.",
        },
        {
          token: "so",
          plainMeaning: "Swap-out rate: memory written from RAM to swap per second, normally KiB/s.",
          operationalUse: "Sustained output under low available memory is strong evidence of active reclaim pressure.",
          trap: "Swap-out can occur proactively. It does not by itself identify a leak or the process causing pressure.",
        },
        {
          token: "bi",
          plainMeaning: "Blocks received from block devices per second after the first row.",
          operationalUse: "Shows read-side block-I/O activity and helps contextualize b and wa.",
          trap: "procps reports blocks/s and does not change bi/bo with --unit; do not silently relabel the value as bytes or KiB. Activity is not latency, queue depth, utilization, or proof of saturation.",
        },
        {
          token: "bo",
          plainMeaning: "Blocks sent to block devices per second after the first row.",
          operationalUse: "Shows write-side block-I/O activity and helps connect workload phases to waits.",
          trap: "procps keeps bi/bo in blocks/s even when --unit changes other fields. Buffered writes can appear later than the application call, and high throughput can be healthy.",
        },
        {
          token: "in",
          plainMeaning: "Interrupts handled per second, including the clock interrupt, after the first row.",
          operationalUse: "Provides system-activity context and can expose an interrupt storm when compared with baseline and CPU cost.",
          trap: "High in is workload- and hardware-dependent; it is not automatically a fault and does not name the interrupt source.",
        },
        {
          token: "cs",
          plainMeaning: "Context switches per second after the first row.",
          operationalUse: "Shows scheduler switching activity and can support a hypothesis about excessive concurrency or wakeups.",
          trap: "High cs can be normal for asynchronous workloads. It needs a baseline and process/thread-level evidence.",
        },
        {
          token: "us",
          plainMeaning: "Percentage of CPU time spent running user-space code.",
          operationalUse: "High us with high r and low id supports user-code CPU demand or saturation.",
          trap: "It does not identify the process, distinguish useful work from spinning, or account for a tighter cgroup CPU quota.",
        },
        {
          token: "sy",
          plainMeaning: "Percentage of CPU time spent executing kernel code.",
          operationalUse: "High sy can direct investigation toward syscalls, networking, storage, interrupts, or kernel overhead.",
          trap: "Kernel time is not automatically a kernel bug; workload behavior often drives it.",
        },
        {
          token: "id",
          plainMeaning: "Percentage of CPU time idle.",
          operationalUse: "Persistently low id alongside high r and us/sy supports CPU scarcity at the visible host level.",
          trap: "Host idle can coexist with container throttling, CPU affinity constraints, or one saturated core, so system-wide id can hide local scarcity.",
        },
        {
          token: "wa",
          plainMeaning: "Percentage of CPU time classified as idle while the system has outstanding I/O work.",
          operationalUse: "When sustained with b and device activity, it supports an I/O-wait hypothesis.",
          trap: "wa is not disk utilization or the percentage by which storage is slow. Multiprocessor accounting and workload concurrency make it easy to overinterpret.",
        },
        {
          token: "st",
          plainMeaning: "Percentage of CPU time a virtual CPU was ready but the hypervisor used the physical CPU elsewhere.",
          operationalUse: "Sustained steal time points toward noisy-neighbor or hypervisor capacity contention outside the guest.",
          trap: "Zero st does not prove the virtualization layer is healthy, and bare-metal systems normally report zero.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "Rows 2+ show r persistently above logical CPU count, us+sy high, and id near zero",
          likelyHypothesis: "Runnable work is queueing for CPU and host-visible CPU saturation is credible.",
          safestNextEvidence: "Run nproc. For advanced per-CPU and per-process sampling, first check for the optional sysstat package, then use mpstat -P ALL 1 and pidstat -u 1. Check cgroup quota/throttling and workload latency before tuning or scaling.",
        },
        {
          signalCombination: "Rows 2+ show b elevated with wa and bi/bo activity while id is not consumed by us/sy",
          likelyHypothesis: "Tasks are blocked in I/O-related kernel paths and storage or another blocking subsystem may be delaying progress.",
          safestNextEvidence: "Inspect process D-state/wchan, mount type, and kernel logs. If the optional sysstat package is present, iostat -xz 1 and pidstat -d 1 add device and process interval evidence.",
        },
        {
          signalCombination: "si and so remain non-zero, free -h available is low, and latency rises",
          likelyHypothesis: "Active memory reclaim and swapping may be causing memory-pressure latency or thrashing.",
          safestNextEvidence: "Read free -h, /proc/pressure/memory, cgroup memory.current/events, and per-process RSS/fault rates; do not disable swap as the first move.",
        },
        {
          signalCombination: "st remains material across rows 2+",
          likelyHypothesis: "The guest is losing scheduled CPU time to its hypervisor or shared host.",
          safestNextEvidence: "Compare guest demand with hypervisor/cloud steal and host-allocation metrics, CPU limits, placement, and neighboring workload changes.",
        },
        {
          signalCombination: "Only the first row's rate or CPU-percentage fields look busy while rows 2+ are quiet",
          likelyHypothesis: "Since-boot rate and CPU averages are being mistaken for present pressure; the first row's process and memory fields are still snapshots.",
          safestNextEvidence: "Interpret rows 2+ for current rates, continue reading r/b and memory as snapshots, or use vmstat -y 1 5 where supported to omit the first report.",
        },
      ],
      advancedNote:
        "Read vmstat horizontally as combinations, not vertically as isolated thresholds. r/us/sy/id describe scheduler and CPU pressure; b/wa/bi/bo describe blocking context; swpd/si/so need free/available and Pressure Stall Information (PSI); in/cs need a workload baseline; st moves the investigation outside the guest. In row one, snapshot columns remain current while derived rates and CPU percentages cover time since boot; later rows use the requested interval.",
    },
    {
      title: "Distinguish unused memory from safely reclaimable headroom",
      command: "free -h",
      questionAnswered:
        "What do procps's overlapping views of visible used, free, shared, cache/buffer, available, and swap memory report at this moment?",
      prerequisiteExplanation:
        "Run as a normal user with procps installed. -h selects human-readable binary units. Treat this as a host-visible snapshot and pair it with interval and pressure evidence; in a container it may not represent the cgroup limit that can trigger OOM.",
      sampleOutput: `               total        used        free      shared  buff/cache   available
Mem:            15Gi       6.1Gi       1.4Gi       412Mi       8.0Gi       8.9Gi
Swap:          2.0Gi       128Mi       1.9Gi`,
      fields: [
        {
          token: "Mem: total",
          plainMeaning: "Physical memory visible to this operating-system view.",
          operationalUse: "Defines the denominator for host memory headroom and scale.",
          trap: "Inside a container, visible host total can exceed the cgroup memory limit that actually governs the workload.",
        },
        {
          token: "Mem: used",
          plainMeaning: "On modern procps, MemTotal minus MemAvailable; in this sample, about 15 GiB minus 8.9 GiB equals 6.1 GiB.",
          operationalUse: "Provides a broad consumption signal to compare over time.",
          trap: "It is not the sum of application heaps. Because available is an estimate and columns overlap, do not add used, free, shared, and buff/cache as if they were a clean partition.",
        },
        {
          token: "Mem: free",
          plainMeaning: "RAM with no current use at all.",
          operationalUse: "Shows immediately unused pages, but is secondary to available for normal Linux headroom decisions.",
          trap: "Low free is normal when Linux uses RAM for cache; alerting on free alone creates false incidents.",
        },
        {
          token: "Mem: shared",
          plainMeaning: "Memory used mainly by tmpfs and shared-memory mappings as reported from Shmem.",
          operationalUse: "Can expose growth in tmpfs-backed workloads or interprocess shared memory.",
          trap: "It is not simply memory duplicated between processes and should not be added blindly to other columns.",
        },
        {
          token: "Mem: buff/cache",
          plainMeaning: "Buffer and page-cache memory, including reclaimable kernel cache according to procps accounting.",
          operationalUse: "Explains productive filesystem caching and potential reclaimable capacity.",
          trap: "Reclaim is not free or instantaneous, and some cache can be dirty, pinned, hot, or constrained by cgroups.",
        },
        {
          token: "Mem: available",
          plainMeaning: "Kernel-informed estimate of memory that can be given to new work without swapping, including reclaimable cache.",
          operationalUse: "Best single free output field for near-term host memory headroom.",
          trap: "It is an estimate, not a guarantee or cgroup-aware application SLO; rapid allocation and reclaim behavior still matter.",
        },
        {
          token: "Swap: total",
          plainMeaning: "Total configured swap capacity visible to the host.",
          operationalUse: "Shows whether swap is available as a pressure buffer and establishes its scale.",
          trap: "More swap does not fix a memory leak and can convert fast OOM failure into severe latency.",
        },
        {
          token: "Swap: used",
          plainMeaning: "Pages currently stored in swap.",
          operationalUse: "Supplies context for memory history and must be paired with vmstat si/so to detect active movement.",
          trap: "Used swap can remain non-zero after pressure ends; it does not prove current thrashing.",
        },
        {
          token: "Swap: free",
          plainMeaning: "Configured swap capacity not currently allocated.",
          operationalUse: "Shows remaining swap buffer if host policy permits its use.",
          trap: "Free swap is not equivalent to available RAM and does not make a latency-sensitive workload safe under pressure.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "free is low, buff/cache is large, and available remains healthy",
          likelyHypothesis: "Linux is using otherwise-idle RAM productively for cache; basic host memory headroom is likely healthy.",
          safestNextEvidence: "Check application latency and PSI; observe available over time rather than clearing caches.",
        },
        {
          signalCombination: "available is persistently low, vmstat si/so are active, and memory PSI/latency rises",
          likelyHypothesis: "The machine or cgroup is under active memory pressure and reclaim/swapping may be harming service latency.",
          safestNextEvidence: "Inspect cgroup memory.current, memory.events and limits, /proc/pressure/memory, process RSS/anonymous growth, and OOM logs before changing limits.",
        },
        {
          signalCombination: "Swap used is non-zero but vmstat si/so stay zero and available is healthy",
          likelyHypothesis: "Cold pages remain in swap from earlier pressure; current thrashing is not demonstrated.",
          safestNextEvidence: "Trend available, si/so, major faults, and latency. Do not cycle swap or restart workloads solely to make used swap read zero.",
        },
      ],
      advancedNote:
        "On modern procps, used is calculated from total minus available, while shared and cache-related accounting overlap other views; the row is not an additive partition. Combine free with PSI and cgroup v2. A host can have available memory while a container reaches memory.max. OOM victim choice also considers cgroup scope and oom_score_adj, a per-process preference value, not only Resident Set Size (RSS).",
    },
  ],

  "network-request-path": [
    {
      title: "Ask the kernel which route and source address it would choose",
      command: "ip route get 1.1.1.1",
      questionAnswered:
        "For destination 1.1.1.1, which next hop, interface, source address, and policy-routing result would this network namespace select?",
      prerequisiteExplanation:
        "Run as a normal user with iproute2 installed. This performs a local route lookup; it does not send a packet and does not prove that the destination or gateway responds.",
      sampleOutput:
        "1.1.1.1 via 172.22.64.1 dev eth0 src 172.22.74.25 uid 1000\n    cache",
      fields: [
        {
          token: "1.1.1.1",
          plainMeaning: "The destination address evaluated by the routing policy database.",
          operationalUse: "Keeps the route conclusion tied to one exact destination.",
          trap: "A hostname can resolve to several IPv4/IPv6 addresses that take different routes.",
        },
        {
          token: "via 172.22.64.1",
          plainMeaning: "The selected next-hop gateway.",
          operationalUse: "Shows where packets leave the local subnet and which neighbor must be reachable first.",
          trap: "A selected gateway does not prove ARP/neighbor resolution, forwarding, firewall passage, or return routing.",
        },
        {
          token: "dev eth0",
          plainMeaning: "The egress network interface selected for this lookup.",
          operationalUse: "Scopes interface state, address, packet counters, captures, and namespace investigation.",
          trap: "Interface names and routes are namespace-specific; the host, container, and pod can select different devices.",
        },
        {
          token: "src 172.22.74.25",
          plainMeaning: "The preferred local source address the kernel would use.",
          operationalUse: "Explains return-path, allow-list, policy-routing, and source-NAT expectations.",
          trap: "Applications can bind another source address, and NAT can rewrite it after this routing decision.",
        },
        {
          token: "uid 1000",
          plainMeaning: "The user identity considered for rules that route by UID.",
          operationalUse: "Helps explain policy-routing differences between services or users.",
          trap: "UID routing is only one selector; marks, source, destination, interfaces, and routing tables can also affect the result.",
        },
        {
          token: "cache",
          plainMeaning: "A marker in the formatted route-get result for the resolved route information.",
          operationalUse: "Indicates this is a resolved lookup result rather than a raw listing of one route-table row.",
          trap: "It does not prove an end-to-end connection or imply that a historical route cache guarantees reachability.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "A route returns with expected dev and src",
          likelyHypothesis: "The local routing decision exists and matches design, but downstream reachability remains unproved.",
          safestNextEvidence: "Check interface/link state and use a bounded connection test to the actual destination and port from the same namespace.",
        },
        {
          signalCombination: "Output reports unreachable or no route",
          likelyHypothesis: "The local routing policy cannot currently select a usable path for this destination.",
          safestNextEvidence: "Inspect ip address, ip link, ip rule, and the relevant ip route table; compare namespace and recent network changes.",
        },
        {
          signalCombination: "Selected src or dev differs from application/network policy expectations",
          likelyHypothesis: "Policy routing, multiple interfaces, VPN routes, or namespace placement can cause asymmetric or denied traffic.",
          safestNextEvidence: "Inspect ip rule and all relevant tables, then compare firewall/allow-list and return-route expectations without changing routes.",
        },
      ],
      advancedNote:
        "Routing answers only 'where would the kernel send it?' The complete path still includes neighbor discovery, local and remote firewalls, NAT, overlay/tunnel routing, load balancers, the reverse route, and the destination listener. Always run the lookup in the failing process's network namespace.",
    },
    {
      title: "Decode listening TCP sockets and their owning processes",
      command: "ss -lntp",
      questionAnswered:
        "Which TCP sockets are listening, on which local addresses and ports, with what queues, and—when permitted—which processes own them?",
      prerequisiteExplanation:
        "Run with iproute2 installed. -l selects listeners, -n keeps numeric addresses/ports, -t selects TCP, and -p requests process details. A normal user can inspect sockets but may not see ownership for processes it cannot inspect.",
      sampleOutput: `State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
LISTEN 0      4096   127.0.0.1:18080      0.0.0.0:*     users:(("python3",pid=2410,fd=3))
LISTEN 0      128          0.0.0.0:22         0.0.0.0:*`,
      fields: [
        {
          token: "-l",
          plainMeaning: "Show listening sockets rather than established connections by default.",
          operationalUse: "Answers whether a server-side TCP endpoint exists before testing the application protocol.",
          trap: "A listener is not readiness and does not prove that the process can complete a request.",
        },
        {
          token: "-n",
          plainMeaning: "Do not resolve addresses or service names; print numeric values.",
          operationalUse: "Avoids DNS/service-name delay and ambiguity during incident inspection.",
          trap: "Numeric output is precise but does not validate the hostname clients use or its DNS records.",
        },
        {
          token: "State",
          plainMeaning: "TCP socket state; this filtered view normally shows LISTEN.",
          operationalUse: "Confirms the kernel has a listening endpoint.",
          trap: "LISTEN does not prove the expected binary owns it, the accept loop is progressing, or dependencies are healthy.",
        },
        {
          token: "Recv-Q",
          plainMeaning: "For a listening socket, queued connection work currently waiting for the application to accept, subject to kernel details.",
          operationalUse: "A sustained growing queue can support an accept-loop or overload hypothesis.",
          trap: "Semantics differ from established sockets, and one snapshot or zero does not prove healthy request processing.",
        },
        {
          token: "Send-Q",
          plainMeaning: "For a listening socket, the configured maximum listen backlog shown by ss.",
          operationalUse: "Provides scale for interpreting the listener's current queue.",
          trap: "It is not bytes waiting to be sent for this LISTEN row and is not the application's end-to-end concurrency limit.",
        },
        {
          token: "Local Address:Port",
          plainMeaning: "The local IP scope and TCP port on which the socket accepts connections.",
          operationalUse: "Distinguishes loopback-only, one-interface, IPv4/IPv6, and all-interface bindings.",
          trap: "127.0.0.1 is reachable only inside that network namespace; 0.0.0.0 widens binding but firewalls and routing still control reachability.",
        },
        {
          token: "Peer Address:Port",
          plainMeaning: "For a listener, the wildcard remote endpoint from which connections may arrive at the socket layer.",
          operationalUse: "Confirms this row is not tied to one established peer.",
          trap: "0.0.0.0:* does not mean every remote host can reach it.",
        },
        {
          token: "Process",
          plainMeaning: "Owning process name, PID, and file descriptor when permissions allow ss to report them.",
          operationalUse: "Connects the socket to ps, service ownership, logs, and the exact runtime.",
          trap: "A blank field can mean insufficient permission, not absence of an owner; PIDs can also be namespace-relative.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "Expected port is absent",
          likelyHypothesis: "The process is not listening in this namespace, failed before bind, chose another port/address, or is not running.",
          safestNextEvidence: "Inspect service/process state and bind errors, then confirm configuration and namespace before restarting anything.",
        },
        {
          signalCombination: "Listener exists only on 127.0.0.1 but clients connect through a non-loopback interface",
          likelyHypothesis: "Bind scope prevents direct remote access unless a local proxy intentionally fronts the service.",
          safestNextEvidence: "Confirm architecture and proxy listener/configuration; do not widen the bind address without reviewing exposure and authentication.",
        },
        {
          signalCombination: "Recv-Q remains high or grows toward Send-Q",
          likelyHypothesis: "The application may be accepting connections too slowly or experiencing overload/backpressure.",
          safestNextEvidence: "Repeat interval observations, inspect application thread/event-loop state and latency, and correlate backlog/drop counters and load.",
        },
      ],
      advancedNote:
        "Socket visibility follows network namespaces. A host listener, container listener, Kubernetes Service, and ingress listener are different boundaries. Test each intended hop and do not infer pod readiness from a node-level socket alone.",
    },
    {
      title: "Follow a local TCP and HTTP exchange boundary by boundary",
      command: "curl -v --connect-timeout 3 http://127.0.0.1:18080/",
      questionAnswered:
        "Can this namespace connect to the loopback listener within three seconds, send an HTTP request, and receive an HTTP response?",
      prerequisiteExplanation:
        "Read this decoder now, but run the command only after Guided Local Lab Step 2 starts its disposable server on 127.0.0.1:18080. This exact URL avoids DNS and TLS on purpose. curl -v writes diagnostics to stderr and response content to stdout.",
      sampleOutput: `*   Trying 127.0.0.1:18080...
* Connected to 127.0.0.1 (127.0.0.1) port 18080
> GET / HTTP/1.1
> Host: 127.0.0.1:18080
> User-Agent: curl/8.5.0
> Accept: */*
< HTTP/1.0 200 OK
< Server: SimpleHTTP/0.6 Python/3.12.3
< Content-Type: text/html
<
sre-network-response=true`,
      fields: [
        {
          token: "--connect-timeout 3",
          plainMeaning: "Limit the connection-establishment phase to three seconds.",
          operationalUse: "Bounds a diagnostic that could otherwise wait too long at the connect boundary.",
          trap: "It is not a total request deadline. Use --max-time separately when the complete transfer must be bounded.",
        },
        {
          token: "Trying",
          plainMeaning: "The concrete address and port curl is attempting.",
          operationalUse: "Confirms the selected endpoint after URL parsing and, for hostnames, resolution.",
          trap: "It does not prove that a SYN received a reply or that this is the endpoint the real application selects.",
        },
        {
          token: "Connected",
          plainMeaning: "The TCP connection completed from curl's current namespace.",
          operationalUse: "Proves local routing and the TCP handshake to this address/port succeeded for this attempt.",
          trap: "It does not prove HTTP success, TLS identity, another client's path, or future availability.",
        },
        {
          token: ">",
          plainMeaning: "A request line or header curl sent to the server.",
          operationalUse: "Shows method, path, Host header, and relevant client headers actually transmitted.",
          trap: "Verbose output can expose authorization headers or cookies; never paste unredacted production traces containing secrets.",
        },
        {
          token: "<",
          plainMeaning: "A response status line or header received from the server.",
          operationalUse: "Separates successful TCP establishment from HTTP-level behavior and identifies the responding software/content metadata.",
          trap: "Headers can be generated by a proxy or error page rather than the intended backend.",
        },
        {
          token: "HTTP/1.0 200 OK",
          plainMeaning: "The server returned HTTP status 200 using HTTP/1.0 in this lab response.",
          operationalUse: "Confirms an HTTP response classified as successful for this request.",
          trap: "A 200 can still contain wrong or stale content, and curl without --fail returns success for many HTTP error statuses too.",
        },
        {
          token: "sre-network-response=true",
          plainMeaning: "The unique response body created by the controlled lab.",
          operationalUse: "Proves the response came from the intended teaching fixture rather than an unrelated listener returning a generic 200.",
          trap: "A static sentinel proves this lab path only; production health requires a representative user operation and dependency behavior.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "Trying appears, then connection refused",
          likelyHypothesis: "The route reached a host TCP stack, but no listener accepted that address/port or a firewall actively rejected it.",
          safestNextEvidence: "Run ss -lntp in the destination namespace and confirm bind address, port, process, and service logs.",
        },
        {
          signalCombination: "Trying appears, then connect timeout",
          likelyHypothesis: "Packets or replies may be silently dropped, misrouted, filtered, or the destination may be unreachable.",
          safestNextEvidence: "Check ip route get, interface state, firewall policy/counters, destination listener, and both forward and return paths.",
        },
        {
          signalCombination: "Connected appears, followed by HTTP 5xx or wrong sentinel",
          likelyHypothesis: "Basic TCP connectivity works; failure has moved to HTTP routing, application logic, dependency behavior, or the wrong listener.",
          safestNextEvidence: "Correlate request ID/time with proxy and application logs, verify Host/path, and test the intended dependency/user journey.",
        },
      ],
      advancedNote:
        "This loopback decoder deliberately removes DNS, TLS, proxies, NAT, and remote routing. In production, add one boundary at a time: resolve the real name, inspect route/source, verify TCP, validate certificate name/chain/time, inspect HTTP status/body, then test the user journey through the actual load balancer or ingress.",
    },
  ],

  "identity-permissions": [
    {
      title: "Decode the shell's user and group identity",
      command: "id",
      questionAnswered:
        "Which numeric user, primary group, and supplementary groups does this shell currently have?",
      prerequisiteExplanation:
        "Run in the same Ubuntu shell or execution context as the operation being investigated. No sudo is needed. Identity can differ across SSH sessions, systemd units, containers, and Kubernetes pods.",
      sampleOutput:
        "uid=1000(sreuser) gid=1000(sreuser) groups=1000(sreuser),27(sudo),998(docker)",
      fields: [
        {
          token: "uid=1000(sreuser)",
          plainMeaning: "The current user ID and its resolved account name.",
          operationalUse: "Provides the identity used for owner-bit checks and many access-control/audit decisions.",
          trap: "A name is a local resolution of a numeric ID. Containers, NFS, LDAP, and user namespaces can map the same number or name differently.",
        },
        {
          token: "gid=1000(sreuser)",
          plainMeaning: "The current primary group ID and resolved group name.",
          operationalUse: "Explains the group assigned by default to new files unless directory setgid or another mechanism changes it.",
          trap: "The primary group is not the only group considered during access checks.",
        },
        {
          token: "groups=...",
          plainMeaning: "All supplementary groups currently attached to this process, including the primary group.",
          operationalUse: "Tests whether group-mode bits or group ACL entries can apply to this shell.",
          trap: "A newly added group often requires a new login/session. /etc/group membership does not prove an already-running process received that group.",
        },
        {
          token: "27(sudo)",
          plainMeaning: "Membership in the sudo administrative-policy group on many Ubuntu installations.",
          operationalUse: "Explains potential authorization to request elevation under sudo policy.",
          trap: "Membership is not current root identity and does not guarantee every sudo command is permitted or passwordless.",
        },
        {
          token: "998(docker)",
          plainMeaning: "Example membership that can grant access to the Docker daemon socket.",
          operationalUse: "Explains why a user may control the local Docker daemon without sudo.",
          trap: "Docker-daemon control is effectively root-equivalent on typical hosts; treat this group as privileged, not as harmless convenience.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "File group matches an id supplementary group and group mode grants the required action",
          likelyHypothesis: "Traditional Unix group permissions may authorize the operation, assuming every parent directory is traversable and no stronger policy denies it.",
          safestNextEvidence: "Use namei -l on the exact path, stat/getfacl on the object, and test from the actual service identity.",
        },
        {
          signalCombination: "Expected supplementary group is absent from id",
          likelyHypothesis: "This running session did not receive the group, the membership is missing, or identity resolution differs in this context.",
          safestNextEvidence: "Compare getent group output and start a new approved login/session if membership recently changed; do not chmod 777 as a workaround.",
        },
        {
          signalCombination: "Interactive id differs from the service/container identity",
          likelyHypothesis: "A successful manual test may not reproduce the application's authorization context.",
          safestNextEvidence: "Inspect systemd User/Group, container runtime user, or Kubernetes securityContext and repeat read-only evidence in that context.",
        },
      ],
      advancedNote:
        "Linux access decisions can also involve filesystem UID/GID mappings, user namespaces, capabilities, POSIX ACLs, SELinux/AppArmor, seccomp, mount flags, and read-only container filesystems. id establishes the caller; it does not alone decide access.",
    },
    {
      title: "Trace permissions through every component of a pathname",
      command: "namei -l \"$LAB_DIR/app/config/settings\"",
      questionAnswered:
        "For each directory and the final file in this exact path, what type, mode, owner, and group does the kernel encounter during pathname traversal?",
      prerequisiteExplanation:
        "Read this decoder now, but run it only after Guided Local Lab Step 1 creates the sentinel-guarded LAB_DIR in the same normal-user shell. namei is supplied by util-linux. Stop if LAB_DIR is empty or no longer identifies the controlled lab.",
      sampleOutput: `f: /tmp/sre-permissions.Ab12Cd34/app/config/settings
drwxr-xr-x root     root     /
drwxrwxrwt root     root     tmp
drwx------ sreuser sreuser sre-permissions.Ab12Cd34
drwxr-x--- sreuser sreuser app
drwxr-x--- sreuser sreuser config
-rw-r----- sreuser sreuser settings`,
      fields: [
        {
          token: "f:",
          plainMeaning: "The full pathname namei is resolving component by component.",
          operationalUse: "Confirms that the evidence targets the intended object rather than a similar path.",
          trap: "A shell variable can be empty or stale; verify the controlled lab identity before trusting or acting on the path.",
        },
        {
          token: "d / -",
          plainMeaning: "The first mode character identifies object type: d directory and - regular file in this sample.",
          operationalUse: "Distinguishes traversal components from the final file and can reveal an unexpected symlink or object type.",
          trap: "Following symlinks can move resolution to another tree or mount; inspect unexpected l entries deliberately.",
        },
        {
          token: "rwx (owner triplet)",
          plainMeaning: "Permissions applied when the caller's effective UID owns that component.",
          operationalUse: "For directories, x permits traversal, r permits listing names, and w with x permits entry creation/removal subject to sticky and policy rules.",
          trap: "Directory read without execute can list some names but cannot normally resolve entries; directory write alone is not sufficient to create or remove entries.",
        },
        {
          token: "r-x / --- (group triplet)",
          plainMeaning: "Permissions considered when an applicable group matches and owner permissions do not apply.",
          operationalUse: "Finds a missing group traversal bit on any parent directory.",
          trap: "Traditional mode bits may be modified by a matching ACL entry or ACL mask; namei -l does not display the ACL.",
        },
        {
          token: "r-x / --- (other triplet)",
          plainMeaning: "Fallback permissions for callers matching neither owner nor an applicable group class.",
          operationalUse: "Explains access for unrelated identities and highlights unnecessarily broad exposure.",
          trap: "Opening other permissions to fix one service can expose data to every local identity and is rarely the least-privilege correction.",
        },
        {
          token: "root root / sreuser sreuser",
          plainMeaning: "Resolved owner and group for each path component.",
          operationalUse: "Lets you select the applicable mode class using id output.",
          trap: "Names can hide numeric mapping differences. Use numeric stat fields when containers, NFS, or user namespaces are involved.",
        },
        {
          token: "t in drwxrwxrwt",
          plainMeaning: "Sticky bit on /tmp: users can create entries, but removal/rename is restricted by ownership rules.",
          operationalUse: "Explains how a world-writable shared directory prevents arbitrary users from deleting one another's entries.",
          trap: "Sticky does not encrypt or hide filenames and does not replace private subdirectory permissions.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "The final file grants read, but one parent directory lacks x for the caller's applicable class",
          likelyHypothesis: "Path traversal fails before the kernel can reach the file, producing permission denied despite readable-looking file bits.",
          safestNextEvidence: "Use id to choose the applicable class and getfacl on the blocking directory; correct the narrow ownership/group/ACL design rather than broadening all modes.",
        },
        {
          signalCombination: "Every component appears traversable but access still fails",
          likelyHypothesis: "ACL, SELinux/AppArmor, read-only mount, immutable attributes, namespace mapping, or application identity may be the real boundary.",
          safestNextEvidence: "Check getfacl, findmnt options, lsattr, security/audit logs, and the exact service identity without changing permissions.",
        },
        {
          signalCombination: "An unexpected symlink appears in the path",
          likelyHypothesis: "The application resolves into a different directory, mount, or trust boundary than the textual path suggests.",
          safestNextEvidence: "Inspect the symlink target and mount mapping, then validate whether that indirection is expected before any ownership or mode change.",
        },
      ],
      advancedNote:
        "Path access is evaluated component by component. The final file's mode is only the last gate. In production, also consider symlink protections, sticky/setgid bits, default ACL inheritance, mount namespaces, idmapped mounts, and race-safe application APIs such as openat2 for hostile paths.",
    },
    {
      title: "Read exact file metadata in both symbolic and numeric form",
      command:
        "stat -c 'name=%n type=%F mode=%A octal=%a owner=%U:%G uid=%u gid=%g size=%s inode=%i links=%h' \"$LAB_DIR/app/config/settings\"",
      questionAnswered:
        "What is this exact object's type, mode, numeric ownership, size, inode number, and hard-link count?",
      prerequisiteExplanation:
        "Read this decoder now, but run it only after Guided Local Lab Step 1 creates and verifies LAB_DIR in the same normal-user shell. GNU stat is provided by coreutils. The custom format is read-only.",
      sampleOutput:
        "name=/tmp/sre-permissions.Ab12Cd34/app/config/settings type=regular file mode=-rw-r----- octal=640 owner=sreuser:sreuser uid=1000 gid=1000 size=9 inode=524381 links=1",
      fields: [
        {
          token: "%n / name=",
          plainMeaning: "The pathname stat inspected.",
          operationalUse: "Keeps copied evidence tied to the exact target.",
          trap: "It is the supplied path string, not proof that no symlink or rename race occurred before stat completed.",
        },
        {
          token: "%F / type=",
          plainMeaning: "Human-readable object type such as regular file, directory, or symbolic link.",
          operationalUse: "Prevents treating a device, directory, socket, or link as an ordinary file.",
          trap: "GNU stat reports the symbolic-link object by default. Add -L or --dereference only when you deliberately need the target's metadata, and remain alert to rename races.",
        },
        {
          token: "%A / mode=",
          plainMeaning: "Symbolic type and owner/group/other permission bits.",
          operationalUse: "Makes the familiar rwx permission model readable at a glance.",
          trap: "It does not fully display POSIX ACL entries, SELinux/AppArmor decisions, capabilities, or mount read-only state.",
        },
        {
          token: "%a / octal=",
          plainMeaning: "Permission and special bits in compact octal form, such as 640.",
          operationalUse: "Allows exact comparison with intended configuration and infrastructure code.",
          trap: "640 is not meaningful without object type, owner/group, caller identity, parent traversal, and additional policy layers.",
        },
        {
          token: "%U:%G / owner=",
          plainMeaning: "Resolved user and group names for the object's numeric IDs.",
          operationalUse: "Makes ownership readable to humans and ties it to id output.",
          trap: "Name resolution can fail or differ between host, container, NFS client, and directory service.",
        },
        {
          token: "%u / uid= and %g / gid=",
          plainMeaning: "Numeric owner user ID and group ID stored in file metadata.",
          operationalUse: "Provides stable evidence when names or namespace mappings differ.",
          trap: "The same numeric ID can represent a different principal across user namespaces or systems without coordinated identity mapping.",
        },
        {
          token: "%s / size=",
          plainMeaning: "Logical file size in bytes.",
          operationalUse: "Distinguishes empty/tiny metadata objects from content-heavy files.",
          trap: "Logical size is not allocated block usage; sparse files can have a large size with few blocks.",
        },
        {
          token: "%i / inode=",
          plainMeaning: "The inode number within this filesystem.",
          operationalUse: "Shows the metadata identity referenced by this directory entry and can correlate hard links.",
          trap: "An inode number is unique only within one filesystem and can be reused after deletion.",
        },
        {
          token: "%h / links=",
          plainMeaning: "Number of hard directory entries currently referencing the inode.",
          operationalUse: "Explains why removing one filename may not remove the inode or release its blocks.",
          trap: "Open file descriptors can keep an unlinked inode allocated even after link count reaches zero.",
        },
      ],
      interpretationPatterns: [
        {
          signalCombination: "uid/gid do not match the service identity and its groups, and other bits deny the operation",
          likelyHypothesis: "Traditional ownership/mode checks can explain the denial if path traversal and stronger policy layers agree.",
          safestNextEvidence: "Confirm the actual service id and namei -l traversal. For ACL detail, first check for getfacl from Ubuntu package acl, then inspect the exact path before proposing a narrow correction.",
        },
        {
          signalCombination: "mode appears sufficient but the filesystem is mounted ro",
          likelyHypothesis: "Permission bits permit the operation while the mount layer independently denies writes.",
          safestNextEvidence: "Run findmnt -T on the file and inspect kernel logs/reason for read-only state; do not chmod or remount blindly.",
        },
        {
          signalCombination: "links > 1 or an unlinked file remains open",
          likelyHypothesis: "One pathname deletion may not release the inode/data allocation as expected.",
          safestNextEvidence: "Inspect same-filesystem inode references. For open descriptors, first check for lsof from Ubuntu package lsof, then use lsof +L1 and coordinate with the owning process and retention policy.",
        },
      ],
      advancedNote:
        "stat exposes inode metadata, not the complete authorization decision. POSIX ACL masks, file capabilities, immutable/append-only attributes, mount flags, LSM policy, NFS root squashing, and container/user-namespace mappings can all change the operational result without changing the displayed 640 mode.",
    },
  ],
} as const satisfies CommandDecoderCatalog;
