# LES-0017 lab: safe Bash automation boundaries

This offline lab turns shell failure into visible state. It teaches five distinctions:

```text
source text != final argument vector
visible output != complete successful pipeline
process exit != transaction rollback
local lock != remote idempotency
cleanup command != cleanup proof
```

The lab does not execute a real broken producer, call an API, open a port, inspect another process, start a container, contact Kubernetes, install a package, use sudo, or create a cloud resource. A reviewed Bash fixture prints deterministic virtual evidence. The wrapper stores only allowlisted evidence in one guarded private directory beneath `/tmp`.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04; WSL 2 Ubuntu 24.04 supported |
| Required user | Normal non-root user; UID 0 is refused before state mutation |
| Guided time | 60-75 minutes |
| Independent time | 90-110 minutes |
| CPU | Short foreground Bash and base-utility commands; no load generator |
| Memory | Deterministic text records; normally under 32 MiB |
| Disk | Under 512 KiB in one mode-0700 root and one mode-0600 descriptor |
| Network and ports | None; no socket, DNS, HTTP, package, container, cluster, or cloud request |
| Dependencies | Bash 5 or newer and Ubuntu base GNU tools already present |
| Privilege | No sudo, capability, namespace entry, other-user process access, or host service change |
| Persistent processes | None |
| Mutation boundary | One exact root matching `/tmp/reliability-atlas-LES-0017.XXXXXXXX` and `/tmp/reliability-atlas-LES-0017-<uid>.state` |
| Deletion | Exact named files plus `rmdir`; no recursive deletion |

The script ignores `TMPDIR` and deliberately uses `/tmp`. Before setup it requires `/tmp` to be a real directory owned by UID 0 with mode 1777. The leading `1` is the sticky bit: users can create their entries but ordinary users cannot delete another user's entries merely because the directory is writable.

Do not continue if a guard refuses. Do not use sudo or manually remove a guessed directory. A refusal means the state no longer matches the reviewed ownership contract.

## Files

```text
LES-0017-bash-automation/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- automation_model.sh
```

The repository fixture is executable lesson code. Setup copies it into the private root with mode 0500: owner read and execute, no write, no group or other access. Every lifecycle command compares the copy byte-for-byte with the repository source. The lab never asks you to inspect or edit the copy.

## What setup creates

Descriptor:

```text
/tmp/reliability-atlas-LES-0017-<numeric-uid>.state
```

Registered root:

```text
/tmp/reliability-atlas-LES-0017.<eight-alphanumeric-characters>
```

Allowlisted children:

```text
.sentinel            lesson, version, and UID identity
.lock                local advisory-lock object
model.sh             reviewed deterministic fixture copy
baseline.txt         immutable known-good evidence
case.txt             exactly guided or independent
raw-observed.txt     raw case record and raw-first lifecycle proof
recovery.txt         modeled case-specific recovery
verification.txt     separate modeled postcondition
candidate.txt        fixed staged name allowed only during publication/checks
```

Before reading, writing, or deleting registered state, the lab validates:

- descriptor is a nonsymlink regular file, mode 0600, one hard link, expected UID;
- descriptor has four exact ordered fields and no extra field;
- root is a direct child of `/tmp`, matches the exact prefix and eight-character suffix, resolves to itself, is a real directory, mode 0700, expected UID;
- sentinel has three exact ordered fields, mode 0400, one link, expected UID;
- every direct child has an allowlisted fixed name, regular-file type, expected mode, one link, and expected UID;
- copied model equals the reviewed source;
- raw and recovery records equal deterministic model output before later lifecycle steps trust them.

The script uses a nonblocking advisory lock on the registered `.lock` descriptor around state mutations. Contention returns a temporary-failure status instead of waiting forever. The lock coordinates only cooperating processes in this tested local filesystem; it is intentionally not described as distributed coordination.

## Command contract

Run from this directory as a normal user.

