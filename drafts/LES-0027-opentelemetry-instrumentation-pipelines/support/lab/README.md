# LES-0027 bounded OpenTelemetry pipeline lab candidate

## Read this boundary first

This directory is a **quarantined lab candidate**, not a canonical learner lab and not evidence that OpenTelemetry has run. The checked-in image and wheel digests are deliberate `RECORD_REAL_*` placeholders. On the 2026-08-02 authoring host, the Docker client and Compose plugin were available, while daemon readiness varied between checks; neither required official image was cached during the dependency inspection. Consequently, `prepare`, `validate-configs`, `setup`, and every runtime exercise currently fail closed before creating a lab lifecycle.

An independent source audit found unresolved runtime-safety defects in cleanup locking, partial-setup recovery, temporary validation-container proof, live enforcement of Compose limits/network membership, worker supervision, and durable evidence validation. They are listed in the package-level `STATUS.md`. Do not replace the placeholders, run preparation, or treat the conditional runtime walkthrough as authorized until those blockers are fixed and re-reviewed.

The runnable `[READ-ONLY]` model teaches the relationships without importing OpenTelemetry. Its output says `opentelemetry_executed=false`, `collector_executed=false`, and `model_is_not-runtime-evidence=true`. Do not relabel model output as SDK, Collector, container, export, or production evidence.

## What this lab is designed to prove after its locks are reviewed

The future runtime is deliberately small:

```text
Host process
  |
  | HTTP :18027 (127.0.0.1 only)
  v
[service-a / Python SDK] --HTTP :8081 + W3C traceparent--> [service-b / Python SDK]
          | OTLP/HTTP :4318                               | OTLP/HTTP :4318
          v                                               v
       [agent-a]                                       [agent-b]
          |                                               |
          +-------------- OTLP/gRPC :4317 ----------------+
                                  |
                                  v
                              [gateway]
                                  |
                                  +--> detailed debug exporter -> container stdout

All five containers share one Docker internal network.
No container can route to the Internet through that network.
No backend, cloud service, Docker socket, host network, or production data is present.
```

The two agent Collectors own finite sending queues and bounded retries. The gateway owns receive, memory protection, batching, and a detailed debug exporter. The debug exporter is intentionally the terminal observation boundary. Finding a trace ID in gateway stdout proves that this exact gateway process decoded and exported that local trace to its debug output. It does **not** prove backend ingest, indexing, query visibility, retention, a vendor product, or production behavior.

## Safety and scope

| Item | Contract |
|---|---|
| Host | Ubuntu 24.04, normal user only; root exits 77 |
| Default network use | none; model and static verification are local |
| Explicit network use | only `prepare --allow-network-downloads`, and only after real reviewed locks exist |
| Runtime pulls | prohibited with Compose `pull_policy: never` and `--pull never` |
| Runtime package index | prohibited with `pip --no-index --require-hashes --no-deps` |
| Host bindings | `127.0.0.1` only; service A `18027`, gateway metrics `18888`, agent metrics `18889` and `18890` |
| Container privileges | read-only root filesystems, non-root users, all capabilities dropped, no-new-privileges, bounded memory/CPU/PIDs |
| Docker access inside containers | none; the Docker socket is never mounted |
| State | one UID-scoped state directory and one random UID-owned root under `/tmp` |
| Runtime ownership | exact lesson, Compose project, service, and random owner-token labels |
| Cleanup | token guarded, exact container/network IDs, exact local allowlist, restartable cleanup-state rename |
| Atomic deletion claim | none; exact IDs make cooperative replacement races safe, but Docker has no compare-and-delete primitive |
| Prepared dependencies | `.artifacts/` is a gitignored, verified prerequisite cache and is not runtime state |

Blast radius after preparation is five local containers, one internal Docker network, four loopback ports, and a small `/tmp` state tree. The image store and `.artifacts/` cache persist across runtime cleanup so preparation is not silently repeated. Runtime cleanup must prove all lifecycle containers, the lifecycle network, and the owned `/tmp` state are absent.

