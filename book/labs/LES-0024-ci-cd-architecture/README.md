# LES-0024 lab: follow one release through the CI/CD control plane

This lab turns a CI/CD pipeline into evidence you can inspect. A pipeline is not a YAML file that somehow deploys software. It is a controller coordinating source identity, separated job workspaces, runner identity, cache reuse, artifact identity, quality gates, human or policy approval, deployment, verification, and recovery.

The exercise is deliberately local and offline. A Python standard-library model calculates deterministic records in memory while `lab.sh` owns a tightly guarded temporary state. Nothing contacts GitHub Actions, Azure DevOps, GitLab, Jenkins, a package registry, a container registry, Kubernetes, a cloud API, or a production environment. No credential is requested or created.

That boundary matters: a verifier pass proves that this local model and its filesystem controller behaved as encoded. It does **not** prove that a hosted runner is isolated, a real token is trustworthy, an artifact exists in a registry, an approval is legally sufficient, or a production deployment is safe.

## Environment card

| Item | Contract |
|---|---|
| Platform | Ubuntu 24.04 LTS, including Ubuntu 24.04 under WSL 2 |
| Run as | A normal non-root user; effective UID 0 is refused with exit status 77 |
| Required tools | Bash 5+, Python 3 standard library, coreutils, findutils, and `flock` from util-linux |
| Installation | None; a missing command is a stop condition, not permission to install |
| Network | None; no URL, remote, registry, socket, or hosted-CI endpoint is used |
| Privilege | No `sudo`, daemon control, Docker socket, cloud login, token, or secret |
| CPU/RAM/disk | One small Python process at a time; under 64 MiB RAM expected; under 256 KiB state |
| Ports, containers, VMs | None |
| Host mutation | One per-UID descriptor and one private random directory under `/tmp` |
| Cleanup | Exact allowlisted paths only through `bash lab.sh cleanup`; no wildcard or recursive delete |

Do not use `sudo`. Do not manually remove a state file after a refusal. The refusal means the controller can no longer prove that the path is its own. Preserve the evidence and restore the exact invariant instead of broadening deletion.

## The system you are operating

Read this left to right:

```text
reviewed source + pipeline definition
                 |
                 v
       CI controller / job graph
          |                 |
          v                 v
  runner-a workspace   runner-b workspace
   private path         private path
       same current UID; separation is not isolation
          |                 |
          +---- gates ------+
                    |
        cache key + artifact digest
                    |
          identity and approval binding
                    |
             canary deployment
                    |
         user check + promote or stop
                    |
       digest-bound receipt and rollback target
```

Every arrow is an ownership boundary. When a pipeline fails, ask which owner accepted a valid input but produced an invalid or missing output. “CI is broken” is not yet a diagnosis.

The local filesystem boundary is:

```text
reviewed repository files
  |-- fixtures/pipeline_model.py
  |-- lab.sh
  `-- verify.sh
            |
            | setup installs one byte-identical model copy
            v
/tmp/reliability-atlas-LES-0024-uUID.<random>/   mode 0700, current UID
  |-- .sentinel                            mode 0400
  |-- pipeline_model.py                    mode 0500, source bytes checked
  |-- runner-a/                            mode 0700
  |   `-- .workspace                       mode 0400, exact runner identity
  |-- runner-b/                            mode 0700
  |   `-- .workspace                       mode 0400, exact runner identity
  |-- baseline.record                      mode 0600, controller-write-once
  |-- case.record                          mode 0600, after injection
  |-- prediction.record                    mode 0600, digest only; independent case
  |-- experiment.record                    mode 0600, one-variable local experiment
  |-- recovery.record                      mode 0600, after recovery
  |-- verification.record                  mode 0600, after verification
  `-- cleanup.marker                       mode 0600, only during resumable cleanup

/tmp/reliability-atlas-LES-0024-UID.state  mode 0600, registration, phase, and stable flock
```

A matching name is not ownership proof. The controller checks the descriptor grammar, canonical path, root owner and mode, exact child allowlist, file types, link counts, runner workspace identities, sentinel content, installed-model bytes, and the descriptor inode held by the lock file descriptor. Setup captures the new descriptor candidate's device/inode identity and the new root before registration, then registers with destination-nondirectory semantics. After opening, locking, and loading the registered descriptor, setup requires the locked descriptor identity to equal that captured candidate and the loaded root to equal the root this invocation created. Only then may it clear pending ownership and emit the setup receipt. If another lifecycle replaced the path in between, setup refuses without claiming or deleting that replacement. Pending cleanup also unlinks the candidate pathname only when it still names the captured candidate inode; a changed type or identity is preserved and reported. The verifier saves the successful ownership receipt and supplies it to cleanup; cleanup compares both values only after locking and loading the current descriptor, before any transition or deletion. The descriptor remains locked while cleanup removes the root and then unlinks the descriptor; a stale process opens it read-only and therefore cannot recreate it. The active-to-cleanup transition changes one phase byte on that locked inode and calls `fsync` before any child is removed.

