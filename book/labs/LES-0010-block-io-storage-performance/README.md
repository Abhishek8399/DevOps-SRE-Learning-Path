# LES-0010 lab: diagnose a slow durable-write path

This lab is a deterministic storage-performance incident model. It gives you
stable, realistic-looking evidence from an application, Linux memory and block
layers, a process view, and a mount map. It does **not** benchmark, throttle, or
write meaningful data to a host device. That is deliberate: a real disk load
generator can disrupt unrelated workloads, and virtualized device timing can
vary enough to hide the concept being taught.

The fixture teaches the diagnostic method. Its values are synthetic virtual
measurements and must never be presented as Ubuntu, WSL, Docker, VM, cloud,
Kubernetes, or production performance evidence.

## Environment and safety card

| Boundary | Contract |
|---|---|
| Supported shell | Bash on Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 LTS |
| Identity | A normal user; effective UID 0 is refused |
| Required tools | `bash`, `cmp`, `find`, `grep`, `mktemp`, `python3` 3.8+, `realpath`, `sha256sum`, `stat`, and base file utilities |
| Network | None |
| Ports and processes | No listener, daemon, background process, or sleep |
| Host I/O pressure | None beyond tiny lesson-owned metadata files in `/tmp` |
| Time | About 25 minutes; each command should return immediately |
| State | One random mode-0700 directory and one UID-scoped mode-0600 descriptor under `/tmp` |
| Stop conditions | Any refusal, unknown entry, symlink, owner/mode/link mismatch, integrity mismatch, unsupported UID, or output inconsistent with this contract |
| Recovery | Only `bash lab.sh recover`; it changes model state, not a real device |
| Cleanup | Only `bash lab.sh cleanup`; it validates an exact allowlist and removes files individually |

Never use `sudo`, run a benchmark, write to a raw device, edit the descriptor,
delete the registered directory recursively, or create a loop device for this
lab. If a command refuses, keep the first message and stop. The refusal is a
safety result, not an invitation to weaken a guard.

## Why a model instead of `dd` or `fio`

`dd` can copy bytes, but without careful cache, durability, alignment,
direct-I/O, device, duration, and concurrency controls it is not a trustworthy
storage benchmark. `fio` is a powerful workload generator, not a harmless
diagnostic command. Either can fill a filesystem, consume shared bandwidth,
wear flash, distort neighbor latency, or target the wrong device.

This lab instead fixes the interval, units, request mix, and evidence values.
You can practice the reasoning chain:

```text
slow user operation
  -> time is concentrated in commit
  -> dirty/writeback state and blocked tasks rise
  -> the mapped block device has high write completion time and queue depth
  -> process writes are present, but attribution is not causation
  -> bounded recovery restores the operation and the same evidence boundaries
```

That chain is a hypothesis supported by joined evidence. No single column proves
it alone.

## Lifecycle

Run from the repository root:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh check
bash book/labs/LES-0010-block-io-storage-performance/lab.sh setup
bash book/labs/LES-0010-block-io-storage-performance/lab.sh status
```

A clean check reports `state=absent`. Setup creates one private workspace,
copies the reviewed model, records its SHA-256 digest, and activates the guided
incident. Status reports only lifecycle state; it does not reveal a diagnosis.

Capture the healthy and affected user-operation summaries:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe baseline
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe incident
```

Before looking deeper, write this prediction:

> If storage completion is the first abnormal boundary, commit latency should
> move far more than arrival rate, and device completion time plus queued work
> should rise in the same affected profile. If the application is CPU-bound,
> those storage boundaries need not move together.

Map the path, then inspect one boundary at a time:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe path
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe mount
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe system
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe device
bash book/labs/LES-0010-block-io-storage-performance/lab.sh probe process
```

For every output row, record:

1. its scope and interval;
2. its unit;
3. what changed from baseline;
4. what that change proves;
5. what it does not prove;
6. the next boundary needed to discriminate hypotheses.

Then use the model's supported recovery and verify the user operation:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh recover
bash book/labs/LES-0010-block-io-storage-performance/lab.sh observe recovered
bash book/labs/LES-0010-block-io-storage-performance/lab.sh verify-operation
bash book/labs/LES-0010-block-io-storage-performance/lab.sh status
```

