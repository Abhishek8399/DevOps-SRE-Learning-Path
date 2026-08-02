# LES-0009 lab: read a Git worktree before you repair it

This lab gives you a real Git repository without asking you to risk your own
work. It teaches one durable habit:

> Never choose an undo command until you can name the source state, destination
> state, path owner, expected result, and recovery boundary.

The repository is local and synthetic. It has no remote, contains no real
credential, and lives only under one guarded lesson-owned `/tmp` root.

## Mental picture

~~~text
                     git add
WORKING TREE ----------------------> INDEX
     |                                 |
     | git diff                        | git diff --cached
     v                                 v
what changed after staging?       proposed next snapshot
                                       |
                                       | git commit
                                       v
                              HEAD + object database

Remote and CI are outside this lab. No command crosses the network.
~~~

When status shows `MM service.conf`, three versions exist:

~~~text
HEAD version A -> staged index version B -> current worktree version C
~~~

Ordinary diff shows B to C. Cached diff shows A to B. Read both.

## Safety contract

Run from Ubuntu 24.04 or WSL 2 Ubuntu 24.04 as a normal non-root user.
Required tools are Bash, Git, GNU find, and standard core utilities available in
the base environment.

The harness:

- refuses effective UID 0;
- installs nothing and never invokes `sudo`;
- opens no port, starts no background process, and creates no load;
- makes no network, DNS, login, clone, fetch, pull, push, or hosted API request;
- creates no Git remote;
- uses only synthetic filenames, identity, content, and placeholder values;
- writes one UID-scoped descriptor and one random mode-0700 root under `/tmp`;
- refuses an unregistered root with the lesson prefix;
- refuses a changed descriptor, root, owner, mode, sentinel, or top-level name;
- refuses every symlink, hard-linked file, special file, foreign-owned item, or
  cross-device item under the root;
- bounds entry count, individual file size, and total regular-file bytes;
- uses only path-scoped Git restore during modeled recovery;
- never runs `reset --hard`, `clean`, rebase, force push, or a remote command;
- proves the exact root and descriptor absent after guarded cleanup.

The cleanup must traverse Git's variable internal files, so it validates the
entire bounded root before physical, one-filesystem, depth-first deletion. It
deletes only regular files and directories inside that exact root. A newly
appearing link or special file makes final root removal fail. Like other
same-user local scripts, it cannot defeat every malicious race from another
process running as your UID; do not run competing processes in its root.

## Commands and risk

| Command | Classification | Purpose |
|---|---|---|
| `bash lab.sh check` | Read-only | Validate environment and registered-state boundary. |
| `bash lab.sh setup` | Bounded mutation | Create one isolated synthetic repository. |
| `bash lab.sh run baseline` | Bounded mutation | Record the clean branch and HEAD baseline once. |
| `bash lab.sh inject guided` | Bounded mutation | Create the taught mixed Git state. |
| `bash lab.sh inject transfer` | Bounded mutation | Create the answer-isolated assessment state. |
| `bash lab.sh observe status` | Read-only at lesson level | Show branch and porcelain state, including ignored paths. Git itself may refresh index stat data. |
| `bash lab.sh observe worktree` | Read-only | Compare worktree `service.conf` with the index. |
| `bash lab.sh observe staged` | Read-only | Compare the staged `service.conf` with `HEAD`. |
| `bash lab.sh observe ignored` | Read-only | Show ignored path/rule evidence without file values. |
| `bash lab.sh observe history` | Read-only | Show synthetic HEAD, object types, branch, subject, and remote count. |
| `bash lab.sh recover` | Bounded mutation | Restore only exact fixture paths after your written prediction. |
| `bash lab.sh verify-operation` | Bounded mutation | Record a fixed assertion of the recovered local snapshot. |
| `bash lab.sh status` | Read-only at lesson level | Validate state and print lifecycle fields. |
| `bash lab.sh reset` | Bounded cleanup and setup | Start a new guarded attempt. |
| `bash lab.sh cleanup` | Bounded destructive cleanup | Remove only the validated lesson root and descriptor, then prove absence. |
| `bash verify.sh` | Bounded engineering QA | Exercise positive flows and negative safety boundaries from clean state. |

No Dockerfile is involved. `lab.sh` is the entry point.

## Start with a safety card

Write this before setup:

~~~text
environment: Ubuntu 24.04 or WSL2 Ubuntu 24.04
identity: normal user; EUID must not be zero
target: generated /tmp/devops-sre-LES-0009-safe-local-workbench.XXXXXXXX
network: forbidden and not implemented
remote: forbidden and not configured
real credentials/data: forbidden
expected changes: descriptor, guarded root, synthetic Git repo, lifecycle files
abort: any refusal, unexpected owner/path/type/link/name/size/state/output
recovery: supported recover or reset only
cleanup: supported cleanup followed by check reporting state=absent
~~~

If a command refuses, the safe response is to retain the first diagnostic. Do
not edit the descriptor or random root. Do not substitute `sudo`, force, a
broad glob, or manual recursive deletion.

## Guided lifecycle

From this directory:

