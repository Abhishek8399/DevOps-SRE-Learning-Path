---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0018",
  "aliases": ["V03-L03", "python-operational-automation"],
  "curriculumIds": ["AUT-002"],
  "slug": "python-operational-automation",
  "route": "/book/engineering/python-operational-automation",
  "order": 3,
  "volume": "03-engineering-delivery",
  "title": "Python operational automation: build tools that fail clearly and recover safely",
  "summary": "Build production-safe Python automation from the process boundary inward: validate inputs, preserve structured data, run subprocesses without a shell, classify exceptions and outcomes, publish local state atomically, reconcile ambiguous remote effects, bound concurrency and retries, protect secrets, test failure paths, and ship observable tools operators can trust.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 480,
  "prerequisiteLessonIds": ["LES-0009", "LES-0017"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-001"],
  "testedEnvironments": [
    {
      "platform": "Ubuntu",
      "version": "24.04 LTS",
      "support": "required",
      "notes": "Commands target the Ubuntu-provided Python 3 family and standard library. The required lab runs as a normal user, installs nothing, opens no socket, makes no network request, and creates only a guarded UID-scoped descriptor and private directory beneath /tmp."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "24.04 LTS",
      "support": "supported",
      "notes": "Run inside the Ubuntu filesystem and process boundary. Interpreter discovery, permissions, signals, path identity, file replacement, and process behavior belong to Linux; do not infer identical Windows or /mnt/c semantics without testing them separately."
    },
    {
      "platform": "CI runners, containers, Kubernetes, private cloud, and public cloud",
      "version": "provider-neutral concepts",
      "support": "concept-only",
      "notes": "Production transfer covers immutable runner images, containers, controller retries, service accounts, secret injection, distributed state, telemetry, and rollout. This lesson creates no remote job, image, cluster, account, or paid resource."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "release-engineer", "security-engineer", "data-platform-engineer"],
  "learningObjectives": [
    "Trace a Python automation request through interpreter selection, module import, input parsing, validation, planning, effects, durable state, result verification, and exit-status translation.",
    "Choose explicit types and schemas for arguments, environment variables, JSON, paths, timestamps, identifiers, and command results instead of letting strings silently cross trust boundaries.",
    "Use pathlib, file descriptors, temporary files, fsync-aware durability reasoning, and os.replace to publish local state without exposing incomplete output or deleting an unverified path.",
    "Run child processes with argument lists, controlled environment and directory, deadlines, captured streams, explicit status handling, and no shell interpretation of untrusted data.",
    "Design exception hierarchies, error messages, exit codes, structured logs, metrics, traces, and redaction so humans and callers can distinguish invalid input, transient dependency failure, unknown outcome, and internal defect.",
    "Apply idempotency, reconciliation, bounded retry, backoff with jitter, concurrency limits, locks, cancellation, cleanup, rollback, and compensation according to the component that owns state.",
    "Test pure logic, executable interfaces, hostile inputs, filesystem failures, timeouts, concurrent runs, interrupted resume, cleanup refusal, logging redaction, packaging, and reproducibility.",
    "Transfer a safe local Python tool to CI, systemd, containers, Kubernetes, and platform APIs while identifying changed identity, filesystem, network, secret, controller, and distributed-coordination boundaries."
  ],
  "productionSignals": [
    "A Python job exits zero although expected records, files, receipts, or user-visible changes are missing.",
    "The tool works in an interactive shell but CI imports a different module, selects another interpreter, lacks the working directory, or receives different environment values.",
    "A timeout is retried and produces duplicate tickets, deployments, notifications, or configuration updates because the first attempt may already have committed.",
    "A subprocess hangs, emits unbounded output, inherits secrets or file descriptors, or receives a single shell string containing untrusted data.",
    "Two cron jobs, runners, operators, or replicas race while reading and replacing the same checkpoint or remote object.",
    "A broad exception handler logs a vague message, returns success, discards the traceback, or retries permanent authentication and validation failures.",
    "A partial JSON file is visible after interruption, a symlink redirects output, or cleanup removes a path the invocation did not create and prove it owns.",
    "Automation latency, memory, API calls, retry traffic, log volume, or cardinality grows faster than useful work as the input set expands."
  ],
  "diagrams": [
    {
      "id": "LES-0018-DIA-001",
      "title": "A trustworthy Python run crosses explicit contracts",
      "direction": "left-to-right",
      "boundaries": ["launcher and interpreter", "imports and configuration", "untrusted input", "typed validation", "pure plan", "bounded effects", "durable receipt", "verified outcome", "exit and telemetry"],
      "evidencePoints": ["sys.executable and version", "module paths and dependency identity", "raw CLI environment JSON", "normalized model", "planned operations", "deadlines and attempt IDs", "operation receipt", "real postcondition", "status logs metrics trace"],
      "textAlternative": "A launcher chooses an interpreter that imports code and configuration; raw input becomes a validated typed model, pure code builds a plan, bounded effect adapters execute it, durable receipts record outcomes, verification checks the real result, and one exit contract plus sanitized telemetry reports the run."
    },
    {
      "id": "LES-0018-DIA-002",
      "title": "Separate functional core from imperative shell",
      "direction": "top-to-bottom",
      "boundaries": ["CLI or event adapter", "parse and validate", "pure decision functions", "effect ports", "filesystem subprocess API implementations", "state owners"],
      "evidencePoints": ["argument contract", "validation errors", "deterministic unit tests", "typed protocol methods", "timeouts statuses payload limits", "files processes remote services"],
      "textAlternative": "Thin adapters parse input and call deterministic decision functions. Effects sit behind narrow interfaces whose implementations own filesystem, process, and API behavior. Tests exercise decisions without pretending a mock proves the external system."
    },
    {
      "id": "LES-0018-DIA-003",
      "title": "Timeout after mutation creates an unknown outcome",
      "direction": "cyclic",
      "boundaries": ["intent persisted", "attempt sent with operation ID", "service may commit", "response deadline expires", "outcome unknown", "query by operation ID", "commit local receipt or retry eligible", "verify user operation"],
      "evidencePoints": ["canonical intent hash", "idempotency key", "authoritative state", "monotonic elapsed time", "unknown outcome class", "reconciliation response", "durable transition", "end-to-end result"],
      "textAlternative": "After a mutation request is sent, a timeout says only that the client did not receive a timely response. The service may have committed. The client must reconcile by durable logical operation identity before recording success or making another eligible attempt."
    },
    {
      "id": "LES-0018-DIA-004",
      "title": "Safe local publication has distinct visibility and durability boundaries",
      "direction": "left-to-right",
      "boundaries": ["approved parent", "private candidate", "complete write loop", "flush and optional file sync", "validate schema and invariants", "same-filesystem replace", "optional directory sync", "reader observes old or new"],
      "evidencePoints": ["canonical parent identity", "mode owner link count", "written byte count", "flush and fsync result", "parsed candidate", "os.replace result", "directory fsync support", "consumer readback"],
      "textAlternative": "A writer creates a private candidate under an approved parent, writes and validates it, optionally synchronizes file data, replaces the final name on the same filesystem, optionally synchronizes the directory for crash durability, and verifies what a reader sees. Atomic visibility and power-loss durability are separate claims."
    }
  ],
  "commands": [
    {
      "id": "LES-0018-CMD-001",
      "question": "Which operating system, identity, Python executable, and version define this run?",
      "risk": "read-only",
      "command": "cat /etc/os-release; id; pwd -P; command -V python3; python3 -c 'import platform,sys; print(\"executable=\"+sys.executable); print(\"version=\"+sys.version.replace(chr(10),\" \")); print(\"platform=\"+platform.platform())'",
      "runFrom": "The exact Ubuntu 24.04 or WSL Ubuntu shell that will run the tool",
      "expectedBranches": [
        {"when": "The expected normal-user identity, path, executable, and supported version appear", "meaning": "The runtime baseline matches the declared environment.", "nextEvidence": "Record import paths and dependency identity before diagnosing application behavior."},
        {"when": "An unexpected interpreter, root identity, directory, or platform appears", "meaning": "A foundational execution assumption is false.", "nextEvidence": "Stop and select the intended environment; do not install or elevate during incident diagnosis."}
      ],
      "proves": "Displayed process and interpreter identity for this invocation.",
      "doesNotProve": "That the intended source or dependencies were imported, inputs are valid, side effects are safe, or production behaves identically."
    },
    {
      "id": "LES-0018-CMD-002",
      "question": "From where would Python import modules?",
      "risk": "read-only",
      "command": "python3 -c 'import json,sys; print(\"prefix=\"+sys.prefix); print(\"path=\"+json.dumps(sys.path)); print(\"json_module=\"+str(json.__file__))'",
      "runFrom": "The same working directory and environment as the failing automation",
      "expectedBranches": [
        {"when": "Paths and module location match the packaged runtime", "meaning": "Import resolution is consistent with the intended environment for this sample.", "nextEvidence": "Inspect the application package location and dependency versions."},
        {"when": "The current directory, user site, or another environment appears first unexpectedly", "meaning": "Module shadowing or interpreter drift is plausible.", "nextEvidence": "Preserve sys.path and inspect exact imported module files without deleting them."}
      ],
      "proves": "The import search path and standard-library json module selected by this process.",
      "doesNotProve": "The origin or integrity of every imported package, reproducible installation, or absence of later path mutation."
    },
    {
      "id": "LES-0018-CMD-003",
      "question": "Does the source parse without importing or executing it?",
      "risk": "read-only",
      "command": "python3 -c 'from pathlib import Path; p=Path(\"tool.py\"); compile(p.read_text(encoding=\"utf-8\"), str(p), \"exec\"); print(\"syntax=valid\")'",
      "runFrom": "A reviewed repository containing tool.py; replace only with the intended local source path",
      "expectedBranches": [
        {"when": "syntax=valid prints", "meaning": "This interpreter parsed the complete selected source.", "nextEvidence": "Run type, lint, unit, and executable behavior checks."},
        {"when": "SyntaxError reports a line", "meaning": "The parser could not construct a program.", "nextEvidence": "Fix the first syntax error and rerun before importing the module."}
      ],
      "proves": "Syntax parsing under this interpreter without executing module top-level code.",
      "doesNotProve": "Import success, type correctness, runtime branch behavior, dependency availability, or safe effects."
    },
    {
      "id": "LES-0018-CMD-004",
      "question": "Does JSON input have the required shape and types?",
      "risk": "read-only",
      "command": "python3 -c 'import json; raw=\"{\\\"service\\\":\\\"billing\\\",\\\"max_attempts\\\":3}\"; obj=json.loads(raw); assert isinstance(obj,dict); assert set(obj)=={\"service\",\"max_attempts\"}; assert isinstance(obj[\"service\"],str) and obj[\"service\"]; assert type(obj[\"max_attempts\"]) is int and 1 <= obj[\"max_attempts\"] <= 5; print(obj)'",
      "runFrom": "Any supported lesson shell; this uses only a synthetic string",
      "expectedBranches": [
        {"when": "The object prints", "meaning": "The synthetic object passed the exact demonstrated boundary checks.", "nextEvidence": "Apply a named schema to real input before planning effects."},
        {"when": "JSONDecodeError, AssertionError, or another explicit validation error occurs", "meaning": "Syntax, shape, type, or range is invalid.", "nextEvidence": "Return a caller-safe validation error without beginning effects."}
      ],
      "proves": "The shown synthetic bytes decode and satisfy the shown assertions.",
      "doesNotProve": "That assertions are a complete production validator, semantic authorization, uniqueness, cross-field invariants, or safety of downstream use."
    },
    {
      "id": "LES-0018-CMD-005",
      "question": "What kind, owner, mode, link count, and resolved identity does a path have?",
      "risk": "read-only",
      "command": "python3 -c 'from pathlib import Path; import os; p=Path(\".\"); s=p.lstat(); print(f\"symlink={p.is_symlink()} uid={s.st_uid} mode={oct(s.st_mode & 0o7777)} links={s.st_nlink} resolved={p.resolve(strict=True)} dev={s.st_dev} inode={s.st_ino}\")'",
      "runFrom": "The exact approved directory; do not substitute an unreviewed mutation target",
      "expectedBranches": [
        {"when": "The path is the expected real directory with expected identity", "meaning": "This snapshot supports the planned path boundary.", "nextEvidence": "Open through a narrow trusted parent and revalidate before commit or cleanup."},
        {"when": "Symlink, owner, mode, device, inode, or resolution is unexpected", "meaning": "The path assumption failed or changed.", "nextEvidence": "Refuse mutation and preserve the object for review."}
      ],
      "proves": "Point-in-time metadata and resolution for the selected pathname.",
      "doesNotProve": "That a later lookup reaches the same inode, that contents are safe, or that pathname validation alone prevents every race."
    },
    {
      "id": "LES-0018-CMD-006",
      "question": "Can Python run a child with exact arguments and captured streams without a shell?",
      "risk": "read-only",
      "command": "python3 -c 'import subprocess; r=subprocess.run([\"/usr/bin/printf\",\"%s\\n\",\"value with spaces; $(not-code)\"], text=True, capture_output=True, check=False, timeout=2); print(f\"returncode={r.returncode} stdout={r.stdout!r} stderr={r.stderr!r}\")'",
      "runFrom": "Any supported lesson shell; it prints one synthetic value",
      "expectedBranches": [
        {"when": "Return code is 0 and the literal metacharacters remain data", "meaning": "The argument-list boundary avoided shell interpretation in this sample.", "nextEvidence": "Set explicit cwd, environment, deadline, output limit, and status policy for the real child."},
        {"when": "The executable is missing, times out, or returns nonzero", "meaning": "Process creation or child outcome failed distinctly.", "nextEvidence": "Classify the exact exception or status instead of converting all failures to success."}
      ],
      "proves": "Exact behavior of one local child invocation with shell=False, which is the default.",
      "doesNotProve": "That the executable is trustworthy, its arguments are authorized, output is bounded, or a return code proves the desired operation."
    },
    {
      "id": "LES-0018-CMD-007",
      "question": "How does a child deadline surface?",
      "risk": "read-only",
      "command": "python3 -c 'import subprocess,sys; code=\"import time; time.sleep(0.2)\";\ntry: subprocess.run([sys.executable,\"-c\",code],check=True,timeout=0.05)\nexcept subprocess.TimeoutExpired as e: print(f\"outcome=timeout timeout_seconds={e.timeout}\")'",
      "runFrom": "Any supported lesson shell; it launches only the same Python interpreter and makes no external call",
      "expectedBranches": [
        {"when": "outcome=timeout prints", "meaning": "The parent deadline expired and subprocess.run handled the direct child.", "nextEvidence": "Decide whether any child or external side effect is unknown before retry."},
        {"when": "The child completes", "meaning": "Scheduling made the synthetic child finish inside the tiny boundary.", "nextEvidence": "Use deterministic injected clocks in tests; do not depend on this timing as a benchmark."}
      ],
      "proves": "TimeoutExpired behavior for one synthetic direct child.",
      "doesNotProve": "That descendants are gone, external work did not commit, the timeout is a safe retry signal, or production timing."
    },
    {
      "id": "LES-0018-CMD-008",
      "question": "Why use monotonic time for elapsed deadlines?",
      "risk": "read-only",
      "command": "python3 -c 'import time; wall=time.time_ns(); start=time.monotonic_ns(); time.sleep(0.01); elapsed=time.monotonic_ns()-start; print(f\"wall_epoch_ns={wall} elapsed_ns={elapsed} elapsed_ms={elapsed/1_000_000:.3f}\")'",
      "runFrom": "Any supported lesson shell",
      "expectedBranches": [
        {"when": "A positive elapsed value near or above ten milliseconds prints", "meaning": "A monotonic clock measured an interval while wall time supplied a timestamp.", "nextEvidence": "Carry a single overall deadline through nested operations."},
        {"when": "Elapsed timing differs substantially", "meaning": "Scheduling and virtualization affected the sample.", "nextEvidence": "Treat this as semantics, not performance evidence."}
      ],
      "proves": "Two clock readings and one measured local sleep interval.",
      "doesNotProve": "Scheduler precision, production latency, clock synchronization between hosts, or deadline correctness in an application."
    },
    {
      "id": "LES-0018-CMD-009",
      "question": "Can a log event stay machine-readable without exposing a secret?",
      "risk": "read-only",
      "command": "python3 -c 'import json; event={\"severity\":\"INFO\",\"event\":\"operation_finished\",\"operation_id\":\"op-demo-17\",\"result\":\"reconciled\",\"attempts\":2,\"duration_ms\":84}; print(json.dumps(event,separators=(\",\",\":\"),sort_keys=True))'",
      "runFrom": "Any supported lesson shell; all values are synthetic",
      "expectedBranches": [
        {"when": "One JSON object prints without credentials or payload contents", "meaning": "The sample uses stable keys and deliberate fields.", "nextEvidence": "Enforce redaction tests and bounded-cardinality conventions in the application."},
        {"when": "An edited event includes tokens, headers, signed URLs, or arbitrary payloads", "meaning": "The telemetry boundary leaks sensitive or unbounded data.", "nextEvidence": "Remove or transform the field before it reaches any logger."}
      ],
      "proves": "Serialization of one synthetic event.",
      "doesNotProve": "Redaction across exceptions and libraries, schema compatibility, log delivery, retention, or safe cardinality."
    },
    {
      "id": "LES-0018-CMD-010",
      "question": "Does the guarded lab environment pass preflight without creating state?",
      "risk": "read-only",
      "command": "bash book/labs/LES-0018-python-automation/lab.sh check",
      "runFrom": "Repository root in Ubuntu 24.04 or WSL Ubuntu as a normal user",
      "expectedBranches": [
        {"when": "environment=ready and state=absent appear", "meaning": "Required local guards passed and no registered state exists.", "nextEvidence": "Run setup, baseline, and the guided case."},
        {"when": "A guard refuses", "meaning": "Identity, /tmp, dependency, source, descriptor, or orphan state is unsafe or unexpected.", "nextEvidence": "Stop; inspect the refusal instead of using sudo or manual deletion."}
      ],
      "proves": "The lab's current preflight and absence checks passed.",
      "doesNotProve": "Python mastery, production safety, or correctness of a learner diagnosis."
    },
    {
      "id": "LES-0018-CMD-011",
      "question": "Can the complete offline lifecycle and refusal suite pass?",
      "risk": "mutating-bounded",
      "command": "bash book/labs/LES-0018-python-automation/verify.sh",
      "runFrom": "Repository root in a clean normal-user Ubuntu 24.04 or supported WSL Ubuntu shell",
      "expectedBranches": [
        {"when": "verification_passed=true and cleanup_proven=true appear", "meaning": "The deterministic guided and independent lifecycles plus tested guards passed.", "nextEvidence": "Review the learner's diagnosis separately; verifier success is not mastery."},
        {"when": "The verifier stops", "meaning": "A lifecycle, invariant, output, answer-isolation, tamper, or cleanup assertion failed.", "nextEvidence": "Preserve output and inspect the first failure before rerunning."}
      ],
      "proves": "Behavior of the checked-in lab and model under the tested local cases.",
      "doesNotProve": "Real API behavior, distributed coordination, all filesystem races, security certification, or learner understanding.",
      "cleanup": "The verifier invokes guarded cleanup and asserts absence of the exact UID-scoped descriptor and registered directory; if interrupted, inspect with lab.sh status and use lab.sh cleanup only after its guards pass."
    },
    {
      "id": "LES-0018-CMD-012",
      "question": "Can a Python source tree be compiled without leaving bytecode residue?",
      "risk": "read-only",
      "command": "PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; files=sorted(Path(\"book/labs/LES-0018-python-automation\").rglob(\"*.py\")); [compile(p.read_text(encoding=\"utf-8\"),str(p),\"exec\") for p in files]; print(f\"compiled={len(files)}\")'",
      "runFrom": "Repository root",
      "expectedBranches": [
        {"when": "The expected file count prints", "meaning": "Every selected source parsed under this interpreter without importing or writing pyc files.", "nextEvidence": "Run behavioral tests and check the tree remains free of generated residue."},
        {"when": "A syntax or decoding exception occurs", "meaning": "At least one selected source is not parseable UTF-8 Python.", "nextEvidence": "Fix the first named source and rerun."}
      ],
      "proves": "Syntax parsing for selected Python sources.",
      "doesNotProve": "Imports, types, branch coverage, runtime effects, packaging, or compatibility with another interpreter."
    }
  ],
  "labs": [
    {
      "id": "LES-0018-LAB-001",
      "title": "Reconcile a modeled Python operation after explicit validation and bounded failure",
      "mode": "guided",
      "environment": "Ubuntu 24.04 or WSL 2 Ubuntu 24.04 with Bash and Python 3.8 or newer",
      "timeMinutes": 75,
      "privilege": "Normal user only; root is refused",
      "network": "None; deterministic standard-library model only",
      "changes": ["One validated UID-scoped descriptor under /tmp", "One private lesson directory under /tmp", "Small allowlisted evidence records inside that directory"],
      "abortConditions": ["Effective UID is zero", "/tmp identity or sticky mode differs", "A descriptor, root, owner, mode, hard-link count, sentinel, manifest, digest, or allowlist check fails", "A required command is absent"],
      "recovery": "Use the model's recover transition only after explaining the failure class; verify the original operation and invoke guarded cleanup. Never delete a discovered path recursively.",
      "cleanupProof": "Cleanup validates and removes exact registered regular files, then the empty exact root and descriptor, and check proves state=absent.",
      "path": "book/labs/LES-0018-python-automation"
    },
    {
      "id": "LES-0018-LAB-002",
      "title": "Independent timeout-after-effect diagnosis with answer-isolated raw inputs",
      "mode": "independent",
      "environment": "A clean normal-user Ubuntu 24.04 or supported WSL Ubuntu shell",
      "timeMinutes": 100,
      "privilege": "Normal user only; no sudo, package install, socket, external process inspection, or cloud credential",
      "network": "None; raw independent inputs and deterministic derived observation views",
      "changes": ["The same guarded lab-owned state", "A neutral case identifier", "Learner notes outside lab state and never read by the verifier"],
      "abortConditions": ["Any guard refuses", "A second case is requested", "An unexpected artifact appears", "The learner has not written a prediction before derived observations"],
      "recovery": "Reconcile the modeled authoritative receipt by operation ID before deciding whether an attempt is eligible; verify the original operation and clean up through the controller.",
      "cleanupProof": "The normal-user verifier covers both cases, invalid transitions, content tampering, symlink and descriptor redirection, orphan refusal, answer isolation, and final absence. Root refusal is separate reviewer-supplied evidence and is not executed by the learner verifier.",
      "path": "book/labs/LES-0018-python-automation"
    }
  ],
  "incidents": [
    {
      "id": "LES-0018-INC-001",
      "signal": "A deployment reconciler times out after 30 seconds, the job controller retries it, and two change records appear even though each run logged only one request.",
      "firstThought": "A client timeout is an unknown outcome after a mutation, not proof of failure. Freeze blind retries and correlate one durable logical operation ID across attempts, service receipts, and actual target state.",
      "safePath": "Preserve code, normalized intent, operation IDs, attempt timing, sanitized request metadata, server receipts, and target state; classify the outcome, query the authoritative owner by operation ID, record the result durably, then retry only if the service proves no effect and the failure is eligible. Verify the real deployment and duplicate count.",
      "trap": "Increasing the timeout or retry count, using a new random key per attempt, trusting a local exception as remote truth, or deleting duplicate records before preserving evidence."
    },
    {
      "id": "LES-0018-INC-002",
      "signal": "An inventory generator exits zero in CI but publishes a truncated JSON file; logs show a caught OSError and the old implementation writes directly to the final path from two overlapping jobs.",
      "firstThought": "Exit status, exception policy, publication atomicity, and concurrency are separate failed boundaries. The final file cannot be trusted until its schema, count, provenance, and writer ownership are verified.",
      "safePath": "Stop publishers, retain the prior known-good artifact, capture file metadata and job IDs, reproduce a write failure offline, reject broad exception swallowing, serialize the commit boundary, write a private same-directory candidate, validate it, replace the name, and verify a consumer readback plus expected record count.",
      "trap": "Repairing the JSON by hand, wrapping the whole program in try/except, retrying both writers, or claiming os.replace provides remote transactionality and power-loss durability by itself."
    }
  ],
  "assessmentIds": ["ASM-0037", "ASM-0038", "ASM-0039"],
  "referenceIds": ["REF-0097", "REF-0098", "REF-0099", "REF-0100", "REF-0101", "REF-0102", "REF-0103", "REF-0104"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The required lab is a deterministic model and does not prove behavior of a real API, package index, CI runner, container, cluster, filesystem under power loss, or production service.",
    "Python implementations, standard-library details, Linux filesystems, process supervisors, and package policies differ; declare and test the supported runtime instead of assuming universal behavior.",
    "Real secret access, network calls, remote mutations, package installation, systemd changes, container builds, and cluster actions require separate authorization and are deliberately not performed.",
    "Capacity examples teach dimensional reasoning; production sizing requires measured input distributions, dependency latency, output sizes, retry rates, concurrency, memory profiles, and safety margins.",
    "Publishing or completing this lesson does not award mastery; independent learner evidence and human review remain required."
  ]
}
---

# Python operational automation: build tools that fail clearly and recover safely

## What you see and first thought

You see `TimeoutError`, `CalledProcessError`, `JSONDecodeError`, `PermissionError`, or simply a green CI job whose promised artifact is wrong. Here is the first habit to keep:

> A Python exception tells you what this process observed. It does not automatically tell you what another process, filesystem, API, or user experienced.

If a deployment request times out, do not translate that into “deployment failed.” The service may have committed and the reply may have been lost. If `subprocess.run` returns zero, do not translate that into “inventory is correct.” The child only reported its own status; it did not prove record count, schema, publication, or consumer behavior. If `os.replace` succeeds, do not translate that into “the workflow is transactional.” It changes one local name atomically under particular filesystem assumptions; it cannot roll back a remote API.

When production is noisy, ask five short questions:

1. **What exact operation was promised?** Name the user or delivery result, not only the function.
2. **Which process and interpreter ran it?** Record executable, version, package, identity, directory, namespace, and code revision.
3. **What state owner was crossed?** Python memory, local filesystem, child process, database, queue, API, or controller.
4. **Is the outcome known, rejected, committed, or unknown?** A timeout frequently means unknown.
5. **What evidence verifies the real result?** A receipt, state query, consumer readback, record reconciliation, or user transaction.

Do not begin with a restart, a broad retry, `sudo`, package installation, manual state deletion, or `except Exception: pass`. Preserve evidence and reduce the blast radius first.

This chapter treats Python as an operational toolchain. Syntax matters, but the enduring skill is turning ambiguous external behavior into explicit types, state transitions, evidence, and safe recovery.

**Memory sentence:** Python can make control flow readable; you must still make state ownership and outcomes explicit.

## Terms before commands

### Interpreter, implementation, executable, and environment

The **Python language** defines syntax and semantics. An **implementation** executes that language; CPython is the common implementation on Ubuntu. An **interpreter executable** is the actual file launched, visible as `sys.executable`. `python3` is a command resolved through `PATH`; it is not a promise that every shell, CI image, or virtual environment selects the same executable.

A **virtual environment** is an isolated prefix containing an interpreter link or copy, installed packages, and activation helpers. Activation mostly changes shell environment such as `PATH`; the durable truth is the executable being run. A tool installed in one environment can import different versions from another. Always record the executable, `sys.version`, package location, and working directory when parity matters.

The **standard library** ships with Python. A **distribution package** is an installable artifact; an **import package** is a module namespace. Their names can differ. A **module** is an importable unit, often one `.py` file. Import executes module top-level code once per interpreter cache entry, so importing is not guaranteed to be side-effect free.

### Object, type, value, identity, and mutability

Python variables are names bound to **objects**. Each object has a **type**, **value**, and **identity**. Assignment binds a name; it does not copy an object automatically. A list is **mutable**: its contents can change in place. A tuple, string, integer, and frozen dataclass are examples of immutable values, although an immutable container may reference mutable objects.

This matters operationally:

```python
defaults = {"labels": []}
request = defaults
request["labels"].append("urgent")
```

Both names point to the same dictionary. A later caller sees changed defaults. Prefer immutable configuration models, explicit copying when ownership changes, and functions whose mutation contract is obvious.

**Equality** asks whether values compare equal; **identity** asks whether two names reference the same object. Use `is None`, because `None` is a singleton sentinel. Do not use `is` for ordinary string or integer equality.

### None, truthiness, and missing values

`None` usually represents absence. **Truthiness** converts a value to Boolean context: empty strings, empty containers, numeric zero, `False`, and `None` are false-like. They are not equivalent business states.

```python
if not replicas:
    ...
```

This collapses `None`, `0`, `False`, and sometimes an empty value into one branch. If zero is valid but missing is not, say `if replicas is None`. At input boundaries, distinguish missing key, explicit null, empty string, zero, and invalid type.

Also remember that `bool` is a subclass of `int` in Python. `isinstance(True, int)` is true. For an exact integer field where booleans are invalid, use `type(value) is int` or a schema library with the desired rule.

### Iterable, iterator, generator, and sequence

An **iterable** can produce an iterator. An **iterator** yields one item at a time and is consumed. A **generator** is an iterator commonly created by a generator function or expression. A **sequence** has ordered indexed elements and normally supports repeated traversal.

The production trap is consuming an iterator while counting or logging it and then passing an empty iterator to the real operation:

```python
items = load_items()
logger.info("count=%s", sum(1 for _ in items))
for item in items:                 # nothing remains
    process(item)
```

Choose streaming deliberately. If the set must be counted, validated, retried, and traversed repeatedly, materialize it within a measured memory bound or design a durable cursor and per-record state.

### Function, method, pure function, and side effect

A **function** is callable code. A **method** is a function accessed through an object or class. A **pure function** returns a result determined only by explicit inputs and changes no external state. A **side effect** changes or observes state outside the returned value: filesystem I/O, environment access, clock reads, random values, logging, subprocesses, network calls, or mutation of shared objects.

The **functional core, imperative shell** pattern keeps parsing adapters and effects thin while decision logic stays pure. It is not about avoiding objects. It is about making business decisions deterministic and effects reviewable.

### Exception, traceback, cause, context, and exit status

An **exception** is an object raised when normal control flow cannot continue. A **traceback** records stack frames through which it propagated. An exception's **cause** can be made explicit with `raise DomainError(...) from exc`. Python otherwise records implicit context when one exception arises while handling another.

Catch only where you can add context, translate an interface, retry a classified operation, clean up owned resources, or terminate with a documented result. A broad catch at the executable boundary can log an unexpected defect and return an internal-error status, but it should preserve the traceback and must not report success.

An **exit status** is the process result observed by its parent. Conventionally zero means the program fulfilled its contract. Nonzero categories should be documented: for example 2 for CLI usage, 3 for invalid domain input, 4 for dependency unavailable, 5 for unknown mutation outcome, and 70 for unexpected internal failure. Avoid exposing dozens of unstable exception classes as exit codes.

### Context manager and resource lifetime

A **context manager** implements entry and exit around a block, normally used with `with`. Files, locks, temporary directories, database transactions, and telemetry spans use this pattern because release happens even when an exception leaves the block.

`with` improves lifetime management; it does not guarantee cleanup after SIGKILL, interpreter crash, kernel failure, or power loss. Startup reconciliation still needs to recognize durable intent and validated leftover state.

### Path, directory entry, descriptor, symlink, and race

A **path** is a name, not an object identity. A directory lookup maps a name to an inode-like filesystem object. A symbolic link redirects lookup. A **file descriptor** is a process-local handle to an opened object. A **time-of-check-to-time-of-use race** occurs when a program validates a pathname and later reopens it after another actor changes the mapping.

`pathlib.Path` makes path composition readable but does not make an untrusted path authorized. Avoid `base / user_value` followed only by a string-prefix check. Normalize the intended grammar, reject absolute paths and `..` components when those are forbidden, resolve against a proven root when appropriate, use no-follow and directory-descriptor facilities for high-risk boundaries, and revalidate identity at commit and cleanup.

### Serialization, schema, encoding, and canonical form

**Serialization** turns data into bytes or text. JSON distinguishes objects, arrays, strings, numbers, booleans, and null, but it does not supply your business schema. A **schema** defines required keys, allowed keys, types, ranges, formats, and cross-field invariants.

An **encoding** maps text to bytes; UTF-8 is a sensible explicit default. Never rely on a machine's locale for operational state. A **canonical form** is one deterministic representation used for hashing, comparison, or operation identity. JSON object key order and insignificant whitespace should not accidentally create a new idempotency key. Normalize first, then serialize with a documented rule.

### Subprocess, argument vector, shell, environment, and working directory

A **subprocess** is a child process. Its **argument vector** is a sequence of strings. With `subprocess.run([executable, arg1, arg2])`, Python invokes the executable without a shell by default. Metacharacters such as `;`, `$()`, `*`, and spaces remain ordinary argument data.

With `shell=True`, a shell interprets a command string. If untrusted data reaches that string, command injection becomes possible. Even trusted strings inherit quoting, shell dialect, environment, and error-propagation complexity. Prefer an argument list and an explicit executable.

The child inherits environment, current directory, open descriptors under defined rules, resource limits, identity, and namespace. Pass a minimal deliberate `env`, an explicit `cwd` when needed, `close_fds` behavior appropriate to the platform, a timeout or higher-level deadline, and an output policy. `capture_output=True` buffers output in memory; it is unsuitable for unbounded output.

### Deadline, timeout, retry, backoff, jitter, and retry budget

A **deadline** is the latest time an entire operation may use. A **timeout** bounds one wait or attempt. Nesting three ten-second attempts inside a twenty-second caller deadline without carrying remaining time violates the outer contract.

A **retry** is another attempt. **Backoff** spaces attempts, often exponentially. **Jitter** randomizes delay so many clients do not synchronize. A **retry budget** caps extra traffic or time. None of these make an unsafe mutation retryable.

Use wall-clock time for human timestamps and a monotonic clock for elapsed duration. A wall clock can jump due to synchronization or manual change; monotonic time is designed not to go backward within one system run.

### Idempotency, operation identity, receipt, and reconciliation

An operation is **idempotent** when repeating the same logical request creates no additional effect beyond the first successful application. An **idempotency key** identifies the logical operation across attempts. It must remain stable when retrying the same intent; a fresh random key per attempt defeats deduplication.

A **receipt** is durable evidence that an owner accepted or completed an operation. **Reconciliation** compares desired intent with authoritative actual state. When a mutation times out, query by operation ID. Only after the owner proves no effect and the failure class is retryable should another attempt begin.

### Atomicity, visibility, durability, transaction, cleanup, rollback, and compensation

**Atomic visibility** means observers see an operation as indivisible within a defined boundary. A same-filesystem `os.replace(candidate, final)` can make a file name point to old or new content without exposing a partially copied final file. It does not automatically guarantee bytes survive sudden power loss. Crash durability may require flushing Python buffers, `os.fsync` on the file, replacement, and `os.fsync` on the containing directory where supported, plus knowledge of filesystem and storage behavior.

A **transaction** has defined commit and abort behavior across participating state. A local rename is not a transaction with an API call. **Cleanup** removes temporary resources. **Rollback** restores a prior committed version. **Compensation** applies a new operation that semantically offsets an irreversible or distributed effect. Use the correct word because the recovery guarantee changes.

### Concurrency, parallelism, thread, process, task, lock, and race

**Concurrency** means multiple operations make progress over overlapping time. **Parallelism** means work literally executes at the same time. Threads share a Python process and objects. Processes normally have separate memory. Async tasks cooperate on an event loop and yield at awaits.

CPython's Global Interpreter Lock does not make compound application operations atomic and does not coordinate files, child processes, other interpreters, hosts, or services. A lock protects only actors that share and honor it. Keep critical sections small, attach ownership to state, reread state after acquiring a lock, define contention behavior, and use the remote state owner's conditional update or idempotency facility for distributed coordination.

### Type hints, static analysis, tests, and mocks

A **type hint** documents intended types for humans and tools; CPython normally does not enforce it at runtime. Validate external input at runtime. Static analysis can find inconsistent calls and impossible branches before execution, but it does not prove external behavior.

A **unit test** isolates a small behavior. An **integration test** crosses real component boundaries. A **black-box CLI test** runs the executable and asserts arguments, streams, status, files, and effects. A **mock** replaces a collaborator with controlled behavior. Mocks prove how code reacts to the simulated contract, not that the real API or subprocess follows it. Contract tests and limited integration tests protect that gap.

**Memory sentence:** validate bytes into types, decide with pure code, execute through bounded adapters, and verify at the state owner.

## Architecture map

### Diagram 1: the executable contract

```text
launcher
  |  executable, argv, cwd, env, uid, namespace
  v
Python entry point
  |  parse -> validate -> normalize
  v
typed request ------> pure planner ------> list of intended operations
                                              |
                                              v
                                      bounded effect adapters
                                   / filesystem / process / API \
                                  v                            v
                            durable receipt              sanitized evidence
                                  |                            |
                                  +------> verify outcome <----+
                                                |
                                                v
                                    stdout / stderr / exit code
```

Text alternative: the launcher supplies interpreter and process context. The entry point translates raw inputs into a typed request. Pure logic plans operations. Narrow adapters execute effects and persist receipts. Verification checks the owning system, while sanitized telemetry and the exit code communicate the result.

### Diagram 2: functional core and imperative shell

```text
              PURE, CHEAP TO TEST
      request -> validate_model -> plan -> classify -> decision
          ^                                           |
          |                                           v
CLI -----+                                     Effect interface
event ---+                                     /      |      \
                                                file  process  API
                                                  IMPERATIVE BOUNDARY
```

Put clocks, random IDs, environment access, filesystem, subprocesses, and clients behind explicit parameters or small interfaces. The planner can then accept a fixed `now`, current state, and requested intent and return a decision. Tests cover the state machine without sleeping or sending traffic.

Do not make every line an abstract class. One `Protocol` or callable boundary per genuinely variable effect is enough. Excess indirection hides the path just as surely as one giant function does.

### Diagram 3: outcome state machine

```text
VALIDATED
    |
    v
INTENT_RECORDED -- invalid/permanent --> REJECTED
    |
    v
ATTEMPTING ----- definite no effect ---> RETRY_ELIGIBLE --budget--> ATTEMPTING
    |                                      |
    | response lost / timeout              +--no budget--> FAILED
    v
UNKNOWN -------- query operation ID ------> COMMITTED ------> VERIFIED
    |
    +------ owner proves absent ----------> RETRY_ELIGIBLE
                                               |
                                               +-- no budget --> FAILED
```

The key branch is `UNKNOWN`. Treating it as `FAILED` is how safe-looking retry loops create duplicate effects.

### Diagram 4: publication boundary

```text
[approved directory]
      |
      +-- final.json        known-good reader target
      |
      +-- .candidate-XYZ    mode 0600, invocation-owned
              |
              +-- write all bytes
              +-- flush / optional fsync
              +-- parse and validate
              +-- os.replace(candidate, final)
              +-- optional directory fsync
                         |
                         v
                  consumer readback
```

If candidate and final are on different filesystems, replacement can fail or a higher-level move can degrade into copy and delete. Create the candidate in the same trusted directory. Keep the previous artifact until the new candidate is validated.

**Architecture rule:** every arrow crossing a state owner needs an input contract, deadline, outcome classification, evidence, and recovery story.

## Request or state path

Follow one request end to end. Imagine `reconcile --manifest release.json --environment production`.

### 1. Launch contract

The parent chooses executable, arguments, working directory, environment, UID, groups, resource limits, namespace, open descriptors, and signal behavior. A correct program can fail under the wrong launcher. Make the entry point explicit and support `--version` so evidence includes code identity.

Avoid relying on the current directory for package imports or data files. Package resources belong with the package; operator-supplied files should be explicit arguments. Resolve relative paths against a documented base and print the normalized non-secret configuration in a dry-run or diagnostic view.

### 2. Parse without effects

`argparse` can enforce command grammar, required options, enums, and basic types. Parsing should not call a remote API or mutate state. Separate `parse_args(argv) -> RawOptions` from `validate(raw) -> Request` so validation can produce domain-specific messages and tests can call it directly.

Treat environment as untrusted ambient input. Read all required names once near startup, validate them, and pass a configuration object downward. Hidden `os.environ` reads inside helpers make tests and incident reconstruction fragile.

### 3. Decode and validate structured data

Open files with explicit encoding and a size policy. A tiny configuration should not accept a 20 GB file into memory. JSON parsing proves only syntax. Then enforce:

- root type;
- required and allowed keys;
- exact field types;
- numeric and length bounds;
- enum values;
- identifier format;
- uniqueness;
- cross-field invariants;
- authorization to act on the named environment.

Produce a normalized immutable request. Keep the raw source digest for provenance but do not log secret content.

### 4. Read current state and build a plan

Read current state from the owner closest to truth. A stale local cache may be useful but is not authoritative. Pure code compares desired and actual models and returns a plan with explicit no-op, create, update, delete, and conflict decisions.

Plans should carry reasons and preconditions, not executable source strings. A change entry might include operation ID, resource identity, expected version, desired digest, and risk. A dry-run renders this plan but does not prove the later state remains unchanged.

### 5. Persist intent before risky effects

For resumable mutation, persist a durable intent record before sending the request. Include a stable operation ID, normalized intent digest, target, code version, creation time, state-machine version, and current phase. Do not include credentials.

The write itself must be safe: create a private candidate, write complete content, validate, publish locally, and verify. If a crash occurs after remote commit but before local receipt, startup sees an incomplete intent and reconciles it rather than guessing.

### 6. Execute one bounded attempt

An effect adapter accepts explicit intent and remaining deadline. It performs one attempt, not an invisible retry loop. It returns a classified result such as accepted, rejected, transient-no-effect, unknown, or conflict. Preserve status code, safe response identifier, duration, and attempt number.

For subprocesses, pass an argument list. Decide how stdout and stderr are consumed. Bound output or stream it to a private file. On timeout, understand process-tree behavior: killing the direct child may not terminate descendants or undo their effects.

### 7. Reconcile uncertainty

If the response is lost after a mutation, transition to unknown. Query the authoritative service by operation key or inspect a durable receipt. If committed, record the receipt. If definitively absent and the error is eligible, another attempt can reuse the same key. If the owner cannot answer, stop and escalate rather than multiplying uncertainty.

### 8. Commit local state

Once the outcome is known, write a candidate checkpoint, validate it against the state-machine schema, and replace the previous checkpoint. An unexpected failure should leave the previous known-good record available. Never write `complete=true` before verifying required item counts and receipt uniqueness.

### 9. Verify the promised operation

Verification is not `returncode == 0`. Re-read authoritative state, read the published artifact as a consumer would, or execute the safe user journey. Compare intended IDs with observed terminal receipts. Verify no duplicates and no missing items. Use a meaningful observation window for asynchronous systems.

### 10. Translate the result

Return machine output on stdout only when promised. Put diagnostics on stderr. Map expected result categories to documented stable exit codes. Unexpected defects should retain a traceback in protected logs, emit a sanitized correlation ID to the caller, and exit nonzero.

**Memory sentence:** parse, validate, plan, persist intent, attempt once, reconcile, publish, verify, report.

## Failure zoom

### Failure 1: the interpreter is not the one you tested

Symptom: local execution imports package version 4, CI imports version 3, or `ModuleNotFoundError` appears only under systemd.

Mechanism: the launcher selected a different `sys.executable`, `sys.path`, working directory, user site, or environment. A local file named like a standard or third-party module may shadow the intended module.

Evidence: record `sys.executable`, `sys.version`, `sys.prefix`, `sys.path`, `module.__file__`, installed distribution metadata, launcher definition, and code revision. Do not “fix” it by appending arbitrary paths in code. Package the tool and make the launcher select the declared environment.

### Failure 2: a string pretends to be a typed value

Symptom: `"false"` enables a feature because non-empty strings are truthy; `"3" * 2` becomes `"33"`; `True` passes an integer check; a missing key becomes `None` and fails much later.

Mechanism: parsing and validation were collapsed. Environment variables and CLI tokens begin as strings. JSON has types but still requires schema validation.

Evidence: preserve raw field presence and type without logging secrets. Reject unexpected keys and invalid types at the boundary. Return a path-aware message such as `items[4].max_attempts: expected integer 1..5, got string`, not a later `TypeError` from unrelated code.

### Failure 3: an iterator disappears

Symptom: a count log says 240 items, but the loop processes zero.

Mechanism: the generator was consumed while counting. Iterators are stateful streams, not repeatable collections.

Evidence: inspect type and ownership, then reproduce with a synthetic generator. Decide whether one-pass streaming or bounded materialization matches the contract. Do not duplicate an unbounded stream merely for a debug log.

### Failure 4: exception swallowed, job green

```python
try:
    publish(report)
except Exception:
    logger.warning("publish failed")
return 0
```

The handler destroys type, traceback, cause, and caller signal. It may also continue with invalid state. Catch the narrow errors you expect. Translate them into domain outcomes with context. Let unexpected defects propagate to one top-level boundary that logs `logger.exception` and exits nonzero.

Never log a secret merely to gain context. Record operation ID, stage, target identity, attempt, duration, exception type, and a sanitized stable message.

### Failure 5: unsafe subprocess boundary

```python
subprocess.run(f"deploy --name {name}", shell=True)
```

If `name` contains shell syntax, data becomes code. Replacing it with escaping is error-prone and shell-specific. Use:

```python
subprocess.run(
    ["/usr/local/bin/deploy", "--name", name],
    shell=False,
    check=False,
    timeout=remaining_seconds,
    cwd=approved_directory,
    env=minimal_environment,
)
```

This prevents shell interpretation; it does not authorize `name`, trust the executable, bound its descendants, or prove the deployment.

### Failure 6: timeout becomes duplicate work

Timeline:

```text
10:00:00.000 client stores op-417 intent
10:00:00.020 client sends op-417
10:00:29.900 service commits op-417
10:00:30.000 client deadline expires before response
10:00:31.000 retry creates op-918 and sends same effect
10:00:32.000 service commits op-918
```

The defect is not only “timeout too small.” The retry changed logical identity and never reconciled. Preserve one operation ID, query the owner after uncertainty, and use a service-side idempotency contract whose retention window exceeds the retry and resume window.

### Failure 7: partial or redirected local state

Writing directly to `final.json` exposes truncation and partial bytes. Following a symlink can redirect an authorized name to an unauthorized target. A cleanup routine that trusts a mutable string can remove another run's state.

Use an approved real parent, private candidates, restrictive permissions, exact file-type and ownership checks, validation before replacement, and exact cleanup. Keep state roots immutable after creation. For high-risk privileged writers, use descriptor-relative and no-follow APIs; this normal-user lesson models the reasoning but is not a privileged filesystem hardening guide.

### Failure 8: concurrency loses updates

Two workers read version 7, independently compute version 8, and each writes it. The later writer silently erases the other update. CPython's interpreter lock does not make read-modify-write across files or services safe.

Use conditional writes with expected version, database transactions, leases, or the state owner's compare-and-swap facility. A local advisory lock helps cooperating processes on one compatible filesystem; it does not coordinate two Kubernetes nodes or an API service.

### Failure 9: retries overload the dependency

Suppose 100 workers each make one request per second. A policy of four total attempts can create up to 400 attempts per second during failure before backoff. If every layer retries—client, library, sidecar, ingress, and server—the multiplication is worse.

Measure attempt rate separately from logical operation rate. Set one retry owner, cap attempts and elapsed time, respect server retry guidance, add jitter, limit concurrency, and shed or queue work before the dependency collapses.

**Failure rule:** name the mechanism, the state owner, the exact evidence, and the proof limit before naming a fix.

## Internals and state ownership

### Import and startup state

Python initializes an interpreter, constructs `sys.path`, imports the entry module, and executes top-level statements. Top-level network clients, environment reads, threads, or file writes make import surprising and tests fragile. Prefer definitions at import time and perform effects under an explicit `main(argv)`.

```python
def main(argv: list[str] | None = None) -> int:
    options = parse_args(argv)
    return run(options)

if __name__ == "__main__":
    raise SystemExit(main())
```

Returning an integer makes the executable policy testable. `SystemExit` translates it at the boundary.

### Memory ownership and copying

Python passes object references. Mutable default arguments persist between calls:

```python
def collect(item, bucket=[]):     # unsafe shared object
    bucket.append(item)
    return bucket
```

Use `None` and create a fresh list, or accept an explicit collection. Dataclasses can express state models; `frozen=True` prevents attribute assignment but does not recursively freeze referenced objects. Treat ownership as a design decision, not a language default.

### Exception ownership

Raise at the layer that detects violation. Translate at a boundary that can add domain meaning:

```python
try:
    raw = path.read_text(encoding="utf-8")
except OSError as exc:
    raise ConfigurationUnavailable(path.name) from exc
```

The domain exception tells callers what failed; chaining preserves the system cause for protected diagnostics. Do not catch and re-raise a fresh vague error without `from`, and do not expose full local paths or secret values to an untrusted caller.

### Filesystem ownership

The filesystem owns persistent bytes and name mappings. Python buffering may hold bytes before the kernel sees them. The kernel may acknowledge writes before stable storage persists them. Filesystem replacement guarantees vary by mount, network filesystem, and crash model.

Define the guarantee you need:

- process-visible complete file;
- atomic name visibility to concurrent readers;
- persistence after process crash;
- persistence after OS crash or power loss;
- replication across hosts;
- consistency with a remote effect.

Each stronger claim needs more than `write_text`.

### Child-process ownership

After process creation, the child owns its code and effects. Python observes creation failure, output, return status, signal termination, and timeout. A negative return code on POSIX indicates signal termination. `check=True` converts nonzero into `CalledProcessError`; it does not make zero semantically correct.

Define output limits. `capture_output=True` accumulates streams in memory. For large output, stream to a controlled file, consume incrementally without deadlock, or use a tool-supported output path. Avoid logging complete stderr if it can contain tokens or payloads.

### Remote-service ownership

An API owns whether a request was accepted, deduplicated, committed, and retained. Client memory and local checkpoint are observers. Use the service's documented idempotency, conditional request, version, transaction, or operation-status features. If none exists for a high-impact mutation, your tool cannot manufacture exactly-once semantics with a retry loop.

### Scheduler and controller ownership

Cron, CI, systemd, Kubernetes Jobs, and operators can restart or duplicate work. Your program's own retry policy composes with theirs. Document exit meanings and controller policy together. An exit 5 for unknown outcome should normally route to reconciliation, not a blind generic restart.

### Thread, process, and async ownership

Threads share objects and require synchronization around invariants. Processes have separate memory and need IPC or shared external state. Async tasks share one thread by default but can interleave whenever they await; an async lock protects only tasks using that lock in that event loop.

Concurrency limit belongs at the scarce boundary: API requests, child processes, memory-heavy transformations, or writes. A pool size is not a capacity proof. Measure arrival rate, service time, queue time, memory per task, failure amplification, and downstream quotas.

### Secrets and logs

A secret provider owns credential lifecycle. Retrieve as late as possible, keep the scope narrow, and avoid command arguments, URLs, exception strings, `repr` of configuration objects, process environment dumps, traces, and debug logs. Redaction must happen before serialization and before third-party handlers see the record.

Use identifiers for correlation, not secret values. If exposure is suspected, preserve non-secret evidence and rotate through the approved owner; deleting logs is not a substitute for rotation and incident handling.

**Ownership rule:** local code may coordinate state, but only the state owner can authoritatively answer what it committed.

## Evidence table

| Evidence | What it proves | What it cannot prove | Next safe question |
|---|---|---|---|
| `sys.executable`, version, prefix | Interpreter identity for one process | Every runner used it or packages are correct | Which module files and distributions were imported? |
| `sys.path` and `module.__file__` | Import search order and selected file | Artifact integrity or future import behavior | Does packaging pin and verify the intended build? |
| Raw input digest and validation error | Exact bytes were observed and rejected by a rule | Caller intent or authorization | Which field and invariant failed before effects? |
| Parsed typed request | Boundary checks produced this model | Remote target exists or action is permitted | What precondition and policy authorize the plan? |
| Dry-run plan | Planner decision for sampled state | State will remain unchanged or effect will succeed | How is version checked at commit time? |
| Child return code 0 | Child reported success | Output is complete or user outcome succeeded | What semantic postcondition must be checked? |
| `TimeoutExpired` | Parent did not observe completion in time | Child descendants stopped or remote effect failed | Is outcome unknown, and how can it be reconciled? |
| HTTP 500 or analogous dependency error | One request received a server failure response | Mutation definitely did not commit | Does endpoint contract provide operation status? |
| Idempotency receipt | Owner associates operation ID with a result | User journey works or receipt retention is sufficient | Verify target state and retention window |
| `os.replace` returned | Local name replacement call succeeded | Power-loss durability or remote atomicity | Can a consumer parse the new file and is directory sync required? |
| File mode, UID, link count, resolution | Point-in-time path metadata | No later name race | Can the operation use a trusted descriptor and revalidate? |
| Lock acquired | Cooperating contenders sharing that lock serialized | Other hosts or noncooperating writers are excluded | Which actors and filesystem semantics share it? |
| Exception traceback | Call path and failure context in this process | Root cause in another service | Which first bad input or external fact made this frame possible? |
| Unit test pass | Pure behavior matches tested cases | Real adapters follow mocks | Which contract and integration test closes the gap? |
| End-to-end verification | Sampled promised operation succeeded | Future reliability or every tenant is correct | What window, count, and guardrail are sufficient? |

Evidence has a timestamp, scope, identity, unit, and collection method. Without them, `duration=30` could mean seconds, milliseconds, a client timeout, or an old dashboard value.

Classify statements explicitly:

- **observation:** `attempt op-417 timed out at monotonic 30.0 s`;
- **documented fact:** the endpoint retains an idempotency result for 24 hours;
- **calculation:** four attempts times 250 workers gives at most 1,000 attempt slots before pacing;
- **inference:** retry amplification probably raised dependency queue time;
- **hypothesis:** the first attempt committed before its response was lost;
- **unknown:** whether the target owner retained a receipt after its documented window.

## Command decoders

### Decoder 1: establish the runtime

```bash
cat /etc/os-release
id
pwd -P
command -V python3
python3 -c 'import platform,sys; print(sys.executable); print(sys.version); print(platform.platform())'
```

`command -V` shows how the shell resolves `python3`. `sys.executable` shows what the running interpreter believes its executable is. `sys.version` includes implementation build information. `pwd -P` resolves the shell's physical directory. Read them together: a virtual-environment command, system Python path, and unexpected directory point to launcher drift before application logic.

This is read-only. It does not prove package versions or production parity.

### Decoder 2: inspect import resolution

```bash
python3 -c 'import json,sys; print(sys.prefix); print(sys.path); print(json.__file__)'
```

`sys.prefix` identifies the active installation prefix. `sys.path[0]` often reflects the script directory or current context and can enable shadowing. `json.__file__` proves the selected module file for this process. Substitute an application module only when importing it is known to be side-effect free; otherwise use distribution metadata or inspect packaging without import.

### Decoder 3: compile without execution

`compile(source, filename, "exec")` invokes the parser and compiler on source text but does not execute the resulting code object. The `filename` becomes diagnostic context. This avoids `py_compile` bytecode residue and avoids import-time effects. It proves syntax only.

### Decoder 4: parse and validate JSON

`json.loads` converts JSON syntax to Python objects. `assert isinstance(obj, dict)` checks the root, but `assert` can be disabled with optimization and produces poor external errors. The one-liner is a learning microscope. Production code should raise a stable validation error with field path, expected rule, safe observed type, and no secret value.

Check `type(max_attempts) is int` when Boolean must be rejected. Limit input bytes before decoding. Reject duplicate or unexpected keys when ambiguity is dangerous. Validate cross-field rules after individual fields.

### Decoder 5: inspect a path

`lstat` examines the directory entry without following its final symlink. `is_symlink` classifies it. `st_uid`, permission bits, hard-link count, device, and inode give point-in-time identity. `resolve(strict=True)` follows links and requires existence. No sequence of pathname checks eliminates all races; high-risk code should operate relative to an already opened trusted directory where the OS APIs allow.

### Decoder 6: call a subprocess safely

The first list element is the executable, followed by exact arguments. No shell interprets `;` or `$()` when `shell=False`. `text=True` decodes streams using a text mode; production should specify encoding and error policy. `capture_output=True` uses pipes and stores complete output, so enforce a bound or stream large results. `check=False` makes status classification explicit.

### Decoder 7: understand timeout

`timeout=0.05` bounds the wait in `subprocess.run`. `TimeoutExpired` reports the configured limit and possibly captured partial output. Python will terminate the direct child and wait in this API, but external effects may remain and descendants can require explicit process-group design. A timeout is never automatic permission to repeat a mutation.

### Decoder 8: use the right clock

`time.time_ns()` is wall time since an epoch and is useful for timestamps. `time.monotonic_ns()` has an unspecified origin but does not go backward during the process environment, making differences suitable for elapsed deadlines. Carry `deadline = monotonic() + budget`; nested functions compute remaining time rather than each receiving a fresh full timeout.

### Decoder 9: structure logs

The example emits one JSON object with stable low-cardinality keys. `operation_id` correlates attempts. `result` is a bounded enum. `duration_ms` includes a unit. Do not use tenant, full URL, exception text, or input payload as a metric label. Logs can carry higher-cardinality correlation IDs under controlled retention; metrics generally cannot.

### Decoder 10: lab preflight

`lab.sh check` verifies a non-root user, required commands, Python version, `/tmp` identity, fixture syntax, fixture digest availability, and registered state. It creates nothing. If it detects an unregistered matching directory, it refuses because the script cannot prove ownership.

### Decoder 11: full verifier

`verify.sh` creates bounded state, drives both deterministic cases, checks invalid transitions and tampering refusal, verifies answer isolation, invokes guarded cleanup, and proves absence. Its exit trap restores verifier-created tamper states after INT or TERM when guarded identities still match. Treat its first failed assertion as evidence. If interruption leaves valid registered state, resume with `lab.sh cleanup`; do not delete a path manually.

### Decoder 12: residue-free source compilation

`Path.rglob("*.py")` selects local sources. `read_text(encoding="utf-8")` makes decoding explicit. `compile` parses without import. `PYTHONDONTWRITEBYTECODE=1` is defensive, although this exact command does not import project modules. Afterward, scan for `__pycache__`, `.pyc`, test caches, coverage data, and generated artifacts before committing.

**Decoder habit:** for every command, state where it runs, whether it changes anything, what each field means, what success proves, what it cannot prove, and the next discriminating check.

## Decision path

Use this path when Python automation is failing:

```text
1. Is the promised operation and blast radius known?
   no  -> freeze mutation; identify caller, target, and user impact
   yes -> continue

2. Is runtime identity proven?
   no  -> collect executable, version, package, cwd, env names, uid, namespace
   yes -> continue

3. Did input validate before effects?
   no  -> reject safely; preserve field-level diagnostics; no retry
   yes -> continue

4. Did a local or remote mutation start?
   no  -> classify parser/planner/dependency failure; repair and retest
   yes -> continue

5. Is the outcome authoritative and definite?
   committed -> persist receipt and verify promised result
   rejected/no effect -> consider eligible bounded retry
   unknown -> reconcile by stable operation ID; do not blind retry

6. Is state publication complete and trusted?
   no  -> retain prior known-good state; inspect candidate and concurrency
   yes -> verify consumer readback and record reconciliation

7. Is recovery safe and reversible?
   no  -> reduce scope, add approval, or escalate
   yes -> define actor, target, preconditions, abort, rollback/compensation

8. Did the real operation recover for a sufficient window?
   no  -> reassess first failed boundary
   yes -> document mechanism, contributing conditions, and prevention
```

### Failure classes and default policy

| Class | Examples | Default action |
|---|---|---|
| invalid request | unknown flag, wrong type, forbidden target | reject; caller fixes; no retry |
| permanent dependency rejection | authentication, authorization, schema, policy | stop; correct owner or configuration |
| conflict | version mismatch, already exists with different intent | reread and replan; never overwrite blindly |
| transient definite no-effect | connection refused before send, explicit retryable rejection | bounded retry if budget and idempotency permit |
| unknown mutation outcome | timeout, connection loss after send | reconcile by operation identity |
| resource exhaustion | disk, inode, memory, descriptors, process limit | stop admission, identify resource owner, recover capacity |
| internal defect | invariant violation, unexpected exception | fail closed, preserve traceback, rollback or reconcile |

### Recovery card

Before acting, write:

- **actor:** who or what performs the action;
- **target:** exact resource and namespace;
- **preconditions:** evidence that makes the action valid;
- **blast radius:** maximum users, records, files, or operations affected;
- **abort:** metric or observation that stops the action;
- **rollback:** how local code/config/state returns;
- **compensation:** how committed external effects are handled;
- **verification:** the original promised operation and guardrails;
- **owner:** who accepts remaining risk.

**Decision sentence:** retry only a classified attempt; reconcile an unknown operation; verify the user result.

## Guided Ubuntu lab

The lab at `book/labs/LES-0018-python-automation` is an offline incident simulator. It uses Python only to emit deterministic evidence. It does not call an API, spawn a workload, inspect another process, edit host configuration, install a package, or open a socket.

The lab teaches a production habit through a safe local state machine:

> Write intent, observe one boundary at a time, classify the outcome, reconcile before retry, verify the original operation, and prove cleanup.

### Blast-radius contract

| Property | Lab contract |
|---|---|
| User | normal non-root UID; root is refused |
| Platform | Ubuntu 24.04 or WSL 2 Ubuntu 24.04 |
| Dependencies | Bash, Python 3.8+, and ordinary Ubuntu core utilities |
| Network | none; no socket and no DNS or HTTP request |
| Host configuration | read-only |
| State | one UID-specific descriptor and one random private directory beneath `/tmp` |
| Files | sentinel, manifest, installed model, baseline, case, recovery, verification, cleanup-phase marker |
| Cleanup | resumable exact allowlist, regular-file checks, empty-directory removal; no recursion or glob |

If a guard refuses, stop. Do not use `sudo`, change permissions, manually delete a discovered directory, or edit the descriptor to make the lab proceed. A refusal is evidence that ownership is unknown.

### Preflight

From the lab directory:

```bash
pwd -P
id
bash -n lab.sh verify.sh
PYTHONDONTWRITEBYTECODE=1 python3 -c 'from pathlib import Path; p=Path("fixtures/operation_model.py"); compile(p.read_text(encoding="utf-8"),str(p),"exec")'
bash lab.sh check
```

Expected important fields:

```text
lesson_id=LES-0018
environment=ready
privilege=normal-user
network=none
execution=deterministic_python_model
state=absent
```

`check` creates no state. It validates `/tmp`, the source fixture, and any existing registered state. It also refuses an unregistered directory matching this lesson's prefix because guessing ownership would make cleanup unsafe.

### Establish a baseline

```bash
bash lab.sh setup
bash lab.sh status
bash lab.sh run baseline
```

The baseline describes three validated operations, three receipts, one published checkpoint, and a successful consumer readback. It proves the model's known-good output shape. It does not prove this host has a production API or that your own program is correct.

Before the incident, identify each state owner:

```text
intent and checkpoint  -> modeled local durable state
attempt and timeout    -> modeled Python client
receipt and target     -> modeled authoritative service
published report       -> modeled consumer-visible state
```

### Guided incident: bad boundary handling

Inject the guided case:

```bash
bash lab.sh inject guided
bash lab.sh observe operation
bash lab.sh observe input
bash lab.sh observe runtime
bash lab.sh observe state
bash lab.sh observe outcome
```

Build the diagnosis from evidence:

- the operation promised three terminal receipts and a complete checkpoint;
- raw input contains `max_attempts` as a string rather than an integer;
- the unsafe path treated non-empty input as acceptable and continued;
- one child result was nonzero but a broad handler converted the run to success;
- direct publication exposed two of three records;
- consumer verification reports a mismatch.

The immediate mechanism is not “Python is weakly typed.” Python objects have types. The tool failed to validate external data, collapsed an exception into success, and published before checking invariants. Strong type hints would help reviewers but would not validate JSON at runtime.

The safe modeled recovery validates the input contract, classifies the failed operation, reconstructs the complete candidate from deterministic receipts, validates three unique terminal records, publishes it, and performs a consumer readback. Run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh status
bash lab.sh cleanup
bash lab.sh check
```

Expected verification includes:

```text
operation_success=true
receipt_count=3
duplicate_receipts=0
consumer_readback=valid
verification_scope=deterministic_model_only
```

The fix is not a global `try/except`, an extra retry, or a cast such as `int(value)` without policy. A cast may silently accept values your interface should reject. Validate exact type and range at the input boundary, then keep the internal model typed.

### Independent incident: predict before observing

Start from clean state:

```bash
bash lab.sh setup
bash lab.sh run baseline
bash lab.sh inject independent
bash lab.sh scenario
```

The scenario is intentionally raw. It provides one operation ID, a request deadline, a response-loss timestamp, an intended target version, a configured retry limit, and the local phase visible after interruption. It does not reveal whether the service committed, the diagnosis, or the recovery.

Before running any `observe` command, write:

1. the exact promised operation;
2. which facts belong to the client and which belong to the state owner;
3. at least three possible outcomes: rejected, committed, unknown;
4. why the timeout cannot distinguish them;
5. the first view you want and the observation that would disconfirm your leading hypothesis;
6. whether retry is currently permitted and why;
7. changes you refuse to make without more evidence.

Then gather views:

```bash
bash lab.sh observe operation
bash lab.sh observe input
bash lab.sh observe runtime
bash lab.sh observe state
bash lab.sh observe outcome
```

Interpret carefully. The runtime view proves the modeled client crossed its deadline. The state view may show a local `attempting` phase. Neither is authoritative for the modeled service. The outcome view represents a query by stable operation ID; use it to decide whether to record a receipt or make another attempt eligible.

Complete the ASM-0039 response outside the lab directory. Only after committing to a diagnosis run:

```bash
bash lab.sh recover
bash lab.sh verify-operation
bash lab.sh cleanup
```

Compare your reasoning with the evidence path, not merely with the recovery action. A copied action without state ownership reasoning is not mastery.

### Refusal drills

These should fail safely at invalid stages:

```bash
bash lab.sh status
bash lab.sh scenario
bash lab.sh run incident
bash lab.sh inject unknown
bash lab.sh observe unknown
bash lab.sh verify-operation
```

`verify.sh` also tests an unexpected artifact, installed-model tampering, a symlink aimed at an external file, a descriptor redirected outside the lesson pattern, and an unregistered orphan. Each protected external target must survive unchanged.

### Full verification

From the lab directory as a normal user:

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

Root refusal is a separate review check. The learner should not acquire privilege to test it. An authorized isolated verifier can run `bash lab.sh check` as UID 0 and confirm refusal occurs before state creation.

Passing proves the checked-in lifecycle behaved as asserted in this environment. It does not prove the learner's diagnosis, a real API's idempotency, filesystem crash durability, package supply-chain integrity, or production readiness.

## Production transfer

The same reasoning survives when the runtime changes. The commands and owners do not.

### CI runners

CI adds an orchestrator, image, checkout, cache, secret store, artifact service, and retry policy. Record:

- immutable image or runner identity;
- Python executable and lockfile or package artifact digest;
- checkout revision and whether untrusted pull-request code runs;
- working directory and path filters;
- environment variable names, never secret values;
- cache keys and whether cache contents are trusted;
- artifact upload status and consumer download verification;
- job retry, timeout, cancellation, and concurrency policy.

Build once and promote the same artifact when possible. Re-resolving dependencies in every environment creates drift. Do not use a dependency cache as proof of package integrity. Separate lint, type, unit, integration, packaging, and black-box executable checks so a failure tells you which contract broke.

For pull requests from untrusted contributors, never expose production credentials merely because Python code “only runs tests.” Imports, build backends, test discovery, and package hooks execute code. Use least-privilege tokens, protected environments, approvals, and isolated runners.

### systemd services and timers

systemd defines executable, user, group, directory, environment sources, filesystem permissions, resource limits, restart policy, timeout, and signal flow. A service that succeeds interactively can fail because the unit has no shell profile or uses a different working directory.

Use an absolute interpreter or packaged entry point. Set `WorkingDirectory` only when the program truly needs it. Use `EnvironmentFile` only with correct permissions and remember values can reach child processes. Align `TimeoutStopSec` with Python's graceful shutdown and checkpoint model. Avoid restart loops for permanent invalid configuration and unknown mutation outcomes.

Hardening such as read-only filesystem, private temporary directory, restricted address families, and capability removal can reduce blast radius, but test them. A hardening flag is not valuable if engineers disable the unit during the first incident because required paths were never documented.

### Containers

A container packages user space; it does not remove kernel, filesystem, process, network, and secret boundaries. Use a non-root UID, read-only root filesystem where feasible, explicit writable mounts, a minimal image, pinned base digest policy, and one clear entry point.

PID 1 has signal and child-reaping responsibilities. Ensure TERM reaches Python and that shutdown stops new work, bounds in-flight work, records unknown outcomes, and exits before the platform grace period. Ephemeral container files disappear; durable reconciliation state belongs in a designed external owner, not `/tmp` inside a disposable container.

### Kubernetes Jobs and controllers

Kubernetes can start replacement pods, retry Jobs, evict nodes, and run overlapping revisions. A pod-local file lock coordinates only that pod. Use a database conditional update, lease, queue ownership, or API idempotency feature for distributed work.

Map these boundaries:

```text
Job controller retry
    + Python retry
        + client-library retry
            + proxy retry
                = possible multiplied attempts
```

Choose one retry owner for mutations or prove the composition safe. Set `activeDeadlineSeconds`, backoff policy, parallelism, completion semantics, and termination grace with the Python state machine. Use service accounts with least privilege and namespace-scoped authorization. Keep credentials out of command arguments and logs.

Readiness is usually inappropriate for a short batch tool; completion verification is the key. For a service, readiness means it can serve its contract now, not merely that the interpreter started. Liveness should detect irrecoverable deadlock, not kill a slow dependency call and generate more duplicates.

### Platform and cloud APIs

Provider SDKs add authentication refresh, endpoint discovery, pagination, waiter behavior, retries, and generated exception types. Inspect the SDK's retry policy before adding yours. Use request or operation IDs in logs, conditional resource versions when supported, and official idempotency tokens for mutations.

Pagination is a correctness boundary. Processing only the first page can still exit zero. Verify total counts or continuation exhaustion. Eventual consistency means a successful write may not appear immediately in a read path; define the expected consistency model and bounded verification window rather than looping forever.

Cloud access is outside this local lesson. Transfer on paper first, then use a sandbox account, plan or dry-run facility, budget limits, least privilege, scoped rollout, and cleanup ownership.

### Data and ML operations

Data pipelines add schema evolution, partition ownership, checkpoints, replay, late data, large objects, and expensive compute. Do not load an unbounded dataset merely because Python makes `list(records)` convenient. Stream with durable offsets, validate schemas at boundaries, make writes partition-idempotent, and record input/output lineage.

For model or notebook workflows, package executable transformations outside interactive state. Record code, environment, data version, parameters, model artifact digest, and evaluation. A notebook cell order that works once is not an operational deployment contract.

### Language choice

Python is a strong fit when rich validation, structured data, libraries, tests, and a moderate state machine exceed Bash's comfortable boundary. Python is not automatically the right fit for every agent or data plane. Consider Go, Rust, Java, or another runtime when static binaries, tighter memory bounds, stronger compile-time guarantees, massive concurrency, startup constraints, or organizational support make them safer.

The mature design keeps protocols and state contracts clear enough that the implementation language can change without redefining reliability.

## Reliability, security, observability, capacity, and cost

### Reliability

Define an operation-level service objective for the automation. “Job ran” is weak. Useful indicators include:

- fraction of logical operations reaching verified terminal state;
- age of the oldest unreconciled unknown outcome;
- time from accepted intent to consumer-visible result;
- duplicate and missing receipt rate;
- publication freshness and readback validity;
- resume success after interruption.

Reliability mechanisms include idempotency, conditional updates, durable intent, reconciliation, bounded concurrency, prior-state preservation, and verification. Retries are one small mechanism, not the architecture.

Design graceful degradation. If one tenant is invalid, policy may quarantine that tenant while preserving a nonzero partial-result state rather than aborting all 10,000. If atomic batch semantics are required, do not silently switch to partial success. Make the contract explicit.

### Security

Threat-model input as data that may be malformed or malicious:

- reject unknown CLI options and unexpected JSON keys;
- never use `eval`, `exec`, unsafe deserialization, or `shell=True` with untrusted values;
- use argument vectors and explicit executables;
- constrain paths and refuse symlink surprises;
- limit file and payload sizes before allocation;
- avoid regular-expression denial of service in attacker-controlled patterns;
- use TLS verification and hostname validation in real clients;
- apply least privilege to files, service accounts, and APIs;
- verify dependency provenance and vulnerability policy;
- redact before logs, metrics, traces, crash reports, and error responses.

Python's `pickle` can execute code while deserializing and must not accept untrusted input. YAML libraries have safe and unsafe loaders. Dynamic imports and plugin entry points execute code. Treat build and test dependencies as code, not inert data.

Use secret values only through approved providers. Do not store them in operation manifests or idempotency keys. A deterministic hash of a low-entropy secret may still reveal it through guessing. Correlation IDs should be random or derived from non-secret canonical intent under an approved scheme.

### Observability

Logs answer “what happened in this run?” Metrics answer “how often and how much?” Traces answer “where did one operation spend time across boundaries?”

A structured event might contain:

```json
{
  "timestamp": "2026-08-02T12:34:56.789Z",
  "severity": "INFO",
  "event": "operation_reconciled",
  "run_id": "run-7c2f",
  "operation_id": "op-417",
  "stage": "verify",
  "attempt": 2,
  "result": "committed",
  "duration_ms": 84,
  "code_version": "artifact-digest-or-release"
}
```

Use UTC timestamps for cross-system chronology and monotonic time for duration. Preserve exception type and traceback in protected internal logs for unexpected errors. Give callers a stable error code and correlation ID rather than the full traceback.

Metrics should use bounded labels: operation class, result class, stage, and code version category. Do not label by operation ID, user, URL, exception message, filename, or tenant unless the cardinality and privacy design explicitly permits it.

Alert on impact and stuck state:

- verified success ratio below objective;
- oldest unknown outcome above recovery target;
- duplicate receipt rate nonzero;
- no successful publication for multiple expected intervals;
- queue age or memory above safety threshold;
- sustained dependency rejection by class.

Do not page on every handled retry. That produces noise without an action.

### Capacity

Start with dimensions. If 500 logical operations arrive each minute and average service time is 1.2 seconds, offered concurrency is approximately:

```text
arrival rate = 500 / 60 = 8.33 operations/second
in-flight average = arrival rate * service time
                  = 8.33 * 1.2
                  = 10 operations
```

This is an average, not a safe limit. Bursts, tail latency, retries, and dependency quotas require headroom. If each in-flight operation buffers 8 MiB of output, 50 workers can consume roughly 400 MiB just for those buffers, before interpreter, objects, libraries, and filesystem cache.

Retry amplification example:

```text
logical rate                 100 operations/s
failure fraction             0.40
average extra attempts       2 per failed operation
extra attempt rate           100 * 0.40 * 2 = 80 attempts/s
total attempt rate           180 attempts/s
amplification                1.8x
```

Measure operation rate and attempt rate separately. Add queue length, queue age, worker utilization, dependency latency percentiles, output bytes, memory high-water mark, and cancellation count.

Concurrency is a budget. A semaphore of 20 prevents more than 20 tasks from entering one boundary in that process; it does not cap replicas or other clients. Coordinate local and fleet-wide limits.

### Cost

Operational automation consumes CPU, memory, storage, network, API calls, logs, traces, build minutes, and engineer attention. A verbose per-record INFO log across 100 million records can cost more than the computation and make incident search slower. Sample routine successes, aggregate metrics, retain audit events required by policy, and keep failure evidence sufficient.

Cloud pricing changes and is outside this offline lesson. The durable practice is dimensional:

```text
monthly compute  = executions * average seconds * resource rate
request cost     = attempts * price per request tier
storage cost     = retained bytes * storage rate * retention factor
logging cost     = emitted bytes * ingest/retention/query rates
failure cost     = duplicate effects + missed operations + engineer time
```

Optimize after measuring. Removing operation IDs to save log bytes can destroy reconciliation and increase failure cost. Reliability evidence is not waste; unbounded duplicate evidence is.

### One balanced design review

For every proposed improvement, ask:

- Does it improve the promised user result?
- What new state and failure mode does it add?
- What privilege or secret does it require?
- How will an operator observe it?
- What capacity limit and cost does it introduce?
- How is it disabled, rolled back, or compensated?

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| `except Exception: pass` | hides defect, traceback, and nonzero outcome | catch narrow expected types; fail closed at top boundary |
| retry every exception | repeats permanent and unknown mutations | classify; reconcile unknown; cap eligible retries |
| fresh idempotency key per attempt | makes duplicates look like new work | persist one key per logical intent |
| `shell=True` string | permits shell interpretation and quoting bugs | explicit executable and argument list |
| `check=True` everywhere | turns status into exception without domain classification | inspect documented statuses and semantic result |
| status zero means success | process status is not user outcome | verify schema, count, receipt, and real operation |
| direct final-file write | readers observe truncation or partial output | private same-directory candidate, validate, replace |
| `Path.resolve()` means safe | pathname can race and authorization is separate | trusted parent, grammar, descriptors/no-follow where needed |
| temporary file with predictable name | collisions and symlink attacks | secure random creation and restrictive mode |
| cleanup by prefix or glob | can remove another run's state | registered immutable root and exact allowlist |
| local lock means distributed lock | other hosts and noncooperators bypass it | state-owner transaction, lease, or conditional update |
| environment is trusted config | ambient strings drift and may expose secrets | read once, validate, pass typed configuration |
| import-time effects | discovery and tests unexpectedly mutate | explicit `main`, dependency construction after validation |
| mutable default argument | state leaks across calls | use `None` or immutable default |
| count a generator then reuse | one-pass iterator is exhausted | stream once or bounded materialization |
| mock-only test suite | fake behavior may not match real dependency | contract and integration tests at real boundaries |
| sleep-based test | timing races make tests slow and flaky | inject clock/sleeper and deterministic outcomes |
| unbounded captured output | child can exhaust memory | byte limits, streaming, controlled file, kill policy |
| metric label per tenant/error | cardinality and cost explode | bounded enums; IDs in controlled logs/traces |
| unpinned mutable dependency resolution | builds drift or ingest compromised code | reviewed lock/artifact/provenance policy |
| rollback means redeploy old code | accepted external effects remain | inventory operation IDs and reconcile/compensate |

### Prevention pipeline

Use layered gates:

1. format and syntax checks;
2. lint rules for correctness and security-relevant patterns;
3. static type checking for internal contracts;
4. unit tests of pure parsing, validation, planning, and classification;
5. property or fuzz tests for hostile structured input within resource bounds;
6. black-box CLI tests of status, stdout, stderr, files, and signals;
7. adapter contract tests for subprocess and API semantics;
8. filesystem failure and interruption injection around every commit boundary;
9. concurrent-run and stale-version tests;
10. timeout-after-effect reconciliation and duplicate prevention;
11. secret-redaction tests, including exception paths;
12. package build, clean-environment install, entry-point, and provenance checks;
13. canary rollout with abort metrics and real operation verification.

Pinning every byte forever is not a maintenance strategy. Define how dependencies are selected, reviewed, rebuilt, scanned, tested, promoted, and rolled back. Record hashes or provenance for artifacts that cross trust boundaries.

### Code review questions

Ask these before approving an operational tool:

- What happens before validation?
- Which inputs can contain secrets or attacker-controlled text?
- Can a timeout occur after a side effect?
- Is logical operation identity durable across restarts?
- Which exceptions are expected and which indicate defects?
- Can two invocations overlap?
- Can output or input exhaust memory or disk?
- What previous state survives a failed commit?
- Can cleanup prove ownership without a wildcard?
- Which controller also retries or restarts?
- What verifies the user-visible result?
- What evidence would a second engineer have during an incident?

## Memory card and retrieval

Use **T-Y-P-E-D** when a Python tool fails:

```text
T  Target and runtime
   promised operation, interpreter, package, uid, cwd, namespace

Y  Yielded evidence
   raw input type, exception/status, timestamps, receipts, readback

P  Persisted intent
   stable operation ID, normalized digest, phase, owner, prior state

E  Effect outcome
   rejected, committed, transient no-effect, conflict, or unknown

D  Decide and demonstrate
   reconcile, bounded recovery, verify real result, prove cleanup
```

### Five sentences to remember

1. A type hint documents internal intent; runtime validation protects the boundary.
2. A zero exit status proves only the process's reported contract, not the user's result.
3. A timeout after mutation is unknown until the state owner answers.
4. Atomic local replacement is not a distributed transaction or automatic crash durability.
5. The safest cleanup removes only exact state the current invocation can prove it owns.

### Thirty-second incident card

```text
Impact:      which promised operation and how many users/items?
Runtime:     executable, version, artifact, identity, cwd, namespace?
Boundary:    parse, validate, plan, file, child, API, controller, verify?
Outcome:     known rejection, known commit, conflict, or unknown?
Evidence:    operation ID, status/exception, receipt, state query, readback?
Action:      actor, target, preconditions, blast radius, abort, rollback?
Proof:       original operation, duplicates, missing work, guardrail window?
```

### Retrieval exercise

Close the lesson and explain:

- why `shell=False` is necessary but insufficient;
- why `except Exception` can be valid only at one narrow boundary;
- why `os.replace` protects visibility but not an API effect;
- why a Kubernetes retry changes your Python retry design;
- how to distinguish a failed attempt from an unknown outcome.

If one answer is vague, return to the corresponding state owner rather than memorizing more syntax.

## Complete answers

### Question 1: Why does a Python tool work locally but import the wrong code in CI?

**Direct answer:** The launcher selected a different interpreter or import path. Local activation, current directory, editable install, user site, or cached workspace may make a module visible that the clean runner does not have—or a same-named local file may shadow the intended package.

**Evidence path:** Capture `sys.executable`, `sys.version`, `sys.prefix`, `sys.path`, application `module.__file__` when safe, distribution metadata, working directory, runner image, checkout revision, and install command. Compare facts; do not add `sys.path.append` as a guess.

**Fix:** Build a versioned package, test installation in a clean environment, invoke its declared entry point using the intended interpreter, lock or constrain dependencies according to policy, and print a non-secret `--version` with artifact identity.

**Verification:** The clean runner imports the expected file, executable black-box tests pass, the built artifact digest is promoted unchanged, and runtime telemetry reports the expected version.

### Question 2: Should every external call use `check=True`?

**Direct answer:** No. `check=True` is useful when any nonzero status means this layer cannot continue and exception translation is appropriate. Many tools use nonzero statuses for expected outcomes such as “not found,” “differences exist,” or “lock busy.” The adapter must interpret the command's documented status table.

Use `check=False`, capture the result, and convert known statuses into a bounded domain enum when multiple outcomes are expected. Raise for unexpected statuses with safe stdout/stderr excerpts and context. In either case, verify semantic output before declaring success.

### Question 3: How should I catch exceptions?

Catch the narrowest expected exception at the layer that can decide. A JSON adapter catches `JSONDecodeError` and raises `InvalidManifest` with a field-safe location. A subprocess adapter handles `FileNotFoundError`, `TimeoutExpired`, and known return codes separately. A coordinator catches domain outcomes to decide reject, retry, reconcile, or abort.

At the top-level executable boundary, a broad `except Exception` can be appropriate to log the full traceback internally with `logger.exception`, emit a sanitized correlation ID, and return a nonzero internal-error code. It must not catch `BaseException`, hide cancellation/system exit blindly, report success, or continue mutations with broken invariants.

### Question 4: What exactly should happen after a mutating request times out?

1. Stop automatic blind replay.
2. Mark the durable intent as unknown with the same operation ID and attempt timing.
3. Query the authoritative owner by operation ID or a documented state/version predicate.
4. If committed, store the receipt and verify the target.
5. If definitively absent and the error is classified transient, retry within the remaining budget using the same logical ID.
6. If still unknown, stop and escalate; do not invent certainty.
7. Verify the real operation, duplicate count, and missing work.

Increasing the timeout may reduce frequency but does not solve ambiguous outcomes.

### Question 5: How do I safely write a JSON checkpoint?

Use a trusted real parent and restrictive creation. Serialize a normalized schema with explicit UTF-8. Create a private random candidate in the same directory, write complete bytes, flush, and use `os.fsync` if your durability requirement needs it. Reopen or parse the candidate and validate required counts and unique IDs. Use `os.replace` to change the final name atomically on the same filesystem. If crash durability requires it and the platform supports the contract, synchronize the directory. Finally read the final file as a consumer and verify its digest or invariants.

Retain the prior known-good version or backup according to rollback policy. This does not make a remote side effect transactional.

### Question 6: Does the GIL prevent race conditions?

No. The GIL is an implementation mechanism around execution of Python bytecode in one CPython process. Compound logic such as “read version, compute, write version” can interleave between threads and certainly races with processes, containers, hosts, and services. I/O releases execution opportunities, and extension modules have their own behavior.

Protect invariants with a lock or conditional update at the state owner. Define scope and contenders. Test overlapping operations. Never use the GIL as a correctness claim.

### Question 7: Threads, processes, or asyncio?

Choose from the workload and dependency contract:

- threads can suit blocking I/O libraries and share memory, but need synchronization and bounded pools;
- processes can suit CPU-bound work and isolate memory, but serialization, startup, and state coordination cost more;
- asyncio suits many cooperative I/O operations when libraries are async and every blocking call is controlled, but cancellation and task lifetime require explicit design.

None removes idempotency, deadlines, backpressure, rate limits, or state ownership. Start sequentially, measure, then add the smallest bounded concurrency that meets the objective.

### Question 8: How should retries be implemented?

The coordinator should call an adapter that performs one attempt and returns a classified outcome. Use one overall monotonic deadline, a maximum attempt count, exponential or policy-driven backoff, jitter, and a retry budget. Respect service guidance. Retry only outcomes documented as transient and safe. Authentication, authorization, invalid input, and deterministic conflict are not healed by time. Unknown mutation outcomes go to reconciliation.

Expose logical operation count, attempt count, retry reasons, delay, and exhausted budget. Test with an injected clock and sleeper; do not make unit tests sleep.

### Question 9: What is a production-quality CLI contract?

It has a stable entry point, help and version, explicit subcommands and options, reject-by-default parsing, documented stdin/stdout/stderr, stable machine output when promised, stable exit categories, noninteractive behavior, deadline and cancellation semantics, configuration precedence, secret policy, dry-run limitations, idempotency model, concurrency policy, and examples.

It also states what success means. `exit 0` should mean the promised operation reached its declared verification boundary, not merely that Python reached the end of `main`.

### Question 10: How do I test operational automation?

Test in layers. Pure unit tests cover normalization, validation, planning, classification, and state transitions. Black-box tests run the executable and assert streams, statuses, and files. Adapter contract tests simulate each documented status and verify mapping. Integration tests use controlled real dependencies. Failure injection targets every transition: input read, candidate write, replace, receipt persistence, timeout after effect, lock contention, interruption, resume, and cleanup.

Add hostile data, large-boundary inputs, two concurrent invocations, redaction assertions, repeat-run idempotency, and consumer readback. A green test suite is scoped evidence, not a proof of all production behavior.

### Question 11: How do I prevent secrets in logs?

Design log schemas with an allowlist of safe fields. Keep secret-bearing objects separate from printable configuration. Never rely only on a regex after formatting; structured values may appear in exception text, URLs, headers, subprocess arguments, library debug logs, or object `repr`. Disable verbose transport logging around credentials, sanitize errors at adapter boundaries, and test representative failure paths with sentinel secret values that must never appear.

If a real secret appears, do not repeat it in the incident ticket. Rotate through the credential owner and follow retention and breach procedures.

### Question 12: When should Bash hand work to Python?

Move the core to Python when structured data, reusable validation, exception classification, testable state machines, API libraries, concurrency, or long-term interfaces dominate over simple command orchestration. Keep Bash as a small launcher if it still adds value. Do not rewrite solely because a script is long; use defect rate, change risk, data complexity, and state-machine clarity.

Python does not erase operational design. A poorly bounded Python program can hide more complexity than a small honest shell script.

## Product-company interview

### Interview prompt

“Design a Python reconciliation service that runs in Kubernetes, reads desired deployment state, calls an external control-plane API, survives pod replacement, prevents duplicate mutations, publishes an audit report, and serves 10,000 tenants. Explain code structure, correctness, security, observability, testing, capacity, rollout, and incident response.”

### Strong answer shape

Start with the contract and failure model. One logical reconciliation has a stable operation ID derived or issued from canonical non-secret intent. Desired state is validated into an immutable model. The authoritative current state is read with version information. A pure planner returns no-op or conditional operations. Before a mutation, durable intent is recorded in an external store because pod files are ephemeral.

An effect adapter performs one deadline-bounded attempt and returns accepted, rejected, conflict, transient-no-effect, or unknown. The external API receives the stable idempotency key or conditional version. A timeout becomes unknown and is queried by operation ID before retry. Retry has one owner, capped attempts, an overall monotonic deadline, backoff, jitter, and a fleet budget. Kubernetes Job or controller retries are incorporated rather than stacked invisibly.

Concurrency is bounded per pod and across the fleet using queue ownership, leases, or conditional state transitions. Tenant fairness and dependency quotas prevent a large tenant from monopolizing workers. Per-tenant operations can proceed independently only if the product contract permits partial progress; otherwise batch atomicity needs a state owner that actually supports it.

The code separates adapters, typed domain models, pure planning, state-machine persistence, effect clients, verification, and executable translation. External input is runtime-validated. No `shell=True`, unsafe deserialization, or untrusted dynamic import exists. Service accounts use least privilege. Secrets come from the platform and never enter operation records or logs.

State transitions and receipts are durable. Audit output is built as a validated candidate and published with a versioned object or transactional database update. Every completion verifies the real control-plane state and records missing or duplicate operations.

Telemetry includes logical operations, attempts, outcome class, queue age, oldest unknown, reconciliation latency, dependency latency, rate-limit response, duplicate/missing receipts, and verified completion. Metrics use bounded labels; operation and tenant IDs live in controlled logs or traces. Alerts follow user impact and stuck unknown state.

Capacity begins with arrival rate, service time, tail latency, memory per in-flight item, payload size, retry amplification, and API quotas. Backpressure limits admission. Pagination, streaming, and checkpointing avoid loading all tenants. Load tests include slow and failing dependencies, not only successful throughput.

Testing covers pure state transitions, schema boundaries, API contract fixtures, timeout after commit, duplicate delivery, conflict, pagination, pod interruption, lease expiry, concurrent workers, secret redaction, report publication, and full user-operation verification. Rollout uses shadow planning, canary tenants, concurrency caps, abort thresholds, and a kill switch. Rollback stops new mutations but also inventories operation IDs and reconciles already accepted work.

During an incident, freeze blind retries, preserve operation IDs and code version, quantify affected tenants, classify known versus unknown outcomes, reconcile at the API owner, recover a bounded cohort, verify user operations and duplicates, then expand. Root cause identifies the first violated contract; “the pod restarted” is a trigger, not enough cause.

### Weak answer

“Use FastAPI, requests, ten threads, try/except, three retries, and a Kubernetes Job. Store progress in a file and scale replicas when slow.”

Why it is weak: it names technologies without defining state ownership. Pod files disappear. Replicas race. A timeout can duplicate mutations. Threads and retries multiply load. Broad exception handling destroys classification. There is no durable intent, idempotency, conditional update, verification, secret model, capacity calculation, testing, or rollback of accepted work.

### Follow-up questions and concise answers

**What if the API has no idempotency or lookup by request ID?** Then the client cannot guarantee safe automatic replay after an unknown outcome. Use a read-before/write-after state predicate if it uniquely proves effect, serialize through an owner that can deduplicate, redesign the API, or require human reconciliation. Say the limitation plainly.

**Why not use exactly-once delivery?** “Exactly once” usually hides assumptions. Queues commonly provide at-least-once delivery; consumers obtain effectively-once effects through stable identity, deduplication, idempotent state transitions, transactions within one owner, and reconciliation.

**How do you prevent a stuck worker from holding a lease forever?** A lease expires according to owner time, includes fencing or version tokens, and is renewed only by the current holder. A stale holder's writes are rejected by the state owner after another holder obtains a newer fence.

**How do you roll out a state-machine schema change?** Make readers tolerate the old version, write an explicit migration, test interruption at every migration step, deploy compatible readers first, canary writes, retain rollback readability, and never reuse a state name with incompatible meaning.

**What makes the answer senior?** It connects code decisions to user outcomes, failure semantics, state ownership, bounded resource usage, evidence, and recovery instead of treating a library choice as architecture.

## Independent transfer and rubric

Complete ASM-0039 using only the independent lab case. The assessment is answer-isolated: it contains deliverables and evidence requirements but no model diagnosis. Store your response outside the guarded lab directory.

### Required workflow

1. Run preflight and record runtime scope.
2. Set up and record the baseline.
3. Inject `independent` and capture `scenario`.
4. Write your prediction before any observation view.
5. Gather the minimum views needed to discriminate hypotheses.
6. Classify every claim as observation, documented model fact, calculation, inference, hypothesis, or unknown.
7. Propose a recovery card with actor, target, preconditions, blast radius, abort, rollback or compensation, and verification.
8. Recover only after committing to the plan.
9. Verify the original operation and duplicate count.
10. Run full verification and prove cleanup.

### Reviewer rubric summary

| Area | Strong evidence | Points |
|---|---|---:|
| scope and prediction | exact runtime, operation, owners, competing hypotheses before derived views | 10 |
| Python mechanism | validation, exception, subprocess, timeout, typing, and publication boundaries accurately explained | 10 |
| state and recovery | unknown outcome, durable operation ID, reconciliation, retry eligibility, rollback/compensation | 10 |
| verification and safety | real operation, duplicates, prior state, concurrency, cleanup/refusal, proves/does-not-prove | 10 |
| production transfer | CI/Kubernetes identity, durable state, secrets, observability, capacity, rollout | 10 |

Maximum: 50. A verifier pass does not earn these points. A reviewer must examine the learner's evidence and reasoning.

### Mastery signals

A strong learner:

- refuses to retry an unknown mutation;
- separates Python exception from remote truth;
- validates external values instead of trusting annotations;
- distinguishes process status, artifact publication, and user outcome;
- explains the exact scope of locks and atomic replacement;
- gives proof limits without weakening the diagnosis;
- transfers the model without claiming the offline lab tested Kubernetes or cloud behavior.

## References and review

This lesson uses the authoritative references registered as REF-0097 through REF-0104. They cover the Python execution model and exceptions, command-line parsing, subprocess boundaries, filesystem paths, JSON, logging, temporary state, and modern project metadata. The prose paraphrases them; the chapter does not reproduce long source passages.

Reference use map:

| Reference | Use in this lesson |
|---|---|
| REF-0097 | language execution, objects, exceptions, `with`, imports |
| REF-0098 | explicit CLI grammar and errors |
| REF-0099 | argument vectors, statuses, streams, timeouts, security notes |
| REF-0100 | path operations and their scope |
| REF-0101 | JSON parsing and serialization limits |
| REF-0102 | logging hierarchy, exception information, configuration |
| REF-0103 | secure temporary files and directories |
| REF-0104 | `pyproject.toml`, build-system and project metadata contracts |

### Review boundaries

- Last reviewed: 2026-08-02.
- Review after: 2027-02-02.
- Recheck the supported Ubuntu Python version, standard-library behavior, packaging specifications, and lab verifier at review time.
- Re-run syntax, schema, ShellCheck, normal-user lifecycle, root refusal, answer-isolation, cleanup, name, encoding, and generated-residue checks after any content or script change.
- Real cloud SDK retry policies, Kubernetes controller behavior, security guidance, dependency tooling, and pricing are intentionally not frozen by this provider-neutral offline chapter; verify their current official documentation before production use.

### Final perspective

The valuable Python engineer is not the person who can write the shortest script. It is the person who can explain what every boundary owns, make invalid states hard to represent, make failures visible without leaking secrets, stop ambiguity from becoming duplicate work, and leave enough evidence that the next engineer can recover safely.

The chapter gives you a map. Mastery still requires repeated independent incidents, code review, production feedback, and the discipline to say “unknown” until the state owner provides evidence.
