# LES-0026 local observability evidence lab

> **Maintainer-review notice:** this copy lives under `drafts/.../support/lab` and is not the learner entry point. Review and verification happen here before promotion. Every learner command below intentionally points to the future canonical location, `book/labs/LES-0026-observability-foundations`.

This lab teaches one operating habit: **do not ask a single signal to answer a question it cannot answer**.

It creates a tiny, deterministic request stream and five kinds of evidence—metrics, logs, traces, events, and a profile—entirely on Ubuntu 24.04. A second case deliberately omits two exported traces. That case is a **guided walkthrough**, not an answer-isolated assessment: you inspect the symptom, record a hypothesis, and only then ask the lab to reveal its modeled pipeline evidence. The source remains transparent and reviewable.

This is a provider-neutral teaching model. It does not install an agent, contact a collector, emulate a production service, prove a vendor's behavior, or prove that two correlated facts have a causal relationship.

## What you will learn

After the guided path, you should be able to explain:

- what question each signal family can answer well;
- why event time, observation time, and ingest time are different;
- how a sequence number helps distinguish reordering from missing data;
- why a shared correlation key joins evidence but does not prove cause;
- how to investigate a missing signal before blaming the application;
- why high-cardinality identifiers do not belong in metric labels;
- why retention and privacy are part of observability design;
- what a local profile proves—and what it does not prove.

## The evidence path

```text
                        deterministic request fixture
                                     |
          +--------------------------+---------------------------+
          |              |              |             |          |
       metrics          logs           traces        events    profile
    "how much?"     "what record?"  "which path?" "what changed?" "which calls?"
          |              |              |             |          |
          +----------------------+-------+-------------+----------+
                                 |
                    requestId + syntheticTraceKey
                       + timestamp + sequence
                                 |
                    one evidence timeline for inquiry
                                 |
              hypothesis -> next discriminating check -> claim

Shared keys make correlation possible. Correlation is not causality.
```

Think of the five families as camera angles, not competing products:

| Signal | Strong question | Weak or unsafe conclusion |
| --- | --- | --- |
| Metric | “How many requests failed? Did latency cross our modeled threshold?” | It does not explain one request's exact path. |
| Log | “What did the application record for request 4?” | A log line alone does not prove root cause or user impact. |
| Trace | “Which modeled steps contributed duration for this request?” | A span sequence does not prove causality or host saturation. |
| Event | “What change or operational marker was recorded near this time?” | “Earlier” does not mean “caused later.” |
| Profile | “Which local Python functions were called, and how often?” | This deterministic summary omits timing and does not prove a production hot path. |

## Safety contract

Run this lab as your normal Ubuntu user—native Ubuntu or Ubuntu in WSL—never as `root`.

The lab:

- uses only Bash and the Python 3 standard library;
- makes no network, cloud, container, package-manager, or privilege calls;
- creates a random owned root under `/tmp` and a per-UID state directory;
- records the device and inode of the root before later operations;
- keeps its ownership descriptor immutable and starts cleanup with a separately bound intent record;
- requires owned, non-symlink directories with mode `0700` and files with mode `0600` (`0400` for the sentinel);
- refuses unexpected children rather than deleting them;
- cleans only an explicit allowlist of names;
- uses deterministic, allowlisted quarantine names so an interrupted cleanup can resume;
- quarantines and rechecks a deletion target's inode before unlinking it;
- leaves a replacement untouched if a cooperative replacement race is detected;
- proves final absence after cleanup.

Why the extra transactional machinery? Cleanup contains several separate filesystem operations. A process can stop after a rename but before an unlink, or after a case record disappears but before its artifacts do. Random temporary names and an in-place descriptor rewrite would make ownership ambiguous after such an interruption. This controller instead keeps immutable identity evidence, removes a case record before its artifacts, and uses reconstructible quarantine names. A later `cleanup` can distinguish “not started,” “interrupted after quarantine,” and “already completed” without wildcard deletion.

