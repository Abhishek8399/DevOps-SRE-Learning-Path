# LES-0008 lab: troubleshoot with FRAME before you restart

This lab is about one production habit:

> A symptom is where the investigation starts. It is not the root cause.

You will investigate the same user-visible symptom in three deterministic
virtual cases. The lab gives you evidence in layers so you can practise FRAME:

```text
Frame
  define impact, operation, scope, time window, and what good looked like
Retrieve
  collect baseline, path, change, metric, and log evidence
Analyze
  separate fact, inference, assumption, and hypothesis; find first divergence
Make a safe move
  choose the smallest reversible experiment with prediction and abort condition
Evaluate and encode
  verify the user operation, preserve evidence, prevent recurrence, clean up
```

The fixture advances no real clock and creates no real outage. Python prints
fixed key-value evidence for a virtual request path:

```text
[synthetic client]
       |
       v
[gateway] -> [API worker pool] -> [dependency]
                    |
                    +-> bounded virtual queue
```

The foreground Python command does not sleep, open sockets, create workers, or
write files. Bash records only small, deterministic summaries inside the lab's
private temporary directory. This is a reasoning lab, not a benchmark.

## Environment and blast-radius card

| Item | Contract |
|---|---|
| Tested environment | Ubuntu 24.04, including WSL2 Ubuntu 24.04 |
| User | Normal non-root user; root is refused before setup mutation |
| Time | 20-35 minutes guided; verifier normally completes in seconds |
| CPU | No synthetic pressure; only short foreground Bash/Python commands |
| Memory | Less than 32 MiB expected for the fixture process |
| Disk | Less than 256 KiB in one guarded lab root plus one state descriptor |
| Network and ports | None; no socket is opened and no port is bound |
| Packages | No installation; Bash, Python 3.8+, and standard Ubuntu tools |
| Privilege and cost | No `sudo`, Docker, cloud account, or paid resource |
| Persistent processes | None; no background or long-running child process |
| Mutation boundary | One exact `/tmp` lab root and one UID-scoped descriptor |

The lab ignores `TMPDIR` and passes `--tmpdir=/tmp` explicitly. It verifies
that `/tmp` is a real, root-owned, sticky directory before mutation.

## Commands and risk

Run from this lab directory.

| Command | Risk | Purpose |
|---|---|---|
| `bash lab.sh check` | Read-only | Check dependencies, boundary, and registered state. |
| `bash lab.sh setup` | Bounded mutation | Create private lab state. |
| `bash lab.sh status` | Read-only | Validate and summarize recorded state. |
| `bash lab.sh run baseline` | Bounded mutation | Record the known-good comparison once. |
| `bash lab.sh inject guided` | Bounded mutation | Select the guided virtual incident. |
| `bash lab.sh inject changed` | Bounded mutation | Select the changed-constraint case. |
| `bash lab.sh inject transfer` | Bounded mutation | Select the answer-isolated transfer case. |
| `bash lab.sh observe symptoms` | Read-only | Retrieve user impact evidence. |
| `bash lab.sh observe timeline` | Read-only | Retrieve event order without claiming causality. |
| `bash lab.sh observe path` | Read-only | Compare each virtual request-path stage. |
| `bash lab.sh observe changes` | Read-only | Compare known-good and incident configuration. |
| `bash lab.sh probe app-only` | Read-only | Run a virtual discriminating app-path probe. |
| `bash lab.sh probe dependency-only` | Read-only | Run a virtual dependency-path probe. |
| `bash lab.sh probe queue` | Read-only | Inspect the virtual waiting stage. |
| `bash lab.sh experiment retry-off` | Bounded mutation | Record one reversible virtual canary result. |
| `bash lab.sh experiment known-good-workers` | Bounded mutation | Record a known-good worker-limit canary. |
| `bash lab.sh recover` | Bounded mutation | Restore fixture-scoped known-good behavior. |
| `bash lab.sh verify-operation` | Bounded mutation | Record the post-recovery synthetic user operation. |
| `bash lab.sh cleanup` | Bounded mutation | Remove only validated, allowlisted lab artifacts. |
| `bash lab.sh reset` | Bounded mutation | Guarded cleanup followed by fresh setup. |
| `bash verify.sh` | Bounded mutation | Exercise clean-state lifecycle and refusal tests. |

