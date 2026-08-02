---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0023",
  "aliases": ["V03-L08", "oci-containers-docker"],
  "curriculumIds": ["CTR-001", "CTR-002"],
  "slug": "oci-containers-docker",
  "route": "/book/engineering/oci-containers-docker",
  "order": 8,
  "volume": "03-engineering-delivery",
  "title": "OCI containers and Docker: understand the image, process, isolation, and trust boundaries",
  "summary": "Build a first-principles container model from host processes, Linux namespaces and cgroups through OCI image/index/manifest/config/layers, runtime bundles, copy-on-write filesystems, mounts, networks, PID 1, signals, health, logging, resources, least privilege, reproducible builds, registry trust, SBOMs, provenance, incident debugging, and exact lifecycle cleanup.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 560,
  "prerequisiteLessonIds": ["LES-0011", "LES-0004", "LES-0022"],
  "prerequisiteCurriculumIds": ["LNX-007", "NET-003", "BLD-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Bash syntax, static safety, local state guards, and blocked-runtime behavior target a normal non-root Ubuntu shell. The lab never installs packages, elevates privilege, contacts a registry, or mutates host configuration."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu with Docker Desktop Linux containers",
      "version": "Ubuntu 24.04 LTS; Docker Engine API compatible with lab checks",
      "support": "supported",
      "notes": "Runtime exercises require Docker Desktop already running, Ubuntu WSL integration already enabled, and the exact pinned BusyBox digest already cached. If any gate is absent, verification reports blocked and stops without pulling or reconfiguration."
    },
    {
      "platform": "Docker Engine, containerd/OCI runtimes, Kubernetes, private cloud, and public cloud",
      "version": "provider-neutral production transfer",
      "support": "concept-only",
      "notes": "The chapter maps concepts to production runtimes and orchestrators, but the local lab proves none of their admission, registry, kernel, network, storage, multi-architecture, or supply-chain behavior."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "release-engineer", "security-engineer", "data-platform-engineer"],
  "learningObjectives": [
    "Explain a container as ordinary host-kernel processes with scoped views and controls, and distinguish it precisely from a virtual machine with a guest kernel.",
    "Trace a named image through registry reference, optional OCI index, platform manifest, configuration, compressed layer blobs, uncompressed rootfs changes, local content store, runtime bundle, container record, and processes.",
    "Distinguish mutable tag, digest, image ID, container ID/name, namespace PID, host PID, cgroup identity, and logical user operation in evidence and automation.",
    "Reason about OverlayFS lower layers, upper writable layer, copy-up, whiteouts, merged view, read-only root filesystems, bind mounts, volumes, and tmpfs ownership and persistence.",
    "Trace Docker CLI, daemon, container manager, shim and OCI runtime responsibilities without assuming every implementation has the same process tree.",
    "Design PID 1, child reaping, signal forwarding, stop grace, restart, health, logging, and durable work state so container replacement does not corrupt or duplicate operations.",
    "Interpret cgroup memory, CPU, PID and I/O policies with exact units, relate them to process/host observations, and diagnose OOM/throttle/exhaustion without namespace confusion.",
    "Design container network and service paths from process socket through namespace interfaces, virtual links, bridge/routing/NAT, host publication, load balancers and user verification.",
    "Apply least privilege through non-root users, capability minimization, no-new-privileges, seccomp, mandatory access control, read-only rootfs, mount/device/network policy, secret handling, rootless/user namespaces, and daemon protection.",
    "Build and promote reproducible, minimal, multi-platform images with digest-pinned inputs, trusted builders, verified downloads, secret-safe builds, SBOMs, provenance, signatures/attestations, scanning, admission and immutable rollout evidence.",
    "Run safe container incident response: preserve immutable/runtime identity, separate trigger from root cause, control restarts, reconcile business effects, recover bounded scope, verify users, and remove only exact owned resources."
  ],
  "productionSignals": [
    "A container exits 137 or reports OOMKilled while the host still has available memory.",
    "A workload is running but unhealthy, healthy but not processing work, or repeatedly restarted without durable progress.",
    "SIGTERM is sent but the application never logs shutdown, children remain, or the runtime escalates to SIGKILL after grace.",
    "Container writable-layer size, Docker backing-store blocks, or inodes grow although an application volume appears healthy.",
    "The same image tag resolves to different content across nodes, times, architectures, or environments.",
    "AMD64 works while ARM64 fails because an OCI index selects different platform manifests or a binary/package is wrong for the platform.",
    "A container runs as root, privileged, with broad capabilities, disabled seccomp, host namespace, Docker socket, sensitive bind, or writable root filesystem.",
    "CPU throttling, memory events, PID exhaustion, I/O latency, or node pressure rises while application telemetry reports only generic timeout.",
    "Published ports or container-localhost assumptions route traffic to the wrong namespace or expose a service unexpectedly.",
    "Logs disappear with the container, grow without rotation, leak secrets, or cannot be correlated to image/container/logical operation identity.",
    "A scanner, SBOM, signature, or provenance check is treated as a universal security certificate rather than scoped evidence.",
    "Restart or rollout repeats accepted jobs because business state lived in the writable layer or attempt identity replaced logical operation identity."
  ],
  "diagrams": [
    {
      "id": "LES-0023-DIA-001",
      "title": "Container and virtual machine isolation differ at the kernel boundary",
      "direction": "left-to-right",
      "boundaries": ["physical or virtual host", "host Linux kernel", "namespaces and cgroups", "container processes", "hypervisor", "guest kernel", "virtual-machine processes"],
      "evidencePoints": ["host/VM identity", "kernel release", "namespace inode IDs", "cgroup path and limits", "virtual hardware", "guest boot/kernel", "process IDs"],
      "textAlternative": "Container processes execute system calls against the host Linux kernel while namespaces change their views and cgroups account/control resources. A virtual machine receives virtual hardware and boots a separate guest kernel whose processes call that guest kernel."
    },
    {
      "id": "LES-0023-DIA-002",
      "title": "An OCI image is a content-addressed descriptor graph",
      "direction": "hierarchical",
      "boundaries": ["name or tag", "index descriptor", "platform manifest descriptor", "image configuration descriptor", "layer descriptors", "content blobs", "runtime root filesystem"],
      "evidencePoints": ["registry/repository/reference", "index digest and platform entries", "manifest digest", "config digest and image ID", "compressed blob digests/sizes", "verified content", "uncompressed DiffIDs and applied changes"],
      "textAlternative": "A registry name or mutable tag resolves to a descriptor, sometimes an OCI image index. The index selects a platform manifest. That manifest references one configuration blob and ordered filesystem layer blobs by media type, digest, and size. Verified content becomes a root filesystem and runtime configuration."
    },
    {
      "id": "LES-0023-DIA-003",
      "title": "Overlay copy-on-write combines immutable lower layers with one upper layer",
      "direction": "top-to-bottom",
      "boundaries": ["image lower directories", "container upper directory", "OverlayFS work directory", "merged mount", "bind volume or tmpfs mount", "application path"],
      "evidencePoints": ["layer DiffIDs", "copy-up and whiteout", "backing filesystem", "visible inode/path", "mount source/type/options", "read/write and persistence result"],
      "textAlternative": "Read-only image layer directories form the lower view. A writable container upper directory records changes and a work directory supports OverlayFS operations. The merged mount presents one tree. A volume, bind or tmpfs mounted on a path hides the merged content beneath it and has a separate owner/lifecycle."
    },
    {
      "id": "LES-0023-DIA-004",
      "title": "Docker coordinates an OCI runtime and the host kernel",
      "direction": "left-to-right",
      "boundaries": ["Docker CLI/client", "Docker API and daemon", "image/network/volume state", "container manager and shim", "OCI runtime", "namespaces cgroups mounts", "host-kernel processes"],
      "evidencePoints": ["context and endpoint", "daemon version/events", "container/image IDs", "runtime task/shim identity", "bundle config and lifecycle", "namespace/cgroup IDs", "host and namespace PIDs"],
      "textAlternative": "The Docker client calls a daemon API. The daemon manages metadata, images, networks and volumes and delegates a task to container-management and low-level OCI runtime components. The runtime configures namespaces, cgroups, mounts, credentials and the initial process; after creation the workload remains host-kernel processes. Exact component names and lifetimes vary by implementation."
    },
    {
      "id": "LES-0023-DIA-005",
      "title": "PID 1 owns the container signal and child lifecycle boundary",
      "direction": "cyclic",
      "boundaries": ["controller stop request", "runtime stop signal", "container PID 1", "application and children", "grace timer", "forced kill", "durable checkpoint and verification"],
      "evidencePoints": ["stop signal and timeout", "signal delivery timestamp", "PID namespace process tree", "forward/reap behavior", "remaining seconds", "exit signal/status", "work receipt and duplicate count"],
      "textAlternative": "A controller asks the runtime to stop the container. The runtime sends the configured signal to container PID 1. PID 1 must handle or forward it and reap children while the grace timer runs. If it remains, the runtime can force kill. Durable work identity and verification determine whether restart is safe."
    },
    {
      "id": "LES-0023-DIA-006",
      "title": "Container traffic crosses several network ownership boundaries",
      "direction": "left-to-right",
      "boundaries": ["application socket", "container network namespace", "virtual interface", "bridge routing or overlay", "host publication or service proxy", "load balancer", "client and user operation"],
      "evidencePoints": ["bind address and port", "namespace interface/route/socket", "veth identity", "bridge route policy", "host address/NAT/firewall", "backend decision/health", "response and user result"],
      "textAlternative": "A process binds a socket inside its network namespace. Packets traverse namespace interfaces and virtual links into a bridge, route or overlay, then possibly host port publication, service proxy and load balancer before reaching a client. Every layer has its own addresses, policy, counters and failure evidence."
    }
  ],
  "commands": [
    {
      "id": "LES-0023-CMD-001",
      "question": "Which kernel and namespace views does this Ubuntu shell use?",
      "risk": "read-only",
      "command": "uname -a; printf 'self_pid_namespace='; readlink /proc/self/ns/pid; printf 'self_mount_namespace='; readlink /proc/self/ns/mnt; printf 'self_network_namespace='; readlink /proc/self/ns/net; printf 'cgroup='; cat /proc/self/cgroup",
      "runFrom": "The exact Ubuntu 24.04 or WSL shell whose Docker boundary you are diagnosing",
      "expectedBranches": [
        {"when": "Kernel, namespace inode-like identifiers, and cgroup membership print", "meaning": "You captured this shell's current Linux execution boundary.", "nextEvidence": "Compare with the target container's process namespace and cgroup through authorized runtime inspection."},
        {"when": "A `/proc` namespace link or cgroup record is unavailable", "meaning": "The environment or permissions differ from the assumed Linux procfs boundary.", "nextEvidence": "Stop and identify the actual OS/runtime namespace before interpreting container output."}
      ],
      "proves": "Kernel string and current process namespace/cgroup references for this shell at one instant.",
      "doesNotProve": "Container membership, isolation strength, guest versus physical host, kernel security, or the target workload's namespaces."
    },
    {
      "id": "LES-0023-CMD-002",
      "question": "Which Docker client, context and daemon are being addressed?",
      "risk": "read-only",
      "command": "docker context show; docker version --format 'client={{.Client.Version}} server={{.Server.Version}} api={{.Server.APIVersion}} os={{.Server.Os}} arch={{.Server.Arch}}'; docker info --format 'name={{.Name}} driver={{.Driver}} cgroup={{.CgroupVersion}} rootless={{json .SecurityOptions}}'",
      "runFrom": "An already-authorized local Ubuntu/WSL Docker shell; stop if the context is remote or production",
      "expectedBranches": [
        {"when": "The intended local context and Linux daemon facts print", "meaning": "The client reached a daemon and identified its basic runtime boundary.", "nextEvidence": "Verify the exact cached image and lesson container identity before action."},
        {"when": "Daemon unavailable, context unexpected, or server fields absent", "meaning": "The Docker control boundary is unavailable or not the intended target.", "nextEvidence": "Stop; do not switch context, start services, or reconfigure Docker during the lab."}
      ],
      "proves": "Client-selected context and responding daemon metadata.",
      "doesNotProve": "Authorization scope, daemon safety, network isolation, workload ownership, or that a local-looking name is not remote."
    },
    {
      "id": "LES-0023-CMD-003",
      "question": "Is the exact pinned image already present, and what content metadata does Docker expose?",
      "risk": "read-only",
      "command": "IMAGE_REF='busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662'; docker image inspect --format 'id={{.Id}} repo_digests={{json .RepoDigests}} os={{.Os}} arch={{.Architecture}} rootfs={{.RootFS.Type}} layers={{len .RootFS.Layers}} user={{if index .Config \"User\"}}{{index .Config \"User\"}}{{else}}unspecified{{end}} entrypoint={{if index .Config \"Entrypoint\"}}{{json (index .Config \"Entrypoint\")}}{{else}}null{{end}} cmd={{if index .Config \"Cmd\"}}{{json (index .Config \"Cmd\")}}{{else}}null{{end}}' \"$IMAGE_REF\"",
      "runFrom": "The intended local Docker daemon; this command never pulls",
      "expectedBranches": [
        {"when": "An image ID, repository digest, Linux platform, rootfs layers and config print", "meaning": "The daemon has local metadata/content resolvable by that digest.", "nextEvidence": "Record platform-specific manifest/index evidence from the registry promotion system for production."},
        {"when": "No such image error appears", "meaning": "The digest is not locally cached.", "nextEvidence": "Stop the lab; do not pull or retag to bypass the offline gate."}
      ],
      "proves": "Local daemon resolution and selected image/config metadata for the exact digest.",
      "doesNotProve": "Registry freshness, signature/provenance/SBOM policy, vulnerability absence, or the exact remote descriptor graph."
    },
    {
      "id": "LES-0023-CMD-004",
      "question": "What build/history metadata is attached to the cached image?",
      "risk": "read-only",
      "command": "IMAGE_REF='busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662'; docker image history --no-trunc --format 'created={{.CreatedAt}} size={{.Size}} created_by={{.CreatedBy}} comment={{.Comment}}' \"$IMAGE_REF\"",
      "runFrom": "The intended local daemon; output may reveal build commands and must be handled as potentially sensitive",
      "expectedBranches": [
        {"when": "History rows print", "meaning": "The image configuration exposes history entries recorded by its build process.", "nextEvidence": "Compare with trusted provenance and inspect for credential-bearing commands without copying secrets."},
        {"when": "History is empty or incomplete", "meaning": "This artifact does not expose useful history through that interface.", "nextEvidence": "Use build-system provenance/SBOM and source records rather than inventing lineage."}
      ],
      "proves": "Docker-visible history metadata and reported layer-command sizes for this local image.",
      "doesNotProve": "Actual source, reproducibility, absence of deleted secrets, builder identity, or runtime filesystem contents."
    },
    {
      "id": "LES-0023-CMD-005",
      "question": "Does the exact lesson container match the intended security and resource envelope?",
      "risk": "read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker container inspect --format 'id={{.Id}} image={{.Image}} user={{.Config.User}} state={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} network={{.HostConfig.NetworkMode}} readonly={{.HostConfig.ReadonlyRootfs}} privileged={{.HostConfig.Privileged}} caps={{json .HostConfig.CapDrop}} security={{json .HostConfig.SecurityOpt}} memory={{.HostConfig.Memory}} cpus={{.HostConfig.NanoCpus}} pids={{.HostConfig.PidsLimit}}' \"$LAB_CONTAINER\"",
      "runFrom": "The LES-0023 lab directory after guarded setup",
      "expectedBranches": [
        {"when": "Exact ID/image/user/state and hardened settings match", "meaning": "The live container configuration satisfies the inspected portion of the lab envelope.", "nextEvidence": "Use the controller, which also checks labels, token, mounts, ports and descriptor identity."},
        {"when": "Container missing or any field differs", "meaning": "The assumed instance or envelope is false.", "nextEvidence": "Stop; do not replace or clean it until exact ownership is established."}
      ],
      "proves": "Selected configuration/state fields for the named container at one instant.",
      "doesNotProve": "Full controller ownership, kernel enforcement, application correctness, image trust, or future state."
    },
    {
      "id": "LES-0023-CMD-006",
      "question": "Which processes are visible for this container, and who is PID 1?",
      "risk": "sampled-read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker top \"$LAB_CONTAINER\" -eo pid,ppid,user,comm,args",
      "runFrom": "The running guarded LES-0023 container",
      "expectedBranches": [
        {"when": "A shell and sleep child appear under the configured nobody user", "meaning": "Docker mapped container tasks to host-visible process records for this sample.", "nextEvidence": "Compare host PIDs with container namespace PIDs and inspect signal logs during controlled stop."},
        {"when": "Container is stopped or process output differs", "meaning": "Lifecycle or process-tree assumptions changed.", "nextEvidence": "Inspect container state, exit/OOM fields and logs before restart."}
      ],
      "proves": "One sampled daemon-reported process table for the exact container.",
      "doesNotProve": "Complete process history, absence of short-lived children, correct signal forwarding, or host-wide process ownership."
    },
    {
      "id": "LES-0023-CMD-007",
      "question": "What changed in the container layer and which paths are separate mounts?",
      "risk": "read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker diff \"$LAB_CONTAINER\"; docker container inspect --format 'driver={{.GraphDriver.Name}} readonly={{.HostConfig.ReadonlyRootfs}} tmpfs={{json .HostConfig.Tmpfs}} binds={{json .HostConfig.Binds}} mounts={{json .Mounts}}' \"$LAB_CONTAINER\"",
      "runFrom": "The guarded LES-0023 container in running or stopped state",
      "expectedBranches": [
        {"when": "No rootfs diff appears and `/run`/`/work` are tmpfs with no binds", "meaning": "Test writes live on separate memory-backed mounts while the root filesystem is read-only.", "nextEvidence": "Verify tmpfs capacity/options and application persistence requirements."},
        {"when": "Unexpected changes or host binds appear", "meaning": "Filesystem ownership/blast radius differs from the lab contract.", "nextEvidence": "Stop cleanup and inspect exact container identity and mount sources."}
      ],
      "proves": "Daemon-reported rootfs changes and mount configuration for the exact container.",
      "doesNotProve": "Underlying bytes are durable, host storage is healthy, a mount is backed up, or no file was changed then removed."
    },
    {
      "id": "LES-0023-CMD-008",
      "question": "What cgroup limits are visible to the running workload?",
      "risk": "sampled-read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker container exec \"$LAB_CONTAINER\" sh -c 'for f in memory.max memory.current memory.events cpu.max cpu.stat pids.max pids.current; do if [ -r /sys/fs/cgroup/$f ]; then printf \"--- %s ---\\n\" \"$f\"; cat \"/sys/fs/cgroup/$f\"; fi; done'",
      "runFrom": "The running guarded LES-0023 container; exec creates only a short-lived read process",
      "expectedBranches": [
        {"when": "cgroup-v2 limit/current/event files print", "meaning": "The process can observe its scoped cgroup controls/accounting through this mount.", "nextEvidence": "Compare exact units and interval deltas with daemon config and host/node signals."},
        {"when": "Files differ or are unavailable", "meaning": "Cgroup version, mount layout, runtime or permissions differ.", "nextEvidence": "Record daemon cgroup version and inspect the workload's actual cgroup path without assuming filenames."}
      ],
      "proves": "Point-in-time contents of available cgroup files from the container's view.",
      "doesNotProve": "Host capacity, correct resource sizing, future OOM/throttle, or the cause of application latency."
    },
    {
      "id": "LES-0023-CMD-009",
      "question": "Which network and port-publication boundary does the container have?",
      "risk": "read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker container inspect --format 'mode={{.HostConfig.NetworkMode}} port_bindings={{json .HostConfig.PortBindings}} publish_all={{.HostConfig.PublishAllPorts}} networks={{json .NetworkSettings.Networks}}' \"$LAB_CONTAINER\"",
      "runFrom": "The guarded LES-0023 container",
      "expectedBranches": [
        {"when": "mode=none, empty port bindings and no attached network print", "meaning": "Docker configured no external container network attachment or published port.", "nextEvidence": "Confirm application makes no network assumption and inspect host/daemon separately only when authorized."},
        {"when": "Bridge/host/network or ports appear", "meaning": "Traffic blast radius exceeds the offline lab contract.", "nextEvidence": "Stop; preserve inspection and identify who created the nonconforming container."}
      ],
      "proves": "Docker configuration for network mode, attachments and port publication.",
      "doesNotProve": "Host network inactivity, kernel/firewall correctness, DNS behavior, or absence of Unix-socket/host-mount communication."
    },
    {
      "id": "LES-0023-CMD-010",
      "question": "What do container state, health and logs say together?",
      "risk": "sampled-read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker container inspect --format 'state={{.State.Status}} running={{.State.Running}} exit={{.State.ExitCode}} oom={{.State.OOMKilled}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} restarts={{.RestartCount}}' \"$LAB_CONTAINER\"; docker container logs --tail 20 \"$LAB_CONTAINER\"",
      "runFrom": "The exact guarded LES-0023 container; logs may be sensitive in production",
      "expectedBranches": [
        {"when": "Running/healthy plus PID1 start log, or stopped plus signal log, appears", "meaning": "Lifecycle metadata and application-emitted evidence can be correlated for this instance.", "nextEvidence": "Verify the real work outcome and controller action; neither health nor log line is sufficient."},
        {"when": "State and expected logs disagree", "meaning": "Logging, process, timing or identity assumptions are incomplete.", "nextEvidence": "Preserve container ID/timestamps and inspect runtime events and process tree before action."}
      ],
      "proves": "Sampled state fields and last 20 captured log lines for the exact container.",
      "doesNotProve": "Complete logs, user-operation success, no secret leakage, root cause, or why a signal/exit occurred."
    },
    {
      "id": "LES-0023-CMD-011",
      "question": "What resource usage does Docker sample now relative to configured limits?",
      "risk": "sampled-read-only",
      "command": "LAB_CONTAINER=\"reliability-atlas-les0023-u$(id -u)\"; docker stats --no-stream --format 'name={{.Name}} cpu={{.CPUPerc}} memory={{.MemUsage}} memory_percent={{.MemPerc}} pids={{.PIDs}} block_io={{.BlockIO}} network_io={{.NetIO}}' \"$LAB_CONTAINER\"",
      "runFrom": "The running guarded LES-0023 container",
      "expectedBranches": [
        {"when": "One sample with CPU, memory, PID and I/O fields prints", "meaning": "The daemon reported a point-in-time/interval-derived resource sample.", "nextEvidence": "Collect a time series and cgroup event/throttle counters under representative workload."},
        {"when": "Container is stopped or fields unavailable", "meaning": "No live sample can be obtained through this command.", "nextEvidence": "Use retained metrics/events and inspect state; do not restart solely to collect stats."}
      ],
      "proves": "One Docker-formatted resource sample for the named running container.",
      "doesNotProve": "Peak usage, correct units across every platform, no throttling/OOM, host capacity, or safe production sizing."
    },
    {
      "id": "LES-0023-CMD-012",
      "question": "Is the guarded offline Docker lab ready without pulling or changing state?",
      "risk": "read-only",
      "command": "bash lab.sh check",
      "runFrom": "book/labs/LES-0023-oci-containers-docker in a normal-user Ubuntu 24.04 WSL shell",
      "expectedBranches": [
        {"when": "runtime=ready, image_cached=true, state=absent or registered, network=none", "meaning": "Local runtime/image and exact lesson-state gates passed at that instant.", "nextEvidence": "Read the lab README before explicit setup or continue only through controller commands."},
        {"when": "Daemon/image/root/foreign container/artifact refusal appears", "meaning": "A prerequisite or ownership boundary is not satisfied.", "nextEvidence": "Stop; do not pull, elevate, reconfigure, replace, or manually clean."}
      ],
      "proves": "Controller preflight for daemon reachability, cached digest and exact local lesson-state boundary.",
      "doesNotProve": "Image trust, runtime security, network absence outside the container, lab outcome, cleanup, learner reasoning, or mastery."
    }
  ],
  "labs": [
    {
      "id": "LES-0023-LAB-001",
      "title": "Guided running-versus-health container investigation",
      "mode": "guided",
      "environment": "Ubuntu 24.04 WSL, already-running Docker Desktop Linux engine, exact BusyBox digest already cached, normal user; otherwise static blocked path",
      "timeMinutes": 60,
      "privilege": "Normal user only. Docker access itself is a high-privilege daemon boundary; lab and verifier refuse UID 0 and any nonconforming same-name container.",
      "network": "No external network, no registry call, `--pull=never`, container network none, no published ports",
      "changes": ["Creates one exact labeled Docker container with a fixed UID-scoped name and random instance label", "Creates one mode-0600 atomic state descriptor and optional exact case/recovery/verification records beneath /tmp", "Writes only health/readiness and probe data to bounded container tmpfs mounts"],
      "abortConditions": ["Docker context/daemon is unavailable, remote, shared unexpectedly, or production", "Pinned digest is absent, which is a blocked gate rather than permission to pull", "Root identity, stale artifact, descriptor mismatch, foreign container, label/image/config/mount/port/security/limit mismatch, or symlink is observed", "Any step requests build, pull, install, privilege, host bind, Docker socket mount, external network, prune, or wildcard cleanup"],
      "recovery": "Use only controller recovery to recreate the `/run/ready` marker after the guided case, verify running/health/user/rootfs/tmpfs/network/log contracts, then exact cleanup.",
      "cleanupProof": "When runtime is available, verifier proves exact container and local-artifact absence after guided/independent/refusal cases. When unavailable, it reports cleanup not exercised and makes no runtime claim.",
      "path": "book/labs/LES-0023-oci-containers-docker"
    },
    {
      "id": "LES-0023-LAB-002",
      "title": "Independent PID 1, stop signal, restart and production transfer",
      "mode": "independent",
      "environment": "A clean LES-0023 lifecycle with the same offline gates; learner response outside lab state; no fixture/controller or prior-answer inspection",
      "timeMinutes": 90,
      "privilege": "Normal user through an already-authorized local Docker context; no sudo, daemon reconfiguration, privileged container, host namespace, device, bind, or socket",
      "network": "No pull/build/registry/external call; exact cached digest and network-none container only",
      "changes": ["Creates and gracefully stops/restarts only the exact registered lesson container", "Records case/recovery/verification in exact UID-owned local files", "Leaves learner notes outside controller-owned state"],
      "abortConditions": ["Raw scenario was not captured and predicted before derived observation", "Runtime/image gate is blocked or context target is uncertain", "Proposed recovery lacks exact container ID/digest, daemon scope, stop grace, state reconciliation, abort or verification", "Controller reports any ownership, tamper, symlink, foreign-object, configuration or cleanup refusal"],
      "recovery": "Use written evidence and controller start only after committing to a recovery card. Verify PID1 start/TERM log, non-root UID, read-only root, writable tmpfs, network none, security/limits and cleanup, then transfer without claiming production proof.",
      "cleanupProof": "Runtime pass requires verifier runtime_verification=passed and cleanup_proven=true plus final check state=absent. Blocked runtime requires an honest blocked record and no cleanup claim. Human review separately scores ASM-0054.",
      "path": "book/labs/LES-0023-oci-containers-docker"
    }
  ],
  "incidents": [
    {
      "id": "LES-0023-INC-001",
      "signal": "A container exits 137 with OOMKilled=true under a 512 MiB limit while the host has free memory; its writable layer also grew rapidly and work outcome is unknown.",
      "firstThought": "Treat cgroup memory, host capacity, signal/exit, writable-layer storage and business state as separate owners. Freeze blind restart and preserve the exact container/image/cgroup evidence.",
      "safePath": "Correlate runtime OOM flag with cgroup events and limits, profile allocation/concurrency, inventory layer paths/backing storage, reconcile in-flight work, run a measured digest-pinned canary, and verify user outcomes, duplicates, memory plateau and layer growth.",
      "trap": "Declaring host RAM exhausted from 137, assigning arbitrary memory, enabling restart always, or deleting the container/layer before evidence and work reconciliation."
    },
    {
      "id": "LES-0023-INC-002",
      "signal": "A mutable multi-platform tag deploys different content across architectures; the image has secret-bearing build history and a critical finding, while runtime is privileged with Docker socket/host mounts and duplicate job replay.",
      "firstThought": "Stop rollout/retry, treat host access as security incident scope, preserve the OCI descriptor graph and runtime envelope, and rotate exposed credentials through their owner.",
      "safePath": "Resolve index and platform digests, investigate host/daemon, rebuild from verified pinned materials in a trusted builder, attach/verify SBOM and provenance, enforce admission and least privilege, externalize idempotent job state, and canary both architectures with reconciliation.",
      "trap": "Retagging, trusting a signature or scan as universal proof, restarting everything, or assuming container root/privileged/socket access remains isolated from the host."
    }
  ],
  "assessmentIds": ["ASM-0052", "ASM-0053", "ASM-0054"],
  "referenceIds": ["REF-0137", "REF-0138", "REF-0139", "REF-0140", "REF-0141", "REF-0142", "REF-0143", "REF-0144"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "At the 2026-08-02 authoring verification, Ubuntu 24.04 WSL normal user UID 1000 reached Docker client/server 29.6.2 and the already-cached pinned BusyBox digest resolved to local image ID sha256:b116e155074440ffd9e449559433feb4cd2341eb3554b1da1c638c976e56451d. Bash syntax, ShellCheck, both runtime cases, all observation/refusal gates, answer isolation, no-pull policy, exact cleanup, final absence, and root refusal were exercised; this remains scoped local evidence rather than platform certification.",
    "The lab uses one already-cached pinned BusyBox image and a highly constrained Docker Desktop container. It does not prove OCI registry, multi-platform, build, signing, SBOM, provenance, vulnerability, Kubernetes, production network/storage, or hostile-tenant behavior.",
    "Docker Engine/Desktop, containerd, low-level runtimes, kernels, cgroup versions, storage/network drivers, security modules and orchestrators vary. Inspect exact versions and official primary documentation before production action.",
    "Docker daemon access is powerful. The lab's exact labels, IDs and configuration reduce accidental scope but are not a security boundary against a malicious same-user daemon client or compromised daemon.",
    "Publishing or completing this chapter does not award mastery; reviewed independent evidence, repeated failure practice, security review and production feedback remain required."
  ]
}
---

