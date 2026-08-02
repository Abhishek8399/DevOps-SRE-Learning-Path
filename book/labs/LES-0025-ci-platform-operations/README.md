# LES-0025 lab: prove that two green pipelines can have different contracts

This lab gives you two small CI engines that run entirely on your Ubuntu machine. Both engines build and test the same bytes. Both finish green. One port also declares package-write permission, parallel same-ref execution, and no pipeline timeout. The lab compares those declarations; it does not grant the permission, launch concurrent runs, or allow an unbounded child process.

That is the lesson: **green is a result; equivalence is a contract comparison.**

The engines are purpose-built teaching software checked into this lab:

- `local-graph` schedules jobs from explicit dependency edges, similar to the way a directed acyclic graph exposes `needs` relationships;
- `local-stage` schedules ordered stages, similar to platforms that make stages the primary grouping.

They are real local executors in the narrow sense that two independent schedulers create job workspaces, run a shared portable job program, publish an artifact, download it into a dependent job, and verify the downloaded bytes. They are **not** GitHub Actions, GitLab CI/CD, Jenkins, or Azure Pipelines. A pass cannot prove any hosted provider's parser, scheduler, security boundary, cancellation behavior, approval model, or outage behavior.

## The picture to remember

```text
same source identity + same portable job program
                     |
             +-------+-------+
             |               |
             v               v
      [local-graph]     [local-stage]
       build -> test     build | test
             |               |
             +-------+-------+
                     |
          same artifact SHA-256
                     |
       Do the encoded fields match?
                     |
       +-------------+-------------+
       | digest/graph: yes          |
       | permission:   NO           |
       | concurrency:  NO           |
       | timeout:      NO           |
       +-------------+-------------+
                     |
       green, declared fields differ
                     |
       corrected stage contract -> verify
```

Whenever a migrated pipeline is green, do not stop at the green icon. Compare the source, resolved configuration, graph, worker boundary, permissions, timeout, retry and cancellation behavior, artifact identity, environment authorization, and external effects.

## Environment and blast-radius contract

| Item | Contract |
|---|---|
| Platform | Ubuntu 24.04 LTS, including Ubuntu 24.04 under WSL 2 |
| User | Normal non-root user; UID 0 is refused with exit status 77 |
| Required tools | Bash 5+, Python 3 with Linux `fcntl` support, coreutils, and `grep` |
| Installation | None; a missing dependency is a stop condition |
| Network | No endpoint is configured and no lab source imports a network client; do not enable network access for the exercise |
| Credentials | No declared secret input; child processes receive an allowlisted environment without inherited token or credential variables, `HOME`, or cloud-configuration path variables. Same-UID host files and credentials outside that process environment remain outside the proof boundary. |
| Ports and services | None opened; no daemon, container, virtual machine, provider, or cloud service |
| Files changed | One exact state directory and one random private lab root below `/tmp`, both owned by the current UID |
| Cleanup | Exact allowlisted files and directories only; no glob and no recursive deletion |
| Expected resources | Under 64 MiB RAM, under 1 MiB disk, and a few seconds of CPU time |

Do not use `sudo`. Do not connect this lab to a Docker socket. Do not paste a provider token into the shell. Do not replace the bounded fixtures with an arbitrary command runner.

Abort when:

- `lab.sh` reports a missing command, unexpected path, altered source digest, invalid owner or mode, unexpected file, or lock contention;
- the shell is UID 0;
- a proposed step needs a login, network call, package installation, secret, persistent runner, production endpoint, or writable system directory;
- the directory is not the reviewed lesson lab.

## What the controller protects

`lab.sh` is a thin Bash entry point. `lab_controller.py` owns the lifecycle.

```text
/tmp/reliability-atlas-LES-0025-UID.state.d/  mode 0700
  |-- lock                                      mode 0600
  `-- descriptor.json                           mode 0600
          |
          | exact root path + device/inode + reviewed-source digests
          v
/tmp/reliability-atlas-LES-0025-UID.RANDOM/   mode 0700
  |-- .sentinel                                 mode 0400
  |-- runs/                                     mode 0700
  |    |-- graph/
  |    |-- stage-broken/
  |    `-- stage-fixed/
  |         |-- build/artifact.bin
  |         |-- artifact-store/build-output.bin
  |         `-- test/downloaded-output.bin
  |-- graph.record.json
  |-- stage-broken.record.json
  |-- comparison.record.json
  |-- stage-fixed.record.json
  `-- verification.record.json
```