| Command | Mutation | Question answered |
|---|---|---|
| `bash lab.sh check` | None | Is the environment supported and registered state valid or absent? |
| `bash lab.sh setup` | Bounded | Can one guarded private workbench be created or reused idempotently? |
| `bash lab.sh status` | None | Which lifecycle artifacts are valid and present? |
| `bash lab.sh run baseline` | Bounded | What does the known-good virtual automation path report? |
| `bash lab.sh inject guided` | Bounded | Select the framing/pipeline/publication incident. |
| `bash lab.sh inject independent` | Bounded | Select the concurrency/unknown-outcome transfer incident. |
| `bash lab.sh observe input` | Bounded | Print raw case input and record that raw evidence was viewed first. |
| `bash lab.sh observe expansion` | None | Did logical records remain exact arguments? |
| `bash lab.sh observe pipeline` | None | Which stage and selected statuses were visible? |
| `bash lab.sh observe state` | None | What local and modeled remote state committed? |
| `bash lab.sh observe retry` | None | Which operation identity, classification, and retry policy applied? |
| `bash lab.sh recover` | Bounded | Record the case-specific modeled safe reconciliation. |
| `bash lab.sh verify-operation` | Bounded | Record a separate post-recovery operation check. |
| `bash lab.sh cleanup` | Bounded | Remove only revalidated named state and prove absence. |
| `bash lab.sh reset` | Bounded | Guarded cleanup followed by fresh setup. |
| `bash verify.sh` | Bounded | Exercise normal lifecycle and refusal invariants from clean state. |

Every argument uses a closed allowlist. Unknown commands, arbitrary cases or views, extra arguments, paths, and a second active case are refused. No command accepts an arbitrary path.

`observe input` is deliberately classified bounded rather than read-only because it writes `raw-observed.txt`. That marker enforces the teaching sequence: raw evidence, then prediction, then derived views. Repeating the command validates and reprints the same raw record.

## Preflight

```bash
bash lab.sh check
```

Clean output includes:

```text
lesson_id=LES-0017
environment=ready
privilege=normal-user
bash_major=5
network=none
execution=deterministic_bash_model
state=absent
next_command=bash lab.sh setup
```

Field decoder:

- `lesson_id` binds output to this chapter.
- `environment=ready` means required checks passed for this invocation.
- `privilege=normal-user` means effective numeric UID is not zero.
- `bash_major` is the observed major interpreter version, not every feature version.
- `network=none` is the lab contract, not a firewall measurement.
- `execution` says evidence comes from a deterministic model, not host telemetry.
- `state=absent` means descriptor and matching root scan found no lesson state.

If a root-like entry exists without a trusted descriptor, preflight refuses. It does not guess which directory is yours.

## Setup and baseline