## Command contract

| Command | Question answered | Mutation |
|---|---|---|
| `bash lab.sh check` | Is there registered or orphaned state for this UID? | None |
| `LAB_DRY_RUN=1 bash lab.sh setup` | What would setup create? | None |
| `bash lab.sh setup` | Can the exact guarded state and two workspaces be registered? | Bounded `/tmp` state plus a locked setup ownership receipt |
| `bash lab.sh status` | Which lifecycle records exist? | None |
| `bash lab.sh run baseline` | What does a healthy release contract look like? | One controller-write-once record, validated later |
| `bash lab.sh inject guided` | Can I inspect a failed canary without changing real infrastructure? | One case record |
| `bash lab.sh inject independent` | Can I reason from an unfamiliar raw scenario? | One answer-isolated case record |
| `bash lab.sh scenario` | Which raw independent inputs are available before interpretation? | None |
| `bash lab.sh acknowledge-predictions SHA256` | Was one caller-supplied digest receipt recorded before controller-gated views? | One digest-only acknowledgment; external bytes are not inspected |
| `bash lab.sh observe VIEW` | What does one control-plane owner report? | None |
| `bash lab.sh experiment cache-key` | What changes when only the definition digest is added to the cache key? | One deterministic experiment record |
| `bash lab.sh recover` | What bounded modeled transition restores the operation? | One recovery record |
| `bash lab.sh verify-operation` | Did the original release promise succeed once without duplicates? | One verification record |
| `LAB_DRY_RUN=1 bash lab.sh cleanup` | What exact state would cleanup remove? | None |
| `bash lab.sh cleanup` | Can exact owned state be removed and absence proved? | Removes only validated allowlisted state |

Allowed observation views are `graph`, `runner`, `cache`, `artifact`, `identity`, `approval`, and `deployment`.

## Preflight

Open a normal Ubuntu 24.04 shell and change into this directory:

```bash
pwd
id
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
```

Expected safe branches:

- `state=absent` means no descriptor and no matching orphan were observed for your UID at that instant.
- `dry_run=true` describes setup but creates nothing.
- `root-is-refused-run-as-a-normal-user` means leave the elevated shell. Root is not required.
- `missing-required-command-*` means stop. This lab never installs the missing tool.
- `unregistered-lesson-root-found-refusing-to-guess` means preserve and inspect the matching path; never delete it by name pattern.

## Guided case: a green pipeline reaches an unhealthy canary

### 1. Establish the healthy contract

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Do not memorize the values. Read the relationships:

- the source revision and pipeline-definition digest identify two different inputs;
- each job gets a separate private path rather than inheriting another job's files; because both paths have the same owner UID, this proves separation and identity, not a security-isolation boundary;
- cache reuse is keyed by source, definition, lock, runner image, and job policy;
- the artifact tested, reviewed, and deployed has one digest;
- the execution identity has a subject, audience, and environment scope;
- approval names an artifact and environment, not merely a run number;
- one logical release produces one promotion and zero duplicates;
- user verification is separate from a green deployment command.

`network_calls=0`, `hosted_ci_calls=0`, `registry_calls=0`, and `cloud_calls=0` are model boundaries, not claims about the Ubuntu host.

### 2. Stop at the first failed boundary

```bash
bash lab.sh inject guided
bash lab.sh observe graph
bash lab.sh observe runner
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe identity
bash lab.sh observe approval
bash lab.sh observe deployment
```

Source, runner, cache, artifact, identity, and approval evidence remain coherent. The canary does not become ready and its user check fails. The graph therefore does not start promotion, and the known production artifact remains unchanged.

This is an important production habit: a failed deployment attempt does not have to become a production outage. Preserve the failed canary evidence, stop the rollout boundary, and keep serving the known artifact while you investigate.

### 3. Recover the operation, not just the job

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

Recovery models removal of the failed canary, correction of the readiness contract, a fresh canary, one promotion, and end-to-end user verification. It does not rebuild the artifact because the evidence did not show artifact drift. Rebuilding everything would destroy useful evidence and change more state than the diagnosis justified.