Abort if an ownership label, UID, mode, inode identity, lifecycle token, project resource set, wheel hash, image digest, host binding, or expected trace relationship differs. Do not “fix” an ownership failure with a wildcard delete or `docker system prune`.

## Public action and risk contract

Read the risk before running an action. The controller and verifier maintain the same complete action map.

| Action | Risk | Persistent effect |
|---|---|---|
| `doctor`, `model`, `status`, `check` | `[READ-ONLY]` | None |
| `verify-operation` | `[SAMPLED READ-ONLY]` | Uses a short-lived ownership lock while sampling existing lab evidence; it does not repair or complete evidence |
| `validate-configs` | `[MUTATING]` bounded | Creates one exact temporary validation container at a time and removes it by immutable ID |
| `setup`, `run ...`, `recover-context`, `interrupt-gateway`, `compare-sampling` | `[MUTATING]` bounded | Changes only the token-owned local lifecycle and its evidence records |
| `prepare --allow-network-downloads` | `[MUTATING]` `[NETWORK ACCESS]` | Pulls only locked public artifacts and creates the verified local dependency cache |
| `cleanup --expect-token TOKEN` | `[DESTRUCTIVE]` disposable | Removes only the exact token-owned lifecycle after revalidating identity |

`verify-operation` currently exits 78 after reporting the missing per-hop counter contract. That refusal is deliberate: existing control records and trace-log receipts are useful evidence, but they do not measure source, SDK, agent, gateway, sink, refusal, retry, and drop deltas with units, reset boundaries, and freshness.

## Current safe walkthrough

Run from this directory in Ubuntu 24.04 as a normal user.

### 1. Inspect readiness

`[READ-ONLY]`

```bash
bash lab.sh doctor
```

In the checked-in state, expect `artifact_lock=incomplete` and `prepared_artifacts=absent`. Docker readiness is reported independently. An available daemon does not make an incomplete supply-chain lock safe.

### 2. Run the teaching model

`[READ-ONLY]`

```bash
bash lab.sh model
```

Read it as a prediction sheet:

- baseline propagation joins service A and service B under one trace;
- dropping the carrier creates two unrelated traces even when both services succeed;
- restoring injection and extraction repairs the trace relationship;
- a bounded modeled gateway interruption queues four items and later drains four;
- full versus quarter sampling changes recorded evidence, not request success.

The model performs no filesystem mutation and has zero network targets. It does not import the SDK or start a Collector.

### 3. Run static regression checks

`[READ-ONLY]`

```bash
bash verify.sh
```

This validates Python syntax, shell safety, repository contracts, Compose safety text, Collector topology text, fail-closed lock behavior, deterministic model output, and final absence. With placeholder locks it intentionally does not validate Collector configuration using the Collector binary and does not run the two services.

## Maintainer-only artifact preparation

Do not invent a digest merely to make the lab start. A maintainer must first resolve the complete Python 3.12 linux/amd64 wheel set, review its provenance and compatibility, and replace every wheel hash marker in `requirements.lock`. The maintainer must also review the exact official image manifests and replace both digest markers in `artifacts.lock.json`. Tags are explanatory; runtime identity is `repository@sha256`.

Only after that reviewed change is committed may this explicit operation be considered:

`[MUTATING]` `[NETWORK ACCESS]`

```bash
bash lab.sh prepare --allow-network-downloads
```

Prepare pulls only the two exact official digest references. It then uses the pinned Python image in a constrained temporary container to download the fully hashed wheel set. The controller verifies the downloaded bytes, writes an exact receipt, and atomically publishes `.artifacts/`. With placeholders, it exits 78 before Docker pull or pip download.

## Conditional runtime walkthrough

The following section documents the designed interface. It is **conditional**, because the repository currently has no reviewed artifact lock or prepared runtime.

### Validate the Collector configurations

