# LES-0027 bounded OpenTelemetry pipeline lab

## Read this boundary first

This is a **quarantined publication candidate**, not a canonical learner lab. Its local runtime and evidence contract have been exercised on Ubuntu 24.04, but the lesson is not a canonical website route until the package-level promotion gates pass.

The lab uses exact digest-addressed images, fourteen hash-pinned Python wheels, five non-root containers, and one Docker `internal` network. Normal setup and every exercise are offline. Only the explicitly named preparation command may download artifacts, and it is unnecessary while the verified UID-scoped artifact cache remains present.

The terminal observation boundary is the gateway Collector's detailed debug exporter. That proves the pinned local gateway decoded and exported the selected spans to its stdout. It does **not** prove vendor-backend ingest, indexing, querying, retention, production capacity, or learner mastery.

## Architecture and trust boundaries

```text
Ubuntu lab controller
  |
  | exact validated container ID + docker exec
  v
[service-a / Python SDK] -- HTTP + W3C traceparent --> [service-b / Python SDK]
          | OTLP/HTTP :4318                              | OTLP/HTTP :4318
          v                                              v
       [agent-a]                                      [agent-b]
          | finite queue + bounded retry                  |
          +--------------- OTLP/gRPC :4317 ---------------+
                                  |
                                  v
                              [gateway]
                                  |
                                  +--> detailed debug exporter --> stdout

All five containers: one Docker internal network, no published host ports.
No Internet route, cloud service, backend, Docker socket, or host network exists.
```

The controller does not trust a container name alone. It revalidates the lifecycle token, Compose project, lesson, service, immutable image digest, user, read-only root filesystem, capabilities, security options, memory, CPU, PID limit, tmpfs, restart policy, mounts, exact network membership, and internal-network labels.

## Safety and scope

| Item | Enforced contract |
|---|---|
| Host | Ubuntu 24.04; normal user only; root exits 77 |
| Runtime network use | none outside the internal Docker network |
| Explicit Internet use | only `prepare --allow-network-downloads` |
| Runtime pulls | prohibited by `pull_policy: never` and `--pull never` |
| Python package index | prohibited by `--no-index --no-deps --require-hashes` |
| Published host ports | none |
| Containers | non-root, read-only, `cap_drop: ALL`, no-new-privileges |
| Per-container ceiling | 192 MiB, 0.50 CPU, 96 PIDs |
| Service tmpfs | 96 MiB; UID/GID owned; `nosuid,nodev` |
| Collector tmpfs | 16 MiB; UID 10001; `nosuid,nodev,noexec` |
| Docker access in containers | none; Docker socket is never mounted |
| Runtime state | one UID-scoped state directory plus one random UID-owned `/tmp` root |
| Cleanup | exact token, labels, immutable IDs, path identities, and allowlists |
| Atomic deletion claim | none; cleanup is restartable and race-resistant, not atomic |

Blast radius is five disposable containers, one internal network, and one small `/tmp` state tree. The image store and verified UID-scoped artifact cache survive runtime cleanup so the lab does not silently download again.

Never use `docker system prune`, wildcard deletion, or a broad `docker compose down` to recover this lab. Run `status`, copy its exact lifecycle token, and use the guarded cleanup command.

## Public actions and risk

| Action | Risk | Effect |
|---|---|---|
| `doctor`, `model`, `status`, `check` | `[READ-ONLY]` | Inspect readiness, model output, state, and evidence |
| `verify-operation` | `[SAMPLED READ-ONLY]` | Uses a short-lived owned lock and audits five existing records |
| `validate-configs` | `[MUTATING]` bounded | Creates and exactly removes three one-at-a-time validation containers |
| `setup`, `run ...`, `recover-context`, `interrupt-gateway`, `compare-sampling` | `[MUTATING]` bounded | Mutate only the token-owned local lifecycle |
| `prepare --allow-network-downloads` | `[MUTATING]` `[NETWORK ACCESS]` | Populate the verified UID-scoped artifact cache from locked public artifacts |
| `cleanup --expect-token TOKEN` | `[DESTRUCTIVE]` disposable | Remove only the exact validated lifecycle |

## Quick readiness checks

Run these commands from this directory in Ubuntu 24.04.

### Inspect the environment

`[READ-ONLY]`

```bash
bash lab.sh doctor
```

Ready output includes:

```text
ubuntu_24_04_ready=true
docker_daemon_ready=true
published_host_ports=0
artifact_lock=complete
requirements_lock_count=14
prepared_artifacts=verified
compose_render_binding=exact-reviewed-lock
runtime_ready=true
```

If `prepared_artifacts=absent`, do not run setup. Review `artifacts.lock.json` and `requirements.lock`, then use the explicit preparation command only if network access is acceptable:

```bash
bash lab.sh prepare --allow-network-downloads
```

Preparation pulls only the two digest-addressed images and downloads only the fourteen named, hash-checked wheels. It stages the cache and publishes it only after every byte and manifest check passes.

### Run the zero-runtime teaching model

`[READ-ONLY]`

```bash
bash lab.sh model
```

This predicts propagation, context loss, recovery, queueing, and sampling without importing OpenTelemetry, starting a container, changing a file, or contacting a network. Its output explicitly says `opentelemetry_executed=false` and `model_is_not-runtime-evidence=true`.

### Run non-mutating readiness verification

`[READ-ONLY]`

```bash
bash verify.sh static
```

This mode runs Python parsing, fourteen safety/static/atomicity tests, Bash parsing, ShellCheck, the action-risk contract, complete-lock checks, the deterministic model, Compose rendering, artifact verification, and doctor. It accepts either an absent or already-active valid lifecycle and performs zero runtime mutation.

