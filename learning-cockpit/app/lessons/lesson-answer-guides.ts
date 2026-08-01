import type { LessonGlossaryId } from "./lesson-glossaries";

export type AnswerGuideKind = "checkpoint" | "practice" | "interview";

export type EvidenceOrCommand = Readonly<{
  classification: "READ-ONLY" | "MUTATING" | "EVIDENCE";
  item: string;
  interpretation: string;
}>;

export type AnswerGuideFollowUp = Readonly<{
  question: string;
  answer: string;
}>;

export type LessonAnswerGuideEntry = Readonly<{
  id: string;
  kind: AnswerGuideKind;
  question: string;
  shortAnswer: string;
  foundationAnswer: string;
  reasoningSteps: readonly string[];
  productionAnswer: string;
  commonWeakAnswer: string;
  whyWeak: string;
  evidenceOrCommands: readonly EvidenceOrCommand[];
  followUpQuestions: readonly AnswerGuideFollowUp[];
}>;

export type LessonAnswerGuides = Readonly<
  Record<LessonGlossaryId, readonly LessonAnswerGuideEntry[]>
>;

export const lessonAnswerGuides: LessonAnswerGuides = {
  storage: [
    {
      id: "storage-enospc-proof",
      kind: "practice",
      question: "What does ENOSPC prove?",
      shortAnswer:
        "It proves that Linux could not allocate a required storage resource. It does not, by itself, prove that the whole disk has no free bytes.",
      foundationAnswer:
        "ENOSPC is the Linux error behind 'No space left on device.' Treat it as an alarm. A file-creation operation may need a data block, which stores content, and an inode, which stores the filesystem record for an object. Either resource can be unavailable, and a quota or runtime limit can also stop the operation, so the exact failing path must be checked.",
      reasoningSteps: [
        "Identify the exact operation and path that returned ENOSPC.",
        "Map that path to the filesystem or container mount that owns the allocation.",
        "Check independent limits: data blocks, inodes, quota, and workload-specific storage limits.",
        "Use the failed limit to guide investigation; do not infer the producer or safe remediation from the error alone.",
      ],
      productionAnswer:
        "I would state that ENOSPC is the symptom and preserve the exact path, timestamp, workload identity, and recent-change context. I would map the path with findmnt, compare block and inode capacity on that path, then inspect quota and container or volume limits. Only after identifying the exhausted resource and its producer would I propose a bounded, authorized mitigation and verify the real user operation.",
      commonWeakAnswer: "The disk is full, so delete some files or add disk space.",
      whyWeak:
        "It collapses several independent limits into one guess, does not target the failing filesystem, and proposes state-changing work before proving what is exhausted or what is safe to remove.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "findmnt -T <exact-failing-path>",
          interpretation: "Shows the mounted filesystem that owns the exact path; it does not show which capacity limit failed.",
        },
        {
          classification: "READ-ONLY",
          item: "df -hT <exact-failing-path>",
          interpretation: "Shows filesystem type and block capacity for that path.",
        },
        {
          classification: "READ-ONLY",
          item: "df -i <exact-failing-path>",
          interpretation: "Shows inode capacity for the same filesystem.",
        },
      ],
      followUpQuestions: [
        {
          question: "Can free blocks compensate for zero free inodes?",
          answer: "No. File creation needs an available inode even when content capacity remains.",
        },
        {
          question: "Does ENOSPC identify which files are safe to delete?",
          answer: "No. Safety requires producer, purpose, age, retention, recovery, and ownership evidence.",
        },
      ],
    },
    {
      id: "storage-df-ht",
      kind: "practice",
      question: "What does df -hT tell you?",
      shortAnswer:
        "It reports block capacity in human-readable units and the filesystem type for the filesystem behind the supplied path.",
      foundationAnswer:
        "The command df reports filesystem capacity. The -h option formats byte counts into units such as MiB or GiB, and -T includes the filesystem type, such as ext4 or tmpfs. Supplying the failed path makes Linux report the filesystem that actually backs that path instead of whichever filesystem an operator happens to inspect.",
      reasoningSteps: [
        "Resolve the supplied path to its mounted filesystem.",
        "Read total, used, available, and percentage values as data-block capacity.",
        "Use the filesystem type and mount target to understand what kind of storage is involved.",
        "Check inode or quota evidence separately because df -hT does not answer those questions.",
      ],
      productionAnswer:
        "I use df -hT on the exact failed path to establish the block-capacity boundary and filesystem type. I compare it with the same command on a known-good path only when that comparison is relevant. I do not call the incident solved because block space is free; I pair it with inode, quota, mount-option, and workload-limit evidence.",
      commonWeakAnswer: "It tells me how much disk space the server has.",
      whyWeak:
        "It ignores that df reports per-filesystem block capacity, not total physical server storage, and it says nothing about inodes, quotas, deleted-open files, or application health.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "df -hT /var/lib/api/uploads",
          interpretation: "Reports block capacity and filesystem type for the filesystem resolving that exact path.",
        },
        {
          classification: "READ-ONLY",
          item: "findmnt -T /var/lib/api/uploads -o TARGET,SOURCE,FSTYPE,OPTIONS",
          interpretation: "Adds mount source, target, type, and options so the df result has a clear ownership boundary.",
        },
      ],
      followUpQuestions: [
        {
          question: "Why pass a path instead of running df -hT alone?",
          answer: "The path selects the filesystem relevant to the failed operation and avoids reading an unrelated mount.",
        },
        {
          question: "Does 50% block use prove a new file can be created?",
          answer: "No. Inodes, quota, permissions, and other limits may still prevent creation.",
        },
      ],
    },
    {
      id: "storage-df-inodes",
      kind: "practice",
      question: "What does df -i tell you?",
      shortAnswer:
        "It reports how many inode records the selected filesystem has, uses, and still has available.",
      foundationAnswer:
        "An inode is the filesystem record for an object such as a file or directory. It stores metadata including type, owner, permissions, timestamps, size, and references to content. df -i checks the finite supply of those records on the filesystem behind a path; it does not measure how many bytes remain.",
      reasoningSteps: [
        "Use the exact failing path so the correct filesystem is selected.",
        "Read total inodes, used inodes, free inodes, and inode-use percentage.",
        "If free inodes are zero, rank excessive object count above one-large-file hypotheses.",
        "Locate the producing population and prove retention policy before deleting anything.",
      ],
      productionAnswer:
        "I pair df -i with df -hT on the same exact path. If inode use is 100% while blocks remain available, I investigate file-count concentration within the filesystem, starting narrow to limit scan cost. I then identify the producer, growth rate, business purpose, and approved retention rule before any cleanup.",
      commonWeakAnswer: "It shows the inode size of each file.",
      whyWeak:
        "df -i reports filesystem-wide inode capacity, not per-file inode size or metadata details. The misunderstanding can send an operator toward the wrong files and wrong remediation.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "df -i <exact-failing-path>",
          interpretation: "Shows inode totals and availability for the filesystem containing the path.",
        },
        {
          classification: "READ-ONLY",
          item: "du --inodes -x -d 1 <narrow-reviewed-directory>",
          interpretation: "Estimates inode-count concentration without crossing filesystems; recursive scanning may still be expensive.",
        },
      ],
      followUpQuestions: [
        {
          question: "Does one empty file normally require an inode?",
          answer: "Yes. It may use almost no content blocks, but the object still needs a filesystem record.",
        },
        {
          question: "Will truncating a file free its inode?",
          answer: "No. Truncation frees content blocks while the file and its inode remain.",
        },
      ],
    },
    {
      id: "storage-free-many-inodes",
      kind: "practice",
      question: "What frees many inodes?",
      shortAnswer:
        "Removing many approved filesystem objects frees many inodes after their final directory links and open references are gone.",
      foundationAnswer:
        "One normal file or directory consumes an inode, whether its contents are huge or empty. Deleting one large file usually releases one inode; deleting a reviewed population of thousands of disposable objects can release thousands. A hard link is another filename for the same inode, and an open file descriptor is a process handle, so storage is not fully released until no links or open references remain.",
      reasoningSteps: [
        "Find which bounded directory population accounts for the object count.",
        "Identify the process or workflow producing those objects.",
        "Confirm exact selection, purpose, age, retention, recovery, and authorization.",
        "Preview and count with the same filters that the deletion will use.",
        "Delete only the approved population, then verify inode headroom and the real failed operation.",
      ],
      productionAnswer:
        "I do not 'clear inodes' directly. I reduce object count under an approved retention policy, preferably through the owning application's lifecycle mechanism. During an incident I use identical discovery and deletion predicates, bound the filesystem with -xdev, define abort criteria, monitor headroom, and follow up with prevention such as rotation, TTL cleanup, rate controls, or inode alerts.",
      commonWeakAnswer: "Delete the biggest files until df looks better.",
      whyWeak:
        "File size measures content, not object count. The advice may free blocks but almost no inodes, and it ignores data ownership and deletion authorization.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "find <approved-directory> -xdev -maxdepth 1 -type f -name '<approved-pattern>' | wc -l",
          interpretation: "Counts the exact candidate population without crossing into another filesystem.",
        },
        {
          classification: "EVIDENCE",
          item: "Retention owner, age rule, recovery path, and approver",
          interpretation: "Establishes that the population is disposable; a directory name such as cache is not sufficient policy.",
        },
        {
          classification: "READ-ONLY",
          item: "df -i <exact-failing-path>",
          interpretation: "Verifies whether inode headroom improved after an authorized cleanup.",
        },
      ],
      followUpQuestions: [
        {
          question: "Why can deleting one pathname fail to release an inode?",
          answer: "Another hard link or an open process reference may still keep the inode alive.",
        },
        {
          question: "What prevention follows temporary-file growth?",
          answer: "Fix lifecycle ownership with TTL or completion cleanup, bound creation rate, and alert on inode trend before exhaustion.",
        },
      ],
    },
    {
      id: "storage-first-safe-move",
      kind: "practice",
      question: "The API reports ENOSPC and /var shows 48% block use. What do you do next?",
      shortAnswer:
        "Check inode capacity on the exact failing path, while preserving the possibility that the path is on a different mount or subject to another limit.",
      foundationAnswer:
        "The 48% figure describes data-block use on whichever filesystem was checked. ENOSPC can also occur when no inode is available for a new object. The exact path matters because a directory beneath /var may be a separate mount, a memory-backed tmpfs, or a container volume, so first map and then measure that path.",
      reasoningSteps: [
        "Preserve the exact error, path, time, impact, and recent change.",
        "Map the exact failing path instead of assuming all of /var is one filesystem.",
        "Compare block and inode availability on that path.",
        "If neither is exhausted, inspect quotas, writable-layer limits, permissions, and application-specific constraints.",
        "Choose remediation only after the responsible resource and safe change boundary are known.",
      ],
      productionAnswer:
        "My first move is read-only and falsifiable: findmnt -T on the failed path, followed by df -hT and df -i on that same path. I would not restart the API because a restart does not create capacity and may discard evidence. I would not delete the largest file because 48% block use and unknown retention provide no justification.",
      commonWeakAnswer: "Restart the API because df says there is free space.",
      whyWeak:
        "A restart changes state without testing the inode hypothesis, cannot manufacture an inode, and may lose the evidence needed to identify a runaway producer.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "findmnt -T /var/lib/api/uploads",
          interpretation: "Maps the sample failure path to its real filesystem boundary.",
        },
        {
          classification: "READ-ONLY",
          item: "df -hT /var/lib/api/uploads; df -i /var/lib/api/uploads",
          interpretation: "Compares independent block and inode limits on the same path.",
        },
      ],
      followUpQuestions: [
        {
          question: "Why is restart not an informative first experiment?",
          answer: "It changes several variables, loses transient evidence, and does not test or repair filesystem capacity.",
        },
        {
          question: "What would make deletion the next safe move?",
          answer: "A proven exhausted resource, exact approved population, retention authorization, bounded filter, recovery plan, and verification criteria.",
        },
      ],
    },
    {
      id: "storage-teach-back",
      kind: "practice",
      question: "Explain inode exhaustion to a developer whose upload just failed.",
      shortAnswer:
        "The upload needs both space for content and a free filesystem record. The filesystem still has content space, but it has no free inode for the new upload object, so Linux returns ENOSPC.",
      foundationAnswer:
        "A filename is recorded in a directory entry, which points to an inode. The inode holds the object's metadata and references its content blocks. Your upload failed because the filesystem behind the upload path could not allocate the required object record, even though data-block space remained. We must find the population creating too many objects, remove only approved disposable objects, and then retry the upload.",
      reasoningSteps: [
        "Start with the developer-visible symptom: creating a new upload failed.",
        "Explain the two independent resources: object records and content capacity.",
        "Connect the exact upload path to the filesystem that owns those resources.",
        "Explain that diagnosis does not grant deletion permission.",
        "Close with both capacity verification and a real upload retry.",
      ],
      productionAnswer:
        "I would tell the developer that the immediate cause is inode exhaustion on the upload filesystem, not a generic full host disk. The mitigation is to recover an authorized high-count disposable population without touching retained uploads. The root-cause work is to identify why object creation outpaced cleanup, add lifecycle controls and inode trend alerting, and confirm the complete upload journey after recovery.",
      commonWeakAnswer: "The inode cache is full, so we need to clear it.",
      whyWeak:
        "An inode is not a cache registration, and mounting does not create one inode per future file. The wording hides object ownership, safe remediation, and the distinction between immediate cause and root cause.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "findmnt -T <upload-path>; df -hT <upload-path>; df -i <upload-path>",
          interpretation: "Establishes the owning filesystem and distinguishes block from inode capacity.",
        },
        {
          classification: "EVIDENCE",
          item: "Controlled request through the real upload API",
          interpretation: "Verifies user-visible recovery; a successful touch alone proves only low-level path writability.",
        },
      ],
      followUpQuestions: [
        {
          question: "What is the root cause if cleanup stopped running?",
          answer: "Inode exhaustion is the immediate cause; the broken cleanup lifecycle is the root failure mechanism.",
        },
        {
          question: "What should be monitored afterward?",
          answer: "Free inode trend, object creation and deletion rates, cleanup failures, upload success, and headroom forecast.",
        },
      ],
    },
    {
      id: "storage-container-interview",
      kind: "interview",
      question: "A container reports ENOSPC while the host has 200 GB free. Walk me through your response.",
      shortAnswer:
        "I would scope the impact, map the failing container path to its writable layer or mounted volume, check blocks, inodes, quotas, and runtime limits there, identify the producer, mitigate safely, and verify the real request.",
      foundationAnswer:
        "A container has a mount namespace, meaning its paths can map to storage differently from the host shell. A path may live in the container writable layer, a bind mount, a named volume, tmpfs, or Kubernetes volume. Therefore, 200 GB free on the host's root filesystem may describe the wrong storage boundary. ENOSPC must be investigated from the failing container and mapped back to the responsible host or volume resource.",
      reasoningSteps: [
        "Clarify affected containers, requests, path, start time, deployment change, and data risk.",
        "Inspect the path from the failing container's mount namespace and map it to writable layer or volume ownership.",
        "Compare block, inode, quota, tmpfs, and container-runtime limits on that storage boundary.",
        "Measure object or byte growth and identify the responsible process and retention policy.",
        "Choose a reversible mitigation, verify container health and the user journey, then fix lifecycle and alerting gaps.",
      ],
      productionAnswer:
        "I would reject host-free-space as conclusive because container paths are namespaced. I would collect mount and df evidence inside the container, then inspect the corresponding Docker or Kubernetes volume and host backing filesystem without mutating it. If inode exhaustion is confirmed, I would use an approved population and identical discovery/deletion filters; if the writable layer is growing, I would move durable state to a volume and fix log or temp-file lifecycle. Recovery must include the application operation, not only df headroom.",
      commonWeakAnswer: "Docker is confused; restart Docker or prune everything.",
      whyWeak:
        "It ignores mount namespaces and independent limits, has a large blast radius, can delete unrelated images or volumes, and offers no user-visible verification or prevention.",
      evidenceOrCommands: [
        {
          classification: "READ-ONLY",
          item: "docker inspect <container> --format '{{json .Mounts}}'",
          interpretation: "Shows declared container mounts; inspect output carefully and do not assume unmounted paths are durable.",
        },
        {
          classification: "READ-ONLY",
          item: "docker exec <container> sh -c 'findmnt -T <path>; df -hT <path>; df -i <path>'",
          interpretation: "Collects path-specific evidence inside the failing mount namespace.",
        },
        {
          classification: "EVIDENCE",
          item: "Application request, error rate, and retained-data check after mitigation",
          interpretation: "Proves both service recovery and preservation of required state.",
        },
      ],
      followUpQuestions: [
        {
          question: "What if the full path is in tmpfs?",
          answer: "Inspect tmpfs size and inode limits plus workload creation behavior; host disk expansion will not repair it.",
        },
        {
          question: "What if deleted files remain open?",
          answer: "Identify the exact owning descriptors and use a safe reload or restart only after preserving evidence and evaluating write integrity.",
        },
      ],
    },
  ],

  "processes-signals-systemd": [
    {
      id: "process-running-but-unavailable",
      kind: "checkpoint",
      question: "Explain why a running process can still represent an unavailable service.",
      shortAnswer: "A PID can exist while the service is blocked, listening incorrectly, returning errors, or unable to reach a dependency.",
      foundationAnswer: "A process is one running instance of a program. Linux can show it in ps even when the application is stuck, listening on the wrong address, or failing every request. Availability is an end-to-end property: a real request must reach the listener, complete application work, and receive the required dependency responses.",
      reasoningSteps: [
        "Confirm the expected process identity, owner, parent, age, and state.",
        "Check whether it owns the expected listening socket.",
        "Send a bounded protocol request from the relevant network location.",
        "Trace a failed request into application and dependency evidence.",
      ],
      productionAnswer: "I treat process existence as liveness evidence only. I correlate systemd state, process state, socket ownership, a representative request, latency, errors, and dependency health. A blocked event loop, descriptor exhaustion, deadlock, bad binding, or failed database can all leave the PID alive while users see an outage.",
      commonWeakAnswer: "If ps shows the PID, the service is up.",
      whyWeak: "It confuses operating-system liveness with application readiness and customer success.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "ps -o pid,ppid,user,stat,etime,cmd -p <PID>", interpretation: "Confirms process identity and state, not service health." },
        { classification: "READ-ONLY", item: "ss -lntp", interpretation: "Shows listeners and possible owning processes, not completed requests." },
        { classification: "EVIDENCE", item: "A representative request through the real serving path", interpretation: "Tests more of the user journey than PID or socket checks." },
      ],
      followUpQuestions: [
        { question: "What is readiness?", answer: "Whether an instance can usefully receive traffic now." },
        { question: "Can a listener prove the database works?", answer: "No; it proves only a transport endpoint exists." },
      ],
    },
    {
      id: "process-sigkill-evidence-loss",
      kind: "checkpoint",
      question: "Explain what evidence SIGKILL destroys compared with SIGTERM.",
      shortAnswer: "SIGKILL ends a process without cleanup; SIGTERM can allow final logs, draining, buffer flushes, resource closure, and observable graceful-shutdown behavior.",
      foundationAnswer: "A signal is a kernel-delivered notification. SIGTERM is a catchable request to stop, so an application can run a shutdown handler. SIGKILL cannot be caught or delayed; the kernel ends the process immediately. No application cleanup, final logging, queue draining, or graceful connection close can run.",
      reasoningSteps: [
        "Preserve logs, process state, open resources, and timing before signaling.",
        "Send SIGTERM to the re-identified target when graceful shutdown is appropriate.",
        "Observe handler output, drain duration, and exit result within a defined deadline.",
        "Escalate only after re-identifying the process and comparing continued-execution risk with evidence loss.",
      ],
      productionAnswer: "SIGKILL removes live state useful for stack, descriptor, or deadlock analysis and can interrupt in-flight work. I collect first-failure evidence, use SIGTERM with a drain deadline, and reserve SIGKILL for an approved escalation when leaving the exact process alive is riskier than forced termination.",
      commonWeakAnswer: "SIGKILL is just a faster SIGTERM.",
      whyWeak: "The signals have different semantics for cleanup, evidence preservation, and data consistency.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "ps -o pid,ppid,user,stat,etime,cmd -p <PID>", interpretation: "Re-identifies the exact target." },
        { classification: "READ-ONLY", item: "journalctl -u <unit> --since '-15 min' --no-pager", interpretation: "Preserves recent lifecycle evidence." },
        { classification: "MUTATING", item: "kill -TERM <verified-disposable-or-approved-PID>", interpretation: "Requests graceful shutdown of an exact reviewed target." },
      ],
      followUpQuestions: [
        { question: "Can SIGKILL be handled?", answer: "No; it cannot be caught, blocked, or ignored." },
        { question: "When is SIGKILL defensible?", answer: "After bounded graceful escalation when continued execution creates greater risk." },
      ],
    },
    {
      id: "process-user-health-check",
      kind: "checkpoint",
      question: "Name one check between process existence and user-visible health.",
      shortAnswer: "Verify that the process owns the expected listening socket, then follow with a protocol-level request.",
      foundationAnswer: "A listening socket is a kernel endpoint waiting on an address and port. It is an intermediate boundary between a PID and a complete request. A listener proves that something accepts connections there, but not that application logic or dependencies work.",
      reasoningSteps: [
        "Confirm the process identity.",
        "Confirm the intended address, port, and socket owner.",
        "Connect from the relevant client boundary.",
        "Send a representative application request and inspect the response.",
      ],
      productionAnswer: "I use ss -lntp to verify binding and ownership, then test the actual protocol through the user path. I also avoid an over-deep readiness check that ejects every replica during a shared dependency failure; health semantics must match the traffic decision being made.",
      commonWeakAnswer: "Ping the server.",
      whyWeak: "Ping tests ICMP reachability when allowed, not the listener, process, TLS, application, or dependencies.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "ss -lntp | grep ':<port>'", interpretation: "Checks the local listener boundary." },
        { classification: "READ-ONLY", item: "curl --fail --show-error --max-time 3 http://127.0.0.1:<port>/health", interpretation: "Checks local HTTP behavior, not the full external path." },
      ],
      followUpQuestions: [
        { question: "Why can loopback work while users fail?", answer: "It bypasses external DNS, routing, policy, proxy, and TLS boundaries." },
        { question: "Should readiness test every dependency?", answer: "Not automatically; it should answer whether this instance can usefully receive traffic." },
      ],
    },
    {
      id: "process-systemd-restart-loop-interview",
      kind: "interview",
      question: "A systemd service restarts every 30 seconds. How do you distinguish an application crash, health-check kill, dependency failure, and bad restart policy?",
      shortAnswer: "Correlate the effective unit policy and restart counter with the main process exit cause, pre-exit logs, signal source, dependency evidence, and the exact 30-second timing.",
      foundationAnswer: "systemd is the service manager, and a unit describes how a service starts and restarts. The application may exit because of its own bug, a watchdog may signal it, a dependency may make startup fail, or Restart= may recreate it even after a normal exit. The exit reason, unit policy, and timeline separate those causes.",
      reasoningSteps: [
        "Establish impact, first failure, recent change, and whether the interval is exact.",
        "Inspect unit result, main exit status, restart counter, timeouts, watchdog, and effective configuration.",
        "Read logs before the first exit rather than only the newest restart.",
        "Classify normal exit, application error, signal, watchdog, or start timeout.",
        "Correlate dependency and health-check evidence on the same timeline.",
      ],
      productionAnswer: "I begin with systemctl status, show, cat, and the journal around the first failure. An application crash leaves its exit or signal and usually application evidence; a watchdog or external kill aligns with a timeout and signal source; dependency failure appears before exit as DNS, connection, authentication, or startup errors. I compare the 30-second cadence with RestartSec, WatchdogSec, TimeoutStartSec, probes, and dependency timeouts before modifying policy.",
      commonWeakAnswer: "Increase RestartSec or disable restarts.",
      whyWeak: "It changes the symptom before establishing who ends the process, why it exits, and whether restart behavior helps or harms availability.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "systemctl status <unit> --no-pager", interpretation: "Shows current state, main PID, result, and a limited log tail." },
        { classification: "READ-ONLY", item: "systemctl show <unit> -p Result -p ExecMainCode -p ExecMainStatus -p NRestarts -p Restart -p RestartUSec -p WatchdogUSec", interpretation: "Shows exit classification and effective lifecycle settings." },
        { classification: "READ-ONLY", item: "journalctl -u <unit> --since '<before-first-failure>' --no-pager", interpretation: "Builds the timeline leading into exits." },
        { classification: "READ-ONLY", item: "systemctl cat <unit>", interpretation: "Shows unit fragments and overrides." },
      ],
      followUpQuestions: [
        { question: "What does exit 0 followed by restart suggest?", answer: "The process succeeded, but a policy such as Restart=always may still recreate it." },
        { question: "Why preserve the first failure?", answer: "Later attempts can produce secondary errors and rotate away the original trigger." },
      ],
    },
  ],

  "cpu-memory-pressure": [
    {
      id: "cpu-load-with-idle",
      kind: "checkpoint",
      question: "Explain why load average can be high while CPU utilization is not 100%.",
      shortAnswer: "Linux load includes runnable tasks and tasks stuck in uninterruptible kernel waits, so I/O-waiting work can raise load while CPUs still show idle time.",
      foundationAnswer: "CPU utilization measures sampled processor time. Load average is a smoothed count of tasks that are ready for CPU plus tasks in uninterruptible sleep, usually waiting inside the kernel for I/O. If many tasks wait on slow storage, load can rise even though they are not executing instructions and some CPU time remains idle.",
      reasoningSteps: [
        "Compare load with the number of logical CPUs and with its 1, 5, and 15 minute trend.",
        "Inspect runnable and blocked task counts rather than assuming all load is CPU demand.",
        "Check process states for R tasks and D-state uninterruptible waits.",
        "Correlate CPU categories, device latency, throughput, and application latency.",
      ],
      productionAnswer: "High load with non-saturated CPU makes me separate run-queue pressure from uninterruptible waits. I compare nproc and uptime, sample vmstat r and b, inspect task states, then correlate iostat or storage telemetry and application latency. I would not scale CPU until the evidence shows runnable demand rather than blocked I/O.",
      commonWeakAnswer: "Load is CPU percentage, so the metrics must be wrong.",
      whyWeak: "Load is a task count over time, not a percentage, and it includes an important class of blocked tasks.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "nproc; uptime", interpretation: "Provides CPU count and load trend for relative interpretation." },
        { classification: "READ-ONLY", item: "vmstat 1 5", interpretation: "Samples runnable tasks, blocked tasks, and CPU categories; the first row is a since-boot average." },
        { classification: "READ-ONLY", item: "ps -eo pid,stat,wchan:24,comm | awk '$2 ~ /D/'", interpretation: "Finds sampled D-state tasks and their kernel wait channel when visible." },
      ],
      followUpQuestions: [
        { question: "Is load 8 high?", answer: "It depends on CPU count, task states, trend, latency, and workload expectations." },
        { question: "Does high iowait prove a disk is bad?", answer: "No; it is a clue that requires device, filesystem, and workload correlation." },
      ],
    },
    {
      id: "memory-low-free-normal",
      kind: "checkpoint",
      question: "Explain why low free memory is normal on a healthy Linux system.",
      shortAnswer: "Linux uses otherwise idle RAM for useful caches and can reclaim much of it; MemAvailable and pressure behavior matter more than MemFree alone.",
      foundationAnswer: "RAM is fast working memory. Linux keeps recently used file data in the page cache so later reads avoid slower storage. MemFree counts completely unused RAM, while MemAvailable estimates memory that can serve new allocations without heavy swapping. A healthy machine can therefore have little free RAM but plenty of reclaimable, available memory.",
      reasoningSteps: [
        "Read MemAvailable, cache, swap totals, and the trend rather than one MemFree value.",
        "Observe whether reclaim and active swap traffic are increasing.",
        "Correlate memory signals with latency, allocation failures, and workload throughput.",
        "Inspect process and cgroup ownership if pressure is real.",
      ],
      productionAnswer: "I expect Linux to use RAM for cache. I diagnose pressure from MemAvailable trend, sustained reclaim, swap-in and swap-out, pressure-stall data, cgroup events, latency, and OOM evidence. I do not drop caches merely to make free output look larger because that can force expensive storage reads and worsen the incident.",
      commonWeakAnswer: "Free memory is low, so clear the cache or restart the largest process.",
      whyWeak: "It mistakes useful reclaimable cache for a leak and proposes a disruptive action without evidence of pressure or ownership.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "free -h", interpretation: "Shows available memory, cache, and swap accounting at one point in time." },
        { classification: "READ-ONLY", item: "vmstat 1 5", interpretation: "Shows sampled swap traffic, runnable or blocked work, and CPU behavior." },
        { classification: "READ-ONLY", item: "cat /proc/pressure/memory", interpretation: "Shows recent time tasks were stalled by memory pressure; availability depends on kernel support." },
      ],
      followUpQuestions: [
        { question: "Is used swap proof of current pressure?", answer: "No; inactive pages may remain in swap after an earlier event. Active traffic and stalls matter." },
        { question: "Why not drop caches?", answer: "It destroys useful cached data and can create extra I/O without fixing the workload cause." },
      ],
    },
    {
      id: "memory-exit-137-evidence",
      kind: "checkpoint",
      question: "Name the evidence needed before calling exit code 137 an OOM kill.",
      shortAnswer: "Prove SIGKILL and correlate it with kernel or cgroup OOM events, memory-limit counters, usage near the event, and runtime or orchestrator termination evidence.",
      foundationAnswer: "Shells commonly report 128 plus a terminating signal number, so 137 often means signal 9, SIGKILL. The out-of-memory killer can send SIGKILL, but a person, health system, runtime timeout, or administrative action can send it too. An OOM diagnosis requires evidence from the kernel or the workload's memory cgroup, which is the kernel accounting boundary used for container limits.",
      reasoningSteps: [
        "Confirm the process actually ended by SIGKILL and establish the event timestamp.",
        "Inspect runtime and orchestrator reason fields rather than relying only on the derived exit number.",
        "Check cgroup memory.events for oom or oom_kill increments and inspect the configured limit.",
        "Check host kernel evidence for a global OOM and selected victim.",
        "Correlate memory usage, workload traffic, deployment changes, and other possible signal senders.",
      ],
      productionAnswer: "I treat 137 as a SIGKILL clue. For a container I inspect termination reason, cgroup v2 memory.events, memory.current and memory.max, pod events, and node kernel logs in the same time window. I also consider liveness timeouts, eviction, rollout termination, and manual kills. Only then do I classify container-limit OOM, host OOM, or non-OOM SIGKILL and choose a fix.",
      commonWeakAnswer: "Exit 137 always means OOMKilled, so double the memory limit.",
      whyWeak: "It mistakes a derived signal code for a sender and cause, and increasing a limit can move pressure to the node without fixing a leak or workload model.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "cat /sys/fs/cgroup/memory.events", interpretation: "On cgroup v2, oom and oom_kill counters provide workload-boundary evidence." },
        { classification: "READ-ONLY", item: "cat /sys/fs/cgroup/memory.current; cat /sys/fs/cgroup/memory.max", interpretation: "Shows current use and configured cgroup limit; post-event current use may already have fallen." },
        { classification: "READ-ONLY", item: "journalctl -k --since '<event-window>' | grep -Ei 'oom|out of memory|killed process'", interpretation: "Finds matching host-kernel messages; permissions and container-specific visibility can limit results." },
      ],
      followUpQuestions: [
        { question: "What does 137 directly tell you?", answer: "The shell-style result is consistent with termination by SIGKILL." },
        { question: "Can a liveness system produce 137?", answer: "Yes, if its termination escalates to SIGKILL after a grace period." },
      ],
    },
    {
      id: "memory-kubernetes-137-interview",
      kind: "interview",
      question: "A Kubernetes pod exits with code 137 during traffic peaks. Walk through host, cgroup, application, and workload evidence before changing its memory limit.",
      shortAnswer: "I would establish user impact and timing, confirm the Kubernetes termination reason, inspect container cgroup limits and OOM events, check node pressure and kernel evidence, then correlate application allocation behavior with peak traffic before sizing or fixing anything.",
      foundationAnswer: "A Pod is Kubernetes' workload unit, and each container can have a memory limit enforced by a Linux cgroup. If that boundary cannot satisfy memory demand, the kernel may kill the container even while the node has memory. The node can also suffer global pressure, and SIGKILL can come from non-OOM lifecycle actions, so pod, cgroup, host, application, and traffic evidence must agree.",
      reasoningSteps: [
        "Frame affected requests, replicas, peak interval, deployment change, and whether all pods or one pod fail.",
        "Inspect last termination reason, timestamps, restart count, events, requests, and limits.",
        "Read container cgroup OOM counters and compare working-set trend with memory.max.",
        "Inspect node availability, pressure, eviction signals, and kernel OOM events.",
        "Correlate heap, cache, queue, concurrency, payload size, and traffic behavior with the peak.",
        "Compare leak correction, concurrency bounds, cache limits, request sizing, and capacity changes before rollout.",
      ],
      productionAnswer: "I first determine whether this is cgroup OOM, node OOM, eviction, or another SIGKILL. I compare each pod's memory working set and OOM counters with its limit, then inspect node pressure and kernel selection. At the application layer I look for heap growth, unbounded queues, caches, large requests, concurrency, and garbage-collection behavior. If peak working set is legitimate, I size requests and limits from distributions with node headroom and test under representative load; if it is unbounded, more memory only delays recurrence.",
      commonWeakAnswer: "Traffic is high, so raise the limit and add replicas.",
      whyWeak: "It skips cause classification and capacity math; replicas may increase node pressure, and a higher limit may only hide a leak.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "kubectl describe pod <pod> -n <namespace>", interpretation: "Shows termination reason, restart history, events, placement, and configured resources." },
        { classification: "READ-ONLY", item: "kubectl top pod <pod> -n <namespace> --containers", interpretation: "Shows a current sample, not the peak that already caused termination." },
        { classification: "READ-ONLY", item: "kubectl describe node <node>", interpretation: "Shows node conditions, pressure, capacity, allocation, and events." },
        { classification: "EVIDENCE", item: "Time-aligned memory, request rate, concurrency, latency, queue, and heap profiles", interpretation: "Connects workload demand and application behavior to the termination window." },
      ],
      followUpQuestions: [
        { question: "Why can a pod OOM on a healthy node?", answer: "Its container cgroup limit can be exhausted independently of node-wide free memory." },
        { question: "When is raising the limit correct?", answer: "When tested legitimate peak working set plus safety headroom exceeds the old limit and node capacity remains safe." },
      ],
    },
  ],

  "network-request-path": [
    {
      id: "network-dns-proof",
      kind: "checkpoint",
      question: "Explain what DNS success proves and what it does not prove.",
      shortAnswer: "It proves the tested resolver returned a record for the name at that time; it does not prove the address is correct, reachable, listening, TLS-valid, or application-healthy.",
      foundationAnswer: "DNS, the Domain Name System, maps names to records such as IP addresses. A successful lookup means the current client received an answer through its configured resolver and cache. The request still needs a route, allowed network path, listening port, successful TLS negotiation for HTTPS, valid HTTP exchange, and healthy application dependencies.",
      reasoningSteps: [
        "Identify the exact hostname, record type, client environment, and configured resolver.",
        "Inspect returned addresses, aliases, and differences across affected and healthy clients.",
        "Evaluate cache and time-to-live behavior if a record recently changed.",
        "Continue separately through route, TCP, TLS, HTTP, and application gates.",
      ],
      productionAnswer: "I state DNS success narrowly: this namespace and resolver returned these records now. I compare results from the failing client, inspect split-DNS and cache behavior, and verify whether the address matches intended service discovery. I then test the next boundary instead of using DNS as end-to-end proof.",
      commonWeakAnswer: "The hostname resolves, so networking is fine.",
      whyWeak: "Resolution is only the naming gate and says nothing about reachability, policy, transport, TLS, HTTP, or backend health.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "getent ahosts <hostname>", interpretation: "Shows addresses returned through the system resolver used by many applications." },
        { classification: "READ-ONLY", item: "cat /etc/resolv.conf", interpretation: "Shows resolver configuration visible in this namespace; a local stub may hide upstream details." },
        { classification: "EVIDENCE", item: "Lookup from both failing and known-good client namespaces", interpretation: "Reveals resolver, cache, search-domain, or split-DNS differences." },
      ],
      followUpQuestions: [
        { question: "Can cached DNS be successful but stale?", answer: "Yes; a resolver or application may keep an older record until its cache expires or refreshes." },
        { question: "Does ping prove DNS is correct?", answer: "No; it may resolve a name and test ICMP to one address, not the intended service protocol." },
      ],
    },
    {
      id: "network-error-boundaries",
      kind: "checkpoint",
      question: "Distinguish connection refused, timeout, TLS failure, and HTTP 503.",
      shortAnswer: "Refused means transport was actively rejected, timeout means the expected step did not finish before its deadline, TLS failure happens after or during secure negotiation, and HTTP 503 means an HTTP component replied that service is unavailable.",
      foundationAnswer: "A TCP connection is the reliable transport channel. 'Connection refused' usually follows an immediate TCP reset because no usable listener exists at that address and port. A timeout means no expected completion arrived in time and can occur at connection or later request stages. TLS is the certificate and encryption negotiation over transport. HTTP 503 is an application-protocol response, so TCP and usually TLS already succeeded to whichever proxy or service generated it.",
      reasoningSteps: [
        "Record the exact stage, address, port, hostname, timeout type, and elapsed time.",
        "For refusal, inspect listener binding and destination translation.",
        "For timeout, inspect route, policy, packet loss, backlog, server latency, and return path at the timed-out stage.",
        "For TLS failure, inspect server name, certificate chain, trust, clock, protocol, and termination point.",
        "For 503, identify the responding HTTP component and inspect its upstream or overload evidence.",
      ],
      productionAnswer: "I name the last successful and first failed gate. Refusal is active transport rejection, commonly no listener or an explicit reject. Timeout is absence of completion and requires stage-specific timing plus both-side evidence. TLS errors narrow the problem to secure negotiation after reachability. A 503 proves an HTTP endpoint responded but may come from a proxy, mesh, gateway, or application, so headers, request IDs, and logs establish ownership.",
      commonWeakAnswer: "They are all network errors, so check the firewall.",
      whyWeak: "The signals occur at different protocol layers and imply different owners, evidence, and safe next checks.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "ip route get <destination-ip>", interpretation: "Shows the local route decision, not downstream policy or return-path success." },
        { classification: "READ-ONLY", item: "ss -lntp", interpretation: "Checks local listeners and possible owners on the server side." },
        { classification: "READ-ONLY", item: "openssl s_client -connect <host>:443 -servername <host> </dev/null", interpretation: "Shows TLS negotiation and presented certificates for the real server name." },
        { classification: "READ-ONLY", item: "curl -v --connect-timeout 3 --max-time 10 https://<host>/<path>", interpretation: "Separates connection, TLS, and HTTP evidence while enforcing bounded waits." },
      ],
      followUpQuestions: [
        { question: "Can a proxy return 503 while the app is healthy?", answer: "Yes; it may have stale endpoints, failed health state, overload, or upstream connectivity problems." },
        { question: "Does timeout always mean packets were dropped?", answer: "No; a slow server, queue, dependency, handshake, or response body can also exceed a deadline." },
      ],
    },
    {
      id: "network-namespace-matters",
      kind: "checkpoint",
      question: "Explain why the failing client's network namespace matters.",
      shortAnswer: "Each namespace can have different interfaces, routes, DNS configuration, firewall rules, sockets, and source addresses, so another namespace may follow a different path.",
      foundationAnswer: "A Linux network namespace is a separate view of networking. Containers and Kubernetes pods usually receive their own interfaces, routes, addresses, and socket table. A request from the host can bypass a pod's DNS, network policy, virtual interfaces, service translation, proxy, or source-address rules, so host success does not reproduce pod behavior.",
      reasoningSteps: [
        "Identify the exact process and namespace where the failure occurs.",
        "Collect name resolution, interface, route, and connection evidence from that namespace.",
        "Compare the same evidence with a known-good peer and the node only to locate divergence.",
        "Trace namespace crossings through virtual interfaces, policy, service translation, and destination endpoints.",
      ],
      productionAnswer: "I reproduce from the failing client's namespace because that defines its resolver, route, source identity, policy, sidecar, and service path. Node-level curl is a useful comparison, not a substitute. I compare an affected pod with a healthy pod on the same and different nodes to isolate pod configuration, namespace policy, or node dataplane failures.",
      commonWeakAnswer: "It works from the node, so the service is healthy and the pod should be restarted.",
      whyWeak: "The node and pod can traverse different DNS, route, NAT, policy, proxy, and identity boundaries; restart discards evidence without locating the divergence.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "kubectl exec -n <namespace> <pod> -- getent ahosts <service-name>", interpretation: "Tests resolution inside the affected pod; image tooling and permissions may limit availability." },
        { classification: "READ-ONLY", item: "kubectl exec -n <namespace> <pod> -- ip route", interpretation: "Shows routes visible in the affected namespace." },
        { classification: "READ-ONLY", item: "kubectl exec -n <namespace> <pod> -- curl -v --connect-timeout 3 http://<service>:<port>/<path>", interpretation: "Tests the request from the failing network context with bounded timing." },
      ],
      followUpQuestions: [
        { question: "What does a healthy peer pod comparison add?", answer: "It controls for service health and highlights pod, node, namespace, or policy differences." },
        { question: "Why might a minimal image block diagnosis?", answer: "It may omit tools; use an approved ephemeral debug container rather than changing the application image during an incident." },
      ],
    },
    {
      id: "network-one-pod-timeout-interview",
      kind: "interview",
      question: "A service works from the node but times out from one Kubernetes pod. Trace namespace, route, policy, service, endpoint, and application evidence.",
      shortAnswer: "Start in the affected pod, compare it with a healthy peer, and walk DNS, route, NetworkPolicy, Service translation, EndpointSlice readiness, destination listener, and application request evidence in order.",
      foundationAnswer: "Kubernetes gives pods isolated network namespaces. A Service is a stable virtual address, and EndpointSlices list the ready pod addresses behind it. NetworkPolicy can permit or deny pod traffic, while the cluster dataplane translates Service traffic toward an endpoint. Since the node path may bypass these boundaries, the failing pod must be the starting point.",
      reasoningSteps: [
        "Frame scope: one pod, one node, one namespace, one destination, or one request type; record recent changes.",
        "From the affected pod, inspect DNS result, source address, route, proxy variables, sidecar, and bounded connection timing.",
        "Compare labels, service account, policy selection, routes, and results with a healthy peer.",
        "Inspect Service ports and selectors, EndpointSlices, readiness, and destination port agreement.",
        "Inspect allowed ingress and egress policy plus the node or CNI dataplane when the failure follows a node.",
        "At the destination, verify listener, arrival logs or packet evidence, application latency, and dependencies.",
      ],
      productionAnswer: "Node success proves only the node path. I start with the pod's namespace and compare an affected pod with a healthy one. If DNS and route are correct, I inspect NetworkPolicy selection in both directions, then Service targetPort and EndpointSlices. Direct endpoint and Service tests can isolate service translation, but I keep protocol and hostname differences explicit. If SYNs never reach the destination, I inspect CNI and node dataplane; if they arrive, I move to listener, backlog, proxy, application, and dependency evidence.",
      commonWeakAnswer: "Restart the pod or CoreDNS because pod networking is flaky.",
      whyWeak: "It changes state without showing which boundary diverges and assumes DNS despite successful or untested later gates.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "kubectl get pod <pod> -n <namespace> -o wide --show-labels", interpretation: "Shows placement, address, readiness, and labels used by policy and service selection." },
        { classification: "READ-ONLY", item: "kubectl get svc,endpointslice -n <namespace> -o wide", interpretation: "Shows Service definition and ready endpoint membership; inspect exact named ports and target ports." },
        { classification: "READ-ONLY", item: "kubectl get networkpolicy -A", interpretation: "Lists policy objects; effective behavior also depends on labels, directions, namespace selectors, and CNI implementation." },
        { classification: "EVIDENCE", item: "Time-aligned client, proxy, destination, and dataplane logs or packet capture", interpretation: "Shows the last observed boundary and distinguishes silent path failure from application delay." },
      ],
      followUpQuestions: [
        { question: "What if the failure follows one node?", answer: "Prioritize that node's CNI agent, routes, conntrack, interfaces, policy programming, and resource pressure." },
        { question: "What if direct endpoint works but Service IP times out?", answer: "Investigate Service translation, proxy or eBPF programming, port mapping, and related policy differences." },
      ],
    },
  ],

  "identity-permissions": [
    {
      id: "identity-directory-execute",
      kind: "checkpoint",
      question: "Explain execute permission on a directory without describing it as running the directory.",
      shortAnswer: "Execute on a directory means search or traversal permission: it allows a process to pass through that directory and access a named child when other required permissions allow it.",
      foundationAnswer: "The rwx letters mean different operations on directories than on regular files. Directory read permission allows listing names, write permission allows changing directory entries, and execute permission allows path traversal or lookup of a known child name. Linux checks execute permission on every parent directory while resolving a path.",
      reasoningSteps: [
        "Identify the effective user and groups of the process making the request.",
        "Walk every directory component from the starting root toward the target.",
        "Apply the owner, group, or other permission class at each component.",
        "Require execute for traversal, then evaluate the final object's operation-specific permissions.",
      ],
      productionAnswer: "For directories I call x 'search' or 'traverse.' A process may know a filename and access it with directory x even without listing the directory, while directory r without x can reveal names but not let the process stat or open them normally. I use namei -l as a first path-mode view, then include ACL, mount, identity, and mandatory-policy evidence.",
      commonWeakAnswer: "Execute permission runs the folder.",
      whyWeak: "Directories are not executed as programs; the wording hides the path-resolution check that commonly causes permission incidents.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "id", interpretation: "Shows the current shell identity; inspect the actual service identity separately." },
        { classification: "READ-ONLY", item: "namei -l <exact-path>", interpretation: "Shows ownership and mode bits for each path component." },
        { classification: "READ-ONLY", item: "test -x <directory> && echo traversable=true", interpretation: "Tests traversal for the current process identity, not a different service user." },
      ],
      followUpQuestions: [
        { question: "Can a file be readable but unreachable?", answer: "Yes; missing execute permission on any parent directory prevents path traversal." },
        { question: "What does write on a directory allow?", answer: "Creating, removing, or renaming entries, subject to execute and special-bit rules." },
      ],
    },
    {
      id: "identity-chmod-777",
      kind: "checkpoint",
      question: "Explain why chmod 777 is usually the wrong incident response.",
      shortAnswer: "It grants every local identity read, write, and execute permissions, expands the blast radius, hides the real denied boundary, and cannot fix many non-mode controls.",
      foundationAnswer: "chmod changes Unix mode bits. The digits in 777 grant rwx to the owner, group, and everyone else. That may expose confidential data, allow tampering, or make files executable, while the original problem may actually be a missing parent-directory traversal bit, wrong service user, ACL, read-only mount, SELinux or AppArmor policy, or container volume mismatch.",
      reasoningSteps: [
        "Identify the exact process identity, failed operation, and path.",
        "Locate the first denied boundary across every parent and the target.",
        "Inspect modes, ownership, ACLs, mount options, and mandatory-policy evidence.",
        "Choose the narrowest owner, group, ACL, identity, or policy correction that matches the requirement.",
        "Verify the required operation as the service identity and confirm unrelated access remains denied.",
      ],
      productionAnswer: "I reject 777 because it converts an unknown authorization failure into a broad integrity risk. I reproduce safely as the runtime identity, use namei, stat, getfacl, findmnt, and policy logs to locate the decision, then implement least privilege. The verification includes a positive test for the service and negative tests for identities that should remain unauthorized.",
      commonWeakAnswer: "Use 777 temporarily, then tighten it after the outage.",
      whyWeak: "Temporary permissions are often forgotten, may expose or corrupt data immediately, and destroy the evidence showing which permission was actually required.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "namei -l <exact-path>", interpretation: "Shows owner and mode at every path component." },
        { classification: "READ-ONLY", item: "getfacl -p <exact-path>", interpretation: "Shows POSIX ACL entries and masks when ACL tooling and support are available." },
        { classification: "READ-ONLY", item: "findmnt -T <exact-path> -o TARGET,SOURCE,FSTYPE,OPTIONS", interpretation: "Shows mount ownership and options such as ro, noexec, or nosuid." },
      ],
      followUpQuestions: [
        { question: "What is a safer shared-write pattern?", answer: "Use a dedicated group or narrow ACL, controlled directory modes, appropriate umask, and tested ownership." },
        { question: "Can chmod fix a read-only mount?", answer: "No; the mount boundary rejects writes independently of file mode bits." },
      ],
    },
    {
      id: "identity-controls-beyond-mode",
      kind: "checkpoint",
      question: "Name two controls that can deny access even when mode bits look correct.",
      shortAnswer: "A read-only mount and an SELinux or AppArmor policy can deny access; ACLs, capabilities, and container security settings can also change the result.",
      foundationAnswer: "Mode bits are the basic owner, group, and other rwx rules, but they are not the whole decision. A mount can be read-only, an access control list can add entries or limit group-class rights, and mandatory access control such as SELinux or AppArmor can enforce a separate security policy. Containers add runtime identity, capabilities, and volume settings that may differ from the host shell.",
      reasoningSteps: [
        "Confirm the actual runtime identity and requested operation.",
        "Validate every path component and target mode or ownership decision.",
        "Inspect ACL entries and their effective mask.",
        "Inspect mount flags and container volume mappings.",
        "Inspect SELinux or AppArmor denials and runtime security settings before changing policy.",
      ],
      productionAnswer: "Two clear examples are a ro mount and mandatory access control. I also check ACL masks, container UID and groups, Kubernetes securityContext, capabilities, read-only root filesystem, and rootless user mappings. I never disable SELinux or AppArmor as diagnosis; I correlate an explicit denial with the intended access and write the narrowest reviewed rule.",
      commonWeakAnswer: "If ls -l looks right, the application must be using the wrong password.",
      whyWeak: "Filesystem access does not normally involve a password, and ls -l omits several controls and the service's real identity.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "getfacl -p <exact-path>", interpretation: "Shows ACL entries and the mask that may limit effective rights." },
        { classification: "READ-ONLY", item: "findmnt -T <exact-path> -o TARGET,SOURCE,FSTYPE,OPTIONS", interpretation: "Shows the path's mount options." },
        { classification: "READ-ONLY", item: "journalctl -k --since '<event-window>' | grep -Ei 'apparmor|avc|denied'", interpretation: "Searches kernel logs for policy denials; use platform-specific audit tooling when configured." },
      ],
      followUpQuestions: [
        { question: "Why can your shell succeed while systemd fails?", answer: "The unit may use a different UID, groups, umask, working directory, capabilities, or confinement policy." },
        { question: "What does an ACL mask do?", answer: "It limits effective permissions for named users, named groups, and the owning group class." },
      ],
    },
    {
      id: "identity-container-uid-interview",
      kind: "interview",
      question: "A container works as root but fails as UID 10001 when writing a mounted volume. Explain the host, image, mount, Kubernetes securityContext, and policy evidence you would collect.",
      shortAnswer: "Trace numeric identity end to end: image USER, runtime UID and groups, host-volume numeric ownership and modes, mount flags, securityContext and fsGroup behavior, then ACL and mandatory-policy denials.",
      foundationAnswer: "Linux access checks use numeric user and group identifiers. Root is UID 0 and can bypass many ordinary checks, so root success can hide a volume ownership defect. UID 10001 must match the file owner, an allowed group, or an ACL and still pass parent traversal, mount, and security-policy checks. Kubernetes securityContext controls runtime identity and can request group handling for supported volumes.",
      reasoningSteps: [
        "Identify the exact failing operation, container, volume path, workload version, and security requirement.",
        "Inspect image USER and entrypoint assumptions, then verify effective UID, GIDs, groups, and capabilities inside the running container.",
        "Map the container path to the volume and inspect numeric ownership, modes, ACLs, parent traversal, and mount options on the responsible boundary.",
        "Inspect runAsUser, runAsGroup, fsGroup, supplementalGroups, privilege escalation, root filesystem, and volume type behavior.",
        "Inspect SELinux, AppArmor, admission policy, and node-level denial evidence.",
        "Fix ownership or group policy narrowly and verify both required write and prohibited access with rollback readiness.",
      ],
      productionAnswer: "I do not solve this by reverting to root. I compare the image's declared USER with the effective runtime credentials and Kubernetes securityContext. On the volume I use numeric IDs because names may differ across image and node, inspect every path component, ACLs, and mount flags, and determine whether fsGroup applies to that volume driver. I correlate policy denials, then choose a predictable image-time ownership, init-time bounded correction, or storage-class/group design without recursive broad chmod on shared data.",
      commonWeakAnswer: "Set runAsUser: 0 or chmod -R 777 on the volume.",
      whyWeak: "Both bypass the intended security boundary, expand write access, can be very slow or destructive on shared volumes, and leave the numeric ownership design broken.",
      evidenceOrCommands: [
        { classification: "READ-ONLY", item: "docker image inspect <image> --format '{{json .Config.User}}'", interpretation: "Shows the image's declared default user, not necessarily the overridden runtime identity." },
        { classification: "READ-ONLY", item: "kubectl exec -n <namespace> <pod> -c <container> -- id", interpretation: "Shows effective UID and groups inside the running container." },
        { classification: "READ-ONLY", item: "kubectl get pod <pod> -n <namespace> -o yaml", interpretation: "Shows pod and container securityContext plus volume definitions; redact secrets before sharing." },
        { classification: "READ-ONLY", item: "namei -l <mounted-path>; stat -c '%u:%g %a %n' <mounted-path>", interpretation: "Shows numeric ownership and mode along the responsible path when run in the relevant namespace." },
      ],
      followUpQuestions: [
        { question: "Why use numeric IDs in evidence?", answer: "Usernames are local mappings; the kernel and mounted filesystem compare numeric UIDs and GIDs." },
        { question: "Does fsGroup always rewrite volume ownership?", answer: "No; behavior depends on volume type, CSI driver, policy, existing ownership, and fsGroupChangePolicy." },
      ],
    },
  ],
};
