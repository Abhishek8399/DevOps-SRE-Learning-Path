# LES-0022 lab: prove what produced an artifact

This offline lab makes a slippery build problem visible: two jobs can say "success" while using different inputs, and two artifacts can have the same digest while the current workspace is already unsafe. You will work with a tiny standard-library model that exposes source bytes, a dependency lock, dependency integrity, build context, cache keys, artifact hashes, an SBOM, and a provenance statement as separate evidence.

No real dependency is downloaded. No Docker daemon is required. No socket is opened. The model never runs a compiler or package manager and never contacts a registry. That keeps failure practice safe and fast, but it also limits the claim: verifier success proves this guarded local model behaved as designed. It does not certify a real build platform, package registry, container image, signature, SBOM generator, SLSA level, or release.

## Environment card

| Item | Contract |
|---|---|
| Tested platform | Ubuntu 24.04 LTS under WSL 2 |
| Tested tools | Bash 5.2.21 and Python 3.12.3 standard library |
| Run as | A normal non-root user; effective UID 0 is refused with status 77 |
| Time | 35-55 minutes guided; 45-75 minutes independent |
| Network | None; no remote name, URL, registry, or socket is used |
| Packages | Bash 5+, Python 3, coreutils, util-linux, and findutils; the lab installs nothing |
| CPU/RAM/disk | One short Python process at a time; under 64 MiB RAM expected; under 128 KiB guarded state |
| Ports and containers | None |
| Host changes | One descriptor `/tmp/reliability-atlas-LES-0022-UID.state` and one random private directory matching `/tmp/reliability-atlas-LES-0022.XXXXXXXX` |
| Cleanup | `bash lab.sh cleanup`; exact allowlisted files only, never a wildcard or recursive removal |

Do not use `sudo`. Do not manually delete the descriptor or private directory. A cleanup refusal is useful evidence that the controller can no longer prove ownership or scope.

## What the model contains

```text
reviewed repository files
  |
  +-- fixtures/build_model.py
  +-- lab.sh
  `-- verify.sh
          |
          | setup installs one byte-identical model copy
          v
/tmp/reliability-atlas-LES-0022.<random>/  mode 0700, current UID
  |-- .sentinel                           mode 0400
  |-- .lock                               mode 0600
  |-- build_model.py                      mode 0500, source bytes checked
  |-- baseline.record                     mode 0600, after baseline
  |-- case.record                         mode 0600, after injection
  |-- recovery.record                     mode 0600, after recovery
  |-- verification.record                 mode 0600, after verification
  `-- cleanup.marker                      mode 0600, only while cleanup resumes

/tmp/reliability-atlas-LES-0022-UID.state mode 0600, exact root registration
```

A matching pathname is not enough. The controller validates canonical path, owner UID, mode, link count, exact child allowlist, sentinel, model bytes, and descriptor grammar. It refuses a symlink, hard link, changed model, unregistered candidate, redirected descriptor, unexpected child, elevated execution, or competing lock holder.

## Preflight and preview

Open Ubuntu 24.04 and change into this directory. Then run:

```bash
bash lab.sh check
LAB_DRY_RUN=1 bash lab.sh setup
```

Expected branches:

- `state=absent` means this UID has no registered state and no matching orphan at that instant.
- `dry_run=true` describes the bounded state setup would create but creates nothing.
- A missing tool means stop. The lab never installs it for you.
- A root refusal means return to the normal Ubuntu user. Privilege is not a repair.

## Guided exercise: same intent, different bytes

### 1. Create a guarded state and baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

Read the baseline as a chain, not as a collection of random hashes:

- `source_sha256` identifies the exact modeled source bytes.
- `lock_sha256` identifies the dependency resolution record.
- `locked_dependency_sha256` identifies the local dependency artifact named by that lock.
- `context_sha256` identifies framed path names and bytes after deterministic sorting.
- `toolchain_id`, `source_date_epoch`, timezone, locale, normalized path, and order are declared build-environment inputs.
- `artifact_sha256` and `repeat_artifact_sha256` match because two normalized builds emitted the same bytes.
- SBOM and provenance subject digests point at those artifact bytes.
- `consumer_readback=valid` is the modeled end-to-end acceptance check.

A SHA-256 digest is evidence about bytes. It does not say the bytes are authorized, safe, signed, complete, or produced by the claimed builder.

### 2. Inject volatility

```bash
bash lab.sh inject guided
bash lab.sh observe inputs
bash lab.sh observe dependencies
bash lab.sh observe context
bash lab.sh observe artifact
```

The source, lock, dependency, and declared toolchain are equal. Yet the naive artifacts differ because they embed a wall-clock value, a workspace-path digest, a run label, and traversal order. This is the important mental move: do not start by blaming "the compiler." Walk backward from the first differing bytes to the first uncontrolled input.

The context view shows that a set and a byte stream are different ideas. The same three files can be traversed in different orders. A stable builder sorts by a documented byte-level rule before hashing or packaging.

Now inspect caching and supply-chain records:

```bash
bash lab.sh observe cache
bash lab.sh observe supplychain
```

The guided cache key covers source, lock, dependency, context, toolchain, and flags. That is necessary, not magical: it makes reuse conditional on the declared inputs. A cache hit still proves reuse, not correctness. The local SBOM and provenance statement agree with the artifact, but the statement is unsigned and created by the same teaching process. It is structure, not independent trust.

### 3. Normalize, rebuild, and verify

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
```

Recovery removes volatile fields, uses `SOURCE_DATE_EPOCH`, normalizes the build path, sorts inputs, verifies the dependency digest, rebuilds twice, and compares the output bytes. Verification then checks the lock, context allowlist, complete cache key, artifact subject links, zero duplicate promotions, consumer readback, and zero network calls.

This is stronger than "the second build passed." It verifies the original promise: the reviewed input set produces one accepted artifact identity twice.

### 4. Preview and perform exact cleanup

```bash
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