The state path is:

```text
/tmp/reliability-atlas-LES-0026-<your-uid>.state.d
```

The data root has this grammar:

```text
/tmp/reliability-atlas-LES-0026-<your-uid>.<random-suffix>
```

If the controller reports an unexpected file, inspect it. Do not broaden the cleanup command. The refusal is the safety feature.

## Prerequisites

The learner workflow needs only:

**[READ-ONLY]**

```bash
python3 --version
bash --version | head -n 1
```

The maintainer verifier additionally expects `shellcheck`, `sha256sum`, `grep`, and `find`, all of which are already present in the intended Ubuntu 24.04 workbench. The lab never installs them.

After promotion, enter the canonical lab directory on native Ubuntu or Ubuntu in WSL, then begin with a read-only check:

**[READ-ONLY]**

```bash
cd /path/to/DevOps-SRE-Learning-Path/book/labs/LES-0026-observability-foundations
bash lab.sh check
```

Expected starting evidence includes:

```text
state=absent
state_recovery_count=0
orphan_count=0
normal_user_required=true
network_required=false
```

If state or an orphan is already present, stop. Finish or inspect that earlier run instead of guessing which directory is safe to remove.

## Guided case: see all five signal families

### 1. Preview, then create the bounded workspace

The dry run must not mutate state:

**[READ-ONLY]**

```bash
LAB_DRY_RUN=1 bash lab.sh setup
bash lab.sh check
```

Create the workspace:

**[MUTATING]**

```bash
bash lab.sh setup
```

**[READ-ONLY]**

```bash
bash lab.sh status
```

`setup` records SHA-256 digests for the reviewed executable sources. If one changes during an active run, later commands refuse. That prevents a lifecycle from silently changing meaning halfway through.

### 2. Generate the guided evidence

**[MUTATING]**

```bash
bash lab.sh run guided
```

**[READ-ONLY]**

```bash
bash lab.sh inspect-signals guided
```

The input contains eight requests and three deliberate symptoms:

```text
sequence 3 and 5 -> queue wait above 200 ms
sequence 4       -> HTTP-like status 503
sequence 6       -> total modeled latency above 300 ms
```

The metric view reports aggregates. The log view retains one structured record per request. Each trace has a `request.total` root. `queue.wait` and `service.handle` are sequential sibling phases beneath that root, not parent and child:

```text
request.total                    offset 0, duration queue + service
├── queue.wait                   offset 0, duration queue
└── service.handle               offset queue, duration service
```

That topology prevents an impossible claim such as placing a 450 ms service operation inside a 15 ms queue span. The event view records one release marker plus queue and error observations. The profile view records deterministic call counts.

Now bind the guided evidence into a verification record:

**[MUTATING]**

```bash
bash lab.sh verify-guided
```

The command deliberately says:

```text
correlation_is_causality=false
production_causality_proven=false
```

That wording matters. Suppose the release marker comes before the slow request. You may say, “the release is temporally correlated and is a hypothesis worth testing.” You may not say, “the release caused the latency” until a discriminating experiment or stronger evidence excludes credible alternatives.

## The three clocks and the sequence number

Every request-oriented row carries:

- `eventTime`: when the modeled service says the activity occurred;
- `observedTime`: when the modeled instrumentation observed it;
- `ingestTime`: when the modeled pipeline accepted it;
- `sequence`: a deterministic monotonic number for this fixture.

The model keeps this order:

```text
eventTime <= observedTime <= ingestTime
```

Why keep all three? The fixture makes this concrete: sequence 2 has a modeled ingest delay. Its event still occurs second, but its stored arrival sorts after sequences 3, 4, 5, and 6.

**Pause before running the command.** Predict the eight sequence numbers when sorted first by `eventTime`, then by `ingestTime`. Also decide whether a reordered ingest view proves any row is missing.