# OCI containers and Docker: understand the image, process, isolation, and trust boundaries

## What you see and first thought

You see `Exited (137)`, `OOMKilled`, `unhealthy`, `permission denied`, `read-only file system`, `no space left on device`, `exec format error`, a container that ignores TERM, or two nodes running different bytes under the same tag. Do not start with "Docker is broken." Start here:

> A container is an agreement among content, configuration, host-kernel mechanisms, runtime policy, and application behavior. Identify which agreement failed and which owner can prove it.

If a process in a container cannot write `/var/lib/app`, the image may have wrong ownership, the root filesystem may be read-only, a mount may cover the path, the mount may belong to another UID, the filesystem may lack blocks or inodes, or mandatory access control may deny it. `chmod 777` attacks none of those mechanisms safely.

If a container exits 137, it may have received SIGKILL; a cgroup OOM kill is one reason, but an operator or runtime timeout can also send KILL. Correlate runtime `OOMKilled`, cgroup memory events, limits, process/log timing and controller events. Do not infer host-wide RAM exhaustion because a container has a smaller cgroup boundary.

If `service:stable` works on AMD64 and fails on ARM64, the tag may resolve to an OCI index whose platform manifests intentionally differ. The question is not "is the tag the same?" It is "which index, platform manifest, configuration and layer digests did each node select?"

In the first minute, record:

```text
User impact:       jobs, requests, data, tenants, time window
Logical operation: durable work identity independent of restart
Image identity:    reference, index/manifest/config/layer digests, image ID
Container identity:name, 64-hex ID, created/start/finish time
Runtime envelope:  user, command, namespaces, cgroups, limits, mounts,
                   network, capabilities, seccomp, health, restart
Process outcome:   PID tree, signal, exit, OOM, logs
State owners:      image store, writable layer, volume, database, queue
Controller action: desired state, retries, backoff, rollout revision
Next safe evidence:smallest read that distinguishes mechanisms
```

Do not pull, retag, rebuild, restart, delete, prune, enter privileged mode, mount the Docker socket, or change permissions until the target and evidence are protected. Containers are cheap to recreate; production evidence and user state are not.

**Memory sentence:** image names describe desired content, runtimes create host processes, the kernel enforces isolation, and only the business state owner proves the user's work.

## Terms before commands

### Process, container, virtual machine, kernel and system call

A **process** is an executing program with memory, threads, file descriptors, credentials and kernel-managed state. A **system call** asks the kernel to perform work such as opening a file, allocating memory, creating a socket or starting a process.

A **container** is not a special kernel object and not automatically a small computer. It is a runtime-managed group of ordinary Linux processes created with a particular root filesystem, credentials, namespaces, cgroups, mounts, capabilities, security filters and lifecycle metadata.

A **virtual machine (VM)** is given virtual hardware by a hypervisor and normally boots a **guest kernel**. Processes inside the VM call that guest kernel. Containers on one Linux host share its kernel. Under Docker Desktop on Windows, Linux containers usually share the kernel of Docker's managed Linux virtual machine; they do not use the Windows kernel as a Linux kernel.

This distinction affects security and debugging. A container cannot load a different kernel. Kernel vulnerabilities can cross container boundaries. Kernel counters may be host- or cgroup-scoped. A VM can provide a stronger kernel boundary at greater resource and operational cost, but configuration still determines security.

### Namespace

A Linux **namespace** changes what a process can see or which identifiers it uses. Common namespaces include:

- PID: process identifiers and visible process tree;
- mount: filesystem mount table;
- network: interfaces, routes, sockets, ports and firewall context;
- UTS: hostname/domain name;
- IPC: System V IPC and POSIX message queues;
- user: mapping of user/group IDs and capabilities;
- cgroup: view of the cgroup hierarchy;
- time: selected clock offsets on supported systems.

Namespaces isolate views, not all resources. Two processes can be in different PID namespaces but the same network namespace. Host PID and container PID can name the same task differently. A process seen as PID 1 in a container has another PID on the host.