```bash
bash lab.sh setup
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

The second setup should report `setup=already-ready`; idempotent setup converges on the same valid state rather than silently creating another root. It refuses if state is malformed.

Baseline output is stored only after a fixed candidate succeeds and is nonempty. The baseline fields describe a known-good virtual run:

| Field | Unit or meaning |
|---|---|
| `input_records` | Count of logical input records |
| `arguments_received` | Count received after framing and expansion |
| `producer_status` | Synthetic process exit status |
| `consumer_status` | Synthetic downstream exit status |
| `pipeline_status` | Status selected for the whole modeled pipeline |
| `effects_committed` | Unique modeled external effects |
| `candidate_records` | Records staged before publication |
| `publication` | Candidate publication state |
| `operation_verified` | Boolean modeled consumer postcondition |

A baseline is immutable in one lifecycle. A second baseline command is refused so a learner cannot replace known-good evidence after seeing the incident.

## Guided incident

### 1. Select and read raw input

```bash
bash lab.sh inject guided
bash lab.sh observe input
```

The raw view gives the named operation, six raw records, observed producer status, caller status, and final count. It does not state the diagnosis or recovery.

Before the next command, write:

```text
Exact failed operation:
Expected record and effect counts:
Input framing contract:
Likely failure boundary:
One alternative hypothesis:
Evidence that separates them:
Smallest safe move:
Unsafe move I will avoid:
```

Try `bash lab.sh observe expansion` before raw input in a fresh lifecycle and it will refuse. That refusal is part of the contract.

### 2. Observe arguments

```bash
bash lab.sh observe expansion
```

Compare `logical_records` with `arguments_received`. If they differ, one input record did not remain one argument. The per-shape booleans identify spaces, wildcard data, leading dash, and empty-value preservation. This view proves the deterministic model's argument result; it cannot prove what a production utility received without production-side evidence.

### 3. Observe the pipeline

```bash
bash lab.sh observe pipeline
```

Read four things separately:

```text
producer_status
consumer_status
pipefail_enabled
selected_pipeline_status
```

Then inspect `partial_output_exists` and `candidate_is_final_path`. Status propagation and state publication are separate. Even a nonzero selected pipeline status cannot unwrite partial output.

### 4. Observe state and retry

```bash
bash lab.sh observe state
bash lab.sh observe retry
```

Reconcile counts:

```text
expected_effects - committed_effects = unresolved effects
committed_effects before replay = possible duplicate population
```

Do not blindly rerun the batch. The model makes committed effects and receipt state visible so the recovery can select missing logical operations rather than repeat all attempts.

### 5. State your diagnosis, then recover

A complete diagnosis includes immediate shell mechanism, partial state, retry consequence, deeper contract gap, and evidence limitations. Then:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

Recovery records NUL framing, quoted array transport, option boundary, explicit producer status, validated candidate publication, prior-report preservation, and idempotent missing-only retry. Verification separately checks six unique terminal receipts, six published records, no duplicates, nonzero producer-failure behavior, prior-report preservation, and `operation_verified=true`.

## Independent transfer

Start from clean state and use ASM-0036:

```bash
bash lab.sh cleanup
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh observe input
```

Write your prediction before derived views. This case is intentionally different: expansion and pipeline evidence may be healthy. Two runners have different local filesystems, a request times out after a possible effect, and a second attempt uses another identity.

Your reasoning must separate:

- lock path existence from acquired advisory lock ownership;
- one runner's local lock from cross-runner coordination;
- process attempt ID from logical operation ID;
- client timeout from remote commit status;
- cleanup from rollback of a remote effect.

The model source contains deterministic case implementation and is not an assessment resource. Do not open it during independent work. The reviewer scores your raw-first prediction, selected evidence, state model, safe recovery, verification, and production transfer—not whether you can repeat an answer string.

## Cleanup

Preserve your reasoning transcript outside the registered root, then run:

```bash
bash lab.sh cleanup
bash lab.sh check
```

Expected cleanup fields include:

```text
cleanup=complete
recursive_delete=false
state=absent
```

The root is removed with `rmdir`, which succeeds only when empty. If an unexpected child appears, validation or `rmdir` refuses. The script does not broaden deletion. Repeating cleanup reports `cleanup=already-absent` only when both the exact descriptor and any matching root are absent.

## Verifier

Run only from clean state:

```bash
bash verify.sh
```

It checks Bash parsing, clean preflight, no network contract, unknown and extra argument refusal, invalid case refusal, setup idempotency, baseline prerequisites, advisory-lock contention, immutable baseline, one-case rule, raw-before-derived and raw-before-recovery gates, guided evidence, recovery, independent changed constraint, operation verification, idempotent cleanup, and final descriptor absence.

The verifier deliberately refuses root. A reviewer can test root refusal separately in a disposable command context; do not use sudo merely to create that evidence. Passing output ends with exact pass and check counts, `failed=0`, `state=absent`, and `network=none`.

## Refusal recovery

| Refusal | Meaning | Safe response |
|---|---|---|
| `root-is-refused` | Effective UID is zero | Return to normal user; do not change the guard |
| `missing-required-command` | Supported dependency baseline is absent | Stop; do not auto-install; review environment separately |
| `unregistered-lesson-root` | A matching path has no trusted descriptor | Preserve and inspect ownership/history; do not guess or sudo-delete |
| `state-descriptor-...` | Descriptor type, owner, mode, links, or fields changed | Stop and preserve evidence |
| `registered-root-...` | Root path, parent, owner, mode, or canonical identity changed | Stop; do not cross the path boundary |
| `unexpected-child` | State contains a name outside the fixed allowlist | Stop; identify origin; cleanup remains refused |
| `registered-model-differs` | Copied executable evidence changed | Stop; do not trust case output; restore through fresh reviewed setup only after state review |
| `state-lock-contended` | Another cooperating mutation holds the lock | Wait or retry within a human-bounded interval; never delete the lock path |
| `raw-input-must-be-observed` | Derived evidence requested too early | Observe raw input and write prediction |
| `stale-candidate-present` | A prior publication was interrupted | Preserve and inspect; do not overwrite automatically |

A refusal may intentionally leave state for investigation. The safest automation is sometimes the one that stops.

## What this lab proves and does not prove

A successful run proves the deterministic fixture and wrapper produced expected evidence, enforced selected lifecycle gates, kept mutation inside the validated local root, and proved declared cleanup in that Ubuntu environment.

It does not prove:

- production data or filenames match the fixture;
- every Bash grammar edge is covered;
- a real CI runner, network filesystem, container, or Kubernetes cluster has the same semantics;
- a remote API honors idempotency keys or retains them long enough;
- a local advisory lock coordinates hosts;
- atomic rename is crash-durable or distributed-transactional;
- no secret can ever reach logs;
- the learner has mastered diagnosis or transfer.

Keep those limitations in the evidence. Strong engineering is not claiming more than the experiment actually demonstrated.
