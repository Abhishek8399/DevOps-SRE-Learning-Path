# LES-0013 lab: find the transport state owner

This lab teaches a production habit: separate a failed user operation from the
many state budgets required to complete it.

```text
client operation
  -> descriptor and client socket
  -> ephemeral source tuple
  -> stateful network path
  -> listener and handshake state
  -> completed accept queue
  -> accepted socket and worker
  -> verified application result
```

The lab does not create a real TCP or UDP socket. It does not listen on a port,
send a packet, modify a route, write a sysctl, touch a firewall, inspect another
process, start a container, contact a cluster, or call a cloud API. A small
Python program prints deterministic virtual evidence. Bash stores only
allowlisted records in a guarded lesson-owned directory.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| User | Normal non-root user; root is refused before mutation |
| Time | 35-50 minutes guided; 50-70 minutes independent |
| CPU | No load generator; short foreground Bash and Python commands only |
| Memory | No allocator pressure; model normally uses less than 32 MiB |
| Disk | Less than 256 KiB in one private root and one UID-scoped descriptor |
| Network and ports | None; no socket, bind, connect, listen, packet, or DNS call |
| Packages | No installation; Bash, Python 3.8+, and base Ubuntu tools |
| Privilege | No sudo, capability, namespace entry, runtime socket, or sysctl write |
| Persistent processes | None |
| Paid resources | None |
| Mutation boundary | One exact child of `/tmp` and one exact state file |

The script ignores `TMPDIR` and uses `/tmp` explicitly. Before creating state,
it requires `/tmp` to be a real, root-owned, sticky directory. A sticky
directory lets users create their own entries while preventing ordinary users
from deleting entries owned by someone else.

## Files

```text
LES-0013-transport-path/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- transport_model.py
```

During setup, the fixture is copied mode `0500` into a private mode `0700`
directory. `0500` means the owner can read and execute it but cannot edit it;
group and other users receive no permission. Strict lifecycle operations
compare that copy byte-for-byte with the reviewed repository source.

## State safety model

The state descriptor is:

```text
/tmp/reliability-atlas-LES-0013-<numeric-uid>.state
```

The registered root must match:

```text
/tmp/reliability-atlas-LES-0013.<eight-alphanumeric-characters>
```

Before reading or deleting state, the lab validates:

- the descriptor is a single-link, mode `0600`, normal file owned by the user;
- descriptor fields and their order are exact;
- the root is a direct child of `/tmp`, not a symbolic link, and resolves to itself;
- root owner is the current numeric UID and mode is `0700`;
- a lesson, version, and UID sentinel matches exactly;
- the artifact manifest is unchanged;
- every direct child is on the fixed allowlist;
- regular files have one hard link and expected ownership;
- the model copy equals the repository source;
- recorded evidence equals deterministic model output for the registered case;
- lifecycle dependencies such as baseline before inject remain valid.

If an unregistered directory matches the lesson root pattern, the script
refuses to guess. It never recursively removes a discovered path. Resolve a
refusal by inspecting ownership and history, not by adding `sudo`.

## Command contract

Run commands from this directory.

| Command | Mutation | Purpose |
|---|---|---|
| `bash lab.sh check` | None | Validate environment and registered state or prove absence. |
| `bash lab.sh setup` | Bounded | Create guarded private state; repeated setup is idempotent. |
| `bash lab.sh status` | None | Validate and summarize lifecycle state. |
| `bash lab.sh run baseline` | Bounded | Record immutable known-good model output once. |
| `bash lab.sh inject guided` | Bounded | Select the guided virtual incident. |
| `bash lab.sh inject independent` | Bounded | Select the answer-isolated transfer incident. |
| `bash lab.sh observe operation` | None | Read user operation, error, phase, and timing. |
| `bash lab.sh observe endpoints` | None | Read TCP endpoint and state populations. |
| `bash lab.sh observe queues` | None | Read modeled listener queue, rate, and counter evidence. |
| `bash lab.sh observe resources` | None | Read tuple, descriptor, and socket-memory budgets. |
| `bash lab.sh observe stateful-path` | None | Read a separate node state-table budget. |
| `bash lab.sh recover` | Bounded | Record the case-specific modeled recovery. |
| `bash lab.sh verify-operation` | Bounded | Record a separate post-recovery user-operation check. |
| `bash lab.sh cleanup` | Bounded | Delete only revalidated allowlisted state. |
| `bash verify.sh` | Bounded | Exercise lifecycle and refusal boundaries from clean state. |

Every argument is a closed allowlist. Unknown commands, shell fragments,
paths, extra arguments, unsupported views, and a second active case are
refused. No command accepts an arbitrary path.

## Preflight

```bash
bash lab.sh check
```

A clean result is:

```text
lesson_id=LES-0013
environment=ready
privilege=normal-user
network=none
execution=deterministic_transport_model
state=absent
next_command=bash lab.sh setup
```

If root, a dependency, `/tmp`, an orphan candidate, or registered state fails a
guard, stop. Do not install packages, use `sudo`, manually delete a guessed
directory, or weaken a check.

## Baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

The baseline is not host telemetry. It is fixed evidence for a known-good
virtual service. Read field units before comparing values:

| Field family | Unit or meaning |
|---|---|
| `*_connections` and `*_used` | Count at the modeled observation |
| `*_per_second` | Rate during the modeled interval |
| `*_percent` | Percentage from 0 through 100 |
| `*_latency_ms` | Milliseconds |
| `*_total` | Cumulative counter; compare a later sample minus earlier sample |
| `*_limit` or `*_eligible` | Configured or modeled ceiling, not proof of availability |
| `*_success` | Boolean outcome for the named operation |

The baseline must exist before incident selection. A second baseline is
refused so a learner cannot silently replace known-good evidence after seeing
the failure.

## Guided case

Select the case:

```bash
bash lab.sh inject guided
```

Before reading evidence, write:

```text
Exact failed operation:
Direction and endpoint roles:
Error and failed phase:
Known-good baseline:
Top three candidate owners:
First observation and why:
```

Observe one boundary at a time:

```bash
bash lab.sh observe operation
bash lab.sh observe endpoints
bash lab.sh observe queues
bash lab.sh observe resources
bash lab.sh observe stateful-path
```

For every view, record:

```text
Observed value and unit:
Owner and scope:
What it proves:
What it does not prove:
Healthy comparison:
Next disconfirming evidence:
```

Do not diagnose from the largest number. Compare each value with its own
baseline, ceiling, rate, or counter delta. For example, an entry count and a
rate have different units. A listener existing is not worker health. A full
stateful-path table is not the client's local port range.

Once the first divergent owner is evidenced, record a recovery and separately
verify the user operation:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

`recover` is a modeled configuration action. `verify-operation` is a separate
fresh plus reused connection and correctness check. This separation teaches a
production rule: successful change execution does not prove service recovery.

## Independent case

Start from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
```

Use the same five observations. The script prints no root-cause label, answer,
recommended command, or scoring result. `verify.sh` captures the values only
to check their structure and deliberately does not print them.

Deliver an incident note containing:

1. exact operation, protocol, direction, phase, error, and deadline;
2. state-owner architecture;
3. baseline-to-incident evidence with units and scope;
4. at least three candidate mechanisms;
5. disconfirming evidence for each candidate;
6. last known-good and first abnormal boundary;
7. one bounded remediation with blast radius and approval owner;
8. rollback trigger and action;
9. new-flow, established-reuse, and application-correctness verification;
10. one prevention improvement.

This repository is intentionally inspectable. Reading fixture constants before
submitting your analysis invalidates the independent exercise; hiding a local
answer cryptographically would be fake security. Isolation here means normal
lab output and the verifier do not reveal a diagnosis or solution key, the
independent fixture is immutable during a run, and learner notes are never
read by the scripts.

## What the verifier proves

From clean state:

```bash
bash verify.sh
```

The verifier checks:

- the Python source compiles in memory without creating `__pycache__`;
- clean preflight and refusal before setup;
- guided and independent full lifecycles;
- idempotent setup and cleanup;
- required baseline and legal state transitions;
- invalid command, case, view, target, and argument refusal;
- unexpected artifact refusal and preservation;
- changed copied-model refusal;
- symbolic-link refusal while an external target survives unchanged;
- descriptor redirection outside the lesson prefix without target mutation;
- unregistered orphan-candidate refusal and preservation;
- independent evidence and diagnosis not printed in verifier output;
- final registered-state absence.

A pass ends with:

```text
verification_passed=true
cases=guided,independent
refusals=invalid-input,invalid-transition,unexpected-artifact,changed-model,symlink,out-of-scope-descriptor,orphan-candidate
answer_isolation=independent-values-and-diagnosis-not-printed
network_mutation=none
cleanup_proven=true
```

## Separate review gates

The verifier cannot prove all filesystem implementations, concurrent commands,
forced process termination, every Bash or Python version, or real transport
behavior. Run one lifecycle command at a time. ShellCheck is a separate gate
when installed. Root refusal is also tested separately because the verifier
itself must not run as root:

```bash
sudo -n bash lab.sh check
```

The command should fail before mutation. Do not run it if passwordless sudo is
not already authorized; never type a password merely to test this lesson.

## Production transfer boundary

This lab teaches reasoning, not production access. In a real incident:

- preserve exact operation, error, direction, namespace, and timestamp;
- obtain authorization before inspecting another process or stateful device;
- protect endpoint, process, tenant, and topology data;
- do not load-test, flush connection tracking, kill sockets, write sysctls, or
  change firewall policy as an unreviewed experiment;
- use a bounded remediation with owner, blast radius, rollback, and validation;
- verify the complete user operation, not only a resource graph.

A passing verifier proves that the deterministic learning lifecycle and listed
guards behaved as expected in the tested environment. It does not prove mastery
or diagnose any host, container, Kubernetes cluster, gateway, or production
service.