### Cgroup

A **control group (cgroup)** hierarchically accounts for and controls resources for processes. Cgroup v2 exposes controllers such as memory, CPU, PIDs and I/O through a unified hierarchy. A namespace says "what can I see?" A cgroup says "what can I consume and how is it accounted?"

`memory.max` is a byte limit; `memory.current` is current charged usage; `memory.events` is a cumulative counter set including high/max/oom/oom_kill events. `cpu.max` commonly contains quota and period in microseconds or `max`. `pids.max` is the task limit; `pids.current` is current tasks. Read documentation for the running kernel/cgroup version and label counters versus gauges.

### OCI, runtime bundle and lifecycle

The **Open Container Initiative (OCI)** publishes interoperable image, runtime and distribution specifications. An OCI **runtime bundle** is a directory containing a configuration file and root filesystem prepared for a low-level runtime. Runtime lifecycle operations create, start, kill and delete a container according to that configuration.

Docker is a higher-level product/API and daemon. It manages images, networks, volumes, build and container metadata, then delegates lower-level task/runtime work. A common Linux stack includes Docker daemon, containerd, a shim and `runc`, but exact components and processes vary. Diagnose the installed stack rather than reciting one diagram as universal.

### Registry, repository, reference, tag and digest

A **registry** serves image content and metadata through a distribution API. A **repository** is a named collection within a registry. A **reference** can use a tag or digest.

A **tag** such as `platform-api:stable` is a mutable human-friendly name. Registry policy may make tags immutable, but the basic concept does not. A **digest** such as `sha256:...` identifies exact content bytes under an algorithm. Pulling by digest removes tag movement from resolution; it does not prove who built the content or whether it is safe.

### Descriptor

An OCI **descriptor** identifies content with fields including media type, digest and size, plus optional annotations, URLs, platform or artifact relationships. The consumer verifies received bytes against digest and size. A descriptor can point to an index, manifest, configuration, layer or other artifact.

Never say "the digest" without naming which descriptor. An index digest and its AMD64 manifest digest are both correct but identify different bytes.

### Image index, manifest, configuration and layers

An **image index** (or manifest list in related Docker terminology) contains descriptors for manifests, often keyed by operating system, architecture and variant. A runtime resolves the matching platform entry.

An image **manifest** references one configuration descriptor and ordered layer descriptors. The **configuration** contains runtime defaults such as environment, user, entrypoint/command, working directory, labels and rootfs DiffIDs, plus history metadata.

A filesystem **layer** is a content blob representing a changeset. Registry blob digest usually covers the compressed blob. A **DiffID** covers the uncompressed layer content used in rootfs identity. Compression changes can change blob digest without changing the uncompressed DiffID. The runtime applies ordered changesets to build the image root filesystem.

Docker's local **image ID** commonly relates to a configuration digest for the selected image. It is not the same as a mutable tag, multi-platform index digest or container ID.

### Build context, Dockerfile, instruction and cache

A **build context** is the file set a builder can access. Sending a repository root can expose secrets even when not copied into the final stage; use a strict ignore file and dedicated context. A **Dockerfile** declares ordered build instructions. Each instruction contributes configuration, filesystem changes or build graph metadata.

A **build cache** reuses results for inputs the builder considers equivalent. A cache hit proves the cache key matched, not that upstream mutable repositories remain identical or safe. Build secrets must use secret-mount/identity mechanisms and must not appear in `ARG`, `ENV`, commands, layers, history or logs.

### Reproducible build and hermetic build

A **reproducible build** produces byte-identical output from declared equivalent inputs under defined conditions. A **hermetic build** obtains inputs only through declared controlled boundaries. They are related, not identical. Timestamps, file order, package mirrors, generated IDs, architecture and tool versions can create differences.

Pin base images and dependencies according to update policy, verify downloaded content, record builder and materials, normalize nondeterminism where practical, and compare output digests. Pinning forever is not patch management; update deliberately through review.

### Entrypoint, command and PID 1

An image **entrypoint** and **command** define defaults combined by the runtime. In Dockerfile exec form, JSON-array arguments launch the executable without an implicit shell. Shell form runs through a shell, which can become PID 1 and may not forward signals or preserve argument boundaries.

**PID 1** is the first process in a PID namespace. Linux gives it special signal/orphan-child behavior. The container stays running while PID 1 stays. PID 1 should receive and handle/forward termination, reap orphaned children and return a meaningful status. Use the application directly when it does this correctly or a reviewed minimal init when it does not.

### Signal, stop grace, exit status and OOM kill

A **signal** is asynchronous process notification. `SIGTERM` requests termination and can be handled. `SIGKILL` cannot be caught or cleaned up. `docker stop` normally sends the configured stop signal to PID 1, waits a timeout, then escalates if needed.

Shells commonly represent signal termination as 128 plus signal number, so 137 suggests signal 9. It is a clue, not unique proof. Docker's `OOMKilled` field and cgroup events provide stronger scoped evidence for memory OOM. A user or runtime timeout can also send KILL.

### Health, startup, readiness and liveness

A Docker **health check** runs a command and records starting, healthy or unhealthy. Docker Engine does not automatically restart an unhealthy container solely because it is unhealthy; controller policy may act.

Orchestrators distinguish concepts:

- startup: has slow initialization finished enough for other probes?
- readiness: should this instance receive new traffic/work?
- liveness: is restarting the process likely to help?

A health endpoint must have a stated predicate. Process exists, event loop responds, dependency reachable and user transaction succeeds are different tests. A liveness probe that fails during dependency outage can restart every replica and worsen impact.

### Root filesystem, writable layer, OverlayFS and copy-up

An image provides immutable lower changesets. A default container gets a thin writable layer. With Docker's OverlayFS driver, lower directories and an upper directory are presented through a merged mount. On first write to a lower-layer file, **copy-up** creates an upper copy and changes that. Deleting a lower entry records a **whiteout** that hides it in the merged view; it does not alter the image layer.

The writable layer belongs to that container lifecycle. Removing the container normally removes it. It is poor storage for durable databases, queues, audit or uploads. Large writes consume Docker backing-store blocks/inodes and can have copy-up performance costs.

### Bind mount, volume and tmpfs

A **bind mount** exposes a specific host path. Its contents, permissions and security impact come directly from the host; a sensitive bind can collapse isolation.

A Docker **volume** is daemon-managed persistent storage with a lifecycle separate from one container. It still needs ownership, capacity, backup, encryption and restore design.

A **tmpfs** is memory-backed temporary storage mounted into the container; it disappears when unmounted and is charged/accounted according to the platform. Mounting any of these on an image path hides the underlying image content until unmounted.

A **read-only root filesystem** prevents writes to the merged image root while explicit writable mounts support `/tmp`, caches or runtime files. This makes undeclared writes fail early and reduces persistence opportunities, but does not make mounted secrets/volumes or the kernel safe.

### Container network, port and localhost

A network namespace has its own interfaces, routes and sockets. `127.0.0.1` inside a container addresses that namespace, not another container or the host. Bridge networking often connects a virtual Ethernet pair to a host bridge and uses routing/NAT. Other drivers and Kubernetes Container Network Interface (CNI) plugins differ.

A **published port** maps/listens on a host address and forwards toward a container port. Image `EXPOSE` is metadata, not proof a port is published. Binding an application to `127.0.0.1` inside its namespace may prevent traffic arriving on the container interface. Host network mode removes much network-namespace separation and increases collision/blast radius.

### Log stream and logging driver

Processes write stdout/stderr file descriptors. Docker captures them through a **logging driver**. `docker logs` availability depends on driver/config and may not contain every event. Unbounded local JSON logs can fill Docker storage. Production platforms need structured safe logs, rotation/retention, correlation and backpressure policy.

Logs are observations, not business state. A line "job complete" can be emitted before a transaction commits or lost after commit. Verify at the state owner.

### Linux capability, seccomp and no-new-privileges

Traditional root privilege is split into **Linux capabilities** such as network administration or changing file ownership. Drop all and add only justified capabilities. Capability inside a user namespace has different scope, so state the namespace.

**seccomp** filters system calls. Docker's default profile blocks selected high-risk calls; disabling it expands attack surface. **no-new-privileges** prevents `execve` from gaining privilege through set-user-ID/set-group-ID bits or file capabilities. It does not remove privileges already present.

AppArmor or SELinux can apply mandatory policy. A denial may come from discretionary mode/UID, read-only mount, capability, seccomp or mandatory access control. Diagnose the actual enforcement layer.

### Privileged, rootless and Docker socket

`--privileged` broadly expands device and capability access and changes security policy; it can approach host control. Host PID/network namespaces and host-root binds similarly erase boundaries.

The Docker socket/API controls container creation and mounts. A process that can ask the daemon to start a privileged container or bind host `/` can usually gain powerful control over that daemon host. Never mount the socket as a convenience for deployment automation; expose a narrower authorized service.

**Rootless** mode runs daemon/container plumbing without host root and can reduce impact, but has feature/platform limits and does not replace workload least privilege, secure mounts, network policy or kernel patching. **User namespaces** map container IDs to different host IDs; container UID 0 can then map to an unprivileged host ID. Record actual mapping before claiming protection.

### SBOM, vulnerability scan, signature, attestation and provenance

A **software bill of materials (SBOM)** inventories components/files and relationships under a format such as SPDX. It is not a vulnerability list and can be incomplete.

A **vulnerability scan** compares observed components/configuration with advisory and policy data at a time. It can miss unknown vulnerabilities and produce false positives/negatives.

A **signature** authenticates a statement or artifact association when identity/key and verification policy are trusted. An **attestation** is a signed statement about an artifact, such as scan results or build facts. **Provenance** describes where/how an artifact was built, including subject digests, builder, invocation and materials under a schema such as SLSA provenance.

None alone means safe. Policy verifies exact digest, trusted builder/signer, allowed materials, provenance completeness, SBOM/license/vulnerability posture, and deployment context.

## Architecture map

### Container versus VM

```text
CONTAINER PATH
application -> libc/runtime -> system calls
            -> shared Linux kernel
                 namespaces: scoped view/IDs
                 cgroups: accounting/control
                 LSM/seccomp/capabilities: authorization/filter
            -> physical or VM hardware

VM PATH
application -> guest libraries -> system calls
            -> guest kernel
            -> virtual devices
            -> hypervisor/host kernel
            -> physical hardware
```

Docker Desktop inserts a managed Linux VM into the container path on Windows. From inside the Linux container, the shared kernel is that VM's Linux kernel. The Windows host still owns Desktop lifecycle and integration, while the Docker daemon owns container metadata.

### Content to process

```text
registry/repository:tag (mutable lookup)
             |
             v
OCI INDEX digest (optional multi-platform)
  |-- linux/amd64 -> MANIFEST digest A
  `-- linux/arm64 -> MANIFEST digest B
                         |
               +---------+----------+
               |                    |
          CONFIG blob          LAYER blobs, ordered
          user/env/cmd          compressed changesets
          history/DiffIDs              |
               +-----------------------+
                         |
                  local content store
                         |
                  runtime rootfs/config
                         |
                  namespaces + cgroups
                         |
                  PID 1 and children
```

The digest verified during registry transfer is not automatically the same field as Docker image ID. Record the descriptor type and platform. Promotion should move reviewed digests, not rebuild or retag unreviewed bytes.

### Runtime ownership

```text
docker CLI
  | API request over local/remote endpoint
  v
Docker daemon ---- image store / volume / network metadata
  |
  v
container manager -> shim -> low-level OCI runtime
                                  |
                     create namespaces/cgroups/mounts
                     set UID/GID/caps/seccomp/rlimits
                     exec initial process
                                  |
                                  v
                          host Linux kernel tasks
```

The low-level create step can be brief; a shim may remain to own I/O and exit status. Do not kill daemon/containerd/shim processes because a diagram suggested ownership. Use supported runtime APIs and exact container identity.

## Request or state path

### Build and publish path

1. Source and build definition are reviewed at a commit.
2. Builder receives a minimal context and declared platform(s).
3. Base image and remote materials resolve by reviewed digest/checksum.
4. Secrets arrive through ephemeral secret/identity channels and do not enter filesystem changes/history/logs.
5. Build steps create platform configuration and ordered layers.
6. Builder emits manifest(s), optionally an index, SBOM and provenance whose subjects are exact digests.
7. Registry stores blobs/descriptors; signing/attestation system associates verified claims.
8. Policy promotes immutable digest references into environments.

Every arrow is a trust boundary. TLS to a registry protects transport but does not decide whether the publisher is authorized or the artifact meets policy.

### Create and start path

1. Client selects a known Docker context and submits create configuration.
2. Daemon resolves local/pinned image; a pull policy determines whether registry access occurs.
3. Daemon prepares snapshot/rootfs, mounts, network and metadata.
4. Runtime creates namespace/cgroup/security configuration and initial process in created state.
5. Start releases the process to run as PID 1 in its namespace.
6. Logging captures stdout/stderr; health checks execute according to schedule.
7. Controller observes state and may restart/reschedule according to policy.
8. Business owner records whether the user operation completed.

Container `running` begins around step 5. Application `ready` and user success occur later and need separate evidence.

### Stop and remove path

```text
controller intends stop
 -> runtime sends configured stop signal to PID 1
 -> application stops admission, drains/checkpoints, forwards signal
 -> children exit and PID 1 reaps
 -> PID 1 exits with meaningful status inside grace
 -> runtime records exit and releases task resources
 -> container metadata/writable layer remain while stopped
 -> remove deletes container record/writable layer
 -> volumes/images remain unless explicitly and separately owned
```

Forced removal can send KILL and bypass cleanup. Use it only when the target is proven and state/recovery policy allows. The lab uses force only after exact ID/profile checks and stores no business state.

## Failure zoom

### Exit 137 and memory boundaries

```text
host/VM memory may be available
        |
parent cgroup / node policy
        |
container cgroup memory.max = 512 MiB
        |
processes + charged memory approach limit
        |
reclaim cannot satisfy charge
        |
cgroup OOM policy selects/kills task
        |
runtime: OOMKilled=true, exit often 137
```

Strong evidence includes exact container ID, cgroup path, `memory.max`, current/peak, `memory.events` delta with timestamps, runtime OOM flag and kernel/runtime events. Root cause still requires allocation/concurrency/input analysis. Raising the limit changes policy; it does not explain growth.

### PID 1 wrapper failure

Bad shell form:

```Dockerfile
ENTRYPOINT /app/server --port 8080
```

A shell becomes PID 1 and starts the server as a child. Depending on shell/script, TERM may stop the shell without reaching the server, or the shell waits incorrectly. After grace the runtime kills remaining processes.

Better direct form when the server handles PID 1 correctly:

```Dockerfile
ENTRYPOINT ["/app/server"]
CMD ["--port", "8080"]
```

This preserves argument boundaries and direct signal delivery. It still requires the server to handle TERM and reap children. Otherwise use a reviewed init or explicit wrapper that traps, forwards, waits and returns status.

### Copy-up and hidden mounts

```text
image has /var/lib/app/default.db
container mounts volume on /var/lib/app
result: image default.db is hidden by volume contents
```

The file was not deleted. The mount covers it. Similarly, changing a large lower-layer file may copy the whole file into upper storage before modification. Container diff reflects upper changes but not writes inside a volume/tmpfs. Inspect mount table and the correct storage owner.

### Same tag, different platform content

```text
stable -> index digest I
          |-- amd64 manifest A -> config/layers for amd64
          `-- arm64 manifest B -> config/layers for arm64
```

Different A/B is normal for multi-platform content; divergent behavior must be tested. A mutable tag can also move from index I to J during rollout, so nodes pulling at different times get different graphs. Record requested reference, resolved index and selected manifest digest per node.

### Health/restart loop

A shallow probe fails during a shared database outage. An orchestrator restarts every pod. Restart discards in-memory queues, increases connections, replays jobs and delays recovery. The database was the failing owner; restarts amplified it.

Liveness should answer "is this process irrecoverably stuck such that restart helps?" Readiness can remove traffic during dependency or drain states. Business progress needs a separate SLI such as oldest job age.

## Internals and state ownership

### Identifier map

| Identifier | Owner | Meaning | Persistence |
|---|---|---|---|
| tag | registry namespace | mutable name to descriptor | until moved/deleted by policy |
| index digest | content store/registry | exact index bytes | while retained/reachable |
| manifest digest | content store/registry | exact platform manifest bytes | while retained/reachable |
| config digest / image ID | image content/local daemon | exact configuration bytes/selected image identity | image lifecycle |
| layer blob digest | content store | exact compressed blob | image/content lifecycle |
| DiffID | image config/rootfs model | uncompressed changeset digest | image config lifecycle |
| container ID/name | daemon | one created container record | until removal; name may be reused |
| namespace PID | kernel namespace | process ID in that PID view | process lifetime |
| host PID | host kernel | same/different task identity in host view | process lifetime; reusable |
| cgroup path/ID | kernel/runtime | resource accounting/control group | task/container/runtime lifecycle |
| logical job ID | business state owner | one user intent across retries/restarts | business retention policy |