Arguments are closed allowlists. Strings such as paths, shell fragments, extra
arguments, or unknown case names are refused before case mutation.

## Guided lifecycle

```bash
bash lab.sh check
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
bash lab.sh inject guided
```

Before retrieving more evidence, write a short FRAME note:

```text
Impact:
Exact failing operation:
Affected and unaffected scope:
Time window:
Known-good baseline:
Facts already observed:
Assumptions:
Top hypotheses:
First discriminating evidence:
```

Then retrieve evidence deliberately:

```bash
bash lab.sh observe symptoms
bash lab.sh observe timeline
bash lab.sh observe path
bash lab.sh observe changes
bash lab.sh probe app-only
bash lab.sh probe dependency-only
bash lab.sh probe queue
```

Run a virtual experiment only after stating its prediction, abort condition,
and what result would weaken the hypothesis:

```bash
bash lab.sh experiment retry-off
bash lab.sh experiment known-good-workers
```

Restore only the virtual fixture, verify the user operation, inspect state, and
prove cleanup:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

A separate case requires a fresh state:

```bash
bash lab.sh reset
bash lab.sh run baseline
bash lab.sh inject changed
```

`reset` is not a shortcut around an unknown file or unsafe identity. It uses the
same guarded cleanup contract and refuses when ownership, root, sentinel, file
type, link count, or allowlist identity cannot be proven.

## Stable status contract

After setup, `status` emits exactly these fields in this order:

```text
lesson_id=LES-0008
state=ready
lab_root=/tmp/devops-sre-LES-0008-frame-troubleshooting.XXXXXXXX
baseline=pending
active_case=none
experiments_completed=none
recovery=pending
operation_verification=pending
execution=virtual-time-bounded
cases_available=guided,changed,transfer
```

Allowed changes are:

- `baseline`: `pending` or `recorded`;
- `active_case`: `none`, `guided`, `changed`, or `transfer`;
- `experiments_completed`: `none`, `retry-off`,
  `known-good-workers`, or their fixed comma-separated order;
- `recovery` and `operation_verification`: `pending` or `complete`.

The random eight-character root suffix is evidence of isolation, not a path to
copy into a manual deletion command.

## Baseline output contract

`run baseline` writes and prints these fields in order:

```text
record=baseline
case=baseline
requests=20
successes=20
timeouts=0
p95_latency_ms=120
app_p95_ms=30
dependency_p95_ms=50
max_queue=0
dependency_calls=20
retries=0
worker_limit=4
app_revision=app-2026.08.1
config_revision=cfg-001
```

This is the known-good comparison window. It does not prove future capacity,
real production behavior, or that every dependency is healthy.

## Observation and probe fields

All values are deterministic. A smaller virtual sample is not a production
service-level indicator.

| Command family | Exact field order after `record`, `case`, and selector |
|---|---|
| `observe symptoms` | `requests`, `successes`, `timeouts`, `p95_latency_ms`, `error` |
| `observe timeline` | `baseline_at`, `event_at`, `symptom_at`, `followup_at`, `observation` |
| `observe path` | `gateway_p95_ms`, `app_only_p95_ms`, `dependency_p95_ms`, `max_queue`, `dependency_calls` |
| `observe changes` | `app_revision_before`, `app_revision_after`, `worker_limit_before`, `worker_limit_after`, `retry_limit_before`, `retry_limit_after`, `config_revision_before`, `config_revision_after` |
| `probe ...` | `requests`, `successes`, `p95_latency_ms`, `max_queue`, `conclusion_hint` |

The three cases intentionally share `upstream_timeout` as the surface error.

| Case | Symptom p95/success | First useful divergence | Trap |
|---|---|---|---|
| `guided` | 980 ms; 8/20 | Dependency-only p95 is 700 ms; app-only is 30 ms | A recent app deploy is correlated, while retries amplify dependency calls from 20 to 44. |
| `changed` | 840 ms; 14/20 | Dependency-only remains 50 ms; app queue reaches 12 after worker limit changes 4 to 1 | Reusing the guided diagnosis ignores changed evidence. |