The controller opens the predictable state directory and lock without following symlinks, holds a non-blocking exclusive lock during each transition, validates current UID ownership and exact modes, binds the random root by device and inode, verifies every reviewed runtime-input digest, and refuses unexpected children. Cleanup moves each validated target to an unpredictable same-directory quarantine name with Linux `renameat2(RENAME_NOREPLACE)`, compares the quarantined inode with the open descriptor, restores a cooperatively replaced target when the identities differ, and removes only the matching quarantine name. Root, state, nested directories, rollback paths, and regular files all use descriptor-relative parents. It never runs `rm -rf`, follows a record symlink, or deletes a path merely because its name looks familiar.

This is bounded local lifecycle hygiene, not atomic deletion and not a security sandbox against malicious code running as the same UID. Deterministic tests prove preservation when one cooperative replacement occurs at the validation-to-quarantine boundary. Code that can race repeatedly after the final identity check has the same UID and can mutate every lab file; that adversary is explicitly outside this lab's guarantee. Both engines and all workspaces use your current UID. Real untrusted CI needs a stronger boundary such as a disposable VM, hardened container boundary, separate identity, restricted network, and short-lived credentials.

## The two engine contracts

Both configurations intentionally share:

- source identity `local-source-001`;
- pipeline identity `portable-pipeline-v1`;
- jobs `build -> test`;
- the same portable input bytes;
- explicit artifact publish and download;
- zero secret inputs and zero network targets.

The first stage-shaped port intentionally differs:

| Declared field | Graph engine | Mismatched stage port | Why it matters if a real platform enforces the declaration |
|---|---|---|---|
| Permissions | `source:read`, `artifact:write` | adds `packages:write` | A test path can now mutate a package namespace even though the job does not need that authority. |
| Same-ref concurrency | cancel older run | allow parallel runs | Two release attempts may race or repeat an external effect. |
| Timeout | 300 seconds | unbounded (`0` in the local contract) | A stuck job can occupy capacity indefinitely. |

The corrected stage configuration makes those three declarations equal. `0` models an omitted pipeline timeout, but the lab controller always enforces its own 20-second subprocess safety ceiling. The permission strings are never converted into operating-system or provider authority, and the concurrency strings never create competing processes. No production effect exists in any configuration; this slice tests declared-field comparison, not permission, concurrency, or timeout behavior.

## Command path

Run from this directory in a normal Ubuntu shell.

### 1. Prove the initial boundary

```bash
pwd
id
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
```

`state=absent orphan_count=0` is the safe starting state. The dry run reports intended mutations but creates nothing.

### 2. Register private local state

```bash
bash lab.sh setup
bash lab.sh status
```

The setup receipt includes a random root and the source-manifest digest. Do not edit files under that root. The state belongs to the controller lifecycle.

### 3. Run both green paths

```bash
bash lab.sh run graph
bash lab.sh run stage-broken
```

Each engine:

1. creates separate `build`, `artifact-store`, and `test` directories;
2. invokes the same typed portable job program without a shell;
3. writes exact input bytes in the build workspace;
4. copies those bytes into the artifact store;
5. copies them into the test workspace;
6. verifies the expected content and SHA-256 digest;
7. emits a controller-validated record.

Expected high-level result:

```text
engine=local-graph status=passed jobs=build,test
engine=local-stage status=passed jobs=build,test
```

That proves both encoded local executions passed. It does not prove provider equivalence.

### 4. Compare the contract, not the color

```bash
bash lab.sh compare
```

Expected decision:

```text
both_green=true
artifact_digest_equal=true
job_graph_equal=true
permission_contract_equal=false
concurrency_contract_equal=false
timeout_contract_equal=false
encoded_comparison_equal=false
declarative_fields_behaviorally_enforced=false
```

The important sentence is:

> The port produced the expected bytes, but its declared authority, same-ref policy, and pipeline timeout fields differ. A real migration must now test whether the target platform actually enforces the intended behavior.

### 5. Apply the bounded correction and verify

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

`recover` does not edit a hosted pipeline. It runs the second local engine again using the reviewed corrected fixture. Verification requires:

- both corrected executions green;
- equal source and pipeline identities;
- equal job graph and artifact digest;
- equal encoded permission, concurrency, timeout, secret-input, and network-target declarations;
- the earlier comparison record to prove that the negative case was actually observed;
- digest binding between every consumed record and the final verification record.

Expected final tokens are `encoded_comparison_equal=true`, `declarative_fields_behaviorally_enforced=false`, and `local_verification_passed=true`. They prove equality only for encoded fields plus the observed local artifact path.

### 6. Preview and prove cleanup