Never use container name alone for cleanup. Names can be reused. Combine state descriptor, exact ID, random instance label, image identity and full envelope. Never use PID alone after delay; PIDs are reused.

### Layer application and whiteouts

Layer order matters. Later changes override earlier paths in the merged result. OCI layer archives encode deletions with whiteout entries and opaque directories with special markers. Tools should apply these semantics safely rather than extracting arbitrary layer tars over a host path.

The manifest references compressed distribution blobs; config rootfs DiffIDs correspond to uncompressed content. Chain identity depends on order. A scanner that unpacks the final filesystem may miss deleted-but-secret historical layer content; secrets committed then removed can remain in earlier blobs and caches.

### Overlay performance and accounting

Copy-up adds latency for first writes to lower files. Many small files stress metadata/inodes. Database workloads can suffer from layered-filesystem semantics and fsync behavior. The container writable layer and named volume may live on the same Docker backing disk even though `df` inside shows different mounts.

Capacity evidence must include:

- `df -hT` and `df -i` at the exact relevant mount;
- daemon storage driver and backing filesystem;
- per-container writable size and image/shared size semantics;
- volume size and owner;
- log-driver file usage/rotation;
- Docker Desktop VM disk allocation/reclamation behavior.

Do not delete overlay directories under Docker's data root manually. The daemon owns their reference graph.

### Cgroup memory and OOM

Memory accounting can include anonymous memory, file cache and kernel categories depending on version. `docker stats` memory percentage is a formatted metric whose exact cache treatment/platform behavior should be verified. One process RSS is not the cgroup total. `memory.events` counters are cumulative; record before/after or timestamps.

A memory request in Kubernetes informs scheduling; a limit enforces a maximum. Quality-of-service and eviction behavior depend on requests/limits and node pressure. Container OOM, pod eviction and node OOM are different mechanisms.

### CPU quota and throttling

A CPU quota limits execution over a period. `0.25` CPU roughly represents a quarter of one core's scheduling time over periods, not a dedicated quarter-core. `cpu.stat` provides cumulative usage and throttle counters/time. A high throttle count alone needs interval and workload demand; latency may arise from run queue, I/O or locks.

### PID exhaustion

The PIDs cgroup limits tasks, often including threads. A process/thread leak or fork storm can reach `pids.max`; new process/thread creation fails even when memory and host PID space remain. Observe `pids.current`, events where available and the scoped process tree. A limit protects the host but should be sized for legitimate peak plus margin.

### Security boundary stack

```text
artifact policy: trusted digest/provenance/SBOM/scan
runtime identity: non-root UID/GID, user namespace/rootless where supported
privilege:        drop capabilities, no-new-privileges
syscalls:         default/reviewed seccomp
mandatory policy:AppArmor/SELinux where enforced
filesystem:       read-only root, minimal mounts, safe ownership
devices:          none unless explicitly required
network:          least reachability and authenticated services
resources:        memory/CPU/PID/storage bounds
host/daemon:      patched kernel/runtime; protected Docker API
application:      validation, authz, secret handling, idempotency
```

Defense in depth matters because each layer has limits. Non-root inside a container does not make a host-root bind safe. Seccomp does not authorize application data. A signed vulnerable image remains vulnerable.

### Durable state and replacement

Containers are disposable compute identities. Business state belongs to a database, durable queue, object store or explicitly managed volume according to product requirements. A volume gives persistence, not transactionality, backup, replication or correctness.

For job workers, persist stable job ID, claim/lease with fencing, attempt state, receipt and authoritative effect. On restart, reconcile committed/unknown work before retry. Restart policy and Kubernetes controllers create new attempts; they must not create new logical operations.

## Evidence table

A senior responder does not collect a pile of commands and call it a diagnosis. Each observation must carry five labels: **target**, **time**, **source**, **claim**, and **limit**. The same word, such as `memory`, can describe host availability, a cgroup maximum, one process RSS, an application heap, or a dashboard calculation. Without the owner and unit, it is not yet usable evidence.

Use this table as a practical translation layer:

| Observation | Most direct owner | What it supports | What it cannot establish alone |
|---|---|---|---|
| `uname -a` in WSL | current Linux kernel view | kernel release/architecture visible to that shell | physical host identity, container membership, patch safety |
| `/proc/self/ns/pid -> pid:[N]` | kernel namespace object | namespace identity for that process at that instant | isolation quality or another process's namespace |
| Docker context and server version | Docker client/daemon boundary | which named endpoint replied and its reported version | that endpoint is safe, local, authorized, or intended |
| tag `stable` | registry naming namespace | requested human reference | immutable content or what every node already runs |
| `sha256:...` descriptor digest | OCI content graph | exact bytes for that descriptor kind | signer, source, vulnerability state, platform selection unless descriptor is typed |
| image ID/config digest | local image metadata | selected image configuration identity | multi-platform index identity or runtime container configuration |
| container ID | Docker daemon | one created container record | logical job identity, future name ownership, or process lifetime |
| `State.OOMKilled=true` | runtime state for one container | runtime recorded an OOM kill for that instance | allocation root cause or correct future limit |
| exit status 137 | process/runtime convention | commonly `128 + SIGKILL(9)` | OOM by itself; an application/wrapper can produce 137 |
| `memory.max=67108864` | cgroup v2 | enforced byte ceiling for that cgroup hierarchy | working-set demand, node headroom, or whether the limit is appropriate |
| `memory.events: oom_kill` delta | kernel cgroup accounting | scoped OOM-kill event occurred in interval | guilty allocation path or user-operation correctness |
| `cpu.max=25000 100000` | cgroup v2 | 25,000 microseconds quota per 100,000 microsecond period | dedicated core, observed utilization, or latency cause |
| `pids.max=64` | PIDs cgroup | maximum charged tasks for the scope | current tasks, host PID availability, or safe peak |
| `docker stats` one sample | daemon/cgroup formatter | sampled usage/rates for the target | peak, trend, saturation cause, or identical semantics across platforms |
| `ReadonlyRootfs=true` | runtime mount configuration | rootfs was requested read-only | all mounts read-only, no tmpfs/volume writes, or kernel exploit resistance |
| empty `docker diff` | daemon storage-driver view | no currently reported rootfs changes | no write ever occurred; mounted paths are outside this diff |
| `/work` tmpfs is writable | runtime mount | bounded memory-backed work path can change | durability, backup, transactionality, or zero memory impact |
| `NetworkMode=none` | Docker container config | no Docker network attachment for that container | daemon/host offline status or no Unix-socket communication if mounted |
| process state `running` | runtime | container PID 1 exists now | readiness, correctness, queue progress, or user success |
| health `healthy` | configured probe | probe predicate passed recently | service usefulness, dependency correctness, or SLO compliance |
| `event=signal signal=TERM pid=1` | workload stdout | PID 1 code emitted that event | durable checkpoint, every child stopped, or actual signal source without correlation |
| SBOM contains package P | SBOM producer | producer claims P is in described artifact/relationship | completeness, runtime reachability, known-safe status |
| scanner flags CVE C | scanner database/rules | artifact matched available intelligence/policy at scan time | exploitation, reachability, or absence of other vulnerabilities |
| verified signature/attestation | verifier/trust policy | trusted identity signed a claim bound to a subject | claim truth beyond policy, application correctness, or vulnerability absence |
| provenance lists builder/materials | attestation producer | claimed build process and inputs tied to subject digest | builder itself uncompromised unless the trust system establishes it |
| restarted container is healthy | controller/runtime/probe | a new attempt is alive and passes the probe | old work reconciled, no duplicate, or incident resolved |
| final user receipt and duplicate query | business state owner | the original operation reached declared terminal state | broad infrastructure health beyond the checked population/window |

### From observation to conclusion

Suppose you see:

```text
host_available_bytes = 19327352832
container_memory_max  = 536870912
container_oom_kill_delta = 1
container_oom_killed  = true
container_exit_code   = 137
```

A sound statement is: "The target container's memory cgroup recorded an OOM kill under a 512 MiB limit during the incident window; the runtime reports that instance as OOM-killed and its signal-derived exit is consistent with SIGKILL. Host-wide available memory was a different boundary. The allocation cause and correct limit remain unknown."

A weak statement is: "Docker randomly killed it even though memory was free." It silently changes the owner of `free` from host to cgroup and turns mechanism evidence into a root cause.

### Calculations must show units

```text
536,870,912 bytes / 1,048,576 bytes per MiB = 512 MiB
25,000 microseconds / 100,000 microseconds = 0.25 CPU quota ratio
3 GiB writable growth / 30 minutes = 0.1 GiB/min average growth
```

Averages hide bursts. A CPU quota ratio is not a utilization sample. A GiB is 1,073,741,824 bytes while a GB is 1,000,000,000 bytes. Preserve the source unit and conversion.

### Evidence timeline template

| UTC time | Type | Target identity | Raw fact | Interpretation | Does not prove | Next discriminator |
|---|---|---|---|---|---|---|
| T0 | observation | container ID + image ID | exact inspect fields | lifecycle state | application outcome | query durable operation state |
| T1 | calculation | same cgroup | counter delta | event in window | allocation owner | profile processes/heap/workload |
| T2 | hypothesis | code revision + input cohort | predicted growth | testable candidate | truth | bounded reproduction |
| T3 | action | exact deployment/container | admission capped | containment applied | recovery | watch guardrails |
| T4 | verification | logical operation IDs | terminal receipts | user result restored | global safety | expand cohort cautiously |

Label documented contracts separately from observations. `--memory 64m` is desired/configured policy; `memory.max` is kernel-visible configuration; `memory.current` is sampled accounting; a stable service under representative load is behavioral evidence. Those are four different claims.

## Command decoders

Read every command as a question, not a ritual. Before pressing Enter, say the target, expected output branches, risk, and what you will do next. Never paste production output containing tokens, environment secrets, registry credentials, mount paths, or customer data into a public record.

### Decoder 1: locate the current Linux boundary

```bash
uname -a
printf 'self_pid_namespace='; readlink /proc/self/ns/pid
printf 'self_mount_namespace='; readlink /proc/self/ns/mnt
printf 'self_network_namespace='; readlink /proc/self/ns/net
printf 'cgroup='; cat /proc/self/cgroup
```

- `uname -a` asks the running kernel for its reported system, release, version, machine and related fields. In Docker Desktop with WSL, this is a Linux kernel supplied through the virtualization stack, not the Windows NT kernel.
- `/proc/self` means the process executing `readlink`. `/proc/self/ns/pid` is a symbolic link representing its PID namespace. The bracketed value is a kernel namespace-object identity, not a PID count.
- `mnt` and `net` similarly identify mount and network namespace views. Equal identifiers suggest two processes share that namespace object at that moment; different identifiers prove different objects, not how safe either is.
- `/proc/self/cgroup` maps this process to controller hierarchy paths. On unified cgroup v2, a line often begins `0::`. It does not itself print every effective inherited limit.

Run it from the shell whose boundary matters. A result from Windows PowerShell, WSL Ubuntu, a container exec session and a Kubernetes pod can legitimately differ.

### Decoder 2: identify the Docker control plane before touching it

```bash
docker context show
docker version --format 'client={{.Client.Version}} server={{.Server.Version}} api={{.Server.APIVersion}} os={{.Server.Os}} arch={{.Server.Arch}}'
docker info --format 'name={{.Name}} driver={{.Driver}} cgroup={{.CgroupVersion}} security={{json .SecurityOptions}}'
```

`docker` is a client. The context chooses an endpoint and credentials. The client can be local while the daemon is remote, so a familiar prompt proves nothing about target location. `docker version` contains client facts even when the daemon is unavailable; require server fields before claiming runtime access. Go-template expressions inside `{{...}}` select structured response fields. Quoting prevents the shell from interpreting braces and spaces.

Stop if the context is unexpected. Do not switch contexts during an incident merely to make a command work. Record the endpoint name without publishing credentials. The Docker API is powerful: a principal able to ask the daemon for privileged containers and host mounts can often control the daemon host or Docker Desktop VM.

### Decoder 3: inspect the exact cached content without pulling

```bash
IMAGE_REF='busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662'
docker image inspect --format 'id={{.Id}} repo_digests={{json .RepoDigests}} os={{.Os}} arch={{.Architecture}} layers={{len .RootFS.Layers}} user={{if index .Config "User"}}{{index .Config "User"}}{{else}}unspecified{{end}}' "$IMAGE_REF"
```

The shell variable removes repetition; single quotes preserve the literal reference. `image inspect` is local lookup. If the content is missing it fails rather than pulling. `RepoDigests` are repository-qualified digest references known locally; `.Id` commonly corresponds to the image configuration digest in Docker's model. `.RootFS.Layers` are uncompressed DiffIDs, not necessarily the registry's compressed blob digests.

`user=unspecified` means the image configuration did not select a non-root user. It does not mean every runtime will execute as root because a deployment can override the user. Conversely, an image-declared non-root user does not prove the runtime did not override it.

### Decoder 4: use history as a clue, never as provenance

```bash
docker image history --no-trunc --format 'created={{.CreatedAt}} size={{.Size}} created_by={{.CreatedBy}} comment={{.Comment}}' "$IMAGE_REF"
```

`--no-trunc` avoids hiding command metadata. History may reveal how layers were declared and where size entered. It may also reveal secret-bearing build arguments or commands, so treat output as sensitive. A zero-sized history entry can be metadata-only. A size value may represent layer contribution, not total unique registry transfer or runtime disk use.

History is not a trustworthy build transcript. It does not prove source revision, builder identity, dependency checks, secret safety or reproducibility. Use signed/verifiable provenance plus builder audit for those claims.

### Decoder 5: inspect the runtime envelope as one object

```bash
LAB_CONTAINER="reliability-atlas-les0023-u$(id -u)"
docker container inspect --format 'id={{.Id}} image={{.Image}} user={{.Config.User}} state={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} network={{.HostConfig.NetworkMode}} readonly={{.HostConfig.ReadonlyRootfs}} privileged={{.HostConfig.Privileged}} caps={{json .HostConfig.CapDrop}} security={{json .HostConfig.SecurityOpt}} memory={{.HostConfig.Memory}} cpus={{.HostConfig.NanoCpus}} pids={{.HostConfig.PidsLimit}}' "$LAB_CONTAINER"
```

`$(id -u)` is command substitution performed by the shell to derive this normal user's deterministic lab name. In production automation, a name is not sufficient ownership. The controller also validates exact container ID, local image ID, requested digest, random instance label, owner UID label, mounts, namespaces, security and resource fields.

Important units:

- `Memory` is bytes; `67108864` is 64 MiB.
- `NanoCpus` expresses CPUs multiplied by 1,000,000,000; `250000000` represents 0.25 CPU.
- `PidsLimit` is a task count.
- `ReadonlyRootfs` covers the root filesystem mount, not separate writable mounts.
- `CapDrop=["ALL"]` removes the bounding set Docker would otherwise grant; only explicitly justified additions should follow.

Inspect is a snapshot. Between inspection and action, identity or state can change. Production controllers need precondition checks at mutation time, not a screenshot from five minutes earlier.

### Decoder 6: map PID 1 and children

```bash
docker top "$LAB_CONTAINER" -eo pid,ppid,user,comm,args
```

`top` here is a Docker subcommand, not the interactive Linux `top`. `-eo` passes a process-format request supported by the daemon/platform. Host-visible PIDs may appear. Inside the PID namespace the same initial process sees itself as PID 1. `PPID`, user, command name and arguments reveal wrappers and children.

Arguments can contain secrets; use a safer approved field set in production. One sample can miss short-lived zombies or forks. Correlate with namespace-aware process inspection and runtime events. If PID 1 is `/bin/sh -c app`, ask whether it replaces itself with `exec`, forwards TERM, and reaps orphaned children. The lab's shell deliberately installs TERM/INT traps and waits on one child at a time.

### Decoder 7: separate rootfs changes from mounted state

```bash
docker diff "$LAB_CONTAINER"
docker container inspect --format 'driver={{.GraphDriver.Name}} readonly={{.HostConfig.ReadonlyRootfs}} tmpfs={{json .HostConfig.Tmpfs}} binds={{json .HostConfig.Binds}} mounts={{json .Mounts}}' "$LAB_CONTAINER"
```

`docker diff` reports added, changed and deleted paths in the container writable layer as seen by the storage driver. It does not inventory changes inside a volume, bind mount or tmpfs. Inspect therefore accompanies it. In the lab, `/run` and `/work` are tmpfs and the rootfs is read-only; changing `/run/ready` should not become an image-layer diff.

A mount at `/var/lib/app` hides image content already present at that merged path. If an expected file disappears after mounting, inspect the mount source and path before concluding the image is broken. Never browse or delete Docker's backing directories manually; storage-driver metadata is daemon-owned.

### Decoder 8: read cgroup policy from the workload boundary

```bash
docker container exec "$LAB_CONTAINER" sh -c '
for f in memory.max memory.current memory.events cpu.max cpu.stat pids.max pids.current; do
  if [ -r /sys/fs/cgroup/$f ]; then
    printf "--- %s ---\n" "$f"
    cat "/sys/fs/cgroup/$f"
  fi
done'
```

