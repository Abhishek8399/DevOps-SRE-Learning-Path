export type LessonCommand = {
  classification: string;
  command: string;
  proves: string;
  doesNotProve: string;
};

export type LessonStep = {
  label: string;
  action: string;
  command: string;
  meaning: string;
};

export type FoundationLesson = {
  id: string;
  number: string;
  title: string;
  subtitle: string;
  mentalModel: string;
  memoryRule: string;
  diagram: string;
  mechanisms: Array<{ term: string; explanation: string }>;
  incident: {
    signal: string;
    firstThought: string;
    safePath: string;
    trap: string;
  };
  commands: LessonCommand[];
  lab: {
    scope: string;
    steps: LessonStep[];
    success: string[];
    cleanup: string;
  };
  checkpoint: string[];
  interviewPrompt: string;
};

export const foundationLessons: FoundationLesson[] = [
  {
    id: "processes-signals-systemd",
    number: "02",
    title: "Processes, signals, exit codes, and systemd",
    subtitle: "Understand what is actually running before you restart it.",
    mentalModel:
      "A program is a file on disk. A process is one running instance of that program, with a PID, parent, user, memory, open files, and lifecycle. systemd is usually the service manager that creates, watches, and restarts long-running Linux services.",
    memoryRule:
      "A restart is an action. Process state, logs, ownership, and exit reason are the evidence that tells you whether it is the right action.",
    diagram: `systemd (PID 1)
   |
   | starts from a unit file
   v
api.service
   |
   +--> API process (PID 2410)
          |
          +--> worker (PID 2418)
          +--> open sockets and files
          +--> memory and CPU state

SIGTERM --> process gets time to clean up
SIGKILL --> kernel stops it immediately`,
    mechanisms: [
      {
        term: "PID and PPID",
        explanation:
          "PID identifies this running process. PPID identifies the parent that created it. A process tree tells you whether a service manager, shell, container runtime, or application spawned the process.",
      },
      {
        term: "Process state",
        explanation:
          "R is runnable, S is interruptible sleep, D is uninterruptible sleep, T is stopped, and Z is zombie. State is a clue, not a complete diagnosis. A D-state process often waits on kernel I/O and may ignore normal signals until that wait returns.",
      },
      {
        term: "File descriptors",
        explanation:
          "A process reaches files, pipes, sockets, and devices through numbered file descriptors. Descriptor leaks can create failures even while CPU and memory look healthy.",
      },
      {
        term: "Signals and exit codes",
        explanation:
          "SIGTERM requests graceful shutdown. SIGKILL cannot be handled and prevents cleanup. Exit code 0 normally means success; non-zero means the program reported failure. A signal-derived exit such as 137 often means SIGKILL, but you still need evidence of who sent it and why.",
      },
      {
        term: "systemd unit",
        explanation:
          "A unit describes how a service starts, its dependencies, restart policy, identity, limits, and environment. The process is runtime state; the unit is desired-service configuration.",
      },
    ],
    incident: {
      signal: "The API is unavailable and someone says, 'restart the service.'",
      firstThought:
        "First determine whether the process is absent, running but unhealthy, blocked, crash-looping, or unable to bind its port.",
      safePath:
        "Check service state and recent logs, inspect the process and listening socket, preserve the first failure, then choose a bounded restart only if recovery benefit outweighs evidence loss.",
      trap:
        "Using kill -9 first. It can interrupt writes, skip cleanup, erase transient evidence, and allow systemd to create a new failing process without fixing the cause.",
    },
    commands: [
      {
        classification: "READ-ONLY",
        command: "ps -eo pid,ppid,user,stat,%cpu,%mem,etime,cmd --sort=-%cpu | head",
        proves: "Which processes exist, who owns them, their parent, state, age, and current sampled resource percentages.",
        doesNotProve: "Why a process is consuming CPU or whether the application is serving requests correctly.",
      },
      {
        classification: "READ-ONLY",
        command: "systemctl status <unit> --no-pager",
        proves: "The unit state, main PID, recent lifecycle result, and a small log tail.",
        doesNotProve: "End-to-end service health or the complete root cause; the displayed logs are intentionally limited.",
      },
      {
        classification: "READ-ONLY",
        command: "journalctl -u <unit> --since '-15 min' --no-pager",
        proves: "Logs associated with that unit in the requested time window.",
        doesNotProve: "That the application emitted every important event or that timestamps across dependencies are aligned.",
      },
      {
        classification: "READ-ONLY",
        command: "ls -l /proc/<PID>/fd | head",
        proves: "A sample of resources currently referenced by that process.",
        doesNotProve: "Whether the descriptor count is leaking; that requires counts or observations over time.",
      },
      {
        classification: "READ-ONLY",
        command: "ss -lntp",
        proves: "Which TCP ports are listening and, when permitted, which process owns each socket.",
        doesNotProve: "That a listener can complete a real application request.",
      },
    ],
    lab: {
      scope: "A disposable shell process created by you. Do not substitute a production or system service PID.",
      steps: [
        {
          label: "MUTATING / DISPOSABLE PROCESS",
          action: "Start a process that records SIGTERM.",
          command: "sh -c 'trap \"echo graceful_shutdown; exit 0\" TERM; while :; do sleep 1; done' & LAB_PID=$!; echo $LAB_PID",
          meaning: "The shell stores the new process ID in LAB_PID so every later action remains scoped.",
        },
        {
          label: "READ-ONLY",
          action: "Inspect identity and process state.",
          command: "ps -o pid,ppid,user,stat,etime,cmd -p $LAB_PID",
          meaning: "Confirm the PID and command match your disposable process before sending a signal.",
        },
        {
          label: "MUTATING / EXACT PID",
          action: "Request graceful termination and collect the result.",
          command: "kill -TERM $LAB_PID; wait $LAB_PID; echo exit_code=$?",
          meaning: "You should see graceful_shutdown and exit_code=0 because the process handled SIGTERM.",
        },
      ],
      success: [
        "The inspected PID matches the process you created.",
        "SIGTERM reaches the handler.",
        "The process exits cleanly and no longer appears in ps.",
      ],
      cleanup: "The process exits during the lab. If interrupted, run kill -TERM $LAB_PID only after verifying that variable still identifies your disposable command.",
    },
    checkpoint: [
      "Explain why a running process can still represent an unavailable service.",
      "Explain what evidence SIGKILL destroys compared with SIGTERM.",
      "Name one check between process existence and user-visible health.",
    ],
    interviewPrompt:
      "A systemd service restarts every 30 seconds. Explain how you would distinguish an application crash, health-check kill, dependency failure, and bad restart policy.",
  },
  {
    id: "cpu-memory-pressure",
    number: "03",
    title: "CPU, load, memory pressure, swap, and OOM",
    subtitle: "Separate a busy machine from a machine that cannot make progress.",
    mentalModel:
      "CPU is execution time. The run queue is work waiting for CPU. Memory is active working space. Swap is slower backing space. Pressure appears when demand competes for a limited resource; the useful question is not 'is usage high?' but 'is useful work delayed or being killed?'",
    memoryRule:
      "High utilization is not automatically bad. Sustained queueing, latency, reclaim, swapping, and failed work turn utilization into an incident.",
    diagram: `requests arrive
      |
      v
 runnable work ----> CPU cores ----> completed work
      |                 |
      | queue grows     +--> user / system / iowait time
      v
 latency increases

process allocations --> RAM --> reclaim --> swap
                         |
                         +--> OOM selection when recovery fails`,
    mechanisms: [
      {
        term: "CPU utilization",
        explanation:
          "User time runs application code; system time runs kernel work; idle means no runnable work used the CPU; iowait means the CPU was idle while at least one task waited for I/O. One percentage alone does not identify the responsible workload.",
      },
      {
        term: "Load average",
        explanation:
          "Linux load roughly counts runnable tasks plus tasks in uninterruptible sleep over 1, 5, and 15 minutes. Compare it with CPU count and process states. Load 8 means something very different on a 2-core and a 64-core machine.",
      },
      {
        term: "Available memory",
        explanation:
          "Linux intentionally uses spare RAM for cache. MemAvailable estimates memory that can be used without heavy swapping. 'Free' being small is not itself an incident.",
      },
      {
        term: "Reclaim and swap",
        explanation:
          "The kernel reclaims caches and may move inactive anonymous pages to swap. Persistent swap-in and swap-out with latency can indicate thrashing; allocated swap alone does not prove current pressure.",
      },
      {
        term: "OOM kill",
        explanation:
          "When an allocation cannot be satisfied, the kernel or a cgroup can kill a selected process. Container exit 137 is a clue for SIGKILL, but inspect cgroup events and kernel/runtime evidence before calling it OOM.",
      },
    ],
    incident: {
      signal: "Latency is high, CPU shows 95%, and free memory is near zero.",
      firstThought:
        "Do not diagnose from the two headline percentages. Determine CPU count, queueing, process ownership, useful throughput, MemAvailable, swap activity, I/O wait, and recent OOM evidence.",
      safePath:
        "Correlate uptime, vmstat, free, process samples, application latency, and workload changes over the same time window. Throttle or scale only after identifying the constrained resource and expected workload.",
      trap:
        "Dropping caches, disabling swap, or restarting the largest process before identifying workload, leak, limit, or dependency behavior.",
    },
    commands: [
      {
        classification: "READ-ONLY",
        command: "nproc; uptime",
        proves: "Logical CPU count and the 1, 5, and 15 minute load averages.",
        doesNotProve: "Which task caused load or whether load is CPU work versus uninterruptible I/O wait.",
      },
      {
        classification: "READ-ONLY / SAMPLED",
        command: "vmstat 1 5",
        proves: "Five samples of runnable tasks, blocked tasks, memory, swap traffic, I/O, interrupts, context switches, and CPU time categories.",
        doesNotProve: "Per-process causality; correlate with process and application evidence.",
      },
      {
        classification: "READ-ONLY",
        command: "free -h",
        proves: "Current memory accounting including available memory, cache, and swap totals.",
        doesNotProve: "A memory leak or which allocation path created pressure.",
      },
      {
        classification: "READ-ONLY",
        command: "ps -eo pid,user,stat,%cpu,%mem,rss,etime,cmd --sort=-%mem | head",
        proves: "A current process snapshot sorted by memory percentage, including resident memory and age.",
        doesNotProve: "Peak memory, cgroup totals, shared-memory attribution, or growth over time.",
      },
      {
        classification: "READ-ONLY / MAY REQUIRE PRIVILEGE",
        command: "journalctl -k --since '-30 min' | grep -Ei 'oom|out of memory|killed process'",
        proves: "Whether matching kernel messages exist in that time window.",
        doesNotProve: "That every SIGKILL was OOM or that a container cgroup event appears in the host journal.",
      },
    ],
    lab: {
      scope: "Read-only observation of your Ubuntu environment. This lesson deliberately avoids creating artificial memory pressure on the host.",
      steps: [
        {
          label: "READ-ONLY",
          action: "Establish machine capacity and load trend.",
          command: "nproc; uptime",
          meaning: "Interpret load relative to CPU count and compare short versus longer windows.",
        },
        {
          label: "READ-ONLY / FIVE-SECOND SAMPLE",
          action: "Observe whether work is runnable, blocked, swapping, or waiting on I/O.",
          command: "vmstat 1 5",
          meaning: "Focus on r, b, si, so, us, sy, id, and wa across samples rather than one line.",
        },
        {
          label: "READ-ONLY",
          action: "Correlate system totals with process ownership.",
          command: "free -h; ps -eo pid,user,stat,%cpu,%mem,rss,cmd --sort=-%mem | head",
          meaning: "Available memory and the largest current processes provide two different layers of evidence.",
        },
      ],
      success: [
        "CPU count and load averages are interpreted together.",
        "At least two vmstat samples are compared instead of reading the first line alone.",
        "MemAvailable is used instead of treating low free memory as automatic failure.",
      ],
      cleanup: "None. Every lab command is read-only.",
    },
    checkpoint: [
      "Explain why load average can be high while CPU utilization is not 100%.",
      "Explain why low free memory is normal on a healthy Linux system.",
      "Name the evidence needed before calling exit code 137 an OOM kill.",
    ],
    interviewPrompt:
      "A Kubernetes pod exits with code 137 during traffic peaks. Walk through host, cgroup, application, and workload evidence before changing its memory limit.",
  },
  {
    id: "network-request-path",
    number: "04",
    title: "DNS, routing, TCP, TLS, HTTP, and sockets",
    subtitle: "Debug the failed layer instead of calling every problem 'networking.'",
    mentalModel:
      "A request is a sequence of gates. A name must resolve, a route must exist, a TCP connection must form, TLS may authenticate and encrypt it, HTTP must be valid, and the application plus its dependencies must respond. Test one boundary at a time.",
    memoryRule:
      "'The network is down' is not a diagnosis. Name the last successful gate and the first failed gate.",
    diagram: `client
  |
  +-- DNS: name -> IP
  +-- route: IP -> interface / gateway
  +-- TCP: SYN -> SYN-ACK -> ACK
  +-- TLS: certificate + key agreement
  +-- HTTP: method, path, headers, response
  v
reverse proxy -> application -> database / queue / cache`,
    mechanisms: [
      {
        term: "DNS",
        explanation:
          "DNS converts a name into records such as A or AAAA. Successful resolution proves a record was returned through the configured resolver; it does not prove the selected IP is reachable or healthy.",
      },
      {
        term: "Routing",
        explanation:
          "The kernel chooses an output interface, source address, next hop, and route. Containers and Kubernetes add namespaces, virtual interfaces, overlays, service translation, and policy boundaries.",
      },
      {
        term: "TCP",
        explanation:
          "A listener accepts connections on an address and port. A timeout, refusal, and reset are different signals: silent path/filter failure, no listener, and active connection termination are different hypothesis families.",
      },
      {
        term: "TLS",
        explanation:
          "TLS authenticates the server name through certificates and negotiates encryption. TCP success with TLS failure narrows the problem to certificate, name, trust, protocol, cipher, clock, or TLS termination behavior.",
      },
      {
        term: "HTTP and application",
        explanation:
          "An HTTP status proves that an HTTP-speaking endpoint replied. A 503 from a proxy and a 503 from an application can have different owners, so inspect headers, logs, upstream state, and request IDs.",
      },
    ],
    incident: {
      signal: "A user reports that https://api.example.test/orders is unavailable.",
      firstThought:
        "Map the requester, name, resolved address, route, destination port, TLS server name, proxy, application, and downstream dependency before choosing a command.",
      safePath:
        "Test DNS, route, TCP, TLS, and HTTP in order from the same network namespace as the failing client. Stop when the first boundary fails and gather evidence on both sides of it.",
      trap:
        "Testing from your laptop when only a pod fails, or using ping as proof that HTTPS works. Different namespaces, policies, proxies, ports, and protocols produce different paths.",
    },
    commands: [
      {
        classification: "READ-ONLY",
        command: "getent ahosts <hostname>",
        proves: "What addresses the system resolver currently returns for the name.",
        doesNotProve: "Reachability, correct application routing, or freshness beyond resolver/cache behavior.",
      },
      {
        classification: "READ-ONLY",
        command: "ip route get <destination-ip>",
        proves: "The kernel-selected route, source address, interface, and next hop for that destination.",
        doesNotProve: "That every device or policy after the local host permits the traffic.",
      },
      {
        classification: "READ-ONLY",
        command: "ss -lntp",
        proves: "Local TCP listeners and, with permission, owning processes.",
        doesNotProve: "Remote reachability, load-balancer health, TLS, or application response correctness.",
      },
      {
        classification: "READ-ONLY / NETWORK REQUEST",
        command: "curl -v --connect-timeout 3 http://127.0.0.1:8080/",
        proves: "Connection and HTTP details for this URL from the current namespace.",
        doesNotProve: "Behavior from another host, pod, proxy path, hostname, or TLS endpoint.",
      },
      {
        classification: "READ-ONLY / NETWORK REQUEST",
        command: "openssl s_client -connect <host>:443 -servername <host> </dev/null",
        proves: "The presented certificate chain and TLS negotiation for that address and server name.",
        doesNotProve: "Authorization or successful application requests after the handshake.",
      },
    ],
    lab: {
      scope: "A Python HTTP server bound only to 127.0.0.1:8080. It is reachable from your machine, not intentionally exposed to the LAN.",
      steps: [
        {
          label: "MUTATING / LOCAL DISPOSABLE PROCESS",
          action: "Start a loopback-only HTTP server from an empty temporary directory.",
          command: "LAB_DIR=$(mktemp -d); cd $LAB_DIR; python3 -m http.server 8080 --bind 127.0.0.1 & SERVER_PID=$!; echo $SERVER_PID",
          meaning: "The server has a known directory, port, interface, and PID.",
        },
        {
          label: "READ-ONLY",
          action: "Prove the socket is listening before testing HTTP.",
          command: "ss -lntp | grep ':8080'",
          meaning: "This checks the TCP listener boundary, not the complete HTTP response.",
        },
        {
          label: "READ-ONLY / LOOPBACK REQUEST",
          action: "Send an HTTP request and observe connection plus protocol details.",
          command: "curl -v --connect-timeout 3 http://127.0.0.1:8080/",
          meaning: "A successful status proves that this namespace reached the listener and received HTTP.",
        },
        {
          label: "DESTRUCTIVE / EXACT LAB PROCESS AND DIRECTORY",
          action: "Stop the server and remove only its temporary directory.",
          command: "kill -TERM $SERVER_PID; wait $SERVER_PID; cd /; rm -rf -- $LAB_DIR",
          meaning: "Verify SERVER_PID and LAB_DIR still refer to this lab before cleanup.",
        },
      ],
      success: [
        "The listener appears on 127.0.0.1:8080.",
        "curl shows a completed TCP connection and an HTTP response.",
        "After cleanup, the listener is absent.",
      ],
      cleanup: "The final step stops the exact recorded PID and removes the mktemp-created directory. Never run the cleanup with empty variables.",
    },
    checkpoint: [
      "Explain what DNS success proves and what it does not prove.",
      "Distinguish connection refused, timeout, TLS failure, and HTTP 503.",
      "Explain why the failing client's network namespace matters.",
    ],
    interviewPrompt:
      "A service works from the node but times out from one Kubernetes pod. Trace the path and identify evidence at namespace, route, policy, service, endpoint, and application layers.",
  },
  {
    id: "identity-permissions",
    number: "05",
    title: "Identity, permissions, traversal, and least privilege",
    subtitle: "Debug access from the effective user through every path component.",
    mentalModel:
      "Linux checks what the running process is allowed to do using its effective user, groups, capabilities, ACLs, mount options, and security controls. Reaching a file also requires directory traversal permission on every parent directory.",
    memoryRule:
      "Permission denied is a path decision, not only a file-mode decision. Check identity and every boundary before changing permissions.",
    diagram: `process identity
  |-- effective UID
  |-- effective groups
  |-- capabilities
  v
/opt       requires execute to traverse
  |
/opt/app   requires execute to traverse
  |
config     file read/write bits and ACLs

also check: read-only mount, SELinux/AppArmor,
container user, Kubernetes securityContext`,
    mechanisms: [
      {
        term: "User and groups",
        explanation:
          "The kernel evaluates the process's effective identity. The account you used to start a command, a systemd User setting, Docker USER, and Kubernetes runAsUser can produce different runtime identities.",
      },
      {
        term: "r, w, and x",
        explanation:
          "On a regular file, r reads content, w modifies content, and x executes it. On a directory, r lists names, w changes directory entries, and x traverses or accesses entries. Directory semantics are crucial during path failures.",
      },
      {
        term: "Ownership and mode classes",
        explanation:
          "Mode bits select owner, group, or other permissions based on runtime identity. Octal values are compact representations, not a reason to guess with chmod 777.",
      },
      {
        term: "umask, ACLs, and capabilities",
        explanation:
          "umask removes permissions from newly created objects. ACLs can add named-user or group rules. Capabilities split selected root powers, but broad capabilities can still create serious privilege paths.",
      },
      {
        term: "Higher-level controls",
        explanation:
          "A correct mode can still fail because the filesystem is read-only, SELinux or AppArmor denies access, a container mount changes ownership, or a Kubernetes volume and fsGroup do not match the process identity.",
      },
    ],
    incident: {
      signal: "The application logs 'permission denied' while opening /opt/app/config/settings.yaml.",
      firstThought:
        "Identify the exact process user and operation, then inspect every parent component, target ownership and modes, ACLs, mount flags, and security-policy denials.",
      safePath:
        "Reproduce as the service identity when safe, use namei and stat to locate the first denied boundary, then make the narrowest ownership, group, ACL, or service-identity correction.",
      trap:
        "Running chmod -R 777. It hides the original boundary, grants unrelated users write access, expands blast radius, and often fails to address read-only mounts or mandatory access controls.",
    },
    commands: [
      {
        classification: "READ-ONLY",
        command: "id",
        proves: "The current process's user ID, primary group, and supplementary groups.",
        doesNotProve: "The identity of a different service, container, or pod process.",
      },
      {
        classification: "READ-ONLY",
        command: "namei -l /opt/app/config/settings.yaml",
        proves: "Ownership and mode bits for each component in the path.",
        doesNotProve: "ACL entries, SELinux/AppArmor decisions, or that the service uses your shell identity.",
      },
      {
        classification: "READ-ONLY",
        command: "stat -c '%A %a %U:%G %n' <path>",
        proves: "File type, symbolic and octal mode, owner, group, and name for the target.",
        doesNotProve: "Which rule denied a failed operation or the permissions of every parent directory.",
      },
      {
        classification: "READ-ONLY / IF INSTALLED",
        command: "getfacl -p <path>",
        proves: "POSIX ACL entries and effective masks for the path.",
        doesNotProve: "Mount or mandatory access-control decisions.",
      },
      {
        classification: "READ-ONLY",
        command: "findmnt -T <path> -o TARGET,SOURCE,FSTYPE,OPTIONS",
        proves: "The filesystem and mount options, including whether the resolved mount is read-only.",
        doesNotProve: "Application-level authorization or all host security controls.",
      },
    ],
    lab: {
      scope: "A private directory created with mktemp under /tmp and owned by your current user. No sudo or system path is used.",
      steps: [
        {
          label: "MUTATING / PRIVATE TEMP DIRECTORY",
          action: "Create a controlled path with restrictive permissions.",
          command: "LAB_DIR=$(mktemp -d); mkdir -p $LAB_DIR/app/config; printf 'mode=lab\\n' > $LAB_DIR/app/config/settings; chmod 700 $LAB_DIR; chmod 750 $LAB_DIR/app $LAB_DIR/app/config; chmod 640 $LAB_DIR/app/config/settings",
          meaning: "Every object is under the mktemp-created directory and belongs to your current user.",
        },
        {
          label: "READ-ONLY",
          action: "Trace every path component and inspect the target.",
          command: "id; namei -l $LAB_DIR/app/config/settings; stat -c '%A %a %U:%G %n' $LAB_DIR/app/config/settings",
          meaning: "Connect runtime identity with directory traversal and file read/write permissions.",
        },
        {
          label: "READ-ONLY",
          action: "Verify the permitted operation without changing modes.",
          command: "test -r $LAB_DIR/app/config/settings && echo readable=true; test -x $LAB_DIR/app/config && echo traversable=true",
          meaning: "The checks evaluate access for your current shell identity.",
        },
        {
          label: "DESTRUCTIVE / EXACT TEMP DIRECTORY",
          action: "Remove only the directory created by mktemp.",
          command: "case $LAB_DIR in /tmp/tmp.*) rm -rf -- $LAB_DIR ;; *) echo 'refusing unexpected path' ;; esac",
          meaning: "The guard refuses cleanup if LAB_DIR does not resemble the expected mktemp path.",
        },
      ],
      success: [
        "The effective identity is stated before interpreting permissions.",
        "Every directory component is visible in namei output.",
        "Read and traversal checks succeed without broadening permissions.",
      ],
      cleanup: "Use only the guarded final command. Do not manually replace LAB_DIR with /tmp or another parent directory.",
    },
    checkpoint: [
      "Explain execute permission on a directory without describing it as running the directory.",
      "Explain why chmod 777 is usually the wrong incident response.",
      "Name two controls that can deny access even when mode bits look correct.",
    ],
    interviewPrompt:
      "A container works as root but fails as UID 10001 when writing a mounted volume. Explain the host, image, mount, Kubernetes securityContext, and policy evidence you would collect.",
  },
];