This README intentionally previews no transfer symptom values, divergence,
diagnosis, or trap. Discover and classify its evidence independently.

`p95_latency_ms` is the nearest fixed virtual tail value for that record. The
model is not estimating a population percentile.

## Experiment output contract

Both experiment commands emit:

```text
record
case
experiment
requests
successes
timeouts
p95_latency_ms
dependency_calls
max_queue
worker_limit
result
```

The important fixed results are:

| Case | `retry-off` | `known-good-workers` |
|---|---|---|
| `guided` | Calls fall to 20 and p95 to 760 ms, but the dependency problem remains. | No material latency recovery. |
| `changed` | No material change; queue remains 12. | Success returns to 20/20, p95 to 120 ms, queue to 0. |

Transfer-case experiment outcomes are deliberately omitted. State a prediction
before each experiment and interpret the returned evidence without this README
acting as an answer key.

An experiment result is evidence against or for a hypothesis. It is not
automatically a production fix. Adding workers can move overload into a
database, and removing retries can reduce amplification while requests still
fail.

## Recovery and verification output

`recover` restores only the virtual fixture's known-good values and emits:

```text
record=recovery
case=<guided|changed|transfer>
action=restore_fixture_known_good
requests=20
successes=20
timeouts=0
p95_latency_ms=120
dependency_calls=20
max_queue=0
worker_limit=4
lost_work=0
```

`verify-operation` is separate because “the change applied” is not the same as
“the user operation recovered”:

```text
record=verification
case=<guided|changed|transfer>
operation=synthetic_checkout
requests=20
successes=20
timeouts=0
p95_latency_ms=120
lost_work=0
recovery_verified=true
```

These values prove only the deterministic model returned to its known-good
contract.

## Exact state boundary

The UID-scoped descriptor is:

```text
/tmp/devops-sre-LES-0008-frame-troubleshooting-<uid>.state
```

It is a mode-`0600`, current-UID-owned, regular non-symlink, single-link file
containing exactly version, lesson ID, UID, and the registered root.

The root must match:

```text
/tmp/devops-sre-LES-0008-frame-troubleshooting.<8 alphanumeric characters>
```

It must be canonical, mode `0700`, current-UID-owned, a direct child of `/tmp`,
and not a symlink. Only these regular single-link artifacts are allowed:

| Artifact | Mode during strict operation | Created by |
|---|---:|---|
| `.les-0008-sentinel` | `0600` | setup |
| `artifact-manifest.tsv` | `0600` | setup |
| `incident_model.py` | `0500` | setup from reviewed source |
| `baseline.summary` | `0600` | run baseline |
| `active-case.state` | `0600` | inject |
| `retry-off.experiment` | `0600` | experiment |
| `known-good-workers.experiment` | `0600` | experiment |
| `recovery.summary` | `0600` | recover |
| `verification.summary` | `0600` | verify-operation |

Strict operations verify the sentinel, manifest, copied model, state ordering,
field ordering, and byte-exact deterministic summaries, including the intended
end-of-file newline. Cleanup deliberately accepts content or mode drift only
for allowlisted regular current-UID single-link files; it still requires the
byte-exact descriptor, canonical root, byte-exact sentinel, ownership, file
type, link count, and no unknown name. This narrower recovery contract can
remove a partial known result without guessing about unfamiliar state.

When the descriptor is absent, `check`, `setup`, and `cleanup` scan only direct
children of `/tmp` matching this lesson's exact eight-character root pattern.
If a canonical directory owned by the current UID is present, the command
reports the first candidate and refuses. It does not delete or repair that
candidate. This catches a private root left by an uncatchable interruption
without turning a name pattern into deletion authority.

Cleanup validates every entry before removal, removes exact known files,
removes the sentinel last, uses `rmdir` for the empty root, then removes the
descriptor. It never uses recursive deletion. Success ends with:

```text
cleanup=complete
state=absent
cleanup_proof_scope=descriptor-and-owned-candidates-at-check
cleanup_proven=true
```

The proof is a point-in-time statement: the registered descriptor and root are
absent, and no matching canonical current-UID-owned candidate existed at the
final check. It is not a promise that another process cannot create a new path
after that check. `cleanup=already-clean` uses the same candidate check and
proof scope.

