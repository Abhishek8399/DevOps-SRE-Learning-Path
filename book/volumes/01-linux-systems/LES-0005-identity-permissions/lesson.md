---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0005",
  "aliases": ["V01-L05", "identity-permissions"],
  "curriculumIds": ["LNX-004"],
  "slug": "identity-permissions",
  "route": "/book/linux/identity-permissions",
  "order": 5,
  "volume": "01-linux-systems",
  "title": "Identity, permissions, traversal, and least privilege",
  "summary": "Trace an access decision from the exact process credentials through pathname resolution, owner/group/other modes, ACL masks, mount and namespace state, capabilities, mandatory policy, container identity, and the requested operation before changing authorization.",
  "domain": "linux",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 230,
  "prerequisiteLessonIds": ["LES-0002"],
  "prerequisiteCurriculumIds": ["LNX-002"],
  "testedEnvironments": [
    {"platform": "Ubuntu", "version": "24.04 LTS", "support": "required", "notes": "The guided walkthrough is normal-user and read-only; coreutils, util-linux, and namei are required while getfacl is optional."},
    {"platform": "WSL 2 Ubuntu", "version": "24.04", "support": "supported", "notes": "Linux-owned files behave normally; Windows-mounted paths can have drvfs metadata and permission semantics that differ from native Linux filesystems."},
    {"platform": "Docker container", "version": "Linux container", "support": "concept-only", "notes": "Image USER, runtime overrides, user/mount namespaces, capabilities, bind mounts, and host numeric ownership affect access."},
    {"platform": "Kubernetes", "version": "Version-dependent", "support": "concept-only", "notes": "SecurityContext and volume-driver behavior require exact Pod/container, node, CSI, mount, and policy evidence."}
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer"],
  "learningObjectives": [
    "Distinguish real, effective, saved, and filesystem identity; UID/GID names from numeric credentials; and the operator shell from the service process.",
    "Explain read, write, and execute/search semantics for regular files and directories, including owner/group/other class selection and every-parent traversal.",
    "Decode symbolic and octal modes, special bits, umask, access/default ACLs, ACL masks, ownership, inode/link evidence, and access tests.",
    "Separate discretionary modes from mount state, namespaces, capabilities, file attributes, SELinux/AppArmor, and application authorization.",
    "Trace container and Kubernetes numeric identity from image declaration and runtime security context to volume ownership and storage behavior.",
    "Design a narrow reversible repair with positive functional verification and a negative unauthorized-access test instead of chmod 777 or root."
  ],
  "productionSignals": [
    "A service gets EACCES or EPERM while an operator shell succeeds.",
    "A file appears mode 0644 but remains unreachable through a parent directory.",
    "A write fails on a read-only mount despite writable-looking mode bits.",
    "A container works as root but fails under its intended non-root UID.",
    "An ACL entry appears to allow access but its mask removes effective rights.",
    "An AppArmor or SELinux denial accompanies otherwise valid discretionary permissions.",
    "Recursive ownership changes are proposed for a large or shared persistent volume.",
    "A deployment changes image USER, fsGroup, user namespace, or volume driver behavior."
  ],
  "diagrams": [
    {"id": "LES-0005-DIA-001", "title": "Layered access decision", "direction": "left-to-right", "boundaries": ["process credentials", "root/current directory and namespace", "each pathname component", "final inode mode or ACL", "mount and attributes", "capability and LSM policy", "application operation"], "evidencePoints": ["PID/start identity", "Uid/Gid/Groups/CapEff", "readlink and namei", "stat and getfacl", "findmnt and lsattr", "kernel/audit denial", "real service test"], "textAlternative": "The caller's credentials enter its filesystem view, traverse every directory, reach the target inode, then face discretionary access, mount and attribute rules, capabilities, mandatory policy, and finally application-level behavior."},
    {"id": "LES-0005-DIA-002", "title": "Owner group other class selection", "direction": "top-to-bottom", "boundaries": ["effective filesystem UID", "inode owner UID", "effective and supplementary groups", "inode group GID", "ACL entries and mask", "other class"], "evidencePoints": ["numeric uid/gid", "id groups", "stat owner/group", "getfacl effective rights", "requested read/write/search/execute"], "textAlternative": "If caller UID matches owner, use owner class; otherwise matching groups use group-class and ACL-mask rules; otherwise use other. The kernel does not combine owner, group, and other bits to find the most permissive result."},
    {"id": "LES-0005-DIA-003", "title": "Container volume identity path", "direction": "top-to-bottom", "boundaries": ["image USER", "runtime override", "Pod security context", "user and mount namespace", "volume plugin and mount", "numeric inode ownership", "application write"], "evidencePoints": ["image config", "container id output", "runAsUser/runAsGroup/fsGroup", "uid_map/gid_map", "mountinfo", "numeric stat/ACL", "positive and negative operation"], "textAlternative": "Image defaults can be overridden by runtime and Pod configuration; namespace mapping and the volume driver connect container credentials to numeric storage ownership before the application operation is authorized."}
  ],
  "commands": [
    {"id": "LES-0005-CMD-001", "question": "Which credentials does this shell currently carry?", "risk": "read-only", "command": "id; grep -E '^(Uid|Gid|Groups|CapInh|CapPrm|CapEff|CapBnd|NoNewPrivs):' /proc/self/status", "runFrom": "The exact process namespace where the observation is relevant; inspect a service PID separately.", "expectedBranches": [{"when": "UID/GID/groups differ from the service", "meaning": "Shell success or failure cannot stand in for the service access check.", "nextEvidence": "Inspect the exact service PID/start time and its proc status or supervisor configuration."}, {"when": "effective capabilities are nonzero", "meaning": "Capability-based bypasses or privileged operations may change normal mode results.", "nextEvidence": "Decode only required capability bits and inspect bounding/ambient/file sources."}], "proves": "Readable current-process numeric credentials, groups, capability-set encodings, and no-new-privileges state.", "doesNotProve": "Another process's credentials, file access, namespace mapping, or authorization result."},
    {"id": "LES-0005-CMD-002", "question": "What object does the path resolve to and what must be traversed?", "risk": "read-only", "command": "readlink -f -- PATH; namei -l -- PATH", "runFrom": "The same mount/root namespace as the failing process, on an authorized non-sensitive path.", "expectedBranches": [{"when": "a parent lacks applicable x/search", "meaning": "Path resolution can fail before final-file mode matters.", "nextEvidence": "Confirm caller class and ACL on the first blocking component."}, {"when": "a symlink changes the path or mount", "meaning": "The lexical path and resolved ownership boundary differ.", "nextEvidence": "Verify link ownership, intended target, mount namespace, and race-safe application behavior."}], "proves": "Current lexical component metadata and canonicalized path visible to the observing namespace.", "doesNotProve": "Race-free future resolution, ACL/LSM decisions, or another namespace's view."},
    {"id": "LES-0005-CMD-003", "question": "What type, mode, ownership, inode, and link count does the target have?", "risk": "read-only", "command": "stat -c 'type=%F mode=%A octal=%a owner=%U:%G uid=%u gid=%g inode=%i links=%h name=%n' -- PATH", "runFrom": "The responsible filesystem namespace with an exact, authorized path.", "expectedBranches": [{"when": "numeric owner/group do not match intended credentials", "meaning": "Discretionary class selection may explain denial.", "nextEvidence": "Combine actual groups, parent traversal, ACL mask, and requested operation."}, {"when": "link count exceeds one", "meaning": "Multiple directory entries reference this inode.", "nextEvidence": "Find authorized same-filesystem ownership before assuming one deletion or chmod is isolated."}], "proves": "Target metadata returned by stat at that instant.", "doesNotProve": "Complete authorization, pathname stability, private page/block ownership, or which rule caused a past denial."},
    {"id": "LES-0005-CMD-004", "question": "Do ACL entries change the effective discretionary rights?", "risk": "read-only", "command": "getfacl -p -- PATH", "runFrom": "An Ubuntu shell with the optional acl package, in the relevant namespace.", "expectedBranches": [{"when": "a named entry is limited by mask", "meaning": "Displayed requested bits exceed effective group-class rights.", "nextEvidence": "Calculate the matching entry intersected with mask and the requested operation."}, {"when": "no extended ACL exists", "meaning": "Base entries correspond to ordinary mode classes.", "nextEvidence": "Continue to mount, attribute, namespace, capability, and LSM boundaries."}], "proves": "Readable access/default ACL entries and effective-mask annotations for the object.", "doesNotProve": "Mount/LSM authorization, application identity, or inherited ACLs of future objects."},
    {"id": "LES-0005-CMD-005", "question": "Which filesystem and mount options govern this resolved path?", "risk": "read-only", "command": "findmnt -T PATH -o TARGET,SOURCE,FSTYPE,OPTIONS", "runFrom": "The failing process's mount namespace where possible.", "expectedBranches": [{"when": "ro is present", "meaning": "The mount independently rejects filesystem mutation.", "nextEvidence": "Identify why it is read-only and the owning recovery path; do not chmod or remount blindly."}, {"when": "noexec or nosuid is present", "meaning": "Execution or privilege-transition semantics are constrained.", "nextEvidence": "Match the actual failed operation and security intent rather than treating all permission errors alike."}], "proves": "The selected mount target, source, filesystem type, and visible options.", "doesNotProve": "Underlying storage health, another namespace's mount, LSM policy, or application authorization."},
    {"id": "LES-0005-CMD-006", "question": "Is an enforcing security policy recording the denial?", "risk": "read-only", "command": "journalctl -k --since 'TIME-WINDOW' | grep -Ei 'apparmor|avc|denied'", "runFrom": "An authorized host shell with a bounded incident window; access may be restricted.", "expectedBranches": [{"when": "PID/path/operation/profile align", "meaning": "The recorded mandatory-policy denial supports that layer as a blocker.", "nextEvidence": "Validate intended access and propose the narrowest reviewed policy correction."}, {"when": "nothing matches", "meaning": "No visible matching event was found; retention, audit routing, access, and other layers remain open.", "nextEvidence": "Record the evidence gap and use platform-specific audit or policy tooling."}], "proves": "Matching kernel-journal records visible under the caller's permissions and selected window.", "doesNotProve": "Absence of denial, safe policy disablement, or that all discretionary and mount gates permit access."}
  ],
  "labs": [
    {"id": "LES-0005-LAB-001", "title": "Read one Ubuntu permission path", "mode": "guided", "environment": "Ubuntu 24.04, normal user, one authorized non-sensitive existing path", "timeMinutes": 20, "privilege": "No sudo or root; read-only observation.", "network": "No network access.", "changes": ["No persistent or runtime mutation; the selected path is only read."], "abortConditions": ["The shell is root.", "The target contains secrets or production data.", "The target does not exist.", "A required base command is missing.", "Any step would require changing identity, ownership, permissions, mount, capability, or policy."], "recovery": "No recovery is required because the walkthrough does not mutate state.", "cleanupProof": "bash lab.sh cleanup reports cleanup=not-required, mutation=none, and cleanup_proven=true.", "path": "book/labs/LES-0005-permission-path"}
  ],
  "incidents": [
    {"id": "LES-0005-INC-001", "signal": "The file is 0644 but the service receives permission denied.", "firstThought": "Final-file read may be allowed while parent traversal, actual service identity, ACL mask, mount, namespace, or LSM still denies.", "safePath": "Bind to exact process credentials and operation, resolve every component, then inspect layered controls before a narrow fix.", "trap": "Run recursive chmod from the lexical path."},
    {"id": "LES-0005-INC-002", "signal": "A write fails after a storage or node event although mode and ownership did not change.", "firstThought": "The filesystem may be read-only or remounted after an error; discretionary permissions are not the only writer authority.", "safePath": "Use findmnt on the exact resolved path, inspect kernel/storage evidence and recovery ownership, preserve data, and avoid blind remount.", "trap": "Keep changing mode bits or force a writable remount."},
    {"id": "LES-0005-INC-003", "signal": "A mounted volume works with UID 0 but fails with UID 10001.", "firstThought": "Root may bypass ordinary checks; trace numeric identity, volume ownership, group/ACL, namespace mapping, driver behavior, and LSM policy.", "safePath": "Preserve the non-root failure, compare declared/effective identities, inspect storage metadata, implement an owned narrow correction, and test allowed plus denied identities.", "trap": "Restore root or chmod 777 as the permanent solution."}
  ],
  "assessmentIds": ["ASM-0268", "ASM-0269", "ASM-0270"],
  "referenceIds": ["REF-1209", "REF-1210", "REF-1211", "REF-1212", "REF-1213", "REF-1214"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-09-02",
  "reviewAfter": "2027-03-02",
  "limitations": [
    "The guided walkthrough observes one current-user path and intentionally performs no denial injection, identity switch, ACL/capability/mount/policy change, or container runtime.",
    "Access-check details vary with filesystem, network storage, idmapped mounts, user namespaces, LSM policy, CSI driver, and platform version.",
    "journal and ACL visibility may be restricted; missing output is an evidence gap rather than proof a control is absent.",
    "Formal review, real-browser QA, representative service/volume tests, independent learner transfer, delayed recall, and mastery remain unproved."
  ]
}
---

# Identity, permissions, traversal, and least privilege

## What you see and first thought

An application says `Permission denied`. Someone runs `ls -l` on the final file, sees `-rw-r--r--`, and concludes Linux is wrong. Another person proposes `chmod -R 777`.

Stop there. Permission denied is not “a bad file mode.” It is the result of one attempted operation by one process identity, through one namespace and resolved path, at one time. The kernel may reject path traversal, the final inode operation, a mount rule, a capability check, a file attribute, or mandatory policy. The application may also translate another error into the same message.

Keep one sentence: **identity asks who, pathname asks where, operation asks what, and policy decides whether.** Preserve all four before changing anything.

## Terms before commands

**UID and GID:** Numeric user and group identifiers used by kernel access checks. Names are local directory-service mappings; the number is the important evidence at a filesystem boundary.

**Real, effective, saved, and filesystem IDs:** A process can carry multiple identity values. Effective/filesystem credentials normally drive access checks; set-user-ID transitions and specialized APIs can make them differ. Use the exact process, not the login name.

**Supplementary groups:** Additional GIDs attached to a process. A new group membership does not automatically enter an already-running service; it usually needs a new process/session.

**Mode classes:** Owner, group, and other each have read/write/execute bits. The kernel selects the applicable class; it does not combine all three to find the most generous permission.

**Regular-file read/write/execute:** Read returns content, write changes content, and execute permits program execution subject to format, mount, and policy.

**Directory read/write/search:** Read lists directory entries; write creates/removes/renames entries; execute means search/traverse and is required on every pathname component.

**Octal mode:** Three-bit groups encode r=4, w=2, x=1. `640` means owner rw, group r, other none. Leading digits can represent setuid, setgid, and sticky.

**umask:** A process mask that removes permission bits from a creation request. It does not retroactively change existing objects and is not the final mode formula when default ACLs apply.

**Access ACL and mask:** A POSIX ACL can name users/groups. The ACL mask limits effective permissions of the group class, including named users and groups except the owner entry.

**Default ACL:** Directory ACL entries inherited as the starting access ACL for new children, then affected by requested creation mode. It is not an access rule on the directory itself.

**Capabilities:** Separately named slices of traditional root privilege carried in process sets and sometimes file metadata. A capability can bypass a narrow class of checks but remains powerful.

**Special bits:** setuid/setgid may affect execution identity or directory group inheritance; sticky restricts removal/rename in shared writable directories.

**Mount namespace and options:** A process sees its own mount tree. `ro`, `noexec`, and `nosuid` independently constrain operations even when inode modes look permissive.

**LSM/MAC:** Linux Security Modules such as AppArmor and SELinux can enforce mandatory policy after discretionary checks. Never disable them merely to test a guess.

**EACCES and EPERM:** Both describe denial families but arise from different interfaces and policies. Preserve syscall, arguments, errno, PID, and policy record when available.

**Least privilege:** Give the intended principal only the operations and scope it requires, for only the needed time, with an owner, review, and revocation path.

## Architecture map

```text role=diagram lines=off
requested open/read/write/exec
            |
process PID + start + effective UID/GIDs + capabilities
            |
root/cwd + mount namespace -> symlink/path resolution
            |
directory search check on / -> opt -> app -> config
            |
final inode: type + owner/group/other + ACL mask
            |
mount options + immutable state + capability rules + AppArmor/SELinux
            |
kernel allow/deny -> application behavior -> user-visible operation
```

The final file is only one gate. A strong incident record states the first failed boundary and the evidence that excludes earlier ones.

## Request or state path

Suppose PID 4200 opens `/opt/app/config/settings.yaml` for read:

1. determine its root directory, current/mount namespace, filesystem UID and groups;
2. start at `/` because the path is absolute;
3. resolve each component and symlink under that namespace;
4. require search permission on `/`, `/opt`, `/opt/app`, and `/opt/app/config`;
5. select one discretionary class or matching ACL entry for the final inode;
6. evaluate mount, capability, attribute, and mandatory-policy rules;
7. perform the read and return success or an errno;
8. let the application interpret the result.

Deletion is different: unlinking a name normally needs write and search on the parent directory, not write on the file. Renaming checks directories. Executing needs file execute plus traversal and can be blocked by `noexec`. Always name the operation.

## Failure zoom

### Shell works, service fails

The shell and service can differ in UID, groups, capabilities, umask, root/cwd, mount namespace, environment, systemd hardening, and LSM profile. Reproduce only with approved tooling and never assume `sudo -u` perfectly reproduces a container or unit.

### Final mode looks correct

Search can fail on a parent; an ACL mask can reduce named rights; the resolved symlink can enter another mount; `ro` can reject write; AppArmor/SELinux can deny. `ls -l` is orientation, not complete proof.

### Root works

Root or capabilities can bypass discretionary access. This proves the operation is possible with more authority, not that more authority is justified. Preserve the non-root failure because it shows the missing contract.

### Recursive chmod or chown

Recursive mutation can cross unexpected links/mounts, touch shared data, destroy carefully different modes, race with writers, and take hours. Define exact target population, inode types, ownership authority, rollback, and negative tests before any bulk change.

## Internals and state ownership

The inode stores numeric owner, group, type, mode, timestamps, link count, and references to extended metadata. Directory entries map names to inode numbers. Path resolution is performed in the caller's filesystem view, so the same textual path can reach different objects in host and container.

For base modes, owner match selects owner bits. Otherwise a matching effective/supplementary GID selects group bits. Otherwise other bits apply. An ACL expands this logic; its mask caps the group-class entries. More permissive “other” bits do not override a restrictive owner class for the owner.

Creation begins with an application's requested mode. umask removes bits when ordinary mode creation applies. A directory default ACL can derive the child's access ACL and mode. Therefore a unit's umask, application mode, parent default ACL, setgid directory, and storage behavior all matter.

Capabilities have inheritable, permitted, effective, bounding, and ambient relationships. `CapEff` is a hexadecimal bitmask, not a friendly list; decode with approved tools and exact kernel capability definitions. `NoNewPrivs` prevents exec from gaining new privilege through setuid/setgid or file capabilities, but it does not remove privilege already held.

Mount options and LSMs have different owners. A filesystem remounted read-only after errors is a storage/recovery problem. A policy denial is a security contract problem. Changing inode mode cannot solve either.

## Evidence table

| Question | Evidence | Scope | Useful branch | Proves | Does not prove |
|---|---|---|---|---|---|
| Who made the request? | PID/start, `id`, proc Uid/Gid/Groups/CapEff | exact process lifetime | shell differs from service | visible credentials | access result |
| Where does the path go? | root/cwd, mount namespace, `readlink`, `namei` | failing namespace | symlink/mount divergence | current resolution evidence | race-free future path |
| Which class applies? | numeric `stat` plus process groups | each inode | owner, group, or other | selected base class inputs | ACL/LSM result |
| Does ACL change rights? | `getfacl` and mask | exact inode | effective rights reduced | visible ACL algorithm inputs | mount or MAC permission |
| Can this mount perform it? | `findmnt -T` | mount namespace | ro/noexec/nosuid | visible mount constraint | underlying health |
| Did mandatory policy deny? | bounded audit/kernel event | profile/label and time | matching PID/path/op | visible policy denial | safe policy change |
| Did the fix preserve least privilege? | positive operation plus negative identity | user/service boundary | allow intended, deny unintended | tested outcomes | all future paths |

## Command decoders

### Read the caller, not the username assumption

```bash role=command lines=on
id
grep -E '^(Uid|Gid|Groups|CapInh|CapPrm|CapEff|CapBnd|NoNewPrivs):' /proc/self/status
```

```text role=output lines=off
uid=1000(learner) gid=1000(learner) groups=1000(learner),27(sudo)
Uid:    1000    1000    1000    1000
Gid:    1000    1000    1000    1000
Groups: 27 1000
CapInh: 0000000000000000
CapPrm: 0000000000000000
CapEff: 0000000000000000
CapBnd: 000001ffffffffff
NoNewPrivs: 0
```

`id` prints real/effective identity in a readable form for the current process. The four Uid/Gid columns in proc status represent real, effective, saved-set, and filesystem values. `Groups` contains numeric supplementary GIDs. Capability sets are hexadecimal; all-zero effective means this process currently exercises no effective capability bits, while a nonzero bounding set does not mean those bits are effective.

This output describes the shell, not PID 4200. For a service, use its exact `/proc/PID/status` after recording PID and start time, subject to authorization.

### Resolve and walk the path

```bash role=command lines=on
readlink -f -- /opt/app/config/settings.yaml
namei -l -- /opt/app/config/settings.yaml
```

```text role=output lines=off
f: /opt/app/config/settings.yaml
drwxr-xr-x root root /
drwxr-xr-x root root opt
drwxr-x--- app  app  app
drwxr-x--- app  app  config
-rw-r----- app  app  settings.yaml
```

The first character is object type: `d` directory, `-` regular file, `l` symbolic link. Each triplet is owner, group, other. Directory `x` means search/traverse. If the service matches neither UID nor GID for `app` and other has `---`, path resolution stops there even if the final file were 0644.

`readlink -f` canonicalizes existing components in this observation; it does not make a later application open race-free. On hostile writable paths, application code needs directory-file-descriptor and constrained-resolution APIs rather than check-then-open logic.

### Read exact inode metadata

```bash role=command lines=on
stat -c 'type=%F mode=%A octal=%a owner=%U:%G uid=%u gid=%g inode=%i links=%h name=%n' -- PATH
```

`%F` names type; `%A` symbolic mode; `%a` octal bits; `%U/%G` resolved names; `%u/%g` numeric owner; `%i` inode number within this filesystem; `%h` hard-link count. Names can differ across containers and hosts while numbers remain the stored metadata—though user namespaces can translate those numbers too.

An inode number is unique only within a filesystem and can be reused after deletion. Multiple hard links mean one mode/owner mutation affects every name for that inode.

### Decode octal and directory semantics

Each class uses r=4, w=2, x=1:

- `7 = 4+2+1 = rwx`
- `6 = 4+2 = rw-`
- `5 = 4+1 = r-x`
- `4 = r--`
- `0 = ---`

For a regular file, `640` is owner read/write, group read, other none. For a directory, `750` is owner full directory operations, group list/traverse, other none. Directory write without search is rarely useful; deletion depends primarily on the parent directory and sticky rules.

### Read ACL and its mask

```bash role=command lines=on
getfacl -p -- PATH
```

```text role=output lines=off
user::rw-
user:api:rwx                 #effective:r--
group::r--
mask::r--
other::---
```

The named `api` entry asks for rwx, but the mask permits only r. Its effective result is intersection: rwx AND r-- equals r--. Owner and other entries are not limited by the ACL mask. A default ACL appears only on directories and influences new children; it does not by itself grant access to the directory.

### Read the mount boundary

```bash role=command lines=on
findmnt -T PATH -o TARGET,SOURCE,FSTYPE,OPTIONS
```

`TARGET` is the selected mountpoint, `SOURCE` its backing source, `FSTYPE` the filesystem type, and `OPTIONS` visible mount flags. `ro` blocks mutation; `noexec` blocks direct execution through that mount; `nosuid` suppresses setuid/setgid privilege transitions. A bind mount and container mount namespace can make the relevant options differ from the host shell.

### Read policy evidence narrowly

```bash role=command lines=on
journalctl -k --since '2026-09-02 10:00:00' --until '2026-09-02 10:10:00' |
  grep -Ei 'apparmor|avc|denied'
```

Correlate timestamp, executable/profile/domain, requested operation, path/label, PID, and result. An empty result may mean no denial, no permission, different audit destination, lost retention, or wrong window. It never justifies disabling enforcement.

## Decision path

```text role=diagram lines=off
Exact operation fails with EACCES/EPERM
  |
  +-- preserve PID/start + errno/syscall + path + time
  |
  +-- actual credentials differ? -> fix service identity contract
  |
  +-- resolution/traversal fails? -> fix one owned component or intended group/ACL
  |
  +-- final mode/ACL denies? -> grant only required operation to intended principal
  |
  +-- mount/attribute denies? -> use storage/filesystem recovery owner
  |
  +-- LSM policy denies? -> validate intent and review narrow policy
  |
  +-- application still fails? -> application auth, locks, schema, dependency

Before mutation: exact target set -> backup/rollback -> canary -> abort
After mutation: intended operation succeeds AND unauthorized identity stays denied
```

During an outage, restoring root is rarely the safest recovery. Prefer rollback to the last compatible image/security context, replacement of one bad replica, or a narrow group/ACL correction owned by the storage and security contracts. Preserve the denial before change.

## Guided Ubuntu lab

From `book/labs/LES-0005-permission-path` on Ubuntu, choose only a non-sensitive path you own or are authorized to inspect:

```bash role=command file=book/labs/LES-0005-permission-path/lab.sh lines=on
bash lab.sh check
bash lab.sh observe "$PWD/README.md"
bash lab.sh cleanup
```

Create an evidence table with caller numeric identity, capability fields, lexical/resolved path, each component's type/owner/mode, chosen class, required directory action, target operation, ACL/mask, mount options, and proof limits.

Do not create a denied state. Do not run sudo, chmod, chown, setfacl, setcap, remount, or policy-disable commands. The goal is to reason accurately from real harmless metadata. Cleanup is `not-required` because the lab writes nothing.

## Production transfer

**systemd:** inspect `User`, `Group`, supplementary groups, umask, working/root directories, capability bounding/ambient sets, no-new-privileges, protect-system/home, read-write paths, private mounts, and AppArmor/SELinux. Manager configuration plus exact process credentials form the contract.

**Docker/OCI:** image `USER` is a default, not immutable runtime truth. Bind mounts retain host ownership semantics; named volumes and user namespaces differ. Avoid baking writable application data into root-owned locations and testing only as root.

**Kubernetes:** inspect pod- and container-level `runAsUser`, `runAsGroup`, `supplementalGroups`, `fsGroup`, `fsGroupChangePolicy`, capabilities, allowPrivilegeEscalation, read-only root filesystem, SELinux options, volume type, and CSI behavior. Configured fsGroup is not proof ownership was changed.

**NFS and managed storage:** root squashing, server-side ACLs, identity-domain mapping, protocol versions, and storage-side policy can override local assumptions. Identify the actual writer authority before changing local metadata.

**CI runners:** runner user, container UID, checkout umask, workspace ownership, cache/artifact extraction, service containers, and host mounts cause “works locally” differences. Fix the execution contract rather than granting broad workspace permission.

## Reliability, security, observability, capacity, and cost

**Reliability:** permission incidents often recur after rollout, reschedule, restore, or new-volume creation because the fix changed one live inode rather than its provisioning owner. Test cold start and replacement, not only the current process.

**Security:** broad read risks confidentiality; broad write risks integrity and execution; root/capabilities increase blast radius. Redact paths, usernames, labels, and file contents. Evidence collection never authorizes reading secrets.

**Observability:** record sanitized principal, operation, object class, policy layer, errno, deployment, node, volume, and decision outcome. Avoid unbounded path labels and secret-bearing command lines. Audit high-risk changes and expiry.

**Performance:** recursive chmod/chown and fsGroup ownership walks can cause metadata storms, startup delay, and shared-volume contention. Measure object count and driver behavior; prefer provisioning-correct ownership.

**Capacity:** identity stores, group expansion, ACL entries, audit pipelines, and storage metadata operations have limits. Large supplementary-group sets or volume scans can increase latency.

**Cost:** privileged exceptions create review and incident cost; repeated startup ownership scans consume compute and storage IOPS. A predictable identity/storage contract is usually cheaper than recurring emergency mutation.

## Traps and prevention

| Trap | Why it fails | Better habit |
|---|---|---|
| Final file is readable, so path is readable | Every parent requires search | Walk every component as actual identity |
| Kernel combines owner/group/other | It selects the applicable class | Calculate one class plus ACL algorithm |
| Directory x means execute a folder | It means search/traverse | Name the directory operation |
| chmod 777 proves the cause | It changes several rights and exposure | Preserve evidence and alter one narrow rule |
| Root success is the fix | Privilege can bypass the intended boundary | Repair non-root ownership contract |
| ACL named user rwx always gets rwx | The mask can reduce effective rights | Intersect group-class entry with mask |
| chmod fixes read-only filesystem | Mount rule is independent | Diagnose mount/storage state |
| Disable AppArmor/SELinux | Removes a defense and hides intent | Correlate denial and review narrow policy |
| Recursive chown is harmless | It can cross ownership and overload metadata | Define exact targets, canary, rollback |
| fsGroup guarantees access | Driver and volume behavior vary | Verify actual mount and inode result |

## Memory card and retrieval

Remember **I-P-O-L-A**:

- **I — Identity:** exact PID/start, numeric UID/GIDs, groups, capabilities.
- **P — Path:** root/cwd, namespace, symlinks, every directory component.
- **O — Operation:** list, search, read, write, create, unlink, rename, execute.
- **L — Layers:** mode class, ACL mask, mount, attributes, capability, LSM.
- **A — Allow narrowly:** owner, reversible change, positive and negative proof.

Questions:

1. Why can mode 0644 still produce permission denied?
2. What does x mean on a directory?
3. Does Linux combine owner, group, and other bits?
4. How does an ACL mask affect a named user?
5. Why can root success hide the defect?
6. What does `ro` change compared with mode bits?
7. Why can fsGroup configuration and actual volume ownership disagree?
8. What must verification prove after a least-privilege fix?

## Complete answers

**1. 0644 can still fail:** the service may differ from the shell, a parent may deny search, a symlink may resolve elsewhere, ACL mask can restrict rights, the mount may be read-only, an LSM may deny, or the requested operation may be write rather than read. Bind every conclusion to exact identity/path/operation.

**2. Directory x:** it is search/traversal. It lets the process look up a known child and pass through the component when other gates permit. Directory r lists names; w changes entries, normally together with x.

**3. Class selection:** no. Owner match uses owner class. Otherwise matching effective/supplementary groups use group class/ACL logic. Otherwise other applies. A restrictive owner class is not rescued by permissive other bits.

**4. ACL mask:** named-user, named-group, and owning-group entries in the group class are intersected with the mask. `rwx` entry with `r--` mask yields effective `r--`.

**5. Root success:** UID 0 or capabilities can bypass normal discretionary rules. It shows additional authority changes the outcome but does not show which minimum right is missing or justify permanent privilege.

**6. Read-only mount:** it rejects mutation at the mount/filesystem boundary even if an inode's selected mode/ACL grants write. chmod cannot make a read-only mount writable.

**7. fsGroup disagreement:** volume type, CSI driver implementation, existing ownership, change policy, user namespace, mount behavior, and platform version determine what is applied. Read actual numeric metadata and tested operation.

**8. Verification:** the intended service identity completes the real bounded operation and durable read-back while an unauthorized identity remains denied. Also verify user outcome, restart/replacement durability, rollback readiness, audit, and no unexpected target changes.

## Product-company interview

**Scenario:** A checkout Pod worked as root. A hardening rollout sets UID 10001, and writes to a shared volume fail. The proposed fix is `runAsUser: 0` plus `chmod -R 777`.

**Strong opening:** “Root success is evidence that privilege masks the missing contract, not a safe solution. I will preserve the non-root failure, map numeric identity from image and securityContext to the volume authority, and identify the first denied layer before one reversible canary.”

Pause rollout if capacity is threatened. Record Pod UID, container ID, image digest, node, volume/PVC/PV/CSI identity, operation/errno/path, and timestamps. Inspect declared image USER versus actual id/groups/capabilities, securityContext, user namespace, mountinfo, numeric owner/mode/ACL on every component, fsGroup behavior, mount flags, and LSM/admission events. Compare old/new and healthy/failing cohorts.

Choose the owner-level fix: predictable image/runtime ID, correctly provisioned storage group, narrow ACL, supported fsGroup behavior, or bounded init correction over a verified target set. Canary it. Verify harmless write plus durable read-back, user transaction, rollout replacement, metadata latency, and denial for an unauthorized identity.

**Weak answer:** root or 777. It defeats least privilege, expands data-write risk, may trigger huge recursive I/O, and never fixes ownership design.

**Follow-up — fsGroup is already set:** configuration is intent. Inspect actual supplementary groups, driver support, mount ownership, existing inode ownership, change policy, events, and tested access.

**Follow-up — recursive chown would take two hours:** stop. Quantify targets, shared writers, hard links/mount boundaries, recovery window, and storage capacity. Prefer provisioning or a narrow top-level/group design; schedule any authorized migration with canary, checkpoint, rollback, and monitoring.

**Follow-up — AppArmor denial also appears:** keep discretionary and mandatory controls separate. Validate the workload's required operation, ensure path/identity is correct, then review the narrow profile rule. Do not disable enforcement.

## Independent transfer and rubric

On disposable Ubuntu, inspect one authorized, non-sensitive existing path as your normal user. Do not create a failure or change identity, mode, owner, ACL, capability, mount, attribute, or policy.

Deliver an environment card, layered diagram, field-by-field evidence table, manual allow/deny reasoning for a hypothetical service identity, narrow proposed remediation with owner/rollback, positive and negative tests, no-mutation cleanup proof, redactions, limitations, and assistance disclosure.

Rubric: safety/provenance 4; path resolution 4; layered authorization 4; least-privilege repair 4; production transfer 4. A reviewer must inspect original evidence and reasoning. Repository validation, reading progress, or AI help does not award mastery.

## References and review

- `REF-1209`: Linux pathname resolution and directory search.
- `REF-1210`: POSIX ACL access algorithm, masks, and defaults.
- `REF-1211`: Linux capability sets and privilege division.
- `REF-1212`: mount options and namespace behavior.
- `REF-1213`: Linux Security Modules and AppArmor/SELinux context.
- `REF-1214`: Kubernetes Pod/container security context.

Review by 2027-03-02 or earlier when Ubuntu, Linux permission/capability behavior, util-linux, ACL tooling, LSM policy, Docker/Kubernetes identity, CSI behavior, or reader contracts change. Re-run schema, references, route/search/state compatibility, Bash syntax, lab static contract, reader tests, typecheck, lint, and build. Ubuntu execution and independently reviewed learner transfer remain separate gates.