```bash
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

The dry run must leave status unchanged. Final cleanup reports `cleanup_proven=true`; the last check must report `state=absent orphan_count=0`.

## Reading the evidence like an operator

| Evidence | What it proves here | What it cannot prove |
|---|---|---|
| engine status `passed` | the encoded scheduler and typed job actions finished under this local run | hosted provider availability, parser behavior, or worker isolation |
| same artifact SHA-256 | all three local copies contain the same bytes | that the bytes are safe, reviewed, signed, or present in a real registry |
| same dependency edge | both reports contain `build->test` | provider conditions, skipped-job behavior, retry semantics, or cancellation propagation |
| empty secret inputs | the reviewed fixture declares none and child processes receive a minimal environment | absence of host credentials outside this process boundary |
| empty network targets | the reviewed fixture declares none and lab code configures no endpoint | a kernel-level packet trace or proof about unrelated host processes |
| encoded comparison equality after recovery | the observed local output fields and encoded declarations checked by this model match | behavioral enforcement of permission, concurrency, timeout, cancellation, or any provider semantic |

## Provider translation map

Use the lab's fields as questions, not keyword substitutions.

| Local question | GitHub Actions | GitLab CI/CD | Jenkins | Azure Pipelines |
|---|---|---|---|---|
| What creates the graph? | workflow jobs and `needs` | stages, jobs, `needs`, rules | Pipeline stages and scripted/declarative graph | stages, jobs, `dependsOn`, conditions |
| Where is permission expressed? | workflow/job permissions plus external identity | job token, variables, runner and external identity policy | credentials binding, authorization, agent authority, shared libraries | job token, service connection, variable groups, external identity |
| What serializes same-target work? | concurrency groups | resource groups and platform limits | locks/throttles/job policy | exclusive locks/checks and pipeline controls |
| What limits a stuck job? | job/workflow timeout controls | job timeout and runner/platform limits | Pipeline timeout and executor/controller policy | job timeout and pool/platform policy |
| How does output cross jobs? | artifacts or external immutable store | job artifacts or external immutable store | archive/stash or external immutable store | pipeline/build artifacts or external immutable store |

Exact defaults and capabilities change. Verify the current official documentation and the real organization configuration before production use.

## Deterministic engineering verifier

From clean state:

```bash
bash verify.sh
```

It checks:

- Bash syntax and Python abstract-syntax-tree parsing without creating repository bytecode;
- the verifier's normal-user boundary and the checked-in `lab.sh` root guard (a separate targeted UID-0 invocation validates the entry-point exit status);
- dry-run non-mutation;
- invalid lifecycle transitions;
- both independent scheduler implementations and the shared typed job boundary;
- green artifact parity plus three intentional declared-field mismatches;
- refusal to verify before correction;
- corrected encoded-field equality and digest-bound final evidence, with behavioral enforcement explicitly false;
- source-digest binding across every registered lifecycle transition;
- pre-existing state refusal without changing its marker bytes;
- unexpected-child cleanup refusal without deleting the unexpected file;
- cooperative replacement-race preservation for a regular file and root, state, rollback-root, and rollback-state directory boundaries, while explicitly making no atomic-deletion claim;
- exact cleanup, idempotent cleanup, and final absence.

The verifier tests the checked-in implementation. It does not score a learner's incident explanation and does not turn these teaching engines into provider acceptance tests.

## Failure guide

| Refusal | Meaning | Safe response |
|---|---|---|
| `root-is-refused-run-as-a-normal-user` | the shell is elevated | leave the root shell; never weaken the guard |
| `state-already-exists` | another or earlier lifecycle owns the predictable state directory | run `bash lab.sh status`; clean only through the controller |
| `state-lock-contended` | another transition currently holds the lifecycle lock | wait, identify the other invocation, and retry; do not remove lock files |
| `reviewed-source-digest-changed-*` | an engine, job program, controller, or fixture differs from setup | preserve the repository diff; clean the lab and review the source change before rerunning |
| `unexpected-root-child-*` | the lab root contains a path outside the controller allowlist | preserve it and identify its creator; cleanup intentionally refuses |
| `expected-regular-file-*` | a record or artifact is missing, linked, multiply linked, wrongly owned, or wrongly permissioned | stop; inspect type and ownership without following the path |
| `compare-requires-*` | both baseline engine records do not exist | run the exact graph and broken-stage commands first |
| `verification-requires-corrected-stage-run` | recovery evidence is missing | run `bash lab.sh recover`; do not fabricate a record |
| `encoded-comparison-equality-not-proven` | a required observed output or encoded declaration still differs | inspect the emitted comparison and fixtures; do not claim behavioral equivalence |

## Memory sentence

> Two pipelines are equivalent only when the important execution contracts match—not when both dashboards are green.