`docker exec` creates a short-lived process in the existing container namespaces/cgroup; it is read-only in intent but still mutates the process timeline and can fail near a PID limit. The outer shell expands `$LAB_CONTAINER`; the single-quoted script is passed literally to the container shell, where `$f` expands.

On cgroup v2:

- `memory.max` is a byte maximum or `max`.
- `memory.current` is current charged memory, sampled.
- `memory.events` contains cumulative counters such as `high`, `max`, `oom`, and `oom_kill`; compute deltas over a known interval.
- `cpu.max` is `quota period` in microseconds, or `max period`.
- `cpu.stat` contains cumulative usage and throttle data; field availability varies.
- `pids.max` is a count or `max`; `pids.current` is the present charged task count.

If files differ, first identify cgroup version and mount layout. Do not force a cgroup-v2 interpretation onto v1 output.

### Decoder 9: prove the network configuration you actually have

```bash
docker container inspect --format 'mode={{.HostConfig.NetworkMode}} port_bindings={{json .HostConfig.PortBindings}} publish_all={{.HostConfig.PublishAllPorts}} networks={{json .NetworkSettings.Networks}}' "$LAB_CONTAINER"
```

`NetworkMode=none`, empty port bindings and no attached Docker networks are the lab contract. This means the container receives only the isolated loopback-style namespace arrangement Docker provides for `none`; no bridge service path or published port is created. It does not switch off network access for Docker Desktop, the daemon, Windows, WSL or other containers.

For a normal service, ask four separate questions: where does the process bind, what route/DNS exists in its namespace, what service/backend selection exists, and what host/load-balancer publication exists. `127.0.0.1` inside one container is that network namespace, not its sibling or host.

### Decoder 10: correlate state, OOM, restart, health and logs

```bash
docker container inspect --format 'state={{.State.Status}} running={{.State.Running}} exit={{.State.ExitCode}} oom={{.State.OOMKilled}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} restarts={{.RestartCount}}' "$LAB_CONTAINER"
docker container logs --tail 20 "$LAB_CONTAINER"
```

Read these fields together:

- `running=true` says the current PID 1 exists.
- `health=unhealthy` says recent configured probes failed; Docker does not automatically restart an unhealthy container merely because it has a health check.
- `exit` is meaningful after termination and must be interpreted with signal/OOM/runtime evidence.
- `OOMKilled` is scoped runtime evidence, stronger than guessing from 137 alone.
- `RestartCount` helps detect controller amplification but not orchestrator-created replacement containers.
- logs are application stdout/stderr captured by the configured driver. `--tail 20` bounds output, not sensitivity.

In the guided lab, removal of `/run/ready` makes health fail while PID 1 remains. That is intentional proof that lifecycle state and probe state differ. It does not model production recovery policy.

### Decoder 11: treat stats as a sample, not capacity truth

```bash
docker stats --no-stream --format 'name={{.Name}} cpu={{.CPUPerc}} memory={{.MemUsage}} memory_percent={{.MemPerc}} pids={{.PIDs}} block_io={{.BlockIO}} network_io={{.NetIO}}' "$LAB_CONTAINER"
```

`--no-stream` produces one bounded sample. CPU percentage is derived over an interval; memory formatting and cache subtraction can vary with daemon/platform versions; block/network fields are cumulative-style I/O totals rendered for humans. A quiet sample after an incident cannot rule out a burst. Use time series, exact cgroup counters, application profiles and saturation indicators.

A limit is policy. Current usage is state. Peak is history over a defined reset/lifetime. A rate is change divided by time. Keep them separate in dashboards and explanations.

### Decoder 12: let the guarded controller decide readiness

```bash
bash lab.sh check
```

This command checks normal-user identity, required local commands, safe `/tmp` properties, Docker daemon access, exact cached digest, absence/validity of the lab's own artifacts, and absence of an unregistered same-name container. It never installs, starts Docker, changes WSL integration or pulls.

A blocked result is successful safety behavior, not a failed learning attempt. `docker-daemon-unavailable` means runtime claims are unavailable. `pinned-busybox-image-not-cached` means the offline artifact gate held. Record the exact reason and continue with static architecture reasoning; do not weaken the guard.

## Decision path

When a container alert arrives, resist the urge to begin with `restart`. Start with the user operation and work inward.

```text
USER IMPACT OR ALERT
        |
        v
Identify service + operation IDs + time window
        |
        +-- no user impact known --> define SLI and verify; do not assume green
        |
        v
Identify orchestrator/daemon + container ID + image/index/manifest digest
        |
        +-- identity uncertain --> preserve, stop mutation, resolve ownership
        |
        v
Classify current lifecycle
  running | unhealthy | exited | restarting | missing | pending
        |
        +-- running --> request path + saturation + progress + dependencies
        +-- unhealthy --> decode probe; compare PID/work/user outcome
        +-- exited --> exit/signal/OOM/runtime events + prior logs
        +-- restarting --> pause amplification if safe; inspect previous attempt
        +-- missing --> controller/audit/scheduler/node timeline
        |
        v
Locate constrained resource/state owner
 process -> cgroup -> container layer/mount -> daemon/node -> dependency
        |
        v
Write competing hypotheses and one disconfirming check each
        |
        v
Contain smallest blast radius; preserve evidence and business identity
        |
        v
Reconcile durable outcome BEFORE retry/restart when effects may be unknown
        |
        v
Recover bounded cohort by exact immutable artifact and config
        |
        v
Verify user outcome + mechanism + capacity + security + no duplicate
        |
        v
Expand slowly or abort/compensate; record prevention owner/deadline
```

### Branch: running but failing requests

1. Verify request route and exact backend container/pod.
2. Compare readiness, liveness and actual user journey.
3. Check listener bind address, DNS, route, service endpoints, policy and load-balancer decision.
4. Check cgroup saturation, process/thread pool, queues and dependencies.
5. Inspect recent deploy/config/secret/certificate changes by immutable identity.
6. Shed or reroute load only under an explicit capacity/error budget plan.

A running process can deadlock, return corrupt data, serve only a shallow health path, or be disconnected from traffic.

### Branch: exited 137

1. Preserve container ID/state, cgroup events, node events and timestamps.
2. Decode `137` as a SIGKILL clue, not an OOM verdict.
3. Check `OOMKilled` and cgroup OOM event delta. Distinguish container, parent cgroup and node OOM.
4. Inspect workload memory growth, input size, concurrency, children and code revision.
5. Reconcile in-flight work; SIGKILL bypasses graceful cleanup.
6. Change code/concurrency/backpressure and choose a measured limit with node headroom.

### Branch: writable layer full

1. Identify the exact mount that returned `ENOSPC`; check blocks and inodes there.
2. Separate container upper layer, volume, bind, tmpfs, log-driver storage and Docker Desktop backing disk.
3. Attribute paths and lifecycle before deletion. A deleted-open file may still consume blocks.
4. Move durable state to its proper owner; bound caches/temp/logs.
5. Recover storage through owner-aware rotation/cleanup, not manual overlay deletion.
6. Verify application writes and Docker backing capacity/inodes after recovery.

### Branch: architecture-only failure

1. Record node `os/architecture/variant` and requested reference.
2. Record index digest and selected platform manifest/config/layers.
3. Compare binaries, packages, entrypoint, build arguments and tests across platforms.
4. Stop mutable-tag rollout; pin reviewed descriptor identity.
5. Build in a declared matrix, test natively/emulated as policy permits, attach per-subject provenance/SBOM.
6. Canary each architecture and verify equivalent user behavior, not merely successful process start.

### Mutation card

Before any stop, remove, rollout, policy or limit change, write:

```text
actor/authorization:
exact daemon/cluster/namespace/workload/container:
immutable image identity:
logical operations at risk:
current evidence preserved:
single change:
blast radius and timeout:
abort thresholds:
rollback or business compensation:
end-to-end success proof:
```

If any field is unknown, gather evidence or escalate ownership. Speed comes from eliminating unsafe ambiguity, not from typing faster.

## Guided Ubuntu lab

The lab lives at `book/labs/LES-0023-oci-containers-docker`. It is intentionally small: one existing cached artifact, one non-root process tree, one health marker and a controller that owns exact state. The point is to see boundaries, not to build an application stack.

### Safety contract before execution

Run from Ubuntu 24.04 or WSL Ubuntu as a normal user. Docker Desktop Linux containers and WSL integration must already work, and the pinned digest must already be cached. The controller refuses root with exit 77. It does not pull, build, install, expose ports, attach a network, mount a host directory/socket/device, use privileged mode, or reconfigure the machine.

It may create only:

```text
Docker object:
  reliability-atlas-les0023-u<effective-uid>

Local records:
  /tmp/reliability-atlas-LES-0023-<uid>.state
  /tmp/reliability-atlas-LES-0023-<uid>.case
  /tmp/reliability-atlas-LES-0023-<uid>.recovery
  /tmp/reliability-atlas-LES-0023-<uid>.verification
```

The state file records exact container ID, image ID/reference, random instance token and owner. Cleanup validates them again. Never manually delete those records, because that discards the controller's proof of ownership. Never use a prune command for this lesson.

### Step 1: preflight without fixing the environment

```bash
cd book/labs/LES-0023-oci-containers-docker
bash lab.sh check
```

Ready output includes `runtime=ready`, `state=absent`, `image_cached=true`, and `network=none`. If the daemon or digest gate is blocked, record it and stop runtime work. Do not sign in or pull to turn an independent assessment into a different experiment.

Prediction: explain why a cached digest check is different from a registry trust check. The former proves local lookup. The latter would require registry identity, descriptor graph, policy, signatures/attestations and audit not exercised here.

### Step 2: create one constrained container

```bash
bash lab.sh setup
bash lab.sh status
```

Setup uses the exact digest with `--pull=never`. It configures:

- `65534:65534`, not root;
- read-only rootfs;
- `/run` 1 MiB and `/work` 4 MiB tmpfs with `nosuid,nodev,noexec`;
- network `none` and zero published ports;
- all capabilities dropped and `no-new-privileges`;
- 64 MiB memory with equal memory+swap ceiling, 0.25 CPU and 64 PIDs;
- restart policy `no`;
- a three-second stop timeout;
- a BusyBox shell as PID 1 with TERM/INT traps and child `sleep` loop;
- a health command that checks `/run/ready`.

Ask what each setting limits and what it does not. For example, `--network none` limits this container's Docker network attachment; it does not make the host offline. `--read-only` protects the rootfs mount; it does not prevent writes to `/run` or `/work`. A 64 MiB cgroup limit protects capacity; it does not prove the process needs that amount.

### Step 3: observe the owners separately

```bash
bash lab.sh observe image
bash lab.sh observe runtime
bash lab.sh observe filesystem
bash lab.sh observe limits
bash lab.sh observe process
bash lab.sh observe network
bash lab.sh observe health
bash lab.sh observe logs
```

Do not skim. Build this table in your notes:

| View | Owner | One fact | One proof limit |
|---|---|---|---|
| image | local daemon content store | exact image ID/platform/layer count | not registry provenance |
| runtime | container record | state/command/security fields | not business correctness |
| filesystem | storage driver + mounts | rootfs read-only, tmpfs separate | not durability |
| limits | HostConfig + cgroup | configured limits | not usage or correct sizing |
| process | kernel/runtime | host-visible tree; namespace PID 1 | not process history |
| network | network namespace/config | no network/ports | not host offline |
| health | Docker probe state | marker predicate passes | not useful work |
| logs | log driver/stdout | start event | not durable transaction receipt |

Sketch the path from Docker CLI to daemon to OCI runtime to kernel process. Then sketch the image descriptor graph. They are different paths: one describes artifact content; the other creates/runs state.

### Step 4: create a running-but-unhealthy condition

```bash
bash lab.sh inject guided
bash lab.sh status
bash lab.sh observe health
bash lab.sh observe process
bash lab.sh observe logs
```

The inject command removes only `/run/ready`. The PID 1 loop remains. The health command eventually fails. This is the memorable model:

```text
PID exists       -> running
probe predicate  -> healthy/unhealthy
traffic decision -> ready/not ready (orchestrator-specific)
business result  -> useful/correct
```

No arrow makes these equivalent. A health check can inform automation, but restart policy `no` means Docker records unhealthy without restarting. In Kubernetes, readiness and liveness probes drive different controller actions; a badly designed liveness probe can turn dependency slowness into restart amplification.

### Step 5: write the recovery card before recovery

Your bounded action is not "restart Docker." It is "restore one marker in one validated tmpfs path for one exactly owned container." Record exact container ID/name/digest, expected running state, timeout, abort on ownership mismatch, and success as both health restored and process identity understood.

```bash
bash lab.sh recover
bash lab.sh verify-operation
```

`verify-operation` checks the intended security/resource envelope, rootfs write refusal, one exact tmpfs write/remove, network none, healthy state and expected start log. It does not certify the image, daemon, kernel or production design.

### Step 6: exact cleanup and final absence

```bash
bash lab.sh cleanup
bash lab.sh check
```

Cleanup revalidates ownership before forced removal. Here `--force` is bounded to one lab-owned ID with no durable business work. In production, forced removal can destroy last logs/state and interrupt unknown effects, so preserve and reconcile first.

After cleanup, `state=absent` and container absence are evidence about the lab's exact resources. They do not prove Docker has no other containers or that host storage was reclaimed immediately.

### Safe exercise 2: static verification and blocked runtime

```bash
bash verify.sh
```

The verifier first checks Bash syntax and safety invariants. If runtime prerequisites are unavailable, expected output is:

```text
static_verification=passed
runtime_verification=blocked
reason=docker-daemon-unavailable
network_pull_attempted=false
cleanup_proven=not-exercised
```

or the reason states the pinned image is not cached. This is an honest three-valued result:

- **passed**: a defined check ran and met its predicate;
- **failed**: a defined check ran and violated its predicate;
- **blocked**: prerequisites prevented the runtime check, so no runtime claim exists.

Do not convert blocked into passed. Do not call it failed and encourage unsafe bypass. Good reliability systems model unknown/blocked explicitly.

When runtime is available, the verifier exercises both guided and independent state transitions, wrong transitions, state tamper/symlink/foreign-container refusal, answer isolation, cleanup idempotency and final absence. Even then, scope remains this local guarded envelope.

### Independent lab boundary

The independent exercise and blank response template are in the same lab directory, but its answer is intentionally absent. Capture `scenario` before any derived observation, write three competing hypotheses with predicted/disconfirming evidence, then investigate. Do not read another learner's response or alter the controller. A reviewer evaluates the transfer.

## Production transfer

A local Docker container is a learning microscope. Production adds registries, schedulers, many nodes, multiple architectures, policy engines, secret systems, persistent state, load balancers, tenants and humans. Transfer the reasoning, not the exact command.

### Immutable promotion chain

```text
source revision + reviewed dependency lock
              |
              v
trusted isolated builder -- verified materials/secrets by mount or identity
              |
              v
platform manifests (amd64, arm64, ...)
              |
              v
OCI index digest + per-platform manifest/config/layer digests
              |
              +--> SBOM subjects
              +--> provenance subjects/materials/builder
              +--> signatures/attestations
              |
              v
registry policy/admission verifies exact digest
              |
              v
canary deployment records selected platform manifest per node
              |
              v
user journey + security + capacity verification
```

Promote an immutable digest through environments. A tag may remain a friendly pointer, but release evidence records the resolved index and selected manifest. Enforce policy at admission and again where useful; merely generating an SBOM or signature in CI does not make deployment consume it.

### Dockerfile and build design

Use these principles rather than copying a magic Dockerfile:

1. Pin base materials by reviewed digest and define the update mechanism. Permanent pinning without updates creates stale risk; mutable tags create non-reproducibility.
2. Keep build context small with `.dockerignore`; context content affects cache, confidentiality and transfer time.
3. Use multi-stage builds so compilers and caches do not enter the runtime image unless required.
4. Verify downloaded bytes by trusted digest/signature and TLS identity; avoid `curl | sh`.
5. Use BuildKit secret/SSH mounts or workload identity. `ARG` and `ENV` are not secret stores; build history/cache can retain values.
6. Lock dependencies and repository snapshots according to ecosystem. Clear package caches in the same layer that created them when appropriate.
7. Use a numeric non-root UID/GID whose file ownership is designed, not accidental.
8. Prefer exec-form `ENTRYPOINT`/`CMD` so the application receives signals directly; use a reviewed init when child reaping/forwarding requires it.
9. Make timestamps, ordering and metadata deterministic where practical, then compare output digests and explain unavoidable variance.
10. Generate SBOM and provenance from the build system and bind their subjects to output digests.

A minimal image reduces packages and attack surface, but "small" is not equal to "secure" or "debuggable." Provide an authorized ephemeral-debug path instead of shipping a shell/toolbox into every production workload.

### Kubernetes mapping

