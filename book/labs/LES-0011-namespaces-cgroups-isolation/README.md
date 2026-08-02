# LES-0011 lab: see the boundary before changing the limit

This lab turns a container mystery into four separate questions:

```text
namespace view  -> what state can the process see?
cgroup policy   -> what is counted, shared, throttled, or capped?
security policy -> what operations may the process perform?
user operation  -> what actually succeeded or failed?
```

It does **not** create a real container, namespace, cgroup, pod, memory spike,
CPU load, process storm, mount, socket, or network request. A deterministic
Python model prints fixed evidence. Bash records only small summaries in one
guarded temporary directory.

The optional `host-observe` command reads only the current lab shell/process
view: its namespace links, cgroup membership, and cgroup filesystem type. It
does not inspect other users, enumerate workloads, or write kernel state.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| User | Normal non-root user; root is refused before lab mutation |
| Time | 30-45 minutes guided; verifier normally completes in seconds |
| CPU | No load generator; short foreground Bash and Python commands only |
| Memory | No allocator pressure; fixture process normally uses less than 32 MiB |
| Disk | Less than 256 KiB in one guarded root and one UID-scoped descriptor |
| Network and ports | None; no socket, image pull, API call, or cloud resource |
| Packages | No installation; Bash, Python 3.8+, util-linux and base Ubuntu tools |
| Privilege | No `sudo`, capability, runtime socket, cgroup write, or namespace join |
| Persistent processes | None |
| Cost | No paid resource |
| Mutation boundary | One exact direct child of `/tmp` and one exact state file |

The script ignores `TMPDIR` and explicitly uses `/tmp`. Before mutation it
requires `/tmp` to be a real, root-owned, sticky directory.

## Files

```text
LES-0011-namespaces-cgroups-isolation/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- isolation_model.py
```

The model is copied mode `0500` into the private lab root. Strict operations
compare that copy byte-for-byte with the reviewed repository source.

## Commands and risk

Run commands from this directory.

| Command | Risk | Purpose |
|---|---|---|
| `bash lab.sh check` | Read-only | Check dependencies, safety boundary, and registered state. |
| `bash lab.sh host-observe` | Read-only | Read this process's namespace/cgroup view. |
| `bash lab.sh setup` | Bounded mutation | Create the private state. |
| `bash lab.sh status` | Read-only | Validate and summarize state. |
| `bash lab.sh baseline` | Bounded mutation | Record fixed known-good evidence once. |
| `bash lab.sh inject guided` | Bounded mutation | Select the guided virtual incident. |
| `bash lab.sh inject transfer` | Bounded mutation | Select the answer-isolated virtual incident. |
| `bash lab.sh observe identity` | Read-only | Read stable virtual workload/cgroup identity. |
| `bash lab.sh observe resources` | Read-only | Read virtual gauges and configured ceilings. |
| `bash lab.sh observe events` | Read-only | Read virtual cumulative resource events. |
| `bash lab.sh observe operation` | Read-only | Read the modeled user-operation result. |
| `bash lab.sh recover` | Bounded mutation | Record restoration to virtual known-good state. |
| `bash lab.sh verify` | Bounded mutation | Record a separate post-recovery operation check. |
| `bash lab.sh cleanup` | Bounded mutation | Remove only validated allowlisted state. |
| `bash lab.sh reset` | Bounded mutation | Guarded cleanup followed by setup. |
| `bash verify.sh` | Bounded mutation | Test lifecycle and refusal boundaries from clean state. |

Arguments are closed allowlists. Extra arguments, paths, shell fragments,
unknown cases, and unknown views are refused.

## Preflight

```bash
bash lab.sh check
bash lab.sh host-observe
```

A clean check ends with:

```text
lesson_id=LES-0011
environment=ready
privilege=normal-user
network=none
execution=deterministic-virtual-model
state=absent
next_command=bash lab.sh setup
```

`host-observe` returns dynamic local fields:

```text
lesson_id=LES-0011
host_observation=read-only
pid=<current shell process ID>
uid=<effective numeric UID>
namespace_mnt=mnt:[...]
namespace_pid=pid:[...]
namespace_net=net:[...]
namespace_user=user:[...]
namespace_uts=uts:[...]
namespace_ipc=ipc:[...]
namespace_cgroup=cgroup:[...]
namespace_time=time:[...] or unavailable
cgroup_filesystem=cgroup2 or another observed value
cgroup_membership=<current visible v2 path or unavailable>
mutation=none
```