**[READ-ONLY]**

```bash
bash lab.sh inspect-ordering
```

The bounded result is:

```text
sequence_order=1,2,3,4,5,6,7,8
event_time_order=1,2,3,4,5,6,7,8
ingest_time_order=1,3,4,5,6,2,7,8
missing_sequences=none
ingest_reordered=true
fixture_explanation=sequence-2-modeled-ingest-delay
production_cause_proven=false
```

This distinguishes reordering from loss: every sequence is present, but ingest order differs. The local fixture tells you why its own row moved. In production, the ordering alone would not prove whether buffering, retry, transport, collector pressure, or a clock problem caused it.

Real distributed systems do not automatically have a universal sequence. If you introduce one, define its scope: per process, partition, stream, tenant, or workflow. A per-partition sequence cannot establish a global order across partitions.

## Synthetic keys are deliberately not W3C trace context

The files use `requestId`, `syntheticTraceKey`, and `syntheticSpanKey`. Values such as `trace-key-0006` are readable teaching keys. They are **not** W3C `traceparent` trace IDs or span IDs, and the lab claims no propagation-standard compliance.

A correlation key answers, “which records were modeled as belonging together?” It does not answer:

- whether the key was propagated securely in a real system;
- whether every hop emitted telemetry;
- whether the upstream operation caused a downstream symptom;
- whether two clocks were synchronized;
- whether sampling or export changed the evidence set.

## Missing-signal guided walkthrough: do not guess from absence

This section is deliberately a source-transparent guided walkthrough. It is not the answer-isolated transfer assessment. Generate its evidence:

**[MUTATING]**

```bash
bash lab.sh run missing-signal
```

**[READ-ONLY]**

```bash
bash lab.sh inspect-signals missing-signal
```

You will see eight metric requests and eight log rows, but only six trace rows. At this stage, the correct conclusion is narrow:

> Two expected trace rows are absent from the exported trace artifact.

You do **not** yet know why. Plausible hypotheses include:

- the application never produced them;
- a sampler intentionally excluded them;
- an exporter dropped them;
- they arrived after the query window;
- the query scope was wrong;
- correlation propagation or lookup was defective.

The first inspection therefore prints `cause_determined=false`. Ask the next discriminating question: do pipeline counters and the artifact manifest agree on production, export, drop, and stored row counts?

**Pause and attempt before reveal.** Write one sentence in your own notes: “My current hypothesis is ___ because ___; the counter or manifest result that would weaken it is ___.” Then record only the hypothesis category. The choice is not scored; its purpose is to preserve your reasoning before the walkthrough reveals its fixture evidence.

Allowed categories are `not-produced`, `sampled`, `dropped`, `delayed`, `query-scope`, and `correlation-defect`. This example intentionally records a plausible category, not a promised correct answer:

**[MUTATING]**

```bash
bash lab.sh record-hypothesis delayed
```

Without an attempt record, the reveal command refuses with `pipeline-reveal-requires-hypothesis-attempt`.

Now inspect the modeled pipeline counters and bind the inspection record:

**[MUTATING]**

```bash
bash lab.sh inspect-pipeline missing-signal
```

For this fixture only, that later evidence reports:

```text
walkthrough=true
attempt_recorded_before_reveal=true
pipeline_trace_produced=8
pipeline_trace_exported=6
pipeline_trace_dropped=2
modeled_drop_sequences=3,7
modeled_drop_reason=export_queue_full
manifest_trace_rows=6
```

The safe statement is:

> In this deterministic local model, the producer counter is eight, the exporter records two drops with the modeled reason `export_queue_full`, and the manifest binds six rows to the stored trace digest.

It is unsafe to generalize that answer to a production collector or a vendor implementation. Production counters can be stale, mislabeled, reset, incomplete, or emitted by a different replica. You would next validate counter scope, time window, reset behavior, pipeline logs, queue saturation, sampling policy, and storage/query health.