The preview must not change `active_case`. Final evidence should include `cleanup_proven=true` and `state=absent`.

## Independent exercise: the trustworthy-looking stale artifact

Start from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

Copy the raw scenario into `ASM-0051-response-template.md` before requesting an observation. Store your response outside the guarded random directory. The raw scenario provides declared inputs, current digests, a deliberately narrow cache key, context count, operation identity, and build count. It deliberately omits derived outcome, diagnosis, root cause, retry decision, recovery, promotion decision, and answer text.

Write at least four hypotheses. Useful shapes include:

1. the current dependency still matches the lock and another input explains the evidence;
2. dependency bytes drifted while the dependency name looked unchanged;
3. an incomplete cache key returned a prior artifact without evaluating current inputs;
4. a context file outside the reviewed allowlist changed the intended input set.

For every hypothesis, predict a result that would disconfirm it. Then ask for the smallest view:

```bash
bash lab.sh observe inputs
bash lab.sh observe dependencies
bash lab.sh observe context
bash lab.sh observe cache
bash lab.sh observe artifact
bash lab.sh observe supplychain
```

The deliberately uncomfortable clue is that the candidate artifact hash can equal the expected baseline while current input integrity is invalid. That is not a contradiction. A stale cache entry can contain previously valid bytes. It cannot prove that the current request, workspace, lock, and builder would produce them now.

Before recovery, write a decision card with:

- artifact promotion permitted or refused;
- exact evidence and unresolved unknowns;
- cache quarantine boundary;
- dependency restore source and digest;
- complete replacement cache key;
- two-build comparison rule;
- SBOM and provenance subject checks;
- signature/trust limitation;
- abort conditions and cleanup plan.

Then run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash verify.sh
```

The verifier begins from clean state, runs both cases, proves dry-run behavior and idempotent cleanup, checks raw-answer isolation, tests invalid transitions, tampers with the installed model, adds an unexpected file, substitutes a symlink toward an external canary, redirects the descriptor, creates an orphan, simulates interruption after the cleanup marker, resumes cleanup, and proves final absence. It restores only its own exact mutations.

## What each failure injection teaches

| Injection | Symptom | First useful boundary | Safe response |
|---|---|---|---|
| Wall clock and workspace path | Same declared source, different artifact hashes | Compare unpacked bytes and volatile metadata | Normalize or remove values that are not part of artifact meaning |
| Unstable traversal order | Same file set, different context stream | Compare path order and framed context digest | Sort paths with one documented rule before hashing or packaging |
| Dependency drift | Name/version claim looks familiar but digest differs | Lock record versus actual dependency bytes | Fail closed; restore an approved artifact or review a lock update |
| Incomplete cache key | A green cache hit returns an old artifact | Key fields versus every build-affecting input | Quarantine entry and replace the key; do not clear all caches blindly |
| Unexpected context file | Local note enters the recursive context | Reviewed allowlist and context manifest | Exclude intentionally or add through review; do not silently absorb it |
| Unsigned local provenance | Subject and materials look coherent | Attestation producer and verification policy | Treat as a claim; require trusted signing and policy in production |

## Troubleshooting refusals

| Refusal | Meaning | Safe next action |
|---|---|---|
| `root-is-refused-run-as-a-normal-user` | Effective UID is zero | Return to the intended normal-user Ubuntu shell |
| `unregistered-lesson-root-found-refusing-to-guess` | A matching path exists without an owned descriptor | Preserve it and inspect owner, type, mode, and contents; do not delete by pattern |
| `unexpected-child-*` | Guarded state contains an unrecognized path | Preserve the path, find its creator, and remove it only after exact review |
| `installed-model-differs-from-reviewed-source` | Executed model bytes changed | Preserve both hashes and reinstall only from the reviewed repository copy |
| `expected-regular-file-*` | A required path is missing, linked, or has the wrong type | Stop and inspect without following the untrusted link |
| `registered-root-pattern-invalid` | Descriptor points outside the exact root grammar | Treat the descriptor as tampered; do not follow or clean its target |
| `state-lock-contended` | Another invocation owns the workflow lock | Identify or wait for that invocation; do not delete the lock |
| `cleanup-is-in-progress-use-cleanup-to-resume` | A cleanup marker closed the mutation phase | Run only `bash lab.sh cleanup` or inspect the marker; do not restart the case |
| `cleanup-interruption-hook-is-verifier-only` | A learner tried the internal test hook | Use `bash verify.sh`; do not set internal verifier controls manually |

## Evidence questions

1. What exact equality must hold before you claim a build is reproducible?
2. Why is a version pin weaker than a version plus artifact integrity?
3. What is the difference between a manifest, a lockfile, and installed bytes?
4. Why must build context be treated as an input API?
5. Why does a cache hit prove reuse rather than correctness?
6. How can an expected artifact hash coexist with invalid current inputs?
7. Why is a second clean build different from rerunning against the same warm cache?
8. What does an SBOM describe, and what does it not prove?
9. What does provenance claim, who must be trusted, and what must a verifier check?
10. Why must cleanup refuse an unexpected file even though refusal is inconvenient?

Complete answers are in LES-0022. ASM-0051 remains answer-isolated and requires human review.

## Scope and security statement

This is a teaching model, not a security boundary against a malicious process running as the same UID. The current user can alter their own `/tmp` state and repository. The guards prevent common accidents and make ownership assumptions visible. Production assurance additionally needs protected source control, hermetic or declared builders, trusted package mirrors, isolated identities, signed attestations, verified policy, protected release storage, independent rebuilders where appropriate, and incident-ready logs.