## Guided runtime lifecycle

### 1. Validate Collector configurations

`[MUTATING]` bounded temporary containers

```bash
bash lab.sh validate-configs
```

For each Collector config, the controller creates one digest-pinned container with no network, a read-only root filesystem, no capabilities, no-new-privileges, a non-root user, bounded resources, and a read-only config mount. Success requires a successful start/attach, observed `exited` state, valid start/finish timestamps, exit code zero, exact removal, and a specific Docker not-found result afterward.

### 2. Create the offline runtime

`[MUTATING]`

```bash
bash lab.sh setup
```

Setup rechecks the image and wheel bytes, validates all three Collector configurations, renders and validates Compose, atomically publishes a complete state document, and starts with `--pull never --no-build`. Preserve `lifecycle_token=...`; cleanup requires it.

If setup reports an incomplete token, run `bash lab.sh status`, copy that token, and use the exact cleanup command. A failure before state publication removes both the staging directory and temporary root; the injected failure test covers this path.

### 3. Prove propagation, break it, and recover it

`[MUTATING]`

```bash
bash lab.sh run baseline
bash lab.sh run broken-context
bash lab.sh recover-context
```

Each operation creates three spans: service A's request span, its bounded async-worker span, and service B's downstream span. The record proves:

- service A's span is the worker parent when propagation is enabled;
- the worker span is always service B's direct parent;
- dropping the in-process carrier separates the request and worker traces without breaking HTTP;
- restoring the carrier rejoins them;
- SDK ended/export-success counters, agent receive/process/export counters, gateway receive/process/export counters, and debug-sink visibility reconcile exactly `3 = 3 = 3 = 3`;
- refused, failed, and reset boundaries are explicit rather than assumed.

### 4. Measure queueing, retry, and drain

`[MUTATING]`

```bash
bash lab.sh interrupt-gateway
```

The controller snapshots the pipeline, stops the exact gateway container, sends four operations, forces both SDK exporters to flush, samples both agent queues, and captures bounded retry-sender records. The exact agent configuration uses one-span batches and one consumer, so queue occupancy is measured in queue items with one span per item.

The gateway is restored in `finally`. Its process-start identity must change while both services and both agents must keep the same process identities. The new gateway's absolute counters must show all twelve queued spans, both agent queues must drain to zero, retry evidence must be present, and refusal/drop deltas must remain zero. The reported oldest queue residence is a controller-observed lower bound from the first completed outage request to proven drain; it is not an internal Collector oldest-item gauge.

### 5. Compare deterministic head sampling

`[MUTATING]`

```bash
bash lab.sh compare-sampling
```

The controller recreates only the two services at ratios `1.0` and `0.25`, sends 32 requests at each ratio, and restores `1.0` in `finally`. All requests must succeed. The lab-only deterministic ID generator must produce the same trace-ID sequence after recreation, full sampling must retain 32, and quarter sampling must retain a nonzero strict subset. This isolates the sampling decision from request success; deterministic IDs are not a production recommendation.

### 6. Audit all evidence

`[SAMPLED READ-ONLY]`

```bash
bash lab.sh verify-operation --expect-token TOKEN_FROM_SETUP_OR_STATUS
```

Success requires exactly five records: baseline, broken context, recovery, gateway interruption, and sampling. Every record is digest protected and rebound to its action, time window, lifecycle, state/root identities, artifact locks, resolved Compose, three Collector configs, three service sources, exact stable runtime resources, internal network, and workload identifiers.

Expected final markers include:

```text
source_creation_delta=3
sdk_export_delta=3
agent_receive_delta=3
gateway_export_delta=3
refused_span_delta=0
dropped_span_delta=0
per_hop_reconciliation_passed=true
sampling_deterministic_trace_ids_equal=true
runtime_verification_passed=true
backend_ingest_proven=false
production_behavior_proven=false
```

### 7. Clean up exactly

`[DESTRUCTIVE]` only for this disposable lifecycle

```bash
bash lab.sh cleanup --expect-token TOKEN_FROM_SETUP_OR_STATUS
bash lab.sh status
```

Final status must report `state=absent`, `state_recovery_count=0`, and `project_resource_count=0`. Cleanup acquires the same OS-held nonblocking file lock used by exercises before renaming state, refuses a genuinely concurrent operation, and can reclaim a matching sentinel after an abruptly terminated owner because the kernel releases the lock when that process exits. It then validates every target again, removes immutable container/network IDs, and deletes only allowlisted UID-owned files whose identities still match. A sentinel containing a different lifecycle token is preserved and rejected.

## One-command full offline verification

Start only when `bash lab.sh status` reports absence:

```bash
bash verify.sh runtime
```

This mode performs the static gates, setup, a live cleanup-lock refusal test, all five exercises, the complete evidence audit, token-guarded cleanup, and final zero-resource proof. The kernel lock remains held across state rename, exact Docker removal, local-artifact removal, and final state deletion, so another cleanup cannot enter the transaction midway. A trap attempts the same exact cleanup if an intermediate command fails. It performs no download and no cloud call.

## What this lab does not prove

This lab does not prove backend ingest/query/retention, durable disk queues, arbitrary outage survival, queue saturation behavior, multi-tenant isolation, TLS or workload identity, tail sampling, vendor behavior, production cardinality, privacy compliance, representative capacity, or learner competency. Those need separate systems and evidence.

Memory sentence: **A connected trace is a propagation result, and a visible trace is a pipeline result; neither is automatically a truthful picture of every request.**
