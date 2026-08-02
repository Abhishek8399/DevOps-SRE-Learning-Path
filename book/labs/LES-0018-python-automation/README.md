# LES-0018 lab: reconcile Python automation before retry

This is a deterministic offline reasoning lab for production-safe Python
automation. It creates no network socket, calls no service, installs no
package, edits no host configuration, starts no long-lived process, and uses no
credential. Python prints fixed key-value evidence; Bash owns a guarded local
lifecycle beneath `/tmp`.

The habit is simple:

> Validate before effect, preserve one logical operation identity, treat a
> timeout after mutation as unknown, reconcile at the state owner, then verify
> the original operation.

A passing verifier demonstrates the checked-in lab guards and deterministic
cases. It does not certify Python skill, API behavior, production safety, or
mastery.

## Environment and blast radius

Run on Ubuntu 24.04 LTS or WSL 2 Ubuntu 24.04 as a normal user.

| Property | Contract |
|---|---|
| Required tools | Bash, Python 3.8+, and ordinary Ubuntu core utilities |
| Privilege | root is refused before state creation |
| Network | none; no socket or request |
| Host configuration | read-only |
| Temporary state | one UID-specific descriptor and one private registered directory in `/tmp` |
| Cleanup | exact allowlisted regular files and the exact empty registered directory; no recursive or wildcard deletion |
| Cloud/Kubernetes | neither required nor contacted |

Stop if any guard refuses. Do not use `sudo`, change a mode, edit the
descriptor, or manually remove a discovered matching path. The script refuses
unknown ownership instead of guessing.

## Files

```text
LES-0018-python-automation/
|-- README.md
|-- lab.sh
|-- verify.sh
`-- fixtures/
    `-- operation_model.py
```

- `operation_model.py` reads no file and opens no socket. It emits deterministic
  baseline, scenario, observation, recovery, and verification records.
- `lab.sh` validates environment and state, controls lifecycle transitions,
  checks source and installed-model digests, and performs guarded cleanup.
- `verify.sh` exercises both cases, answer isolation, invalid transitions,
  content tampering, symlink and descriptor redirection, orphan refusal,
  cleanup, and generated-residue absence.

## State boundary

The descriptor is:

```text
/tmp/reliability-atlas-LES-0018-<numeric-uid>.state
```

It registers one root shaped exactly like:

```text
/tmp/reliability-atlas-LES-0018.<eight-alphanumeric-characters>
```

Before trusting or removing state, the controller checks:

1. the effective UID is nonzero;
2. `/tmp` is a real root-owned mode-1777 directory resolving to `/tmp`;
3. the descriptor is a regular non-symlink file, mode 0600, owned by this UID,
   with one hard link and exact four-line identity;
4. the root matches the exact prefix, is real, resolves to itself, is mode
   0700, and is owned by this UID;
5. the sentinel identifies LES-0018 and this UID;
6. the source digest, manifest, installed-model digest, owner, mode, and link
   count agree;
7. every directory entry is on the exact allowlist;
8. every recorded model output can be reproduced byte for byte.

Cleanup first records an exact `.cleanup-in-progress` marker inside the validated
root. It removes optional lifecycle records, the installed model, manifest, and
sentinel by exact name, then removes the marker, empty root, and exact descriptor.
If cleanup is interrupted, the marker and descriptor let the same guarded
command validate the remaining phase and resume. If interruption occurs after
the root is removed, the exact descriptor permits descriptor-only finalization.
It never follows an unexpected symlink or recursively deletes a path.

## Commands

```text
bash lab.sh check
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
bash lab.sh inject guided|independent
bash lab.sh scenario
bash lab.sh observe operation|input|runtime|state|outcome
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
```

`scenario` is available only for an active unrecovered independent case. It
contains raw client inputs and local phase, not authoritative outcome,
diagnosis, receipt, duplicate result, recovery, or an answer key.

## Preflight

From this directory:

```bash
pwd -P
id
bash -n lab.sh verify.sh
PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; p=Path("fixtures/operation_model.py"); compile(p.read_text(encoding="utf-8"),str(p),"exec")'
bash lab.sh check
```

Expected fields include:

```text
environment=ready
privilege=normal-user
network=none
execution=deterministic_python_model
state=absent
```

`check` creates nothing.

## Guided case

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject guided
bash lab.sh observe operation
bash lab.sh observe input
bash lab.sh observe runtime
bash lab.sh observe state
bash lab.sh observe outcome
```

Explain why all of these matter separately:

- an external field has string type instead of required integer type;
- runtime validation was missing;
- one helper result was nonzero;
- a broad handler continued and top-level status became zero;
- direct publication exposed two of three required records;
- consumer readback is invalid.

Do not summarize this as “add type hints.” Type hints are not runtime input
validation. Do not summarize it as “use check=True.” A child status is not a
semantic postcondition.

Recover and verify:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
bash lab.sh check
```

The modeled recovery validates the boundary, reconstructs and validates a
complete candidate, publishes it, and checks consumer readback.

## Independent case

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Copy the raw scenario into notes outside the lab directory. Before any
`observe`, write the promised operation, state owners, possible rejected,
committed, and unknown outcomes, one disconfirming check per hypothesis, and
whether retry is currently permitted.

Then gather only needed evidence:

```bash
bash lab.sh observe operation
bash lab.sh observe input
bash lab.sh observe runtime
bash lab.sh observe state
bash lab.sh observe outcome
```

The client deadline and local `attempting` phase cannot prove service state.
The outcome view models an authoritative query by stable operation ID. Complete
ASM-0039 before running recovery.

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
```

The intended learning is why another mutation attempt is or is not safe, not
memorizing the recovery string.

## Full verifier

From this directory as a normal user:

```bash
bash verify.sh
```

Expected final fields:

```text
verification_passed=true
cases=guided,independent
answer_isolation=raw-independent-inputs-no-derived-outcome-diagnosis-or-recovery
network_mutation=none
host_mutation=guarded-tmp-state-only
cleanup_proven=true
```

The verifier expects a clean beginning. If it finds existing registered or
orphan state, inspect the first refusal. Do not bypass it.
If `verify.sh` receives INT or TERM during a deliberate tamper drill, its exit
trap restores the descriptor, installed model, and baseline when their guarded
identities still match. It deliberately leaves otherwise valid registered lab
state for evidence. Run `bash lab.sh cleanup`; cleanup resumes its exact phase,
then run `bash lab.sh check` to prove absence. SIGKILL and power loss cannot run
a process trap, but the cleanup marker still makes cleanup itself resumable.

Root refusal is tested separately by an authorized reviewer in an isolated
environment. A normal learner should not acquire privilege merely to run that
test.

## What passing proves and does not prove

Passing proves that this environment parsed the sources, drove both modeled
cases, rejected tested unsafe states, preserved external targets in redirection
tests, kept independent raw input answer-isolated, and ended with registered
state absent.

It does not prove the learner's diagnosis, real subprocess process-tree
handling, network or API behavior, distributed idempotency, filesystem
power-loss durability, Kubernetes safety, security certification, or mastery.

## Production transfer worksheet

| Model field | Production evidence to replace it |
|---|---|
| Python runtime | executable, version, package artifact, image, UID, cwd, namespace |
| raw request | schema version, safe digest, validated fields, authorization |
| operation ID | durable logical identity and owner retention window |
| client attempt | start, deadline, status/exception, response ID, sanitized streams |
| local phase | transactional checkpoint, version, writer and controller |
| authoritative result | service receipt or state/version query |
| publication | candidate validation, commit version, consumer readback |
| verification | original user or delivery operation, duplicates, missing work, window |

Real APIs, credentials, packages, CI pipelines, systemd units, images, and
Kubernetes resources are outside the lab. Any such action needs separate
authorization, a scoped plan or diff, least privilege, abort conditions,
rollback or compensation, and operation-level verification.