| Container concept | Kubernetes owner/field | Reliability question |
|---|---|---|
| image reference/digest | Pod spec + admission + runtime status | What exact platform manifest ran? |
| runtime user/capabilities/seccomp | `securityContext` and policy | Did effective runtime match intent? |
| cgroup CPU/memory | requests/limits + node/runtime cgroup | Was it scheduled safely and constrained correctly? |
| PID 1 and stop | container command, `terminationGracePeriodSeconds`, hooks | Did TERM reach code and did drain finish before kill? |
| health | startup/liveness/readiness probes | Does each probe answer one appropriate question? |
| network | pod namespace, CNI, Service, NetworkPolicy, ingress/LB | Where was traffic selected/dropped? |
| writable root/tmpfs/volume | `readOnlyRootFilesystem`, `emptyDir`, PVC/CSI | Who owns bytes, quota, durability, backup and restore? |
| logs | stdout/stderr, node/runtime, collector/backend | Can events be correlated, bounded and retained? |
| restart | kubelet + workload controller | Is a new attempt safe for durable operations? |
| rollout/rollback | Deployment/StatefulSet/Job/controller | How are accepted operations reconciled across revisions? |

`kubectl get pods` is an inventory view, not a diagnosis. Scope namespace/context, capture pod UID, node, container ID, image ID, previous termination state and controller revision. Before mutation prefer authorized `kubectl diff`, explicit namespace, bounded rollout, and rollback/business-compensation awareness.

### Production incident 1: host free, container OOM

**Symptom:** payment worker exits 137; host shows 18 GiB available; container limit is 512 MiB; runtime says OOM-killed.

**First thought:** host availability and cgroup limit are different boundaries. Freeze blind replay because SIGKILL may leave unknown payment effects.

**Evidence:** exact container and image identity, state/OOM/exit timestamps, cgroup memory event delta, configured limit/request, process/heap and workload dimensions, queue/operation IDs, node pressure, restart/controller events. Separately inspect the 3 GiB writable-layer growth by path and mount owner.

**Containment:** cap admission/concurrency and retries, preserve the failed instance where policy permits, protect healthy tenants, and run only a small known-digest replacement cohort.

**Recovery:** reconcile every payment at its authoritative ledger before replay. Fix unbounded allocations/batch/concurrency and choose a measured memory envelope with node headroom. Do not jump from 512 MiB to 4 GiB without capacity proof.

**Verification:** terminal receipts and zero unsupported duplicates; queue drains; memory plateaus under representative inputs; no new OOM events; writable growth remains bounded; planned TERM completes; node pressure stays within guardrails.

### Production incident 2: mutable multi-architecture rollout and unsafe runtime

**Symptom:** AMD64 and ARM64 nodes resolve different content under `stable`; a critical package is flagged; privileged containers mount Docker socket and host `/`; restart retries duplicate jobs.

**First thought:** distinct platform manifests under one index can be normal, but mutable tag timing and unreviewed divergence make identity uncertain. Privileged/socket/root mount is a potential host-security incident. Job duplication is a durable-state defect, not an image-tag-only problem.

**Containment:** stop rollout/replay, isolate affected workload/node scope through incident authority, preserve registry descriptor graph and node/container/runtime evidence, restrict deploy/socket access, and rotate any build credential exposed through arguments/cache without repeating it.

**Correction:** rebuild from digest-pinned reviewed inputs in a trusted builder; verify downloads; use secret mounts/identity; produce per-subject SBOM/provenance/signatures; admit by policy. Remove privileged, host socket/root bind and excess capabilities; use non-root, seccomp, no-new-privileges, read-only root with bounded mounts, network policy and measured resource limits. Fix PID 1 and move queue state to a durable fenced/idempotent owner.

**Verification:** host-integrity disposition, credential invalidation, exact digest selected per architecture, policy verification, scanner finding disposition/reachability, effective sandbox, graceful termination, state survival, zero unsupported duplicates and end-to-end jobs on both architectures. Expand only with explicit abort thresholds.

### Rollback is a software action, not business time travel

A deployment rollback changes desired future software. It does not undo a payment, un-send a message, restore deleted data, remove an exfiltrated secret, or reconcile an in-flight job. Pair rollback with operation inventory and domain compensation. In a queue worker, stop consumers, preserve leases/receipts, classify committed/absent/unknown, then retry only eligible identities.

### Production command safety

Every command needs context and authorization. Examples in this chapter are local. Before translating to production, record:

- cluster/daemon/context and namespace;
- resource UID/container ID, not only name;
- image index/manifest digest and deployment revision;
- whether output contains secrets/customer data;
- command load and timeout;
- mutation blast radius;
- preservation, abort and rollback/compensation;
- user-facing success criteria.

Never mount the Docker socket into a general CI job to make deployment convenient. Prefer a narrow authenticated deployment API or workload identity with least-privilege authorization and auditable operations.

## Reliability, security, observability, capacity, and cost

Container engineering becomes mature when these concerns are designed together. A security control can change operability; a reliability retry can increase cost and duplicates; an observability sidecar consumes resources; an aggressive CPU limit can inflate latency; an oversized image slows recovery and increases registry/storage traffic.

### Reliability

Design for replacement:

- stable logical operation identity across attempts;
- idempotent effects or explicit reconciliation/compensation;
- bounded queues, concurrency, retries and backoff with jitter;
- timeouts aligned across client, proxy, application and dependency;
- TERM handling, drain, checkpoint and sufficient but bounded grace;
- startup, readiness and liveness with distinct predicates;
- immutable rollout and deterministic rollback target;
- disruption, node loss, OOM, network and storage failure tests;
- backup and restore proof for actual durable state owners.

Availability is not "containers running." Define an SLI at the user's transaction boundary. For a job system: accepted jobs reaching correct terminal state within objective, with duplicate/unknown rates bounded. For an API: valid requests receiving correct responses within latency objective, measured at meaningful edges.

### Security

Use defense in depth:

- protect source, CI identity, builder and registry namespaces;
- pin and verify materials, downloads and output subjects;
- prevent secrets in context, Dockerfile, args, layers, history, cache and logs;
- generate and verify SBOM/provenance/signature/attestation under policy;
- scan continuously with reachability and remediation ownership;
- run as a numeric non-root identity; use user namespaces/rootless where compatible;
- privileged false, drop all capabilities, add only reviewed minimum;
- default/reviewed seccomp, no-new-privileges, SELinux/AppArmor policy where enforced;
- read-only root, minimal bounded mounts, no host root/socket/device unless narrowly justified;
- least network reachability and application authentication/authorization;
- patch kernel/runtime/daemon and isolate tenants according to threat model.

A container is not a complete security boundary for hostile multi-tenancy by default. Threat model kernel sharing and consider stronger sandbox/VM isolation where required.

### Observability

Correlate these identifiers without exploding cardinality:

```text
service, environment, region/zone, cluster/node
deployment revision, index digest, selected manifest digest
pod UID/container ID (logs/traces, not every metric label)
logical operation/request/trace ID with privacy controls
```

Collect:

- request/error/duration and business outcome;
- queue age, retry, duplicate and unknown result;
- restarts, exit reason, OOM events and termination latency;
- CPU usage/throttle, memory current/peak/events, PIDs current/max;
- filesystem blocks/inodes/growth by mount and log retention;
- network errors/retransmits/DNS/connect/TLS/load-balancer backend decisions;
- image/admission/policy identity and drift;
- build/registry/deploy audit.

Logs should be structured, bounded and secret-safe. Metrics show trends; logs explain events; traces join request path; profiles expose code resource ownership; audit records control-plane mutation. No one signal replaces the others.

### Capacity

Capacity planning spans layers:

```text
per request/job demand
    x concurrency and retry amplification
    x replica distribution
    + runtime/sidecar/kernel overhead
    + headroom for burst/failure/rollout
    <= node and fleet allocatable constraints
```

Requests influence scheduling; limits protect neighbors but can throttle/kill. Too-low CPU quota increases queue time and may create timeout retries. Too-high memory limits multiplied by replicas can overcommit nodes. PID limits must cover legitimate threads/children. Ephemeral storage includes writable layers/logs depending on platform; volumes have separate capacity/IOPS/throughput contracts.

Load-test representative payload distributions, not only averages. Measure steady state, burst, dependency slowdown, cold start, rolling overlap and one-node loss. State exact window and percentile.

### Cost

Container cost includes more than CPU requests:

- build minutes and cache storage;
- registry transfer/retention and multi-platform duplication;
- node idle headroom and over-requesting;
- log/metric/trace volume and high-cardinality indexing;
- image pull/cold-start time and egress;
- persistent storage, snapshots and restores;
- retry amplification and failed work;
- incident/on-call/toil and security remediation.

Do not reduce cost by removing safety margins blindly. Optimize a measured unit such as cost per successful transaction while holding reliability/security objectives. A smaller image may reduce transfer and attack surface; a broken minimal image can increase incident cost if there is no safe debug path.

### SLO and alert examples

Good alerts connect symptom to action:

| Signal | Window/threshold idea | Why actionable | Guard against |
|---|---|---|---|
| user error-budget burn | fast + slow burn windows | pages before objective exhaustion | paging on one transient error |
| queue oldest age | above objective with growth | shows work progress failure | queue depth alone without arrival rate |
| cgroup OOM kill delta | any on critical service + user impact | abrupt state risk | exit 137 alone |
| memory saturation/peak | sustained near reviewed envelope | gives mitigation lead time | one noisy sample |
| CPU throttled time ratio | sustained with latency/queue rise | detects quota contention | throttle count without interval |
| PID current/max | sustained high with create failures | detects thread/fork exhaustion | confusing tasks with processes |
| writable layer/log growth | slope and remaining-time estimate | prevents backing-store ENOSPC | aggregate host disk only |
| restart amplification | attempts per logical operation | exposes controller feedback loop | raw restart count without workload |
| artifact drift | running digest outside release set | immutable identity violation | tag text comparison only |

Every alert needs owner, runbook, query, unit, freshness, silence policy and user-impact connection. Test it by injecting a safe known signal and confirming notification, diagnosis evidence and recovery path.

## Traps and prevention

The dangerous container mistakes are usually category mistakes: a person observes one boundary and acts on another. Learn these pairs until the correction becomes automatic.

### Trap: "A container is a lightweight VM"

Why it fails: the phrase hides the most important boundary. A Linux container normally shares the host Linux kernel. Namespaces change what processes can see; cgroups account and constrain them; mounts/credentials/capabilities/security policy restrict them. A VM boots a guest kernel over virtual hardware.

Prevention: in every design diagram draw the kernel. Ask, "Whose kernel executes this syscall?" On Docker Desktop, draw Windows, the Linux VM/kernel, Docker daemon and container processes rather than treating them as one host.

### Trap: "The tag is the version"

Why it fails: a tag is mutable registry naming. Nodes can resolve it at different times, use cached content, or choose different platform manifests. Human text equality is not content equality.

Prevention: promote by digest; record the index digest and selected manifest digest per platform; retain release-to-source/build mappings. Use a tag only as a discoverable pointer protected by registry policy.

### Trap: "A digest proves the image is safe"

Why it fails: a digest proves content identity/integrity relative to the bytes named. It says nothing about author, build, review, vulnerabilities, license, runtime behavior or authorization.

Prevention: combine immutable digest with trusted provenance, verified signer/builder/material policy, SBOM, scanning/reachability, admission, runtime least privilege and behavioral testing. State the claim each control makes.

### Trap: "The final image no longer contains the secret because RUN rm deleted it"

Why it fails: deleting in a later layer creates a whiteout; the earlier blob can retain the bytes. Build arguments, history, cache, logs and provenance can also expose values.

Prevention: never copy the secret into a committed layer. Use ephemeral build secret mounts or workload identity, keep secret-bearing stages/caches isolated, scan history/context, revoke any exposed credential and audit its use.

### Trap: "Smaller image means secure image"

Why it fails: size does not prove provenance, patch status, configuration, absence of malicious code or safe runtime. A tiny static binary can contain a critical defect.

Prevention: optimize minimality as one property. Maintain patch/update ownership, artifact policy, tests, non-root runtime, sandboxing and a safe debug method.

### Trap: "Root inside the container is harmless"

Why it fails: UID 0 may hold capabilities, write mounted data, control devices or exploit a shared-kernel/runtime defect. With a Docker socket, host root bind, host namespaces or privileged mode, the boundary can collapse.

Prevention: numeric non-root UID/GID, designed ownership, drop all capabilities, add the minimum, no-new-privileges, reviewed seccomp/MAC, no sensitive mounts/devices, rootless/user namespaces where supported, and protected daemon API.

### Trap: "Privileged is the easiest permissions fix"

Why it fails: privileged mode grants a broad device/capability/security bypass far beyond the missing operation. It destroys useful least-privilege evidence and magnifies compromise.

Prevention: identify the exact syscall, device, filesystem owner, capability or API permission. Fix that narrow requirement, test the denied and allowed paths, document expiry/owner, and reconsider whether the function belongs outside the application container.

### Trap: "Read-only rootfs means the container cannot write"

Why it fails: tmpfs, volumes, binds, sockets and some runtime-mounted paths are separate mounts. The process can also write to external services.

Prevention: inventory every mount with source/type/options/owner/quota/lifecycle; grant only explicit writable paths. Test expected writes and denied paths under the final runtime user.

### Trap: "A volume makes data durable"

Why it fails: a volume persists beyond one container, but durability also requires failure-domain placement, replication, consistency, backup, restore, encryption, access control, capacity and lifecycle. Local volume loss can follow node loss.

Prevention: name the authoritative state service and its RPO/RTO/consistency contract. Run restore and failover drills. Keep container writable layers for disposable state only.

### Trap: "The process is running, so the service is healthy"

Why it fails: the process can deadlock, lose traffic, return corrupt results, lag a queue or pass a shallow endpoint while dependencies fail.

Prevention: separate startup, liveness, readiness and business-progress/user SLIs. Make liveness conservative so restart is likely to help. Verify the real operation.

### Trap: "Unhealthy means Docker restarts it"

Why it fails: Docker health records probe state; restart behavior follows separate runtime/controller policy. Kubernetes liveness may restart, readiness may only remove endpoints, and implementation details matter.

Prevention: document the actor for every transition: probe producer, health recorder, traffic controller, restart controller and business reconciler. Test failure behavior rather than inferring it.

### Trap: shell-form command without signal reasoning

```Dockerfile
ENTRYPOINT my-server --port 8080
```

This commonly becomes `/bin/sh -c ...` as PID 1. The shell may not forward TERM or reap as expected. Prefer an exec-form direct process where suitable:

```Dockerfile
ENTRYPOINT ["/usr/local/bin/my-server"]
CMD ["--port", "8080"]
```

Exec form avoids shell expansion; environment-variable substitution behaves differently, so design intentionally. If a wrapper is required, end with `exec "$@"`, install traps where needed, and test children plus forced-kill boundary. A reviewed tiny init can handle reaping/forwarding, but it is another component to maintain.

### Trap: "Exit 137 always means OOM"

Why it fails: 137 is conventionally 128 + signal 9, but SIGKILL can come from manual action, controller escalation, kernel OOM, runtime/host shutdown, or an explicit wrapper exit. The numeric status alone lacks source.

Prevention: correlate exact container ID, OOMKilled, cgroup event delta, runtime/orchestrator/node audit, stop grace, timestamps and logs. Then investigate why, not only how it died.

### Trap: "Host free memory disproves container OOM"

Why it fails: a child cgroup can reach its limit while the host has capacity. A parent cgroup may also constrain it. Scheduling request and enforced limit differ.

Prevention: label all memory signals by owner and unit: host/node, parent cgroup, container cgroup, process, heap. Measure peak and input/concurrency, then size the full fleet with headroom.

### Trap: "CPU limit reserves a core"

Why it fails: quota caps runtime over periods; it does not grant exclusive hardware or eliminate scheduler contention. A request may affect placement/share but is not a private core in the common model.

Prevention: inspect request, limit/quota/period, actual usage, throttled time, run queue, latency and node topology. Use CPU Manager/dedicated placement only for justified workloads and verify the platform behavior.

### Trap: "docker stats proves there was no spike"

Why it fails: one sample misses history and may be collected after recovery. Rendered memory semantics differ by platform/version.

Prevention: retain time-series cgroup and application signals with stated scrape intervals, peaks and counter deltas. Use profiling and representative failure reproduction.

### Trap: "docker diff shows every write"

Why it fails: it covers current container-layer changes, not separate mounts, not necessarily deleted historical bytes, and not external state.

Prevention: map mount table and storage owner first. Observe blocks and inodes at the exact mount, volume/backend metrics, log driver and Docker backing store.

### Trap: "localhost is the host"

Why it fails: loopback belongs to the current network namespace. Inside a container it usually refers to that container's namespace. Sidecars in one Kubernetes pod share a network namespace; separate containers normally do not.

Prevention: draw socket bind, namespace interface, route, DNS, service, policy, publication and load-balancer path. Test from the same boundary as the real client.

### Trap: "Restart is recovery"

Why it fails: restart creates another process attempt. It does not reconcile the prior attempt's database write, payment, message, lease or external side effect. It can amplify load and duplicates.

Prevention: stable operation ID, idempotency key, fenced claims/leases, transactional outbox/inbox or equivalent domain design, bounded retries, dead-letter/review path and authoritative reconciliation before replay.

### Trap: "Rollback returns the system to the old state"

Why it fails: rollback changes software desired state, not already-accepted business operations, leaked credentials or altered data.