Treat every value as local and point-in-time. A namespace number is useful for
same-type comparison on this running system; it is not a security score or
container identity. `unavailable` means the read did not supply evidence.
Do not install, elevate, or remount anything to force preferred output.

Before saving output, remove username, hostname, random temporary path,
addresses, employer data, and unrelated command text.

## Guided lifecycle

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh baseline
bash lab.sh inject guided
```

Before observing the incident, write:

```text
Exact failed operation:
Workload and instance identity:
Known-good values:
What is a namespace view:
What is a cgroup configuration:
What is a point-in-time gauge:
What is a cumulative counter:
Top three mechanisms:
Prediction for first observation:
```

Retrieve one owner at a time:

```bash
bash lab.sh observe identity
bash lab.sh observe resources
bash lab.sh observe events
bash lab.sh observe operation
```

Do not say "high memory" until you state the unit, scope, and ceiling. Do not
say "the counter rose" until you show baseline, current value, identity
continuity, and the subtraction. Do not say "root cause" when evidence proves
only an enforcement mechanism.

## Baseline contract

The known-good record has exact ordered fields:

```text
record=baseline
case=baseline
operation_success=true
workload_id=report-worker
instance_id=ctr-a1
namespace_view=workload-a
cgroup_id=cg-91
memory_current_bytes=268435456
memory_max_bytes=536870912
memory_oom=0
memory_oom_kill=0
cpu_nr_throttled=2
pids_current=18
pids_max=128
pids_max_events=0
```

Field types:

| Field | Type and unit | Interpretation boundary |
|---|---|---|
| `record`, `case` | record labels | identify fixture output, not a Linux object |
| `operation_success` | boolean outcome | modeled operation only |
| `workload_id` | logical identity | can outlive one process/container |
| `instance_id` | fixture instance identity | joins baseline/current in the model |
| `namespace_view` | virtual identity | names a modeled view, not a kernel inode |
| `cgroup_id` | virtual identity | names a modeled cgroup object |
| `memory_current_bytes` | point-in-time gauge, bytes | current modeled charged memory |
| `memory_max_bytes` | configuration, bytes | modeled hard ceiling |
| `memory_oom` | cumulative counter, events | modeled OOM conditions |
| `memory_oom_kill` | cumulative counter, events | modeled OOM kill events |
| `cpu_nr_throttled` | cumulative counter, periods | modeled quota-throttled periods |
| `pids_current` | point-in-time gauge, tasks | modeled current task use |
| `pids_max` | configuration, tasks | modeled task ceiling |
| `pids_max_events` | cumulative counter, events | modeled rejected task creations |

`536870912` bytes is 512 MiB and `268435456` bytes is 256 MiB. The model
uses powers of 1024. It does not allocate those bytes.

## Observation contracts

Every observation begins with `record`, `case`, and `view`.

| View | Remaining exact fields |
|---|---|
| `identity` | `workload_id`, `instance_id`, `namespace_view`, `cgroup_id` |
| `resources` | `memory_current_bytes`, `memory_max_bytes`, `cpu_nr_throttled`, `pids_current`, `pids_max` |
| `events` | `memory_oom`, `memory_oom_kill`, `cpu_nr_throttled`, `pids_max_events` |
| `operation` | `operation`, `operation_success`, `error` |

In the guided case, compare the baseline and observed identities before using a
counter delta. Explain why a finite memory maximum can matter even when a host
has spare memory. Explain why an OOM-kill event establishes enforcement but
does not identify a leak, allocation call site, or correct production limit.

The transfer case intentionally has no values, diagnosis, or solution in this
README. Discover it through the interface. Do not inspect the fixture source,
verifier expectations, another learner's submission, generated site files, or
repository history before independent review.

## Recovery and operation verification

After recording a diagnosis and recovery prediction:

```bash
bash lab.sh recover
bash lab.sh verify
bash lab.sh status
```

Recovery output fields are:

```text
record
case
action
operation_success
memory_current_bytes
memory_oom_kill_delta_after
cpu_nr_throttled_delta_after
pids_current
pids_max_events_delta_after
```

Verification output fields are:

```text
record
case
operation
operation_success
durable_outputs
duplicate_outputs
lost_outputs
verification_scope
```

The final field is always `deterministic-model-only`. Recovery means the
fixture state changed to its fixed known-good record. Verification means one
modeled operation returned its fixed correct outcome. Neither proves a Linux
resource was changed, production remediation is safe, or the learner reasoned
independently.

## Cleanup

```bash
bash lab.sh cleanup
bash lab.sh check
```

Successful cleanup ends with:

```text
cleanup=complete
state=absent
cleanup_proven=true
```

The proof is scoped to the exact descriptor, registered root, and matching
current-UID candidates at the final point-in-time check. It is not a claim that
no audit/access record exists or that another process cannot create a new path
later.

## Exact state and deletion authority

The UID-scoped descriptor is:

```text
/tmp/reliability-atlas-LES-0011-<uid>.state
```

It must be mode `0600`, current-UID-owned, regular, non-symlink, and one hard
link. It contains exactly version, lesson ID, owner UID, and registered root.

The root must match:

```text
/tmp/reliability-atlas-LES-0011.<8 alphanumeric characters>
```

It must be a canonical mode-`0700`, current-UID-owned, non-symlink directory
directly under `/tmp`. The byte-exact sentinel binds lesson, version, and UID.

Only these regular current-UID single-link names are allowed:

| Artifact | Strict mode | Owner |
|---|---:|---|
| `.les-0011-sentinel` | `0600` | setup |
| `artifact-manifest.tsv` | `0600` | setup |
| `isolation_model.py` | `0500` | setup copy |
| `baseline.summary` | `0600` | baseline |
| `active-case.state` | `0600` | inject |
| `recovery.summary` | `0600` | recover |
| `verification.summary` | `0600` | verify |

Strict operations validate the descriptor, root, sentinel, manifest, fixture
copy, modes, and deterministic content. Cleanup accepts content/mode drift only
for known non-sentinel artifact files so a partial record can be removed, but
it still requires the exact descriptor/root/sentinel identity, file type,
ownership, link count, and closed allowlist. It removes files individually and
uses `rmdir`; it never recursively deletes.

If the descriptor is absent, `check`, `setup`, and `cleanup` scan only direct
children of `/tmp` matching the exact lesson prefix and eight-character suffix.
A matching canonical current-UID directory causes refusal. The script does not
infer deletion authority from a name pattern.

## Refusal and recovery guide

| Refusal | Meaning | Safe action |
|---|---|---|
| normal non-root required | privileged use is outside the lab contract | leave the root shell; do not weaken the check |
| state absent | setup has not registered a root | run setup |
| orphan candidate exists | matching unregistered current-UID root exists | preserve and independently inspect; do not ask the lab to guess |
| baseline already recorded | immutable attempt would be overwritten | finish/cleanup or guarded reset |
| incident already active | cases would be mixed | finish/cleanup or guarded reset |
| verify requires recovery | status is not operation verification | recover through supported interface first |
| unexpected artifact | closed allowlist cannot prove cleanup target | preserve, identify, remove only with independent authority |
| symlink/link/owner/mode failure | path identity is unsafe | stop; never replace with recursive deletion |
| descriptor/root/sentinel mismatch | deletion authority cannot be proven | stop and review exact state |
| root changed during cleanup | race or unknown entry appeared | stop and inspect; do not force removal |

A refusal that leaves uncertain state untouched is successful safety behavior.

## Independent transfer

Start fresh:

```bash
bash lab.sh reset
bash lab.sh baseline
bash lab.sh inject transfer
```

Use the four observation views. Classify every field before interpreting it.
Build at least three hypotheses, reject two, identify the first abnormal
boundary, recover, verify, and clean up. Submit against `ASM-0018`.

If you see fixture source, transfer values, or a solution, disclose it. The
attempt becomes guided practice and can no longer demonstrate independent
transfer.

## Verifier

Run only from clean state:

```bash
bash verify.sh
```

The verifier refuses to replace active learner state. It exercises:

- read-only host observation;
- guided and transfer setup/baseline/inject/observe/recover/verify/cleanup;
- repeated setup idempotency;
- verify-before-recovery, repeated baseline, second-case, repeated recovery,
  repeated verification, invalid view, and extra-argument refusals;
- unknown-artifact refusal without mutation;
- symlink refusal while a verifier-owned external target survives;
- descriptor redirection outside the lesson prefix without target mutation;
- orphan-candidate refusal and preservation;
- idempotent cleanup and final absent state;
- transfer-case values not printed in the verifier result.

A pass ends with:

```text
verification_passed=true
cases=guided,transfer
refusals=verify-before-recovery,repeat-baseline,second-case,invalid-input,unexpected-artifact,symlink,out-of-scope-descriptor,orphan-candidate
answer_isolation=transfer-case-not-printed
cleanup_proven=true
```

Root refusal, forced `SIGKILL` during setup, concurrent lifecycle commands,
ShellCheck, and every filesystem implementation remain separate review gates.
The lab is not a locking protocol; run one command at a time. A verifier pass
does not award mastery.