Complete the operational proof:

**[MUTATING]**

```bash
bash lab.sh verify-operation
```

## Cardinality: identifiers are not free dimensions

The model uses bounded metric dimensions:

```text
route + method + status_class
```

It explicitly refuses the design idea “put every request ID in a metric label.” If eight unique request IDs become labels, this tiny fixture can create eight series instead of the three bounded combinations it actually needs. At production scale, users, UUIDs, raw URLs, session IDs, and trace IDs can multiply series until memory, query latency, and cost fail together.

Use this decision rule:

```text
Need a bounded aggregate split? -> metric label may fit.
Need a unique request lookup?   -> controlled log/trace/event field may fit.
Contains personal or secret data? -> minimize, redact, restrict, or do not collect.
```

Cardinality is not merely “many values.” It is the number of distinct label combinations over the active time range. Ten labels with ten possible values each can produce up to ten billion combinations if they vary independently. Actual systems may produce fewer, but the multiplication risk is the design warning.

## Retention: availability of evidence has a clock

The fixture analyzes records two days after their event time and models different policies:

| Signal | Modeled retention | Present at analysis time? |
| --- | ---: | --- |
| Metrics | 7 days | yes |
| Logs | 3 days | yes |
| Traces | 1 day | no |
| Events | 30 days | yes |
| Profiles | 6 hours | no |

Nothing is actually deleted. `retention.json` is a policy calculation, not proof that a storage engine enforced deletion.

This matters during incidents: “no trace found” can mean the trace never existed, was sampled, was dropped, was queried incorrectly, arrived late, or expired under retention. Check the evidence lifecycle before turning absence into a service claim.

## Privacy: observability data is production data

The source fixture contains a synthetic `.invalid` email address so the model can prove redaction. Generated logs contain only `[REDACTED]`; the raw value must not appear in any output artifact.

The model also lists request IDs, trace IDs, and customer emails as prohibited metric labels. That is a teaching baseline, not a complete legal or organizational policy. In a real design, document:

- the minimum fields needed for an operational purpose;
- classification and allowed destinations;
- masking or tokenization rules;
- access control and auditability;
- retention and deletion requirements;
- incident handling for telemetry leaks.

Never assume “it is only a log” makes a value safe to collect.

## Profile boundary

`profile.json` comes from Python standard-library `cProfile` and `pstats`. The program performs one `profile_work` call and twelve `checksum_step` calls. It emits only those deterministic call counts and a result checksum.

Timing fields are intentionally omitted because wall and CPU durations vary with the host. Therefore this lab proves that the local profiler observed those function calls. It does not prove CPU saturation, scheduler delay, a kernel hot path, or what a production process spends time doing.

## Artifact map

Each case lives beneath the guarded `/tmp` root:

| Artifact | Purpose |
| --- | --- |
| `metrics.json` | Aggregate request, error, latency, and queue evidence. |
| `logs.ndjson` | One redacted structured request record per sequence. |
| `traces.ndjson` | Exported modeled spans and synthetic correlation keys. |
| `events.ndjson` | Release and operational timeline markers. |
| `profile.json` | Deterministic Python call-count summary. |
| `pipeline-counters.json` | Produced/exported/dropped counts; inspect later in the missing case. |
| `cardinality.json` | Bounded-series calculation and unsafe-label warning. |
| `retention.json` | Policy-time calculation; performs no deletion. |
| `privacy.json` | Redaction and prohibited-label assertions. |
| `evidence-limits.json` | What each artifact proves and does not prove. |
| `signal-manifest.json` | SHA-256 and row-count binding for the ten evidence artifacts. |
| `case-report.json` | Case-level counts and external-effect boundary. |

NDJSON means newline-delimited JSON: each line is an independent JSON object. This makes streaming and line-oriented inspection practical without requiring the entire dataset to be one array.

## Cleanup

Preview cleanup without mutation:

**[READ-ONLY]**

```bash
LAB_DRY_RUN=1 bash lab.sh cleanup
bash lab.sh status
```

Then remove only the registered, validated lab objects:

**[DESTRUCTIVE]** — destructive only inside the exact registered lab lifecycle; unexpected or replacement objects are preserved and refused.

```bash
bash lab.sh cleanup
```

**[READ-ONLY]**

```bash
bash lab.sh check
```

Successful final evidence is:

```text
cleanup_proven=true
state=absent
state_recovery_count=0
orphan_count=0
```

Cleanup is allowlisted, non-recursive, and restartable. It writes a bound cleanup-intent record without rewriting the immutable descriptor. It removes case records before case artifacts, then advances the root and state directories through deterministic recovery names. If execution stops after a rename, unlink, or `rmdir`, the next cleanup recognizes only the exact allowlisted original/recovery pair and resumes. It never sweeps a prefix or wildcard.

Linux `renameat2(RENAME_NOREPLACE)` prevents overwriting a quarantine destination. The controller confirms that a quarantined inode is the inode it opened. Internal regressions inject cooperative replacements and interruptions at thirteen durable boundaries. This narrows race and crash risk; it does not claim adversarial, filesystem-wide atomic deletion against another process running as the same UID.

## Maintainer verification

This command is for maintainers reviewing the draft before promotion:

**[DESTRUCTIVE]** — creates and removes only bounded verifier-owned `/tmp` lifecycles and private regression roots.

```bash
bash verify.sh
```

The verifier first reads `/etc/os-release` through Python's standard library and accepts the canonical result only on Ubuntu 24.04. On any other system it prints the detected platform and refuses the canonical pass. It checks Bash syntax, ShellCheck, Python AST parsing, JSON configuration, root guards, corrected sibling-span topology, the real ingest-reordering exercise, hypothesis-before-reveal, evidence bindings, dry-run non-mutation, pre-existing and concurrent-run preservation, unexpected-child refusal, replacement preservation, thirteen interruption/resume boundaries, exact cleanup, and final absence. Its EXIT trap receives cleanup authority only after parsing and validating the lifecycle token plus state/root identities created by that verifier invocation.

It does not access the network, install packages, call a cloud, or require `sudo`.

## Troubleshooting by evidence

| Refusal | Meaning | Safe next action |
| --- | --- | --- |
| `root-is-refused-run-as-a-normal-user` | The lab was invoked as UID 0. | Exit the root shell and use your normal Ubuntu account, native or WSL. |
| `state-already-exists` | A run—or foreign object—already owns the exact state name. | Use `[READ-ONLY] bash lab.sh status`; do not overwrite it. |
| `cleanup-in-progress` | A restartable cleanup intent exists. | Run `[DESTRUCTIVE] bash lab.sh cleanup`; normal learning commands remain refused. |
| `cleanup-recovery-state-exists` | An interrupted cleanup has a registered recovery state. | Run `[DESTRUCTIVE] bash lab.sh cleanup`; setup will not overwrite it. |
| `unregistered-lesson-root-found-refusing-to-guess` | A matching root exists without a trusted state descriptor. | Inspect ownership and provenance manually; the lab will not guess. |
| `reviewed-source-digest-changed-...` | An executable source changed after setup. | Preserve evidence, restore the reviewed source version, then clean up. |
| `workspace-already-exists-...-cleanup-required` | A prior run created all or part of that case. | Inspect it, then use guarded cleanup and start a new lifecycle. |
| `unexpected-root-child-...` | Something outside the allowlist appeared. | Inspect and handle that object explicitly; cleanup leaves it untouched. |
| `deletion-target-identity-changed-...` | A name was replaced at the cleanup boundary. | Investigate the replacement; it is preserved. |

The final lesson is simple: start with a precise claim, name the evidence that supports it, name the evidence it lacks, and choose the next check that can distinguish competing explanations.