## Refusal and recovery guide

| Refusal | Meaning | Safe response |
|---|---|---|
| `run this lab from a normal non-root Ubuntu shell` | Root use is outside this host-lab contract. | Leave the privileged shell; do not weaken the check. |
| `lab state is absent` | Setup has not registered a root. | Run setup. |
| `unregistered lesson root candidate exists` | A matching current-UID-owned root exists without a descriptor, commonly after an interruption. | Preserve it, inspect the exact reported path, and remove it only after independently proving its identity and contents. |
| `record the baseline before incident injection` | There is no known-good comparison. | Record the baseline first. |
| `an incident case is already active` | A second case would mix evidence. | Finish and cleanup, or guarded reset. |
| `... was already recorded` | Immutable evidence would be overwritten. | Read status or reset for a fresh attempt. |
| Manifest, model, or summary `content changed` | Strict evidence is no longer trustworthy. | Use guarded reset only if cleanup identity still passes. |
| `unexpected artifact blocks safe operation` | The root contains a name the lab did not authorize. | Preserve it, identify ownership, remove only with independent proof, retry. |
| Owner, type, mode, link, path, descriptor, or sentinel failure | The removal identity boundary is unsafe. | Stop; inspect exact state; never substitute `rm -rf`. |
| `lab root changed during cleanup` | A race or unknown entry prevented `rmdir`. | The sentinel is restored when safe; resolve the new entry and retry. |

A refusal that preserves unknown state is a successful safety behavior.

## Verifier

Run `verify.sh` only from a clean state. It refuses to replace an active learner
state.

```bash
bash verify.sh
```

It exercises:

- syntax-compatible lifecycle behavior for all three cases;
- hostile `TMPDIR` confinement to explicit `/tmp`;
- baseline, observation, probe, experiment, recovery, verification, status,
  cleanup, and post-cleanup absence;
- repeated baseline, second-case, repeated-experiment, and invalid-input
  refusal;
- byte-exact sentinel, manifest, summary, and verifier-target trailing-blank
  tamper refusal;
- known manifest and summary drift recovery through guarded reset;
- unknown-artifact cleanup refusal without mutation;
- known-file symlink refusal while an external verifier-owned target survives;
- unregistered-root detection by `check`, `setup`, and `cleanup`, preservation
  across every refusal, and exact verifier-owned empty-root removal;
- a static learner-README answer-isolation scan for known transfer spoilers;
- idempotent cleanup.

A pass ends with:

```text
verification_passed=true
cases=guided,changed,transfer
refusals=repeat-baseline,second-case,repeat-experiment,invalid-input,sentinel-trailing-blank,manifest-trailing-blank,summary-trailing-blank,unexpected-artifact,symlink,external-target-trailing-blank,orphan-candidate
answer_isolation=passed
cleanup_proven=true
```

Root refusal, forced interruption, concurrent command races, and ShellCheck are
separate release-matrix gates even when this verifier passes. Catchable setup
traps are installed before root creation, but `SIGKILL` cannot be trapped. The
orphan-candidate check makes that residue visible and refuses to guess. The lab
does not claim serialized concurrent operation because it does not create a
per-UID lock; run one lifecycle command at a time.

## Evidence separation

The verifier proves the implemented fixture contract on one environment. It
does not prove learner understanding. Website reading state, copied model
answers, mentor-operated output, and `verification_passed=true` must never
change the learner ledger.

A reviewed learner submission needs:

1. the FRAME statement written before recovery;
2. facts separated from assumptions, inferences, and hypotheses;
3. at least two ranked hypotheses and the evidence that discriminates them;
4. one safe move with exact target, prediction, abort condition, and rollback;
5. before/after user-operation evidence, not only a changed configuration;
6. prevention or missing-telemetry improvement;
7. `cleanup_proven=true` followed by `state=absent`;
8. sanitized output with no username, random host path, employer data, or secret.

The `guided` case may have a revealed answer after an attempt. The `changed`
case tests changed constraints. The `transfer` assessment must stay
answer-isolated and should be reviewed without using fixture source as an answer
key. Independent transfer and delayed recall remain separate mastery evidence.