`[READ-ONLY with respect to persistent lab state]` `[MUTATING temporary container]`

```bash
bash lab.sh validate-configs
```

Each config is validated in an exact, temporary Collector container with `--network none`, a read-only filesystem, no capabilities, no-new-privileges, and an exact container ID cleanup. A YAML parser or successful Compose interpolation is weaker evidence; this command asks the pinned Collector binary whether its own config is valid.

### Create the offline runtime

`[MUTATING]`

```bash
bash lab.sh setup
```

Setup rechecks every artifact and local image digest, validates all three Collector configs, validates Compose, and starts with `--pull never --no-build`. Preserve `lifecycle_token=...`; cleanup requires it. Success also reports `network_internal=true`, `runtime_pull_policy=never`, and `runtime_package_index=disabled`.

If setup stops part-way, run `[READ-ONLY] bash lab.sh status`, copy its lifecycle token, and use the token-guarded cleanup below. Do not run a broad Compose or Docker cleanup.

### Prove propagation, break it, and recover it

`[MUTATING local evidence records]`

```bash
bash lab.sh run baseline
bash lab.sh run broken-context
bash lab.sh recover-context
```

Baseline requires equal upstream and downstream trace IDs and then finds both IDs in gateway debug output. Broken context deliberately omits W3C injection; two successful HTTP operations then have different trace IDs. Recovery restores propagation and requires equality again. The lesson is simple: healthy HTTP is not proof of a connected trace.

### Interrupt the gateway within a bound

`[MUTATING]`

```bash
bash lab.sh interrupt-gateway
```

The controller stops the exact gateway container ID with a three-second stop bound, sends four requests through the still-running services and agents, restores the same gateway in `finally`, and waits for the trace IDs in gateway debug output. This supports a bounded inference that the configured agent queue/retry path bridged this interruption. It does not prove zero loss under arbitrary outage duration, agent failure, process crash, queue saturation, or backend failure.

### Compare sampling without confusing it with request loss

`[MUTATING]`

```bash
bash lab.sh compare-sampling
```

The controller recreates only the two services first at ratio `1.0`, then `0.25`, and restores `1.0` in `finally`. A lab-only deterministic ID generator makes the comparison reproducible. All HTTP requests must succeed and preserve context; fewer spans are recorded at the lower ratio. Deterministic IDs are a teaching control, not a recommended production ID generator.

### Audit the intentionally incomplete runtime evidence contract

`[READ-ONLY]`

```bash
bash lab.sh verify-operation
```

The command validates the exact active resources and whatever recognized control records are present, requires a valid baseline record, prints every missing per-hop measurement, and then deliberately exits 78 with `runtime-evidence-incomplete-per-hop-counter-contract-not-implemented`. It cannot succeed in the checked-in draft. Its output also states `backend_ingest_proven=false`, `production_behavior_proven=false`, and `runtime_evidence_complete=false`.

### Clean up exactly

`[DESTRUCTIVE]` — destructive only to the exact lab lifecycle named by the token.

```bash
bash lab.sh cleanup --expect-token TOKEN_FROM_SETUP_OR_STATUS
bash lab.sh status
```

Cleanup renames the fixed state directory to a token-specific recovery name before touching Docker. It validates every resource label, targets immutable Docker IDs rather than names, refuses unknown resources, removes only allowlisted UID-owned files with preserved identities, and proves final runtime absence. If Docker is unavailable, cleanup preserves the recovery state so the same command can resume later. It does not claim deletion is atomic.

## What this lab never proves

Even after a successful future runtime run, it will not prove production capacity, tail sampling, multi-tenant isolation, TLS or workload identity, durable queues, backend ingest/query/retention, vendor behavior, correct cardinality, privacy compliance, causality, learner mastery, or safe incident leadership. Those require separate versioned tests and reviewed evidence.

Memory sentence: **A connected trace is a propagation result, and a visible trace is a pipeline result; neither one is automatically a truthful picture of every request.**
