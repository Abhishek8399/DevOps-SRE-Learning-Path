export type LessonGlossaryId =
  | "storage"
  | "processes-signals-systemd"
  | "cpu-memory-pressure"
  | "network-request-path"
  | "identity-permissions";

export type GlossaryEntry = Readonly<{
  term: string;
  plainMeaning: string;
  technicalMeaning: string;
  sreRelevance: string;
}>;

export type LessonGlossaries = Readonly<
  Record<LessonGlossaryId, readonly GlossaryEntry[]>
>;

export const lessonGlossaries: LessonGlossaries = {
  storage: [
    {
      term: "Filesystem",
      plainMeaning: "The rulebook Linux uses to organize names, files, directories, metadata, and stored bytes on one storage area.",
      technicalMeaning: "A filesystem is the data structure and implementation that maps directory entries to filesystem objects, tracks metadata, and allocates data blocks on a backing device or memory-backed store.",
      sreRelevance: "Capacity and failure belong to a particular filesystem. Checking a different mount can make healthy-looking evidence hide the real incident.",
    },
    {
      term: "Path",
      plainMeaning: "The address Linux follows to reach an object, such as /var/lib/api/uploads/report.log.",
      technicalMeaning: "A path is a sequence of directory-entry names resolved from the root directory or the process's current directory, with mounts potentially changing the filesystem during resolution.",
      sreRelevance: "Always test the exact failing path. Similar-looking directories can resolve to different disks, volumes, container layers, or tmpfs mounts.",
    },
    {
      term: "Mount point",
      plainMeaning: "The doorway where one filesystem is attached to the visible directory tree.",
      technicalMeaning: "A mount point binds a filesystem root to a directory so path resolution crosses from the parent filesystem into the mounted filesystem.",
      sreRelevance: "findmnt -T <path> reveals which filesystem owns the failed allocation and prevents remediation on the wrong device.",
    },
    {
      term: "Directory entry",
      plainMeaning: "The name tag inside a directory that points Linux toward an object.",
      technicalMeaning: "A directory entry associates a filename with an inode number in that filesystem. The filename is not stored in the inode itself.",
      sreRelevance: "This explains renames, hard links, and why deleting a name does not always release an object immediately.",
    },
    {
      term: "Inode",
      plainMeaning: "The filesystem record that describes one object; think identity and metadata, not the filename or file contents.",
      technicalMeaning: "An inode stores object type, ownership, permissions, timestamps, link count, size, and references used to locate file data. Each filesystem has a finite inode supply.",
      sreRelevance: "A filesystem can have free bytes but zero free inodes, causing new-file creation to fail with ENOSPC.",
    },
    {
      term: "Data block",
      plainMeaning: "A filesystem-sized piece of storage used to hold file content and filesystem structures.",
      technicalMeaning: "Filesystems allocate storage in blocks or extents from the backing store; allocation size and physical usage can differ from the logical number of bytes in a file.",
      sreRelevance: "df -hT measures block capacity. It answers a different question from df -i, so both may be needed during ENOSPC triage.",
    },
    {
      term: "Logical size and allocated size",
      plainMeaning: "Logical size is how long a file appears; allocated size is how much storage it actually occupies.",
      technicalMeaning: "A file's logical byte length may include sparse regions with no backing blocks, while filesystem allocation is rounded and tracked separately.",
      sreRelevance: "A large sparse file may consume little disk, while millions of zero-byte files may consume many inodes. File size alone is weak capacity evidence.",
    },
    {
      term: "Hard link",
      plainMeaning: "Another filename for the same inode and the same underlying file data.",
      technicalMeaning: "A hard link creates an additional directory entry pointing to an existing inode. The inode is released only after its link count reaches zero and no process still holds it open.",
      sreRelevance: "Deleting one name may not free the expected inode or blocks if another hard link still references the object.",
    },
    {
      term: "Symbolic link",
      plainMeaning: "A small file containing another path, similar to a sign pointing somewhere else.",
      technicalMeaning: "A symbolic link has its own inode and stores a path string that the kernel resolves when the link is followed; its target may be missing or on another filesystem.",
      sreRelevance: "A command aimed at a symlink can reach an unexpected mount or fail because the target moved. Verify the resolved path before changing state.",
    },
    {
      term: "File descriptor",
      plainMeaning: "A process's numbered handle to an open file, socket, pipe, or device.",
      technicalMeaning: "A file descriptor indexes the process's descriptor table and refers to a kernel open-file description that can remain valid after a directory entry is deleted.",
      sreRelevance: "A deleted but open log can keep consuming blocks until the owning process closes it, so pathname scans may not explain df usage.",
    },
    {
      term: "ENOSPC",
      plainMeaning: "Linux is saying, 'I could not allocate the storage resource this operation needs.' It is an alarm, not the full diagnosis.",
      technicalMeaning: "ENOSPC is the error returned when an allocation cannot proceed because a relevant limit such as free blocks or free inodes has been exhausted.",
      sreRelevance: "Do not immediately expand a disk or delete a large file. Map the exact path, then compare block, inode, quota, and runtime limits.",
    },
    {
      term: "Quota",
      plainMeaning: "A smaller allowance placed on a user, group, project, or workload even when the wider filesystem has room.",
      technicalMeaning: "Filesystem quota mechanisms enforce limits on block or inode consumption for an identity or project independently of global filesystem availability.",
      sreRelevance: "Healthy df output does not rule out a quota failure. Check the limits applied to the failing identity and workload.",
    },
    {
      term: "tmpfs",
      plainMeaning: "A filesystem whose contents live primarily in memory and can also use swap, rather than a normal disk partition.",
      technicalMeaning: "tmpfs is a volatile, memory-backed Linux filesystem with configurable size and inode limits; its contents disappear when unmounted or the system stops.",
      sreRelevance: "A path named /var or /cache may resolve to tmpfs. Disk dashboards may therefore be irrelevant to the failing allocation.",
    },
    {
      term: "Deleted-open file",
      plainMeaning: "A file whose name is gone but whose storage stays alive because a process still has it open.",
      technicalMeaning: "Unlinking removes a directory entry and decrements the inode's link count, but the kernel retains the inode and data until the last open reference is closed.",
      sreRelevance: "This explains the classic incident where du sees less usage than df. Find the owning process before deciding whether and how to release the space.",
    },
  ],

  "processes-signals-systemd": [
    {
      term: "Program",
      plainMeaning: "Executable instructions stored on disk; it is potential work, not work currently running.",
      technicalMeaning: "A program is executable code plus related data that the kernel can load to create a process.",
      sreRelevance: "Replacing a binary does not automatically change an already running process. Know whether a restart or reload is actually required.",
    },
    {
      term: "Process",
      plainMeaning: "One running instance of a program with its own identity, resources, and lifecycle.",
      technicalMeaning: "A process is a kernel-managed execution context containing a virtual address space, credentials, descriptor table, signal state, and one or more threads.",
      sreRelevance: "A process can exist yet be unhealthy, blocked, or unable to serve traffic. PID existence is not service health.",
    },
    {
      term: "PID",
      plainMeaning: "The number Linux currently uses to identify one process.",
      technicalMeaning: "A process identifier is unique within its PID namespace while that process exists, but the number can be reused after exit.",
      sreRelevance: "Re-identify the command and ownership before signaling a stored PID; otherwise PID reuse can make cleanup affect the wrong process.",
    },
    {
      term: "PPID and process tree",
      plainMeaning: "PPID tells you which parent created a process; the tree shows the chain of responsibility.",
      technicalMeaning: "Each process records a parent process identifier, allowing tools to represent ancestry among shells, service managers, runtimes, workers, and child processes.",
      sreRelevance: "The tree helps identify whether systemd, a container runtime, a supervisor, or the application will recreate a process after you stop it.",
    },
    {
      term: "Thread",
      plainMeaning: "One execution path inside a process that shares most resources with its sibling threads.",
      technicalMeaning: "Threads have separate scheduling state and stacks while sharing the process address space, open descriptors, and other resources.",
      sreRelevance: "One blocked or hot thread can harm a multithreaded service even when process-level averages hide the imbalance.",
    },
    {
      term: "Scheduler",
      plainMeaning: "The kernel decision-maker that chooses which runnable thread gets CPU time next.",
      technicalMeaning: "The Linux scheduler places runnable tasks on CPU run queues and allocates execution according to scheduling class, priority, affinity, and available processors.",
      sreRelevance: "Latency can come from waiting to run, not slow application code. Scheduler and run-queue evidence distinguish the two.",
    },
    {
      term: "Process state",
      plainMeaning: "A compact clue showing whether a task is running, sleeping, blocked, stopped, or already dead but not collected.",
      technicalMeaning: "Linux exposes states such as R for runnable, S for interruptible sleep, D for uninterruptible sleep, T for stopped, and Z for zombie.",
      sreRelevance: "A fleet of D-state tasks points toward kernel or I/O waits; a zombie points toward parent lifecycle handling. State narrows the next evidence to collect.",
    },
    {
      term: "Signal",
      plainMeaning: "A small asynchronous message sent to a process to request or report an event.",
      technicalMeaning: "Signals are kernel-delivered notifications with defined default actions; most can be caught, blocked, or handled by a process.",
      sreRelevance: "Signals are control mechanisms, not proof of root cause. Record who sent one and why before blaming the application.",
    },
    {
      term: "SIGTERM",
      plainMeaning: "A polite request to stop, giving the process a chance to finish and clean up.",
      technicalMeaning: "SIGTERM is signal 15 and can be handled so a process drains work, flushes state, closes resources, and exits deliberately.",
      sreRelevance: "It is the normal first shutdown signal because it preserves consistency and produces better operational evidence than an immediate kill.",
    },
    {
      term: "SIGKILL",
      plainMeaning: "The process cannot handle this stop signal or run application cleanup; it may still remain visible while an uninterruptible kernel wait finishes.",
      technicalMeaning: "SIGKILL is signal 9 and cannot be caught, blocked, or ignored by the application. The kernel marks the target for forced termination, but a task in uninterruptible D state may not disappear until its kernel wait returns.",
      sreRelevance: "Use only after bounded escalation. It can interrupt writes and hide shutdown faults, while repeated kill -9 attempts cannot repair the kernel or I/O wait holding a D-state task.",
    },
    {
      term: "Exit status",
      plainMeaning: "The small result number a process leaves when it finishes.",
      technicalMeaning: "A parent retrieves a child's termination status, including its normal exit code or the signal that ended it; shells commonly expose only a derived numeric value.",
      sreRelevance: "Code 137 suggests SIGKILL but does not identify who sent it or prove OOM. Correlate runtime, cgroup, and kernel evidence.",
    },
    {
      term: "Zombie process",
      plainMeaning: "A process that has finished but still has a tiny bookkeeping entry because its parent has not collected the result.",
      technicalMeaning: "A zombie retains a process-table record containing termination status until its parent calls a wait operation or exits.",
      sreRelevance: "Zombies consume PID-table capacity, not normal CPU or memory. Restarting unrelated services or killing the zombie cannot fix the parent's missing wait logic.",
    },
    {
      term: "File descriptor",
      plainMeaning: "A process's numbered handle to a file, socket, pipe, or device it is using.",
      technicalMeaning: "Descriptors index a per-process table of kernel-managed open resources and are constrained by per-process and system-wide limits.",
      sreRelevance: "Descriptor exhaustion can break accepts, logs, and dependency calls while CPU and memory look normal. Count usage and inspect limits over time.",
    },
    {
      term: "systemd unit",
      plainMeaning: "A declaration telling systemd what should exist and how it should be managed.",
      technicalMeaning: "A unit is systemd configuration describing a service, socket, mount, timer, target, or other managed object, including dependencies and lifecycle behavior.",
      sreRelevance: "The unit is desired configuration; the process is runtime state. Inspect both before changing either.",
    },
    {
      term: "Restart policy",
      plainMeaning: "The rule deciding whether a service manager should create another process after this one stops.",
      technicalMeaning: "systemd restart directives evaluate exit cause and timing to decide whether and when to start a replacement process, subject to rate limits.",
      sreRelevance: "A bad policy can turn one failure into a crash loop, overload a dependency, and erase the first meaningful error from view.",
    },
  ],

  "cpu-memory-pressure": [
    {
      term: "CPU and core",
      plainMeaning: "The hardware that executes instructions; multiple cores allow multiple runnable tasks to execute at the same time.",
      technicalMeaning: "A logical CPU is a schedulable execution context exposed to the kernel. Physical cores may expose more than one logical CPU through simultaneous multithreading.",
      sreRelevance: "Always compare demand and load with the available logical CPU count. Load 8 means very different pressure on 2 CPUs and 64 CPUs.",
    },
    {
      term: "Runnable task and run queue",
      plainMeaning: "Runnable work is ready for CPU; the run queue is the line of work waiting to execute.",
      technicalMeaning: "A runnable thread is executing or eligible to execute, and the scheduler organizes runnable tasks in per-CPU scheduling queues.",
      sreRelevance: "A growing runnable population is stronger evidence of CPU contention than one utilization percentage by itself.",
    },
    {
      term: "CPU utilization",
      plainMeaning: "The fraction of sampled time CPUs spent doing categories of work instead of being idle.",
      technicalMeaning: "Linux accounts CPU time across user, system, idle, iowait, steal, and other categories over an observation interval.",
      sreRelevance: "High utilization can be efficient and healthy. It becomes an incident when queueing, latency, errors, or lost throughput show useful work is suffering.",
    },
    {
      term: "Load average",
      plainMeaning: "A smoothed count of work that is running, waiting for CPU, or stuck in certain kernel waits.",
      technicalMeaning: "Linux load average estimates runnable tasks plus tasks in uninterruptible sleep over roughly 1, 5, and 15 minute windows.",
      sreRelevance: "Load includes more than CPU demand. Compare it with CPU count, process states, and I/O evidence before deciding to scale compute.",
    },
    {
      term: "User time and system time",
      plainMeaning: "User time runs application instructions; system time runs kernel work requested on behalf of tasks.",
      technicalMeaning: "CPU accounting separates execution in user mode from execution in privileged kernel mode, including system calls and kernel processing.",
      sreRelevance: "A jump in system time shifts investigation toward syscalls, networking, storage, contention, or kernel overhead rather than only application algorithms.",
    },
    {
      term: "I/O wait",
      plainMeaning: "CPU time recorded as idle while at least one task is waiting for input or output to complete.",
      technicalMeaning: "The iowait accounting category is reported when a CPU has no runnable work while the system has outstanding I/O; its interpretation has kernel and workload limitations.",
      sreRelevance: "High iowait is a clue, not proof of a bad disk. Correlate blocked tasks, device latency, throughput, and application calls.",
    },
    {
      term: "Context switch",
      plainMeaning: "The kernel pauses one task and lets another task use the CPU.",
      technicalMeaning: "A context switch saves and restores execution state when scheduling changes the running thread, either voluntarily or through preemption.",
      sreRelevance: "Excess switching can consume CPU without useful throughput and may reveal lock contention, too many threads, or tiny units of work.",
    },
    {
      term: "RAM",
      plainMeaning: "Fast working memory holding active code, data, and useful filesystem cache.",
      technicalMeaning: "Physical memory is managed in pages and shared among process memory, kernel structures, page cache, buffers, and reclaimable or pinned allocations.",
      sreRelevance: "Low unused RAM is normal because Linux uses memory productively. Diagnose pressure from availability, reclaim, swapping, latency, and failures.",
    },
    {
      term: "Virtual memory",
      plainMeaning: "Each process sees its own address map while the kernel decides which parts are backed by RAM, files, or swap.",
      technicalMeaning: "Virtual addresses are translated through page tables to physical pages or backing stores, enabling isolation, shared mappings, demand paging, and overcommit policies.",
      sreRelevance: "A process's virtual size is not its physical RAM consumption. Use resident, cgroup, and system evidence for capacity decisions.",
    },
    {
      term: "Memory page",
      plainMeaning: "A fixed-sized chunk the kernel uses as the basic unit for mapping and managing memory.",
      technicalMeaning: "Virtual and physical memory are divided into pages, commonly 4 KiB, with page-table entries recording mappings and access properties.",
      sreRelevance: "Page faults, reclaim, huge pages, and resident-memory measurements all build on this unit, so page behavior explains many latency spikes.",
    },
    {
      term: "Page cache",
      plainMeaning: "Linux keeps recently used file data in spare RAM so later access can avoid slower storage.",
      technicalMeaning: "The kernel caches filesystem-backed pages in memory and can reclaim clean cache pages when other allocations need space.",
      sreRelevance: "Cache makes free memory look low on healthy systems. Dropping it blindly can create an I/O storm and worse latency.",
    },
    {
      term: "MemAvailable",
      plainMeaning: "Linux's estimate of memory that new work can use without heavy swapping.",
      technicalMeaning: "MemAvailable combines currently free memory with portions of reclaimable page cache and kernel memory, accounting for reserves.",
      sreRelevance: "It is usually a better first capacity signal than MemFree, though workload trend and cgroup limits still matter.",
    },
    {
      term: "Memory reclaim",
      plainMeaning: "The kernel tries to recover usable memory by discarding reusable cache or writing eligible pages to backing storage.",
      technicalMeaning: "Direct or background reclaim scans memory lists, evicts clean file-backed pages, writes dirty data, and may move anonymous pages to swap.",
      sreRelevance: "Sustained reclaim can add latency long before OOM. Observe page scanning, faults, I/O, and application response time together.",
    },
    {
      term: "Swap",
      plainMeaning: "Disk-backed space where Linux can place less-active memory pages to keep RAM available for current work.",
      technicalMeaning: "Swap stores evicted anonymous memory pages outside RAM and brings them back on demand, with far higher access latency than memory.",
      sreRelevance: "Allocated swap is not automatically bad. Active swap-in and swap-out with latency and stalled work indicates real pressure.",
    },
    {
      term: "Thrashing",
      plainMeaning: "The machine spends more effort moving memory pages around than completing useful work.",
      technicalMeaning: "Thrashing occurs when a working set cannot remain resident, causing repeated faults, reclaim, and swap or file I/O with poor forward progress.",
      sreRelevance: "CPU may not look saturated while latency explodes. Scaling CPU alone will not fix a memory working-set problem.",
    },
    {
      term: "OOM kill",
      plainMeaning: "When memory cannot be recovered, the kernel or a cgroup ends a process so the system or workload can continue.",
      technicalMeaning: "The out-of-memory path selects a victim under global or cgroup memory exhaustion and terminates it, normally with SIGKILL, using policy and badness scoring.",
      sreRelevance: "Exit 137 is only a clue. Confirm kernel or cgroup OOM evidence, then fix the leak, workload, limit, or capacity model instead of guessing.",
    },
    {
      term: "Control group (cgroup)",
      plainMeaning: "A kernel boundary that measures and can limit the CPU, memory, process, and I/O resources used by a workload group.",
      technicalMeaning: "Linux cgroup v2 organizes processes in one hierarchy and exposes controller files such as cpu.max, memory.current, memory.max, and memory.events for accounting and control.",
      sreRelevance: "A host can look healthy while one container is throttled or reaches memory.max. Read workload cgroup evidence as well as host totals.",
    },
    {
      term: "Pressure Stall Information (PSI)",
      plainMeaning: "A measure of how much time useful work is delayed because CPU, memory, or I/O is unavailable.",
      technicalMeaning: "Linux PSI reports some and full stall-time percentages and cumulative microseconds through /proc/pressure and, where enabled, cgroup pressure files.",
      sreRelevance: "PSI connects resource contention to lost forward progress. It is often more useful than a capacity percentage alone when explaining latency.",
    },
    {
      term: "Resident Set Size (RSS)",
      plainMeaning: "The memory pages of a process that are currently present in physical RAM.",
      technicalMeaning: "RSS counts resident anonymous and file-backed mappings attributed to a process; shared pages can be counted in more than one process, so RSS values are not simply additive.",
      sreRelevance: "RSS helps find large residents but does not equal private memory, working set, cgroup charge, or proof of a leak.",
    },
    {
      term: "Working set",
      plainMeaning: "The memory a workload is actively reusing and needs to keep close for good performance.",
      technicalMeaning: "A working set is the set of pages referenced during a relevant time window; Linux and cgroup counters provide approximations rather than one universal exact value.",
      sreRelevance: "When the working set cannot stay resident, reclaim and faults repeat and latency rises even before an OOM kill.",
    },
    {
      term: "Page fault",
      plainMeaning: "A process touched a virtual-memory page that was not currently mapped in the way needed, so the kernel had to resolve it.",
      technicalMeaning: "A minor fault can be satisfied without storage I/O, while a major fault requires reading the page from a file or swap-backed storage before execution continues.",
      sreRelevance: "Rising major faults with reclaim, swap activity, and latency supports a memory-pressure hypothesis; a fault count alone does not prove thrashing.",
    },
  ],

  "network-request-path": [
    {
      term: "IP address",
      plainMeaning: "A numeric address used to identify a network interface or endpoint for routed communication.",
      technicalMeaning: "An IPv4 or IPv6 address is assigned with a prefix and used as a source or destination in IP packets; it identifies a network location, not application health.",
      sreRelevance: "A correct address narrows name resolution but does not prove routing, firewall permission, a listener, TLS, or application behavior.",
    },
    {
      term: "Subnet and CIDR prefix",
      plainMeaning: "The rule that says which part of an IP address describes the network and which part identifies an address inside it.",
      technicalMeaning: "CIDR notation pairs an address with a prefix length, defining the contiguous network bits used for route matching and address-range calculation.",
      sreRelevance: "A wrong prefix can send traffic to the wrong gateway, overlap networks, or make peers appear locally reachable when they are not.",
    },
    {
      term: "Network interface",
      plainMeaning: "The kernel's send-and-receive doorway for network traffic, physical or virtual.",
      technicalMeaning: "An interface has link state, addresses, MTU, counters, and queueing behavior; containers add virtual Ethernet interfaces and bridges.",
      sreRelevance: "Interface state and counters identify local drops, errors, wrong bindings, and namespace boundaries before blaming remote systems.",
    },
    {
      term: "Route",
      plainMeaning: "The kernel's decision for where a packet should leave and which next destination should receive it.",
      technicalMeaning: "Route lookup selects an output interface, source address, next hop, and policy using destination prefixes and routing rules.",
      sreRelevance: "ip route get shows the local decision, not end-to-end reachability. It is the correct bridge between a resolved IP and the wider path.",
    },
    {
      term: "Gateway",
      plainMeaning: "A router that accepts packets for destinations outside the directly reachable network.",
      technicalMeaning: "A gateway is the next-hop address selected by a route; the host sends a link-layer frame to it while retaining the final IP destination in the packet.",
      sreRelevance: "Gateway reachability is only one hop. Healthy local routing can coexist with a downstream route, policy, or return-path failure.",
    },
    {
      term: "DNS",
      plainMeaning: "The naming system that turns a service name into records such as IP addresses.",
      technicalMeaning: "The Domain Name System is a distributed hierarchy queried through configured resolvers, with record types, delegation, caching, and time-to-live behavior.",
      sreRelevance: "DNS success proves a record was returned, not that it is correct, reachable, or healthy. Compare the failing client's resolver and namespace.",
    },
    {
      term: "Socket",
      plainMeaning: "A kernel endpoint an application uses to send or receive network data.",
      technicalMeaning: "A socket combines protocol state with local and possibly remote addresses and ports, exposed to a process through a file descriptor.",
      sreRelevance: "Socket state connects the application to kernel networking. It shows whether a process is listening or a connection is established, waiting, or closing.",
    },
    {
      term: "Port and listener",
      plainMeaning: "A port selects a service on an address; a listener is a socket waiting for new connections there.",
      technicalMeaning: "Transport protocols use 16-bit port numbers. A server binds a local address and port, then listens so the kernel can queue incoming connection attempts.",
      sreRelevance: "Connection refused commonly means the destination actively reported no usable listener. Confirm binding address and namespace, not only the process name.",
    },
    {
      term: "TCP",
      plainMeaning: "A reliable ordered byte stream built between two endpoints before application data is exchanged.",
      technicalMeaning: "Transmission Control Protocol tracks sequence numbers, acknowledgements, retransmission, congestion, flow control, and connection state between address-port pairs.",
      sreRelevance: "TCP establishes transport, not application correctness. Its timing and state distinguish loss, refusal, reset, backlog, and slow-reader hypotheses.",
    },
    {
      term: "TCP handshake",
      plainMeaning: "The opening exchange where client and server agree that a connection can begin.",
      technicalMeaning: "The client sends SYN, the server replies SYN-ACK, and the client acknowledges, establishing sequence state before normal payload exchange.",
      sreRelevance: "A timeout, refusal, and reset imply different failure families. Identify the last packet or state instead of calling all three 'network down.'",
    },
    {
      term: "Network namespace",
      plainMeaning: "A separate network view with its own interfaces, routes, firewall rules, and sockets.",
      technicalMeaning: "A Linux network namespace isolates network devices, address configuration, routing tables, protocol state, and related kernel resources.",
      sreRelevance: "A request can work on the node but fail in a container or pod because each namespace follows a different path and policy.",
    },
    {
      term: "NAT",
      plainMeaning: "A device or kernel rule rewrites packet addresses or ports while traffic crosses a boundary.",
      technicalMeaning: "Network Address Translation changes source or destination tuple fields and maintains connection-tracking state so return traffic can be translated consistently.",
      sreRelevance: "NAT and state-table exhaustion can cause selective timeouts. Logs may show translated identities rather than the original client.",
    },
    {
      term: "TLS",
      plainMeaning: "The security layer that authenticates an endpoint and encrypts data after TCP connects.",
      technicalMeaning: "Transport Layer Security negotiates protocol parameters and keys, validates certificates according to trust policy, and protects record confidentiality and integrity.",
      sreRelevance: "TCP success plus TLS failure narrows investigation to name, trust, certificate, clock, protocol, cipher, or termination configuration.",
    },
    {
      term: "Certificate and SNI",
      plainMeaning: "A certificate binds identity to a public key; SNI tells a shared TLS endpoint which hostname the client wants.",
      technicalMeaning: "An X.509 certificate carries identity claims signed through a trust chain, while Server Name Indication is a TLS extension sent during negotiation for virtual hosting.",
      sreRelevance: "Connecting only by IP can select the wrong certificate or backend. Test the real hostname and inspect the complete presented chain.",
    },
    {
      term: "HTTP",
      plainMeaning: "The application protocol that carries methods, paths, headers, bodies, and status responses after transport is available.",
      technicalMeaning: "Hypertext Transfer Protocol defines request-response semantics and can run over multiple transport versions, commonly protected by TLS for HTTPS.",
      sreRelevance: "An HTTP status proves an HTTP-speaking component replied. Headers, request IDs, and logs identify whether a proxy or application produced it.",
    },
    {
      term: "Reverse proxy and load balancer",
      plainMeaning: "An entry component accepts a client request and forwards it to one of the services behind it.",
      technicalMeaning: "A reverse proxy terminates and creates connections on behalf of clients; a load balancer selects backends using health, policy, and distribution algorithms, often at transport or HTTP layers.",
      sreRelevance: "The client connection and upstream connection are separate failure boundaries. A proxy-generated 503 does not automatically prove the application returned 503.",
    },
  ],

  "identity-permissions": [
    {
      term: "UID",
      plainMeaning: "The number Linux uses as a user's identity when making access decisions.",
      technicalMeaning: "A user identifier is a numeric credential associated with a process and filesystem ownership; names are human-readable mappings supplied by user databases.",
      sreRelevance: "Matching usernames across hosts or containers do not guarantee matching UIDs. Mounted-volume access follows numbers, not labels.",
    },
    {
      term: "GID and supplementary groups",
      plainMeaning: "Group numbers let several identities share access without giving permission to everyone.",
      technicalMeaning: "A process has a primary group identifier and may have supplementary group identifiers used during discretionary access checks.",
      sreRelevance: "A service launched without the expected supplementary group can fail even though your interactive shell succeeds.",
    },
    {
      term: "Effective identity",
      plainMeaning: "The user and groups the kernel actually evaluates for the operation happening now.",
      technicalMeaning: "Processes carry real, effective, and saved user and group IDs; effective credentials normally drive filesystem permission checks.",
      sreRelevance: "Inspect the service, container, or pod process identity rather than assuming it matches the operator who started or deployed it.",
    },
    {
      term: "Owner, group, and other",
      plainMeaning: "Linux mode bits divide access into the object's owner, matching group members, and everybody else.",
      technicalMeaning: "The kernel selects one discretionary-access class based on file ownership and the process credentials, then evaluates that class's permission bits.",
      sreRelevance: "The kernel does not combine the most generous bits from all three classes. Correctly identify which class applies before changing modes.",
    },
    {
      term: "Mode bits",
      plainMeaning: "The familiar rwx flags, often written as octal numbers such as 640 or 750.",
      technicalMeaning: "Filesystem mode bits encode object type plus owner, group, and other permissions, with additional set-user-ID, set-group-ID, and sticky bits.",
      sreRelevance: "Modes are only one access layer. A correct-looking mode does not rule out ACL, mount, capability, or mandatory-policy denial.",
    },
    {
      term: "File read, write, and execute",
      plainMeaning: "On a file, read sees contents, write changes contents, and execute asks the kernel to run it as a program.",
      technicalMeaning: "Regular-file r, w, and x bits authorize data reads, data modification, and execution subject to mount, interpreter, and security-policy checks.",
      sreRelevance: "Grant only the operation the workload needs. Write permission can change data; execute permission does not imply read permission.",
    },
    {
      term: "Directory read, write, and execute",
      plainMeaning: "On a directory, read lists names, write changes names, and execute lets you pass through or access named children.",
      technicalMeaning: "Directory permissions govern listing directory entries, creating or removing entries, and searching or traversing the directory during path resolution.",
      sreRelevance: "A readable target file can still fail if execute permission is missing on any parent directory. Inspect the whole path with namei.",
    },
    {
      term: "Path traversal",
      plainMeaning: "Linux must successfully pass through every parent directory before it can evaluate the final object.",
      technicalMeaning: "Path resolution performs a search permission check on each directory component and follows mounts and links until reaching the requested object.",
      sreRelevance: "Permission denied may belong to /opt or /opt/app, not settings.yaml. Recursive chmod on the target cannot fix the wrong boundary safely.",
    },
    {
      term: "umask",
      plainMeaning: "A creation-time filter that removes selected permissions from newly created files and directories.",
      technicalMeaning: "The process umask masks requested mode bits during object creation; it does not retroactively change existing objects.",
      sreRelevance: "A service can create files with unexpected modes after a unit, image, shell, or runtime changes its umask.",
    },
    {
      term: "ACL",
      plainMeaning: "Extra named-user or named-group rules beyond the basic owner, group, and other mode bits.",
      technicalMeaning: "A POSIX access control list adds permission entries and an effective mask that can limit named-user and group-class rights.",
      sreRelevance: "ls -l may not explain the final access decision. getfacl reveals entries and masks that can grant or restrict access.",
    },
    {
      term: "root",
      plainMeaning: "UID 0, the traditional superuser with broad authority over the host.",
      technicalMeaning: "Root is the privileged Unix identity, although Linux capabilities and mandatory security controls can split or constrain parts of its authority.",
      sreRelevance: "Running as root can hide ownership defects and expands blast radius. Reproduce with the real service identity whenever safe.",
    },
    {
      term: "Linux capability",
      plainMeaning: "One separated slice of traditional root power, such as binding a low port or changing ownership.",
      technicalMeaning: "Capabilities divide privileged kernel checks into independently assignable bits carried by processes and, in some cases, executable files.",
      sreRelevance: "Capabilities support least privilege but remain powerful. Grant the exact capability, bound its scope, and verify it cannot enable an escalation path.",
    },
    {
      term: "Special mode bits",
      plainMeaning: "setuid, setgid, and sticky add special identity or directory behavior beyond normal rwx permissions.",
      technicalMeaning: "setuid and setgid can alter execution identity or group inheritance; the sticky bit restricts deletion in shared writable directories to authorized owners.",
      sreRelevance: "These bits explain shared-directory and executable behavior and can create privilege risk when applied carelessly.",
    },
    {
      term: "Read-only mount",
      plainMeaning: "The filesystem boundary itself refuses writes even if the file's mode bits appear writable.",
      technicalMeaning: "A mount with the ro option rejects modifying operations for objects reached through that mount, independent of ordinary discretionary write bits.",
      sreRelevance: "chmod cannot repair a read-only mount. Use findmnt on the exact path before changing ownership or permissions.",
    },
    {
      term: "SELinux and AppArmor",
      plainMeaning: "Host security policies that can deny an operation even when normal Unix permissions allow it.",
      technicalMeaning: "SELinux applies label-based mandatory access control, while AppArmor applies profile-based rules to confine process access beyond discretionary modes.",
      sreRelevance: "Do not disable enforcement to make an application work. Find the policy denial, validate intended access, and create the narrowest reviewed rule.",
    },
    {
      term: "Container security context",
      plainMeaning: "Runtime settings that decide which identity and privileges a container receives.",
      technicalMeaning: "Container and Kubernetes settings such as USER, runAsUser, runAsGroup, fsGroup, capabilities, privilege escalation, and read-only root filesystems shape process credentials and access.",
      sreRelevance: "A workload that works as root but fails as UID 10001 usually exposes an image, volume, ownership, group, or policy mismatch that must be fixed deliberately.",
    },
  ],
};