~~~bash
bash lab.sh check
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject guided
bash lab.sh observe status
bash lab.sh observe worktree
bash lab.sh observe staged
bash lab.sh observe ignored
bash lab.sh observe history
bash lab.sh status
~~~

The guided status includes:

~~~text
## main
MM service.conf
?? notes.txt
!! .env.local
!! scratch.log
~~~

Read it carefully:

- `main` remains the current local branch;
- left `M`: index `service.conf` differs from `HEAD`;
- right `M`: worktree `service.conf` differs from the index;
- `notes.txt` is untracked, which says nothing about human ownership;
- the two `!!` paths match repository ignore rules;
- an ignore match does not prove secret safety or historical absence.

The ignored observation prints rule and path evidence. It deliberately does not
print the placeholder value in `.env.local`. Use the same habit in production:
begin with metadata, not secret content.

## Predict recovery

Before mutation, write:

~~~text
question: can exact selective restoration recover the synthetic baseline?
expected: main and HEAD unchanged; tracked bytes equal baseline; clean status;
          zero remotes; fixture temporary paths absent
abort: any different status, path, owner, link, content contract, or refusal
recovery of recovery: stop and retain state; do not broaden the command
verification: verify-operation plus status, then guarded cleanup plus check
~~~

Run:

~~~bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
~~~

`recover` first validates the complete active state. It uses:

~~~text
HEAD -> index for service.conf
index -> worktree for service.conf
exact validated removal for each fixture-local temporary file
~~~

The verification requires:

~~~text
branch=main
HEAD equals the recorded baseline
HEAD snapshot has exact synthetic tracked content
working tree and index are clean
remote_count=0
fixture temporary state is absent
~~~

These assertions prove only the modeled local operation. They do not prove that
a remote, CI system, deployment, database, Kubernetes controller, or customer
operation recovered.

## Finish and prove cleanup

After retaining sanitized learning evidence:

~~~bash
bash lab.sh cleanup
bash lab.sh check
~~~

A complete cleanup reports:

~~~text
cleanup=complete
state=absent
cleanup_proof_scope=descriptor-and-owned-candidates-at-check
cleanup_proven=true
~~~

The following check independently reports `state=absent`. The scope phrase is
important: it is a point-in-time proof for the exact descriptor and matching
current-UID candidates. It does not prevent future path creation.

## Refusal guide

| Refusal | Meaning | Safe response |
|---|---|---|
| `run this lab from a normal non-root Ubuntu shell` | Root is intentionally unsupported. | Exit root and use your normal Ubuntu identity. |
| `Ubuntu 24.04 LTS is required` | The tested OS contract differs. | Use the supported environment; do not install from the lab. |
| `unregistered lesson root candidate exists` | A matching root is not safely tied to the descriptor. | Preserve it and investigate ownership; never delete by wildcard. |
| `state descriptor content is invalid` | The exact state pointer changed. | Stop and preserve the descriptor and root for review. |
| `unexpected top-level artifact` | The root contains a name outside its fixed lifecycle allowlist. | Identify and remove it only after proving ownership; do not weaken cleanup. |
| Link, special-file, ownership, device, count, or size refusal | A structural cleanup invariant failed. | Stop. Do not run a recursive fallback. |
| `active case Git status differs` | Fixture Git state was changed outside the supported interface. | Preserve evidence; guarded cleanup remains available if structural checks pass. |
| Duplicate baseline, case, recovery, or verification | Evidence is immutable for this attempt. | Read status or use guarded reset for a genuinely fresh attempt. |
| Cleanup leaves the root | State changed during or after validation. | Descriptor remains when possible; inspect the exact root and stop. |

A refusal is successful safety behavior. "The script would not delete" is
better than deleting a path it no longer understands.

## Independent transfer boundary

For `ASM-0012`:

1. start from clean absent state;
2. use setup and one baseline;
3. inject only `transfer`;
4. use supported observations;
5. classify state and write recovery prediction before mutation;
6. use supported recovery and operation verification;
7. use guarded cleanup and following check;
8. submit sanitized original evidence and disclose assistance.

This README intentionally does not describe the transfer case's path states,
diff values, or answer. Do not inspect implementation files to extract them.
The reviewer evaluates your evidence and reasoning, not whether you can copy a
fixture answer.

## Run engineering verification

Only from clean state:

~~~bash
bash verify.sh
~~~

A pass ends with:

~~~text
verification_passed=true
cases=guided,transfer
answer_isolation=passed
external_target_preserved=true
cleanup_proven=true
~~~

The verifier proves its encoded assertions ran successfully in this
environment. It includes duplicate-operation, invalid-view, unexpected
top-level, symlink, out-of-scope descriptor, and orphan-candidate refusals. It
does not prove every possible race or attack, production equivalence, lesson
acceptance, independent learner reasoning, later recall, or mastery.

## What to retain

Retain a sanitized worksheet, not the random root:

- environment and safety card;
- prediction before each mutation;
- baseline object ID shortened or sanitized only when policy requires;
- status pairs and path classifications;
- ordinary/cached diff interpretation without sensitive values;
- recovery result and proof limits;
- operation verification;
- cleanup and following check;
- production transfer and remaining unknowns.

Never retain the placeholder as if it were a real credential, and never use a
real credential to make the exercise feel more realistic.