Recovery is not proof until `verify-operation` succeeds. Even then, it proves
only the fixed model assertion for the recovered profile. It does not establish
production root cause, long-term stability, data durability on real hardware,
or learner mastery.

Finally clean up and independently check absence:

```bash
bash book/labs/LES-0010-block-io-storage-performance/lab.sh cleanup
bash book/labs/LES-0010-block-io-storage-performance/lab.sh check
```

Successful cleanup reports `cleanup_proven=true`. Its scope is the exact
registered path plus matching current-user candidates at that instant. It does
not promise that another process cannot create a later path.

## Decode the model fields

The model uses the names you will meet in common Linux tools, but all values are
synthetic:

| Field | Unit | Meaning in this model |
|---|---:|---|
| `requests_s` | original operations/s | Accepted application operations, not storage requests |
| `app_p95_ms` | milliseconds | 95th percentile end-to-end application latency over the virtual 60-second interval |
| `commit_p95_ms` | milliseconds | 95th percentile of the application's durable-commit stage |
| `r/s`, `w/s` | completed requests/s | Block reads and writes completed during the interval |
| `rkB/s`, `wkB/s` | KiB/s | Read and written kibibytes per second |
| `rrqm/s`, `wrqm/s` | merges/s | Read and write requests merged per second |
| `r_await`, `w_await` | milliseconds/request | Average completion time for read or write requests represented by the tool model |
| `aqu-sz` | average requests | Time-weighted average number of requests queued or active |
| `%util` | percent of interval | Time the modeled device had at least one request in progress; not a universal capacity percentage |
| `Dirty_kib` | KiB | Memory pages modified but not yet fully written back |
| `Writeback_kib` | KiB | Dirty memory currently under writeback |
| `b` | tasks | Runnable tasks blocked while waiting for I/O in the virtual sample |
| `bi`, `bo` | KiB/s in this model | Blocks received from and sent to block devices, normalized here to KiB/s for teaching |
| `kB_rd/s`, `kB_wr/s` | KiB/s | Per-process storage read and write rates |
| `iodelay` | clock ticks | Delay attributed by the modeled process accounting; it is not milliseconds |

The real command's version and help text remain authoritative. In particular,
`vmstat` block units can depend on options and implementation, `pidstat`
availability depends on the `sysstat` package, and device `%util` must be
interpreted with the device's concurrency and virtualization model.

## Three hypotheses to rank

Do not read the component name and jump to a fix. Rank at least these mechanisms:

- application work or lock contention before the filesystem boundary;
- dirty-page writeback or a synchronous durability wait along the filesystem
  and block path;
- device or lower-layer completion delay, perhaps shared below the guest;
- a misleading mapping in which the inspected device is not the one backing
  the affected path.

The mount view connects `/srv/ledger` to a device-mapper source and parent
device. The application and process views connect work to the path. The system
view exposes dirty/writeback and blocked-task context. The device view exposes
the completion and queue symptom. The baseline comparison controls for the
meaning of the fields. Together they make one mechanism more likely; they do
not identify a physical drive, hypervisor neighbor, storage-array component,
or source-code line.

## Engineering verifier

`verify.sh` is for maintainers. It exercises the supported lifecycle and proves
that cleanup refuses unknown entries, symbolic links, and an out-of-scope root.
It also proves that the symbolic-link target survives, recovery order is
enforced, duplicate lifecycle transitions refuse, and final cleanup returns to
absent state.

Run it only from clean state as a normal user:

```bash
bash book/labs/LES-0010-block-io-storage-performance/verify.sh
```

A verifier pass means its encoded assertions passed in that environment. It is
not a formal proof against every filesystem race, a storage benchmark, a
production equivalence claim, an answer to the independent transfer, or
evidence of learner mastery.

## Independent work stays answer-isolated

`ASM-0015` changes the workload shape and evidence ambiguity. Its response
template is blank by design. Do not treat this guided incident's explanation as
the transfer answer, inspect another learner's response, or ask for a model
solution before submission. If you need help, return to the guided chapter and
later attempt a fresh transfer. Record any help honestly.