Prevention: pair technical rollback with impact inventory, state reconciliation, compensation, credential response and user verification.

### Trap: broad cleanup

Commands such as `docker system prune`, `docker container prune`, wildcard `rm`, or manual deletion inside Docker's data root target objects whose ownership the lesson cannot establish.

Prevention: record exact created IDs and random ownership labels atomically; validate them before mutation; delete only those objects; prove final absence. Preserve forensic evidence first in real incidents.

### Trap: weakening a blocked lab

Why it fails: starting/reconfiguring Docker, pulling an image or running as root changes the experiment and may add network/system risk. It turns missing evidence into unjustified confidence.

Prevention: represent blocked explicitly, keep static validation, record the prerequisite owner, and run later under an authorized prepared environment. Unknown is a valid reliability state.

## Memory card and retrieval

Use this compact card when you need the chapter in sixty seconds.

```text
CONTAINER = host-kernel processes
            + namespaces (views)
            + cgroups (account/control)
            + mounts/rootfs (files)
            + credentials/caps/seccomp/MAC (privilege)
            + runtime/controller lifecycle

VM        = virtual hardware + guest kernel + guest processes

OCI IMAGE = optional INDEX
              -> platform MANIFEST
                   -> CONFIG + ordered compressed LAYER blobs
              digest identifies bytes; tag is a mutable pointer

RUNTIME   = client -> daemon/manager -> OCI runtime -> kernel process
FILES     = immutable lowers + writable upper + separate mounts
PID 1     = signal boundary + child lifecycle
HEALTH    = one probe predicate, not user correctness
RESTART   = new attempt, not business reconciliation
TRUST     = digest + provenance/signature policy + SBOM/scan + runtime controls
```

### The first five questions in an incident

1. Which user operation is failing or unknown?
2. Which exact daemon/cluster, container/pod UID and immutable image descriptor are involved?
3. Is the workload running, unhealthy, exited, restarting, missing or unscheduled - and who reports that?
4. Which owner is constrained or inconsistent: process, cgroup, mount, node, network, dependency, controller or business store?
5. What evidence must be preserved and reconciled before the smallest bounded action?

### The four identity rule

Always separate:

```text
artifact identity  -> index/manifest/config/layer digest
runtime identity   -> container ID or pod UID/container ID
process identity   -> host PID + namespace PID + start time
business identity  -> request/job/payment/idempotency key
```

Names and PIDs can be reused. Record timestamps and owner boundaries.

### The four filesystem rule

```text
image lower layers -> immutable shared artifact content
container upper    -> disposable changes for one container
tmpfs/emptyDir     -> explicit temporary mount with lifecycle/capacity
volume/service     -> separate state owner; durability must be designed
```

A mount hides the merged path underneath. `docker diff` does not show mounted writes.

### The four health rule

```text
started?  startup predicate
alive?    liveness predicate where restart helps
serve?    readiness/traffic predicate
correct?  user/business SLI
```

Do not use one shallow `/health` answer for all four.

### The evidence sentence

Say: "At [time], [source] observed [raw fact and unit] for [exact owner/identity]. It supports [narrow claim], does not establish [limit], so next I will collect [discriminator]."

### The safe change sentence

Say: "With [authorization], I will change [one exact target] from [known state] to [desired state] for [time/blast radius]. I will abort at [threshold], preserve [evidence/state], roll back or compensate by [method], and call it successful only when [user proof] holds."

### Spaced retrieval prompts

Without looking back, answer these after ten minutes, one day, one week and one month:

1. Draw a container and VM with the kernel boundary.
2. Draw tag -> index -> manifest -> config/layers and label every digest type.
3. Explain copy-up, whiteout and why a mounted volume hides image content.
4. Explain why 137 is a clue and what establishes cgroup OOM.
5. Name PID 1 responsibilities and test a graceful/forced stop.
6. Separate running, healthy, ready and useful.
7. Explain what digest, signature, provenance, SBOM and scan each prove.
8. Design a job worker restart without duplicates.
9. Write a least-privilege runtime envelope from memory.
10. Write the mutation card for an exact production container.

If you cannot draw and teach it in plain language, revisit the relevant boundary rather than memorizing another command.

## Complete answers

These answers correspond to the guided evidence questions. They are deliberately detailed. The separate independent transfer case remains answer-isolated and reviewer-scored.

### 1. Why is a container a group of host-kernel processes rather than a VM?

When a process in a normal Linux container calls `open`, `clone`, `socket` or `mmap`, it enters the host Linux kernel. The runtime created namespace membership so its PID, mount, network, IPC, UTS and possibly user views differ; it placed tasks in cgroups for resource accounting/control; it selected filesystem mounts, credentials, capabilities, syscall/MAC policy and an initial process. There is no separate guest-kernel boot in that container abstraction.

A VM is given virtual CPU, memory, devices and firmware by a hypervisor and boots a guest kernel. Guest processes call that guest kernel. This usually creates a stronger kernel boundary at additional resource/startup/management cost. Docker Desktop complicates the picture only visually: Windows hosts a Linux VM; the Docker Linux containers share that VM's Linux kernel, not the Windows kernel and not a private kernel per container.

The distinction matters for kernel compatibility, security threat models, observability and capacity. A container image cannot bring an arbitrary kernel. A shared-kernel vulnerability can cross a boundary. Host-kernel accounting sees the tasks even if their namespace PIDs differ.

### 2. Which identifiers name an image reference, content, a container, a process and a user job?

A registry repository/tag such as `platform-api:stable` is a name and mutable pointer. An OCI descriptor digest identifies exact bytes of a typed object: perhaps an index, platform manifest, config or layer blob. In a multi-platform artifact, record the index digest and selected manifest digest. Docker's image ID commonly identifies the config object of the locally selected image.

A container ID identifies one daemon-created runtime record. A name is a mutable convenience mapping and can be reused. A host PID identifies a kernel task in the host PID namespace for one lifetime; namespace PID can be 1 for that same task. PIDs are reusable, so include start time/container identity.

A user job/payment/request ID belongs to durable product state across all process/container attempts. It must survive restart and rollout. Never substitute container ID for job ID: one container processes many jobs, and one job may cross several containers.

### 3. Why can the container be running but unhealthy?

Running means the runtime currently has a live container PID 1. Health means the configured probe command recently met its exit-code/timing predicate. In the guided lab, PID 1 keeps looping while `/run/ready` is removed, so the process exists but the health command fails. That is a valid state, not a contradiction.

The reverse can also be misleading near timing edges: a last health result may be stale while lifecycle changes. Always preserve timestamps. Docker records health but does not automatically equate unhealthy with restart. A separate controller and policy decide action.

### 4. Why does the health probe not prove useful work?

The probe only proves what it tested. A file existence check proves a file exists. `curl /health` might prove a local HTTP handler replied within timeout. Neither proves traffic reaches the instance, dependencies are correct, queue age is bounded, payments are committed exactly once, results are correct or the SLO is met.

Design health in layers. Startup says initialization may continue without premature kill. Liveness asks whether the process is irrecoverably stuck and restart is likely to help. Readiness asks whether traffic should be sent. Business progress belongs to an SLI such as valid successful requests or job age/terminal outcomes. Keep liveness conservative; a dependency outage should not necessarily restart every healthy process and amplify load.

### 5. What special responsibilities does PID 1 have for signals and orphaned children?

The runtime sends its configured stop signal to container PID 1, then waits a grace period before possible SIGKILL. PID 1 must cause the application and relevant children to receive/handle the signal, stop accepting work, drain/checkpoint within the deadline and exit with meaningful status. If PID 1 is the application, it handles directly. If it is a shell/supervisor, forwarding must be implemented and tested.

PID 1 also becomes the reparent target for orphaned descendants in its PID namespace and should reap exited children with `wait`; otherwise zombies accumulate. Linux PID 1 has special signal semantics, so relying on default behavior without testing is risky. A tiny init can forward/reap, but direct exec is often simpler. SIGKILL cannot be caught or used for cleanup, which is why durable state must tolerate abrupt death.

### 6. Why does shell-form ENTRYPOINT often create a signal-forwarding problem?

Shell form typically launches `/bin/sh -c 'my-server ...'` as PID 1 and the server as a child. The runtime sends TERM to the shell. Some shells do not forward it automatically, so the server keeps running until grace expires and SIGKILL arrives. The shell must also reap children.

Exec-form JSON (`ENTRYPOINT ["/path/server"]`) asks the runtime to start the executable directly, making it PID 1. A wrapper can be valid when it validates/configures then `exec`s the server, or when it deliberately supervises children with traps/wait. Test actual process tree, TERM receipt, drain time, child absence and forced-kill behavior. Exec form does not perform shell interpolation unless the application does it.

### 7. What belongs to immutable layers, the container writable layer, tmpfs and a volume?

Image layers are ordered immutable filesystem changes shared through the content store. The container upper/writable layer records copy-on-write changes to the merged rootfs for one container and normally disappears with it. It is poor storage for business data and uncontrolled logs/cache.

Tmpfs is a separate memory-backed mount with its own capacity and lifecycle; it is useful for bounded ephemeral files and can remain writable under a read-only root. Its bytes consume memory resources according to kernel/runtime accounting and vanish when the mount/container ends. A Docker/Kubernetes volume is another mount whose provider/lifecycle can outlive the container. Its durability, backup, replication, IOPS, encryption and ownership depend on the volume system, not the word "volume."

A bind mount exposes an existing host path and can create major host coupling/security risk. Any mount on a path hides image/upper content below that mount until unmounted.

### 8. Why can a read-only root filesystem still support temporary work?

Read-only applies to the merged root filesystem mount. The runtime can mount writable tmpfs at explicit paths such as `/run` and `/work`. The application writes only there while unexpected writes elsewhere fail. This shrinks persistence and tampering paths and exposes undeclared write assumptions early.

It is not a magic switch. The image/runtime user must have correct ownership; tmpfs must have byte/inode capacity and appropriate options; application state must be classified; and required certificate/config/secret mounts need correct modes. Test both an allowed temporary write and a denied rootfs write.

### 9. What do memory, CPU and PID settings limit, and what do they not measure?

A memory cgroup maximum constrains charged memory for that hierarchy. It does not report legitimate application demand or reserve private physical RAM. `memory.current`, peak/events and component/process profiling provide different observations. A child cgroup can OOM while the host has capacity.

CPU quota permits a bounded amount of execution time per period, such as 25,000 microseconds per 100,000 = 0.25 CPU. It does not dedicate a quarter core, measure current CPU or explain latency alone. Inspect use, throttle deltas, scheduler/node contention and queues.

A PID cgroup maximum limits charged tasks, often including threads. It does not show current use, host PID space or legitimate peak. These settings contain blast radius; correct values come from representative load/failure measurement and fleet headroom.

### 10. Why is a digest different from a signature, SBOM, provenance and scan?

A digest is a content-addressed identifier: recomputing the hash over the specified bytes detects change. A signature or signed attestation binds an identity to a digest and claim under a verification/trust policy. Provenance is a structured claim about how an artifact was built, including subject, builder and materials. An SBOM describes components and relationships. A scanner compares artifacts/SBOM/runtime context with known advisory and policy data.

None is a universal certificate. A digest has no authorship. A valid signature can sign vulnerable code. Provenance can be untrusted or incomplete if builder/issuer policy is weak. An SBOM can omit components. A scanner can have stale data, false matches or unknown vulnerabilities. Combine them with review, trusted build/admission, runtime controls and observed behavior.

### 11. Why is Docker socket access a large privilege boundary?

The Docker API can often create containers with privileged mode, host filesystem/device/socket mounts, host namespaces and access to daemon-managed images, networks, secrets or workloads. A process controlling a rootful host daemon can commonly arrange effective host control. Group membership or socket access must therefore be treated as powerful privilege, not ordinary application connectivity.

Do not mount the socket into general CI/application containers. Use a narrow deployment service/API with authentication, authorization, policy and audit, or a platform-native controller with least-privilege workload identity. Rootless Docker reduces parts of the host privilege boundary but does not make arbitrary mounts, vulnerable kernels, secrets or tenant access safe.

### 12. What exactly does cleanup prove?

The lab controller validates its descriptor and live object, removes one exact owned container and exact known state records, then verifies their absence. A passing cleanup proves those defined resources were absent at verification time. It does not prove the entire daemon is empty, image layers were garbage-collected, backing-disk bytes were immediately returned to Windows, logs were retained, no kernel state remains, or production cleanup is safe.

Idempotent cleanup means repeating the exact cleanup safely reports absence; it never justifies wildcard/prune deletion. In an incident, preserve required evidence and reconcile business state before removal.

### Assessment answer: cgroup OOM and writable-layer growth

For the guided diagnostic in `ASM-0052`, the correct mechanism-first reasoning is:

1. Declare affected payment batches and every in-flight logical ID unknown until reconciled. Stop blind replay.
2. Preserve exact container ID, immutable image identity, config/revision, timestamps, state, OOM flag, limit/request, cgroup counters, logs, process and job evidence.
3. Treat 137 as SIGKILL-compatible. `OOMKilled=true` plus a matching cgroup `oom_kill` event delta under 512 MiB establishes the scoped kill mechanism more strongly. Host 18 GiB availability is a separate boundary.
4. Do not infer allocation root cause. Investigate heap/RSS/cgroup categories, children, input/batch size, concurrency, queue behavior, code revision and parent/node pressure.
5. Treat 3 GiB writable-layer growth as a second storage signal. Attribute exact cache/log/temp/state paths and backing-store blocks/inodes; it is not automatically the OOM cause.
6. Contain admission/concurrency/restarts and protect healthy cohorts. Reconcile durable payment outcomes before any retry.
7. Recover via a bounded exact-digest canary, smaller/bounded work and a measured memory limit with node/fleet headroom. Abort on OOM, queue/latency, duplicate or node-pressure guardrails.
8. Verify original payments, no unsupported duplicates, stable memory under representative distribution, zero new OOM events, bounded layer growth and graceful planned termination.
9. Prevent with profiling, bounded allocation/concurrency/buffers, backpressure, durable idempotent checkpoints, read-only root plus bounded mounts, log management, resource declarations and failure tests.

Raising to 4 GiB and restarting may hide a leak, shift pressure to the node and repeat unknown payments. A limit change is justified only by measured legitimate working set, concurrency and aggregate capacity.

### Assessment answer: multi-platform and supply-chain incident

For the guided production case in `ASM-0053`, a senior response is:

1. Stop rollout and automatic retry. Treat privileged mode plus Docker socket/host-root mount as potential host compromise and coordinate reliability/security timelines.
2. Preserve requested tag, resolved index digest, selected AMD64/ARM64 manifest/config/layer digests, node architecture/cache/pull evidence, container/pod/runtime configuration, build/registry/deploy audit and impacted job IDs.
3. Distinct platform manifests under one index are normal; unexpected content caused by tag movement, wrong/missing platform entry or build divergence requires descriptor comparison. Tag equality is insufficient.
4. Treat the package token used as a build argument as exposed. Revoke/rotate through its owner and audit without copying it. Identify affected caches, logs and images.
5. Evaluate the critical finding by exact package/version/artifact, advisory quality, reachability/exploit conditions and runtime exposure. A scan is triage evidence, not exploitation proof.
6. Rebuild from reviewed digest-pinned inputs in an isolated trusted builder, using secret mounts/identity, verified downloads, locked dependencies, minimal non-root final stage and exec-form entry. Produce SBOM and verifiable provenance/signatures tied to exact subjects and enforce policy at admission.
7. Remove privileged, socket/root bind, all capabilities and writable-root default; use no-new-privileges, reviewed seccomp/MAC, minimal bounded mounts, network/secret policy and measured resource limits.
8. Move queue state to a durable owner with stable identity, fencing/idempotency/receipts. Reconcile each old job before bounded replay.
9. Canary exact digests on both architectures. Verify credential invalidation, host-integrity disposition, artifact/admission claims, effective runtime sandbox, TERM/reaping, persistent state and end-to-end jobs with zero unsupported duplicates.
10. Expand only while security, correctness, capacity, latency, duplicate and unknown-outcome guardrails hold. Rollback still requires business reconciliation.

## Product-company interview

Top interviews reward clear boundary reasoning, not command recitation. Use this answer shape: **user impact -> system model -> hypotheses -> discriminating evidence -> containment -> recovery -> verification -> prevention/trade-off**.

### Question 1: Are containers less secure than VMs?

Strong answer: neither label is universally safer. Standard Linux containers share a kernel, so kernel/runtime defects and dangerous capabilities/mounts matter. VMs add a guest-kernel/hypervisor boundary and often provide stronger workload isolation, with boot, density and management trade-offs. Security depends on threat model: tenant hostility, data sensitivity, kernel attack surface, hardware, patching and operational controls. For ordinary trusted microservices, least-privilege containers may be appropriate. For hostile multi-tenant execution, use stronger sandbox/VM boundaries plus artifact/runtime/network controls. I would measure actual configuration - non-root, user namespace/rootless, capabilities, seccomp/MAC, devices/mounts, daemon exposure - rather than claim "containers are isolated."

Follow-up: what would change your decision? Untrusted code, cross-customer co-tenancy, kernel exploit risk, compliance isolation, accelerator/device sharing and forensic requirements may justify microVMs or dedicated nodes.