Verification must report the controller converged, workspaces stayed distinct and private to the current UID, cache and artifact identity are valid, identity scope and approval binding are valid, promotion happened once, the rollback target remains, and the user check passed. `workspace_isolation_proven=false` is intentional: two mode-0700 directories owned by one UID do not prevent that UID from reading both.

### 4. Prove exact cleanup

```bash
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

The preview must not change the active case. Final evidence is `cleanup_proven=true` followed by `state=absent`.

## Independent case: reason before asking for more evidence

Begin only from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

The scenario output contains configured and observed inputs only. It deliberately omits a decision, diagnosis, root cause, recovery, validity verdict, deployment outcome, duplicate-effect conclusion, and answer key. Save your response outside the guarded lab root; cleanup owns every allowlisted path inside it.

Before viewing anything else, write:

1. the user operation and the exact artifact/environment promise;
2. at least four competing hypotheses across runner, cache, artifact, identity, approval, and deployment boundaries;
3. one observation that would reject each hypothesis;
4. whether any production transition is currently authorized, with the evidence required to change that answer;
5. the smallest safe next observation.

Save those predictions in a file **outside** the guarded lab root. The controller accepts and stores only the lowercase SHA-256 value you supply, never your answer:

```bash
sha256sum /path/to/my-les-0024-predictions.md
bash lab.sh acknowledge-predictions <paste-the-64-character-digest>
```

Independent observations, the experiment, and recovery remain closed until that acknowledgment exists. This proves only that the controller recorded a syntactically valid digest receipt before opening those gates. It does not prove that an external file existed, that the digest matched it, who wrote it, or when it was written; nor can it prevent the external file from changing. Retain the original bytes and recompute the digest during review if you want later changes to be detectable.

Then request views one at a time:

```bash
bash lab.sh observe graph
bash lab.sh observe runner
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe identity
bash lab.sh observe approval
bash lab.sh observe deployment
```

Keep these concepts separate while reasoning:

- **workspace separation in this lab** proves distinct paths, permissions, and identities only; real isolation needs a different UID, namespace, VM, or hardened runner sandbox;
- **concurrency control** asks whether two attempts can change the same release operation simultaneously;
- **cache identity** asks whether reuse is bound to every relevant input;
- **artifact identity** asks whether the tested, reviewed, and candidate bytes are the same object;
- **workload identity** asks who is acting, for which audience, in which environment;
- **approval binding** asks exactly what object and environment a review authorized;
- **deployment state** asks what actually changed and what users receive.

Do not inspect `fixtures/pipeline_model.py` or `verify.sh` during the independent attempt. They necessarily encode verifier expectations and would replace diagnosis with source-code reading.

After the views, run one controlled experiment. The control and treatment keep source, lockfile, runner image, and job policy unchanged. The treatment adds exactly one variable: the pipeline-definition digest in the cache key.

```bash
bash lab.sh experiment cache-key
```

The result proves only the deterministic local model. It does not benchmark a real cache or contact hosted CI. After recording your diagnosis, recovery proposal, abort conditions, and verification plan:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
```

Passing these commands verifies the encoded model transition. It does not score your reasoning. Independent competence still requires review of your original, timestamped explanation and later transfer to an unfamiliar system.

## Engineering verifier

Run the verifier only from clean state:

```bash
bash verify.sh
```

It checks:

- Bash and Python syntax;
- dry-run behavior and invalid lifecycle transitions;
- the complete guided and independent lifecycles;
- all seven evidence views;
- the failed-canary stop boundary;
- the raw independent scenario’s answer-isolation field denylist;
- strict parsing and exact digest binding across baseline, case, prediction, experiment, recovery, and verification records;
- refusal of truncated or semantically altered records instead of self-attesting success;
- a prediction-gated, single-variable cache-key experiment;
- valid pre-existing state refusal with a byte-for-byte before/after snapshot;
- setup registration races against a directory and a symlink-to-directory, with exact refusal and no foreign-path mutation;
- a verifier-release-gated post-registration race where lifecycle A cannot resume until B has replaced it and been snapshotted; A then refuses without a success receipt and B remains byte-for-byte unchanged;
- verifier cleanup bound to the locked setup descriptor receipt, including preservation of a complete replacement lifecycle;
- an unexpected file and a record symlink without changing the foreign target;
- concurrent cleanup refusal on the stable descriptor lock;
- simulated interruption after one workspace removal and after the empty-root window, followed by safe resume;
- a stale invocation that cannot recreate the unlinked descriptor;
- idempotent cleanup and final `state=absent`.

