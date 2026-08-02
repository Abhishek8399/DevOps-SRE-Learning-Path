---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0020",
  "aliases": ["V03-L05", "go-infrastructure-tooling"],
  "curriculumIds": ["AUT-004"],
  "slug": "go-infrastructure-tooling",
  "route": "/book/engineering/go-infrastructure-tooling",
  "order": 5,
  "volume": "03-engineering-delivery",
  "title": "Go infrastructure tooling: bounded concurrency, explicit contracts, and trustworthy outcomes",
  "summary": "Learn Go by building the kind of infrastructure tool an operator can trust: one compiled artifact, strict inputs, small interfaces, wrapped errors, propagated cancellation, bounded goroutines, safe HTTP and JSON boundaries, guarded filesystem publication, stable exit codes, structured evidence, and tests that attack failure paths instead of only celebrating the happy path.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 540,
  "prerequisiteLessonIds": ["LES-0009", "LES-0018"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-002"],
  "testedEnvironments": [
    {
      "platform": "Windows",
      "version": "Windows 11 with Go 1.22.0 windows/amd64 and Windows PowerShell 5.1",
      "support": "required",
      "notes": "The standard-library lab, unit tests, vet checks, build, guarded lifecycle verifier, tamper refusals, idempotent recovery, answer-isolation check, and cleanup proof are executed here. The lab sets dependency networking off and uses a randomized lab directory, an isolated descriptor directory, and a verifier-owned reusable Go build-cache directory beneath the current user's temporary directory; the verifier proves all three are removed."
    },
    {
      "platform": "Ubuntu and WSL 2 Ubuntu",
      "version": "Ubuntu 24.04 LTS",
      "support": "concept-only",
      "notes": "The lesson gives Ubuntu commands and explains Linux process, signal, permission, and filesystem differences, but Go is absent from the available WSL Ubuntu environment at this review. No package install was performed. Do not call the Go lab Ubuntu-tested until the pinned toolchain is installed through an approved process and the same gates pass there."
    },
    {
      "platform": "CI runners, containers, Kubernetes, private cloud, and public cloud",
      "version": "provider-neutral transfer",
      "support": "concept-only",
      "notes": "Production sections cover build provenance, immutable images, service identity, controller retries, HTTP transports, distributed coordination, telemetry, and rollout. This lesson creates no remote resource, account, cluster, image, deployment, or paid service."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "release-engineer", "security-engineer"],
  "learningObjectives": [
    "Trace Go source through modules, packages, type checking, compilation, linking, process startup, configuration, effects, verification, and exit-status translation.",
    "Model infrastructure inputs with named types and strict validation so malformed JSON, ambiguous zero values, unknown fields, unsafe paths, and invalid ranges stop before mutation.",
    "Place small consumer-owned interfaces at effect boundaries, preserve error identity with wrapping, and distinguish invalid input, definite no-effect, transient failure, unknown outcome, cancellation, and programmer defect.",
    "Propagate context deadlines and cancellation across goroutines and HTTP requests without treating a timeout as proof that a remote effect did not commit.",
    "Build bounded worker lifecycles with explicit ownership, synchronization, channel-closing rules, backpressure, and leak-free shutdown; detect executed data races without claiming the detector proves absence.",
    "Configure HTTP clients and transports with explicit timeouts, body-size limits, status contracts, connection reuse, TLS verification, redaction, and retry eligibility.",
    "Publish JSON and local receipts through guarded paths, same-directory candidates, validation, synchronization reasoning, atomic visibility, idempotent readback, and exact cleanup.",
    "Use tests, fuzzing, race detection, vet, benchmarks, profiles, build metadata, module verification, cross-compilation, and vulnerability review as different evidence layers rather than one green badge."
  ],
  "productionSignals": [
    "A fast Go binary returns exit zero while a requested infrastructure change is missing, duplicated, or only partially published.",
    "Goroutine count, heap use, open connections, or queue age rises after traffic falls, suggesting leaked workers, bodies, timers, or blocked channel operations.",
    "A client timeout triggers a retry and two remote objects appear because the first request may have committed before its response was lost.",
    "The race detector reports conflicting access, or an intermittent map panic appears only under load.",
    "A JSON configuration silently accepts a misspelled field or turns an omitted value into a dangerous zero-value default.",
    "The tool works on a developer laptop but a CI cross-build fails, embeds a local path, depends on cgo, or cannot verify module inputs offline.",
    "An HTTP client hangs during DNS, connect, TLS, headers, or body reading because only one phase or no phase had a deadline.",
    "A shutdown signal stops the main goroutine while workers still own mutations, receipts, buffered output, or unflushed telemetry."
  ],
  "diagrams": [
    {
      "id": "LES-0020-DIA-001",
      "title": "A Go tool is a chain of contracts, not merely a binary",
      "direction": "left-to-right",
      "boundaries": ["source and go.mod", "compiler and linker", "artifact identity", "process and configuration", "validated request", "bounded orchestration", "effect adapter", "authoritative state", "verified result and exit"],
      "evidencePoints": ["revision and module graph", "toolchain and target", "digest and build metadata", "argv environment identity", "typed invariants", "deadline worker budget", "HTTP filesystem process result", "owner readback", "receipt telemetry status"],
      "textAlternative": "Source and module declarations enter a selected Go toolchain, which creates an identified artifact. A launched process parses configuration into a validated request, bounded orchestration calls explicit effect adapters, the authoritative owner records state, and verification translates the real outcome into a receipt, telemetry, and exit status."
    },
    {
      "id": "LES-0020-DIA-002",
      "title": "Cancellation flows down while results and errors flow up",
      "direction": "top-to-bottom",
      "boundaries": ["operator or controller deadline", "root context", "orchestrator", "bounded workers", "HTTP or filesystem adapters", "cleanup and reconciliation"],
      "evidencePoints": ["deadline budget", "Done channel and cause", "admission and ownership", "completed versus canceled work", "request context and return error", "joined workers and authoritative lookup"],
      "textAlternative": "A controller creates one root deadline. The orchestrator derives contexts and admits bounded work. Workers pass context into blocking adapters. Cancellation requests travel downward, while typed results and wrapped errors travel upward. The owner still joins workers, cleans local resources, and reconciles any operation whose outcome is unknown."
    },
    {
      "id": "LES-0020-DIA-003",
      "title": "A worker pool must bound admission, work, and retirement",
      "direction": "cyclic",
      "boundaries": ["validated jobs", "bounded queue", "fixed workers", "effect call", "result channel", "collector", "cancel and join"],
      "evidencePoints": ["accepted job count", "queue depth and wait", "active worker count", "attempt ID and deadline", "terminal result per accepted job", "expected versus observed totals", "all goroutines retired"],
      "textAlternative": "Validated jobs enter a bounded queue, a fixed number of workers own each admitted job, effects produce one terminal result, and one collector reconciles accepted with completed work. On failure or cancellation the producer stops, channels close only from their owning sender side, workers exit, and the coordinator waits for every goroutine."
    },
    {
      "id": "LES-0020-DIA-004",
      "title": "An HTTP response is not yet a successful operation",
      "direction": "left-to-right",
      "boundaries": ["typed intent", "request context", "DNS connect TLS", "headers", "bounded body", "decoded schema", "authoritative readback", "durable receipt"],
      "evidencePoints": ["operation ID and idempotency key", "remaining deadline", "phase timings", "status and headers", "byte limit and close", "strict fields and invariants", "resource version and state", "local committed transition"],
      "textAlternative": "A typed intent becomes a request carrying a deadline and stable operation identity. DNS, connection, TLS, headers, and bounded body reading each produce evidence. The client validates status, payload shape, and semantics, then reads authoritative state before recording a durable local receipt."
    },
    {
      "id": "LES-0020-DIA-005",
      "title": "Safe local publication separates visibility from crash durability",
      "direction": "left-to-right",
      "boundaries": ["approved real parent", "private candidate", "complete encode", "file synchronization", "candidate validation", "same-filesystem rename", "directory synchronization", "consumer readback"],
      "evidencePoints": ["owner kind identity", "exclusive candidate", "byte count and encoder error", "Sync and Close results", "strict decode and invariants", "atomic namespace change", "platform support", "old or new complete document"],
      "textAlternative": "The writer proves an approved parent, creates a private candidate in that same directory, fully encodes and synchronizes it, validates it, renames it into place, optionally synchronizes the directory where supported, and performs consumer readback. Rename visibility, disk durability, and semantic correctness are separate claims."
    }
  ],
  "commands": [
    {
      "id": "LES-0020-CMD-001",
      "question": "Which Go toolchain and target are answering this shell?",
      "risk": "read-only",
      "command": "command -V go; go version; go env GOVERSION GOOS GOARCH CGO_ENABLED GOMOD GOWORK GOPROXY GOSUMDB",
      "runFrom": "The exact Ubuntu shell or CI step that will build or run the tool; if go is absent, stop rather than installing during diagnosis",
      "expectedBranches": [
        {"when": "The intended executable, version, target, module path, workspace state, and dependency policy appear", "meaning": "The displayed process has the expected build baseline.", "nextEvidence": "Record source revision and module graph before building."},
        {"when": "go is missing, a workspace is unexpectedly active, GOMOD is wrong, or target values differ", "meaning": "The build boundary is not the one assumed.", "nextEvidence": "Select the approved toolchain and working directory; do not compare artifacts yet."}
      ],
      "proves": "The selected Go executable and displayed environment values for this invocation.",
      "doesNotProve": "Toolchain integrity, source identity, dependency availability, reproducibility, runtime compatibility, or production safety."
    },
    {
      "id": "LES-0020-CMD-002",
      "question": "What main module does the local source declare without contacting a proxy?",
      "risk": "read-only",
      "command": "GOPROXY=off GOSUMDB=off go list -m -json",
      "runFrom": "The root of the reviewed LES-0020 lab module or another approved local module",
      "expectedBranches": [
        {"when": "One JSON object shows the expected Path, GoVersion, Dir, and Main=true", "meaning": "The command located the intended main module locally.", "nextEvidence": "Enumerate packages and dependencies with networking still disabled."},
        {"when": "It reports no go.mod, an unexpected directory, or a missing cached dependency", "meaning": "Module selection or offline availability differs from the assumption.", "nextEvidence": "Inspect pwd -P, go.mod, go.work, and the approved dependency preparation process."}
      ],
      "proves": "The local module selected by this go command.",
      "doesNotProve": "That every dependency is reviewed, cached, untampered, compiled, tested, or vulnerability-free."
    },
    {
      "id": "LES-0020-CMD-003",
      "question": "Which packages and standard-library dependencies are in the build graph?",
      "risk": "read-only",
      "command": "GOPROXY=off GOSUMDB=off go list -deps -f '{{if not .Standard}}{{.ImportPath}} module={{with .Module}}{{.Path}}@{{.Version}}{{end}}{{end}}' ./...",
      "runFrom": "The reviewed module root with dependency networking disabled",
      "expectedBranches": [
        {"when": "Only the main module appears as non-standard", "meaning": "This lesson lab depends only on its own packages and the selected standard library.", "nextEvidence": "Run format, test, and vet gates."},
        {"when": "Unexpected external module paths or versions appear", "meaning": "The dependency graph is broader than expected.", "nextEvidence": "Stop, inspect go.mod, go.sum, replacements, workspace files, and provenance."}
      ],
      "proves": "Packages resolved for the selected patterns under the current module and cache state.",
      "doesNotProve": "Reachability of every function, source trust, absence of toolchain code, build-tag variants, or behavior on another target."
    },
    {
      "id": "LES-0020-CMD-004",
      "question": "Would the canonical formatter change any Go source?",
      "risk": "read-only",
      "command": "test -z \"$(gofmt -l .)\" && printf 'gofmt=clean\\n' || { printf 'gofmt=changes-required\\n' >&2; exit 1; }",
      "runFrom": "The reviewed module root",
      "expectedBranches": [
        {"when": "gofmt=clean prints", "meaning": "No scanned Go file differs from gofmt output.", "nextEvidence": "Run semantic tests and vet."},
        {"when": "gofmt=changes-required prints", "meaning": "At least one file is not canonically formatted.", "nextEvidence": "Review gofmt -d output before applying a formatting change."}
      ],
      "proves": "Canonical formatting agreement for Go files found below the current directory.",
      "doesNotProve": "Compilation, correctness, readability, race freedom, API stability, or safe effects."
    },
    {
      "id": "LES-0020-CMD-005",
      "question": "Do deterministic package tests pass without using the network?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go test -count=1 ./...",
      "runFrom": "The LES-0020 module after lab.ps1 setup has printed an absolute private ATLAS_RUN_ROOT containing gocache and tmp directories",
      "expectedBranches": [
        {"when": "Every package reports ok", "meaning": "The selected tests passed once under this toolchain and environment.", "nextEvidence": "Run vet, race detection where supported, and executable lifecycle verification."},
        {"when": "A package fails or setup cannot use the isolated directories", "meaning": "The first reported test, build, or environment assumption failed.", "nextEvidence": "Preserve the first failure and fix it before broader gates."}
      ],
      "proves": "One execution of selected tests and compilation paths.",
      "doesNotProve": "Untested branches, absence of races, production dependencies, wall-clock behavior, or correctness of a mocked authority.",
      "cleanup": "Use the lab's exact cleanup command; it removes only the verified registered root and descriptor after refusing unexpected artifacts."
    },
    {
      "id": "LES-0020-CMD-006",
      "question": "Does static analysis report suspicious constructs in the selected packages?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go vet ./...",
      "runFrom": "The LES-0020 module with isolated cache and temporary directories",
      "expectedBranches": [
        {"when": "The command exits zero without diagnostics", "meaning": "Enabled vet analyzers found no reportable issue in this build configuration.", "nextEvidence": "Continue with dynamic tests and review."},
        {"when": "A file and diagnostic appear", "meaning": "An analyzer found a suspicious pattern or type-check failure.", "nextEvidence": "Understand the first finding; do not suppress it blindly."}
      ],
      "proves": "The result of enabled go vet analyzers for selected packages and target.",
      "doesNotProve": "General correctness, security, complete static analysis, runtime behavior, or analysis under every build tag.",
      "cleanup": "Use the registered lab cleanup to remove the isolated build cache and temporary files created by vet."
    },
    {
      "id": "LES-0020-CMD-007",
      "question": "Do executed concurrent paths contain a detectable data race?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go test -race -count=1 ./...",
      "runFrom": "A supported host with the race-enabled toolchain prerequisites and the isolated lab directories",
      "expectedBranches": [
        {"when": "Tests pass with no race report", "meaning": "No race was detected on paths and schedules exercised during this run.", "nextEvidence": "Review ownership and synchronization; repeat representative stress workloads."},
        {"when": "A race report names two accesses and goroutine stacks", "meaning": "At least one executed conflicting access lacked required synchronization.", "nextEvidence": "Preserve both stacks, identify the shared object owner, fix synchronization, and add a regression test."},
        {"when": "The toolchain reports race is unsupported or a C compiler is missing", "meaning": "The environment cannot run this detector.", "nextEvidence": "Record the limitation and use an approved supported runner; do not relabel the gate passed."}
      ],
      "proves": "Detected races on executed code only, when the detector is supported.",
      "doesNotProve": "Absence of races on unexecuted schedules, absence of deadlocks or leaks, or production equivalence.",
      "cleanup": "Use the registered lab cleanup to remove the isolated cache; retain a sanitized race report outside lab-owned state when needed."
    },
    {
      "id": "LES-0020-CMD-008",
      "question": "Does strict JSON decoding reject generated hostile inputs without panicking?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go test -run '^FuzzDecodeRequest$' -fuzz '^FuzzDecodeRequest$' -fuzztime=3s ./internal/model",
      "runFrom": "The isolated LES-0020 lab only; fuzzing is CPU-intensive and bounded here to three seconds",
      "expectedBranches": [
        {"when": "The fuzz target passes for the time budget", "meaning": "No failing input was found in the explored corpus and mutations.", "nextEvidence": "Keep seed cases and run longer fuzzing in a resource-governed CI job."},
        {"when": "A minimized failing input is written", "meaning": "The tool found a reproducible panic or violated invariant.", "nextEvidence": "Preserve the generated case, add it as a regression, and fix the boundary."}
      ],
      "proves": "Coverage-guided exploration performed during the bounded run.",
      "doesNotProve": "Exhaustive input safety, semantic authorization, resource safety at larger sizes, or absence of denial-of-service cases.",
      "cleanup": "The registered lab cleanup removes its isolated cache and temporary corpus; copy only a sanitized reproducer to reviewed testdata when intentionally retaining it."
    },
    {
      "id": "LES-0020-CMD-009",
      "question": "What structured events did a focused test emit?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go test -json -run '^TestRecoverIdempotent$' ./internal/model",
      "runFrom": "The isolated LES-0020 module root",
      "expectedBranches": [
        {"when": "JSON events end with a package pass action", "meaning": "The named regression passed and produced machine-readable test events.", "nextEvidence": "Archive the test result with revision and toolchain identity if policy requires."},
        {"when": "A fail action identifies test output", "meaning": "The idempotency contract failed or test setup could not run.", "nextEvidence": "Start at the first failure event and inspect retained temporary evidence."}
      ],
      "proves": "Structured test-run events for the exact named test.",
      "doesNotProve": "That production replay is safe, a remote API honors idempotency, or other tests passed.",
      "cleanup": "Use the registered lab cleanup to remove the isolated test cache and temporary files after preserving only an approved sanitized test report."
    },
    {
      "id": "LES-0020-CMD-010",
      "question": "Can the module produce a path-trimmed local executable?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go build -trimpath -buildvcs=false -o \"$ATLAS_RUN_ROOT/bin/opsmodel\" ./cmd/opsmodel",
      "runFrom": "The isolated LES-0020 module root after setup created the bin directory",
      "expectedBranches": [
        {"when": "The command exits zero and the file exists", "meaning": "This toolchain linked the selected main package for its current target.", "nextEvidence": "Inspect build metadata and execute known read-only behavior."},
        {"when": "Compilation or linking fails", "meaning": "Source, target, tags, cgo, or environment assumptions are incompatible.", "nextEvidence": "Preserve the first compiler or linker diagnostic and the go env baseline."}
      ],
      "proves": "A current-target executable was produced from selected source.",
      "doesNotProve": "Reproducible bytes, artifact signing, runtime compatibility, vulnerability freedom, or safe production behavior.",
      "cleanup": "The registered cleanup deletes only the verified bin/opsmodel beneath the lab root."
    },
    {
      "id": "LES-0020-CMD-011",
      "question": "Which module and build settings are embedded in the executable?",
      "risk": "read-only",
      "command": "go version -m \"$ATLAS_RUN_ROOT/bin/opsmodel\"",
      "runFrom": "The shell holding the exact artifact path produced by the prior bounded build",
      "expectedBranches": [
        {"when": "The main module, Go version, target settings, and trimpath appear", "meaning": "The artifact exposes embedded Go build information.", "nextEvidence": "Compare it with approved provenance and calculate an artifact digest."},
        {"when": "The file is absent, not a recognized Go executable, or metadata differs", "meaning": "Artifact identity is not what the operator assumed.", "nextEvidence": "Stop promotion and trace the artifact source."}
      ],
      "proves": "Build information readable from this file.",
      "doesNotProve": "Who built it, source cleanliness, signature validity, reproducible correspondence, or authorization to deploy it."
    },
    {
      "id": "LES-0020-CMD-012",
      "question": "Can pure-Go source compile for Linux amd64 without executing the result?",
      "risk": "mutating-bounded",
      "command": "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go build -trimpath -buildvcs=false -o \"$ATLAS_RUN_ROOT/bin/opsmodel-linux-amd64\" ./cmd/opsmodel",
      "runFrom": "The isolated module root on a host whose selected toolchain supports the target",
      "expectedBranches": [
        {"when": "The target artifact is produced", "meaning": "The selected pure-Go build graph compiled and linked for linux/amd64.", "nextEvidence": "Test it inside the approved Linux runtime; do not execute a Linux binary on Windows and call that validation."},
        {"when": "A cgo, build-tag, syscall, or package error appears", "meaning": "The graph is not portable under these target choices.", "nextEvidence": "Identify the target-specific dependency or source file and decide whether portability is required."}
      ],
      "proves": "Cross-compilation success for one target.",
      "doesNotProve": "That the binary starts, has correct certificates and timezone data, observes Linux signals correctly, or behaves safely in a container.",
      "cleanup": "The registered cleanup removes the exact target artifact under its verified bin directory."
    },
    {
      "id": "LES-0020-CMD-013",
      "question": "What does a bounded synthetic CPU profile attribute?",
      "risk": "mutating-bounded",
      "command": "GOPROXY=off GOSUMDB=off GOCACHE=\"$ATLAS_RUN_ROOT/gocache\" GOTMPDIR=\"$ATLAS_RUN_ROOT/tmp\" go test -run '^$' -bench '^BenchmarkDecodeRequest$' -benchtime=1s -cpuprofile \"$ATLAS_RUN_ROOT/cpu.pprof\" -o \"$ATLAS_RUN_ROOT/bin/model.test\" ./internal/model && go tool pprof -top \"$ATLAS_RUN_ROOT/bin/model.test\" \"$ATLAS_RUN_ROOT/cpu.pprof\"",
      "runFrom": "The isolated lab using synthetic non-secret data; profiles can contain symbol and environment details",
      "expectedBranches": [
        {"when": "A top table names sampled functions", "meaning": "The profile attributes samples from this synthetic benchmark run.", "nextEvidence": "Compare multiple controlled runs before optimizing."},
        {"when": "The benchmark, profile creation, or parser fails", "meaning": "The selected workload or profile artifact was not produced as assumed.", "nextEvidence": "Inspect the first error and preserve environment identity."}
      ],
      "proves": "Sample attribution for one bounded synthetic execution.",
      "doesNotProve": "Production bottlenecks, representative traffic, causal latency, safe profile disclosure, or an optimization priority.",
      "cleanup": "The lab cleanup removes the exact cpu.pprof and retained model.test test binary inside the registered root; never expose a production profile without security review."
    }
  ],
  "labs": [
    {
      "id": "LES-0020-LAB-001",
      "title": "Guided evidence lab: strict input, cancellation, idempotent receipt, and exact cleanup",
      "mode": "guided",
      "environment": "Windows 11 normal-user PowerShell with local Go 1.22; the Go module itself is portable but Ubuntu execution remains unverified in this environment",
      "timeMinutes": 100,
      "privilege": "Normal user only; the controller refuses an elevated Windows token and includes a verifier-only forced refusal branch",
      "network": "None; GOPROXY is off, GOSUMDB is off, and the module imports only the standard library",
      "changes": ["One randomized lab directory below the current user's temporary directory", "One isolated descriptor directory supplied to the controller", "One verifier-owned reusable Go build-cache directory below the current user's temporary directory", "Go build and test cache files only beneath the registered lab or verifier build-cache roots", "Deterministic JSON observations, one receipt, one verification marker, profiles, and local binaries beneath the registered lab root"],
      "abortConditions": ["Go is missing or not the tested 1.22 family", "The shell is elevated", "The descriptor or registered root is a reparse point", "The descriptor names another lesson, an unexpected root prefix, or a root outside the current user's temporary directory", "Source digest, manifest, expected file type, or allowlist differs", "Any command would need network, package installation, cloud access, or administrator rights"],
      "recovery": "Do not delete a path after a boundary refusal. Restore only a deliberately changed verifier fixture when its original bytes and exact target were recorded. For an interrupted valid session, rerun status, inspect allowlisted evidence, then use the idempotent recover or exact cleanup action.",
      "cleanupProof": "The verifier demonstrates cleanup refusal on unexpected artifacts and a tampered out-of-scope descriptor, proves an external sentinel survives, removes individually allowlisted model files plus only reparse-checked cache and temporary trees beneath registered roots, confirms the lab root, descriptor directory, and verifier build-cache root are absent, and leaves no generated file in the repository.",
      "path": "book/labs/LES-0020-go-tooling"
    },
    {
      "id": "LES-0020-LAB-002",
      "title": "Independent timeout-after-mutation diagnosis and design review",
      "mode": "independent",
      "environment": "The same clean normal-user Windows lab session; store the response template outside lab-owned state",
      "timeMinutes": 120,
      "privilege": "Normal user only; no elevation",
      "network": "None; the service is a deterministic local model and no socket is opened",
      "changes": ["Only the same registered randomized lab root and descriptor", "A deterministic independent scenario selection, observations requested by the learner, one idempotent receipt, and verification evidence"],
      "abortConditions": ["The learner viewed the model source, hidden assessment answer, guided diagnosis, or a prior completed response", "Raw scenario output contains a derived outcome, diagnosis, recovery, or answer key", "The registered state boundary fails", "An unplanned file or network requirement appears"],
      "recovery": "Stop replay. Preserve the raw scenario and predictions outside lab-owned state. Reconcile by stable operation identity in the modeled authoritative view, choose an evidence-backed transition, then run the bounded recover command once and repeat it only to demonstrate idempotent readback.",
      "cleanupProof": "The same verifier checks raw independent output for forbidden derived fields, repeats recovery and verification without duplicate receipt creation, exercises tamper refusals, and proves final state absence. Passing validates the harness contract, not the learner's diagnosis or mastery.",
      "path": "book/labs/LES-0020-go-tooling"
    }
  ],
  "incidents": [
    {
      "id": "LES-0020-INC-001",
      "signal": "Goroutines and open connections climb after a batch deadline, while the process remains alive and new work slows.",
      "firstThought": "Treat this as an ownership and retirement problem. Ask which goroutine can block, who closes each channel or response body, whether the root context reaches every call, and whether the coordinator joins all admitted work.",
      "safePath": "Freeze expansion, capture bounded goroutine, connection, queue, and deadline evidence, compare accepted with terminal jobs, identify a minimal leak reproduction, fix ownership, and verify return to baseline after repeated cancellation.",
      "trap": "Increasing worker count, forcing garbage collection, closing a channel from the receiver, or assuming context cancellation kills goroutines can turn a leak into panic, lost work, or more pressure."
    },
    {
      "id": "LES-0020-INC-002",
      "signal": "A POST request reaches its deadline, the controller retries, and the platform later shows two resources.",
      "firstThought": "A timeout is a client observation, not a remote rollback receipt. Preserve the stable operation identity and query the authoritative owner before deciding whether another mutation is eligible.",
      "safePath": "Stop automatic replay, record request and operation IDs plus phase timing, reconcile remote state, adopt an existing committed result or prove no effect, compensate only through a reviewed operation, and test response-loss behavior.",
      "trap": "Wrapping the call in a retry loop or creating a new idempotency key per attempt defeats deduplication and can multiply effects."
    },
    {
      "id": "LES-0020-INC-003",
      "signal": "A JSON inventory file parses successfully but omits resources after concurrent collection.",
      "firstThought": "Parsing proves syntax, not completeness. Compare accepted work, terminal results, unique IDs, expected count, publication method, cancellation point, and consumer readback.",
      "safePath": "Retain the prior good artifact, stop publishers, reconstruct from authoritative inputs with bounded workers and one collector, validate semantics, publish a same-directory candidate, and verify the consumer view.",
      "trap": "Adding a mutex only around file writes can still preserve lost results, early channel closure, invalid zero values, or semantically incomplete JSON."
    }
  ],
  "assessmentIds": ["ASM-0043", "ASM-0044", "ASM-0045"],
  "referenceIds": ["REF-0113", "REF-0114", "REF-0115", "REF-0116", "REF-0117", "REF-0118", "REF-0119", "REF-0120"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The complete executable lab is validated on local Windows Go 1.22.0. Go is absent from the available WSL Ubuntu 24.04 environment, so Ubuntu commands and signal/filesystem transfer are not runtime-verified here.",
    "The lab models remote outcomes without opening a socket. It cannot prove DNS, TLS, proxy, load balancer, API, service-mesh, controller, or cloud behavior.",
    "Windows directory ownership and reparse-point checks do not establish a formal discretionary access-control audit; the verifier isolates state beneath a fresh user temporary root and refuses boundary drift.",
    "Race detector success covers only executed schedules, fuzzing explores only a bounded search, vet runs selected analyzers, and a passing test suite is not a security or correctness proof.",
    "Cross-compilation proves buildability only. The Linux artifact is not executed in this environment and no deployment is performed.",
    "Reading, completing, or locally marking this lesson never awards mastery. Independent learner evidence requires review."
  ]
}
---
# Go infrastructure tooling: bounded concurrency, explicit contracts, and trustworthy outcomes


## What you see and first thought

A Go infrastructure tool often looks reassuring before you know anything about it. It may be one binary. It may start quickly. The compiler may reject many mistakes before the program runs. Teams therefore make a dangerous mental jump:

> It compiled, so it is safe.

Compilation is valuable evidence, but it answers a narrow question: did this selected toolchain accept the selected source for the selected build configuration? It does not say that a timeout is retryable, a goroutine will retire, a JSON document is complete, a path is owned, an HTTP body is bounded, a secret is redacted, or a remote operation happened exactly once.

When a Go tool behaves badly in production, begin with this sentence:

> First identify the contract that failed, the component that owns the truth, and the evidence that would distinguish no effect from committed effect and unknown effect.

Do not begin by increasing goroutines. Do not wrap every error in a retry. Do not add a global mutex because a map panicked. Those actions change the system before you understand it.

Here are four signals and the useful first thought behind each one.

| What you see | Useful first thought |
|---|---|
| context deadline exceeded | The caller stopped waiting. What work had been admitted, what effect may have committed, and who can authoritatively reconcile it? |
| all goroutines are asleep - deadlock | Which goroutine owns progress, which channel or lock is it waiting on, and which lifecycle rule made that progress impossible? |
| concurrent map read and map write or a race report | Which shared object lacks one clear owner or synchronization relation? Preserve both access stacks. |
| HTTP 200 with missing resources | Transport success is not operation success. Was the response bounded, decoded strictly, validated semantically, and compared with authoritative state? |

The lesson uses Go because the language makes several important boundaries visible: explicit errors, package imports, typed values, goroutines, channels, contexts, and a compiled entry point. But the deeper skill is operational reasoning. The same questions apply to controllers, CI helpers, Kubernetes operators, deployment CLIs, reconciliation agents, and internal platform services.

The local lab is deliberately small and offline. It proves that a strict decoder, cancellation-aware model, idempotent receipt, state guard, tamper refusal, and exact cleanup work in one controlled environment. It does not pretend to be a cloud API.

## Terms before commands

### Source file, package, module, and executable

A Go source file ends in .go. Files in the same directory normally declare the same package and compile together for the selected build constraints.

A package is the unit other Go code imports. Package main is special: when it contains func main(), the toolchain can link it into an executable.

A module is a versioned collection of packages rooted at a go.mod file. The module path gives packages their import prefix. The go directive records the language/toolchain compatibility floor used by module commands; it is not proof that every newer or older toolchain behaves identically.

An executable is the linked artifact the operating system starts. Many Go programs are self-contained, but "Go binaries are always static" is false. cgo, DNS choices, platform libraries, certificate stores, and build tags can introduce runtime dependencies. Inspect the actual artifact and target.

### Compilation and linking

The compiler parses source, resolves types, and emits object code. The linker combines the main package, reachable dependencies, runtime support, and build information into an executable. Build tags, GOOS, GOARCH, cgo, environment, toolchain version, and source revision can change the result.

Compilation catches type errors. It does not execute all branches. A valid program can deadlock, race, leak, corrupt state, retry an unsafe mutation, or return the wrong exit code.

### Value, type, zero value, and invariant

A value is data at runtime. A type defines the operations and representation Go permits. Named types let the program distinguish concepts that share an underlying representation, such as OperationID and ServiceName.

Every variable has a zero value. For int it is 0, for bool false, for string empty, and for pointers, maps, slices, channels, functions, and interfaces nil. Zero values are useful when "empty" is safe and meaningful. They are dangerous when zero silently means "unlimited retries", "no timeout", "all namespaces", or "delete default target".

An invariant is a rule that must always be true after validation. Examples:

- operation ID is non-empty and matches a restricted alphabet;
- concurrency is between 1 and 16;
- timeout is between 100 milliseconds and 30 seconds;
- exactly one terminal result exists per accepted job;
- a published receipt names the same intent hash as the request.

Types help express invariants, but constructors and runtime validation still enforce them.

### Struct, method, interface, and dependency direction

A struct groups named fields. A method associates behavior with a receiver type.

An interface is a method set. A concrete type satisfies it implicitly by implementing those methods. Small interfaces are most useful at the consumer boundary. If an orchestrator needs only GetOperation, define that one method near the orchestrator instead of forcing every adapter to implement a giant provider interface.

This reverses a common mistake: do not create interfaces merely because mocking feels difficult. Create a boundary because the consumer needs a stable contract and multiple implementations or controlled tests are valuable there.

The nil-interface trap matters. An interface value contains a dynamic type and a dynamic value. An interface holding a typed nil pointer is not itself nil. Avoid returning typed nils as errors or service interfaces; test the behavior and return a literal nil interface when no value exists.

### Error, wrapping, identity, and classification

In Go an error is a value implementing Error() string. A useful error tells the caller what operation failed and preserves the underlying identity:

~~~go
return fmt.Errorf("read operation receipt %q: %w", operationID, err)
~~~

The %w relationship lets callers use errors.Is and errors.As. Comparing error strings is fragile. Decide which error categories are part of the public contract:

- invalid input: caller must change the request;
- definite no-effect: a new attempt may be eligible under policy;
- transient dependency failure: retry may be eligible within budget;
- unknown outcome: reconcile before any replay;
- cancellation or deadline: the caller stopped waiting; effect status still needs reasoning;
- internal defect: fail closed, preserve evidence, and fix code.

A panic is not an ordinary infrastructure error. It represents a broken runtime assumption or explicit panic call. Recover only at carefully chosen process or request boundaries to emit evidence and isolate one request when safe. A recovered panic does not make corrupted shared state trustworthy.

### Context, deadline, cancellation, and cause

A context carries cancellation, deadline, and request-scoped values across an API boundary. Pass it as the first parameter. Do not store it in a long-lived struct. The creator of a derived context should call its cancel function, usually with defer.

Cancellation is cooperative. Closing ctx.Done asks code to stop; it does not kill a goroutine or roll back a remote request. Blocking calls must select on the context or accept it directly. A context deadline should represent the remaining overall budget, not be reset to a fresh full timeout at every layer.

Context values are for request-scoped metadata that crosses process/API boundaries, not optional parameters or a hidden dependency container.

### Goroutine, channel, synchronization, and race

A goroutine is a function executing concurrently under the Go runtime. It is cheaper than an operating-system thread, but it is not free. Each goroutine retains a stack, references, scheduler state, and possibly an open body, timer, lock, or downstream request.

A channel transports typed values and synchronizes send/receive operations. It is not automatically a queueing strategy. Unbuffered channels couple sender and receiver directly. Buffered channels allow a bounded number of sends to proceed, but a buffer does not remove the need for ownership and backpressure.

The sending side that knows no more values will be sent owns channel closure. Receivers should not close a shared input channel. Sending on a closed channel panics; receiving from a closed channel returns buffered values and then the zero value with ok=false.

A data race occurs when concurrent accesses to the same memory include a write and lack required synchronization. A logical race can occur without a data race: two synchronized workers may still both decide to create the same remote resource because the business operation lacks atomicity or idempotency.

Mutexes protect shared memory. Channels coordinate ownership and data flow. Neither automatically fixes a distributed race.

### HTTP client, transport, request, response, and body

http.Client applies policy across requests. Transport owns connection establishment, pooling, proxy behavior, TLS negotiation, and many phase limits.

The zero-value Client has no overall timeout. A context deadline can bound a request. In production, combine a remaining request deadline with deliberate transport phase settings. Avoid constructing a new Transport per request because that destroys connection reuse and can leak idle resources.

A response status is part of the application protocol. Go does not treat HTTP 500 as a transport error. Check status explicitly. Always close a non-nil response body. Bound how many bytes you read. For connection reuse, consume an acceptably bounded body to EOF when safe, then close it; never drain an attacker-controlled or unexpectedly huge body without a limit.

### JSON syntax, shape, and meaning

JSON decoding has layers:

1. bytes must be valid JSON;
2. top-level shape must match;
3. unknown fields may need rejection;
4. field types must match;
5. ranges and relationships must be valid;
6. the caller must be authorized for the requested effect.

Decoder.DisallowUnknownFields helps catch misspellings. It does not replace semantic validation. Decode once, then attempt a second decode and require io.EOF so trailing JSON is rejected. Limit input bytes before decoding. Avoid relying on omitempty when omitted and explicitly zero have different meanings.

### Atomic visibility, durability, and exact cleanup

An atomic rename can make readers observe either the old complete name or the new complete name, not a partially copied file, when source and destination are on the same filesystem and platform semantics support the operation. It does not prove the bytes reached stable storage. File Sync and, on supported Unix filesystems, directory synchronization strengthen crash-durability evidence.

Windows replacement semantics differ from Unix when a destination already exists. Design and test for the supported operating systems instead of treating one successful rename as portable proof.

Exact cleanup means the tool removes only objects it created and can still prove it owns. It verifies a canonical root, expected identity, file types, names, and content contract; refuses on unexpected objects; deletes leaf artifacts by literal path; removes empty directories; and verifies absence. Recursive wildcard deletion is not a cleanup proof.

### Signal and exit code

A signal is an operating-system notification. On Unix, signal.NotifyContext can convert selected signals such as SIGINT and SIGTERM into cancellation. SIGKILL cannot be caught, so correctness cannot depend only on deferred cleanup. Windows console events and service shutdown differ; test the target host.

An exit code is part of the CLI API. A practical contract might use:

- 0: requested operation verified;
- 2: invalid CLI or input;
- 3: definite operation failure;
- 4: outcome unknown and reconciliation required;
- 5: internal defect;
- 130: interrupted convention where appropriate.

Keep main small. Let run return an exit code after defers complete. Calling os.Exit deep inside the program skips deferred functions in that goroutine.

## Architecture map

Here is the whole tool as an evidence chain:

~~~text
 repository                 build boundary                    runtime boundary
+-------------+     +--------------------------+     +--------------------------+
| .go source  | --> | go version / env / tags  | --> | argv + env + identity    |
| go.mod      |     | type check + compile     |     | parse + strict validate  |
| go.sum      |     | link + build metadata    |     | immutable typed request  |
+-------------+     +--------------------------+     +-------------+------------+
                                                                    |
                                                                    v
 authoritative state          effect boundary                orchestration
+----------------------+     +--------------------------+     +-------------------+
| remote resource      | <-- | HTTP/process/filesystem  | <-- | context deadline  |
| durable local state  |     | status/body/receipt      |     | bounded workers   |
| operation lookup     |     | error classification     |     | ownership + join  |
+----------+-----------+     +--------------------------+     +-------------------+
           |
           v
+--------------------------------------------------------------------------+
| reconcile -> verify user operation -> durable receipt -> logs/metrics -> |
| stable stdout/stderr and exit code                                       |
+--------------------------------------------------------------------------+
~~~

Whenever behavior is surprising, locate the earliest boundary where the contract diverged. If input was invalid, debugging worker scheduling is premature. If the request left the process and the response was lost, retry logic cannot decide from the local error alone. If the binary differs between CI and laptop, application source review alone is incomplete.

### Functional core and imperative shell

Keep policy functions deterministic where possible:

~~~text
 raw bytes --> strict decode --> Validate --> Plan
                                      |
                                      v
                               immutable intent
                                      |
                  +-------------------+-------------------+
                  v                                       v
            HTTP adapter                           filesystem adapter
                  |                                       |
                  +-------------------+-------------------+
                                      v
                              typed observations
                                      |
                                      v
                           Reconcile --> Verify
~~~

The core decides. Adapters observe and mutate. This gives tests honest boundaries: a unit test can prove Plan maps valid input to intent; it cannot prove a real API honors an idempotency key.

A useful interface is small:

~~~go
type OperationReader interface {
    GetOperation(ctx context.Context, id OperationID) (OperationState, error)
}
~~~

The production HTTP adapter and a deterministic lab adapter can implement it. The orchestrator owns the policy for what to do with returned states. The adapter owns transport mechanics.

### Cancellation and result flow

~~~text
 controller deadline
        |
        v
  root context ---- cancellation cause
        |
        +--> producer --jobs--> fixed workers --results--> collector
        |                       |       |
        |                       |       +--> adapter(ctx)
        |                       |
        +-----------------------+----------- stop admission
                                                |
                                                v
                        close jobs -> workers exit -> close results -> join
~~~

Cancellation flows down. Results and errors flow up. Ownership determines who closes channels. The coordinator does not return until all goroutines it started are accounted for, unless it deliberately transfers ownership to a longer-lived component.

### HTTP operation path

~~~text
 intent + operation ID
          |
          v
 request.WithContext
          |
 DNS -> connect -> TLS -> write -> response headers -> bounded body
          |                                         |
          |                                         v
   phase evidence                             strict decode
                                                    |
                         +--------------------------+----------------------+
                         |                                                 |
                    definite reject                                  response lost
                         |                                                 |
                         v                                                 v
                 no-effect evidence                              authoritative lookup
                         |                                                 |
                         +--------------------------+----------------------+
                                                    v
                                      committed / no-effect / unknown
~~~

Notice what is missing: "timeout -> retry". That arrow is intentionally absent.

### Publication path

~~~text
 approved parent
      |
 lstat / canonical identity / policy
      |
 private candidate in same directory
      |
 encode -> check errors -> Sync -> Close -> strict readback
      |
 rename or platform-specific replace
      |
 directory durability where supported
      |
 consumer readback and intent comparison
~~~

A generated file is not correct because json.Valid returns true. The consumer contract may require exact count, unique IDs, stable ordering, version metadata, and a digest over canonical intent.

## Request or state path

Walk one infrastructure operation from launch to truth.

### 1. Select the artifact

Record the absolute executable path, digest, Go build information, source revision, target, and configuration source. PATH is a policy decision. If an operator thinks release A ran but PATH selected release B, every later conclusion is contaminated.

go version -m reads embedded build information from many Go executables. It is evidence, not signature verification.

### 2. Parse the CLI boundary

Use flag.FlagSet or a deliberate CLI library. Separate machine-readable stdout from diagnostics on stderr. Reject unknown flags. Distinguish usage errors from operational errors.

Configuration precedence must be explicit. For example:

~~~text
 compiled safe defaults
        < reviewed config file
        < environment
        < explicit CLI flag
~~~

Do not let an empty environment variable silently erase a safe default unless the contract says it may.

### 3. Decode and validate external data

A strict decoder pattern:

~~~go
func DecodeRequest(r io.Reader) (Request, error) {
    limited := io.LimitReader(r, maxRequestBytes+1)
    dec := json.NewDecoder(limited)
    dec.DisallowUnknownFields()

    var raw requestWire
    if err := dec.Decode(&raw); err != nil {
        return Request{}, fmt.Errorf("decode request: %w", err)
    }

    var extra any
    if err := dec.Decode(&extra); !errors.Is(err, io.EOF) {
        if err == nil {
            return Request{}, errors.New("decode request: trailing JSON value")
        }
        return Request{}, fmt.Errorf("decode trailing data: %w", err)
    }
    return validateRequest(raw)
}
~~~

Also prove the size limit. LimitReader alone returns EOF after the limit; use a limit of maximum plus one and count bytes, or MaxBytesReader in an HTTP handler, so oversized input is distinguishable from exactly bounded input.

Use pointer fields in the wire struct when omitted differs from zero:

~~~go
type requestWire struct {
    Concurrency *int `json:"concurrency"`
    TimeoutMS   *int `json:"timeout_ms"`
}
~~~

Convert that wire representation into an internal Request with no ambiguous missing state.

### 4. Construct immutable intent

Create a canonical operation ID and intent digest before mutation. A retry of the same logical request reuses the identity. A new random key per attempt describes a different operation to most servers.

Do not put credentials, full payloads, or personal data in the idempotency key or logs. Prefer an opaque operation ID plus server-side association with authorized intent.

### 5. Establish one overall deadline

At process or request entry:

~~~go
ctx, cancel := context.WithTimeout(parent, overallBudget)
defer cancel()
~~~

Every nested operation sees the remaining deadline. Do not reset a 30-second timeout inside each of ten sequential calls and accidentally create a five-minute operation.

A local validation failure should occur before a remote request. A canceled context before admission should prevent new work. A cancellation after a request is sent may leave its effect unknown.

### 6. Admit bounded concurrent work

Decide the concurrency cap from dependency capacity, memory, file descriptors, rate limits, and latency goals. It is not CPU count by default.

One pattern:

~~~go
jobs := make(chan Job)
results := make(chan Result)
var workers sync.WaitGroup

for i := 0; i < workerCount; i++ {
    workers.Add(1)
    go func() {
        defer workers.Done()
        for job := range jobs {
            results <- execute(ctx, job)
        }
    }()
}

go func() {
    workers.Wait()
    close(results)
}()
~~~

This fragment is incomplete: sends must respect cancellation, the producer must close jobs, the collector must keep draining results, and early returns must not strand workers. The lesson lab uses simpler deterministic effects; production code needs lifecycle tests.

### 7. Cross the effect boundary

For HTTP, construct a request with context, use one reused client, check status, cap the response, close the body, decode strictly, and return a classified error.

For filesystem state, prove the parent, create the candidate there, encode fully, sync according to durability requirements, validate, publish, and verify.

For a child process, use exec.CommandContext with an argument slice. Understand that killing the direct child may not terminate grandchildren or undo external effects.

### 8. Reconcile ambiguous outcomes

Classify observations:

| Observation | Local knowledge | Retry decision |
|---|---|---|
| validation rejected before send | definite no effect | eligible only after correction |
| server returns documented conflict with existing same intent | likely committed or duplicate | read authority and adopt if identical |
| connection failed before any request bytes were written, with trustworthy phase evidence | may be no effect | policy may allow bounded retry |
| deadline after request write | unknown | reconcile first |
| response decoded but semantic version mismatches | operation not verified | stop and investigate |
| authoritative operation lookup says committed | committed | record receipt, do not replay |
| lookup says absent with a documented linearizable guarantee | proven no effect within that guarantee | bounded retry may be eligible |
| lookup itself unavailable | unknown remains | do not guess |

"Connection refused" may be evidence of no server accepting that connection, but proxies, retries inside transports, and alternative endpoints complicate the claim. Be precise about the observed layer.

### 9. Publish a durable receipt

A receipt should bind:

- stable operation ID;
- canonical intent digest;
- target identity and namespace;
- authority-reported version/state;
- attempt count;
- timestamps and duration with units;
- verification method;
- tool artifact identity.

Writing the receipt twice with identical intent should converge on the same logical state. Writing the same operation ID with a different intent must fail as a conflict.

### 10. Verify the user's operation and exit

Process success means the promised postcondition is visible through the appropriate consumer or authority. It does not mean the last function returned nil.

Only after verification should the tool emit its success event and return 0. Unknown outcome needs a distinct nonzero code and a clear next action.

## Failure zoom

### Failure 1: unbounded goroutines make the dependency the queue

A loop starts one goroutine per resource:

~~~go
for _, resource := range resources {
    go reconcile(resource)
}
~~~

For 100 resources it may look fast. For one million resources it creates a memory, scheduler, socket, and downstream pressure event. If each goroutine blocks on an HTTP connection or result send, the process becomes an unbounded queue with weak observability.

Root cause is not "Go is too concurrent". The design admitted work without a capacity contract.

Fix:

- bound accepted work;
- use a fixed or dynamically capped worker group;
- carry context through admission and execution;
- make queue depth and wait visible;
- define overload behavior;
- collect one terminal result per accepted job;
- join every worker.

### Failure 2: the collector returns early and leaks workers

A collector sees the first error and returns. Workers continue sending to an unbuffered result channel. No receiver remains. They block forever, retaining request state and possibly response bodies.

Fix either keep draining until workers retire or cancel and use a design where every send can observe cancellation:

~~~go
select {
case results <- result:
case <-ctx.Done():
    return
}
~~~

Even then, the coordinator must wait for worker retirement. Cancellation is not joining.

### Failure 3: channel closure has no owner

Multiple workers each defer close(results). The first worker to finish closes it; the next worker sends and panics.

Only a goroutine that knows all sends are complete should close the channel. Usually that is a coordinator waiting on a WaitGroup.

Do not test whether a channel is closed before sending. Another goroutine can change the state immediately; the operation is inherently racy as a policy.

### Failure 4: a map is protected only sometimes

Writes hold a mutex, but a metrics endpoint reads the map without it. Under load the runtime may report concurrent map access, or the race detector may report the exact conflicting stacks.

Every access follows one ownership rule. Choices include:

- one goroutine owns the map and receives messages;
- all reads and writes hold the same mutex;
- a copy-on-write snapshot is published atomically;
- sync.Map is chosen for a measured access pattern.

Changing to sync.Map without understanding compound invariants can remove a runtime panic while leaving incorrect multi-step decisions.

### Failure 5: context is accepted and ignored

An API has ctx context.Context but calls a helper that uses http.NewRequest instead of NewRequestWithContext. The top layer times out, yet the network call continues. This creates latency, resource leakage, and duplicate-risk if a controller starts another attempt.

Trace cancellation end to end. A context parameter is not proof.

### Failure 6: timeout is classified as definite failure

The client sent a create request. The server committed. The response was lost. Client.Do returns context deadline exceeded. Code retries with a new operation ID. Two resources exist.

Immediate mechanism: response absence was misclassified as effect absence.

Root cause: no durable logical identity and no reconciliation interface.

Prevention: stable operation identity, server-side idempotency contract, authoritative lookup, explicit unknown-outcome state, and response-loss tests.

### Failure 7: HTTP body is not closed or is unbounded

The code decodes directly from resp.Body and forgets Close. Connections stop being reused and file descriptors grow. Another version calls io.ReadAll on an untrusted error body, allowing memory growth.

Use a maximum. Close on every response path. Capture only a redacted bounded excerpt for diagnostics. Decide whether draining to EOF is safe within the size and deadline budget.

### Failure 8: JSON accepts a typo

Configuration says "concurency": 100. The struct field remains zero. Code interprets zero as unlimited.

Reject unknown fields. Model omission explicitly. Validate a safe range. Return an input exit code before starting workers. Include the offending field name without logging secret values.

### Failure 9: an interface hides a typed nil

~~~go
var client *APIClient = nil
var reader OperationReader = client
if reader != nil {
    // This branch runs because the interface has a dynamic type.
}
~~~

A method call may panic. Constructors should avoid returning typed nil interface values. Tests should cover absent adapters and nil receiver behavior. Keep interfaces narrow so construction is obvious.

### Failure 10: os.Exit skips cleanup

Deep code calls os.Exit(1). Deferred file closes, profile stops, trace flushes, lock release, and temporary cleanup in that goroutine do not run.

Let run return an error or exit code. main alone calls os.Exit after run returns:

~~~go
func main() {
    os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}
~~~

This still cannot protect against SIGKILL or power loss. Durable intent and startup reconciliation remain necessary.

### Failure 11: rename is called "durable"

The process writes a candidate and renames it. Readers see a complete file. After a crash, directory metadata may not be durable on the target filesystem. Or on Windows, replacing an existing destination behaves differently.

Write down the guarantee you need:

- no partial readers;
- survives process crash;
- survives operating-system crash;
- survives storage-controller failure;
- replicated across nodes.

Then test the relevant platform. "Atomic" without scope is incomplete.

### Failure 12: green tests hide the wrong model

A mock returns exactly what the implementation expects. The test passes even though the real API uses a different status, retries internally, caps idempotency retention, or returns eventual state.

Layer evidence:

- unit tests for pure decisions;
- contract tests against an authoritative specification or controlled fake;
- integration tests against a real isolated dependency;
- failure injection for response loss, latency, cancellation, and partial state;
- canary and production telemetry.

A mock proves your code's behavior against that mock.

## Internals and state ownership

### Runtime scheduler and goroutine state

The Go runtime multiplexes runnable goroutines over operating-system threads. Goroutines can be runnable, running, waiting on channels or locks, sleeping, blocked in system calls, or stopped for garbage collection.

A goroutine dump is a snapshot. Repeated dumps show whether stacks persist. One large count may be legitimate during a batch; a count that never returns toward baseline after cancellation is stronger leak evidence.

Expose bounded metrics:

- goroutines;
- accepted, active, completed, failed, canceled, and unknown jobs;
- queue depth and wait seconds;
- operation latency by outcome;
- open/idle connections where available;
- reconciliation count;
- receipt conflicts.

Never label metrics with unbounded operation IDs, URLs, error strings, or resource names.

### Memory ownership and happens-before

The memory model defines when one goroutine's write is visible to another. Channel send/receive and mutex unlock/lock establish synchronization relationships. "It usually runs after" is not synchronization.

Prefer one owner for mutable state. If multiple goroutines need a snapshot, publish an immutable copy. Keep lock scope small but preserve invariants. A pair of individually atomic fields may still represent an invalid combined state if readers need them to change together.

The race detector instruments memory accesses and reports conflicts that occur. It changes timing and resource use. Run it on representative tests, but also reason about ownership.

### Error ownership

The function closest to the mechanism adds context. The layer that owns policy classifies the error.

An HTTP adapter might return:

~~~go
type UnknownOutcomeError struct {
    OperationID OperationID
    Cause       error
}

func (e *UnknownOutcomeError) Error() string {
    return "operation outcome is unknown: " + string(e.OperationID)
}

func (e *UnknownOutcomeError) Unwrap() error { return e.Cause }
~~~

It should not itself retry indefinitely. The orchestrator knows the overall budget, attempt history, idempotency contract, and business operation.

Avoid logging the same error at every layer. Return with context, then log once at the boundary that owns the final outcome.

### Context ownership

The caller creates and cancels a child context. Libraries do not accept nil context. Long-lived background services use a lifecycle context created at startup and canceled during shutdown.

Do not use context values for secrets if they may be logged or propagated unexpectedly. Typed unexported keys reduce collisions but do not create a security boundary.

When joining errors after cancellation, preserve the primary operation state. A cancellation may be a contributing observation while the authoritative outcome remains unknown.

### Channel ownership

Write a channel table before complex concurrency:

| Channel | Sender | Receiver | Who closes | Maximum buffered | Cancellation behavior |
|---|---|---|---|---|---|
| jobs | producer | workers | producer | bounded | producer stops; workers drain or exit by policy |
| results | workers | collector | coordinator after WaitGroup | bounded | sends select on context or collector drains |
| alerts | detector | reporter | detector owner | bounded | overflow policy is explicit |

If no one can answer "who closes it", the lifecycle is not ready.

### HTTP transport ownership

Create and reuse a Client and Transport. The component that constructs them owns configuration and CloseIdleConnections at shutdown if required.

A production transport can set:

- ProxyFromEnvironment only when proxy use is intended and reviewed;
- DialContext with connection timeout and keepalive;
- TLSHandshakeTimeout;
- ResponseHeaderTimeout;
- ExpectContinueTimeout;
- MaxIdleConns and MaxIdleConnsPerHost;
- IdleConnTimeout.

Client.Timeout is an overall convenience limit, including reading the response body. A request context gives per-operation control and cancellation cause. Choose one coherent deadline model; nested independent timers make diagnosis harder.

TLS defaults verify certificate chains and hostnames. Do not set InsecureSkipVerify to make an incident disappear. Load an approved trust root and preserve verification.

### Filesystem ownership

A path string is not ownership. Resolve and validate the intended root, reject symlinks/reparse points according to platform policy, use exclusive creation, record identity, and operate through the narrowest available directory boundary.

The LES-0020 lab uses a randomized root below the current user's temp directory and a separate isolated descriptor directory. Its complete verifier also owns one reusable, randomly named Go build-cache directory under that temp boundary so repeated refusal cases do not recompile the standard library. It validates the registered paths, rejects reparse points, allowlists model files, and refuses cleanup if something unexpected appears. That demonstrates a boundary, not a formal Windows ACL certification.

Production options include:

- openat-style directory-relative operations on Unix;
- dedicated service-owned directories;
- immutable container filesystems plus a mounted state volume;
- object-store conditional writes and version IDs;
- database transactions with uniqueness constraints.

Do not emulate a distributed lock with a local file when multiple hosts can act.

### Authoritative state ownership

Local state can say "attempt sent". Only the remote service can say whether it committed, unless the protocol provides a stronger receipt. Kubernetes controllers, cloud APIs, payment services, and CI orchestrators may all retry independently.

Map every state:

~~~text
planned -> admitted -> attempting -> unknown
                    \-> definite-no-effect
                    \-> committed -> locally-recorded -> user-verified
~~~

Unknown is a first-class state, not a temporary spelling of failure.

## Evidence table

| Question | Evidence | Proves | Does not prove | Next step |
|---|---|---|---|---|
| Which code and toolchain built this? | revision, go version, go env, build metadata, digest | identity claims for inspected inputs/artifact | signature, clean source, reproducibility | compare approved provenance |
| Did input satisfy the contract? | bounded bytes, strict decode result, validated typed request | demonstrated syntax/shape/invariants | authorization or safe effect | build canonical intent |
| Was work bounded? | configured workers, queue cap, accepted count, active peak | admission limits in this run | downstream capacity or leak absence | compare retirement to baseline |
| Did cancellation propagate? | timestamps, context cause, adapter return, goroutine retirement | observed propagation on executed path | remote rollback | reconcile authority |
| Did a request commit? | authoritative lookup by stable operation ID | state returned under that API guarantee | permanent global uniqueness | bind receipt and verify target |
| Is JSON complete? | schema, expected count, uniqueness, digest, consumer readback | selected semantic invariants | future readers or durability | publish receipt and monitor |
| Is a race absent? | no report from -race | no race detected in executed schedules | all possible schedules | ownership review and stress |
| Is build portable? | cross-build success | compilation for one target | runtime behavior on target | execute target test |
| Is cleanup safe? | guard checks, refusal tests, exact deletion, absence proof | harness behavior for tested paths | all hostile filesystem races | platform security review |
| Is the learner proficient? | reviewed independent evidence | only what rubric review accepts | general mastery from reading | retain practice and review |

The important habit is to attach a "does not prove" sentence to each green result. That prevents one tool from being promoted into a universal guarantee.

## Command decoders

### Decode CMD-001: toolchain identity

command -V go shows how the shell resolves go. go version names the selected release and host target. go env reveals target, module, workspace, cgo, proxy, and checksum policy.

GOMOD pointing to /dev/null means module-aware mode without a main module. GOWORK can silently combine modules from a workspace. CGO_ENABLED changes portability. GOPROXY and GOSUMDB describe potential dependency network behavior; they are not proof no request occurred.

On the current WSL Ubuntu environment, go is absent. The correct response is to record that limitation, not perform an unapproved install during a lesson or claim later commands passed.

### Decode CMD-002 and CMD-003: module graph

go list -m -json answers which main module is selected. go list -deps asks which packages the build patterns resolve. The template prints only non-standard modules.

GOPROXY=off prevents module proxy or direct version-control fetching. GOSUMDB=off prevents checksum database access. These settings make a missing dependency fail locally rather than silently using the network. They do not erase already cached code or prove cache integrity.

Inspect replace directives. A replace can redirect a module to a local path or alternate version. That is useful in development and dangerous when hidden in release provenance.

### Decode CMD-004: formatting

gofmt -l prints filenames it would change. The wrapper converts an empty list to a clean status. gofmt is deterministic for a toolchain, but formatting is not correctness. Review generated diffs; do not mix broad formatting with an incident fix.

### Decode CMD-005: tests

-count=1 disables successful test-result reuse for that invocation. It does not disable build caching. GOCACHE and GOTMPDIR isolate generated files under the registered root.

A passing package line means all selected tests completed successfully. A test may still be weak, flaky in another schedule, or disconnected from the real authority.

### Decode CMD-006: vet

go vet runs analyzers selected by the toolchain. It can find Printf mismatches, copied locks, unreachable code patterns, malformed struct tags, and other suspicious constructs. It is not a complete static analyzer and does not promise backward-compatible analyzer output across releases.

Treat a warning as a question backed by source evidence. If suppression is necessary, document why the construct is correct and how a regression is prevented.

### Decode CMD-007: race detection

-race instruments accesses and adds runtime cost. Reports include stacks for conflicting accesses and goroutine creation. Preserve the first report. Fix the ownership rule rather than adding sleeps.

No report means only that no instrumented executed path exposed a race. Tests with small inputs or deterministic scheduling may miss the dangerous interleaving. Race-enabled binaries also have target/toolchain prerequisites.

### Decode CMD-008: fuzzing

A fuzz test begins with seed inputs, then the engine mutates values and uses coverage feedback. A failure is minimized and retained. Fuzz functions must be deterministic for the same input and should not access production networks, shared mutable state, or unbounded resources.

A three-second run is a learning gate, not security assurance. CI can run longer with CPU, time, disk, and corpus retention limits.

### Decode CMD-009: JSON test events

go test -json emits actions such as start, run, output, pass, fail, and package results. This is safer for CI ingestion than scraping friendly text. Timestamps and output may still contain sensitive data from tests; sanitize fixtures and logs.

The named TestRecoverIdempotent demonstrates the lab's local receipt contract. It cannot prove a remote API implements idempotency.

### Decode CMD-010 and CMD-011: artifact creation and inspection

-trimpath removes many local filesystem paths from object file metadata, improving privacy and reproducibility. -buildvcs=false deliberately prevents the learning artifact from embedding repository VCS metadata; production policy may instead require stamped provenance.

go version -m reads Go version, module path, dependencies, and selected build settings. Calculate a cryptographic digest separately when tracking the artifact. A digest identifies bytes, not trust.

### Decode CMD-012: cross-compilation

GOOS and GOARCH select the target. CGO_ENABLED=0 keeps this standard-library lab in the pure-Go path. Cross-build success means the compiler and linker produced a file. Linux behavior still requires Linux execution tests for paths, signals, certificates, DNS, permissions, and filesystem semantics.

In PowerShell, environment assignment syntax differs:

~~~powershell
$oldGoos = $env:GOOS
$oldGoarch = $env:GOARCH
$oldCgo = $env:CGO_ENABLED
try {
    $env:GOOS = 'linux'
    $env:GOARCH = 'amd64'
    $env:CGO_ENABLED = '0'
    go build -trimpath -buildvcs=false -o $target ./cmd/opsmodel
} finally {
    $env:GOOS = $oldGoos
    $env:GOARCH = $oldGoarch
    $env:CGO_ENABLED = $oldCgo
}
~~~

Restoring environment is part of the operation.

### Decode CMD-013: profiling

A CPU profile samples where execution time is attributed. pprof -top aggregates samples by function. Go's profile flags retain the test binary for symbolization, so CMD-013 gives that binary an explicit path inside the registered lab `bin` directory instead of allowing a package-named test binary to appear in the repository. A one-second synthetic benchmark is too small for confident optimization but teaches the workflow.

Profiles can expose function names, paths, endpoints, allocation behavior, and request data depending on profile type. Never enable a production profiling endpoint publicly or copy a profile into an unrestricted ticket.

Optimization order:

1. define the user-visible problem and SLO;
2. reproduce with representative load;
3. collect a bounded profile;
4. identify a dominant cost;
5. change one mechanism;
6. verify correctness and performance;
7. retain before/after evidence.

## Decision path

Use this when a Go tool fails during an infrastructure operation.

~~~text
START
  |
  v
Can you identify artifact, config, identity, target, and operation ID?
  | no
  +--> stop mutation; reconstruct execution identity
  |
 yes
  v
Did strict validation finish before effects?
  | no / unknown
  +--> preserve input safely; inspect decoder and admission boundary
  |
 yes
  v
Was a mutation request or local publish attempted?
  | no
  +--> classify input/planning/build failure; fix and revalidate
  |
 yes
  v
Is the effect outcome authoritative and terminal?
  | committed
  +--> record/adopt receipt; verify the user's operation
  |
  | definite no effect
  +--> decide bounded retry from policy and remaining budget
  |
  | unknown
  +--> freeze replay; reconcile by stable operation ID
  |
  v
Did every admitted goroutine produce one terminal result and retire?
  | no
  +--> cancel admission; drain or join; diagnose ownership/leak
  |
 yes
  v
Is publication semantically complete and consumer-readable?
  | no
  +--> retain prior good state; rebuild candidate; validate; republish
  |
 yes
  v
Emit bounded telemetry and the exit code matching the verified outcome
~~~

### When retry is allowed

Retry only if all are true:

- the failure class is eligible;
- the logical operation identity is stable;
- the dependency documents idempotency or no-effect evidence is strong enough;
- the overall deadline has remaining budget;
- attempt count and elapsed time remain below caps;
- backoff includes jitter for shared dependencies;
- concurrency and total retry traffic are bounded;
- cancellation stops new attempts;
- telemetry distinguishes original work from retries.

Exponential backoff without a cap can exceed the operation deadline. Jitter reduces synchronized retry storms. A retry budget limits the fraction of traffic consumed by retries.

### When compensation replaces rollback

A remote notification, payment, or external provisioning effect may not be reversible as though it never happened. Compensation is a new authorized operation that attempts to restore business intent. It needs its own identity, audit trail, failure handling, and verification.

Do not call compensation "rollback" when the original effect remains historically visible.

### When to use a mutex, channel, or atomic

- Mutex: several goroutines access one in-memory invariant and short critical sections are clear.
- Channel: ownership transfer, bounded work flow, or lifecycle coordination is the primary model.
- Atomic: one independent word-sized state or counter with documented memory semantics.
- Database/API conditional write: the invariant spans processes or hosts.
- Lease plus fencing token: a distributed actor must prove it is still current before writing.

A process-local mutex cannot solve two Kubernetes replicas racing.

## Guided Ubuntu lab

The heading remains stable for the book contract, but environment truth comes first: the available WSL Ubuntu 24.04 instance does not currently have Go. The lab was executed on Windows 11 with Go 1.22.0. Do not install Go from the network merely to satisfy a checkbox.

If an approved Go 1.22 or newer compatible toolchain is later present in Ubuntu, run these read-only preflights:

~~~bash
cat /etc/os-release
id
pwd -P
command -V go
go version
go env GOVERSION GOOS GOARCH CGO_ENABLED GOMOD GOWORK GOPROXY GOSUMDB
~~~

Expected branches:

- command -V go fails: stop. Record "Ubuntu Go runtime unavailable"; use the tested Windows path.
- Go exists but version or module differs: stop and select the approved environment.
- The module root and supported version match: run gofmt, go test, and go vet with networking disabled and an isolated absolute cache root.
- An external dependency is missing: do not turn networking on. Review the module and approved dependency acquisition workflow.

### Tested Windows walkthrough

Open normal, non-administrator Windows PowerShell in:

~~~text
book/labs/LES-0020-go-tooling
~~~

Preflight:

~~~powershell
whoami
Get-Location
Get-Command go
go version
go env GOVERSION GOOS GOARCH CGO_ENABLED GOMOD GOWORK GOPROXY GOSUMDB
~~~

Expected tested baseline includes go1.22.0 windows/amd64. A different compatible version may work, but that is a new environment result.

Choose an isolated descriptor directory for this run:

~~~powershell
$stateHome = Join-Path ([IO.Path]::GetTempPath()) ('reliability-atlas-LES-0020-state.' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stateHome | Out-Null
$env:RELIABILITY_ATLAS_STATE_HOME = $stateHome
~~~

The verifier does this automatically. The learning controller refuses an elevated token, reparse-point boundaries, out-of-scope roots, changed source identity, unexpected files, and malformed state.

Check absence and setup:

~~~powershell
.\lab.ps1 check
.\lab.ps1 setup
.\lab.ps1 status
~~~

Expected shape:

~~~text
state=absent
setup=complete
lab_root=C:\Users\...\Temp\reliability-atlas-LES-0020.<random>
state=ready
baseline=pending
case=none
receipt=absent
verification=absent
~~~

Copy the printed lab_root into an absolute environment variable only if you want to run the decoded Go commands manually:

~~~powershell
$env:ATLAS_RUN_ROOT = (.\lab.ps1 root)
~~~

Run the deterministic baseline:

~~~powershell
.\lab.ps1 baseline
~~~

Expected JSON reports record=baseline, accepted_jobs=3, terminal_results=3, duplicate_receipts=0, cancellation=none, and operation_success=true. This proves the model's baseline output, not remote behavior.

Inject the guided case:

~~~powershell
.\lab.ps1 inject guided
.\lab.ps1 scenario
~~~

The raw scenario says a publisher accepted three jobs, returned success, and produced only two terminal results after a child context was canceled. Before observing more, predict:

- which lifecycle invariant failed;
- whether any remote effect is unknown;
- which evidence distinguishes missing result from missing effect;
- who owns channel closure and worker joining;
- why returning zero is invalid.

Observe one view at a time:

~~~powershell
.\lab.ps1 observe contract
.\lab.ps1 observe runtime
.\lab.ps1 observe state
.\lab.ps1 observe outcome
~~~

Interpretation:

- contract compares accepted jobs with required terminal results;
- runtime shows cancellation and retirement evidence;
- state identifies which owner has which fact;
- outcome supplies authoritative modeled results.

Recover:

~~~powershell
.\lab.ps1 recover
.\lab.ps1 recover
~~~

The first run writes a receipt through the Go model. The second reads the existing receipt, compares operation ID and intent digest, and reports already-complete. It does not create a duplicate receipt. This is idempotency in this local model only.

Verify:

~~~powershell
.\lab.ps1 verify
.\lab.ps1 status
~~~

Verification checks expected result count, unique IDs, receipt binding, and consumer readback. A green verifier does not award mastery.

Cleanup:

~~~powershell
.\lab.ps1 cleanup
.\lab.ps1 check
~~~

Expected final state is absent. If cleanup reports an unexpected file or boundary mismatch, stop. Inspect it. Do not use recursive deletion.

### Complete verifier

From the lab directory:

~~~powershell
.\verify.ps1
~~~

It performs:

1. Go version and offline module preflight;
2. gofmt check;
3. go test with count=1;
4. go vet;
5. current-target build and metadata inspection;
6. baseline, guided, and independent lifecycles;
7. repeated setup, recover, verify, cleanup, and check;
8. raw independent answer-isolation checks;
9. unexpected-artifact cleanup refusal;
10. manifest tamper refusal and restoration;
11. out-of-scope descriptor cleanup refusal while an external sentinel survives;
12. verifier-only elevated-guard branch;
13. final registered-state absence.

It deliberately does not claim the race gate passes if the Windows host lacks the required race toolchain. Run that command separately and record its real branch.

### Independent case

Copy ASM-0045-response-template.md outside the lab-owned root before beginning. Start a clean session:

~~~powershell
.\lab.ps1 setup
.\lab.ps1 baseline
.\lab.ps1 inject independent
.\lab.ps1 scenario
~~~

Paste raw scenario output before requesting derived observations. The controller's scenario output contains inputs and client-observed facts only. It omits authoritative outcome, diagnosis, recovery, retry decision, and answer key.

Write at least three hypotheses. Then use only the views needed to distinguish them. Preserve a timeline with "proves" and "does not prove" for each observation.

Finish with recover, verify, cleanup, and check. A human or authorized reviewer evaluates the response. The harness cannot score your reasoning.

## Production transfer

### CLI deployed in CI

CI adds several controllers:

~~~text
developer push -> CI event -> job scheduler -> runner -> Go tool -> dependency
                       \---------- retry / timeout / cancellation ---------/
~~~

Define how retries compose. If the Go tool retries three times and the CI job retries twice, one event may produce six attempts. Use one stable logical operation ID across controller boundaries where possible.

Pin the Go toolchain and dependency policy. Build in an immutable runner. Record artifact digest, module graph, source revision, target, build flags, and test evidence. Avoid depending on a developer's GOWORK or module cache.

CI stdout may become a public artifact. Put stable machine output on stdout, bounded diagnostics on stderr, and secrets nowhere.

### Long-running service

A service needs lifecycle ownership:

- construct shared clients and transports once;
- begin readiness only after required dependencies and state are ready;
- stop admission on shutdown;
- cancel the root lifecycle context;
- allow bounded in-flight completion;
- reconcile unknown effects;
- close idle connections and telemetry exporters;
- exit before the supervisor's hard kill deadline.

Readiness is not liveness. A process can be alive but unable to serve safely.

### Kubernetes controller

Controllers are reconciliation loops. Events can repeat, disappear, or arrive out of order. Desired and observed state are the contract; event delivery is a hint.

Use:

- namespaced identity and least privilege;
- resourceVersion or conditional updates for conflicts;
- stable object identity;
- workqueue rate limiting and bounded concurrency;
- context from the reconciliation request;
- finalizers only when cleanup responsibility is explicit;
- status conditions that separate progressing, failed, and unknown;
- leader election when needed, with fencing-aware external writes.

A Kubernetes leader lease does not automatically fence a slow old leader from an external database. The external effect needs a token or conditional write it understands.

### Container image

A small Go binary can support a minimal image, but operations still need certificates, timezone data when relevant, user identity, writable state paths, and debug strategy.

Build and runtime stages should pin base images by reviewed digest according to policy. Run as non-root. Use a read-only root filesystem where possible. Mount only explicit state. Handle PID 1 signals and reap children if the tool launches them.

Cross-compilation is not a container test. Execute the exact image under the target architecture and security context.

### HTTP API client

Production API integration adds:

- authentication and secret rotation;
- TLS trust and proxy boundaries;
- API versioning;
- rate limits and Retry-After;
- pagination;
- request/response size limits;
- idempotency retention window;
- consistency model of operation lookup;
- regional failover semantics;
- audit logging;
- cost and quota.

A failover endpoint may not share idempotency state immediately. Retrying in another region can create a distributed duplicate unless the service contract says otherwise.

### Local file to object storage

os.Rename does not translate to object storage. Object stores use object versions, conditional requests, multipart uploads, and read consistency contracts. Publish a manifest or pointer through a conditional write after the data object is complete. Verify the consumer path.

### PowerShell and Ubuntu differences

The Go program can be portable while wrappers are not. PowerShell environment assignment, path syntax, signal handling, ACLs, and executable suffixes differ from Bash, Unix permissions, and forward-slash paths.

Keep platform-specific code in files selected by suffix such as _windows.go and _unix.go when behavior genuinely differs. Test both targets. Do not hide semantic differences behind one interface without tests.

## Reliability, security, observability, capacity, and cost

### Reliability

Define service-level behavior for the tool:

- valid request either reaches a verified terminal state or returns a distinct unknown outcome;
- no accepted job disappears;
- repeated delivery with the same intent converges;
- cancellation stops admission and retires owned goroutines;
- the last known-good published state remains available after failed candidate creation;
- restart reconciles durable in-progress operations.

Test the negative paths. Inject cancellation before admission, during queue wait, during HTTP response loss, during candidate write, after remote commit, and before receipt publication.

### Security

Treat every boundary as untrusted:

- CLI arguments and environment;
- JSON and YAML;
- file paths and symlinks/reparse points;
- HTTP status, headers, and bodies;
- proxy environment;
- redirect targets;
- module replacements;
- build scripts and generators;
- profiles and logs.

The standard HTTP client follows redirects by default. Authorization headers can be sensitive across hosts. Configure CheckRedirect when redirect behavior matters, and validate the final authority.

Avoid logging full URLs with signed queries, Authorization or Cookie headers, request/response bodies, environment maps, or errors containing them. Redaction must have tests.

The Go module ecosystem provides checksums and a vulnerability database, but:

- go.sum authenticates module content against recorded hashes and checksum policy; it does not review code;
- module proxy and checksum database access are network and privacy decisions;
- replace directives can bypass expected provenance;
- a clean vulnerability scan means no known matching report under the scanner's knowledge and reachability model;
- standard-library risk depends on the Go release used to build.

Use approved toolchains, minimal dependencies, code review, provenance, signed release policy, vulnerability scanning, and rebuild response.

### Observability

Logs should answer:

- which operation and attempt;
- which artifact and target;
- which phase;
- which bounded result class;
- what duration and unit;
- whether outcome is committed, no-effect, or unknown;
- what next action is safe.

Example:

~~~json
{"severity":"WARN","event":"operation_outcome_unknown","operation_id":"op-417","attempt":1,"phase":"response_wait","elapsed_ms":30000,"next_action":"reconcile"}
~~~

Metrics:

- operations_total by bounded outcome;
- operation_duration_seconds histogram;
- queue_wait_seconds;
- active_workers;
- goroutines;
- retries_total by bounded cause;
- unknown_outcomes;
- reconciliation_duration_seconds;
- receipt_conflicts_total;
- response_body_limit_exceeded_total.

Traces should link controller, queue, worker, HTTP client, and reconciliation. Do not create one span per tiny item without sampling and cost analysis.

### Capacity

Concurrency is a budget across resources:

~~~text
memory ~= base process
        + active workers * per-worker live data
        + queued jobs * per-job size
        + buffered results
        + HTTP bodies
        + telemetry
~~~

If 50 workers each retain a 4 MiB response, that is roughly 200 MiB before queues, stacks, runtime, and copies. Bound response bodies and keep streaming where possible.

Use Little's Law carefully: average items in a stable system approximately equal arrival rate times average time in system. If arrivals exceed sustainable completions, queue wait grows. Adding workers helps only until CPU, network, dependency quota, lock contention, or downstream capacity saturates.

Backpressure choices:

- block the producer within a deadline;
- reject or shed low-priority work;
- persist to a durable queue;
- coalesce duplicate intents;
- reduce upstream rate.

An unbounded slice is not backpressure.

### Cost

Go can reduce memory and packaging overhead, but cost follows behavior:

- retries multiply API calls and egress;
- high-cardinality telemetry increases storage;
- profiles and debug logs consume disk;
- oversized concurrency creates throttling and longer tail latency;
- cross-region failover adds network cost;
- frequent full scans waste API quota;
- short-lived builds repeatedly download modules without a governed cache.

Measure cost per verified operation, not just process CPU. A fast tool that creates duplicate cloud resources is expensive.

### Performance evidence

Benchmarks use controlled inputs and report allocations:

~~~go
func BenchmarkDecodeRequest(b *testing.B) {
    payload := []byte(validFixture)
    b.ReportAllocs()
    for i := 0; i < b.N; i++ {
        if _, err := DecodeRequest(bytes.NewReader(payload)); err != nil {
            b.Fatal(err)
        }
    }
}
~~~

Do not compare benchmarks across noisy hosts without metadata. Correctness gates run before optimization. A lower allocation count does not justify unsafe buffer reuse across goroutines.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| "Compiled means correct" | type checking does not exercise operations | layer tests, reviews, failure injection, and runtime verification |
| One goroutine per item | admission has no capacity boundary | bounded worker or semaphore plus queue policy |
| Context only at top level | blocking adapters continue | propagate context to every wait and effect |
| Timeout means failure | remote commit may precede lost response | unknown state plus authoritative reconciliation |
| Close channels from receivers | senders may still send and panic | sender/coordinator owns close |
| Sleep to fix a race | changes timing, not synchronization | explicit ownership, mutex, channel, conditional write |
| Ignore Close on response body | connection and descriptor leakage | close every path and bound reading |
| io.ReadAll on errors | untrusted body can exhaust memory | bounded reader and redacted excerpt |
| http.Get everywhere | default client policy is implicit and hard to test | shared configured client and request context |
| DisallowUnknownFields alone | trailing JSON and semantics remain | size limit, second EOF decode, validation |
| Zero means unlimited | omitted configuration becomes unsafe | pointer wire fields and safe validated defaults |
| Compare error text | wrapping changes strings | errors.Is, errors.As, typed classifications |
| Recover every panic | corrupted state may continue | narrow boundary, fail request/process safely |
| os.Exit in helper | defers are skipped | return status to main |
| Rename means durable | visibility and crash durability differ | Sync, platform tests, consumer verification |
| Local mutex for distributed race | other processes do not share memory | authority-side conditional operation |
| New idempotency key on retry | server sees a new operation | stable logical identity |
| Infinite exponential retry | consumes budget and amplifies outage | cap, jitter, deadline, retry budget |
| go test cached green | result may not execute again | -count=1 for evidence runs |
| Race detector green means race-free | only executed schedules are covered | ownership review and stress |
| go.sum means dependency safe | checksum is not review or vulnerability proof | provenance, review, scanning, patch policy |
| Cross-build means deployable | target runtime was not executed | test exact image/host/architecture |
| Public pprof endpoint | profiles expose internals and consume resources | authenticated bounded access and review |
| Recursive cleanup | path drift can delete unrelated data | descriptor guard, allowlist, exact leaf deletion |

A senior engineer does not merely know the safer API. They can explain the failed assumption, demonstrate the relevant evidence, and state the remaining uncertainty.

## Memory card and retrieval

### The nine-word model

> Identify, validate, bound, cancel, classify, reconcile, publish, verify, retire.

- Identify artifact, identity, target, and operation.
- Validate every external input before effects.
- Bound bytes, workers, queues, attempts, and time.
- Cancel downward through every wait.
- Classify errors and outcomes without guessing.
- Reconcile unknown effects at the authority.
- Publish only complete validated state.
- Verify the user's promised operation.
- Retire every owned goroutine and resource.

### Command memory card

~~~text
go version / go env        Who is building for what?
go list -m / -deps         Which module graph?
gofmt -l                   Canonical format?
go test -count=1           Did selected tests execute?
go vet                     Suspicious constructs?
go test -race              Race on executed schedules?
go test -fuzz              Generated boundary failures?
go test -json              Machine-readable test events?
go build -trimpath         Can this target link?
go version -m              What is embedded?
go tool pprof              Where were samples attributed?
~~~

### Four distinctions to recall

1. Goroutine cancellation is not goroutine termination.
2. Client timeout is not remote rollback.
3. Data-race freedom is not business-operation atomicity.
4. Atomic visibility is not crash durability or semantic correctness.

### Retrieval prompts

Without looking back, answer:

1. Why can an interface containing a nil pointer be non-nil?
2. Who should close a results channel fed by multiple workers?
3. What must happen after a timeout following a sent mutation?
4. Why decode a second JSON value and require io.EOF?
5. What does go test -race not prove?
6. Why can cross-compilation pass while a container still fails?
7. Why should main be the only place that calls os.Exit?
8. What files may exact cleanup remove?

Then draw the cancellation diagram and unknown-outcome state path from memory.

## Complete answers

### 1. Why can an interface containing a nil pointer be non-nil?

An interface value contains both a dynamic type and a dynamic value. If a *Client pointer with value nil is assigned to an OperationReader interface, the interface still records dynamic type *Client. Therefore the interface pair is not empty and comparison with nil is false. A method call can then dereference a nil receiver and panic.

Prevent it by returning a literal nil interface when no implementation exists, validating constructor results, and testing absent dependencies.

### 2. Who should close a results channel fed by multiple workers?

A coordinator that knows every worker has finished sending. A common pattern uses a WaitGroup: workers call Done, a coordinator waits, then closes results. Individual workers cannot know whether another worker will send later. The collector normally receives until the channel closes and does not close it.

Closure is a lifecycle signal, not a broadcast cancellation mechanism.

### 3. What must happen after a timeout following a sent mutation?

Mark the effect outcome unknown. Preserve the stable logical operation ID, attempt evidence, deadline phase, and local durable state. Stop blind replay. Query the authoritative service by that operation ID or target/version. If it committed with identical intent, adopt it and record the receipt. If the authority proves no effect under a strong enough guarantee, a bounded retry may become eligible. If lookup fails, unknown remains.

The timeout proves the caller did not receive a timely result; it does not prove the server did nothing.

### 4. Why decode a second JSON value and require io.EOF?

The first Decode can successfully parse one complete value while extra JSON or junk follows. A second decode must return io.EOF to prove no second value remains. This protects a single-document contract. It still does not prove semantic validity, authorization, or absence of trailing whitespace concerns beyond what the decoder accepts.

### 5. What does go test -race not prove?

It does not prove the program has no data races. The detector reports conflicting memory accesses only on instrumented code paths and schedules that execute. It also does not find deadlocks, goroutine leaks, missing results, distributed races, idempotency defects, or semantic atomicity problems.

Combine it with ownership review, stress/failure tests, and production-safe telemetry.

### 6. Why can cross-compilation pass while a container still fails?

Compilation does not execute target behavior. The container may lack CA roots, timezone data, writable directories, the expected user, DNS configuration, architecture compatibility, or signal behavior. Build tags and cgo decisions may also differ. Run the exact artifact inside the exact image and security context, then exercise startup, readiness, shutdown, filesystem, networking, and operation verification.

### 7. Why should main be the only place that calls os.Exit?

os.Exit ends the process immediately and skips deferred calls. Deep helpers may own open files, profile flushes, locks, temporary candidates, telemetry, and worker joins. Returning errors or status to run lets those defers complete. main calls os.Exit only after run has returned.

Even this does not defend against hard kill or power loss, so durable intent and startup reconciliation remain required.

### 8. What files may exact cleanup remove?

Only individually named model, profile, and binary artifacts plus Go cache/temporary trees beneath a root the current invocation can prove is the registered lab root, with expected lesson ID, canonical location, type, identity, and allowlisted contents. It refuses symlinks/reparse points, unexpected files, malformed descriptors, and out-of-scope roots. It removes named leaves by literal path; recursively removes only the verified, reparse-free cache/temporary trees; removes the now-empty root; then verifies absence.

It never uses a wildcard or recursive deletion merely because a pathname contains the lesson name.

### Worked incident A: goroutines climb after cancellation

Signal: goroutines increase from 80 to 12,000 during a failed inventory run and remain above 11,000 ten minutes later.

Evidence path:

1. Freeze new batch admission.
2. Record artifact, config, worker limit, queue cap, active requests, and cancellation timestamps.
3. Capture two bounded goroutine profiles thirty seconds apart through an authorized channel.
4. Group persistent stacks. Suppose most block on results <- result.
5. Inspect collector lifecycle. It returned on the first error and no receiver remains.
6. Inspect worker send path. It cannot observe ctx.Done.
7. Compare accepted jobs with terminal results.
8. Confirm response bodies and child resources close before sends.

Root cause: collector ownership allowed early return while workers retained send responsibility; result delivery lacked cancellation and the coordinator did not join workers.

Recovery: stop admission, cancel the batch, keep a drainer until workers retire if state is trustworthy, restart only after reconciling accepted operations, and verify goroutine and connection counts return toward baseline.

Prevention: one lifecycle owner, bounded queue, cancellation-aware send, WaitGroup join, no early collector exit, leak regression that repeats cancellation, and telemetry for accepted minus terminal work.

### Worked incident B: duplicate resource after HTTP timeout

Signal: tool records deadline exceeded for operation op-417; two resources later appear.

Evidence path:

1. Disable automatic retry.
2. Preserve operation ID, attempt number, client timestamps, trace phase, target, artifact, and sanitized status.
3. Confirm the request may have left the client.
4. Query authoritative operation state and list resources bound to op-417.
5. Inspect whether retry used a new idempotency key.
6. Compare intents and server retention window.
7. Determine whether two client attempts or a server-side defect created duplicates.

Root cause example: controller created a new operation ID on retry after response loss, so the service correctly treated it as a second create.

Recovery: select the intended canonical resource, compensate the duplicate through an authorized reviewed operation, bind the receipt to the stable logical intent, and verify consumer behavior.

Prevention: create operation identity before attempt one, persist it, reconcile unknown outcomes, retain idempotency keys across attempts, document retention/failover semantics, and test a committed response that is deliberately dropped.

### Worked incident C: valid but incomplete JSON

Signal: parser accepts inventory.json, but 37 of 4,000 expected resources are absent.

Evidence path:

1. Preserve the last known-good file and failed candidate.
2. Compare accepted IDs, terminal result IDs, duplicate IDs, cancellation, and worker errors.
3. Verify one collector owns the final slice.
4. Check whether result channel closed before all workers finished.
5. Validate expected count and set equality, not syntax alone.
6. Inspect publish path and consumer readback.

Root cause example: a coordinator closed results when the producer stopped, not when workers finished. The collector ranged to channel close and published the two thousand results already buffered.

Recovery: rebuild from authoritative inputs with a fixed worker count and one terminal result per accepted ID. Validate set equality, write a candidate, sync as required, publish, and verify the consumer.

Prevention: results closes only after workers.Wait, invariant checks before publication, incomplete candidate refusal, previous artifact retention, and cancellation tests.

## Product-company interview

### Question 1: Design a Go CLI that reconciles 100,000 resources

A strong answer begins with contracts, not goroutine count.

Input is bounded and strictly decoded into named types. The tool constructs a canonical intent and stable operation identity. A producer streams validated resource IDs into a bounded queue. A fixed worker group is sized from dependency quota, memory, sockets, and latency evidence. Each worker receives the same overall context budget, performs one bounded request through a reused configured client, and returns one typed terminal observation.

One collector owns aggregation and checkpoint publication. It reconciles accepted versus terminal IDs, classifies committed, no-effect, and unknown outcomes, and persists resumable checkpoints through an authoritative store or conditional writes. Retrying uses stable identities, capped attempts, jitter, remaining deadline, and a global retry budget.

Telemetry exposes queue wait, active workers, result classes, unknowns, retry traffic, and resource use with bounded labels. Shutdown stops admission, cancels work, drains results, joins workers, reconciles ambiguity, publishes a final checkpoint, and exits with a status matching the verified operation.

Tests cover invalid inputs, huge input streams, backpressure, cancellation at every phase, response loss after commit, duplicate delivery, checkpoint corruption, concurrent runners, and restart.

### Question 2: Mutex or channel?

Neither is universally better. Choose from ownership.

Use a mutex when multiple goroutines need short synchronized access to one in-process invariant and the critical section is understandable. Use a channel when transferring ownership, coordinating a pipeline, or bounding work is the clearer model. Use atomics for narrow independent state with well-understood semantics.

If the invariant spans processes, neither a mutex nor a channel works. Use an authority that supports conditional writes, transactions, leases with fencing, or idempotent operations.

I would ask: what data is shared, who owns it, what operations must be atomic together, what blocks, how cancellation works, and how shutdown proves retirement?

### Question 3: How do you make retries safe?

First classify outcome. Validation failure is not transient. A response timeout after sending a mutation is unknown. I create one durable operation ID per logical intent before the first attempt and reuse it. The service must document idempotency scope, retention, regions, and intent conflict behavior.

The client has one overall deadline, capped attempts, exponential backoff with jitter, a retry budget, and bounded concurrency. It honors server rate signals. Unknown outcome triggers lookup before replay. Committed identical intent is adopted. Proven no effect may retry. Conflicting intent stops. Every attempt and reconciliation is observable without leaking secrets.

Finally I test response loss after commit, failover, idempotency expiration, simultaneous callers, and controller-level retries.

### Question 4: How do you prevent goroutine leaks?

Every goroutine has an owner, a termination condition, and a join path. Blocking operations accept context or select on Done. Queue and result sends are bounded and cancellation-aware. Channel closure belongs to the side that knows sends are finished. Coordinators do not return while owned workers remain.

I test by taking a baseline, repeating start/cancel cycles, waiting within a defined retirement bound, comparing goroutine classes, and checking resources such as bodies and timers. A stable count alone is not proof; stacks and terminal-work accounting matter.

### Question 5: What is wrong with http.Client without a timeout?

The zero client has no overall timeout, so a request can wait indefinitely in some phase or body reading. But setting one number is not the whole design. I pass a context with the remaining operation deadline, configure a reused Transport for connection, TLS, header, pool, and idle behavior, bound body reading, close bodies, validate status and schema, and classify response-loss outcomes.

I also review proxies, redirects, TLS roots, credentials, rate limiting, retry composition, and observability.

### Question 6: How do you publish a configuration file safely?

I prove a dedicated parent directory and reject unexpected link/path state. I create a private candidate in the same directory, encode fully, check every write/close error, synchronize the file when required, reopen and validate syntax plus semantic invariants, then perform a platform-tested atomic namespace replacement. On Unix, directory synchronization may be required for crash durability. I verify consumer readback and retain the last known-good state until success.

If multiple processes publish, I add authority-side conditional versioning or a lock with correct scope and fencing. I never assume a local mutex solves it.

### Question 7: What evidence do go test, vet, race, fuzz, and pprof each provide?

go test executes selected assertions. vet applies selected static analyzers. -race detects conflicting accesses on executed instrumented schedules. Fuzzing explores generated inputs for failing invariants during a bounded run. pprof attributes samples or allocations in a measured workload.

They answer different questions. None alone proves correctness, security, production performance, or mastery. I record toolchain, target, revision, command, environment, and limitations for each result.

### Question 8: How do you ship one Go tool across Windows, Linux, and containers?

I isolate portable core logic from platform adapters. Build targets are explicit, cgo is deliberate, and platform-specific source uses build constraints. CI compiles and tests each supported target; runtime tests execute exact artifacts in exact environments. I test paths, permissions/ACLs, reparse/symlink behavior, CA roots, DNS, proxies, signals, service identity, writable locations, and cleanup.

Artifacts carry provenance and digests. Cross-compilation is one gate, not the release claim.

## Independent transfer and rubric

The independent task is ASM-0045. It presents a controller that times out after a mutation may have reached a modeled service. The raw scenario intentionally excludes the authoritative outcome and solution.

Use ASM-0045-response-template.md outside the lab-owned directory. Before observe:

1. declare whether you saw guided or hidden material;
2. capture raw scenario;
3. state the promised operation;
4. separate client facts, local state, and remote unknowns;
5. predict at least three possible outcomes;
6. name the discriminating observation for each;
7. state whether retry is currently allowed.

Your submission must include:

- architecture and state-owner diagram with text alternative;
- chronological evidence table;
- Go design for strict input, interfaces, errors, context, bounded concurrency, HTTP, JSON, receipt, signal, and exit code;
- diagnosis and rejected alternative;
- recovery decision card with authorization, scope, abort, rollback or compensation, and verification;
- test matrix covering race, cancellation, response loss, duplicate delivery, invalid input, tamper, and cleanup;
- Windows evidence and honest Ubuntu limitation;
- production transfer to CI or Kubernetes;
- complete verifier transcript and final state absence;
- incident communication.

Rubric totals 50 points:

| Area | Points | Observable evidence |
|---|---:|---|
| Independence and prediction | 10 | raw input captured before derived views; hypotheses and disconfirming checks |
| Go mechanism accuracy | 10 | correct types, error, context, goroutine, channel, HTTP, JSON, filesystem, signal, and exit reasoning |
| Outcome and recovery safety | 10 | stable identity, unknown-state reconciliation, no blind replay, bounded action |
| Verification depth | 10 | tests and evidence distinguish local harness from remote guarantees |
| Production communication | 10 | clear timeline, owner, impact, remaining risk, and prevention |

Reading the full answer file or model source before submission invalidates an independent attempt. The rubric still requires a reviewer. A score is not generated automatically.

## References and review

The lesson uses eight primary Go sources:

- REF-0113: The Go Programming Language Specification, language version go1.26 at review time.
- REF-0114: Go Modules Reference.
- REF-0115: The Go Memory Model, version dated June 6, 2022.
- REF-0116: context package documentation.
- REF-0117: net/http package documentation.
- REF-0118: Go Data Race Detector documentation.
- REF-0119: Go Fuzzing documentation.
- REF-0120: Go Diagnostics documentation for profiling, tracing, and runtime evidence.

Use these as ownership anchors. The chapter paraphrases concepts and adds operational reasoning; it does not replace checking the documentation for the Go version actually selected.

Review checklist:

- current spec language version and local tested toolchain are stated separately;
- commands with possible cache or artifact writes are bounded to ATLAS_RUN_ROOT;
- no command installs a package, opens a cloud account, or mutates a remote service;
- HTTP examples retain TLS verification and bounded bodies;
- timeout never implies rollback;
- goroutine ownership, channel closing, and joining are explicit;
- race, fuzz, vet, tests, profiles, and cross-builds keep their proof limits;
- Windows and Ubuntu support claims match executed evidence;
- independent scenario and response template remain answer-isolated;
- content remains substantive-draft and awards no mastery.

Next review is due 2027-02-02 or earlier when the minimum supported Go version, HTTP behavior, module/security workflow, lab controller, schema, or target operating systems materially change.