### Question 2: Explain an OCI image to a first-year engineer and then to a staff engineer

Foundation answer: it is not one magic disk file. A human name can point to an index; the index selects the image for Linux/AMD64 or Linux/ARM64; a manifest points to configuration and ordered filesystem layer blobs. Digests identify exact bytes. The runtime assembles layers into a root filesystem and applies configuration to start a process.

Staff extension: distinguish compressed distribution blob digests from uncompressed DiffIDs and config/image ID; media types and descriptor sizes; whiteout application; content verification; platform variant selection; registry referrers/attestations; local snapshotter/storage-driver representation; immutable promotion and garbage-collection reachability. State which descriptor digest a deployment records.

### Question 3: A container exits 137. Walk me through it

Strong answer: 137 suggests 128 + SIGKILL 9 but is not unique proof. I capture exact instance/image/config and user operations, then correlate runtime OOM flag, cgroup `memory.events` delta and limits, orchestrator/node events, stop/kill audit and timestamps. If cgroup OOM is established, I separate mechanism from cause: heap leak, input/batch/concurrency, children/cache, request/limit sizing, parent/node pressure. Because SIGKILL skips graceful handling, I reconcile in-flight work before retry. Containment bounds admission/restarts. Recovery uses a measured envelope and exact-digest canary; success is correct operations plus stable memory/no new OOM, not just uptime.

### Question 4: Why did my file disappear when I mounted a volume?

Strong answer: the image/merged root may contain a file at that path, but a mount attaches a different filesystem tree on top, hiding underlying content. It was not necessarily deleted. I inspect mount type/source/options and compare the image without mutating production. Initialization should explicitly populate a volume or the application should tolerate empty durable state; do not rely on hidden image defaults. Also define ownership, capacity, backup and concurrent-access semantics.

### Question 5: How do you shrink an image safely?

Strong answer: measure first: transfer, unpacked unique/shared size, cold-start and vulnerability/package inventory. Reduce build context; use multi-stage build; copy only runtime artifacts; use locked/pinned dependencies and minimal reviewed base; remove caches in the same layer that creates them; avoid secrets; preserve CA/timezone/debug requirements as needed. Rebuild with SBOM/provenance, scan/test, compare both architectures, verify startup/TERM/health/user behavior. I would not squash blindly because it can harm cache/sharing/provenance and hide history without removing registry secrets everywhere.

### Question 6: How do you make a container graceful in Kubernetes?

Strong answer: make application or reviewed init PID 1; handle TERM; mark unready/stop new work; drain/checkpoint within a measured bound; reap children; set `terminationGracePeriodSeconds` beyond required drain with margin; align load-balancer deregistration and client timeouts; ensure preStop, if used, does not consume unbudgeted grace. Test during load and dependency delay, then verify no accepted operation is lost/duplicated. SIGKILL after grace is always possible, so correctness cannot depend solely on graceful shutdown.

### Question 7: What is wrong with mounting Docker socket into CI?

Strong answer: a generic job can command the daemon to mount host paths, create privileged workloads, access daemon networks/images/secrets and often gain host-equivalent control. It expands one repository/build compromise into runner/host compromise and cross-job impact. Prefer isolated ephemeral builders, rootless/daemonless patterns where appropriate, a narrow build/deploy service, workload identity, policy, protected environments and audit. If an exception exists, dedicate/ephemeral-isolate the runner and document residual risk; do not describe socket access as a harmless convenience.

### Question 8: How do requests and limits affect reliability?

Strong answer: in Kubernetes, requests influence scheduling and resource share/QoS; limits are enforced through runtime/cgroups. A CPU limit can throttle tail latency and amplify retries. A memory limit can OOM a cgroup even with host memory available. No limit can expose neighbors/node; oversized requests waste bin-packing capacity; undersized requests permit overpacking. I use representative distributions, rolling overlap and failure capacity, monitor throttle/OOM/queue/user SLO, and roll out changes gradually. Exact QoS/eviction behavior is platform/version-specific.

### Question 9: What does a signed image prove?

Strong answer: technically, a verifier establishes that a trusted identity signed a statement bound to a subject digest and that policy conditions hold. It does not prove the code is vulnerability-free, reviewed, reproducible or authorized for every environment unless those claims/policies exist. I combine signature/attestation verification with provenance builder/material rules, SBOM/scan/license policy, immutable admission, secret controls, runtime sandbox and behavior tests. Keyless systems still require issuer/identity/transparency/time policy.

### Question 10: A deployment is healthy but users fail. What next?

Strong answer: decode what health tested. Map user request through DNS/load balancer/service/endpoints/network policy/socket/app/dependency and exact backend revision/digest. Compare readiness and actual request/error/duration traces, dependency saturation and business correctness. Preserve one failure trace and one success comparator. Contain by routing or rollback only after accepted operations are inventoried. Improve the probe only if it can safely represent traffic eligibility; keep the user SLI primary.

### Question 11: How would you design a safe container build platform?

Strong answer: isolate ephemeral builders by tenant/trust, least-privilege workload identity, controlled network/material sources, digest-pinned bases, locked dependencies, secret mounts rather than args, context/secret scanning, deterministic builds where practical, per-platform matrix, signed provenance/SBOM subjects, vulnerability/license policy, protected immutable registry promotion and admission verification. Log source revision, builder, materials and outputs without secrets. Patch and rotate builders, constrain cache sharing, measure queue/build latency/cost, and test compromised dependency/secret/policy failures.

### Question 12: How do you debug without a shell in a minimal image?

Strong answer: do not weaken every production image for ad-hoc convenience. Start with metrics/logs/traces/profiles and runtime metadata. Use an authorized ephemeral debug container or node-level tooling that joins only required namespaces under policy, records audit, has no unnecessary credentials and expires. Preserve immutable workload identity and avoid modifying the target filesystem. Reproduce exact digest/config in an isolated environment. The debug mechanism itself is a privileged product requiring RBAC and evidence controls.

### Question 13: Docker reports no space left; what boundaries do you check?

Strong answer: `ENOSPC` can mean blocks or inodes on the exact filesystem handling the write. In containers, locate whether the path belongs to writable upper layer, volume, bind, tmpfs or log driver, then check `df -hT` and `df -i` at that mount. Include Docker backing-store/Desktop VM capacity, deleted-open files, image/build cache and log rotation. Attribute ownership before cleanup; never manually delete overlay metadata. Verify the original write and user outcome after recovery.

### Question 14: How does restart policy interact with exactly-once processing?

Strong answer: restart policy supplies new compute attempts; it cannot guarantee exactly-once business effects. Networks and crashes create an ambiguous interval between external commit and acknowledgement. Use stable idempotency keys, atomic state transitions, transactional outbox/inbox or fenced lease/receipt patterns, and reconciliation. At-least-once delivery plus idempotent effects is often realistic. Track attempts separately from operation identity, cap retries and provide a reviewed unknown/dead-letter path.

### Question 15: What would you monitor for a container platform?

Strong answer: user SLO/error-budget first; workload request/error/duration and business progress; scheduler/pending/rollout/restart/termination; cgroup CPU throttle, memory current/peak/events, PIDs, I/O; node capacity/pressure/kernel/runtime; network DNS/connect/TLS/drop; filesystem blocks/inodes and layer/log/volume growth; image digest/admission/policy drift; registry/build latency/failure; and cost. Correlate service/revision/digest and keep high-cardinality container/trace IDs in appropriate stores. Every alert must have an actionable owner/runbook and a tested failure signal.

### How interviewers distinguish levels

| Level | Typical answer | Missing boundary |
|---|---|---|
| memorized | lists Docker commands | no user, identity or proof limits |
| foundation | explains image/container/process | limited production action |
| competent | correlates lifecycle, cgroup, mounts, network | may ignore business state/security |
| senior | contains safely, reconciles, verifies users, prevents | may need platform economics/governance |
| staff | designs policy/platform feedback loops across teams | must still remain concrete and testable |

A staff answer is not longer for its own sake. It chooses the smallest sufficient model, names owners/trade-offs and creates a reusable guardrail so other teams cannot repeat the failure easily.

## Independent transfer and rubric

The independent transfer is `ASM-0054`. Its blank response template lives at `book/assessments/engineering/ASM-0054-response-template.md`. The case is intentionally answer-isolated. Do not add a solution, derived final state or reviewer answer to the template, lab scenario output, source code comments, UI hints or repository search index.

### Independence rules

Before starting, declare:

- no prior solution or another learner's evidence was consulted;
- controller/verifier/source was not altered;
- Docker/root/network/image gates will not be bypassed;
- raw `scenario` will be captured before derived observations;
- predictions will be timestamped before tests;
- blocked will remain blocked rather than being presented as runtime proof.

If Docker is unavailable or the exact digest is absent, submit static evidence and the verifier's exact blocked reason. Do not fix the environment within the attempt.

### Required workflow

1. Complete the environment/authorization card and draw the expected architecture with text alternative.
2. Run preflight. If blocked, preserve output, explain what static validation proves/does not prove and stop runtime claims.
3. If ready, set up and capture baseline identities/views.
4. Run `inject independent`, then `scenario`. Save that raw output immediately.
5. Prove the scenario contains no derived state, exit, signal, health, diagnosis, recovery, outcome or answer key.
6. Write at least three competing mechanism hypotheses, predicted evidence and one disconfirming result each.
7. Collect the minimum ordered observations; label observation, calculation, inference, hypothesis and unknown.
8. Write a mutation/recovery card before `recover`.
9. Verify operation and exact cleanup. Run the full verifier and preserve output.
10. Transfer the design to one real or realistic production Docker/Kubernetes workload without performing an unauthorized mutation.

This workflow tests scientific discipline. The number of commands is not scored; hypothesis quality, evidence scope, safe decisions and user verification are.

### Fifty-point rubric

| Criterion | 0-3 | 4-6 | 7-8 | 9-10 |
|---|---|---|---|---|
| Independent prediction and identity | answer leakage or identity confused | some predictions; name/tag used loosely | raw-first hypotheses and most IDs separated | timestamped competing/disconfirming hypotheses; artifact/runtime/process/business IDs exact |
| Container mechanism depth | container treated as VM; commands unexplained | basic process/image model | OCI, namespaces/cgroups, layers/mounts, PID1/health/network mostly correct | boundaries traced end-to-end with units, owner and proof limits |
| Recovery and safety | root/pull/broad delete/blind restart | action lacks ownership/abort | exact bounded action and blocked handling | preconditions, blast radius, state preservation, abort, compensation and user proof complete |
| Verification quality | running equals success | checks a few technical fields | security/resource/lifecycle/cleanup matrix | negatives/tamper/refusal plus operation result, timing and scope limitations proven |
| Production and supply-chain transfer | copies local command to production | generic hardening list | immutable artifact, build/admission/runtime/state/rollout design | platform-specific trade-offs, multi-arch, policy evidence, capacity, rollback reconciliation and ownership integrated |

Score bands:

- **0-29:** not safe to operate independently; rebuild the boundary model.
- **30-39:** useful foundation; repeat missing evidence/safety dimensions.
- **40-44:** strong senior-level performance on the scoped case; close explicit gaps.
- **45-50:** mastery candidate; still requires human review and another unfamiliar transfer.

A numeric score never overrides a safety violation. Pulling, running as root, touching a foreign object, broad cleanup, fabricating output, exposing a secret or claiming runtime pass while blocked is an automatic review failure.

### Reviewer prompts

A reviewer should ask the learner to:

1. redraw one boundary without notes;
2. explain one result's does-not-prove limit;
3. change one hypothetical constraint (cgroup v1, ARM64, Kubernetes, remote daemon, durable job) and adapt;
4. defend one recovery trade-off and abort threshold;
5. identify one false-positive/false-negative in health, scanning or telemetry;
6. verify a user outcome rather than a container state;
7. repeat a safe cleanup proof.

Mastery means the learner can transfer reasoning to unfamiliar evidence, challenge a misleading premise and operate within authority. It does not mean memorizing the scenario.

### Portfolio artifact

A sanitized portfolio version may include architecture diagrams, generic hypotheses, evidence taxonomy, a safe lab run, verification matrix and production design. Remove company names, endpoints, tokens, user/customer/job IDs, internal registry paths, node names and raw sensitive logs. Never publish an employer incident or proprietary configuration. State that this is a local educational lab and list its proof limits.

## References and review

The chapter uses versioned primary specifications for OCI/SPDX/SLSA concepts and official Docker documentation for implementation-facing behavior. A specification describes a contract; it does not prove a particular daemon, kernel, storage driver or registry complies. Validate the versions actually deployed.

### Reference map

- **REF-0137 - Open Container Initiative Image Format Specification v1.1.0.** Use for image/index/manifest/config/layer descriptors, media types, digests, DiffIDs, layer application and whiteouts. It defines portable artifact structure, not Docker daemon internals, registry trust or runtime security.
- **REF-0138 - Open Container Initiative Runtime Specification v1.2.0.** Use for runtime bundle/config, lifecycle and Linux runtime settings. An implementation can add layers/components; inspect the deployed runtime and kernel.
- **REF-0139 - Open Container Initiative Distribution Specification v1.1.0.** Use for registry content push/pull and content-addressed distribution behavior. Authentication, authorization, retention and admission policy are deployment concerns beyond the base protocol.
- **REF-0140 - Docker Engine OverlayFS storage-driver documentation.** Use for Docker's OverlayFS/`overlay2` model, copy-on-write and operational prerequisites. Storage behavior depends on host/VM filesystem, kernel and Docker version; do not apply it blindly to another snapshotter/driver.
- **REF-0141 - Docker Engine resource constraints.** Use for Docker memory/CPU/PID configuration concepts. Confirm cgroup version, rootless/Desktop platform, effective hierarchy and orchestrator translation.
- **REF-0142 - Docker Engine security.** Use for daemon, namespaces, capabilities, control groups and broader security model. It is a starting point, not a workload-specific threat model or proof of secure configuration.
- **REF-0143 - SPDX Specification 3.0.** Use for SBOM/software supply-chain data modeling. An SPDX document's quality depends on producer completeness, identity and verification; it is not a vulnerability verdict.
- **REF-0144 - SLSA Provenance v1.0.** Use for provenance predicate/subject/build definition/run details and verification concepts. A provenance statement is useful only under a trust policy for issuer, builder, materials and subject.

### Review checklist

Before considering this chapter understood, demonstrate all of the following without reading the answers:

- draw container versus VM and identify the executing kernel;
- trace name/tag through index, manifest, config, layers and platform selection;
- distinguish blob digest, DiffID, image ID, container ID, PID and job ID;
- explain OverlayFS copy-up/whiteout and each mount lifecycle;
- trace Docker client/daemon/runtime/kernel ownership without overfitting implementation names;
- test PID 1 TERM/children/grace and explain SIGKILL limits;
- distinguish running, startup, liveness, readiness and user correctness;
- decode cgroup memory/CPU/PID values with units and event deltas;
- trace a container service network path across namespaces/publication;
- design a non-root least-privilege runtime with explicit writable paths;
- explain digest, signature, attestation, provenance, SBOM and scanner limits;
- diagnose OOM and storage growth as separate evidence paths;
- reconcile a durable job before restart/rollback;
- write bounded production mutation, abort, rollback/compensation and verification cards;
- prove exact cleanup and state what it does not prove.

### Environment verification note

At authoring review on 2026-08-02, Bash syntax and ShellCheck passed. Ubuntu 24.04 WSL ran as UID 1000 against Docker client/server 29.6.2, and the exact pinned digest was already cached as image ID `sha256:b116e155074440ffd9e449559433feb4cd2341eb3554b1da1c638c976e56451d`. The guarded verifier completed in 83.5 seconds: guided health and independent PID 1 cases, eight observation views, invalid-input/transition, descriptor-tamper, artifact-symlink and foreign-container refusals, answer isolation, root refusal, no-pull policy, exact cleanup and final absence all passed. No registry pull or external network fallback occurred. This proves only the declared local transitions and guards; it does not certify Docker Desktop, the cached image, kernel isolation, production behavior or learner mastery.

### Review cadence

Recheck this chapter by 2027-02-02 or earlier when OCI image/runtime/distribution versions, Docker Engine/Desktop behavior, cgroup/kernel semantics, OverlayFS guidance, SPDX, SLSA provenance or the repository lesson schema changes. During review:

1. compare referenced versioned contracts with currently supported versions;
2. run schema, JSON, Bash syntax and ShellCheck checks;
3. run the guarded verifier on prepared Ubuntu and WSL environments without network pull;
4. retain passed/failed/blocked distinctions and exact tool versions;
5. inspect the lab's fail-closed ownership, tamper/symlink/foreign-container refusals and exact cleanup;
6. review threat model, resource units, command output fields and Docker/Kubernetes transfer statements;
7. ensure independent answer isolation and personal/company-data privacy;
8. perform a human technical and teaching review.

The enduring lesson is not "use Docker." It is: **know which bytes you selected, which kernel runs which process, which boundary owns each state and limit, which controller causes each transition, which user operation may be unknown, and exactly what your evidence and recovery prove.**