The verifier refuses any pre-existing state. Setup emits no ownership receipt until its locked descriptor and loaded root match the candidate inode and root created by that same invocation. The verifier then binds cleanup authority to those emitted values. Normal and EXIT cleanup pass that receipt back to `lab.sh`; after locking the current descriptor, `lab.sh` refuses before mutation if either identity differs. Therefore a later lifecycle that reuses the predictable descriptor path is preserved rather than mistaken for verifier-owned state. Ownership is cleared only after guarded cleanup and a final `state=absent` check. If an owned run is interrupted, run `bash lab.sh check`; if the state is `cleanup-in-progress`, run only `bash lab.sh cleanup` to resume.

## Why each modeled failure matters

| Boundary | Dangerous shortcut | Better evidence |
|---|---|---|
| Runner | “The same runner worked yesterday.” | Exact image/toolchain identity, workspace ownership, isolation, and job logs |
| Cache | “A cache hit makes the build trustworthy.” | Complete key inputs, entry writer, creation run, object digest, and post-restore validation |
| Artifact | “The run number is the artifact.” | Immutable digest carried unchanged through test, review, promotion, and readback |
| Identity | “The token exists, so access is valid.” | Issuer, subject, audience, environment, expiry, claims, policy result, and audit identity |
| Approval | “Someone clicked approve.” | Reviewer authority and a binding to exact artifact, environment, policy, and freshness window |
| Concurrency | “Both attempts are for the same commit.” | One logical release ID, serialized ownership, idempotency receipt, and duplicate-effect reconciliation |
| Deployment | “The deploy command returned zero.” | Controller state, canary health, user journey, dependency health, artifact served, and rollback readiness |

## Refusal guide

| Refusal | What it means | Safe response |
|---|---|---|
| `root-is-refused-run-as-a-normal-user` | The shell is elevated | Return to a normal user; do not weaken the guard |
| `state-lock-contended` | Another controller invocation owns the descriptor-backed state transition | Wait for or identify it; never delete the state descriptor |
| `unexpected-child-*` | The guarded root contains a path the controller does not own | Preserve it, identify its creator, and remove only after exact review |
| `workspace-*-identity-invalid` | A workspace sentinel no longer names its directory | Stop job execution and inspect the path without trusting inherited files |
| `installed-model-differs-from-reviewed-source` | Executed fixture bytes changed | Preserve both hashes and restore only from the reviewed repository copy |
| `expected-regular-file-*` | A record is missing, linked, or has an invalid type | Do not follow it; inspect file type, owner, link count, and target separately |
| `registered-root-pattern-invalid` | The descriptor points outside the exact per-lesson grammar | Treat it as tampered and never clean the target |
| `cleanup-is-in-progress-use-cleanup-to-resume` | Mutation closed after the descriptor entered cleanup phase | Run only cleanup or inspect; do not start a case |
| `test-hooks-are-verifier-only` | An internal failure or timing hook was invoked manually | Unset it and use `bash verify.sh` |

## Retrieval questions

1. Why are source revision, pipeline definition, run ID, and artifact digest four different identities?
2. What does a distinct private workspace prove here, and what additional boundary would real runner isolation require?
3. Why must a cache key include the pipeline definition and runner image as well as source?
4. Why is a cache hit evidence of reuse rather than evidence of correctness?
5. Which identity claims should a deployment gate verify before authorizing an environment change?
6. What exactly should an approval bind to?
7. How do two retries become a concurrency problem even when both use the same commit?
8. Why can a failed canary be a successful safety control?
9. What evidence distinguishes “deployment command succeeded” from “users received the intended release”?
10. Why does cleanup refuse unknown state instead of deleting everything with the lesson prefix?

## Scope and security statement

This lab is designed to resist common accidents, not a malicious process running as the same UID or a compromised kernel. The receipt and candidate-identity checks close the tested lifecycle-replacement windows, but they are not a security boundary against a same-UID process that can continuously rewrite pathnames and bytes around checks. The current user can alter their own repository and `/tmp` files. The fixture creates no cryptographic credential and makes no real authorization decision.

The verifier exercises controlled process interruption after durable phase transition, partial child cleanup, and root removal. It does not simulate kernel failure, storage-controller failure, filesystem corruption, or sudden power loss; `fsync` narrows that boundary but cannot prove the entire host storage stack.

A production CI/CD design additionally needs protected source and workflow changes, ephemeral or securely cleaned runners, sandbox and network boundaries, secretless or short-lived federated identity, least privilege, protected artifact storage, signed provenance where policy requires it, independent approval controls, immutable environment history, deployment reconciliation, user-centered telemetry, rollback and roll-forward plans, audit retention, capacity limits, and tested incident response.
